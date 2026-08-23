# Rain

Program that simulates rain.

## Information

The simplest way to to simulate rain is drawing points or little lines from
the top to the bottom of the screen. Some sensation of deep can be achieved
by drawing smaller ones wich fall slower as if they are distant. Some
horizontal movement can be added to simulate wind, and a gravity effect to add
acceleration. Transparency can help too.

In this program, actual 3D coordinates will be used as well as gravity
and wind forces applied (using a _CHXPas_' `cCHXMover[x]` descendant). We can
set a ground level were drops dissapear (and create a splash).

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
both are equal and a value of `Window.RenderWidth` means 90º of horizontal FOV.

More advanced methods include perspective correction, aspect ratio (pixel and
screen ones), rotation and orientation of the camera (to know what is _up_
and _right_), use a projection plane instead a naked camera, &c.

As all divisions, we can't divide by 0. In this context, it means that the
_star_ with `Z = 0` is at the same XY Plane as the camera. It's easy to say
"ignore it, don't draw" and all _will work_ as expected, although there are
some quirks if _stars_ have size (or trails).

After this, don't forgive to translate (0,0) to the center of the screen.

### Variants and Improvements

Some ideas, not sure if they are noticeable unless gravity is very small:

- [X] **3D Wind**: Treat wind as and actual 3D force
- [ ] **Walking**: We can add movement.
- [X] **Splash**: Draw a little splash when a drop hits de floor.
- [ ] **Wet Floor**: Use a _SDLSurface_ as Floor. When an drop hits the floor,
  add some "water color" to the "pixel" hit.

## Compiling

From main directory (where `build.sh` and `Build.ba`_ are):

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

If Lazarus is used, maybe it's needed to add used units folders to the project.

### Scripts, Parameters and Executable

Both script files simply do the following:

1. Change to script directory.
2. Create FPC output directories.
3. Change to `{MainProg}.pas` directory.
4. Run `fpc @fp.cfg {MainProg}.pas [OtherParameters]`

So,

- FPC parameters can be passed to scripts to add or override _fp.cfg_ ones.
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

- **[F1]**: Toggle help text inside of the program.
- **[F11]**: Toggle FPS info.
- **[F10]** / **[F12]**: Decrease / Increase FPS.
- **[ESC]**: Exit the program.

In this program:

## Sources and more information

- **The Coding Train Challenge #{Seach}** by Daniel Shiffman
  - http://codingtra.in - http://patreon.com/codingtrain
  - Video: https://youtu.be/KkyIDI6rQJI
  - Not actual 3D projection of drops. Drops are lines falling with Size and
    Velocity wicvh depends on distance. They don't do splashs neither.
