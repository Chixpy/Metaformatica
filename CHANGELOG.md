## 2026-08-23 23:15

- Some Readme files and comments edition.
- Added Application Data to `MainEng.pas`.
- Executables will create `{Executable}.ini` on first execution and will
  read it next times. But it will no write changes at runtime by default.
- Adding _Rain_ simulation, but not finished until `cCHXSDL3Renderer` is
  reworked.
- `0Common/Units` for common units of Metaformática programs, obviusly.

## 2026-08-16 01:57

- Ouch, ingnoring _bin_ and _lib_ directories from projects by default.
  Removing test ones for the first project.
- Adding the program _StarField_.

## 2026-08-07 20:16

- Better _Build.bat_ and _build.sh_ created by _NewProject.sh_. Now
  they must compile from anywhere and create executable in project's _bin_
  directory.
- _BuildAll.bat_ and _buildall.sh_ compile all projects in subfolders.
- _0Base/MainProg.pas_: Reworked.
  - No window size consts, now config file is readed for window size (Renderer
    logical size and window size can be read or set inside `cCHXSDL3Engine`
    anyway).
  - Removed SDL debug info because `cCHXSDL3Engine` do it by itself of
    `Destroy`.
- _0Base/Classes/ucMainEng.pas_: Added some initial code.
  - Added `[F1]` to show help, and shows `cCHXSDL3Engine` keys initially.
  - Set Logical size on `Setup`.

## 2026-08-06 01:59

- _build.sh/bat_ will pass its parameters to _fpc_.
- Fixing `cMainEng` class name from _ucMainEng.pas_
- Now, new empty proyects compile. Let's have fun.

## 2026-08-04 01:55

- Fixing _README.md_ mess with estructure and more info compiling.
- Ops, removed _Fractal/Merger_. It was little test with _NewProject.sh_.
- Moving _CHXPas_ submodule to _0Common/CHXPas_.
- Adding _SDL3-for-Pascal_ in _0Common/CHXPas_.
- Renaming _000Base_ to _0Base_.

## 2026-08-03 20:23

Initial commit after creation. None useful yet.
- Writing some info at _Readme.md_.
- Creating initial directory structure and _000Base_ template.
- _NewProject.sh_ to create new projects copying _000Base_ template. And 
  creating _build.sh/bat_ for project compilation.
- Adding CHXPas as submodule.

Nothing interesting yet.


