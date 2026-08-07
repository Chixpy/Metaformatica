unit ucMainEng;
{<
  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}
interface
uses
  CTypes,
  SDL3,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers;

type

  { cMainEng }

  cMainEng = class(cCHXSDL3Engine)
  protected
    procedure Setup; override; { It's abstract. }
    procedure Finish; override; { It's abstract. }
    procedure Compute(var ExitProg : Boolean); override; { It's abstract. }
    procedure Draw; override; { It's abstract. }
    procedure HandleEvent(const aEvent : TSDL_Event; var Handled : Boolean;
      var ExitProg : Boolean); override; { It's virtual. }

  protected
    ShowHelp: Boolean;
    procedure DrawHelp;


  end;

implementation

{ cMainEng }

procedure cMainEng.Setup;
begin
  ShowFrameRate := True;
  SDL_SetRenderLogicalPresentation(SDLRenderer, 200, 200,
    SDL_LOGICAL_PRESENTATION_LETTERBOX);

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

  if ShowHelp then DrawHelp;
end;

procedure cMainEng.HandleEvent(const aEvent : TSDL_Event;
var Handled : Boolean; var ExitProg : Boolean);
begin
  inherited;
  if ExitProg or Handled then Exit;

  case aEvent.type_ of
    SDL_EVENT_KEY_DOWN:
    begin
      case aEvent.key.key of
        // SDLK_ESC, SDLK_F10, SDLK_F11, SDLK_F12: Managed by cCHXSDLRenderer
        SDLK_F1:
        begin
          ShowHelp := not ShowHelp;
          Handled := True;
        end;

      otherwise
        ;
      end;
    end;
  otherwise
    ;
  end;
end;

procedure cMainEng.DrawHelp;
begin
  Render.SetDrawColor(1, 0, 1, 1);
  SDL_RenderDebugText(SDLRenderer, 4, 10, '[ESC]: Exit');
  SDL_RenderDebugText(SDLRenderer, 4, 20, '[F1]: Toggle this help');
  SDL_RenderDebugText(SDLRenderer, 4, 30, '[F11]: Toggle FPS');
  SDL_RenderDebugText(SDLRenderer, 4, 40,
    '[F10] / [F12]: Decrease / Increase FPS');
end;
end.
