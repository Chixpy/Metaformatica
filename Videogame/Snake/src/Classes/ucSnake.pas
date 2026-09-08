unit ucSnake;
{< Main engine.

  This file is part of Snake

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface

uses
  CTypes,
  SDL3,
  ucCHXSDL3Renderer, uCHXSDL3TypeHelpers;

type

  { cSnake }

  cSnake = class
  public type
    TSnkDir = (sdNone, sdLeft, sdUp, sdRight, sdDown);

  public
    Head: TSDL_Point; // or TPoint; or X,Y; etc.
    Tail: TSDLPointDynArray; // Array of previous type, actually a queue.
    TailSize: Integer; // To know is snake is growing
    Direction: TSnkDir; // Next direction to move.
    Speed: Integer; // Milliseconds between moves.
    Delay: Integer; // Milliseconds to wait until next move.
    Lives: Integer;
    IsDead: Boolean;

    Score: Integer;

    TailColor, HeadColor: TSDL_FColor;

    constructor Create;
    destructor Destroy; override;

    procedure Update(const TimePassed: Integer);
    procedure Draw(const Render: cCHXSDL3Renderer;
      const Scale, OffSetX, OffSetY: CFloat);

    procedure ChangeDir(const aDir: TSnkDir);
    procedure Eat(const Points: Integer);
    procedure LoseLive;
  end;

implementation

{ sSnake }

constructor cSnake.Create;
begin
  inherited Create;

  Head.Init(0,0);
  Direction := sdNone;
  TailSize := 3;
  Speed := 250;
  Delay := Speed;
  Score := 0;

  HeadColor.Init(0, 1, 0);
  TailColor.Init(1, 1, 0);

  Lives := 2;
  IsDead := False;
end;

destructor cSnake.Destroy;
begin

  inherited Destroy;
end;

procedure cSnake.Update(const TimePassed: Integer);
var
  TailPos: TSDL_Point;
begin
  if IsDead or (Direction = sdNone) then Exit;

  if TimePassed < Delay then
  begin
    Delay -= TimePassed;
    Exit;
  end;

  Delay := Speed;

  // Updating tail first.
  if Length(Tail) >= TailSize then
    Tail := Copy(Tail, 1, High(Tail));

  SetLength(Tail, Length(Tail) + 1);
  Tail[High(Tail)] := Head;

  // Moving
  case Direction of
  //sdNone: Exit; // Tested before
  sdLeft: Head.X -= 1;
  sdUp: Head.Y -= 1;
  sdRight: Head.X += 1;
  sdDown: Head.Y += 1;
  otherwise
    ;
  end;

  // Test self colliding
  for TailPos in Tail do
    if TailPos = Head then
    begin
      LoseLive;
      Break;
    end;
end;

procedure cSnake.Draw(const Render: cCHXSDL3Renderer;
  const Scale, OffSetX, OffSetY: CFloat);
var
  TailProj: TSDLFRectDynArray;
  HeadProj: TSDL_FRect;
  i: Integer;
begin
  SetLength(TailProj, Length(Tail));

  HeadProj.Init(Head.X * Scale + OffSetX, Head.Y * Scale + OffSetY,
    Scale, Scale);
  for i := 0 to High(Tail) do
    TailProj[i].Init(Tail[i].X * Scale + OffSetX, Tail[i].Y * Scale + OffSetY,
      Scale, Scale);

  Render.SetDrawColor(TailColor);
  Render.RectsFilled(TailProj);

  Render.SetDrawColor(HeadColor);
  Render.RectFilled(HeadProj);
end;

procedure cSnake.ChangeDir(const aDir: TSnkDir);
begin
  // Prevent a 180º turn
  case aDir of
  sdNone: Direction := aDir;
  sdLeft: if Direction <> sdRight then Direction := sdLeft;
  sdUp: if Direction <> sdDown then Direction := sdUp;
  sdRight: if Direction <> sdLeft then Direction := sdRight;
  sdDown: if Direction <> sdUp then Direction := sdDown;
  otherwise
    ;
  end;
end;

procedure cSnake.Eat(const Points: Integer);
begin
  Score += Points;
  TailSize += 1;
  if Speed > 10 then
    Speed -=1;
end;

procedure cSnake.LoseLive;
begin
  IsDead := True;
  Lives -= 1;
  Direction := sdNone;
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
