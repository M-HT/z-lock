/*
	D-System 'LUMINOUS'

		'luminous.d'

	2004/01/30 jumpei isshiki
*/

private	import std.math;
private	import std.string;
private	import opengl;
private	import util_sdl;
private	import task;

private	GLuint		luminousTexture;
private	const int	LUMINOUS_TEXTURE_WIDTH_MAX = 64;
private	const int	LUMINOUS_TEXTURE_HEIGHT_MAX = 64;
private	GLuint[LUMINOUS_TEXTURE_WIDTH_MAX * LUMINOUS_TEXTURE_HEIGHT_MAX * 4 * uint.sizeof] td;
private	int			luminousTextureWidth = 64, luminousTextureHeight = 64;
private	float		luminous;

private	int[2][5]	lmOfs = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]];
private	const float	lmOfsBs = 5;

void TSKluminous(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_NPAUSE;
		    glLineWidth(1);
		    glEnable(GL_LINE_SMOOTH);
		    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		    glEnable(GL_BLEND);
		    glDisable(GL_LIGHTING);
		    glDisable(GL_CULL_FACE);
		    glDisable(GL_DEPTH_TEST);
		    glDisable(GL_TEXTURE_2D);
		    glDisable(GL_COLOR_MATERIAL);
			init(0.0f);
			TskBuf[id].fp_draw = &TSKluminousDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			close();
			clrTSK(id);
			break;
	}
}

void TSKluminousDraw(int id)
{
	startRenderToTexture();
	draw();
	endRenderToTexture();
}

/*----------------------------------------------------------------------------*/

static void init(float lumi)
{
	makeLuminousTexture();
	luminous = lumi;
}

static void makeLuminousTexture()
{
	uint *data = td.ptr;
	int i;

	td[0..$] = 0;
	//memset(data, 0, luminousTextureWidth * luminousTextureHeight * 4 * uint.sizeof);
	glGenTextures(1, &luminousTexture);
	glBindTexture(GL_TEXTURE_2D, luminousTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, 4, luminousTextureWidth, luminousTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

static void close()
{
	glDeleteTextures(1, &luminousTexture);
}

static void startRenderToTexture()
{
	glViewport(0, 0, luminousTextureWidth, luminousTextureHeight);
}

static void endRenderToTexture()
{
	glBindTexture(GL_TEXTURE_2D, luminousTexture);
	glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, luminousTextureWidth, luminousTextureHeight, 0);
	glViewport(util_sdl.screenStartx, util_sdl.screenStarty, util_sdl.screenWidth, util_sdl.screenHeight);
}

static void viewOrtho()
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, SCREEN_X, SCREEN_Y, 0, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
}

static void viewPerspective()
{
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
}

static void draw()
{
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, luminousTexture);
	viewOrtho();
	glColor4f(1.0, 1.0, 1.0, luminous);
	glBegin(GL_QUADS);
	for(int i = 0; i < 5; i++){
		glTexCoord2f(0, 1);
		glVertex2f(0 + lmOfs[i][0] * lmOfsBs, 0 + lmOfs[i][1] * lmOfsBs);
		glTexCoord2f(0, 0);
		glVertex2f(0 + lmOfs[i][0] * lmOfsBs, SCREEN_X + lmOfs[i][1] * lmOfsBs);
		glTexCoord2f(1, 0);
		glVertex2f(SCREEN_X + lmOfs[i][0] * lmOfsBs, SCREEN_Y + lmOfs[i][0] * lmOfsBs);
		glTexCoord2f(1, 1);
		glVertex2f(SCREEN_X + lmOfs[i][0] * lmOfsBs, 0 + lmOfs[i][0] * lmOfsBs);
    }
	glEnd();
	viewPerspective();
	glDisable(GL_TEXTURE_2D);
}
