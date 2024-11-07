shader_type canvas_item;
uniform float f :hint_range(0.0,1.0,0.002)= 0.125;
uniform vec3 c1:source_color = vec3(0.5);
uniform vec3 c2:source_color = vec3(0.1,0.3,0.4);
void fragment() {
	// get uv by dividing resolution and fragcoords.
	vec2 res = 1.0/SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy/res.xy;
	// fix uv ratio.
	uv.x *= res.x/res.y;
	// get step of mod of uvs.
	float x = step(f,mod(uv.x,f*2.0));
	float y = step(f,mod(uv.y,f*2.0));
	// get length of x-y.
	vec3 c = vec3(mix(c1,c2,length(x-y)));
	// return color.
	COLOR.rgb = c;
}