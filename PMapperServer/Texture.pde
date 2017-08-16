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
  float speed;
  int previousRead;
  boolean firstRead = true;
  
  MovieTexture(String name) {
    super(name);
  }
  
  abstract boolean available();
  abstract void read();
  
  abstract float duration();
  abstract float time();
  abstract void jump(float time);
  
  abstract void loop();
  abstract void play();
  abstract void speed(float speed);
  abstract void pause();
  abstract void stop();
  
  void rewind() {
    jump(0);
  }
  
  void setSpeed(float speed) {
    this.speed = speed;
    
    if (speed >= 0) {
      speed(speed);
      loop();
    } else {
      speed(1);
      play();
    }
  }
  
  void update() {
    if (speed < 0) {
      if ((frameCount - previousRead) < frameRate * REWIND_REFRESH_RATE) {
        return;
      }
      
      float t = time() + (speed * REWIND_REFRESH_RATE);
      if (t < 0) {
        t = duration() + t;
      }
      jump(t);
      play();
    }
    
    if (available()) {
      if (firstRead) {
        firstRead = false;
        texturesWaiting--;
      }
      
      read();
      
      if (speed < 0) {
        pause();
        previousRead = frameCount;
      }
    }
  }
}

class PMovieTexture extends MovieTexture {
  Movie movie;
  boolean printThat;
  
  PMovieTexture(Movie movie, String name) {
    super(name);
    this.movie = movie;
  }
  
  PImage getImage() {
    return movie;
  }
  
  void loop() {
    movie.loop();
  }
  
  void play() {
    movie.play();
  }
  
  void speed(float speed) {
    movie.speed(speed);
  }
  
  void pause() {
    movie.pause();
  }
  
  void stop() {
    movie.stop();
  }
  
  boolean available() {
    return movie.available();
  }
  
  void read() {
    movie.volume(0);
    movie.read();
  }
  
  float time() {
    return movie.time();
  }
  
  float duration() {
    return movie.duration();
  }
  
  void jump(float time) {
    movie.jump(time);
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
  
  void loop() {
    movie.loop();
  }
  
  void play() {
    movie.play();
  }
  
  void speed(float speed) {
    movie.speed(speed);
  }
  
  void pause() {
    movie.pause();
  }
  
  void stop() {
    rewind();
    pause();
  }
  
  boolean available() {
    return movie.available();
  }
  
  void read() {
    movie.volume(0);
    movie.read();
  }
  
  float time() {
    return movie.time();
  }
  
  float duration() {
    return movie.duration();
  }
  
  void jump(float time) {
    movie.jump(time);
  }
}