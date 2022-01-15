unit Unit1;

interface

uses Winapi.Windows, ShellApi,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    Memo2: TMemo;
    Button1: TButton;
    Timer1: TTimer;
    procedure Image1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);


    procedure Decompress (FileName:string);
    procedure FilesMove (FileName:string);
    procedure FilesDelete (FileName:string);
    procedure FilesRename (FileName:string);

    procedure StartPatch;
    procedure UPKPatch(FileName:string; ReplaceType: string);

    procedure StringReplace(FileToPatch, OutDir: string; SearchString, ReplaceString : AnsiString);

    procedure GetFileList;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  StopPatch:Boolean;
  Rollback:Boolean;
  Nolog:Boolean;
  Stage: integer;
  FileListStrings : TStringList;
const
  BUFSIZE = 8192;


//���������� ��������� � ��������� ��������

HexSearchArray: array [0..13]  of array of byte =
([$6B, $56, $7F, $B0, $1B, $30, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$01, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00],
[$95, $6C, $26, $FF, $B0, $1B, $30, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$45, $02, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00],
[$95, $6C, $87, $7F, $B0, $1D, $D8, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$02, $C8, $CC, $CC, $40, $00, $0C, $1B, $88, $CC, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00],
[$95, $6C, $87, $7F, $B0, $1E, $F0, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$03, $C8, $CC, $CC, $40, $00, $0C, $1A, $C9, $20, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6C, $87, $7F, $B0, $1E, $48, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$03, $C8, $CC, $CC, $40, $00, $0C, $1B, $B8, $DF, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6C, $87, $7F, $B0, $1D, $10, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$04, $C8, $CC, $CC, $40, $00, $0C, $1A, $C9, $20, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6C, $87, $7F, $B0, $1E, $00, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$04, $C8, $CC, $CC, $40, $00, $0C, $1A, $C8, $CC, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21]);


HexReplaceArray: array [0..13]  of array of byte =
([$6E, $CE, $00, $C8, $1F, $90, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$01, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00],
[$95, $6E, $CE, $00, $C8, $1F, $90, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$45, $02, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00],
[$95, $6F, $FF, $00, $C8, $22, $60, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$02, $C5, $38, $80, $C3, $50, $30, $6E, $23, $30, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00],
[$95, $6F, $FF, $00, $C8, $22, $60, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$03, $C5, $38, $80, $C3, $50, $30, $6B, $24, $80, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6F, $FF, $00, $C8, $22, $60, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$03, $C5, $38, $80, $C3, $50, $30, $6E, $E3, $7C, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6F, $FF, $00, $C8, $22, $60, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$04, $C5, $38, $80, $C3, $50, $30, $6B, $24, $80, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6F, $FF, $00, $C8, $22, $60, $ED, $33, $D2, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E, $3C, $2F, $70, $3E, $00],
[$04, $C5, $38, $80, $C3, $50, $30, $6B, $23, $30, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21]);

//��������� ����� �� ������ ����������

HexLobbySearchArray: array [0..5]  of array of byte =
([$95, $68, $E7, $7F, $B0, $1D, $88, $ED, $33, $D1, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$C5, $E6, $66, $F3, $33, $30, $FE, $29, $7C, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6B, $56, $7F, $B0, $1B, $30, $ED, $33, $D1, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$02, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6C, $26, $FF, $B0, $1B, $30, $ED, $33, $D1, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$02, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21]);

HexLobbyReplaceArray: array [0..5]  of array of byte =
([$95, $6C, $62, $00, $C8, $21, $20, $ED, $33, $D1, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$C5, $86, $A0, $C3, $50, $30, $FE, $29, $7C, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21],
[$95, $6F, $05, $00, $C8, $20, $08, $ED, $33, $D1, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$02, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6F, $A0, $00, $C8, $20, $08, $ED, $33, $D1, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$02, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21]);


//��������� ������

WGUHexSearchArray: array [0..5]  of array of byte =
([$95, $6C, $26, $FF, $B0, $1B, $30, $ED, $33, $24, $01, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$03, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6B, $56, $7F, $B0, $1B, $30, $ED, $33, $24, $01, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$03, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6C, $87, $7F, $B0, $1D, $88, $ED, $33, $24, $01, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$03, $C8, $CC, $CC, $40, $00, $0C, $1A, $C9, $20, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21]);

WGUHexReplaceArray: array [0..5]  of array of byte =
([$95, $6F, $A0, $00, $C8, $1F, $90, $ED, $33, $24, $01, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$03, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6E, $CE, $00, $C8, $1F, $90, $ED, $33, $24, $01, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$03, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6F, $FF, $00, $C8, $21, $E8, $ED, $33, $24, $01, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$03, $C5, $38, $80, $C3, $50, $30, $6B, $24, $80, $6E, $61, $6D, $65, $00, $01, $02, $00, $00, $00, $FF, $00, $00, $08, $00, $00, $00, $05, $00, $00, $02, $21]);

//�������� ������ � ��������, �� ����� � �������� �� �������

WStartupHexSearchArray: array [0..3]  of array of byte =
([$95, $6B, $56, $7F, $B0, $1B, $30, $ED, $33, $26, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$00, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6C, $26, $FF, $B0, $1B, $30, $ED, $33, $73, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$01, $C8, $CC, $CC, $40, $00, $0C, $32, $1A, $7B, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21]);


WStartupHexReplaceArray: array [0..3]  of array of byte =
([$95, $6E, $CE, $00, $C8, $1F, $90, $ED, $33, $26, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$00, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21],
[$95, $6F, $A0, $00, $C8, $1F, $90, $ED, $33, $73, $00, $40, $01, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $70, $20, $61, $6C, $69, $67, $6E, $3D, $22, $6C, $65, $66, $74, $22, $3E],
[$01, $C5, $38, $80, $C3, $50, $30, $C8, $69, $EC, $6E, $61, $6D, $65, $00, $01, $00, $00, $00, $00, $E5, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $C9, $00, $00, $00, $00, $00, $00, $00, $09, $21]);



implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}

function IndexStr2(const AText: string; const AValues: array of string): Integer;
var
 I: Integer;
begin
    Result := -1;
    for I := Low(AValues) to High(AValues) do
    if AText = AValues[I]
    then begin
        Result := I;
        Break;
    end;
end;

procedure AddLog(s: string; AddTStamp: boolean);  overload;
var ErrLogFile : TextFile;
begin
    if not NoLog
    then begin
        AssignFile(ErrLogFile, ExtractFileDir(Paramstr(0)) + PathDelim +'umapPatchLog.txt');
        if not FileExists(ExtractFileDir(Paramstr(0)) + PathDelim +'umapPatchLog.txt')
        then begin
            Rewrite(ErrLogFile);
            if AddTStamp
            then Writeln(ErrLogFile, Formatdatetime('YYYY-MM-DD HH:MM:SS', Now) +'     '+ s )
            else Writeln(ErrLogFile, s );
            CloseFile(ErrLogFile)
        end
        else begin
            Append(ErrLogFile);
            if AddTStamp
            then Writeln(ErrLogFile, Formatdatetime('YYYY-MM-DD HH:MM:SS', Now) +'     '+ s )
            else Writeln(ErrLogFile, s );
            CloseFile(ErrLogFile);
        end;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
    StopPatch:=False;
    Rollback:=False;
    Nolog:=False;
    for i := 1 to ParamCount-1 do
    begin
        if Paramstr(i)='-rollback'
        then Rollback:=True;
        if Paramstr(i)='-nolog'
        then NoLog:=True;
    end;

    Label1.Text:='��������� ������� ������ ����� �������� � ������ ~2-3 ������. ���������.';
    Stage:=0;
    Timer1.Enabled:=True;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled:=False;
    if Stage=0
    then begin
        GetFileList;
        AddLog     ('******************************************************', false);
        if (Rollback)
        then AddLog('***����� ��������� �������� ���� � ��������� ������***', false)
        else Addlog('***����� ��������� �������� ���� � ��������� ������***', false);
        AddLog     ('******************************************************', false);
        StartPatch;
        Timer1.Enabled:=True;
    end
    else begin
        Application.Terminate;
    end;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
		SelButton : Integer;
begin
    SelButton := MessageDlg('������ ������ ���������� �������� ����� ����?',TMsgDlgType.mtWarning , mbYesNo, 0);
    if SelButton = mrYes
    then begin
        StopPatch:=True;
    end;
    if SelButton = mrNo
    then ShowMessage('��-�� ��. ����� � ��������.');
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
    ShellExecute(0, 'open', 'https://borderlands.fandom.com/ru/', nil, nil, SW_SHOW)
end;

procedure TForm1.GetFileList;
	var  RS: TResourceStream;
  begin
      try
          RS := TResourceStream.Create(HInstance, 'Res1', RT_RCDATA);
      finally

      end;

      try
          FileListStrings:= TStringList.Create;
          FileListStrings.LoadFromStream(RS);
          FreeAndNil(RS);
          //FreeAndNil(TransStrings);
      except on e:exception do

      end;
  end;

procedure TForm1.StartPatch;
var
  i: Integer; WGUName, WGUName2: string;
  CurrentFile: string;
  CurrentType: string;
begin
    Stage:=1;
    try
        ProgressBar1.Value := 0 ;
        Label2.Text:='0%';
        try
            if not (DirectoryExists('temp'))
            then MkDir('Temp')
        except
            AddLog('�� ������� ������� ��������� �����', true);
        end;

        for i := 0 to FileListStrings.count-1 do begin
            CurrentFile:=FileListStrings[i];
            CurrentType:= 'inventory';
            if not StopPatch then begin

                if FileExists(ExtractFileDir(Paramstr(0))+FileListStrings[i])
                then begin
                    Label1.Text:='��������� ����� '+CurrentFile;
                    AddLog('������ ��������� '+ExtractFileName(Paramstr(0)+CurrentFile), true);
                    Application.ProcessMessages;
                    decompress(CurrentFile);
                    FilesMove(FileListStrings[i]);
                    UPKPatch(FileListStrings[i],CurrentType);
                    ProgressBar1.Value := ((i+1) * 100) div (FileListStrings.Count+3) ;
                    Label2.Text:=inttostr(Round( ((i+1) * 100) div (FileListStrings.count+3) ))+'%   ';
                end
                else begin
                    Label1.Text:='�� ������ ���� '+FileListStrings[i];
                    AddLog('�� ������ ���� '+ExtractFileName(Paramstr(0)+(FileListStrings[i])), true);
                end;
            end;

        end;
        Application.ProcessMessages;

        FileListStrings.Clear;
        FileListStrings.Add('\WillowGame\CookedPC\DLC2\Maps\dlc2_lobby_p.umap');
        FileListStrings.Add('\WillowGame\CookedPC\Startup_RUS.upk');
//        if (Rollback)
//        then FileListStrings.Add('\WillowGame\CookedPC\WillowGame.upk')
//        else FileListStrings.Add('\WillowGame\CookedPC\WillowGame.u');

        //FileListStrings.Add('\WillowGame\CookedPC\DLC2\Maps\dlc2_lobby_p.umap');

        for i:=0 to FileListStrings.Count-1 do

        if not StopPatch then begin
            case IndexStr2(FileListStrings[i], ['\WillowGame\CookedPC\DLC2\Maps\dlc2_lobby_p.umap', '\WillowGame\CookedPC\Startup_RUS.upk' ]) of
                0: CurrentType:= 'dlc2lobby';
                1: CurrentType:= 'wstartup';
               //2: CurrentType:= 'wgu';
                else begin
                    AddLog('������', true);
                    break;
                end;
            end;
            if FileExists(ExtractFileDir(Paramstr(0))+FileListStrings[i])
            then begin
                Label1.Text:='��������� ����� '+FileListStrings[i];
                AddLog('������ ��������� '+ExtractFileName(Paramstr(0)+FileListStrings[i]), true);
                Application.ProcessMessages;
                decompress(FileListStrings[i]);
                FilesMove(FileListStrings[i]);
                UPKPatch(FileListStrings[i], CurrentType);
                ProgressBar1.Value :=  (98 + i);
                Label2.Text:=inttostr(Round(ProgressBar1.Value))+'%   ';
            end
            else begin
                Label1.Text:='�� ������ ���� '+FileListStrings[i];
                AddLog('�� ������ ���� '+ExtractFileName(Paramstr(0)+FileListStrings[i]), true);
            end;
            Application.ProcessMessages;
        end;

        //willowGame.u
        if (Rollback)
        then WGUName:='\WillowGame\CookedPC\WillowGame.upk'
        else begin
        		WGUName:='\WillowGame\CookedPC\WillowGame.u';
            if not FileExists(ExtractFileDir(Paramstr(0))+WGUName)
            then WGUName:='\WillowGame\CookedPC\WillowGame.upk';
        end;
        WGUName2:='\WillowGame\CookedPC\WillowGame.upk';
        if not StopPatch then begin
            if FileExists(ExtractFileDir(Paramstr(0))+WGUName)
            then begin
                Label1.Text:='��������� ����� '+WGUName;
                AddLog('������ ��������� '+ExtractFileName(Paramstr(0)+WGUName), true);
                Application.ProcessMessages;
                decompress(WGUName);
                FilesMove(WGUName);

                if not (Rollback)
                then begin
                		if (FileExists(ExtractFileDir(Paramstr(0))+WGUName)) and (FileExists(ExtractFileDir(Paramstr(0))+WGUName2)) and not (WGUName=WGuName2)
                    then FilesDelete(WGUName2);

                    if WGUName<>WGUName2
                    then FilesRename(WGUName);
                end;

                UPKPatch(WGUName2, 'wgu');
                ProgressBar1.Value := 99;
                Label2.Text:='99%   ';
            end
            else begin
                Label1.Text:='�� ������ ���� '+WGUName;
                AddLog('�� ������ ���� '+ExtractFileName(Paramstr(0)+WGUName), true);
            end;
        end;

        ProgressBar1.Value := 100;
        Label2.Text:='100%   ';
        Application.ProcessMessages;

        if StopPatch
        then begin
            AddLog('***************************************************', false);
            AddLog('***********��������� ������ �����������.***********', false);
            AddLog('***************************************************', false);
        end;
    except on e:exception do
    		AddLog('�������������� ������ '+e.Message, true);
    end;

    Button1.Visible:=False;
    Application.ProcessMessages;

    if RemoveDir('Temp')
    then begin
        Label1.Text:='������. ��������.';
        AddLog('��������� ��������� ������', true);
    end
    else begin
        Label1.Text:=('�� ������� ������� ��������� �����. ��������, �������� ����.'+IntToStr(GetLastError));
        AddLog('�� ������� ������� ��������� ����� ', true);
    end;

    Application.ProcessMessages;
end;


{$REGION '�������� ��������'}

procedure TForm1.Decompress (FileName:string);
var
Rlst: LongBool; //��������� ����������
StartUpInfo: TStartUpInfo; //��������� �������� ��������
ProcessInfo: TProcessInformation; //������������ ����������
app, CurrDir:string; //������� �����
Error:integer; //����� �������
SendFail,ExitCode: Cardinal; //��� ����������

parameter:String;
SecAtrrs: TSecurityAttributes;
begin
    CurrDir:=ExtractFileDir(Paramstr(0));
    with SecAtrrs do begin
        nLength := SizeOf(SecAtrrs);
        bInheritHandle := True;
        lpSecurityDescriptor := nil;
    end;

    FillChar(StartUpInfo, SizeOf(TStartUpInfo), 0);    //���������� ������ ����� StartUpInfo.
    with StartUpInfo do
    begin
        cb := SizeOf(TStartUpInfo);
        dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK; //���������� ����, ������ - ������.
        wShowWindow := SW_HIDE; //���������� ��� ������ ��������� ���� ����������� ����������.
    end;

    app := CurrDir+'\decompress.exe';

    if not FileExists (app) then
    begin
        Label1.Text:='�� ������ '+ExtractFileName(app);
        AddLog('�� ������ ���� '+ExtractFileName(app), true);
        exit;
    end;

    Application.ProcessMessages;
    parameter:=' -lzo "'+CurrDir+FileName+'" -out="'+CurrDir+'\Temp"';
    if FileExists(CurrDir+FileName)
    then begin
        Rlst:= CreateProcess(PChar(app), PChar(parameter),nil, nil, false,0,nil, nil, StartUpInfo, ProcessInfo);

        //����������� ����������.
        if Rlst
        then begin   //���� ������ �������
            with ProcessInfo do
            begin
                WaitForInputIdle(hProcess, INFINITE);     //���� ���������� �������������.
                 WaitforSingleObject(ProcessInfo.hProcess, INFINITE);    //���� ���������� ��������.
                 GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);    //�������� ��� ����������.
                 CloseHandle(hThread);    //��������� ���������� ��������.
                 CloseHandle(hProcess);    //��������� ���������� ������.
            end;
        end

        else begin
            Error := GetLastError;  //�������� ��� � ������ ������
        end;
        SendFail:=ExitCode;
        Application.ProcessMessages;
        if (SendFail<>0)
        then begin
           Label1.Text:='������ ��� ����������: '+FileName+' /'+inttostr(SendFail)+' /'+inttostr(Error);
           AddLog('������ ��� ���������� '+ExtractFileName(Paramstr(0)+(FileName)), true);
        end
        else begin
           Label1.Text:='����������: '+FileName;
           AddLog('���������� '+ExtractFileName(Paramstr(0)+(FileName)), true);
        end;
    end
    else begin
        Label1.Text:='���� �� ������: '+FileName;
        AddLog('�� ������ ���� '+ExtractFileName(Paramstr(0)+(FileName)), true);
    end;
    Application.ProcessMessages;
end;

procedure TForm1.FilesMove (FileName:string);
  var CurrDir:String;
  begin
      try
          CurrDir:=ExtractFileDir(Paramstr(0));
          MoveFileEx(pchar(CurrDir+'\Temp\'+ExtractFileName(Paramstr(0)+(FileName))),
                    pchar(ExtractFileDir( CurrDir+FileName)+'\'+ExtractFileName(Paramstr(0)+FileName)), MOVEFILE_REPLACE_EXISTING);
          Label1.Text:='���������: '+FileName;
          AddLog('��������� �� ��������� ����� '+ExtractFileName(Paramstr(0)+(FileName)), true);
          Application.ProcessMessages;
      except on e:exception do
          AddLog('�� ������� ����������� �� ��������� ����� '+ExtractFileName(Paramstr(0)+(FileName)), true);
      end;
  end;

  procedure TForm1.FilesDelete (FileName:string);
  var CurrDir:String;
  begin
      try
          CurrDir:=ExtractFileDir(Paramstr(0));

          if DeleteFile(CurrDir+'\'+fileName)
          then begin
              Label1.Text:='������ '+fileName;
              AddLog('������ '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end
          else begin
              Label1.Text:='��������� ������ ��� �������� '+ fileName;
              AddLog('��������� ������ '+IntToStr(GetLastError)+' ��� �������� '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end;
      except on e:exception do
          AddLog('�� ������� ������� ���� '+ExtractFileName(Paramstr(0)+(FileName)), true);
      end;
      Application.ProcessMessages;
  end;

  procedure TForm1.FilesRename (FileName:string);
  var CurrDir, oldName, newName:String;
  begin
      try
          CurrDir:=ExtractFileDir(Paramstr(0));
          oldName := CurrDir+'\'+fileName;
          newName := ChangeFileExt(oldName, '.upk');
          if RenameFile(oldName, newName)

          then begin
              Label1.Text:='������������ '+fileName;
              AddLog('������������ '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end
          else begin
              Label1.Text:='��������� ������ ��� �������������� '+ fileName;
              AddLog('��������� ������ '+IntToStr(GetLastError)+' ��� �������������� '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end;
      except on e:exception do
          AddLog('�� ������� ������������� ���� '+ExtractFileName(Paramstr(0)+(FileName)), true);
      end;
      Application.ProcessMessages;
  end;
{$ENDREGION}

procedure TForm1.UPKPatch(FileName:string; ReplaceType: string);
var k:integer;
SearchString, ReplaceString: AnsiString;
SearchArray, ReplaceArray: Tstrings;

begin
    if not assigned(SearchArray) then
    SearchArray:=TstringList.Create;
    if not assigned(ReplaceArray) then
    ReplaceArray:=TstringList.Create;

    SearchArray.Text:='';
    ReplaceArray.Text:='';

    case IndexStr2(ReplaceType, ['inventory', 'dlc2lobby', 'wstartup', 'wgu' ]) of
        1: begin
            for k:= Low(HexLobbyReplaceArray) to High(HexLobbyReplaceArray) do
            begin
                SetString(SearchString, PAnsiChar(@HexLobbySearchArray[k][0]), Length(HexLobbySearchArray[k]));
                SearchArray.Add(SearchString);
                SetString(ReplaceString, PAnsiChar(@HexLobbyReplaceArray[k][0]), Length(HexLobbyReplaceArray[k]));
                ReplaceArray.Add(ReplaceString);
            end;
        end;
        2: begin
            //setlength(ReplaceArray,Length(HexReplaceArray));
            for k:= Low(WStartupHexReplaceArray) to High(WStartupHexReplaceArray) do
            begin
                SetString(SearchString, PAnsiChar(@WStartupHexSearchArray[k][0]), Length(WStartupHexSearchArray[k]));
                SearchArray.Add(SearchString);
                SetString(ReplaceString, PAnsiChar(@WStartupHexReplaceArray[k][0]), Length(WStartupHexReplaceArray[k]));
                ReplaceArray.Add(ReplaceString);
            end;
        end;
        3: begin
            //setlength(ReplaceArray,Length(HexReplaceArray));
            for k:= Low(WGUHexReplaceArray) to High(WGUHexReplaceArray) do
            begin
                SetString(SearchString, PAnsiChar(@WGUHexSearchArray[k][0]), Length(WGUHexSearchArray[k]));
                SearchArray.Add(SearchString);
                SetString(ReplaceString, PAnsiChar(@WGUHexReplaceArray[k][0]), Length(WGUHexReplaceArray[k]));
                ReplaceArray.Add(ReplaceString);
            end;
        end;
        else begin
            for k:= Low(HexReplaceArray) to High(HexReplaceArray) do
            begin
                SetString(SearchString, PAnsiChar(@HexSearchArray[k][0]), Length(HexSearchArray[k]));
                SearchArray.Add(SearchString);
                SetString(ReplaceString, PAnsiChar(@HexReplaceArray[k][0]), Length(HexReplaceArray[k]));
                ReplaceArray.Add(ReplaceString);
            end;
        end;
    end;

    if not (Rollback)
    then begin
        for k:= 0 to SearchArray.Count-1 do begin
            Label1.Text:='��������� '+ExtractFilename(ExtractFileDir(Paramstr(0))+FileName);
            Application.ProcessMessages;
            StringReplace ( ExtractFileDir(Paramstr(0))+FileName, ExtractFileDir(Paramstr(0)+FileName), SearchArray[k], ReplaceArray[k] );
        end;

    end
    else begin
        for k:= 0 to ReplaceArray.Count-1 do begin
            Label1.Text:='������� ��������� '+ExtractFilename(ExtractFileDir(Paramstr(0))+FileName);
            Application.ProcessMessages;
            StringReplace ( ExtractFileDir(Paramstr(0))+FileName, ExtractFileDir(Paramstr(0)+FileName), ReplaceArray[k], SearchArray[k] );
        end;
    end;
end;


procedure TForm1.StringReplace(FileToPatch, OutDir: string; SearchString, ReplaceString : AnsiString);
var
  Fs : TFileStream;
  FileName : String;
  SBuff : AnsiString; //AnsiString - ���, ����������� ������ ����������� ��������.
  Offs : Int64;
begin
    FileName := FileToPatch; //���� � �����.
    //������ ��������� ��������� ������ � ��������� ���� � ������ ������ � ������
    //(fmOpenReadWrite), � �������� �� ������ �� ������ ��������� (fmShareDenyWrite).
    Fs := TFileStream.Create(FileName, fmOpenReadWrite + fmShareDenyWrite);
    try
        SetLength(SBuff, Fs.Size); //�������� ������ ��� ������.
        Fs.Read(SBuff[1], Length(SBuff)); //��������� � ����� ������ ��������� ������.
        //����� � ������ SBuff ������� ��������� ��������� Sf. ��������� �������� � ���� ��������.
        Offs := Pos(SearchString, SBuff) - 1;
        if Offs > -1 then //���� ��������� �������.
        begin
          Fs.Position := Offs; //���������� ��������� ������ � ��������� ���������.
          Fs.Write(ReplaceString[1], Length(ReplaceString)); //���������� ����� ������������������ ������.
        end;
    finally
        FreeAndNil(Fs); //���������� ��������� ��������� ������ � ��������� ����.
    end;

    if Offs > -1 then begin
        Label1.Text:=ExtractFilename(FileName)+' �������� = ' + IntToStr(Offs);
        AddLog('������� �������� '+Inttostr(offs)+' � ����� '+ExtractFileName(Paramstr(0)+(FileName)), true);
    end
    else begin
        Label1.Text:=ExtractFilename(FileName)+' ������ �� �������';
        AddLog('�� ������� �������� � ����� '+ExtractFileName(Paramstr(0)+(FileName)), true);
    end;
    Application.ProcessMessages;
end;

end.









