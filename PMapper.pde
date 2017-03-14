import java.awt.*;
import java.util.*;
import processing.video.*;

boolean left;
boolean right;
boolean up;
boolean down;
boolean shiftDown;
Vertex mousePosition;
int previousNudge;

Mode mode = Mode.EDIT_SCENE;
float scale;
float invScale;
float VERTEX_SIZE;
float VERTEX_SIZE_SQUARED;
float BUTTON_SIZE;
float BUTTON_SIZE_SQUARED;
float BORDER_SIZE;
float NUDGE = 0.25;

Set<Vertex> selection = new HashSet<Vertex>();
PGraphics selectionBuffer;
Selectable toSelect;
boolean clearSelection;

Toolbar tools = new Toolbar(new Vertex(-0.9, -0.9));
Toolbar videoControls = new Toolbar(new Vertex(-0.9, 0.9));
LayerWindow textureWindow;
LayerWindow shapeWindow;
PFont font;
PImage icons;

Scene scene = new Scene();
PShader texShader;
PShader colShader;
color shapeColors[] = {
  #4080ff,
  #ff4080,
  #80ff40,
  #8040ff,
  #ff8040,
  #40ff80
};

void setup() {
  size(1280, 800, P3D);
  ortho(-width/2f, width/2f, -height/2f, height/2f, -100.0f, 100.0f);
  selectionBuffer = createGraphics(width, height, P3D);
  ellipseMode(RADIUS);
  textureMode(NORMAL);
  scale = min(width, height) / 2.0;
  invScale = 1.0 / scale;

  VERTEX_SIZE = 5.0 * invScale;
  VERTEX_SIZE_SQUARED = VERTEX_SIZE * VERTEX_SIZE;
  BUTTON_SIZE = 10.0 * invScale;
  BUTTON_SIZE_SQUARED = BUTTON_SIZE * BUTTON_SIZE;
  BORDER_SIZE = invScale;
  
  icons = loadImage("Icons.png");
  tools.addTool("Load", new Button(new Vertex(0, 0), new Runnable() { public void run() { selectInput("Load scene", "loadScene"); }}));
  tools.addTool("Save", new Button(new Vertex(1.0 / 6.0, 0), new Runnable() { public void run() { selectOutput("Save scene", "saveScene"); }}));
  tools.addTool("Rectangle", new Button(new Vertex(2.0 / 6.0, 0), new Runnable() { public void run() { createRect(); }}));
  tools.addTool("Merge", new Button(new Vertex(3.0 / 6.0, 0), new Runnable() { public void run() { merge(); }}));
  tools.addTool("Split", new Button(new Vertex(4.0 / 6.0, 0), new Runnable() { public void run() { split(); }}));
  tools.addTool("Add texture", new Button(new Vertex(5.0 / 6.0, 0), new Runnable() { public void run() { selectInput("Load texture", "loadTexture"); }}));
  tools.disableTool("Merge");
  tools.disableTool("Split");

  videoControls.addTool("Play", new Button(new Vertex(0, 1.0 / 2.0), new Runnable() { public void run() { play(); }}));
  videoControls.addTool("Pause", new Button(new Vertex(1.0 / 6.0, 1.0 / 2.0), new Runnable() { public void run() { pause(); }}));
  videoControls.addTool("Rewind", new Button(new Vertex(2.0 / 6.0, 1.0 / 2.0), new Runnable() { public void run() { rewind(); }}));
  
  font = createFont("Verdana", 10);
  textFont(font);
  textureWindow = new LayerWindow("Textures", new Vertex(-width / (scale * 2) + 0.1, -0.5));
  shapeWindow = new LayerWindow("Shapes", new Vertex(width / (scale * 2) - 0.3, -0.5));
  
  texShader = loadShader("quadtexfrag.glsl", "quadtexvert.glsl");
  colShader = loadShader("quadcolfrag.glsl", "quadcolvert.glsl");
  createRect();
}

void draw() {
  ((PGraphicsOpenGL) g).modelview.m23 = 0;
  
  background(0);
  noStroke();

  translate(width / 2, height / 2);
  scale(scale, scale, 1.0);
  
  
  if (mode != Mode.PRESENTATION) {
    move();
  }
  
  if (mode != Mode.EDIT_UVS) {
    scene.draw();
  }

  resetShader();
  
  if (mode != Mode.PRESENTATION) {
    drawHandles();
    drawButtons();
    textureWindow.draw();
    shapeWindow.draw();
  }

  mousePosition = null;
}

void move() {
  int diff = frameCount - previousNudge;
  if (diff < 5 || !(left || right || up || down)) {
    return;
  }
  
  float x = 0;
  float y = 0;
  if (left) {
    x -= NUDGE * invScale;
  }
  
  if (right) {
    x += NUDGE * invScale;
  }
  
  if (up) {
    y -= NUDGE * invScale;
  }
  
  if (down) {
    y += NUDGE * invScale;
  }
  
  for (Vertex v : selection) {
    v.x += x;
    v.y += y;
    
    for (Rect s : v.shapes) {
      s.dirty = true;
    }
  }
  
  previousNudge = frameCount;
}

void exit() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).movie.stop();
    }
  }
  
  super.exit();
}

void drawHandles() {
  if (mode == Mode.EDIT_SCENE) {
    scene.drawHandles();
  } else {
    Texture selectedTexture = (Texture) textureWindow.selected.iterator().next();
  }
  
  tools.position.drawHandle();
  videoControls.position.drawHandle();
  textureWindow.position.drawHandle();
  shapeWindow.position.drawHandle();
}

void drawButtons() {
  tools.draw();
  videoControls.draw();
}

Vertex getMousePosition() {
  if (mousePosition == null) {
    mousePosition = new Vertex((mouseX - width / 2.0) * invScale, (mouseY - height / 2.0) * invScale);
  }

  return mousePosition;
}

void mousePressed() {
  Vertex mouse = getMousePosition();
  if (selectionHasTools()) {
    selection.clear();
  }
  toSelect = scene.grab(mouse.x, mouse.y);
  
  if (toSelect == null && !shiftDown) {
    if (tools.position.grab(mouse.x, mouse.y)) {
      toSelect = tools.position;
    } else if (videoControls.position.grab(mouse.x, mouse.y)) {
      toSelect = videoControls.position;
    } else if (textureWindow.position.grab(mouse.x, mouse.y)) {
      toSelect = textureWindow.position;
    } else if (shapeWindow.position.grab(mouse.x, mouse.y)) {
      toSelect = shapeWindow.position;
    } else {
      clearSelection = true;
    }
  }
}

boolean selectionHasTools() {
  return selection.contains(tools.position)
    || selection.contains(videoControls.position)
    || selection.contains(textureWindow.position)
    || selection.contains(shapeWindow.position);
}

void select() {
  if (toSelect == null && !clearSelection) {
    enableContextSensitiveTools();
    return;
  }
  
  if (clearSelection) {
    clearSelection();
  } else if (shiftDown) {
    toggleSelection(toSelect.getVertices());
  } else {
    clearSelection();
    for (Vertex v : toSelect.getVertices()) {
      selection.add(v);
    }
  }
  
  for (Vertex v : selection) {
    for (Rect s : v.shapes) {
      shapeWindow.addSelected(s);
    }
  }
  
  toSelect = null;
  clearSelection = false;
  enableContextSensitiveTools();
}

void clearSelection() {
  shapeWindow.clearSelection();
  selection.clear();
}

void toggleSelection(Iterable<Vertex> vertexIterator) {
  ArrayList<Vertex> vertices = new ArrayList<Vertex>();
  for (Vertex v : vertexIterator) {
    vertices.add(v);
  }

  if (selection.containsAll(vertices)) {
    selection.removeAll(vertices);
  } else {
    selection.addAll(vertices);
  }
}

void mouseDragged() {
  float dX = (mouseX - pmouseX) * invScale;
  float dY = (mouseY - pmouseY) * invScale;
  select();

  for (Vertex v : selection) {
    v.x += dX;
    v.y += dY;
    
    for (Rect s : v.shapes) {
      s.dirty = true;
    }
  }

  tools.disableTool("Merge");
  if (selection.size() == 1) {
    snap();
  }
}

void mouseClicked() {
  if (tools.click() || videoControls.click()) {
    return;
  }
  
  shapeWindow.click();
  textureWindow.click();
  
  select();
}

void keyPressed() {
  shiftDown |= keyCode == SHIFT;
  left |= keyCode == LEFT;
  right |= keyCode == RIGHT;
  up |= keyCode == UP;
  down |= keyCode == DOWN;
}

void keyReleased() {
  shiftDown ^= keyCode == SHIFT;
  left ^= keyCode == LEFT;
  right ^= keyCode == RIGHT;
  up ^= keyCode == UP;
  down ^= keyCode == DOWN;
}

void createRect() {
  Rect r = new Rect(new Vertex(-0.25, -0.25), new Vertex(-0.25, 0.25), new Vertex(0.25, 0.25), new Vertex(0.25, -0.25), shapeColors[scene.shapes.size() % shapeColors.length]);
  scene.addRect(r);
  r.setName("Rect " + scene.shapes.size());
}

Vertex getSelectedVertex() {
  if (selection.size() != 1) {
    return null;
  }

  return selection.iterator().next();
}

Rect getSelectedShape() {
  Set<Rect> selectedShapes = new HashSet<Rect>();
  for (Vertex v : selection) {
    selectedShapes.addAll(v.shapes);
  }
  
  Iterator<Rect> it = selectedShapes.iterator();
  while (it.hasNext()) {
    boolean allSelected = true;
    Rect r = it.next();
    for (Vertex v : r.corners) {
      if (!selection.contains(v)) {
        allSelected = false;
        break;
      }
    }
    
    if (!allSelected) {
      it.remove();
    }
  }
  
  if (selectedShapes.size() == 1) {
    return selectedShapes.iterator().next();
  }
  
  return null;
}

void snap() {
  Vertex selected = selection.iterator().next();

  for (Vertex v : scene.vertices) {
    if (selected != v && v.grab(selected.x, selected.y)) {
      selected.x = v.x;
      selected.y = v.y;
      tools.enableTool("Merge");
      return;
    }
  }
}

void enableContextSensitiveTools() {
  enableMerge();
  enableSplit();
}

void enableMerge() {
  Vertex selected = getSelectedVertex();
  if (selected == null) {
    tools.disableTool("Merge");
    return;
  }
  
  for (Vertex v : scene.vertices) {
    if (selected != v && v.grab(selected.x, selected.y)) {
      tools.enableTool("Merge");
      return;
    }
  }
  
  tools.disableTool("Merge");
}

void enableSplit() {
  Vertex selected = getSelectedVertex();
  if (selected == null || selected.shapes.isEmpty()) {
    tools.disableTool("Split");
  } else if (selected.shapes.size() > 1) {
    tools.enableTool("Split");
  } else {
    int count = 0;
    for (Vertex v : selected.shapes.iterator().next().corners) {
      if (selected == v) {
        count++;
      }
    }
    
    if (count > 1) {
      tools.enableTool("Split");
    }
  }
}

void merge() {
  Vertex selected = getSelectedVertex();
  if (selected == null) {
    return;
  }
  
  ArrayList<Vertex> mergeCandidates = new ArrayList<Vertex>();
  for (Vertex v : scene.vertices) {
    if (selected != v && v.grab(selected.x, selected.y)) {
      mergeCandidates.add(v);
    }
  }
  
  for (Vertex v : mergeCandidates) {
    selected.merge(v);
  }
  
  enableContextSensitiveTools();
}

void split() {
  Vertex selected = getSelectedVertex();
  if (selected == null) {
    return;
  }
  
  boolean first = true;
  for (Rect s : selected.shapes) {
    for (int i = 0; i < s.corners.length; i++) {
      if (selected == s.corners[i]) {
        if (first) {
          first = false;
        } else {
          Vertex replacement = new Vertex(selected.x, selected.y);
          replacement.addShape(s);
          scene.vertices.add(replacement);
          s.corners[i] = replacement;
        }
      }
    }
  }
  
  enableContextSensitiveTools();
}

void play() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).play();
    }
  }
}

void pause() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).pause();
    }
  }
}

void rewind() {
  for (Texture t : scene.textures.values()) {
    if (t instanceof MovieTexture) {
      ((MovieTexture) t).rewind();
    }
  }
}

void loadScene(File f) {
  if (f == null) {
    return;
  }
  
  Scene scene = new Scene();
  scene.fromJSON(loadJSONObject(f));
  this.scene = scene;
}

void saveScene(File f) {
  if (f == null) {
    return;
  }
  
  saveJSONObject(scene.toJSON(), f.getAbsolutePath());
}

void loadTexture(File f) {
  loadTexture(f, scene);
}

void loadTexture(File f, Scene scene) {
  if (f == null) {
    return;
  }
  
  PImage img = loadImage(f.getAbsolutePath());
  Texture t = null;
  if (img != null && img.width >= 0) {
    t = new ImageTexture(img, f.getName());
  } else {
    t = new MovieTexture(new Movie(this, f.getAbsolutePath()), f.getName());
  }
  
  if (!scene.addTexture(t, f.getAbsolutePath())) {
    return;
  }

  for (Rect s : scene.shapes) {
    Collection<Vertex> verts = (Collection<Vertex>) s.getVertices();
    if (selection.containsAll(verts) && verts.containsAll(selection)) {
      s.setTexture(t);
    }
  }
}