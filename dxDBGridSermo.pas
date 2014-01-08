unit dxDBGridSermo;

{	Historique Versions :
	22/07/2003 : DF
		Ajout des propriétés XLSDialog :
			Lors de l'export Excel, si XLSFileName est renseigné et XLSDialog = False,
			supprime le dialogue de saisie du nom du fichier Excel.

	09/04/2004 : DF
		Ajout des évènements OnBeforeExcel et OnAfterExcel
}

{	Utilisation :
	Renseigner les propriétés PrintTitle (Titre de l'impression) et
	XLSFileName (Nom du fichier d'export vers Excel)
	Le PopupMenu assigné en conception sera associé au PopupMenu Standard :
}

interface

uses
	Windows, Messages, SysUtils, Classes, Controls, Graphics, Menus, Dialogs,
	Variants, Forms, ShellAPI, DB, DBClient, Clipbrd,
	dxCntner, dxTL, dxDBCtrl, dxDBGrid, dxPSCore, dxPSdxDBGrLnk,JclMime,dxPrnDev;

type
	TCanPasteEvent = procedure(Sender: TObject; var Allow: Boolean;var KeyFieldName:String) of object;

	TCanPasteFieldEvent=function(AFieldName:String):Boolean of Object;
	TCanPasteEditRecordEvent=function(var Keyvalue:String):Boolean of Object;

	//La fonction doit renvoyer le nom de champs correspondant à l'entête de colonne
	TFieldsMappingEvent=function(AColumnName:String):String of Object;


	TdxDBGridSermo = class(TdxDBGrid)
	private
		FTextToFind: String;
		FColumnToFind: Integer;
		FOnBeforePrint: TNotifyEvent;
		FPrintTitle: String;
		FXLSFileName: TFileName;
		FOnCopy: TNotifyEvent;
		FOnPaste: TNotifyEvent;
		FOnCut: TNotifyEvent;
		FOnCanPaste: TCanPasteEvent;
		FOnCancelling: Boolean;
		FXLSDialog: Boolean;
		FXLSCurrentFile: TFileName;
    FOnAfterExcel: TNotifyEvent;
    FOnBeforeExcel: TNotifyEvent;
		FOnAfterPrint: TNotifyEvent;
    FStandardDraw: Boolean;
		FOnRevertRecord: TNotifyEvent;
		FOnUndoLastChange: TNotifyEvent;
    FOnCanPasteEditRecord: TCanPasteEditRecordEvent;
    FOnCanPasteField: TCanPasteFieldEvent;
    FOnGetPasteFieldName: TFieldsMappingEvent;
    FPasteKeyFieldName:String;
		procedure SetColumnToFind(const Value: Integer);
		procedure SetOnBeforePrint(const Value: TNotifyEvent);
		procedure SetPrintTitle(const Value: String);
		procedure SetXLSFileName(const Value: TFileName);
		procedure SetOnCopy(const Value: TNotifyEvent);
		procedure SetOnCut(const Value: TNotifyEvent);
		procedure SetOnPaste(const Value: TNotifyEvent);
		procedure SetOnCanPaste(const Value: TCanPasteEvent);
		procedure SetOnCancelling(const Value: Boolean);
		procedure SetXLSDialog(const Value: Boolean);
		procedure SetXLSCurrentFile(const Value: TFileName);
		procedure ReplaceDialog1Replace(Sender: TObject);
		procedure SetOnAfterExcel(const Value: TNotifyEvent);
		procedure SetOnBeforeExcel(const Value: TNotifyEvent);
		procedure SetOnAfterPrint(const Value: TNotifyEvent);
		procedure SetStandardDraw(const Value: Boolean);
		procedure SetOnRevertRecord(const Value: TNotifyEvent);
		procedure SetOnUndoLastChange(const Value: TNotifyEvent);
    procedure SetOnCanPasteEditRecord(
      const Value: TCanPasteEditRecordEvent);
    procedure SetOnCanPasteField(const Value: TCanPasteFieldEvent);
    procedure SetOnGetPasteFieldName(const Value: TFieldsMappingEvent);
		{ Déclarations privées }
	protected
		{ Déclarations protégées }
		InitSearch: Boolean;
		MenuFilled: Boolean;
		OnCustomPopup: TNotifyEvent;
		OnCustomEndColCust: TNotifyEvent;

		procedure FillMenu(LocalMenu: TPopupMenu);
		procedure OnPopup(Sender: TObject);
		procedure DoEndColumsCustomizing(Sender: TObject);

		procedure DoEnter; override;
		procedure DoDrawCell(ACanvas: TCanvas; var ARect: TRect; ANode: TdxTreeListNode; AIndex: Integer; ASelected, AFocused: Boolean;
			ANewItemRow: Boolean; ALeftEdge, ARightEdge: Boolean; ABrush: HBRUSH;
			var AText: string; var AColor: TColor; AFont: TFont; var AAlignment: TAlignment; var ADone: Boolean); override;

		function DoFindLast:Boolean;
		function DoFindFirst:Boolean;
		function DoFindNext:Boolean;
		function DoFindPrior:Boolean;

		function CurrentMatch(CurrentNode: TdxTreeListNode):Boolean;
		property XLSCurrentFile: TFileName read FXLSCurrentFile write SetXLSCurrentFile;

    function CanEditAcceptKey(Key: Char): Boolean; override;

	public
		{ Déclarations publiques }
		FindDlg: TFindDialog;
		ReplaceDialog:TReplaceDialog;

		ComponentPrinter: TdxComponentPrinter;
		GridReport: TdxDBGridReportLink;
		HMUndo, HMRevert: HMENU;
		HMFind, HMFindNext, HMReplace: HMENU;
		HMCut, HMCopy, HMPast,HMFindReplace: HMENU;
		HMInsert, HMDelete, HMSelAll: HMENU;
		HMExcel, HMPrint: HMENU;
		HMCollAll, HMExpAll: HMENU;
		HMCustomize: HMENU;

		constructor Create(AOwner:TComponent); override;
		destructor Destroy; override;

		procedure FindText(Sender:TObject);
		procedure FindNext(Sender:TObject);
		procedure FindReplace(Sender:TObject);

		function DoFindText(Txt:String): boolean;
		procedure FindDlgFind(Sender: TObject);

    procedure CopySelectedRecordsToClipboard;
    procedure PasteClipBoardToDataset;

		procedure UndoLastUpdate(Sender: TObject);
		procedure RevertRecord(Sender: TObject);
		Procedure Print(Sender: TObject);
		Procedure ExportExcel(Sender: TObject);
		Procedure CopyToClipBoard(Sender: TObject);
		Procedure CutToClipBoard(Sender: TObject);
		Procedure DeleteRows(Sender: TObject);
		Procedure Paste(Sender: TObject);
		Procedure SelectAllRows(Sender: TObject);
		Procedure CustomizeColumns(Sender: TObject);
		Procedure ExpandAll(Sender: TObject);
		Procedure CollapseAll(Sender: TObject);


		property ColumnToFind: Integer read FColumnToFind write SetColumnToFind;
		property TextToFind: String read FTextToFind write FTextToFind;



	published
		{ Déclarations publiées }
		property XLSFileName: TFileName read FXLSFileName write SetXLSFileName;
		property XLSDialog: Boolean read FXLSDialog write SetXLSDialog;
		property PrintTitle: String read FPrintTitle write SetPrintTitle;
		property StandardDraw: Boolean read FStandardDraw write SetStandardDraw;
		property OnBeforePrint: TNotifyEvent read FOnBeforePrint write SetOnBeforePrint;
		property OnAfterPrint: TNotifyEvent read FOnAfterPrint write SetOnAfterPrint;
		property OnBeforeExcel: TNotifyEvent read FOnBeforeExcel write SetOnBeforeExcel;
		property OnAfterExcel: TNotifyEvent read FOnAfterExcel write SetOnAfterExcel;
		property OnCopy: TNotifyEvent read FOnCopy write SetOnCopy;
		property OnCut: TNotifyEvent read FOnCut write SetOnCut;
		property OnPaste: TNotifyEvent read FOnPaste write SetOnPaste;
		property OnCanPaste: TCanPasteEvent read FOnCanPaste write SetOnCanPaste;
		property OnCancelling: Boolean read FOnCancelling write SetOnCancelling;
		property OnRevertRecord: TNotifyEvent read FOnRevertRecord write SetOnRevertRecord;
		property OnUndoLastChange: TNotifyEvent read FOnUndoLastChange write SetOnUndoLastChange;
    //Gestion paste clipboard

    property OnCanPasteField:TCanPasteFieldEvent read FOnCanPasteField write SetOnCanPasteField;
    property OnCanPasteEditRecord:TCanPasteEditRecordEvent read FOnCanPasteEditRecord write SetOnCanPasteEditRecord;
    property OnGetPasteFieldName:TFieldsMappingEvent read FOnGetPasteFieldName write SetOnGetPasteFieldName;
	end;

procedure Register;

ResourceString
	GSConst_NoRecordFind = 'No record found';
	GSConst_PrintOn='Printed on';
	GSConst_Page='Page';

	GSConst_Confirmation='Confirmation';
	GSConst_UndoLastUpdate='Undo the last modification';
	GSConst_RevertRecord='Undo row modifications';
	GSConst_Find='Search...';
//	rsFind='Find...';
	GSConst_FindNext='Find next';
//	rsFindNext='Find next';
	GSConst_FindReplace='Replace...';
//	rsFindReplace='Replace...';
	GSConst_Copy='Copy';
//	rsCopy='Copy';
	GSConst_Cut='Cut';
//	rsCut='Cut';
	GSConst_Paste='Paste';
//	rsPaste='Paste';
	GSConst_Insert='Insert';
	GSConst_Delete='Delete';
	GSConst_DeleteRows='Delete rows';
	GSConst_ConfDeleteRow='Delete rows ?';
//	rsDeleteRows='Delete rows';
	GSConst_SelectAll='Select all';
//	rsSelectAll='Select all';
	GSConst_ExportExcel='Export to Excel file...';
//	rsExportExcel='Export to Excel file...';
	GSConst_Print='Print...';
//	rsPrint='Print...';
	GSConst_ExpandAll='Expand all';
//	rsExpandAll='Expand all';
	GSConst_CollapseAll='Collapse alle';
//	rsCollapseAll='Collapse all';
	GSConst_CustomizeColumns='Customize columns';
//	rsCustomizeColumns='Customize columns';

	rsKeyFieldNotInClipboard='The key field "%s" doesn''t exist in the clipboard'#13+
			'The data can not be pasted';

var
  CF_SISTablename:Word;

procedure ClipboardSetTableContent(Tablename,CSV:String);
function ClipboardGetTablename: String;

type
	//La fonction doit renvoyer vrai si le champ peut être "pasté"
	TCanPasteFunction=function(AFieldName:String):Boolean;
	TCanEditRecord=function(Dataset:TDataset;var Keyvalue:String):Boolean;



implementation

procedure Register;
begin
	RegisterComponents('Dev Express', [TdxDBGridSermo]);
end;

{ TdxDBGridSermo }

constructor TdxDBGridSermo.Create(AOwner: TComponent);
begin
	inherited;

	SimpleCustomizeBox := True;
  CustomizingRowCount:=25;
	MenuFilled := False;

	if (csDesigning in Self.ComponentState) then
	begin
		// Default options for the grid
		LookAndFeel := lfFlat;

		OptionsBehavior := OptionsBehavior + [edgoAutoSort, edgoMultiSort, edgoTabs] - [edgoImmediateEditor];
		OptionsDB := [edgoCanAppend,edgoCanInsert,edgoCanDelete, edgoCancelOnExit, edgoCanNavigation, edgoConfirmDelete, edgoLoadAllRecords, edgoUseBookmarks];
		OptionsView := OptionsView +[edgoIndicator];
		Options := Options + [egoTabs];

    FStandardDraw := False;
	end;

	// Initialisation de la boite de dialogue de recherche
	FindDlg := TFindDialog.Create(Nil);
	FindDlg.OnFind := FindDlgFind;
	FindDlg.Options := FindDlg.Options + [frHideMatchCase];

	FXLSDialog := True;

	OnCancelling := False;
end;

destructor TdxDBGridSermo.Destroy;
begin
	FindDlg.Free;
	FindDlg := Nil;

	GridReport.Free;
	GridReport := Nil;

	ComponentPrinter.Free;
	ComponentPrinter := nil;

	if ReplaceDialog<>Nil then
		FreeAndNil(ReplaceDIalog);

	inherited;
end;

function TdxDBGridSermo.CurrentMatch(CurrentNode: TdxTreeListNode): Boolean;
var
	i: integer;
	vColValue : Variant;
begin
	Result := False;
	if (ColumnToFind > -1) then
	begin
		vColValue := CurrentNode.Values[VisibleColumns[ColumnToFind].Index];
		if not (frWholeWord in FindDlg.Options) then
			Result := (not VarIsNull(vColValue)) and (Pos(AnsiUppercase(TextToFind), AnsiUppercase(VarToStr(vColValue))) <> 0)
		else
			Result := (not VarIsNull(vColValue)) and (AnsiUppercase(TextToFind) = AnsiUppercase(VarToStr(vColValue)));
	end
	else
	begin
		for i := 0 to VisibleColumnCount-1 do
		begin
			vColValue := CurrentNode.Values[VisibleColumns[i].Index];
			if not (frWholeWord in FindDlg.Options) then
				Result := (not VarIsNull(vColValue)) and (Pos(AnsiUppercase(TextToFind),AnsiUppercase(VarToStr(vColValue))) <> 0)
			else
				Result := (not VarIsNull(vColValue)) and (AnsiUppercase(TextToFind) = AnsiUppercase(VarToStr(vColValue)));
			if Result then break;
		end;
	end;
end;

procedure TdxDBGridSermo.DoEnter;
begin
	inherited;

	if (PopupMenu = Nil) then
		PopupMenu := TPopupMenu.Create(Self);

	FillMenu(PopupMenu);
end;

function TdxDBGridSermo.DoFindFirst: Boolean;
begin
	InitSearch := True;
	Result := DoFindNext;
	if not Result then
		ShowMessage(GSConst_NoRecordFind);
end;

function TdxDBGridSermo.DoFindLast: Boolean;
begin
	InitSearch := True;
	Result := DoFindPrior;
	if not Result then
		ShowMessage(GSConst_NoRecordFind);
end;

function TdxDBGridSermo.DoFindNext: Boolean;
var
	SaveNode, CurrentNode: TdxTreeListNode;
	Trouve: Boolean;
begin
	Trouve := False;
	SaveNode := FocusedNode;
	try
		if InitSearch then
		begin
			GotoFirst;
			CurrentNode := FocusedNode;
		end
		else
			CurrentNode := FocusedNode.GetNext;

		While not ((CurrentNode = nil) or Trouve) do
		begin
			Trouve := CurrentMatch(CurrentNode);
			if not Trouve then
				CurrentNode := CurrentNode.GetNext;
		end;

		Result := Trouve;

		if Trouve then
		begin
			CurrentNode.Focused := True;
			InitSearch:=False;
		end
		else
			SaveNode.Focused := True;
	finally
	end;
end;

function TdxDBGridSermo.DoFindPrior: Boolean;
var
	SaveNode, CurrentNode: TdxTreeListNode;
	Trouve: Boolean;
begin
	Trouve := False;
	SaveNode := FocusedNode;
	try
		if InitSearch then
		begin
			GotoLast(False);
			CurrentNode := FocusedNode;
		end
		else
			CurrentNode := FocusedNode.GetPrev;

		While not ((CurrentNode = nil) or Trouve) do
		begin
			Trouve := CurrentMatch(CurrentNode);
			if not Trouve then
				CurrentNode := CurrentNode.GetPrev;
		end;

		Result := Trouve;

		if Trouve then
		begin
			CurrentNode.Focused := True;
			InitSearch:=False;
		end
		else
			SaveNode.Focused := True;
	finally
	end;
end;

function TdxDBGridSermo.DoFindText(Txt: String): boolean;
begin
	InitSearch := True;
	TextToFind := Txt;
	Result := DoFindNext;
end;

procedure TdxDBGridSermo.FillMenu(LocalMenu: TPopupMenu);

	function AddItem(ACaption:String;AShortcut:TShortCut;AEvent:TNotifyEvent): HMENU;
	var
		AMI: TMenuItem;
	begin
//		if (AShortCut = 0) or (PopupMenu.FindItem(AShortcut, fkShortCut) = nil) then
		begin
			AMI := TMenuItem.Create(LocalMenu);
			with AMI do
			begin
				Caption := ACaption;
				ShortCut := AShortcut;
				OnClick := AEvent;
			end;
			LocalMenu.Items.Add(AMI);
			Result := AMI.Handle;
		end
{		else
		try
			Result := PopupMenu.FindItem(AShortcut, fkShortCut).Handle;
		except
			Result := 0;
		end;}
	end;

begin
	if not MenuFilled then
	try
		if Assigned(LocalMenu.OnPopup) then
			OnCustomPopup := LocalMenu.OnPopup;
		LocalMenu.OnPopup := OnPopup;

		if (LocalMenu.Items.Count > 0) then
			AddItem('-', 0, nil);

		if (HMUndo = 0) then
			HMUndo := AddItem(GSConst_UndoLastUpdate, ShortCut(ord('Z'), [ssCtrl]), UndoLastUpdate);
		if (HMRevert = 0) then
			HMRevert := AddItem(GSConst_RevertRecord, 0, RevertRecord);
		AddItem('-', 0, nil);
		HMFind := AddItem(GSConst_Find, ShortCut(ord('F'), [ssCtrl]), FindText);
		HMFindNext := AddItem(GSConst_FindNext, VK_F3, FindNext);
		HMFindReplace := AddItem(GSConst_FindReplace, ShortCut(ord('H'), [ssCtrl]), FindReplace);
//		HMReplace := AddItem(GSConst_FindReplace, ShortCut(ord('H'), [ssCtrl]), FindReplace);
		AddItem('-', 0, nil);
		HMCut := AddItem(GSConst_Cut, ShortCut(ord('X'),[ssCtrl]), CutToClipBoard);
		HMCopy := AddItem(GSConst_Copy, ShortCut(ord('C'),[ssCtrl]), CopyToClipBoard);
		HMPast := AddItem(GSConst_Paste, ShortCut(ord('V'),[ssCtrl]), Paste);
		AddItem('-', 0, nil);
//		if edgoCanInsert in OptionsDB then
//			HMInsert := AddItem(GSConst_Insert, ShortCut(VK_INSERT,[]), InsertRow);
		if (edgoCanDelete in OptionsDB) then
			HMDelete := AddItem(GSConst_Delete, ShortCut(VK_DELETE,[ssCtrl]), DeleteRows);
		if edgoMultiselect in OptionsBehavior then
			HMSelAll := AddItem(GSConst_SelectAll, ShortCut(ord('A'),[ssCtrl]), SelectAllRows);
		AddItem('-', 0, nil);
		HMExcel := AddItem(GSConst_ExportExcel, 0, ExportExcel);
		if (HMPrint = 0) then
			HMPrint := AddItem(GSConst_Print, ShortCut(ord('P'),[ssCtrl]), Print);
		AddItem('-', 0, nil);
		HMExpAll := AddItem(GSConst_ExpandAll, Shortcut(ord('E'),[ssCtrl,ssShift]), ExpandAll);
		HMCollAll := AddItem(GSConst_CollapseAll, Shortcut(ord('R'),[ssCtrl,ssShift]), CollapseAll);
		AddItem('-', 0, nil);
		HMCustomize := AddItem(GSConst_CustomizeColumns, 0, CustomizeColumns);
	finally
    MenuFilled := True;
	end;
end;

procedure TdxDBGridSermo.FindNext(Sender: TObject);
begin
	if (FindDlg.FindText = '') then
		FindDlg.Execute
	else
	begin
		try
			TextToFind := FindDlg.FindText;
			if frDown in FindDlg.Options then
			begin
				if not DoFindNext then
					ShowMessage(GSConst_NoRecordFind);
			end
			else
				if not DoFindPrior then
					ShowMessage(GSConst_NoRecordFind);
		finally
		end;
	end;
end;

procedure TdxDBGridSermo.FindDlgFind(Sender: TObject);
begin
	if (FindDlg.FindText <> TextToFind) then
	begin
		if egoRowSelect in Options then
			ColumnToFind := -1
		else
			ColumnToFind := FocusedColumn;

		TextToFind := FindDlg.FindText;
		if frDown in FindDlg.Options then
		begin
			if DoFindFirst then
				FindDlg.CloseDialog;
		end
		else
			if DoFindLast then
				FindDlg.CloseDialog;
	end
	else
		if frDown in FindDlg.Options then
		begin
			if not DoFindNext then ShowMessage(GSConst_NoRecordFind);
		end
		else
			if not DoFindPrior then ShowMessage(GSConst_NoRecordFind)
end;

procedure TdxDBGridSermo.FindText(Sender: TObject);
begin
	FindDlg.Execute;
	TextToFind:='';
end;

procedure TdxDBGridSermo.SetColumnToFind(const Value: Integer);
begin
  FColumnToFind := Value;
end;

procedure TdxDBGridSermo.FindReplace(Sender: TObject);
begin
	if ReplaceDialog=Nil then
		ReplaceDialog:=TReplaceDialog.Create(Self);
	try
		ReplaceDialog.Options := [frDown, frDisableUpDown, frReplace, frReplaceAll];
		ReplaceDialog.OnReplace := ReplaceDialog1Replace;
		if InplaceEditor<>Nil then
			ReplaceDialog.FindText:=InplaceEditor.GetEditingText;
		ReplaceDialog.Execute;
	finally
	end;
end;

procedure TdxDBGridSermo.CollapseAll(Sender: TObject);
begin
	FullCollapse;
end;

procedure TdxDBGridSermo.CopyToClipBoard(Sender: TObject);
begin
	if (State=tsEditing) and (InplaceEditor<>Nil) then
		SendMessage(InplaceEditor.Handle,WM_COPY,0,0)
	else
	if (EditingText <> '') then
		Clipboard.AsText := EditingText
	else
		if Assigned(OnCopy) then
			OnCopy(Sender)
		else
			CopySelectedRecordsToClipboard;
end;

procedure TdxDBGridSermo.CustomizeColumns(Sender: TObject);
var
	miCustom: TMenuItem;
begin
	miCustom := PopupMenu.FindItem(HMCustomize, fkHandle);
	if miCustom <> nil then
	try
		miCustom.Checked := not miCustom.Checked;

		if miCustom.Checked then
		begin
			if Assigned(OnEndColumnsCustomizing) then
				OnCustomEndColCust := OnEndColumnsCustomizing;

			OnEndColumnsCustomizing := DoEndColumsCustomizing;

			ColumnsCustomizing;
		end
		else
			EndColumnsCustomizing;
	except
	end;
end;

procedure TdxDBGridSermo.CutToClipBoard(Sender: TObject);
begin
	if (State=tsEditing) and (InplaceEditor<>Nil) then
		SendMessage(InplaceEditor.Handle,WM_CUT,0,0)
	else
	if (EditingText <> '') then
  begin
		Clipboard.AsText := EditingText;
    EditingText:='';
  end
	else
		if Assigned(OnCut) then
			OnCut(Sender)
		else
    begin
			CopySelectedRecordsToClipboard;
      DeleteSelection;
    end;
end;

procedure TdxDBGridSermo.DeleteRows(Sender: TObject);
begin
	if (edgoCanDelete in OptionsDB) then
		if (edgoMultiSelect in OptionsBehavior) and (BkmList.Count > 1) then
		begin
			if (not (edgoConfirmDelete in OptionsDB)) or
				(Application.MessageBox(PChar(GSConst_DeleteRows),PChar(GSConst_Confirmation),
				MB_YESNO+MB_ICONQUESTION+MB_APPLMODAL) = mrYes) then
				DeleteSelection;
		end
		else
			if (FocusedNode <> nil) then
				if (not (edgoConfirmDelete in OptionsDB)) or
				(Application.MessageBox(PChar(GSConst_ConfDeleteRow),PChar(GSConst_Confirmation),
				MB_YESNO+MB_ICONQUESTION+MB_APPLMODAL) = mrYes) then
					TdxDBGridNode(FocusedNode).Delete;
end;

procedure TdxDBGridSermo.ExpandAll(Sender: TObject);
begin
	FullExpand;
end;

procedure TdxDBGridSermo.ExportExcel(Sender: TObject);
var
	SD:TSaveDialog;
	oShowHeader : Boolean;

  function sanitize(st:string):string;
  var
    i:integer;
  begin
    Result:='';
    for i:=1 to length(st) do
      if upcase(st[i]) in ['A'..'Z','_','-','.'] then
        Result:=Result+st[i];
  end;

begin
	if Assigned(FOnBeforeExcel) then
		FOnBeforeExcel(Sender);

	if (FXLSFileName = '') or FXLSDialog then
	begin
		SD := TSaveDialog.Create(Nil);
		oShowHeader := Self.ShowHeader;
		try
			Self.ShowHeader := True;
			SD.Filter := 'Excel files|*.xls';
			SD.DefaultExt := 'xls';

			if (FXLSCurrentFile <> '') then
				SD.FileName := FXLSCurrentFile
			else
			if (FXLSFileName <> '') then
				SD.FileName := FXLSFileName
			else
			if (Owner <> Nil) and (Owner is TForm) then
				SD.FileName := sanitize(TForm(Owner).Caption);

			if SD.Execute then
				XLSCurrentFile := SD.FileName
			else
				Exit;
		finally
			Self.ShowHeader := oShowHeader;
			SD.Free;
		end;
	end
	else
		XLSCurrentFile := FXLSFileName;

	try
		oShowHeader := Self.ShowHeader;
		Self.ShowHeader := True;

		SaveToXLS(FXLSCurrentFile, True);
		ShellExecute(Handle,Nil,Pchar(FXLSCurrentFile),Nil,Nil,0);
	finally
		Self.ShowHeader := oShowHeader;
	end;

	if Assigned(FOnAfterExcel) then
		FOnAfterExcel(Sender);
end;

function GridCanEdit(Dataset:TDataset;var Keyvalue:String):Boolean;
begin
  if (Dataset.FieldByName('etat').AsInteger<>0) then
  begin
    //Force l'ajout au lieu de l'édition
    Result:=False;
    //Modification de la clé
    Keyvalue:='Z'+KeyValue;
  end
  else
    Result:=True;
end;

procedure TdxDBGridSermo.Paste(Sender: TObject);
begin
	if (State=tsEditing) and (InplaceEditor<>Nil) then
		SendMessage(InplaceEditor.Handle,WM_PASTE,0,0)
	else
	if Assigned(OnPaste) then
		OnPaste(Sender)
	else
	if (Clipboard.AsText <> '') and (State = tsEditing) then
		EditingText := ClipBoard.AsText
  else
    //Par défaut
    PasteClipBoardToDataset;
end;

procedure TdxDBGridSermo.Print(Sender: TObject);
begin
	if (GridReport = nil) then
	begin
		ComponentPrinter := TdxComponentPrinter.Create(Self);
		GridReport := TdxDBGridReportLink.Create(Self);

		GridReport.Component := Self;
		GridReport.ComponentPrinter := ComponentPrinter;
		ComponentPrinter.AddLink(GridReport);

		GridReport.PrinterPage.PageFooter.CenterTitle.Clear;
		GridReport.PrinterPage.PageFooter.CenterTitle.Add(GSConst_Page+' [Page #]/[Total Pages]');
		GridReport.PrinterPage.PageFooter.RightTitle.Clear;
		GridReport.PrinterPage.PageFooter.RightTitle.Add(GSConst_PrintOn+' [Date & Time Printed]');
    GridReport.PrinterPage.Orientation := poLandscape;

    //Pour copieur couleur...
    GridReport.PrinterPage.GrayShading:=True;
	end;

	// La personnalisation de l'impression est à faire dans l'événement BeforePrint de la grille
	if Assigned(FOnBeforePrint) then
		FOnBeforePrint(Sender);

	if (PrintTitle <> '') then
  begin
    GridReport.PrinterPage.PageHeader.CenterTitle.Clear;
	  if (PrintTitle <> '') then
		  GridReport.PrinterPage.PageHeader.CenterTitle.Add(PrintTitle);
  end;

	GridReport.Preview(True);

	if Assigned(FOnAfterPrint) then
		FOnAfterPrint(Sender);
end;

procedure TdxDBGridSermo.SelectAllRows(Sender: TObject);
begin
	SelectAll;
end;

procedure TdxDBGridSermo.OnPopup(Sender: TObject);
var
	IsCDS,AllowPaste: Boolean;
begin
	// Appel de l'événement OnPopup du menu initial
	if Assigned(OnCustomPopup) then
		OnCustomPopup(Sender);

	IsCDS := (DataSource <> nil) and  (DataSource.DataSet <> nil) and
		(DataSource.DataSet is TCustomClientDataSet);
	if (HMUndo > 0) then
		PopupMenu.FindItem(HMUndo, fkHandle).Enabled := IsCDS and
			TCustomClientDataSet(DataSource.DataSet).Active and
			(TCustomClientDataSet(DataSource.DataSet).ChangeCount > 0);
	if (HMRevert > 0) then
		PopupMenu.FindItem(HMRevert, fkHandle).Enabled := IsCDS and
			TCustomClientDataSet(DataSource.DataSet).Active and
			(TCustomClientDataSet(DataSource.DataSet).UpdateStatus <> usUnmodified);

	if (HMCopy > 0) then
		PopupMenu.FindItem(HMCopy, fkHandle).Enabled := (RowCount > 0);
	if (HMCut > 0) then
		PopupMenu.FindItem(HMCut, fkHandle).Enabled := (RowCount > 0);
	if (HMPast > 0) then
			With PopupMenu.FindItem(HMPast, fkHandle) do
			begin
				AllowPaste:=True;
				if Assigned(OnCanPaste) then
					OnCanPaste(Self,AllowPaste,FPasteKeyFieldName);
				Enabled := ((Clipboard.AsText <> '') or Assigned(OnPaste) ) and AllowPaste;
			end;

	if (HMDelete > 0) then
		if (edgoMultiSelect in OptionsBehavior) and (BkmList.Count > 1) then
		begin
			PopupMenu.FindItem(HMDelete, fkHandle).Caption := GSConst_DeleteRows;
			PopupMenu.FindItem(HMDelete, fkHandle).Enabled := True;
		end
		else
		begin
			PopupMenu.FindItem(HMDelete, fkHandle).Caption := GSConst_Delete;
			PopupMenu.FindItem(HMDelete, fkHandle).Enabled := (FocusedNode <> nil);
		end;

	if (HMCollAll > 0) then
		PopupMenu.FindItem(HMCollAll, fkHandle).Enabled := (GroupColumnCount > 0);
	if (HMExpAll > 0) then
		PopupMenu.FindItem(HMExpAll, fkHandle).Enabled := (GroupColumnCount > 0);

	if (HMCustomize > 0) then
		PopupMenu.FindItem(HMCustomize, fkHandle).Visible := (edgoColumnMoving in OptionsCustomize);
end;

procedure TdxDBGridSermo.SetOnBeforePrint(const Value: TNotifyEvent);
begin
	FOnBeforePrint := Value;
end;

procedure TdxDBGridSermo.SetPrintTitle(const Value: String);
begin
	FPrintTitle := Value;
end;

procedure TdxDBGridSermo.RevertRecord(Sender: TObject);
begin
	try
		OnCancelling := True;
		if Assigned(OnRevertRecord) then
			OnRevertRecord(Sender)
		else
			TCustomClientDataSet(DataSource.DataSet).RevertRecord;
	finally
		OnCancelling := False;
	end;
end;

procedure TdxDBGridSermo.UndoLastUpdate(Sender: TObject);
begin
	try
		OnCancelling := True;
		if Assigned(OnUndoLastChange) then
			OnUndoLastChange(Sender)
		else
		begin
			if edgoMultiselect in OptionsBehavior then
				ClearSelection;
			TCustomClientDataSet(DataSource.DataSet).UndoLastChange(True);
		end;
	finally
		OnCancelling := False;
	end;
end;

procedure TdxDBGridSermo.DoDrawCell(ACanvas: TCanvas; var ARect: TRect;
	ANode: TdxTreeListNode; AIndex: Integer; ASelected, AFocused,
	ANewItemRow, ALeftEdge, ARightEdge: Boolean; ABrush: HBRUSH;
	var AText: string; var AColor: TColor; AFont: TFont;
	var AAlignment: TAlignment; var ADone: Boolean);
var
	us:Variant;
begin
	if (DataSource = Nil) or (DataSource.DataSet = Nil) or not Datasource.DataSet.Active then Exit;

	//Try pour éviter erreur variant quand insertion nouvelle ligne
	try
		if ASelected and not AFocused then
		begin
			AColor:=clLtGray;
			AFont.Color:=clBlack;
		end;

		if FStandardDraw then
			if (not ANode.HasChildren) then
			begin
				if (Self.FindColumnByFieldName('us') <> nil) and not (AFocused or ASelected) then
				try
					us := ANode.Values[Self.ColumnByFieldName('us').Index];
					if (not VarIsNull(us)) and (us <> Ord(usUnModified)) then
						AColor := clInfoBk;
				except
				end
				else
				if (Self.FindColumnByFieldName('ETATMODIF') <> nil) then
				try
					us := ANode.Values[Self.ColumnByFieldName('ETATMODIF').Index];
					if (not VarIsNull(us)) then
						if (us = Ord(usModified)) then
						begin
							AFont.Color := clRed;
							AFont.Style := AFont.Style - [fsItalic];
						end
						else
						if (us = Ord(usInserted)) then
						begin
							if not AFocused then
								AFont.Color := clWindowText;
							AFont.Style := AFont.Style + [fsItalic];
						end;
				except
				end;
			end
			else
				AFont.Style := AFont.Style - [fsItalic];

	except
		showmessage('erreur');
	end;

	inherited;
end;

procedure TdxDBGridSermo.SetXLSFileName(const Value: TFileName);
begin
	FXLSFileName := Value;
end;

procedure TdxDBGridSermo.DoEndColumsCustomizing(Sender: TObject);
begin
	// Appel de l'événement OnEndColumsCustomizing utilisé à la conception
	if Assigned(OnCustomEndColCust) then
		OnCustomEndColCust(Sender);

	if (HMCustomize > 0) then
		PopupMenu.FindItem(HMCustomize, fkHandle).Checked := False;

  OnEndColumnsCustomizing := OnCustomEndColCust;
end;

procedure TdxDBGridSermo.SetOnCopy(const Value: TNotifyEvent);
begin
  FOnCopy := Value;
end;

procedure TdxDBGridSermo.SetOnCut(const Value: TNotifyEvent);
begin
	FOnCut := Value;
end;

procedure TdxDBGridSermo.SetOnPaste(const Value: TNotifyEvent);
begin
  FOnPaste := Value;
end;

procedure TdxDBGridSermo.SetOnCanPaste(const Value: TCanPasteEvent);
begin
	FOnCanPaste := Value;
end;

procedure TdxDBGridSermo.SetOnCancelling(const Value: Boolean);
begin
  FOnCancelling := Value;
end;

procedure TdxDBGridSermo.SetXLSDialog(const Value: Boolean);
begin
	FXLSDialog := Value;
end;

procedure TdxDBGridSermo.SetXLSCurrentFile(const Value: TFileName);
begin
  FXLSCurrentFile := Value;
end;

procedure TdxDBGridSermo.ReplaceDialog1Replace(Sender: TObject);
var
	i:integer;
	NewStr,OldIFN:String;
	rfs:TReplaceFlags;
	Sel:TStringList;
	oldds:TDataset;
	F:TField;

			procedure DoReplace(F:TField);
			begin
				if frWholeWord in ReplaceDialog.Options then
				begin
					if AnsiSameText(ReplaceDialog.FindText,F.Text) then
					begin
						Oldds.Edit;
						F.Text:=ReplaceDialog.ReplaceText;
					end;
				end
				else
					begin
						Rfs:=[];
						if not (frMatchCase in ReplaceDialog.Options) then
							Rfs:=Rfs+[rfIgnoreCase];
						if frReplaceAll in ReplaceDialog.Options then
							Rfs:=Rfs+[rfReplaceAll];
						NewStr:=StringReplace(F.Text,ReplaceDialog.FindText,ReplaceDialog.ReplaceText,Rfs);
						if NewStr<>F.Text then
						begin
							Oldds.Edit;
							F.Text:=NewStr;
						end;
					end;
			end;

begin
	try
		Sel:=TStringList.Create;
		for i:=0 to SelectedCount-1 do
			Sel.Add(SelectedRows[i]);

		Datasource.Dataset.DisableControls;
		try
			Oldds:=Datasource.Dataset;
			F:=FocusedField;
			Datasource.Dataset:=Nil;
			for i:=0 to Sel.Count-1 do
			begin
				Oldds.Bookmark:=Sel[i];
				DoReplace(F);
				if Oldds.State<>dsBrowse then Oldds.Post;
			end;
			{if (Datasource.Dataset is TClientDataset) then
			With TClientDataset(Datasource.Dataset) do
			begin
				OldIFN:=IndexFieldNames;
				IndexFieldNames:='';
			end;
			Datasource.Dataset.First;
			While not Datasource.Dataset.Eof do
			begin
				DoReplace(FocusedField);
				if Datasource.Dataset.State<>dsBrowse then Datasource.Dataset.Post;
				Datasource.Dataset.Next;
			end;}
		finally
			Datasource.Dataset:=Oldds;
			{Beginselection;
			try
				for i:=0 to Sel.Count-1 do
				begin
					Datasource.Dataset.Bookmark:=Sel[i];
					FindNodeById;
					FocusedNode.Selected:=True;
				end;
			finally
				EndSelection;
			end;}
		end;
	finally
		Sel.Free;
		{if (Datasource.Dataset is TClientDataset) then
			With TClientDataset(Datasource.Dataset) do
				IndexFieldNames:=OldIFN;}
		Datasource.Dataset.EnableControls;
	end;

end;


procedure TdxDBGridSermo.SetOnAfterExcel(const Value: TNotifyEvent);
begin
  FOnAfterExcel := Value;
end;

procedure TdxDBGridSermo.SetOnBeforeExcel(const Value: TNotifyEvent);
begin
  FOnBeforeExcel := Value;
end;

procedure TdxDBGridSermo.SetOnAfterPrint(const Value: TNotifyEvent);
begin
  FOnAfterPrint := Value;
end;

procedure TdxDBGridSermo.SetStandardDraw(const Value: Boolean);
begin
  FStandardDraw := Value;
end;

procedure TdxDBGridSermo.SetOnRevertRecord(const Value: TNotifyEvent);
begin
  FOnRevertRecord := Value;
end;

procedure TdxDBGridSermo.SetOnUndoLastChange(const Value: TNotifyEvent);
begin
	FOnUndoLastChange := Value;
end;

type
  THCB=Class(TClipBoard);


function ClipboardGetTablename: String;
var
  Data: THandle;
begin
  with THCB(ClipBoard) do
  begin
    Open;
    Data := GetClipboardData(CF_SISTablename);
    try
      if Data <> 0 then
        Result := PChar(GlobalLock(Data))
      else
        Result := '';
    finally
      if Data <> 0 then GlobalUnlock(Data);
      Close;
    end;
  end;
end;

procedure ClipboardSetTableContent(Tablename,CSV:String);
var
  Data: THandle;
  DataPtr: Pointer;
    procedure AddFormat(Format:Word;St:String);
    begin
      Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Length(St)+1);
      try
        DataPtr := GlobalLock(Data);
        try
          Move(PChar(St)^, DataPtr^, Length(St)+1);
          SetClipboardData(Format, Data);
        finally
          GlobalUnlock(Data);
        end;
      except
        GlobalFree(Data);
        raise;
      end;
    end;

begin
  with THCB(ClipBoard) do
  begin
    Open;
    try
      AddFormat(CF_Text,CSV);
      AddFormat(CF_SISTableName,TableName);
    finally
      Close;
    end;
  end;
end;

//Copie dans le Clipboard les lignes sélectionnées et les champs marqués visibles
// dans le dataset associé...
procedure TdxDBGridSermo.CopySelectedRecordsToClipboard;
	var
    i,r:integer;
		V,VC:String;
		BM:TBookMark;


    procedure CopyRecord;
    var
      i:integer;
      f:TField;
    begin
      with DataSource,Dataset do
  		for i:=0 to pred(FieldCount) do
			begin
        F:=Fields[i];
        if (V<>'') and (V[length(V)]<>#10) then
          V:=V+#9;
        if Fields[i].DataType in [ftMemo,ftFmtMemo,ftWideString] then
          VC:=Fields[i].AsString
        else
        if F.DataType=ftBlob then
          VC:=MimeEncodeStringNoCRLF(TBlobField(F).Value)
        else
          VC:=Fields[i].Text;
        if (Pos(#10,VC)=0) and (pos(#13,VC)=0) then
          V:=V+VC
        else
          V:=V+'"'+VC+'"';{Text;}
			end;
    end;

begin
	if DataSource.Dataset=Nil then
		Raise Exception.Create('Pas de dataset connecté');
	BM:=DataSource.Dataset.GetBookMark;
	with DataSource,Dataset do
	try
		Screen.Cursor:=crHourGlass;
		DisableControls;
		First;
		V:='';
    //Entêtes
    for i:=0 to pred(FieldCount) do
    begin
      if (V<>'') and (V[length(V)]<>#10) then
        V:=V+#9;
       V:=V+Fields[i].FieldName;
    end;
    V:=V+#13#10;
    
    //Lignes
    if SelectedCount>0 then
      for r:=0 to SelectedCount-1 do
      begin
        Bookmark:=Self.SelectedRows[r];
        Copyrecord;
        Next;
        if not Eof then V:=V+#13#10;
      end
    else
      CopyRecord;

    Clipboard.Clear;
		ClipboardSetTableContent(uppercase(Self.DataSource.DataSet.Name),V);
	finally
		EnableControls;
		GotoBookMark(BM);
		Screen.Cursor:=crDefault;
	end;
end;

procedure TdxDBGridSermo.PasteClipBoardToDataset;
var
	Clp,V:String;
	I,P,NbCol:integer;
	FV:Array[0..200] of Variant;
	FN:Array[0..200] of String;
	FR:Array[0..200] of TField;
	ColSep:char;
	LigneVide:Boolean;
  Keyvalue:String;

	function Eol:Boolean;
	begin
		Result:=(p>length(clp)) or (Clp='') or (Clp[p] in [#13,#10,#0]);
	end;

	function GetNext:String;
	var
		Deb:integer;
		InsSTr,Guill:Boolean;

	begin
		InsStr:=False;
		Guill:=False;
		Deb:=P;
		While (p <= length(Clp)) and (InsStr or not ((Clp[P]=ColSep) or Eol)) do
		begin
			if Clp[P]='"' then
			begin
				InsStr:=not InsStr;
				Guill:=True;
			end;
			Inc(p);
		end;
		if not Guill then
			Result:=Copy(Clp,Deb,P-Deb)
		else
			Result:=Copy(Clp,Deb+1,P-Deb-2);

		//Passage au champ suivant.
		if (p < length(Clp)) and (Clp[P]=ColSep) then
			Inc(P);
	end;


	procedure SkipEol;
	begin
		While (p <= length(Clp)) and (Clp[P] in [#10,#13]) do
			Inc(P);
	end;

	procedure InitFV;
	var
		i:integer;
	begin
		for i:= low(FV) to High(FV) do
			FV[i]:='';
	end;

	function IndexOfField(Fname:String):integer;
	var
		i:integer;
	begin
		result:=-1;
		for i:=0 to NbCol do
			if CompareText(FN[i],FName)=0 then
			begin
				Result:=i;
				Break;
			end;
	end;

	function GetFV(FName:String):String;
	var
		i:integer;
	begin
		i:=IndexOfField(FName);
		if i>=0 then
			result:=FV[i]
		else
			result:='';
	end;

begin
	Clp:=Clipboard.AsText;
	if Clp='' then
	begin
		MessageBeep(1);
		Exit;
	end;
	if Pos(#9,Clp)>0 then
		ColSep:=#9
	else
	if Pos(';',Clp)>0 then
		ColSep:=';'
	else
		ColSep:=' ';

	P:=1;
	NbCol:=0;

	//Lecture de l'entête
	While not Eol do
	begin
		FN[NbCol]:=GetNext;
		Inc(NbCol);
	end;
	SkipEol;

	for i:=0 to NbCol-1 do
	begin
		if Assigned(FOnGetPasteFieldName) then
			FR[i]:=DataSource.Dataset.FindField(FOnGetPasteFieldName(FN[i]))
		else
			FR[i]:=DataSource.Dataset.FindField(FN[i]);
	end;

	DataSource.Dataset.DisableControls;
	Screen.Cursor:=crHourGlass;
	try
		While (P <= length(Clp)) do
		begin
			LigneVide:=True;
			//Lecture de la lignz
			NbCol:=0;
			While not Eol do
			begin
				FV[NbCol]:=GetNext;
				Inc(NbCol);
			end;
			SkipEol;

      KeyValue:='{NULL}';
			if not (DataSource.Dataset.state in dsEditModes) then
			begin
        if (FPasteKeyFieldName<>'') then
          KeyValue:=GetFV(FPasteKeyFieldName);
				if (FPasteKeyFieldName<>'') and (KeyValue<>'') and DataSource.Dataset.Locate(FPasteKeyFieldName,KeyValue,[]) then
        begin
          if not Assigned(FOnCanPasteEditRecord) or FOnCanPasteEditRecord(KeyValue) then
					  DataSource.Dataset.Edit
          else
            DataSource.Dataset.Append;
				end
        else
					DataSource.Dataset.Append;
			end;
			for i:=0 to NbCol-1 do
			begin
				V:=FV[i];
				if (V<>'') and (FR[i]<>Nil) and not (FR[i].ReadOnly) and
					(not Assigned(FOnCanPasteField) or FOnCanPasteField(FR[i].FieldName) ) then
				try
					LigneVide:=False;
					//FR[i].AsString:=V;
					if FR[i].DataType in [ftMemo,ftFmtMemo,ftWideString]  then
            try
              FR[i].AsString:=V;
            except
              FR[i].Text:=V;
            end
          else
					if FR[i].DataType=ftBlob then
            try
              TBlobField(FR[i]).Value:=MimeDecodeString(V);
            except
              FR[i].Clear;
            end
          else
            try
              FR[i].Text:=V;
            except
              FR[i].AsString:=V;
            end
				except
					MessageBeep(1);
				end;
			end;
      if KeyValue<>'{NULL}' then
        DataSource.Dataset.FieldByName(FPasteKeyFieldName).AsString:=Keyvalue;

			if DataSource.Dataset.Modified and not LigneVide then
			try
				DataSource.Dataset.Post
			except
				MessageBeep(1);
				DataSource.Dataset.Cancel;
			end
			else
				DataSource.Dataset.Cancel;
			SkipEol;
		end;
	finally
		DataSource.Dataset.EnableControls;
		Screen.Cursor:=crDefault;
	end;

end;

procedure TdxDBGridSermo.SetOnCanPasteEditRecord(
  const Value: TCanPasteEditRecordEvent);
begin
  FOnCanPasteEditRecord := Value;
end;

procedure TdxDBGridSermo.SetOnCanPasteField(
  const Value: TCanPasteFieldEvent);
begin
  FOnCanPasteField := Value;
end;

procedure TdxDBGridSermo.SetOnGetPasteFieldName(
  const Value: TFieldsMappingEvent);
begin
  FOnGetPasteFieldName := Value;
end;

function TdxDBGridSermo.CanEditAcceptKey(Key: Char): Boolean;
begin
  // pour permettre ":" dans les champs float
  if key = ':' then
    result := True
  else
    Result := inherited CanEditAcceptKey(Key);
end;

initialization
  CF_SISTablename:=RegisterClipboardFormat('SISTablename');
end.
