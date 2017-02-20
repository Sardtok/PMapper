abstract class Texture implements Layer {
  Set<Rect> uvs = new LinkedHashSet<Rect>();
  String name;
  
  Texture(String name) {
    this.name = name;
  }

  String getName() {
    return name;
  }
  
  void select() {
    Rect s = getSelectedShape();
    
    if (s != null) {
      s.setTexture(this);
    }
    
    textureWindow.clearSelection();
    textureWindow.addSelected(this);
    
    clearSelection = false;
  }

  abstract PImage getImage();
}

class ImageTexture extends Texture {
  PImage image;
  
  ImageTexture(PImage image, String name) {
    super(name);
    this.image = image;
  }
  
  PImage getImage() {
    return image;
  }
}

class MovieTexture extends Texture {
  Movie movie;
  
  MovieTexture(Movie movie, String name) {
    super(name);
    this.movie = movie;
  }
  
  PImage getImage() {
    return movie;
  }
}