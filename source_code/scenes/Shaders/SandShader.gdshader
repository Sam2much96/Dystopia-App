/*
	アニメ風流砂シェーダー by あるる（きのもと 結衣） @arlez80
	Anime-esque Quicksand Shader by Yui Kinomoto @arlez80

	MIT License
*/
shader_type spatial;

uniform vec4 sand_color : source_color = vec4( 0.8, 0.6, 0.232, 1.0 );

uniform vec2 speed = vec2( 0.1, 0.0 );
uniform float wave_scale = 0.8;
uniform float wave_power = 80.0;
uniform float wave_interval = 90.0;

uniform float normal_depth = 1.0;

void fragment( )
{
	vec2 uv = UV + speed * TIME;
	NORMAL_MAP = normalize( vec3( cos( sin( uv.y * wave_power ) * wave_scale + uv.x * wave_interval ) * 0.25 + 0.5, 1.0, 0.5 ) );
	NORMAL_MAP_DEPTH = normal_depth;
	ALBEDO = sand_color.rgb;
}
