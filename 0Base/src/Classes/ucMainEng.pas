unit ucMainEng;
{<
  (c) 2026 Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}
interface
uses
  CTypes,
  SDL3,
  ucCHXSDL3Engine, ucCHXSDL3TypeHelpers;

type

  { cSDL3Eng }

  cSDL3Eng = class(cCHXSDL3Engine)
  protected
    procedure Setup; override; { It's abstract. }
    procedure Finish; override; { It's abstract. }
    procedure Compute(var ExitProg : Boolean); override; { It's abstract. }
    procedure Draw; override; { It's abstract. }
    procedure HandleEvent(const aEvent : TSDL_Event; var Handled : Boolean;
      var ExitProg : Boolean); override; { It's virtual. }

  public // or protected

  end;

implementation
{ cSDL3Eng }
procedure cSDL3Eng.Setup;
begin
  ShowFrameRate := True;

end;

procedure cSDL3Eng.Finish;
begin

end;

procedure cSDL3Eng.Compute(var ExitProg : Boolean);
begin

end;

procedure cSDL3Eng.Draw;
begin

end;

procedure cSDL3Eng.HandleEvent(const aEvent : TSDL_Event;
var Handled : Boolean; var ExitProg : Boolean);
begin
  inherited;
  if ExitProg or Handled then Exit;

  case aEvent.type_ of
    SDL_EVENT_KEY_DOWN:
    begin
      case aEvent.key.key of
        SDLK_A..SDLK_Z:
        begin
          ExitProg := True;
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

end.
