/*
	Z-LOCK 'MAIN'

		'main.d'

	2003/11/28 jumpei isshiki
*/

version(Windows){
	private import core.runtime;
	private import core.sys.windows.windows;
}
private	import	std.stdio;
private	import	std.string;
private	import	std.randomD1;
private	import	std.conv;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_sdl;
private	import	util_glbf;
private	import	util_pad;
private	import	util_snd;
private	import	util_ascii;
private	import	bulletcommand;
private	import	init;
private	import	define;
private	import	task;
private	import	sysinfo;
private	import	gctrl;
private	import	ship;

version(PANDORA) version = FORCE_FULLSCREEN;
version(PYRA) version = FORCE_FULLSCREEN;

GLBitmapFont font;

int turn = 0;
int game_exec = 0;
int pause = 0;
int pause_flag = 0;
int skip = 0;

version(Windows){
	extern (Windows)
	int		WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		int result;
		int argc;
		char[] str_buf;
		char[][] split_buf;

		debug{
			argc = 0;
			for(int i = 0; ; i++){
				argc++;
				if(lpCmdLine[i] == 0x00) break;
			}

			str_buf.length = argc;
			for(int i = 0; i < argc; i++){
				str_buf[i] = lpCmdLine[i];
			}
			split_buf = split(str_buf);
		}

		try{
			Runtime.initialize();
			result = boot();
			Runtime.terminate();
		}catch (Throwable o){
			MessageBoxA(null, std.string.toStringz(o.toString()), std.string.toStringz("Error"), MB_OK | MB_ICONEXCLAMATION);
			result = 0;
		}

		return result;
	}
}else{
	int main(char[][] argv)
	{
		return boot();
	}
}

int		boot()
{
	const int INTERVAL_BASE = 16;

	int			id;
	SDL_Event	event;
	int			interval = INTERVAL_BASE;
	int			accframe = 0;
	int			maxSkipFrame = 5;
	int			prvTickCount = 0;
	int			nowTick;
	int			frame;
	int			i;

	debug{
		writefln("TASK structure size %d",TSK.sizeof);
	}

	if(!initSDL()){
		writefln("SDL initialize failed.");
		return	0;
	}
	if(!initPAD()){
		writefln("PAD initialize failed.");
		closeSDL();
		return	0;
	}

	/* 起動用パッドを取得 */
	version(FORCE_FULLSCREEN) {
	} else {
		writefln("press c button - full screen");
		for(int i1 = 0; i1 < 60; i1++){
			SDL_Delay(16);
			while (SDL_PollEvent(&event)){}
			getPAD();
		}
	}

	if(!initVIDEO()){
		writefln("VIDEO initialize failed.");
		closeSDL();
		closePAD();
		return	0;
	}
	if(!initSND(SND_BGMMAX,SND_SEMAX)){
		writefln("SOUND initialize failed.");
		closePAD();
		closeVIDEO();
		closeSDL();
		return	0;
	}

	grpINIT();
	sndINIT();
	initTSK();
	initASCII();
	bulletINIT();
	configINIT();
	sysinfoINIT(256);

	glbfInit(&font, std.string.toStringz("edificio.bmp"), 14.0f, 16.0f, 16.0f);
	glbfSetScreen(SCREEN_X, SCREEN_Y);

	game_exec = 1;

	setTSK(GROUP_00,&TSKgctrl);

	while(game_exec){
		while (game_exec && SDL_PollEvent(&event)){
			if(event.type == SDL_QUIT){
				game_exec = 0;
			}
		}
		getPAD();
		if(game_exec == 1 && (trgs & PAD_BUTTON9)){
			game_exec = 0;
		}
		if(!pause && game_exec == 2 && (trgs & PAD_BUTTON9)){
			game_exec--;
			g_step = GSTEP_QUIT;
		}
		nowTick = SDL_GetTicks();
		frame = (nowTick - prvTickCount) / interval;
		if(frame <= 0){
			frame = 1;
			SDL_Delay(prvTickCount + interval - nowTick);
			if(accframe){
			  prvTickCount = SDL_GetTicks();
			}else{
			  prvTickCount += interval;
			}
		}else if(frame > maxSkipFrame){
			frame = maxSkipFrame;
			prvTickCount = nowTick;
		} else {
			prvTickCount += frame * interval;
		}

		if(pause_flag == 1 && (trgs & PAD_BUTTON3)){
			if(!pause){
				pause = 1;
				debug{
				}else{
					pauseSNDmusic(-1);
					pauseSNDse(-1);
				}
			}else{
				pause = 0;
				debug{
				}else{
					pauseSNDmusic(-1);
					pauseSNDse(-1);
				}
			}
		}

		debug{
			if(pause && (reps & PAD_BUTTON8)){
				frame = 1;
				skip = 1;
			}else{
				skip = 0;
			}
		}

		for(i = 0; i < frame; i++){
			execTSK();
			if(!pause || skip){
				fadeSNDmusicCtrl();
				loopSNDmusicCtrl();
				collision();
				turn++;
			}
			trgs = 0;
			reps = 0;
		}

		clearSDL();
		drawTSK();
		flipSDL();
	}

	releaseBulletcommandParser();

	clrTSKall();
	sysinfoEXIT();
	closeSND();
	closePAD();
	closeVIDEO();
	closeSDL();

	return	1;
}

void collision()
{
	int	prev;

	ship_level = 0.0f;

	if(TskBuf[ship_id].tskid != 0 && TskBuf[ship_id].fp_int) collision_sub2(ship_id, GROUP_02);
	if(TskBuf[ship_id].tskid != 0 && TskBuf[ship_id].fp_int) collision_sub3(ship_id, GROUP_06);
	for(int i = TskIndex[GROUP_04]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			collision_sub1(i, GROUP_02);
		}
	}
}

void collision_sub1(int id, int group)
{
	int	coll_flag = 0;
	int	prev;
	int	ssx,ssy;
	int	sex,sey;
	int	dsx,dsy;
	int	dex,dey;

	ssx = cast(int)(TskBuf[id].px - TskBuf[id].cx);
	ssy = cast(int)(TskBuf[id].py - TskBuf[id].cy);
	sex = cast(int)(TskBuf[id].px + TskBuf[id].cx);
	sey = cast(int)(TskBuf[id].py + TskBuf[id].cy);

	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			dsx = cast(int)(TskBuf[i].px - TskBuf[i].cx);
			dsy = cast(int)(TskBuf[i].py - TskBuf[i].cy);
			dex = cast(int)(TskBuf[i].px + TskBuf[i].cx);
			dey = cast(int)(TskBuf[i].py + TskBuf[i].cy);
			coll_flag = ((ssx - dex) & (dsx - sex) & (ssy - dey) & (dsy - sey)) >> 31;
			if(coll_flag){
				TskBuf[i].trg_id = id;
				TskBuf[i].fp_int(i);
				TskBuf[id].trg_id = i;
				TskBuf[id].fp_int(id);
				return;
			}
		}
	}
}

void collision_sub2(int id, int group)
{
	int	coll_flag = 0;
	int	prev;
	int	ssx,ssy;
	int	sex,sey;
	int	dsx,dsy;
	int	dex,dey;

	ssx = cast(int)(TskBuf[id].px - TskBuf[id].cx);
	ssy = cast(int)(TskBuf[id].py - TskBuf[id].cy);
	sex = cast(int)(TskBuf[id].px + TskBuf[id].cx);
	sey = cast(int)(TskBuf[id].py + TskBuf[id].cy);

	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			dsx = cast(int)(TskBuf[i].px - TskBuf[i].cx);
			dsy = cast(int)(TskBuf[i].py - TskBuf[i].cy);
			dex = cast(int)(TskBuf[i].px + TskBuf[i].cx);
			dey = cast(int)(TskBuf[i].py + TskBuf[i].cy);
			coll_flag = ((ssx - dex) & (dsx - sex) & (ssy - dey) & (dsy - sey)) >> 31;
			if(coll_flag){
				TskBuf[i].trg_id = id;
				TskBuf[i].fp_int(i);
				TskBuf[id].trg_id = i;
				TskBuf[id].fp_int(id);
				if(!(TskBuf[i].tskid & TSKID_LOCK)) return;
			}
		}
	}
}

void collision_sub3(int id, int group)
{
	int	coll_flag = 0;
	int	prev;
	int	ssx,ssy;
	int	sex,sey;
	int	dsx,dsy;
	int	dex,dey;

	ssx = cast(int)(TskBuf[id].px - TskBuf[id].cx);
	ssy = cast(int)(TskBuf[id].py - TskBuf[id].cy);
	sex = cast(int)(TskBuf[id].px + TskBuf[id].cx);
	sey = cast(int)(TskBuf[id].py + TskBuf[id].cy);

	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].fp_int){
			dsx = cast(int)(TskBuf[i].px - TskBuf[i].cx);
			dsy = cast(int)(TskBuf[i].py - TskBuf[i].cy);
			dex = cast(int)(TskBuf[i].px + TskBuf[i].cx);
			dey = cast(int)(TskBuf[i].py + TskBuf[i].cy);
			coll_flag = ((ssx - dex) & (dsx - sex) & (ssy - dey) & (dsy - sey)) >> 31;
			if(coll_flag){
				TskBuf[id].trg_id = i;
				TskBuf[id].fp_int(id);
				return;
			}
		}
	}
}

uint Rand()
{
	uint ret = rand();

	debug{
		//writefln("rand %d", ret);
	}

	return ret;
}

void RandSeed(int seed)
{
	rand_seed(seed, 0);
}
