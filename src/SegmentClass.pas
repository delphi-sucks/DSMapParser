unit SegmentClass;

interface

uses
  System.Generics.Collections;

type
  TSegmentClass = class
  strict private
    FID: Integer;
    FName: String;
    FClassName: String;
  public
    constructor Create(AID: Integer; const AName, AClassName: String);
    property ID: Integer read FID;
    property Name: String read FName;
    property ClassName: String read FClassName;
  end;

  TSegmentClasses = TObjectDictionary<Integer, TSegmentClass>;

implementation

{ TSegmentClass }

constructor TSegmentClass.Create(AID: Integer; const AName, AClassName: String);
begin
  inherited Create;
  FID := AID;
  FName := AName;
  FClassName := AClassName;
end;

end.
