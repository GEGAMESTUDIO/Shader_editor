shader_type canvas_item;
uniform float t:hint_range(-1.0,1.0,0.001) = 0.27;
uniform vec3 c:source_color = vec3(0.36,0.0,0.99);
float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u * u * (3.0 - 2.0 * u);
	float res = mix(mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x),mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x),u.y);
	return res;
}

void fragment() {
	vec2 res = 1.0/SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy/(res.xy);
	uv = uv*2.0-1.0;
	uv.x*= res.x/res.y;
	COLOR.rgb = c*vec3(noise(uv*300.0/sin(uv.x+uv.y+TIME)))*(1.0-length(uv)+t);
}