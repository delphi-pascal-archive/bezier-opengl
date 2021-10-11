unit gui;

interface

uses
  Windows, Messages, SysUtils, {Variants,} Classes, Graphics, Controls, Forms,
  Dialogs, math,
  GFX,
  strutils,
  StdCtrls, ComCtrls,
  ExtCtrls, Buttons;

type
  TfrmMain = class(TForm)
    StatusBar: TStatusBar;
    grp_lines: TGroupBox;
    trckNbLines: TTrackBar;
    Label1: TLabel;
    lblNbLines: TLabel;
    btnLinesApply: TButton;
    grp_Options: TGroupBox;
    trckMBhaut: TTrackBar;
    Inb: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    trckMBbas: TTrackBar;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Quitter1Click(Sender: TObject);
    procedure trckNbLinesChange(Sender: TObject);
    procedure btnLinesApplyClick(Sender: TObject);
    procedure trckMBhautChange(Sender: TObject);
    procedure trckMBbasChange(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;



var


  frmMain: TfrmMain;
  glWnd : HWND;



  run_drawThread : boolean;




implementation

uses GLext,glBezier;

{$R *.dfm}




function DrawThreadProc(param:pointer) : cardinal; cdecl;
begin
  result := 0;

  CreerRC(glWnd, false);

  InitDraw();

  while(run_drawThread) do begin
    Draw();
  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  id : cardinal;
begin

  glWnd := CreerFenetreGL('Glop glop',
    200, 0,
    640, 480,
    false, 32,
    frmMain.Handle);

 { glWnd := CreerFenetreGL('Glop glop',
    0, 0,
    1024, 768,
    true, 32,
    frmMain.Handle);  }

  run_drawThread := true;

  CreateThread(nil, 0, @DrawThreadProc, nil, 0, id);

end;



procedure TfrmMain.FormResize(Sender: TObject);
begin

  MoveWindow(glWnd,
               200, //X
                 0, //Y
         Width-200, //WIDTH
         Height-19, //HEIGHT
              true );

  {MoveWindow(glWnd,
                 0, //X
                 0, //Y
              1024, //WIDTH
               768, //HEIGHT
              true ); }
end;



procedure TfrmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var k:single;
begin
  k := -SmallInt(WheelDelta) / WHEEL_DELTA;
   camera.pos.x := camera.pos.x + camera.mat_model[2] * k;
   camera.pos.y := camera.pos.y + camera.mat_model[6] * k;
   camera.pos.z := camera.pos.z + camera.mat_model[10]* k;;
  camera.moved := true;
end;



procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 try
  run_drawThread := false;
 except
  close;
 end;
end;


procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

//ShowCursor(true);
end;

procedure TfrmMain.Quitter1Click(Sender: TObject);
begin
run_drawThread:=false;
Close;
end;

procedure TfrmMain.trckNbLinesChange(Sender: TObject);
begin
 lblNbLines.Caption := inttostr(trckNbLines.Position);
 trckNbLines.SelEnd := trckNbLines.Position;
end;

procedure TfrmMain.btnLinesApplyClick(Sender: TObject);
begin
 nb_lines:=trckNbLines.Position;
end;

procedure TfrmMain.trckMBhautChange(Sender: TObject);
begin
 mb_haut := trckMBhaut.Position/1000;
 trckMBhaut.SelEnd := trckMBhaut.Position;
end;

procedure TfrmMain.trckMBbasChange(Sender: TObject);
begin
 mb_bas := trckMBbas.Position/1000;
 trckMBbas.SelEnd := trckMBbas.Position;
end;

end.


