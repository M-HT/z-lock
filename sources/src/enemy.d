/*
	Z-LOCK 'ENEMY COMMON'

		'enemy.d'

	2004/04/14 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.conv;
private	import	std.string;
private	import	std.math;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_glbf;
private	import	util_snd;
private	import	bulletml;
private	import	bulletcommand;
private	import	main;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	stg;
private	import	bg;
private	import	ship;
private	import	effect;

const float	ENEMY_AREAMAX_X = (284.0f + 48.0f);
const float	ENEMY_AREAMAX_Y = (356.0f + 64.0f);
const float	ESHOT_AREAMAX_X = (248.0f);
const float	ESHOT_AREAMAX_Y = (200.0f);
const float	EFIRE_MIN = (128.0f);

private	const float PAL_R = 0.125f;
private	const float PAL_G = 0.125f;
private	const float PAL_B = 0.125f;

private	float[]	eshot_body_simple = [
										-12.0f, +0.0f,
										 +0.0f,-12.0f,
										+12.0f, +0.0f,
										 +0.0f,+12.0f,
									];

private	float[]	eshot_body_active = [
										 -8.0f, -8.0f,
										 +0.0f,-16.0f,
										 +8.0f, -8.0f,
										 +0.0f,+16.0f,
									];

private	float[]	lock01_poly = [
								 +0.0f,-16.0f,
								+16.0f, +0.0f,
								 +0.0f,+16.0f,
								-16.0f, +0.0f,
							];

private	float[]	option_poly = [
								 -2.5f, -2.5f,
								 +2.5f, -2.5f,
								 +2.5f, +2.5f,
								 -2.5f, +2.5f,
							];

private	char[]	str_buf;

void TSKenemyDest(int id, int add_score)
{
	if(add_score){
		int add;
		int	eid;
		if(TskBuf[id].level) add = add_score * (TskBuf[id].level * 20);
		else				 add = add_score;
		level_dest[TskBuf[id].level]++;
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
	}

	enemy_cnt--;
	dest_enemy += 1.0f;
}

void TSKenemyDamage(int id, int eid)
{
	TskBuf[id].tskid |= TSKID_MUTEKI;
	TskBuf[id].energy -= TskBuf[eid].energy;
	TskBuf[id].pal_cnt = 10;
	TskBuf[id].pal_r = 1.0f;
	TskBuf[id].pal_g = 1.0f;
	TskBuf[id].pal_b = 1.0f;
	TskBuf[id].pal_r_add = (TskBuf[id].pal_r_base - TskBuf[id].pal_r) / TskBuf[id].pal_cnt;
	TskBuf[id].pal_g_add = (TskBuf[id].pal_g_base - TskBuf[id].pal_g) / TskBuf[id].pal_cnt;
	TskBuf[id].pal_b_add = (TskBuf[id].pal_b_base - TskBuf[id].pal_b) / TskBuf[id].pal_cnt;
}

void TSKtargetLock(int id)
{
	int	parent = TskBuf[id].parent;

	if(TskBuf[parent].step == -1 && TskBuf[id].step <= 5 && TskBuf[id].step != -1){
		TskBuf[id].step = 6;
	}

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_LOCK;
			TskBuf[id].px = TskBuf[parent].px;
			TskBuf[id].py = TskBuf[parent].py;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].tx = TskBuf[parent].px;
			TskBuf[id].ty = TskBuf[parent].py;
			TskBuf[id].cx = 16.0f;
			TskBuf[id].cy = 16.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = &TSKtargetLockInt;
			TskBuf[id].fp_draw = &TSKtargetLockDraw;
			TskBuf[id].body_ang.length	= lock01_poly.length / 2;
			{
				float[XY] tpos;
				for(int i = 0; i < TskBuf[id]. body_ang.length; i++){
					tpos[X] = lock01_poly[i*2+0];
					tpos[Y] = lock01_poly[i*2+1];
					TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Z] = 0.0f;
					tpos[X] = fabs(tpos[X]);
					tpos[Y] = fabs(tpos[Y]);
					TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
				}
			}
			TskBuf[id].level_add = cast(float)(SHIP_LEVEL_MAX) / (cast(float)(TskBuf[id].level) * cast(float)TskBuf[id].level_max);
			TskBuf[id].lock_mode = 0;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].tx = TskBuf[parent].px;
			TskBuf[id].ty = TskBuf[parent].py;
			TskBuf[id].px += (TskBuf[TskBuf[id].tid].px - TskBuf[id].px) / 5.0f;
			TskBuf[id].py += (TskBuf[TskBuf[id].tid].py - TskBuf[id].py) / 5.0f;
			TskBuf[id].rot += PI / 5.5f;
			break;
		case	2:
			playSNDse(SND_SE_LOCK_ON);
			TskBuf[id].lock_mode = 1;
			TskBuf[id].sx = 1.0f;
			TskBuf[id].sy = 1.0f;
			TskBuf[id].vx = 0.5f / 15;
			TskBuf[id].vy = 0.5f / 15;
			TskBuf[id].alpha = 1.0;
			TskBuf[id].alpha_add = 0.5f / 15;
			TskBuf[id].cnt = 15;
			TskBuf[id].step++;
			goto case;
		case	3:
			if(TskBuf[id].cnt){
				TskBuf[id].cnt--;
				TskBuf[id].sx -= TskBuf[id].vx;
				TskBuf[id].sy -= TskBuf[id].vy;
				TskBuf[id].alpha -= TskBuf[id].alpha_add;
			}else{
				TskBuf[parent].lock_mode = 1;
				TskBuf[id].sx = 0.5f;
				TskBuf[id].sy = 0.5f;
				TskBuf[id].alpha = 0.5f;
				TskBuf[id].step++;
			}
			TskBuf[id].tx = TskBuf[parent].px;
			TskBuf[id].ty = TskBuf[parent].py;
			TskBuf[id].px += (TskBuf[TskBuf[id].tid].px - TskBuf[id].px) / 15.0f;
			TskBuf[id].py += (TskBuf[TskBuf[id].tid].py - TskBuf[id].py) / 15.0f;
			break;
		case	4:
			if(TskBuf[id].lock_cnt){
				TskBuf[id].lock_cnt--;
			}else{
				TskBuf[id].step++;
			}
			TskBuf[id].tx = TskBuf[parent].px;
			TskBuf[id].ty = TskBuf[parent].py;
			TskBuf[id].px += (TskBuf[TskBuf[id].tid].px - TskBuf[id].px) / 15.0f;
			TskBuf[id].py += (TskBuf[TskBuf[id].tid].py - TskBuf[id].py) / 15.0f;
			break;
		case	5:
			TskBuf[id].tx = TskBuf[parent].px;
			TskBuf[id].ty = TskBuf[parent].py;
			if(ship_special != SHIP_SPECIAL_NONE){
				TskBuf[id].tx = TskBuf[parent].px;
				TskBuf[id].ty = TskBuf[parent].py;
				TskBuf[id].px += (TskBuf[TskBuf[id].tid].px - TskBuf[id].px) / 5.0f;
				TskBuf[id].py += (TskBuf[TskBuf[id].tid].py - TskBuf[id].py) / 5.0f;
			}
			break;
		case	6:
			if(TskBuf[id].lock_mode == 1){
				TskBuf[id].lock_mode = 2;
				TskBuf[id].alpha_add = 0.5f / 15;
				TskBuf[id].cnt = 15;
				TskBuf[id].step++;
			}else if(TskBuf[id].lock_mode == 2){
				TskBuf[id].alpha_add = 0.5f / 15;
				TskBuf[id].cnt = 15;
				TskBuf[id].step++;
			}else{
				TskBuf[id].step = -1;
				break;
			}
			goto case;
		case	7:
			if(TskBuf[id].cnt){
				TskBuf[id].cnt--;
				TskBuf[id].alpha -= TskBuf[id].alpha_add;
			}else{
				TskBuf[id].alpha = 0.0;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKtargetLockDraw(int id)
{
	float[XYZ] pos;
	float[XY] base;
	float z;
	float size,lx,ly;

	z = TskBuf[id].pz;
	base[X] = TskBuf[id].px - scr_pos[X];
	base[Y] = TskBuf[id].py - scr_pos[Y];

	if(TskBuf[id].lock_mode == 0){
		glColor4f(0.25f,0.25f,0.50f,0.25f);
		glBegin(GL_POLYGON);
		for(int i = 0; i < TskBuf[id].body_ang.length; i++){
			pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, z);
			pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, z);
			pos[Z] = TskBuf[id].body_ang[i][Z];
			glVertex3f(pos[X] - getPointX(base[X], z),
					   pos[Y] - getPointY(base[Y], z),
					   pos[Z]);
		}
		glEnd();
		glColor4f(1.0f,1.0f,1.0f,1.0f);
		glBegin(GL_LINE_LOOP);
		for(int i = 0; i < TskBuf[id].body_ang.length; i++){
			pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, z);
			pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, z);
			pos[Z] = TskBuf[id].body_ang[i][Z];
			glVertex3f(pos[X] - getPointX(base[X], z),
					   pos[Y] - getPointY(base[Y], z),
					   pos[Z]);
		}
		glEnd();
	}else if(TskBuf[id].lock_mode == 1 || TskBuf[id].lock_mode == 2){
		size = 32.0f * TskBuf[id].sx;
		glColor4f(0.25f,0.25f,0.25f,TskBuf[id].alpha);
		glBegin(GL_QUADS);
		glVertex3f(-getPointX(base[X]-size, z),
				   -getPointY(base[Y]-size, z),
				   z);
		glVertex3f(-getPointX(base[X]-size, z),
				   -getPointY(base[Y]+size, z),
				   z);
		glVertex3f(-getPointX(base[X]+size, z),
				   -getPointY(base[Y]+size, z),
				   z);
		glVertex3f(-getPointX(base[X]+size, z),
				   -getPointY(base[Y]-size, z),
				   z);
		glEnd();
		glColor4f(0.5f,0.5f,0.5f,(TskBuf[id].alpha * 1.25f));
		lx = 18.0f * TskBuf[id].sx;
		ly = 18.0f * TskBuf[id].sx;
		glBegin(GL_LINES);
		glVertex3f(-getPointX(base[X]-size+ 0, z),
				   -getPointY(base[Y]-size+ly, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+ 0, z),
				   -getPointY(base[Y]-size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+ 0, z),
				   -getPointY(base[Y]-size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+lx, z),
				   -getPointY(base[Y]-size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+ 0, z),
				   -getPointY(base[Y]+size-ly, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+ 0, z),
				   -getPointY(base[Y]+size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+ 0, z),
				   -getPointY(base[Y]+size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]-size+lx, z),
				   -getPointY(base[Y]+size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+size+ 0, z),
				   -getPointY(base[Y]-size+ly, z),
				   z);
		glVertex3f(-getPointX(base[X]+size+ 0, z),
				   -getPointY(base[Y]-size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+size+ 0, z),
				   -getPointY(base[Y]-size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+size-lx, z),
				   -getPointY(base[Y]-size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+size+ 0, z),
				   -getPointY(base[Y]+size-ly, z),
				   z);
		glVertex3f(-getPointX(base[X]+size+ 0, z),
				   -getPointY(base[Y]+size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+size+ 0, z),
				   -getPointY(base[Y]+size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+size-lx, z),
				   -getPointY(base[Y]+size+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]-lx, z),
				   -getPointY(base[Y]+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+lx, z),
				   -getPointY(base[Y]+ 0, z),
				   z);
		glVertex3f(-getPointX(base[X]+ 0, z),
				   -getPointY(base[Y]-ly, z),
				   z);
		glVertex3f(-getPointX(base[X]+ 0, z),
				   -getPointY(base[Y]+ly, z),
				   z);
		glEnd();
	}
	if(TskBuf[id].lock_mode != 2){
		glColor4f(0.5f,0.5f,0.5f,0.5f);
		glBegin(GL_LINES);
		pos[Z] = TskBuf[id].body_ang[0][Z];
		glVertex3f(-getPointX(base[X], z),
				   -getPointY(base[Y], z),
				   pos[Z]);
		glVertex3f(-getPointX(TskBuf[id].tx - scr_pos[X], z),
				   -getPointY(TskBuf[id].ty - scr_pos[Y], z),
				   pos[Z]);
		glEnd();
	}else if(TskBuf[id].lock_mode != -1){
		glColor4f(0.5f,0.5f,0.5f,TskBuf[id].alpha);
		glBegin(GL_LINES);
		pos[Z] = TskBuf[id].body_ang[0][Z];
		glVertex3f(-getPointX(base[X], z),
				   -getPointY(base[Y], z),
				   pos[Z]);
		glVertex3f(-getPointX(TskBuf[id].tx - scr_pos[X], z),
				   -getPointY(TskBuf[id].ty - scr_pos[Y], z),
				   pos[Z]);
		glEnd();
	}
}

void TSKtargetLockInt(int id)
{
	if(!(TskBuf[TskBuf[id].trg_id].tskid & TSKID_SHIP)) return;
	if(TskBuf[id].step == 1) TskBuf[id].step++;
}

void TSKeshotSimple(int id)
{
	double[XY]	tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].tx = TskBuf[TskBuf[id].tid].px;
			TskBuf[id].ty = TskBuf[TskBuf[id].tid].py;
			TskBuf[id].cx = 4.0f;
			TskBuf[id].cy = 4.0f;
			TskBuf[id].fp_int = &TSKeshotInt;
			TskBuf[id].fp_draw = &TSKeshotDrawSimple;
			TskBuf[id].fp_exit = &TSKeshotExit;
			TskBuf[id].body_org.length = eshot_body_simple.length;
			for(int i = 0; i < eshot_body_simple.length; i++){
				TskBuf[id].body_org[i] = eshot_body_simple[i];
			}
			TskBuf[id].body_ang.length	= eshot_body_simple.length / 2;
			for(int i = 0; i < TskBuf[id].body_ang.length; i++){
				tpos[X] = eshot_body_simple[i*2+0];
				tpos[Y] = eshot_body_simple[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			if(game_mode == GMODE_HIDDEN){
				TskBuf[id].bullet_length = getTargetLength(id, TskBuf[id].tx, TskBuf[id].ty);
				TskBuf[id].bullet_length_bak = TskBuf[id].bullet_length;
			}
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].energy = 1;
			TskBuf[id].step++;
			break;
		case	1:
			if(game_mode == GMODE_HIDDEN){
				float len = getTargetLength(id, TskBuf[id].tx, TskBuf[id].ty);
				if(TskBuf[id].bullet_length_bak > len){
					TskBuf[id].alpha = len / TskBuf[id].bullet_length;
					TskBuf[id].bullet_length_bak = len;
				}else{
					TskBuf[id].alpha = 0.0f;
				}
			}
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			if(TskBuf[id].px < -ENEMY_AREAMAX_X || TskBuf[id].px > +ENEMY_AREAMAX_X || TskBuf[id].py > +ENEMY_AREAMAX_Y || TskBuf[id].py < -ENEMY_AREAMAX_Y){
				TskBuf[id].step = -1;
			}
			TskBuf[id].roll += PI / 12.0f;
			break;

		case	100:
			effSetBrokenBody(id, TskBuf[id].body_org, 0, 4,+0.0f,+0.0f,+1.0f,+1.0f);
			effSetBrokenLine(id, TskBuf[id].body_org, 0, 4,+0.0f,+0.0f,+1.0f,+1.0f);
			TskBuf[id].step = -1;
			break;

		default:
			clrTSK(id);
			break;
	}
}

void TSKeshotActive(int id)
{
	double[XY]	tpos;
	BulletCommand	cmd = TskBuf[id].bullet_command;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].tx = TskBuf[TskBuf[id].tid].px;
			TskBuf[id].ty = TskBuf[TskBuf[id].tid].py;
			TskBuf[id].cx = 4.0f;
			TskBuf[id].cy = 4.0f;
			TskBuf[id].fp_int = &TSKeshotInt;
			TskBuf[id].fp_draw = &TSKeshotDrawActive;
			TskBuf[id].fp_exit = &TSKeshotExit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].body_org.length = eshot_body_active.length;
			for(int i = 0; i < eshot_body_active.length; i++){
				TskBuf[id].body_org[i] = eshot_body_active[i];
			}
			TskBuf[id].body_ang.length	= eshot_body_active.length / 2;
			for(int i = 0; i < TskBuf[id].body_ang.length; i++){
				tpos[X] = eshot_body_active[i*2+0];
				tpos[Y] = eshot_body_active[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			if(game_mode == GMODE_HIDDEN){
				TskBuf[id].bullet_length = getTargetLength(id, TskBuf[id].tx, TskBuf[id].ty);
				TskBuf[id].bullet_length_bak = TskBuf[id].bullet_length;
			}
			TskBuf[id].alpha = 1.0f;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			cmd.set(id, TskBuf[id].bullet_state);
			TskBuf[id].step++;
			break;
		case	1:
			if(game_mode == GMODE_HIDDEN){
				float len = getTargetLength(id, TskBuf[id].tx, TskBuf[id].ty);
				if(TskBuf[id].bullet_length_bak > len){
					TskBuf[id].alpha = len / TskBuf[id].bullet_length;
					TskBuf[id].bullet_length_bak = len;
				}else{
					TskBuf[id].alpha = 0.0f;
				}
			}
			TskBuf[id].bullet_velx = (sin(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].bullet_vely = (cos(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			if(TskBuf[id].px < -ENEMY_AREAMAX_X || TskBuf[id].px > +ENEMY_AREAMAX_X || TskBuf[id].py > +ENEMY_AREAMAX_Y || TskBuf[id].py < -ENEMY_AREAMAX_Y){
				TskBuf[id].step = -1;
			}
			if(!cmd.isEnd()) cmd.run();
			break;

		case	100:
			effSetBrokenBody(id, TskBuf[id].body_org, 0, 4,+0.0f,+0.0f,+1.0f,+1.0f);
			effSetBrokenLine(id, TskBuf[id].body_org, 0, 4,+0.0f,+0.0f,+1.0f,+1.0f);
			TskBuf[id].step = -1;
			break;

		default:
			if(cmd){
				cmd.vanish();
				destroy(cmd);
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;
	}
}

void TSKeshotInt(int id)
{
	TskBuf[id].step = -1;

}

void TSKeshotDrawSimple(int id)
{
	void setVertex(int id, int i)
	{
		float[XYZ] pos;

		pos[X] = sin(TskBuf[id].roll - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].roll - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}

	glColor4f(0.35f, 0.35f, 0.15f, TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
	glColor4f(1.0f, 1.0f, 1.0f, TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POINTS);
	glVertex3f(getPointX(scr_pos[X] - TskBuf[id].px, TskBuf[id].pz),
			   getPointY(scr_pos[Y] - TskBuf[id].py, TskBuf[id].pz),
			   0.0f);
	glEnd();
}

void TSKeshotDrawActive(int id)
{
	void setVertex(int id, int i)
	{
		float[XYZ] pos;

		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}

	glColor4f(0.15f, 0.35f, 0.15f, TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
	glColor4f(1.0f, 1.0f, 1.0f, TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POINTS);
	glVertex3f(getPointX(scr_pos[X] - TskBuf[id].px, TskBuf[id].pz),
			   getPointY(scr_pos[Y] - TskBuf[id].py, TskBuf[id].pz),
			   0.0f);
	glEnd();
}

void TSKeshotExit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_ang.length	= 0;
	if(cmd){
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}
}

void setTSKoption(int id, int max, int bullet)
{
	int eid;
	float roll,roll_add;

	roll = 0.0f;
	roll_add = (Rand() % 30) - 15.0f;

	if(roll_add <= 0.0f) roll_add = -(PI / (Rand() % 30 + 30));
	else 				 roll_add = +(PI / (Rand() % 30 + 30));

	for(int i = 0; i < max; i++){
		eid = setTSK(GROUP_03, &TSKoption);
		if(eid != -1){
			TskBuf[eid].parent = id;
			TskBuf[eid].level_max = enemy_max;
			TskBuf[eid].level = max;
			TskBuf[eid].roll = roll;
			TskBuf[eid].rot_add = roll_add;
			TskBuf[eid].bullet_num = bullet;
			roll += PI / max * 2.0f;
			assert(TskBuf[eid].turn == 0);
		}
	}

}

void TSKoption(int id)
{
	int parent = TskBuf[id].parent;

	void seqMove01(int id)
	{
		TskBuf[id].px = TskBuf[parent].px + sin(TskBuf[id].roll) * TskBuf[id].rad_x * 3.0f;
		TskBuf[id].py = TskBuf[parent].py + cos(TskBuf[id].roll) * TskBuf[id].rad_y * 3.0f;
		TskBuf[id].roll += TskBuf[id].rot_add;
	}

	int chkParent(int id)
	{
		if(TskBuf[parent].tskid & TSKID_DESTROY){
			TskBuf[id].step = 100;
			return 0;
		}
		if(TskBuf[parent].step == -1){
			TskBuf[id].step = -1;
			return 0;
		}

		return 1;
	}

	BulletCommand cmd = TskBuf[id].bullet_command;

	TskBuf[id].rank = getRank();

	switch(TskBuf[id].step){
		case	0:	// init
			TskBuf[id].tskid |= TSKID_ZAKO;
			TskBuf[id].fp_draw = &TSKoptionDraw;
			TskBuf[id].fp_exit = &TSKoptionExit;
			TskBuf[id].tid = ship_id;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].rad_x = 8.0f;
			TskBuf[id].rad_y = 8.0f;
			TskBuf[id].alpha = 1.0f;
			{
				float[XY] tpos;
				TskBuf[id].body_org.length = option_poly.length;
				for(int i = 0; i < option_poly.length; i++){
					TskBuf[id].body_org[i] = option_poly[i];
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
			setEnemyPallete(id, PAL_R, PAL_G, PAL_B);
			initEnemyLock(id, 30, 20);
			setEnemyLock(id);
			seqMove01(id);
			TskBuf[id].step++;
			break;
		case	1:	// move
			if(!chkParent(id)) break;
			if(TskBuf[parent].tskid & TSKID_LOCKON) TskBuf[id].step++;
			seqMove01(id);
			break;
		case	2:	// lock & move
			if(!chkParent(id)) break;
			seqMove01(id);
			if(execEnemyLock(id)){
				TskBuf[id].bullet_command = new BulletCommand();
				TskBuf[id].bullet_wait = 0;
				TskBuf[id].step++;
			}
			break;
		case	3:	// fire & move
			if(!chkParent(id)) break;
			seqMove01(id);
			execEnemyBullet(id, cmd, 180, TskBuf[id].bullet_num);
			break;

		case	100:
			effSetBrokenBody(id, TskBuf[id].body_org,0,cast(int)(TskBuf[id].body_ang.length),+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,0,cast(int)(TskBuf[id].body_ang.length),+0.0f,+0.0f,+3.0f,+3.0f);
			TskBuf[id].step = -1;
			break;

		default:
			clrTSK(id);
			break;

	}
}

void TSKoptionExit(int id)
{
	BulletCommand cmd = TskBuf[id].bullet_command;

	destroyEnemyBullet(id, cmd);

	TskBuf[id].body_ang.length	= 0;
	TskBuf[id].body_org.length	= 0;
}

void TSKoptionDraw(int id)
{
	void setVertex(int id, int i)
	{
		float[XYZ] pos;

		pos[X] = sin(TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}

	int parent = TskBuf[id].parent;
	glColor4f(TskBuf[id].pal_r,TskBuf[id].pal_g,TskBuf[id].pal_b,TskBuf[parent].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[parent].alpha / 1.25f);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
}

void TSKescore(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKescoreDraw;
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].py += 0.5f;
				TskBuf[id].wait--;
			}else{
				TskBuf[id].step = -1;
			}
			break;

		default:
			clrTSK(id);
			break;
	}
}

void TSKescoreDraw(int id)
{
	float px,py;

	str_buf = "+".dup ~ to!string(TskBuf[id].cnt);
	glColor4f(0.5f,1.0f,0.5f,1.0f);
	glbfPrintBegin();
	if(TskBuf[id].cnt < 10000){
		px = TskBuf[id].px - 14;
	}else{
		px = TskBuf[id].px - 14 * 5;
	}
	py = TskBuf[id].py;
	glbfTranslate(px, py);
	glbfScale(TskBuf[id].sx, TskBuf[id].sy);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
}

/* ============================================================================ */

float getShipDirection(int id)
{
	float	px,py;
	float	dir;
	int		tid;

	tid = TskBuf[id].tid;
	px = TskBuf[id].px - TskBuf[tid].px;
	py = TskBuf[id].py - TskBuf[tid].py;
	dir = atan2(px, py);

	return	dir;
}

int setEnemyPallete(int id, float pal_r, float pal_g, float pal_b)
{
	TskBuf[id].pal_r_base = pal_r;
	TskBuf[id].pal_g_base = pal_g;
	TskBuf[id].pal_b_base = pal_b;
	TskBuf[id].pal_r = TskBuf[id].pal_r_base;
	TskBuf[id].pal_g = TskBuf[id].pal_g_base;
	TskBuf[id].pal_b = TskBuf[id].pal_b_base;
	TskBuf[id].pal_cnt = 0;

	return	1;
}

int initEnemyLock(int id, int cnt, int rnd)
{
	TskBuf[id].lock_mode = 0;
	TskBuf[id].lock_cnt = cnt - cast(int)(getRank() * rnd);
	TskBuf[id].lock_id = -1;

	return 1;
}

int setEnemyLock(int id)
{
	int eid;
	eid = setTSK(GROUP_02, &TSKtargetLock);
	if(eid != -1){
		TskBuf[eid].parent = id;
		TskBuf[eid].level = TskBuf[id].level;
		TskBuf[eid].level_max = TskBuf[id].level_max;
		TskBuf[eid].lock_cnt = TskBuf[id].lock_cnt;
		TskBuf[id].tid = eid;
		return	1;
	}

	return	0;
}

int execEnemyLock(int id)
{
	if(TskBuf[id].lock_mode > 0){
		if(TskBuf[id].lock_cnt){
			TskBuf[id].lock_cnt--;
		}else{
			return	1;
		}
	}

	return	0;
}

int waitEnemyStep(int id, void function(int) fp_int)
{
	TskBuf[id].wait--;
	if(!TskBuf[id].wait){
		TskBuf[id].bullet_command = new BulletCommand();
		TskBuf[id].bullet_wait = 0;
		TskBuf[id].fp_int = fp_int;
		TskBuf[id].alpha = 1.0f;
		return	1;
	}

	return	0;
}

int waitEnemyStep2(int id, void function(int) fp_int)
{
	TskBuf[id].wait--;
	if(!TskBuf[id].wait){
		TskBuf[id].fp_int = fp_int;
		TskBuf[id].alpha = 1.0f;
		return	1;
	}

	return	0;
}

int execEnemyBullet(int id, BulletCommand cmd, int wait, int bullet)
{
	if(cmd){
		if(TskBuf[id].bullet_wait){
			if(cmd.isEnd()) TskBuf[id].bullet_wait--;
		}else{
			TskBuf[id].bullet_wait = wait;
			cmd.set(id, bullet);
		}
		if(getEshotArea(id)){
			if(!cmd.isEnd()) cmd.run();
		}
	}

	return	1;
}

int destroyEnemyBullet(int id, BulletCommand cmd)
{
	if(cmd){
		cmd.vanish();
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}

	return	1;
}

int chkEmoveArea(int id)
{
	if(TskBuf[id].py > +ENEMY_AREAMAX_Y || TskBuf[id].py < -ENEMY_AREAMAX_Y || TskBuf[id].px > +ENEMY_AREAMAX_X || TskBuf[id].px < -ENEMY_AREAMAX_X){
		TskBuf[id].tskid &= ~TSKID_ZAKO;
		enemy_cnt--;
		return	1;
	}

	return	0;
}

int execEpalFade(int id)
{
	if(TskBuf[id].pal_cnt){
		TskBuf[id].pal_cnt--;
		TskBuf[id].pal_r += TskBuf[id].pal_r_add;
		TskBuf[id].pal_g += TskBuf[id].pal_g_add;
		TskBuf[id].pal_b += TskBuf[id].pal_b_add;
	}

	return	1;
}

int getEshotArea(int id)
{
	if(TskBuf[id].px > +ESHOT_AREAMAX_X) return 0;
	if(TskBuf[id].px < -ESHOT_AREAMAX_X) return 0;
	if(TskBuf[id].py > +ESHOT_AREAMAX_Y) return 0;
	if(getShipLength(TskBuf[id].px, TskBuf[id].py) < EFIRE_MIN) return 0;

	return	1;
}

void EnemyVanish()
{
	int	prev;

	for(int i = TskIndex[GROUP_02]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].step != -1){
			TskBuf[i].fp_int = null;
			TskBuf[i].step = 100;
		}
	}
}

void EbulletVanish()
{
	int	prev;

	for(int i = TskIndex[GROUP_06]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && TskBuf[i].step != -1){
			TskBuf[i].fp_int = null;
			TskBuf[i].step = 100;
		}
	}
}

float getTargetLength(int id, float tx, float ty)
{
	float len;
	float px, py;
	float lpx,lpy;

	px = TskBuf[id].px;
	py = TskBuf[id].py;
	lpx = fabs(tx - px);
	lpy = fabs(ty - py);
	lpx = pow(lpx, 2.0f);
	lpy = pow(lpy, 2.0f);
	len = sqrt(lpx + lpy);

	return	len;
}

