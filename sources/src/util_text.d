/*
	D-System 'TEXT UTILITY'

		'util_text.d'

	2005/05/21 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.string;
private	import	std.math;
private	import	bindbc.sdl;
private	import	opengl;
private	import	util_sdl;
private	import	task;

struct TEXT {
	char[] str;
	int step;
	int len;
	int wait;
	int cnt;
}

void initTEXT(ref TEXT[] text, int cnt)
{
	text.length = cnt;
	for(int i = 0; i < text.length; i++){
		text[i].str.length = 0;
		text[i].step = 0;
		text[i].len  = -1;
		text[i].wait = 0;
		text[i].cnt  = 0;

	}
}

void freeTEXT(ref TEXT[] text)
{
	text.length = 0;
}

void setTEXTstr(ref TEXT text, char[] str)
{
	text.str = str;
}

void setTEXTwait(ref TEXT text, int wait)
{
	text.wait = wait;
	text.cnt  = 0;
	if(text.wait){
		text.len  = -1;
		text.step = 0;
	}else{
		text.len  = cast(int)(text.str.length);
		text.step = 1;
	}
}

char[] execTEXT(ref TEXT text)
{
	if(text.str.length == 0){
		return null;
	}

	if(!text.step){
		text.cnt++;
		if(text.wait == text.cnt){
			text.cnt = 0;
			text.len++;
		}
		if(text.str.length == text.len){
			text.step = 1;
		}
	}

	char[] tmp;

	if(text.step){
		tmp.length = text.str.length;
		tmp[] = text.str[];
	}else{
		if(text.len != -1){
			tmp.length = text.len;
			tmp[0 .. text.len] = text.str[0 .. text.len];
		}
	}

	return tmp;
}
