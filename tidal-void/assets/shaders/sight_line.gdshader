shader_type canvas_item;


void fragment() {
	//Workaround for Godot Nonsense
	vec4 pixel_color =  texture(TEXTURE, UV);
	if(pixel_color.a < 0.5){
		//Save performance by skipping transparent pixels
		discard;
	}
	vec2 player_screen_uv = vec2(0.5,0.5);
	//Get the direction and distance
	vec2 dir = normalize(SCREEN_UV - player_screen_uv);
	float dist = 0.0001;
	float goal_dist = distance(player_screen_uv,SCREEN_UV);
	for (int i = 0; i < 15; i++){
		//March forward based the distance (in sdf) to the nearest occluder
		float sdf = texture_sdf(screen_uv_to_sdf(player_screen_uv + (dir*dist)));
		if(sdf < 1.0){
			discard;
		}
		float sdf_uv = sdf * min(SCREEN_PIXEL_SIZE.x,SCREEN_PIXEL_SIZE.y);
		dist += max(sdf_uv,0.01f);
		if(dist >= goal_dist){
			break;
		}
	}
	COLOR = pixel_color;
}
