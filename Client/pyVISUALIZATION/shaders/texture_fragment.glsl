#version 400

in vec2 tex;
out vec4 color;
uniform sampler2D image;

void main()
{
  color = vec4( texture(image, tex).rgb, 1.0 );
}

