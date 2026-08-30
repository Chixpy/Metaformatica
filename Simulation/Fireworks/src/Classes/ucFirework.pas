unit ucFirework;
{< `cFirework` unit.

  This file is part of Fireworks.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Generics.Collections, Math, CTypes,
  SDL3,
  utCHXVec3S, ucCHXMoverS,
  uCHXSDL3TypeHelpers, ucCHXSDL3Renderer,
  ucSpark;

type

  TFireWorkState = (fwFlying, fwExploding, fwExploded, fwDead);

{ cFirework }

  cFirework = class (cCHXMoverS) // Single = CFloat
  {
    Inherited properties and methods:

    - Mass, Position, Velocity, Acceleration, Force
    - procedure AddForce(aForce : TCHXVec3Type); Adds force / mass
    - procedure ApplyForce; Calculate new position and velocity, resets Force
      and Acceleration to 0.
  }
  public
    Proj: TCHXVec3S;
    //< Last projection position on screen.

    RckColor, SpkColor: TSDL_FColor;

    State: TFireWorkState;

    NSparks: Integer;
    Sparks: cSparkList;

    constructor Create(const aPos, aVel: TCHXVec3S; const aNSparks: Integer;
      const aRckColor, aSpkColor: TSDL_FColor);

    procedure Update(const Gravity: TCHXVec3S;
        const ProjX0, ProjY0, CameraDst, FocLen: CFloat);
    procedure Draw(const Render: cCHXSDL3Renderer);

    destructor Destroy; override;
  end;

  cFireworkGenList = specialize TObjectList<cFirework>;
  cFireworkList = class (cFireworkGenList)
  public
    function AddFirework(const aPos, aVel: TCHXVec3S; const aNSparks: Integer;
      const aRckColor, aSpkColor: TSDL_FColor): cFirework;

    procedure UpdateAll(const Gravity: TCHXVec3S;
      const ProjX0, ProjY0, CamDst, FocLen: CFloat);
    procedure DrawAll(const Render: cCHXSDL3Renderer);

    procedure RotateAllXZ(const aAngle: CFloat);
    procedure RotateAllZY(const aAngle: CFloat);
  end;

implementation

{ cFirework }

constructor cFirework.Create(const aPos, aVel: TCHXVec3S;
  const aNSparks: Integer; const aRckColor, aSpkColor: TSDL_FColor);
begin
  inherited Create;

  Position := aPos;
  Velocity := aVel;

  // SDL_log('Created | Pos: %s - Vel: %s',
  //   [PAnsiChar(Position.ToString), PAnsiChar(Velocity.ToString)]);

  RckColor := aRckColor;
  SpkColor := aSpkColor;

  State := fwFlying;

  NSparks := aNSparks;
  Proj.Z := aNSparks;
  Sparks := cSparkList.Create(True);
end;

procedure cFirework.Update(const Gravity: TCHXVec3S;
  const ProjX0, ProjY0, CameraDst, FocLen: CFloat);
var
  i: Integer;
  FOVCons: CFloat;
  aVel: TCHXVec3S;
begin
  case State of

  fwFlying:
  begin
    Acceleration.Add(Gravity);
    ApplyForce;

    if (Position.Z + CameraDst) < 0.1 then
    begin
      Proj.Init3D(0, 0, -1);
      Exit;
    end;

    FOVCons := FocLen / (Position.Z + CameraDst);
    Proj.X := Position.X * FOVCons + ProjX0;
    Proj.Y := -Position.Y * FOVCons + ProjY0;

    // Checking if begining to fall to explode.
    if Velocity.ScalProd(Gravity) > 0 then
    begin
      // Creating Sparks
      for i := 1 to NSparks do
      begin
        aVel.InitRndPolar3D(Gravity.GetMagnitude3D * 5);
        aVel.Add(-Gravity);
        Sparks.AddSpark(Position, aVel, SpkColor);
      end;
      State := fwExploding;
    end;
  end;

  fwExploding:
  begin
    // Actually is one frame for drawing the explosion
    Sparks.UpdateAll(Gravity, ProjX0, ProjY0, CameraDst, FocLen);
    State := fwExploded;

    // SDL_log('Explodes | Pos: %s - Vel: %s',
    //   [PAnsiChar(Position.ToString), PAnsiChar(Velocity.ToString)]);
    // SDL_log('         | Proj: %g, %g', [Proj.X, Proj.Y]);
  end;

  fwExploded:
  begin
    // Wait until all Sparks are dead
    Sparks.UpdateAll(Gravity, ProjX0, ProjY0, CameraDst, FocLen);
    if Sparks.Count <= 0 then
      State := fwDead;
  end;

  otherwise // fwDead
    ;
  end; // case State of
end;

procedure cFirework.Draw(const Render: cCHXSDL3Renderer);
label BreakCase;
begin
  case State of
  fwFlying:
  begin
    if Proj.Z < 0 then goto BreakCase;
    RckColor.A := 0.5;
    Render.SetDrawColor(RckColor);
    Render.CircleFilled(Proj.X, Proj.Y, 1 + Ln(NSparks) * 0.5);
  end;

  fwExploding:
  begin
    if Proj.Z < 0 then goto BreakCase;
    RckColor.A := 1;
    Render.SetDrawColor(RckColor);
    Render.CircleFilled(Proj.X, Proj.Y, 1 + Ln(NSparks) * 2);
  end;

  fwExploded:
    Sparks.DrawAll(Render);

  otherwise
    ;
  end;
  BreakCase:
  ;
end;

destructor cFirework.Destroy;
begin
  Sparks.Free;
  inherited Destroy;
end;


{ cFireworkList }
function cFireworkList.AddFirework(const aPos, aVel: TCHXVec3S;
  const aNSparks: Integer; const aRckColor, aSpkColor: TSDL_FColor): cFirework;
begin
  Result := cFirework.Create(aPos, aVel, aNSparks, aRckColor, aSpkColor);
  Self.Add(Result);
end;

procedure cFireworkList.UpdateAll(const Gravity: TCHXVec3S;
  const ProjX0, ProjY0, CamDst, FocLen: CFloat);
var
  i: Integer;
  aFirework: cFirework;
begin
  for i := (Self.Count - 1) downto 0 do
  begin
    aFirework := Items[i];
    if aFirework.State = fwDead then
    begin
      Self.Delete(i);
      Continue;
    end;
    aFirework.Update(Gravity, ProjX0, ProjY0, CamDst, FocLen);
  end;
end;

procedure cFireworkList.DrawAll(const Render: cCHXSDL3Renderer);
var
  aFirework: cFirework;
begin
  for aFirework in Self do
    aFirework.Draw(Render);
end;

procedure cFireworkList.RotateAllXZ(const aAngle: CFloat);
var
  aFirework: cFirework;
  TempX, aSin, aCos: CFloat;
begin
  // for aFirework in Self do
  //   aFirework.RotateXZ(aAngle)

  SinCos(aAngle, aSin, aCos);
  for aFirework in Self do
  begin
    TempX := aFirework.Position.X;
    aFirework.Position.X := TempX * aCos - aFirework.Position.Z * aSin;
    aFirework.Position.Z := TempX * aSin + aFirework.Position.Z * aCos;
    aFirework.Sparks.RotateAllXZ(aAngle);
  end;
end;

procedure cFireworkList.RotateAllZY(const aAngle: CFloat);
var
  aFirework: cFirework;
  TempZ, aSin, aCos: CFloat;
begin
  // for aFirework in Self do
  //   aFirework.RotateZY(aAngle)

  SinCos(aAngle, aSin, aCos);
  for aFirework in Self do
  begin
    TempZ := aFirework.Position.Z;
    aFirework.Position.Z := TempZ * aCos - aFirework.Position.Y * aSin;
    aFirework.Position.Y := TempZ * aSin + aFirework.Position.Y * aCos;
    aFirework.Sparks.RotateAllZY(aAngle);
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
