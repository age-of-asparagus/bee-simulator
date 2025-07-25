shader_type canvas_item;

uniform float pixel_scale : hint_range(4.0, 100.0) = 20.0;
uniform float aspect_ratio = 1.77778;
uniform float outline_thickness : hint_range(0.001, 0.005) = 0.002;

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
    // Adjust UV for aspect ratio
    vec2 uv = UV;
    uv.x *= aspect_ratio;

    // Hex geometry
    float hex_w = 1.0 / pixel_scale;
    float hex_h = hex_w * 0.8660254; // sqrt(3)/2 — vertical spacing

    // Axial coordinates
    vec2 q = vec2(
        uv.x / hex_w,
        (uv.y / hex_h) - (uv.x / (hex_w * 2.0))
    );

    vec2 rounded = hex_round(q);

    // Center of the hex in UV space
    vec2 center;
    center.x = hex_w * rounded.x;
    center.y = hex_h * (rounded.y + rounded.x * 0.5);

    // 👇 Nudge even columns vertically to avoid double sampling
    if (mod(rounded.x, 2.0) == 0.0) {
        center.y += hex_h * 0.01;
    }

    // Back to aspect-correct UV
    center.x /= aspect_ratio;

    float dist = distance(UV, center);
    float hex_radius = hex_w * 0.5 * 0.98;

    float edge = smoothstep(hex_radius - outline_thickness, hex_radius, dist);
    vec4 tex_color = texture(TEXTURE, center);
	
	
    COLOR = mix(tex_color, vec4(0.0, 0.0, 0.0, 1.0), edge);
}
