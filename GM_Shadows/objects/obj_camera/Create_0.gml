///@desc Initialize variables and settings

//Camera direction and turn delta
dx = 0;
dy = 0;

tx = 0;
ty = 0;

sensitivity = 0.1;

//Camera position and velocity
px = 0;
py = 0;
pz = 8;

vx = 0;
vy = 0;
vz = 0;

//Target radius and smooth radius
rad = 1;
radius = 0;

locked = true;
debug = false;
AA = false; //Causes issues (press 3 to see)

window_set_cursor(cr_cross);
window_mouse_set_locked(locked);

//Set gpu settings
gpu_set_tex_filter(tf_linear);
gpu_set_tex_mip_enable(true);
gpu_set_tex_mip_bias(-0.5);
gpu_set_ztestenable(true);

//Camera matrix
ww = window_get_width();
wh = window_get_height();

mat_proj = matrix_build_projection_perspective_fov(100,ww/wh,0.1,250);
mat_view = matrix_build_lookat(0,0,0,0,0,0,0,0,-1);

camera_set_proj_mat(view_camera[0], mat_proj);

//Shadow uniforms
sha_surface = -1;
sha_res = 2048;

sha_mat_proj = matrix_build_projection_ortho(32,32,-100,100);
//sha_mat_proj = matrix_build_projection_perspective_fov(100,1,0.1,250);
sha_mat_view = matrix_build_lookat(-8,-8,16,0,0,8,0,0,-1);

u_sha_proj = shader_get_uniform(shd_light, "u_sha_proj");
u_sha_view = shader_get_uniform(shd_light, "u_sha_view");
u_sha_map = shader_get_sampler_index(shd_light, "u_sha_map");
u_noise = shader_get_sampler_index(shd_light, "u_noise");
u_radius = shader_get_uniform(shd_light, "u_radius");

gpu_set_tex_filter_ext(u_noise, tf_point);
gpu_set_tex_repeat_ext(u_noise, true);

t_noise = sprite_get_texture(spr_noise, 0);


function shadow_update()
{
	//Disable alpha blending (which messes up the data)
	gpu_set_blendenable(false);
    //Draw to the depth surface
	surface_set_target(sha_surface);
    //Clear the surface
	draw_clear(-1);
    //Set matrices
	matrix_set(matrix_view, sha_mat_view);
	matrix_set(matrix_projection, sha_mat_proj);
	//Apply depthmap shader
	shader_set(shd_depth);
	shader_set_uniform_f(shader_get_uniform(shd_depth,"u_radius"),radius);

    //Draw any models that you want to cast shadows
	with(obj_model)
	{
		event_perform(ev_other,ev_user0);
	}

	//Reset
	shader_reset();
	surface_reset_target();
	gpu_set_blendenable(true);
}