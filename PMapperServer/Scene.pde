class Scene {
  Set<Vertex> vertices = new LinkedHashSet<Vertex>();
  Set<Vertex> uvs = new LinkedHashSet<Vertex>();
  Set<Quad> shapes = new LinkedHashSet<Quad>();
  Map<String, Texture> textures = new HashMap<String, Texture>();

  void addQuad(Quad r) {
    for (Vertex v : r.corners) {
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
    
    for (Quad s : shapes) {
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
    JSONArray uvs = json.getJSONArray("uvs");
    float red = json.getFloat("red");
    float green = json.getFloat("green");
    float blue = json.getFloat("blue");
    float alpha = json.getFloat("alpha");

    Vertex v0 = getVertex(corners.getInt(0));
    Vertex v1 = getVertex(corners.getInt(1));
    Vertex v2 = getVertex(corners.getInt(2));
    Vertex v3 = getVertex(corners.getInt(3));

    Quad quad = new Quad(v0, v1, v2, v3, color(red, green, blue, alpha));

    quad.uvs[0] = getUV(uvs.getInt(0));
    quad.uvs[1] = getUV(uvs.getInt(1));
    quad.uvs[2] = getUV(uvs.getInt(2));
    quad.uvs[3] = getUV(uvs.getInt(3));

    if (!json.isNull("texture")) {
      String path = json.getString("texture");
      Texture t = loadTexture(path, this);
      quad.setTexture(t);
    }

    return quad;
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
    for (Quad s : shapes) {
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
  
  int indexOf(Quad quad) {
    int i = 0;
    for (Quad q : shapes) {
      if (quad == q) {
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