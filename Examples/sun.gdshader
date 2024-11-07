shader_type canvas_item;

// Define a edge , falloff and color.
uniform float edge:hint_range(0.0,1.0,0.001) = 0.24;
uniform float falloff:hint_range(0.0,1.0,0.001) = 0.64;
uniform vec3 color:source_color = vec3(1.0,0.4,0.0);
uniform float xOffset:hint_range(-1.0,1.0,0.001) = 0.0;
uniform float yOffset:hint_range(-1.0,1.0,0.01) = 0.0;

void fragment() {
// Define uv by dividing resolution and fragcoords.
	vec2 res = 1.0/SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy/(res.xy);
// Centre tthe uv.
	uv = uv*2.0-1.0;
// Scale the uv.x component.
	uv.x *= res.x/res.y;
	uv+=vec2(xOffset,yOffset);
// get the inverse smoothstep sin of length of uv.
	vec3 r = vec3(1.0-smoothstep(edge,edge+falloff,length(uv)));
// Multiply the color.
	COLOR.rgb = r*color*2.0;
}