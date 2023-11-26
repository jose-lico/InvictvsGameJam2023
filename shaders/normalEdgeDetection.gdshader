shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float min_step : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float max_step : hint_range(0.0, 1.0, 0.01) = 0.6;

// const mat3 kx = mat3(
// 	vec3(-1, 0, 1),
// 	vec3(-2, 0, 2),
// 	vec3(-1, 0, 1)
// );

// const mat3 ky = mat3(
// 	vec3(-1, -2, -1),
// 	vec3(0, 0, 0),
// 	vec3(1, 2, 1)
// );

const mat3 kx = mat3(
	vec3(0, -1, 0),
	vec3(-1, 4, -1),
	vec3(-0, -1, 0)
);

const mat3 ky = mat3(
	vec3(-1, -1, -1),
	vec3(-1, 8, -1),
	vec3(-1, -1, -1)
);

void vertex() { 
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() { 
	
	vec4 texture_color = texture(screen_texture, SCREEN_UV);
	
	mat3 I;
	for (int i = 0; i < 3; i++ ) {
		for (int j = 0; j < 3; j++) {
			vec3 sample_around_pixel = texelFetch(screen_texture, ivec2(FRAGCOORD.xy) + ivec2(i-1,j-1), 0).rgb;
			vec3 sample_grey = vec3(sample_around_pixel.r * 0.3, sample_around_pixel.g * 0.59, sample_around_pixel.b * 0.11);
			I[i][j] = sample_grey.r + sample_grey.g + sample_grey.b;
			
		}
	}
	
	float gx = dot(kx[0], I[0]) + dot(kx[1], I[1]) + dot(kx[2], I[2]);
	float gy = dot(ky[0], I[0]) + dot(ky[1], I[1]) + dot(ky[2], I[2]);
	float g = sqrt(pow(gx, 2.0) + pow(gy, 2.0)); 
	
	g = smoothstep(min_step, max_step, g);

	ALBEDO = texture_color.rgb * (vec3(1.0) - vec3(g));

}
