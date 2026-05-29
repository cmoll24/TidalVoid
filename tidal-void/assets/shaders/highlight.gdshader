shader_type canvas_item;

const vec4 HighlightColor = vec4(0.5,0.5,0.5,1);
const float TimeScale = 0.5f;
const float StripeLength = 0.1f;

void fragment() {
	float Progress = mod(TIME*TimeScale, 1.0f);
	vec4 FinalColor = texture(TEXTURE, UV);
	if(FinalColor.a < 0.01f){
			discard;
	}
	if(Progress <= 0.6f){
		Progress *= 4.0f;
		float StripeStart = Progress - StripeLength;
		float UVSum = UV.x + UV.y;
		if((UVSum < Progress && UVSum > StripeStart)){
			//apply the highlight
			FinalColor.r += HighlightColor.r;
			FinalColor.g += HighlightColor.g;
			FinalColor.b += HighlightColor.b;
		}
	}
	COLOR = FinalColor;
}