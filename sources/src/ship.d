/*
	Z-LOCK 'SHIP CTRL'

		'ship.d'

	2003/12/01 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.string;
private	import	std.math;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	util_ascii;
private	import	bulletml;
private	import	bulletcommand;
private	import	main;
private	import	init;
private	import	define;
private	import	task;
private	import	sysinfo;
private	import	gctrl;
private	import	effect;
private	import	bg;
private	import	stg;
private	import	enemy;

const float START_X =   +0.0f;
const float START_Y = +200.0f;

const int PAD_SHOT = PAD_BUTTON1;
const int PAD_SPECIAL = PAD_BUTTON2;

const int SHIP_TYPE01 = 0;	/* normal ship */
const int SHIP_TYPE02 = 1;	/* concept ship */
const int SHIP_TYPE03 = 2;	/* original ship */

const int MAX_SHIP = 4;
const int EXTEND_SCORE = 1000000;
const int FIRST_EXTEND = 500000;
const int SHIP_SPECIAL_MAX = 0x10000;
const int SHIP_SPECIAL_ADD = 0x100;
const int SHIP_SPECIAL_SUB = 0x200;
const float SHIP_LEVEL_MAX = 8.0f;
const float SHIP_SPECIAL_NONE = -1.0f;

int ship_id;
int ship_type;
int ship_spgauge;
int ship_spheat;
int next_extend;
float ship_px;
float ship_py;
float ship_level;
float ship_level_bak;
float ship_special;

private	const float SHIP_SRATE = 1.0f / SQRT2;
private	const float SHIP_SX1 = 8.0f;
private	const float SHIP_SY1 = 8.0f;
private	const float SHIP_SX2 = (SHIP_SX1 * SHIP_SRATE);
private	const float SHIP_SY2 = (SHIP_SY1 * SHIP_SRATE);
private	const float ACC_RATE = 30.0f;

private	const float SHIP_AREAMAX_X = (384.0f - 100.0f);
private	const float SHIP_AREAMAX_Y = (480.0f - 124.0f);
private	const float SSHOT_AREAMAX_X = (384.0f - 64.0f);
private	const float SSHOT_AREAMAX_Y = (480.0f - 64.0f);
private	const float SLASER_AREAMAX_X = (384.0f - 32.0f);
private	const float SLASER_AREAMAX_Y = (640.0f - 32.0f);
private	const float SLASER_SPDMAX = (12.0f);

private	int ship_pad = 0;
private	int ship_trg = 0;
private	int ship_dir = 0;

private	float[]	ship_poly = [
								 -4.0f, -4.0f,
								 +0.0f, -8.0f,
								 +4.0f, -4.0f,
								 +0.0f, +8.0f,

								 -2.0f, -2.0f,
								 -6.0f, -2.0f,
								-10.0f,-10.0f,
								 -2.0f, -6.0f,

								 +2.0f, -2.0f,
								 +6.0f, -2.0f,
								+10.0f,-10.0f,
								 +2.0f, -6.0f,
							];


private	float[]	sshot00_body = [
								 -2.0f,+10.0f,
								 -2.0f,-10.0f,
								 +2.0f,-10.0f,
								 +2.0f,+10.0f,
							];

private	float[]	sshot01_body = [
								 -2.0f,+10.0f,
								 -3.0f,-10.0f,
								 +3.0f,-10.0f,
								 +2.0f,+10.0f,
							];

private	float[]	sshot02_body = [
								 -2.0f,+12.0f,
								 -3.0f,-12.0f,
								 +3.0f,-12.0f,
								 +2.0f,+12.0f,
							];

private	float[]	sshot03_body = [
								 -2.0f,+14.0f,
								 -3.0f,-14.0f,
								 +3.0f,-14.0f,
								 +2.0f,+14.0f,
							];

private	float[]	sshot04_body = [
								 -2.0f,+14.0f,
								 -4.0f,-14.0f,
								 +4.0f,-14.0f,
								 +2.0f,+14.0f,
							];

private	float[]	sshot05_body = [
								 -2.0f,+16.0f,
								 -4.0f,-16.0f,
								 +4.0f,-16.0f,
								 +2.0f,+16.0f,
							];

private	float[]	sshot06_body = [
								 -3.0f,+16.0f,
								 -5.0f,-16.0f,
								 +5.0f,-16.0f,
								 +3.0f,+16.0f,
							];

private	float[]	sshot07_body = [
								 -3.0f,+20.0f,
								 -6.0f,-20.0f,
								 +6.0f,-20.0f,
								 +3.0f,+20.0f,
							];

private	float[]	sshot08_body = [
								 -4.0f,+24.0f,
								 -8.0f,-24.0f,
								 +8.0f,-24.0f,
								 +4.0f,+24.0f,
							];

private	float[][]	ship_move = [
									[     +0.0f,    +0.0f ],	/*  0 PAD_NONE */
									[     +0.0f,-SHIP_SY1 ],	/*  1 PAD_UP */
									[     +0.0f,+SHIP_SY1 ],	/*  2 PAD_DOWN */
									[     +0.0f,    +0.0f ],	/*  3 PAD_NONE */
									[ +SHIP_SX1,    +0.0f ],	/*  4 PAD_LEFT */
									[ +SHIP_SX2,-SHIP_SY2 ],	/*  5 PAD_UP+PAD_LEFT */
									[ +SHIP_SX2,+SHIP_SY2 ],	/*  6 PAD_DOWN+PAD_LEFT */
									[     +0.0f,    +0.0f ],	/*  7 NONE */
									[ -SHIP_SX1,    +0.0f ],	/*  8 PAD_RIGHT */
									[ -SHIP_SX2,-SHIP_SY2 ],	/*  9 PAD_UP+PAD_RIGHT */
									[ -SHIP_SX2,+SHIP_SY2 ],	/* 10 PAD_DOWN+PAD_RIGHT */
									[     +0.0f,    +0.0f ],	/* 11 NONE */
									[     +0.0f,    +0.0f ],	/* 12 NONE */
									[     +0.0f,    +0.0f ],	/* 13 NONE */
									[     +0.0f,    +0.0f ],	/* 14 NONE */
									[     +0.0f,    +0.0f ],	/* 15 NONE */
								];


void TSKship(int id)
{
	BulletCommand cmd = TskBuf[id].bullet_command;

	if(stg_ctrl == STG_GAMEOVER && TskBuf[id].step != 255){
		TskBuf[id].step = 255;
	}

	/* replay */
	if(replay_flag == 1){
		if(replay_cnt >= replay.length){
			int ret = replay.length;
			ret *= 2;
			replay.length = ret;
		}
		ship_pad = (pads & (PAD_DIR|PAD_SHOT|PAD_SPECIAL));
		ship_trg = (trgs & (PAD_DIR|PAD_SHOT|PAD_SPECIAL));
		replay[replay_cnt+0] = ship_pad;
		replay[replay_cnt+1] = ship_trg;
	}else if(replay_flag == 2){
		ship_pad = replay_data[replay_cnt+0];
		ship_trg = replay_data[replay_cnt+1];
	}else{
		ship_pad = (pads & (PAD_DIR|PAD_SHOT|PAD_SPECIAL));
		ship_trg = (trgs & (PAD_DIR|PAD_SHOT|PAD_SPECIAL));
	}

	replay_cnt += 2;

	switch(TskBuf[id].step){
		case	0:
			ship_id = id;
			ship_level = 0.0f;
			ship_level_bak = -1.0f;
			ship_special = SHIP_SPECIAL_NONE;
			ship_spheat = 0;
			if(ship_type == SHIP_TYPE01) ship_spgauge = SHIP_SPECIAL_MAX;
			if(ship_type == SHIP_TYPE02) ship_spgauge = 0;
			if(ship_type == SHIP_TYPE03) ship_spgauge = SHIP_SPECIAL_MAX;
			next_extend = FIRST_EXTEND;
			TskBuf[id].tskid |= TSKID_SHIP+TSKID_MUTEKI;
			TskBuf[id].px = START_X;
			TskBuf[id].py = START_Y;
			TskBuf[id].pz = 0.0f;
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			TskBuf[id].tid = id;
			TskBuf[id].fp_draw = &TSKshipDraw;
			TskBuf[id].fp_exit = &TSKshipExit;
			TskBuf[id].simple = &TSKsshotSimple;
			TskBuf[id].active = &TSKsshotActive;
			TskBuf[id].target = &getShipShotDirection;
			TskBuf[id].cx = 1.0f;
			TskBuf[id].cy = 1.0f;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].roll = 0.0f;
			TskBuf[id].alpha = 0.0f;
			{
				float[XYZ] tpos;
				float* poly_data;
				poly_data = &ship_poly[0];
				TskBuf[id].body_org.length = ship_poly.length;
				for(int i = 0; i < TskBuf[id].body_org.length; i++){
					TskBuf[id].body_org[i] = poly_data[i];
				}
				TskBuf[id].body_ang.length = TskBuf[id].body_org.length / 2;
				for(int i = 0; i < TskBuf[id].body_ang.length; i++){
					tpos[X] = TskBuf[id].body_org[i*2+0];
					tpos[Y] = TskBuf[id].body_org[i*2+1];
					TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Z] = 0.0f;
					tpos[X] = fabs(tpos[X]);
					tpos[Y] = fabs(tpos[Y]);
					TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
				}
			}
			TskBuf[id].wait = 120;
			TskBuf[id].cnt = TskBuf[id].wait;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			TskBuf[id].step++;
			break;
		case	1:
			if(!TskBuf[id].wait){
				TskBuf[id].fp_int = &TSKshipInt;
				TskBuf[id].tskid &= ~TSKID_MUTEKI;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}else{
				TskBuf[id].wait--;
				if(TskBuf[id].cnt) TskBuf[id].alpha += 1.0f / TskBuf[id].cnt;
			}
		case	2:
			if(g_step == GSTEP_CLEAR){
				TskBuf[id].tskid |= TSKID_MUTEKI;
				TskBuf[id].step = 254;
				break;
			}
			/* move */
			ship_dir = ship_pad & PAD_DIR;
			TskBuf[id].vx = ship_move[ship_dir][0];
			TskBuf[id].vy = ship_move[ship_dir][1];
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			if(TskBuf[id].px < -SHIP_AREAMAX_X){
				TskBuf[id].px = -SHIP_AREAMAX_X;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].px > +SHIP_AREAMAX_X){
				TskBuf[id].px = +SHIP_AREAMAX_X;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].py < -SHIP_AREAMAX_Y){
				TskBuf[id].py = -SHIP_AREAMAX_Y;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			if(TskBuf[id].py > +SHIP_AREAMAX_Y){
				TskBuf[id].py = +SHIP_AREAMAX_Y;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			TskBuf[id].tx = TskBuf[id].px + sin(TskBuf[id].rot) * 1.0f;
			TskBuf[id].ty = TskBuf[id].py + cos(TskBuf[id].rot) * 1.0f;
			/* special */
			if(ship_type == SHIP_TYPE01){
				if(ship_special == SHIP_SPECIAL_NONE){
					if(ship_spgauge != SHIP_SPECIAL_MAX){
						ship_spgauge += SHIP_SPECIAL_ADD;
						if(ship_spgauge == SHIP_SPECIAL_MAX){
							playSNDse(SND_VOICE_CHARGE);
						}
					}else{
						if((ship_pad & PAD_SPECIAL)){
							playSNDse(SND_SE_SPSHOT);
							ship_special = ship_level;
						}
					}
				}else{
					if(ship_spgauge > 0){
						ship_spgauge -= SHIP_SPECIAL_SUB;
						if(ship_special < ship_level) ship_special = ship_level;
						ship_level = ship_special;
					}else{
						ship_special = SHIP_SPECIAL_NONE;
					}
				}
			}
			if(ship_type == SHIP_TYPE02){
				if(!ship_spheat && (ship_trg & PAD_SHOT)){
					playSNDse(SND_SE_SPSHOT);
				}
				if(!ship_spheat && (ship_pad & PAD_SHOT)){
					if(ship_spgauge < SHIP_SPECIAL_MAX){
						ship_spgauge += SHIP_SPECIAL_ADD;
						if(ship_special < ship_level) ship_special = ship_level;
					}else{
						playSNDse(SND_VOICE_OVER);
						ship_special = SHIP_SPECIAL_NONE;
						ship_spgauge = SHIP_SPECIAL_MAX;
						ship_spheat = 1;
					}
				}else{
					ship_special = SHIP_SPECIAL_NONE;
					if(ship_spgauge > 0){
						ship_spgauge -= SHIP_SPECIAL_SUB / 2;
					}else{
						if(ship_spheat){
							playSNDse(SND_VOICE_CHARGE);
						}
						ship_spheat = 0;
					}
				}
			}
			if(ship_type == SHIP_TYPE03){
				if(ship_special == SHIP_SPECIAL_NONE){
					if(ship_spgauge != SHIP_SPECIAL_MAX){
						ship_spgauge += SHIP_SPECIAL_ADD;
						if(ship_spgauge == SHIP_SPECIAL_MAX){
							playSNDse(SND_VOICE_CHARGE);
						}
					}else{
						if((ship_pad & PAD_SPECIAL)){
							playSNDse(SND_SE_SPSHOT);
							ship_special = ship_level;
						}
					}
				}else{
					if(ship_spgauge > 0){
						ship_spgauge -= cast(int)(cast(float)SHIP_SPECIAL_SUB * (2.0f / 3.0f));
						if(ship_special < ship_level) ship_special = ship_level;
						ship_level = ship_special;
					}else{
						ship_special = SHIP_SPECIAL_NONE;
						ship_spgauge = 0;
					}
				}
			}
			/* shot */
			int flag = 0;
			if(ship_type == SHIP_TYPE01 && (ship_pad & PAD_SHOT)) flag = 1;
			if(ship_type == SHIP_TYPE02 && ship_level != 0.0f && ship_special != SHIP_SPECIAL_NONE) flag = 1;
			if(ship_type == SHIP_TYPE03 && (ship_pad & PAD_SHOT) && ship_level != 0.0f) flag = 1;
			if(flag){
				if(!cmd.isEnd() && ship_level == ship_level_bak){
					 cmd.run();
				}else{
					switch(cast(int)ship_level){
						case	0: cmd.set(id, BULLET_SHIP00); break;
						case	1: cmd.set(id, BULLET_SHIP01); break;
						case	2: cmd.set(id, BULLET_SHIP02); break;
						case	3: cmd.set(id, BULLET_SHIP03); break;
						case	4: cmd.set(id, BULLET_SHIP04); break;
						case	5: cmd.set(id, BULLET_SHIP05); break;
						case	6: cmd.set(id, BULLET_SHIP06); break;
						case	7: cmd.set(id, BULLET_SHIP07); break;
						default:   cmd.set(id, BULLET_SHIP08); break;
					}
				}
			}else{
				cmd.vanish();
			}
			ship_level_bak = ship_level;
			TskBuf[id].roll += PI / 5.5f;
			break;
		case	3:
			TskBuf[id].wait--;
			if(!TskBuf[id].wait){
				TskBuf[id].px   = START_X;
				TskBuf[id].py   = START_Y;
				TskBuf[id].wait = 120;
				TskBuf[id].cnt = TskBuf[id].wait;
				TskBuf[id].step = 1;
			}
			TskBuf[id].roll += PI / 5.5f;
			break;

		case	6:
			writefln("undefined step for ship is 6!!!!!!");
			assert(0);

		case	254:
			if(!TskBuf[id].wait){
				TskBuf[id].step++;
			}else{
				TskBuf[id].wait--;
				if(TskBuf[id].cnt) TskBuf[id].alpha += 1.0f / TskBuf[id].cnt;
			}
			break;
		case	255:
			break;


		default:
			if(cmd){
				cmd.vanish();
				delete cmd;
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;

	}
	ctrlExtend();
}

void TSKshipInt(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	if(TskBuf[TskBuf[id].trg_id].tskid & TSKID_LOCK){
		ship_level += TskBuf[TskBuf[id].trg_id].level_add;
		ship_level *= 10000.0f;
		ship_level  = ceil(ship_level);
		ship_level /= 10000.0f;
		if(ship_level > SHIP_LEVEL_MAX) ship_level = SHIP_LEVEL_MAX;
		effSetParticle00(id, 0.0f, 0.0f, 1);
		return;
	}

	if(TskBuf[id].tskid & TSKID_MUTEKI) return;

	if(cmd.isEnd()) cmd.vanish();

	playSNDse(SND_SE_SDEST);

	TskBuf[id].alpha = 0.0f;
	TskBuf[ship_id].trg_id = -1;
	TskBuf[id].tskid |= TSKID_MUTEKI;
	ship_special = SHIP_SPECIAL_NONE;

	effSetBrokenBody(id, TskBuf[id].body_org,  0, 4,+0.0f,+0.0f,+3.0f,+3.0f);
	effSetBrokenBody(id, TskBuf[id].body_org,  4, 4,+0.0f,+0.0f,+3.0f,+3.0f);
	effSetBrokenBody(id, TskBuf[id].body_org,  8, 4,+0.0f,+0.0f,+3.0f,+3.0f);
	effSetBrokenLine(id, TskBuf[id].body_org,  0, 4,+0.0f,+0.0f,+3.0f,+3.0f);
	effSetBrokenLine(id, TskBuf[id].body_org,  4, 4,+0.0f,+0.0f,+3.0f,+3.0f);
	effSetBrokenLine(id, TskBuf[id].body_org,  8, 4,+0.0f,+0.0f,+3.0f,+3.0f);

	if(game_mode == GMODE_NORMAL || game_mode == GMODE_CONCEPT || game_mode == GMODE_ORIGINAL || game_mode == GMODE_HIDDEN){
		if(!left){
			TskBuf[id].fp_draw = null;
			stg_ctrl = STG_GAMEOVER;
			time_flag = 0;
			TskBuf[id].step = 255;
		}else{
			TskBuf[id].step = 3;
			TskBuf[id].wait = 60;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].roll = 0.0f;
			TskBuf[id].vx = +0.0f;
			TskBuf[id].vy = +0.0f;
			TskBuf[id].ax = +0.0f;
			TskBuf[id].ay = +0.0f;
			left--;
		}
	}else{
		TskBuf[id].step = 3;
		TskBuf[id].wait = 60;
		TskBuf[id].rot = 0.0f;
		TskBuf[id].roll = 0.0f;
		TskBuf[id].vx = +0.0f;
		TskBuf[id].vy = +0.0f;
		TskBuf[id].ax = +0.0f;
		TskBuf[id].ay = +0.0f;
	}
}

void TSKshipDraw(int id)
{
	void setVertex(int id, int i)
	{
		float[XYZ] pos;

		pos[X] = sin(TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], pos[Z]),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], pos[Z]),
				   pos[Z]);
	}

	if(TskBuf[id].step == 3) return;

	if(TskBuf[id].fp_int && !(TskBuf[id].tskid & TSKID_MUTEKI)){
		glColor3f(0.25f,0.25f,0.50f);
		glBegin(GL_POLYGON);
		for(int i = 0; i < 4; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_POLYGON);
		for(int i = 4; i < 8; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_POLYGON);
		for(int i = 8; i < 12; i++) setVertex(id, i);
		glEnd();
		glColor3f(1.0f,1.0f,1.0f);
		glBegin(GL_LINE_LOOP);
		for(int i = 0; i < 4; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_LINE_LOOP);
		for(int i = 4; i < 8; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_LINE_LOOP);
		for(int i = 8; i < 12; i++) setVertex(id, i);
		glEnd();
	}else{
		glColor4f(0.25f,0.25f,0.50f,TskBuf[id].alpha);
		glBegin(GL_POLYGON);
		for(int i = 0; i < 4; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_POLYGON);
		for(int i = 4; i < 8; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_POLYGON);
		for(int i = 8; i < 12; i++) setVertex(id, i);
		glEnd();
		glColor3f(1.0f,1.0f,1.0f);
		glBegin(GL_LINE_LOOP);
		for(int i = 0; i < 4; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_LINE_LOOP);
		for(int i = 4; i < 8; i++) setVertex(id, i);
		glEnd();
		glBegin(GL_LINE_LOOP);
		for(int i = 8; i < 12; i++) setVertex(id, i);
		glEnd();
	}
}

void TSKshipExit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}

void TSKsshotSimple(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].fp_int = &TSKsshotInt;
			TskBuf[id].fp_draw = &TSKsshotDraw;
			TskBuf[id].fp_exit = &TSKsshotExit;
			TskBuf[id].level = cast(int)ship_level;
			TSKsshotSetForm(id);
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].cnt = 5;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 5.0f;
			TskBuf[id].cnt--;
			if(!TskBuf[id].cnt){
				TskBuf[id].step++;
			}
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			if(TskBuf[id].px < -SSHOT_AREAMAX_X || TskBuf[id].px > +SSHOT_AREAMAX_X || TskBuf[id].py > +SSHOT_AREAMAX_Y || TskBuf[id].py < -SSHOT_AREAMAX_Y){
				TskBuf[id].step = -1;
			}
			break;
		case	2:
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			if(TskBuf[id].px < -SSHOT_AREAMAX_X || TskBuf[id].px > +SSHOT_AREAMAX_X || TskBuf[id].py > +SSHOT_AREAMAX_Y || TskBuf[id].py < -SSHOT_AREAMAX_Y){
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKsshotActive(int id)
{
	float[XY]	tpos;
	BulletCommand	cmd = TskBuf[id].bullet_command;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = &TSKsshotInt;
			TskBuf[id].fp_draw = &TSKsshotDraw;
			TskBuf[id].fp_exit = &TSKsshotExit;
			TskBuf[id].simple = &TSKsshotSimple;
			TskBuf[id].active = &TSKsshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].level = cast(int)ship_level;
			TSKsshotSetForm(id);
			TskBuf[id].alpha = 1.0f;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			cmd.set(id, TskBuf[id].bullet_state);
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].cnt = 5;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / 5.0f;
			TskBuf[id].cnt--;
			if(!TskBuf[id].cnt){
				TskBuf[id].step++;
			}
			TskBuf[id].bullet_velx = (sin(TskBuf[id].bullet_direction) * (+TskBuf[id].bullet_speed));
			TskBuf[id].bullet_vely = (cos(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			TskBuf[id].tx  = TskBuf[TskBuf[id].tid].px;
			TskBuf[id].ty  = TskBuf[TskBuf[id].tid].py;
			if(TskBuf[id].px < -SSHOT_AREAMAX_X || TskBuf[id].px > +SSHOT_AREAMAX_X || TskBuf[id].py > +SSHOT_AREAMAX_Y || TskBuf[id].py < -SSHOT_AREAMAX_Y){
				TskBuf[id].step = -1;
			}
			if(!cmd.isEnd()) cmd.run();
			break;
		case	2:
			TskBuf[id].bullet_velx = (sin(TskBuf[id].bullet_direction) * (+TskBuf[id].bullet_speed));
			TskBuf[id].bullet_vely = (cos(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			TskBuf[id].tx  = TskBuf[TskBuf[id].tid].px;
			TskBuf[id].ty  = TskBuf[TskBuf[id].tid].py;
			if(TskBuf[id].px < -SSHOT_AREAMAX_X || TskBuf[id].px > +SSHOT_AREAMAX_X || TskBuf[id].py > +SSHOT_AREAMAX_Y || TskBuf[id].py < -SSHOT_AREAMAX_Y){
				TskBuf[id].step = -1;
			}
			if(!cmd.isEnd()) cmd.run();
			break;

		default:
			if(cmd){
				cmd.vanish();
				delete cmd;
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;
	}
}

void TSKsshotInt(int id)
{
	if(TskBuf[TskBuf[id].trg_id].tskid & TSKID_LOCK){
		return;
	}

	TskBuf[id].step = -1;
}

void TSKsshotDraw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.125f,0.125f,0.125f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++){
		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(0.50f,0.50f,0.50f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++){
		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}

void TSKsshotExit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}

void TSKsshotSetForm(int id)
{
	float[XY] tpos;
	float[] tmp;

	switch(TskBuf[id].level){
		case	0:
			TskBuf[id].body_ang.length  = sshot00_body.length / 2;
			tmp = sshot00_body;
			TskBuf[id].cx = 2.0f;
			TskBuf[id].cy = 2.0f;
			TskBuf[id].energy = 1;
			break;
		case	1:
			TskBuf[id].body_ang.length  = sshot01_body.length / 2;
			tmp = sshot01_body;
			TskBuf[id].cx = 2.0f;
			TskBuf[id].cy = 3.0f;
			TskBuf[id].energy = 1;
			break;
		case	2:
			TskBuf[id].body_ang.length  = sshot02_body.length / 2;
			tmp = sshot02_body;
			TskBuf[id].cx = 2.0f;
			TskBuf[id].cy = 4.0f;
			TskBuf[id].energy = 2;
			break;
		case	3:
			TskBuf[id].body_ang.length  = sshot03_body.length / 2;
			tmp = sshot03_body;
			TskBuf[id].cx = 2.0f;
			TskBuf[id].cy = 5.0f;
			TskBuf[id].energy = 2;
			break;
		case	4:
			TskBuf[id].body_ang.length  = sshot04_body.length / 2;
			tmp = sshot04_body;
			TskBuf[id].cx = 2.0f;
			TskBuf[id].cy = 6.0f;
			TskBuf[id].energy = 3;
			break;
		case	5:
			TskBuf[id].body_ang.length  = sshot05_body.length / 2;
			tmp = sshot05_body;
			TskBuf[id].cx = 3.0f;
			TskBuf[id].cy = 6.0f;
			TskBuf[id].energy = 3;
			break;
		case	6:
			TskBuf[id].body_ang.length  = sshot06_body.length / 2;
			tmp = sshot06_body;
			TskBuf[id].cx = 4.0f;
			TskBuf[id].cy = 7.0f;
			TskBuf[id].energy = 4;
			break;
		case	7:
			TskBuf[id].body_ang.length  = sshot07_body.length / 2;
			tmp = sshot07_body;
			TskBuf[id].cx = 3.0f;
			TskBuf[id].cy = 8.0f;
			TskBuf[id].energy = 4;
			break;
		default:
			TskBuf[id].body_ang.length  = sshot08_body.length / 2;
			tmp = sshot08_body;
			TskBuf[id].cx = 3.0f;
			TskBuf[id].cy = 9.0f;
			TskBuf[id].energy = 5;
			break;
	}

	for(int i = 0; i < TskBuf[id].body_ang.length; i++){
		tpos[X] = tmp[i*2+0];
		tpos[Y] = tmp[i*2+1];
		TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
		TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
		TskBuf[id].body_ang[i][Z] = 0.0f;
		tpos[X] = fabs(tpos[X]);
		tpos[Y] = fabs(tpos[Y]);
		TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
	}
}

void ctrlExtend()
{
	if(game_mode == GMODE_SCORE || game_mode == GMODE_TIME) return;
	if(score >= next_extend){
		next_extend += EXTEND_SCORE;
		if(left < MAX_SHIP){
			playSNDse(SND_VOICE_EXTEND);
			left++;
		}
	}
}

float getShipShotDirection(int id)
{
	float px,py;
	float dir;
	int tid;

	tid = TskBuf[id].tid;
	px = TskBuf[id].tx - TskBuf[tid].px;
	py = TskBuf[id].ty - TskBuf[tid].py;
	dir = atan2(px, py);

	return	dir;
}

float getShipLength(float px,float py)
{
	float len = 0;
	float lpx,lpy;

	lpx = fabs(TskBuf[ship_id].px - px);
	lpy = fabs(TskBuf[ship_id].py - py);
	lpx = pow(lpx, 2.0f);
	lpy = pow(lpy, 2.0f);
	len = sqrt(lpx + lpy);

	return	len;
}

float getTargetDirection(int id)
{
	float px,py;
	float dir;
	int tid;

	tid = TskBuf[id].trg_id;
	if(tid == -1) return 0.0;
	px = TskBuf[id].tx - TskBuf[tid].px;
	py = TskBuf[id].ty - TskBuf[tid].py;
	dir = atan2(px, py);

	return	dir;
}

int getTargetNearEnemy(int id)
{
	int tid = -1;
	int prev;
	float dist = (384.0f + 480.0f) * 2;
	float dx,dy;
	float px,py;

	px = TskBuf[id].px;
	py = TskBuf[id].py;

	for(int i = TskIndex[GROUP_02]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if((TskBuf[i].tskid & (TSKID_ZAKO)) && TskBuf[i].lock_id == -1){
			dx = TskBuf[i].px - px;
			dy = TskBuf[i].py - py;
			if(dx < 0.0f) dx = -dx;
			if(dy < 0.0f) dy = -dy;
			if(dist > (dx + dy)){
				tid = i;
				dist = dx + dy;
			}
		}
		if((TskBuf[i].tskid & TSKID_BOSS)){
			dx = TskBuf[i].px - px;
			dy = TskBuf[i].py - py;
			if(dx < 0.0f) dx = -dx;
			if(dy < 0.0f) dy = -dy;
			if(dist > (dx + dy)){
				tid = i;
				dist = dx + dy;
			}
		}
	}

	if(tid != -1) TskBuf[tid].lock_id = id;

	return	tid;
}
