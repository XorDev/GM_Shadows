varying float v_depth;
varying vec2 v_coord;

void main()
{
	//Discard below the alpha threshold
	vec4 col = texture2D(gm_BaseTexture, v_coord);
	if (col.a<0.5) discard;
	
	//Output depth
    gl_FragColor = vec4(v_depth, 0, 0, 1);
}