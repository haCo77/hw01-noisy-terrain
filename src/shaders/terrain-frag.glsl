#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_height;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

void main()
{
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    if(fs_height == 0.5) {
        out_Col = vec4(120.0 / 255.0, 156.0 / 255.0, 150.0 / 255.0, 1.0);
    } else if(fs_height < 0.55) {
        float tt = smoothstep(0.5, 0.55, fs_height);
        vec3 sand = mix(vec3(225.0 / 255.0, 188.0 / 255.0, 143.0 / 255.0), 
                        vec3(225.0 / 255.0, 154.0 / 255.0, 62.0 / 255.0), tt);
        out_Col = vec4(mix(sand + random1(floor(vec3(fs_Pos.xz + u_PlanePos, 1.0) * 11.287), 
                            vec3(51.241, 31.4437, -47.314159)) / 10.0, vec3(144.0 / 255.0, 213.0 / 255.0, 235.0 / 255.0), t), 1.0);
    } else {
        float colort = (fs_height - 0.53) * 1.2 + 0.3;
        // float colort = fs_height;
        vec3 tree = mix(vec3(156.0 / 255.0, 151.0 /255.0, 92.0 / 255.0), 
                        vec3(102.0 / 255.0, 111.0 /255.0, 70.0 / 255.0), sqrt((fs_height - 0.5) / 0.45));
        out_Col = vec4(mix(tree, vec3(144.0 / 255.0, 213.0 / 255.0, 235.0 / 255.0), t), 1.0);
    }
}
