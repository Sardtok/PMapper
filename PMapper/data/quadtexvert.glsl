uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec4 feather;
attribute vec2 texCoord;
attribute float texCoordQ;

varying vec4 vertColor;
varying vec4 vertFeather;
varying vec3 vertTexCoord;

void main() {
  gl_Position = transform * position;

  vertColor = color;
  vertTexCoord = vec3(texCoord * texCoordQ, texCoordQ);
  vertFeather = feather;
}
