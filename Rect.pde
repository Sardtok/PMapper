class Rect implements Selectable, Layer {
  Vertex corners[] = new Vertex[4];
  Vertex uvs[] = {new Vertex(0, 0), new Vertex(0, 1), new Vertex(1, 1), new Vertex(1, 0)};
  
  boolean rbDirty = true;
  Vertex rectBuf[][] = new Vertex[5][5];
  boolean uvbDirty = true;
  Vertex uvBuf[][] = new Vertex[5][5];
  
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
      texture(texture.getImage());
      tint(c);
    } else {
      fill(c);
    }
    
    if (rbDirty) {
      populateBuffer(rectBuf, corners);
    }
    
    if (uvbDirty) {
      populateBuffer(uvBuf, uvs);
    }
    
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        rectBuf[i][j].draw(uvBuf[i][j]);
        rectBuf[i + 1][j].draw(uvBuf[i + 1][j]);
        rectBuf[i + 1][j + 1].draw(uvBuf[i + 1][j + 1]);
        rectBuf[i][j + 1].draw(uvBuf[i][j + 1]);
      }
    }
    
    endShape();
  }
  
  void populateBuffer(Vertex[][] buffer, Vertex[] original) {
    buffer[0][0] = original[0];
    buffer[4][0] = original[1];
    buffer[4][4] = original[2];
    buffer[0][4] = original[3];
    
    
    buffer[0][2] = buffer[0][0].middle(buffer[0][4]);
    buffer[2][0] = buffer[0][0].middle(buffer[4][0]);
    buffer[2][4] = buffer[4][4].middle(buffer[0][4]);
    buffer[4][2] = buffer[4][0].middle(buffer[4][4]);
    buffer[2][2] = buffer[2][0].middle(buffer[2][4]);
    
    buffer[0][1] = buffer[0][0].middle(buffer[0][2]);
    buffer[0][3] = buffer[0][2].middle(buffer[0][4]);
    buffer[2][1] = buffer[2][0].middle(buffer[2][2]);
    buffer[2][3] = buffer[2][2].middle(buffer[2][4]);
    buffer[4][1] = buffer[4][0].middle(buffer[4][2]);
    buffer[4][3] = buffer[4][2].middle(buffer[4][4]);
    
    buffer[1][0] = buffer[0][0].middle(buffer[2][0]);
    buffer[1][1] = buffer[0][1].middle(buffer[2][1]);
    buffer[1][2] = buffer[0][2].middle(buffer[2][2]);
    buffer[1][3] = buffer[0][3].middle(buffer[2][3]);
    buffer[1][4] = buffer[0][4].middle(buffer[2][4]);
    
    buffer[3][0] = buffer[2][0].middle(buffer[4][0]);
    buffer[3][1] = buffer[2][1].middle(buffer[4][1]);
    buffer[3][2] = buffer[2][2].middle(buffer[4][2]);
    buffer[3][3] = buffer[2][3].middle(buffer[4][3]);
    buffer[3][4] = buffer[2][4].middle(buffer[4][4]);
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
    
    jsonCorners.setInt(0, scene.indexOf(corners[0]));
    jsonCorners.setInt(1, scene.indexOf(corners[1]));
    jsonCorners.setInt(2, scene.indexOf(corners[2]));
    jsonCorners.setInt(3, scene.indexOf(corners[3]));
    
    json.setJSONArray("corners", jsonCorners);
    
    json.setFloat("red", red(c));
    json.setFloat("green", green(c));
    json.setFloat("blue", blue(c));
    json.setFloat("alpha", alpha(c));
    
    if (texture != null) {
      json.setString("texture", "PATH");
    }
    
    return json;
  }
  
  Iterable<Vertex> getVertices() {
    return Arrays.asList(corners);
  }
}