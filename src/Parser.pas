unit Parser;

interface

uses
  System.Types,
  Segments;

type
  TParser = class
  strict private
    FMapLines: TStringDynArray;
    FRootSegment: TSegment;
    procedure DoParse;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: String);
    property RootSegment: TSegment read FRootSegment;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.RegularExpressions, System.Generics.Collections;

{ TParser }

constructor TParser.Create;
begin
  inherited;
end;

destructor TParser.Destroy;
begin
  FreeAndNil(FRootSegment);
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

var
  i1:           Integer;
  i2:           Integer;
  regEx:        TRegEx;
  match:        TMatch;
//  segmentType:  TSegmentType;
//  name:         String;
//  lastSegments: TDictionary<UInt64, TSegment>;
  segment:      TSegment;
  parentSegment:  TSegment;
  segmentNames: TArray<string>;
  SegmentClassType: TSegmentClassType;
begin
  // Files
  regEx := TRegEx.Create('^\s*([A-F0-9]+):([A-F0-9]+)\s+([A-F0-9]+)\s+C=[A-Z]+\s+S=\.[a-z]+\s+G=[a-zA-Z\(\)]+\s+M=([a-zA-Z0-9_\.]+)\s+(ACBP|ALIGN)=[A-Z0-9]+$', []);
  for i1 := Low(FMapLines) to High(FMapLines) do
  begin
    match := regEx.Match(FMapLines[i1]);
    if match.Success then
    begin
      SegmentClassType := TSegmentClassType(StrToUInt64('$' + match.Groups[1].Value));
      segmentNames := match.Groups[4].Value.Split(['.']);
      parentSegment := RootSegment;
      for i2 := Low(segmentNames) to High(segmentNames) do
      begin
        if parentSegment.TryGetValue(segmentNames[i2], segment) then
        begin
          parentSegment := segment;
        end else
        begin
          segment := TSegment.Create(stFile, segmentNames[i2]);
          parentSegment.Add(segmentNames[i2], segment);
          parentSegment := segment;
        end;
        segment.SetSize(SegmentClassType, StrToUInt64Def('$' + match.Groups[3].Value, 0));
      end;
    end;
  end;


  // Classes, Functions
  regEx := TRegEx.Create('^\s*([A-F0-9]+):([A-F0-9]+)\s+([a-zA-Z0-9_\.{}<>,]+)$', []);

//  lastSegments := TDictionary<UInt64, TSegment>.Create;
//  try
//    for i1 := Low(FMapLines) to High(FMapLines) do
//    begin
//      match := regEx.Match(FMapLines[i1]);
//      if match.Success then
//      begin
//        address1 := StrToUInt64('$' + match.Groups[1].Value);
//        if address1 <> 1 then
//        begin
//          Continue;
//        end;
//
//        address2 := StrToUInt64('$' + match.Groups[2].Value);
//        name := match.Groups[3].Value;
//        segmentNames := SplitName(name);
//
//        if name.Contains('..') then
//        begin
//          segmentType := stClass;
//        end else
//        begin
//          segmentType := stFunction;
//        end;
//        parentSegment := RootSegment;
//        for i2 := Low(segmentNames) to High(segmentNames) - 1 do
//        begin
//          if not parentSegment.TryGetValue(segmentNames[i2], parentSegment) then
//          begin
//            raise Exception.Create('Could not find segment "' + name + '"');
//          end;
//        end;
//        segment := TSegment.Create(segmentType, segmentNames[Length(segmentNames) - 1], 0, address1, address2);
//
//        // overloaded methods
//        if not parentSegment.ContainsKey(segmentNames[Length(segmentNames) - 1]) then
//        begin
//          parentSegment.Add(segmentNames[Length(segmentNames) - 1], segment);
//        end;
//      end;
//    end;
//  finally
//    FreeAndNil(lastSegments);
//  end;
end;

procedure TParser.LoadFromFile(const AFileName: String);
begin
  FMapLines := TFile.ReadAllLines(AFileName);
  FRootSegment := TSegment.Create(stRoot, ChangeFileExt(ExtractFileName(AFileName), EmptyStr));
  DoParse;
end;

end.