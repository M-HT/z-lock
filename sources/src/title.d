/*
	Z-LOCK 'TITLE'

		'title.d'

	2004/04/08 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.string;
private	import	std.file;
private	import	std.path;
private	import	std.conv;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_sdl;
private	import	util_glbf;
private	import	util_pad;
private	import	util_snd;
private	import	util_ascii;
private	import	define;
private	import	init;
private	import	task;
private	import	main;
private	import	gctrl;
private	import	stg;
private	import	ship;
private	import	sysinfo;

private	char[] str_buf;
private int menu_culumn;
private int menu_culumn_bak;
private int menu_ofs;
private int menu_num;
private int menu_max;
private int menu_cell;
private int menu_cell_max;
private int bgm_test;
private int bgm_play;
private int se_test;
private int voice_test;
private int[9] rep_flag;
private int[2] rep_data;

void TSKtitle(int id)
{
	switch(TskBuf[id].step){
		case	0:
			str_buf.length = 256;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKtitleDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].cnt = 0;
			for(int i = 0; i < rep_flag.length; i++){
				rep_flag[i] = 0;
			}
/++
			for(int i = 0; i < replay_file.length; i++){
				if(fnmatch(replay_file[i], "rep_normal.rep")){
					rep_flag[0] = 1;
				}
				if(fnmatch(replay_file[i], "rep_concept.rep")){
					rep_flag[1] = 1;
				}
				if(fnmatch(replay_file[i], "rep_original.rep")){
					rep_flag[2] = 1;
				}
				if(fnmatch(replay_file[i], "rep_score_nrm.rep")){
					rep_flag[3] = 1;
				}
				if(fnmatch(replay_file[i], "rep_score_con.rep")){
					rep_flag[4] = 1;
				}
				if(fnmatch(replay_file[i], "rep_score_org.rep")){
					rep_flag[5] = 1;
				}
				if(fnmatch(replay_file[i], "rep_time_nrm.rep")){
					rep_flag[6] = 1;
				}
				if(fnmatch(replay_file[i], "rep_time_con.rep")){
					rep_flag[7] = 1;
				}
				if(fnmatch(replay_file[i], "rep_time_org.rep")){
					rep_flag[8] = 1;
				}
			}
++/
			attract_flag = 0;
			TskBuf[id].wait = ONE_SEC * 30;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				attract_flag = 1;
				stopSNDmusic();
				g_step = GSTEP_GAME;
				replay_data = cast(int[])read("attract01.dat");
				replay_flag = 2;
				TskBuf[id].step = -1;
				break;
			}
			TskBuf[id].cnt++;
			if((trgs & PAD_BUTTON1)){
				TskBuf[id].wait = 60;
				TskBuf[id].step++;
			}
			break;
		case	2:
			TskBuf[id].cnt++;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				menu_culumn = 0;
				//menu_max = 8;
				menu_max = 7;
				menu_ofs = 0;
				menu_num = 0;
				TskBuf[id].py = -32.0f;
				TskBuf[id].ty = -32.0f;
				TskBuf[id].step++;
			}
			break;
		case	3:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				return;
			}
			TskBuf[id].cnt++;
			if((trgs & PAD_UP)) menu_culumn--;
			if((trgs & PAD_DOWN)) menu_culumn++;
			if(menu_culumn < 0) menu_culumn = menu_max;
			if(menu_culumn > menu_max) menu_culumn = 0;
			TSKtitleGetMenu(id);
			if((reps & PAD_LEFT)) menu_cell--;
			if((reps & PAD_RIGHT)) menu_cell++;
			if(menu_cell < 0) menu_cell = menu_cell_max;
			if(menu_cell > menu_cell_max) menu_cell = 0;
			TSKtitleSetMenu(id);
			TskBuf[id].py = -32.0f - cast(float)(menu_culumn * 16);
			if((trgs & PAD_BUTTON2)){
				stopSNDmusic();
				TskBuf[id].wait = 30 * ONE_SEC;
				TskBuf[id].step = 1;
			}
			if((trgs & PAD_BUTTON1)){
				if(menu_culumn == 0){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					ship_type = SHIP_TYPE01;
					game_mode = GMODE_NORMAL;
					replay_flag = 1;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 1){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					ship_type = SHIP_TYPE02;
					game_mode = GMODE_CONCEPT;
					replay_flag = 1;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 2){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					ship_type = SHIP_TYPE03;
					game_mode = GMODE_ORIGINAL;
					replay_flag = 1;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 3){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					ship_type = SHIP_TYPE01;
					game_mode = GMODE_HIDDEN;
					replay_flag = 1;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 4){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					game_mode = GMODE_SCORE;
					switch(attack_mode){
						case	0:
							ship_type = SHIP_TYPE01;
							break;
						case	1:
							ship_type = SHIP_TYPE02;
							break;
						case	2:
							ship_type = SHIP_TYPE03;
							break;
						default:
							assert(false);
					}
					replay_flag = 1;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 5){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					game_mode = GMODE_TIME;
					switch(time_mode){
						case	0:
							ship_type = SHIP_TYPE01;
							break;
						case	1:
							ship_type = SHIP_TYPE02;
							break;
						case	2:
							ship_type = SHIP_TYPE03;
							break;
						default:
							assert(false);
					}
					replay_flag = 1;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 6){
					menu_culumn = 0;
					menu_max = 5;
					menu_ofs = 0;
					menu_num = 0;
					bgm_test = 0;
					bgm_play = -1;
					se_test = 0;
					voice_test = 0;
					TSKtitleGetOption(id);
					TskBuf[id].py = -72.0f;
					TskBuf[id].ty = -72.0f;
					TskBuf[id].wait = 3;
					TskBuf[id].step = 4;
					break;
				}
/++
				if(replay_file.length != 0 && menu_culumn == 7){
					menu_culumn = 0;
					menu_culumn_bak = -1;
					menu_max = 5;
					menu_ofs = 0;
					menu_num = 0;
					bgm_test = 0;
					bgm_play = -1;
					se_test = 0;
					voice_test = 0;
					TSKtitleGetReplay(id);
					TskBuf[id].py = -48.0f;
					TskBuf[id].ty = -48.0f;
					TskBuf[id].wait = 3;
					TskBuf[id].step = 5;
					break;
				}
++/
				//if(menu_culumn == 8){
				if(menu_culumn == 7){
					configSAVE();
					stopSNDmusic();
					game_exec = 0;
					TskBuf[id].step = -1;
					break;
				}
			}
			break;
		case	4:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				return;
			}
			TskBuf[id].cnt++;
			if((trgs & PAD_UP)) menu_culumn--;
			if((trgs & PAD_DOWN)) menu_culumn++;
			if(menu_culumn < 0) menu_culumn = menu_max;
			if(menu_culumn > menu_max) menu_culumn = 0;
			TSKtitleGetOption(id);
			if((reps & PAD_LEFT)) menu_cell--;
			if((reps & PAD_RIGHT)) menu_cell++;
			if(menu_cell < 0) menu_cell = menu_cell_max;
			if(menu_cell > menu_cell_max) menu_cell = 0;
			TSKtitleSetOption(id);
			TskBuf[id].py = -72.0f - cast(float)(menu_culumn * 16);
			if((trgs & PAD_BUTTON2)){
				stopSNDall();
				stopSNDmusic();
				configSAVE();
				menu_culumn = 6;
				menu_max = 7;
				menu_ofs = 0;
				menu_num = 0;
				TskBuf[id].py = -32.0f - cast(float)(menu_culumn * 16);
				TskBuf[id].step = 3;
			}
			if((trgs & PAD_BUTTON1)){
				if(menu_culumn == 2){
					if(bgm_play == bgm_test){
						bgm_play = -1;
						stopSNDmusic();
					}else{
						bgm_play = bgm_test;
						switch(bgm_test){
							case	0:
								playSNDmusic(SND_BGM01);
								break;
							case	1:
								playSNDmusic(SND_BGM02);
								break;
							case	2:
								playSNDmusic(SND_BGM03);
								break;
							case	3:
								playSNDmusic(SND_BGM04);
								break;
							case	4:
								playSNDmusic(SND_BGM05);
								break;
							default:
								break;
						}
					}
				}
				if(menu_culumn == 3){
					stopSNDse(SND_SE_LOCK_ON);
					stopSNDse(SND_SE_SPSHOT);
					stopSNDse(SND_SE_EDMG);
					stopSNDse(SND_SE_EDEST1);
					stopSNDse(SND_SE_EDEST2);
					stopSNDse(SND_SE_EDEST3);
					switch(se_test){
						case	0:
							playSNDse(SND_SE_LOCK_ON);
							break;
						case	1:
							playSNDse(SND_SE_SPSHOT);
							break;
						case	2:
							playSNDse(SND_SE_SDEST);
							break;
						case	3:
							playSNDse(SND_SE_EDMG);
							break;
						case	4:
							playSNDse(SND_SE_EDEST1);
							break;
						case	5:
							playSNDse(SND_SE_EDEST2);
							break;
						case	6:
							playSNDse(SND_SE_EDEST3);
							break;
						default:
							break;
					}
				}
				if(menu_culumn == 4){
					stopSNDse(SND_VOICE_CHARGE);
					stopSNDse(SND_VOICE_OVER);
					stopSNDse(SND_VOICE_EXTEND);
					stopSNDse(SND_VOICE_WARNING);
					switch(voice_test){
						case	0:
							playSNDse(SND_VOICE_CHARGE);
							break;
						case	1:
							playSNDse(SND_VOICE_OVER);
							break;
						case	2:
							playSNDse(SND_VOICE_EXTEND);
							break;
						case	3:
							playSNDse(SND_VOICE_WARNING);
							break;
						default:
							break;
					}
				}
				if(menu_culumn == 5){
					stopSNDall();
					stopSNDmusic();
					configSAVE();
					menu_culumn = 6;
					menu_max = 7;
					menu_ofs = 0;
					menu_num = 0;
					TskBuf[id].py = -32.0f - cast(float)(menu_culumn * 16);
					TskBuf[id].step = 3;
				}
			}
			break;
/++
		case	5:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				return;
			}
			TskBuf[id].cnt++;
			if((trgs & PAD_UP)) menu_culumn--;
			if((trgs & PAD_DOWN)) menu_culumn++;
			if(menu_culumn < 0) menu_culumn = menu_max;
			if(menu_culumn > menu_max) menu_culumn = 0;
			TSKtitleGetReplay(id);
			if((reps & PAD_LEFT)) menu_cell--;
			if((reps & PAD_RIGHT)) menu_cell++;
			if(menu_cell < 0) menu_cell = menu_cell_max;
			if(menu_cell > menu_cell_max) menu_cell = 0;
			TSKtitleSetReplay(id);
			TskBuf[id].py = -48.0f - cast(float)(menu_culumn * 16);
			if((trgs & PAD_BUTTON2)){
				stopSNDall();
				stopSNDmusic();
				configSAVE();
				menu_culumn = 6;
				menu_max = 7;
				menu_ofs = 0;
				menu_num = 0;
				TskBuf[id].py = -32.0f - cast(float)(menu_culumn * 16);
				TskBuf[id].step = 3;
			}
			if((trgs & PAD_BUTTON1)){
				if(rep_flag[0] != 0 && menu_culumn == 0){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					replay_data = cast(int[])read("rep_normal.rep");
					replay_flag = 2;
					TskBuf[id].step = -1;
					break;
				}
				if(rep_flag[1] != 0 && menu_culumn == 1){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					replay_data = cast(int[])read("rep_concept.rep");
					replay_flag = 2;
					TskBuf[id].step = -1;
					break;
				}
				if(rep_flag[2] != 0 && menu_culumn == 2){
					stopSNDmusic();
					g_step = GSTEP_GAME;
					replay_data = cast(int[])read("rep_original.rep");
					replay_flag = 2;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 3){
					if(repatk_mode == 0 && rep_flag[3] == 0) break;
					if(repatk_mode == 1 && rep_flag[4] == 0) break;
					if(repatk_mode == 2 && rep_flag[5] == 0) break;
					stopSNDmusic();
					g_step = GSTEP_GAME;
					switch(repatk_mode){
						case	0:
							replay_data = cast(int[])read("rep_score_nrm.rep");
							break;
						case	1:
							replay_data = cast(int[])read("rep_score_con.rep");
							break;
						case	2:
							replay_data = cast(int[])read("rep_score_org.rep");
							break;
						default:
							assert(false);
					}
					replay_flag = 2;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 4){
					if(reptime_mode == 0 && rep_flag[6] == 0) break;
					if(reptime_mode == 1 && rep_flag[7] == 0) break;
					if(reptime_mode == 2 && rep_flag[8] == 0) break;
					stopSNDmusic();
					g_step = GSTEP_GAME;
					switch(reptime_mode){
						case	0:
							replay_data = cast(int[])read("rep_time_nrm.rep");
							break;
						case	1:
							replay_data = cast(int[])read("rep_time_con.rep");
							break;
						case	2:
							replay_data = cast(int[])read("rep_time_org.rep");
							break;
						default:
							assert(false);
					}
					replay_flag = 2;
					TskBuf[id].step = -1;
					break;
				}
				if(menu_culumn == 5){
					stopSNDall();
					stopSNDmusic();
					configSAVE();
					menu_culumn = 6;
					menu_max = 7;
					menu_ofs = 0;
					menu_num = 0;
					TskBuf[id].py = -32.0f - cast(float)(menu_culumn * 16);
					TskBuf[id].step = 3;
				}
			}
			break;
++/
		default:
			str_buf.length = 0;
			clrTSK(id);
			break;
	}
}

void TSKtitleDraw(int id)
{
	float z;
	float[XY] pos;

	z = BASE_Z - cam_pos;
	glEnable(GL_TEXTURE_2D);
	bindSDLtexture(GRP_TITLE);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glBegin(GL_TRIANGLE_FAN);
	pos[X] = 0.0f + (-184.0f);
	pos[Y] = +(SCREEN_Y / 2 - 128) + (+104.0f) - 16.0f;
	glTexCoord2f(0, 0);
	glVertex3f(getPointX(pos[X], z),getPointY(pos[Y], z), 0);
	pos[X] = 0.0f + (+184.0f);
	pos[Y] = +(SCREEN_Y / 2 - 128) + (+104.0f) - 16.0f;
	glTexCoord2f(0.71875f, 0);
	glVertex3f(getPointX(pos[X], z),getPointY(pos[Y], z), 0);
	pos[X] = 0.0f + (+184.0f);
	pos[Y] = +(SCREEN_Y / 2 - 128) + (-104.0f) - 16.0f;
	glTexCoord2f(0.71875f, 0.8125f);
	glVertex3f(getPointX(pos[X], z),getPointY(pos[Y], z), 0);
	pos[X] = 0.0f + (-184.0f);
	pos[Y] = +(SCREEN_Y / 2 - 128) + (-104.0f) - 16.0f;
	glTexCoord2f(0, 0.8125f);
	glVertex3f(getPointX(pos[X], z),getPointY(pos[Y], z), 0);
	glEnd();
	glDisable(GL_TEXTURE_2D);

    glBlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);
	glBegin(GL_QUADS);
	glColor4f(0.0f,0.0f,0.0f,0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) + 0.0f, z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) + 0.0f, z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) - 16.0f, z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) - 16.0f, z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) - 16.0f, z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) - 16.0f, z),
			   0.0f);
	glColor4f(0.0f,0.0f,0.0f,1.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) - 48.0f, z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(+(SCREEN_SY / 2) - 48.0f, z),
			   0.0f);
	glEnd();
	glBegin(GL_QUADS);
	glColor4f(0.0f,0.0f,0.0f,0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2), z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2) + 160.0f, z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2) + 160.0f, z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2) + 160.0f, z),
			   0.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2) + 160.0f, z),
			   0.0f);
	glColor4f(0.0f,0.0f,0.0f,1.0f);
	glVertex3f(getPointX(+(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2) + 288.0f, z),
			   0.0f);
	glVertex3f(getPointX(-(SCREEN_SX / 2), z),
			   getPointY(-(SCREEN_SY / 2) + 288.0f, z),
			   0.0f);
	glEnd();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	glColor3f(1.0f, 1.0f, 1.0f);
	glbfPrintBegin();
	str_buf = "HELLO WORLD PROJECT 2005,2006".dup;
	pos[X]  = -glbfGetWidth(font, str_buf, 0.75f);
	pos[X] /= 2.0f;
	pos[Y]  = -(SCREEN_Y / 2) + 32.0f;
	pos[X]  = ceil(pos[X]);
	pos[Y]  = ceil(pos[Y]);
    glbfTranslate(pos[X], pos[Y]);
    glbfScale(0.75f, 0.6f);
	glbfPrint(font, str_buf);
	glbfPrintEnd();

	switch(TskBuf[id].step){
		case	1:
			if(!(TskBuf[id].cnt & 0x20)){
				glbfPrintBegin();
				str_buf = "PRESS SHOT BUTTON".dup;
				pos[X]  = -glbfGetWidth(font, str_buf, 0.75f);
				pos[X] /= 2.0f;
				pos[Y]  = -80.0f;
				pos[X]  = ceil(pos[X]);
				pos[Y]  = ceil(pos[Y]);
			    glbfTranslate(pos[X], pos[Y]);
			    glbfScale(0.75f, 0.5f);
				glbfPrint(font, str_buf);
				glbfPrintEnd();
			}
			break;
		case	2:
			if(!(TskBuf[id].cnt & 0x01)){
				glbfPrintBegin();
				str_buf = "PRESS SHOT BUTTON".dup;
				pos[X]  = -glbfGetWidth(font, str_buf, 0.75f);
				pos[X] /= 2.0f;
				pos[Y]  = -80.0f;
				pos[X]  = ceil(pos[X]);
				pos[Y]  = ceil(pos[Y]);
			    glbfTranslate(pos[X], pos[Y]);
			    glbfScale(0.75f, 0.5f);
				glbfPrint(font, str_buf);
				glbfPrintEnd();
			}
			break;
		/* main menu */
		case	3:
			str_buf = "SCORE ATTACK  [ORIGINAL]".dup;
			pos[X]	= -glbfGetWidth(font, str_buf, 0.75f);
			pos[X] /= 2.0f;
			pos[Y]	= -32.0f;
			pos[X]	= ceil(pos[X]);
			pos[Y]	= ceil(pos[Y]);
			glbfPrintBegin();
			str_buf  = "NORMAL MODE   ".dup;
			str_buf ~= "<";
			if(normal_stg < 99) str_buf ~= "0";
			if(normal_stg < 9 ) str_buf ~= "0";
			str_buf ~= to!string(normal_stg+1);
			str_buf ~= ">";
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "CONCEPT MODE  ".dup;
			str_buf ~= "<";
			if(concept_stg < 99) str_buf ~= "0";
			if(concept_stg < 9 ) str_buf ~= "0";
			str_buf ~= to!string(concept_stg+1);
			str_buf ~= ">";
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "ORIGINAL MODE ".dup;
			str_buf ~= "<";
			if(original_stg < 99) str_buf ~= "0";
			if(original_stg < 9 ) str_buf ~= "0";
			str_buf ~= to!string(original_stg+1);
			str_buf ~= ">";
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "HIDDEN MODE ".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "SCORE ATTACK  ".dup;
			switch(attack_mode){
				case	0:
					str_buf ~= "<NORMAL  >";
					break;
				case	1:
					str_buf ~= "<CONCEPT >";
					break;
				case	2:
					str_buf ~= "<ORIGINAL>";
					break;
				default:
					assert(false);
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "TIME ATTACK   ".dup;
			switch(time_mode){
				case	0:
					str_buf ~= "<NORMAL  >";
					break;
				case	1:
					str_buf ~= "<CONCEPT >";
					break;
				case	2:
					str_buf ~= "<ORIGINAL>";
					break;
				default:
					assert(false);
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf = "SOUND".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
/++
			if(replay_file.length == 0) glColor3f(0.5f, 0.5f, 0.5f);
			glbfPrintBegin();
			str_buf = "REPLAY".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			glColor3f(1.0f, 1.0f, 1.0f);
			pos[Y] -= 16.0f;
++/
			glbfPrintBegin();
			str_buf = "EXIT".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y]  = TskBuf[id].py;
			pos[Y] += 5.0f;
			glColor4f(0.5f,0.5f,0.0f,0.5f);
			glBegin(GL_POLYGON);
			glVertex3f((pos[X] -   0.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] -   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] + 138.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] -   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] + 138.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] +   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] -   0.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] +   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glEnd();

			int high;
			pos[X]	= -glbfGetWidth(font, "HIGH SCORE 100000000", 0.75f);
			pos[X] /= 2.0f;
			pos[Y]  = -(SCREEN_Y / 2) + 64.0f;
			switch(menu_culumn){
				case	0:
					high = high_score[0][game_level];
					str_buf  = "HIGH SCORE ".dup;
					if(high < 100000000) str_buf ~= "0";
					if(high < 10000000 ) str_buf ~= "0";
					if(high < 1000000  ) str_buf ~= "0";
					if(high < 100000   ) str_buf ~= "0";
					if(high < 10000    ) str_buf ~= "0";
					if(high < 1000     ) str_buf ~= "0";
					if(high < 100      ) str_buf ~= "0";
					if(high < 10       ) str_buf ~= "0";
					str_buf ~= to!string(high);
					glColor3f(1.0f,1.0f,1.0f);
					glbfPrintBegin();
					glbfTranslate(pos[X], pos[Y]);
				    glbfScale(0.75f, 0.50f);
					glbfPrint(font, str_buf);
					glbfPrintEnd();
					break;
				case	1:
					high = high_score[1][game_level];
					str_buf  = "HIGH SCORE ".dup;
					if(high < 100000000) str_buf ~= "0";
					if(high < 10000000 ) str_buf ~= "0";
					if(high < 1000000  ) str_buf ~= "0";
					if(high < 100000   ) str_buf ~= "0";
					if(high < 10000    ) str_buf ~= "0";
					if(high < 1000     ) str_buf ~= "0";
					if(high < 100      ) str_buf ~= "0";
					if(high < 10       ) str_buf ~= "0";
					str_buf ~= to!string(high);
					glColor3f(1.0f,1.0f,1.0f);
					glbfPrintBegin();
					glbfTranslate(pos[X], pos[Y]);
				    glbfScale(0.75f, 0.50f);
					glbfPrint(font, str_buf);
					glbfPrintEnd();
					break;
				case	2:
					high = high_score[4][game_level];
					str_buf  = "HIGH SCORE ".dup;
					if(high < 100000000) str_buf ~= "0";
					if(high < 10000000 ) str_buf ~= "0";
					if(high < 1000000  ) str_buf ~= "0";
					if(high < 100000   ) str_buf ~= "0";
					if(high < 10000    ) str_buf ~= "0";
					if(high < 1000     ) str_buf ~= "0";
					if(high < 100      ) str_buf ~= "0";
					if(high < 10       ) str_buf ~= "0";
					str_buf ~= to!string(high);
					glColor3f(1.0f,1.0f,1.0f);
					glbfPrintBegin();
					glbfTranslate(pos[X], pos[Y]);
				    glbfScale(0.75f, 0.50f);
					glbfPrint(font, str_buf);
					glbfPrintEnd();
					break;
				case	3:
					high = high_score[5][game_level];
					str_buf  = "HIGH SCORE ".dup;
					if(high < 100000000) str_buf ~= "0";
					if(high < 10000000 ) str_buf ~= "0";
					if(high < 1000000  ) str_buf ~= "0";
					if(high < 100000   ) str_buf ~= "0";
					if(high < 10000    ) str_buf ~= "0";
					if(high < 1000     ) str_buf ~= "0";
					if(high < 100      ) str_buf ~= "0";
					if(high < 10       ) str_buf ~= "0";
					str_buf ~= to!string(high);
					glColor3f(1.0f,1.0f,1.0f);
					glbfPrintBegin();
					glbfTranslate(pos[X], pos[Y]);
				    glbfScale(0.75f, 0.50f);
					glbfPrint(font, str_buf);
					glbfPrintEnd();
					break;
				case	4:
					high = high_score[2][time_mode];
					str_buf  = "HIGH SCORE ".dup;
					if(high < 100000000) str_buf ~= "0";
					if(high < 10000000 ) str_buf ~= "0";
					if(high < 1000000  ) str_buf ~= "0";
					if(high < 100000   ) str_buf ~= "0";
					if(high < 10000    ) str_buf ~= "0";
					if(high < 1000     ) str_buf ~= "0";
					if(high < 100      ) str_buf ~= "0";
					if(high < 10       ) str_buf ~= "0";
					str_buf ~= to!string(high);
					glColor3f(1.0f,1.0f,1.0f);
					glbfPrintBegin();
					glbfTranslate(pos[X], pos[Y]);
				    glbfScale(0.75f, 0.50f);
					glbfPrint(font, str_buf);
					glbfPrintEnd();
					break;
				case	5:
					high = high_score[3][attack_mode];
					int	tmin,tsec,tmsec;
					tmin  = high / ONE_MIN;
					tsec  = high / ONE_SEC % ONE_SEC;
					tmsec = ((high % ONE_SEC) * 100 / ONE_SEC);
					str_buf  = "HIGH SCORE ".dup;
					if(tmin < 10) str_buf ~= "0";
					str_buf ~= to!string(tmin);
					str_buf ~= ":";
					if(tsec < 10) str_buf ~= "0";
					str_buf ~= to!string(tsec);
					str_buf ~= ":";
					if(tmsec < 10) str_buf ~= "0";
					str_buf ~= to!string(tmsec);
					glColor3f(1.0f,1.0f,1.0f);
					glbfPrintBegin();
					glbfTranslate(pos[X], pos[Y]);
				    glbfScale(0.75f, 0.50f);
					glbfPrint(font, str_buf);
					glbfPrintEnd();
					break;
				default:
					break;
			}
			break;
		/* sound */
		case	4:
			str_buf = "- SOUND -".dup;
			pos[X]	= -glbfGetWidth(font, str_buf, 0.75f);
			pos[X] /= 2.0f;
			pos[Y]	= -48.0f;
			pos[X]	= ceil(pos[X]);
			pos[Y]	= ceil(pos[Y]);
			glbfPrintBegin();
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			str_buf  = "   SE TEST ".dup;
			str_buf ~= "SPECIAL-SHOT";
			pos[X]	= -glbfGetWidth(font, str_buf, 0.75f);
			pos[X] /= 2.0f;
			pos[Y]	= -72.0f;
			pos[X]	= ceil(pos[X]);
			pos[Y]	= ceil(pos[Y]);
			glbfPrintBegin();
			str_buf  = "BGM VOLUME ".dup;
			if(vol_music < 100) str_buf ~= "0";
			if(vol_music < 10 ) str_buf ~= "0";
			str_buf ~= to!string(vol_music);
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = " SE VOLUME ".dup;
			if(vol_se < 100) str_buf ~= "0";
			if(vol_se < 10 ) str_buf ~= "0";
			str_buf ~= to!string(vol_se);
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "  BGM TEST ".dup;
			switch(bgm_test){
				case	0:
					str_buf ~= "STAGE-A";
					break;
				case	1:
					str_buf ~= "STAGE-B";
					break;
				case	2:
					str_buf ~= "STAGE-C";
					break;
				case	3:
					str_buf ~= "STAGE-D";
					break;
				case	4:
					str_buf ~= "ATTACK";
					break;
				default:
					str_buf ~= "?????";
					break;
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "   SE TEST ".dup;
			switch(se_test){
				case	0:
					str_buf ~= "LOCK-ON";
					break;
				case	1:
					str_buf ~= "SPECIAL-SHOT";
					break;
				case	2:
					str_buf ~= "SHIP DEST";
					break;
				case	3:
					str_buf ~= "ENE-DAMAGE";
					break;
				case	4:
					str_buf ~= "ENE-DEST 01";
					break;
				case	5:
					str_buf ~= "ENE-DEST 02";
					break;
				case	6:
					str_buf ~= "ENE-DEST 03";
					break;
				default:
					str_buf ~= "?????";
					break;
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf  = "VOICE TEST ".dup;
			switch(voice_test){
				case	0:
					str_buf ~= "CHARGE";
					break;
				case	1:
					str_buf ~= "OVER HEAT";
					break;
				case	2:
					str_buf ~= "EXTEND";
					break;
				case	3:
					str_buf ~= "WARNING";
					break;
				default:
					str_buf ~= "?????";
					break;
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glbfPrintBegin();
			str_buf = "QUIT".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y]  = TskBuf[id].py;
			pos[Y] += 5.0f;
			glColor4f(0.5f,0.5f,0.0f,0.5f);
			glBegin(GL_POLYGON);
			glVertex3f((pos[X] -   0.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] -   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] + 106.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] -   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] + 106.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] +   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] -   0.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] +   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glEnd();
			break;
		/* replay */
		case	5:
			str_buf = "- REPLAY -".dup;
			pos[X]	= -glbfGetWidth(font, str_buf, 0.75f);
			pos[X] /= 2.0f;
			pos[Y]	= -16.0f;
			pos[X]	= ceil(pos[X]);
			pos[Y]	= ceil(pos[Y]);
			glbfPrintBegin();
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			str_buf = "SCORE ATTACK  [ORIGINAL]".dup;
			pos[X]	= -glbfGetWidth(font, str_buf, 0.75f);
			pos[X] /= 2.0f;
			pos[Y]	= -48.0f;
			pos[X]	= ceil(pos[X]);
			pos[Y]	= ceil(pos[Y]);
			if(rep_flag[0] != 0) glColor3f(1.0f,1.0f,1.0f);
			else				 glColor3f(0.5f,0.5f,0.5f);
			glbfPrintBegin();
			str_buf  = "NORMAL MODE".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			if(rep_flag[1] != 0) glColor3f(1.0f,1.0f,1.0f);
			else				 glColor3f(0.5f,0.5f,0.5f);
			glbfPrintBegin();
			str_buf  = "CONCEPT MODE".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			if(rep_flag[2] != 0) glColor3f(1.0f,1.0f,1.0f);
			else				 glColor3f(0.5f,0.5f,0.5f);
			glbfPrintBegin();
			str_buf  = "ORIGINAL MODE".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			if(repatk_mode == 0 && rep_flag[3] != 0)	  glColor3f(1.0f,1.0f,1.0f);
			else if(repatk_mode == 0 && rep_flag[3] == 0) glColor3f(0.5f,0.5f,0.5f);
			if(repatk_mode == 1 && rep_flag[4] != 0)	  glColor3f(1.0f,1.0f,1.0f);
			else if(repatk_mode == 1 && rep_flag[4] == 0) glColor3f(0.5f,0.5f,0.5f);
			if(repatk_mode == 2 && rep_flag[5] != 0)	  glColor3f(1.0f,1.0f,1.0f);
			else if(repatk_mode == 2 && rep_flag[5] == 0) glColor3f(0.5f,0.5f,0.5f);
			glbfPrintBegin();
			str_buf  = "SCORE ATTACK  ".dup;
			switch(repatk_mode){
				case	0:
					str_buf ~= "<NORMAL  >";
					break;
				case	1:
					str_buf ~= "<CONCEPT >";
					break;
				case	2:
					str_buf ~= "<ORIGINAL>";
					break;
				default:
					assert(false);
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			if(reptime_mode == 0 && rep_flag[6] != 0)	   glColor3f(1.0f,1.0f,1.0f);
			else if(reptime_mode == 0 && rep_flag[6] == 0) glColor3f(0.5f,0.5f,0.5f);
			if(reptime_mode == 1 && rep_flag[7] != 0)	   glColor3f(1.0f,1.0f,1.0f);
			else if(reptime_mode == 1 && rep_flag[7] == 0) glColor3f(0.5f,0.5f,0.5f);
			if(reptime_mode == 2 && rep_flag[8] != 0)	   glColor3f(1.0f,1.0f,1.0f);
			else if(reptime_mode == 2 && rep_flag[8] == 0) glColor3f(0.5f,0.5f,0.5f);
			glbfPrintBegin();
			str_buf  = "TIME ATTACK   ".dup;
			switch(reptime_mode){
				case	0:
					str_buf ~= "<NORMAL  >";
					break;
				case	1:
					str_buf ~= "<CONCEPT >";
					break;
				case	2:
					str_buf ~= "<ORIGINAL>";
					break;
				default:
					assert(false);
			}
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 16.0f;
			glColor3f(1.0f,1.0f,1.0f);
			glbfPrintBegin();
			str_buf = "EXIT".dup;
			glbfTranslate(pos[X], pos[Y]);
			glbfScale(0.75f, 0.5f);
			glbfPrint(font, str_buf);
			glbfPrintEnd();
			pos[Y] -= 32.0f;
			int high;
			switch(menu_culumn){
				case	0:
					if(rep_flag[0] != 0){
						high = high_score[0][0];
						str_buf  = "HIGH SCORE ".dup;
						if(high < 100000000) str_buf ~= "0";
						if(high < 10000000 ) str_buf ~= "0";
						if(high < 1000000  ) str_buf ~= "0";
						if(high < 100000   ) str_buf ~= "0";
						if(high < 10000    ) str_buf ~= "0";
						if(high < 1000     ) str_buf ~= "0";
						if(high < 100      ) str_buf ~= "0";
						if(high < 10       ) str_buf ~= "0";
						str_buf ~= to!string(high);
						glColor3f(1.0f,1.0f,1.0f);
						glbfPrintBegin();
						glbfTranslate(pos[X], pos[Y]);
					    glbfScale(0.75f, 0.50f);
						glbfPrint(font, str_buf);
						glbfPrintEnd();
						pos[Y] -= 16.0f;
						str_buf  = "    SECTOR ".dup;
						str_buf ~= to!string(rep_data[0]);
						str_buf ~= " - ";
						str_buf ~= to!string(rep_data[1]);
						glColor3f(1.0f,1.0f,1.0f);
						glbfPrintBegin();
						glbfTranslate(pos[X], pos[Y]);
					    glbfScale(0.75f, 0.50f);
						glbfPrint(font, str_buf);
						glbfPrintEnd();
					}
					break;
				case	1:
					if(rep_flag[1] != 0){
						high = high_score[1][0];
						str_buf  = "HIGH SCORE ".dup;
						if(high < 100000000) str_buf ~= "0";
						if(high < 10000000 ) str_buf ~= "0";
						if(high < 1000000  ) str_buf ~= "0";
						if(high < 100000   ) str_buf ~= "0";
						if(high < 10000    ) str_buf ~= "0";
						if(high < 1000     ) str_buf ~= "0";
						if(high < 100      ) str_buf ~= "0";
						if(high < 10       ) str_buf ~= "0";
						str_buf ~= to!string(high);
						glColor3f(1.0f,1.0f,1.0f);
						glbfPrintBegin();
						glbfTranslate(pos[X], pos[Y]);
					    glbfScale(0.75f, 0.50f);
						glbfPrint(font, str_buf);
						glbfPrintEnd();
						pos[Y] -= 16.0f;
						str_buf  = "    SECTOR ".dup;
						str_buf ~= to!string(rep_data[0]);
						str_buf ~= " - ";
						str_buf ~= to!string(rep_data[1]);
						glColor3f(1.0f,1.0f,1.0f);
						glbfPrintBegin();
						glbfTranslate(pos[X], pos[Y]);
					    glbfScale(0.75f, 0.50f);
						glbfPrint(font, str_buf);
						glbfPrintEnd();
					}
					break;
				case	2:
					if(rep_flag[2] != 0){
						high = high_score[1][1];
						str_buf  = "HIGH SCORE ".dup;
						if(high < 100000000) str_buf ~= "0";
						if(high < 10000000 ) str_buf ~= "0";
						if(high < 1000000  ) str_buf ~= "0";
						if(high < 100000   ) str_buf ~= "0";
						if(high < 10000    ) str_buf ~= "0";
						if(high < 1000     ) str_buf ~= "0";
						if(high < 100      ) str_buf ~= "0";
						if(high < 10       ) str_buf ~= "0";
						str_buf ~= to!string(high);
						glColor3f(1.0f,1.0f,1.0f);
						glbfPrintBegin();
						glbfTranslate(pos[X], pos[Y]);
					    glbfScale(0.75f, 0.50f);
						glbfPrint(font, str_buf);
						glbfPrintEnd();
						pos[Y] -= 16.0f;
						str_buf  = "    SECTOR ".dup;
						str_buf ~= to!string(rep_data[0]);
						str_buf ~= " - ";
						str_buf ~= to!string(rep_data[1]);
						glColor3f(1.0f,1.0f,1.0f);
						glbfPrintBegin();
						glbfTranslate(pos[X], pos[Y]);
					    glbfScale(0.75f, 0.50f);
						glbfPrint(font, str_buf);
						glbfPrintEnd();
					}
					break;
				default:
					break;
			}

			pos[Y]  = TskBuf[id].py;
			pos[Y] += 5.0f;
			glColor4f(0.5f,0.5f,0.0f,0.5f);
			glBegin(GL_POLYGON);
			glVertex3f((pos[X] -   0.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] -   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] + 138.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] -   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] + 138.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] +   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glVertex3f((pos[X] -   0.0f) / (SCREEN_X / 2.0f),
					   (pos[Y] +   8.0f) / (SCREEN_Y / 2.0f),
					   0.0f);
			glEnd();
			break;

		default:
			break;
	}
	glEnd();
}

void TSKtitleGetMenu(int id)
{
	switch(menu_culumn){
		case	0:
			menu_cell = normal_stg;
			menu_cell_max = normal_max;
			stg_num = normal_stg;
			break;
		case	1:
			menu_cell = concept_stg;
			menu_cell_max = concept_max;
			stg_num = concept_stg;
			break;
		case	2:
			menu_cell = original_stg;
			menu_cell_max = original_max;
			stg_num = concept_stg;
			break;
		case	4:
			menu_cell = attack_mode;
			menu_cell_max = 2;
			break;
		case	5:
			menu_cell = time_mode;
			menu_cell_max = 2;
			break;
		default:
			break;
	}
}

void TSKtitleSetMenu(int id)
{
	switch(menu_culumn){
		case	0:
			normal_stg = menu_cell;
			stg_num = normal_stg;
			break;
		case	1:
			concept_stg = menu_cell;
			stg_num = concept_stg;
			break;
		case	2:
			original_stg = menu_cell;
			stg_num = original_stg;
			break;
		case	4:
			attack_mode = menu_cell;
			break;
		case	5:
			time_mode = menu_cell;
			break;
		default:
			break;
	}
}

void TSKtitleGetOption(int id)
{
	switch(menu_culumn){
		case	0:
			menu_cell = vol_music;
			menu_cell_max = 100;
			break;
		case	1:
			menu_cell = vol_se;
			menu_cell_max = 100;
			break;
		case	2:
			menu_cell = bgm_test;
			menu_cell_max = 4;
			break;
		case	3:
			menu_cell = se_test;
			menu_cell_max = 6;
			break;
		case	4:
			menu_cell = voice_test;
			menu_cell_max = 3;
			break;
		default:
			break;
	}
}

void TSKtitleSetOption(int id)
{
	switch(menu_culumn){
		case	0:
			vol_music = menu_cell;
			volumeSNDmusic(vol_music);
			break;
		case	1:
			vol_se = menu_cell;
			volumeSNDse(vol_se);
			break;
		case	2:
			bgm_test = menu_cell;
			break;
		case	3:
			se_test = menu_cell;
			break;
		case	4:
			voice_test = menu_cell;
			break;
		default:
			break;
	}
}

void TSKtitleGetReplay(int id)
{
	if(menu_culumn != menu_culumn_bak){
		switch(menu_culumn){
			case	0:
				if(rep_flag[0] != 0){
					replay_data = cast(int[])read("rep_normal.rep");
					rep_data[0] = replay_data[4];
					rep_data[1] = replay_data[5];
				}
				break;
			case	1:
				if(rep_flag[1] != 0){
					replay_data = cast(int[])read("rep_concept.rep");
					rep_data[0] = replay_data[4];
					rep_data[1] = replay_data[5];
				}
				break;
			case	2:
				if(rep_flag[2] != 0){
					replay_data = cast(int[])read("rep_original.rep");
					rep_data[0] = replay_data[4];
					rep_data[1] = replay_data[5];
				}
				break;
			case	3:
				if(repatk_mode == 0 && rep_flag[3] == 0) break;
				if(repatk_mode == 1 && rep_flag[4] == 0) break;
				if(repatk_mode == 2 && rep_flag[5] == 0) break;
				switch(repatk_mode){
					case	0:
						replay_data = cast(int[])read("rep_score_nrm.rep");
						break;
					case	1:
						replay_data = cast(int[])read("rep_score_con.rep");
						break;
					case	2:
						replay_data = cast(int[])read("rep_score_org.rep");
						break;
					default:
						assert(false);
				}
				break;
			case	4:
				if(reptime_mode == 0 && rep_flag[6] == 0) break;
				if(reptime_mode == 1 && rep_flag[7] == 0) break;
				if(reptime_mode == 2 && rep_flag[8] == 0) break;
				switch(reptime_mode){
					case	0:
						replay_data = cast(int[])read("rep_time_nrm.rep");
						break;
					case	1:
						replay_data = cast(int[])read("rep_time_con.rep");
						break;
					case	2:
						replay_data = cast(int[])read("rep_time_org.rep");
						break;
					default:
						assert(false);
				}
				break;
			default:
				break;
		}
		menu_culumn_bak = menu_culumn;
	}

	switch(menu_culumn){
		case	3:
			menu_cell = repatk_mode;
			menu_cell_max = 2;
			break;
		case	4:
			menu_cell = reptime_mode;
			menu_cell_max = 2;
			break;
		default:
			break;
	}
}

void TSKtitleSetReplay(int id)
{
	switch(menu_culumn){
		case	3:
			repatk_mode = menu_cell;
			break;
		case	4:
			reptime_mode = menu_cell;
			break;
		default:
			break;
	}
}
