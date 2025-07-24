shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 2.0) = 1.0;
uniform int projection_mode : hint_enum("None,Stereographic,Equidistant,Equisolid") = 1;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	vec2 distorted_uv = uv;

	if (projection_mode == 1) {
		// Stereographic
		float theta = atan(r);
		float r_fisheye = theta / (PI * 0.5 * distortion_strength);
		distorted_uv = uv * r_fisheye;
	}
	else if (projection_mode == 2) {
		// Equidistant: r_fisheye = f * θ
		float theta = atan(r);
		float r_fisheye = theta * distortion_strength;
		distorted_uv = uv * r_fisheye;
	}
	else if (projection_mode == 3) {
		// Equisolid: r_fisheye = 2f * sin(θ / 2)
		float theta = atan(r);
		float r_fisheye = 2.0 * sin(theta / 2.0) * distortion_strength;
		distorted_uv = uv * r_fisheye;
	}
	// projection_mode == 0 is passthrough (no distortion)

	distorted_uv = (distorted_uv + 1.0) * 0.5;

	// Optional clamp to avoid sampling outside bounds
	if (any(lessThan(distorted_uv, vec2(0.0))) || any(greaterThan(distorted_uv, vec2(1.0)))) {
		discard;
	}

	COLOR = texture(TEXTURE, distorted_uv);
}
