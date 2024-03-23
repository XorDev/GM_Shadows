///@desc Movement

//Smoothly turn
tx = lerp(tx, -window_mouse_get_delta_x()*sensitivity, 0.1);
ty = lerp(ty, +window_mouse_get_delta_y()*sensitivity, 0.1);

dx = (dx-tx+360)%360;
dy = clamp(dy-ty,-89,89);

//Update radius
rad += (mouse_wheel_up() - mouse_wheel_down())*0.1;
radius = lerp(radius, rad, 0.1);

//Keyboard movement
var _kb,_kf,_ks,_ku;
_kb = (.2+.8*keyboard_check(vk_shift))/(1+4*keyboard_check(vk_control));
_kf = (keyboard_check(ord("W")) - keyboard_check(ord("S")))*_kb;
_ks = (keyboard_check(ord("D")) - keyboard_check(ord("A")))*_kb;
_ku = (keyboard_check(ord("E")) - keyboard_check(ord("Q")))*_kb;

//Smooth velocity
vx = lerp(vx, (+_kf*dcos(dx)-_ks*dsin(dx))*dcos(dy), 0.1);
vy = lerp(vy, (-_kf*dsin(dx)-_ks*dcos(dx))*dcos(dy), 0.1);
vz = lerp(vz, (+_kf*dsin(dy)+_ku), 0.1);

px += vx;
py += vy;
pz += vz;

//Update view
mat_view = matrix_build_lookat(px,py,pz, px+dcos(dx)*dcos(dy),py-dsin(dx)*dcos(dy),pz+dsin(dy), 0,0,-1);

camera_set_view_mat(view_camera[0], mat_view);

//End game with escape
if keyboard_check(vk_escape) game_end();

//Update light
if keyboard_check(vk_space)
{
	sha_mat_view = mat_view;
	
	shadow_update();
}

//Toggle mouse lock
if keyboard_check_pressed(vk_enter)
{
	locked = !locked;
	show_debug_message($"Mouse {locked? "locked" : "unlocked" }");
	
	window_mouse_set_locked(locked);
}


//Toggle debug menu
if keyboard_check_pressed(ord("1"))
{
	debug = !debug;
	
	show_debug_overlay(debug);
}
//Toggle anti-aliasing
if keyboard_check_pressed(ord("3"))
{
	AA = !AA;
	show_debug_message($"Anti-aliasing: {AA}");
	
	var _aa = max(display_aa&1, display_aa&2, display_aa&4, display_aa&8);
	display_reset(_aa * AA, true);
	
	shadow_update();
}