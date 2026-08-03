{<

  (c) 2026 Chixpy
}
{$mode ObjFPC}{$H+}
uses
  CTypes, SDL3,
  ucMainEng;

const
  // Renderer scales images to actual size of the window.
  RenderW: Integer = 300; { Renderer width. }
  RenderH: Integer  = 300; { Renderer height. }
  WindowScale = 3; { Scale of the Window. }

var
  CTCEng : cMainEng;

begin
  CTCEng := cMainEng.Create('Metaformática', RenderW, RenderH, False);
  try
    // We can change configuration, call init and then run the engine...
    CTCEng.Config.WindowWidth := Trunc(RenderW * WindowScale);
    CTCEng.Config.WindowHeight := Trunc(RenderH * WindowScale);
    CTCEng.Init;
    CTCEng.Run;
  finally
    SDL_LogInfo(SDL_LOG_CATEGORY_APPLICATION, 'Program finished.');
    if SDL_GetError <> '' then
      SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, SDL_GetError);
    if SDL_GetNumAllocations >= 0 then
       SDL_LogWarn(SDL_LOG_CATEGORY_APPLICATION,
         'SDL memory not freed: %d', [SDL_GetNumAllocations]); 
    CTCEng.Free;
  end;
end.
{
  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}
