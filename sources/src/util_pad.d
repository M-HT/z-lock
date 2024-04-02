/*
	D-System 'PAD UTILITY'

		'util_pad.d'

	2003/12/02 jumpei isshiki
*/

private	import	bindbc.sdl;
private	import	std.conv;

version(PANDORA) version = PANDORA_OR_PYRA;
version(PYRA) version = PANDORA_OR_PYRA;

enum{
	PAD_UP = 0x01,
	PAD_DOWN = 0x02,
	PAD_LEFT = 0x04,
	PAD_RIGHT = 0x08,
	PAD_BUTTON1 = 0x10,
	PAD_BUTTON2 = 0x20,
	PAD_BUTTON3 = 0x40,
	PAD_BUTTON4 = 0x80,
	PAD_BUTTON5 = 0x100,
	PAD_BUTTON6 = 0x200,
	PAD_BUTTON7 = 0x400,
	PAD_BUTTON8 = 0x800,
	PAD_BUTTON9 = 0x1000,

	PAD_DIR = PAD_UP | PAD_DOWN | PAD_LEFT | PAD_RIGHT,
	PAD_BUTTON = PAD_BUTTON1 | PAD_BUTTON2 | PAD_BUTTON3 | PAD_BUTTON4 | PAD_BUTTON5 | PAD_BUTTON6 | PAD_BUTTON7 | PAD_BUTTON8 | PAD_BUTTON9,
	PAD_ALL = PAD_DIR | PAD_BUTTON,

	JOYSTICK_AXIS = 16384,

	REP_MIN = 2,
	REP_MAX = 30,
}

int	pads;
int	trgs;
int	reps;

SDL_Joystick*	joys;
ubyte*			keys;

private	int	pads_old;
private	int	rep_cnt;

int initPAD()
{
	if(SDL_InitSubSystem(SDL_INIT_JOYSTICK) < 0){
		return	0;
    }

	joys = null;
	version (PANDORA) {
		foreach (i; 0..SDL_NumJoysticks()) {
			if (to!string(SDL_JoystickNameForIndex(i)) == "nub0") {
				joys = SDL_JoystickOpen(i);
				break;
			}
		}
	} else {
		if(SDL_NumJoysticks() > 0){
			joys = SDL_JoystickOpen(0);
		}
	}

	if (joys){
		SDL_JoystickEventState(SDL_ENABLE);
	}

	pads = 0;
	trgs = 0;
	reps = 0;

	rep_cnt = 0;

	return	1;
}


void closePAD()
{
	if(joys){
		SDL_JoystickClose(joys);
		joys = null;
	}
}

int getPAD()
{
	int x = 0, y = 0;
	int pad = 0;

	keys = SDL_GetKeyboardState(null);

	if(joys){
		x = SDL_JoystickGetAxis(joys, 0);
		y = SDL_JoystickGetAxis(joys, 1);
	}
	if(keys[SDL_SCANCODE_RIGHT] == SDL_PRESSED || keys[SDL_SCANCODE_KP_6] == SDL_PRESSED || keys[SDL_SCANCODE_D] == SDL_PRESSED || x > JOYSTICK_AXIS){
		pad |= PAD_RIGHT;
	}
	if(keys[SDL_SCANCODE_LEFT] == SDL_PRESSED || keys[SDL_SCANCODE_KP_4] == SDL_PRESSED || keys[SDL_SCANCODE_A] == SDL_PRESSED || x < -JOYSTICK_AXIS){
		pad |= PAD_LEFT;
	}
	if(keys[SDL_SCANCODE_DOWN] == SDL_PRESSED || keys[SDL_SCANCODE_KP_2] == SDL_PRESSED || keys[SDL_SCANCODE_S] == SDL_PRESSED || y > JOYSTICK_AXIS){
		pad |= PAD_DOWN;
	}
	if(keys[SDL_SCANCODE_UP] == SDL_PRESSED || keys[SDL_SCANCODE_KP_8] == SDL_PRESSED || keys[SDL_SCANCODE_W] == SDL_PRESSED || y < -JOYSTICK_AXIS){
		pad |= PAD_UP;
	}

	int	btn1 = 0, btn2 = 0, btn3 = 0, btn4 = 0, btn5 = 0, btn6 = 0, btn7 = 0, btn8 = 0, btn9 = 0;

	version(PYRA){
	}else{
		if(joys){
			btn1 = SDL_JoystickGetButton(joys, 0);
			btn2 = SDL_JoystickGetButton(joys, 1);
			btn3 = SDL_JoystickGetButton(joys, 2);
			debug{
				btn4 = SDL_JoystickGetButton(joys, 3);
				btn5 = SDL_JoystickGetButton(joys, 4);
				btn6 = SDL_JoystickGetButton(joys, 5);
				btn7 = SDL_JoystickGetButton(joys, 6);
				btn8 = SDL_JoystickGetButton(joys, 7);
			}
		}
	}
	version(PANDORA_OR_PYRA) {
		if(keys[SDL_SCANCODE_HOME] == SDL_PRESSED || keys[SDL_SCANCODE_PAGEUP] == SDL_PRESSED || btn1){
			pad |= PAD_BUTTON1;
		}
		if(keys[SDL_SCANCODE_PAGEDOWN] == SDL_PRESSED || keys[SDL_SCANCODE_END] == SDL_PRESSED || btn2){
			pad |= PAD_BUTTON2;
		}
	} else {
		if(keys[SDL_SCANCODE_Z] == SDL_PRESSED || keys[SDL_SCANCODE_SLASH] == SDL_PRESSED || btn1){
			pad |= PAD_BUTTON1;
		}
		if(keys[SDL_SCANCODE_X] == SDL_PRESSED || keys[SDL_SCANCODE_BACKSLASH] == SDL_PRESSED || btn2){
			pad |= PAD_BUTTON2;
		}
	}
	if(keys[SDLK_p] == SDL_PRESSED || btn3){
		pad |= PAD_BUTTON3;
	}
	debug{
		if(keys[SDL_SCANCODE_C] == SDL_PRESSED || btn4){
			pad |= PAD_BUTTON4;
		}
		if(keys[SDL_SCANCODE_V] == SDL_PRESSED || btn5){
			pad |= PAD_BUTTON5;
		}
		if(keys[SDL_SCANCODE_B] == SDL_PRESSED || btn6){
			pad |= PAD_BUTTON6;
		}
		if(keys[SDL_SCANCODE_F] == SDL_PRESSED || btn7){
			pad |= PAD_BUTTON7;
		}
		if(keys[SDL_SCANCODE_G] == SDL_PRESSED || btn8){
			pad |= PAD_BUTTON8;
		}
	}
	if(keys[SDL_SCANCODE_ESCAPE] == SDL_PRESSED || btn9){
		pad |= PAD_BUTTON9;
	}

	pads_old = pads;
	pads = pad;
	trgs = pads & ~pads_old;

	reps = 0;
	if(pads){
		if(!trgs && !rep_cnt){
			reps = pads;
			rep_cnt = REP_MIN;
		}else if(!trgs && rep_cnt){
			rep_cnt--;
		}else if(trgs){
			rep_cnt = REP_MAX;
			reps = trgs;
		}
	}else{
		rep_cnt = 0;
	}

	return	pad;
}
