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


//интерфейсы магазинов в различных локациях

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

//интерфейс банка во втором дополнении

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


//инвентарь игрока

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

//карточки оружия в сундуках, на земле и наградах за задания

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

    Label1.Text:='Обработка игровых файлов скоро начнется и займет ~2-3 минуты. Подождите.';
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
        then AddLog('***Откат изменений масштаба поля с названием оружия***', false)
        else Addlog('***Старт изменений масштаба поля с названием оружия***', false);
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
    SelButton := MessageDlg('Правда хотите прекратить изменять файлы игры?',TMsgDlgType.mtWarning , mbYesNo, 0);
    if SelButton = mrYes
    then begin
        StopPatch:=True;
    end;
    if SelButton = mrNo
    then ShowMessage('То-то же. Тогда я продолжу.');
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
            AddLog('Не удалось создать временную папку', true);
        end;

        for i := 0 to FileListStrings.count-1 do begin
            CurrentFile:=FileListStrings[i];
            CurrentType:= 'inventory';
            if not StopPatch then begin

                if FileExists(ExtractFileDir(Paramstr(0))+FileListStrings[i])
                then begin
                    Label1.Text:='Обработка файла '+CurrentFile;
                    AddLog('Начало обработки '+ExtractFileName(Paramstr(0)+CurrentFile), true);
                    Application.ProcessMessages;
                    decompress(CurrentFile);
                    FilesMove(FileListStrings[i]);
                    UPKPatch(FileListStrings[i],CurrentType);
                    ProgressBar1.Value := ((i+1) * 100) div (FileListStrings.Count+3) ;
                    Label2.Text:=inttostr(Round( ((i+1) * 100) div (FileListStrings.count+3) ))+'%   ';
                end
                else begin
                    Label1.Text:='Не найден файл '+FileListStrings[i];
                    AddLog('Не найден файл '+ExtractFileName(Paramstr(0)+(FileListStrings[i])), true);
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
                    AddLog('Ошибка', true);
                    break;
                end;
            end;
            if FileExists(ExtractFileDir(Paramstr(0))+FileListStrings[i])
            then begin
                Label1.Text:='Обработка файла '+FileListStrings[i];
                AddLog('Начало обработки '+ExtractFileName(Paramstr(0)+FileListStrings[i]), true);
                Application.ProcessMessages;
                decompress(FileListStrings[i]);
                FilesMove(FileListStrings[i]);
                UPKPatch(FileListStrings[i], CurrentType);
                ProgressBar1.Value :=  (98 + i);
                Label2.Text:=inttostr(Round(ProgressBar1.Value))+'%   ';
            end
            else begin
                Label1.Text:='Не найден файл '+FileListStrings[i];
                AddLog('Не найден файл '+ExtractFileName(Paramstr(0)+FileListStrings[i]), true);
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
                Label1.Text:='Обработка файла '+WGUName;
                AddLog('Начало обработки '+ExtractFileName(Paramstr(0)+WGUName), true);
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
                Label1.Text:='Не найден файл '+WGUName;
                AddLog('Не найден файл '+ExtractFileName(Paramstr(0)+WGUName), true);
            end;
        end;

        ProgressBar1.Value := 100;
        Label2.Text:='100%   ';
        Application.ProcessMessages;

        if StopPatch
        then begin
            AddLog('***************************************************', false);
            AddLog('***********Обработка файлов остановлена.***********', false);
            AddLog('***************************************************', false);
        end;
    except on e:exception do
    		AddLog('Непредвиденная ошибка '+e.Message, true);
    end;

    Button1.Visible:=False;
    Application.ProcessMessages;

    if RemoveDir('Temp')
    then begin
        Label1.Text:='Готово. Наверное.';
        AddLog('Завершена обработка файлов', true);
    end
    else begin
        Label1.Text:=('Не удалось удалить временную папку. Возможно, запущена игра.'+IntToStr(GetLastError));
        AddLog('Не удалось удалить временную папку ', true);
    end;

    Application.ProcessMessages;
end;


{$REGION 'Файловые операции'}

procedure TForm1.Decompress (FileName:string);
var
Rlst: LongBool; //результат выполнения
StartUpInfo: TStartUpInfo; //параметры будущего процесса
ProcessInfo: TProcessInformation; //Отслеживание выполнения
app, CurrDir:string; //текущая папка
Error:integer; //номер ошибкок
SendFail,ExitCode: Cardinal; //код завершения

parameter:String;
SecAtrrs: TSecurityAttributes;
begin
    CurrDir:=ExtractFileDir(Paramstr(0));
    with SecAtrrs do begin
        nLength := SizeOf(SecAtrrs);
        bInheritHandle := True;
        lpSecurityDescriptor := nil;
    end;

    FillChar(StartUpInfo, SizeOf(TStartUpInfo), 0);    //Заполнение нулями всего StartUpInfo.
    with StartUpInfo do
    begin
        cb := SizeOf(TStartUpInfo);
        dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK; //Показываем окно, курсор - часики.
        wShowWindow := SW_HIDE; //Определяет как должно выглядеть окно запущенного приложения.
    end;

    app := CurrDir+'\decompress.exe';

    if not FileExists (app) then
    begin
        Label1.Text:='Не найден '+ExtractFileName(app);
        AddLog('Не найден файл '+ExtractFileName(app), true);
        exit;
    end;

    Application.ProcessMessages;
    parameter:=' -lzo "'+CurrDir+FileName+'" -out="'+CurrDir+'\Temp"';
    if FileExists(CurrDir+FileName)
    then begin
        Rlst:= CreateProcess(PChar(app), PChar(parameter),nil, nil, false,0,nil, nil, StartUpInfo, ProcessInfo);

        //Отслеживаем выполнение.
        if Rlst
        then begin   //Если запуск успешен
            with ProcessInfo do
            begin
                WaitForInputIdle(hProcess, INFINITE);     //Ждем завершения инициализации.
                 WaitforSingleObject(ProcessInfo.hProcess, INFINITE);    //Ждем завершения процесса.
                 GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);    //Получаем код завершения.
                 CloseHandle(hThread);    //Закрываем дескриптор процесса.
                 CloseHandle(hProcess);    //Закрываем дескриптор потока.
            end;
        end

        else begin
            Error := GetLastError;  //Получаем код в случае ошибки
        end;
        SendFail:=ExitCode;
        Application.ProcessMessages;
        if (SendFail<>0)
        then begin
           Label1.Text:='Ошибка при распаковке: '+FileName+' /'+inttostr(SendFail)+' /'+inttostr(Error);
           AddLog('Ошибка при распаковке '+ExtractFileName(Paramstr(0)+(FileName)), true);
        end
        else begin
           Label1.Text:='Распакован: '+FileName;
           AddLog('Распакован '+ExtractFileName(Paramstr(0)+(FileName)), true);
        end;
    end
    else begin
        Label1.Text:='Файл не найден: '+FileName;
        AddLog('Не найден файл '+ExtractFileName(Paramstr(0)+(FileName)), true);
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
          Label1.Text:='Перемещен: '+FileName;
          AddLog('Перемещен из временной папки '+ExtractFileName(Paramstr(0)+(FileName)), true);
          Application.ProcessMessages;
      except on e:exception do
          AddLog('Не удалось переместить из временной папки '+ExtractFileName(Paramstr(0)+(FileName)), true);
      end;
  end;

  procedure TForm1.FilesDelete (FileName:string);
  var CurrDir:String;
  begin
      try
          CurrDir:=ExtractFileDir(Paramstr(0));

          if DeleteFile(CurrDir+'\'+fileName)
          then begin
              Label1.Text:='Удален '+fileName;
              AddLog('Удален '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end
          else begin
              Label1.Text:='Произошла ошибка при удалении '+ fileName;
              AddLog('Произошла ошибка '+IntToStr(GetLastError)+' при удалении '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end;
      except on e:exception do
          AddLog('Не удалось удалить файл '+ExtractFileName(Paramstr(0)+(FileName)), true);
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
              Label1.Text:='Переименован '+fileName;
              AddLog('Переименован '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end
          else begin
              Label1.Text:='Произошла ошибка при переименовании '+ fileName;
              AddLog('Произошла ошибка '+IntToStr(GetLastError)+' при переименовании '+ExtractFileName(Paramstr(0)+(FileName)), true);
          end;
      except on e:exception do
          AddLog('Не удалось переименовать файл '+ExtractFileName(Paramstr(0)+(FileName)), true);
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
            Label1.Text:='Обработка '+ExtractFilename(ExtractFileDir(Paramstr(0))+FileName);
            Application.ProcessMessages;
            StringReplace ( ExtractFileDir(Paramstr(0))+FileName, ExtractFileDir(Paramstr(0)+FileName), SearchArray[k], ReplaceArray[k] );
        end;

    end
    else begin
        for k:= 0 to ReplaceArray.Count-1 do begin
            Label1.Text:='Возврат изменений '+ExtractFilename(ExtractFileDir(Paramstr(0))+FileName);
            Application.ProcessMessages;
            StringReplace ( ExtractFileDir(Paramstr(0))+FileName, ExtractFileDir(Paramstr(0)+FileName), ReplaceArray[k], SearchArray[k] );
        end;
    end;
end;


procedure TForm1.StringReplace(FileToPatch, OutDir: string; SearchString, ReplaceString : AnsiString);
var
  Fs : TFileStream;
  FileName : String;
  SBuff : AnsiString; //AnsiString - тип, описывающий строку однобайтных символов.
  Offs : Int64;
begin
    FileName := FileToPatch; //Путь к файлу.
    //Создаём экземпляр файлового потока и открываем файл в режиме чтения и записи
    //(fmOpenReadWrite), с запретом на запись из других процессов (fmShareDenyWrite).
    Fs := TFileStream.Create(FileName, fmOpenReadWrite + fmShareDenyWrite);
    try
        SetLength(SBuff, Fs.Size); //Выделяем память для буфера.
        Fs.Read(SBuff[1], Length(SBuff)); //Загружаем в буфер данные файлового потока.
        //Поиск в буфере SBuff первого вхождения подстроки Sf. Результат получаем в виде смещения.
        Offs := Pos(SearchString, SBuff) - 1;
        if Offs > -1 then //Если подстрока найдена.
        begin
          Fs.Position := Offs; //Перемещаем указатель потока к найденной подстроке.
          Fs.Write(ReplaceString[1], Length(ReplaceString)); //Записываем новую последовательность байтов.
        end;
    finally
        FreeAndNil(Fs); //Уничтожаем экземпляр файлового потока и закрываем файл.
    end;

    if Offs > -1 then begin
        Label1.Text:=ExtractFilename(FileName)+' Смещение = ' + IntToStr(Offs);
        AddLog('Найдено смещение '+Inttostr(offs)+' в файле '+ExtractFileName(Paramstr(0)+(FileName)), true);
    end
    else begin
        Label1.Text:=ExtractFilename(FileName)+' Строка не найдена';
        AddLog('Не найдено смещение в файле '+ExtractFileName(Paramstr(0)+(FileName)), true);
    end;
    Application.ProcessMessages;
end;

end.









