//Shadow fading rate (higher = sharper, lower = softer)
//This is the reciprocal of a regular bias (1/bias)
#define FADE 5e3
//Gamma exponent (2.2 is standard)
#define GAMMA 2.2
//Number if soft shadow samples
#define NUM 16.0
//Shadow map resolution
#define RES 2048.0
//Offset bias
#define BIAS -0.1
//Specular exponent for sharpness
#define SPEC_EXP 16.0
//Specular strength
#define SPEC_AMOUNT 0.5


varying vec4 v_shadow;
varying vec3 v_normal;
varying vec3 v_eye;
varying vec2 v_coord;
varying vec4 v_color;

//Shadow map texture
uniform sampler2D u_sha_map;
//Shadow projection
uniform mat4 u_sha_proj;

//Soft shadow radius
uniform float u_radius;
//Blue noise for soft shadows
uniform sampler2D u_noise;

//1-sample, shadow map test
float shadow_hard(vec4 p)
{
	//Project shadow map uvs
	vec2 uv = p.xy / p.w * vec2(0.5,-0.5) + 0.5;
	//Difference in shadow map and current depth
	float dif = (texture2D(u_sha_map, uv).r - p.z) / p.w;
	
	//Map to the 0 to 1 range
	return clamp(dif * FADE + 2.0, 0.0, 1.0);
}
//Interpolated shadows
float shadow_interp(vec4 p, float slope)
{
	//Linear sub-pixel coordinates
	vec2 l = fract(p.xy / p.w * RES * 0.5);
	//Cubic interpolation
	vec2 c = l*l * (3.0 - l*2.0);
	
	//Texel offsets
	vec3 t = p.w / RES * vec3(-0.5, +0.5, 0);
	//Offset to the nearest texel center
	vec4 o = p.w / RES * vec4(0.5 - l, BIAS*0.7*slope, 0);
	
	//Sample 4 nearest texels
	float s00 = shadow_hard(p + o + t.xxzz);
	float s10 = shadow_hard(p + o + t.yxzz);
	float s01 = shadow_hard(p + o + t.xyzz);
	float s11 = shadow_hard(p + o + t.yyzz);
	
	//Interpolate between samples (bi-cubic)
	return mix(mix(s00,s10,c.x), mix(s01,s11,c.x), c.y);
}
//Soft, disk shadows
float shadow_soft(vec4 p, float slope)
{
	//Sum of shadow samples for averaging
	float sum = 0.0;
	
	//Pick a random starting direction
	vec2 dir = normalize(texture2D(u_noise, gl_FragCoord.xy/64.0).xy - 0.5);
	//Noiseless version
	//vec2 dir = vec2(1,0);
	
	//Golden angle rotation matrix
	//https://mini.gmshaders.com/i/139108917/golden-angle
	const mat2 ang = mat2(-0.7373688, -0.6754904, 0.6754904,  -0.7373688);
	
	//Fibonacci disk scale
	float scale = u_radius / RES;

	//Loop through samples in a disk (i approx. ranges from 0 to 1)
	for(float i = 0.5/NUM; i<1.0; i+=1.0/NUM)
	{
		//Rotate sample direction
		dir *= ang;
		//Sample point radius
		float radius = scale * sqrt(i);
		
		//Add hard shadow sample
		sum += shadow_hard(radius * vec4(dir, BIAS*slope, 0) + p);
	}
	return sum / NUM;
}

void main()
{
	//Discard below the alpha threshold
	vec4 col = texture2D(gm_BaseTexture, v_coord);
	if (col.a<0.5) discard;
	
	//Factor in vertex color
	col *= v_color;
	//Convert to linear RGB
	col.rgb = pow(col.rgb, vec3(GAMMA));
	
	//Compute shadow-projection-space coordinates
	vec4 proj = u_sha_proj * v_shadow;
	
	//Normalize to the -1 to +1 range (accounting for perspective)
	vec2 suv = proj.xy/proj.w;
	//Edge vignette from shadow uvs
	vec2 edge = max(1.0 - suv*suv, 0.0);
	//Shade anything outside of the shadow map
	float shadow = edge.x * edge.y * float(proj.z>0.0);
	//Normalize shadow-space normals
	vec3 norm = normalize(v_normal);
	
	//Compute slope with safe limits
	float slope = 1.0 / max(-norm.z, 0.1);
	//Only do shadow mapping inside the shadow map
	if (shadow>0.01) shadow *= shadow_soft(proj, slope);
	//Try alternative shadow functions here: shadow_hard(proj), shadow_interp(proj, slope)
	
	//Soft lighting
	float lig = max(-norm.z, 0.5-0.5*norm.z);
	//Blend with shadows and some ambient light
	lig *= lig * (shadow*0.95 + 0.05);
	
	//Specular reflection
	vec3 eye = normalize(v_eye);
	float ref = max(reflect(eye, norm).z, 0.0);
	float spec = pow(ref, SPEC_EXP) * SPEC_AMOUNT;
	//Screen blend specular highlights with 
	col.rgb = 1.0 - (1.0 - col.rgb*lig) * (1.0 - spec);
	
	//Convert back to sRGB
	col.rgb = pow(col.rgb, 1.0/vec3(GAMMA));
	//col.rgb = sin(eye/.1)*.5+.5;
	
	//Colorless test
	//col.rgb = vec3(shadow);
    gl_FragColor = col;
}