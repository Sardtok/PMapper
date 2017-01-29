class Vertex implements Selectable {
  float x, y;
  boolean handleDrawn;

  Vertex(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void draw() {
    vertex(x, y);
    handleDrawn = false;
  }

  void draw(float u, float v) {
    vertex(x, y, u, v);
    handleDrawn = false;
  }

  void drawHandle() {
    if (handleDrawn) {
      return;
    }

    if (selection.contains(this)) {
      fill(#ffa0a0);
    } else {
      fill(#ffffff);
    }
    ellipse(x, y, VERTEX_SIZE, VERTEX_SIZE);
    handleDrawn = true;
  }

  boolean grab(float x, float y) {
    float diffX = this.x - x;
    float diffY = this.y - y;
    return (diffX * diffX + diffY * diffY) < VERTEX_SIZE_SQUARED;
  }

  Iterable<Vertex> getVertices() {
    return new Iterable<Vertex>() {
      public Iterator<Vertex> iterator() {
        return new Iterator<Vertex>() {
          boolean done;

          public boolean hasNext() {
            return !done;
          }

          public Vertex next() {
            if (done) {
              throw new NoSuchElementException();
            }

            done = true;
            return Vertex.this;
          }

          public void remove() {
            throw new UnsupportedOperationException();
          }
        };
      }
    };
  }
}