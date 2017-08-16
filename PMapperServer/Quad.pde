class Quad extends Shape {
  Quad(Vertex v0, Vertex v1, Vertex v2, Vertex v3, color c) {
    vertices = new Vertex[] { v0, v1, v2, v3 };
    uvs = new Vertex[] {new Vertex(0, 0), new Vertex(0, 1), new Vertex(1, 1), new Vertex(1, 0)};
    
    this.c = c;
    
    v0.addShape(this);
    v1.addShape(this);
    v2.addShape(this);
    v3.addShape(this);
  }
  
  void draw() {
    if (dirty) {
      populateBuffer();
    }
    
    if (texture != null && shaderMode == ShaderMode.TEXTURE) {
      shader(texShader);
    }
    shape(buffer);
    
    for (Vertex v : vertices) {
      v.handleDrawn = false;
    }
    
    resetShader();
  }
  
  void populateBuffer() {
    buffer = createShape();
    buffer.beginShape(QUADS);
    
    if (texture != null && shaderMode == ShaderMode.TEXTURE) {
      float dx1 = vertices[2].x - vertices[0].x;
      float dy1 = vertices[2].y - vertices[0].y;
      float dx2 = vertices[3].x - vertices[1].x;
      float dy2 = vertices[3].y - vertices[1].y;
      float dx3 = vertices[0].x - vertices[1].x;
      float dy3 = vertices[0].y - vertices[1].y;
    
      float crs = dx1 * dy2 - dy1 * dx2;
      float cqpr = dx1 * dy3 - dy1 * dx3;
      float cqps = dx2 * dy3 - dy2 * dx3;
    
      float t = cqps / crs;
      float u = cqpr / crs;
      
      buffer.texture(texture.getImage());
      buffer.tint(c);

      buffer.attrib("texCoordQ", 1.0 / (1.0 - t));
      buffer.vertex(vertices[0].x, vertices[0].y, uvs[0].x, uvs[0].y);

      buffer.attrib("texCoordQ", 1.0 / (1.0 - u));
      buffer.vertex(vertices[1].x, vertices[1].y, uvs[1].x, uvs[1].y);

      buffer.attrib("texCoordQ", 1.0 / (t));
      buffer.vertex(vertices[2].x, vertices[2].y, uvs[2].x, uvs[2].y);

      buffer.attrib("texCoordQ", 1.0 / (u));
      buffer.vertex(vertices[3].x, vertices[3].y, uvs[3].x, uvs[3].y);
    } else {
      buffer.fill(getColor());
      buffer.vertex(vertices[0].x, vertices[0].y);
      buffer.vertex(vertices[1].x, vertices[1].y);
      buffer.vertex(vertices[2].x, vertices[2].y);
      buffer.vertex(vertices[3].x, vertices[3].y);
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
    jsonCorners.setInt(3, scene.indexOf(vertices[3]));
    
    json.setJSONArray("vertices", jsonCorners);
    
    jsonUVs.setInt(0, scene.indexOfUV(uvs[0]));
    jsonUVs.setInt(1, scene.indexOfUV(uvs[1]));
    jsonUVs.setInt(2, scene.indexOfUV(uvs[2]));
    jsonUVs.setInt(3, scene.indexOfUV(uvs[3]));
    
    json.setJSONArray("uvs", jsonUVs);
    
    json.setFloat("red", red(c));
    json.setFloat("green", green(c));
    json.setFloat("blue", blue(c));
    json.setFloat("alpha", alpha(c));
    
    if (texture != null) {
      json.setString("texture", scene.getTexturePath(texture));
    }
    
    json.setString("type", "quad");
    
    return json;
  }
}