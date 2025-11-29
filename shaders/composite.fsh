#version 120

uniform sampler2D gcolor;


// Mercator projection enabled by default (set to 0 to disable at compile time)
const int U_USE_MERCATOR = 1;

varying vec2 texcoord;

const float PI = 3.14159265358979323846;

void main() {
	// Optional: remap vertical coordinate to Web-Mercator projection
	// This maps input texture V (0..1) -> latitude (-pi/2..pi/2) and then
	// to Mercator Y: y = 0.5 - ln(tan(pi/4 + lat/2)) / (2*pi).
	// Values are clamped to [0,1] to avoid infinities at poles.
	vec2 uv = texcoord;
	if (U_USE_MERCATOR != 0) {
		float lat = (uv.y - 0.5) * PI; // latitude in radians
		float merc = 0.5 - (log(tan(PI * 0.25 + 0.5 * lat)) / (2.0 * PI));
		uv.y = clamp(merc, 0.0, 1.0);
	}

	vec3 color = texture2D(gcolor, uv).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}