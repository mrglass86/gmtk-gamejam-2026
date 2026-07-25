shader_type canvas_item;

// Retro mockup filter (2026-07-25): ordered Bayer dither plus palette
// quantise over the finished frame, with optional chunky pixel snapping.
// Toggled at runtime with G; ships default-off until the director rules on
// the look. Colour-preserving (per-channel quantise) so the night palette
// and the dark-is-safe read survive.

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float color_levels : hint_range(2.0, 12.0) = 5.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.55;
uniform float pixel_size : hint_range(1.0, 8.0) = 3.0;

const mat4 BAYER = mat4(
	vec4(0.0, 8.0, 2.0, 10.0),
	vec4(12.0, 4.0, 14.0, 6.0),
	vec4(3.0, 11.0, 1.0, 9.0),
	vec4(15.0, 7.0, 13.0, 5.0)
) / 16.0;

void fragment() {
	vec2 block = floor(FRAGCOORD.xy / pixel_size);
	vec2 snapped_uv = (block * pixel_size + pixel_size * 0.5) * SCREEN_PIXEL_SIZE;
	vec3 color = texture(screen_texture, snapped_uv).rgb;
	int bayer_x = int(mod(block.x, 4.0));
	int bayer_y = int(mod(block.y, 4.0));
	float threshold = BAYER[bayer_y][bayer_x] - 0.5;
	color += threshold * dither_strength / color_levels;
	color = floor(color * color_levels + 0.5) / color_levels;
	COLOR = vec4(color, 1.0);
}
