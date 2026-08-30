unit ucMainEng;
{< Main engine of Fireworks.

  This file is part of Fireworks.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Math, CTypes,
  SDL3,
  utCHXVec3S,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers,
  ucFirework;

const
  kCameraDst = 100;
  kGravity = 1;
  kAngleStep = 0.03;

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
    Fireworks: cFireworkList;

    Gravity: TCHXVec3S;

    // Axis
    // Actually this must be done with a Matrix, linear transf. etc.
    ProjX0, ProjY0, FocLen: CFloat;
    XAxis, YAxis, ZAxis: TCHXVec3S;
  end;

implementation

{ cMainEng }

procedure cMainEng.Setup;
begin
  ShowFrameRate := True; ShowHelp := True;
  // If we require a fixed logical size.
  // Window.SetRenderSize(200, 200, SDL_LOGICAL_PRESENTATION_LETTERBOX);

  Fireworks := cFireworkList.Create(True);
  Gravity.Init3D(0, -kGravity, 0);

  // This must be changed to Compute if Logical Render Size changes
  ProjX0 := Window.Width * 0.5;
  ProjY0 := Window.Height * 0.75;
  FocLen := Window.Width; // 90º

  XAxis.Init3D(5, 0, 0);
  YAxis.Init3D(0, 5, 0);
  ZAxis.Init3D(0, 0, 5);
end;

procedure cMainEng.Finish;
begin
  Fireworks.Free;
end;

procedure cMainEng.Compute(var ExitProg : Boolean);
begin
  // Nearly all is handled by Fireworks list as is actually a manager more
  // than a simple list.
  Fireworks.UpdateAll(Gravity, ProjX0, ProjY0, kCameraDst, FocLen);
end;

procedure cMainEng.Draw;
var
  FOVCons: CFloat;
  X0, Y0, X1, Y1: CFloat;
begin
  Render.Clear(0.1);
  Render.SetDrawColor(1, 1, 1);

  Fireworks.DrawAll(Render);

  // Drawing coord axis
  Render.SetDrawColor(1,1,1);

  FOVCons := FocLen / kCameraDst;

  X1 := XAxis.X * FOVCons + ProjX0;
  Y1 := -XAxis.Y * FOVCons + ProjY0;
  Render.Line(ProjX0, ProjY0, X1, Y1);

  X1 := ZAxis.X * FOVCons + ProjX0;
  Y1 := -ZAxis.Y * FOVCons + ProjY0;
  Render.Line(ProjX0, ProjY0, X1, Y1);

  Render.SetDrawColor(0, 1, 0); // Y in green
  X1 := YAxis.X * FOVCons + ProjX0;
  Y1 := -YAxis.Y * FOVCons + ProjY0;
  Render.Line(ProjX0, ProjY0, X1, Y1);

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
  Render.DebugText(0, 50, '[SPACE]: Add Firework');
  Render.DebugText(0, 60, '[ARROWS]: Move camera');

  Window.SetRenderSize(CurrW, CurrH);
end;

procedure cMainEng.HandleEvent(const aEvent : TSDL_Event;
  var Handled : Boolean; var ExitProg : Boolean);
var
  aPoint: TCHXVec3S;
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

        SDLK_SPACE:
        begin
          aPoint.InitRandomXZ(-kCameraDst * 0.5, kCameraDst * 0.5,
            -kCameraDst * 0.5, kCameraDst * 0.5);
          Fireworks.AddFirework(
            aPoint, // Origin
            -Gravity * (10 + Random * Ln(kCameraDst)), // Initial velocity
            RandomRange(25, 76), // Number of sparks
            SDLFColorFastHUE(Random), // Rocket color
            SDLFColorFastHUE(Random)); // Spark color
        end;

        SDLK_UP:
        begin
          Gravity.RotateZY(-kAngleStep);
          Fireworks.RotateAllZY(-kAngleStep);

          XAxis.RotateZY(-kAngleStep);
          YAxis.RotateZY(-kAngleStep);
          ZAxis.RotateZY(-kAngleStep);
        end;

        SDLK_DOWN:
        begin
          Gravity.RotateZY(kAngleStep);
          Fireworks.RotateAllZY(kAngleStep);

          XAxis.RotateZY(kAngleStep);
          YAxis.RotateZY(kAngleStep);
          ZAxis.RotateZY(kAngleStep);
        end;

        SDLK_LEFT:
        begin
          Gravity.RotateXZ(kAngleStep);
          Fireworks.RotateAllXZ(kAngleStep);

          XAxis.RotateXZ(kAngleStep);
          YAxis.RotateXZ(kAngleStep);
          ZAxis.RotateXZ(kAngleStep);
        end;

        SDLK_RIGHT:
        begin
          Gravity.RotateXZ(-kAngleStep);
          Fireworks.RotateAllXZ(-kAngleStep);

          XAxis.RotateXZ(-kAngleStep);
          YAxis.RotateXZ(-kAngleStep);
          ZAxis.RotateXZ(-kAngleStep);
        end;

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
