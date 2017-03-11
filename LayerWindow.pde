class LayerWindow { //<>//
  Set<Layer> layers = new LinkedHashSet<Layer>();
  Set<Layer> selected = new HashSet<Layer>();
  Vertex position;
  String title;
  PGraphics g;

  int fontHeight;
  int width;
  int height;

  LayerWindow(String title, Vertex position) {
    this.title = title;
    this.position = position;
    fontHeight =  ceil(textAscent() + textDescent());
    fitToText(title);
  }

  void draw() {
    g.beginDraw();
    g.background(#002040);
    
    g.noFill();
    g.stroke(#6080a0);
    g.strokeWeight(1);
    g.rect(0, 0, width - 1, height - 1);
    
    g.noStroke();
    g.fill(#c0d0ff);
    g.textAlign(LEFT, TOP);
    g.textFont(font);
    g.text(title, 2, 2);

    float y = fontHeight + 2;
    for (Layer l : layers) {
      if (selected.contains(l)) {
        g.fill(#604000);
        g.rect(1, y + 2, width - 2, fontHeight);
        g.fill(#c0d0ff);
      }
      g.text(l.getName(), 2, y + 2);
      y += fontHeight;
    }

    g.endDraw();

    image(g, position.x, position.y, g.width * invScale, g.height * invScale);
    position.handleDrawn = false;
  }

  void clearSelection() {
    selected.clear();
  }
  
  void addSelected(Layer l) {
    if (!layers.contains(l)) {
      return;
    }
    
    selected.add(l);
  }
  
  void add(Layer l) {
    if (!layers.add(l)) {
      return;
    }

    fitToText(l.getName());
  }

  void fitToText(String text) {
    float w = textWidth(text);
    width = max(ceil(w) + 4, width);
    height = ceil(height + fontHeight + 4);
    g = createGraphics(width, height, P2D);
  }
  
  void click() {
    Vertex mouse = getMousePosition();
    float dx = (mouse.x - position.x) * scale;
    float dy = (mouse.y - position.y) * scale;
    
    if (dx < 0 || dy < 0 || dx > width || dy > width) {
      return;
    }
    
    float pos = fontHeight + 2;
    for (Layer l : layers) {
      if (dy >= pos && dy < pos + fontHeight) {
        l.select();
        break;
      }
      pos += fontHeight;
    }
  }
}