/*
	D-System 'SDL UTILITY'

		'util_sdl.d'

	2003/11/28 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.string;
private	import	SDL;
private	import	opengl;
private	import	util_pad;
private	import	define;

enum{
	SURFACE_MAX = 100,
	SCREEN_X = 640,
	SCREEN_Y = 480,
	SCREEN_Z = 640,
	SCREEN_SX = 384,
	SCREEN_SY = SCREEN_Y,
	SCREEN_SZ = SCREEN_Z,
	SCREEN_MX = (SCREEN_X - SCREEN_SX) / 2,

	X = 0,
	Y,
	Z,
	W,
	XY = 2,
	XYZ = 3,
	XYZW = 4,

	SX = 0,
	SY,
	EX,
	EY,
}

struct VEC_POS {
	float	px;
	float	py;
	float	pz;
}

SDL_Surface*	primary;
SDL_Surface*[]	offscreen;

const float	BASE_Z = 2.0f;
float		cam_scr = -0.75f;
float		cam_pos;

private	int width = SCREEN_X;
private	int height = SCREEN_Y;
public	int startx = 0;
public	int starty = 0;
private	float nearPlane = 0.0f;
private	float farPlane = 1000.0f;
private	GLuint TEXTURE_NONE = 0xffffffff;

private	GLuint[] tex_bank;

int initSDL()
{
	if(SDL_Init(SDL_INIT_VIDEO|SDL_INIT_JOYSTICK) < 0){
		return	0;
    }

	return	1;
}

void closeSDL()
{
	SDL_ShowCursor(SDL_ENABLE);
	SDL_Quit();
}

int initVIDEO()
{
	Uint32	videoFlags;

	videoFlags = SDL_OPENGL;
	version (PANDORA) {
		videoFlags |= SDL_FULLSCREEN;
	} else {
		debug{
			if((pads & PAD_BUTTON1)){
				videoFlags = SDL_OPENGL | SDL_FULLSCREEN;
			}else{
				videoFlags = SDL_OPENGL | SDL_RESIZABLE;
			}
		}
	}
	int physical_width = width;
	int physical_height = height;
	version (PANDORA) {
		physical_width = 800;
		physical_height = 480;
		startx = (800 - width) / 2;
		starty = (480 - height) / 2;
	}
	primary = SDL_SetVideoMode(physical_width, physical_height, 0, videoFlags);
	if(primary == null){
		return	0;
    }

	offscreen.length = SURFACE_MAX;
	tex_bank.length  = SURFACE_MAX;
	for(int i = 0; i < SURFACE_MAX; i++){
		offscreen[i] = null;
		tex_bank[i]  = TEXTURE_NONE;
	}

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    resizedSDL(width, height);
	SDL_ShowCursor(SDL_DISABLE);

	SDL_WM_SetCaption(std.string.toStringz(PROJECT_NAME), null);

	return	1;
}

void closeVIDEO()
{
	for(int i = 0; i < SURFACE_MAX; i++){
		if(tex_bank[i] != TEXTURE_NONE){
			glDeleteTextures(1, &tex_bank[i]);
			writefln("free texture bank %d.",i);
		}
		if(offscreen[i]){
			SDL_FreeSurface(offscreen[i]);
			writefln("free off-screen surface %d.",i);
		}
	}
}

void readSDLtexture(const char[] fname, int bank)
{
	offscreen[bank] = SDL_LoadBMP(toStringz(fname));
	if(offscreen[bank]){
		glGenTextures(1, &tex_bank[bank]);
		glBindTexture(GL_TEXTURE_2D, tex_bank[bank]);
		glTexImage2D(GL_TEXTURE_2D, 0, 3, offscreen[bank].w, offscreen[bank].h, 0, GL_RGB, GL_UNSIGNED_BYTE, offscreen[bank].pixels);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	}
}

void bindSDLtexture(int bank)
{
	if(tex_bank[bank] != TEXTURE_NONE) glBindTexture(GL_TEXTURE_2D, tex_bank[bank]);
}

void clearSDL()
{
	glClear(GL_COLOR_BUFFER_BIT);
}

void flipSDL()
{
	glFlush();
	SDL_GL_SwapBuffers();
}

void resizedSDL(int w, int h)
{
	glViewport(startx, starty, w, h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	if (nearPlane != 0.0f) {
		w = (w ? w : 1);
		glFrustum(-nearPlane,nearPlane,
			  	-nearPlane * h / w,
			   	nearPlane * h / w,
				  0.1f, farPlane);
	}
	glMatrixMode(GL_MODELVIEW);
}

float	getPointX(float p,float z)
{
	return	p / SCREEN_X * (z + cam_pos);
}

float	getPointY(float p,float z)
{
	return	p / SCREEN_Y * (z + cam_pos);
}

float	getPointZ(float p,float z)
{
	return	p / SCREEN_Z * (z + cam_pos);
}

