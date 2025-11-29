#version 120

uniform sampler2D gcolor;


// Mercator projection enabled by default (set to 0 to disable at compile time)
const int U_USE_MERCATOR = 1;

// Horizontal field of view in degrees. 360.0 produces a full wrap-around view.
const float U_FOV_DEG = 360.0;
// Horizontal longitude offset in degrees (rotate view)
const float U_LON_OFFSET_DEG = 0.0;
// Vertical scale/zoom for the Mercator mapping (1.0 = natural)
const float U_VERT_SCALE = 1.0;

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
	if (U_USE_MERCATOR != 0) {
		// Build view vector from screen UV assuming the screen maps to
		// spherical directions. Horizontal longitude range is controlled
		// by U_FOV_DEG; for a full 360-degree horizontal view set to 360.
		float lon = (uv.x - 0.5) * (radians(U_FOV_DEG));
		lon += radians(U_LON_OFFSET_DEG);

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