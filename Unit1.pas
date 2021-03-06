unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Inifiles;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    DateTimePicker1: TDatePicker;
    Memo2: TMemo;
    Button5: TButton;
    Button6: TButton;
    DateTimePicker2: TDatePicker;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Edit3: TEdit;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Memo2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function ExecAndWait(const FileName, Params: ShortString;
      const WinState: Word; i: integer): boolean; export;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SaveList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  StringL: TStringList;
  isg: integer = 0;

implementation

{$R *.dfm}

function TForm1.ExecAndWait(const FileName, Params: ShortString;
  const WinState: Word; i: integer): boolean; export;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: ShortString;
begin
  { �������� ��� ����� ����� ���������, � ����������� ���� �������� � ������ Win9x }
  CmdLine := '"' + FileName + '" ' + Params;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  Result := CreateProcess(nil, PChar(String(CmdLine)), nil, nil, false,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
    PChar(ExtractFilePath(FileName)), StartInfo, ProcInfo);
  if Result then
  begin
    StringL.Add(IntTOStr(ProcInfo.hProcess));
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
Var
  i: integer;
begin
  if OpenDialog1.Execute then
    for i := 0 to OpenDialog1.Files.Count - 1 do
      Memo1.Lines.Add(OpenDialog1.Files.strings[i]);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Memo1.Lines.Delete(Memo1.CaretPos.Y);
end;

procedure TForm1.Button3Click(Sender: TObject);
Var
  i: integer;
begin
  for i := 0 to Memo1.Lines.Count - 1 do
  if pos(Memo1.Lines[i],'http')>0 then
  ExecAndWait(Edit1.Text, ' -vvv "' + Memo1.Lines[i] +
      '" :file-caching=' + Edit3.Text + ' -I dummy :sout=#http{mux=ts,dst=:' +
      IntTOStr(StrToInt(Edit2.Text) + i) + '/} :sout-all :sout-keep',
      SW_MINIMIZE, i)
  else
    ExecAndWait(Edit1.Text, ' -vvv "file:///' + Memo1.Lines[i] +
      '" :file-caching=' + Edit3.Text + ' -I dummy :sout=#http{mux=ts,dst=:' +
      IntTOStr(StrToInt(Edit2.Text) + i) + '/} :sout-all :sout-keep',
      SW_MINIMIZE, i);
  Timer1.Enabled := True;
  Timer2.Enabled := True;
   SaveList;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    Edit1.Text := OpenDialog1.FileName;
end;

procedure TForm1.Button5Click(Sender: TObject);
Var
  i: integer;
begin
  if OpenDialog1.Execute then
    for i := 0 to OpenDialog1.Files.Count - 1 do
      Memo2.Lines.Add(OpenDialog1.Files.strings[i]);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Memo2.Lines.Delete(Memo2.CaretPos.Y);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  i: integer;
      Ini:   Tinifile;
begin
  for i := 0 to StringL.Count - 1 do
    TerminateProcess(StrToInt(StringL[i]), 0);

    Ini := TiniFile.Create(extractfilepath(ParamStr(0)) + 'List.ini');
    Ini.WriteInteger('Options', 'AutoPlay', 0);
    Ini.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
  var
    Ini: Tinifile;
    i, o, j, ap: integer;
begin
  StringL := TStringList.Create;

    Ini := TiniFile.Create(extractfilepath(ParamStr(0)) + 'List.ini');
    Edit1.Text := Ini.ReadString('Options', 'VLC', '');
    Edit2.Text := IntToStr(Ini.ReadInteger('Options', 'Port', 1908));
    Edit3.Text := IntToStr(Ini.ReadInteger('Options', 'Cache', 600));

    i := Ini.ReadInteger('List1', 'Count', 0);
    if i > 0 then
      for j := 0 to i-1 do
        Memo1.Lines.Add(Ini.ReadString('List1', IntToStr(j), ''));

    o := Ini.ReadInteger('List2', 'Count', 0);
    if o > 0 then
      for j := 0 to o-1 do
        Memo2.Lines.Add(Ini.ReadString('List2', IntToStr(j), ''));

    DateTimePicker1.Date:= Ini.ReadDate('List1','EndDate',Now);
    DateTimePicker2.Date:= Ini.ReadDate('List2','EndDate',Now);
    ap := Ini.ReadInteger('Options', 'AutoPlay', 0);
    if ap = 1 then
    Button3.Click;
    Ini.Free;
end;

procedure TForm1.Memo1Click(Sender: TObject);
var
  Line: integer;
begin
  with (Sender as TMemo) do
  begin
    Line := Perform(EM_LINEFROMCHAR, SelStart, 0);
    SelStart := Perform(EM_LINEINDEX, Line, 0);
    SelLength := Length(Lines[Line]);
  end;
end;

procedure TForm1.Memo2Click(Sender: TObject);
var
  Line: integer;
begin
  with (Sender as TMemo) do
  begin
    Line := Perform(EM_LINEFROMCHAR, SelStart, 0);
    SelStart := Perform(EM_LINEINDEX, Line, 0);
    SelLength := Length(Lines[Line]);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
Var
  i: integer;
begin
  for i := 0 to StringL.Count - 1 do
    if WaitForSingleObject(StrToInt(StringL[i]), 200) = 0 then
    begin
      ExecAndWait(Edit1.Text, ' -vvv "file:///' + Memo1.Lines[i] +
        '" :file-caching=' + Edit3.Text + ' -I dummy :sout=#http{mux=ts,dst=:' +
        IntTOStr(StrToInt(Edit2.Text) + i) + '/} :sout-all :sout-keep',
        SW_MINIMIZE, i);
    end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
Var
  d1, d2: TDate;
  i: integer;
begin
  d1 := date(); // ������� ����
  d2 := DateTimePicker1.date; // ���� ��� ���������
  if d1 > d2 then
  begin
    for i := 0 to StringL.Count - 1 do
      TerminateProcess(StrToInt(StringL[i]), 0);
    Timer1.Enabled := false;
    Memo1.Clear;
    StringL.Clear;
    Memo1.Lines := Memo2.Lines;
    DateTimePicker1.date := DateTimePicker2.date;
    Memo2.Clear;
    DateTimePicker2.date := DateTimePicker1.date + 7;
    Button3.Click;
  end;
end;


procedure TForm1.SaveList;
  var
    Ini: Tinifile;
    i:   integer;
  begin
    Ini := TiniFile.Create(extractfilepath(ParamStr(0)) + 'List.ini');
    Ini.WriteInteger('Options', 'AutoPlay', 1);
    Ini.WriteString('Options', 'VLC', Edit1.Text);
    Ini.WriteInteger('Options', 'Port', StrToInt(Edit2.Text));
    Ini.WriteInteger('Options', 'Cache', StrToInt(Edit3.Text));

    ini.EraseSection('List1');
    Ini.WriteInteger('List1', 'Count', Memo1.Lines.Count);
    Ini.WriteString('List1', 'Date', Edit3.Text);
    for i := 0 to Memo1.Lines.Count - 1 do
      Ini.WriteString('List1', IntToStr(i), Memo1.Lines[i]);
    Ini.WriteDate('List1','EndDate',DateTimePicker1.Date);

    ini.EraseSection('List2');
    Ini.WriteInteger('List2', 'Count', Memo2.Lines.Count);
    Ini.WriteString('List2', 'Date', Edit3.Text);
    for i := 0 to Memo2.Lines.Count - 1 do
      Ini.WriteString('List2', IntToStr(i), Memo2.Lines[i]);
    Ini.WriteDate('List2','EndDate',DateTimePicker2.Date);

    Ini.Free;
  end;

end.
