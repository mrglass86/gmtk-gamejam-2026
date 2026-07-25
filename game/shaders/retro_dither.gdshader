shader_type canvas_item;

// Style-audition filter (2026-07-25): G cycles style 0 (off, layer hidden),
// 1 construction-paper stop-motion, 2 storybook halftone print, 3 pencil
// hatch, 4 VHS night-video. Every style shares the low-fps boil so each look
// keeps the hand-made flicker. Director picks one before submission.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform int style : hint_range(0, 4) = 1;
uniform float boil_fps : hint_range(2.0, 24.0) = 8.0;
uniform float wobble_pixels : hint_range(0.0, 4.0) = 1.3;
uniform float grain_amount : hint_range(0.0, 0.4) = 0.11;
uniform float color_levels : hint_range(3.0, 16.0) = 7.0;
uniform float posterize_mix : hint_range(0.0, 1.0) = 0.65;
uniform float exposure_flicker : hint_range(0.0, 0.08) = 0.018;
uniform float halftone_dot_scale : hint_range(0.08, 0.5) = 0.19;
uniform float halftone_shadow_end : hint_range(0.2, 0.9) = 0.55;

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

vec2 rotate_2(vec2 p, float a) {
	float c = cos(a);
	float s = sin(a);
	return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void fragment() {
	float boil_frame = floor(TIME * boil_fps);
	vec2 boil_seed = vec2(
		hash_21(vec2(boil_frame, 1.7)),
		hash_21(vec2(boil_frame, 9.2))
	) * 64.0;

	vec2 wobble = vec2(
		value_noise(FRAGCOORD.xy * 0.015 + boil_seed),
		value_noise(FRAGCOORD.xy * 0.015 + boil_seed + 31.7)
	) - 0.5;
	vec2 sample_uv = SCREEN_UV;
	// The halftone print is deliberately steady (2026-07-25): no cutout
	// wobble; the other styles keep their stop-motion boil.
	if (style != 2) {
		sample_uv += wobble * wobble_pixels * SCREEN_PIXEL_SIZE * 2.0;
	}
	vec3 color = texture(screen_texture, sample_uv).rgb;
	float lum = dot(color, vec3(0.299, 0.587, 0.114));

	if (style == 2) {
		// Storybook halftone v2 (2026-07-25 tune): colour-preserving warm
		// paper, a highlight shoulder instead of blowout, soft posterise so
		// floor detail survives, and ink dots only in the shadow tones.
		vec3 toned = mix(color, vec3(lum), 0.35);
		toned = toned * vec3(1.06, 1.03, 0.98) + 0.02;
		toned /= 1.0 + max(lum - 0.72, 0.0) * 1.4;
		vec3 quant2 = floor(toned * 6.0 + 0.5) / 6.0;
		toned = mix(toned, quant2, 0.45);
		vec2 grid_uv = rotate_2(FRAGCOORD.xy, 0.26) * halftone_dot_scale;
		vec2 cell_offset = fract(grid_uv) - 0.5;
		float shade_amount = 1.0 - smoothstep(0.12, halftone_shadow_end, lum);
		float dot_radius = mix(0.06, 0.5, shade_amount);
		float ink = 1.0 - smoothstep(
			dot_radius - 0.09,
			dot_radius + 0.05,
			length(cell_offset)
		);
		color = mix(toned, toned * 0.42, ink * shade_amount * 0.85);
	} else if (style == 3) {
		// Pencil hatch: posterised tone, boiling diagonal strokes in dims.
		vec3 quant3 = floor(color * 5.0 + 0.5) / 5.0;
		vec3 toned = mix(color, quant3, 0.7);
		float stroke_a = sin(
			rotate_2(FRAGCOORD.xy, 0.7).x * 0.9 + boil_seed.x
		);
		float stroke_b = sin(
			rotate_2(FRAGCOORD.xy, -0.6).x * 0.9 + boil_seed.y
		);
		float hatch = 0.0;
		if (lum < 0.42) {
			hatch += smoothstep(0.2, 0.9, stroke_a) * 0.5;
		}
		if (lum < 0.2) {
			hatch += smoothstep(0.2, 0.9, stroke_b) * 0.5;
		}
		color = mix(toned, toned * 0.35, clamp(hatch, 0.0, 1.0));
		color += (value_noise(FRAGCOORD.xy * 0.9 + boil_seed * 3.1) - 0.5)
			* 0.06;
	} else if (style == 4) {
		// VHS night video: chroma split, scanlines, tape noise, vignette.
		float split = 1.6;
		color.r = texture(
			screen_texture,
			sample_uv + vec2(SCREEN_PIXEL_SIZE.x * split, 0.0)
		).r;
		color.b = texture(
			screen_texture,
			sample_uv - vec2(SCREEN_PIXEL_SIZE.x * split, 0.0)
		).b;
		float scan = 0.88 + 0.12 * sin(FRAGCOORD.y * 2.07);
		color *= scan;
		color += (value_noise(FRAGCOORD.xy * 1.7 + boil_seed * 11.0) - 0.5)
			* 0.09;
		vec2 centered = SCREEN_UV - 0.5;
		color *= 1.0 - dot(centered, centered) * 0.55;
		color = mix(vec3(lum), color, 0.8) * vec3(0.96, 1.02, 0.98);
	} else {
		// Style 1: construction-paper stop-motion.
		vec3 quantized = floor(color * color_levels + 0.5) / color_levels;
		color = mix(color, quantized, posterize_mix);
		float fibre = value_noise(FRAGCOORD.xy * 0.85 + boil_seed * 3.1) - 0.5;
		color *= 1.0 + fibre * grain_amount;
	}

	if (style != 2) {
		color *= 1.0 + (hash_21(vec2(boil_frame, 4.4)) - 0.5) * 2.0
			* exposure_flicker;
	}
	COLOR = vec4(color, 1.0);
}
