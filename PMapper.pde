import java.awt.*;
import java.util.*;
import processing.video.*;

boolean shiftDown;

boolean editMode = true;
float scale;

Set<Vertex> selection = new HashSet<Vertex>();

Scene scene = new Scene();

void setup() {
  size(1280, 800, P2D);
  scale = min(width, height) / 2.0;

  Rect r = new Rect();
  r.c = #4080ff;
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
  }
}

void drawHandles() {
  strokeWeight(2.0 / scale);
  stroke(#ff0000);
  fill(#ffffff);

  scene.drawHandles();
}

void mousePressed() {
  Selectable s = scene.grab((mouseX - width / 2.0) / scale, (mouseY - height / 2.0) / scale);

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

void keyPressed() {
  shiftDown |= keyCode == SHIFT;
}

void keyReleased() {
  shiftDown ^= keyCode == SHIFT;
}