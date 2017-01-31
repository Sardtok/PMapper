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
Toolbar tools = new Toolbar(new Vertex(-0.9, -0.9));

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
  ellipseMode(RADIUS);
  scale = min(width, height) / 2.0;

  VERTEX_SIZE = 5.0 / scale;
  VERTEX_SIZE_SQUARED = VERTEX_SIZE * VERTEX_SIZE;
  BUTTON_SIZE = 10.0 / scale;
  BUTTON_SIZE_SQUARED = BUTTON_SIZE * BUTTON_SIZE;
  
  tools.addTool("Load", new Button(new Vertex(0, 0), new Runnable() { public void run() { selectInput("Load scene", "loadScene"); }}));
  tools.addTool("Save", new Button(new Vertex(0, 0), new Runnable() { public void run() { selectOutput("Save scene", "saveScene"); }}));
  tools.addTool("Rectangle", new Button(new Vertex(0, 0), new Runnable() { public void run() { createRect(); }}));
  
  createRect();
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
  
  if (selection.size() == 1) {
    Vertex selected = selection.iterator().next();
    Vertex mouse = getMousePosition();
    
    for (Vertex v : scene.vertices) {
      if (selected != v && v.grab(mouse.x, mouse.y)) {
        selected.x = v.x;
        selected.y = v.y;
      }
    }
  }
}

void mouseClicked() {
  tools.click();
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
}

void loadScene(File f) {
  scene.fromJSON(loadJSONObject(f));
}

void saveScene(File f) {
  saveJSONObject(scene.toJSON(), f.getAbsolutePath());
}