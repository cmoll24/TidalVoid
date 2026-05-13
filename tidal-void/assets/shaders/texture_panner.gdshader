shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.5;
uniform float edge_smoothness : hint_range(0.0, 1.0) = 0.01;
uniform vec2 rotation_speed;
uniform vec2 ripple_dir;
const float RippleRate = 0.05f;
const float RippleStrength = 0.1f;

void fragment() {
	if(texture(TEXTURE,UV).a < 0.5f){
		discard;
	}
	float TimeFunc = ((0.5f-mod((TIME*RippleRate),1))*2.0f);
	TimeFunc = TimeFunc*TimeFunc;
	float TimeScalar = -0.25f+TimeFunc;
	float RippleScalar = (1.0f-abs((UV.x*ripple_dir.x)+(UV.y*ripple_dir.y) - (TimeFunc*2.0f)))*RippleStrength;
	vec4 pixelColor = texture(TEXTURE, vec2(mod(UV.x + TIME*rotation_speed.x,1)+RippleScalar
	,mod(UV.y + TIME*rotation_speed.y,1)+RippleScalar));
	//We center the uv coordinates
	vec2 uv = UV - 0.5;
	
	float dist = length(uv);
	
	float mask = 1.0 - smoothstep(radius - edge_smoothness, radius + edge_smoothness, dist);
	
	COLOR = pixelColor;
	COLOR.a = mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
