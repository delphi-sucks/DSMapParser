unit Main;

interface

uses
  System.Classes,
  Vcl.Controls, Vcl.Dialogs, System.Actions, Vcl.ActnMan, Vcl.Forms, Vcl.ActnCtrls,
  Vcl.ToolWin, Vcl.ActnMenus, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  VirtualTrees,
  Parser;

type
  TfrmMain = class(TForm)
    ActionManager: TActionManager;
    actOpen: TAction;
    ActionMainMenuBar1: TActionMainMenuBar;
    ActionToolBar1: TActionToolBar;
    treSegments: TVirtualStringTree;
    FileOpenDialog: TFileOpenDialog;
    edtSearch: TEdit;
    chkSearchRegEx: TCheckBox;
    barStatus: TStatusBar;
    actCalcuateSumByVisible: TAction;
    actHideNullValues: TAction;
    procedure actCalcuateSumByVisibleExecute(Sender: TObject);
    procedure actHideNullValuesExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure chkSearchRegExClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
    procedure treSegmentsCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var
        Result: Integer);
    procedure treSegmentsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var LineBreakStyle:
        TVTTooltipLineBreakStyle; var HintText: string);
    procedure treSegmentsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType:
        TVSTTextType; var CellText: string);
    procedure treSegmentsInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure treSegmentsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates:
        TVirtualNodeInitStates);
  strict private
    FCalculateSumByVisible: Boolean;
    FHideNullValues: Boolean;
    FParser: TParser;
    procedure Search(AText: String);
    procedure SetErrorMessage(const AMessage: String);
    function SizeAsKiB(ASize: UInt64): String;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  System.SysUtils, System.RegularExpressions,
  Segments;

procedure TfrmMain.actCalcuateSumByVisibleExecute(Sender: TObject);
begin
  FCalculateSumByVisible := actCalcuateSumByVisible.Checked;
  treSegments.Refresh;
end;

procedure TfrmMain.actHideNullValuesExecute(Sender: TObject);
begin
  FHideNullValues := actHideNullValues.Checked;
  treSegments.Refresh;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FParser);
end;

procedure TfrmMain.Search(AText: String);
var
  RegEx: TRegEx;
  RegularSearch: Boolean;
  SearchText: String;

  procedure SetNodeVisible(ANode: PVirtualNode; AVisible: Boolean);
  var
    Segment: TSegment;
  begin
    Segment := treSegments.GetNodeData<TSegment>(ANode);
    Segment.Visible := AVisible;
    treSegments.IsVisible[ANode] := AVisible;
  end;

  function MatchesSearch(AText: String): Boolean;
  begin
    if SearchText = EmptyStr then
    begin
      Result := True;
    end else
    if RegularSearch then
    begin
      Result := RegEx.IsMatch(AText);
    end else
    begin
      Result := AText.ToLower.Contains(SearchText);
    end;
  end;

  procedure prcIterateSearch(const _node: PVirtualNode);
  var
    nodeChild:      PVirtualNode;
    bIsVisible:     Boolean;
  begin
    if SearchText = EmptyStr then
    begin
      SetNodeVisible(_node, True);
      if treSegments.HasChildren[_node] then
      begin
        nodeChild := treSegments.GetFirstChild(_node);
        while nodeChild <> nil do
        begin
          prcIterateSearch(nodeChild);
          nodeChild := treSegments.GetNextSibling(nodeChild);
        end;
        treSegments.Expanded[_node] := False;
      end;
    end else
    begin
      bIsVisible := False;
      if MatchesSearch(treSegments.Text[_node, 0]) then
      begin
        SetNodeVisible(_node, True);
        bIsVisible := True;
      end;
      if not bIsVisible then
      begin
        if treSegments.HasChildren[_node] then
        begin
          nodeChild := treSegments.GetFirstChild(_node);
          while nodeChild <> nil do
          begin
            prcIterateSearch(nodeChild);
            nodeChild := treSegments.GetNextSibling(nodeChild);
          end;
          treSegments.Expanded[_node] := AText <> EmptyStr;
          nodeChild := treSegments.GetFirstVisibleChild(_node);
          SetNodeVisible(_node, Assigned(nodeChild));
        end else
        begin
          SetNodeVisible(_node, False);
        end;
      end else
      begin
        if treSegments.HasChildren[_node] then
        begin
          treSegments.FullExpand(_node);
        end;
      end;
    end;
  end;

var
  node: PVirtualNode;
begin
  RegularSearch := chkSearchRegEx.Checked;
  SetErrorMessage(EmptyStr);
  if AText = EmptyStr then
  begin
    SearchText := EmptyStr;
  end else
  if RegularSearch then
  begin
    RegEx := TRegEx.Create(AText);
    try
      RegEx.IsMatch('Test');
    except
      on E: Exception do
      begin
        SetErrorMessage(E.Message);
        Exit;
      end;
    end;
    SearchText := AText;
  end else
  begin
    SearchText := AText.ToLower;
  end;
  treSegments.BeginUpdate;
  try
    node := treSegments.GetFirst;
    while node <> nil do
    begin
      prcIterateSearch(node);
      node := treSegments.GetNextSibling(node);
    end;
    if AText = EmptyStr then
    begin
      treSegments.Expanded[treSegments.GetFirst] := True;
    end;
  finally
    treSegments.EndUpdate;
  end;
end;

procedure TfrmMain.SetErrorMessage(const AMessage: String);
begin
  barStatus.Panels.Items[0].Text := AMessage;
end;

function TfrmMain.SizeAsKiB(ASize: UInt64): String;
begin
  if (ASize = 0)
  and FHideNullValues then
  begin
    Result := EmptyStr;
  end else
  begin
    if ASize >= 1024 then
    begin
      Result := (ASize div 1024).ToString + ' KiB';
    end else
    begin
      Result := ASize.ToString + ' Byte';
    end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FParser := TParser.Create;
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
begin
  if FileOpenDialog.Execute then
  begin
    treSegments.BeginUpdate;
    try
      treSegments.Clear;
      edtSearch.Text := EmptyStr;
      FParser.LoadFromFile(FileOpenDialog.FileName);
      treSegments.RootNodeCount := 1;
      treSegments.Refresh;
      treSegments.Header.AutoFitColumns(False);
    finally
      treSegments.EndUpdate;
    end;
  end;
end;

procedure TfrmMain.chkSearchRegExClick(Sender: TObject);
begin
  Search(edtSearch.Text);
end;

procedure TfrmMain.edtSearchChange(Sender: TObject);
begin
  Search(edtSearch.Text);
end;

procedure TfrmMain.treSegmentsCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex;
    var Result: Integer);
var
  Segment1: TSegment;
  Segment2: TSegment;
begin
  Segment1 := Sender.GetNodeData<TSegment>(Node1);
  Segment2 := Sender.GetNodeData<TSegment>(Node2);
  case Column of
    0:
      begin
        Result := CompareText(Segment1.Name, Segment2.Name);
      end;
    1:
      begin
        Result := Ord(Segment1.SegmentType) - Ord(Segment2.SegmentType);
      end;
    2:
      begin
        Result := Segment1.Size[sctCODE] - Segment2.Size[sctCODE];
      end;
    3:
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[sctCODE] - Segment2.SizeVisible[sctCODE];
        end else
        begin
          Result := Segment1.SizeSum[sctCODE] - Segment2.SizeSum[sctCODE];
        end;
      end;
    4:
      begin
        Result := Segment1.Size[sctICODE] - Segment2.Size[sctICODE];
      end;
    5:
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[sctICODE] - Segment2.SizeVisible[sctICODE];
        end else
        begin
          Result := Segment1.SizeSum[sctICODE] - Segment2.SizeSum[sctICODE];
        end;
      end;
    6:
      begin
        Result := Segment1.Size[sctDATA] - Segment2.Size[sctDATA];
      end;
    7:
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[sctDATA] - Segment2.SizeVisible[sctDATA];
        end else
        begin
          Result := Segment1.SizeSum[sctDATA] - Segment2.SizeSum[sctDATA];
        end;
      end;
    8:
      begin
        Result := Segment1.Size[sctBSS] - Segment2.Size[sctBSS];
      end;
    9:
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[sctBSS] - Segment2.SizeVisible[sctBSS];
        end else
        begin
          Result := Segment1.SizeSum[sctBSS] - Segment2.SizeSum[sctBSS];
        end;
      end;
    10:
      begin
        Result := Segment1.Size[sctTLS] - Segment2.Size[sctTLS];
      end;
    11:
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[sctTLS] - Segment2.SizeVisible[sctTLS];
        end else
        begin
          Result := Segment1.SizeSum[sctTLS] - Segment2.SizeSum[sctTLS];
        end;
      end;
    12:
      begin
        Result := Segment1.Size[sctPDATA] - Segment2.Size[sctPDATA];
      end;
    13:
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[sctPDATA] - Segment2.SizeVisible[sctPDATA];
        end else
        begin
          Result := Segment1.SizeSum[sctPDATA] - Segment2.SizeSum[sctPDATA];
        end;
      end;
  end;
end;

procedure TfrmMain.treSegmentsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var
    LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  Segment:  TSegment;
begin
  Segment := Sender.GetNodeData<TSegment>(Node);
  case Column of
    0:
      begin
        HintText := Segment.GetFullName;
      end;
    1:
      begin
        case Segment.SegmentType of
          stRoot:
            begin
              HintText := 'Root';
            end;
          stFile:
            begin
              HintText := 'File';
            end;
          stFunction:
            begin
              HintText := 'Function';
            end;
          stClass:
            begin
              HintText := 'Class';
            end;
        end;
      end;
    2:
      begin
        HintText := Segment.Size[sctCODE].ToString + ' Byte';
      end;
    3:
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[sctCODE].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[sctCODE].ToString + ' Byte';
        end;
      end;
    4:
      begin
        HintText := Segment.Size[sctICODE].ToString + ' Byte';
      end;
    5:
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[sctICODE].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[sctICODE].ToString + ' Byte';
        end;
      end;
    6:
      begin
        HintText := Segment.Size[sctDATA].ToString + ' Byte';
      end;
    7:
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[sctDATA].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[sctDATA].ToString + ' Byte';
        end;
      end;
    8:
      begin
        HintText := Segment.Size[sctBSS].ToString + ' Byte';
      end;
    9:
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[sctBSS].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[sctBSS].ToString + ' Byte';
        end;
      end;
    10:
      begin
        HintText := Segment.Size[sctTLS].ToString + ' Byte';
      end;
    11:
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[sctTLS].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[sctTLS].ToString + ' Byte';
        end;
      end;
    12:
      begin
        HintText := Segment.Size[sctPDATA].ToString + ' Byte';
      end;
    13:
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[sctPDATA].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[sctPDATA].ToString + ' Byte';
        end;
      end;
  end;
end;

procedure TfrmMain.treSegmentsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType:
    TVSTTextType; var CellText: string);
var
  Segment:  TSegment;
begin
  Segment := Sender.GetNodeData<TSegment>(Node);
  case Column of
    0:
      begin
        CellText := Segment.Name;
      end;
    1:
      begin
        case Segment.SegmentType of
          stRoot:
            begin
              CellText := 'Root';
            end;
          stFile:
            begin
              CellText := 'File';
            end;
          stFunction:
            begin
              CellText := 'Function';
            end;
          stClass:
            begin
              CellText := 'Class';
            end;
        end;
      end;
    2:
      begin
        CellText := SizeAsKiB(Segment.Size[sctCODE]);
      end;
    3:
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[sctCODE]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[sctCODE]);
        end;
      end;
    4:
      begin
        CellText := SizeAsKiB(Segment.Size[sctICODE]);
      end;
    5:
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[sctICODE]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[sctICODE]);
        end;
      end;
    6:
      begin
        CellText := SizeAsKiB(Segment.Size[sctDATA]);
      end;
    7:
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[sctDATA]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[sctDATA]);
        end;
      end;
    8:
      begin
        CellText := SizeAsKiB(Segment.Size[sctBSS]);
      end;
    9:
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[sctBSS]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[sctBSS]);
        end;
      end;
    10:
      begin
        CellText := SizeAsKiB(Segment.Size[sctTLS]);
      end;
    11:
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[sctTLS]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[sctTLS]);
        end;
      end;
    12:
      begin
        CellText := SizeAsKiB(Segment.Size[sctPDATA]);
      end;
    13:
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[sctPDATA]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[sctPDATA]);
        end;
      end;
  end;
end;

procedure TfrmMain.treSegmentsInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Segment:  TSegment;
begin
  Segment := Sender.GetNodeData<TSegment>(Node);
  if Segment <> nil then
  begin
    ChildCount := Segment.Count;
  end;
end;

procedure TfrmMain.treSegmentsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates:
    TVirtualNodeInitStates);
var
  Segment:  TSegment;
begin
  InitialStates := [];
  if ParentNode = nil then
  begin
    Segment := FParser.RootSegment;
    InitialStates := InitialStates + [ivsExpanded];
  end else
  begin
    Segment := Sender.GetNodeData<TSegment>(ParentNode).Items[Node.Index];
  end;
  if Segment.Count > 0 then
  begin
    InitialStates := InitialStates + [ivsHasChildren];
  end;
  Sender.SetNodeData<TSegment>(Node, Segment);
end;

end.
