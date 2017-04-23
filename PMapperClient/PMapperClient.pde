import java.awt.*;
import java.util.*;
import processing.net.*;
import processing.video.*;
import gohai.glvideo.*;

boolean left;
boolean right;
boolean up;
boolean down;
boolean shiftDown;
Vertex mousePosition;
Vertex serverDelta = new Vertex(0, 0);
int previousMove;

Mode mode = Mode.EDIT_SCENE;
float scale;
float invScale;
float VERTEX_SIZE;
float VERTEX_SIZE_SQUARED;
float BUTTON_SIZE;
float BUTTON_SIZE_SQUARED;
float BORDER_SIZE;

Set<Vertex> selection = new HashSet<Vertex>();
Vertex selectedVertex;
PGraphics selectionBuffer;
Selectable toSelect;
boolean clearSelection;

Toolbar tools = new Toolbar(new Vertex(-0.9, -0.9));
Toolbar videoControls = new Toolbar(new Vertex(-0.9, 0.9));
LayerWindow shapeWindow;
PFont font;
PImage icons;
boolean highlightBackground = true;

Scene scene = new Scene();
boolean useGLMovie;
color shapeColors[] = {
  #2040a0,
  #a02040,
  #40a020,
  #4020a0,
  #a04020,
  #20a040
};

Client client;

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
  BUTTON_SIZE = 10.0 * invScale;
  BUTTON_SIZE_SQUARED = BUTTON_SIZE * BUTTON_SIZE;
  BORDER_SIZE = invScale;
  
  icons = loadImage("Icons.png");
  tools.addTool("Merge", new Button(new Vertex(3.0 / 6.0, 0), new Runnable() { public void run() { merge(); }}));
  tools.addTool("Split", new Button(new Vertex(4.0 / 6.0, 0), new Runnable() { public void run() { split(); }}));
  tools.addTool("Background", new Button(new Vertex(3.0 / 6.0, 0.5), new Runnable() { public void run() { highlightBackground = !highlightBackground; }}));
  tools.disableTool("Merge");
  tools.disableTool("Split");

  videoControls.addTool("Play", new Button(new Vertex(0, 1.0 / 2.0), new Runnable() { public void run() { play(); }}));
  videoControls.addTool("Pause", new Button(new Vertex(1.0 / 6.0, 1.0 / 2.0), new Runnable() { public void run() { pause(); }}));
  videoControls.addTool("Rewind", new Button(new Vertex(2.0 / 6.0, 1.0 / 2.0), new Runnable() { public void run() { rewind(); }}));
  
  font = createFont("Verdana", 10);
  textFont(font);
  shapeWindow = new LayerWindow("Shapes", new Vertex(width / (scale * 2) - 0.3, -0.5));
  
  useGLMovie = System.getProperty("os.arch").equals("arm");
  
  client = new Client(this, "localhost", 2540);
  scene.fromJSON(readMessage());
}

void draw() {
  background(highlightBackground ? #ff0000 : 0);
  noStroke();

  translate(width / 2, height / 2);
  scale(scale);
  
  
  if (mode != Mode.PRESENTATION) {
    move();
  }
  
  if (mode != Mode.EDIT_UVS) {
    scene.draw();
  }
  
  if (mode != Mode.PRESENTATION) {
    drawHandles();
    drawButtons();
    shapeWindow.draw();
  }

  mousePosition = null;
}

void move() {
  if (frameCount - previousMove < 5 || !(left || right || up || down)) {
    return;
  }
  
  // SEND nudge to server
  JSONObject msg = new JSONObject();
  msg.setString("type", "nudge");
  msg.setBoolean("left", left);
  msg.setBoolean("right", right);
  msg.setBoolean("up", up);
  msg.setBoolean("down", down);
  sendMessage(msg);
  
  msg = readMessage();
  JSONArray positions = msg.getJSONArray("positions");
  for (int i = 0; i < positions.size(); i++) {
    JSONObject position = positions.getJSONObject(i);
    int index = position.getInt("vertex");
    float x = position.getFloat("x");
    float y = position.getFloat("y");
    
    Vertex v = scene.getVertex(index);
    v.x = x;
    v.y = y;
  }
  
  previousMove = frameCount;
}

void exit() {
  client.stop();
  super.exit();
}

void drawHandles() {
  if (mode == Mode.EDIT_SCENE) {
    scene.drawHandles();
  }
  
  tools.position.drawHandle();
  videoControls.position.drawHandle();
  shapeWindow.position.drawHandle();
}

void drawButtons() {
  tools.draw();
  videoControls.draw();
}

Vertex getMousePosition() {
  if (mousePosition == null) {
    mousePosition = new Vertex((mouseX - width / 2.0) * invScale, (mouseY - height / 2.0) * invScale);
  }

  return mousePosition;
}

void mousePressed() {
  Vertex mouse = getMousePosition();
  if (selectionHasTools()) {
    selection.clear();
  }
  toSelect = scene.grab(mouse.x, mouse.y);
  
  if (toSelect == null && !shiftDown) {
    if (tools.position.grab(mouse.x, mouse.y)) {
      toSelect = tools.position;
    } else if (videoControls.position.grab(mouse.x, mouse.y)) {
      toSelect = videoControls.position;
    } else if (shapeWindow.position.grab(mouse.x, mouse.y)) {
      toSelect = shapeWindow.position;
    } else {
      clearSelection = true;
    }
  }
}

boolean selectionHasTools() {
  return selection.contains(tools.position)
    || selection.contains(videoControls.position)
    || selection.contains(shapeWindow.position);
}

void select() {
  if (toSelect == null && !clearSelection) {
    enableContextSensitiveTools();
    return;
  }
  
  if (clearSelection) {
    clearSelection();
  } else if (shiftDown) {
    toggleSelection(toSelect.getVertices());
  } else {
    clearSelection();
    for (Vertex v : toSelect.getVertices()) {
      selection.add(v);
    }
  }
  
  selectedVertex = selection.size() == 1 ? selection.iterator().next() : null;
  
  JSONObject msg = new JSONObject();
  JSONArray selected = new JSONArray();
  int i = 0;
  msg.setString("type", "select");
  msg.setJSONArray("selection", selected);
  
  for (Vertex v : selection) {
    for (Quad s : v.shapes) {
      shapeWindow.addSelected(s);
    }
    
    selected.setInt(i++, scene.indexOf(v));
  }
  
  toSelect = null;
  clearSelection = false;
  enableContextSensitiveTools();
  sendMessage(msg);
}

void clearSelection() {
  shapeWindow.clearSelection();
  selection.clear();
}

void toggleSelection(Iterable<Vertex> vertexIterator) {
  ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  for (Vertex v : vertexIterator) {
    vertices.add(v);
  }

  if (selection.containsAll(vertices)) {
    selection.removeAll(vertices);
  } else {
    selection.addAll(vertices);
  }
}

void mouseDragged() {
  float dX = (mouseX - pmouseX) * invScale;
  float dY = (mouseY - pmouseY) * invScale;
  serverDelta.x += dX;
  serverDelta.y += dY;
  select();

  for (Vertex v : selection) {
    v.x += dX;
    v.y += dY;
  }

  tools.disableTool("Merge");
  if (selectedVertex != null) {
    snap();
  }
  
  if (frameCount - previousMove >= 5) {
    sendMove();
  }  
}

void mouseClicked() {
  if (tools.click() || videoControls.click()) {
    return;
  }
  
  shapeWindow.click();
  
  select();
}

void mouseReleased() {
  if (serverDelta.x != 0 || serverDelta.y != 0) {
    sendMove();
  }
}

void sendMove() {
  JSONObject msg = new JSONObject();
  msg.setString("type", "move");
  msg.setFloat("x", serverDelta.x);
  msg.setFloat("y", serverDelta.y);
  sendMessage(msg);
  
  serverDelta.x = 0;
  serverDelta.y = 0;
  previousMove = frameCount;

}

void keyPressed() {
  shiftDown |= keyCode == SHIFT;
  left |= keyCode == LEFT;
  right |= keyCode == RIGHT;
  up |= keyCode == UP;
  down |= keyCode == DOWN;
}

void keyReleased() {
  shiftDown ^= keyCode == SHIFT;
  left ^= keyCode == LEFT;
  right ^= keyCode == RIGHT;
  up ^= keyCode == UP;
  down ^= keyCode == DOWN;
}

void createQuad() {
  Quad r = new Quad(new Vertex(-0.25, -0.25), new Vertex(-0.25, 0.25), new Vertex(0.25, 0.25), new Vertex(0.25, -0.25), shapeColors[scene.shapes.size() % shapeColors.length]);
  scene.addQuad(r);
  r.setName("Quad " + scene.shapes.size());
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

void snap() {
  if (selectedVertex == null) {
    return;
  }
  
  for (Vertex v : scene.vertices) {
    if (selectedVertex != v && v.grab(selectedVertex.x, selectedVertex.y)) {
      serverDelta.x += v.x - selectedVertex.x;
      serverDelta.y += v.y - selectedVertex.y;
      selectedVertex.x = v.x;
      selectedVertex.y = v.y;
      //tools.enableTool("Merge"); - So scuhrred!
      return;
    }
  }
}

void enableContextSensitiveTools() {
  /* Scary tools - consider adding these to server client model
  enableMerge();
  enableSplit();
  */
}

void enableMerge() {
  if (selectedVertex == null) {
    tools.disableTool("Merge");
    return;
  }
  
  for (Vertex v : scene.vertices) {
    if (selectedVertex != v && v.grab(selectedVertex.x, selectedVertex.y)) {
      tools.enableTool("Merge");
      return;
    }
  }
  
  tools.disableTool("Merge");
}

void enableSplit() {
  if (selectedVertex == null || selectedVertex.shapes.isEmpty()) {
    tools.disableTool("Split");
  } else if (selectedVertex.shapes.size() > 1) {
    tools.enableTool("Split");
  } else {
    int count = 0;
    for (Vertex v : selectedVertex.shapes.iterator().next().corners) {
      if (selectedVertex == v) {
        count++;
      }
    }
    
    if (count > 1) {
      tools.enableTool("Split");
    }
  }
}

void merge() {
  if (selectedVertex == null) {
    return;
  }
  
  ArrayList<Vertex> mergeCandidates = new ArrayList<Vertex>();
  for (Vertex v : scene.vertices) {
    if (selectedVertex != v && v.grab(selectedVertex.x, selectedVertex.y)) {
      mergeCandidates.add(v);
    }
  }
  
  for (Vertex v : mergeCandidates) {
    selectedVertex.merge(v);
  }
  
  enableContextSensitiveTools();
}

void split() {
  if (selectedVertex == null) {
    return;
  }
  
  boolean first = true;
  for (Quad s : selectedVertex.shapes) {
    for (int i = 0; i < s.corners.length; i++) {
      if (selectedVertex == s.corners[i]) {
        if (first) {
          first = false;
        } else {
          Vertex replacement = new Vertex(selectedVertex.x, selectedVertex.y);
          replacement.addShape(s);
          scene.vertices.add(replacement);
          s.corners[i] = replacement;
        }
      }
    }
  }
  
  enableContextSensitiveTools();
}

void play() {
  // SEND play to server
}

void pause() {
  // SEND pause to server
}

void rewind() {
  // SEND rewind to server
}

JSONObject readMessage() {
  boolean inProgress = true;
  int level = 0;
  StringBuilder sb = new StringBuilder();
  
  while (inProgress) {
    int b = client.read();
    if (b == -1) {
      try {
        Thread.sleep(10);
      } catch (InterruptedException ie) {
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
  
  return parseJSONObject(sb.toString());
}

void sendMessage(JSONObject msg) {
  client.write(msg.toString());
}