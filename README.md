# Metaformatica
Miscelaneous programs, simulations, algorithms and tests. Mainly in Free Pascal
with cCHXSDL3Engine.

## About the repository

This repository has unsorted programs with miscellaneous small little
projects: Fractals, Minigames, Simulations, Data Structures visualization,
and other experiments.

### Folder structure

The basic directory structure of Metaformática is:

- _README.md_: This text.
- _LastChanges.md_: Last changes commited to the repository.
- _CHANGELOG.md_: Full change log.
- _0Base/_: Template program structure (to be copied).
  - _README.md_: Information about the program.
  - _bin/_: Final program directory.
    - _[Architecture]/_: Actual executable directory (and dll).
    - _[OtherFolderFiles]_: Whatever executable needs to run.
  - _lib/_: Where compiler will put compilation files.
  - _src/_: Source directory.
    - _[MainProgram].pas_: Program(s) for compiling.
    - _fpc.cfg_: FPC config file for easy compiling.
    - _[Units/Classes]/_: Directories with units used by the program.
  - _[res/man/doc]/_: Recurses/Manual/Documentation if exists.
- _0Common/_: 
  - _[Units/Classes]/_: Common units between programs but not in CHXPas.
  - _CHXPas/_: CHXPas units, where cCHXSDL3Engine is.
  - _SDL3/_: SDL3-for-Pascal submodule, used by cCHXSDL3Engine.
- _[Category]/_ Actual programs directory, each in its own folder.

Maybe, someday, all of above is under _Pascal_ directory because programs in
other languages are added (although surely I will try to port to Pascal).

### Compilation

Every project have a _Build.sh/bat_ for easy compilation, but they only does
in _src_ folder:

```
fpc @fp.cfg [MainFile].pas
```

All fpc parameters are in _fp.cfg_.

Executable file will be created at _bin_ directory, and it must run from
there.

On Windows, _fpc_ compiler program is suposed to be in `PATH` enviroment
variable and executable's folder must have _SDL3.dll_ (and other .dll if 
needed) and be sure that they are for the _compiled_ architecture (32/64bits).

If Lazarus is used, maybe it's needed to add units folders to the project.

## About `cCHXSDL3Engine`

`cCHXSDL3Engine` is a class very similar to _GameEngine_ pattern. Two main
differences are very little anyways:
- Main Loop is divided in three methods: `Compute`, `Draw` and `HandleEvent`.
  Nothing stops to use only one for all things, but have some differences:
    - `Compute` is intended for algorithm computation. With `ExitProg` variable
      can finish program execution by itself. Time spend inside it is
      monitorized by `cCHXSDLFPSManager`.
    - `Draw` is for drawing. It's not called if the Window is minimized.
    - `HandleEvent` is called once per Event ocurred between frames and some
      of then are automatically handle by `cCHXSDL3Engine` components.
- Order of the loop is `Compute`, `Draw` and `HandleEvent` while usually
  _GameEngine_ pattern is handle events first, and then compute and draw.
  In real time there is not difference at all.
- Actually there are 2 other methods:

Other classes are developed to help:
- `cCHXSDLWindow` encapsulates `SDL_Window` and handles window events.
- `cCHXSDLFrameManager` keeps framerate constant with interpolation and
  stores some information related: `FrameCounter`, `LastFrameTime` and
  `LastCompTime` (Last computation time).
- `cCHXSDLRenderer` encapsulates `SDL_Renderer` and its functions, and
  proporcionate more primitives to draw than vanilla SDL3 without *SDL_gfx*
  library.
- `cCHXSDLTypeHelpers` is a unit with helpers for SDL types, operator
  overloads and some useful types.

The engine uses **SDL3-for-FreePascal** project headers.
