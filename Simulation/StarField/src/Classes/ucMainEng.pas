unit ucMainEng;
{< 3D StarField.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Math, CTypes,
  SDL3,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers,
  uc3DStar;

const
  kNStars = 100;

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
    StarList, VisibleStars: c3DStarList;
    NStars: Integer;
    Speed: CFloat;

    DrawShapes, DrawTrails: Boolean;

    procedure InitStar(const aStar: c3DStar; const ResetZ: Boolean);
  end;

implementation

{ cMainEng }

procedure cMainEng.InitStar(const aStar: c3DStar; const ResetZ: Boolean);
var
  SpaceDeep: CFloat;
begin
  if not Assigned(aStar) then Exit;

  SpaceDeep := Window.Width * 2;

  aStar.CurrPos.InitRandomXY(-SpaceDeep, SpaceDeep, -SpaceDeep, SpaceDeep);
  if not ResetZ then
    aStar.CurrPos.Z := (Random * SpaceDeep) + (SpaceDeep * 0.5)
  else
    aStar.CurrPos.Z := SpaceDeep * 1.5;

  aStar.PrevPos := aStar.CurrPos;

  aStar.Radius := Random * Window.Width / 20 + 1;
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
  StarList.Capacity := kNStars;
  NStars := kNStars;
  for i := 1 to NStars do
  begin
    aStar := c3DStar.Create;
    InitStar(aStar, False);
    StarList.Add(aStar);
  end;

  VisibleStars := c3DStarList.Create(False);

  Speed := 0; DrawShapes := False; DrawTrails := False;
end;

procedure cMainEng.Finish;
begin
  VisibleStars.Free;
  StarList.Free; // Free all stars too
end;

procedure cMainEng.Compute(var ExitProg : Boolean);
var
  Star1, Star2: c3DStar;
  StarPos, aPos: Integer;
  Distances: Array of CFloat;
  StarDst: CFloat;
begin
  StarList.UpdateAll(Speed, Window.Width div 2, Window.Height div 2,
    Window.Width);

  // All of this can be in a Starfield manager.

  VisibleStars.Clear;
  VisibleStars.Capacity := StarList.Count;
  for Star1 in StarList do
  begin

    // Maybe we don't want reset stars until they past much more the camera.
    // Doing big rotations will show that they disappear.
    if Star1.PrevPos.Z <= 0 then InitStar(Star1, True);

    if DrawShapes then
    begin
      // Sorting stars by distance and removing hidden ones.
      StarPos := 0;
      SetLength(Distances, 0); // Clears the array (?)
      SetLength(Distances, StarList.Count);
      StarDst := Star1.CurrPos.GetSqrMag3D;
      while (StarPos >= 0) and (StarPos < VisibleStars.Count) do
      begin
        // Testing if Star1 is hidded by current
        if (Distances[StarPos] <  StarDst) then
        begin
          Star2 := VisibleStars[StarPos];
          // `Z` stores the projection radius
          if Star1.CurrProj.InDistanceXY(Star2.CurrProj,
            Star1.CurrProj.Z - Star2.CurrProj.Z, True) then
          begin
            // Star2 hides Star1
            StarPos := -1;
          end
          else // Continue
            Inc(StarPos);
        end

        else // Test if next stars in the list are hidden by this one.

        begin
          aPos := StarPos;
          while (aPos < VisibleStars.Count) do
          begin
            Star2 := VisibleStars[aPos];
            if Star1.CurrProj.InDistanceXY(Star2.CurrProj,
              Star1.CurrProj.Z - Star2.CurrProj.Z, True) then
            begin
              // Star1 hides Star 2
              Delete(Distances, aPos, 1);
              VisibleStars.Delete(aPos);
            end
            else
              Inc(aPos);
          end;
        end;
      end;

      if StarPos >= 0 then
      begin
        Insert(StarDst, Distances, StarPos);
        VisibleStars.Insert(StarPos, Star1);
      end;
      // else susbtract 1 in VisibleStars.Capacity and Distances length.
      // but its not needed.
    end
    else // if not drawing shapes
    begin
      VisibleStars.Add(Star1);
    end;
  end;
end;

procedure cMainEng.Draw;
begin
  Render.Clear(0, 0, 0);

  VisibleStars.DrawAll(Render, DrawShapes, DrawTrails);

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
  Render.DebugText(0, 40, '[F10] / [F12]: Decrease / Increase FPS');
  Render.DebugText(0, 50, '[Q] / [A]: Change speed');
  Render.DebugText(0, 60, '[ARROWS]: Change direction');
  Render.DebugText(0, 70, '[T]: Toggle trails');
  Render.DebugText(0, 80, '[S]: Toggle shapes');
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
        // SDLK_ESC, SDLK_F10, SDLK_F11, SDLK_F12: Managed by cCHXSDL3Engine.

        SDLK_F1: ShowHelp := not ShowHelp;

        SDLK_T: DrawTrails := not DrawTrails;

        SDLK_S: DrawShapes := not DrawShapes;

        SDLK_UP: StarList.RotateAllZY(-0.03);

        SDLK_DOWN: StarList.RotateAllZY(0.03);

        SDLK_LEFT: StarList.RotateAllXZ(-0.03);

        SDLK_RIGHT: StarList.RotateAllXZ(0.03);

        SDLK_Q: Speed := Speed + 1;

        SDLK_A:
          if Speed >= 1 then
            Speed := Speed - 1
          else
            Speed := 0;

      otherwise // of aEvent.key.key
        Handled := False;
      end;
    end;
  otherwise // of aEvent.type_
    ;
  end;
end;

end.
