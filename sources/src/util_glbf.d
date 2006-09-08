/*
 *		This Code Was Created By Jeff Molofee 2000
 *		And Modified By Giuseppe D'Agata (waveform@tiscalinet.it)
 *		If You've Found This Code Useful, Please Let Me Know.
 *		Visit My Site At nehe.gamedev.net
 */

private	import	std.stdio;
private	import	std.string;
private	import	std.math;
private	import	std.stream;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;

struct GLBitmapFont {
	GLfloat	xsize;				// x-size
	GLfloat	xdots;				// x-dots
    GLuint	base;				// Base Display List For The Font
    GLuint	texture;			// Storage For Our Font Texture
}

private GLfloat scr_width;
private GLfloat scr_height;
private GLfloat half_width;
private GLfloat half_height;
private GLfloat rate_width;
private GLfloat rate_height;

private SDL_Surface* LoadBMP(char* filename)
{
	Uint8* rowhi, rowlo;
	Uint8[] tmpbuf;
	Uint8 tmpch;
	SDL_Surface* image;
	int i, j;

	image = SDL_LoadBMP(filename);
	if(image == null){
		writefln("Unable to load %s: %s", filename, SDL_GetError());
		return	null;
	}

	/* GL surfaces are upsidedown and RGB, not BGR :-) */
	tmpbuf.length = image.pitch;
	if(tmpbuf.length == 0){
		writefln("Out of memory");
		return	null;
	}
	rowhi = cast(Uint8*)image.pixels;
	rowlo = rowhi + (image.h * image.pitch) - image.pitch;
	for(i = 0; i < image.h / 2; ++i){
		for(j = 0; j < image.w; ++j){
			tmpch = rowhi[j*3];
			rowhi[j*3] = rowhi[j*3+2];
			rowhi[j*3+2] = tmpch;
			tmpch = rowlo[j*3];
			rowlo[j*3] = rowlo[j*3+2];
			rowlo[j*3+2] = tmpch;
		}
		//memcpy(tmpbuf, rowhi, image.pitch);
		//memcpy(rowhi, rowlo, image.pitch);
		//memcpy(rowlo, tmpbuf, image.pitch);
		tmpbuf[0..image.pitch] = rowhi[0..image.pitch];
		rowhi[0..image.pitch] = rowlo[0..image.pitch];
		rowlo[0..image.pitch] = tmpbuf[0..image.pitch];
		rowhi += image.pitch;
		rowlo -= image.pitch;
	}
	tmpbuf.length = 0;

	return	image;
}

// Load Bitmaps And Convert To Textures
private int LoadGLTextures(int* tex, char* filename, int* width, int* height)
{
    GLuint texture;
    SDL_Surface* TextureImage;				// Create Storage Space For The Textures

    TextureImage = null;

    if((TextureImage = LoadBMP(filename)) == null){
        return 1;
    }

    glGenTextures(1, &texture);		 		// Create Two Texture

    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage.w, TextureImage.h, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage.pixels);

    *width = TextureImage.w;
    *height = TextureImage.h;

    SDL_FreeSurface(TextureImage);			// Free The Image Structure

    *tex = texture;

    return 0;								// Return The Status
}

// Build Our Font Display List
private int BuildFont(GLBitmapFont* font, char* filename, GLfloat xsize, GLfloat xdots, GLfloat ydots)
{
    int loop;
	float cx;												// Holds Our X Character Coord
	float cy;												// Holds Our Y Character Coord
    int xchars, ychars;
    int width, height;
    int ret;

    ret = LoadGLTextures(cast(int*)&font.texture, filename, &width, &height);
    if(ret != 0){
        SDL_SetError("glbf: cannot load font");
        return	1;
    }

    xchars = cast(int)(width / xdots);
    ychars = cast(int)(height / ydots);

	font.xsize = xsize;
	font.xdots = xdots;
	font.base = glGenLists(256);							// Creating 256 Display Lists
	glBindTexture(GL_TEXTURE_2D, font.texture);				// Select Our Font Texture
	for(loop = 0; loop < 96; loop++){						// Loop Through All 256 Lists
		cx = cast(float)(loop % xchars) * xdots / width;	// X Position Of Current Character
		cy = cast(float)(loop / xchars) * ydots / height;	// Y Position Of Current Character
		cy -= 0.001;
		glNewList(font.base+loop, GL_COMPILE);				// Start Building A List
        glBegin(GL_QUADS);									// Use A Quad For Each Character
        glTexCoord2f(cx, 1-cy-ydots/height);				// Texture Coord (Bottom Left)
        glVertex2f(0, 0);									// Vertex Coord (Bottom Left)
        glTexCoord2f(cx+xdots/width, 1-cy-ydots/height);	// Texture Coord (Bottom Right)
        glVertex2f(xdots, 0);								// Vertex Coord (Bottom Right)
        glTexCoord2f(cx+xdots/width, 1-cy);					// Texture Coord (Top Right)
        glVertex2f(xdots, ydots);							// Vertex Coord (Top Right)
        glTexCoord2f(cx, 1-cy);								// Texture Coord (Top Left)
        glVertex2f(0, ydots);								// Vertex Coord (Top Left)
        glEnd();											// Done Building Our Quad (Character)
        glTranslated(xsize, 0, 0);							// Move To The Right Of The Character
		glEndList();										// Done Building The Display List
	}
    return	0;
}

// Delete The Font From Memory
GLvoid KillFont(GLBitmapFont font)
{
	glDeleteLists(font.base, 256);							// Delete All 256 Display Lists
}

// Where The Printing Happens
GLvoid glPrint(GLBitmapFont font, char[] str)
{
	glBindTexture(GL_TEXTURE_2D, font.texture);				// Select Our Font Texture
	glListBase(font.base-32);								// Choose The Font Set (0 or 1)
	glCallLists(str.length, GL_BYTE, str);					// Write The Text To The Screen
}

int glbfInit(GLBitmapFont* font, char* filename, GLfloat xsize, GLfloat xdots, GLfloat ydots)
{
	scr_width   = cast(GLfloat)SCREEN_X;
	scr_height  = cast(GLfloat)SCREEN_Y;
	half_width  = scr_width / 2.0f;
	half_height = scr_height / 2.0f;
	rate_width  = 2.0f / scr_width;
	rate_height = 2.0f / scr_height;

    return BuildFont(font, filename, xsize, xdots, ydots);
}

void glbfQuit(GLBitmapFont font)
{
    KillFont(font);
}

void glbfPrint(GLBitmapFont font, char[] str)
{
    glPrint(font, str);
}

// =============
// User Function
// =============

void glbfSetScreen(GLfloat width, GLfloat height)
{
	scr_width = width;
	scr_height = height;
}

void glbfPrintBegin()
{
	glEnable(GL_TEXTURE_2D);
	glPushMatrix();
}

void glbfPrintEnd()
{
	glPopMatrix();
	glDisable(GL_TEXTURE_2D);
}

void glbfScale(GLfloat x, GLfloat y)
{
	glScalef(rate_width * x, rate_height * y, 1.0f);
}

void glbfTranslate(GLfloat x, GLfloat y)
{
	glTranslatef(x / half_width, y / half_height, +0.0f);
}

GLfloat glbfGetWidth(GLBitmapFont font, char[] str, GLfloat s)
{
	return	str.length * glbfGetXsize(font, s);
}

GLfloat glbfGetXsize(GLBitmapFont font, GLfloat s)
{
	return	font.xsize * s;
}
