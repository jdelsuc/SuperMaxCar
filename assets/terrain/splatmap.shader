shader_type spatial;

uniform sampler2D text_R;
uniform sampler2D text_G;
uniform sampler2D text_B;
uniform sampler2D splatmap;
//uniform sampler2D heightmap;
uniform float texture_scale_factor;
//uniform float height_factor;

void fragment() {	
	vec3 result;
	vec3 pixr = texture(text_R,UV*texture_scale_factor).rgb;
	vec3 pixg = texture(text_G,UV*texture_scale_factor).rgb;
	vec3 pixb = texture(text_B,UV*texture_scale_factor).rgb;
	vec4 pixs = texture(splatmap,UV);
	
	ALBEDO = pixr*pixs.r + pixg*pixs.g + pixb*pixs.b;

}

//void vertex() {
//    vec2 xz = VERTEX.xz;
//    float h = texture(heightmap, UV).g * height_factor;
//    VERTEX = vec3(xz.x, h, xz.y);
//}
//





