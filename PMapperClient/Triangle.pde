class Triangle extends Shape {
  
  Triangle(Vertex v0, Vertex v1, Vertex v2, color c) {
    vertices = new Vertex[] { v0, v1, v2 };
    uvs = new Vertex[] {new Vertex(0, 0), new Vertex(0, 1), new Vertex(1, 1)};
    
    this.c = c;
    
    v0.addShape(this);
    v1.addShape(this);
    v2.addShape(this);
  }

  void draw() {
    beginShape(TRIANGLES);
    fill(c);
    vertices[0].draw();
    vertices[1].draw();
    vertices[2].draw();
    endShape();
    
    for (Vertex v : vertices) {
      v.handleDrawn = false;
    }
    
    resetShader();
  }
  
  void select() {
    clearSelection = false;
    toSelect = this;
  }
  
  boolean grab(float x, float y) {
    selectionBuffer.beginDraw();
    selectionBuffer.background(0);
    selectionBuffer.fill(#ffffff);
    selectionBuffer.noStroke();
    selectionBuffer.translate(width / 2, height / 2);
    selectionBuffer.scale(scale);
    
    selectionBuffer.triangle(vertices[0].x, vertices[0].y, 
      vertices[1].x, vertices[1].y, 
      vertices[2].x, vertices[2].y);
    
    selectionBuffer.endDraw();
    
    return selectionBuffer.get((int)((x * scale) + (width / 2)), (int)((y * scale) + (height / 2))) == #ffffff;
  }
}