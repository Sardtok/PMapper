class Button {
  Vertex uvs;
  boolean enabled;
  Runnable action;
  
  Button(Vertex uvs, Runnable action) {
    this.uvs = uvs;
    this.action = action;
  }
  
  void draw(float x, float y, Vertex mouse) {
    if (!enabled) {
      return;
    }
    
    fill(#8080a0);
    ellipse(x, y, BUTTON_SIZE + BORDER_SIZE, BUTTON_SIZE + BORDER_SIZE);
    
    fill(isOver(x - mouse.x, y - mouse.y) ? #ffffff : #a0a0ff);  
    ellipse(x, y, BUTTON_SIZE - BORDER_SIZE, BUTTON_SIZE - BORDER_SIZE);
    
    beginShape(QUADS);
    noStroke();
    texture(icons);
    vertex(x - BUTTON_SIZE / 2, y - BUTTON_SIZE / 2, uvs.x, uvs.y);
    vertex(x - BUTTON_SIZE / 2, y + BUTTON_SIZE / 2, uvs.x, uvs.y + 10.0 / icons.height);
    vertex(x + BUTTON_SIZE / 2, y + BUTTON_SIZE / 2, uvs.x + 10.0 / icons.width, uvs.y + 10.0 / icons.height);
    vertex(x + BUTTON_SIZE / 2, y - BUTTON_SIZE / 2, uvs.x + 10.0 / icons.width, uvs.y);
    endShape();
  }
  
  boolean isOver(float x, float y) {
    return (x * x + y * y) < BUTTON_SIZE_SQUARED;
  }
  
  void disable() {
    enabled = false;
  }
  
  void enable() {
    enabled = true;
  }
  
  boolean click(float x, float y) {
    if (!enabled) {
      return false;
    }
    
    if (isOver(x, y)) {
      action.run();
      return true;
    }
    
    return false;
  }
}