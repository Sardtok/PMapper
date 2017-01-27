import processing.video.*;

float scale;

Rect r = new Rect();

void setup() {
  size(1280, 800, P2D);
  scale = min(width, height) / 2.0;
  
  r.c = #ff0000;
  noStroke();
}

void draw() {
  background(0);
  
  scale(scale);
  translate(width / (scale * 2), height / (scale * 2));
  
  r.draw();
}