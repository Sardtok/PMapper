class Toolbar {
  Vertex position;
  LinkedHashMap<String, Button> tools = new LinkedHashMap<String, Button>();
  
  Toolbar(Vertex position) {
    this.position = position;
  }
  
  void addTool(String name, Button button) {
    tools.put(name, button);
    button.enable();
  }
  
  void enableTool(String name) {
    tools.get(name).enable();
  }
  
  void disableTool(String name) {
    tools.get(name).disable();
  }
  
  boolean click() {
    Vertex mouse = getMousePosition();
    float x = position.x - mouse.x + 0.1;
    float y = position.y - mouse.y;
    
    for (Button b : tools.values()) {
      if (!b.enabled) {
        continue;
      }
      
      if (b.click(x, y)) {
        return true;
      }
      x += 0.1;
    }
    
    return false;
  }
  
  void draw() {
    Vertex mouse = getMousePosition();
    float x = position.x + 0.1;
    for (Button b : tools.values()) {
      if (!b.enabled) {
        continue;
      }
      
      b.draw(x, position.y, mouse);
      x += 0.1;
    }
    position.handleDrawn = false;
  }
}