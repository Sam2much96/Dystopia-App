// BoTW Toon Shader by NekotoArts
// wrote this at 2AM
//
//
//
// England is my city
// Smoke trees
// Two to the One from the One to the Three

// Adapted for open gl 2.0 on June 19,2025

shader_type spatial;




// enables toon lighting for both diffuse and specular
render_mode diffuse_toon, specular_toon;

// colour multiplier added to base texture
uniform vec4 tint : hint_color;

// the base texture
uniform sampler2D albedo_texture : hint_albedo;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D normal_map : hint_albedo;
uniform float shadow_size = 0.75;
uniform float shadow_blend = 0.001;
uniform float shadow_extra_intensity = 0.3;
uniform vec4 shadow_color : hint_color;
uniform vec4 light_tint : hint_color;
uniform float rimlight_size = 0.921;
uniform float rimlight_blend = 0.01;
uniform vec4 rimlight_color : hint_color;
uniform bool use_normalmap = true;
uniform bool animated = false;
uniform float time_scale = 0.02;
uniform vec3 normal_bias = vec3(0.0);
uniform vec3 light_bias = vec3(0.0);
uniform bool use_view = true;
uniform vec4 view_bias : hint_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform float view_multiplier : hint_range(-1.0, 1.0) = -1.0;

//Produces edge highlights based on view angle (used for the rim light).
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

//Stores normal and tangent for use in the fragment/light functions.
varying vec3 vertex_normal;
varying vec3 vertex_tangent;

void vertex(){
	vertex_normal = NORMAL;
	vertex_tangent = TANGENT;
}

// Sets base color and metallic property.
void fragment(){
	ALBEDO = texture(albedo_texture, UV).rgb * tint.rgb;
	METALLIC = metallic;
}

// Light Function: Core Stylized Lighting Logic
void light(){
	vec3 normal;
	if (use_normalmap){
		vec3 normal_from_texture;
		if (animated){
			normal_from_texture = texture(normal_map, UV + TIME * time_scale).rgb;
		}else{
			normal_from_texture = texture(normal_map, UV).rgb;
		}
		normal = vec3(normal_from_texture.x * NORMAL.x,
		normal_from_texture.y * NORMAL.y, normal_from_texture.z);
		
		normal = NORMAL - normal_from_texture;
	}else{
		normal = NORMAL;
	}
	
	if (use_view){
		normal -= VIEW * view_bias.rgb * view_multiplier;
	}
	
	float NdotL = dot(normal + normal_bias, LIGHT + light_bias);
	
	float rounded = smoothstep(shadow_size, shadow_blend + shadow_size, NdotL);
	float one_minus = 1.0 - rounded;
	vec3 mult1 = LIGHT_COLOR * rounded * light_tint.rgb * ATTENUATION;
	vec3 mult2 = (one_minus * 1.4 * shadow_color.rgb) - shadow_extra_intensity;
	vec3 add1 = mult1 + mult2;
	
	float add3  = rimlight_blend + rimlight_size;

	float basic_fresnel = fresnel(1.0, NORMAL, VIEW); // unoptimised fresnel code
	//float basic_fresnel = 1.0 - dot(normalize(NORMAL), normalize(VIEW)); // optimised fresnel code
	
	float smoothed = smoothstep(rimlight_size, add3, basic_fresnel);
	
	vec3 add2 = add1 + smoothed * rimlight_color.rgb;
	DIFFUSE_LIGHT += ALBEDO * add2;
}
