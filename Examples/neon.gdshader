shader_type canvas_item;
uniform float t = 0.314;
void fragment() {
	// get uv by dividing resolution and fragcoords.
	vec2 res = 1.0/SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy/res.xy;
	// centre the uv.
	uv=uv*2.0-1.0;
	// scale UV.x to a ratio of resolution x and y.
	uv.x*=res.x/res.y;
	// return the sqrt of length.
	COLOR.rgb = 1.0-sqrt(vec3(sin(TIME+length(uv*uv+8.0)))-vec3(t*2.0,t*t,t+0.1));
}