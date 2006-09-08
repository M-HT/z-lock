/*
	D-System 'INITIALIZE'

		'init.d'

	2003/12/01 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.stream;
private	import	std.file;
private	import	util_sdl;
private	import	util_snd;
private	import	util_pad;
private	import	bulletcommand;
private	import	define;
private	import	gctrl;

void	grpINIT()
{
	readSDLtexture("title.bmp", GRP_TITLE);
}

void	sndINIT()
{
	loadSNDmusic("zlock01.ogg",SND_BGM01, -1);
	loadSNDmusic("zlock02.ogg",SND_BGM02, -1);
	loadSNDmusic("zlock03.ogg",SND_BGM03, -1);
	loadSNDmusic("zlock04.ogg",SND_BGM04, -1);
	loadSNDmusic("zlock05.ogg",SND_BGM05, -1);

	loadSNDse("se_lock_on.wav",SND_SE_LOCK_ON,0);
	loadSNDse("se_spshot.wav" ,SND_SE_SPSHOT ,1);
	loadSNDse("se_sdest.wav"  ,SND_SE_SDEST  ,1);
	loadSNDse("se_edmg.wav"   ,SND_SE_EDMG   ,2);
	loadSNDse("se_edest1.wav" ,SND_SE_EDEST1 ,3);
	loadSNDse("se_edest2.wav" ,SND_SE_EDEST2 ,4);
	loadSNDse("se_edest3.wav" ,SND_SE_EDEST3 ,4);

	loadSNDse("voice_ok.wav"     ,SND_VOICE_CHARGE ,5);
	loadSNDse("voice_over.wav"   ,SND_VOICE_OVER   ,5);
	loadSNDse("voice_extend.wav" ,SND_VOICE_EXTEND ,6);
	loadSNDse("voice_warring.wav",SND_VOICE_WARNING,7);

	volumeSNDse(vol_se);
	volumeSNDmusic(vol_music);
}

void	bulletINIT()
{
	initBulletcommandParser(256);
	readBulletcommandParser( BULLET_SHIP00, "bullet00.xml");
	readBulletcommandParser( BULLET_SHIP01, "bullet01.xml");
	readBulletcommandParser( BULLET_SHIP02, "bullet02.xml");
	readBulletcommandParser( BULLET_SHIP03, "bullet03.xml");
	readBulletcommandParser( BULLET_SHIP04, "bullet04.xml");
	readBulletcommandParser( BULLET_SHIP05, "bullet05.xml");
	readBulletcommandParser( BULLET_SHIP06, "bullet06.xml");
	readBulletcommandParser( BULLET_SHIP07, "bullet07.xml");
	readBulletcommandParser( BULLET_SHIP08, "bullet08.xml");
	readBulletcommandParser( BULLET_ZAKO01, "bulletzako01.xml");
	readBulletcommandParser( BULLET_ZAKO02, "bulletzako02.xml");
	readBulletcommandParser( BULLET_ZAKO03, "bulletzako03.xml");
	readBulletcommandParser( BULLET_ZAKO04, "bulletzako04.xml");
	readBulletcommandParser( BULLET_ZAKO05, "bulletzako05.xml");
	readBulletcommandParser( BULLET_ZAKO06, "bulletzako06.xml");
	readBulletcommandParser( BULLET_ZAKO07, "bulletzako07.xml");
	readBulletcommandParser( BULLET_ZAKO08, "bulletzako08.xml");
}

void configINIT()
{
	game_level = GLEVEL_EASY;
	normal_max = 0;
	concept_max = 0;
	original_max = 0;
	attack_mode = 0;
	time_mode = 0;
	repatk_mode = 0;
	reptime_mode = 0;

	auto File fd = new File;
	if(exists("config.dat")){
		initialized = 0;
		fd.open("config.dat");
		fd.read(game_ver);
		fd.read(game_level);
		fd.read(vol_se);
		fd.read(vol_music);
		fd.read(normal_max);
		fd.read(concept_max);
		if(game_ver > 0x0010) fd.read(original_max);
		fd.read(time_mode);
		fd.read(attack_mode);
		fd.close();
		if(game_ver != GAME_NOWVER) game_ver = GAME_NOWVER;
	}else{
		initialized = 1;
		fd.create("config.dat");
		fd.write(game_ver);
		fd.write(game_level);
		fd.write(vol_se);
		fd.write(vol_music);
		fd.write(normal_max);
		fd.write(concept_max);
		fd.write(original_max);
		fd.write(time_mode);
		fd.write(attack_mode);
		fd.close();
	}

	normal_stg   = normal_max;
	concept_stg  = concept_max;
	original_stg = original_max;

	volumeSNDse(vol_se);
	volumeSNDmusic(vol_music);

	for(int i = 0; i < high_score[0].length; i++){	/* normal mode */
		high_score[0][i] = 100000;
	}
	for(int i = 0; i < high_score[1].length; i++){	/* concept mode */
		high_score[1][i] = 100000;
	}
	for(int i = 0; i < high_score[2].length; i++){	/* score attack */
		high_score[2][i] = 100000;
	}
	for(int i = 0; i < high_score[3].length; i++){	/* time attack */
		high_score[3][i] = ONE_MIN * 99 + ONE_SEC * 59 + 59;
	}
	for(int i = 0; i < high_score[1].length; i++){	/* original mode */
		high_score[4][i] = 100000;
	}
	for(int i = 0; i < high_score[1].length; i++){	/* hidden mode */
		high_score[5][i] = 100000;
	}

	int[] score_tmp;

	if(exists("score.dat")){
		score_tmp = cast(int[])read("score.dat");
		for(int i = 0; i < high_score.length; i++){
			for(int j = 0; j < high_score[i].length; j++){
				high_score[i][j] = score_tmp[i*high_score[i].length+j];
			}
		}
	}else{
		write("score.dat", cast(void[])high_score);
	}
}

void configSAVE()
{
	auto File fd = new File;
	fd.create("config.dat");
	fd.write(game_ver);
	fd.write(game_level);
	fd.write(vol_se);
	fd.write(vol_music);
	fd.write(normal_max);
	fd.write(concept_max);
	fd.write(original_max);
	fd.write(time_mode);
	fd.write(attack_mode);
	fd.close();
}

void scoreSAVE()
{
	write("score.dat", cast(void[])high_score);
}
