shader_type canvas_item;
uniform float e :hint_range(-1.0, 1.0, 0.001)= 0.314;
uniform float r :hint_range(0.0, 100.0, 1.0)=4.0;
void fragment() {
	vec2 res = 1.0/SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy/res;
	uv.x*=res.x/res.y;
	uv*=r;
	COLOR.rgb = 1.0-sqrt(sin(vec3(length(uv-1.0),length(uv),e)+TIME));
}
