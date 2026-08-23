unit uc3DStar;
{< Unit of c3DStar.

  This file is part of StarField.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}

interface
uses
  Generics.Collections, Math, CTypes, // RTL / SDL
  ucCHXSDL3Renderer,
  utCHXVec3F; // CFloat version of TCHXVec3

type

  { c3DStar }

  c3DStar = class
  protected
    FColor: TCHXVec3F; // if SDL3 unit is used: TSDL_FColor
    FRadius: CFloat;

    procedure SetColor(const aValue: TCHXVec3F);
    procedure SetRadius(const aValue: CFloat);

  public
    // CHX: No special getter or setter properties:
    CurrPos: TCHXVec3F;
    //< Current start position
    PrevPos: TCHXVec3F;
    //< Previous start position
    CurrProjX, CurrProjY, CurrProjR: CFloat;
    //< Last projection position and radius.

    property Radius: CFloat read FRadius write SetRadius;
    property Color: TCHXVec3F read FColor write SetColor;

    constructor Create(const X, Y, Z: CFloat);

    procedure Init(const X, Y, Z: CFloat);
    procedure Update(const Speed: CFloat);
    procedure Draw(const Render: cCHXSDL3Renderer;
      const DrawShape, DrawTrail: Boolean;
      const OffsetX, OffsetY, FocLen: CFloat);

    destructor Destroy; override;
  end;

  c3DStarGenList = specialize TObjectList<c3DStar>;
  c3DStarList = class (c3DStarGenList)
    constructor Create(const aOwnsObjects: Boolean);

    procedure UpdateAll(const Speed: CFloat);
    procedure DrawAll(const Render: cCHXSDL3Renderer; const DrawShape,
      DrawTrail: Boolean; const OffsetX, OffsetY, FocLen: CFloat);
    procedure RotateAllXZ(const aAngle: CFloat);
    procedure RotateAllZY(const aAngle: CFloat);

    destructor Destroy; override;
  end;

implementation

{ c3DStar }
procedure c3DStar.SetColor(const aValue: TCHXVec3F);
begin
  FColor.R := EnsureRange(aValue.R, 0, 1); // R
  FColor.G := EnsureRange(aValue.G, 0, 1); // G
  FColor.B := EnsureRange(aValue.B, 0, 1); // B
end;

procedure c3DStar.SetRadius(const aValue: CFloat);
begin
  FRadius := Abs(aValue);
end;
constructor c3DStar.Create(const X, Y, Z: CFloat);
begin
  inherited Create;
  Init(X, Y, Z);

  Radius := 1;
  Color.Init3D(1, 1, 1);
end;

procedure c3DStar.Init(const X, Y, Z: CFloat);
begin
  CurrPos.Init3D(X, Y, Z);
  PrevPos := CurrPos;
  CurrProjX := CurrPos.X;
  CurrProjY := CurrPos.Y;
  CurrProjR := 1;
end;

procedure c3DStar.Update(const Speed : CFloat);
begin
  PrevPos := CurrPos;
  CurrPos.Z -= Speed;
end;

procedure c3DStar.Draw(const Render: cCHXSDL3Renderer;
  const DrawShape, DrawTrail: Boolean; const OffsetX, OffsetY, FocLen: CFloat);
var
  PrevProjX, PrevProjY, PrevProjR: CFloat;
  FOVCons: CFloat;
begin
  if IsZero(CurrPos.Z) then Exit;

  FOVCons := FocLen / CurrPos.Z;
  CurrProjX := CurrPos.X * FOVCons + OffsetX;
  CurrProjY := CurrPos.Y * FOVCons + OffsetY;
  CurrProjR := Radius * FOVCons;

  if DrawTrail and (not IsZero(PrevPos.Z)) then
  begin
    FOVCons := FocLen / PrevPos.Z;
    PrevProjX := PrevPos.X * FOVCons + OffsetX;
    PrevProjY := PrevPos.Y * FOVCons + OffsetY;
    PrevProjR := Radius * FOVCons;

    if DrawShape then
    begin
      // ToDo: Draw a beautiful gradient transparent trail.
      Render.SetDrawColor(Color.R, Color.G, Color.B, 0.5);
      Render.Line(PrevProjX, PrevProjY, CurrProjX, CurrProjY);
    end
    else
    begin
      Render.SetDrawColor(Color.R, Color.G, Color.B, 0.5);
      Render.Line(PrevProjX, PrevProjY, CurrProjX, CurrProjY);
    end;
  end;

  Render.SetDrawColor(Color.R, Color.G, Color.B);
  if DrawShape then
  begin
    Render.CircleFilled(CurrProjX, CurrProjY, CurrProjR);
  end
  else
    Render.Point(CurrProjX, CurrProjY);
end;

destructor c3DStar.Destroy;
begin
  inherited Destroy;
end;

{ c3DStarList }
constructor c3DStarList.Create(const aOwnsObjects: Boolean);
begin
  inherited Create(aOwnsObjects);
end;

procedure c3DStarList.UpdateAll(const Speed: CFloat);
var
  aStar: c3DStar;
begin
  for aStar in Self do
    aStar.Update(Speed);
end;

procedure c3DStarList.DrawAll(const Render: cCHXSDL3Renderer; const DrawShape,
  DrawTrail: Boolean; const OffsetX, OffsetY, FocLen: CFloat);
var
  aStar: c3DStar;
begin
  for aStar in Self do
    aStar.Draw(Render, DrawShape, DrawTrail, OffsetX, OffsetY, FocLen);
end;

procedure c3DStarList.RotateAllXZ(const aAngle: CFloat);
var
  aStar: c3DStar;
  TempX, aSin, aCos: CFloat;
begin
  // for aStar in Self do
  //   aStar.RotateXZ(aAngle)

  SinCos(aAngle, aSin, aCos);
  for aStar in Self do
  begin
    TempX := aStar.CurrPos.X;
    aStar.CurrPos.X := TempX * aCos - aStar.CurrPos.Z * aSin;
    aStar.CurrPos.Z := TempX * aSin + aStar.CurrPos.Z * aCos;
  end;
end;

procedure c3DStarList.RotateAllZY(const aAngle: CFloat);
var
  aStar: c3DStar;
  TempZ, aSin, aCos: CFloat;
begin
  // for aStar in Self do
  //   aStar.RotateZY(aAngle)

  SinCos(aAngle, aSin, aCos);
  for aStar in Self do
  begin
    TempZ := aStar.CurrPos.Z;
    aStar.CurrPos.Z := TempZ * aCos - aStar.CurrPos.Y * aSin;
    aStar.CurrPos.Y := TempZ * aSin + aStar.CurrPos.Y * aCos;
  end;
end;

destructor c3DStarList.Destroy;
begin
  inherited Destroy;
end;

end.

