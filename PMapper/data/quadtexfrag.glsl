#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertFeather;
varying vec3 vertTexCoord;

float max(vec4 vector) {
  return max(max(vector.x, vector.y), max(vector.z, vector.q));
}

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st / vertTexCoord.p)
               * vec4(vertColor.rgb, vertColor.a - (max(vertFeather) - 0.95) * 20);
}
