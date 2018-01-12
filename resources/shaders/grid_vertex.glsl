#version 150

in vec3 position;
in vec3 normal;

out vec3 position_eye;
out vec3 normal_eye;

uniform mat4 projection_matrix;
uniform mat4 model_matrix;
uniform mat4 view_matrix;

void main()
{
  mat4 model_view_matrix =  view_matrix * model_matrix;

  position_eye = vec3 (model_view_matrix * vec4 (position,            1.0));
  normal_eye   = vec3 (model_view_matrix * vec4 (normalize( normal ), 0.0));

  gl_Position  = projection_matrix * model_view_matrix * vec4(position, 1.0);
}
