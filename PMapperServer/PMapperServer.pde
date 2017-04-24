import java.awt.*;
import java.util.*;
import processing.net.*;
import processing.video.*;
import gohai.glvideo.*;

Mode mode = Mode.PRESENTATION;
float scale;
float invScale;
float VERTEX_SIZE;
float VERTEX_SIZE_SQUARED;
float BORDER_SIZE;
float NUDGE = 0.25;
int previousNudge;

Set<Vertex> selection = new HashSet<Vertex>();
boolean clearSelection;

boolean highlightBackground;

Scene scene;
PShader texShader;
boolean useGLMovie;
color shapeColors[] = {
  #2040a0,
  #a02040,
  #40a020,
  #4020a0,
  #a04020,
  #20a040
};

Server server;
Client controller;

void setup() {
  //fullScreen(P2D);
  size(1280, 800, P2D);
  ellipseMode(RADIUS);
  textureMode(NORMAL);
  scale = min(width, height) / 2.0;
  invScale = 1.0 / scale;

  VERTEX_SIZE = 5.0 * invScale;
  VERTEX_SIZE_SQUARED = VERTEX_SIZE * VERTEX_SIZE;
  BORDER_SIZE = invScale;
  
  texShader = loadShader("quadtexfrag.glsl", "quadtexvert.glsl");
  
  useGLMovie = System.getProperty("os.arch").equals("arm");
  
  loadScene("scene.json");
  play();
  
  server = new Server(this, 2540);
}

void draw() {
  getClientUpdates();
  
  background(mode != Mode.PRESENTATION ? #ff0000 : 0);
  noStroke();

  translate(width / 2, height / 2);
  scale(scale);
  
  scene.draw();
  
  if (mode != Mode.PRESENTATION) {
    drawHandles();
  }
}

void exit() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).stop();
    }
  }
  
  server.stop();
  super.exit();
}

void drawHandles() {
  scene.drawHandles();
}

void clearSelection() {
  selection.clear();
}

void createQuad() {
  Quad r = new Quad(new Vertex(-0.25, -0.25), new Vertex(-0.25, 0.25), new Vertex(0.25, 0.25), new Vertex(0.25, -0.25), shapeColors[scene.shapes.size() % shapeColors.length]);
  scene.addQuad(r);
  r.setName("Quad " + scene.shapes.size());
}

Vertex getSelectedVertex() {
  if (selection.size() != 1) {
    return null;
  }

  return selection.iterator().next();
}

Quad getSelectedShape() {
  Set<Quad> selectedShapes = new HashSet<Quad>();
  for (Vertex v : selection) {
    selectedShapes.addAll(v.shapes);
  }
  
  Iterator<Quad> it = selectedShapes.iterator();
  while (it.hasNext()) {
    boolean allSelected = true;
    Quad r = it.next();
    for (Vertex v : r.corners) {
      if (!selection.contains(v)) {
        allSelected = false;
        break;
      }
    }
    
    if (!allSelected) {
      it.remove();
    }
  }
  
  if (selectedShapes.size() == 1) {
    return selectedShapes.iterator().next();
  }
  
  return null;
}

void play() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).play();
    }
  }
}

void pause() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).pause();
    }
  }
}

void rewind() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).rewind();
    }
  }
}

void serverEvent(Server server, Client client) {
  if (controller != null) {
    server.disconnect(client);
  } else {
    controller = client;
    client.write(scene.toJSON().toString());
    mode = Mode.EDIT_SCENE;
  }
}

void disconnectEvent(Client client) {
  if (client == controller) {
    mode = Mode.PRESENTATION;
    controller = null;
  }
}

void getClientUpdates() {
  if (controller == null || controller.available() == 0) {
    return;
  }
  
  boolean inProgress = true;
  int level = 0;
  StringBuilder sb = new StringBuilder();
  
  while (inProgress) {
    int b = controller.read();
    if (b == -1) {
      try {
        Thread.sleep(10);
      } catch(InterruptedException ie) {
      }
      continue;
    } else if (b == '{') {
      level++;
    } else if (b == '}') {
      level--;
    }
    
    sb.append((char) b);
    
    inProgress = level > 0;
  }
  
  JSONObject msg = parseJSONObject(sb.toString());
  
  switch (msg.getString("type")) {
    case "select":
      select(msg);
      break;
    case "nudge":
      nudge(msg);
      break;
    case "move":
      move(msg);
      break;
    case "play":
      play();
      break;
    case "pause":
      pause();
      break;
    case "rewind":
      rewind();
      break;
  }
}

void select(JSONObject msg) {
  clearSelection();
  
  JSONArray select = msg.getJSONArray("selection");
  for (int i = 0; i < select.size(); i++) {
    selection.add(scene.getVertex(select.getInt(i)));
  }
}

void nudge(JSONObject msg) {
  boolean left = msg.getBoolean("left");
  boolean right = msg.getBoolean("right");
  boolean up = msg.getBoolean("up");
  boolean down = msg.getBoolean("down");
  
  JSONObject reply = new JSONObject();
  JSONArray positions = new JSONArray();
  int i = 0;
  reply.setJSONArray("positions", positions);
  
  float x = 0;
  float y = 0;
  if (left) {
    x -= NUDGE * invScale;
  }
  
  if (right) {
    x += NUDGE * invScale;
  }
  
  if (up) {
    y -= NUDGE * invScale;
  }
  
  if (down) {
    y += NUDGE * invScale;
  }
  
  for (Vertex v : selection) {
    v.x += x;
    v.y += y;
    
    for (Quad s : v.shapes) {
      s.dirty = true;
    }
    
    JSONObject pos = new JSONObject();
    pos.setInt("vertex", scene.indexOf(v));
    pos.setFloat("x", v.x);
    pos.setFloat("y", v.y);
    positions.setJSONObject(i, pos);
  }
  
  controller.write(reply.toString());
}

void move(JSONObject msg) {
  float x = msg.getFloat("x");
  float y = msg.getFloat("y");
  
  for (Vertex v : selection) {
    v.x += x;
    v.y += y;
    
    for (Quad s : v.shapes) {
      s.dirty = true;
    }
  }
}

void loadScene(File f) {
  if (f == null) {
    return;
  }
  
  if (!f.exists()) {
    loadScene(f.getName());
    return;
  }

  Scene scene = new Scene();
  scene.fromJSON(loadJSONObject(f));
  this.scene = scene;
}

void loadScene(String filename) {
  if (filename == null) {
    return;
  }
  
  Scene scene = new Scene();
  scene.fromJSON(loadJSONObject(filename));
  this.scene = scene;
}

Texture loadTexture(File f) {
  return loadTexture(f, scene);
}

Texture loadTexture(String filename) {
  return loadTexture(filename, scene);
}

Texture loadTexture(File f, Scene scene) {
  if (f == null) {
    return null;
  }
  
  if (f.exists()) {
    return loadTexture(f.getAbsolutePath(), scene);
  } else {
    return loadTexture(f.getName(), scene);
  }
}

Texture loadTexture (String filename, Scene scene) {
  if (scene.textures.containsKey(filename)) {
    return scene.textures.get(filename);
  }
  
  PImage img = loadImage(filename);
  String name = filename.substring(max(0, max(filename.lastIndexOf('/'), filename.lastIndexOf('\\'))));
  Texture t = null;
  if (img != null && img.width >= 0) {
    t = new ImageTexture(img, name);
  } else if (useGLMovie) {
    t = new GLMovieTexture(new GLMovie(this, filename), name);
  } else {
    t = new PMovieTexture(new Movie(this, filename), name);
  }
  
  scene.addTexture(t, filename);

  for (Quad s : scene.shapes) {
    Collection<Vertex> verts = (Collection<Vertex>) s.getVertices();
    if (selection.containsAll(verts) && verts.containsAll(selection)) {
      s.setTexture(t);
    }
  }
  
  return t;
}