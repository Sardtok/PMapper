class Texture {
  Set<Vertex> uvs = new LinkedHashSet<Vertex>();
  PImage image;

  Texture(PImage image) {
    this.image = image;
  }
}