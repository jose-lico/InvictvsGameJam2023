shader_type canvas_item;
uniform float color_multi = 1.0;
uniform int pixelSize = 4;


vec4 pixelatePosition(sampler2D texture, vec2 uv)
{

	ivec2 size = textureSize(texture, 0);

	int xRes = size.x;
	int yRes = size.y;

	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);

	float grid_uv_x = round(uv.x * xFactor) / xFactor;
	float grid_uv_y = round(uv.y * yFactor) / yFactor;

	vec4 text = texture(texture, vec2(grid_uv_x, grid_uv_y));

	vec4 col = text * color_multi;
	return col;
}

void fragment()
{
	COLOR = pixelatePosition(TEXTURE, UV);
}