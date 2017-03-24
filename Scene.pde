class Scene {
  Set<Vertex> vertices = new LinkedHashSet<Vertex>();
  Set<Vertex> uvs = new LinkedHashSet<Vertex>();
  Set<Rect> shapes = new LinkedHashSet<Rect>();
  Map<String, Texture> textures = new HashMap<String, Texture>();

  void addRect(Rect r) {
    for (Vertex v : r.corners) {
      vertices.add(v);
    }
    for (Vertex v : r.uvs) {
      uvs.add(v);
    }

    shapes.add(r);
    shapeWindow.add(r);
  }

  boolean addTexture(Texture t, String path) {
    if (textures.put(path, t) == null) {
      textureWindow.add(t);
      return true;
    }
    return false;
  }

  void draw() {
    for (Texture t : textures.values()) {
      t.update();
    }
    
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

  void fromJSON(JSONObject json) {
    JSONArray jsonVertices = json.getJSONArray("vertices");
    JSONArray jsonUVs = json.getJSONArray("uvs");
    JSONArray jsonShapes = json.getJSONArray("shapes");

    vertices.clear();
    shapes.clear();
    shapeWindow.clear();
    textureWindow.clear();

    for (int i = 0; i < jsonVertices.size(); i++) {
      vertices.add(vertexFromJSON(jsonVertices.getJSONObject(i)));
    }

    for (int i = 0; i < jsonUVs.size(); i++) {
      uvs.add(vertexFromJSON(jsonUVs.getJSONObject(i)));
    }

    for (int i = 0; i < jsonShapes.size(); i++) {
      addRect(rectFromJSON(jsonShapes.getJSONObject(i)));
    }
  }

  Vertex vertexFromJSON(JSONObject json) {
    float x = json.getFloat("x");
    float y = json.getFloat("y");

    return new Vertex(x, y);
  }

  Rect rectFromJSON(JSONObject json) {
    JSONArray corners = json.getJSONArray("corners");
    JSONArray uvs = json.getJSONArray("uvs");
    float red = json.getFloat("red");
    float green = json.getFloat("green");
    float blue = json.getFloat("blue");
    float alpha = json.getFloat("alpha");

    Vertex v0 = getVertex(corners.getInt(0));
    Vertex v1 = getVertex(corners.getInt(1));
    Vertex v2 = getVertex(corners.getInt(2));
    Vertex v3 = getVertex(corners.getInt(3));

    Rect rect = new Rect(v0, v1, v2, v3, color(red, green, blue, alpha));

    rect.uvs[0] = getUV(uvs.getInt(0));
    rect.uvs[1] = getUV(uvs.getInt(1));
    rect.uvs[2] = getUV(uvs.getInt(2));
    rect.uvs[3] = getUV(uvs.getInt(3));

    if (!json.isNull("texture")) {
      String path = json.getString("texture");

      if (!textures.containsKey(path)) {
        loadTexture(new File(path), this);
      }

      rect.setTexture(textures.get(path));
    }

    return rect;
  }

  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    JSONArray jsonVertices = new JSONArray();
    JSONArray jsonUVs = new JSONArray();
    JSONArray jsonShapes = new JSONArray();

    json.setJSONArray("vertices", jsonVertices);
    json.setJSONArray("uvs", jsonUVs);
    json.setJSONArray("shapes", jsonShapes);

    int i = 0;
    for (Vertex v : vertices) {
      jsonVertices.setJSONObject(i, v.toJSON());
      i++;
    }

    i = 0;
    for (Vertex v : uvs) {
      jsonUVs.setJSONObject(i, v.toJSON());
      i++;
    }

    i = 0;
    for (Rect s : shapes) {
      jsonShapes.setJSONObject(i, s.toJSON());
      i++;
    }

    return json;
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

  Vertex getUV(int i) {
    for (Vertex v : uvs) {
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

  int indexOfUV(Vertex vertex) {
    int i = 0;

    for (Vertex v : uvs) {
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