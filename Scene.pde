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
  
  void fromJSON(JSONObject json) {
    JSONArray jsonVertices = json.getJSONArray("vertices");
    JSONArray jsonShapes = json.getJSONArray("shapes");
    
    vertices.clear();
    shapes.clear();
    
    for (int i = 0; i < jsonVertices.size(); i++) {
      vertices.add(vertexFromJSON(jsonVertices.getJSONObject(i)));
    }
    
    for (int i = 0; i < jsonShapes.size(); i++) {
      shapes.add(rectFromJSON(jsonShapes.getJSONObject(i)));
    }
  }
  
  Vertex vertexFromJSON(JSONObject json) {
    float x = json.getFloat("x");
    float y = json.getFloat("y");
    
    return new Vertex(x, y);
  }
  
  Rect rectFromJSON(JSONObject json) {
    JSONArray corners = json.getJSONArray("corners");
    float red = json.getFloat("red");
    float green = json.getFloat("green");
    float blue = json.getFloat("blue");
    float alpha = json.getFloat("alpha");
    
    Vertex v0 = getVertex(corners.getInt(0));
    Vertex v1 = getVertex(corners.getInt(1));
    Vertex v2 = getVertex(corners.getInt(2));
    Vertex v3 = getVertex(corners.getInt(3));
    
    Rect rect = new Rect(v0, v1, v2, v3, color(red, green, blue, alpha));
    
    return rect;
  }
  
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    JSONArray jsonVertices = new JSONArray();
    JSONArray jsonShapes = new JSONArray();
    
    json.setJSONArray("vertices", jsonVertices);
    json.setJSONArray("shapes", jsonShapes);
    
    int i = 0;
    for (Vertex v : vertices) {
      jsonVertices.setJSONObject(i, v.toJSON());
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
}