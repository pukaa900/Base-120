#version 120

uniform sampler2D gcolor;


// Runtime controllable: enable equirectangular projection (1 = on)
uniform int u_use_equirectangular; // set to 1 to enable

// Horizontal field of view in degrees. 360.0 produces a full wrap-around view.
uniform float u_fov_deg;
// Horizontal longitude offset in degrees (rotate view)
uniform float u_lon_offset_deg;
// (unused for equirectangular but left for compatibility)
uniform float u_vert_scale;

varying vec2 texcoord;

const float PI = 3.14159265358979323846;

void main() {
	// Convert screen UV to a view direction vector then to
	// equirectangular coordinates (longitude, latitude) matching:
	// vec2 ViewToEquirectangular(vec3 view) {
	//   return vec2(atan(view.z, view.x) * INV_TAU + 0.5,
	//               1.0 - acos(view.y) * INV_PI);
	// }
	vec2 uv = texcoord;
	if (u_use_equirectangular != 0) {
		// Build view vector from screen UV assuming the screen maps to
		// spherical directions. Horizontal longitude range is controlled
		// by U_FOV_DEG; for a full 360-degree horizontal view set to 360.
		// convert FOV/offset from degrees (uniforms) to radians
		float lon = (uv.x - 0.5) * (radians(u_fov_deg));
		lon += radians(u_lon_offset_deg);

		// Polar angle from +Y axis: polar = (1 - v) * PI
		float polar = (1.0 - uv.y) * PI;

		float vy = cos(polar);
		float r = sin(polar);
		float vx = cos(lon) * r;
		float vz = sin(lon) * r;

		// Now compute equirectangular UV from view vector (matches provided function)
		float INV_TAU = 1.0 / (2.0 * PI);
		float INV_PI = 1.0 / PI;
		float u = atan(vz, vx) * INV_TAU + 0.5;
		float v = 1.0 - acos(vy) * INV_PI;

		uv = vec2(u - floor(u), clamp(v, 0.0, 1.0));
	}

	vec3 color = texture2D(gcolor, uv).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}