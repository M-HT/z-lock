#!/bin/sh

FLAGS="-frelease -fdata-sections -ffunction-sections -fno-section-anchors -c -O2 -Wall -pipe -fversion=BindSDL_Static -fversion=SDL_201 -fversion=SDL_Mixer_202 -I`pwd`/import"

rm import/*.o*
rm import/sdl/*.o*
rm import/bindbc/sdl/*.o*
rm phobos/std/*.o*
rm src/*.o*

cd import
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS \{\} \;
cd sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS \{\} \;
cd ../bindbc/sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS \{\} \;
cd ../../..

cd phobos/std
gdc $FLAGS randomD1.d
cd ../..

cd src
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS -I../phobos \{\} \;
cd ..

gdc -o z-lock -s -Wl,--gc-sections -static-libphobos import/*.o* import/sdl/*.o* import/bindbc/sdl/*.o* phobos/std/*.o* src/*.o* -lGL -lSDL2_mixer -lSDL2 -lbulletml_d -L./lib/x64
