uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  gl_Position = transform * vec4(position.xy, 0.0, position.w);

  vertColor = color;
  vertTexCoord = vec4(texCoord, position.zw);
}
