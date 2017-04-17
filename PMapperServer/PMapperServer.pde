import java.awt.*;
import java.util.*;
import processing.video.*;
import gohai.glvideo.*;

Mode mode = Mode.EDIT_SCENE;
float scale;
float invScale;
float VERTEX_SIZE;
float VERTEX_SIZE_SQUARED;
float BORDER_SIZE;
float NUDGE = 0.25;
int previousNudge;

Set<Vertex> selection = new HashSet<Vertex>();
PGraphics selectionBuffer;
Selectable toSelect;
boolean clearSelection;

boolean highlightBackground;

Scene scene;
PShader texShader;
boolean useGLMovie;
color shapeColors[] = {
  #4080ff,
  #ff4080,
  #80ff40,
  #8040ff,
  #ff8040,
  #40ff80
};

void setup() {
  //fullScreen(P2D);
  size(1280, 800, P2D);
  selectionBuffer = createGraphics(width, height, P2D);
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
}

void draw() {
  background(highlightBackground ? #ff0000 : 0);
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