// KapowFX — anime-style star/spark flash.
// Classic "impact frame": hot core + 4 long spikes + 4 short diagonal spikes.
shader_type canvas_item;
render_mode blend_add;

uniform int points : hint_range(2, 16) = 4;
uniform float sharpness : hint_range(1.0, 64.0) = 26.0;
uniform float spin = 0.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float secondary : hint_range(0.0, 1.0) = 0.45;
uniform vec4 tint : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform vec4 core_tint : source_color = vec4(1.0, 1.0, 0.95, 1.0);

float star_mask(vec2 uv, float ang_offset, float len, float sharp) {
	float r = length(uv);
	float a = atan(uv.y, uv.x) + ang_offset;
	float spike = pow(abs(cos(a * float(points) * 0.5)), sharp);
	float silhouette = mix(0.10, len, spike);
	return smoothstep(silhouette, silhouette - 0.10, r);
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	// Primary long spikes + secondary short spikes rotated 45°.
	float m1 = star_mask(uv, spin, 1.0, sharpness);
	float m2 = star_mask(uv, spin + PI / float(points), secondary, sharpness * 1.6);
	float shape = max(m1, m2 * 0.85);
	float core = exp(-r * 9.0) * 2.4;
	float fade = 1.0 - progress;
	fade = fade * fade * fade; // hard ease-out: snappy decay
	vec3 col = tint.rgb * shape + core_tint.rgb * core;
	COLOR = vec4(col * fade, clamp(shape + core, 0.0, 1.0) * fade);
}
