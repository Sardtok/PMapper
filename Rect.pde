class Rect {
  Vertex corners[] = new Vertex[4];
  PImage texture;
  color c = #ffffff;
  
  Rect() {
    corners[0] = new Vertex(-0.25, -0.25);
    corners[1] = new Vertex(-0.25,  0.25);
    corners[2] = new Vertex( 0.25,  0.25);
    corners[3] = new Vertex( 0.25, -0.25);
  }
  
  void draw() {
    beginShape(QUADS);
    
    if (texture != null) {
      texture(texture);
      tint(c);
    } else {
      fill(c);
    }
    
    corners[0].draw();
    corners[1].draw();
    corners[2].draw();
    corners[3].draw();
    
    endShape();
  }
}