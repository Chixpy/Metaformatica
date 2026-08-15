unit ucMainEng;
{<
  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}
interface
uses
  CTypes, SysUtils, Math,
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
  Window.SetRenderSize(200, 200, SDL_LOGICAL_PRESENTATION_LETTERBOX);

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
begin
  Render.SetDrawColor(1, 0, 1, 1);
  Render.DebugText(0, 10, '[ESC]: Exit');
  Render.DebugText(0, 20, '[F1]: Toggle this help');
  Render.DebugText(0, 30, '[F11]: Toggle FPS');
  Render.DebugText(0, 40, '[F10] / [F12]: Dec/Inc FPS');
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
