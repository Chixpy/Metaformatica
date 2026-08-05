unit ucMainEng;
{<
  (c) 2026 Chixpy
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

  public // or protected

  end;

implementation
{ cMainEng }
procedure cMainEng.Setup;
begin
  ShowFrameRate := True;

end;

procedure cMainEng.Finish;
begin

end;

procedure cMainEng.Compute(var ExitProg : Boolean);
begin

end;

procedure cMainEng.Draw;
begin

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
