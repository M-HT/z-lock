/*
  SDL_image:  An example image loading library for use with SDL
  Copyright (C) 1999, 2000, 2001  Sam Lantinga

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Sam Lantinga
  slouken@libsdl.org
*/

/* $Id: SDL_image.h,v 1.13 2002/04/13 15:06:00 slouken Exp $ */

// convert to D by shinichiro.h

/* A simple library to load images of various formats as SDL surfaces */

import SDL;

extern (C) {

/* Load an image from an SDL data source.
   The 'type' may be one of: "BMP", "GIF", "PNG", etc.

   If the image format supports a transparent pixel, SDL will set the
   colorkey for the surface.  You can enable RLE acceleration on the
   surface afterwards by calling:
   SDL_SetColorKey(image, SDL_RLEACCEL, image->format->colorkey);
*/
	SDL_Surface * IMG_LoadTyped_RW(SDL_RWops *src, int freesrc, char *type);
/* Convenience functions */
	SDL_Surface * IMG_Load(char *file);
	SDL_Surface * IMG_Load_RW(SDL_RWops *src, int freesrc);

/* Invert the alpha of a surface for use with OpenGL
   This function is now a no-op, and only provided for backwards compatibility.
*/
	int IMG_InvertAlpha(int on);

/* Functions to detect a file type, given a seekable source */
	int IMG_isBMP(SDL_RWops *src);
	int IMG_isPNM(SDL_RWops *src);
	int IMG_isXPM(SDL_RWops *src);
	int IMG_isXCF(SDL_RWops *src);
	int IMG_isPCX(SDL_RWops *src);
	int IMG_isGIF(SDL_RWops *src);
	int IMG_isJPG(SDL_RWops *src);
	int IMG_isTIF(SDL_RWops *src);
	int IMG_isPNG(SDL_RWops *src);
	int IMG_isLBM(SDL_RWops *src);

/* Individual loading functions */
	SDL_Surface * IMG_LoadBMP_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadPNM_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadXPM_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadXCF_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadPCX_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadGIF_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadJPG_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadTIF_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadPNG_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadTGA_RW(SDL_RWops *src);
	SDL_Surface * IMG_LoadLBM_RW(SDL_RWops *src);

	SDL_Surface * IMG_ReadXPMFromArray(char **xpm);

/* We'll use SDL for reporting errors */
//#define IMG_SetError	SDL_SetError
	char* IMG_GetError() {
		return SDL_GetError();
	}

}
