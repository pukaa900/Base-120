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
	// Map screen coordinates to longitude/latitude and sample the
	// equirectangular source (`gcolor`). This supports full 360deg FOV
	// horizontally by wrapping longitude, and uses the inverse Mercator
	// for vertical conversion.
	vec2 uv = texcoord;
	if (U_USE_MERCATOR != 0) {
		// --- longitude (u) ---
		// map x from [0,1] -> [-0.5,0.5], scale by FOV, add offset
		float lon = (uv.x - 0.5) * radians(U_FOV_DEG) + radians(U_LON_OFFSET_DEG);
		// normalize longitude to [0,1]
		float u = lon / (2.0 * PI) + 0.5;
		// wrap horizontally
		u = u - floor(u);

		// --- latitude (v) via inverse Mercator ---
		// Treat screen Y as Mercator Y; allow vertical scaling/zoom
		float merc = (uv.y - 0.5) * U_VERT_SCALE + 0.5;
		merc = clamp(merc, 0.0, 1.0);
		float lat = 2.0 * atan(exp((0.5 - merc) * 2.0 * PI)) - (PI * 0.5);
		float v = clamp((lat / PI) + 0.5, 0.0, 1.0);

		uv = vec2(u, v);
	}

	vec3 color = texture2D(gcolor, uv).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}