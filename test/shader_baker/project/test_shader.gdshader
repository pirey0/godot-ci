shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	ALBEDO = albedo_color.rgb;
	METALLIC = 0.5;
	ROUGHNESS = 0.3;
}
