shader_type canvas_item;

const float RippleStrength = 0.3f;
const float RippleRate = 0.05f;
const float RippleRate2 = 0.07f;
uniform vec2 Dir = vec2(0.447f,0.894f);

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	if(alpha < 0.5){
		discard;
	}
	vec2 DeltaUV = vec2(0);
	float TimeFunc = ((0.5f-mod((TIME*RippleRate),1)));
	TimeFunc = TimeFunc*TimeFunc;
	float TimeFunc2 = ((0.5f-mod((TIME*RippleRate2),1))*2.0f);
	TimeFunc2 = TimeFunc2*TimeFunc2;
	float TimeScalar = -0.25f+TimeFunc;
	float shitfuck1 = Dir.x/Dir.y;
	float shitfuck2 = Dir.y/Dir.x;
	float RippleScalar = 1.0f-abs((UV.x*shitfuck1)+(UV.y*shitfuck2) - (TimeFunc2*2.0f));
	
	
	DeltaUV = Dir*TimeScalar*RippleStrength*RippleScalar;
	COLOR = texture(TEXTURE, mod(UV+DeltaUV,vec2(1)));
	COLOR.a = 1.0f;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
