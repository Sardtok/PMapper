abstract class Shape {
  Vertex[] vertices;
  Vertex uvs[];
  Texture texture;
  color c;
  boolean dirty = true;
  PShape buffer;
  String name;
  
  void drawHandles() {
    for (Vertex v : vertices) {
      v.drawHandle();
    }
  }
  
  void replace(Vertex v1, Vertex v2) {
    for (int i = 0; i < vertices.length; i++) {
      if (vertices[i] == v1) {
        vertices[i] = v2;
      }
    }
  }
  
  color getColor() {
    switch (shaderMode) {
      case WHITE:
        return #ffffff;
      case COLOR:
        return shapeColors[scene.indexOf(this) % shapeColors.length];
      default:
        return c;
    }
  }
  
  Iterable<Vertex> getVertices() {
    return Arrays.asList(vertices);
  }
  
  void setTexture(Texture t) {
    this.texture = t;
    dirty = true;
  }
  
  void setName(String name) {
    this.name = name;
  }
  
  String getName() {
    return name;
  }
  
  abstract void draw();
  abstract JSONObject toJSON();
}