unit uLoginDlg;
interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Buttons, ExtCtrls;

type
	TLoginDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ImgIcone: TImage;
    ButOK: TBitBtn;
    ButAnnuler: TBitBtn;
    EdLoginId: TEdit;
    EdPwd: TEdit;
    EdAppli: TEdit;
		procedure EdLoginIdChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
	private
		{ Déclarations privées }
	public
		{ Déclarations publiques }
	end;



implementation

{$R *.DFM}
uses tisutils;



procedure TLoginDlg.EdLoginIdChange(Sender: TObject);
begin
	ButOK.Enabled := (EdLoginId.Text <> '');
end;

procedure TLoginDlg.FormShow(Sender: TObject);
begin
	ImgIcone.Picture.Icon:=Application.Icon;
	EdAppli.Text:=GetApplicationName + ' '+GetApplicationVersion;
	EdLoginIdChange(Sender);
	if (EdLoginId.Text <> '') then
		ActiveControl := EdPwd
	else
		ActiveControl := EdLoginId;
end;


end.
