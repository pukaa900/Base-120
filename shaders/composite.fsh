#version 120

uniform sampler2D gcolor;


// Runtime controllable: enable equirectangular projection (1 = on)
uniform int u_use_equirectangular; // set to 1 to enable
// Runtime controllable: enable cubemap sampling (1 = on)
uniform int u_use_cubemap;
// Cubemap sampler (optional - shader will fallback to `gcolor` if not used)
uniform samplerCube u_cubemap;

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

	vec3 color = vec3(0.0);

	// Use cubemap if requested. If neither cubemap nor equirectangular
	// uniforms are provided (common for simple shader hosts), default to
	// equirectangular mapping so the projection actually changes.
	bool want_cubemap = (u_use_cubemap != 0);
	bool want_equirect = (u_use_equirectangular != 0) || (!want_cubemap && u_use_equirectangular == 0);

	if (want_cubemap) {
		// Cubemap sampling: build a view direction from screen UV and sample the cube map.
		float lon = (uv.x - 0.5) * (radians(u_fov_deg));
		lon += radians(u_lon_offset_deg);
		float polar = (1.0 - uv.y) * PI;
		float vy = cos(polar);
		float r = sin(polar);
		float vx = cos(lon) * r;
		float vz = sin(lon) * r;
		vec3 dir = vec3(vx, vy, vz);
		color = textureCube(u_cubemap, dir).rgb;

	} else if (want_equirect) {
		// Equirectangular mapping: from view vector to (u,v)
		float lon = (uv.x - 0.5) * (radians(u_fov_deg));
		lon += radians(u_lon_offset_deg);
		float polar = (1.0 - uv.y) * PI;
		float vy = cos(polar);
		float r2 = sin(polar);
		float vx = cos(lon) * r2;
		float vz = sin(lon) * r2;
		float INV_TAU = 1.0 / (2.0 * PI);
		float INV_PI = 1.0 / PI;
		float u = atan(vz, vx) * INV_TAU + 0.5;
		float v = 1.0 - acos(vy) * INV_PI;
		uv = vec2(u - floor(u), clamp(v, 0.0, 1.0));
		color = texture2D(gcolor, uv).rgb;

	} else {
		// Fallback: original sampling
		color = texture2D(gcolor, texcoord).rgb;
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}