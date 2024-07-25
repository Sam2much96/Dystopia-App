// 2D Hexagon Masking Shader
shader_type canvas_item;

// Firt quadrant hexagon edge constants
const float X1 = 0.25;
const float Y1 = 0.06698729810778;
const float M  = -1.73205080756888;

// Border = Everything outside the hexagon
// Tile = Everything inside the hexagon
// Outline = Edges of the hexagon (size in UV units)
uniform float BorderAlpha : hint_range( 0.0, 1.0 ) = 0.0;
uniform float TileAlpha : hint_range( 0.0, 1.0 ) = 1.0;
uniform float OutlineSize : hint_range( 0.0, 0.5 ) = 0.0;
uniform float OutlineAlpha : hint_range( 0.0, 1.0 ) = 1.0;

void fragment() {
	// Pull in the texture
	COLOR = texture( TEXTURE, UV );
	// Need a copy for original alpha values
	vec4 color = texture( TEXTURE, UV );
	// Set everything to the BorderAlpha
	COLOR.a = color.a * BorderAlpha;
	// Map current point to first quadrant
	float x0 = min( UV.x, 1.0 - UV.x );
	float y0 = min( UV.y, 1.0 - UV.y );
	// Compute line through UV.x,UV.y orthogonal to hex edge
	float m = M;
	float m0 = -1.0 / m;
	float b0 = y0 - m0 * x0;
	// Find x,y = intersection of hex edge and orthognoal through UV.x,UV.y
	float x = ( 0.5 - b0 ) / ( m0 - m );
	float y = m0 * x + b0;
	// Are we inside the hex?
	if ( x0 >= x && y0 >= Y1 ) {
		float d = distance( vec2( x, y ), vec2( x0, y0 ) );
		// Are we inside the outline?
		if ( d < OutlineSize || y0 - Y1 < OutlineSize )
			COLOR.a = color.a * OutlineAlpha;
		else
			COLOR.a = color.a * TileAlpha;
	}
}