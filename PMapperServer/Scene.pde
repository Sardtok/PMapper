class Scene {
  Set<Vertex> vertices = new LinkedHashSet<Vertex>();
  Set<Vertex> uvs = new LinkedHashSet<Vertex>();
  Set<Shape> shapes = new LinkedHashSet<Shape>();
  Map<String, Texture> textures = new HashMap<String, Texture>();

  void addShape(Shape r) {
    for (Vertex v : r.vertices) {
      vertices.add(v);
    }
    for (Vertex v : r.uvs) {
      uvs.add(v);
    }

    shapes.add(r);
  }

  boolean addTexture(Texture t, String path) {
    if (textures.put(path, t) == null) {
      return true;
    }
    return false;
  }

  void draw() {
    for (Texture t : textures.values()) {
      t.update();
    }
    
    for (Shape s : shapes) {
      s.draw();
    }
  }

  void drawHandles() {
    for (Vertex v : vertices) {
      v.drawHandle();
    }
  }

  void fromJSON(JSONObject json) {
    JSONArray jsonVertices = json.getJSONArray("vertices");
    JSONArray jsonUVs = json.getJSONArray("uvs");
    JSONArray jsonShapes = json.getJSONArray("shapes");

    vertices.clear();
    shapes.clear();

    for (int i = 0; i < jsonVertices.size(); i++) {
      vertices.add(vertexFromJSON(jsonVertices.getJSONObject(i)));
    }

    for (int i = 0; i < jsonUVs.size(); i++) {
      uvs.add(vertexFromJSON(jsonUVs.getJSONObject(i)));
    }

    for (int i = 0; i < jsonShapes.size(); i++) {
      Shape s = shapeFromJSON(jsonShapes.getJSONObject(i));
      addShape(s);
    }
  }

  Vertex vertexFromJSON(JSONObject json) {
    float x = json.getFloat("x");
    float y = json.getFloat("y");

    return new Vertex(x, y);
  }

  Shape shapeFromJSON(JSONObject json) {
    JSONArray vertices = json.getJSONArray("vertices");
    JSONArray uvs = json.getJSONArray("uvs");
    float red = json.getFloat("red");
    float green = json.getFloat("green");
    float blue = json.getFloat("blue");
    float alpha = json.getFloat("alpha");
    color c = color(red, green, blue, alpha);
    Shape s = null;

    if (json.isNull("type") || "quad".equals(json.getString("type"))) {
      s = new Quad(getVertex(vertices.getInt(0)), getVertex(vertices.getInt(1)), getVertex(vertices.getInt(2)), getVertex(vertices.getInt(3)), c);
    } else if ("triangle".equals(json.getString("type"))) {
      s = new Triangle(getVertex(vertices.getInt(0)), getVertex(vertices.getInt(1)), getVertex(vertices.getInt(2)), c);
    }
    
    if (s == null) {
      return null;
    }
    
    for (int i = 0; i < s.vertices.length; i++) {
        s.uvs[i] = getUV(uvs.getInt(i));
    }

    if (!json.isNull("texture")) {
      String path = json.getString("texture");
      Texture t = loadTexture(path, this);
      s.setTexture(t);
    }

    return s;
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
    for (Shape s : shapes) {
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
  
  int indexOf(Shape shape) {
    int i = 0;
    for (Shape s : shapes) {
      if (shape == s) {
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