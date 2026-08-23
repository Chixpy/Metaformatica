unit ucMainEng;
{< 3D StarField.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}
interface
uses
  SysUtils, Math, CTypes,
  SDL3,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers,
  uc3DStar;

const
  kNStars = 1000;

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
    StarList: c3DStarList;
    NStars: Integer;
    Speed: CFloat;

    DrawShapes, DrawTrails: Boolean;

    procedure InitStar(const aStar: c3DStar; const ResetZ: Boolean);
  end;

implementation

{ cMainEng }

procedure cMainEng.InitStar(const aStar: c3DStar; const ResetZ: Boolean);
var
  SpaceSize: CFloat;
begin
  if not Assigned(aStar) then Exit;

  SpaceSize := Window.Width * 2;

  aStar.CurrPos.InitRandomXY(-SpaceSize, SpaceSize, -SpaceSize, SpaceSize);
  aStar.CurrPos.Z := SpaceSize;
  if not ResetZ then
    aStar.CurrPos.Z := Random * aStar.CurrPos.Z;

  aStar.PrevPos := aStar.CurrPos;

  aStar.Radius := Random * Window.Width / 20;
  aStar.Color.Init3D(Random, Random, Random);

  // Test one star:
  // aStar.Init(0, 0, 1);
  // aStar.Radius := 1;
  // aStar.Color.Init3D(1, 1, 1);
end;

procedure cMainEng.Setup;
var
  i: Integer;
  aStar: c3DStar;
begin
  ShowFrameRate := True; ShowHelp := True;
  //Window.SetRenderSize(200, 200, SDL_LOGICAL_PRESENTATION_LETTERBOX);

  StarList := c3DStarList.Create(True);
  NStars := kNStars;
  for i := 1 to NStars do
  begin
    aStar := c3DStar.Create(0, 0, 0);
    InitStar(aStar, False);
    StarList.Add(aStar);
  end;

  Speed := 0;
  DrawShapes := False; DrawTrails := False;
end;

procedure cMainEng.Finish;
begin
  StarList.Free; // Free all stars too
end;

procedure cMainEng.Compute(var ExitProg : Boolean);
var
  aStar: c3DStar;
begin
  StarList.UpdateAll(Speed);

  for aStar in StarList do
    if aStar.CurrPos.Z <= 0 then InitStar(aStar, True);
end;

procedure cMainEng.Draw;
begin
  Render.Clear(0, 0, 0);

  StarList.DrawAll(Render, DrawShapes, DrawTrails,
    Window.Width div 2, Window.Height div 2, Window.Width);

  // Render.DebugTextF(2, 90, '(%f, %f, %f)',
  //   [StarList[0].CurrPos.X, StarList[0].CurrPos.Y, StarList[0].CurrPos.Z]);

  if ShowHelp then DrawHelp;
end;

procedure cMainEng.DrawHelp;
begin
  Render.SetDrawColor(1, 0, 1, 1);
  Render.DebugText(0, 10, '[ESC]: Exit');
  Render.DebugText(0, 20, '[F1]: Toggle this help');
  Render.DebugText(0, 30, '[F11]: Toggle FPS');
  Render.DebugText(0, 40, '[F10] / [F12]: Decrease / Increase FPS');
  Render.DebugText(0, 50, '[Q] / [A]: Change speed');
  Render.DebugText(0, 60, '[ARROWS]: Change direction');
  Render.DebugText(0, 70, '[T]: Toggle trails');
  Render.DebugText(0, 80, '[S]: Toggle shapes');
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
        // SDLK_ESC, SDLK_F10, SDLK_F11, SDLK_F12: Managed by cCHXSDL3Engine.
        SDLK_F1: ShowHelp := not ShowHelp;

        SDLK_T: DrawTrails := not DrawTrails;

        SDLK_S: DrawShapes := not DrawShapes;

        SDLK_UP: StarList.RotateAllZY(-0.03);

        SDLK_DOWN: StarList.RotateAllZY(0.03);

        SDLK_LEFT: StarList.RotateAllXZ(-0.03);

        SDLK_RIGHT: StarList.RotateAllXZ(0.03);

        SDLK_Q: Speed := Speed + 5;

        SDLK_A:
          if Speed >= 5 then Speed := Speed - 5;

      otherwise // of aEvent.key.key
        Handled := False;
      end;
    end;
  otherwise // of aEvent.type_
    ;
  end;
end;

end.
