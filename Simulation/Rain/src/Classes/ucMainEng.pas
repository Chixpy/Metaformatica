unit ucMainEng;
{< Main engine.

  This file is part of Rain.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Math, CTypes,
  SDL3,
  utCHXVec3S,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers,
  ucDrop;

const
  kNDrops = 1000; // Number of drops
  kFloorY = -1;   // Height of the "floor"
  kGravityStep = 0.1; // Gravity accelaration
  kWindForce = 0.075; // Wind intensity
  kWindRotationStep = 0.03; // Wind rotation angle

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
    Drops: cDropList;
    Gravity: TCHXVec3S; //< Gravity force.
    Wind: TCHXVec3S; //< 3D Wind.

    FocLen: CFloat; //< Focal Length
    XAxisPos, YAxisPos: CFloat; //< Position of (0,0)

    procedure InitDrop(const aDrop: cDrop);
  end;

implementation

{ cMainEng }

procedure cMainEng.InitDrop(const aDrop: cDrop);
var
  FOVConsInv, aZ: CFloat;
begin
  // Creating the drop over the screen
  aZ := Random * Window.Width * 0.5 + 0.2;
  FOVConsInv := aZ / FocLen;

  aDrop.Init((Random - 0.5) * Window.Width,
    Random * YAxisPos + YAxisPos * FOVConsInv,
    aZ, Random * 2 + 1);
end;

procedure cMainEng.Setup;
var
  i: Integer;
  Drop: cDrop;
begin
  ShowFrameRate := True; ShowHelp := True;
  // Window.SetRenderSize(200, 200, SDL_LOGICAL_PRESENTATION_LETTERBOX);

  // Focal Length
  FocLen := Window.Width;
  XAxisPos := Window.Width div 2; YAxisPos := Window.Height div 2;

  Drops := cDropList.Create(True);
  for i := 1 to kNDrops do
  begin
    Drop := cDrop.Create(0, 0, 0, 1);
    InitDrop(Drop);
    Drops.Add(Drop);
  end;

  Gravity.Init3D(0, -kGravityStep, 0);
  Wind.Init3D(kWindForce, 0, 0);
end;

procedure cMainEng.Finish;
begin
  Drops.Free; // Frees all drops.
end;

procedure cMainEng.Compute(var ExitProg : Boolean);
var
  Drop: cDrop;
begin
  for Drop in Drops do
    // Resetting drop out of screen or splashed
    while (Drop.Splash)
      or (Drop.Proj.X < (-Window.Width * 0.5))
      or (Drop.Proj.X > (Window.Width * 1.5)) do
      InitDrop(Drop);

  Drops.UpdateAll(Gravity, Wind, XAxisPos, YAxisPos, kFloorY, FocLen);
end;

procedure cMainEng.Draw;
var
  WindX, WindY, WindRad: CFloat;
  WindNorm: TCHXVec3S;
begin
  Render.Clear(0.05);

  // Fake floor
  Render.SetDrawColor(0, 0.5, 0);
  Render.RectFilled(SDLFRect(0, Window.Height div 2,
    Window.Width, Window.Height));

  // Drops
  Drops.DrawAll(Render);

  // Drawing wind position
  WindX := Window.Width div 40;
  WindY := Window.Height div 40;
  WindRad := Min(WindX, WindY);
  WindX := Window.Width - WindRad;
  WindY := Window.Height - WindRad;
  WindNorm := Wind.GetNormalized;

  Render.SetDrawColor(0.5);
  Render.CircleBorder(WindX, WindY, WindRad);
  Render.SetDrawColor(1);
  Render.Line(WindX, WindY,
    WindX + WindNorm.X * WindRad, WindY - WindNorm.Z * WindRad);

  if ShowHelp then DrawHelp;
end;

procedure cMainEng.DrawHelp;
var
  CurrW, CurrH: Integer;
begin
  CurrW := Window.Width; CurrH := Window.Height;
  Window.SetRenderSize(400, 400);
  Render.SetDrawColor(1, 0, 1, 1);
  Render.SetDrawColor(1, 0, 1, 1);
  Render.DebugText(0, 0, '[ESC]: Exit');
  Render.DebugText(0, 10, '[F1]: Toggle this help');
  Render.DebugText(0, 20, '[F11]: Toggle FPS');
  Render.DebugText(0, 30, '[F10]/[F12]: Dec/Inc FPS');
  Render.DebugText(0, 40, '[UP]/[DOWN]: Dec/Inc Gravity');
  Render.DebugText(0, 50, '[LEFT]/[RIGHT]: Rotate Wind');
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

    SDLK_UP:
      if Gravity.Y >= 0 then
        Gravity.Y := 0
      else
        Gravity.Y += kGravityStep;

    SDLK_DOWN: Gravity.Y -= kGravityStep;

    SDLK_LEFT: Wind.RotateXZ(kWindRotationStep);

    SDLK_RIGHT: Wind.RotateXZ(-kWindRotationStep);

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
