/*
	D-System 'TASK CTRL'

		'task.d'

	2003/11/27 jumpei isshiki
*/

private	import	SDL;
private	import	util_sdl;
private	import	bulletml;
private	import	bulletcommand;
private	import	main;

struct TSK {
	/* タスクメンバ */
	int				tskid;
	int				group;
	int				entry;
	int				next;
	int				prev;
	int				parent;
	int				child;
	void 			function(int) fp;
	void 			function(int) fp_int;
	void 			function(int) fp_draw;
	void 			function(int) fp_exit;
	int				step;
	int				flag;
	int				mode;
	int				type;
	int				wait;
	int				cnt;
	int				num;
	int				wrk1;
	int				wrk2;
	float			fwrk1;
	float			fwrk2;
	/* ゲーム依存メンバ */
	int				chr_id;
	int				trg_id;
	int				mov_mode;
	int				mov_cnt;
	int				energy;
	int				bullet_wait;
	int				lock_mode;
	int				lock_cnt;
	int				lock_id;
	int				level;
	int				level_max;
	float			level_add;
	float			px;
	float			py;
	float			pz;
	float			vx;
	float			vy;
	float			vz;
	float			ax;
	float			ay;
	float			az;
	float			nx;
	float			ny;
	float			nz;
	float			tx;
	float			ty;
	float			tz;
	float			sx;
	float			sy;
	float			sz;
	float			cx;
	float			cy;
	float			cz;
	float			cen_x;
	float			cen_y;
	float			cen_z;
	float			rad_x;
	float			rad_y;
	float			rad_z;
	float			ang_x;
	float			ang_y;
	float			ang_z;
	float			roll;
	float			rot;
	float			rot_add;
	float			rot_x;
	float			rot_y;
	float			rot_z;
	float			alpha;
	float			alpha_add;
	float			pal_r_base;
	float			pal_g_base;
	float			pal_b_base;
	float			pal_r;
	float			pal_g;
	float			pal_b;
	float			pal_r_add;
	float			pal_g_add;
	float			pal_b_add;
	int				pal_cnt;
	/* 描画関連メンバ */
	SDL_Surface*	image;
	float[]			body_org;
	float[XYZW][]	body_ofs;
	float[XYZW][]	body_ang;
	/* BulletMLメンバ */
	BulletCommand	bullet_command;
	BulletMLState*	bullet_state;
	int				tid;
	int				turn;
	float			rank;
	int				bullet_num;
	int				bullet_cnt;
	float			bullet_speed;
	float			bullet_velx;
	float			bullet_vely;
	float			bullet_accx;
	float			bullet_accy;
	float			bullet_direction;
	float			bullet_length;
	float			bullet_length_bak;
	void 			function(int) simple;
	void 			function(int) active;
	float			function(int) target;
}

enum{
	TSK_MAX = 10000,

	GROUP_00 = 0,
	GROUP_01,
	GROUP_02,
	GROUP_03,
	GROUP_04,
	GROUP_05,
	GROUP_06,
	GROUP_07,
	GROUP_08,
	GROUP_MAX,

}

enum{
	TSKID_NONE     = 0x00000000,
	TSKID_EXIST    = 0x00000001,
	TSKID_NPAUSE   = 0x00000002,

	TSKID_LOCKON   = 0x00000010,

	TSKID_SHIP     = 0x00100000,
	TSKID_ZAKO     = 0x00200000,
	TSKID_BOSS     = 0x00400000,
	TSKID_LOCK     = 0x00800000,

	TSKID_MUTEKI   = 0x10000000,
	TSKID_DESTROY  = 0x20000000,
	TSKID_POSSET   = 0x40000000,
}

int	TskEntry;
int	TskCnt;
TSK[] TskBuf;
int[] TskIndex;

void initTSK()
{
	TskBuf.length = TSK_MAX;
	TskIndex.length = GROUP_MAX;

	for(int i = 0; i < GROUP_MAX; i++){
		TskIndex[i] = -1;
	}

	TskEntry = 0;

	int	i;
	for(i = 0; i < TSK_MAX - 1; i++){
		TskBuf[i].tskid = TSKID_NONE;
		TskBuf[i].entry = i + 1;
		TskBuf[i].next = -1;
		TskBuf[i].prev = -1;
		TskBuf[i].fp = null;
		TskBuf[i].fp_int = null;
		TskBuf[i].fp_draw = null;
		TskBuf[i].fp_exit = null;
		TskBuf[i].image = null;
		TskBuf[i].bullet_command = null;
		TskBuf[i].bullet_state = null;
	}
	TskBuf[i].tskid = TSKID_NONE;
	TskBuf[i].entry = -1;
	TskBuf[i].next = -1;
	TskBuf[i].prev = -1;
	TskBuf[i].fp = null;
	TskBuf[i].fp_int = null;
	TskBuf[i].fp_draw = null;
	TskBuf[i].fp_exit = null;
	TskBuf[i].bullet_command = null;
	TskBuf[i].bullet_state = null;
	TskBuf[i].image = null;

	return;
}

int	setTSK(int group,void function(int) func)
{
	int	id = TskEntry;

	if(id != -1){
		TskBuf[id].tskid = TSKID_EXIST;
		TskBuf[id].group = group;
		TskBuf[id].step = 0;
		TskBuf[id].fp = func;
		TskBuf[id].fp_int = null;
		TskBuf[id].fp_draw = null;
		TskBuf[id].fp_exit = null;
		TskBuf[id].image = null;
		TskBuf[id].bullet_command = null;
		TskBuf[id].bullet_state = null;
		TskBuf[id].turn = 0;
		if(TskIndex[group] != -1){
			int i = TskIndex[group];
			TskBuf[id].prev = i;
			TskBuf[i].next = id;
		}
		TskIndex[group] = id;
		TskEntry = TskBuf[id].entry;
	}

	return	id;
}

void clrTSK(int id)
{
	if(id != -1){
		int	next,prev;
		int group = TskBuf[id].group;

		if(TskBuf[id].fp_exit){
			TskBuf[id].fp_exit(id);
		}
		TskBuf[id].tskid = TSKID_NONE;
		TskBuf[id].group = 0;
		next = TskBuf[id].next;
		prev = TskBuf[id].prev;
		if(TskIndex[group] == id){
			TskIndex[group] = prev;
		}
		if(next != -1){
			TskBuf[next].prev = TskBuf[id].prev;
		}
		if(prev != -1){
			TskBuf[prev].next = TskBuf[id].next;
		}
		TskBuf[id].next = -1;
		TskBuf[id].prev = -1;
		TskBuf[id].entry = TskEntry;
		TskBuf[id].fp = null;
		TskBuf[id].fp_int = null;
		TskBuf[id].fp_draw = null;
		TskBuf[id].fp_exit = null;
		TskBuf[id].image = null;
		TskBuf[id].body_ofs.length = 0;
		TskBuf[id].body_ang.length = 0;
		TskBuf[id].bullet_command = null;
		TskBuf[id].bullet_state = null;
		TskEntry = id;
	}

	return;
}

void clrTSKall()
{
	int	prev;

	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			if(TskBuf[j].tskid & TSKID_EXIST){
				clrTSK(j);
			}
		}
	}
}

void clrTSKgroup(int group)
{
	int	prev;

	for(int i = TskIndex[group]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0){
			clrTSK(i);
		}
	}
}

int cntTSK()
{
	int	prev;
	int cnt = 0;

	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			cnt++;
		}
	}

	return cnt;
}

void execTSK()
{
	int	prev;

	TskCnt = 0;

	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			if(TskBuf[j].tskid != 0 && TskBuf[j].fp){
				if(pause != 1){
					TskBuf[j].fp(j);
				}else if(skip || (TskBuf[j].tskid & TSKID_NPAUSE)){
					TskBuf[j].fp(j);
				}
				TskCnt++;
			}
		}
	}

	return;
}

void drawTSK()
{
	int	prev;

	for(int i = 0; i < GROUP_MAX; i++){
		for(int j = TskIndex[i]; j != -1; j = prev){
			prev = TskBuf[j].prev;
			if(TskBuf[j].tskid != 0 && TskBuf[j].fp_draw){
				TskBuf[j].fp_draw(j);
			}
		}
	}

	return;
}
