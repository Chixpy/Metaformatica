# StarField

A simple simulation of a space travel between stars like old movies. By _stars_
we can mean planets, spaceships or cows.

## Information

This simulation is made projecting 3D points (or shapes) while they _move_
towards the Camera, instead _moving_ the camera. Tecnically, is usual in 3D
that camera never _moves_, it's the world who moves instead.

To keep no end sensation, not visible anymore _stars_ (ones behind the camera
and ones which are out of the screen) will be moved to be visible at huge
distance again.

The simplest way to make 3D perspective with deep sensation is dividing camera
plane coordinates (in this example `X` and `Y`) by deep coordinate (`Z` here,
positive is in from of the camera).

```
X' := X / Z * k;
Y' := Y / Z * j;
```

`k` and `j` constants can be define erroneously as "the size on the screen
of 1 unit at 1 unit of distance (horizontally and vertically)" or
correctly as Focal Lengths. They are FOV related. If screen pixels are square,
both are equal and  a value of `Window.RenderWidth` means 90º of FOV.

More advanced methods include perspective correction, aspect ratio (pixel and
screen ones), rotation and orientation of the camera (to know what is _up_
and _right_), use a projection plane instead a naked camera, &c.

As all divisions, we can't divide by 0. In this context, it means that the
_star_ with `Z = 0` is at the same XY Plane as the camera. It's easy to say
"ignore it, don't draw" and all _will work_ as expected, although there are
some quirks if _stars_ have size (or trails).

After this, don't forgive to translate (0,0) to the center of the screen.

### Variants and improvements

Some improved variants can be implemented (only some are done), all of
them add more complexity and computations to the base algorithm:

- [x] **Velocity**: Changing the velocity of camera is the easiest one. If we
  remove not visible _stars_, a going backwards algorithm must be adapted. Or
  simply don't let going backwards.
- [x] **Change direction**: Changing Camera position vertically or horizontally
  (by shifting all _stars_), althought physically possible, maybe is not
  satisfactory because it's expected to rotate (and then rotate al _stars_).
- [ ] **Star movement**: _Stars_ can have movement by themselves, as in
  reallity. But may be it not noticeable.
- [x] **Colors**: Obvious, to add variety to the stars.
  - No Doppler effect involved. It will be cumbersome.
  - If a _star_ overlaps other in same screen coordinates... teorically, We
    need to know who is closest to the camera. With no-size points it can be
    ignored as they are small it only will last few frames.
- [x] **Size** (and shape): Define a size of the _stars_ and shape, usually a
  circle but it can be anything, a geometric star or a cow^2.
  - Giving a size means that _stars_ grow as we aproach them. Overlaping and
    hidding will be more common. For a correct representation, sorting  _stars_
    by distance is required, then draw from far to near.
    - With Circle, Rect and spherical cows (and maybe Regular Polygon and
      ellipse too) can be easy to optimize by removing _stars_ totally hidded
      by others. A _QuadTree_ can be usefull here too.
    - Giving another shape, searching totally hidded _stars_ can be complex.
  - Testing for _stars_ out of screen must be done with projected shape as a
    whole.
- [-] **Trails**: Adding trails increases speed sensation.
  - Initially it is easy, with simple points we can keep previous position and
    draw a line from it to current position.
    - Alpha for the can be used, ideally gradient, having same quirks as
      colors wich can be ignored in this case.
    - For a line with gradient alpha, a custom drawing function must be created.
  - With _stars_ with size, we need to sort the _stars_ **AND** _Trails_,
    - The problem is that if a _star_ position is crossed by a trail.
      As it last for one frame, it can be ignored.
    - Trails there are no longer a simple lines, they are at least a
      Quad(rilateral)
  - A _star_ with trail can't be removed until both _star_ and trail is out
    of the screen.


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

If Lazarus is used, maybe it's needed to add used units folders to the project.

### Scripts, Parameters and Executable

Both script files simply do the following:

1. Change to script directory.
2. Create FPC output directories.
3. Change to `{MainProg}.pas` directory.
4. Run `fpc @fpMeta.cfg {MainProg}.pas [OtherParameters]`

So,

- FPC parameters can be passed to scripts to add or override _fp.cfg_ ones.
- Parameter `-dRELEASE` generates a smart linked, stripped and optimized
  executable. By default, debug one will be created with debug info, error
  checking fallback and `heaptrc` unit for memory leaks.

Executable program will be created in `bin/` directory. As said in _Compiling_,
it need _at least_ find `SDL3.{dll|o}`. In Windows, it's not common to have it
in a system folder so a copy of `SDL3.dll` in the same folder as executable.

Furthermore, executable will change its current directory to the directory
wherte it resides to search external files if needed (own _SDL3Engine_ config
file for example).

## Usage

By default some keys are assigned:

- **[F1]**: Toggle help text inside of the program.
- **[F11]**: Toggle FPS info.
- **[F10]** / **[F12]**: Decrease / Increase FPS.
- **[ESC]**: Exit the program.

In this program:

- **[Q]** / **[A]**: Increase / Decrease speed.
- **[S]**: Toggle Shape / Point drawing.
- **[T]**: Toggle Trails drawing.
- **Arrows**: Turn direction.

## Sources and more information

- _The Coding Train Challenge_ #001 by Daniel Shiffman
  - http://codingtra.in - http://patreon.com/codingtrain
  - Processing implementation.
  - Video implementing this: https://youtu.be/17WoOqgXsRM
  - Actual inspiration of this project and CHXSDL[2/3]Engine
- _PcMania nº <unknown>_, Sección Metaformática, Pág. <unknown>.
  - Turbo Pascal implementation. No OOP.
