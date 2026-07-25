shader_type canvas_item;

// Construction-paper stop-motion filter (2026-07-25 direction, replacing the
// first Bayer-dither mockup): soft posterised colour, paper-fibre grain, and
// a low-fps "boil" — the grain, a tiny cutout wobble, and a slight exposure
// flicker all re-randomise at boil_fps, like paper cutouts re-photographed
// frame by frame. Toggled at runtime with G; default off until the director
// rules on the look.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float boil_fps : hint_range(2.0, 24.0) = 8.0;
uniform float wobble_pixels : hint_range(0.0, 4.0) = 1.3;
uniform float grain_amount : hint_range(0.0, 0.4) = 0.11;
uniform float color_levels : hint_range(3.0, 16.0) = 7.0;
uniform float posterize_mix : hint_range(0.0, 1.0) = 0.65;
uniform float exposure_flicker : hint_range(0.0, 0.08) = 0.018;

float hash_21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 offset = fract(p);
	offset = offset * offset * (3.0 - 2.0 * offset);
	float bottom = mix(
		hash_21(cell),
		hash_21(cell + vec2(1.0, 0.0)),
		offset.x
	);
	float top = mix(
		hash_21(cell + vec2(0.0, 1.0)),
		hash_21(cell + vec2(1.0, 1.0)),
		offset.x
	);
	return mix(bottom, top, offset.y);
}

void fragment() {
	float boil_frame = floor(TIME * boil_fps);
	vec2 boil_seed = vec2(
		hash_21(vec2(boil_frame, 1.7)),
		hash_21(vec2(boil_frame, 9.2))
	) * 64.0;

	// Cutout wobble: a coarse noise field nudges where each pixel samples,
	// re-rolled every boil frame — the whole scene shimmies like paper.
	vec2 wobble = vec2(
		value_noise(FRAGCOORD.xy * 0.015 + boil_seed),
		value_noise(FRAGCOORD.xy * 0.015 + boil_seed + 31.7)
	) - 0.5;
	vec2 sample_uv = SCREEN_UV + wobble * wobble_pixels * SCREEN_PIXEL_SIZE * 2.0;
	vec3 color = texture(screen_texture, sample_uv).rgb;

	// Soft posterise: flat construction-paper tones, not hard dither bands.
	vec3 quantized = floor(color * color_levels + 0.5) / color_levels;
	color = mix(color, quantized, posterize_mix);

	// Paper fibre: fine multiplicative grain, re-rolled per boil frame.
	float fibre = value_noise(FRAGCOORD.xy * 0.85 + boil_seed * 3.1) - 0.5;
	color *= 1.0 + fibre * grain_amount;

	// Per-frame exposure wobble, like a hand-cranked camera.
	color *= 1.0 + (hash_21(vec2(boil_frame, 4.4)) - 0.5) * 2.0 * exposure_flicker;

	COLOR = vec4(color, 1.0);
}
