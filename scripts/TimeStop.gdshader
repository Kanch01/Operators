shader_type canvas_item;

uniform float amount  : hint_range(0.0, 1.0) = 1.0;      // overall desaturation strength
uniform float radius  : hint_range(0.0, 1.0) = 1.0;      // normalized radius (1.0 = full‑screen)
uniform float feather : hint_range(0.0, 0.5) = 0.2;      // how soft the edge is
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // sample the world
    vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);

    // compute grayscale value
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));

    // compute distance from center (0.5,0.5)
    float dist = distance(SCREEN_UV, vec2(0.5));

    // vignette mask: 1.0 inside radius-feather, 0.0 outside radius
    float mask = smoothstep(radius, radius - feather, dist);

    // mix original & gray by mask * amount
    vec3 final = mix(col.rgb, vec3(gray), mask * amount);

    COLOR = vec4(final, col.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
