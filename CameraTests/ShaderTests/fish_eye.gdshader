shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 2.0) = 1.0;
uniform int projection_mode : hint_enum("None,Stereographic,Equidistant,Equisolid") = 1;
uniform float fov_degrees : hint_range(60.0, 180.0) = 120.0;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0; // [-1,1] centered coords
	float r = length(uv);
	float max_r = sqrt(2.0); // max radius in screen space
	float r_norm = r / max_r; // normalize radius from 0 (center) to 1 (corner)

	vec2 distorted_uv = uv;
	float r_fisheye = r;
	
	if (projection_mode != 0) {
		float theta = r_norm * radians(fov_degrees);

		if (projection_mode == 1) {
			// Stereographic
			r_fisheye = tan(theta / 2.0) * distortion_strength;
		}
		else if (projection_mode == 2) {
			// Equidistant: r_fisheye = f * θ
			r_fisheye = theta * distortion_strength;
		}
		else if (projection_mode == 3) {
			// Equisolid: r_fisheye = 2f * sin(θ / 2)
			r_fisheye = 2.0 * sin(theta / 2.0) * distortion_strength;
		}

		// Smooth blend to keep center looking normal
		//float blend = smoothstep(0.2, 0.8, r_norm);
		//r_fisheye = mix(r, r_fisheye * max_r, blend); // rescale back to screen space
		distorted_uv = uv * (r_fisheye / r);
	}

	distorted_uv = (distorted_uv + 1.0) * 0.5;

	if (any(lessThan(distorted_uv, vec2(0.0))) || any(greaterThan(distorted_uv, vec2(1.0)))) {
		discard;
	}

	COLOR = texture(TEXTURE, distorted_uv);
}
