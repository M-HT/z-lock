/*
	D-System 'DEBUG'

		'debug.d'

	2004/09/20 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.string;
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

	str_buf  = "TASK ";
	str_buf ~= toString(TskCnt);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "RANK ";
	tmp = cast(int)(getRank() * 1000.0f);
	str_buf ~= toString(tmp / 1000);
	str_buf ~= ".";
	if((tmp % 1000) < 100) str_buf ~= "0";
	if((tmp % 1000) < 10)  str_buf ~= "0";
	str_buf ~= toString(tmp % 1000);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "ZOOM ";
	tmp = cast(int)(scr_zoom[Z] * 100);
	if(tmp < 0 && !(tmp / 100)) str_buf ~= "-";
	str_buf ~= toString(tmp/100);
	str_buf ~= ".";
	if(tmp < 0) tmp = -tmp;
	str_buf ~= toString(tmp%100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "LEVEL   ";
	tmp = cast(int)(ship_level * 1000.0f);
	str_buf ~= toString(tmp / 1000);
	str_buf ~= ".";
	if((tmp % 1000) < 100) str_buf ~= "0";
	if((tmp % 1000) < 10)  str_buf ~= "0";
	str_buf ~= toString(tmp % 1000);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "SPECIAL ";
	str_buf ~= toString(ship_spgauge);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "SHIP X  ";
	tmp = cast(int)(ship_px * 100);
	if(tmp < 0 && !(tmp / 100)) str_buf ~= "-";
	str_buf ~= toString(tmp/100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "     Y  ";
	tmp = cast(int)(ship_py * 100);
	if(tmp < 0 && !(tmp / 100)) str_buf ~= "-";
	str_buf ~= toString(tmp/100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	str_buf  = "SCREEN X ";
	tmp = cast(int)(getPointX(ship_px, -(BASE_Z + cam_scr) / 2) * SCREEN_X);
	str_buf ~= toString(tmp);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "       Y ";
	tmp = cast(int)(getPointY(ship_py, -(BASE_Z + cam_scr) / 2) * SCREEN_Y);
	str_buf ~= toString(tmp);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "EXT ";
	str_buf ~= toString(next_extend);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "ENE ";
	str_buf ~= toString(enemy_cnt);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	str_buf  = "TOTAL ";
	str_buf ~= toString(cast(int)total_enemy);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "DEST  ";
	str_buf ~= toString(cast(int)dest_enemy);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	str_buf  = "S-LEV ";
	str_buf ~= toString(stg_level);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "E-LEV ";
	tmp = cast(int)(level_enemy * 100.0f);
	str_buf ~= toString(tmp / 100);
	str_buf ~= ".";
	if((tmp % 100) < 10) str_buf ~= "0";
	str_buf ~= toString(tmp % 100);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;
	str_buf  = "COST  ";
	str_buf ~= toString(game_cost);
	drawASCII(str_buf, px, py, 0.50f);
	py -= 12;

	glEnd();
}
