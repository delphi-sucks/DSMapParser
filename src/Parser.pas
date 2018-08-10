unit Parser;

interface

uses
  System.Types,
  Segments, SegmentClass;

type
  TParser = class
  strict private
    FMapLines: TStringDynArray;
    FRootSegment: TSegment;
    FMapClasses: TMapClasses;
    procedure DoParse;
    procedure ParseClass(const ALine: String);
    procedure ParseSegment(const ALine: String);
    procedure ParsePublicByName(const ALine: String);
    procedure ParsePublicByValue(const ALine: String);
    procedure ParseResourceFiles(const ALine: String);
    function SplitPublicName(AName: String): TArray<String>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: String);
    property RootSegment: TSegment read FRootSegment;
    property MapClasses: TMapClasses read FMapClasses;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.RegularExpressions, System.Generics.Collections,
  Publics;

{ TParser }

constructor TParser.Create;
begin
  inherited;
end;

destructor TParser.Destroy;
begin
  FreeAndNil(FRootSegment);
  FreeAndNil(FMapClasses);
  inherited;
end;

procedure TParser.DoParse;

  function SplitName(Name: String): TArray<String>;
  var
    i1:           Integer;
    genericDepth: Integer;
    tempName:     String;
  begin
    SetLength(Result, 0);
    tempName := EmptyStr;
    genericDepth := 0;
    for i1 := 0 to Name.Length - 1 do
    begin
      if (genericDepth = 0)
      and (Name.Chars[i1] = '.') then
      begin
        if tempName <> EmptyStr then
        begin
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := tempName;
          tempName := EmptyStr;
        end;
      end else
      begin
        tempName := tempName + Name.Chars[i1];
        if CharInSet(Name.Chars[i1], ['>', '}']) then
        begin
          Dec(genericDepth);
        end else
        if CharInSet(Name.Chars[i1], ['<', '{']) then
        begin
          Inc(genericDepth);
        end;
      end;
    end;
    if tempName <> EmptyStr then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := tempName;
    end;
  end;

type
  TParseSection = (psNone, psClasses, psSegments, psPublicsByName, psPublicsByValue, psResourceFiles);
  TParseSections = set of TParseSection;
var
  i1: Integer;
  parseSection: TParseSection;
  parsedSections: TParseSections;
  MapLine: String;
begin
  parseSection := psNone;
  parsedSections := [];
  for i1 := Low(FMapLines) to High(FMapLines) do
  begin
    MapLine := FMapLines[i1].Trim;
    if MapLine = EmptyStr then
    begin
      Continue;
    end;

    if not (psClasses in parsedSections)
    and TRegEx.IsMatch(MapLine, '^Start +Length +Name +Class$') then
    begin
      parseSection := psClasses;
      Include(parsedSections, psClasses);
      Continue;
    end;
    if not (psSegments in parsedSections)
    and (MapLine = 'Detailed map of segments') then
    begin
      parseSection := psSegments;
      Include(parsedSections, psSegments);
      Continue;
    end;
    if not (psPublicsByName in parsedSections)
    and MapLine.StartsWith('Address')
    and MapLine.EndsWith('Publics by Name') then
    begin
      parseSection := psPublicsByName;
      Include(parsedSections, psPublicsByName);
      Continue;
    end;
    if not (psPublicsByValue in parsedSections)
    and MapLine.StartsWith('Address')
    and MapLine.EndsWith('Publics by Value') then
    begin
      parseSection := psPublicsByValue;
      Include(parsedSections, psPublicsByValue);
      Continue;
    end;
    if not (psResourceFiles in parsedSections)
    and (MapLine = 'Bound resource files') then
    begin
      parseSection := psResourceFiles;
      Include(parsedSections, psResourceFiles);
      Continue;
    end;

    case parseSection of
      psClasses:
        ParseClass(MapLine);
      psSegments:
        ParseSegment(MapLine);
      psPublicsByName:
        ParsePublicByName(MapLine);
      psPublicsByValue:
        ParsePublicByValue(MapLine);
      psResourceFiles:
        ParseResourceFiles(MapLine);
    end;
  end;
end;

procedure TParser.LoadFromFile(const AFileName: String);
begin
  FreeAndNil(FRootSegment);
  FreeAndNil(FMapClasses);

  FMapLines := TFile.ReadAllLines(AFileName);
  FMapClasses := TMapClasses.Create;
  FRootSegment := TSegment.Create(0, stRoot, ChangeFileExt(ExtractFileName(AFileName), EmptyStr));
  DoParse;
end;

procedure TParser.ParseClass(const ALine: String);
var
  Match: TMatch;
  ID: UInt8;
  Address: UInt64;
  Length: UInt64;
  Name: String;
  ClassName: String;
begin
  Match := TRegEx.Match(ALine, '^(\d{4}):([0-9A-F]{8,16}) ([0-9A-F]{8,16})H (\.[a-z]+) +([A-Z]+)$');
  if Match.Success then
  begin
    ID := StrToInt('$' + Match.Groups[1].Value);
    Address := StrToUInt64('$' + Match.Groups[2].Value);
    Length := StrToUInt64('$' + Match.Groups[3].Value);
    Name := Match.Groups[4].Value.Trim;
    ClassName := Match.Groups[5].Value.Trim;
    FMapClasses.Add(ID, TMapClass.Create(ID, Address, Length, Name, ClassName));
  end;
end;

procedure TParser.ParsePublicByName(const ALine: String);
var
  Match: TMatch;
  ID: UInt8;
  Address: UInt64;
  Name: String;
  Typ: TPublicType;
  Modules: TArray<String>;
  Segment: TSegment;
  SegmentChild: TSegment;
  i1: Integer;
begin
  Match := TRegEx.Match(ALine, '^([0-9A-F]{4}):([0-9A-F]{8,16}) +(.+)$');
  if Match.Success then
  begin
    ID := StrToInt('$' + Match.Groups[1].Value);
    Address := StrToUInt64('$' + Match.Groups[2].Value);
    Name := Match.Groups[3].Value.Trim;
    Modules := SplitPublicName(Name);

    Segment := RootSegment;
    for i1 := Low(Modules) to High(Modules) do
    begin
      if Segment.TryGetValue(Modules[i1], SegmentChild) then
      begin
        Segment := SegmentChild;
      end else
      begin
        Break;
      end;
    end;
    if Segment <> RootSegment then
    begin
      Name := Name.Substring(Segment.GetFullName.Length + 1);
      if Name.Chars[0] = '.' then
      begin
        Typ := ptType;
      end else
      begin
        Typ := ptDeclaration;
      end;
      Segment.Publics.Add(TPublic.Create(Typ, Address, Name));
    end;
  end;
end;

procedure TParser.ParsePublicByValue(const ALine: String);
begin

end;

procedure TParser.ParseResourceFiles(const ALine: String);
begin

end;

procedure TParser.ParseSegment(const ALine: String);
var
  i1: Integer;
  Match: TMatch;
  SegmentClass: TMapClass;
  Segment: TSegment;
  ParentSegment: TSegment;
  ID: UInt8;
  Address: UInt64;
  Length: UInt64;
  Group: String;
  Module: String;
  Modules: TArray<String>;
  Name: String;
  ACBP: SmallInt;
begin
  Match := TRegEx.Match(ALine, '^([0-9A-F]{4}):([0-9A-F]{8,16}) +([A-F0-9]{8,16}) +C=.+ +S=.+ +G=(.+) +M=(.+) +(?:ACBP|ALIGN)=([A-Z0-9]+)$');
  if Match.Success then
  begin
    ID := StrToInt('$' + Match.Groups[1].Value);
    if FMapClasses.TryGetValue(ID, SegmentClass) then
    begin
      Address := StrToUInt64('$' + Match.Groups[2].Value);
      Length := StrToUInt64('$' + Match.Groups[3].Value);
      Group := Match.Groups[4].Value.Trim;
      Module := Match.Groups[5].Value.Trim;
      ACBP := StrToInt('$' + Match.Groups[6].Value);


      Modules := Module.Split(['.']);
      Segment := nil;
      ParentSegment := RootSegment;
      for i1 := Low(Modules) to High(Modules) - 1 do
      begin
        Name := Modules[i1];
        if ParentSegment.TryGetValue(Name, Segment) then
        begin
          ParentSegment := Segment;
        end else
        begin
          Segment := TSegment.Create(FMapClasses.Count, stFile, Name);
          ParentSegment.Add(Name, Segment);
          ParentSegment := Segment;
        end;
      end;
      Name := Modules[High(Modules)];
      if not ParentSegment.TryGetValue(Name, Segment) then
      begin
        Segment := TSegment.Create(FMapClasses.Count, stFile, Name);
        ParentSegment.Add(Name, Segment);
      end;
      Segment.SetClassInfo(ID, Address, Length, Group, ACBP);
    end;
  end;
end;

function TParser.SplitPublicName(AName: String): TArray<String>;
var
  Index: Integer;
  QuoteCount: Integer;
  CurrChar: Char;
  Module: String;
  ModuleCount: Integer;
begin
  SetLength(Result, 0);
  ModuleCount := 0;
  QuoteCount := 0;
  Module := EmptyStr;
  for Index := 0 to AName.Length - 1 do
  begin
    CurrChar := AName.Chars[Index];
    if CharInSet(CurrChar, ['<', '{']) then
    begin
      Inc(QuoteCount);
    end;
    if CharInSet(CurrChar, ['>', '}']) then
    begin
      Dec(QuoteCount);
    end;
    if (CurrChar = '.')
    and (QuoteCount = 0) then
    begin
      if Module <> EmptyStr then
      begin
        SetLength(Result, ModuleCount + 1);
        Result[ModuleCount] := Module;
        Inc(ModuleCount);
        Module := EmptyStr;
      end;
    end else
    begin
      Module := Module + CurrChar;
    end;
  end;
  if Module <> EmptyStr then
  begin
    SetLength(Result, ModuleCount + 1);
    Result[ModuleCount] := Module;
  end;
end;

end.
