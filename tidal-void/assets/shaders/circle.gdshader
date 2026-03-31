shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float edge_smoothness : hint_range(0.0, 1.0) = 0.01;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	
	//We center the uv coordinates
	vec2 uv = UV - 0.5;
	
	float dist = length(uv);
	
	float mask = 1.0 - smoothstep(radius - edge_smoothness, radius + edge_smoothness, dist);
	
	COLOR = pixelColor;
	COLOR.a = pixelColor.a * mask;
}
