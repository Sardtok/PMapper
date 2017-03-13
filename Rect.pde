class Rect implements Selectable, Layer {
  Vertex corners[] = new Vertex[4];
  Vertex uvs[] = {new Vertex(0, 0), new Vertex(0, 1), new Vertex(1, 1), new Vertex(1, 0)};
  
  boolean dirty = true;
  float buffer[][] = new float[4][5];
  
  Texture texture;
  color c = #ffffff;
  String name = "Rect";
  
  Rect(Vertex v0, Vertex v1, Vertex v2, Vertex v3, color c) {
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
    beginShape(QUADS);
    
    if (texture != null) {
      shader(texShader);
      texture(texture.getImage());
      tint(c);
    } else {
      shader(colShader);
      fill(c);
    }
    
    if (dirty) {
      populateBuffer();
    }
    
    for (int i = 0; i < buffer.length; i++) {
      vertex(buffer[i][0], buffer[i][1], buffer[i][2], buffer[i][3], buffer[i][4]);
    }
    
    for (Vertex v : corners) {
      v.handleDrawn = false;
    }
    
    endShape();
  }
  
  void populateBuffer() {
    for (int i = 0; i < buffer.length; i++) {
      buffer[i][0] = corners[i].x;
      buffer[i][1] = corners[i].y;
      buffer[i][3] = uvs[i].x;
      buffer[i][4] = uvs[i].y;
    }
    
    float dx1 = buffer[2][0] - buffer[0][0];
    float dy1 = buffer[2][1] - buffer[0][1];
    float dx2 = buffer[3][0] - buffer[1][0];
    float dy2 = buffer[3][1] - buffer[1][1];
    float dx3 = buffer[0][0] - buffer[1][0];
    float dy3 = buffer[0][1] - buffer[1][1];
    
    float crs = dx1 * dy2 - dy1 * dx2;
    float cqpr = dx1 * dy3 - dy1 * dx3;
    float cqps = dx2 * dy3 - dy2 * dx3;
    
    float t = cqps / crs;
    float u = cqpr / crs;
    
    buffer[0][2] = 1.0 / (1.0 - t);
    buffer[0][3] *= buffer[0][2];
    buffer[0][4] *= buffer[0][2];
    
    buffer[1][2] = 1.0 / (1.0 - u);
    buffer[1][3] *= buffer[1][2];
    buffer[1][4] *= buffer[1][2];
    
    buffer[2][2] = 1.0 / (t);
    buffer[2][3] *= buffer[2][2];
    buffer[2][4] *= buffer[2][2];
    
    buffer[3][2] = 1.0 / (u);
    buffer[3][3] *= buffer[3][2];
    buffer[3][4] *= buffer[3][2];
    
    dirty = false;
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
  
  boolean grab(float x, float y) {
    selectionBuffer.beginDraw();
    selectionBuffer.background(0);
    selectionBuffer.fill(#ffffff);
    selectionBuffer.noStroke();
    selectionBuffer.translate(width / 2, height / 2);
    selectionBuffer.scale(scale);
    
    selectionBuffer.quad(corners[0].x, corners[0].y, 
      corners[1].x, corners[1].y, 
      corners[2].x, corners[2].y, 
      corners[3].x, corners[3].y);
    
    selectionBuffer.endDraw();
    
    return selectionBuffer.get((int)((x * scale) + (width / 2)), (int)((y * scale) + (height / 2))) == #ffffff;
  }
  
  void setTexture(Texture t) {
    this.texture = t;
    this.c = #ffffff;
  }
  
  void setName(String name) {
    this.name = name;
  }
  
  String getName() {
    return name;
  }
  
  void select() {
    clearSelection = false;
    toSelect = this;
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