/*
	D-System 'ASCII UTILITY'

		'util_ascii.d'

	2004/02/09 jumpei isshiki
*/

private	import	std.math;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_sdl;

const float	ASC_SIZE = (16.0f + 2.0f);

private	float[][]	ascii_font = [
									/* 'A' */
									[
										3, 0, 11, 2,
										0, 3, 2, 14,
										12, 3, 14, 14,
										3, 7, 11, 9,
									],
									/* 'B' */
									[
										0, 0, 2, 14,
										3, 0, 11, 2,
										3, 6, 11, 8,
										3, 12, 11, 14,
										12, 3, 14, 5,
										12, 9, 14, 11,
									],
									/* 'C' */
									[
										3, 0, 14, 2,
										0, 3, 2, 11,
										3, 12, 14, 14,
									],
									/* 'D' */
									[
										0, 0, 11, 2,
										0, 3, 2, 11,
										12, 3, 14, 11,
										0, 12, 11, 14,
									],
									/* 'E' */
									[
										0, 0, 14, 2,
										0, 3, 2, 11,
										0, 12, 14, 14,
										3, 6, 11, 8,
									],
									/* 'F' */
									[
										0, 0, 2, 14,
										3, 0, 14, 2,
										3, 6, 11, 8,
									],
									/* 'G' */
									[
										3, 0, 14, 2,
										0, 3, 2, 11,
										3, 12, 11, 14,
										9, 6, 14, 8,
										12, 9, 14, 11,
									],
									/* 'H' */
									[
										0, 0, 2, 14,
										12, 0, 14, 14,
										3, 6, 11, 8,
									],
									/* 'I' */
									[
										3, 0, 11, 2,
										6, 3, 8, 11,
										3, 12, 11, 14,
									],
									/* 'J' */
									[
										9, 0, 14, 2,
										12, 3, 14, 11,
										3, 12, 11, 14,
										0, 9, 2, 11,
									],
									/* 'K' */
									[
										0, 0, 2, 14,
										3, 6, 11, 8,
										12, 0, 14, 5,
										12, 9, 14, 14,
									],
									/* 'L' */
									[
										0, 0, 2, 11,
										0, 12, 14, 14,
									],
									/* 'M' */
									[
										0, 0, 2, 14,
										12, 0, 14, 14,
										3, 3, 5, 5,
										9, 3, 11, 5,
										6, 6, 8, 8,
									],
									/* 'N' */
									[
										0, 0, 2, 14,
										12, 0, 14, 14,
										3, 3, 5, 5,
										6, 6, 8, 8,
										9, 9, 11, 11,
									],
									/* 'O' */
									[
										3, 0, 11, 2,
										12, 3, 14, 11,
										3, 12, 11, 14,
										0, 3, 2, 11,
									],
									/* 'P' */
									[
										0, 0, 2, 14,
										3, 0, 11, 2,
										3, 6, 11, 8,
										12, 3, 14, 5,
									],
									/* 'Q' */
									[
										3, 0, 11, 2,
										12, 3, 14, 11,
										3, 12, 11, 14,
										0, 3, 2, 11,
										9, 9, 11, 11,
									],
									/* 'R' */
									[
										0, 0, 2, 14,
										3, 0, 11, 2,
										3, 6, 11, 8,
										12, 3, 14, 5,
										12, 9, 14, 14,
									],
									/* 'S' */
									[
										3, 0, 14, 2,
										0, 3, 2, 5,
										3, 6, 11, 8,
										12, 9, 14, 11,
										0, 12, 11, 14,
									],
									/* 'T' */
									[
										0, 0, 14, 2,
										6, 3, 8, 14,
									],
									/* 'U' */
									[
										0, 0, 2, 11,
										3, 12, 11, 14,
										12, 0, 14, 11,
									],
									/* 'V' */
									[
										0, 0, 2, 8,
										12, 0, 14, 8,
										3, 9, 5, 11,
										9, 9, 11, 11,
										6, 12, 8, 14,
									],
									/* 'W' */
									[
										0, 0, 2, 11,
										6, 0, 8, 11,
										12, 0, 14, 11,
										3, 12, 5, 14,
										9, 12, 11, 14,
									],
									/* 'X' */
									[
										0, 0, 2, 5,
										12, 0, 14, 5,
										3, 6, 11, 8,
										0, 9, 2, 14,
										12, 9, 14, 14,
									],
									/* 'Y' */
									[
										0, 0, 2, 5,
										12, 0, 14, 5,
										3, 6, 5, 8,
										9, 6, 11, 8,
										6, 9, 8, 14,
									],
									/* 'Z' */
									[
										0, 0, 14, 2,
										12, 3, 14, 5,
										3, 6, 11, 8,
										0, 9, 2, 11,
										0, 12, 14, 14,
									],
									/* '.' */
									[
										3, 12, 5, 14,
									],
									/* ':' */
									[
										5,  2, 8,  5,
										5, 11, 8, 14,
									],
									/* '!' */
									[
										6, 0, 8, 11,
										6, 13, 8, 14,
									],
									/* '?' */
									[
										0, 3, 2, 5,
										3, 0, 11, 2,
										12, 3, 14, 5,
										9, 6, 11, 8,
										6, 9, 8, 11,
										6, 13, 8, 14,
									],
									/* '"' */
									[
										5, 0, 7, 5,
										9, 0, 11, 5,
									],
									/* ''' */
									[
										6, 0, 10, 3,
										9, 3, 10, 5,
									],
									/* '-' */
									[
										0, 6, 14, 8,
									],
									/* '=' */
									[
										0, 3, 14, 5,
										0, 9, 14,11,
									],
									/* '+' */
									[
										0, 6, 14, 8,
										6, 0, 8, 5,
										6, 9, 8, 14,
									],
									/* ' ' */
									[
									],
									/* '0' */
									[
										0, 0, 2, 14,
										12, 0, 14, 14,
										3, 0, 11, 2,
										3, 12, 11, 14,
									],
									/* '1' */
									[
										3, 0, 5, 2,
										6, 0, 8, 11,
										3, 12, 11, 14,
									],
									/* '2' */
									[
										0, 0, 14, 2,
										12, 3, 14, 5,
										0, 6, 14, 8,
										0, 9, 2, 11,
										0, 12, 14, 14,
									],
									/* '3' */
									[
										0, 0, 14, 2,
										12, 3, 14, 5,
										3, 6, 14, 8,
										12, 9, 14, 11,
										0, 12, 14, 14,
									],
									/* '4' */
									[
										0, 3, 2, 8,
										3, 0, 14, 2,
										12, 3, 14, 14,
										0, 9, 11, 11,
									],
									/* '5' */
									[
										0, 0, 14, 2,
										0, 3, 2, 5,
										0, 6, 14, 8,
										12, 9, 14, 11,
										0, 12, 14, 14,
									],
									/* '6' */
									[
										0, 0, 14, 2,
										0, 3, 2, 14,
										3, 12, 14, 14,
										12, 6, 14, 11,
										3, 6, 11, 8,
									],
									/* '7' */
									[
										0, 0, 14, 2,
										12, 3, 14, 5,
										9, 6, 11, 8,
										6, 9, 8, 14,
									],
									/* '8' */
									[
										0, 0, 2, 14,
										12, 0, 14, 14,
										3, 0, 11, 2,
										3, 6, 11, 8,
										3, 12, 11, 14,
									],
									/* '9' */
									[
										12, 0, 14, 14,
										0, 12, 11, 14,
										0, 0, 11, 2,
										0, 3, 2, 8,
										3, 6, 11, 8,
									],
								];

private	string	ascii_dict = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.:!?\"'-=+ 0123456789";

void	initASCII()
{
	for(int i = 0; i < ascii_font.length; i++){
		for(int j = 0; j < ascii_font[i].length; j += 4){
			ascii_font[i][j+2] += 1.0f;
			ascii_font[i][j+3] += 1.0f;
			ascii_font[i][j+1] *= (-1.0f);
			ascii_font[i][j+3] *= (-1.0f);
		}
	}
}

void	drawASCII(const char[] str,float px,float py,float s)
{
	int			word;
	float		nx,ny,nz;
	float[XY]	pos1;
	float[XY]	pos2;

	nx = px;
	ny = py;
	nz = BASE_Z - cam_pos;

	for(int i = 0; i < str.length; i++){
		if((word = serchASCIIdict(str[i])) >= 0){
			for(int j = 0; j < ascii_font[word].length; j += 4){
				pos1[X] = ascii_font[word][j+0] * s;
				pos1[Y] = ascii_font[word][j+1] * s;
				pos2[X] = ascii_font[word][j+2] * s;
				pos2[Y] = ascii_font[word][j+3] * s;
				glVertex3f(getPointX(nx+pos1[X], nz),
						   getPointY(ny+pos2[Y], nz),
						   0.0f);
				glVertex3f(getPointX(nx+pos1[X], nz),
						   getPointY(ny+pos1[Y], nz),
						   0.0f);
				glVertex3f(getPointX(nx+pos2[X], nz),
						   getPointY(ny+pos1[Y], nz),
						   0.0f);
				glVertex3f(getPointX(nx+pos2[X], nz),
						   getPointY(ny+pos2[Y], nz),
						   0.0f);
			}
			nx += ASC_SIZE * s;
		}
	}
}

void	drawASCIIZ(const char[] str,float px,float py,float pz,float s)
{
	int			word;
	float		nx,ny,nz;
	float[XY]	pos1;
	float[XY]	pos2;

	nx = px;
	ny = py;
	nz = pz;

	for(int i = 0; i < str.length; i++){
		if((word = serchASCIIdict(str[i])) >= 0){
			for(int j = 0; j < ascii_font[word].length; j += 4){
				pos1[X] = ascii_font[word][j+0] * s;
				pos1[Y] = ascii_font[word][j+1] * s;
				pos2[X] = ascii_font[word][j+2] * s;
				pos2[Y] = ascii_font[word][j+3] * s;
				glVertex3f(getPointX(nx+pos1[X], nz),
						   getPointY(ny+pos2[Y], nz),
						   0.0f);
				glVertex3f(getPointX(nx+pos1[X], nz),
						   getPointY(ny+pos1[Y], nz),
						   0.0f);
				glVertex3f(getPointX(nx+pos2[X], nz),
						   getPointY(ny+pos1[Y], nz),
						   0.0f);
				glVertex3f(getPointX(nx+pos2[X], nz),
						   getPointY(ny+pos2[Y], nz),
						   0.0f);
			}
			nx += ASC_SIZE * s;
		}
	}
}

static	int	serchASCIIdict(char word)
{
	for(int i = 0; i < ascii_dict.length; i++){
		if(ascii_dict[i] == word) return i;
	}

	return	-1;
}

float	getWidthASCII(const char[] str,float s)
{
	int		word;
	float	wx = 0.0f;

	for(int i = 0; i < str.length; i++){
		if((word = serchASCIIdict(str[i])) >= 0) wx += ASC_SIZE * s;
	}

	return	wx;
}

