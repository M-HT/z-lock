/*
	Z-LOCK 'MIDDLE-02'

		'middle02.d'

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
								 -8.0f, +8.0f,
								 +0.0f,+24.0f,
								 +8.0f, +8.0f,
								 +0.0f,-24.0f,

								 +0.0f, +0.0f,
								-16.0f, +8.0f,
								-16.0f,+16.0f,
								+16.0f,+16.0f,
								+16.0f, +8.0f,

								 -8.0f, +0.0f,
								-32.0f, +8.0f,
								-32.0f,+16.0f,
								 -8.0f,+24.0f,

								 +8.0f, +0.0f,
								+32.0f, +8.0f,
								+32.0f,+16.0f,
								 +8.0f,+24.0f,

								 -8.0f,-24.0f,
								-16.0f, -8.0f,
								-16.0f,+16.0f,
								 -8.0f,+16.0f,

								 +8.0f,-24.0f,
								+16.0f, -8.0f,
								+16.0f,+16.0f,
								 +8.0f,+16.0f,
							];

void TSKmiddle02(int id)
{
	void seqMove01(int id)
	{
		TskBuf[id].vx  = TskBuf[id].px;
		TskBuf[id].vy  = TskBuf[id].py;
		TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / (WAIT_CNT / 2);
		TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / (WAIT_CNT / 2);
		TskBuf[id].vx -= TskBuf[id].px;
		TskBuf[id].vy -= TskBuf[id].py;
	}

	void seqMove02(int id)
	{
		TskBuf[id].px -= TskBuf[id].vx;
		TskBuf[id].py -= TskBuf[id].vy;
	}

	TskBuf[id].rank = getRank();

	switch(TskBuf[id].step){
		case	0:	// init
			TskBuf[id].tskid |= TSKID_ZAKO;
			if(TskBuf[id].tskid & TSKID_POSSET){
				TskBuf[id].tskid &= ~TSKID_POSSET;
				if((ship_px) > 0.0f){
					TskBuf[id].px = -192.0f + cast(float)(Rand() % 128);
				}else{
					TskBuf[id].px = +192.0f - cast(float)(Rand() % 128);
				}
				TskBuf[id].py = -SCREEN_SY + 64.0f;
			}
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKmiddle02Draw;
			TskBuf[id].fp_exit = &TSKmiddle02Exit;
			TskBuf[id].tid = ship_id;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].vx = 0.0f;
			TskBuf[id].vy = 4.0f;
			TskBuf[id].cx = 48.0f;
			TskBuf[id].cy = 48.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].tx = TskBuf[id].px;
			TskBuf[id].ty = (Rand() % 80) - (80.0f / 2.0f) - 224.0f;
			float[XY] tpos;
			TskBuf[id].body_org.length = enemy_poly.length;
			for(int i = 0; i < enemy_poly.length; i++){
				TskBuf[id].body_org[i] = enemy_poly[i] * 0.75f;
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
			TskBuf[id].energy = 50 + cast(int)(getRank() * 10);
			TskBuf[id].wait = WAIT_CNT + 5;
			setEnemyPallete(id, PAL_R, PAL_G, PAL_B);
			int eid;
			int max;
			max = (stg_level + 1) / 2;
			if(max == 0) max = 1;
			for(int i = 0; i < max; i++){
				eid = setTSK(GROUP_03, &TSKmiddle02Option);
				TskBuf[eid].level_max = enemy_max;
				TskBuf[eid].level = max;
				TskBuf[eid].parent = id;
			}
			TskBuf[id].step++;
			break;
		case	1:	// first-move
			TskBuf[id].alpha += 1.0f / WAIT_CNT;
			if(waitEnemyStep2(id, &TSKmiddle02Int)) TskBuf[id].step++;
			seqMove01(id);
			if(chkEmoveArea(id)) TskBuf[id].step = -1;
			break;
		case	2:	// lock & move
			TskBuf[id].tskid &= ~TSKID_MUTEKI;
			seqMove02(id);
			execEpalFade(id);
			if(chkEmoveArea(id)) TskBuf[id].step = -1;
			break;
		case	3:	// fire & move
			TskBuf[id].tskid &= ~TSKID_MUTEKI;
			seqMove02(id);
			execEpalFade(id);
			if(chkEmoveArea(id)) TskBuf[id].step = -1;
			break;

		case	100:
			playSNDse(SND_SE_EDEST2);
			setQuake(15, 32.0f);
			if(!(TskBuf[id].tskid & TSKID_DESTROY)){
				TskBuf[id].level = 0;
				TSKenemyDest(id,0);
			}else{
				TskBuf[id].level = TskBuf[TskBuf[id].trg_id].level;
				TSKenemyDest(id,100);
			}
			effSetBrokenBody(id, TskBuf[id].body_org,  0, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org,  4, 5,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org,  9, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org, 13, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org, 17, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenBody(id, TskBuf[id].body_org, 21, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,  0, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,  4, 5,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org,  9, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org, 13, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org, 17, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			effSetBrokenLine(id, TskBuf[id].body_org, 21, 4,+0.0f,+0.0f,+3.0f,+3.0f);
			TskBuf[id].step = -1;
			break;

		default:
			clrTSK(id);
			break;

	}
}

void TSKmiddle02Exit(int id)
{
	TskBuf[id].body_ang.length  = 0;
	TskBuf[id].body_org.length  = 0;
}

void TSKmiddle02Int(int id)
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

void TSKmiddle02Draw(int id)
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

	glColor4f(TskBuf[id].pal_r,TskBuf[id].pal_g,TskBuf[id].pal_b,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < 4; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 4; i < 9; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 9; i < 13; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 13; i < 17; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 17; i < 21; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_POLYGON);
	for(int i = 21; i < 25; i++) setVertex(id, i);
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < 4; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_LINE_LOOP);
	for(int i = 4; i < 9; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_LINE_LOOP);
	for(int i = 9; i < 13; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_LINE_LOOP);
	for(int i = 13; i < 17; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_LINE_LOOP);
	for(int i = 17; i < 21; i++) setVertex(id, i);
	glEnd();
	glBegin(GL_LINE_LOOP);
	for(int i = 21; i < 25; i++) setVertex(id, i);
	glEnd();
}


void TSKmiddle02Option(int id)
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
		int parent = TskBuf[id].parent;
		TskBuf[id].px = TskBuf[parent].px;
		TskBuf[id].py = TskBuf[parent].py;
		if(TskBuf[parent].step == -1) TskBuf[id].step = -1;
	}

	TskBuf[id].rank = getRank();

	switch(TskBuf[id].step){
		case	0:	// init
			TskBuf[id].tskid |= TSKID_ZAKO;
			TskBuf[id].fp_exit = &TSKmiddle02OptionExit;
			TskBuf[id].tid = ship_id;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].wait = WAIT_CNT;
			TskBuf[id].cnt = (Rand() % 15) + 1;
			TskBuf[id].mode = 0;
			setBulletType(id);
			seqMove01(id);
			TskBuf[id].step++;
			break;
		case	1:	// move
			TskBuf[id].alpha += 1.0f / WAIT_CNT;
			if(waitEnemyStep(id, null)) TskBuf[id].step++;
			seqMove01(id);
			break;
		case	2:	// lock & move
			if(execEnemyLock(id)) TskBuf[id].step++;
			seqMove01(id);
			break;
		case	3:	// fire & move
			execEnemyBullet(id, cmd, 60 - cast(int)(getRank() * 30), TskBuf[id].type);
			seqMove01(id);
			break;

		default:
			clrTSK(id);
			break;

	}

	if(TskBuf[id].mode == 0){
		TskBuf[id].cnt--;
		if(TskBuf[id].cnt == 0){
			TskBuf[id].mode = 1;
			initEnemyLock(id, 30, 20);
			setEnemyLock(id);
		}
	}
}

void TSKmiddle02OptionExit(int id)
{
	BulletCommand cmd = TskBuf[id].bullet_command;

	destroyEnemyBullet(id, cmd);
}
