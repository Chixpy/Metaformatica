# Metaformática
Miscelaneous programs, simulations, algorithms and tests. Mainly with Free
Pascal using `cCHXSDL3Engine`.

## About the repository

This repository has unsorted programs with miscellaneous small little
projects: Fractals, Minigames, Simulations, Data Structures visualization,
and other experiments.

### Folder structure

The basic directory structure of Metaformática is:

- `CHANGELOG.md`: Full change log.
- `LastChanges.md`: Last changes commited to the repository.
- `NewProject.sh`: Script to create structure for a new program.
- `README.md`: This text.
- `0Base/`: Template structure for programs (to be copied with
  `NewProject.sh`).
  - `README.md`: Information about the program.
  - `build.sh` and `Build.bat`: Created by `NewProject.sh`.
  - `bin/`: Final program directory.
    - `{Executable}`: Actual executable program (and dll).
    - `{OtherFolderOrFiles}`: Whatever executable needs to run.
  - `lib/`: Where compiler will put compilation files.
  - `src/`: Source directory.
    - `{MainProgram}.pas` Main program(s) for compiling.
    - `fp.cfg`: FPC config file for easy compiling.
    - `Units/`: Directory with non common units used by the program.
  - `res/`, `man/`, `doc/`: Compilation recurses, User manual, Documentation,
     &c; if exists.
- `0Common/`: Submodules and common units.
  - `Units/`: Common units between programs but not in _CHXPas_ or other
    submodule.
  - `CHXPas/`: _CHXPas_ repository as git submodule, where `cCHXSDL3Engine` 
    actually is.
  - `SDL3/`: SDL3-for-Pascal submodule, used by `cCHXSDL3Engine`.
- `{Category}/{ProgramDir}/`: Actual programs directory, each in its own
  folder.

Maybe, someday, all of above is under `Pascal` directory because programs in
other languages are added... (but surely I will try to port to Pascal).

### Compilation

Every project have a `Build.{sh|bat}` for easy compilation, but they only 
changes to `src` folder and execute:

```
fpc @fp.cfg {MainFile}.pas
```

All FPC config parameters are in `fp.cfg`.

Executable file will be created at `bin` directory, and it must run from
there.

On Windows, `fpc` compiler program is suposed to be in `PATH` enviroment
variable and executable's folder must have `SDL3.dll` (and other _.dll_ if
needed) and be sure that they are for the _compiled_ and system
architecture (32/64bits).

If _Lazarus_ is used for compilation, maybe it's needed to add units folders
manually to the project configuration.

## About `cCHXSDL3Engine`

`cCHXSDL3Engine` is a class very similar to _GameEngine_ pattern. Two main
differences are very little anyways:
- Main Loop is divided in three methods: `Compute`, `Draw` and `HandleEvent`.
  Nothing stops to use only one for all things, but have some differences:
    - `Compute` is intended for algorithm computation. With `ExitProg` variable
      can finish program execution by itself. Time spend inside it is
      monitorized by `cCHXSDLFPSManager`.
    - `Draw` is for drawing of course. It's not called if the Window is
      minimized.
    - `HandleEvent` is called once per Event ocurred between frames. Some
      of then are automatically handled by `cCHXSDL3Engine` or its components.
- Order of the loop is `Compute`, `Draw` and `HandleEvent` while usually
  _GameEngine_ pattern is to handle events first; and then compute and draw.
  In real time there is not difference at all.
- Actually there are 2 other methods:
  - `Setup` is called once before entering the main loop for setting initial
    values, object creation, etc.
  - `Finish` is called after exiting main loop for memory freeing or other
    finalization stuff.

Other classes and units are developed to help:

- `cCHXSDLWindow` (`Window` property inside of the engine) encapsulates
  `SDL_Window` and handles window events.
- `cCHXSDLFrameManager` (`FPSMng` property) keeps framerate constant with
  interpolation and stores some information related: `FrameCounter`,
  `LastFrameTime` (Total frame time) and `LastCompTime` (Last computation
  time).
- `cCHXSDLRenderer` (`Render` property) encapsulates `SDL_Renderer` and
  its primitive functions, and proporcionate more primitives to draw than
  vanilla _SDL3_ without `SDL_gfx` library.
- `cCHXSDLTypeHelpers` is a unit with helpers for SDL types, operator
  overloads and some other useful types.

The engine uses **SDL3-for-FreePascal** project headers.
