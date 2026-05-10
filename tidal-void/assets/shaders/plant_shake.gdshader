shader_type canvas_item;

//All uniform variables for active shake, not passive shaking
uniform float shake_amount : hint_range(0.0, 0.5) = 0.1;
uniform float elapsed_time = 0;
uniform bool shake_left = true;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 DeltaUV = vec2(0);
	const float ShakeSpeed = 1.5f;
	float TimeDelta = elapsed_time *ShakeSpeed;
	if(TimeDelta <= 1.0f){
		DeltaUV.x = (shake_left ?  0.5f-abs(0.5f-TimeDelta): -0.5f+abs(0.5f-TimeDelta))*shake_amount;
	}	
	else{
		DeltaUV.x = (-0.25f+abs(0.5f-mod(TIME*0.55f,1)))*0.03;
	}
	DeltaUV.x *= (1.0f-UV.y);
	vec4 pixelColor = texture(TEXTURE, UV+DeltaUV);
	COLOR = pixelColor;
}
