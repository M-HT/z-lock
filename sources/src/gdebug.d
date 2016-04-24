/*
	D-System 'DEBUG'

		'debug.d'

	2004/09/20 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.string;
private	import	std.conv;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_snd;
private	import	util_pad;
private	import	util_ascii;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	stg;
private	import	ship;
private	import	effect;
private	import	enemy;

private	import	bg;

private	char[]	str_buf;

void TSKdebug(int id)
{
	{
		switch(TskBuf[id].step){
			case	0:
				debug{
					TskBuf[id].fp_draw = &TSKdebugDraw;
				}
				TskBuf[id].step++;
				break;
			case	1:
				debug{
					if(pads & PAD_BUTTON7){
						if(reps & PAD_BUTTON4) scr_zoom[Z] += 1.00f;
						if(reps & PAD_BUTTON5) scr_zoom[Z] -= 1.00f;
						if(reps & PAD_BUTTON6) scr_zoom[Z]  = 0.0f;
					}else if(pads & PAD_BUTTON8){
						if(trgs & PAD_BUTTON6) g_step = GSTEP_QUIT;
					}else{
						if(trgs & PAD_BUTTON4) EnemyVanish();
						if(trgs & PAD_BUTTON5) EbulletVanish();
					}
				}
				break;
			default:
				clrTSK(id);
				break;
		}
	}
}

void TSKdebugDraw(int id)
{
	int	tmp;
	int	px = -(SCREEN_X / 2) + 8;
	int	py = +(SCREEN_Y / 2) - 8 - 12 * 0;

	glBegin(GL_QUADS);
	glColor3f(1.0f,1.0f,1.0f);

	str_buf  = "TASK ".dup;
	str_buf ~= to!string(TskCnt);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "RANK ".dup;
	tmp = cast(int)(getRank() * 1000.0f);
	str_buf ~= to!string(tmp / 1000);
	str_buf ~= ".";
	if((tmp % 1000) < 100) str_buf ~= "0";
	if((tmp % 1000) < 10)  str_buf ~= "0";
	str_buf ~= to!string(tmp % 1000);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "ZOOM ".dup;
	tmp = cast(int)(scr_zoom[Z] * 100);
	if(tmp < 0 && !(tmp / 100)) str_buf ~= "-";
	str_buf ~= to!string(tmp/100);
	str_buf ~= ".";
	if(tmp < 0) tmp = -tmp;
	str_buf ~= to!string(tmp%100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "LEVEL   ".dup;
	tmp = cast(int)(ship_level * 1000.0f);
	str_buf ~= to!string(tmp / 1000);
	str_buf ~= ".";
	if((tmp % 1000) < 100) str_buf ~= "0";
	if((tmp % 1000) < 10)  str_buf ~= "0";
	str_buf ~= to!string(tmp % 1000);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "SPECIAL ".dup;
	str_buf ~= to!string(ship_spgauge);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "SHIP X  ".dup;
	tmp = cast(int)(ship_px * 100);
	if(tmp < 0 && !(tmp / 100)) str_buf ~= "-";
	str_buf ~= to!string(tmp/100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "     Y  ".dup;
	tmp = cast(int)(ship_py * 100);
	if(tmp < 0 && !(tmp / 100)) str_buf ~= "-";
	str_buf ~= to!string(tmp/100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	str_buf  = "SCREEN X ".dup;
	tmp = cast(int)(getPointX(ship_px, -(BASE_Z + cam_scr) / 2) * SCREEN_X);
	str_buf ~= to!string(tmp);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "       Y ".dup;
	tmp = cast(int)(getPointY(ship_py, -(BASE_Z + cam_scr) / 2) * SCREEN_Y);
	str_buf ~= to!string(tmp);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "EXT ".dup;
	str_buf ~= to!string(next_extend);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "ENE ".dup;
	str_buf ~= to!string(enemy_cnt);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	str_buf  = "TOTAL ".dup;
	str_buf ~= to!string(cast(int)total_enemy);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "DEST  ".dup;
	str_buf ~= to!string(cast(int)dest_enemy);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	str_buf  = "S-LEV ".dup;
	str_buf ~= to!string(stg_level);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "E-LEV ".dup;
	tmp = cast(int)(level_enemy * 100.0f);
	str_buf ~= to!string(tmp / 100);
	str_buf ~= ".";
	if((tmp % 100) < 10) str_buf ~= "0";
	str_buf ~= to!string(tmp % 100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "COST  ".dup;
	str_buf ~= to!string(game_cost);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	glEnd();
}
