#version 300 es


uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Time;
uniform float u_MH;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out float fs_height;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2(vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(3.117, 1.271)), dot(p + seed, vec2(2.695, 1.833)))) * 853.545);
}

float falloff(float dis) {
  return 1.0 - dis * dis * dis * (dis * (dis * 6.0 - 15.0) + 10.0); 
}

float perlin(vec2 p, vec2 seed) {
  p *= 0.041415926;
  vec2 pfrac = fract(p);
  if(pfrac.x == 0.0 && pfrac.y == 0.0) {
    return 0.0;
  }
  vec2 lbpos = p - pfrac;
  vec2 lbvec = normalize(random2(lbpos, seed));
  vec2 luvec = normalize(random2(lbpos + vec2(0.0, 1.0), seed));
  vec2 rbvec = normalize(random2(lbpos + vec2(1.0, 0.0), seed));
  vec2 ruvec = normalize(random2(lbpos + vec2(1.0, 1.0), seed));
  float lbdot = dot(lbvec, pfrac);
  float ludot = dot(luvec, pfrac - vec2(0.0, 1.0));
  float rbdot = dot(rbvec, pfrac - vec2(1.0, 0.0));
  float rudot = dot(ruvec, pfrac - vec2(1.0, 1.0));
  float lbw = falloff(pfrac.x) * falloff(pfrac.y);
  float luw = falloff(pfrac.x) * falloff(1.0 - pfrac.y);
  float rbw = falloff(1.0 - pfrac.x) * falloff(pfrac.y);
  float ruw = falloff(1.0 - pfrac.x) * falloff(1.0 - pfrac.y);
  return lbdot * lbw + ludot * luw + rbdot * rbw + rudot * ruw;
}

float interpNoise2d(vec2 p) {
  float intx = floor(p.x);
  float inty = floor(p.y);
  float fracx = p.x - intx;
  float fracy = p.y - inty;

  float v1 = perlin(vec2(intx, inty), vec2(51.241, 31.4437));
  float v2 = perlin(vec2(intx, inty + 1.0), vec2(51.241, 31.4437));
  float v3 = perlin(vec2(intx + 1.0, inty), vec2(51.241, 31.4437));
  float v4 = perlin(vec2(intx + 1.0, inty + 1.0), vec2(51.241, 31.4437));

  float i1 = mix(v1, v3, fracx);
  float i2 = mix(v2, v4, fracx);
  return mix(i1, i2, fracy);
}

float fbm(vec2 p) {
  float total = 0.0;
  float persistence = 0.5;
  int octaves = 3;
  float freq = 1.0;
  float amp = 0.5;
  for(int i = 0; i < octaves; i++) {
     total += interpNoise2d(p * freq) * amp;
     amp *= persistence;
     freq *= 2.0;
  }
  return total; 
}

float heightMap(float t) {
  t = 3.0 * t - 2.5;
  return 0.126 * t * t * t + 0.36 * t * t + 0.375 * t + 0.7;
}

void main()
{
  fs_Pos = vs_Pos.xyz;
  float SinTime = sin((vs_Pos.x + u_PlanePos.x + u_Time * 0.5) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y + u_Time * 0.5) * 3.14159 * 0.1);
  fs_height = fbm(vs_Pos.xz + u_PlanePos) * 5.5 + 0.2;
  fs_height = heightMap(fs_height);
  vec3 rSphere;
  if(fs_height < 0.5) {
    fs_height = 0.5;
    float waveH = 0.1;
    rSphere = normalize(fs_Pos - vec3(0.0, -80.0, 0.0)) * (80.0 + fs_height * 7.0 + waveH * (SinTime - 1.0));
  } else {
    rSphere = normalize(fs_Pos - vec3(0.0, -80.0, 0.0)) * (80.0 + fs_height * u_MH);
  }
  // fs_height = perlin((vs_Pos.xz + u_PlanePos), vec2(51.241, 31.4437));
  // fs_height = fs_height / 2.0 + 0.5;
  vec4 modelposition = vec4(rSphere + vec3(0.0, -90.0, 0.0), 1.0);
  // vec4 modelposition = vec4(vs_Pos.xyz, 1.0);
  modelposition = u_Model * modelposition;
  gl_Position = u_ViewProj * modelposition;
}
