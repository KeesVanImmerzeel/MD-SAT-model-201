library dsmodel201;
  {-Model van een berging met uitwateringssluis met een paraboolvormige kruin.
    De relatie tussen de berging en de binnenwaterstand wordt gespecificeerd door middel van een
    tabel. De Toestroming naar berging voor de sluis wordt opgegeven. Afvoer vindt van hieruit plaats
    door de sluis. Het debiet door de sluis wordt bepaald door de sluiseigenschappen, de bovenwaterstand
    (berekend), het type stuwbeheer (opgegeven) en de benedenwaterstand (opgegeven).
    Verondersteld wordt dat de benedenwaterstand een sinus-vormig verloop heeft (eb en vloed).
    Een bijzonderheid daarbij is dat er een ondergrens van de buitenwaterstand kan worden opgegeven.
    Dit is van belang als het uitzakken van de buitenwaterstand beperkt wordt door opslibbing van
    het wad.
    De kwelsterkte naar de berging kan worden opgegeven. Daarnaast bestaat de mogelijkheid
    het peil in de berging te controloren d.m.v. een pomp.}

  { Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  windows, SysUtils, Classes, LargeArrays, ExtParU, USpeedProc, uDCfunc,
  UdsModel, UdsModelS, xyTable, DUtils, uError, Math;

Const
  cModelID      = 201;  {-Uniek modelnummer}

  {-Beschrijving van de array met afhankelijke variabelen}
  cNrOfDepVar   = 5;    {-Lengte van de array met afhankelijke variabelen}
  cBerging      = 1;    {-Berging in waterlopen en op maaiveld (m)}
  cCumQs        = 2;    {-Afvoer door stuw (cumulatief, m)}
  cCumWs1       = 3;    {-Cum. binnenwaterstand (voor berekening gem. binnenwaterstand)}
  cCumKwel      = 4;    {-Kwel naar berging (cumulatief, m)}
  cCumQpump     = 5;    {-Hoeveelheid door gemaal uitgeslagen water (cumulatief, m)}

  {-Aantal keren dat een discontinuiteitsfunctie wordt aangeroepen in de procedure met
    snelheidsvergelijkingen (DerivsProc)}
  nDC = 0;

  {-Variabelen die samenhangen met het aanroepen van het model vanuit de Shell}
  cnRP = 6;   {-Aantal RP-tijdreeksen die door de Shell moeten worden aangeleverd (in
                de externe parameter Array EP (element EP[ indx-1 ]))}
  cnSQ = 0;   {-Idem punt-tijdreeksen}
  cnRQ = 0;   {-Idem lijn-tijdreeksen}

  {-Beschrijving van het eerste element van de externe parameter-array (EP[cEP0])}
  cNrXIndepTblsInEP0 = 10; {-Aantal XIndep-tables in EP[cEP0]}
  cNrXdepTblsInEP0   = 1;  {-Aantal Xdep-tables   in EP[cEP0]}

  {-Nummering van de xIndep-tabellen in EP[cEP0].xInDep De nummers 0&1 zijn gereserveerd}
  cTb_MinMaxValKeys = 2; {-Grenzen aan key-values}
  cTb_Ws2           = 3; {-Par. vr. de beschr. vd. buitenwaterstand (Ws2, (m+NAP);
                           M.U.V. DE GEMIDDELDE BUITENWATERSTAND! }
  cTb_Berging_Ws1   = 4; {-Beschr. v.d. relatie tussen de berging (B, (m)) en de binnenwaterstand (Ws1, (m+NAP))}
  cTb_Cd            = 5; {-Karakteristieke afvoercoefficient Cd (Cd=f(kruinvorm,klephoek en h1)) Deze waarden zijn voor paraboolvormige kruinen P5}
  cTb_cA            = 6; {-Contractiefactor cA (-) voor kleppen met paraboolvormige kruinen en niet-afgeronde ophangarmen}
  cTb_Cdr           = 7; {-Reductiefactor voor gestuwde afvoer (Cdr, (-))}
  cTb_StuwPars      = 8; {-Parameters voor de beschrijving van de stuw (breedte, afw.opp. etc)}
  cTb_SbPars        = 9; {-Parameters voor het beschrijven van het stuwbeheer}

  {-Nummering van de xIndep-tabellen in EP[cEP0].xDep}
  cTb_Ws2Av         = 0; {-Gem.buitenwaterstand m+NAP)}

  {-Beschrijving van het tweede element van de externe parameter-array (EP[cEP1])}
  {-Opmerking: table 0 van de xIndep-tabellen is gereserveerd}
  {-Nummering van de xdep-tabellen in EP[cEP1]}
  cTb_Q           = 0; {-Toestroming naar berging voor stuw (m/d)}
  cTb_Ws1_gewenst = 1; {-Gewenste waterstand in berging voor de stuw (m+NAP)}
  cTb_Ws1_Init    = 2; {-Initiele waterstand in berging voor de stuw (m+NAP)}
  cTb_SbCode      = 3; {-Stuwbeheer-code}
  cTb_Kwel        = 4; {-Kwel (m/d)}
  cTb_PumpCap     = 5; {-Pompcapaciteit (m/d)}

  {-Model specifieke fout-codes: -9911..-9950}
  cInvld_DefaultPar_Cd  = -9911; {-Cd waarde onbekend bij deze combinatie (klephoek, overstorthoogte h1)}
  cInvld_DefaultPar_cA  = -9912; {-cA waarde onbekend bij deze combinatie (klephoek, verhouding h1/B)}
  cInvld_DefaultPar_Cdr = -9913; {-Cdr niet bekend bij deze combinatie (klephoek, verdrinkingsgraad)}
  cInvld_Ws1            = -9914; {-Ongeldige binnenwaterstand (m+NAP)}
  cInvld_SbCode         = -9915; {-Ongeldige stuwbeheer-code (SbCode,(-))}
  cInvld_Q              = -9916; {-Ongeldige waarde v.d. toestroming naar berging voor de sluis (m/d)}
  cH1Exceeded           = -9917; {-Overstorthoogte te groot (>cH1Max) }
  cInvld_Berging        = -9918; {-Ongeldige bering (m)}
  cInvld_Kwel           = -9919; {-Ongeldige waarde voor de kwel naar de berging (m/d)}
  cInvld_PumpCap        = -9920; {-Ongeldige waarde voor de pompcapaciteit (m/d)}

  {-Stuwbeheer codes}
  cSBC_UseMaxCapacity = 1; {-Stuw altijd zover mogelijk open; geen terugstroming}
  cSBC_Closed         = 2; {-Stuw is gesloten}

var
  Indx: Integer; {-Door de Boot-procedure moet de waarde van deze index worden ingevuld,
                   zodat de snelheidsprocedure 'weet' waar (op de externe parameter-array)
                   hij zijn gegevens moet zoeken}
  ModelProfile: TModelProfile;
                 {-Object met met daarin de status van de discontinuiteitsfuncties
                   (zie nDC) }

  {-Globally defined parameters from EP[0]}
  {-Stuwparameters}
  Cv,                        {-Coefficient voor de aanloopsnelheid (-) [1 - 1.015]}
  cStuwBreedte,              {-Breedte stuw (m)}
  cBreedteOphangArm,         {-Breedte v.d. ophangarm (m)}
  cAfwOpp : Double;          {-Afwaterend oppervlak (m2)}
  cAantOphangArmen: Integer; {-Aantal ophangarmen (-)}

  {-Geldige range van key-/parameter/initiele waarden. De waarden van deze  variabelen moeten
    worden ingevuld door de Boot-procedure}
  cMin_SbCode, cMax_SbCode: Integer;
  cMin_Q,      cMax_Q,
  cMin_Ws1,    cMax_Ws1,
  cMin_Kr,     cMax_Kr,
  cH1Max,      {-Maximale overstorthoogte}
  cMin_Kwel,    cMax_Kwel,
  cMin_PumpCap, cMax_PumpCap
  : Double;

Procedure MyDllProc( Reason: Integer );
begin
  if Reason = DLL_PROCESS_DETACH then begin {-DLL is unloading}
    {-Cleanup code here}
    if ( nDC > 0 ) then
      ModelProfile.Free;
  end;
end;

Procedure DerivsProc( var x: Double; var y, dydx: TLargeRealArray;
                      var EP: TExtParArray; var Direction: TDirection;
                      var Context: Tcontext; var aModelProfile: PModelProfile; var IErr: Integer );
{-Deze procedure verschaft de array met afgeleiden 'dydx', gegeven het tijdstip 'x' en
  de toestand die beschreven wordt door de array 'y' en de externe condities die beschreven
  worden door de 'external parameter-array EP'. Als er geen fout op is getreden bij de
  berekening van 'dydx' dan wordt in deze procedure de variabele 'IErr' gelijk gemaakt aan
  de constante 'cNoError'. Opmerking: in de array 'y' staan dus de afhankelijke variabelen,
  terwijl 'x' de onafhankelijke variabele is (meestal de tijd)}
var
  {-Sleutel-waarden voor de default-tabellen in EP[cEP0]}
  SbCode:       {-Stuwbeheer code (-)}
  Integer;
  {-Parameter-waarden afkomstig van de Shell}
  Q,            {-Toestroming naar de berging voor de stuw (m/d)}
  Ws1_gewenst,  {-Gewenste benedenwaterstand (m+NAP)}
  {-Afgeleide (berekende) parameter-waarden}
  Berging,      {-Berging in waterlopen en op maaiveld (m)}
  Ws1,          {-Binnenwaterstand (m+NAP)}
  Ws2,          {-Buitenwaterstand (m+NAP)}
  Kr,           {-Kruinhoogte (m+NAP)}
  Qs,           {-Afvoer door de stuw (m/d)}
  Kwel,         {-Kwel (m/d)}
  PumpCap,      {-Pompcapaciteit (m/d)}
  Qpump:        {-Pompdebiet (m/d)}
  Double;
  i: Integer;

Function SetParValuesFromEP0( var IErr: Integer ): Boolean;
  {-Fill globally defined parameters from EP[0]}
begin
  Result := True;
  IErr   := cNoError;
  with EP[ cEP0 ].xInDep.Items[ cTb_Berging_Ws1 ] do begin
    cMin_Ws1 := GetValue( 1, 2 );
    cMax_Ws1 := GetValue( GetNRows, 2 );
  end;
  {-Stuwparameters}
  with EP[ cEP0 ].xInDep.Items[ cTb_StuwPars ] do begin
    Cv                :=        GetValue( 1, 1 );
    cStuwBreedte      :=        GetValue( 1, 2 );
    cAantOphangArmen  := Trunc( GetValue( 1, 3 ) );
    cBreedteOphangArm :=        GetValue( 1, 4 );
    cAfwOpp           :=        GetValue( 1, 5 );
  end;
end; {-Function SetParValuesFromEP0}

Function GetWs1( const Berging: Double; var IErr: Integer ): Double; {-Binnenwaterstand Ws1 bij Berging (m)}
begin
  Result := EP[ cEP0 ].xInDep.Items[ cTb_Berging_Ws1 ].EstimateYLinInterpolation( Berging, 1, 2, iErr );
  if ( iErr <> cNoError ) then
    IErr := cInvld_Berging;
end;

Function GetBerging(const Ws1: Double; var IErr: Integer ): Double; {-Berging bij Ws1}
begin
  Result := EP[ cEP0 ].xInDep.Items[ cTb_Berging_Ws1 ].EstimateYLinInterpolation( Ws1, 2, 1, iErr );
  if ( iErr <> cNoError ) then
    IErr := cInvld_Ws1;
end;

Function Replace_InitialValues_With_ShellValues( var IErr: Integer): Boolean;
  {-Als de Shell 1-of meer initiele waarden aanlevert voor de array met afhankelijke
    variabelen ('y'), dan kunnen deze waarden hier op deze array worden geplaatst en
    gecontroleerd}
var
  Ws1_Init: Double;
begin
  IErr := cNoError;
  with EP[ indx-1 ].xDep do
    Ws1_Init := Items[ cTb_Ws1_Init ].EstimateY( 0, Direction ); {Opm.: x=0}
  y[ cBerging ] := GetBerging( Ws1_Init, IErr );
  if ( iErr <> cNoError ) then
    IErr := cInvld_Ws1;
  Result := ( IErr = cNoError );
end; {-Replace_InitialValues_With_ShellValues}

Function SetKeyAndParValues( var IErr: Integer ): Boolean;
  Function GetKeyValue_SbCode( const x: Double ): Integer;
  begin
    with EP[ indx-1 ].xDep do
      Result := Trunc( Items[ cTb_SbCode ].EstimateY( x, Direction ) );
  end;
  Function GetParFromShell_Q( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_Q ].EstimateY( x, Direction );
  end;
  Function GetParFromShell_Ws1_gewenst( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_Ws1_gewenst ].EstimateY( x, Direction );
  end;
  Function GetParFromShell_Kwel( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_Kwel ].EstimateY( x, Direction );
  end;
  Function GetParFromShell_PumpCap( const x: Double ): Double;
  begin
    with EP[ indx-1 ].xDep do
      Result := Items[ cTb_PumpCap ].EstimateY( x, Direction );
  end;
begin {-Function SetKeyAndParValues}
  Result := False;
  SbCode := GetKeyValue_SbCode( x );
  if ( SbCode < cMin_SbCode ) or ( SbCode > cMax_SbCode ) then begin
    IErr := cInvld_SbCode; Exit;
  end;
  Q := GetParFromShell_Q( x );
  if ( Q < cMin_Q ) or ( Q > cMax_Q ) then begin
    IErr := cInvld_Q; Exit;
  end;
  Ws1_gewenst := GetParFromShell_Ws1_gewenst( x );
  if ( Ws1_gewenst < cMin_Ws1 ) or ( Ws1_gewenst > cMax_Ws1 ) then begin
    IErr := cInvld_Ws1; Exit;
  end;
  Kwel := GetParFromShell_Kwel( x );
  if ( Kwel < cMin_Kwel ) or ( Kwel > cMax_Kwel ) then begin
    IErr := cInvld_Kwel; Exit;
  end;
  PumpCap := GetParFromShell_PumpCap( x );
  if ( PumpCap < cMin_PumpCap ) or ( PumpCap > cMax_PumpCap ) then begin
    IErr := cInvld_PumpCap; Exit;
  end;
  Result := True; IErr := cNoError;
end; {-Function SetKeyAndParValues}

Function GetWs2( const t: Double ): Double;
  {-Buitenwaterstand (m+NAP)}
var
  w,              {-Hoeksnelheid (radialen/dag)}
  Ws2Av,          {-Gem.buitenwaterstand m+NAP)}
  Ampl,           {-Amplitude, m)}
  Period,         {-Periode d}
  t0,             {-Offset (d)}
  Ws2Min: Double; {-Onderbegrenzing (m+NAP)}
begin
  with EP[ cEP0 ].xInDep.Items[ cTb_Ws2 ] do begin
    Ampl   := GetValue( 1, 1 );
    Period := GetValue( 1, 2 );
    t0     := GetValue( 1, 3 );
    Ws2Min := GetValue( 1, 4 );
  end;
  with EP[ cEP0 ].xDep do
    Ws2Av := Items[ cTb_Ws2Av ].EstimateY( x, Direction );
  w      := ( 2 * Pi / Period );
  Result := Ws2Av + Ampl * Sin( w * ( t - t0 ) );
  Result := Max( Result, Ws2Min );
end;

{-Kruinhoogte (m+NAP). Als deze functie een waarde geeft > cMax_Kr, dan is de sluis
  gesloten}
Function GetKr( const Ws1, Ws2, Ws1_gewenst, Q: Double; const Sbcode: Integer ): Double;
  Function DeltaWs1: Double;
  begin
    Result := EP[ cEP0 ].xInDep.Items[ cTb_SbPars ].GetValue( 1, 1 );
  end;
  Function MinWsDif: Double;
  begin
    Result := EP[ cEP0 ].xInDep.Items[ cTb_SbPars ].GetValue( 1, 2 );
  end;
begin
  Result := MaxSingle; {-Sluis gesloten}
  if ( (Ws1-MinWsDif) <= Ws2 ) then Exit; {-Alleen uitwatering is denkbaar}
  case Sbcode of
    cSBC_UseMaxCapacity: begin
      if ( Ws1 > (Ws1_gewenst - DeltaWs1) ) then
        Result := cMin_Kr {-Gooi de sluis maximaal open}
      else
        Result := MaxSingle; {-Sluit de sluis}
    end;
  end; {-Case}
end;

Function Calc_Qs( const Ws1,         {-Bovenwaterstand (binnen) (m+NAP)}
                        Ws2,         {-Benedenwaterstand (buiten) (m+NAP)}
                        Kr: Double;  {-Kruinhoogte (m+NAP); moet geldige waarde hebben!}
                        var IErr: Integer ): Boolean;
var
  H2, {-Benedenwaterstand t.o.v. kruinhoogte (m)}
  H1, {-Overstorthoogte (m)}
  Kh, {-Klephoek (graden)}
  Cd, {-Kar. afv.ceff.(=f(kruinvorm,klephoek en h1))}
  Cc, {-Reductie afvoerende breedte ophangarmen (-)}
  S,  {-Verdrinkingsgraad (%)}
  Cdr {-Reductiefactor voor gestuwde afvoer (-)}
  : Double;
const
  TinyH1 = 0.0005; {-Minimale overstorthoogte om tot afvoer te komen}
  NrOfSecondsInAday = 3600*24;
  Function SetKh( const Kr: Double; var IErr: Integer ): Boolean;
  begin
    Kh := 0.2488*Sqr( Kr ) - 44.96755 * Kr + 52.932;
    IErr := cNoError; Result := True;
  end;
  Function SetCd( const H1, Kh: Double; var IErr: Integer ): Boolean;
  var
    TableValue: Double;
  begin
    with TDbleMtrxColAndRowIndx( EP[ cEP0 ].xInDep.Items[ cTb_Cd ] ) do
      TableValue := GetValueByLinearInterpolation( H1, Kh );
    if ( TableValue > 0 ) then begin
      Cd   := TableValue;
      IErr := cNoError; Result := True;
    end else begin
      IErr := Trunc( TableValue ); Result := False;
    end;
  end;
  Function SetCc( const H1, Kh: Double; var IErr: Integer ): Boolean;
  var
    cA,               {-Contractiefactor cA (-)}
    TableValue: Double;
  begin
    with TDbleMtrxColAndRowIndx( EP[ cEP0 ].xInDep.Items[ cTb_cA ] ) do
      TableValue := GetValueByLinearInterpolation( H1/cStuwBreedte, Kh );
    if ( TableValue > 0 ) then begin
      cA   := TableValue;
      Cc   := ( cStuwBreedte - ( cA * cAantOphangArmen * cBreedteOphangArm ) ) / cStuwBreedte;
      IErr := cNoError; Result := True;
    end else begin
      IErr := Trunc( TableValue ); Result := False;
    end;
  end;
  Function SetCdr( const S, Kh: Double; var IErr: Integer ): Boolean;
  var
    TableValue: Double;
  begin
    Result := True; IErr := cNoError;
    if ( S <= 0 ) then begin {-Ongestuwde afvoer (Ws2 <= Kr)}
      Cdr := 1;
    end else begin           {-Gestuwde afvoer (Ws2 > Kr)}
      with TDbleMtrxColAndRowIndx( EP[ cEP0 ].xInDep.Items[ cTb_Cdr ] ) do
        TableValue := GetValueByLinearInterpolation( S, Kh );
      if ( TableValue > 0 ) then begin
        Cdr   := TableValue;
        IErr := cNoError; Result := True;
      end else begin
        IErr := Trunc( TableValue ); Result := False;
      end;
    end;
  end;
begin
  IErr   := cNoError;
  Qs     := 0;
  Result := True;
  if ( Ws2 >= Ws1 )   then Exit; {-Geen terugstroom door de stuw toegestaan}
  if ( Kr > cMax_Kr ) then Exit; {-Sluis is gesloten}
  H1 := Ws1 - Kr;
  if ( H1 <= TinyH1 ) then Exit;    {-Er is onvoldoende overstorthoogte aanwezig}
  if ( H1 > cH1Max ) then begin
    IErr := cH1Exceeded; Result := False; Exit;
  end;
  if ( not SetKh( Kr, IErr ) ) then begin Result:= False; Exit; end;
  if ( not SetCd( H1, Kh, IErr ) ) then begin Result:= False; Exit; end;
  if ( not SetCc( H1, Kh, IErr ) ) then begin Result:= False; Exit; end;
  H2 := Ws2 - Kr;
  S  := 100 * H2 / H1;
  if ( not SetCdr( S, Kh, IErr ) ) then begin Result:= False; Exit; end;
  Qs := 3.58028 * Cd * Cc * Cv * Cdr * Power( H1, 1.5 )
            * NrOfSecondsInAday / cAfwOpp; {-m/d}
end; {-Function Calc_Qs}

Function Calc_Qpump( const Ws1, Ws1_gewenst: Double; var IErr: Integer ): Boolean;
begin
  Result := True;
  IErr   := cNoError;
  if ( ( Ws1 > Ws1_gewenst ) and ( PumpCap > 0 ) ) then
    Qpump := PumpCap
  else
    Qpump := 0;
end;

begin
  IErr := cUnknownError;
  for i := 1 to cNrOfDepVar do {-Default speed = 0}
    dydx[ i ] := 0;

  {-Geef de aanroepende procedure een handvat naar het ModelProfiel}
  if ( nDC > 0 ) then
    aModelProfile := @ModelProfile
  else
    aModelProfile := NIL;

  if ( Context = UpdateYstart ) then begin {-Run fase 1}
    if not SetParValuesFromEP0( IErr ) then Exit;
    if not Replace_InitialValues_With_ShellValues( IErr )then Exit; {-Bepaal y[cBerging] op basis van Ws1_Init}

    IErr := cNoError;
  end else begin {-Run fase 2}

    if not SetKeyAndParValues( IErr ) then {-Sbcode, Q, Ws1_gewenst}
      Exit;
    Berging := y[ cBerging ];     {-Berging in waterlopen en op maaiveld (m)}
    Ws1     := GetWs1( Berging, IErr ); {-Bijbehorende binnenwaterstand (m+NAP)}
    if ( IErr <> cNoError ) then
      Exit;

    Ws2     := GetWs2 ( x );      {-Buitenwaterstand (m+NAP)}

    if ( Sbcode <> cSBC_Closed ) then begin
      Kr      := GetKr( Ws1, Ws2, Ws1_gewenst, Q, Sbcode ); {-Kruinhoogte (m+NAP)}
      if not Calc_Qs( Ws1, Ws2, Kr, IErr ) then {-Afvoer door de stuw (m/d)}
        Exit;
    end else
      Qs := 0;

    if not Calc_Qpump( Ws1, Ws1_gewenst, IErr ) then {-Hoeveelheid door gemaal uitgeslagen water (m/d)}
      Exit;

    {-Bereken de array met afgeleiden 'dydx'.
	  Gebruik hierbij 'DCfunc' van 'ModelProfile' i.p.v.
	  'if'-statements! Als hierbij de 'AsSoonAs'-optie
	  wordt gebruikt, moet de statement worden aangevuld
	  met een extra conditie ( Context = Trigger ). Dus
	  bijv.: if DCfunc( AsSoonAs, h, LE, BodemNiveau, Context, cDCfunc0 )
	     and ( Context = Trigger ) then begin...}

    dydx[ cBerging ]  := ( Q + Kwel ) - ( Qs + Qpump );
    dydx[ cCumQs ]    := Qs;
    dydx[ cCumWs1 ]   := Ws1;
    dydx[ cCumKwel ]  := Kwel;
    dydx[ cCumQpump ] := Qpump;

  end;
end; {-DerivsProc}

Function DefaultBootEP( const EpDir: String; const BootEpArrayOption: TBootEpArrayOption; var EP: TExtParArray ): Integer;
  {-Initialiseer de meest elementaire gegevens van het model. Shell-gegevens worden door deze
    procedure NIET verwerkt}
Procedure SetMinMaxKeyAndParValues;
begin
  with EP[ cEP0 ].xInDep.Items[ cTb_MinMaxValKeys ] do begin
    cMin_Q           :=        GetValue( 1, 1 ); {rij, kolom}
    cMax_Q           :=        GetValue( 1, 2 );
    cMin_Kr          :=        GetValue( 1, 3 );
    cMax_Kr          :=        GetValue( 1, 4 );
    cMin_SbCode      := Trunc( GetValue( 1, 5 ) );
    cMax_SbCode      := Trunc( GetValue( 1, 6 ) );
    cH1Max           :=        GetValue( 1, 7 );
    cMin_Kwel        :=        GetValue( 2, 1 );
    cMax_Kwel        :=        GetValue( 2, 2 );
    cMin_PumpCap     :=        GetValue( 2, 3 );
    cMax_PumpCap     :=        GetValue( 2, 4 );
  end;
end;
Begin
  Result := DefaultBootEPFromTextFile( EpDir, BootEpArrayOption, cModelID, cNrOfDepVar, nDC, cNrXIndepTblsInEP0,
                                       cNrXdepTblsInEP0, Indx, EP );
  if ( Result = cNoError ) then begin
    SetMinMaxKeyAndParValues;        {-Behalve cMin_Ws1 en cMax_Ws1}
  end;
end;

Function TestBootEP( const EpDir: String; const BootEpArrayOption: TBootEpArrayOption; var EP: TExtParArray ): Integer;
  {-Deze boot-procedure verwerkt alle basisgegevens van het model en leest de Shell-gegevens
    uit een bestand. Na initialisatie met deze boot-procedure is het model dus gereed om
	'te draaien'. Deze procedure kan dus worden gebruikt om het model 'los' van de Shell te
	testen}
Begin
  Result := DefaultBootEP( EpDir, BootEpArrayOption, EP );
  if ( Result <> cNoError ) then
    exit;
  Result := DefaultTestBootEPFromTextFile( EpDir, BootEpArrayOption, cModelID, cnRP + cnSQ + cnRQ, Indx, EP );
  if ( Result <> cNoError ) then
    exit;
  SetReadyToRun( EP);
end;

Function BootEPForShell( const EpDir: String; const BootEpArrayOption: TBootEpArrayOption; var EP: TExtParArray ): Integer;
  {-Deze procedure maakt het model gereed voor Shell-gebruik.
    De xDep-tables in EP[ indx-1 ] worden door deze procedure NIET geinitialiseerd omdat deze
	gegevens door de Shell worden verschaft }
begin
  Result := DefaultBootEP( EpDir, cBootEPFromTextFile, EP );
  if ( Result = cNoError ) then
    Result := DefaultBootEPForShell( cnRP, cnSQ, cnRQ, Indx, EP );
end;

Exports DerivsProc       index cModelIndxForTDSmodels, {999}
        DefaultBootEP    index cBoot0, {1}
        TestBootEP       index cBoot1, {2}
        BootEPForShell   index cBoot2; {3}

begin
  {-Dit zgn. 'DLL-Main-block' wordt uitgevoerd als de DLL voor het eerst in het geheugen wordt
    gezet (Reason = DLL_PROCESS_ATTACH)}
  DLLProc := @MyDllProc;
  Indx := cBootEPArrayVariantIndexUnknown;
  if ( nDC > 0 ) then
    ModelProfile := TModelProfile.Create( nDC );
end.
