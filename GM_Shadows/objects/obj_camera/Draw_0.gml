///@desc Draw with shadows

//Background color
draw_clear(#AABBCC);

//Draw lighting with shadows
shader_set(shd_light);
shader_set_uniform_matrix_array(u_sha_proj, sha_mat_proj);
shader_set_uniform_matrix_array(u_sha_view, sha_mat_view);
texture_set_stage(u_sha_map, surface_get_texture(sha_surface));
texture_set_stage(u_noise, t_noise);
shader_set_uniform_f(u_radius, exp(radius));

//Draw models
with(obj_model)
{
	event_perform(ev_other,ev_user0);
}

shader_reset();