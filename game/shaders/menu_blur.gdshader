shader_type canvas_item;

// Soft blur-and-dim backdrop for the paper menu (2026-07-25): the live game
// stays visible behind the title and result cards, gently out of focus.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_radius : hint_range(0.0, 8.0) = 3.2;
uniform float darken : hint_range(0.0, 1.0) = 0.42;

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE * blur_radius;
	vec3 sum = texture(screen_texture, SCREEN_UV).rgb * 0.25;
	sum += texture(screen_texture, SCREEN_UV + vec2(px.x, 0.0)).rgb * 0.125;
	sum += texture(screen_texture, SCREEN_UV - vec2(px.x, 0.0)).rgb * 0.125;
	sum += texture(screen_texture, SCREEN_UV + vec2(0.0, px.y)).rgb * 0.125;
	sum += texture(screen_texture, SCREEN_UV - vec2(0.0, px.y)).rgb * 0.125;
	sum += texture(screen_texture, SCREEN_UV + px).rgb * 0.0625;
	sum += texture(screen_texture, SCREEN_UV - px).rgb * 0.0625;
	sum += texture(screen_texture, SCREEN_UV + vec2(px.x, -px.y)).rgb * 0.0625;
	sum += texture(screen_texture, SCREEN_UV + vec2(-px.x, px.y)).rgb * 0.0625;
	COLOR = vec4(sum * (1.0 - darken), 1.0);
}
