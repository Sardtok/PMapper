import processing.video.*;

boolean editMode = true;
float scale;

Rect r = new Rect();

void setup() {
  size(1280, 800, P2D);
  scale = min(width, height) / 2.0;

  r.c = #4080ff;
}

void draw() {
  background(0);
  noStroke();

  scale(scale);
  translate(width / (scale * 2), height / (scale * 2));

  r.draw();
  r.drawHandles();
}

void drawHandles() {
  if (!editMode) {
    return;
  }

  strokeWeight(2.0 / scale);
  stroke(#ff0000);
  fill(#ffffff);
}