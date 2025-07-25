shader_type canvas_item;

uniform sampler2D depth_texture;  // need depth for the pixellation

uniform float distortion_strength : hint_range(0.0, 2.0) = 1.0;
uniform int projection_mode : hint_enum("None,Stereographic,Equidistant,Equisolid") = 1;
uniform float fov_degrees : hint_range(60.0, 180.0) = 120.0;

uniform float near = 0.1;
uniform float far = 100.0;

// Pixelation controls
uniform float pixel_size_near : hint_range(1.0, 20.0) = 1.0;
uniform float pixel_size_far : hint_range(1.0, 20.0) = 8.0;
uniform float pixel_depth_start : hint_range(0.0, 100.0) = 5.0;
uniform float pixel_depth_end : hint_range(0.0, 100.0) = 30.0;


float linearize_depth(float z) {
    return (2.0 * near * far) / (far + near - z * (far - near));
}

void fragment() {

	// FISHEYE /////////////////

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

		distorted_uv = uv * (r_fisheye / r);
	}
	distorted_uv = (distorted_uv + 1.0) * 0.5;

	// PIXELATE ////////////////

	// Get scene depth at this UV
	float z = texture(depth_texture, distorted_uv).r;
	float distance = linearize_depth(z);

	// Map distance to pixel scale (e.g. near = 1, far = 8)
	//float pixel_scale = mix(1.0, 8.0, clamp((distance - 2.0) / 30.0, 0.0, 1.0));

	// Calculate pixelation level based on distance
	float pixel_interp = smoothstep(pixel_depth_start, pixel_depth_end, distance);
	float pixel_scale = mix(pixel_size_near, pixel_size_far, pixel_interp);

	// Snap UV to coarse pixel grid
	vec2 pixelated_uv = floor(distorted_uv * pixel_scale) / pixel_scale;

	vec2 final_uv = pixelated_uv;

	if (any(lessThan(final_uv, vec2(0.0))) || any(greaterThan(final_uv, vec2(1.0)))) {
		discard;
	}

	COLOR = texture(TEXTURE, final_uv);
}
