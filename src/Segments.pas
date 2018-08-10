unit Segments;

interface

uses
  System.Generics.Collections,
  Publics;

type
  TSegmentType = (stRoot, stFile, stFunction, stClass);

  TSegmentClassType = (sctUNKNOWN = 0, sctCODE = 1, sctICODE = 2, sctDATA = 3, sctBSS = 4, sctTLS = 5, sctPDATA = 6);

  TSegmentClass = record
  strict private
    FAddress: UInt64;
    FSize: UInt64;
    FGroup: String;
    FACBP: SmallInt;
  public
    class function Create(AAddress, ASize: UInt64; AGroup: String; AACBP: SmallInt): TSegmentClass; static;
    property Address: UInt64 read FAddress;
    property Size: UInt64 read FSize;
    property Group: String read FGroup;
    property ACBP: Smallint read FACBP;
  end;

  TSegment = class(TObjectList<TSegment>)
  strict private
    FDictionary: TObjectDictionary<String, TSegment>;
    FSegmentType: TSegmentType;
    FParent: TSegment;
    FName: String;
    FVisible: Boolean;
    FClasses: TArray<TSegmentClass>;
    FClassCount: ShortInt;
    FPublics: TObjectList<TPublic>;
    function GetSize(AID: UInt8): UInt64;
    function GetSizeSum(AID: UInt8): UInt64;
    function GetSizeVisible(AID: UInt8): UInt64;
    function GetClass(AID: UInt8): TSegmentClass;
  public
    constructor Create(AClassCount: ShortInt; ASegmentType: TSegmentType; const AName: String);
    destructor Destroy; override;
    procedure Add(AName: String; ASegment: TSegment);
    procedure SetClassInfo(AID: UInt8; AAddress, ALength: UInt64; AGroup: String; AACBP: SmallInt);
    function TryGetValue(AName: String; out ASegment: TSegment): Boolean;
    function ContainsKey(AName: String): Boolean;
    function GetFullName: String;
    property SegmentType: TSegmentType read FSegmentType;
    property Name: String read FName;
    property Size[Index: UInt8]: UInt64 read GetSize;
    property SizeSum[Index: UInt8]: UInt64 read GetSizeSum;
    property SizeVisible[Index: UInt8]: UInt64 read GetSizeVisible;
    property Visible: Boolean read FVisible write FVisible;
    property _ClassInfo[Index: UInt8]: TSegmentClass read GetClass;
    property Publics: TObjectList<TPublic> read FPublics;
  end;

implementation

uses
  System.SysUtils;

procedure TSegment.Add(AName: String; ASegment: TSegment);
begin
  inherited Add(ASegment);
  FDictionary.Add(AName, ASegment);
  ASegment.FParent := Self;
end;

function TSegment.ContainsKey(AName: String): Boolean;
begin
  Result := FDictionary.ContainsKey(AName);
end;

constructor TSegment.Create(AClassCount: ShortInt; ASegmentType: TSegmentType; const AName: String);
var
  i1: Integer;
begin
  inherited Create;
  FPublics := TObjectList<TPublic>.Create;
  FClassCount := AClassCount;
  SetLength(FClasses, FClassCount);
  for i1 := 0 to FClassCount - 1 do
  begin
    FClasses[i1] := TSegmentClass.Create(0, 0, EmptyStr, 0);
  end;

  FDictionary := TObjectDictionary<String, TSegment>.Create;
  FSegmentType := ASegmentType;
  FName := AName;
  FVisible := True;
end;

destructor TSegment.Destroy;
begin
  FreeAndNil(FDictionary);
  FreeAndNil(FPublics);
  inherited;
end;

function TSegment.GetClass(AID: UInt8): TSegmentClass;
begin
  Result := FClasses[AID];
end;

function TSegment.GetFullName: String;
var
  SegmentParent: TSegment;
begin
  Result := Name;
  SegmentParent := FParent;
  while (SegmentParent <> nil)
  and (SegmentParent.SegmentType <> stRoot) do
  begin
    Result := SegmentParent.Name + '.' + Result;
    SegmentParent := SegmentParent.FParent;
  end;
end;

function TSegment.GetSize(AID: UInt8): UInt64;
begin
  if AID > FClassCount then
  begin
    Result := 0;
  end else
  begin
    Result := _ClassInfo[AID - 1].Size;
  end;
end;

function TSegment.GetSizeSum(AID: UInt8): UInt64;

  function IterateSize(ASegment: TSegment): UInt64;
  var
    Segment:  TSegment;
  begin
    Result := 0;
    for Segment in ASegment do
    begin
      Result := Result + Segment.Size[AID] + IterateSize(Segment);
    end;
  end;

begin
  Result := Size[AID] + IterateSize(Self);
end;

function TSegment.GetSizeVisible(AID: UInt8): UInt64;

  function IterateSize(ASegment: TSegment): UInt64;
  var
    Segment:  TSegment;
  begin
    Result := 0;
    for Segment in ASegment do
    begin
      if Segment.Visible then
      begin
        Result := Result + Segment.Size[AID] + IterateSize(Segment);
      end;
    end;
  end;

begin
  Result := Size[AID] + IterateSize(Self);
end;

procedure TSegment.SetClassInfo(AID: UInt8; AAddress, ALength: UInt64; AGroup: String; AACBP: SmallInt);
begin
  FClasses[AID - 1] := TSegmentClass.Create(AAddress, ALength, AGroup, AACBP);
end;

function TSegment.TryGetValue(AName: String; out ASegment: TSegment): Boolean;
begin
  Result := FDictionary.TryGetValue(AName, ASegment);
end;

{ TSegmentClass }

class function TSegmentClass.Create(AAddress, ASize: UInt64; AGroup: String; AACBP: SmallInt): TSegmentClass;
begin
  Result.FAddress := AAddress;
  Result.FSize := ASize;
  Result.FGroup := AGroup;
  Result.FACBP := AACBP;
end;

end.
