shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float edge_smoothness : hint_range(0.0, 1.0) = 0.01;
uniform vec2 rotation_speed;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, vec2(mod(UV.x + TIME*rotation_speed.x,1)
	,mod(UV.y + TIME*rotation_speed.y,1)));
	
	//We center the uv coordinates
	vec2 uv = UV - 0.5;
	
	float dist = length(uv);
	
	float mask = 1.0 - smoothstep(radius - edge_smoothness, radius + edge_smoothness, dist);
	
	COLOR = pixelColor;
	COLOR.a = pixelColor.a * mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
