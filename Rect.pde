class Rect implements Selectable {
  Vertex corners[] = new Vertex[4];
  PImage texture;
  color c = #ffffff;
  
  Rect(Vertex v0, Vertex v1, Vertex v2, Vertex v3, color c) {
    corners[0] = v0;
    corners[1] = v1;
    corners[2] = v2;
    corners[3] = v3;
    
    this.c = c;
  }
  
  void draw() {
    beginShape(QUADS);
    
    if (texture != null) {
      texture(texture);
      tint(c);
    } else {
      fill(c);
    }
    
    corners[0].draw();
    corners[1].draw();
    corners[2].draw();
    corners[3].draw();
    
    endShape();
  }
  
  void drawHandles() {
    for (Vertex v : corners) {
      v.drawHandle();
    }
  }
  
  boolean grab(float x, float y) {
    return false;
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