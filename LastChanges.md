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
