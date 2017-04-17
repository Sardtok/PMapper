abstract class Texture {
  Set<Quad> uvs = new LinkedHashSet<Quad>();
  String name;
  
  Texture(String name) {
    this.name = name;
  }

  String getName() {
    return name;
  }
  
  abstract PImage getImage();
  abstract void update();
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
  
  void update() {
    // Do nothing
  }
}

abstract class MovieTexture extends Texture {
  MovieTexture(String name) {
    super(name);
  }
  
  abstract void play();
  abstract void pause();
  abstract void rewind();
  abstract void stop();
}

class PMovieTexture extends MovieTexture {
  Movie movie;
  
  PMovieTexture(Movie movie, String name) {
    super(name);
    this.movie = movie;
  }
  
  PImage getImage() {
    return movie;
  }
  
  void play() {
    movie.loop();
  }
  
  void pause() {
    movie.pause();
  }
  
  void rewind() {
    movie.jump(0);
  }
  
  void stop() {
    movie.stop();
  }
  
  void update() {
    if (movie.available()) {
      movie.read();
    }
  }
}

class GLMovieTexture extends MovieTexture {
  GLMovie movie;
  
  GLMovieTexture(GLMovie movie, String name) {
    super(name);
    this.movie = movie;
  }
  
  PImage getImage() {
    return movie;
  }
  
  void play() {
    movie.loop();
  }
  
  void pause() {
    movie.pause();
  }
  
  void rewind() {
    movie.jump(0);
  }
  
  void stop() {
    pause();
    rewind();
  }
  
  void update() {
    if (movie.available()) {
      movie.read();
    }
  }
}