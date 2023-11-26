shader_type canvas_item;

uniform float color_multi = 1.0;

uniform int pixelSize = 4;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 edge_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float threshold = 0.1;
uniform float blend = 0.01;

uniform vec2 r_displacement = vec2(0.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(0.0, 0.0);


vec4 get_lined_pixel(sampler2D tex, vec2 pos, vec2 pixel_size){
    vec3 col = -8.0 * texture(tex, pos).xyz;
    col += texture(tex, pos + vec2(0.0, pixel_size.y)).xyz;
    col += texture(tex, pos + vec2(0.0, -pixel_size.y)).xyz;
    col += texture(tex, pos + vec2(pixel_size.x, 0.0)).xyz;
    col += texture(tex, pos + vec2(-pixel_size.x, 0.0)).xyz;
    col += texture(tex, pos + pixel_size.xy).xyz;
    col += texture(tex, pos - pixel_size.xy).xyz;
    col += texture(tex, pos + vec2(-pixel_size.x, pixel_size.y)).xyz;
    col += texture(tex, pos + vec2(pixel_size.x, -pixel_size.y)).xyz;
	
	vec3 outcol = (step(threshold,col.r) == 1.0) ? edge_color.xyz : vec3(1.0);
    return vec4(outcol, 1.0);
}


vec4 pixelatePosition(sampler2D texture, vec2 uv, vec2 pixel_size)
{

	ivec2 size = textureSize(texture, 0);

	int xRes = size.x;
	int yRes = size.y;

	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);

	float grid_uv_x = round(uv.x * xFactor) / xFactor;
	float grid_uv_y = round(uv.y * yFactor) / yFactor;

	vec4 text = texture(texture, vec2(grid_uv_x, grid_uv_y));
	vec4 lined_px = get_lined_pixel(texture, vec2(grid_uv_x, grid_uv_y), pixel_size);
	vec4 col = text * (lined_px * blend);
	return col * color_multi;
}



void fragment()
{
//	COLOR = pixelatePosition(TEXTURE, UV, SCREEN_PIXEL_SIZE);
	float r = pixelatePosition(TEXTURE, UV + vec2(SCREEN_PIXEL_SIZE*r_displacement), SCREEN_PIXEL_SIZE).r;
	float g = pixelatePosition(TEXTURE, UV + vec2(SCREEN_PIXEL_SIZE*g_displacement), SCREEN_PIXEL_SIZE).g;
	float b = pixelatePosition(TEXTURE, UV + vec2(SCREEN_PIXEL_SIZE*b_displacement), SCREEN_PIXEL_SIZE).b;
	
	COLOR = vec4(r, g, b, 1.0);

	
//	COLOR.rgb = mix(edge_color.rgb, screen_color.rgb, edge);
}