unit Publics;

interface

type
  TPublicType = (ptType, ptDeclaration);

  TPublic = class
  strict private
    FPublicType: TPublicType;
    FAddress: UInt64;
    FName: String;
  public
    constructor Create(ATyp: TPublicType; AAddress: UInt64; const AName: String);
    property PublicType: TPublicType read FPublicType;
    property Address: UInt64 read FAddress;
    property Name: String read FName;
  end;

implementation

{ TPublic }

constructor TPublic.Create(ATyp: TPublicType; AAddress: UInt64; const AName: String);
begin
  inherited Create;
  FPublicType := ATyp;
  FAddress := AAddress;
  FName := AName;
end;

end.
