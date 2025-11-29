#version 120

uniform sampler2D gcolor;


// Mercator projection enabled by default (set to 0 to disable at compile time)
const int U_USE_MERCATOR = 1;

varying vec2 texcoord;

const float PI = 3.14159265358979323846;

void main() {
	// Map screen Y (display space) back to equirectangular texture V
	// using the inverse Mercator transform so the displayed viewport
	// is in Mercator projection. Also flip Y to correct upside-down output.
	// Inverse Mercator (given merc in [0,1]):
	// lat = 2*atan(exp((0.5 - merc) * 2*pi)) - pi/2
	// v = lat/pi + 0.5
	vec2 uv = texcoord;
	if (U_USE_MERCATOR != 0) {
		// Correct vertical flip first (texture origin may be top-left)
		float s = 1.0 - uv.y;
		float merc = clamp(s, 0.0, 1.0);
		float lat = 2.0 * atan(exp((0.5 - merc) * 2.0 * PI)) - (PI * 0.5);
		float v = clamp((lat / PI) + 0.5, 0.0, 1.0);
		uv.y = v;
	}

	vec3 color = texture2D(gcolor, uv).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}