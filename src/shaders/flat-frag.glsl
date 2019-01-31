#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting
in vec4 fs_Pos;
out vec4 out_Col;

void main() {
  vec4 sunColor = vec4(220.0 / 255.0, 163.0 / 255.0, 113.0 / 255.0, 1.0);
  if(length(fs_Pos * vec4(1.7, 1.0, 1.0, 1.0) - vec4(-1.27, 0.638, 0.999, 1.0)) < 0.04) {
    out_Col = sunColor;
  } else if(length(fs_Pos * vec4(1.7, 1.0, 1.0, 1.0) - vec4(-1.27, 0.638, 0.999, 1.0)) < 0.49) {
    float t = smoothstep(0.0, 1.0, fs_Pos.y);
    vec4 bgCol = mix(vec4(154.0 / 255.0, 223.0 / 255.0, 245.0 / 255.0, 1.0), vec4(114.0 / 255.0, 183.0 / 255.0, 205.0 / 255.0, 1.0), t);
    t = smoothstep(0.04, 0.49, length(fs_Pos * vec4(1.7, 1.0, 1.0, 1.0) - vec4(-1.27, 0.638, 0.999, 1.0)));
    out_Col = mix(sunColor, bgCol, t);
  } else {
    float t = smoothstep(0.0, 1.0, fs_Pos.y);
    out_Col = mix(vec4(154.0 / 255.0, 223.0 / 255.0, 245.0 / 255.0, 1.0), vec4(114.0 / 255.0, 183.0 / 255.0, 205.0 / 255.0, 1.0), t);
  }
}
