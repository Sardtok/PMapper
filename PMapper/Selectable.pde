interface Selectable {
  boolean grab(float x, float y);
  Iterable<Vertex> getVertices();
}