# Metaformatica
Miscelaneous programs, simulations, algorithms and tests. Mainly in Free Pascal
with cCHXSDL3Engine.

## About the repository

This repository has unsorted programs with miscellaneous small little
projects: Fractals, Minigames, Simulations, Data Structures visualization,
and other experiments.

### Folder structure

The basic directory structure is:

   Metaformatica/
     |> README.md: This text.
     |> LastChanges: Last changes commited to the repository.
     |> CHANGELOG.md: Full change log.
     |
     |> 0Base/: Template program structure (to be copied).
     |    |> README.md: Information about the program.
     |    |
     |    |> bin/: Final program directory.
     |    |    |> [Architecture]: Actual executable directory
     |    |    |> [OtherFolderFiles]: Whatever executable needs to run.
     |    |
     |    |> lib: Where compiler will put compilation files.
     |    |
     |    |> src/: Source directory.
     |    |    |> [MainProgram].pas: Program(s) for compiling
     |    |    |> fpc.cfg: FPC config file for easy compiling.
     |    |    |
     |    |    |> [Units/Classes]/: Directories with units used by the program.
     |    |
     |    |> [res/man/doc]: Recurses/manual/documentation if exists
     |
     |
     |> 0Common/: 
     |    |> [Units/Classes]/: Common units between programs but not in CHXPas.
     |    |> CHXPas/: CHXPas units, where cCHXSDL3Engine is.
     |
     |
     |
     |> [Category]/ Actual programs directory, each in its own folder

Maybe, someday, all of above is under `Pascal` directory because programs in 
other languages are added (although surely I will try to port to Pascal).

### Compilation

Compiling the programs must be as simple as, in `[MainFile].pas` folder:

```
fpc [MainFile].pas
```

Executable file will be created at `../bin/[Architecture]/` from
_MainFile.pas_ directory, and it will run from there. In Windows, this
folder must have _SDL3.dll_ (and other .dll if needed) and be sure that they
are for the _compiled_ architecture (32/64bits).

Not sure if Lazarus

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

