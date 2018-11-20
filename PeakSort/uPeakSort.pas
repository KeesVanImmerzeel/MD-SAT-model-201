unit uPeakSort;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, LargeArrays, xyTable, math, Spin, ExtCtrls, SpinFloat;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    EditBerekendeBinnenwaterstanden: TEdit;
    ButtonSelectBerekendeGrondwaterstanden: TButton;
    OpenDialogSelectBerekendeGrondwaterstanden: TOpenDialog;
    DoubleMatrixBinnenwaterstanden: TDoubleMatrix;
    Label2: TLabel;
    EditBerekendeToestroming: TEdit;
    ButtonBerekendeToestroming: TButton;
    OpenDialogBerekendeToestroming: TOpenDialog;
    DoubleMatrixBerekendeToestroming: TDoubleMatrix;
    Buitenwaterstanden: TLabel;
    EditBuitenwaterstanden: TEdit;
    ButtonSelectBuitenwaterstanden: TButton;
    OpenDialogBuitenwaterstanden: TOpenDialog;
    xyTableBuitenwaterstanden: TxyTable;
    ButtonWritePeaks: TButton;
    DoubleMatrixResult: TDoubleMatrix;
    SaveDialogPeaks: TSaveDialog;
    LargeRealArrayMaxBWSincident: TLargeRealArray;
    Label3: TLabel;
    EditGewensteBinnenwaterstand: TEdit;
    OpenDialogGewensteBinnenwaterstanden: TOpenDialog;
    ButtonSelectBinnenwaterstanden: TButton;
    xyTableGewensteBinnenwaterstanden: TxyTable;
    PanelRefIsBinnenwaterstand: TPanel;
    Label4: TLabel;
    SpinEditCMbovenGem: TSpinEdit;
    PanelRefIsFixed: TPanel;
    Label5: TLabel;
    SpinFloatEditFixedLevel: TSpinFloatEdit;
    CheckBoxFixedRefLevel: TCheckBox;
    procedure ButtonSelectBerekendeGrondwaterstandenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonBerekendeToestromingClick(Sender: TObject);
    procedure ButtonSelectBuitenwaterstandenClick(Sender: TObject);
    procedure ButtonWritePeaksClick(Sender: TObject);
    procedure ButtonSelectBinnenwaterstandenClick(Sender: TObject);
    procedure RadioButtonFixedReferenceClick(Sender: TObject);
    procedure CheckBoxFixedRefLevelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  lf: TextFile;
implementation

{$R *.DFM}

procedure TForm1.ButtonSelectBerekendeGrondwaterstandenClick(
  Sender: TObject);
var
  f: TextFile;
  iError, iTableType: LongInt;
begin
  with OpenDialogSelectBerekendeGrondwaterstanden do begin
    if execute then begin
      Try
        AssignFile( f, FileName ); Reset( f );
        Readln( f, iError );
        Readln( f, iTableType );
        DoubleMatrixBinnenwaterstanden := TDoubleMatrix.InitialiseFromTextFile( f, lf, self );
        EditBerekendeBinnenwaterstanden.Text := ExpandFileName( FileName );
        CloseFile( f );
      except
      end;
    end;
  end; {-with OpenDialogSelectBerekendeGrondwaterstanden}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AssignFile( lf,  'PeakSort.log' ); Rewrite( lf );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  {$I-} CloseFile( lf ); {$I+}
end;

procedure TForm1.ButtonBerekendeToestromingClick(Sender: TObject);
var
  f: TextFile;
  iError, iTableType: LongInt;
begin
  with OpenDialogBerekendeToestroming do begin
    if execute then begin
      Try
        AssignFile( f, FileName ); Reset( f );
        Readln( f, iError );
        Readln( f, iTableType );
        DoubleMatrixBerekendeToestroming := TDoubleMatrix.InitialiseFromTextFile( f, lf, self );
        EditBerekendeToestroming.Text := ExpandFileName( FileName );
        CloseFile( f );
      except
      end;
    end;
  end; {-with OpenDialogBerekendeToestroming}
end;

procedure TForm1.ButtonSelectBuitenwaterstandenClick(Sender: TObject);
var
  f: TextFile;
  iTableType: LongInt;
begin
  with OpenDialogBuitenwaterstanden do begin
    if execute then begin
      Try
        AssignFile( f, FileName ); Reset( f );
        Readln( f, iTableType );
        xyTableBuitenwaterstanden := TxyTable.InitialiseFromTextFile( f, lf, self );
        EditBuitenwaterstanden.Text := ExpandFileName( FileName );
        CloseFile( f );
      except
      end;
    end;
  end; {-with OpenDialogBuitenwaterstanden}
end;

procedure TForm1.ButtonWritePeaksClick(Sender: TObject);
{-1:Time, 2:Toestroming, 3:Buitenwaterstand, 4:IncidentID, 5:Binnenwaterstand,
  6: MaxBWSincident, 7: GewensteBinnenwaterstand }
Function BinnenwaterstandMaaktDeelUitVanPiek( const Binnenwaterstand, GewensteBinnenwaterstand: Double ): Boolean;
begin
  if CheckBoxFixedRefLevel.Checked then begin
    Result := ( Binnenwaterstand > SpinFloatEditFixedLevel.Value );
  end else begin
    Result := ( Binnenwaterstand > ( GewensteBinnenwaterstand + SpinEditCMbovenGem.Value/100 ) );
  end;
end;

var
  i, j, NrOfTimes, IncidentID: LongInt;
  TxyTableBinnenwaterstanden: TxyTable;
  f: TextFile;
begin
  if SaveDialogPeaks.Execute then begin
    AssignFile( f, SaveDialogPeaks.FileName ); Rewrite( f );
  end else
  exit;

  NrOfTimes := DoubleMatrixBerekendeToestroming.GetNRows;
  DoubleMatrixResult := TDoubleMatrix.Create( NrOfTimes, 7, self );
  TxyTableBinnenwaterstanden := TxyTable.InitialiseFromDoubleMatrix
    ( DoubleMatrixBinnenwaterstanden, 1, 3, lf, self );
  for i:=1 to NrOfTimes do begin
    DoubleMatrixResult[ i, 1 ] := DoubleMatrixBerekendeToestroming[ i, 1 ];
    DoubleMatrixResult[ i, 2 ] := DoubleMatrixBerekendeToestroming[ i, 2 ];
    DoubleMatrixResult[ i, 3 ] := xyTableBuitenwaterstanden.EstimateY(
      DoubleMatrixResult[ i, 1 ], FrWrd );
    DoubleMatrixResult[ i, 4 ] := 0;
    DoubleMatrixResult[ i, 5 ] := TxyTableBinnenwaterstanden.EstimateY(
      DoubleMatrixResult[ i, 1 ], FrWrd );
    DoubleMatrixResult[ i, 6 ] := DoubleMatrixResult[ i, 5 ];
    DoubleMatrixResult[ i, 7 ] := xyTableGewensteBinnenwaterstanden.EstimateY(
      DoubleMatrixResult[ i, 1 ], FrWrd );
  end;
  TxyTableBinnenwaterstanden.Free;

  {-Nummer incidenten}
  IncidentID := 1;
  for i:=1 to NrOfTimes do begin
    if BinnenwaterstandMaaktDeelUitVanPiek( DoubleMatrixResult[ i, 5 ], DoubleMatrixResult[ i, 7 ] ) then
      DoubleMatrixResult[ i, 4 ] := IncidentID
    else begin
      DoubleMatrixResult[ i, 4 ] := 0;
      if ( i > 1 ) and ( DoubleMatrixResult[ i-1, 4 ] > 0 ) then
        Inc( IncidentID );
    end;
  end;
  Writeln( lf, 'Aantal incidenten: ', IncidentID );
  MessageDlg('Aantal incidenten: ' + IntToStr( IncidentID ), mtInformation,
      [mbOk], 0);

  {-Bepaal per incident het maximum}
  LargeRealArrayMaxBWSincident := TLargeRealArray.Create( IncidentID, self );
  for i:=1 to NrOfTimes do begin
    IncidentID := Trunc( DoubleMatrixResult[ i, 4 ] );
    if IncidentID > 0 then begin
      if i > 1 then begin
        if DoubleMatrixResult[ i-1, 4 ] > 0 then begin
          LargeRealArrayMaxBWSincident[ IncidentID ]  := Max( DoubleMatrixResult[ i, 5 ], LargeRealArrayMaxBWSincident[ IncidentID ] )
        end else begin
          LargeRealArrayMaxBWSincident[ IncidentID ] := DoubleMatrixResult[ i, 5 ];
        end;
      end else begin
        LargeRealArrayMaxBWSincident[ IncidentID ] := DoubleMatrixResult[ i, 5 ];
      end;
    end
  end; {-for}
  for i:=1 to NrOfTimes do begin
    IncidentID := Trunc( DoubleMatrixResult[ i, 4 ] );
    if IncidentID > 0 then
      DoubleMatrixResult[ i, 6 ] := LargeRealArrayMaxBWSincident[ IncidentID ]
    else
      DoubleMatrixResult[ i, 6 ] := -999;
  end;

  {-1:Time, 2:Toestroming, 3:Buitenwaterstand, 4:IncidentID, 5:Binnenwaterstand,
  6: MaxBWSincident, 7: GewensteBinnenwaterstand }
  for i:=1 to NrOfTimes do begin
    IncidentID := Trunc( DoubleMatrixResult[ i, 4 ] );
    if IncidentID > 0 then begin
      for j:=1 to 7 do
        Write( f, FloatToStrF( DoubleMatrixResult[ i, j ], ffExponent, 8, 2 ), ' ' );
      Writeln( f );
    end;
  end;
  {DoubleMatrixResult.WriteToTextFile( f );}
  CloseFile( f );
  MessageDlg('Ready', mtInformation, [mbOk], 0);
end;

procedure TForm1.ButtonSelectBinnenwaterstandenClick(Sender: TObject);
var
  f: TextFile;
  iTableType: LongInt;
begin
  with OpenDialogGewensteBinnenwaterstanden do begin
    if Execute then begin
      Try
        AssignFile( f, FileName ); Reset( f );
        Readln( f, iTableType );
        xyTableGewensteBinnenwaterstanden := TxyTable.InitialiseFromTextFile( f, lf, self );
        EditGewensteBinnenwaterstand.Text := ExpandFileName( FileName );
        CloseFile( f );
      except
      end;
    end;
  end;
end;

procedure TForm1.RadioButtonFixedReferenceClick(Sender: TObject);
begin
  PanelRefIsFixed.Visible := not PanelRefIsFixed.Visible;
end;

procedure TForm1.CheckBoxFixedRefLevelClick(Sender: TObject);
begin
  PanelRefIsFixed.Visible := not PanelRefIsFixed.visible;
  PanelRefIsBinnenwaterstand.Visible := not PanelRefIsBinnenwaterstand.Visible;
end;

end.
