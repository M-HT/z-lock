/*
	Z-LOCK 'BG'

		'bg.d'

	2004/02/05 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_snd;
private	import	util_pad;
private	import	define;
private	import	task;
private	import	main;
private	import	stg;
private	import	effect;
private	import	ship;

struct BG_OBJ {
	float[XYZ]		pos;
	float[XYZ]		ang;
	float[XYZ][]	body_pos;
}

private const int BG_STAR_MAX = 1024;
private const int BG_STAR_POSY_MAX = 8;

float[XYZ]	scr_pos;
float[XY]	scr_base;
float[XY]	scr_ofs;
float[XY]	scr_spd;
float[XY]	scr_vel;
float[XY]	scr_trg;
float[XY]	scr_acc;
float[XYZ]	scr_rot;
float[XYZ]	scr_rottrg;
float[XYZ]	scr_rotacc;
float[XYZ]	scr_zoom;

int	bg_disp;
int	bg_id;

private	BG_OBJ[]	bg_obj;

void TSKbg00(int id)
{
	int	eid;
	float[XY] scr;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKbgDraw;
			TskBuf[id].fp_exit = &TSKbgExit;
			scr_pos[X] = 0.0f;
			scr_pos[Y] = 0.0f;
			scr_pos[Z] = 0.0f;
			scr_base[X] = 0.0f;
			scr_base[Y] = 0.0f;
			scr_ofs[X] = 0.0f;
			scr_ofs[Y] = 0.0f;
			scr_spd[X] = 0.0f;
			scr_spd[Y] = 0.0f;
			scr_vel[X] = +0.0f;
			scr_vel[Y] = -1.0f;
			scr_trg[X] = +0.0f;
			scr_trg[Y] = +0.0f;
			scr_acc[X] = +0.0f;
			scr_acc[Y] = +0.0f;
			scr_rot[X] = +0.0f;
			scr_rot[Y] = +0.0f;
			scr_rot[Z] = +0.0f;
			scr_zoom[X] = 0.0f;
			scr_zoom[Y] = 0.0f;
			scr_zoom[Z] = 0.0f;
			bg_disp = 1;
			cam_pos = BASE_Z + cam_scr;
			TskBuf[id].rot = 0.0f;
			bg_obj.length = 32;
			for(int i = 0; i < bg_obj.length; i++){
				bg_obj[i].ang[X] = TskBuf[id].rot + PI_2;
				bg_obj[i].ang[Y] = +0.0f;
				bg_obj[i].ang[Z] = TskBuf[id].rot;
				bg_obj[i].pos[X] = sin(bg_obj[i].ang[X]) * cast(float)SCREEN_X / 2;
				bg_obj[i].pos[Y] = +0.0f;
				bg_obj[i].pos[Z] = sin(bg_obj[i].ang[Z]) * cast(float)SCREEN_Z / 4;
				bg_obj[i].body_pos.length = 2;
				bg_obj[i].body_pos[0][X] =   +0.0f;
				bg_obj[i].body_pos[0][Y] = -640.0f;
				bg_obj[i].body_pos[0][Z] =   +0.0f;
				bg_obj[i].body_pos[1][X] =   +0.0f;
				bg_obj[i].body_pos[1][Y] = +640.0f;
				bg_obj[i].body_pos[1][Z] =   +0.0f;
				TskBuf[id].rot += PI / 16.0f;
			}
			scr_rot[X] = ((Rand() % 384) - (384.0f / 2.0f)) / 100000.0f;
			scr_rot[Z] = scr_rot[X];
			for(int i = 0; i < BG_STAR_MAX; i++){
				setTSK(GROUP_01,&TSKbgStar);
			}
			TskBuf[id].step++;
			break;
		case	1:
			for(int i = 0; i < bg_obj.length; i++){
				bg_obj[i].ang[X] += scr_rot[X];
				bg_obj[i].ang[Z] += scr_rot[Z];
				bg_obj[i].pos[X] = sin(bg_obj[i].ang[X]) * cast(float)SCREEN_X / 2;
				bg_obj[i].pos[Z] = sin(bg_obj[i].ang[Z]) * cast(float)SCREEN_Z / 4;
			}
			scr_pos[X] = scr_base[X] + scr_ofs[X];
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y];
			scr_pos[Z] = scr_zoom[Z];
			scr_spd[X] += scr_vel[X];
			scr_spd[Y] += scr_vel[Y];
			scr[X] = scr_spd[X];
			scr[Y] = scr_spd[Y];
			scr[X] %= 64;
			scr[Y] %= 64;
			scr_spd[X] = scr[X];
			scr_spd[Y] = scr[Y];
			break;

		default:
			clrTSK(id);
			break;
	}
}

void TSKbg01(int id)
{
	int	eid;
	float[XY] scr;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKbgDraw;
			TskBuf[id].fp_exit = &TSKbgExit;
			scr_pos[X] = 0.0f;
			scr_pos[Y] = 0.0f;
			scr_pos[Z] = 0.0f;
			scr_base[X] = 0.0f;
			scr_base[Y] = 0.0f;
			scr_ofs[X] = 0.0f;
			scr_ofs[Y] = 0.0f;
			scr_spd[X] = 0.0f;
			scr_spd[Y] = 0.0f;
			scr_vel[X] = +0.0f;
			scr_vel[Y] = +0.0f;
			scr_trg[X] = +0.0f;
			scr_trg[Y] = +0.0f;
			scr_acc[X] = +0.0f;
			scr_acc[Y] = +0.0f;
			scr_rot[X] = +0.0f;
			scr_rot[Y] = +0.0f;
			scr_rot[Z] = +0.0f;
			scr_zoom[X] = 0.0f;
			scr_zoom[Y] = 0.0f;
			scr_zoom[Z] = 0.0f;
			bg_disp = 0;
			cam_pos = BASE_Z + cam_scr;
			TskBuf[id].rot = 0.0f;
			bg_obj.length = 32;
			for(int i = 0; i < bg_obj.length; i++){
				bg_obj[i].ang[X] = TskBuf[id].rot + PI_2;
				bg_obj[i].ang[Y] = +0.0f;
				bg_obj[i].ang[Z] = TskBuf[id].rot;
				bg_obj[i].pos[X] = sin(bg_obj[i].ang[X]) * cast(float)SCREEN_X / 2;
				bg_obj[i].pos[Y] = +0.0f;
				bg_obj[i].pos[Z] = sin(bg_obj[i].ang[Z]) * cast(float)SCREEN_Z / 4;
				bg_obj[i].body_pos.length = 2;
				bg_obj[i].body_pos[0][X] =   +0.0f;
				bg_obj[i].body_pos[0][Y] = -640.0f;
				bg_obj[i].body_pos[0][Z] =   +0.0f;
				bg_obj[i].body_pos[1][X] =   +0.0f;
				bg_obj[i].body_pos[1][Y] = +640.0f;
				bg_obj[i].body_pos[1][Z] =   +0.0f;
				TskBuf[id].rot += PI / 16.0f;
			}
			for(int i = 0; i < BG_STAR_MAX; i++){
				setTSK(GROUP_01,&TSKbgStar);
			}
			TskBuf[id].step++;
			break;
		case	1:
			for(int i = 0; i < bg_obj.length; i++){
				bg_obj[i].ang[X] += scr_rot[X];
				bg_obj[i].ang[Z] += scr_rot[Z];
				bg_obj[i].pos[X] = sin(bg_obj[i].ang[X]) * cast(float)SCREEN_X / 2;
				bg_obj[i].pos[Z] = sin(bg_obj[i].ang[Z]) * cast(float)SCREEN_Z / 4;
			}
			scr_pos[X] = scr_base[X] + scr_ofs[X];
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y];
			scr_pos[Z] = scr_zoom[Z];
			scr_spd[X] += scr_vel[X];
			scr_spd[Y] += scr_vel[Y];
			scr[X] = scr_spd[X];
			scr[Y] = scr_spd[Y];
			scr[X] %= 64;
			scr[Y] %= 64;
			scr_spd[X] = scr[X];
			scr_spd[Y] = scr[Y];
			break;

		default:
			clrTSK(id);
			break;
	}
}

void TSKbgDraw(int id)
{
	float y,z;
	float[XYZ] pos;

	if(!bg_disp) return;

	z = BASE_Z - cam_pos;

	/* 背景 */
	glBegin(GL_QUADS);
	glColor4f(0.01f,0.01f,0.01f,1.0f);
	glVertex3f(getPointX(-(SCREEN_X / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_X / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();

	/* 縦線*/
	for(int i = 0; i < bg_obj.length; i++){
		pos[Z] = getPointZ(bg_obj[i].pos[Z] + scr_pos[Z], 0.0f);
		if(pos[Z] > 0.0f) continue;
		glColor4f(0.50f,0.80f,1.00f,1.0+pos[Z]*1.75f);
		glBegin(GL_LINES);
		pos[X] = getPointX(bg_obj[i].pos[X] - bg_obj[i].body_pos[0][X], pos[Z]);
		pos[Y] = getPointY(bg_obj[i].pos[Y] - bg_obj[i].body_pos[0][Y], pos[Z]);
		glVertex3f(pos[X], pos[Y], pos[Z]);
		pos[X] = getPointX(bg_obj[i].pos[X] - bg_obj[i].body_pos[1][X], pos[Z]);
		pos[Y] = getPointY(bg_obj[i].pos[Y] - bg_obj[i].body_pos[1][Y], pos[Z]);
		glVertex3f(pos[X], pos[Y], pos[Z]);
		glEnd();
	}

	/* 横線 */
	y = 0.0f;
	for(int i = 0; i < (1280 / 64) + 1; i++){
		glBegin(GL_LINE_LOOP);
		for(int j = 0; j < bg_obj.length; j++){
			pos[Z] = getPointZ(bg_obj[j].pos[Z] + scr_pos[Z], 0.0f);
			if(pos[Z] < 0.0f) glColor4f(0.50f,0.80f,1.00f,1.0+pos[Z]*1.75f);
			else			  glColor4f(0.50f,0.80f,1.00f,0.0f);
			pos[X] = getPointX(bg_obj[j].pos[X]     + scr_pos[X] + scr_spd[X] - bg_obj[j].body_pos[0][X], pos[Z]);
			pos[Y] = getPointY(bg_obj[j].pos[Y] + y + scr_pos[Y] + scr_spd[Y] - bg_obj[j].body_pos[0][Y], pos[Z]);
			glVertex3f(pos[X], pos[Y], pos[Z]);
		}
		y -= 64.0f;
		glEnd();
	}
}

void TSKbgExit(int id)
{
	for(int i = 0; i < bg_obj.length; i++){
		bg_obj[i].body_pos.length = 0;
	}
	bg_obj.length = 0;
}

void TSKbgStar(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = cast(float)(Rand() % 2048) - 1024.0f;
			TskBuf[id].py = cast(float)(Rand() % 2048) - 1024.0f;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgStarDraw;
			TskBuf[id].vy = (Rand() % 10000) / 10000.0f * 4.0f * 0.25f;
			TskBuf[id].body_org.length = BG_STAR_POSY_MAX;
			TskBuf[id].body_org[] = TskBuf[id].py;
			TskBuf[id].cy = TskBuf[id].body_org[(BG_STAR_POSY_MAX - 1)];
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].py += TskBuf[id].vy - scr_vel[Y];
			for(int i = (BG_STAR_POSY_MAX - 1); i > 0; i--){
				TskBuf[id].body_org[i] = TskBuf[id].body_org[i-1];
			}
			TskBuf[id].body_org[0] = TskBuf[id].py;
			if(TskBuf[id].py > 1024.0f){
				TskBuf[id].py -= 2048f;
				TskBuf[id].body_org[] = TskBuf[id].py;
			}
			TskBuf[id].cy = TskBuf[id].body_org[(BG_STAR_POSY_MAX - 1)];
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKbgStarDraw(int id)
{
	float pz;

	glBegin(GL_LINES);
	glColor4f(1.0f,1.0f,1.0f,0.5f);
	pz = getPointZ(TskBuf[id].pz + scr_pos[Z], 0.0f);
	glVertex3f(getPointX(-TskBuf[id].px - scr_pos[X], pz),
			   getPointY(-TskBuf[id].py - scr_pos[Y], pz),
			   0.0f);
	glColor4f(1.0f,1.0f,1.0f,0.0f);
	pz = getPointZ(TskBuf[id].pz + scr_pos[Z], 0.0f);
	glVertex3f(getPointX(-TskBuf[id].px - scr_pos[X], pz),
			   getPointY(-TskBuf[id].cy - scr_pos[Y], pz),
			   0.0f);
	glEnd();
}

void TSKbgMask(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgMaskDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].step++;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKbgMaskDraw(int id)
{
	float	z;

	z = BASE_Z - cam_pos;

	/* 背景 */
	glDisable(GL_BLEND);
	glBegin(GL_QUADS);
	glColor4f(0.01f,0.01f,0.01f,1.0f);
	glVertex3f(getPointX(-(SCREEN_X / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X / 2), z),
			   getPointY(-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_X / 2), z),
			   getPointY(+(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();
	glEnable(GL_BLEND);
}

void TSKbgFrame(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgFrameDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKbgFrameDraw(int id)
{
	float	z;

	z = BASE_Z - cam_pos;

	glDisable(GL_BLEND);
	glColor3f(0.025f,0.025f,0.025f);
	glBegin(GL_QUADS);
	glVertex3f(getPointX(-(SCREEN_X  / 2), z),
			   getPointY(-(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_X  / 2), z),
			   getPointY(+(SCREEN_SY / 2), z),
			   0.0f);

	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X  / 2), z),
			   getPointY(-(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_X  / 2), z),
			   getPointY(+(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2), z),
			   0.0f);
	glEnd();
	glEnable(GL_BLEND);
}

void setQuake(int frame, float quake)
{
	int	eid;

	eid = setTSK(GROUP_01,&TSKbgQuake);
	TskBuf[eid].wait = frame;
	TskBuf[eid].vx = quake;
	TskBuf[eid].vy = quake;
}

void TSKbgQuake(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].cnt = TskBuf[id].wait / 2;
			TskBuf[id].cnt = (TskBuf[id].cnt ? TskBuf[id].cnt : 1);
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].px  = ((Rand() % (256.0f * TskBuf[id].vx)) - ((256.0f * TskBuf[id].vx) / 2)) / 256.0f;
				TskBuf[id].py  = ((Rand() % (256.0f * TskBuf[id].vy)) - ((256.0f * TskBuf[id].vy) / 2)) / 256.0f;
				TskBuf[id].vx += (0.0f - TskBuf[id].vx) / TskBuf[id].cnt;
				TskBuf[id].vy += (0.0f - TskBuf[id].vy) / TskBuf[id].cnt;
				scr_ofs[X] = TskBuf[id].px;
				scr_ofs[Y] = TskBuf[id].py;
				TskBuf[id].wait--;
			}else{
				scr_ofs[X] = 0.0f;
				scr_ofs[Y] = 0.0f;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void setBGspeed(int frame, float sx, float sy)
{
	int	eid;

	eid = setTSK(GROUP_01,&TSKbgSpeed);
	TskBuf[eid].wait = frame;
	scr_trg[X] = sx;
	scr_trg[Y] = sy;
}

void TSKbgSpeed(int id)
{
	switch(TskBuf[id].step){
		case	0:
			if(TskBuf[id].wait){
				scr_acc[X] = (scr_trg[X] - scr_vel[X]) / TskBuf[id].wait;
				scr_acc[Y] = (scr_trg[Y] - scr_vel[Y]) / TskBuf[id].wait;
				TskBuf[id].step++;
			}else{
				scr_acc[X] = +0.0f;
				scr_acc[Y] = +0.0f;
				scr_vel[X] = scr_trg[X];
				scr_vel[Y] = scr_trg[Y];
				TskBuf[id].step = -1;
			}
			break;
		case	1:
			if(TskBuf[id].wait){
				scr_vel[X] += scr_acc[X];
				scr_vel[Y] += scr_acc[Y];
				TskBuf[id].wait--;
			}else{
				scr_acc[X] = +0.0f;
				scr_acc[Y] = +0.0f;
				scr_vel[X] = scr_trg[X];
				scr_vel[Y] = scr_trg[Y];
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void setBGrot(int frame, float rot)
{
	int	eid;

	eid = setTSK(GROUP_01,&TSKbgRot);
	TskBuf[eid].wait = frame;
	scr_rottrg[X] = rot;
	scr_rottrg[Z] = rot;
}

void TSKbgRot(int id)
{
	switch(TskBuf[id].step){
		case	0:
			if(TskBuf[id].wait){
				scr_rotacc[X] = (scr_rottrg[X] - scr_rot[X]) / TskBuf[id].wait;
				scr_rotacc[Z] = (scr_rottrg[Z] - scr_rot[Z]) / TskBuf[id].wait;
				TskBuf[id].step++;
			}else{
				scr_rotacc[X] = +0.0f;
				scr_rotacc[Z] = +0.0f;
				scr_rot[X] = scr_rottrg[X];
				scr_rot[Z] = scr_rottrg[Z];
				TskBuf[id].step = -1;
			}
			break;
		case	1:
			if(TskBuf[id].wait){
				scr_rot[X] += scr_rotacc[X];
				scr_rot[Z] += scr_rotacc[Z];
				TskBuf[id].wait--;
			}else{
				scr_rotacc[X] = +0.0f;
				scr_rotacc[Z] = +0.0f;
				scr_rot[X] = scr_rottrg[X];
				scr_rot[Z] = scr_rottrg[Z];
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void setBGzoom(int frame, float zoom)
{
	int	eid;

	eid = setTSK(GROUP_01,&TSKbgZoom);
	TskBuf[eid].wait = frame;
	TskBuf[eid].tx = zoom;
}

void TSKbgZoom(int id)
{
	switch(TskBuf[id].step){
		case	0:
			if(TskBuf[id].wait){
				TskBuf[id].vx = (TskBuf[id].tx - scr_zoom[Z]) / TskBuf[id].wait;
				TskBuf[id].step++;
			}else{
				scr_zoom[Z] = TskBuf[id].tx;
				TskBuf[id].step = -1;
			}
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				scr_zoom[Z] += TskBuf[id].vx;
			}else{
				scr_zoom[Z] = TskBuf[id].tx;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}


