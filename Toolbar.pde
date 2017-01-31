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
  
  void click() {
    Vertex mouse = getMousePosition();
    float x = position.x - mouse.x;
    float y = position.y - mouse.y;
    
    for (Button b : tools.values()) {
      if (!b.enabled) {
        continue;
      }
      
      b.click(x, y);
      x += 0.1;
    }
  }
  
  void draw() {
    Vertex mouse = getMousePosition();
    float x = position.x;
    for (Button b : tools.values()) {
      if (!b.enabled) {
        continue;
      }
      
      b.draw(x, position.y, mouse);
      x += 0.1;
    }
  }
}