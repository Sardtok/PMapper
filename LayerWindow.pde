class LayerWindow { //<>//
  Set<Layer> layers = new LinkedHashSet<Layer>();
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
      g.text(l.getName(), 2, y);
      y += fontHeight;
    }

    g.endDraw();

    image(g, position.x, position.y, g.width / scale, g.height / scale);
    position.handleDrawn = false;
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
}