unit ucMainEng;
{< Main engine.

  This file is part of Snake

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}{$inline ON}{$WARN 6058 OFF}
interface
uses
  SysUtils, Math, CTypes,
  SDL3,
  ucCHXSDL3Engine, uCHXSDL3TypeHelpers,
  ucSnake;

const
  kGridW = 25; // Grid Width
  kGridH = 25; // Grid Height
  kInitSnakeSpeed = 250; // Milliseconds between Snake steps.

type

  // Simpliest state machine
  TProgState = (psTitle, psPlaying, psGameOver);

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
    ProgState: TProgState;

    Snake: cSnake;
    Food: TSDL_Point;
    HiScore: Integer;

    GridOffSetX, GridOffSetY: CFloat;
    CellSize: CFloat;

    WaitTime: Integer; // Time to wait between Lives

    procedure InitGame;
    procedure InitSnake;
    procedure EndGame;
  end;

implementation

{ cMainEng }

procedure cMainEng.InitGame;
begin
  Snake.Free;
  Snake := cSnake.Create;
  InitSnake;

  Food.InitRandom(1, kGridW - 1, 1, kGridH - 1);

  ProgState := psPlaying;
end;

procedure cMainEng.InitSnake;
begin
  // ToDo: This may be in Snake.NextLive(PosX, PoY, Speed)
  Snake.Head.Init(kGridW div 2, kGridH div 2);
  Snake.Speed := kInitSnakeSpeed;
  Snake.IsDead := False;
  SetLength(Snake.Tail, 0);
end;

procedure cMainEng.EndGame;
begin
  if Snake.Score > HiScore then
    HiScore := Snake.Score;
  FreeAndNil(Snake);

  ProgState := psTitle;
end;

procedure cMainEng.Setup;
begin
  ShowFrameRate := True; ShowHelp := True;


  CellSize := Min(Window.Width / kGridW, (Window.Height - 20) / kGridH);
  GridOffSetX := (Window.Width - (CellSize * kGridW)) * 0.5;
  GridOffSetY := (Window.Height - (CellSize * kGridH)) * 0.5 + 10;
  HiScore := 0;

  ProgState := psTitle;
end;

procedure cMainEng.Finish;
begin
  Snake.Free;
end;

procedure cMainEng.Compute(var ExitProg : Boolean);
begin
  case ProgState of
  psTitle:
  begin
  end;

  psPlaying:
  begin
    if Snake.IsDead and (WaitTime > 0) then
    begin
      if WaitTime > FPSMng.LastFullTime then
        WaitTime -= FPSMng.LastFullTime
      else if Snake.Lives < 0 then
        ProgState := psGameOver
      else
        InitSnake;
      Exit;
    end;

    Snake.Update(FPSMng.LastFullTime);

    if (Snake.Head.X <= 0) or (Snake.Head.X >= (kGridW - 1))
      or (Snake.Head.Y <= 0) or (Snake.Head.Y >= (kGridW - 1)) then
      Snake.LoseLive;

    if Snake.IsDead then
    begin
      WaitTime := 1000;
      Exit;
    end;

    if Snake.Head = Food then
    begin
      Snake.Eat(kInitSnakeSpeed - Snake.Speed + 1);
      Food.InitRandom(1, kGridW - 1, 1, kGridH - 1);
      // ToDo: Don't create over Snake's tail
    end;
  end;

  psGameOver:
  begin
  end;
  end; // case ProgState
end;

procedure cMainEng.Draw;
begin
  Render.Clear(0.1);
  Render.SetDrawColor(1);

  case ProgState of
  psTitle:
  begin
    // ToDo: Change to proper text when implemented
    Render.SetDrawColor(Random, Random, Random);
    Render.DebugText((Window.Width - 80) * 0.5, 0.25 * Window.Height,
      'Snake Game');
    Render.SetDrawColor(1);
    Render.DebugText((Window.Width - 240) * 0.5, 0.75 * Window.Height,
      'Push [Any Letter] key to Start');
  end;

  psPlaying:
  begin
    Render.SetDrawColor(1);
    // ToDo: Calculate a correct position with Render target clip or similar.
    Window.PushRenderSize(400, 400);
    Render.DebugTextF(0, 0, 'HiScore: %6.6d', [HiScore]);
    Render.DebugTextF(0, 10, ' Score : %6.6d - Lives: %d',
      [Snake.Score, Snake.Lives]);
    Window.PopRenderSize;

    Render.SetDrawColor(1, 0, 0);
    Render.FrameFilled(GridOffSetX, GridOffSetY,
      CellSize * kGridW, CellSize * kGridH, CellSize);

    Snake.Draw(Render, CellSize, GridOffSetX, GridOffSetY);

    Render.SetDrawColor(0, 1, 1);
    Render.RectFilled(GridOffSetX + Food.X * CellSize,
      GridOffSetY + Food.Y * CellSize, CellSize, CellSize);

    if Snake.IsDead then
    begin
      Render.SetDrawColor(0, 0, 0, 0.5);
      Render.RectFilled(0, 0, Window.Width, Window.Height);
    end;
  end;

  psGameOver:
  begin
    Snake.Draw(Render, CellSize, GridOffSetX, GridOffSetY);
    Render.SetDrawColor(0, 0, 0, 0.5);
    Render.RectFilled(0, 0, Window.Width, Window.Height);

    // ToDo: Change to proper text when implemented
    Render.SetDrawColor(Random, Random, Random);
    Render.DebugText((Window.Width - 72) * 0.5 , 20, 'Game Over');
    Render.SetDrawColor(1);
    Render.DebugTextF((Window.Width - 132) * 0.5, 40,
      'Score: %10d', [Snake.Score]);
    Render.SetDrawColor(Random, Random, Random);
    if Snake.Score > HiScore then
      Render.DebugText((Window.Width - 120) * 0.5 , 50, '¡A NEW HISCORE!');
    Render.SetDrawColor(1);
    Render.DebugText((Window.Width - 172) * 0.5 , 70,
      'Push [Any Letter] key');
  end;
  end; // case ProgState

  if ShowHelp then DrawHelp;
end;

procedure cMainEng.DrawHelp;
begin
  Window.PushRenderSize(0,0);
  Render.SetDrawColor(1, 0, 1);
  Render.DebugText(0, 10, '[ESC]: Exit');
  Render.DebugText(0, 20, '[F1]: Toggle this help');
  Render.DebugText(0, 30, '[ARROWS]: Change Snake Direction');
  Window.PopRenderSize;
end;

procedure cMainEng.HandleEvent(const aEvent : TSDL_Event;
  var Handled : Boolean; var ExitProg : Boolean);
begin
  inherited;
  if ExitProg or Handled then Exit;
  // SDLK_ESC, SDLK_F10, SDLK_F11, SDLK_F12: Managed by cCHXSDLRenderer.

  if (aEvent.type_ = SDL_EVENT_KEY_DOWN)
    and (aEvent.key.key = SDLK_F1) then
  begin
    ShowHelp := not ShowHelp;
    Handled := True;
    Exit;
  end;

  case ProgState of
  psTitle:
  begin
    if (aEvent.type_ = SDL_EVENT_KEY_DOWN) then
    begin
      if (aEvent.key.key < SDLK_A) or (aEvent.key.key > SDLK_Z) then
        Exit;
      InitGame;
      Handled := True;
    end;
  end;

  psPlaying:
  begin
    case aEvent.type_ of
      SDL_EVENT_KEY_DOWN:
      begin
        Handled := True;
        case aEvent.key.key of

        SDLK_UP, SDLK_W: Snake.ChangeDir(sdUp);

        SDLK_Down, SDLK_S: Snake.ChangeDir(sdDown);

        SDLK_Left, SDLK_A: Snake.ChangeDir(sdLeft);

        SDLK_Right, SDLK_D: Snake.ChangeDir(sdRight);

        otherwise // case aEvent.key.key
          Handled := False;
        end; // case aEvent.key.key
      end;
    otherwise // case aEvent.type_
      ;
    end; // case aEvent.type_
  end;

  psGameOver:
  begin
    if (aEvent.type_ = SDL_EVENT_KEY_DOWN) then
    begin
      EndGame;
      Handled := True;
    end;
  end;
  end; // case ProgState
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
