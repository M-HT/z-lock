/*
	Z-LOCK 'Bulletml'

		'bulletcommand.d'

	2004/02/19 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.math;
private	import	bulletml;
private	import	main;
private	import	task;
private	import	gctrl;
private	import	ship;

private	const float	ROTVAL = (180.0f / PI);
private	const float	VEL_SDM_SS_RATIO = 1.0f;
private	const float	VEL_SS_SDM_RATIO = 1.0f;

private const int SHOT_DIST = 20;

private	BulletMLParserTinyXML*[]	parser;

void initBulletcommandParser(int bank)
{
	parser.length = bank;
	for(int i = 0; i < parser.length; i++){
		parser[i] = null;
	}
}

void readBulletcommandParser(int bank, char[] fname)
{
	char[]	buf;

	buf.length = 256;
	buf = fname ~ "\0";
	parser[bank] = BulletMLParserTinyXML_new(buf);
	if(parser[bank]) BulletMLParserTinyXML_parse(parser[bank]);
	buf.length = 0;
}

void releaseBulletcommandParser()
{
	for(int i = 0; i < parser.length; i++){
		if(parser[i]) BulletMLParserTinyXML_delete(parser[i]);
		parser[i] = null;
	}
}

class BulletCommand {
	public:
		static	BulletCommand	now;
		int	id;

	private:
		void setBulletmlRunner(int task_id, int bank){
			runner = BulletMLRunner_new_parser(parser[bank]);
			if(runner){
				registFunctions(runner);
				id = task_id;
			}
		}

		void setBulletmlRunner(int task_id, BulletMLState* state){
			runner = BulletMLRunner_new_state(state);
			if(runner){
				registFunctions(runner);
				id = task_id;
			}
		}

		void delBulletmlRunner(BulletMLRunner* runner){
			BulletMLRunner_delete(runner);
		}

		void registFunctions(BulletMLRunner* runner){
			BulletMLRunner_set_getBulletDirection(runner, &getBulletDirection_);
			BulletMLRunner_set_getAimDirection(runner, &getAimDirection_);
			BulletMLRunner_set_getBulletSpeed(runner, &getBulletSpeed_);
			BulletMLRunner_set_getDefaultSpeed(runner, &getDefaultSpeed_);
			BulletMLRunner_set_getRank(runner, &getRank_);
			BulletMLRunner_set_createSimpleBullet(runner, &createSimpleBullet_);
			BulletMLRunner_set_createBullet(runner, &createBullet_);
			BulletMLRunner_set_getTurn(runner, &getTurn_);
			BulletMLRunner_set_doVanish(runner, &doVanish_);

			BulletMLRunner_set_doChangeDirection(runner, &doChangeDirection_);
			BulletMLRunner_set_doChangeSpeed(runner, &doChangeSpeed_);
			BulletMLRunner_set_doAccelX(runner, &doAccelX_);
			BulletMLRunner_set_doAccelY(runner, &doAccelY_);
			BulletMLRunner_set_getBulletSpeedX(runner, &getBulletSpeedX_);
			BulletMLRunner_set_getBulletSpeedY(runner, &getBulletSpeedY_);
			BulletMLRunner_set_getRand(runner, &getRand_);
		}

	public:
		~this(){
		}

		void set(int task_id, int bank){
			setBulletmlRunner(task_id, bank);
		}

		void set(int task_id, BulletMLState* state){
			setBulletmlRunner(task_id, state);
		}

		bool	isEnd(){
		    if(runner) return BulletMLRunner_isEnd(runner);
			else	   return true;
		}

		void run(){
			now = this;
			TskBuf[BulletCommand.now.id].turn++;
		    if(runner) BulletMLRunner_run(runner);
		}

		void vanish(){
		    if(runner) delBulletmlRunner(runner);
			runner = null;
		}

	private:
		BulletMLRunner*	runner;
}

/*
//	BulletML Functions
*/

extern (C){

double	getBulletDirection_(BulletMLRunner* runner){
	//writefln("getBulletDirection_(%d)",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_direction * ROTVAL;
}

double	getAimDirection_(BulletMLRunner* runner){
	//writefln("getAimDirection_(%d)",BulletCommand.now.id);
	double	dir;
	dir = TskBuf[BulletCommand.now.id].target(BulletCommand.now.id);
	dir = dir * ROTVAL;
	return	dir;
}

double	getBulletSpeed_(BulletMLRunner* runner){
	//writefln("getBulletSpeed_(%d)",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_speed * VEL_SS_SDM_RATIO;
}

double	getDefaultSpeed_(BulletMLRunner* runner){
	//writefln("getDefaultSpeed_(%d)",BulletCommand.now.id);
	return	1.0;
}

double	getRank_(BulletMLRunner* runner){
	//writefln("getRank_(%d)",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].rank;
}

void createSimpleBullet_(BulletMLRunner* runner, double d, double s){
	//writefln("createSimpleBullet_(%d,%f)",BulletCommand.now.id,s);
	if(TskBuf[BulletCommand.now.id].simple){
		int	eid;
		if((TskBuf[BulletCommand.now.id].tskid & TSKID_BOSS+TSKID_ZAKO)) eid = setTSK(GROUP_06,TskBuf[BulletCommand.now.id].simple);
		else															 eid = setTSK(GROUP_04,TskBuf[BulletCommand.now.id].simple);
		if(eid != -1){
			TskBuf[eid].parent = BulletCommand.now.id;
			d = (d <= 180.0f ? d : -(360.0f - d));
			d = d / ROTVAL;
			TskBuf[eid].bullet_speed = s;
			TskBuf[eid].bullet_direction = d;
			TskBuf[eid].bullet_velx = (sin(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_vely = (cos(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_accx = TskBuf[BulletCommand.now.id].bullet_accx;
			TskBuf[eid].bullet_accy = TskBuf[BulletCommand.now.id].bullet_accy;
			if((TskBuf[BulletCommand.now.id].tskid & TSKID_BOSS+TSKID_ZAKO)) TskBuf[eid].tid = TskBuf[BulletCommand.now.id].tid;
			TskBuf[eid].fp(eid);
		}
	}
}

void createBullet_(BulletMLRunner* runner, BulletMLState *state, double d, double s){
	//writefln("createBullet_(%d)",BulletCommand.now.id);
	if(TskBuf[BulletCommand.now.id].active){
		int	eid;
		if((TskBuf[BulletCommand.now.id].tskid & TSKID_BOSS+TSKID_ZAKO)) eid = setTSK(GROUP_06,TskBuf[BulletCommand.now.id].active);
		else															 eid = setTSK(GROUP_04,TskBuf[BulletCommand.now.id].active);
		if(eid != -1){
			TskBuf[eid].parent = BulletCommand.now.id;
			d = (d <= 180.0f ? d : -(360.0f - d));
			d = d / ROTVAL;
			TskBuf[eid].bullet_state = state;
			TskBuf[eid].bullet_speed = s;
			TskBuf[eid].bullet_direction = d;
			TskBuf[eid].bullet_velx = (sin(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_vely = (cos(d) * (-s * VEL_SDM_SS_RATIO));
			TskBuf[eid].bullet_accx = TskBuf[BulletCommand.now.id].bullet_accx;
			TskBuf[eid].bullet_accy = TskBuf[BulletCommand.now.id].bullet_accy;
			if((TskBuf[BulletCommand.now.id].tskid & TSKID_BOSS+TSKID_ZAKO)) TskBuf[eid].tid = TskBuf[BulletCommand.now.id].tid;
			TskBuf[eid].fp(eid);
		}
	}
}

int getTurn_(BulletMLRunner* runner){
	//writefln("getTurn_(%d)",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].turn;
}

void doVanish_(BulletMLRunner* runner){
	//writefln("doVanish_(%d)",BulletCommand.now.id);
}

void doChangeDirection_(BulletMLRunner* runner, double d){
	//writefln("doChangeDirection_(%d)",BulletCommand.now.id);
	d = (d <= 180.0f ? d : -(360.0f - d));
	d = d / ROTVAL;
	TskBuf[BulletCommand.now.id].bullet_direction = d;
}

void doChangeSpeed_(BulletMLRunner* runner, double s){
	//writefln("doChangeSpeed_(%d)",BulletCommand.now.id);
	TskBuf[BulletCommand.now.id].bullet_speed = s * VEL_SDM_SS_RATIO;
}

void doAccelX_(BulletMLRunner* runner, double ax){
	//writefln("doAccelX_(%d)",BulletCommand.now.id);
	TskBuf[BulletCommand.now.id].bullet_accx = ax * VEL_SDM_SS_RATIO;
}

void doAccelY_(BulletMLRunner* runner, double ay){
	//writefln("doAccelY_(%d)",BulletCommand.now.id);
	TskBuf[BulletCommand.now.id].bullet_accy = ay * VEL_SDM_SS_RATIO;
}

double	getBulletSpeedX_(BulletMLRunner* runner){
	//writefln("getBulletSpeedX_(%d)",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_accx;
}

double	getBulletSpeedY_(BulletMLRunner* runner){
	//writefln("getBulletSpeedY_(%d)",BulletCommand.now.id);
	return	TskBuf[BulletCommand.now.id].bullet_accy;
}

double	getRand_(BulletMLRunner* runner){
	double	rand_val;
	//writefln("getRand_(%d)",BulletCommand.now.id);
	rand_val = Rand() % 10000;
	rand_val /= 10000;
	return	rand_val;
}

}
