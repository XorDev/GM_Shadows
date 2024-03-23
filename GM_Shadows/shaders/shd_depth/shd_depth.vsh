attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying float v_depth;
varying vec2 v_coord;

void main()
{
	vec3 pos = in_Position;
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(pos, 1);
    
	v_depth = gl_Position.z;
}