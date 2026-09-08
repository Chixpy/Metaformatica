# Snake

Simple snake game.

## Information

The simple and typical _Snake_ game.

The Snake moves automatically forward in a grid and the player must guide it
to eat dots (or cows). Eating a dot the snake length increases (maybe because
of the nutritive milk). Sometimes speed is increased as well.

The game finish when the snake collides with itself or a wall. Usually there
is not a winning condition, except to dead because the snake have not more
space in the grid.

### Variations and improvements:

There are too many versions, variations and posibilities to improve this
basic premise. To say some:

- Better _game feeling_: Score, Levels with different obstacle layout,
  additional dificulty increase, a winning condition, bonus items, enemies.
- Graphics from Text Mode to 3D Raytracing.
- Freedom of movement instead a square grid, turning some angle the snake
  instead 90º of the grid.
- Multiplayer, similar to cycles of TRON movie

## Compiling

From main directory (where `build.sh` and `Build.bat` are):

### Unix-like:

```
./build.sh
```

### Windows:

Dbl-Click over `Build.bat` or in command line:

```
build
```

On Windows, Free Pascal Compiler program is suposed to be in
`PATH` enviroment variable and executable's folder must have _SDL3.dll_ (and
other _.dll_ if needed) and be sure that they are for the compiled
architecture (32/64bits).

If Lazarus is used, maybe it's needed to add manually used units folders to
the project.

### Scripts, Parameters and Executable

Both script files simply do the following:

1. Change to script directory.
2. Create FPC output directories (defined in `fp.cfg`):
  - `bin` for executable.
  - `../../../0Common/lib` for libraries (`.o`, `.ppu`).
3. Change to `{MainProg}.pas` directory.
4. Run `fpc @fpMeta.cfg {MainProg}.pas [OtherParameters]`.
5. Return to initial directory.

So,

- FPC parameters can be passed to scripts to add or override `fp.cfg` ones.
- Parameter `-dRELEASE` generates a smart linked, stripped and optimized
  executable. By default, debug one will be created with debug info, error
  checking fallback and `heaptrc` unit for memory leaks.

Executable program will be created in `bin/` directory. As said in _Compiling_,
it need _at least_ find `SDL3.{dll|o}`. In Windows it's not common to have it
in a system folder, so it needs a copy of `SDL3.dll` in executable's folder.

Furthermore, executable will change its current directory to the directory
where it resides to search external files if needed (own _SDL3Engine_ config
file for example).

## Usage

By default some keys are assigned:

- **[ESC]**: Exit the program.
- **[F1]**: Toggle help text inside of the program.
- **[F11]**: Toggle FPS info.
- **[F10]** / **[F12]**: Decrease / Increase FPS.

In this program:

- **[ARROWS]** / **[WASD]**: Change Snake direction.

## Sources and more information

- `Nibbles.bas` by Rick Raddarz.
  - Q[uick] Basic - QB64. Text mode (80x50 grid on 80x25 mode), 10 Levels,
    2 Players.
  - Included with MS-DOS 5.0+. 
- The Coding Train Challenge #003 - Snake Game by Daniel Shiffman.
  - Processing
  - http://codingtra.in - http://patreon.com/codingtrain
  - Video of implementation: https://youtu.be/AaGK-fj-BAM
- The are huge amount of implementations outside there.
