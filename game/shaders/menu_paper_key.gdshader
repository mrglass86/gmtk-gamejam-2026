shader_type canvas_item;

// White-key for the director's photographed construction paper (2026-07-25):
// pixels that are bright AND unsaturated (the white table) go transparent,
// leaving the coloured paper, crayon scribbles, and props with their real
// torn edges. No hand masking needed.

uniform float key_threshold : hint_range(0.5, 1.0) = 0.78;
uniform float key_softness : hint_range(0.01, 0.3) = 0.12;
uniform float saturation_guard : hint_range(0.02, 0.4) = 0.14;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float darkest_channel = min(min(tex.r, tex.g), tex.b);
	float brightest_channel = max(max(tex.r, tex.g), tex.b);
	float saturation = brightest_channel - darkest_channel;
	float whiteness = smoothstep(
		key_threshold,
		key_threshold + key_softness,
		darkest_channel
	);
	float colour_hold = smoothstep(
		saturation_guard,
		saturation_guard + 0.1,
		saturation
	);
	float key = whiteness * (1.0 - colour_hold);
	COLOR = vec4(tex.rgb, tex.a * (1.0 - key));
}
