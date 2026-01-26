shader_type canvas_item;

uniform float radius  : hint_range(0.0, 1.0) = 0.0;   // 0 = center only, 1 = off‑screen
uniform float feather : hint_range(0.0, 0.5) = 0.1;   // softness of the edge
uniform float opacity : hint_range(0.0, 1.0) = 1.0;   // overall fade strength


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // distance from center of screen
    float d = distance(SCREEN_UV, vec2(0.5));
    // mask = 1.0 inside circle radius-feather → radius, 0.0 outside
    float mask = smoothstep(radius, radius - feather, d);
    // draw black with that alpha
    COLOR = vec4(0.0, 0.09, 0.0, mask * opacity);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
