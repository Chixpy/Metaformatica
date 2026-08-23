unit uMiscUtils;
interface
uses
  Math, SDL;

procedure GetCameraFocalLengths(const Renderer: PSDL_Renderer;
  const FovRads: Single; out FocLenX, FocLenY: Single);
{< Get the focal lengths for 3D projection to a FOV angle. Usually 
  `FocLenX = FocLenY`

  ```
  X' = X * FocLenX / Z;
  Y' = X * FocLenY / Z;
  ```
}

implementation

procedure GetCameraFocalLengths(const Renderer: PSDL_Renderer; FovRads: Single;
  out FocLenX, FocLenY: Single);
var
  LogicalW, LogicalH: Integer;
  Mode: TSDL_RendererLogicalPresentation;
  ScaleX, ScaleY: Single;
begin
  SDL_GetRenderLogicalPresentation(Renderer, @LogicalW, @LogicalH, @Mode);
  if LogicalW = 0 then
    SDL_GetRenderOutputSize(Renderer, @LogicalW, @LogicalH);

  FocLenY := (LogicalH * 0.5) / Tan(FovRads * 0.5);
  FocLenX := FocLenY; // Square pixels by default

  // In Stretch, can be non square pixels
  if Mode = SDL_LOGICAL_PRESENTATION_STRETCH then
  begin
    SDL_GetRenderScale(Renderer, @ScaleX, @ScaleY);
    if (ScaleX > 0) and (ScaleY > 0) then
      FocLenX := FocLenY * (ScaleY / ScaleX); 
  end;
end;
