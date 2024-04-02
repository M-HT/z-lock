/*
	Z-LOCK 'EFFCTE'

		'effect.d'

	2004/03/31 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.string;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	task;
private	import	main;
private	import	bg;
private	import	ship;

float	fade_r = 0.0f;
float	fade_g = 0.0f;
float	fade_b = 0.0f;
float	fade_a = 0.0f;

int	fade_id;

void effSetParticle00(int id, float ofs_x, float ofs_y, int cnt)
{
	int	eid;

	for(int i = 0; i < cnt; i++){
		eid = setTSK(GROUP_07,&TSKparticle00);
		if(eid != -1){
			TskBuf[eid].px = TskBuf[id].px + ofs_x;
			TskBuf[eid].py = TskBuf[id].py + ofs_y;
		}
	}
}

void TSKparticle00(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKparticle00Draw;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].rot = (Rand() % 10000) / 10000.0f * PI * 2;
			TskBuf[id].rad_x = Rand() % 256 + 256.0f;
			TskBuf[id].tx  = sin(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].ty  = cos(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].wait = 30;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 60.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 60.0f;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (1.0f / 30.0f);
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKparticle00Draw(int id)
{
	glColor4f(1.0f,1.0f,0.0f,TskBuf[id].alpha);
	glBegin(GL_POINTS);
	glVertex3f(getPointX(-TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
			   getPointY(-TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
			   0.0f);
	glEnd();
}

void effSetParticle01(int id, float ofs_x, float ofs_y, int cnt)
{
	int	eid;

	for(int i = 0; i < cnt; i++){
		eid = setTSK(GROUP_07,&TSKparticle01);
		if(eid != -1){
			TskBuf[eid].px = TskBuf[id].px + ofs_x;
			TskBuf[eid].py = TskBuf[id].py + ofs_y;
		}
	}
}

void TSKparticle01(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKparticle01Draw;
			TskBuf[id].fp_exit = &TSKparticle01Exit;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].alpha = 0.625f;
			TskBuf[id].body_ang.length  = 3;
			{
				float[XY] tpos;
				for(int i = 0; i < 3; i++){
					switch(i){
						case	0:
								tpos[X] = -((Rand() % 4096) / 1024.0f + 1.0f);
								tpos[Y] = +((Rand() % 4096) / 1024.0f + 1.0f);
								break;
						case	1:
								tpos[X] =  ((Rand() % 2048) / 1024.0f - 1.0f);
								tpos[Y] = -((Rand() % 4096) / 1024.0f + 1.0f);
								break;
						case	2:
								tpos[X] = +((Rand() % 4096) / 1024.0f + 1.0f);
								tpos[Y] = +((Rand() % 4096) / 1024.0f + 1.0f);
								break;
						default:
								break;
					}
					TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Z] = 0.0f;
					tpos[X] = fabs(tpos[X]);
					tpos[Y] = fabs(tpos[Y]);
					TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
				}
			}

			TskBuf[id].rot = (Rand() % 10000) / 10000.0f * PI * 2;
			TskBuf[id].rad_x = Rand() % 256 + 256.0f;
			TskBuf[id].tx  = sin(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].ty  = cos(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 120.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 120.0f;
			TskBuf[id].rot += PI / 30;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (0.625f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKparticle01Draw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.25f,0.0f,0.0f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}

void TSKparticle01Exit(int id)
{
	TskBuf[id].body_ang.length  = 0;
}

void effSetParticle02(int id, float ofs_x, float ofs_y, int cnt)
{
	int	eid;

	for(int i = 0; i < cnt; i++){
		eid = setTSK(GROUP_07,&TSKparticle02);
		if(eid != -1){
			TskBuf[eid].px = TskBuf[TskBuf[id].trg_id].px + ofs_x;
			TskBuf[eid].py = TskBuf[TskBuf[id].trg_id].py + ofs_y;
		}
	}
}

void TSKparticle02(int id)
{
	float[XY]	tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKparticle02Draw;
			TskBuf[id].fp_exit = &TSKparticle02Exit;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.625f;
			TskBuf[id].body_ang.length  = 3;
			for(int i = 0; i < 3; i++){
				switch(i){
					case	0:
							tpos[X] = -((Rand() % 12288) / 1024.0f + 3.0f);
							tpos[Y] = +((Rand() % 12288) / 1024.0f + 3.0f);
							break;
					case	1:
							tpos[X] =  ((Rand() %  6144) / 1024.0f - 3.0f);
							tpos[Y] = -((Rand() % 12288) / 1024.0f + 3.0f);
							break;
					case	2:
							tpos[X] = +((Rand() % 12288) / 1024.0f + 3.0f);
							tpos[Y] = +((Rand() % 12288) / 1024.0f + 3.0f);
							break;
					default:
							break;
				}
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}

			TskBuf[id].rot = (Rand() % 10000) / 10000.0f * PI * 2;
			TskBuf[id].rad_x = Rand() % 512 + 512.0f;
			TskBuf[id].tx  = sin(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].ty  = cos(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 120.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 120.0f;
			TskBuf[id].rot += PI / 30;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (0.625f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKparticle02Draw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.25f,0.25f,0.00f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < 3; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}

void TSKparticle02Exit(int id)
{
	TskBuf[id].body_ang.length  = 0;
}

void effSetBrokenBody(int id, float[] poly_tbl,int start, int cnt, float ofs_x, float ofs_y, float sx, float sy)
{
	float[XY] tpos;
	float[XY] pos;
	int eid;

	pos[X] = 0.0f;
	pos[Y] = 0.0f;
	for(int i = 0; i < cnt; i++){
		pos[X] += poly_tbl[(start+i)*2+0];
		pos[Y] += poly_tbl[(start+i)*2+1];
	}
	pos[X] /= cnt;
	pos[Y] /= cnt;

	eid = setTSK(GROUP_01,&TSKBrokenBody);
	TskBuf[eid].px = TskBuf[id].px + ofs_x;
	TskBuf[eid].py = TskBuf[id].py + ofs_y;
	TskBuf[eid].sx = sx;
	TskBuf[eid].sy = sy;
	TskBuf[eid].pz = TskBuf[id].pz;
	TskBuf[eid].rot = TskBuf[id].rot;
	TskBuf[eid].body_ang.length  = cnt;
	for(int i = 0; i < cnt; i++){
		tpos[X] = poly_tbl[(start+i)*2+0] + ofs_x - pos[X];
		tpos[Y] = poly_tbl[(start+i)*2+1] + ofs_y - pos[Y];
		TskBuf[eid].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
		TskBuf[eid].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
		TskBuf[eid].body_ang[i][Z] = 0.0f;
		TskBuf[eid].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
	}
}

void effSetBrokenBody2(int id, float[] poly_tbl,int start, int cnt, float ofs_x, float ofs_y, float sx, float sy)
{
	float[XY] tpos;
	float[XY] pos;
	int eid;

	pos[X] = 0.0f;
	pos[Y] = 0.0f;
	for(int i = 0; i < cnt; i++){
		pos[X] += poly_tbl[(start+i)*2+0];
		pos[Y] += poly_tbl[(start+i)*2+1];
	}
	pos[X] /= cnt;
	pos[Y] /= cnt;

	eid = setTSK(GROUP_01,&TSKBrokenBody);
	TskBuf[eid].px = TskBuf[id].px + ofs_x;
	TskBuf[eid].py = TskBuf[id].py + ofs_y;
	TskBuf[eid].sx = sx;
	TskBuf[eid].sy = sy;
	TskBuf[eid].pz = TskBuf[id].pz;
	TskBuf[eid].rot = TskBuf[id].rot;
	TskBuf[eid].body_ang.length  = cnt;
	for(int i = 0; i < cnt; i++){
		tpos[X] = poly_tbl[(start+i)*2+0] - pos[X];
		tpos[Y] = poly_tbl[(start+i)*2+1] - pos[Y];
		TskBuf[eid].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
		TskBuf[eid].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
		TskBuf[eid].body_ang[i][Z] = 0.0f;
		TskBuf[eid].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
	}
}

void TSKBrokenBody(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKBrokenBodyDraw;
			TskBuf[id].fp_exit = &TSKBrokenBodyExit;
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].rot = (Rand() % 10000) / 10000.0f * PI * 2;
			TskBuf[id].rad_x  = Rand() % 256 + 256.0f;
			TskBuf[id].tx  = sin(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].ty  = cos(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].tz  = ((Rand() % 10000) / 5000.0f - 1.0f) / 0.25f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].tz += TskBuf[id].pz;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].rot_add = (Rand() % 30) - 15.0f;
			if(!(TskBuf[id].rot_add - 15))		TskBuf[id].rot_add = -1;
			else if(!(TskBuf[id].rot_add + 15)) TskBuf[id].rot_add = +1;
			if(TskBuf[id].rot_add < 0) TskBuf[id].rot_add = PI / (TskBuf[id].rot_add - 15);
			else					   TskBuf[id].rot_add = PI / (TskBuf[id].rot_add + 15);
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 120.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 120.0f;
			TskBuf[id].pz += (TskBuf[id].tz - TskBuf[id].pz) / 120.0f;
			TskBuf[id].rot += TskBuf[id].rot_add;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (1.0f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKBrokenBodyDraw(int id)
{
	float[XYZ]	pos;

	void setVertex(int id, int i)
	{
		float[XYZ] pos;

		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * TskBuf[id].sx, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * TskBuf[id].sy, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}

	glColor4f(0.5f,0.5f,0.5f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++) setVertex(id, i);
	glEnd();
}

void TSKBrokenBodyExit(int id)
{
	TskBuf[id].body_ang.length  = 0;
}

void effSetBrokenLine(int id, float[] poly_tbl,int start, int cnt, float ofs_x, float ofs_y, float sx, float sy)
{
	float[XY] tpos1;
	float[XY] tpos2;
	float[XY] cen;
	int eid;

	tpos1[X] = poly_tbl[start*2+0] + ofs_x;
	tpos1[Y] = poly_tbl[start*2+1] + ofs_y;
	for(int i = 1; i < cnt; i++){
		tpos2[X] = poly_tbl[(start+i)*2+0] + ofs_x;
		tpos2[Y] = poly_tbl[(start+i)*2+1] + ofs_y;
		cen[X] = (tpos1[X] + tpos2[X]) / 2.0f;
		cen[Y] = (tpos1[Y] + tpos2[Y]) / 2.0f;
		eid = setTSK(GROUP_01,&TSKBrokenLine);
		TskBuf[eid].px = TskBuf[id].px + ofs_x;
		TskBuf[eid].py = TskBuf[id].py + ofs_y;
		TskBuf[eid].pz = TskBuf[id].pz;
		TskBuf[eid].rot = TskBuf[id].rot;
		TskBuf[eid].body_ang.length  = 2;
		TskBuf[eid].body_ang[0][X] = atan2(tpos1[X]-cen[X], tpos1[Y]-cen[Y]);
		TskBuf[eid].body_ang[0][Y] = atan2(tpos1[X]-cen[X], tpos1[Y]-cen[Y]);
		TskBuf[eid].body_ang[0][Z] = 0.0f;
		TskBuf[eid].body_ang[1][X] = atan2(tpos2[X]-cen[X], tpos2[Y]-cen[Y]);
		TskBuf[eid].body_ang[1][Y] = atan2(tpos2[X]-cen[X], tpos2[Y]-cen[Y]);
		TskBuf[eid].body_ang[1][Z] = 0.0f;
		TskBuf[eid].body_ang[0][W] = sqrt(pow(tpos1[X],2.0) + pow(tpos1[Y],2.0));
		TskBuf[eid].body_ang[1][W] = sqrt(pow(tpos2[X],2.0) + pow(tpos2[Y],2.0));
		tpos1[X] = tpos2[X];
		tpos1[Y] = tpos2[Y];
	}
	tpos2[X] = poly_tbl[start*2+0] + ofs_x;
	tpos2[Y] = poly_tbl[start*2+1] + ofs_y;
	cen[X] = (tpos1[X] - tpos2[X]) / 2.0f;
	cen[Y] = (tpos1[Y] - tpos2[Y]) / 2.0f;
	eid = setTSK(GROUP_01,&TSKBrokenLine);
	TskBuf[eid].px = TskBuf[id].px + ofs_x;
	TskBuf[eid].py = TskBuf[id].py + ofs_y;
	TskBuf[eid].pz = TskBuf[id].pz;
	TskBuf[eid].sx = sx;
	TskBuf[eid].sy = sy;
	TskBuf[eid].rot = TskBuf[id].rot;
	TskBuf[eid].body_ang.length  = 2;
	TskBuf[eid].body_ang[0][X] = atan2(tpos1[X]+cen[X], tpos1[Y]+cen[Y]);
	TskBuf[eid].body_ang[0][Y] = atan2(tpos1[X]+cen[X], tpos1[Y]+cen[Y]);
	TskBuf[eid].body_ang[0][Z] = 0.0f;
	TskBuf[eid].body_ang[1][X] = atan2(tpos2[X]+cen[X], tpos2[Y]+cen[Y]);
	TskBuf[eid].body_ang[1][Y] = atan2(tpos2[X]+cen[X], tpos2[Y]+cen[Y]);
	TskBuf[eid].body_ang[1][Z] = 0.0f;
	TskBuf[eid].body_ang[0][W] = sqrt(pow(tpos2[X]+cen[X],2.0) + pow(tpos2[Y]+cen[Y],2.0));
	TskBuf[eid].body_ang[1][W] = sqrt(pow(tpos2[X]+cen[X],2.0) + pow(tpos2[Y]+cen[Y],2.0));
}

void effSetBrokenLine2(int id, float[] poly_tbl,int start, int cnt, float ofs_x, float ofs_y, float sx, float sy)
{
	float[XY] tpos1;
	float[XY] tpos2;
	float[XY] cen;
	int eid;

	tpos1[X] = poly_tbl[start*2+0];
	tpos1[Y] = poly_tbl[start*2+1];
	for(int i = 1; i < cnt; i++){
		tpos2[X] = poly_tbl[(start+i)*2+0] + ofs_x;
		tpos2[Y] = poly_tbl[(start+i)*2+1] + ofs_y;
		cen[X] = (tpos1[X] + tpos2[X]) / 2.0f;
		cen[Y] = (tpos1[Y] + tpos2[Y]) / 2.0f;
		eid = setTSK(GROUP_01,&TSKBrokenLine);
		TskBuf[eid].px = TskBuf[id].px + ofs_x;
		TskBuf[eid].py = TskBuf[id].py + ofs_y;
		TskBuf[eid].pz = TskBuf[id].pz;
		TskBuf[eid].rot = TskBuf[id].rot;
		TskBuf[eid].body_ang.length  = 2;
		TskBuf[eid].body_ang[0][X] = atan2(tpos1[X]-cen[X], tpos1[Y]-cen[Y]);
		TskBuf[eid].body_ang[0][Y] = atan2(tpos1[X]-cen[X], tpos1[Y]-cen[Y]);
		TskBuf[eid].body_ang[0][Z] = 0.0f;
		TskBuf[eid].body_ang[1][X] = atan2(tpos2[X]-cen[X], tpos2[Y]-cen[Y]);
		TskBuf[eid].body_ang[1][Y] = atan2(tpos2[X]-cen[X], tpos2[Y]-cen[Y]);
		TskBuf[eid].body_ang[1][Z] = 0.0f;
		TskBuf[eid].body_ang[0][W] = sqrt(pow(tpos1[X],2.0) + pow(tpos1[Y],2.0));
		TskBuf[eid].body_ang[1][W] = sqrt(pow(tpos2[X],2.0) + pow(tpos2[Y],2.0));
		tpos1[X] = tpos2[X];
		tpos1[Y] = tpos2[Y];
	}
	tpos2[X] = poly_tbl[start*2+0];
	tpos2[Y] = poly_tbl[start*2+1];
	cen[X] = (tpos1[X] - tpos2[X]) / 2.0f;
	cen[Y] = (tpos1[Y] - tpos2[Y]) / 2.0f;
	eid = setTSK(GROUP_01,&TSKBrokenLine);
	TskBuf[eid].px = TskBuf[id].px + ofs_x;
	TskBuf[eid].py = TskBuf[id].py + ofs_y;
	TskBuf[eid].pz = TskBuf[id].pz;
	TskBuf[eid].sx = sx;
	TskBuf[eid].sy = sy;
	TskBuf[eid].rot = TskBuf[id].rot;
	TskBuf[eid].body_ang.length  = 2;
	TskBuf[eid].body_ang[0][X] = atan2(tpos1[X]+cen[X], tpos1[Y]+cen[Y]);
	TskBuf[eid].body_ang[0][Y] = atan2(tpos1[X]+cen[X], tpos1[Y]+cen[Y]);
	TskBuf[eid].body_ang[0][Z] = 0.0f;
	TskBuf[eid].body_ang[1][X] = atan2(tpos2[X]+cen[X], tpos2[Y]+cen[Y]);
	TskBuf[eid].body_ang[1][Y] = atan2(tpos2[X]+cen[X], tpos2[Y]+cen[Y]);
	TskBuf[eid].body_ang[1][Z] = 0.0f;
	TskBuf[eid].body_ang[0][W] = sqrt(pow(tpos2[X]+cen[X],2.0) + pow(tpos2[Y]+cen[Y],2.0));
	TskBuf[eid].body_ang[1][W] = sqrt(pow(tpos2[X]+cen[X],2.0) + pow(tpos2[Y]+cen[Y],2.0));
}

void TSKBrokenLine(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKBrokenLineDraw;
			TskBuf[id].fp_exit = &TSKBrokenLineExit;
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].rot = (Rand() % 100) / 100.0f * PI * 2;
			TskBuf[id].rad_x  = Rand() % 256 + 256.0f;
			TskBuf[id].tx  = sin(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].ty  = cos(TskBuf[id].rot) * TskBuf[id].rad_x;
			TskBuf[id].tz  = ((Rand() % 10000) / 5000.0f - 1.0f) / 0.25f;
			TskBuf[id].tx += TskBuf[id].px;
			TskBuf[id].ty += TskBuf[id].py;
			TskBuf[id].tz += TskBuf[id].pz;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].rot_add = (Rand() % 30) - 15.0f;
			if(!(TskBuf[id].rot_add - 15))		TskBuf[id].rot_add = -1;
			else if(!(TskBuf[id].rot_add + 15)) TskBuf[id].rot_add = +1;
			if(TskBuf[id].rot_add < 0) TskBuf[id].rot_add = PI / (TskBuf[id].rot_add - 15);
			else					   TskBuf[id].rot_add = PI / (TskBuf[id].rot_add + 15);
			TskBuf[id].wait = 60;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 120.0f;
			TskBuf[id].py += (TskBuf[id].ty - TskBuf[id].py) / 120.0f;
			TskBuf[id].pz += (TskBuf[id].tz - TskBuf[id].pz) / 120.0f;
			TskBuf[id].rot += TskBuf[id].rot_add;
			TskBuf[id].wait--;
			if(!TskBuf[id].wait) TskBuf[id].step = -1;
			TskBuf[id].alpha -= (1.0f / 60.0f);
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKBrokenLineDraw(int id)
{
	float[XYZ]	pos;

	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINES);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * TskBuf[id].sx, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * TskBuf[id].sy, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}

void TSKBrokenLineExit(int id)
{
	TskBuf[id].body_ang.length  = 0;
}

void TSKfadeAlpha(int id)
{
	switch(TskBuf[id].step){
		case	0:
			fade_id = id;
			TskBuf[id].px = +0.0f;
			TskBuf[id].py = +0.0f;
			TskBuf[id].fp_draw = &TSKfadeAlphaDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		case	2:
			if(TskBuf[id].wait) TskBuf[id].vx = (TskBuf[id].tx - fade_a) / TskBuf[id].wait;
			TskBuf[id].step++;
			goto case;
		case	3:
			if(TskBuf[id].wait){
				fade_a += TskBuf[id].vx;
				TskBuf[id].wait--;
			}else{
				fade_a = TskBuf[id].tx;
				TskBuf[id].step = 1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKfadeAlphaDraw(int id)
{
	float	z;

	if(fade_a == 0.0f) return;

	z = BASE_Z - cam_pos;

	glBegin(GL_QUADS);
	glColor4f(fade_r,fade_g,fade_b,fade_a);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();
}

void TSKfade(int id)
{
	switch(TskBuf[id].step){
		case	0:
			fade_id = id;
			TskBuf[id].px = +0.0f;
			TskBuf[id].py = +0.0f;
			TskBuf[id].fp_draw = &TSKfadeDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		case	2:
			if(TskBuf[id].wait) TskBuf[id].vx = (TskBuf[id].tx - fade_a) / TskBuf[id].wait;
			TskBuf[id].step++;
			goto case;
		case	3:
			if(TskBuf[id].wait){
				fade_a += TskBuf[id].vx;
				TskBuf[id].wait--;
			}else{
				fade_a = TskBuf[id].tx;
				TskBuf[id].step = 1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKfadeDraw(int id)
{
	float	z;

	if(fade_a == 0.0f) return;

	z = BASE_Z - cam_pos;

    glBlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);
	glBegin(GL_QUADS);
	glColor4f(fade_r,fade_g,fade_b,fade_a);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px-(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py+(SCREEN_Y / 2), z),
			   0.0f);
	glVertex3f(getPointX(TskBuf[id].px+(SCREEN_Y / 2), z),
			   getPointY(TskBuf[id].py-(SCREEN_Y / 2), z),
			   0.0f);
	glEnd();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}
