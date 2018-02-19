object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Map Parser'
  ClientHeight = 741
  ClientWidth = 1038
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ActionMainMenuBar1: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 1038
    Height = 25
    UseSystemFont = False
    ActionManager = ActionManager
    Caption = 'ActionMainMenuBar1'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
  end
  object ActionToolBar1: TActionToolBar
    Left = 0
    Top = 25
    Width = 1038
    Height = 23
    ActionManager = ActionManager
    Caption = 'ActionToolBar1'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Spacing = 0
  end
  object treSegments: TVirtualStringTree
    Left = 0
    Top = 92
    Width = 1038
    Height = 630
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 31
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowHint, hoShowSortGlyphs, hoVisible, hoHeaderClickAutoSort]
    HintMode = hmHint
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnCompareNodes = treSegmentsCompareNodes
    OnGetText = treSegmentsGetText
    OnGetHint = treSegmentsGetHint
    OnInitChildren = treSegmentsInitChildren
    OnInitNode = treSegmentsInitNode
    Columns = <
      item
        Position = 0
        Width = 443
      end
      item
        MinWidth = 31
        Position = 1
        Width = 31
        WideText = 'Typ'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 49
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 2
        Width = 49
        WideText = 'Size (CODE)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 49
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 3
        Width = 49
        WideText = 'Sum (CODE)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 54
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 4
        Width = 54
        WideText = 'Size (ICODE)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 52
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 5
        Width = 52
        WideText = 'Sum (ICODE)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 50
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 6
        WideText = 'Size (DATA)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 47
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 7
        Width = 47
        WideText = 'Sum (DATA)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 39
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 8
        Width = 39
        WideText = 'Size (BSS)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 39
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 9
        Width = 39
        WideText = 'Sum (BSS)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 38
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 10
        Width = 38
        WideText = 'Size (TLS)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 37
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 11
        Width = 37
        WideText = 'Sum (TLS)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 53
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 12
        Width = 53
        WideText = 'Size (PDATA)'
      end
      item
        CaptionAlignment = taCenter
        MinWidth = 53
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coWrapCaption, coUseCaptionAlignment, coEditable]
        Position = 13
        Width = 53
        WideText = 'Sum (PDATA)'
      end>
  end
  object edtSearch: TEdit
    AlignWithMargins = True
    Left = 3
    Top = 48
    Width = 1032
    Height = 21
    Margins.Top = 0
    Align = alTop
    TabOrder = 3
    TextHint = 'Search...'
    OnChange = edtSearchChange
  end
  object chkSearchRegEx: TCheckBox
    AlignWithMargins = True
    Left = 3
    Top = 72
    Width = 1032
    Height = 17
    Margins.Top = 0
    Align = alTop
    Caption = 'Regular expression'
    TabOrder = 4
    OnClick = chkSearchRegExClick
  end
  object barStatus: TStatusBar
    Left = 0
    Top = 722
    Width = 1038
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object ActionManager: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Items = <
              item
                Action = actOpen
                Caption = '&Open'
              end>
            Caption = '&File'
          end
          item
            Items = <
              item
                Action = actCalcuateSumByVisible
                Caption = '&Calculate Sum by Visible'
              end
              item
                Action = actHideNullValues
                Caption = '&Hide null values'
              end>
            Caption = '&Options'
          end>
        ActionBar = ActionMainMenuBar1
      end
      item
        Items = <
          item
            Action = actOpen
            Caption = '&Open'
          end>
        ActionBar = ActionToolBar1
      end>
    Left = 64
    Top = 136
    StyleName = 'Platform Default'
    object actOpen: TAction
      Category = 'File'
      Caption = 'Open'
      OnExecute = actOpenExecute
    end
    object actCalcuateSumByVisible: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Calculate Sum by Visible'
      OnExecute = actCalcuateSumByVisibleExecute
    end
    object actHideNullValues: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Hide null values'
      OnExecute = actHideNullValuesExecute
    end
  end
  object FileOpenDialog: TFileOpenDialog
    DefaultExtension = '*.map'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Map'
        FileMask = '*.map'
      end>
    Options = []
    Left = 168
    Top = 136
  end
end
