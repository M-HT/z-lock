/*
	Z-LOCK 'SYSTEM INFO'

		'sysinfo.d'

	2004/09/23 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.stream;
private	import	std.string;
private	import	std.math;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_glbf;
private	import	util_snd;
private	import	util_pad;
private	import	util_ascii;
private	import	main;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	bg;
private	import	ship;
private	import	stg;

private	float[]	shipleft_body = [
								 -2.0f,+0.0f,
								 +0.0f,+4.0f,
								 +2.0f,+0.0f,
								];

private	char[]	str_buf;

void sysinfoINIT(int size)
{
	str_buf.length = size;
}

void sysinfoEXIT()
{
	str_buf.length = 0;
}

void TSKsysinfo(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKsysinfoDraw;
			{
				float[XY] tpos;
				TskBuf[id].body_ang.length = shipleft_body.length / 2;
				for(int i = 0; i < TskBuf[id].body_ang.length; i++){
					tpos[X] = shipleft_body[i*2+0];
					tpos[Y] = shipleft_body[i*2+1];
					TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Z] = 0.0f;
					tpos[X] = fabs(tpos[X]);
					tpos[Y] = fabs(tpos[Y]);
					TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
				}
				for(int i = 0; i < TskBuf[id].body_ang.length; i++){
					tpos[X] = shipleft_body[i*2+0];
					tpos[Y] = shipleft_body[i*2+1];
					TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
					TskBuf[id].body_ang[i][Z] = 0.0f;
					tpos[X] = fabs(tpos[X]);
					tpos[Y] = fabs(tpos[Y]);
					TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
				}
			}
			TskBuf[id].cnt = 60;
			TskBuf[id].num = 0;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].cnt--;
			if(TskBuf[id].cnt == 0){
				TskBuf[id].num++;
				TskBuf[id].num %= 6;
				if(TskBuf[id].num & 0x01) TskBuf[id].cnt = 15;
				else					  TskBuf[id].cnt = 60;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKsysinfoDraw(int id)
{
	float[XYZ] pos;
	float px,py;
	float z;

	/* score */
	str_buf  = "SCORE ";
	if(score < 100000000) str_buf ~= "0";
	if(score < 10000000 ) str_buf ~= "0";
	if(score < 1000000  ) str_buf ~= "0";
	if(score < 100000   ) str_buf ~= "0";
	if(score < 10000    ) str_buf ~= "0";
	if(score < 1000     ) str_buf ~= "0";
	if(score < 100      ) str_buf ~= "0";
	if(score < 10       ) str_buf ~= "0";
	str_buf ~= toString(score);
	glColor3f(1.0f,1.0f,1.0f);
	glbfPrintBegin();
    px = -(SCREEN_SX / 2) + 6;
    py = +(SCREEN_SY / 2) - 16;
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

	/* time */
	int	tmin,tsec,tmsec;
	tmin  = time / ONE_MIN;
	tsec  = time / ONE_SEC % ONE_SEC;
	tmsec = ((time % ONE_SEC) * 100 / ONE_SEC);
	str_buf  = "TIME ";
	str_buf ~= toString(tmin);
	str_buf ~= ":";
	if(tsec < 10) str_buf ~= "0";
	str_buf ~= toString(tsec);
	str_buf ~= ":";
	if(tmsec < 10) str_buf ~= "0";
	str_buf ~= toString(tmsec);
	glbfPrintBegin();
    px = +(SCREEN_SX / 2) - glbfGetWidth(font, str_buf, 0.75f) - 4;
    py = +(SCREEN_SY / 2) - 16;
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

	/* sector */
	glbfPrintBegin();
	if(replay_flag == 1){
		switch(game_mode){
			case	GMODE_NORMAL:
			case	GMODE_CONCEPT:
			case	GMODE_ORIGINAL:
			case	GMODE_HIDDEN:
				int ret = stg_num;
				str_buf = "SECTOR-";
				if(stg_num > 999){
					ret %= 1000;
					if(ret < 100) str_buf ~= "0";
					if(ret < 10 ) str_buf ~= "0";
				}
				str_buf ~= toString(ret);
				break;
			case	GMODE_SCORE:
				str_buf = " SCORE-ATK";
				break;
			case	GMODE_TIME:
				str_buf = "  TIME-ATK";
				break;
			default:
				assert(false);
		}
	}else{
		if(TskBuf[id].num == 0){
			switch(game_mode){
				case	GMODE_NORMAL:
				case	GMODE_CONCEPT:
				case	GMODE_ORIGINAL:
				case	GMODE_HIDDEN:
					int ret = stg_num;
					str_buf = "SECTOR-";
					if(stg_num > 999){
						ret %= 1000;
						if(ret < 100) str_buf ~= "0";
						if(ret < 10 ) str_buf ~= "0";
					}
					str_buf ~= toString(ret);
					break;
				case	GMODE_SCORE:
					str_buf = " SCORE-ATK";
					break;
				case	GMODE_TIME:
					str_buf = "  TIME-ATK";
					break;
				default:
					assert(false);
			}
		}else if(TskBuf[id].num == 2){
			str_buf = "REPLAY";
		}else if(TskBuf[id].num == 4){
			str_buf = "EXIT - SHOT KEY";
		}else{
			str_buf = "";
		}
	}
    px = +(SCREEN_SX / 2) - glbfGetWidth(font, str_buf, 0.75f) - 4;
    py = +(SCREEN_SY / 2) - 28;
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

	/* ship-level */
    px = +83.0 - 2.0f;
    py = cast(float)(-(SCREEN_SY / 2) + 12);
	int tmp;
	str_buf = "LEVEL-";
	glbfPrintBegin();
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

	px += glbfGetWidth(font, str_buf, 0.75f);
    py -= 1.0f;
	if(ship_special == SHIP_SPECIAL_NONE) tmp = cast(int)(ship_level * 100.0f);
	else								  tmp = cast(int)(ship_special * 100.0f);
	str_buf = toString(tmp/100);
	glbfPrintBegin();
    glbfTranslate(px, py);
    glbfScale(1.00f, 0.75f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

    px  = +156.5;
    py += 1.0f;
	str_buf = ".";
	tmp %= 100;
	if(tmp < 10 ) str_buf ~= "0";
	str_buf ~= toString(tmp);
	glbfPrintBegin();
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

	/* ship */
	z = BASE_Z - cam_pos;
	px = +(SCREEN_SX / 2) - 16;
	py = -(SCREEN_SY / 2) + 32;
	for(int i = 0; i < left; i++){
		glColor3f(0.4f,0.4f,0.8f);
		glBegin(GL_POLYGON);
		for(int j = 0; j < TskBuf[id].body_ang.length; j++){
			pos[X] = sin(TskBuf[id].body_ang[j][X]) * getPointX(TskBuf[id].body_ang[j][W] * 3.0f, z);
			pos[Y] = cos(TskBuf[id].body_ang[j][Y]) * getPointY(TskBuf[id].body_ang[j][W] * 3.0f, z);
			pos[Z] = TskBuf[id].body_ang[j][Z];
			glVertex3f(pos[X] - getPointX(px, z),
					   pos[Y] - getPointY(py, z),
					   pos[Z]);
		}
		glEnd();
		glBegin(GL_LINE_LOOP);
		for(int j = 0; j < TskBuf[id].body_ang.length; j++){
			pos[X] = sin(TskBuf[id].body_ang[j][X]) * getPointX(TskBuf[id].body_ang[j][W] * 3.0f, z);
			pos[Y] = cos(TskBuf[id].body_ang[j][Y]) * getPointY(TskBuf[id].body_ang[j][W] * 3.0f, z);
			pos[Z] = TskBuf[id].body_ang[j][Z];
			glVertex3f(pos[X] - getPointX(px, z),
					   pos[Y] - getPointY(py, z),
					   pos[Z]);
		}
		glEnd();
		px -= 16;
	}
}

void TSKenegauge(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKenegaugeDraw;
			TskBuf[id].cnt = (TskBuf[id].cnt ? TskBuf[id].cnt : 1);
			TskBuf[id].fwrk1 = cast(float)TskBuf[id].wrk1 / TskBuf[id].cnt;
			TskBuf[id].fwrk2 = 0.0f;
			TskBuf[id].wrk2 = 0;
			TskBuf[id].wait = TskBuf[id].cnt;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				TskBuf[id].px += (TskBuf[id].tx - TskBuf[id].px) / 5.0f;
			}else{
				TskBuf[id].px = TskBuf[id].tx;
				TskBuf[id].wait = TskBuf[id].cnt;
				TskBuf[id].step++;
			}
			break;
		case	2:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				TskBuf[id].fwrk2 += TskBuf[id].fwrk1;
				TskBuf[id].wrk2 = cast(int)TskBuf[id].fwrk2;
			}else{
				TskBuf[id].wait = TskBuf[id].cnt;
				TskBuf[id].wrk2 = TskBuf[id].wrk1;
				TskBuf[id].step++;
			}
			break;
		case	3:
			if(TskBuf[TskBuf[id].parent].energy > 0 && TskBuf[TskBuf[id].parent].step >= 0){
				TskBuf[id].wrk2 = TskBuf[TskBuf[id].parent].energy;
			}else{
				TskBuf[id].wrk2 = 0;
				TskBuf[id].step++;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKenegaugeDraw(int id)
{
	float z;
	float[XY] base;
	float energy;
	float gsizex = TskBuf[id].vx;
	float gsizey = TskBuf[id].vy;

	z = BASE_Z - cam_pos;
	base[X] = TskBuf[id].px;
	base[Y] = TskBuf[id].py;

	glColor4f(0.25f,0.25f,0.25f,0.25f);
	glBegin(GL_QUADS);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glEnd();

	energy  = TskBuf[id].wrk2;
	energy /= TskBuf[id].wrk1;
	energy *=gsizex;

	glColor4f(0.50f,0.50f,0.25f,0.50f);
	glBegin(GL_QUADS);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+energy, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+energy, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glEnd();

	glColor4f(1.0f,1.0f,1.0f,0.50f);
	glBegin(GL_LINE_LOOP);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glEnd();
}

void TSKspgauge(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = -(SCREEN_SX / 2) + 12;
			TskBuf[id].py = -(SCREEN_SY / 2) + 20;
			TskBuf[id].vx = 248.0f;
			TskBuf[id].vy = 8.0f;
			TskBuf[id].fp_draw = &TSKspgaugeDraw;
			TskBuf[id].wrk1 = SHIP_SPECIAL_MAX;
			TskBuf[id].wrk2 = ship_spgauge;
			TskBuf[id].alpha = 0.0f; 
			TskBuf[id].cnt = 0; 
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].wrk2 = ship_spgauge;
			TskBuf[id].alpha += 1.0f / 30.0f;
			TskBuf[id].cnt++;
			if(!(TskBuf[id].cnt % 30)){
				TskBuf[id].step = 2;
			}
			break;
		case	2:
			TskBuf[id].wrk2 = ship_spgauge;
			TskBuf[id].alpha -= 1.0f / 30.0f;
			TskBuf[id].cnt++;
			if(!(TskBuf[id].cnt % 30)){
				TskBuf[id].step = 1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKspgaugeDraw(int id)
{
	float z;
	float[XY] base;
	float energy;
	float gsizex = TskBuf[id].vx;
	float gsizey = TskBuf[id].vy;

	z = BASE_Z - cam_pos;
	base[X] = TskBuf[id].px;
	base[Y] = TskBuf[id].py;

	glColor4f(0.25f,0.25f,0.25f,0.25f);
	glBegin(GL_QUADS);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glEnd();

	energy  = TskBuf[id].wrk2;
	energy /= TskBuf[id].wrk1;
	energy *= gsizex;

	if(ship_type == SHIP_TYPE01 || ship_type == SHIP_TYPE03){
		if(ship_spgauge == SHIP_SPECIAL_MAX){
			glColor4f(0.25f,0.25f,0.50f,1.00f);
		}else{
			if(ship_special == SHIP_SPECIAL_NONE){
				glColor4f(0.25f,0.25f,0.50f,0.25f);
			}else{
				glColor4f(0.25f,0.25f,0.50f,0.50f);
			}
		}
	}
	if(ship_type == SHIP_TYPE02){
		if(!ship_spheat){
			glColor4f(0.25f,0.25f,0.50f,1.00f);
		}else{
			glColor4f(1.00f,0.00f,0.00f,TskBuf[id].alpha);
			float px,py;
			px = TskBuf[id].px + 10.0f;
			py = TskBuf[id].py - 9.0f;
			str_buf = "OVER HEAT!!";
			glbfPrintBegin();
		    glbfTranslate(px, py);
		    glbfScale(1.50f, 0.50f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			glColor4f(0.50f,0.25f,0.25f,0.50f);
		}
	}
	glBegin(GL_QUADS);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+energy, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+energy, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glEnd();

	glColor4f(1.0f,1.0f,1.0f,0.50f);
	glBegin(GL_LINE_LOOP);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+  0.0f, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]+  0.0f, z),
			   0.0f);
	glVertex3f(getPointX(base[X]+gsizex, z),
			   getPointY(base[Y]-gsizey, z),
			   0.0f);
	glEnd();
}

void TSKstgInfo(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKstgInfoDraw;
			TskBuf[id].cnt = 120;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].cnt) TskBuf[id].cnt--;
			else			   TskBuf[id].step = -1;
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKstgInfoDraw(int id)
{
	float px,py;

	glColor3f(1.0f,1.0f,1.0f);
	glbfPrintBegin();
	str_buf = "START!!";
	px  = -glbfGetWidth(font, str_buf, 1.0f);
	px /= 2.0f;
	py  = +0.0f;
    glbfTranslate(px, py);
    glbfScale(1.0f, 0.75f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
}

void TSKclrInfo(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].body_ofs.length = 6;
			float px;
			str_buf = "- CLEAR  REPORT -";
			px  = -glbfGetWidth(font, str_buf, 1.0f) - (SCREEN_SX / 2);
			TskBuf[id].body_ofs[0][X] = px;
			TskBuf[id].body_ofs[0][Y] = +(SCREEN_SY / 2) - 48;
			TskBuf[id].body_ofs[1][X] = px;
			TskBuf[id].body_ofs[1][Y] = +(SCREEN_SY / 2) - 64;
			TskBuf[id].body_ofs[2][X] = px;
			TskBuf[id].body_ofs[2][Y] = +(SCREEN_SY / 2) - 80;
			TskBuf[id].body_ofs[3][X] = -(SCREEN_SX / 2) + 6;
			TskBuf[id].body_ofs[3][Y] = +(SCREEN_SY / 2) - 48;
			TskBuf[id].body_ofs[4][X] = -(SCREEN_SX / 2) + 6;
			TskBuf[id].body_ofs[4][Y] = +(SCREEN_SY / 2) - 64;
			TskBuf[id].body_ofs[5][X] = -(SCREEN_SX / 2) + 6;
			TskBuf[id].body_ofs[5][Y] = +(SCREEN_SY / 2) - 80;
			TskBuf[id].fp_draw = &TSKclrInfoDraw;
			TskBuf[id].wait = 15;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].body_ofs[0][X] += (TskBuf[id].body_ofs[3][X] - TskBuf[id].body_ofs[0][X]) / 5.0f;
			TskBuf[id].body_ofs[0][Y] += (TskBuf[id].body_ofs[3][Y] - TskBuf[id].body_ofs[0][Y]) / 5.0f;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = 15;
				TskBuf[id].step++;
			}
			break;
		case	2:
			TskBuf[id].body_ofs[0][X] += (TskBuf[id].body_ofs[3][X] - TskBuf[id].body_ofs[0][X]) / 5.0f;
			TskBuf[id].body_ofs[0][Y] += (TskBuf[id].body_ofs[3][Y] - TskBuf[id].body_ofs[0][Y]) / 5.0f;
			TskBuf[id].body_ofs[1][X] += (TskBuf[id].body_ofs[4][X] - TskBuf[id].body_ofs[1][X]) / 5.0f;
			TskBuf[id].body_ofs[1][Y] += (TskBuf[id].body_ofs[4][Y] - TskBuf[id].body_ofs[1][Y]) / 5.0f;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = 15;
				TskBuf[id].step++;
			}
			break;
		case	3:
			TskBuf[id].body_ofs[0][X] += (TskBuf[id].body_ofs[3][X] - TskBuf[id].body_ofs[0][X]) / 5.0f;
			TskBuf[id].body_ofs[0][Y] += (TskBuf[id].body_ofs[3][Y] - TskBuf[id].body_ofs[0][Y]) / 5.0f;
			TskBuf[id].body_ofs[1][X] += (TskBuf[id].body_ofs[4][X] - TskBuf[id].body_ofs[1][X]) / 5.0f;
			TskBuf[id].body_ofs[1][Y] += (TskBuf[id].body_ofs[4][Y] - TskBuf[id].body_ofs[1][Y]) / 5.0f;
			TskBuf[id].body_ofs[2][X] += (TskBuf[id].body_ofs[5][X] - TskBuf[id].body_ofs[2][X]) / 5.0f;
			TskBuf[id].body_ofs[2][Y] += (TskBuf[id].body_ofs[5][Y] - TskBuf[id].body_ofs[2][Y]) / 5.0f;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = 120;
				TskBuf[id].step++;
			}
			break;
		case	4:
			TskBuf[id].body_ofs[0][X] += (TskBuf[id].body_ofs[3][X] - TskBuf[id].body_ofs[0][X]) / 5.0f;
			TskBuf[id].body_ofs[0][Y] += (TskBuf[id].body_ofs[3][Y] - TskBuf[id].body_ofs[0][Y]) / 5.0f;
			TskBuf[id].body_ofs[1][X] += (TskBuf[id].body_ofs[4][X] - TskBuf[id].body_ofs[1][X]) / 5.0f;
			TskBuf[id].body_ofs[1][Y] += (TskBuf[id].body_ofs[4][Y] - TskBuf[id].body_ofs[1][Y]) / 5.0f;
			TskBuf[id].body_ofs[2][X] += (TskBuf[id].body_ofs[5][X] - TskBuf[id].body_ofs[2][X]) / 5.0f;
			TskBuf[id].body_ofs[2][Y] += (TskBuf[id].body_ofs[5][Y] - TskBuf[id].body_ofs[2][Y]) / 5.0f;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				score += dest_bonus;
				score += time_bonus;
				TskBuf[id].step = -1;
			}
			break;
		default:
			TskBuf[id].body_ofs.length = 0;
			clrTSK(id);
			break;
	}
}

void TSKclrInfoDraw(int id)
{
	float px,py;

	glColor3f(1.0f,1.0f,1.0f);
	glbfPrintBegin();
	str_buf = "- CLEAR  REPORT -";
	px  = TskBuf[id].body_ofs[0][X];
	py  = TskBuf[id].body_ofs[0][Y];
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
	glbfPrintBegin();
	str_buf = "DEST BONUS ";
	if(dest_bonus < 100000) str_buf ~= "0";
	if(dest_bonus < 10000 ) str_buf ~= "0";
	if(dest_bonus < 1000  ) str_buf ~= "0";
	if(dest_bonus < 100   ) str_buf ~= "0";
	if(dest_bonus < 10    ) str_buf ~= "0";
	str_buf ~= toString(dest_bonus);
	px  = TskBuf[id].body_ofs[1][X];
	py  = TskBuf[id].body_ofs[1][Y];
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
	glbfPrintBegin();
	str_buf = "TIME BONUS ";
	if(time_bonus < 100000) str_buf ~= "0";
	if(time_bonus < 10000 ) str_buf ~= "0";
	if(time_bonus < 1000  ) str_buf ~= "0";
	if(time_bonus < 100   ) str_buf ~= "0";
	if(time_bonus < 10    ) str_buf ~= "0";
	str_buf ~= toString(time_bonus);
	px  = TskBuf[id].body_ofs[2][X];
	py  = TskBuf[id].body_ofs[2][Y];
    glbfTranslate(px, py);
    glbfScale(0.75f, 0.50f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
}

void TSKgameover(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKgameoverDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKgameoverDraw(int id)
{
	float px,py;

	glColor3f(1.0f,1.0f,1.0f);
	glbfPrintBegin();
	str_buf = "GAME OVER";
	px  = -glbfGetWidth(font, str_buf, 1.5f);
	px /= 2.0f;
	py  = +0.0f;
	px  = ceil(px);
    glbfTranslate(px, py);
    glbfScale(1.5f, 1.25f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
}

void TSKcomplete(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKcompleteDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
}

void TSKcompleteDraw(int id)
{
	float px,py;

	glColor3f(1.0f,1.0f,1.0f);
	glbfPrintBegin();
	str_buf = "COMPLETE!!";
	px  = -glbfGetWidth(font, str_buf, 1.5f);
	px /= 2.0f;
	py  = +0.0f;
	px  = ceil(px);
    glbfTranslate(px, py);
    glbfScale(1.5f, 1.25f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();
}
