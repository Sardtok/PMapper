class Button {
  Vertex position;
  Vertex uvs;
  Runnable action;
  
  Button(Vertex position, Vertex uvs, Runnable action) {
    this.position = position;
    this.uvs = uvs;
    this.action = action;
  }
  
  void draw(Vertex mouse) {
    stroke(#8080a0);
    fill(#a0a0ff);
    
    if (isOver(mouse)) {
      fill(#ffffff);
    }
    
    ellipse(position.x, position.y, BUTTON_SIZE, BUTTON_SIZE);
  }
  
  boolean isOver(Vertex mouse) {
    float diffX = position.x - mouse.x;
    float diffY = position.y - mouse.y;
    
    return (diffX * diffX + diffY * diffY) < BUTTON_SIZE_SQUARED;
  }
  
  void click(Vertex mouse) {
    if (isOver(mouse)) {
      action.run();
    }
  }
}