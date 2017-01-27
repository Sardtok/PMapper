class Vertex {
  float x, y;
  boolean handleDrawn;
  
  Vertex(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void draw() {
    vertex(x, y);
    handleDrawn = false;
  }
  
  void draw(float u, float v) {
    vertex(x, y, u, v);
    handleDrawn = false;
  }
  
  void drawHandle() {
    if (handleDrawn) {
      return;
    }
    
    ellipse(x, y, 10.0 / scale, 10.0 / scale);
    handleDrawn = true;
  }
}