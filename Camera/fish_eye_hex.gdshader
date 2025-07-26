shader_type canvas_item;

uniform float hex_pixel_scale : hint_range(4.0, 100.0) = 75.0;
uniform float hex_aspect_ratio = 1.5;
uniform float hex_outer_outline: hint_range(0.0, 0.05) = 0.002;
uniform float hex_inner_outline : hint_range(0.0, 0.05) = 0.001;

uniform float hex_inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float hex_inner_scale : hint_range(1.0, 8.0) = 2.0;


// Binocular Mask Settings
uniform float eye_separation : hint_range(0.0, 2.0) = 1.97; // distance between centers
uniform float eye_radius : hint_range(0.0, 2.0) = 1.0;     // max radius
uniform float eye_vertical_scale : hint_range(0.1, 3.0) = 1.2; // controls the vertical stretch (oval)

// Fisheye settings
uniform float fov_distortion : hint_range(0.0, 2.0) = 0.15;
uniform int fov_projection_mode : hint_enum("None,Stereographic,Equidistant,Equisolid") = 1;
uniform float fov_degrees : hint_range(60.0, 360.0) = 180.0;

vec2 fisheye_distort(vec2 uv) {
	vec2 centered = uv * 2.0 - 1.0;
	float r = length(centered);
	if (r == 0.0) return uv;

	float max_r = sqrt(2.0);
	float r_norm = r / max_r;
	float theta = r_norm * radians(fov_degrees);
	float r_fisheye = r;

	if (fov_projection_mode == 1) {
		r_fisheye = tan(theta / 2.0) * fov_distortion;
	} else if (fov_projection_mode == 2) {
		r_fisheye = theta * fov_distortion;
	} else if (fov_projection_mode == 3) {
		r_fisheye = 2.0 * sin(theta / 2.0) * fov_distortion;
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

	// Distance from center of screen
	float dist_from_center = length(uv - vec2(0.5));

	float dynamic_pixel_scale = (dist_from_center < hex_inner_radius)
		? hex_pixel_scale * hex_inner_scale
		: hex_pixel_scale;


	// Build hex grid using *screen UV*, so hexes are uniform in size
	vec2 hex_uv = uv;
	hex_uv.x *= hex_aspect_ratio;

	float hex_w = 1.0 / dynamic_pixel_scale;
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

	center.x /= hex_aspect_ratio;

	// Now apply fisheye to the center of this hex to fetch texture
	vec2 fisheye_uv = fisheye_distort(center);

	// Discard if outside the valid fisheye region, and also binocular mask view thing
	// Convert to centered coordinates
	vec2 centered_uv = fisheye_uv * 2.0 - 1.0;

	// Oval shape (scale Y)
	vec2 left_eye_center = vec2(-eye_separation * 0.5, 0.0);
	vec2 right_eye_center = vec2(eye_separation * 0.5, 0.0);

	vec2 left_offset = centered_uv - left_eye_center;
	vec2 right_offset = centered_uv - right_eye_center;

	left_offset.y *= eye_vertical_scale;
	right_offset.y *= eye_vertical_scale;

	float left_dist = length(left_offset);
	float right_dist = length(right_offset);

	// Discard if not inside either eye shape
	if (left_dist > eye_radius && right_dist > eye_radius) {
	    discard;
	}

	// Edge outline for hex mosaic view
	float dist = distance(uv, center);
	//float hex_radius = hex_w * 0.5 * 0.98;
	////float edge = smoothstep(hex_radius - outline_thickness, hex_radius, dist);
	//float edge = 0.0;
	//if (dist_from_center >= center_cutoff_radius) {
		//edge = smoothstep(hex_radius - outline_thickness, hex_radius, dist);
	//}
		
	float thickness = (dist_from_center < hex_inner_radius) 
		? hex_inner_outline 
		: hex_outer_outline;

	float hex_radius = hex_w * 0.5 * 0.98;
	float edge = smoothstep(hex_radius - thickness, hex_radius, dist);


	vec4 tex_color = texture(TEXTURE, fisheye_uv);
	COLOR = mix(tex_color, vec4(0.0, 0.0, 0.0, 1.0), edge);
}

