unit uc3DStar;
{< Unit of c3DStar.

  This file is part of StarField.

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}

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
    CurrPos, PrevPos: TCHXVec3F;
    //< Current and previous star position.
    CurrProj, PrevProj: TCHXVec3F;
    {< Current and previous projection position and radius.
     `Z` component stores radius.}

    property Radius: CFloat read FRadius write SetRadius;
    property Color: TCHXVec3F read FColor write SetColor;

    constructor Create(const X: CFloat = 0; const Y: CFloat = 0;
      const Z: CFloat = 0);

    procedure Init(const X, Y, Z: CFloat);
    procedure Update(const Speed, ProjOffsetX, ProjOffsetY, FocLen: CFloat);
    {< Update star position with speed in 'Z' direction, and
      calculates its current projection position on screen.

      @param(Speed Displacement in Z coordinate.)
      @param(ProjOffsetX Horizontal position of (0,0))
      @param(ProjOffsetY Vertical position of (0,0))
      @param(FocLen Focal Length. Usually screen width for 90º of FOV.)
    }
    procedure Draw(const Render: cCHXSDL3Renderer;
      const DrawShape, DrawTrail: Boolean);

    destructor Destroy; override;
  end;

  c3DStarGenList = specialize TObjectList<c3DStar>;
  c3DStarList = class (c3DStarGenList)
    constructor Create(const aOwnsObjects: Boolean);

    procedure UpdateAll(const Speed, OffsetX, OffsetY, FocLen: CFloat);
    procedure DrawAll(const Render: cCHXSDL3Renderer;
      const DrawShape, DrawTrail: Boolean);
    procedure RotateAllXZ(const aAngle: CFloat);
    procedure RotateAllZY(const aAngle: CFloat);

    destructor Destroy; override;
  end;

implementation

{ c3DStar }
procedure c3DStar.SetColor(const aValue: TCHXVec3F);
begin
  FColor.R := EnsureRange(aValue.R, 0, 1);
  FColor.G := EnsureRange(aValue.G, 0, 1);
  FColor.B := EnsureRange(aValue.B, 0, 1);
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
  CurrProj.Init3D(0, 0, 0);
  PrevProj := CurrProj;
end;

procedure c3DStar.Update(const Speed, ProjOffsetX, ProjOffsetY, FocLen: CFloat);
var
  FOVCons: CFloat;
begin
  PrevPos := CurrPos;
  PrevProj := CurrProj;

  CurrPos.Z -= Speed;

  if not IsZero(CurrPos.Z) then
  begin
    FOVCons := FocLen / CurrPos.Z;
    CurrProj.X := CurrPos.X * FOVCons + ProjOffsetX;
    CurrProj.Y := CurrPos.Y * FOVCons + ProjOffsetY;
    CurrProj.Z := Radius * FOVCons;
  end
  else
  begin
    CurrProj.Z := 0;
  end;
end;

procedure c3DStar.Draw(const Render: cCHXSDL3Renderer;
  const DrawShape, DrawTrail: Boolean);
begin
  // Don't draw stars behind camera, altougth it can be visible...
  if CurrPos.Z < 0 then Exit;

  if DrawTrail and (PrevProj.Z <> 0) then
  begin
    if DrawShape then
    begin
      // ToDo: Draw a beautiful gradient transparent trail.
      //   with RenderGeometryRaw
      Render.SetDrawColor(Color.R, Color.G, Color.B, 0.5);
      Render.Line(PrevProj.X, PrevProj.Y, CurrProj.X, CurrProj.Y);
    end
    else
    begin
      Render.SetDrawColor(Color.R, Color.G, Color.B, 0.5);
      Render.Line(PrevProj.X, PrevProj.Y, CurrProj.X, CurrProj.Y);
    end;
  end;

  Render.SetDrawColor(Color.R, Color.G, Color.B);
  if DrawShape then
    // Drawing border to show removing hiden stars.
    Render.CircleBorder(CurrProj.X, CurrProj.Y, CurrProj.Z)
  else
    Render.Point(CurrProj.X, CurrProj.Y);
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

procedure c3DStarList.UpdateAll(const Speed, OffsetX, OffsetY, FocLen: CFloat);
var
  aStar: c3DStar;
begin
  for aStar in Self do
    aStar.Update(Speed, OffsetX, OffsetY, FocLen);
end;

procedure c3DStarList.DrawAll(const Render: cCHXSDL3Renderer;
        const DrawShape, DrawTrail: Boolean);
var
  i: Integer;
begin
  // Draw backwards
  for i := (Count - 1) downto 0 do
    Items[i].Draw(Render, DrawShape, DrawTrail);
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

