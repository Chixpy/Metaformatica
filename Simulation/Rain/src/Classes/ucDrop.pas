unit ucDrop;
{< Main engine.

  This file is part of Rain.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}
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
        Acceleration to 0.
  }
  public
    CurrProjX, CurrProjY: CFloat;
    //< Last projection position and radius.
    Len: CFloat;
    //< Length of the drop

    constructor Create(const X, Y, Z, aLen: CFloat);

    procedure Init(const X, Y, Z, aLen: CFloat);

    procedure Draw(const Render: cCHXSDL3Renderer;
      const OffsetX, OffsetY, FloorY, FocLen: CFloat);

    destructor Destroy; override;
  end;

  cDropGenList = specialize TObjectList<cDrop>;
  cDropList = class (cDropGenList)
    procedure UpdateAll(const Gravity, Wind: TCHXVec3S);
    procedure DrawAll(const Render: cCHXSDL3Renderer;
      const OffsetX, OffsetY, FloorY, FocLen: CFloat);
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
  CurrProjX := X;
  CurrProjY := Y;
  Len := aLen;
end;

procedure cDrop.Draw(const Render: cCHXSDL3Renderer;
  const OffsetX, OffsetY, FloorY, FocLen: CFloat);
var
  FOVCons, ProjLen: CFloat;
begin
  if IsZero(Position.Z) then Exit;

  FOVCons := FocLen / Position.Z;
  CurrProjX := Position.X * FOVCons + OffsetX;
  ProjLen := Min(Len, (Position.Y - FloorY)) * FOVCons;

  Render.SetDrawColor(0.2, 0.2, 1, 0.3);
  if Position.Y  <= FloorY then
  begin
    CurrProjY := -FloorY * FOVCons + OffsetY;
    try
      Render.EllipseFilled(CurrProjX, CurrProjY, ProjLen * 0.5, ProjLen * 0.20);
    except
      WriteLn(Format('Position: %g, %g, %g',
        [Position.X, Position.Y, Position.Z]));
      WriteLn(Format('Projection: %g, %g (%g)',
        [CurrProjX, CurrProjY, ProjLen * 0.5]));
    end;
  end
  else
  begin
    CurrProjY := -Position.Y * FOVCons + OffsetY;
    Render.Line(CurrProjX, CurrProjY - ProjLen, CurrProjX, CurrProjY);
  end;
end;

destructor cDrop.Destroy;
begin
  inherited Destroy;
end;

{ cDropList }

procedure cDropList.UpdateAll(const Gravity, Wind: TCHXVec3S);
var
  aDrop: cDrop;
  Force: TCHXVec3S;
begin
  Force := Gravity + Wind;
  for aDrop in Self  do
  begin
    aDrop.AddForce(Force);
    aDrop.Update;
  end;
end;

procedure cDropList.DrawAll(const Render: cCHXSDL3Renderer;
  const OffsetX, OffsetY, FloorY, FocLen: CFloat);
var
  aDrop: cDrop;
begin
  for aDrop in Self do
  begin
    aDrop.Draw(Render, OffsetX, OffsetY, FloorY, FocLen);
  end;
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
