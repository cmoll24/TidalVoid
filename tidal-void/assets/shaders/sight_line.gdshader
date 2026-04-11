shader_type canvas_item;
uniform vec2 player_screen_uv;


void fragment() {
	//Workaround for Godot Nonsense	
	for (float i = 0.0f; i < 80.0; i++){
		float sdf = texture_sdf(
			screen_uv_to_sdf(SCREEN_UV+(i/80.0)*(player_screen_uv-SCREEN_UV)));
		if(sdf <= 0.01){
			discard;
		}
	}
	COLOR = texture(TEXTURE, UV);
}
