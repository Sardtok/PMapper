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
    
    stroke(#8080a0);
    fill(#a0a0ff);
    
    if (isOver(x - mouse.x, y - mouse.y)) {
      fill(#ffffff);
    }
    
    ellipse(x, y, BUTTON_SIZE, BUTTON_SIZE);
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