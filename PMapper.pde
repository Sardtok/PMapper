import java.awt.*;
import java.util.*;
import processing.video.*;

boolean shiftDown;
Vertex mousePosition;

boolean editMode = true;
float scale;
float VERTEX_SIZE;
float VERTEX_SIZE_SQUARED;
float BUTTON_SIZE;
float BUTTON_SIZE_SQUARED;

Set<Vertex> selection = new HashSet<Vertex>();
Button[] buttons = {
  new Button(new Vertex(-0.9, -0.9), new Vertex(0, 0), new Runnable() { void run() { selectInput("Load scene", "loadScene"); }}),
  new Button(new Vertex(-0.8, -0.9), new Vertex(0, 0), new Runnable() { void run() { selectOutput("Save scene", "saveScene"); }})
};

Scene scene = new Scene();

void setup() {
  size(1280, 800, P2D);
  ellipseMode(RADIUS);
  scale = min(width, height) / 2.0;

  VERTEX_SIZE = 5.0 / scale;
  VERTEX_SIZE_SQUARED = VERTEX_SIZE * VERTEX_SIZE;
  BUTTON_SIZE = 10.0 / scale;
  BUTTON_SIZE_SQUARED = BUTTON_SIZE * BUTTON_SIZE;

  Rect r = new Rect(new Vertex(-0.25, -0.25), new Vertex(-0.25, 0.25), new Vertex(0.25, 0.25), new Vertex(0.25, -0.25), #4080ff);
  scene.addRect(r);
}

void draw() {
  background(0);
  noStroke();

  scale(scale);
  translate(width / (scale * 2), height / (scale * 2));

  scene.draw();

  if (editMode) {
    drawHandles();
    drawButtons();
  }

  mousePosition = null;
}

void drawHandles() {
  strokeWeight(2.0 / scale);
  stroke(#ff0000);

  scene.drawHandles();
}

void drawButtons() {
  Vertex mouse = getMousePosition();

  for (Button b : buttons) {
    b.draw(mouse);
  }
}

Vertex getMousePosition() {
  if (mousePosition == null) {
    mousePosition = new Vertex((mouseX - width / 2.0) / scale, (mouseY - height / 2.0) / scale);
  }

  return mousePosition;
}

void mousePressed() {
  Vertex mouse = getMousePosition();
  Selectable s = scene.grab(mouse.x, mouse.y);

  if (s == null) {
    if (!shiftDown) {
      selection.clear();
    }

    return;
  }

  if (shiftDown) {
    toggleSelection(s.getVertices());
  } else {
    selection.clear();
    for (Vertex v : s.getVertices()) {
      selection.add(v);
    }
  }
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

  for (Vertex v : selection) {
    v.x += dX;
    v.y += dY;
  }
}

void mouseClicked() {
  Vertex mouse = getMousePosition();
  for (Button b : buttons) {
    b.click(mouse);
  }
}

void keyPressed() {
  shiftDown |= keyCode == SHIFT;
}

void keyReleased() {
  shiftDown ^= keyCode == SHIFT;
}

void loadScene(File f) {
  scene.fromJSON(loadJSONObject(f));
}

void saveScene(File f) {
  saveJSONObject(scene.toJSON(), f.getAbsolutePath());
}