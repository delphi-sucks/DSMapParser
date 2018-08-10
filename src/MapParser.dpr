program MapParser;

uses
  Winapi.Windows,
  Vcl.Forms,
  Main in 'Main.pas' {frmMain},
  Segments in 'Segments.pas',
  Parser in 'Parser.pas',
  SegmentClass in 'SegmentClass.pas',
  Publics in 'Publics.pas';

{$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}
{$IFOPT D-}{$WEAKLINKRTTI ON}{$ENDIF}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
