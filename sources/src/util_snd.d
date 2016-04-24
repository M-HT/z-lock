/*
	D-System 'SOUND UTILITY'

		'util_snd.d'

	2003/12/02 jumpei isshiki
*/

private	import	std.string;
private	import	std.stdio;
private	import	SDL;
private	import	SDL_mixer;
private	import	define;

enum{
	SND_RATE = 22050,
	SND_CHANNEL = 2,
	SND_BUFFER = 2048,
}

int	vol_se = 100;
int	vol_music = 100;
int	master_vol = 128;

private	bool 		sound_use = false;
private	Mix_Music*[]	music;
private	Mix_Chunk*[]	chunk;
private	int[]			chunkChannel;
private	int[]			musicLoops;
private	int 		musicPlayNum;

private int intro_flag;
private int loop_music;
private int fade_ctrl;
private int fade_time;
private float fade_vol;
private float fade_rate;

int initSND(int mch, int sch)
{
	if(mch < 1 || sch < 1)
	{
		return	0;
	}
	if(SDL_InitSubSystem(SDL_INIT_AUDIO) < 0){
		return	0;
    }

    int audio_rate;
    Uint16	audio_format;
    int audio_channels;
    int audio_buffers;

	audio_rate = SND_RATE;
	audio_format = AUDIO_S16;
	audio_channels = SND_CHANNEL;
	audio_buffers = SND_BUFFER;
	if(Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers) < 0){
		sound_use = false;
	}else{
		sound_use = true;
	}
	Mix_QuerySpec(&audio_rate, &audio_format, &audio_channels);

	music.length = mch;
	musicLoops.length = mch;
	for(int i = 0; i < music.length; i++){
		music[i] = null;
		musicLoops[i] = -1;
	}
	musicPlayNum = -1;

	chunk.length = sch;
	chunkChannel.length = sch;
	for(int i = 0; i < chunk.length; i++){
		chunk[i] = null;
		chunkChannel[i] = -1;
	}

	intro_flag = 0;
	loop_music = -1;

	return	1;
}

void closeSND()
{
	if(!sound_use){
		return;
	}
	freeSND();
	Mix_CloseAudio();
}

void loadSNDmusic(const char[] name, int ch, int loops)
{
	if(!sound_use){
		return;
	}

	const char[] fileName = name ~ "\0";

	music[ch] = Mix_LoadMUS(std.string.toStringz(fileName));
	if(!music[ch]){
		sound_use = false;
	}else{
		musicLoops[ch] = loops;
	}
}

void loadSNDse(const char[] name, int bank, int ch)
{
	if(ch < 0){
		return;
	}
	if(!sound_use){
		return;
	}

	const char[] fileName = name ~ "\0";

	chunk[bank] = Mix_LoadWAV(std.string.toStringz(fileName));
	if(!chunk[bank]){
		sound_use = false;
	}
	chunkChannel[bank] = ch;
}

void freeSND()
{
	for(int i = 0; i < music.length; i++){
	    if(music[i]){
			stopSNDmusic();
			Mix_FreeMusic(music[i]);
		}
		music[i] = null;
	}
	for(int i = 0; i < chunk.length; i++){
		if(chunk[i]){
			stopSNDse(chunkChannel[i]);
			Mix_FreeChunk(chunk[i]);
		}
	}
}

void playSNDmusic(int ch)
{
	if(ch < 0 || !music[ch]){
		return;
	}
	if(!sound_use){
		return;
	}
	fade_ctrl = 0;
    musicPlayNum = ch;
	volumeSNDmusic(vol_music);
    Mix_PlayMusic(music[ch], musicLoops[ch]);
}

void stopSNDmusic()
{
	if(!sound_use){
		return;
	}
    if(Mix_PlayingMusic()){
		Mix_HaltMusic();
		musicPlayNum = -1;
	}
}

void pauseSNDmusic(int flag)
{
	if(!sound_use){
		return;
	}

	if(!checkSNDmusic()){
		return;
	}

    if(flag == -1){
	    if(!Mix_PausedMusic()) Mix_PauseMusic();
		else				   Mix_ResumeMusic();
	}else if(flag == 0){
		Mix_ResumeMusic();
	}else if(flag == 1){
		Mix_PauseMusic();
	}
}

bool checkSNDmusic()
{
	if(!sound_use){
		return	false;
	}
    if(Mix_PlayingMusic()){
		return	true;
	}

	return	false;
}

void fadeSNDmusicSet(int flag, int time)
{
	fade_ctrl = flag;
	fade_time = time;
}

void fadeSNDmusicCtrl()
{
	if(musicPlayNum == -1){
		return;
	}

	if(!fade_ctrl){
		return;
	}

	if(fade_ctrl == 1){
		fade_ctrl = 2;
		fade_vol = cast(float)vol_music;
		fade_rate = fade_vol / cast(float)fade_time;
	}

	if(fade_ctrl == 2){
		fade_time--;
		if(fade_time){
			fade_vol -= fade_rate;
			Mix_VolumeMusic(cast(int)fade_vol);
		}else{
			fade_vol = 0.0f;
			fade_ctrl = 0;
			Mix_VolumeMusic(cast(int)fade_vol);
			musicPlayNum = -1;
		}
	}
}

void loopSNDmusicCtrl()
{
	if(!intro_flag) return;
	if(loop_music == -1) return;
	if(checkSNDmusic() == true) return;
	playSNDmusic(loop_music);
	intro_flag = 0;
	loop_music = -1;
}

void playSNDse(int bank)
{
	if(bank < 0 || chunkChannel[bank] == -1 || !chunk[bank]){
		return;
	}
	if(!sound_use){
		return;
	}
    Mix_PlayChannel(chunkChannel[bank], chunk[bank], 0);
}

void stopSNDse(int bank)
{
	if(bank < 0 || chunkChannel[bank] == -1){
		return;
	}
	if(!sound_use){
		return;
	}
    Mix_HaltChannel(chunkChannel[bank]);
}

int checkSNDse(int ch)
{
	if(ch < 0){
		return	0;
	}
	if(!sound_use){
		return	0;
	}

	return	Mix_Playing(ch);
}

void pauseSNDse(int flag)
{
	if(!sound_use){
		return;
	}

    if(flag == -1){
		for(int i = 0; i < SND_SEBANKMAX; i++){
		    if(!Mix_Paused(i)) Mix_Pause(i);
			else			   Mix_Resume(i);
		}
	}else if(flag == 0){
		for(int i = 0; i < SND_SEBANKMAX; i++){
			Mix_Resume(i);
		}
	}else if(flag == 1){
		for(int i = 0; i < SND_SEBANKMAX; i++){
			Mix_Pause(i);
		}
	}
}

void stopSNDall()
{
	for(int i = 0; i < music.length; i++){
	    if(music[i]){
			stopSNDmusic();
		}
	}
	for(int i = 0; i < chunkChannel.length; i++){
		stopSNDse(i);
	}
}

void volumeSNDse(int vol)
{
	int master = vol * master_vol / 100;
	for(int i = 0; i < chunk.length; i++){
		if(chunk[i]){
			Mix_VolumeChunk(chunk[i], master);
		}
	}
}

void volumeSNDmusic(int vol)
{
	int master = vol * master_vol / 100;
	Mix_VolumeMusic(master);
}
