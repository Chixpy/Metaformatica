unit ucMainEng;
{< Main engine.

  This file is part of 

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}
interface
uses
  SysUtils, Math, CTypes,
  SDL3,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers;

type

  { cMainEng }

  cMainEng = class(cCHXSDL3Engine)
  protected
    ShowHelp: Boolean;

    procedure Setup; override; { It's abstract. }
    procedure Finish; override; { It's abstract. }
    procedure Compute(var ExitProg : Boolean); override; { It's abstract. }
    procedure DrawHelp;
    procedure Draw; override; { It's abstract. }
    procedure HandleEvent(const aEvent : TSDL_Event; var Handled : Boolean;
      var ExitProg : Boolean); override; { It's virtual. }

  public


  end;

implementation

{ cMainEng }

procedure cMainEng.Setup;
begin
  ShowFrameRate := True; ShowHelp := True;
  // If we require a fixed logical size.
  // Window.SetRenderSize(200, 200, SDL_LOGICAL_PRESENTATION_LETTERBOX);

end;

procedure cMainEng.Finish;
begin

end;

procedure cMainEng.Compute(var ExitProg : Boolean);
begin

end;

procedure cMainEng.Draw;
begin
  Render.Clear(0, 0, 0);
  Render.SetDrawColor(1, 1, 1);

  if ShowHelp then DrawHelp;
end;

procedure cMainEng.DrawHelp;
var
  CurrW, CurrH: Integer;
begin
  CurrW := Window.Width; CurrH := Window.Height;
  Window.SetRenderSize(400, 400);
  Render.SetDrawColor(1, 0, 1, 1);
  Render.DebugText(0, 10, '[ESC]: Exit');
  Render.DebugText(0, 20, '[F1]: Toggle this help');
  Render.DebugText(0, 30, '[F11]: Toggle FPS');
  Render.DebugText(0, 40, '[F10]/[F12]: Dec/Inc FPS');
  
  Window.SetRenderSize(CurrW, CurrH);
end;

procedure cMainEng.HandleEvent(const aEvent : TSDL_Event;
var Handled : Boolean; var ExitProg : Boolean);
begin
  inherited;
  if ExitProg or Handled then Exit;

  case aEvent.type_ of
    SDL_EVENT_KEY_DOWN:
    begin
      Handled := True;
      case aEvent.key.key of
        // SDLK_ESC, SDLK_F10, SDLK_F11, SDLK_F12:
        //   Managed by cCHXSDLRenderer
        SDLK_F1: ShowHelp := not ShowHelp;

      otherwise // of aEvent.key.key
        Handled := False;
      end;
    end;
  otherwise // of aEvent.type_
    ;
  end;
end;

end.
{<
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
