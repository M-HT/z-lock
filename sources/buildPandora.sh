#!/bin/sh

FLAGS="-fversion=PANDORA -frelease -fno-section-anchors -c -O2 -pipe"

rm import/*.o*
rm phobos/std/*.o*
rm src/*.o*

cd import
$PNDSDK/bin/pandora-gdc $FLAGS *.d
rm openglu.o*
cd ..

cd phobos/std
$PNDSDK/bin/pandora-gdc $FLAGS randomD1.d
cd ../..

cd src
$PNDSDK/bin/pandora-gdc $FLAGS -I../import -I../D1/phobos *.d
cd ..

$PNDSDK/bin/pandora-gdc -o z-lock -s -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGL -lSDL_mixer -lmad -lSDL -lts -lbulletml_d -L./lib/arm import/*.o* phobos/std/*.o* src/*.o*
