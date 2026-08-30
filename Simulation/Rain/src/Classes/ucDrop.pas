unit ucDrop;
{< Main engine.

  This file is part of Rain.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Generics.Collections, Math, CTypes,
  ucCHXSDL3Renderer,
  utCHXVec3S, ucCHXMoverS;

type

{ cDrop }

  cDrop = class (cCHXMoverS) // Single = CFloat
  {
    Inherited properties and methods:

    - Mass, Position, Velocity, Acceleration, Force
    - procedure AddForce(aForce : TCHXVec3Type); Adds force / mass
    - procedure Update; Calculate new position and velocity, resets Force and
        Acceleration.
  }
  public

    Proj: TCHXVec3S;
    //< Last projection position on screen. `Z` is projected length
    Len: CFloat;
    //< Length of the drop

    Splash: Boolean;

    constructor Create(const X, Y, Z, aLen: CFloat);

    procedure Init(const X, Y, Z, aLen: CFloat);

    procedure Update(const OffsetX, OffsetY, FloorY, FocLen: CFloat);

    procedure Draw(const Render: cCHXSDL3Renderer);

    destructor Destroy; override;
  end;

  cDropGenList = specialize TObjectList<cDrop>;
  cDropList = class (cDropGenList)
    procedure UpdateAll(const Gravity, Wind: TCHXVec3S;
      const OffsetX, OffsetY, FloorY, FocLen: CFloat);
    procedure DrawAll(const Render: cCHXSDL3Renderer);
  end;

implementation

{ cDrop }

constructor cDrop.Create(const X, Y, Z, aLen: CFloat);
begin
  inherited Create;

  Init(X, Y, Z, aLen);
end;

procedure cDrop.Init(const X, Y, Z, aLen: CFloat);
begin
  Position.Init3D(X, Y, Z);
  Velocity.Init3D(0, 0, 0);
  Proj.Init3D(0, 0, 0);
  Len := aLen;
  Splash := False;
end;

procedure cDrop.Update(const OffsetX, OffsetY, FloorY, FocLen: CFloat);
var
  FOVCons: CFloat;
begin
  ApplyForce;

  // Div by zero and clipping plane
  if Position.Z < 0.1 then
  begin
    Proj.Init3D(0, 0, 0);
    Exit;
  end;

  FOVCons := FocLen / Position.Z;
  Proj.X := Position.X * FOVCons + OffsetX;
  Proj.Y := -Position.Y * FOVCons + OffsetY;

  if Position.Y > FloorY then
    Proj.Z := Min(Len, (Position.Y - FloorY)) * FOVCons
  else
  begin
    Proj.Z := Len * FOVCons;
    Splash := True;
  end
end;

procedure cDrop.Draw(const Render: cCHXSDL3Renderer);
begin
  if IsZero(Proj.Z) then Exit;

  Render.SetDrawColor(0, 0, 1, 0.3);
  if not Splash then
    Render.Line(Proj.X, Proj.Y - Proj.Z, Proj.X, Proj.Y)
  else
    Render.EllipseFilled(Proj.X, Proj.Y, Proj.Z * 0.5, Proj.Z * 0.2);
end;

destructor cDrop.Destroy;
begin
  inherited Destroy;
end;

{ cDropList }

procedure cDropList.UpdateAll(const Gravity, Wind: TCHXVec3S;
 const OffsetX, OffsetY, FloorY, FocLen: CFloat);
var
  aDrop: cDrop;
begin
  for aDrop in Self  do
  begin
    // Gravity is an acceleration
    aDrop.Acceleration += Gravity;
    // Wind is a force
    aDrop.AddForce(Wind);
    aDrop.Update(OffsetX, OffsetY, FloorY, FocLen);
  end;
end;

procedure cDropList.DrawAll(const Render: cCHXSDL3Renderer);
var
  aDrop: cDrop;
begin
  for aDrop in Self do
    aDrop.Draw(Render);
end;

end.
{
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
