/*
	Z-LOCK 'GAME CTRL'

		'gctrl.d'

	2004/04/08 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	std.file;
private	import	std.path;
private	import	util_snd;
private	import	util_pad;
private	import	luminous;
private	import	main;
private	import	init;
private	import	define;
private	import	task;
private	import	gdebug;
private	import	sysinfo;
private	import	bg;
private	import	effect;
private	import	title;
private	import	stg;
private	import	ship;
private	import	enemy01;

enum{
	GSTEP_NONE = 0,
	GSTEP_LOGO,
	GSTEP_TITLE,
	GSTEP_OPTION,
	GSTEP_GAME,
	GSTEP_GAMEOVER,
	GSTEP_CLEAR,
	GSTEP_QUIT,
	GSTEP_EXIT,

	GMODE_NORMAL = 0,
	GMODE_CONCEPT,
	GMODE_ORIGINAL,
	GMODE_HIDDEN,
	GMODE_SCORE,
	GMODE_TIME,

	GLEVEL_EASY = 0,
	GLEVEL_NORMAL,
	GLEVEL_HARD,
	GLEVEL_VHARD,
	GLEVEL_MAX,
}

int initialized;

const int GAME_NOWVER = 0x0011;
int game_ver = GAME_NOWVER;

int normal_stg;
int normal_max;
int concept_stg;
int concept_max;
int original_stg;
int original_max;
int attack_mode;
int time_mode;
int repatk_mode;
int reptime_mode;
int attract_flag;

int game_mode;
int game_level;
int	score;
int	left;
int	time;
int	time_flag;
int	g_step;
int game_cost;

int[5][6] high_score;

int[] level_dest;
float rate_dest;
float dest_enemy;
float total_enemy;
float level_enemy;

int time_bonus;
int dest_bonus;

private	float rank;
private	float rank_max;
private	float rank_min;

int[] replay;
int[] replay_data;
int replay_flag;
int replay_cnt;
string[] replay_file;


void TSKgctrl(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_NPAUSE;
			level_dest.length = (cast(int)(SHIP_LEVEL_MAX)) + 1;
			replay.length = 16;
			replay_data.length = 16;
			replay_flag = 0;
			replay_cnt = 0;
			setTSK(GROUP_00,&TSKluminous);
			TskBuf[id].step++;
			break;
		case	1:
			debug{
				pause_flag = 1;
			}
			int fcnt = 0;
			auto fpath = dirEntries(".", SpanMode.shallow);
			foreach (string filename; fpath) {
				string filebasename = baseName(filename);
				if(globMatch(filebasename, "rep*.rep")){
					replay_file.length = fcnt + 1;
					replay_file[fcnt] = filebasename;
					fcnt++;
				}
			}
			debug{
				for(int i = 0; i < replay_file.length; i++){
					writefln("%s", replay_file[i]);
				}
			}
			setTSK(GROUP_01,&TSKbg00);
			setTSK(GROUP_08,&TSKbgFrame);
			setTSK(GROUP_08,&TSKtitle);
			g_step = GSTEP_TITLE;
			TskBuf[id].step++;
			break;
		case	2:
			if(g_step == GSTEP_GAME){
				TSKclrAll();
				TskBuf[id].wait = 60;
				int eid;
				eid = setTSK(GROUP_08,&TSKbgMask);
				if(eid != -1){
					TskBuf[eid].wait = 65;
				}
				TskBuf[id].step++;
			}
			if(g_step == GSTEP_EXIT){
				TSKclrAll();
				TskBuf[id].wait = 60;
				TskBuf[id].step = -1;
			}
			break;
		case	3:
			if(TskBuf[id].wait) TskBuf[id].wait--;
			else				TskBuf[id].step++;
			break;
		case	4:
			if(replay_flag == 1){
				replay[0] = game_mode;		/* level */
				replay[1] = 1443;			/* rand seed */
				replay[2] = 0;				/* score */
				replay[3] = 0;				/* time */
				replay[4] = stg_num + 1;	/* start sector */
				replay[5] = stg_num + 1;	/* end sector */
				replay[6] = ship_type;		/* ship type */
			}else if(replay_flag == 2){
				replay.length = replay_data.length;
				for(int i = 0; i < replay.length; i++){
					replay[i] = replay_data[i];
				}
				stg_num = replay[4] - 1;
				game_mode = replay[0];
				ship_type = replay[6];
			}
			replay_cnt = 16;
			RandSeed(replay[1]);
			setTSK(GROUP_01,&TSKbg01);
			setTSK(GROUP_01,&TSKstgCtrl);
			setTSK(GROUP_05,&TSKship);
			setTSK(GROUP_08,&TSKspgauge);
			setTSK(GROUP_08,&TSKsysinfo);
			setTSK(GROUP_08,&TSKdebug);
			setTSK(GROUP_08,&TSKbgFrame);
			boss_flag = 0;
			score = 0;
			game_exec = 2;
			switch(game_mode){
				case	GMODE_NORMAL:
				case	GMODE_CONCEPT:
				case	GMODE_ORIGINAL:
				case	GMODE_HIDDEN:
					left = 2;
					time = 0;
					break;
				case	GMODE_SCORE:
					left = 0;
					time = ONE_MIN * 3;
					break;
				case	GMODE_TIME:
					left = 0;
					time = 0;
					break;
				default:
					break;
			}
			time_flag = 0;
			initRank(0.0f,1.0f);
			pause_flag = 1;
			if(attract_flag == 1){
				TskBuf[id].wait = ONE_MIN;
			}
			TskBuf[id].step++;
			break;

		case	5:
			if(replay_flag == 2){
				if((trgs & PAD_BUTTON1)){
					stopSNDall();
					TSKclrAll();
					pause_flag = 0;
					pause = 0;
					skip = 0;
					int eid;
					eid = setTSK(GROUP_08,&TSKbgMask);
					if(eid != -1){
						TskBuf[eid].wait = 30;
						TskBuf[eid].fp(eid);
					}
					TskBuf[id].wait = 30;
					TskBuf[id].step = 10;
					break;
				}
			}
			if(attract_flag == 1){
				if(TskBuf[id].wait){
					TskBuf[id].wait--;
				}else{
					stopSNDall();
					TSKclrAll();
					pause_flag = 0;
					pause = 0;
					skip = 0;
					int eid;
					eid = setTSK(GROUP_08,&TSKbgMask);
					if(eid != -1){
						TskBuf[eid].wait = 30;
						TskBuf[eid].fp(eid);
					}
					TskBuf[id].wait = 30;
					TskBuf[id].step = 10;
					break;
				}
			}
			if(g_step == GSTEP_GAMEOVER){
				pause_flag = 0;
				pause = 0;
				skip = 0;
				TskBuf[id].wait = 60 * 1;
				TskBuf[id].step = 6;
			}else if(g_step == GSTEP_CLEAR){
				pause_flag = 0;
				pause = 0;
				skip = 0;
				TskBuf[id].wait = 60 * 1;
				TskBuf[id].step = 7;
			}else if(g_step == GSTEP_QUIT){
				stopSNDall();
				TSKclrAll();
				pause_flag = 0;
				pause = 0;
				skip = 0;
				int eid;
				eid = setTSK(GROUP_08,&TSKbgMask);
				if(eid != -1){
					TskBuf[eid].wait = 30;
					TskBuf[eid].fp(eid);
				}
				TskBuf[id].wait = 30;
				TskBuf[id].step = 10;
			}
			break;

		case	6:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = ONE_SEC * 5;
				setTSK(GROUP_08,&TSKgameover);
				TskBuf[id].step = 10;
			}
			break;
		case	7:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].wait = ONE_SEC * 8;
				setTSK(GROUP_08,&TSKcomplete);
				TskBuf[id].step = 10;
			}
			break;

		case	10:
			if(TskBuf[id].wait < (ONE_SEC * 4) && (pads & PAD_BUTTON1)){
				TskBuf[id].wait = 0;
			}
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				if(game_mode == GMODE_NORMAL){
					if((stg_num-1) > normal_max){
						normal_max = stg_num - 1;
						normal_stg = normal_max;
					}
					if(high_score[0][game_level] < score){
						high_score[0][game_level] = score;
						replaySave();
					}
				}else if(game_mode == GMODE_CONCEPT){
					if((stg_num-1) > concept_max){
						concept_max = stg_num - 1;
						concept_stg = concept_max;
					}
					if(high_score[1][game_level] < score){
						high_score[1][game_level] = score;
						replaySave();
					}
				}else if(game_mode == GMODE_SCORE){
					if(high_score[2][attack_mode] < score){
						high_score[2][attack_mode] = score;
						replaySave();
					}
				}else if(game_mode == GMODE_TIME){
					if(high_score[3][time_mode] > time){
						high_score[3][time_mode] = time;
						replaySave();
					}
				}else if(game_mode == GMODE_ORIGINAL){
					if((stg_num-1) > original_max){
						original_max = stg_num - 1;
						original_stg = original_max;
					}
					if(high_score[4][game_level] < score){
						high_score[4][game_level] = score;
						replaySave();
					}
				}else if(game_mode == GMODE_HIDDEN){
					if(high_score[5][game_level] > time){
						high_score[5][game_level] = time;
						replaySave();
					}
				}
				configSAVE();
				scoreSAVE();
				stopSNDall();
				TSKclrAll();
				game_exec = 1;
				TskBuf[id].step = 1;
			}
			break;

		default:
			clrTSK(id);
			break;
	}
}

void TSKclrAll()
{
	clrTSKgroup(GROUP_01);
	clrTSKgroup(GROUP_02);
	clrTSKgroup(GROUP_03);
	clrTSKgroup(GROUP_04);
	clrTSKgroup(GROUP_05);
	clrTSKgroup(GROUP_06);
	clrTSKgroup(GROUP_07);
	clrTSKgroup(GROUP_08);
}

void initRank(float min, float max)
{
	rank_min = min;
	rank_max = max;
	setRank(0.0f);
	game_cost = 0;
	level_enemy = 1.0f;
	enemy_add = 0;
	enemy_max = 8;
	stg_level = 0;

	if(game_mode == GMODE_NORMAL || game_mode == GMODE_CONCEPT || game_mode == GMODE_ORIGINAL){
		for(int i = 1; i < stg_num+1; i++) ctrlRank(i);
	}

	debug{
		writefln("- initialize level ctrl -");
		writefln("      stage : %d",stg_num+1);
		writefln("       rank : %f",rank);
		writefln("       cost : %d",game_cost);
		writefln("stage level : %d",stg_level);
		writefln("enemy level : %f",level_enemy);
		writefln("  enemy max : %d",enemy_max);
		writefln("  enemy add : %d",enemy_add);
	}
}

float getRank()
{
	return	rank;
}

void addRank(float add)
{
	rank += add;
	rank *= 1000.0f;
	rank  = ceil(rank);
	rank /= 1000.0f;
	if(rank > rank_max) rank = rank_max;
	if(rank < rank_min) rank = rank_min;
}

void setRank(float val)
{
	rank = val;
	if(rank > rank_max) rank = rank_max;
	if(rank < rank_min) rank = rank_min;
}

void ctrlRank(int stg)
{
	addRank(0.01f);
	game_cost += 10;
	stg_level++;
	level_enemy += 0.1f;
	level_enemy *= 10.0f;
	level_enemy  = ceil(level_enemy);
	level_enemy /= 10.0f;

	/*
	//	next stage ctrl
	*/

	if(stg && !(stg % 2)){
		enemy_add++;
	}

	if(stg && !(stg % 10)){
		stg_level = 0;
		addRank(-0.05f);
		enemy_add -= 4;
		enemy_max++;
	}

	if(stg && !(stg % 20)){
		level_enemy -= 1.0f;
	}

	if(stg && !(stg % 50)){
		enemy_max -= 4;
	}

	if(level_enemy > 8.0f) level_enemy = 8.0f;
	if(stg_level > 10) stg_level = 10;
	if(enemy_add < 0) enemy_add = 0;
	if(enemy_add > 16) enemy_add = 16;
	if(enemy_max < 8) enemy_max = 8;
	if(enemy_max > 16) enemy_max = 16;
}

void replaySave()
{
/++
	if(replay_flag == 1){
		replay[2] = score;
		replay[3] = time;
		replay[5] = stg_num;
		replay_data.length = replay.length;
		for(int i = 0; i < replay.length; i++){
			replay_data[i] = replay[i];
		}
		char[] fname;
		switch(game_mode){
			case GMODE_NORMAL:
				fname = "rep_normal.rep";
				break;
			case GMODE_CONCEPT:
				fname = "rep_concept.rep";
				break;
			case GMODE_ORIGINAL:
				fname = "rep_original.rep";
				break;
			case GMODE_SCORE:
				switch(ship_type){
					case	SHIP_TYPE01:
						fname = "rep_score_nrm.rep";
						break;
					case	SHIP_TYPE02:
						fname = "rep_score_con.rep";
						break;
					case	SHIP_TYPE03:
						fname = "rep_score_org.rep";
						break;
					default:
						assert(false);
				}
				break;
			case GMODE_TIME:
				switch(ship_type){
					case	SHIP_TYPE01:
						fname = "rep_time_nrm.rep";
						break;
					case	SHIP_TYPE02:
						fname = "rep_time_con.rep";
						break;
					case	SHIP_TYPE03:
						fname = "rep_time_org.rep";
						break;
					default:
						assert(false);
				}
				break;
			default:
				assert(false);
		}
		write(fname, cast(void[])replay_data);
	}
++/
}
