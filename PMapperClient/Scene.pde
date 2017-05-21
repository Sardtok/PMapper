class Scene {
  Set<Vertex> vertices = new LinkedHashSet<Vertex>();
  Set<Quad> shapes = new LinkedHashSet<Quad>();
  Map<String, Texture> textures = new HashMap<String, Texture>();

  void addQuad(Quad r) {
    for (Vertex v : r.corners) {
      vertices.add(v);
    }

    shapes.add(r);
    shapeWindow.add(r);
  }

  void draw() {
    for (Quad s : shapes) {
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

    for (Quad s : shapes) {
      if (s.grab(x, y)) {
        return s;
      }
    }

    return null;
  }

  void fromJSON(JSONObject json) {
    JSONArray jsonVertices = json.getJSONArray("vertices");
    JSONArray jsonShapes = json.getJSONArray("shapes");

    vertices.clear();
    shapes.clear();
    shapeWindow.clear();

    for (int i = 0; i < jsonVertices.size(); i++) {
      vertices.add(vertexFromJSON(jsonVertices.getJSONObject(i)));
    }

    for (int i = 0; i < jsonShapes.size(); i++) {
      Quad q = quadFromJSON(jsonShapes.getJSONObject(i)); 
      q.name = "Quad " + (i + 1);
      addQuad(q);
    }
  }

  Vertex vertexFromJSON(JSONObject json) {
    float x = json.getFloat("x");
    float y = json.getFloat("y");

    return new Vertex(x, y);
  }

  Quad quadFromJSON(JSONObject json) {
    JSONArray corners = json.getJSONArray("corners");

    Vertex v0 = getVertex(corners.getInt(0));
    Vertex v1 = getVertex(corners.getInt(1));
    Vertex v2 = getVertex(corners.getInt(2));
    Vertex v3 = getVertex(corners.getInt(3));

    Quad quad = new Quad(v0, v1, v2, v3, shapeColors[shapes.size() % shapeColors.length]);

    return quad;
  }

  Vertex getVertex(int i) {
    for (Vertex v : vertices) {
      if (i == 0) {
        return v;
      }

      i--;
    }
    return null;
  }

  int indexOf(Vertex vertex) {
    int i = 0;

    for (Vertex v : vertices) {
      if (vertex == v) {
        return i;
      }

      i++;
    }

    return -1;
  }

  String getTexturePath(Texture t) {
    for (Map.Entry<String, Texture> entry : textures.entrySet()) {
      if (entry.getValue() == t) {
        return entry.getKey();
      }
    }

    return null;
  }
}