# Fireworks

Simulation of fireworks.

## Information

This program simulates launching fireworks and their explosion in sparks.

Its simulation involves some physics and use of particles. A _rocket_ (or a cow)
is launched and then explodes, launching multiple sparks (or spreading
milk) in random directions and fade until disappear.

They are represented in 3D and the camera be moved around the center.
But there are not reference points, so can be confusing.

### Ideas and improvements

  - [ ] Better interactivity, and less hooks to Window size, distance and
    gravity values:
    - Change distance of the camera.
    - Change initial velocity.
    - Change gravity.
  - [ ] Automatic and temporized launch.
  - [ ] Sound. LOL.

## Compiling

From main directory (where `build.sh` and `Build.bat`_ are):

### Unix-like:

```
./build.sh
```

### Windows:

Dbl-Click over `build.bat` or in command line:

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

By default some keys are assigned by _SDL3Engine_:

- **[ESC]**: Exit the program.
- **[F1]**: Toggle help text inside of the program.
- **[F11]**: Toggle FPS info.
- **[F10]** / **[F12]**: Decrease / Increase FPS.

In this program:

- **[SPACE]**: Launch a Firework.
- **[ARROWS]**: Change camera angle. Maybe is a little confusing...

## Sources and more information

- The Coding Train Challenge #027 and #28?- Fireworks (2D and 3D)
  by Daniel Shiffman.
  - http://codingtra.in - http://patreon.com/codingtrain
  - Video of CTC #027: https://youtu.be/CKeyIbT3vXI
  - Video of CTC #028: 
