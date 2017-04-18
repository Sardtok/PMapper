class Vertex {
  Set<Quad> shapes = new HashSet<Quad>();
  float x, y;
  boolean handleDrawn;

  Vertex(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void addShape(Quad s) {
    shapes.add(s);
  }

  void draw() {
    vertex(x, y);
    handleDrawn = false;
  }

  void draw(Vertex uvs) {
    vertex(x, y, uvs.x, uvs.y);
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

    fill(#ff0000);
    ellipse(x, y, VERTEX_SIZE + BORDER_SIZE, VERTEX_SIZE + BORDER_SIZE);
    
    if (selection.contains(this)) {
      fill(#ffa0a0);
    } else {
      fill(#ffffff);
    }
    ellipse(x, y, VERTEX_SIZE - BORDER_SIZE, VERTEX_SIZE - BORDER_SIZE);
    handleDrawn = true;
  }

  void merge(Vertex other) {
    shapes.addAll(other.shapes);
    for (Quad s : other.shapes) {
      s.replace(other, this);
    }
    scene.vertices.remove(other);
  }

  Vertex middle(Vertex other) {
    return new Vertex((x + other.x) / 2, (y + other.y) / 2);
  }

  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    
    json.setFloat("x", x);
    json.setFloat("y", y);
    
    return json;
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