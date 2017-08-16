class Scene {
  Set<Vertex> vertices = new LinkedHashSet<Vertex>();
  Set<Shape> shapes = new LinkedHashSet<Shape>();
  Map<String, Texture> textures = new HashMap<String, Texture>();

  void addShape(Shape r) {
    for (Vertex v : r.vertices) {
      vertices.add(v);
    }

    shapes.add(r);
    shapeWindow.add(r);
  }

  void draw() {
    for (Shape s : shapes) {
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

    for (Shape s : shapes) {
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
      Shape s = shapeFromJSON(jsonShapes.getJSONObject(i)); 
      s.name = "Shape " + (i + 1);
      addShape(s);
    }
  }

  Vertex vertexFromJSON(JSONObject json) {
    float x = json.getFloat("x");
    float y = json.getFloat("y");

    return new Vertex(x, y);
  }

  Shape shapeFromJSON(JSONObject json) {
    println(json);
    JSONArray vertices = json.getJSONArray("vertices");
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

    return s;
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