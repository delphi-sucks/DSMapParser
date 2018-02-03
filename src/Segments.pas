unit Segments;

interface

uses
  System.Generics.Collections;

type
  TSegmentType = (stRoot, stFile, stFunction, stClass);

  TSegmentClassType = (sctCODE = 1, sctICODE = 2, sctDATA = 3, sctBSS = 4, sctTLS = 5, sctPDATA = 6);

  TSegment = class(TObjectList<TSegment>)
  strict private
    FDictionary: TObjectDictionary<String, TSegment>;
    FSegmentType: TSegmentType;
    FParent: TSegment;
    FName: String;
    FSize: Array[1..6] of UInt64;
    FVisible: Boolean;
    function GetSize(SegmentClassType: TSegmentClassType): UInt64;
    function GetSizeSum(SegmentClassType: TSegmentClassType): UInt64;
    function GetSizeVisible(SegmentClassType: TSegmentClassType): UInt64;
  public
    constructor Create(SegmentType: TSegmentType; const Name: String);
    destructor Destroy; override;
    procedure Add(AName: String; ASegment: TSegment);
    procedure SetSize(ASegmentClassType: TSegmentClassType; ASize: UInt64);
    function TryGetValue(AName: String; out ASegment: TSegment): Boolean;
    function GetFullName: String;
    property SegmentType: TSegmentType read FSegmentType;
    property Name: String read FName;
    property Size[Index: TSegmentClassType]: UInt64 read GetSize;
    property SizeSum[Index: TSegmentClassType]: UInt64 read GetSizeSum;
    property SizeVisible[Index: TSegmentClassType]: UInt64 read GetSizeVisible;
    property Visible: Boolean read FVisible write FVisible;
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

constructor TSegment.Create(SegmentType: TSegmentType; const Name: String);
begin
  inherited Create;
  FDictionary := TObjectDictionary<String, TSegment>.Create;
  FSegmentType := SegmentType;
  FName := Name;
  FVisible := True;
end;

destructor TSegment.Destroy;
begin
  FreeAndNil(FDictionary);
  inherited;
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

function TSegment.GetSize(SegmentClassType: TSegmentClassType): UInt64;
begin
  Result := FSize[Ord(SegmentClassType)];
end;

function TSegment.GetSizeSum(SegmentClassType: TSegmentClassType): UInt64;

  function IterateSize(ASegment: TSegment): UInt64;
  var
    Segment:  TSegment;
  begin
    Result := 0;
    for Segment in ASegment do
    begin
      Result := Result + Segment.Size[SegmentClassType] + IterateSize(Segment);
    end;
  end;

begin
  Result := Size[SegmentClassType] + IterateSize(Self);
end;

function TSegment.GetSizeVisible(SegmentClassType: TSegmentClassType): UInt64;

  function IterateSize(ASegment: TSegment): UInt64;
  var
    Segment:  TSegment;
  begin
    Result := 0;
    for Segment in ASegment do
    begin
      if Segment.Visible then
      begin
        Result := Result + Segment.Size[SegmentClassType] + IterateSize(Segment);
      end;
    end;
  end;

begin
  Result := Size[SegmentClassType] + IterateSize(Self);
end;

procedure TSegment.SetSize(ASegmentClassType: TSegmentClassType; ASize: UInt64);
begin
  FSize[Ord(ASegmentClassType)] := ASize;
end;

function TSegment.TryGetValue(AName: String; out ASegment: TSegment): Boolean;
begin
  Result := FDictionary.TryGetValue(AName, ASegment);
end;

end.
