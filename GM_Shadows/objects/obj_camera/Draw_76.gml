///@desc Create the shadow map if there isn't one

if !surface_exists(sha_surface)
{
	//Create shadow map (1 channel, 32 bit float)
	sha_surface = surface_create(sha_res, sha_res, surface_r32float);
	
	//Update shadow map first
	shadow_update();
}