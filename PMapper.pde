import java.awt.*;
import java.util.*;
import processing.video.*;

boolean shiftDown;
Vertex mousePosition;

Mode mode = Mode.EDIT_SCENE;
float scale;
float VERTEX_SIZE;
float VERTEX_SIZE_SQUARED;
float BUTTON_SIZE;
float BUTTON_SIZE_SQUARED;

Set<Vertex> selection = new HashSet<Vertex>();
PGraphics selectionBuffer;
Selectable toSelect;
boolean clearSelection;

Toolbar tools = new Toolbar(new Vertex(-0.9, -0.9));
LayerWindow textureWindow;
LayerWindow shapeWindow;
PFont font;

Scene scene = new Scene();
color shapeColors[] = {
  #4080ff,
  #ff4080,
  #80ff40,
  #8040ff,
  #ff8040,
  #40ff80
};

void setup() {
  size(1280, 800, P2D);
  selectionBuffer = createGraphics(width, height, P2D);
  ellipseMode(RADIUS);
  textureMode(NORMAL);
  scale = min(width, height) / 2.0;

  VERTEX_SIZE = 5.0 / scale;
  VERTEX_SIZE_SQUARED = VERTEX_SIZE * VERTEX_SIZE;
  BUTTON_SIZE = 10.0 / scale;
  BUTTON_SIZE_SQUARED = BUTTON_SIZE * BUTTON_SIZE;
  
  tools.addTool("Load", new Button(new Vertex(0, 0), new Runnable() { public void run() { selectInput("Load scene", "loadScene"); }}));
  tools.addTool("Save", new Button(new Vertex(0, 0), new Runnable() { public void run() { selectOutput("Save scene", "saveScene"); }}));
  tools.addTool("Rectangle", new Button(new Vertex(0, 0), new Runnable() { public void run() { createRect(); }}));
  tools.addTool("Merge", new Button(new Vertex(0, 0), new Runnable() { public void run() { merge(); }}));
  tools.addTool("Add texture", new Button(new Vertex(0, 0), new Runnable() { public void run() { selectInput("Load texture", "loadTexture"); }}));
  tools.disableTool("Merge");
  
  font = createFont("Verdana", 10);
  textFont(font);
  textureWindow = new LayerWindow("Textures", new Vertex(-width / (scale * 2) + 0.1, -0.5));
  shapeWindow = new LayerWindow("Shapes", new Vertex(width / (scale * 2) - 0.3, -0.5));
  
  createRect();
}

void draw() {
  background(0);
  noStroke();

  translate(width / 2, height / 2);
  scale(scale);
  
  scene.draw();

  if (mode == Mode.EDIT_SCENE) {
    drawHandles();
    drawButtons();
    textureWindow.draw();
    shapeWindow.draw();
  }

  mousePosition = null;
}

void drawHandles() {
  strokeWeight(2.0 / scale);
  stroke(#ff0000);

  scene.drawHandles();
  tools.position.drawHandle();
  textureWindow.position.drawHandle();
  shapeWindow.position.drawHandle();
}

void drawButtons() {
  tools.draw();
}

Vertex getMousePosition() {
  if (mousePosition == null) {
    mousePosition = new Vertex((mouseX - width / 2.0) / scale, (mouseY - height / 2.0) / scale);
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
    } else if (textureWindow.position.grab(mouse.x, mouse.y)) {
      toSelect = textureWindow.position;
    } else if (shapeWindow.position.grab(mouse.x, mouse.y)) {
      toSelect = shapeWindow.position;
    } else {
      clearSelection = true;
    }
  }
}

boolean selectionHasTools() {
  return selection.contains(tools.position)
    || selection.contains(textureWindow.position)
    || selection.contains(shapeWindow.position);
}

void select() {
  if (toSelect == null && !clearSelection) {
    enableMerge();
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
  
  for (Vertex v : selection) {
    for (Rect s : v.shapes) {
      shapeWindow.addSelected(s);
    }
  }
  
  toSelect = null;
  clearSelection = false;
  enableMerge();
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
  float dX = (mouseX - pmouseX) / scale;
  float dY = (mouseY - pmouseY) / scale;
  select();

  for (Vertex v : selection) {
    v.x += dX;
    v.y += dY;
  }

  tools.disableTool("Merge");
  if (selection.size() == 1) {
    snap();
  }
}

void mouseClicked() {
  if (tools.click()) {
    return;
  }
  
  shapeWindow.click();
  
  select();
}

void keyPressed() {
  shiftDown |= keyCode == SHIFT;
}

void keyReleased() {
  shiftDown ^= keyCode == SHIFT;
}

void createRect() {
  Rect r = new Rect(new Vertex(-0.25, -0.25), new Vertex(-0.25, 0.25), new Vertex(0.25, 0.25), new Vertex(0.25, -0.25), shapeColors[scene.shapes.size() % shapeColors.length]);
  scene.addRect(r);
  r.setName("Rect " + scene.shapes.size());
}

Vertex getSelectedVertex() {
  if (selection.size() != 1) {
    return null;
  }

  return selection.iterator().next();
}

void snap() {
  Vertex selected = selection.iterator().next();

  for (Vertex v : scene.vertices) {
    if (selected != v && v.grab(selected.x, selected.y)) {
      selected.x = v.x;
      selected.y = v.y;
      tools.enableTool("Merge");
      return;
    }
  }
}

void enableMerge() {
  Vertex selected = getSelectedVertex();
  if (selected == null) {
    tools.disableTool("Merge");
    return;
  }
  
  for (Vertex v : scene.vertices) {
    if (selected != v && v.grab(selected.x, selected.y)) {
      tools.enableTool("Merge");
      return;
    }
  }
}

void merge() {
  Vertex selected = getSelectedVertex();
  if (selected == null) {
    return;
  }
  
  Vertex mergeCandidate = null;
  for (Vertex v : scene.vertices) {
    if (selected != v && v.grab(selected.x, selected.y)) {
      mergeCandidate = v;
      break;
    }
  }
  
  if (mergeCandidate != null) {
    selected.merge(mergeCandidate);
  }
}

void loadScene(File f) {
  if (f == null) {
    return;
  }
  
  scene.fromJSON(loadJSONObject(f));
}

void saveScene(File f) {
  if (f == null) {
    return;
  }
  
  saveJSONObject(scene.toJSON(), f.getAbsolutePath());
}

void loadTexture(File f) {
  if (f == null) {
    return;
  }
  
  PImage img = loadImage(f.getAbsolutePath());
  Texture t = null;
  if (img != null && img.width >= 0) {
    t = new ImageTexture(img, f.getName());
  } else {
    t = new MovieTexture(new Movie(this, f.getAbsolutePath()), f.getName());
  }
  
  if (!scene.addTexture(t, f.getAbsolutePath())) {
    return;
  }

  for (Rect s : scene.shapes) {
    Collection<Vertex> verts = (Collection<Vertex>) s.getVertices();
    if (selection.containsAll(verts) && verts.containsAll(selection)) {
      s.setTexture(t);
    }
  }
}