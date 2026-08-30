unit ucSpark;
{< `cSpark` unit.

  This file is part of Fireworks.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Generics.Collections, Math, CTypes,
  SDL3,
  utCHXVec3S, ucCHXMoverS,
  uCHXSDL3TypeHelpers, ucCHXSDL3Renderer;
const
  kSparkFade = 0.1;
  
type

{ cSpark }

  cSpark = class (cCHXMoverS) // Single = CFloat
  {
    Inherited properties and methods:

    - Mass, Position, Velocity, Acceleration, Force
    - procedure AddForce(aForce : TCHXVec3Type); Adds force / mass
    - procedure ApplyForce; Calculate new position and velocity, resets Force
      and Acceleration to 0.
  }
  public
    Proj: TCHXVec3S;
    //< Last projection position on screen. `Z` can be the size... 

    Color: TSDL_FColor;

    constructor Create(const aPos, aVel: TCHXVec3S; const aColor: TSDL_FColor);

    procedure Update(const Gravity: TCHXVec3S;
      const ProjX0, ProjY0, CameraDst, FocLen: CFloat);
    procedure Draw(const Render: cCHXSDL3Renderer);

    destructor Destroy; override;
  end;

  cSparkGenList = specialize TObjectList<cSpark>;
  cSparkList = class (cSparkGenList)
  public
    function AddSpark(const aPos, aVel: TCHXVec3S; const aColor: TSDL_FColor)
      : cSpark;

    procedure UpdateAll(const Gravity: TCHXVec3S;
      const ProjX0, ProjY0, CameraDst, FocLen: CFloat);
    procedure DrawAll(const Render: cCHXSDL3Renderer);

    procedure RotateAllXZ(const aAngle: CFloat);
    procedure RotateAllZY(const aAngle: CFloat);
  end;

implementation

{ cSpark }

constructor cSpark.Create(const aPos, aVel: TCHXVec3S;
  const aColor: TSDL_FColor);
begin
  inherited Create;

  Position := aPos;
  Velocity := aVel;

  Proj.Init3D(0, 0, 0);
  Color := aColor;
end;

procedure cSpark.Update(const Gravity: TCHXVec3S;
  const ProjX0, ProjY0, CameraDst, FocLen: CFloat);
var
  FOVCons: CFloat;
begin
  if IsZero(Color.A) then Exit;

  Acceleration.Add(Gravity);
  ApplyForce;

Color.A := Max(Color.A - kSparkFade, 0);

  if (Position.Z + CameraDst) < 0.1 then
  begin
    Proj.Init3D(0, 0, -1);
    Exit;
  end;

  FOVCons := FocLen / (Position.Z + CameraDst);
  Proj.X := Position.X * FOVCons + ProjX0;
  Proj.Y := -Position.Y * FOVCons + ProjY0;
end;

procedure cSpark.Draw(const Render: cCHXSDL3Renderer);
begin
  if Proj.Z < 0 then Exit;
  Render.SetDrawColor(Color);
  Render.Point(Proj.X, Proj.Y);
end;

destructor cSpark.Destroy;
begin
  inherited Destroy;
end;


{ cSparkList }

function cSparkList.AddSpark(const aPos, aVel: TCHXVec3S;
  const aColor: TSDL_FColor): cSpark;
begin
  Result := cSpark.Create(aPos, aVel, aColor);
  Self.Add(Result);
end;

procedure cSparkList.UpdateAll(const Gravity: TCHXVec3S;
  const ProjX0, ProjY0, CameraDst, FocLen: CFloat);
var
  i: Integer;
  Spark: cSpark;
begin
  for i := (Self.Count - 1) downto 0 do
  begin
    Spark := Self[i];
    // Spark is dead
    if IsZero(Spark.Color.A) then
    begin
      Self.Delete(i);
      Continue;
    end;
    Spark.Update(Gravity, ProjX0, ProjY0, CameraDst, FocLen);
  end;
end;

procedure cSparkList.DrawAll(const Render: cCHXSDL3Renderer);
var
  aSpark: cSpark;
begin
  for aSpark in Self do
    aSpark.Draw(Render);
end;

procedure cSparkList.RotateAllXZ(const aAngle: CFloat);
var
  aSpark: cSpark;
  TempX, aSin, aCos: CFloat;
begin
  // for aSpark in Self do
  //   aSpark.RotateXZ(aAngle)

  SinCos(aAngle, aSin, aCos);
  for aSpark in Self do
  begin
    TempX := aSpark.Position.X;
    aSpark.Position.X := TempX * aCos - aSpark.Position.Z * aSin;
    aSpark.Position.Z := TempX * aSin + aSpark.Position.Z * aCos;
  end;
end;

procedure cSparkList.RotateAllZY(const aAngle: CFloat);
var
  aSpark: cSpark;
  TempZ, aSin, aCos: CFloat;
begin
  // for aSpark in Self do
  //   aSpark.RotateZY(aAngle)

  SinCos(aAngle, aSin, aCos);
  for aSpark in Self do
  begin
    TempZ := aSpark.Position.Z;
    aSpark.Position.Z := TempZ * aCos - aSpark.Position.Y * aSin;
    aSpark.Position.Y := TempZ * aSin + aSpark.Position.Y * aCos;
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
