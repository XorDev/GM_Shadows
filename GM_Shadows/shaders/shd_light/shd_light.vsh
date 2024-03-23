attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec4 v_shadow;
varying vec3 v_normal;
varying vec3 v_eye;
varying vec2 v_coord;
varying vec4 v_color;

//Shadow view matrix
uniform mat4 u_sha_view;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
    
	//Shortened for convenience
	mat4 mat_world = gm_Matrices[MATRIX_WORLD];
	mat4 mat_view = gm_Matrices[MATRIX_WORLD_VIEW];
	
	//World space position
	vec4 wor = mat_world * vec4(in_Position, 1);
	//World space camera position
	vec3 cam = -mat_view[3].xyz * mat3(mat_view);
	
	//Shadow view coordinates
	v_shadow = u_sha_view * wor;
	//Normals in shadow-space
	v_normal = mat3(u_sha_view) * mat3(mat_world) * in_Normal;
	//World, relative to camera, in shadow space
	v_eye = mat3(u_sha_view) * (cam - wor.xyz);
	//Regular color and texture
    v_color = in_Colour;
    v_coord = in_TextureCoord;
}