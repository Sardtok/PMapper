class Quad {
  Vertex corners[] = new Vertex[4];
  Vertex uvs[] = {new Vertex(0, 0), new Vertex(0, 1), new Vertex(1, 1), new Vertex(1, 0)};
  
  boolean dirty = true;
  PShape buffer;
  
  Texture texture;
  color c;
  String name = "Quad";
  
  Quad(Vertex v0, Vertex v1, Vertex v2, Vertex v3, color c) {
    corners[0] = v0;
    corners[1] = v1;
    corners[2] = v2;
    corners[3] = v3;
    
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
    
    for (Vertex v : corners) {
      v.handleDrawn = false;
    }
    
    resetShader();
  }
  
  void populateBuffer() {
    buffer = createShape();
    buffer.beginShape(QUADS);
    
    if (texture != null && shaderMode == ShaderMode.TEXTURE) {
      float dx1 = corners[2].x - corners[0].x;
      float dy1 = corners[2].y - corners[0].y;
      float dx2 = corners[3].x - corners[1].x;
      float dy2 = corners[3].y - corners[1].y;
      float dx3 = corners[0].x - corners[1].x;
      float dy3 = corners[0].y - corners[1].y;
    
      float crs = dx1 * dy2 - dy1 * dx2;
      float cqpr = dx1 * dy3 - dy1 * dx3;
      float cqps = dx2 * dy3 - dy2 * dx3;
    
      float t = cqps / crs;
      float u = cqpr / crs;
      
      buffer.texture(texture.getImage());
      buffer.tint(c);

      buffer.attrib("texCoordQ", 1.0 / (1.0 - t));
      buffer.vertex(corners[0].x, corners[0].y, uvs[0].x, uvs[0].y);

      buffer.attrib("texCoordQ", 1.0 / (1.0 - u));
      buffer.vertex(corners[1].x, corners[1].y, uvs[1].x, uvs[1].y);

      buffer.attrib("texCoordQ", 1.0 / (t));
      buffer.vertex(corners[2].x, corners[2].y, uvs[2].x, uvs[2].y);

      buffer.attrib("texCoordQ", 1.0 / (u));
      buffer.vertex(corners[3].x, corners[3].y, uvs[3].x, uvs[3].y);
    } else {
      buffer.fill(getColor());
      buffer.vertex(corners[0].x, corners[0].y);
      buffer.vertex(corners[1].x, corners[1].y);
      buffer.vertex(corners[2].x, corners[2].y);
      buffer.vertex(corners[3].x, corners[3].y);
    }

    buffer.endShape();
    dirty = false;
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
  
  void drawHandles() {
    for (Vertex v : corners) {
      v.drawHandle();
    }
  }
  
  void replace(Vertex v1, Vertex v2) {
    for (int i = 0; i < corners.length; i++) {
      if (corners[i] == v1) {
        corners[i] = v2;
      }
    }
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
  
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    JSONArray jsonCorners = new JSONArray();
    JSONArray jsonUVs = new JSONArray();
    
    jsonCorners.setInt(0, scene.indexOf(corners[0]));
    jsonCorners.setInt(1, scene.indexOf(corners[1]));
    jsonCorners.setInt(2, scene.indexOf(corners[2]));
    jsonCorners.setInt(3, scene.indexOf(corners[3]));
    
    json.setJSONArray("corners", jsonCorners);
    
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
    
    return json;
  }
  
  Iterable<Vertex> getVertices() {
    return Arrays.asList(corners);
  }
}