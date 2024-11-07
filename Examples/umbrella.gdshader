shader_type canvas_item;
uniform float m :hint_range(-2.0,2.0,0.001)= 1.58;
void fragment() {
	// get uv by dividing fragcoord and res.
	vec2 uv = FRAGCOORD.xy/(1.0/SCREEN_PIXEL_SIZE.xy);
	// centre uv.
	uv = uv *2.0-1.0;
	// return color
	COLOR.rgb = 1.0-vec3(abs(sin(abs(fract(atan(uv.x/uv.y)*m))+TIME)));
}