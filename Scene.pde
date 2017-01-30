class Scene {
  Set<Vertex> vertices = new LinkedHashSet<Vertex>();
  Set<Rect> shapes = new LinkedHashSet<Rect>();

  void addRect(Rect r) {
    for (Vertex v : r.corners) {
      vertices.add(v);
    }

    shapes.add(r);
  }

  void draw() {
    for (Rect s : shapes) {
      s.draw();
    }
  }

  void drawHandles() {
    for (Vertex v : vertices) {
      v.drawHandle();
    }
  }

  Selectable grab(float x, float y) {
    for (Vertex v : vertices) {
      if (v.grab(x, y)) {
        return v;
      }
    }

    for (Rect s : shapes) {
      if (s.grab(x, y)) {
        return s;
      }
    }

    return null;
  }
  
  void fromJSON(JSONObject data) {
  }
  
  JSONObject toJSON() {
    return null;
  }
}