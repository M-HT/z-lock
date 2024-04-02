/*
	Z-LOCK 'ENEMY-05'

		'enemy05.d'

	2004/03/27 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	bindbc.sdl;
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

private	const float PAL_R = 0.125f;
private	const float PAL_G = 0.125f;
private	const float PAL_B = 0.125f;

private	const int WAIT_CNT = 35;

private	float[]	enemy_poly = [
								 -5.0f, -5.0f,
								 +5.0f, -5.0f,
								 +5.0f, +5.0f,
								 -5.0f, +5.0f,
								 +0.0f, -8.0f,
								 +4.0f, +0.0f,
								 +0.0f, +8.0f,
								 -4.0f, +0.0f,
								 +0.0f, -4.0f,
								 +8.0f, +0.0f,
								 +0.0f, +4.0f,
								 -8.0f, +0.0f,
							];

void TSKenemy05(int id)
{
	void seqMove01(int id)
	{
		TskBuf[id].px += TskBuf[id].vx;
		TskBuf[id].py += TskBuf[id].vy;
		if(TskBuf[id].px < 0.0f){
			TskBuf[id].vx += TskBuf[id].ax;
		}else{
			TskBuf[id].vx -= TskBuf[id].ax;
		}
		TskBuf[id].rot_x += TskBuf[id].rot_add;
		TskBuf[id].rot_add += ((PI / 180.0f) - TskBuf[id].rot_add) / 30.0f;
	}

	BulletCommand cmd = TskBuf[id].bullet_command;

	TskBuf[id].rank = getRank();

	switch(TskBuf[id].step){
		case	0:	// init
			TskBuf[id].tskid |= TSKID_ZAKO;
			if(TskBuf[id].tskid & TSKID_POSSET){
				TskBuf[id].tskid &= ~TSKID_POSSET;
				TskBuf[id].px = (Rand() % SCREEN_SX) - (SCREEN_SX / 2.0f);
				TskBuf[id].py = -SCREEN_SY + 64.0f;
			}
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKenemy05Draw;
			TskBuf[id].fp_exit = &TSKenemy05Exit;
			TskBuf[id].tid = ship_id;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].cx = 32.0f;
			TskBuf[id].cy = 32.0f;
			TskBuf[id].rot_x = 0.0f;
			TskBuf[id].rot_add = PI / 16.0f;
			if(TskBuf[id].px < 0.0f){
				TskBuf[id].vx = -1.0f;
			}else{
				TskBuf[id].vx = +1.0f;
			}
			TskBuf[id].ax = 0.1f;
			TskBuf[id].vy = 1.0f;
			TskBuf[id].alpha = 0.0f;
			float[XY] tpos;
			TskBuf[id].body_org.length = enemy_poly.length;
			TskBuf[id].body_org[] = enemy_poly[];
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
			setTSKoption(id, TskBuf[id].level, BULLET_ZAKO05);
			TskBuf[id].energy = 2 + cast(int)(getRank() * 3);
			TskBuf[id].wait = WAIT_CNT;
			setEnemyPallete(id, PAL_R, PAL_G, PAL_B);
			TskBuf[id].step++;
			break;
		case	1:	// first-move
			TskBuf[id].alpha += 1.0f / WAIT_CNT;
			if(waitEnemyStep2(id, &TSKenemy05Int)){
				TskBuf[id].tskid |= TSKID_LOCKON;
				TskBuf[id].step++;
			}
			seqMove01(id);
			if(chkEmoveArea(id)) TskBuf[id].step = -1;
			break;
		case	2:	// move
			TskBuf[id].tskid &= ~TSKID_MUTEKI;
			seqMove01(id);
			execEpalFade(id);
			if(chkEmoveArea(id)) TskBuf[id].step = -1;
			break;

		case	100:
			playSNDse(SND_SE_EDEST1);
			if(!(TskBuf[id].tskid & TSKID_DESTROY)){
				TskBuf[id].level = 0;
				TSKenemyDest(id,0);
			}else{
				TskBuf[id].level = TskBuf[TskBuf[id].trg_id].level;
				TSKenemyDest(id,10);
			}
			effSetBrokenBody(id, TskBuf[id].body_org,  0, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org,  4, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org,  8, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,  0, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,  4, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,  8, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			TskBuf[id].step = -1;
			break;

		default:
			destroyEnemyBullet(id, cmd);
			clrTSK(id);
			break;

	}
}

void TSKenemy05Exit(int id)
{
	BulletCommand cmd = TskBuf[id].bullet_command;

	destroyEnemyBullet(id, cmd);

	TskBuf[id].body_ang.length  = 0;
	TskBuf[id].body_org.length  = 0;
}

void TSKenemy05Int(int id)
{
	if(TskBuf[TskBuf[id].trg_id].tskid & (TSKID_SHIP)){
		return;
	}

	if(TskBuf[id].tskid & TSKID_MUTEKI) return;

	if(TskBuf[id].energy > 0){
		playSNDse(SND_SE_EDMG);
		TSKenemyDamage(id, TskBuf[id].trg_id);
	}
	if(TskBuf[id].energy <= 0 && TskBuf[id].step != -1 && TskBuf[id].step != 100){
		TskBuf[id].tskid &= ~TSKID_ZAKO;
		TskBuf[id].tskid |= TSKID_DESTROY;
		TskBuf[id].step = 100;
	}else{
		effSetParticle01(TskBuf[id].trg_id, 0.0f, 0.0f, 4);
	}
}

void TSKenemy05Draw(int id)
{
	void setVertex(int id, int i)
	{
		float[XYZ] pos;

		pos[X] = sin(TskBuf[id].rot_x + TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].rot_x + TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}

	glColor4f(TskBuf[id].pal_r,TskBuf[id].pal_g,TskBuf[id].pal_b,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < 4; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 4; i < 8; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 8; i < 12; i++) setVertex(id, i);
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
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
