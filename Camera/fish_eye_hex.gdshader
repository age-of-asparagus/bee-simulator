shader_type canvas_item;

uniform float pixel_scale : hint_range(4.0, 100.0) = 20.0;
uniform float aspect_ratio = 1.77778;
uniform float outline_thickness : hint_range(0.001, 0.05) = 0.002;

// Fisheye settings
uniform float distortion_strength : hint_range(0.0, 2.0) = 1.0;
uniform int projection_mode : hint_enum("None,Stereographic,Equidistant,Equisolid") = 1;
uniform float fov_degrees : hint_range(60.0, 180.0) = 120.0;

vec2 fisheye_distort(vec2 uv) {
	vec2 centered = uv * 2.0 - 1.0;
	float r = length(centered);
	if (r == 0.0) return uv;

	float max_r = sqrt(2.0);
	float r_norm = r / max_r;
	float theta = r_norm * radians(fov_degrees);
	float r_fisheye = r;

	if (projection_mode == 1) {
		r_fisheye = tan(theta / 2.0) * distortion_strength;
	} else if (projection_mode == 2) {
		r_fisheye = theta * distortion_strength;
	} else if (projection_mode == 3) {
		r_fisheye = 2.0 * sin(theta / 2.0) * distortion_strength;
	}

	centered *= r_fisheye / r;
	return (centered + 1.0) * 0.5;
}

vec2 hex_round(vec2 q) {
	float rx = round(q.x);
	float ry = round(q.y);
	float rz = round(-q.x - q.y);

	float x_diff = abs(rx - q.x);
	float y_diff = abs(ry - q.y);
	float z_diff = abs(rz + q.x + q.y);

	if (x_diff > y_diff && x_diff > z_diff) {
		rx = -ry - rz;
	} else if (y_diff > z_diff) {
		ry = -rx - rz;
	}
	return vec2(rx, ry);
}

void fragment() {
	vec2 uv = UV;

	// Build hex grid using *screen UV*, so hexes are uniform in size
	vec2 hex_uv = uv;
	hex_uv.x *= aspect_ratio;

	float hex_w = 1.0 / pixel_scale;
	float hex_h = hex_w * 0.8660254;

	vec2 q = vec2(
		hex_uv.x / hex_w,
		(hex_uv.y / hex_h) - (hex_uv.x / (hex_w * 2.0))
	);

	vec2 rounded = hex_round(q);

	vec2 center;
	center.x = hex_w * rounded.x;
	center.y = hex_h * (rounded.y + rounded.x * 0.5);

	if (mod(rounded.x, 2.0) == 0.0) {
		center.y += hex_h * 0.01;
	}

	center.x /= aspect_ratio;

	// Now apply fisheye to the center of this hex to fetch texture
	vec2 fisheye_uv = fisheye_distort(center);

		// Discard if outside the valid fisheye region
	vec2 offset = fisheye_uv * 2.0 - 1.0;
	if (length(offset) > 1.0) {
	    discard;
	}

	float dist = distance(uv, center);
	float hex_radius = hex_w * 0.5 * 0.98;
	float edge = smoothstep(hex_radius - outline_thickness, hex_radius, dist);

	vec4 tex_color = texture(TEXTURE, fisheye_uv);
	COLOR = mix(tex_color, vec4(0.0, 0.0, 0.0, 1.0), edge);
}
