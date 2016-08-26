unit _fmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls;

type
  TGetTickCount64 = function: Int64;
  TfmMain = class(TForm)
    Timer: TTimer;
    PnTimer: TPanel;
    procedure TimerTimer(Sender: TObject);
    procedure PnTimerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    GetTickCount64: TGetTickCount64;
    procedure SetGetTickCount64;
    procedure ShowOperationTime;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

constructor TfmMain.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;

  SetGetTickCount64;

  for I := 0 to Pred(Screen.MonitorCount) do begin
    if Screen.Monitors[I].Primary then begin
      SetBounds((Screen.Monitors[I].WorkareaRect.Width - Width) shr 1, 0, Width, Height);
      Break;
    end;
  end;
  ShowOperationTime;
end;

function GetTickCount64Alter: Int64;
begin
  Result := PUint64($7FFE0008)^ div 10000; // Virtual Address of InterruptTime(KSYSTEM_TIME) in KUSER_SHARED_DATA
//  Result := Winapi.Windows.GetTickCount;
end;

procedure TfmMain.SetGetTickCount64;
var
  hKernel32: HMODULE;
begin
  if TOSVersion.Major >= 6 then begin
    hKernel32 := LoadLibrary(kernel32);
    if hKernel32 <> 0 then begin
      GetTickCount64 := GetProcAddress(hKernel32, 'GetTickCount64');
      FreeLibrary(hKernel32);
    end;
  end else begin
    GetTickCount64 := GetTickCount64Alter;
  end;
end;

procedure TfmMain.TimerTimer(Sender: TObject);
begin
  ShowOperationTime;
end;

procedure TfmMain.PnTimerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TfmMain.ShowOperationTime;
var
  Day: Int64;
  Hour: Int64;
  Minute: Int64;
  Second: Int64;
  Milli: Int64;
begin
  Milli := GetTickCount64;

  Second := Milli div 1000;
//  Milli := Milli mod 1000;

  Minute := Second div 60;
  Second := Second mod 60;

  Hour := Minute div 60;
  Minute := Minute mod 60;

  Day := Hour div 24;
  Hour := Hour mod 24;

  PnTimer.Caption := Format('%d¿œ %.2d:%.2d:%.2d', [Day, Hour, Minute, Second]);
end;

end.
