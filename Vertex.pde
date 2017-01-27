class Vertex {
  float x, y;
  
  Vertex(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void draw() {
    vertex(x, y);
  }
  
  void draw(float u, float v) {
    vertex(x, y, u, v);
  }
}