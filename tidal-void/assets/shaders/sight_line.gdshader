shader_type canvas_item;
uniform vec2 player_screen_uv;


void fragment() {
	//Workaround for Godot Nonsense
	vec2 dir = normalize(SCREEN_UV - player_screen_uv);
	float dist = 0.0001;
	float goal_dist = distance(player_screen_uv,SCREEN_UV);
	for (int i = 0; i < 10; i++){
		float sdf = texture_sdf(screen_uv_to_sdf(player_screen_uv + (dir*dist)));
		float sdfuv = sdf * min(SCREEN_PIXEL_SIZE.x,SCREEN_PIXEL_SIZE.y);
		dist += max(sdfuv,0.01f);
		if(sdf < 1.0){
			discard;
		}
		if(dist >= goal_dist){
			break;
		}
	}
	COLOR = texture(TEXTURE, UV);
}
