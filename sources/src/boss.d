/*
	Z-LOCK 'BOSS'

		'boss.d'

	2004/10/06 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	bulletcommand;
private	import	define;
private	import	task;
private	import	main;
private	import	sysinfo;
private	import	gctrl;
private	import	effect;
private	import	stg;
private	import	bg;
private	import	ship;
private	import	enemy;

private	const float	PAL_R = 0.125f;
private	const float	PAL_G = 0.125f;
private	const float	PAL_B = 0.125f;

private	const int WAIT_CNT = 35;

private	float[]	option_poly = [
								-24.0f,-24.0f,
								+24.0f,-24.0f,
								+24.0f,+24.0f,
								-24.0f,+24.0f,
							];

void TSKboss(int id)
{
	TskBuf[id].rank = getRank();

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_BOSS;
			TskBuf[id].px = 0.0f;
			TskBuf[id].py = 0.0f;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 128.0f;
			TskBuf[id].cy = 64.0f;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbossDraw;
			TskBuf[id].fp_exit = &TSKbossExit;
			TskBuf[id].rot = PI;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].body_ofs.length = 64;
			TskBuf[id].body_ofs[0][X] = 0.0f;
			TskBuf[id].body_ofs[0][Y] = 0.0f;
			TskBuf[id].body_ofs[0][Z] = 0.0f;
			TskBuf[id].body_ofs[0][W] = 0.0f;
			float pos[XY];
			float rad[XY];
			float ang;
			ang = cast(float)(Rand() % 10000) / 10000.0f * 2.0f * PI;
			for(int i = 1; i < TskBuf[id].body_ofs.length; i++){
				rad[X] = Rand() % 144;
				rad[Y] = Rand() % 80;
				pos[X] = sin(ang) * rad[X];
				pos[Y] = cos(ang) * rad[Y];
				ang += 2.0f * PI / cast(float)(TskBuf[id].body_ofs.length / 2 - 1);
				TskBuf[id].body_ofs[i][X] = pos[X];
				TskBuf[id].body_ofs[i][Y] = pos[Y];
				TskBuf[id].body_ofs[i][Z] = 0.0f;
				TskBuf[id].body_ofs[i][W] = 1.0f;
			}
			TskBuf[id].cen_x =   +0.0f;
			TskBuf[id].cen_y = -148.0f;
			TskBuf[id].rad_x = +164.0f;
			TskBuf[id].rad_y =  +64.0f;
			TskBuf[id].ang_x = cast(float)(Rand() % 1024) / 1024.0f * PI;
			TskBuf[id].ang_y = cast(float)(Rand() % 1024) / 1024.0f * PI;
			TskBuf[id].ax = cast(float)(Rand() % 1024) / 1024.0f / PI / 600.0f;
			TskBuf[id].ay = cast(float)(Rand() % 1024) / 1024.0f / PI / 600.0f;
			TskBuf[id].energy = 250 + cast(int)(getRank() * 250);
			TskBuf[id].energy = 500;
			TskBuf[id].wait = 60;
			TskBuf[id].pal_r = PAL_R;
			TskBuf[id].pal_g = PAL_G;
			TskBuf[id].pal_b = PAL_B;
			TskBuf[id].pal_r_add = 0.0f;
			TskBuf[id].pal_g_add = 0.0f;
			TskBuf[id].pal_b_add = 0.0f;
			TskBuf[id].pal_cnt = 0;
			int eid;
			eid = setTSK(GROUP_08, &TSKenegauge);
			TskBuf[eid].parent = id;
			TskBuf[eid].wrk1 = TskBuf[id].energy;
			TskBuf[eid].cnt = TskBuf[id].wait / 2;
			TskBuf[eid].tx = -(SCREEN_SX / 2) + 8;
			TskBuf[eid].vx = cast(float)SCREEN_SX - 16.0f;
			TskBuf[eid].vy = 8.0f;
			TskBuf[eid].px = -(SCREEN_SX / 2) + 8 + TskBuf[eid].tx + 16;
			TskBuf[eid].py = +(SCREEN_SY / 2) - 40;
			int chr_id;
			chr_id = Rand() % cast(int)(TskBuf[id].body_ofs.length);
			int max = (8 + stg_level) % 19;
			for(int i = 0; i < max; i++){
				eid = setTSK(GROUP_02, &TSKbossOption);
				TskBuf[eid].parent = id;
				TskBuf[eid].chr_id = chr_id;
				TskBuf[eid].num = i + 1;
				TskBuf[eid].level = 1;
				TskBuf[eid].level_max = max;
				chr_id += Rand() % 4;
				chr_id %= TskBuf[id].body_ofs.length;
			}
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].wait--;
			TskBuf[id].alpha += 1.0f / 60.0f;
			if(!TskBuf[id].wait){
				TskBuf[id].fp_int = &TSKbossInt;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}
			TskBuf[id].px = TskBuf[id].cen_x + sin(TskBuf[id].ang_x) * TskBuf[id].rad_x;
			TskBuf[id].py = TskBuf[id].cen_y - cos(TskBuf[id].ang_y) * TskBuf[id].rad_y;
			TskBuf[id].ang_x += PI / 600.0f + TskBuf[id].ax;
			TskBuf[id].ang_y += PI / 600.0f + TskBuf[id].ay;
			break;
		case	2:
			if(TskBuf[id].tskid & TSKID_MUTEKI) TskBuf[id].tskid &= ~TSKID_MUTEKI;
			TskBuf[id].px = TskBuf[id].cen_x + sin(TskBuf[id].ang_x) * TskBuf[id].rad_x;
			TskBuf[id].py = TskBuf[id].cen_y - cos(TskBuf[id].ang_y) * TskBuf[id].rad_y;
			TskBuf[id].ang_x += PI / 600.0f + TskBuf[id].ax;
			TskBuf[id].ang_y += PI / 600.0f + TskBuf[id].ay;
			if(TskBuf[id].pal_cnt){
				TskBuf[id].pal_cnt--;
				TskBuf[id].pal_r += TskBuf[id].pal_r_add;
				TskBuf[id].pal_g += TskBuf[id].pal_g_add;
				TskBuf[id].pal_b += TskBuf[id].pal_b_add;
			}
			break;

		case	-1:
			boss_flag = 1;
			dest_enemy += 1.0f;
			TskBuf[id].level = TskBuf[TskBuf[id].trg_id].level;
			playSNDse(SND_SE_EDEST2);
			setQuake(30, 80.0f);
			for(int i = 0; i < 16; i++){
				int num = Rand() % cast(int)(TskBuf[id].body_ofs.length - 1);
				num++;
				if(TskBuf[id].body_ofs[num][W] != 1.0f){
					i--;
					continue;
				}
				TskBuf[id].body_ofs[num][W] = 0.0f;
				effSetBrokenBody2(id, option_poly, 0, 4, TskBuf[id].body_ofs[num][X], TskBuf[id].body_ofs[num][Y], 1.0f, 1.0f);
				effSetBrokenLine2(id, option_poly, 0, 4, TskBuf[id].body_ofs[num][X], TskBuf[id].body_ofs[num][Y], 1.0f, 1.0f);
			}
			TskBuf[id].pal_cnt = 60;
			TskBuf[id].pal_r = 1.0f;
			TskBuf[id].pal_g = 1.0f;
			TskBuf[id].pal_b = 1.0f;
			TskBuf[id].pal_r_add = (PAL_R - TskBuf[id].pal_r) / TskBuf[id].pal_cnt;
			TskBuf[id].pal_g_add = (PAL_G - TskBuf[id].pal_g) / TskBuf[id].pal_cnt;
			TskBuf[id].pal_b_add = (PAL_B - TskBuf[id].pal_b) / TskBuf[id].pal_cnt;
			if(TskBuf[id].px < 0.0f){
				TskBuf[id].tx = +cast(float)(Rand() % 80) + 80.0f;
			}else{
				TskBuf[id].tx = -cast(float)(Rand() % 80) - 80.0f;
			}
			TskBuf[id].ty = TskBuf[id].py + 160.0f;
			TskBuf[id].wait = 60;
			TskBuf[id].step--;
		case	-2:
			if(TskBuf[id].wait){
				if(TskBuf[id].pal_cnt){
					TskBuf[id].pal_cnt--;
					TskBuf[id].pal_r += TskBuf[id].pal_r_add;
					TskBuf[id].pal_g += TskBuf[id].pal_g_add;
					TskBuf[id].pal_b += TskBuf[id].pal_b_add;
				}
				TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 15.0f;
				TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 15.0f;
				TskBuf[id].wait--;
			}else{
				TskBuf[id].step--;
			}
			break;
		case	-3:
			playSNDse(SND_SE_EDEST3);
			setQuake(30, 80.0f);
			for(int i = 0; i < 16; i++){
				int num = Rand() % cast(int)(TskBuf[id].body_ofs.length - 1);
				num++;
				if(TskBuf[id].body_ofs[num][W] != 1.0f){
					i--;
					continue;
				}
				TskBuf[id].body_ofs[num][W] = 0.0f;
				effSetBrokenBody2(id, option_poly, 0, 4, TskBuf[id].body_ofs[num][X], TskBuf[id].body_ofs[num][Y], 1.0f, 1.0f);
				effSetBrokenLine2(id, option_poly, 0, 4, TskBuf[id].body_ofs[num][X], TskBuf[id].body_ofs[num][Y], 1.0f, 1.0f);
			}
			TskBuf[id].pal_cnt = 60;
			TskBuf[id].pal_r_add = (0.0f - TskBuf[id].pal_r) / TskBuf[id].pal_cnt;
			TskBuf[id].pal_g_add = (0.0f - TskBuf[id].pal_g) / TskBuf[id].pal_cnt;
			TskBuf[id].pal_b_add = (0.0f - TskBuf[id].pal_b) / TskBuf[id].pal_cnt;
			TskBuf[id].alpha_add = (0.0f - TskBuf[id].alpha) / TskBuf[id].pal_cnt;
			if(TskBuf[id].px < 0.0f){
				TskBuf[id].tx = +cast(float)(Rand() % 80) + 80.0f;
			}else{
				TskBuf[id].tx = -cast(float)(Rand() % 80) - 80.0f;
			}
			TskBuf[id].ty = TskBuf[id].py - 240.0f;
			TskBuf[id].wait = 60;
			int add;
			int	eid;
			if(TskBuf[id].level) add = 500 * (TskBuf[id].level * 20);
			else				 add = 500;
			score += add;
			eid = setTSK(GROUP_08,&TSKescore);
			if(eid != -1){
				TskBuf[eid].cnt = add;
				TskBuf[eid].px = -(getPointX(TskBuf[id].px, -(BASE_Z + cam_scr) / 2) * SCREEN_X);
				TskBuf[eid].py = -(getPointY(TskBuf[id].py, -(BASE_Z + cam_scr) / 2) * SCREEN_Y);
				if(add < 1000){
					TskBuf[eid].sx = 0.75f;
					TskBuf[eid].sy = 0.60f;
				}else if(add < 10000){
					TskBuf[eid].sx = 1.00f;
					TskBuf[eid].sy = 0.80f;
				}else{
					TskBuf[eid].sx = 1.50f;
					TskBuf[eid].sy = 1.20f;
				}
			}
			TskBuf[id].step--;
		case	-4:
			if(TskBuf[id].wait){
				if(TskBuf[id].pal_cnt){
					TskBuf[id].pal_cnt--;
					TskBuf[id].pal_r += TskBuf[id].pal_r_add;
					TskBuf[id].pal_g += TskBuf[id].pal_g_add;
					TskBuf[id].pal_b += TskBuf[id].pal_b_add;
					TskBuf[id].alpha += TskBuf[id].alpha_add;
				}
				TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 15.0f;
				TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 15.0f;
				TskBuf[id].wait--;
			}else{
				enemy_cnt--;
				TskBuf[id].step--;
			}
			break;

		default:
			boss_flag = 0;
			clrTSK(id);
			break;

	}
}

void TSKbossInt(int id)
{
	if(TskBuf[TskBuf[id].trg_id].tskid & (TSKID_SHIP)){
		return;
	}

	if(TskBuf[id].tskid & TSKID_MUTEKI) return;

	if(TskBuf[id].energy > 0){
		score += 10;
		playSNDse(SND_SE_EDMG);
		TskBuf[id].tskid |= TSKID_MUTEKI;
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
		TskBuf[id].pal_cnt = 10;
		TskBuf[id].pal_r = 1.0f;
		TskBuf[id].pal_g = 1.0f;
		TskBuf[id].pal_b = 1.0f;
		TskBuf[id].pal_r_add = (PAL_R - TskBuf[id].pal_r) / TskBuf[id].pal_cnt;
		TskBuf[id].pal_g_add = (PAL_G - TskBuf[id].pal_g) / TskBuf[id].pal_cnt;
		TskBuf[id].pal_b_add = (PAL_B - TskBuf[id].pal_b) / TskBuf[id].pal_cnt;
	}
	if(TskBuf[id].energy <= 0 && TskBuf[id].step != -1){
		TskBuf[id].fp_int = null;
		TskBuf[id].step = -1;
		TskBuf[id].tskid &= ~TSKID_BOSS;
		TskBuf[id].step = -1;
		TskBuf[id].tskid &= ~TSKID_BOSS;
	}else{
		effSetParticle01(TskBuf[id].trg_id, 0.0f, 0.0f, 4);
	}
}

void TSKbossDraw(int id)
{
	float[XY]	pos;

	/* BODY */
	for(int i = 0; i < TskBuf[id].body_ofs.length; i++){
		if(TskBuf[id].body_ofs[i][W] == 1.0f){
			pos[X] = TskBuf[id].px - scr_pos[X] - TskBuf[id].body_ofs[i][X];
			pos[Y] = TskBuf[id].py - scr_pos[Y] + TskBuf[id].body_ofs[i][Y];
			glBegin(GL_POLYGON);
			glColor4f(TskBuf[id].pal_r,TskBuf[id].pal_g,TskBuf[id].pal_b,TskBuf[id].alpha);
			glVertex3f(-getPointX(pos[X] - 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] - 24.0f, TskBuf[id].pz),
					   0.0f);
			glVertex3f(-getPointX(pos[X] + 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] - 24.0f, TskBuf[id].pz),
					   0.0f);
			glVertex3f(-getPointX(pos[X] + 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] + 24.0f, TskBuf[id].pz),
					   0.0f);
			glVertex3f(-getPointX(pos[X] - 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] + 24.0f, TskBuf[id].pz),
					   0.0f);
			glEnd();
			glBegin(GL_LINE_LOOP);
			glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
			glVertex3f(-getPointX(pos[X] - 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] - 24.0f, TskBuf[id].pz),
					   0.0f);
			glVertex3f(-getPointX(pos[X] + 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] - 24.0f, TskBuf[id].pz),
					   0.0f);
			glVertex3f(-getPointX(pos[X] + 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] + 24.0f, TskBuf[id].pz),
					   0.0f);
			glVertex3f(-getPointX(pos[X] - 24.0f, TskBuf[id].pz),
					   -getPointY(pos[Y] + 24.0f, TskBuf[id].pz),
					   0.0f);
			glEnd();
		}
	}
}

void TSKbossExit(int id)
{
	TskBuf[id].body_ofs.length  = 0;
}

void TSKbossOption(int id)
{
	BulletCommand cmd = TskBuf[id].bullet_command;

	void setBulletType(int id)
	{
		int max;
		if(game_cost < 10){
			max = ENMEY_03 + 1;
		}else if(game_cost < 20){
			max = ENMEY_04 + 1;
		}else if(game_cost < 30){
			max = ENMEY_05 + 1;
		}else if(game_cost < 50){
			max = ENMEY_05 + 1;
		}else if(game_cost < 70){
			max = ENMEY_06 + 1;
		}else if(game_cost < 90){
			max = ENMEY_07 + 1;
		}else{
			max = ENMEY_08 + 1;
		}
		TskBuf[id].type = BULLET_ZAKO01 + (Rand() % max);
	}

	void seqMove01(int id)
	{
		TskBuf[id].px = TskBuf[id].tx + TskBuf[TskBuf[id].parent].px;
		TskBuf[id].py = TskBuf[id].ty + TskBuf[TskBuf[id].parent].py;
	}

	TskBuf[id].rank = getRank();

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_BOSS;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].tx = TskBuf[TskBuf[id].parent].body_ofs[TskBuf[id].chr_id][X];
			TskBuf[id].ty = TskBuf[TskBuf[id].parent].body_ofs[TskBuf[id].chr_id][Y];
			TskBuf[id].fp_exit = &TSKbossOptionExit;
			TskBuf[id].tid = ship_id;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].rot = PI;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].wait = 60;
			initEnemyLock(id, 30, 20);
			setEnemyLock(id);
			seqMove01(id);
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].alpha += 1.0f / WAIT_CNT;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait){
				cmd = new BulletCommand();
				TskBuf[id].bullet_command = cmd;
				TskBuf[id].bullet_wait = Rand() % 60;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}
			seqMove01(id);
			break;
		case	2:
			if(TskBuf[TskBuf[id].parent].step < 0){
				TskBuf[id].step = 100;
				break;
			}
			if(TskBuf[id].lock_mode > 0){
				if(TskBuf[id].lock_cnt){
					TskBuf[id].lock_cnt--;
				}else{
					TskBuf[id].bullet_cnt = 0;
					TskBuf[id].step++;
				}
			}
			seqMove01(id);
			break;
		case	3:
			if(TskBuf[TskBuf[id].parent].step < 0){
				TskBuf[id].step = 100;
				break;
			}
			if(cmd){
				if(TskBuf[id].bullet_wait){
					if(cmd.isEnd()) TskBuf[id].bullet_wait--;
				}else{
					TskBuf[id].bullet_wait = Rand() % 60;
					if(TskBuf[id].bullet_cnt == 0){
						TskBuf[id].bullet_cnt = 1;
						setBulletType(id);
						cmd.set(id, TskBuf[id].type);
					}else{
						TskBuf[TskBuf[id].tid].step = 6;
						TskBuf[id].wait = 60;
						TskBuf[id].step++;
					}
				}
				if(!cmd.isEnd()) cmd.run();
			}
			seqMove01(id);
			break;
		case	4:
			if(TskBuf[TskBuf[id].parent].step < 0){
				TskBuf[id].step = 100;
				break;
			}
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				initEnemyLock(id, 60, 30);
				setEnemyLock(id);
				TskBuf[id].step = 2;
			}
			seqMove01(id);
			break;

		case	100:
			TskBuf[id].step = -1;
			break;

		default:
			clrTSK(id);
			break;
	}
}

void TSKbossOptionExit(int id)
{
	BulletCommand cmd = TskBuf[id].bullet_command;

	if(cmd){
		cmd.vanish();
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}
