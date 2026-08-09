// KapowFX — expanding shockwave ring (SDF, resolution-independent).
shader_type canvas_item;
render_mode blend_add;

uniform float radius : hint_range(0.0, 1.0) = 0.0;
uniform float thickness : hint_range(0.0, 0.6) = 0.10;
uniform float softness : hint_range(0.001, 0.4) = 0.06;
uniform float squash : hint_range(0.2, 1.0) = 1.0; // <1 = perspective ellipse
uniform float fade : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tint : source_color = vec4(1.0, 0.85, 0.4, 1.0);

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv.y /= squash;
	float r = length(uv);
	float d = abs(r - radius);
	float ring = 1.0 - smoothstep(thickness * 0.5, thickness * 0.5 + softness, d);
	// White-hot leading edge, subtle.
	float lead = (1.0 - smoothstep(0.0, thickness * 0.4, abs(r - radius))) * 0.35;
	vec3 col = tint.rgb * ring + vec3(1.0) * lead * ring;
	COLOR = vec4(col * fade, ring * fade * tint.a);
}
