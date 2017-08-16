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
    if (dirty) {
      populateBuffer();
    }
    
    shape(buffer);
    
    for (Vertex v : vertices) {
      v.handleDrawn = false;
    }
  }
  
  void populateBuffer() {
    buffer = createShape();
    buffer.beginShape(TRIANGLES);
    
    if (texture != null && shaderMode == ShaderMode.TEXTURE) {
      buffer.texture(texture.getImage());
      buffer.tint(c);
      buffer.vertex(vertices[0].x, vertices[0].y, uvs[0].x, uvs[0].y);
      buffer.vertex(vertices[1].x, vertices[1].y, uvs[1].x, uvs[1].y);
      buffer.vertex(vertices[2].x, vertices[2].y, uvs[2].x, uvs[2].y);
    } else {
      buffer.fill(getColor());
      buffer.vertex(vertices[0].x, vertices[0].y);
      buffer.vertex(vertices[1].x, vertices[1].y);
      buffer.vertex(vertices[2].x, vertices[2].y);
    }
    
    buffer.endShape();
    dirty = false;
  }
  
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    JSONArray jsonCorners = new JSONArray();
    JSONArray jsonUVs = new JSONArray();
    
    jsonCorners.setInt(0, scene.indexOf(vertices[0]));
    jsonCorners.setInt(1, scene.indexOf(vertices[1]));
    jsonCorners.setInt(2, scene.indexOf(vertices[2]));
    
    json.setJSONArray("vertices", jsonCorners);
    
    jsonUVs.setInt(0, scene.indexOfUV(uvs[0]));
    jsonUVs.setInt(1, scene.indexOfUV(uvs[1]));
    jsonUVs.setInt(2, scene.indexOfUV(uvs[2]));
    
    json.setJSONArray("uvs", jsonUVs);
    
    json.setFloat("red", red(c));
    json.setFloat("green", green(c));
    json.setFloat("blue", blue(c));
    json.setFloat("alpha", alpha(c));
    
    if (texture != null) {
      json.setString("texture", scene.getTexturePath(texture));
    }
    
    json.setString("type", "triangle");
    
    return json;
  }
}