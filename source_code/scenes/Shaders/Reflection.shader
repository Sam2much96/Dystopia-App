// Reflection shader
//its not working

shader_type canvas_item;

uniform sampler2D reflection_viewport;
uniform sampler2D normal_map;
uniform float amount : hint_range(0, 1);

void fragment()
{
	vec4 color = texture(TEXTURE, UV);
	
	// Define the distortion from the normal map
	vec2 offset = texture(normal_map, UV).xy * amount;
	
	//Offset the viewport texture with the distortion
	vec4 reflection = texture (reflection_viewport, SCREEN_UV + offset);
	
	// Alpha blend the reflection with the main texture
	color.rgb = color.rgb * (1.0 - reflection.a) + reflection.rgb * reflection.a;
	COLOR = color;
}