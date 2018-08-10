unit SegmentClass;

interface

uses
  System.Generics.Collections;

type
  TMapClass = record
  strict private
    FID: UInt8;
    FAddress: UInt64;
    FSize: UInt64;
    FName: String;
    FClassName: String;
  public
    class function Create(AID: UInt8; AAdress, ASize: UInt64; const AName, AClassName: String): TMapClass; static;
    property ID: UInt8 read FID;
    property Address: UInt64 read FAddress;
    property Size: UInt64 read FSize;
    property Name: String read FName;
    property _ClassName: String read FClassName;
  end;

  TMapClasses = TDictionary<ShortInt, TMapClass>;

implementation

{ TSegmentClass }

class function  TMapClass.Create(AID: UInt8; AAdress, ASize: UInt64; const AName, AClassName: String): TMapClass;
begin
  Result.FID := AID;
  Result.FAddress := AAdress;
  Result.FSize := ASize;
  Result.FName := AName;
  Result.FClassName := AClassName;
end;

end.
