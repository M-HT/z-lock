/*
	D-System 'SDL UTILITY'

		'util_sdl.d'

	2003/11/28 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.string;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_pad;
private	import	define;

version(PANDORA) version = FORCE_FULLSCREEN;
version(PYRA) version = FORCE_FULLSCREEN;

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

SDL_Window*	window;
SDL_GLContext	context;
SDL_Surface*	primary;
SDL_Surface*[]	offscreen;

const float	BASE_Z = 2.0f;
float		cam_scr = -0.75f;
float		cam_pos;

int	screenWidth, screenHeight, screenStartx, screenStarty;

private	int width = SCREEN_X;
private	int height = SCREEN_Y;
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
	uint	videoFlags;

	videoFlags = SDL_WINDOW_OPENGL;
	version(FORCE_FULLSCREEN) {
		videoFlags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
	} else {
		debug{
			if((pads & PAD_BUTTON1)){
				videoFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_FULLSCREEN_DESKTOP;
			}else{
				videoFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE;
			}
		}
	}
	window = SDL_CreateWindow(std.string.toStringz(PROJECT_NAME), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, videoFlags);
	if(window == null){
		return	0;
	}
	context = SDL_GL_CreateContext(window);
	if(context == null){
		SDL_DestroyWindow(window);
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
	SDL_GL_DeleteContext(context);
	SDL_DestroyWindow(window);
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
	SDL_GL_SwapWindow(window);
}

void resizedSDL(int w, int h)
{
	screenStartx = 0;
	screenStarty = 0;
	screenWidth = w;
	screenHeight = h;
	static if(SDL_VERSION_ATLEAST(2, 0, 1)) {
		SDL_version linked;
		SDL_GetVersion(&linked);
		if (SDL_version(linked.major, linked.minor, linked.patch) >= SDL_version(2, 0, 1)) {
			int glwidth, glheight;
			SDL_GL_GetDrawableSize(window, &glwidth, &glheight);
			if (SDL_GetWindowFlags(window) & SDL_WINDOW_FULLSCREEN_DESKTOP) {
				if ((cast(float)(glwidth)) / w <= (cast(float)(glheight)) / h) {
					screenStartx = 0;
					screenWidth = glwidth;
					screenHeight = (glwidth * h) / w;
					screenStarty = (glheight - screenHeight) / 2;
				} else {
					screenStarty = 0;
					screenHeight = glheight;
					screenWidth = (glheight * w) / h;
					screenStartx = (glwidth - screenWidth) / 2;
				}
			} else {
				screenWidth = glwidth;
				screenHeight = glheight;
			}
		}
	}
	glViewport(screenStartx, screenStarty, screenWidth, screenHeight);
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

