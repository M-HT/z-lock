/*
	Z-LOCK 'STAGE CTRL'

		'stg.d'

	2003/12/01 jumpei isshiki
*/

private	import	std.stdio;
private	import	util_sdl;
private	import	util_snd;
private	import	define;
private	import	task;
private	import	main;
private	import	gctrl;
private	import	effect;
private	import	bg;
private	import	sysinfo;
private	import	gctrl;
private	import	stg01;
private	import	ship;
private	import	enemy;
private	import	enemy01;
private	import	enemy02;
private	import	enemy03;
private	import	enemy04;
private	import	enemy05;
private	import	enemy06;
private	import	enemy07;
private	import	enemy08;
private	import	middle01;
private	import	middle02;
private	import	boss;

int	enemy_cnt;
int	enemy_max;
int	enemy_stg;
int	enemy_add;
int	enemy_form;
int	enemy_now;
int	enemy_type;
int	enemy_step;
int	middle_step;
int	middle_next;
int	boss_flag;

int	stg_num;
int	stg_ctrl;
int	stg_bgm;
int	stg_level;

int	seq_wait;
int	seq_stg;
int	seq_top;
int	seq_loop;

int[] seq_stgexec;
int[] seq_label;
int[] seq_enemy;
int[] seq_middle;

private const int SEQ_LABELMAX = 32;

//private const int ENEMY_LOOPMIN = 96;
private const int ENEMY_LOOPMIN = 64;
//private const int ENEMY_LOOPMIN = 4;
private const int ENEMY_MIDDLE = 32;

private const int COMPLETE_SCORE = 1000000;

private	void function(int)[]	enemy_func = [
												&TSKenemy01,
												&TSKenemy02,
												&TSKenemy03,
												&TSKenemy04,
												&TSKenemy05,
												&TSKenemy06,
												&TSKenemy07,
												&TSKenemy08,
												&TSKmiddle01,
												&TSKmiddle02,
												&TSKboss,
											];

private const char[][] seq_cmdname = [
										"SEQ_WAIT",
										"SEQ_INITENEMY",
										"SEQ_SETENEMY",
										"SEQ_SETENEMY2",
										"SEQ_SETENEMY3",
										"SEQ_SETENEMY4",
										"SEQ_SETENETYPE",
										"SEQ_EWAIT",
										"SEQ_SETLABEL",
										"SEQ_JUMPLABEL",
										"SEQ_JUMP",
										"SEQ_LOOPSET",
										"SEQ_LOOPSETENEMY",
										"SEQ_LOOP",
										"SEQ_STGINIT",
										"SEQ_REQBGM",
										"SEQ_STOPBGM",
										"SEQ_FADEBGM",
										"SEQ_PLAYVOICE",
										"SEQ_CHKVOICE",
										"SEQ_STGMESS",
										"SEQ_CLRMESS",
										"SEQ_SETENEMAX",
										"SEQ_VANISHENEMY",
										"SEQ_VANISHEBULLET",
										"SEQ_BOSSWAIT",
										"SEQ_BGDISPON",
										"SEQ_BGDISPOFF",
										"SEQ_BGVELSETX",
										"SEQ_BGVELSETY",
										"SEQ_BGVELSETXY",
										"SEQ_BGROTSET",
										"SEQ_BGZOOMSET",
										"SEQ_DATAINIT",
										"SEQ_TIMESTART",
										"SEQ_TIMESTOP",
										"SEQ_SETRAND",
										"SEQ_ADDRAND",
										"SEQ_CTRLRANK",
										"SEQ_BONUS",
										"SEQ_STOP",
										"SEQ_END",
									];

void TSKstgCtrl(int id)
{
	switch(TskBuf[id].step){
		case	0:
			stg_bgm = -1;
			stg_ctrl = STG_INIT;
			switch(game_mode){
				case	GMODE_NORMAL:
				case	GMODE_CONCEPT:
				case	GMODE_ORIGINAL:
				case	GMODE_HIDDEN:
					TskBuf[id].step = 1;
					break;
				case	GMODE_SCORE:
					TskBuf[id].step = 10;
					break;
				case	GMODE_TIME:
					TskBuf[id].step = 20;
					break;
				default:
					TskBuf[id].step = -1;
					break;
			}
			break;

		/* NORMAL & CONCEPT MODE */
		case	1:
			stg_ctrl = STG_MAIN;
			setTSK(GROUP_01,&TSKstg01);
			TskBuf[id].step++;
			break;
		case	2:
			if(stg_ctrl != STG_GAMEOVER && time_flag) time++;
			break;

		/* TIME ATTACK */
		case	10:
			stg_ctrl = STG_MAIN;
			setTSK(GROUP_01,&TSKstg02);
			TskBuf[id].step++;
			break;
		case	11:
			if(stg_ctrl != STG_COMPLETE && time_flag) time--;
			if(!time){
				stg_ctrl = STG_COMPLETE;
				TskBuf[id].step = -1;
			}
			break;

		/* SCORE ATTACK */
		case	20:
			stg_ctrl = STG_MAIN;
			setTSK(GROUP_01,&TSKstg03);
			TskBuf[id].step++;
			break;
		case	21:
			if(stg_ctrl != STG_COMPLETE && time_flag) time++;
			if(score >= COMPLETE_SCORE){
				stg_ctrl = STG_COMPLETE;
				TskBuf[id].step = -1;
			}
			break;

		default:
			break;
	}
}

void SEQinit()
{
	if(seq_label.length == 0) seq_label.length = SEQ_LABELMAX;
	seq_wait = 0;
	seq_stg = 0;
	seq_top = 0;
	seq_loop = 0;
	enemy_cnt = 0;
	enemy_now = 0;
}
			
int SEQexec(int id, int seq_pnt)
{
	int	eid;
	int	seq_flag = 0;

	while(!seq_flag){
		debug{
			//writefln("seq cmd %s(%d)",seq_cmdname[seq_stgexec[seq_pnt]],seq_stgexec[seq_pnt]);
		}
		switch(seq_stgexec[seq_pnt]){
			case	SEQ_WAIT:
				seq_wait = seq_stgexec[seq_pnt+1];
				seq_flag = 1;
				seq_pnt += 2;
				break;
			case	SEQ_INITENEMY:
				SEQenemyInit(id);
				seq_pnt += 1;
				break;
			case	SEQ_SETENEMY:
				if(enemy_cnt < enemy_max){
					eid = setTSK(GROUP_02, enemy_func[seq_stgexec[seq_pnt+1]]);
					if(eid != -1){
						TskBuf[eid].px = cast(float)seq_stgexec[seq_pnt+2];
						TskBuf[eid].py = cast(float)seq_stgexec[seq_pnt+3];
						TskBuf[eid].level = cast(int)level_enemy;
						TskBuf[eid].level_max = enemy_max;
						enemy_cnt++;
						middle_next++;
						total_enemy += 1.0f;
					}
					seq_pnt += 4;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_SETENEMY2:
				if(enemy_cnt < enemy_max){
					eid = setTSK(GROUP_02, enemy_func[seq_stgexec[seq_pnt+1]]);
					if(eid != -1){
						TskBuf[eid].level = cast(int)level_enemy;
						TskBuf[eid].level_max = enemy_max;
						TskBuf[eid].tskid |= TSKID_POSSET;
						enemy_cnt++;
						middle_next++;
						total_enemy += 1.0f;
					}
					seq_pnt += 2;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_SETENEMY3:
				if(!enemy_now){
					enemy_now = seq_stgexec[seq_pnt+1];
				}
				if(enemy_now && enemy_cnt < enemy_max){
					if(SEQenemyCtrl(id)){
						seq_pnt += 2;
					}
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_SETENEMY4:
				if(!enemy_now){
					enemy_now = enemy_form;
				}
				if(enemy_now && enemy_cnt < enemy_max){
					if(SEQenemyCtrl(id)){
						enemy_step++;
						seq_pnt += 1;
					}
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_SETENETYPE:
				SEQenemyType(id);
				seq_pnt += 1;
				break;
			case	SEQ_EWAIT:
				if(enemy_cnt <= seq_stgexec[seq_pnt+1]){
					seq_pnt += 2;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_SETLABEL:
				if(seq_stgexec[seq_pnt+1] < seq_label.length){
					seq_label[seq_stgexec[seq_pnt+1]] = seq_pnt + 2;
				}
				seq_pnt += 2;
				break;
			case	SEQ_JUMPLABEL:
				if(seq_stgexec[seq_pnt+1] < seq_label.length){
					seq_pnt = seq_label[seq_stgexec[seq_pnt+1]];
				}else{
					seq_pnt += 2;
				}
				break;
			case	SEQ_JUMP:
				seq_pnt = seq_stgexec[seq_pnt+1];
				break;
			case	SEQ_LOOPSET:
				seq_loop = seq_stgexec[seq_pnt+1];
				seq_pnt += 2;
				seq_top = seq_pnt;
				break;
			case	SEQ_LOOPSETENEMY:
				seq_loop = enemy_stg;
				seq_pnt += 1;
				seq_top = seq_pnt;
				break;
			case	SEQ_LOOP:
				seq_loop--;
				if(seq_loop){
					seq_pnt = seq_top;
				}else{
					seq_pnt += 1;
				}
				break;
			case	SEQ_STGINIT:
				clrTSKgroup(GROUP_04);
				clrTSKgroup(GROUP_06);
				seq_pnt += 1;
				break;
			case	SEQ_REQBGM:
				int bgm;
				if(seq_stgexec[seq_pnt+1] == -1){
					if(initialized == 1){
						bgm = stg_num;
						if(stg_num == 3) initialized = 0;
					}else{
						do{
							bgm = Rand() % 4;
						}while(stg_bgm == bgm);
					}
				}else{
					bgm = seq_stgexec[seq_pnt+1];
				}
				stg_bgm = bgm;
				playSNDmusic(stg_bgm);
				float rot;
				if((Rand() % 100) < 50){
					rot = +cast(float)(Rand() % 4) / 1000.0f;
					rot += 1.0f / 1000.0f;
				}else{
					rot = -cast(float)(Rand() % 4) / 1000.0f;
					rot -= 1.0f / 1000.0f;
				}
				switch(bgm){
					case 0:
						setBGrot(240, rot);
						setBGzoom(120, +0.0f);
						setBGspeed(240, 0.0f, -2.0f);
						break;
					case 1:
						setBGrot(240, rot);
						setBGzoom(120, +16.0f);
						setBGspeed(240, 0.0f, -4.0f);
						break;
					case 2:
						setBGrot(240, rot);
						setBGzoom(120, -4.0f);
						setBGspeed(240, 0.0f, -0.5f);
						break;
					case 3:
						setBGrot(240, rot);
						setBGzoom(120, +64.0f);
						setBGspeed(240, 0.0f, -8.0f);
						break;
					default:
						setBGrot(240, rot);
						setBGzoom(120, +64.0f);
						setBGspeed(240, 0.0f, -10.0f);
						break;
				}
				seq_pnt += 2;
				break;
			case	SEQ_STOPBGM:
				stopSNDmusic();
				seq_pnt += 1;
				break;
			case	SEQ_FADEBGM:
				fadeSNDmusicSet(1, seq_stgexec[seq_pnt+1]);
				seq_pnt += 2;
				break;
			case	SEQ_PLAYVOICE:
				playSNDse(seq_stgexec[seq_pnt+1]);
				seq_pnt += 2;
				break;
			case	SEQ_CHKVOICE:
				if(checkSNDse(seq_stgexec[seq_pnt+1]) == 1){
					seq_flag = 1;
				}else{
					seq_pnt += 2;
				}
				break;
			case	SEQ_STGMESS:
				stg_num++;
				if(stg_num == 1) setTSK(GROUP_08,&TSKstgInfo);
				seq_pnt += 1;
				break;
			case	SEQ_CLRMESS:
				setTSK(GROUP_08,&TSKclrInfo);
				seq_pnt += 1;
				break;
			case	SEQ_SETENEMAX:
				enemy_max = seq_stgexec[seq_pnt+1];
				seq_pnt += 2;
				break;
			case	SEQ_VANISHENEMY:
				EnemyVanish();
				seq_pnt += 1;
				break;
			case	SEQ_VANISHEBULLET:
				EbulletVanish();
				seq_pnt += 1;
				break;
			case	SEQ_BOSSWAIT:
				if(boss_flag == seq_stgexec[seq_pnt+1]){
					seq_pnt += 2;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_BGDISPON:
				bg_disp = 1;
				seq_pnt += 1;
				break;
			case	SEQ_BGDISPOFF:
				bg_disp = 0;
				seq_pnt += 1;
				break;
			case	SEQ_BGVELSETX:
				setBGspeed(seq_stgexec[seq_pnt+1], cast(float)seq_stgexec[seq_pnt+2]/FLT_MUL, 0.0f);
				seq_pnt += 3;
				break;
			case	SEQ_BGVELSETY:
				setBGspeed(seq_stgexec[seq_pnt+1], 0.0f, cast(float)seq_stgexec[seq_pnt+2]/FLT_MUL);
				seq_pnt += 3;
				break;
			case	SEQ_BGVELSETXY:
				setBGspeed(seq_stgexec[seq_pnt+1], cast(float)seq_stgexec[seq_pnt+2]/FLT_MUL, cast(float)seq_stgexec[seq_pnt+3]/FLT_MUL);
				seq_pnt += 4;
				break;
			case	SEQ_BGROTSET:
				setBGrot(seq_stgexec[seq_pnt+1], cast(float)seq_stgexec[seq_pnt+2]/FLT_MUL);
				seq_pnt += 3;
				break;
			case	SEQ_BGZOOMSET:
				setBGzoom(seq_stgexec[seq_pnt+1], cast(float)seq_stgexec[seq_pnt+2]/FLT_MUL);
				seq_pnt += 3;
				break;
			case	SEQ_DATAINIT:
				for(int i = 0; i < level_dest.length; i++){
					level_dest[i] = 0;
				}
				dest_enemy = 0.0f;
				total_enemy = 0.0f;
				if(game_mode != GMODE_SCORE) time = 0;
				seq_pnt += 1;
				break;
			case	SEQ_TIMESTART:
				time_flag = 1;
				seq_pnt += 1;
				break;
			case	SEQ_TIMESTOP:
				time_flag = 0;
				seq_pnt += 1;
				break;
			case	SEQ_SETRANK:
				setRank(cast(float)(seq_stgexec[seq_pnt+1])/FLT_MUL);
				seq_pnt += 2;
				break;
			case	SEQ_ADDRANK:
				addRank(cast(float)(seq_stgexec[seq_pnt+1])/FLT_MUL);
				seq_pnt += 2;
				break;
			case	SEQ_CTRLRANK:
				ctrlRank(stg_num);
				seq_pnt += 1;
				break;
			case	SEQ_BONUS:
				calcBonus();
				seq_pnt += 1;
				break;
			case	SEQ_STOP:
				seq_flag = 1;
				break;
			case	SEQ_END:
				seq_flag = 1;
				seq_pnt = -1;
				break;
			default:
				assert(1);
				break;
		}
	}

	return	seq_pnt;
}

/* ============================================================================ */

void SEQenemyInit(int id)
{
	void SEQenemyTblShuffle(int id){
		for(int i = seq_enemy.length - 1; i > 0; i--){
			int seed = Rand() % i;
			int tmp = seq_enemy[i];
			seq_enemy[i] = seq_enemy[seed];
			seq_enemy[seed] = tmp;
		}
	}

	enemy_now = 0;
	enemy_stg = ENEMY_LOOPMIN;
	if(ship_type == SHIP_TYPE02) enemy_stg -= 16;
	if(ship_type == SHIP_TYPE03) enemy_stg -= 16;
	enemy_stg += enemy_add;
	if(enemy_stg < 4) enemy_stg = 4;
	enemy_form = 4;
	enemy_type = -1;
	enemy_step = 0;
	middle_step = 0;
	middle_next = 0;

	/* enemy table */
	seq_enemy.length = enemy_stg;
	SEQenemyBaseTblSet(id);
	SEQenemyTblShuffle(id);

/++
	for(int i = 0; i < seq_enemy.length; i++){
		if(i && !(i % 16)){
			writefln("");
		}
		writef("%02d,", seq_enemy[i]);
	}
++/

	/* middle table */
	int ret = ((enemy_stg * enemy_form) / ENEMY_MIDDLE) - 2;
	if(ret > 0){
		seq_middle.length = ret;
		for(int i = 0; i < seq_middle.length; i++){
			seq_middle[i] = (ENEMY_MIDDLE * (i + 1)) + ((Rand() % 4) - 4);
		}
	}else{
		seq_middle.length = 1;
		seq_middle[0] = -1;
	}
}

void SEQenemyBaseTblSet(int id)
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

	for(int i = 0; i < seq_enemy.length; i++){
		seq_enemy[i] = i % max;;
	}
}

void SEQenemyType(int id)
{
	if(enemy_step < seq_enemy.length){
		enemy_type = seq_enemy[enemy_step];
	}
}

int SEQenemyCtrl(int id)
{
	int	eid;

	assert(enemy_type != -1);

	if(middle_step == -1 || seq_middle[middle_step] != middle_next){
		eid = setTSK(GROUP_02, enemy_func[enemy_type]);
		if(eid != -1){
			TskBuf[eid].level = cast(int)level_enemy;
			TskBuf[eid].level_max = enemy_max;
			TskBuf[eid].tskid |= TSKID_POSSET;
			enemy_cnt++;
			middle_next++;
			total_enemy += 1.0f;
			enemy_now--;
			if(enemy_now) return 0;
		}
	}else{
		int type = ENMEY_MID01 + (Rand() % 2);
		eid = setTSK(GROUP_02, enemy_func[type]);
		if(eid != -1){
			TskBuf[eid].level = cast(int)level_enemy;
			TskBuf[eid].level_max = enemy_max;
			TskBuf[eid].tskid |= TSKID_POSSET;
			enemy_cnt++;
			middle_step++;
			total_enemy += 1.0f;
			if(seq_middle.length == middle_step) middle_step = -1;
			return 0;
		}
	}

	return 1;
}

void calcBonus()
{
	float rate = dest_enemy / total_enemy;

	debug{
		writefln("stg-%d destruction rate %f", stg_num, rate);
		writefln("time %d", time);
		writefln("     %d", cast(int)(enemy_stg * enemy_form * 13.28125f));
		writefln("     %d", cast(int)(enemy_stg * enemy_form * 13.4375f));
		writefln("     %d", cast(int)(enemy_stg * enemy_form * 13.59375f));
		writefln("     %d", cast(int)(enemy_stg * enemy_form * 13.75f));
		writefln("     %d", cast(int)(enemy_stg * enemy_form * 13.90625f));
	}

	if(rate == 1.0f)		dest_bonus = 100000;
	else if(rate > 0.98f)	dest_bonus = 50000;
	else if(rate > 0.90f)	dest_bonus = 10000;
	else if(rate > 0.80f)	dest_bonus = 5000;
	else if(rate > 0.50f)	dest_bonus = 3000;
	else 					dest_bonus = 1000;

	if(ship_type == SHIP_TYPE01){
		if(time < (ONE_SEC * 55))					time_bonus = 100000;
		else if(time < (ONE_MIN + ONE_SEC *  0))	time_bonus = 50000;
		else if(time < (ONE_MIN + ONE_SEC *  5))	time_bonus = 10000;
		else if(time < (ONE_MIN + ONE_SEC * 15))	time_bonus = 5000;
		else if(time < (ONE_MIN + ONE_SEC * 30))	time_bonus = 3000;
		else 										time_bonus = 1000;
	}else{
		if(time < (ONE_MIN + ONE_SEC * 0))			time_bonus = 100000;
		else if(time < (ONE_MIN + ONE_SEC *  5))	time_bonus = 50000;
		else if(time < (ONE_MIN + ONE_SEC * 15))	time_bonus = 10000;
		else if(time < (ONE_MIN + ONE_SEC * 30))	time_bonus = 5000;
		else if(time < (ONE_MIN + ONE_SEC * 45))	time_bonus = 3000;
		else 										time_bonus = 1000;
	}

/++
	/*
	//	<time bonus base rate>
	//		5100(1min25sec) / 384(96loop*4enemy) = 13.28125
	//		5160(1min26sec) / 384(96loop*4enemy) = 13.4375
	//		5220(1min27sec) / 384(96loop*4enemy) = 13.59375
	//		5280(1min28sec) / 384(96loop*4enemy) = 13.75
	//		5340(1min29sec) / 384(96loop*4enemy) = 13.90625
	*/
	if(time < cast(int)(enemy_stg * enemy_form * 13.28125f))		time_bonus = 100000;
	else if(time < cast(int)(enemy_stg * enemy_form * 13.4375f))	time_bonus = 50000;
	else if(time < cast(int)(enemy_stg * enemy_form * 13.59375f))	time_bonus = 10000;
	else if(time < cast(int)(enemy_stg * enemy_form * 13.75f))		time_bonus = 5000;
	else if(time < cast(int)(enemy_stg * enemy_form * 13.90625f))	time_bonus = 3000;
	else 															time_bonus = 1000;
++/
}
