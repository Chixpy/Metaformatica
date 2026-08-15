{<
  See Readme.md

  (c) 2026 Chixpy https://github.com/Chixpy
}
{$mode ObjFPC}{$H+}
uses
  SysUtils, CTypes, SDL3, ucMainEng;

var
  SDLEng: cMainEng;
  ProgName: String;

begin
  ProgName := ExtractFileName(ParamStr(0));
  ChDir(ExtractFilePath(ParamStr(0)));
  SDLEng := cMainEng.Create(ChangeFileExt(ProgName, ''),
    ChangeFileExt(ProgName, '.ini'), True);
  try
    SDLEng.Run;
  finally
    SDLEng.Free;
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
