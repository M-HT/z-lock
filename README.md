# Z-LOCK

Japanese shooter with a twist: your shot power is directly proportional to the number of enemies locked on to you.

## How to play

At the title screen, you can select a game mode.

- Normal-mode:
  - A shot can be shot even if lock on is not carried out.
- Concept-mode:
  - If not locked by the enemy, then a shot cannot be shot.
- Original-mode:
  - Prototype mode for the game.
- Hidden-mode:
  - Enemy shells become invisible gradually.
- Score attack:
  - Competition for score that can be earned in 3 minutes.
- Time attack:
  - Competition for time it takes to earn 1 million points.

<hr/>

The game was created by [HELLO WORLD PROJECT (Jumpei Isshiki)](https://web.archive.org/web/20170507115557/http://isk8086.my.coocan.jp/prog_win_d.html "HELLO WORLD PROJECT (Jumpei Isshiki)") and released with BSD 2-Clause License. (See readme.txt/readme_e.txt)

This fork is a port to D version 2, Linux, SDL2, Pandora, DragonBox Pyra.

It uses the [libBulletML](https://shinh.skr.jp/libbulletml/index_en.html "libBulletML") library by shinichiro.h.

It uses std.random module from D version 1, ported to D version 2, which is under zlib/libpng License (See phoboslicense.txt in sources/phobos directory).

It uses [BindBC-SDL](https://github.com/BindBC/bindbc-sdl "BindBC-SDL") (D bindings to SDL), which is under [Boost Software License](https://www.boost.org/LICENSE_1_0.txt "Boost Software License").
