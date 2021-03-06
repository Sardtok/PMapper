class Quad implements Selectable, Layer {
  Vertex corners[] = new Vertex[4];  
  color c = #ffffff;
  String name = "Quad";
  
  Quad(Vertex v0, Vertex v1, Vertex v2, Vertex v3, color c) {
    corners[0] = v0;
    corners[1] = v1;
    corners[2] = v2;
    corners[3] = v3;
    
    this.c = c;
    
    v0.addShape(this);
    v1.addShape(this);
    v2.addShape(this);
    v3.addShape(this);
  }
  
  void draw() {
    beginShape(QUADS);
    fill(c);
    corners[0].draw();
    corners[1].draw();
    corners[2].draw();
    corners[3].draw();
    endShape();
    
    for (Vertex v : corners) {
      v.handleDrawn = false;
    }
    
    resetShader();
  }
  
  void drawHandles() {
    for (Vertex v : corners) {
      v.drawHandle();
    }
  }
  
  void replace(Vertex v1, Vertex v2) {
    for (int i = 0; i < corners.length; i++) {
      if (corners[i] == v1) {
        corners[i] = v2;
      }
    }
  }
  
  boolean grab(float x, float y) {
    selectionBuffer.beginDraw();
    selectionBuffer.background(0);
    selectionBuffer.fill(#ffffff);
    selectionBuffer.noStroke();
    selectionBuffer.translate(width / 2, height / 2);
    selectionBuffer.scale(scale);
    
    selectionBuffer.quad(corners[0].x, corners[0].y, 
      corners[1].x, corners[1].y, 
      corners[2].x, corners[2].y, 
      corners[3].x, corners[3].y);
    
    selectionBuffer.endDraw();
    
    return selectionBuffer.get((int)((x * scale) + (width / 2)), (int)((y * scale) + (height / 2))) == #ffffff;
  }
  
  void setName(String name) {
    this.name = name;
  }
  
  String getName() {
    return name;
  }
  
  void select() {
    clearSelection = false;
    toSelect = this;
  }
  
  Iterable<Vertex> getVertices() {
    return Arrays.asList(corners);
  }
}