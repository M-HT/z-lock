#!/bin/sh

FLAGS="-frelease -fno-section-anchors -c -O2 -Wall -pipe -fversion=PANDORA -fversion=BindSDL_Static -fversion=SDL_201 -fversion=SDL_Mixer_202 -I`pwd`/import"

rm import/*.o*
rm import/sdl/*.o*
rm import/bindbc/sdl/*.o*
rm phobos/std/*.o*
rm src/*.o*

cd import
$PNDSDK/bin/pandora-gdc $FLAGS *.d
cd sdl
$PNDSDK/bin/pandora-gdc $FLAGS *.d
cd ../bindbc/sdl
$PNDSDK/bin/pandora-gdc $FLAGS *.d
cd ../../..

cd phobos/std
$PNDSDK/bin/pandora-gdc $FLAGS randomD1.d
cd ../..

cd src
$PNDSDK/bin/pandora-gdc $FLAGS -I../import -I../phobos *.d
cd ..

$PNDSDK/bin/pandora-gdc -o z-lock -s -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGL -lSDL2_mixer -lSDL2 -lbulletml_d -L./lib/arm import/*.o* phobos/std/*.o* src/*.o*
