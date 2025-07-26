shader_type canvas_item;

uniform bool hex_view = true;

uniform float hex_pixel_scale : hint_range(4.0, 100.0) = 75.0;
uniform float hex_aspect_ratio = 1.5;
uniform float hex_outer_outline: hint_range(0.0, 0.05) = 0.002;
uniform float hex_inner_outline : hint_range(0.0, 0.05) = 0.001;

uniform float hex_inner_radius : hint_range(0.0, 1.0) = 0.0;
uniform float hex_inner_scale : hint_range(1.0, 8.0) = 2.0;

uniform bool spectrum_bee = false;


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

vec2 hexellate(vec2 uv, float dynamic_pixel_scale) {
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
	return center;
}


float get_hex_edge_outline(vec2 uv, vec2 center, float dist_from_center, float hex_w) {
	float thickness = (dist_from_center < hex_inner_radius)
		? hex_inner_outline
		: hex_outer_outline;

	float hex_radius = hex_w * 0.5 * 0.98;
	float dist = distance(uv, center);
	return smoothstep(hex_radius - thickness, hex_radius, dist);
}

bool is_within_binocular_mask(vec2 uv) {
	vec2 centered_uv = uv * 2.0 - 1.0;

	vec2 left_eye_center = vec2(-eye_separation * 0.5, 0.0);
	vec2 right_eye_center = vec2(eye_separation * 0.5, 0.0);

	vec2 left_offset = centered_uv - left_eye_center;
	vec2 right_offset = centered_uv - right_eye_center;

	left_offset.y *= eye_vertical_scale;
	right_offset.y *= eye_vertical_scale;

	float left_dist = length(left_offset);
	float right_dist = length(right_offset);

	return (left_dist <= eye_radius || right_dist <= eye_radius);
}

vec4 bee_vision_remove_red(vec4 uv) {
	uv.r = 0.0;
	return uv;
}

vec4 bee_vision_color_shift1(vec4 tex) {
	float r = tex.r;
	float g = tex.g;
	float b = tex.b;
	tex.r = b;
	tex.g = r;
	tex.b = g;
	return tex;
}

vec4 bee_vision_color_shift2(vec4 tex) {
	float r = tex.r;
	float g = tex.g;
	float b = tex.b;
	tex.r = 0.0;
	tex.g = r+g;
	tex.b = r+b;
	return tex;
}

vec4 bee_vision_apply_purple_mix(vec4 color, float strength) {
    vec3 purple = vec3(1.0, 0.0, 1.0); // Pure purple
    color.rgb = mix(color.rgb, purple, strength);
    return color;
}

vec4 bee_vision_apply_purple_add(vec4 color, float strength) {
    color.r += strength;
    color.b += strength;
    color.g *= (1.0 - strength); // reduce green
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    return color;
}

vec4 bee_vision_apply_purple_preserve_luminance(vec4 color, float strength) {
    float luminance = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 purple = normalize(vec3(1.0, 0.0, 1.0)); // normalized purple
    color.rgb = mix(color.rgb, purple * luminance, strength);
    return color;
}

vec4 vee_vision_desaturate_except_blue(vec4 color, float strength) {
    // Calculate grayscale luminance
    float gray = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));

    // How "blue" is this color? (more blue → less desaturation)
    float blue_ratio = color.b / (color.r + color.g + color.b + 0.001); // avoid div/0

    // You could also use `step` or `smoothstep` to fine-tune
    float preserve_factor = clamp(blue_ratio * 3.0, 0.0, 1.0); // exaggerate difference

    // Compute how much to desaturate: less if more blue
    float t = strength * (1.0 - preserve_factor);

    // Blend toward grayscale
    color.rgb = mix(vec3(gray), color.rgb, 1.0 - t);

    return color;
}


void fragment() {
	vec2 uv = UV;
	float dist_from_center = length(uv - vec2(0.5));
	float dynamic_pixel_scale = (dist_from_center < hex_inner_radius)
		? hex_pixel_scale * hex_inner_scale
		: hex_pixel_scale;

	// HEX
	vec2 hex_center_uv = hex_view
		? hexellate(uv, dynamic_pixel_scale)
		: uv;

	// FISHEYE
	vec2 fisheye_uv = fisheye_distort(hex_center_uv);

	// BINOCULAR MASK
	if (!is_within_binocular_mask(fisheye_uv)) {
		discard;
	}

	// FINAL COLOR
	vec4 color = texture(TEXTURE, fisheye_uv);

	// EDGE OUTLINE
	if(hex_view) {
		float hex_w = 1.0 / dynamic_pixel_scale;
		float edge = get_hex_edge_outline(uv, hex_center_uv, dist_from_center, hex_w);
		color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), edge);
	}
	
	if(spectrum_bee) {
		//color = bee_vision_apply_purple_preserve_luminance(color, 0.5);
		color = bee_vision_remove_red(color);
	}
	
	COLOR = color;
}