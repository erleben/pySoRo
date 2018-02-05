#version 150

in vec2 uv_point;

out vec4 frag_color;

uniform sampler2D colormap;

void main()
{
  frag_color = vec4( texture(colormap, uv_point).rgb, 1.0 );
}

