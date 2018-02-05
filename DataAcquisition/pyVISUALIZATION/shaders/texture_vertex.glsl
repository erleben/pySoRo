#version 400

in vec3 position;
in vec2 uv;
out vec2 tex;

void main()
{
  tex = uv;
  gl_Position  = vec4(position, 1.0);
}
