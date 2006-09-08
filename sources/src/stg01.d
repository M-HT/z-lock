/*
	Z-LOCK 'STAGE-01'

		'stg01.d'

	2004/04/14 jumpei isshiki
*/

private	import	util_sdl;
private	import	util_snd;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	effect;
private	import	bg;
private	import	stg;
private	import	ship;
private	import	seq_test;
private	import	seq_normal;
private	import	seq_attack;

/* NORMAL & CONCEPT MODE */
void TSKstg01(int id)
{
	switch(TskBuf[id].step){
		case	0:
			SEQinit();
			//seq_stgexec = seq_stg00;
			seq_stgexec = seq_stg01;
			seq_top = 0;
			TskBuf[id].step++;
			break;
		case	1:
			if(stg_ctrl == STG_GAMEOVER){
				g_step = GSTEP_GAMEOVER;
				TskBuf[id].step = -1;
				break;
			}
			if(stg_ctrl != STG_MAIN) break;
			if(seq_wait){
				seq_wait--;
				break;
			}
			if((seq_stg = SEQexec(id,seq_stg)) == -1){
				stg_ctrl = STG_CLEAR;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

/* TIME ATTACK */
void TSKstg02(int id)
{
	switch(TskBuf[id].step){
		case	0:
			SEQinit();
			seq_stgexec = seq_stg10;
			seq_top = 0;
			TskBuf[id].step++;
			break;
		case	1:
			if(stg_ctrl == STG_COMPLETE){
				g_step = GSTEP_CLEAR;
				TskBuf[id].step = -1;
				break;
			}
			if(stg_ctrl != STG_MAIN) break;
			if(seq_wait){
				seq_wait--;
				break;
			}
			if((seq_stg = SEQexec(id,seq_stg)) == -1){
				stg_ctrl = STG_CLEAR;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}

/* SCORE ATTACK */
void TSKstg03(int id)
{
	switch(TskBuf[id].step){
		case	0:
			SEQinit();
			seq_stgexec = seq_stg10;
			seq_top = 0;
			TskBuf[id].step++;
			break;
		case	1:
			if(stg_ctrl == STG_COMPLETE){
				g_step = GSTEP_CLEAR;
				TskBuf[id].step = -1;
				break;
			}
			if(stg_ctrl != STG_MAIN) break;
			if(seq_wait){
				seq_wait--;
				break;
			}
			if((seq_stg = SEQexec(id,seq_stg)) == -1){
				stg_ctrl = STG_CLEAR;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
}
