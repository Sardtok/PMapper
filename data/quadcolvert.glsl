uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;

varying vec4 vertColor;
void main() {
  gl_Position = transform * vec4(position.xy, 0.0, position.w);

  vertColor = color;
}