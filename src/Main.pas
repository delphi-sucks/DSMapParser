unit Main;

interface

uses
  System.Classes,
  Vcl.Controls, Vcl.Dialogs, System.Actions, Vcl.ActnMan, Vcl.Forms, Vcl.ActnCtrls, Vcl.ImgList,
  Vcl.ToolWin, Vcl.ActnMenus, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  System.UITypes,
  VirtualTrees,
  Parser, System.ImageList, Vcl.Menus;

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
    FindDialog: TFindDialog;
    ImageList: TImageList;
    mnuSegments: TPopupMenu;
    mnuCopy: TMenuItem;
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
    procedure treSegmentsGetImageIndex(Sender: TBaseVirtualTree; Node:
        PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted:
        Boolean; var ImageIndex: TImageIndex);
    procedure treSegmentsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType:
        TVSTTextType; var CellText: string);
    procedure treSegmentsInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure treSegmentsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates:
        TVirtualNodeInitStates);
  strict private
    FCalculateSumByVisible: Boolean;
    FHideNullValues: Boolean;
    FParser: TParser;
    procedure InitHeaderColumns;
    procedure Search(AText: String);
    procedure SetErrorMessage(const AMessage: String);
    function SizeAsKiB(ASize: UInt64): String;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Winapi.Windows,
  System.SysUtils, System.RegularExpressions, System.Generics.Collections, System.Generics.Defaults, System.StrUtils,
  Segments, SegmentClass, Publics;

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

procedure TfrmMain.InitHeaderColumns;
var
  Column: TVirtualTreeColumn;
  MapClass: TMapClass;
  MapClasses: TList<TMapClass>;
begin
  with treSegments.Header.Columns do
  begin
    BeginUpdate;
    try
      Clear;
      // Text
      Add;

      // Typ
      Column := Add;
      Column.Text := 'Typ';

      MapClasses := TList<TMapClass>.Create;
      try
        for MapClass in FParser.MapClasses.Values do
        begin
          MapClasses.Add(MapClass);
        end;
        MapClasses.Sort(TComparer<TMapClass>.Construct(
          function(const Left, Right: TMapClass): Integer
          begin
            Result := Left.ID - Right.ID;
          end
        ));
        for MapClass in MapClasses do
        begin
          Column := Add;
          Column.CaptionAlignment := taCenter;
          Column.Text := 'Size (' + MapClass._ClassName + ')';
          Column.Tag := MapClass.ID;
          Column.Options := Column.Options + [coWrapCaption, coUseCaptionAlignment];

          Column := Add;
          Column.CaptionAlignment := taCenter;
          Column.Text := 'Sum (' + MapClass._ClassName + ')';
          Column.Tag := MapClass.ID;
          Column.Options := Column.Options + [coWrapCaption, coUseCaptionAlignment];
        end;
      finally
        FreeAndNil(MapClasses);
      end;
    finally
      EndUpdate;
    end;
  end;
  treSegments.Header.AutoSizeIndex := 0;
end;

procedure TfrmMain.Search(AText: String);
var
  RegEx: TRegEx;
  RegularSearch: Boolean;
  SearchText: String;

  procedure SetNodeVisible(ANode: PVirtualNode; AVisible: Boolean);
  var
    _Object: TObject;
  begin
    _Object := treSegments.GetNodeData<TObject>(ANode);
    if _Object is TSegment then
    begin
      (_Object as TSegment).Visible := AVisible;
    end;
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
      Result := ContainsText(AText, SearchText);
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
  end;
  SearchText := AText;
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
      InitHeaderColumns;


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
  _Object1: TObject;
  _Object2: TObject;
  Segment1: TSegment;
  Segment2: TSegment;
  _Public1: TPublic;
  _Public2: TPublic;
  ID: UInt8;
  Title: String;
begin
  if Column = -1 then
  begin
    Exit;
  end;
  _Object1 := Sender.GetNodeData<TObject>(Node1);
  _Object2 := Sender.GetNodeData<TObject>(Node2);
  if (_Object1 is TSegment)
  and (_Object2 is TPublic) then
  begin
    Result := 1;
    Exit;
  end;
  if (_Object1 is TPublic)
  and (_Object2 is TSegment) then
  begin
    Result := -1;
    Exit;
  end;
  if (_Object1 is TSegment)
  and (_Object2 is TSegment) then
  begin
    Segment1 := _Object1 as TSegment;
    Segment2 := _Object2 as TSegment;
    case Column of
      0:
        Result := CompareText(Segment1.Name, Segment2.Name);
      1:
        Result := Ord(Segment1.SegmentType) - Ord(Segment2.SegmentType);
    else
      ID := Sender.Header.Columns[Column].Tag;
      Title := Sender.Header.Columns[Column].Text;
      if Title.StartsWith('Sum') then
      begin
        if FCalculateSumByVisible then
        begin
          Result := Segment1.SizeVisible[ID] - Segment2.SizeVisible[ID];
        end else
        begin
          Result := Segment1.SizeSum[ID] - Segment2.SizeSum[ID];
        end;
      end else
      begin
        Result := Segment1.Size[ID] - Segment2.Size[ID];
      end;
    end;
    Exit;
  end;
  if (_Object1 is TPublic)
  and (_Object2 is TPublic) then
  begin
    _Public1 := _Object1 as TPublic;
    _Public2 := _Object2 as TPublic;
    Exit;
  end;
end;

procedure TfrmMain.treSegmentsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var
    LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  _Object: TObject;
  Segment: TSegment;
  _Public: TPublic;
  ID: UInt8;
  Title: String;
begin
  _Object := Sender.GetNodeData<TObject>(Node);
  if _Object is TSegment then
  begin
    Segment := _Object as TSegment;
    case Column of
      0:
        HintText := Segment.GetFullName;
      1:
        case Segment.SegmentType of
          stRoot:
            HintText := 'Root';
          stFile:
            HintText := 'File';
          stFunction:
            HintText := 'Function';
          stClass:
            HintText := 'Class';
        end;
    else
      ID := Sender.Header.Columns[Column].Tag;
      Title := Sender.Header.Columns[Column].Text;
      if Title.StartsWith('Sum') then
      begin
        if FCalculateSumByVisible then
        begin
          HintText := Segment.SizeVisible[ID].ToString + ' Byte';
        end else
        begin
          HintText := Segment.SizeSum[ID].ToString + ' Byte';
        end;
      end else
      begin
        HintText := Segment.Size[ID].ToString + ' Byte';
      end;
    end;
    Exit;
  end;
  if _Object is TPublic then
  begin
    _Public := _Object as TPublic;
    Exit;
  end;
end;

procedure TfrmMain.treSegmentsGetImageIndex(Sender: TBaseVirtualTree; Node:
    PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted:
    Boolean; var ImageIndex: TImageIndex);
var
  _Object: TObject;
  Segment: TSegment;
  _Public: TPublic;
begin
  if (Kind in [ikNormal, ikSelected])
  and (Column = 0) then
  begin
    _Object := Sender.GetNodeData<TObject>(Node);
    if _Object is TSegment then
    begin
      Segment := _Object as TSegment;
      case Segment.SegmentType of
        stFile:
          ImageIndex := 0;
        stClass:
          ImageIndex := 1;
      end;
      Exit;
    end;
    if _Object is TPublic then
    begin
      _Public := _Object as TPublic;
      Exit;
    end;
  end;
end;

procedure TfrmMain.treSegmentsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType:
    TVSTTextType; var CellText: string);
var
  _Object: TObject;
  Segment: TSegment;
  _Public: TPublic;
  ID: UInt8;
  Title: String;
begin
  _Object := Sender.GetNodeData<TObject>(Node);
  if _Object is TSegment then
  begin
    Segment := _Object as TSegment;
    case Column of
      0:
        CellText := Segment.Name;
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
    else
      ID := Sender.Header.Columns[Column].Tag;
      Title := Sender.Header.Columns[Column].Text;
      if Title.StartsWith('Sum') then
      begin
        if FCalculateSumByVisible then
        begin
          CellText := SizeAsKiB(Segment.SizeVisible[ID]);
        end else
        begin
          CellText := SizeAsKiB(Segment.SizeSum[ID]);
        end;
      end else
      begin
        CellText := SizeAsKiB(Segment.Size[ID]);
      end;
    end;
    Exit;
  end;
  if _Object is TPublic then
  begin
    _Public := _Object as TPublic;
    case Column of
      0:
        CellText := _Public.Name;
    end;
    Exit;
  end;
end;

procedure TfrmMain.treSegmentsInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Segment:  TSegment;
begin
  Segment := Sender.GetNodeData<TSegment>(Node);
  if Segment <> nil then
  begin
    ChildCount := Segment.Count + Segment.Publics.Count;
  end;
end;

procedure TfrmMain.treSegmentsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates:
    TVirtualNodeInitStates);
var
  Segment: TSegment;
  _Public: TPublic;
  ParentSegment: TSegment;
begin
  InitialStates := [];
  if ParentNode = nil then
  begin
    Segment := FParser.RootSegment;
    InitialStates := InitialStates + [ivsExpanded];
  end else
  begin
    ParentSegment := Sender.GetNodeData<TSegment>(ParentNode);
    if Node.Index < ParentSegment.Count then
    begin
      Segment := ParentSegment.Items[Node.Index];
    end else
    begin
      _Public := ParentSegment.Publics.Items[Node.Index - ParentSegment.Count];
      Sender.SetNodeData<TPublic>(Node, _Public);
      Exit;
    end;
  end;
  if Segment <> nil then
  begin
    if (Segment.Count > 0)
    or (Segment.Publics.Count > 0) then
    begin
      InitialStates := InitialStates + [ivsHasChildren];
    end;
    Sender.SetNodeData<TSegment>(Node, Segment);
  end;
end;

end.
