#version 150

in vec3 position;
in vec2 uv;

out vec2 uv_point;

uniform mat4 projection_matrix;
uniform mat4 model_matrix;
uniform mat4 view_matrix;

void main()
{
  mat4 model_view_matrix =  view_matrix * model_matrix;

  uv_point = uv;

  gl_Position  = projection_matrix * model_view_matrix * vec4(position, 1.0);
}
