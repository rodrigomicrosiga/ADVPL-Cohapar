#INCLUDE "CNTA100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"

//Situacoes de contrato
#DEFINE DEF_SCANC "01" //Cancelado
#DEFINE DEF_SELAB "02" //Em Elaboracao
#DEFINE DEF_SEMIT "03" //Emitido
#DEFINE DEF_SAPRO "04" //Em Aprovacao
#DEFINE DEF_SVIGE "05" //Vigente
#DEFINE DEF_SPARA "06" //Paralisado
#DEFINE DEF_SSPAR "07" //Sol Fina.
#DEFINE DEF_SFINA "08" //Finalizado
#DEFINE DEF_SREVS "09" //Revisao
#DEFINE DEF_SREVD "10" //Revisado


//Tipos de Revisao
#DEFINE DEF_ADITI "1" //Aditivo
#DEFINE DEF_REAJU "2" //Reajuste
#DEFINE DEF_REALI "3" //Realinhamento
#DEFINE DEF_READQ "4" //Readequacao
#DEFINE DEF_PARAL "5" //Paralisacao
#DEFINE DEF_REINI "6" //Reinicio
#DEFINE DEF_CLAUS "7" //Alteracao de Clausula

#DEFINE DEF_TRANS "001" //Transacao de controle total do contrato
#DEFINE DEF_TRASIT "018"//Transacao de controle de situacoes
#DEFINE DEF_TRAVIS "037"//Transacao de visualizacao do contrato
#DEFINE DEF_TRABCO "038"//Transacao de controle sobre o banco de conhecimento
#DEFINE DEF_TRAEDT "039"//Transacao de controle sobre a edicao do contrato   
#DEFINE DEF_TRARET "040"//Transacao de controle sobre a baixa da retencao

#DEFINE FLD_BAIXA "BAIXA"//Campo de baixa da retencao
#DEFINE FLD_SALDO "SALDO"//Campo de saldo da retencao
#DEFINE FLD_PLANI "PLANI"//Campo de planilha da retencao

STATIC lCn100BxRet := Iif(Existblock("CN100BxRet"),.T.,.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNTA100  ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Contratos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA100()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CNTA100()
Local aCores := {	{ "Alltrim(CN9->CN9_SITUAC) == '01'", "BR_VERMELHO" },;		// Cancelado
					{ "Alltrim(CN9->CN9_SITUAC) == '02'", "BR_AMARELO"	 },;	// Elaboracao
					{ "Alltrim(CN9->CN9_SITUAC) == '03'", "BR_AZUL"		 },;	// Emitido
					{ "Alltrim(CN9->CN9_SITUAC) == '04'", "BR_LARANJA"	 },;	// Em Aprovacao
					{ "Alltrim(CN9->CN9_SITUAC) == '05'", "BR_VERDE"	 },;	// Vigente
					{ "Alltrim(CN9->CN9_SITUAC) == '06'", "BR_CINZA"	 },;	// Paralisado
					{ "Alltrim(CN9->CN9_SITUAC) == '07'", "BR_MARRON"	 },;	// Sol. Finalizacao
					{ "Alltrim(CN9->CN9_SITUAC) == '08'", "BR_PRETO"	 },;	// Finalizado
					{ "Alltrim(CN9->CN9_SITUAC) == '09'", "BR_PINK"		 },;	// Revisao   
					{ "Alltrim(CN9->CN9_SITUAC) == '10'", "BR_BRANCO"	 }}		// Revisado
					
Local aIndexCN9 := {}
Local  cFiltro  := ""
Local  cCn100Fil:= ""             
Local  lCN100FIB:=ExistBlock("CN100FIB")
Local  cCn100Fib:= "" 
Local lCn100Cor := ExistBlock("CN100COR")
Local aCorUsr	:= {}

Private cCadastro := OemToAnsi(STR0001) //Manutencao de Contratos
Private lVal	  := .T.
Private aRotina   := MenuDef()      
Private bFiltraBrw:= {|| Nil }      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra MBrowse  			                   	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN100FIL")
	cCn100Fil := ExecBlock("CN100FIL",.F.,.F.)
	If ( ValType(cCn100Fil) == "C" ) .And. !Empty(cCn100Fil)
		cFiltro := cCn100Fil
	EndIf
EndIf
If !Empty(cFiltro)
	bFiltraBrw := {|| FilBrowse("CN9",@aIndexCN9,@cFiltro) }
	Eval(bFiltraBrw)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mostra Lancamentos   S/N                          ³
//³ mv_par02 - Aglut Lancamentos    S/N                          ³
//³ mv_par03 - Lancamentos Online   S/N                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F12,{|| Pergunte("CNT100",.T.)})

Pergunte("CNT100",.F.)                      

If lCn100Cor
	aCorUsr := ExecBlock("CN100COR",.F.,.F.,{aCores})
   	If ( ValType(aCorUsr) == "A" )
		aCores := aClone(aCorUsr)
	EndIf
EndIf

mBrowse(6,1,22,75,"CN9",,,,,,aCores,,,,,,,,iIf(lCN100FIB,cCn100Fib :=ExecBlock("CN100FIB",.F.,.F.),))

SetKey( VK_F12 , Nil )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CNTA100Cron³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina que realiza chamada para o Wizard de cronogramas     ³±±
±±³          ³ CN110                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA100Cron(nExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Cron(nOpc)
Local aArea := GetArea()

dbSelectArea("CNF")
dbSetOrder(2)
If dbSeek(xFilial("CNF")+M->CN9_NUMERO+M->CN9_REVISA)
	CN110Manut("CNF",CNF->(Recno()),nOpc,,M->CN9_NUMERO,M->CN9_REVISA)

	//Atualiza Folder CNF
	CN100LdAl(nOpc,"CNF",aCols4,aHeader4,"CNF.CNF_CONTRA = '"+ M->CN9_NUMERO +"' AND CNF.CNF_REVISA = '"+ M->CN9_REVISA +"'",{"CNF_NUMERO","CNF_PARCEL"},oGetDad4,{"CNF_CONTRA","CNF_REVISA"})

	oGetDad4:aCols := aCols4
Else
	Aviso("CNTA100",OemtoAnsi(STR0138),{"Ok"})//"O contrato não possui cronograma financeiro/físico"
EndIf

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Manut ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de manutencao de contrato                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CN100Manut(cExp01,nExp02,nExp03,lExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Alias                                              ³±±
±±³          ³ nExp02 - Registro atual                                     ³±±
±±³          ³ nExp03 - Opcao atual                                        ³±±
±±³          ³ lExp04 - Indica se o usuario podera VISUALIZAR o contrato   ³±±
±±³          ³ 			mesmo sem ter acesso ao mesmo. Esse parametro e	   ³±±
±±³          ³ 			enviado como .T. exclusivamente pela rotina de 	   ³±±
±±³          ³ 			liberacao (MATA097), e somente quando o documento  ³±±
±±³          ³ 			e do tipo CT (Contrato) e o Aprovador nao possui   ³±±
±±³          ³ 			acesso ao contrato.								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Manut(cAlias,nReg,nOpc,lVisAprCt)

Local aSize      := MsAdvSize()
Local aPosObj    := {}
Local aObjects   := {}
Local aArea      := GetArea()
Local aTitles    := {}
Local aCpos      := {}
Local aCposAlt   := {}
Local aCposRet   := {}
Local aButtons   := {}
Local aCN100ENH  := {}
Local lPrjCni    := FindFunction("ValidaCNI") .And. ValidaCNI()
Local nGd1       := 0
Local nGd2       := 0
Local nGd3       := 0
Local nGd4       := 0
Local nOpcA      := 0
Local nX

Local lMedEve    := .F.  //Med. Enventual
Local lContinua  := .T.   
Local lRet       := .T.
Local lAntInc
Local lContraVld := ExistBlock("CN100VLD")
Local lC100VlAt  := ExistBlock("C100VLAT")     
Local lCN100ENH  := ExistBlock("CN100ENH")

Local oDlg

// criacao da tela de Tipo de contrato
Local oDlg2
Local oFnt2
Local oFnt22
Local oFnt32
Local oGroup2
Local oGet012
Local cTitulo2 := STR0116// "Tipo de Contrato"

//Campos nao exibidos para o contrato
Local aCpoN    := {}

//Planilhas
Local aPlani     := {}
Local aPlIt      := {}   
Local aHeaderCNB := {} //Armazena cabecalho da itens de planilha

//Rateio dos itens das Planilhas de contrato
Local aRatCNZ	 := {}
Local lAltPla    := (nOpc == 3 .Or. nOpc == 4)

Local lCaucRet   := (nOpc != 3 .And. (CN9->( FieldPos("CN9_TPCAUC") ) > 0) .And. CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "2")
Local nFldRet    := 0
Local nFldCtb    := 0
Local nOpcTp     := 1

//Controle da numeracao sequencial
Local nStack     := GetSX8Len()
Local nQtdVend   := Min(CntQtdVend("SC5"),CntQtdVend("SC6"))

Local aUsButtons := {}  
Local aCN100FLD  := {}

Local lCn100Fol	 := ExistBlock("CN100FOL")
Local lCN100FLD  := ExistBlock("CN100FLD")
Local lRetVis    := .F.

lVisAprCt := (lVisAprCt != Nil .AND. lVisAprCt != .F.)	//DEFAULT

nQtdVend := Min(CntQtdVend("SE1"),nQtdVend)

dbSelectArea("CN9")

If nOpc != 3 .And. !Empty(CN9->CN9_NUMERO)	
	lContinua := CN240VldUsr(CN9->CN9_NUMERO,If(nOpc==2,DEF_TRAVIS,DEF_TRAEDT),.T.,lVisAprCt)
EndIf

If nOpc == 5 .And. CN9->(FieldPos("CN9_CODED")) > 0 .And. !Empty(CN9->CN9_CODED)
	Help(" ",1,"CNT100EDITAL")//"Contrato não pode ser excluido pois foi gerado por edital"
	lContinua := .F.
EndIf

If lContinua
	PRIVATE lContab  := .T.
	
	PRIVATE aTela    := {}
	PRIVATE aGets    := {}
    PRIVATE Acols    := {}
    
    PRIVATE cEspCtr  := Space(TamSX3("CN1_ESPCTR")[1])
    PRIVATE cCodigo  := Space(TamSX3("CN1_CODIGO")[1])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montando a Tela de Pergunta para o tipo de contrato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc =3
		DEFINE MSDIALOG oDlg2 TITLE OemtoAnsi(cTitulo2) FROM  165,115 TO 245,430 PIXEL
		@ 5, 10 SAY OemToAnsi(cTitulo2) SIZE 60, 8 OF oDlg2 PIXEL
		@ 5,70  MSGET oGet012 VAR cCodigo PICTURE "@!" F3 "CN1" SIZE 25,9 VALID cnt100VTP() .And. ExistCpo("CN1", cCodigo ) OF oDlg2 PIXEL
		DEFINE SBUTTON FROM 25, 93 TYPE 1 ACTION (if(!empty(cCodigo),oDlg2:End(),)) ENABLE OF oDlg2
		DEFINE SBUTTON FROM 25, 123 TYPE 2 ACTION (cCodigo:="",oDlg2:End(),nOpcTp := 2) ENABLE OF oDlg2
		ACTIVATE MSDIALOG oDlg2
		
		CN1->( dbSetOrder(1) )
		CN1->( dbSeek(xFilial("CN1")+cCodigo) )
		
		cEspCtr := If(!Empty(CN1->CN1_ESPCTR),CN1->CN1_ESPCTR,"1")
		If  nOpcTp = 2  .Or. Empty(cCodigo)// cancelando a inclusao
			lContinua := .F.
		Endif
		
	Else
		CN1->( dbSetOrder(1) )
		CN1->( dbSeek(xFilial("CN1")+CN9->CN9_TPCTO) )
		cEspCtr := If(!Empty(CN1->CN1_ESPCTR),CN1->CN1_ESPCTR,"1")
	EndIf
		
	If lContinua
		//Verifica se o contrato possui controle contabil
		lContab := (CN1->CN1_CROCTB == "1")
		
		If cEspCtr =="1"
			aTitles    := {OemtoAnsi(STR0008),OemtoAnsi(STR0009),OemtoAnsi(STR0010),OemtoAnsi(STR0011),OemtoAnsi(STR0012),OemtoAnsi(STR0062)}//"Fornecedores"##"Caucoes"##Planilhas"##"Cronogramas"##"Multas"##"Documentos"
			aCpoN      := {"CN9_JUSTIF","CN9_DESSTA","CN9_TIPREV","CN9_MOTPAR","CN9_DTFIMP","CN9_DTREIN","CN9_DTREAJ","CN9_VLREAJ","CN9_NUMTIT","CN9_ALTCLA","CN9_VLMEAC","CN9_TXADM","CN9_FORMA","CN9_DTENTR","CN9_LOCENT","CN9_CODENT","CN9_DESLOC","CN9_DESFIN","CN9_CONTFI","CN9_DTINPR","CN9_PERPRO","CN9_UNIPRO","CN9_VLRPRO","CN9_DTINCP","CN9_CLIENT","CN9_LOJACL"}
		Else
			aTitles    := {OemtoAnsi(STR0115),OemtoAnsi(STR0009),OemtoAnsi(STR0010),OemtoAnsi(STR0011),OemtoAnsi(STR0012),OemtoAnsi(STR0062)}//"Vendedores"##"Caucoes"##Planilhas"##"Cronogramas"##"Multas"##"Documentos"
			aCpoN      := {"CN9_JUSTIF","CN9_DESSTA","CN9_TIPREV","CN9_MOTPAR","CN9_DTFIMP","CN9_DTREIN","CN9_DTREAJ","CN9_VLREAJ","CN9_NUMTIT","CN9_ALTCLA","CN9_VLMEAC","CN9_TXADM","CN9_FORMA","CN9_DTENTR","CN9_LOCENT","CN9_CODENT","CN9_DESLOC","CN9_DESFIN","CN9_CONTFI","CN9_DTINPR","CN9_PERPRO","CN9_UNIPRO","CN9_VLRPRO","CN9_DTINCP"}
		Endif
		
		Private oFolder
		
		//Controles do fornecedor - CNC ou Vendedores
		Private aHeader1  := {}
		Private aCols1    := {}
		Private oGetDad1
		
		//Controles da caucao - CN8
		Private aHeader2  := {}
		Private aCols2    := {}
		Private oGetDad2
		
		//Controles das planilhas - CNA
		Private aHeader3  := {}
		Private aCols3    := {}
		Private oGetDad3
		
		//Controles dos cronogramas - CNF
		Private aHeader4  := {}
		Private aCols4    := {}
		Private oGetDad4
		
		//Controles das multas - CNA
		Private aHeader5  := {}
		Private aCols5    := {}
		Private oGetDad5
		
		//Controles dos documentos - CNK
		Private aHeader6  := {}
		Private aCols6    := {}
		Private oGetDad6	
		
		//Adiantamentos de Contratos CNX
		Private aHeader7  := {}
		Private aCols7    := {}
		Private oGetDad7
		aAdd(aTitles,STR0118)//Adiantamento
		
		//Cronogramas Contabeis
		If lContab
			Private aHeader8  := {}
			Private aCols8    := {}
			Private oGetDad8
			aAdd(aTitles,STR0137)//Cronog. Ctb.

			nFldCtb := len(aTitles)//Posicao da folder contabil
		EndIf
		
		If lCaucRet
			//Caucões Retidas
			Private aHeader9  := {}
			Private aCols9    := {}
			Private oGetDad9
			Private nTotBaix  := 0
			Private oTotBaix
			aAdd(aTitles,STR0086)//"Caucões Retidas"

			nFldRet := len(aTitles)//Posicao da folder de retencao
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle para verificacao da estrutura do campo    ³
		//³ CNK_CONTRA                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(2)
		
		CN170AjSX3()
		
		//Verifica se o contrato possui revisao
		If (nOpc == 4 .OR. nOpc == 5) .And. !Empty(CN9->CN9_REVATU)
			Help(" ",1,"CNTA100REV") //"Contrato revisado"
			Return .F.
		EndIf
		
		If lC100VlAt .And. nOpc == 4
			If !(ValType(uRet:=ExecBlock("C100VLAT",.F.,.F.,{CN9->CN9_SITUAC}))=="L" .And. uRet==.T.)
				Help(" ",1,"CNTA100ELB") //"Acao disponivel apenas para contratos em Elaboracao"
				Return .F.
			EndIf
		ElseIf (nOpc == 4 .OR. nOpc == 5) .And. !AllTrim(CN9->CN9_SITUAC) $ DEF_SELAB
			Help(" ",1,"CNTA100ELB") //"Acao disponivel apenas para contratos em Elaboracao"
			Return .F.
		EndIf
		         
		if lPrjCni
			//Caio.Santos - FSW - 26/03/2012 - Validacao da exclusao de contrato proveniente de SC de aditivo de contrato
			If (nOpc == 5) .And. (AllTrim(CN9->CN9_XSC) == "1") .And. !Empty(CN9->CN9_XSCORI)
				Aviso("CNTA100",OemtoAnsi("Contrato gerado por SC de aditivo não pode ser excluído."),{"Ok"})
				Return .F.
			EndIf  
		EndIf
		
		dbSelectArea("SX3")
		MsSeek("CN9")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona os campos do cabecalho dos contratos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		While !Eof() .And. SX3->X3_ARQUIVO == "CN9"
			
			If X3Uso(X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. Ascan(aCpoN,{|x| x == alltrim(SX3->X3_CAMPO)}) == 0
				Aadd(aCpos, SX3->X3_CAMPO )
			EndIF
			
			If	( SX3->X3_CONTEXT == "V"  .Or. nOpc == 3  )
				M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
			Else
				M->&(SX3->X3_CAMPO) := CN9->(FieldGet(FieldPos(SX3->X3_CAMPO)))
			EndIf
			
			dbSelectArea("SX3")
			dbSkip()
		EndDo
		If nOpc = 3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizando o campo Tipo de contrato    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M->CN9_TPCTO :=cCodigo
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos Memo do Contrato³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		M->CN9_OBJCTO := MSMM(M->CN9_CODOBJ)
		If nOpc != 3
			M->CN9_JUSTIF := MSMM(M->CN9_CODJUS)
			Aadd(aCpos,"CN9_JUSTIF")
		EndIF
		M->CN9_ALTCLA := MSMM(M->CN9_CODCLA)
		Aadd(aCpos,"CN9_ALTCLA")    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para customizar a enchoice		     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCN100ENH
			aCN100ENH:= ExecBlock("CN100ENH",.F.,.F.,{aCpos})
			If ValType(aCN100ENH) == "A" 
				aCpos    := aClone(aCN100ENH)
			Endif	
		EndIf
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem dos acols e aheaders dos folders 		     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CN100Acols(nOpc,lCaucRet,nFldRet)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa ponto de entrada apos a gravacao do contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lCN100FLD
			aCN100FLD:= ExecBlock("CN100FLD",.F.,.F.,{aPlani,aPlit,aHeader3,aCols3,aHeaderCNB,nOpc})
			If ValType(aCN100FLD) == "A" 
				If Len(aCN100FLD)>=1 .And. ValType(aCN100FLD[1]) == "A"
					aPlani    := aCN100FLD[1]
				Endif	
				If Len(aCN100FLD)>=2 .And. ValType(aCN100FLD[2]) == "A"
					aPlit     := aCN100FLD[2]
				Endif	      
				If Len(aCN100FLD)>=3 .And. ValType(aCN100FLD[3]) == "A"
					aHeader3  := aCN100FLD[3]
				Endif
				If Len(aCN100FLD)>=4 .And. ValType(aCN100FLD[4]) == "A"
					aCols3    := aCN100FLD[4]
				Endif						
				If Len(aCN100FLD)>=5 .And. ValType(aCN100FLD[5]) == "A"
					aHeaderCNB:= aCN100FLD[5]
				Endif 
			EndIf
		EndIf
	
		SETAPILHA()
		
		//Configura botoes de acesso ao cronograma e planilhas na alteracao
		If nOpc == 4
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o contrato tem medicao eventual 	     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lMedEve := (Posicione("CN1",1,xFilial("CN1")+M->CN9_TPCTO,"CN1_MEDEVE") == "1")
			If !lMedEve//Exibe o botao de cronograma quando o contrato nao for de med. eventual
				Aadd(aButtons,{"BUDGET"   ,{|| CN100Cron(nOpc)},OemToAnsi(STR0015),OemtoAnsi(STR0054)})//"Cronogramas"
			EndIf
		EndIf
		Aadd(aButtons,{"NOTE",{|| CN100Hist(M->CN9_NUMERO)},OemtoAnsi(STR0034)})//"Historico"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Botao para exportar dados para EXCEL                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FindFunction("RemoteType") .And. RemoteType() == 1
			aAdd(aButtons   , {PmsBExcel()[1],{|| DlgToExcel({ {"ENCHOICE",STR0036,aGets,aTela},{"GETDADOS",OemToAnsi(STR0008),aHeader1,aCols1},{"GETDADOS",OemToAnsi(STR0009),aHeader2,aCols2},{"GETDADOS",OemToAnsi(STR0014),aHeader3,aCols3},{"GETDADOS",OemToAnsi(STR0011),aHeader4,aCols4},{"GETDADOS",OemToAnsi(STR0012),aHeader5,aCols5} })},PmsBExcel()[2],PmsBExcel()[3]})
		EndIf
		
		If aRotina[ nOpc, 4 ] == 2
			AAdd(aButtons,{ "clips", {|| CN100Conh()  }, STR0056, STR0057 } ) // "Banco de Conhecimento"##"Conhecim."
			AAdd(aButtons,{ "bmpord1",   {|| CN100Track() }, STR0059, STR0060 } ) // "System Tracker"##"Tracker"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia botoes do usuario                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "CN100BUT" ) 
			If ValType( aUsButtons := ExecBlock( "CN100BUT", .F., .F., {nOpc} ) ) == "A"
				AEval( aUsButtons, { |x| AAdd( aButtons, x ) } ) 	 	
			EndIf 	
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa integracao com o PCO      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRotina[ nOpc, 4 ] == 3
			PcoIniLan("000354")
		EndIf		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para permitir a alteração dos campos    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 4 .And. AllTrim(CN9->CN9_SITUAC) == DEF_SREVS
			If ExistBlock( "CN100GET" ) 
				cTipRev := Posicione("CN0",1,xFilial("CN0")+M->CN9_TIPREV,"CN0_TIPO")
				If ValType( aCposRet := ExecBlock( "CN100GET", .F., .F., {cTipRev} ) ) == "A"
					AEval( aCposRet, { |x| AAdd( aCposAlt, x ) } ) 	 	
				EndIf 	
			EndIf
		EndIf		
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Tela Principal										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		aAdd( aObjects, {   0, 119, .t., .t. } )
		aAdd( aObjects, { 120, 101, .t., .t. } )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
		
		EnChoice( cAlias, nReg, nOpc, , , ,aCpos, aPosObj[1],IF(Len(aCposAlt)>0,aCposAlt,), , , , , , , .T.)
		oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,,oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define as posicoes da Getdados a partir do folder    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nGd1 := 2
		nGd2 := 2
		nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
		nGd4 := aPosObj[2,4]-aPosObj[2,2]-2
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta folder das multas (CNH) permitindo insercao    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad5 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,IIF(nOpc!=3 .And. nOpc!=4,0,GD_INSERT+GD_UPDATE+GD_DELETE),"CN100VldMul()",,,,,,,,,oFolder:aDialogs[5],aHeader5,aCols5)
		DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[5]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta folder dos cronogramas                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad4 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[4],aHeader4,aCols4)
		DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[4]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta folder das planilhas                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad3 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[3],aHeader3,aCols3)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada que permite ou não exibir o botão visualizar planilha            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ExistBlock("CN100VPL"))
			lRetVis := ExecBlock("CN100VPL",.F.,.F.,{nOpc})
			If ValType( lRetVis ) == "L"
				lRet := lRetVis
			EndIf
		EndIf
				
		If lRet
			DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(nOpc,aPlani,aPlIt,lVisAprCt) ENABLE OF oFolder:aDialogs[3]//Visualizar
		EndIf
		
		@ nGd3-12 ,nGd4-119 BUTTON OemToAnsi(STR0007) SIZE 29 ,13  FONT oDlg:oFont WHEN lAltPla ACTION If(nOpc==3,CN100IncArr(nOpc,aPlani,aPlIt,aHeaderCNB,aRatCNZ),CN100IncPla(aRatCNZ)) OF oFolder:aDialogs[3] PIXEL//Incluir
		@ nGd3-12 ,nGd4-89  BUTTON OemToAnsi(STR0083) SIZE 29 ,13  FONT oDlg:oFont WHEN lAltPla .AND. Len(ogetDad3:aCols) > 0 .AND. !Empty(ogetDad3:aCols[1][1]) ACTION If(nOpc==3,CN100AltArr(4,aPlani,aPlIt,aHeaderCNB,aRatCNZ),CN100AltPla(4,aRatCNZ)) OF oFolder:aDialogs[3] PIXEL//Editar
		@ nGd3-12 ,nGd4-59  BUTTON OemToAnsi(STR0006) SIZE 29 ,13  FONT oDlg:oFont WHEN lAltPla .AND. Len(ogetDad3:aCols) > 0 .AND. !Empty(ogetDad3:aCols[1][1]) ACTION If(nOpc==3,CN100AltArr(5,aPlani,aPlIt,aHeaderCNB,aRatCNZ),CN100AltPla(5,aRatCNZ)) OF oFolder:aDialogs[3] PIXEL//Excluir
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta folder das caucoes                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad2 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[2],aHeader2,aCols2)
		DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[2]
		
		If cEspCtr =="1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta folder dos fornecedores, permitindo insercao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGetDad1 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,IIF(nOpc!=3 .And. nOpc!=4,0,GD_INSERT+GD_UPDATE+GD_DELETE),"CN100VldFor()",,,,,999,,,"CN100DelFor()",oFolder:aDialogs[1],@aHeader1,@aCols1)
			DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[1]
			@ nGd3-12 ,nGd4-59  BUTTON OemToAnsi(STR0082) SIZE 29 ,13  FONT oDlg:oFont ACTION CN220Aval("CNU",nReg,nOpc,,.T.,,oGetDad1:aCols[oGetDad1:nAt,aScan(oGetDad1:aHeader,{|x| AllTrim(x[2]) == "CNC_CODIGO"})],oGetDad1:aCols[oGetDad1:nAt,aScan(oGetDad1:aHeader,{|x| AllTrim(x[2]) == "CNC_LOJA"})]) OF oFolder:aDialogs[1] PIXEL
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta folder Dos vendedores                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGetDad1 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,IIF(nOpc!=3 .And. nOpc!=4,0,GD_INSERT+GD_UPDATE+GD_DELETE),"CN100VldVen()",,,,,nQtdVend,,,"CN100DelVen()",oFolder:aDialogs[1],@aHeader1,@aCols1)
			DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual() ENABLE OF oFolder:aDialogs[1]
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta folder de visualizacao de documentos           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad6 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[6],@aHeader6,@aCols6)
		DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[6]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta folder Dos  Adiantamentos                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad7 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[7],aHeader7,aCols7)
		DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[7]
		@ nGd3-12 ,nGd4-59  BUTTON OemToAnsi(STR0006) SIZE 29 ,13  FONT oDlg:oFont WHEN (nOpc==2 .And. CN9->CN9_SITUAC == DEF_SVIGE) ACTION If(nOpc==2,CN100CtAdDel(),) OF oFolder:aDialogs[7] PIXEL//Excluir

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe cronogramas contabeis   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lContab
			oGetDad8 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[8],@aHeader8,@aCols8)
			DEFINE SBUTTON FROM nGd3-12,nGd4-29 TYPE 15 ACTION CN100Visual(,,,lVisAprCt) ENABLE OF oFolder:aDialogs[8]
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe retencoes de caucao     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lCaucRet
			oGetDad9 := MsNewGetDados():New(nGd1,nGd2,nGd3-13,nGd4,0,,,,,,,,,,oFolder:aDialogs[nFldRet],@aHeader9,@aCols9)
			@ nGd3-12 ,nGd4-35  BUTTON STR0114 SIZE 35 ,13  FONT oDlg:oFont ACTION CN100BxCauc(.T.) WHEN nOpc # 2 OF oFolder:aDialogs[nFldRet] PIXEL//"Baixar"
		Endif
		
		If lCn100Fol
			ExecBlock("CN100FOL",.F.,.F.,{nOpc})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui linha em branco das getdados de visualizacao  ³
		//³ quando nao houver informacao                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aCols4) == 0
			aDel(oGetDad4:aCols,1)
			aSize(oGetDad4:aCols,0)
		EndIf
		If Len(aCols3) == 0
			aDel(oGetDad3:aCols,1)
			aSize(oGetDad3:aCols,0)
		EndIf
		If Len(aCols2) == 0
			aDel(oGetDad2:aCols,1)
			aSize(oGetDad2:aCols,0)
		EndIf
		
		oFolder:bSetOption:={|nAtu| CN100FoldCh(nAtu,oFolder:nOption,nFldCtb)}
		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela) .And. CN100Valida() .And. If(cEspCtr=="1",CN100VldFor(),CN100VldVen()) .And. If(nOpc!=3 .And. nOpc!=2,CN100VldMul() .And. CN100TudOk()  .And. CN100VldPla(aPlani) .And. CN100VldPer(),.T.) .And. If (lContraVld, ExecBlock("CN100VLD",.F.,.F.), .T.),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||(nOpcA:=2,oDlg:End())},,aButtons))
		
		If nOpcA == 1 .And. nOpc != 2
			
			//Atualiza aCols
			aCols1 := oGetDad1:aCols
			aCols5 := oGetDad5:aCols
			
			CN100Grv(nOpc,aPlani,aPlIt,aHeaderCNB,aRatCNZ)//passar o array de rateio
			
			While GetSX8Len() > nStack
				ConfirmSX8()
			EndDo
			EvalTrigger()
			msUnlockAll()
			
			//Atualiza campos MEMO
			If nOpc != 5
				MSMM(M->CN9_CODOBJ,,,M->CN9_OBJCTO,1,,,"CN9","CN9_CODOBJ")
				MSMM(M->CN9_CODCLA,,,M->CN9_ALTCLA,1,,,"CN9","CN9_CODCLA")
			EndIf  
			
	 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  		//³ Ponto de entrada executado após a gravação dos campos tipo memo do Contrato     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistBlock("CN100PMEM"))
				ExecBlock("CN100PMEM",.F.,.F.,{nOpc})   
			EndIf				       
			
		Else           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada para verificar se foi acionado o botão Cancelar no Contrato   	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistBlock("CN100CAN"))
				ExecBlock("CN100CAN",.F.,.F.,{nOpc})   
			EndIf
			
			While GetSX8Len() > nStack
				RollBackSX8()
			EndDo
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza lancamentos do PCO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If aRotina[ nOpc, 4 ] == 3
			PcoFinLan("000354")  
			PcoFreeBlq("000354")
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Acols ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta acols para as getdados do folder                      ³±±
±±³          ³ -Fornecedor                                                 ³±±
±±³          ³ -Caucao                                                     ³±±
±±³          ³ -Planilha                                                   ³±±
±±³          ³ -Cronograma                                                 ³±±
±±³          ³ -Multas                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CN100Acols(nExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Acols(nOpc,lCaucRet,nFldRet)
Local aCpoNH     := Array(7)//Campos nao exibidos
Local nCntFor    := 0
Local cQuery

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configuracao dos aHeaders  	        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Fornecedores/Vendedores    
If CNC->(FieldPos('CNC_REVISA')) > 0
	aCpoNH[1] := If(cEspCtr=="1",{"CNC_NUMERO","CNC_REVISA"},{"CNU_CONTRA"})
Else
	aCpoNH[1] := If(cEspCtr=="1",{"CNC_NUMERO"},{"CNU_CONTRA"})
EndIf
If cEspCtr == "1"
	aAdd(aCpoNH[1],"CNC_CODED")
	aAdd(aCpoNH[1],"CNC_NUMPR")
EndIf

//Caucao
aCpoNH[2] := {"CN8_CONTRA","CN8_REVISA"}
//Planilhas
aCpoNH[3] := If(cEspCtr=="1",{"CNA_CONTRA","CNA_REVISA","CNA_CLIENT","CNA_LOJACL","CNA_CRONCT"},{"CNA_FORNEC","CNA_LJFORN","CNA_CONTRA","CNA_REVISA","CNA_CRONCT"})
//Cronogramas
aCpoNH[4] := {"CNF_CONTRA","CNF_REVISA"}
//Multas
aCpoNH[5] := {"CNH_NUMERO"}
//Documentos
aCpoNH[6] := {"CNK_OBS","CNK_CONTRA","CNK_TPCOD"}
//Adiantamentos
aCpoNH[7] := {"CNX_CONTRA","CNX_CLIENT","CNX_LOJACL"}
//Cronogramas Contabeis
If lContab
	//Verifica parametro MV_CNVRCTB - para controle de variacao cambial - Projeto Traffic
	aAdd(aCpoNH,If((GetNewPar("MV_CNVRCTB","N") == "S"),{"CNV_CONTRA","CNV_REVISA","CNV_CONTA"},{"CNV_CONTRA","CNV_REVISA","CNV_CONTA","CNV_VRCAMB","CNV_TXMOED"}))	
EndIf

//Campos excluidos no folder de retencao de caucao
If lCaucRet
	If cEspCtr == "1"
		aAdd(aCpoNH,{"CNT_CONTRA","CNT_CLIENT","CNT_LOJACL"})	
	Else
		aAdd(aCpoNH,{"CNT_CONTRA","CNT_CLIENT","CNT_LOJACL","CNT_FORNEC","CNT_LJFORN"})
	EndIf
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem dos aCols 										         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEspCtr="1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CNC - Fornecedores											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNC")                           
	If CNC->(FieldPos('CNC_REVISA')) > 0
		CN100LdAl(nOpc,"CNC",aCols1,aHeader1,"CNC.CNC_NUMERO = '"+ M->CN9_NUMERO +"' AND CNC.CNC_REVISA = '" +M->CN9_REVISA +"'",{"CNC_CODIGO","CNC_LOJA"},oGetDad1,aCpoNH[1],"",xFilial("CNC")+ M->CN9_NUMERO + M->CN9_REVISA,"CNC->CNC_FILIAL+CNC->CNC_NUMERO+CNC->CNC_REVISA")	
 	Else
		CN100LdAl(nOpc,"CNC",aCols1,aHeader1,"CNC.CNC_NUMERO = '"+ M->CN9_NUMERO +"'",{"CNC_CODIGO","CNC_LOJA"},oGetDad1,aCpoNH[1],"",xFilial("CNC")+ M->CN9_NUMERO,"CNC->CNC_FILIAL+CNC->CNC_NUMERO")
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CNU - Vendedores                          						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNU")
	CN100LdAl(nOpc,"CNU",aCols1,aHeader1,"CNU.CNU_CONTRA = '"+ M->CN9_NUMERO +"'",{"CNU_CODVD"},oGetDad1,aCpoNH[1])
Endif					
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CN8 - Caucoes			           					 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CN8") 
CN100LdAl(nOpc,"CN8",aCols2,aHeader2,"CN8.CN8_CONTRA = '"+ M->CN9_NUMERO +"'"+If((AllTrim(CN9->CN9_SITUAC) != DEF_SREVS)," AND CN8.CN8_REVISA = '"+ M->CN9_REVISA +"'",""),{"CN8_CODIGO"},oGetDad2,aCpoNH[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CNA - Cabecalho das Planilhas								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN100LdAl(nOpc,"CNA",aCols3,aHeader3,"CNA.CNA_CONTRA = '"+ M->CN9_NUMERO +"' AND CNA.CNA_REVISA = '"+ M->CN9_REVISA +"'",{"CNA_NUMERO"},oGetDad3,aCpoNH[3],"",xFilial("CNA")+ M->CN9_NUMERO + M->CN9_REVISA,"CNA->CNA_FILIAL+CNA->CNA_CONTRA+CNA->CNA_REVISA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CNF - Cronograma		               				 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                         
CN100LdAl(nOpc,"CNF",aCols4,aHeader4,"CNF.CNF_CONTRA = '"+ M->CN9_NUMERO +"' AND CNF.CNF_REVISA = '"+ M->CN9_REVISA +"'",{"CNF_NUMERO","CNF_PARCEL"},oGetDad4,aCpoNH[4])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CNH - Multas												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN100LdAl(nOpc,"CNH",aCols5,aHeader5,"CNH.CNH_NUMERO = '"+ M->CN9_NUMERO +"'",{"CNH_CODIGO"},oGetDad5,aCpoNH[5])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CNK - Documentos                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CNK") 

cQuery := "SELECT CN5.CN5_DESCRI,CNK.* "
cQuery += "  FROM "+ RetSQLName("CN5") +" CN5, "+ RetSQLName("CNK") +" CNK "
cQuery += " WHERE CN5.CN5_FILIAL = '"+xFilial("CN5")+"'"
cQuery += "   AND CNK.CNK_FILIAL = '"+xFilial("CNK")+"'"
cQuery += "   AND CNK.CNK_CONTRA = '"+ M->CN9_NUMERO +"'"
cQuery += "   AND CNK.CNK_TPDOC  = CN5.CN5_CODIGO "
cQuery += "   AND CN5.D_E_L_E_T_ <> '*' "
cQuery += "   AND CNK.D_E_L_E_T_ <> '*'"
		
CN100LdAl(nOpc,"CNK",aCols6,aHeader6,,,oGetDad6,aCpoNH[6],cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CNX - Adiantamento de Contrato                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN100LdAl(nOpc,"CNX",aCols7,aHeader7,"CNX.CNX_CONTRA = '"+ M->CN9_NUMERO +"'",{"CNX_NUMERO"},oGetDad7,aCpoNH[7])

If lContab
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CNV - Cronograma contabil                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CN100LdAl(nOpc,"CNV",aCols8,aHeader8,"CNV.CNV_CONTRA = '"+ M->CN9_NUMERO +"' AND CNV.CNV_REVISA = '"+ M->CN9_REVISA +"'",{"CNV_NUMERO"},oGetDad8,aCpoNH[8])
EndIf

If lCaucRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CNT - Retencao de Caucao                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CN100LdAl(nOpc,"CNT",aCols9,aHeader9,"CNT.CNT_CONTRA = '"+ M->CN9_NUMERO +"'",{"CNT_FORNEC","CNT_LJFORN","CNT_DTMED"},oGetDad9,aCpoNH[nFldRet])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira os campos sequenciais da caucao e do cronograma para  |
//| nao interferir no codigo automatico do contrato quando       |
//| nao houverem registros                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if len(aCols2) == 0
	nCntFor := aScan(aHeader2,{|x| AllTrim(x[2])  == "CN8_CODIGO"})
	aDel(aHeader2,nCntFor)
	aSize(aHeader2,len(aHeader2)-1)
EndIf
if len(aCols4) == 0
	nCntFor := aScan(aHeader4,{|x| AllTrim(x[2])  == "CNF_NUMERO"})
	aDel(aHeader4,nCntFor)
	aSize(aHeader4,len(aHeader4)-1)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldPer³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a vigencia contra os periodos dos cronogramas e      ³±±
±±³          ³ planilhas cadastrados para o contrato                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldPer()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldPer()
Local lRet := .T.
Local lVldVige := GetNewPar("MV_CNFVIGE","N") == "N"
Local dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida periodo contra os cronogramas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldVige
	dbSelectArea("CNF")
	dbSetOrder(2)
	dbSeek(xFilial("CNF")+M->CN9_NUMERO+M->CN9_REVISA)
	While CNF->CNF_FILIAL == xFilial("CNF") .And. CNF->CNF_CONTRA == M->CN9_NUMERO .And. CNF->CNF_REVISA == M->CN9_REVISA
		If CNF->CNF_PRUMED > dTermino
			lRet := .F.
			Help(" ",1,"CNTA100VIG") //"Vigencia invalida para os cronogramas ja inclusos"
			Exit
		EndIf
		dbSkip()
	EndDo
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Grv   ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a gravacao do contrato                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Grv(nExp01,aExp02,aExp03)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±³          ³ aExp02 - Array com as planilhas adicionadas                 ³±±
±±³          ³ aExp03 - Array com os itens de planilhas adicionadas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Grv(nOpc,aPlani,aPlIt,aHeaderCNB,aRatCNZ)
Local nCntFor  := 0
Local nCntFor2 := 0
Local nUsado   := 0
Local nCntVen  := 0
Local nCntVen2 := 0

Local lRet     := .T.
Local lFixo    := .T.
Local lValor   := .T.   
Local lContinua:= .T.  
Local lRetGrv  := .T.
Local lFilOri  := CNB->(FieldPos("CNB_FILORI")) > 0

Local dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)

Local cQuery   := ""
Local cArqTrb  := ""
Local cFilCNC  := xFilial("CNC")
Local cFilCN8  := xFilial("CN8")
Local cFilCNB  := xFilial("CNB")
Local cFilCNA  := xFilial("CNA")
Local cFilCNS  := xFilial("CNS")
Local cFilCNF  := xFilial("CNF")
Local cFilCNH  := xFilial("CNH")
Local cFilCN9  := xFilial("CN9")
Local cFilCNN  := xFilial("CNN")
Local cFilCNU  := xFilial("CNU")
Local cFilSC1  := xFilial("SC1")
Local cFilCNK  := xFilial("CNK")
Local cFilCNV  := xFilial("CNV")
Local cFilCNW  := xFilial("CNW")  
Local nPItemF  := aScan(aHeader1, {|z| Alltrim(z[2]) == "CNC_CODIGO"})
Local nPItemV  := aScan(aHeader1, {|z| Alltrim(z[2]) == "CNU_CODVD"})
Local lPrjCni    := FindFunction("ValidaCNI") .And. ValidaCNI()

Local aRegistro:= {}

Default aRatCNZ	:= {}
dbSelectArea("CN1")
dbSetOrder(1)
If (CN1->(FieldPos("CN1_CTRFIX")) > 0) .And. dbSeek(xFilial("CN1")+M->CN9_TPCTO)
	lFixo  := Empty(CN1->CN1_CTRFIX) .Or. (CN1->CN1_CTRFIX == "1")
	lValor := Empty(CN1->CN1_VLRPRV) .Or. (CN1->CN1_VLRPRV == "1")
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada anterior a gravacao do Contrato             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("CN100GRM"))
	lRetGrv := ExecBlock("CN100GRM",.F.,.F.,{nOpc})
	If ValType( lRetGrv ) == "L"
		lContinua := lRetGrv
	EndIf
EndIf

If lContinua
	Do Case
		Case nOpc == 3  //Incluir
			Begin Transaction
				//Atualiza Contratos (Principal)
				dbSelectArea("CN9")
				Reclock("CN9",.T.)
					For nCntFor := 1 To FCount()            
						If (FieldName(nCntFor)!="CN9_FILIAL")
							FieldPut(nCntFor,M->&(FieldName(nCntFor)))
						EndIf
					Next nCntFor
					CN9->CN9_FILIAL := cFilCN9
					If CN9->(FieldPos("CN9_FILORI")) > 0
						CN9->CN9_FILORI := cFilCN9
					EndIf
					CN9->CN9_SITUAC := DEF_SELAB//Em elaboracao
                    
					CN9->CN9_DTFIM  := dTermino
			
					//Zera a vigencia quando indefinida
					If CN9->CN9_UNVIGE == "4"
						CN9->CN9_VIGE = 0
					EndIf
					
					//Verifica se o contrato possui planilha
					If !lFixo
						If lValor//Verifica se o contrato tem valor definido
							CN9->CN9_VLATU := CN9->CN9_VLINI
							CN9->CN9_SALDO := CN9->CN9_VLINI
						Else
							CN9->CN9_VLINI := 0
							CN9->CN9_VLATU := 0
							CN9->CN9_SALDO := 0
						EndIf
					EndIf

				MsUnlock()
				
				CN9->(FKCommit())
					
				If cEspCtr == "1" .Or. Empty(cEspCtr)
					//Atualiza Fornecedores
					nUsado := Len(aHeader1)
					For nCntFor := 1 To Len(aCols1)
						If ( !aCols1[nCntFor][nUsado+1] ) .And. !Empty(aCols1[nCntFor][1])
							dbSelectArea("CNC")
							Reclock("CNC",.T.)
								For nCntFor2 := 1 To nUsado
									If ( aHeader1[nCntFor2][10] != "V" )
										FieldPut(FieldPos(aHeader1[nCntFor2][2]),aCols1[nCntFor][nCntFor2])
									EndIf
								Next nCntFor2
								CNC->CNC_FILIAL := cFilCNC
								CNC->CNC_NUMERO := CN9->CN9_NUMERO
							MsUnlock()
						EndIf
					Next
				
					CNC->(FKCommit())
				EndIf
				
				//Atualiza Multas
				nUsado := Len(aHeader5)
				For nCntFor := 1 To Len(aCols5)
					If ( !aCols5[nCntFor][nUsado+1] ) .And. !Empty(aCols5[nCntFor][1])
						dbSelectArea("CNH")
						Reclock("CNH",.T.)
							For nCntFor2 := 1 To nUsado
								If ( aHeader5[nCntFor2][10] != "V" )
									FieldPut(FieldPos(aHeader5[nCntFor2][2]),aCols5[nCntFor][nCntFor2])
								EndIf
							Next nCntFor2
							CNH->CNH_FILIAL := cFilCNH
							CNH->CNH_NUMERO := CN9->CN9_NUMERO
						MsUnlock()
					EndIf
				Next
				
				CNH->(FKCommit())
				
				If len(aPlani) > 0 .And. lFixo
					CN100PlGr(aPlani,aPlIt,aHeaderCNB)
				EndIf
				
				CNA->(FKCommit())
				CNB->(FKCommit())
				
				If AliasInDic("CNN")
					//Gera permissão de controle total sobre o contrato
					dbSelectArea("CNN")
					RecLock("CNN",.T.)
						CNN->CNN_FILIAL := cFilCNN
						CNN->CNN_CONTRA := M->CN9_NUMERO
						CNN->CNN_USRCOD := RetCodUsr()
						CNN->CNN_TRACOD := DEF_TRANS
					MsUnlock()
				EndIf
				
				CNN->(FKCommit())
		
				//Atualiza Vendedores
		     
			      If cEspCtr="2"
						nUsado := Len(aHeader1)
						For nCntVen := 1 To Len(aCols1)
							If ( !aCols1[nCntVen][nUsado+1] ) .And. !Empty(aCols1[nCntVen][1])
								dbSelectArea("CNU")
								Reclock("CNU",.T.)
									For nCntVen2 := 1 To nUsado
										If ( aHeader1[nCntVen2][10] != "V" )
											FieldPut(FieldPos(aHeader1[nCntVen2][2]),aCols1[nCntVen][nCntVen2])
										EndIf
									Next nCntFor2
									CNU->CNU_FILIAL := cFilCNU
									CNU->CNU_CONTRA := CN9->CN9_NUMERO
								MsUnlock()
							EndIf
						Next
				   Endif
				   CNU->(FKCommit())
				
		   	End Transaction
		   	
		Case nOpc == 4  //Atualizar
			Begin Transaction
				//Atualiza Contrato
				dbSelectArea("CN9")
				Reclock("CN9",.F.)
					For nCntFor := 1 To FCount()
						If (FieldName(nCntFor)!="CN9_FILIAL")
							FieldPut(nCntFor,M->&(FieldName(nCntFor)))
						EndIf
					Next nCntFor
					CN9->CN9_FILIAL := cFilCN9
					If CN9->(FieldPos("CN9_FILORI")) > 0
						If !lPrjCni
							CN9->CN9_FILORI := cFilCN9
						EndIf
					EndIf
					CN9->CN9_DTFIM  := dTermino
					
					//Zera a vigencia quando indefinida
					If CN9->CN9_UNVIGE == "4"
						CN9->CN9_VIGE = 0
					EndIf
					
					//Verifica se o contrato possui planilha
					If !lFixo
						If lValor//Verifica se o contrato tem valor definido
							CN9->CN9_VLATU := CN9->CN9_VLINI
							CN9->CN9_SALDO := CN9->CN9_VLINI
						Else
							CN9->CN9_VLINI := 0
							CN9->CN9_VLATU := 0
							CN9->CN9_SALDO := 0
						EndIf
					EndIf
					
				MsUnlock()
					
			  	If cEspCtr == "1"
					dbSelectArea("CNC")
					dbSetOrder(1)
					If dbSeek(cFilCNC+M->CN9_NUMERO+If(FieldPos("CNC_REVISA")>0,M->CN9_REVISA,""))
						While !Eof() .And. CNC->CNC_FILIAL = cFilCNC .And. CNC->CNC_NUMERO == M->CN9_NUMERO .And. If(FieldPos("CNC_REVISA")>0,CNC->CNC_REVISA == M->CN9_REVISA,.T.)
							AADD(aRegistro,CNC->(RecNo()))
							CNC->(dbSkip())
						EndDo
					EndIf
				Else  
					dbSelectArea("CNU")
					dbSetOrder(1)
					If dbSeek(cFilCNU+M->CN9_NUMERO)
						While !Eof() .And. CNU->CNU_FILIAL = cFilCNU .And. CNU->CNU_CONTRA == M->CN9_NUMERO
							If aScan(aCols1, {|aX| aX[nPItemV]==CNU->CNU_CODVD })>0 
								AADD(aRegistro,CNU->(RecNo()))
							EndIf
							CNU->(dbSkip())
						EndDo
					EndIf		
				Endif	      
					
			    If cEspCtr == "1" .Or. Empty(cEspCtr)
					//Atualiza Fornecedores
					nUsado := Len(aHeader1)
					For nCntFor := 1 To Len(aCols1)  
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o registro está marcado como deletado.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
						If ( aCols1[nCntFor][nUsado+1] )		
							If ( Len(aRegistro) >= nCntFor )
								dbSelectArea("CNC")        
				 				dbGoto( aRegistro[nCntFor] ) 					
								RecLock("CNC",.F.)   
								dbDelete()
								MsUnlock()   
							EndIf
						Else
							If !Empty(aCols1[nCntFor][1])					
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Posiciona no registro para alteracao dos fornecedores                 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If ( Len(aRegistro) >= nCntFor )
									dbSelectArea("CNC")        
					 				dbGoto( aRegistro[nCntFor] ) 					
									RecLock("CNC",.F.)
								Else
									RecLock("CNC",.T.)
								EndIf
								For nCntFor2 := 1 To nUsado
									If ( aHeader1[nCntFor2][10] != "V" )
										FieldPut(FieldPos(aHeader1[nCntFor2][2]),aCols1[nCntFor][nCntFor2])
									EndIf
								Next nCntFor2
						 		CNC->CNC_FILIAL := cFilCNC
								CNC->CNC_NUMERO := CN9->CN9_NUMERO
								If CNC->(FieldPos('CNC_REVISA')) > 0
									CNC->CNC_REVISA := CN9->CN9_REVISA
								EndIf
								MsUnlock()  
					 		EndIf
				   		EndIf  
					Next
				Else
					//Atualiza Vendedores
					nUsado := Len(aHeader1)
					For nCntVen := 1 To Len(aCols1)  
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o registro está marcado como deletado.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( aCols1[nCntVen][nUsado+1] )		
							If ( Len(aRegistro) >= nCntVen )
								dbSelectArea("CNU")        
								dbGoto( aRegistro[nCntVen] ) 					
								RecLock("CNU",.F.)   
								dbDelete()
								MsUnlock()   
							EndIf
						Else
							If !Empty(aCols1[nCntVen][1])
								dbSelectArea("CNU")
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Posiciona no registro para alteracao dos vendedores                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If ( Len(aRegistro) >= nCntVen )
									dbGoto( aRegistro[nCntVen] )
									RecLock("CNU",.F.)
								Else
									RecLock("CNU",.T.)
								EndIf
								For nCntVen2 := 1 To nUsado
									If ( aHeader1[nCntVen2][10] != "V" )
										FieldPut(FieldPos(aHeader1[nCntVen2][2]),aCols1[nCntVen][nCntVen2])
									EndIf
								Next nCntFor2
								CNU->CNU_FILIAL := cFilCNU
								CNU->CNU_CONTRA := CN9->CN9_NUMERO
								MsUnlock()
							EndIf
						EndIf
					Next  
				 Endif	
				
				//Atualiza Planilhas
				CN100PlAtu()
								
				//Apaga Multas
				dbSelectArea("CNH")
				dbSetOrder(1)
				If dbSeek(cFilCNH+M->CN9_NUMERO)
					While !Eof() .And. CNH->CNH_FILIAL == cFilCNH .And. CNH->CNH_NUMERO == M->CN9_NUMERO
						Reclock("CNH",.F.)
							dbDelete()
						MsUnlock()
						dbSelectArea("CNH")
						dbSkip()
					EndDo
				EndIf
				
				//Atualiza Multas
				nUsado := Len(aHeader5)
				For nCntFor := 1 To Len(aCols5)
					If ( !aCols5[nCntFor][nUsado+1] )  .And. !Empty(aCols5[nCntFor][1])
						dbSelectArea("CNH")
						Reclock("CNH",.T.)
							For nCntFor2 := 1 To nUsado
								If ( aHeader5[nCntFor2][10] != "V" )
									FieldPut(FieldPos(aHeader5[nCntFor2][2]),aCols5[nCntFor][nCntFor2])
								EndIf
							Next nCntFor2
							CNH->CNH_FILIAL := cFilCNH
							CNH->CNH_NUMERO := CN9->CN9_NUMERO
						MsUnlock()
					EndIf
				Next
								
			End Transaction
			
		Case nOpc == 5  //Exclusao
			If allTrim(CN9->CN9_SITUAC) == DEF_SELAB//Permite exclusao apenas para contratos em elaboracao
				PcoIniLan("000354")
				Begin Transaction
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclui a amarracao com os conhecimentos                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsDocument( "CN9", CN9->( RecNo() ), 2, , 3 ) 
		
					If cEspCtr == "1"
						//Apaga Fornecedores X Contratos
						dbSelectArea("CNC")
						dbSetOrder(1)
						If dbSeek(cFilCNC+CN9->CN9_NUMERO+If(FieldPos('CNC_REVISA')>0,CN9->CN9_REVISA,""))
							While !Eof() .And. CNC_FILIAL = cFilCNC .And. CNC_NUMERO == CN9->CN9_NUMERO .And. If(FieldPos('CNC_REVISA')>0,CNC_REVISA == CN9->CN9_REVISA,.T.)
								RecLock("CNC", .F.)
									dbDelete()
								MsUnLock()
								dbSkip()
							EndDo
						EndIf
						
						CNC->(FKCommit())
					Else
						//Apaga Vendedores
						dbSelectArea("CNU")
						dbSetOrder(1)
						If dbSeek(cFilCNU+M->CN9_NUMERO)
							While !Eof() .And. CNU->CNU_FILIAL = cFilCNU .And. CNU->CNU_CONTRA == M->CN9_NUMERO
								RecLock("CNU",.F.)
									CNU->(dbDelete())
								MsUnlock()
								CNU->(dbSkip())
							EndDo
						EndIf
		
						CNU->(FKCommit())
					EndIf
					
					//Apaga Caucoes
					dbSelectArea("CN8")
					dbSetOrder(2)
					If dbSeek(cFilCN8+CN9->CN9_NUMERO)
						While !Eof() .And. CN8->CN8_FILIAL = cFilCN8 .And. CN8->CN8_CONTRA == CN9->CN9_NUMERO
							RecLock("CN8", .F.)
								dbDelete()
							MsUnLock()
							dbSelectArea("CN8")
							dbSkip()
						EndDo
					EndIf
					
					CN8->(FKCommit())    
					
					If AliasInDic("CNZ") 
						//Apaga Itens de Rateio por Centro de Custo
						dbSelectArea("CNZ")
						dbSetOrder(1)
						If dbSeek(xFilial("CNZ")+CN9->CN9_NUMERO+CN9->CN9_REVISA)
							While !Eof() .And. CNB->CNB_FILIAL = xFilial("CNZ") .And. CNZ->CNZ_CONTRA == CN9->CN9_NUMERO .And. CNZ->CNZ_REVISA == CN9->CN9_REVISA
					 		
								RecLock("CNZ", .F.)
									dbDelete()
								MsUnLock()	 
									
								dbSelectArea("CNZ")
								dbSetOrder(1)
								dbSkip()
							EndDo    
							aRatCNZ	 := {}
						EndIf
						
						CNZ->(FKCommit())				                            					
					EndIf
				
					
					//Apaga Itens das Planilhas
					dbSelectArea("CNB")
					dbSetOrder(1)
					If dbSeek(cFilCNB+CN9->CN9_NUMERO+CN9->CN9_REVISA)
						While !Eof() .And. CNB->CNB_FILIAL = cFilCNB .And. CNB->CNB_CONTRA == CN9->CN9_NUMERO .And. CNB->CNB_REVISA == CN9->CN9_REVISA
							If lFilOri .And. !Empty(CNB->CNB_FILORI)
								cFilSC1 := xFilial("SC1",CNB->CNB_FILORI)
							Else
								cFilSC1 := xFilial("SC1")
							EndIf
							If !Empty(CNB->CNB_ITEMSC)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Retira quantidade atendida da solicitacao de compra³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SC1")
								dbSetOrder(1)
								If dbSeek(cFilSC1+CNB->CNB_NUMSC+CNB->CNB_ITEMSC)
									RecLock("SC1")
										SC1->C1_FLAGGCT := ""
									MsUnlock()
								EndIf
							ElseIf CN9->(FieldPos("CN9_CODED")) > 0 .And. !Empty(CN9->CN9_CODED)
								SC1->(dbOrderNickName("GCP01"))
							  	SC1->(dbSeek(cFilSC1+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT))
							  	While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == cFilSC1+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT
							  		RecLock("SC1",.F.)
									SC1->C1_FLAGGCT	:= ""
									SC1->(MsUnlock())
														
									SC1->(dbSkip())
								End
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Exclui localizacao fisica AGW ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If AliasInDic("AGW")
								AGW->(dbSetOrder(2))
								AGW->(dbSeek(xFilial("AGW")+CNB->(CNB_CONTRA+CNB_NUMERO+CNB_ITEM)))
								While !AGW->(EOF()) .And. AGW->(AGW_FILIAL+AGW_CONTRA+AGW_PLANIL+AGW_ITEM) == xFilial("AGW")+CNB->(CNB_CONTRA+CNB_NUMERO+CNB_ITEM)
									RecLock("AGW")
									AGW->(dbDelete())
									AGW->(MsUnLock())
									
									AGW->(dbSkip())
								End
							EndIf
							
							RecLock("CNB", .F.)
							dbDelete()
							MsUnLock()
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa lancamento do PCO    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							PcoDetLan("000354","02","CNTA200",.T.)
					 		
							RecLock("CNB", .F.)
								dbDelete()
							MsUnLock()
		
							dbSelectArea("CNB")
							dbSetOrder(1)
							dbSkip()
						EndDo
					EndIf
					
					CNB->(FKCommit())
					
					//Apaga Planilhas
					dbSelectArea("CNA")
					dbSetOrder(3)
					If dbSeek(cFilCNA+CN9->CN9_NUMERO+CN9->CN9_REVISA)
						While !Eof() .And. CNA->CNA_FILIAL = cFilCNA .And. CNA->CNA_CONTRA == CN9->CN9_NUMERO .And. CNA->CNA_REVISA == CN9->CN9_REVISA
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa lancamento do PCO    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							PcoDetLan("000354","01","CNTA200",.T.)
		
							RecLock("CNA", .F.)
								dbDelete()
							MsUnLock()
							
							dbSelectArea("CNA")
							dbSkip()
						EndDo
					EndIf
					
					CNA->(FKCommit())
		
					//Apaga Cronograma Fisico
					If AliasInDic("CNS")
						dbSelectArea("CNS")
						dbSetOrder(2)
						cFilCNS := cFilCNS
						If dbSeek(cFilCNS+CN9->CN9_NUMERO+CN9->CN9_REVISA)
							While !Eof() .And. CNS->CNS_FILIAL = cFilCNS .And. CNS->CNS_CONTRA == CN9->CN9_NUMERO .And. CNS->CNS_REVISA == CN9->CN9_REVISA
								RecLock("CNS", .F.)
									dbDelete()
								MsUnLock()
								dbSelectArea("CNS")
								dbSkip()
						 	EndDo
						EndIf
						
						CNS->(FKCommit())
					EndIf
					
					//Apaga Cronograma Financeiro
					dbSelectArea("CNF")
					dbSetOrder(2)
					If dbSeek(cFilCNF+CN9->CN9_NUMERO+CN9->CN9_REVISA)
						While !Eof() .And. CNF->CNF_FILIAL = cFilCNF .And. CNF->CNF_CONTRA == CN9->CN9_NUMERO .And. CNF->CNF_REVISA == CN9->CN9_REVISA
							RecLock("CNF", .F.)
								dbDelete()
							MsUnLock()
							dbSelectArea("CNF")
							dbSkip()
						EndDo
					EndIf
					
					CNF->(FKCommit())
					
					//Apaga Multas X Contrato
					dbSelectArea("CNH")
					dbSetOrder(1)
					If dbSeek(cFilCNH+CN9->CN9_NUMERO)
						While !Eof() .And. CNH->CNH_FILIAL = cFilCNH .And. CNH->CNH_NUMERO == CN9->CN9_NUMERO
							RecLock("CNH", .F.)
								dbDelete()
							MsUnLock()
							dbSelectArea("CNH")
							dbSkip()
						EndDo
					EndIf
					
					CNH->(FKCommit())
					
					//Apaga Parcelas contabeis
					dbSelectArea("CNW")
					dbSetOrder(1)
					If dbSeek(cFilCNW+CN9->CN9_NUMERO)
						While !Eof() .And. CNW->CNW_FILIAL = cFilCNW .And. CNW->CNW_CONTRA == CN9->CN9_NUMERO
							RecLock("CNW", .F.)
								dbDelete()
							MsUnLock()
							dbSelectArea("CNW")
							dbSkip()
						EndDo
					EndIf
					
					CNW->(FKCommit())
		
					//Apaga cronogramas contabeis
					dbSelectArea("CNV")
					dbSetOrder(1)
					If dbSeek(cFilCNV+CN9->CN9_NUMERO)
						While !Eof() .And. CNV->CNV_FILIAL = cFilCNV .And. CNV->CNV_CONTRA == CN9->CN9_NUMERO
							RecLock("CNV", .F.)
								dbDelete()
							MsUnLock()
							dbSelectArea("CNV")
							dbSkip()
						EndDo
					EndIf
					
					CNV->(FKCommit())
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Exclui documentos relacionados ao contrato  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CNK") 
					
					cArqTrb	:= CriaTrab( nil, .F. )  
					cQuery := "SELECT R_E_C_N_O_ as RECNO "
					cQuery += "  FROM "+RetSQLName("CNK")+" CNK "
					cQuery += " WHERE CNK.CNK_FILIAL = '"+cFilCNK+"' "
					cQuery += "   AND CNK.CNK_CONTRA = '"+CN9->CN9_NUMERO+"' "
					cQuery += "   AND CNK.D_E_L_E_T_ = ' ' "
		
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
		
					While !(cArqTrb)->(Eof())	
						CNK->(dbGoTo((cArqTrb)->RECNO))
						RecLock("CNK",.F.)
							dbDelete()
						MsUnlock()
						
						(cArqTrb)->(dbSkip())
					EndDo
					
					(cArqTrb)->( dbCloseArea() )
					
					CNK->(FKCommit())
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Exclui pemissoes de acesso relacionadas ao contrato  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CNN") 
					
					cArqTrb	:= CriaTrab( nil, .F. )  
					cQuery := "SELECT R_E_C_N_O_ as RECNO "
					cQuery += "  FROM "+RetSQLName("CNN")+" CNN "
					cQuery += " WHERE CNN.CNN_FILIAL = '"+cFilCNN+"' "
					cQuery += "   AND CNN.CNN_CONTRA = '"+CN9->CN9_NUMERO+"' "
					cQuery += "   AND CNN.D_E_L_E_T_ = ' ' "
		
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
		
					While !(cArqTrb)->(Eof())	
						CNN->(dbGoTo((cArqTrb)->RECNO))
						RecLock("CNN",.F.)
							dbDelete()
						MsUnlock()
						
						(cArqTrb)->(dbSkip())
					EndDo
					
					(cArqTrb)->( dbCloseArea() )
					
					CNN->(FKCommit())
		
					//Apaga Contratos
					dbSelectArea("CN9")
					MSMM(CN9_CODOBJ,,,,2)
					MSMM(CN9_CODJUS,,,,2)
					MSMM(CN9_CODCLA,,,,2)
					
					Reclock("CN9",.F.)
						dbDelete()
					MsUnlock()
				End Transaction
				
				//Finaliza lancamentos do SIGAPCO		
				PcoFinLan("000354")  
				PcoFreeBlq("000354")
			Else
				Help(" ",1,"CNTA100EXC") //"Exclusao permitida apenas para contratos em elaboracao"
				lRet := .F.
			EndIf
	EndCase
	If AliasInDic("CNZ") .And. Len(aRatCNZ) > 0 .And. FindFunction("GravaCNZ") 
		GravaCNZ(aRatCNZ,oGetDad3,nOpc,aPlanI,aPlIt,cEspCtr,,,aHeaderCNB,"CNB")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa ponto de entrada apos a gravacao do contrato ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("CN100GRC")
	ExecBlock("CN100GRC",.F.,.F.,{nOpc,aPlani,aPlIt,aHeader3,aHeaderCNB})
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MSO021    | Autor ³ Deosdete P. da Silva          ³ Data ³04.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gerar documento para aprovacao com alcada na tabela SCR             ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNTA100                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcAlc = 1 - Incluir 5 - Alterar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function CN100Alc(cRevisa, cGrpApr)

Local nTxMoeda 	:= 0    // Taxa da moeda
Local cDoc     	:= ""   // Documento composto de numero do contrato + revisao
Local cTipoDoc 	:= "CT"	// Indica que o documento é do tipo contrato
Local cCodUsu	:= __cUserID
Local lRet	   	:= .F.

Default cRevisa := ""
Default cGrpApr := ""

cDoc     := CN9->CN9_NUMERO + cRevisa
nTxMoeda := recMoeda(dDataBase,CN9->CN9_MOEDA) // Taxa da moeda

If CN9->(FieldPos("CN9_APROV")) > 0
	
	If !Empty(cGrpApr)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Guardar o grupo aprovador no contrato para gerar documento de liberacao (SCR)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If Empty(CN9->CN9_APROV)
			Reclock("CN9")
			CN9->CN9_APROV := cGrpApr	//Grava o Grupo Aprovador no contrato
			CN9->(MsUnlock())
		EndIf

		MaAlcDoc({;
			cDoc,			;	//[1] Numero do documento
			cTipoDoc,		;   //[2] Tipo de Documento
			CN9->CN9_VLINI,	;   //[3] Valor do Documento
			"",				; 	//[4] Codigo do Aprovador
			cCodUsu,		;   //[5] Codigo do Usuario
			cGrpApr,		;	//[6] Grupo do Aprovador
			"",				;   //[7] Aprovador Superior
			CN9->CN9_MOEDA,	;   //[8] Moeda do Documento		
			nTxMoeda,		;   //[9] Taxa da Moeda
			dDataBase,		;   //[10] Data de Emis.Doc.
			""}				;	//[11] Grupo de Compras
			,dDataBase,1,"",.F.)

		lRet := .T.

	Else
		MsgAlert(STR0088 + " " + STR0162 + CRLF + ;	//"Atenção!" ## "O tipo desse contrato requer um grupo de aprovação."
								 STR0175 + CRLF + ;	//"A situação do contrato não será modificada."
								 STR0179)  			//"É necessário executar o Atualizador CNTAUPD33 (Protheus Versão 10)."
	EndIf
Else
	MsgAlert(STR0088 + " " + STR0174 + CRLF + ;	//"Atenção!" ## "Não foi possível localizar o campo CN9_APROV.
							 STR0175 + CRLF + ;	//"A situação do contrato não será modificada."
							 STR0179)  			//"É necessário executar o Atualizador CNTAUPD33 (Protheus Versão 10)."
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Visual³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a rotina de visualizacao dos elementos do contrato  ³±±
±±³          ³ de acordo com o folder atual                                ³±±
±±³          ³ 1 - Fornecedor                                              ³±±
±±³          ³ 2 - Caucao                                                  ³±±
±±³          ³ 3 - Planilha                                                ³±±
±±³          ³ 4 - Cronograma                                              ³±±
±±³          ³ 5 - Multas                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Visual(nExp01,aExp02,aExp03,lExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±³          ³ aExp02 - Array com as planilhas adicionadas                 ³±±
±±³          ³ aExp03 - Array com os itens das planilhas adicionadas       ³±±
±±³          ³ lExp04 - Indica se o usuario podera VISUALIZAR a planilha   ³±±
±±³          ³ 			do contrato mesmo sem ter acesso ao mesmo. Esse	   ³±±
±±³          ³ 			parametro e enviado como .T. exclusivamente pela   ³±±
±±³          ³ 			rotina de liberacao (MATA097) quando o documento e ³±±
±±³          ³ 			do tipo CT (Contrato) e o Aprovador nao possui     ³±±
±±³          ³ 			acesso ao contrato.					   			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Visual(nOpc,aPlani,aPlIt,lVisAprCt)

Local aArea	  := GetArea()
Local nFolder := oFolder:nOption
Local lRotRevis:= .F.

Default lVisAprCt := .F.

Do Case
	Case nFolder == 1  //Fornecedores//Vendedores
      If cEspCtr="1"
			If Len(ogetDad1:aCols) > 0
				dbSelectArea("SA2")
				dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
				if dbSeek(xFilial("SA2")+ogetDad1:aCols[ogetDad1:nAt][aScan(aHeader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})]+ogetDad1:aCols[ogetDad1:nAt][aScan(aHeader1,{|x| AllTrim(x[2])  == "CNC_LOJA"})])
					AxVisual("SA2",Recno(),2)
				EndIf
			Endif	
		Else	
			If Len(ogetDad1:aCols) > 0
				dbSelectArea("SA3")
				dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
				if dbSeek(xFilial("SA3")+ogetDad1:aCols[ogetDad1:nAt][aScan(aHeader1,{|x| AllTrim(x[2]) == "CNU_CODVD"})])
					AxVisual("SA3",Recno(),2)
				EndIf
			EndIf
		EndIf
		
	Case nFolder == 2  //Caucoes
		If Len(ogetDad2:aCols) > 0
			dbSelectArea("CN8")
			dbSetOrder(1)
			if dbSeek(xFilial("CN8")+ogetDad2:aCols[ogetDad2:nAt][aScan(aHeader2,{|x| AllTrim(x[2]) == "CN8_CODIGO"})])
				CN090Manut("CN8",Recno(),2,,lVisAprCt)
			EndIf
		EndIf
		
	Case nFolder == 3  //Planilhas
	   	If cEspCtr="1"
			PRIVATE aForn := aEval(oGetDad1:aCols,{|x| {x[aScan(aHeader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})],x[aScan(aHeader1,{|x| AllTrim(x[2]) == "CNC_LOJA"})]}})
		Endif
		If nOpc != 3
			If Len(ogetDad3:aCols) > 0
				dbSelectArea("CNA")
				dbSetOrder(1)
				if dbSeek(xFilial("CNA")+M->CN9_NUMERO+M->CN9_REVISA+ogetDad3:aCols[ogetDad3:nAt][aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_NUMERO"})])
					lRotRevis := (FunName() $ "CNTA140|CNTA150")
					CN200Manut("CNA",Recno(),2,,(lRotRevis .And. Posicione("CN0",1,xFilial("CN0")+M->CN9_TIPREV,"CN0_TIPO")==DEF_REALI),(lRotRevis .And. Posicione("CN0",1,xFilial("CN0")+M->CN9_TIPREV,"CN0_TIPO")==DEF_READQ),/*aPlani*/,/*aPlIt*/,/*cContra*/,/*cPlani*/,/*dInicio*/,/*dTermino*/,/*aHeaderPla*/,/*aRateio*/,lVisAprCt)
				EndIf
			EndIf
		Else
			If len(aPlani)> 0
				CN200Manut("CNA",5000,2,,.F.,.F.,aPlani,aPlIt,M->CN9_NUMERO,oGetDad3:aCols[oGetDad3:nAt,aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_NUMERO"})])
			EndIf
		EndIf
		
	Case nFolder == 4  //Cronograma Financeiro
		If Len(ogetDad4:aCols) > 0
			dbSelectArea("CNF")
			dbSetOrder(2)
			if dbSeek(xFilial("CNF")+M->CN9_NUMERO+M->CN9_REVISA+ogetDad4:aCols[ogetDad4:nAt][aScan(aHeader4,{|x| AllTrim(x[2]) == "CNF_NUMERO"})])
				CN110Manut("CNF",Recno(),2,/*aCpos*/,/*cContra*/,/*cRevisa*/,/*lAtuPlan*/,/*lPlanReg*/,lVisAprCt)
			EndIf
		EndIf
		
	Case nFolder == 5  //Multas
		If Len(ogetDad5:aCols) > 0
			dbSelectArea("CN4")
			dbSetOrder(1)
			if dbSeek(xFilial("CN4")+ogetDad5:aCols[ogetDad5:nAt][aScan(aHeader5,{|x| AllTrim(x[2]) == "CNH_CODIGO"})])
				AxVisual("CN4",Recno(),2)
			EndIf
		EndIf

	Case nFolder == 6  //Documentos
		If Len(ogetDad6:aCols) > 0
			dbSelectArea("CNK")
			dbSetOrder(1)
			if dbSeek(xFilial("CNK")+ogetDad6:aCols[ogetDad6:nAt][aScan(aHeader6,{|x| AllTrim(x[2]) == "CNK_CODIGO"})])
				CN170Manut("CNK",Recno(),2,/*xFiller*/,/*cContra*/,/*cTpDoc*/,/*cCod*/,lVisAprCt)
			EndIf
		EndIf

	Case nFolder == 7  //Adiantamentos
		If Len(ogetDad7:aCols) > 0
			dbSelectArea("CNX")
			dbSetOrder(1)
			if dbSeek(xFilial("CNX")+M->CN9_NUMERO+ogetDad7:aCols[ogetDad7:nAt][aScan(aHeader7,{|x| AllTrim(x[2]) == "CNX_NUMERO"})])
				AxVisual("CNX",Recno(),2)
			EndIf
		EndIf

	Case nFolder == 8  //Cronograma Contabil
		If Len(ogetDad8:aCols) > 0
			dbSelectArea("CNV")
			dbSetOrder(1)
			If dbSeek(xFilial("CNV")+M->CN9_NUMERO+M->CN9_REVISA+ogetDad8:aCols[ogetDad8:nAt][aScan(aHeader8,{|x| AllTrim(x[2]) == "CNV_NUMERO"})])
				CN270Manut("CNV",Recno(),2,/*aCpos*/,/*cContra*/,/*cRevisa*/,/*lAtuPlan*/,/*lPlanReg*/,lVisAprCt)
			EndIf
		EndIf
		
EndCase

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldMul³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida as multas do contrato                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldMul()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldMul()
Local lRepetido := .F.
Local lRet		:= .T.
Local nI
Local nPosMult  := Ascan( aheader5, {|x| AllTrim(x[2])  == "CNH_CODIGO"})
Local nPos      := oGetDad5:nAt

if !Empty(oGetDad5:aCols[nPos,nPosMult])
	If Len( oGetDad5:aCols ) > 1 .And. !oGetDad5:aCols[nPos][len( aHeader5 ) + 1]
		
		For nI:= 1 To Len( oGetDad5:aCols )
			If ( nI != nPos ) .and. !oGetDad5:aCols[nI][len( aHeader5 ) + 1]
				If oGetDad5:aCols[nI,nPosMult] == oGetDad5:aCols[nPos,nPosMult]
					lRepetido := .T.
					Exit
				Endif
			Endif
		Next nI
		
		If lRepetido
			lRet:=.F.
			Help(" ",1,"JAGRAVADO")
		End
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldFor³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida os fornecedores do contrato                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldFor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldFor()
Local lRepetido := .F.
Local lRet      := .T.      
Local lDeletado := .T.
Local nPosForn  := Ascan( aheader1, {|x| AllTrim(x[2])  == "CNC_CODIGO"})
Local nPosLoja  := Ascan( aheader1, {|x| AllTrim(x[2])  == "CNC_LOJA"})
Local nI
Local nPos 		:= oGetDad1:nAt

Local m := 0

If INCLUI .Or. ALTERA
	If nPos > 0 .And. nPosForn > 0 .And. nPosLoja > 0
		If (!Empty(oGetDad1:aCols[nPos,nPosForn]) .Or. !Empty(oGetDad1:aCols[nPos,nPosLoja])) 
			lRet := ExistCpo("SA2",oGetDad1:aCols[nPos,nPosForn]+oGetDad1:aCols[nPos,nPosLoja])
			
			If lRet .And. Len( oGetDad1:aCols ) > 1 .And. !oGetDad1:aCols[nPos][len( aHeader1 ) + 1]
				
				For nI:= 1 To Len( oGetDad1:aCols )
					If ( nI != nPos ) .and. !oGetDad1:aCols[nI][len( aHeader1 ) + 1]
						If oGetDad1:aCols[nI,nPosForn] == oGetDad1:aCols[nPos,nPosForn] .And. oGetDad1:aCols[nI,nPosLoja] == oGetDad1:aCols[nPos,nPosLoja]
							lRepetido := .T.
							Exit
						Endif
					Endif
				Next nI
				
				If lRepetido
					lRet:=.F.
					Help(" ",1,"JAGRAVADO")
				End
			Endif  
			
			If lRet //Verifica se todos os fornecedores estão deletados
				For nI:= 1 To Len( oGetDad1:aCols )
					If !oGetDad1:aCols[nI][len( aHeader1 ) + 1]
						lDeletado := .F.
						Exit
					Endif
				Next nI  
				
				If lDeletado
					lRet:=.F.
					Help(" ",1,"CNTA100FOR")//"Inclua ao menos um fornecedor no contrato"
				End
			EndIf
		Else
			Help(" ",1,"CNTA100FOR") //"Inclua ao menos um fornecedor no contrato"
			lRet := .F.
		EndIf
	EndIf     
	
	oGetDad1:oBrowse:SetFocus()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |CN100VlFor  ³ Autor ³ Marcelo Custodio      ³ Data ³16.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida linha atual do fornecedor                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID do campo CNC_CODIGO                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VlFor()
Local lRet	:= .T.
Local cForn	:= M->CNC_CODIGO
Local cLoja := ogetDad1:aCols[n,aScan(aHeader1,{|x| AllTrim(x[2]) == "CNC_LOJA"})]

If !Empty(cForn) .and. !Empty(cLoja) 
	If cForn==SA2->A2_COD .And. cLoja<>SA2->A2_LOJA     
		cLoja := SA2->A2_LOJA
	EndIf
	lRet := ExistCpo("SA2",cForn+cLoja)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |CN100VlLoj  ³ Autor ³ Marcelo Custodio      ³ Data ³16.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida linha atual do fornecedor                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID do campo CNC_LOJA                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VlLoj()
Local lRet	:= .T.
Local cForn	:= ogetDad1:aCols[n,aScan(aHeader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})]
Local cLoja := M->CNC_LOJA

If !Empty(cForn) .and. !Empty(cLoja)
	lRet := ExistCpo("SA2",cForn+cLoja)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldVen³ Autor ³ Robson Nayland        ³ Data ³04.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida os Vendedores do Contrato                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldVen()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldVen()
Local lRepetido := .F.
Local lRet		:= .T.

Local nI
Local nPosVen   := Ascan( aheader1, {|x| TRIM(x[2]) == "CNU_CODVD"})
Local nPosPerc  := Ascan( aheader1, {|x| TRIM(x[2]) == "CNU_PERCCM"})
Local nPos      := oGetDad1:nAt
Local nLinhas   := 0 // numero maximo de venderores
Local m 		:= 0
Local nTotPerc  := 0

If !Empty(oGetDad1:aCols[nPos,nPosVen])
	If !oGetDad1:aCols[nPos][len( aHeader1 ) + 1]
		lRet := ExistCpo("SA3",oGetDad1:aCols[nPos,nPosVen])
	EndIf
	
	If lRet .And. Len( oGetDad1:aCols ) > 1 .And. !oGetDad1:aCols[nPos][len( aHeader1 ) + 1]
		
		For nI:= 1 To Len( oGetDad1:aCols )
			If ( nI != nPos ) .and. !oGetDad1:aCols[nI][len( aHeader1 ) + 1]
				If oGetDad1:aCols[nI,nPosVen] == oGetDad1:aCols[nPos,nPosVen] 
					lRepetido := .T.
					Exit
				Endif               
			Endif
		Next nI
		
		If lRepetido
			lRet:=.F.
			Help(" ",1,"JAGRAVADO")
		End
	Endif
EndIf 

nTotPerc :=0

For nI:= 1 To Len(oGetDad1:aCols)
	nTotPerc +=oGetDad1:aCols[nI][nPosPerc]  // percentuais
   If nTotPerc > 100
  		lRet:=.F.
   	Help(" ",1,"CNTA100PVE")
	Endif
Next nI


Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100FoldCh³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a alteracao de folder                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100FoldCh(nExp01,nExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Folder de destino                                  ³±±
±±³          ³ nExp02 - Folder atual                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100FoldCh(nFldDes,nFldAtu,nFldCtb)

Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida origem		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nFldAtu == 1//Fornecedores/Vendedores
		If len(oGetDad1:aCols) > 0
		   if cEspCtr="1"
				if !CN100VldFor()
					lRet := .F.
				EndIf
			Else	
				if !CN100VldVen()
					lRet := .F.
				EndIf
			Endif
		EndIf
	Case nFldAtu == 5//Multas/Descontos
		if len(oGetDad5:aCols) > 0
			If !CN100VldMul()
				lRet := .F.
			EndIf
		EndIf
EndCase

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida destino	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case nFldDes == nFldCtb  //Cronograma contabil
			lRet := lContab
		Case nFldDes == 2  //Caução
			If CN9->(FieldPos("CN9_FLGCAU")) > 0
				lRet := M->CN9_FLGCAU == '1'
			EndIf	   
		Case nFldDes == 3  //Planilha
			dbSelectArea("CN1")
			dbSetOrder(1)
			If (CN1->(FieldPos("CN1_CTRFIX")) > 0) .And. dbSeek(xFilial("CN1")+M->CN9_TPCTO)
				lRet := (Empty(CN1->CN1_CTRFIX) .Or. CN1->CN1_CTRFIX == "1")
			EndIf
		Case nFldDes == 4  //Cronograma
			dbSelectArea("CN1")
			dbSetOrder(1)
			If (CN1->(FieldPos("CN1_VLRPRV")) > 0) .And. dbSeek(xFilial("CN1")+M->CN9_TPCTO)
				lRet := (Empty(CN1->CN1_CTRFIX) .Or. CN1->CN1_CTRFIX == "1")
			EndIf
	EndCase
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Legenda³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de legenda do contrato                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Legenda(nExp01,nExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Legenda()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com as cores que representam a situacao de cada Contrato na mBrowse.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aLegenda := {	{"BR_VERMELHO", OemtoAnsi(STR0042)	},; // Cancelado
					{"BR_AMARELO" , OemtoAnsi(STR0043)	},; // Em Elaboracao
					{"BR_AZUL"    , OemtoAnsi(STR0044)	},; // Emitido
					{"BR_LARANJA" , OemtoAnsi(STR0045)	},; // Em Aprovacao
					{"BR_VERDE"   , OemtoAnsi(STR0046)	},; // Vigente
					{"BR_CINZA"   , OemtoAnsi(STR0047)	},; // Paralisado
					{"BR_MARRON"  , OemtoAnsi(STR0048)	},; // Sol. Finalizacao
					{"BR_PRETO"	  , OemtoAnsi(STR0049)	},; // Finalizado
					{"BR_PINK"    , OemtoAnsi(STR0050)	},; // Revisao
					{"BR_BRANCO"  , OemtoAnsi(STR0051)	}}  // Revisado
Local lCn100leg := ExistBlock("CN100LEG")
Local aLegUsr	:= {}

If lCn100leg
	aLegUsr := ExecBlock("CN100LEG",.F.,.F.,{aLegenda})
   	If ( ValType(aLegUsr) == "A" )
		aLegenda := aClone(aLegUsr)
	EndIf
EndIf

BrwLegenda(cCadastro, OemtoAnsi(STR0018), aLegenda)//"Legendas"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VlDIni ³ Autor ³ Marcelo Custodio      ³ Data ³13.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data inicial                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VlDIni()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VlDIni()
Local lRet := .T.

lRet := (M->CN9_DTINIC >= dDataBase)

If lRet .And. !Empty(M->CN9_DTASSI)
	lRet := (M->CN9_DTINIC > M->CN9_DTASSI)
EndIf

If !lRet
	Help(" ",1,"CNTA100DTI") //"Data de inicio invalida"
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VlDAss ³ Autor ³ Marcelo Custodio      ³ Data ³13.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data de assinatura                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VlDAss()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VlDAss(dDataAssi,dDataInic)
Local lRet       := .T.             
Local lValidAss  := GetNewPar("MV_CNVLASS","S") == "S"  

DEFAULT dDataAssi:= M->CN9_DTASSI
DEFAULT dDataInic:= M->CN9_DTINIC

If lValidAss
	If !Empty(dDataInic)
		lRet := (dDataAssi >= dDataInic)
	EndIf
	
	If !lRet
		Help(" ",1,"CNTA100ASS") //"Data de assinatura deve ser maior que a data de inicio"
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100DtFim  ³ Autor ³ Marcelo Custodio      ³ Data ³13.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula data final de acordo com a vigencia escolhida        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ dExp01 := CN100DtFim(cExp02,dExp03,cExp04)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp01 - Data calculada                                      ³±±
±±³          ³ cExp04 - Tipo de Vigencia                                    ³±±
±±³          ³          "1" - Dias                                          ³±±
±±³          ³          "2" - Meses                                         ³±±
±±³          ³          "3" - Anos                                          ³±±
±±³          ³ cExp02 - Data calculada                                      ³±±
±±³          ³ dExp03 - Vigencia                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100DtFim(cTipV,dDtIni,nVig)
Local nX			:= 0
Local nDiaIni		:= 1
Local dDtOri		:= dDtIni
Local dDtUsr		:= dDtIni
Local oModel		:= FWModelActive()
Local aSaveLines	:= FWSaveRows()

If !Empty(nVig) .Or. cTipV == "4"
	Do Case
		Case cTipV == "1"  //Dia
			dDtIni += nVig
		Case cTipV == "2"  //Mes  
			nDiaIni := Day(dDtIni) //Dia do início do contrato.
			For nX := 1 to nVig    
				dDtIni += CalcAvanco(dDtIni,.F.,.F.,nDiaIni) 
			Next  
			dDtIni -= 1
		Case cTipV == "3"  //Ano
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida ano bissexto                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Day(dDtIni) == 29 .And. Month(dDtIni) == 2 .And. ((Year(dDtIni)+nVig) % 4 != 0)
				dDtIni := cTod("28/02/"+str(Year(dDtIni)+nVig))
			Else
				dDtIni := cTod(str(Day(dDtIni))+"/"+str(Month(dDtIni))+"/"+str(Year(dDtIni)+nVig))
			EndIf 
			dDtIni -= 1
		Case cTipV == "4"  //Indeterminada
			dDtIni := CTOD("31/12/49")//Retorna data limite do sistema
	EndCase
EndIf

If ExistBlock("CN100ALTDF")
	dDtIni := If( ValType (dDtUsr := ExecBlock("CN100ALTDF",.F.,.F., {dDtIni,cTipV,nVig} ) ) == "D",dDtUsr, dDtIni)
EndIf

//-- Ajusta datas nas planilhas
If oModel # NIL .And. oModel:GetID() == "CNTA300" .And. oModel:GetModel("CNADETAIL"):CanUpdateLine()
	For nX := 1 To oModel:GetModel("CNADETAIL"):Length()
		oModel:GetModel("CNADETAIL"):GoLine(nX)
		If !Empty(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTINI")) .And. oModel:GetModel("CNADETAIL"):GetValue("CNA_DTINI") < dDtOri
			oModel:GetModel("CNADETAIL"):SetValue("CNA_DTINI",dDtOri)
		EndIf
		If !Empty(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM")) .And. oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM") > dDtIni
			oModel:GetModel("CNADETAIL"):SetValue("CNA_DTFIM",dDtIni)
		EndIf
	Next nX
EndIf

FWRestRows(aSaveLines)
Return dDtIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100TudOk  ³ Autor ³ Marcelo Custodio      ³ Data ³13.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o cabecalho do contrato                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100TudOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100TudOk()
Local lRet        := .T.
Local lFornCNA    := .T.
Local nPosForn    := aScan(aHeader1,{|x| AllTrim(x[2])  == "CNC_CODIGO"})
Local nPosLoja    := aScan(aHeader1,{|x| AllTrim(x[2])  == "CNC_LOJA"})  
Local nPosFornCNA := aScan(aHeader3,{|x| AllTrim(x[2])  == "CNA_FORNEC"})
Local nPosLojaCNA := aScan(aHeader3,{|x| AllTrim(x[2])  == "CNA_LJFORN"})
Local nPos        := oGetDad1:nAt
Local nForn       := 0
Local nFornCN9    := 0

If cEspCtr =="1"
    lRet := CN100VerFor()	                        

	//Verifica a existencia de planilhas para o fornecedor atual. 
	If lRet .And. Len(aCols1)>0 .And. Len(oGetDad3:aCols)>0
	    If !Empty(aCols1[1][1]) .And. !Empty(oGetDad3:aCols[1][1])
		    For nForn := 1 To Len(oGetDad3:aCols)
				For nFornCN9 := 1 To Len(oGetDad1:aCols)    
					lFornCNA := AllTrim(oGetDad3:aCols[nForn,nPosFornCNA])  == AllTrim(oGetDad1:aCols[nFornCN9,nPosForn]);
							   .And. AllTrim(oGetDad3:aCols[nForn,nPosLojaCNA]) == AllTrim(oGetDad1:aCols[nFornCN9,nPosLoja])
					If lFornCNA 
						Exit
					EndIf
				Next
			Next                 
			
			If !lFornCNA     
			   	Help("  ",1,"CNTA100FRC")
			   	lRet := .F.		
			EndIf       
		EndIf
	EndIf 
Endif

If lRet .And. (M->CN9_FLGCAU == "1") .And. Empty(M->CN9_MINCAU)
	Help(" ",1,"CNTA100PER") //"Preencha o percentual minimo de caucao"
	lRet := .F.
EndIf

If lRet .And. (M->CN9_FLGCAU == "1") .And. If(CN9->( FieldPos("CN9_TPCAUC") )>0,Empty(M->CN9_TPCAUC),.F.)
	Help(" ",1,"CNTA100TPC") //"Informe o tipo de tratamento da caucao"
	lRet := .F.
EndIf

If lRet .And. (M->CN9_FLGREJ == "1") .And. Empty(M->CN9_INDICE)
	Help(" ",1,"CNTA100IND") //"Preencha o indice de reajuste do contrato"
	lRet := .F.
EndIf

If lRet .And. (M->CN9_MOEDA < 1) .Or. (M->CN9_MOEDA > MOEDFIN())
	Help(" ",1,"CNTA100MOE") //"Preencha a moeda corrente"
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida diario contabil - Portugal     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. cPaisloc == "PTG" .And. FINDFUNCTION("CTBVldDiario")
	lRet:= CTBVldDiario(M->CN9_DIACTB)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100SitCh³ Autor ³ Marcelo Custodio      ³ Data ³18.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera situacao do contrato, executando todas as validacoes³±±
±±³          ³ necessarias                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100SitCh(cExp01,cExp02,cExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Numero do contrato                                ³±±
±±³          ³ cExp02 - Revisao do contrato                               ³±±
±±³          ³ cExp03 - Nova situacao do contrato                         ³±±
±±³          ³          1 - Cancelado                                     ³±±
±±³          ³          2 - Em elaboracao                                 ³±±
±±³          ³          3 - Emitido                                       ³±±
±±³          ³          4 - Em aprovacao                                  ³±±
±±³          ³          5 - Vigente                                       ³±±
±±³          ³          6 - Paralisado                                    ³±±
±±³          ³          7 - Sol Paralisacao                               ³±±
±±³          ³          8 - Finalizado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100SitCh(cContra,cRevisa,cNewSituc,cGrpAprov)
Local lMedeve
Local lCaucao
Local lContab
Local lFisico
Local lValor 
Local lCN100VDA := .F.
Local lRet      := .T.
Local lSitAprAlc:= .F.
Local lFilOri	:= CNB->(FieldPos("CNB_FILORI")) > 0

Local nPCauc	:= 0
Local nTotPlan  := 0//Quant de Planilhas
Local nMotPlan  := 0//Montante das planilhas
Local nMotCron  := 0//Montante dos cronogramas
Local nMotCrCt  := 0//Montante dos cronogramas contabeis
Local nMotCauc  := 0//Montante das caucoes

Local cFilCod	:= ""
Local cQuery    := ""
Local cAliasQry := ""  
Local cFilSC1	:= ""
Local cLctoVige := "694"
Local cLctoCanc := "696"
Local cTpDoc	:= "CT"	//Tipo de Documento. Usado para acesso a tabela SCR

Local dDataAssi := dDataBase
Local uRet      := NIL
Local lCtrApr   := .F.
Local lEstorna	:= .F.

Default cGrpAprov := ""

//Informa variacao do contrato fixo/variavel
//através do ponto de entrada CN100FIX
Private lFixo   := .T.

//Controle de alcada
If !Empty(CN1->( FieldPos( "CN1_CTRAPR" )))
	lCtrApr := CN1->CN1_CTRAPR == "1" //Controla alcada
EndIf

If lCtrApr .And. cNewSituc == DEF_SAPRO	//Controla alcada e verifica se a nova situacao e APROVACAO
	lSitAprAlc := .T.
EndIf

//Ponto de entrada que  permite customizar a validação da assinatura do contrato.
If ExistBlock("CN100VDA")
	lCN100VDA := ExecBlock("CN100VDA",.F.,.F.)
	If valtype(lCN100VDA) == "L"  
		lRet := lCN100VDA 
	EndIf
Else 
	If cNewSituc  == DEF_SVIGE .Or. cNewSituc  == DEF_SAPRO   
		dbSelectArea("CN9")
		dbSetOrder(1)
		//Valida data de assinatura
		If	dbSeek(xFilial("CN9")+cContra+cRevisa) 
		    dDataAssi := If(!Empty(CN9->CN9_DTASSI),CN9->CN9_DTASSI,dDataAssi) //Verifica se a data da assinatura já foi preenchida.
			lRet      := CN100VlDAss(dDataAssi,CN9->CN9_DTINIC)
		EndIf
	EndIf
EndIf
		

//Ponto de entrada para validacao da troca de situacao
If ExistBlock("CN100VST")
	uRet := ExecBlock("CN100VST",.F.,.F.,{cNewSituc})
	If valtype(uRet) == "L"
		lRet := uRet
	EndIf
EndIf

If lRet
	Do Case
		Case cNewSituc  = DEF_SEMIT
			dbSelectArea("CN9")
			dbSetOrder(1)
			//Inclui data de assinatura
			If	dbSeek(xFilial("CN9")+cContra+cRevisa)
				RecLock("CN9",.F.)
					CN9->CN9_SITUAC := cNewSituc
					CN9->CN9_DTULST := dDataBase
				MsUnlock()
				Aviso("CNTA100",OemtoAnsi(STR0029),{"Ok"})// "Situacao alterada com sucesso"
			EndIf                             
			
		Case (cNewSituc  = DEF_SAPRO .And. !lCtrApr)//Atualiza situacao para "Em Aprovacao" em contratos que nao possuem controle de aprovacao por alcada
			dbSelectArea("CN9")
			dbSetOrder(1)
			If	dbSeek(xFilial("CN9")+cContra+cRevisa)
				RecLock("CN9",.F.)
					CN9->CN9_SITUAC := cNewSituc
					CN9->CN9_DTASSI := dDataAssi//Inclui data de assinatura
					CN9->CN9_DTULST := dDataBase
				MsUnlock()
				Aviso("CNTA100",OemtoAnsi(STR0029), {"OK"}) //"Situacao alterada com sucesso"
			EndIf
			
		Case cNewSituc  = DEF_SVIGE .OR. ;	//Atualiza situacao para Vigente
			 lSitAprAlc						//Atualiza para "Em Aprovacao" e executa demais validacoes para contratos que possuem controle de aprovacao por alcada
			
			dbSelectArea("CN9")
			dbSetOrder(1)

			If	dbSeek(xFilial("CN9")+cContra+cRevisa)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica situação atual do contrato                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AllTrim(CN9->CN9_SITUAC) == DEF_SELAB .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SEMIT .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SAPRO
					//Medicao Eventual
					lMedeve := (Posicione("CN1",1,xFilial("CN1")+CN9_TPCTO,"CN1_MEDEVE") == "1")
					
					//Previsao Financeira
					lValor := (Posicione("CN1",1,xFilial("CN1")+CN9_TPCTO,"CN1_VLRPRV") $ "1 " )
					
					//Controla ou nao caucao
					lCaucao := (CN9->CN9_FLGCAU == "1" .And. If((CN9->(FieldPos("CN9_TPCAUC")) > 0),(CN9->CN9_TPCAUC == "1"),.T.))
	
					//Controla ou nao cronograma fisico
					lFisico := (CN1->CN1_CROFIS = "1")
	
					//Controla ou nao planilhas
					If (CN1->(FieldPos("CN1_CTRFIX")) > 0)
						lFixo := Empty(CN1->CN1_CTRFIX) .Or. CN1->CN1_CTRFIX = "1"
					EndIf
	
					//Controla ou nao contabil
					lContab := (Posicione("CN1",1,xFilial("CN1")+CN9_TPCTO,"CN1_CROCTB") == "1")
	                
					If lCaucao
						nPCauc := CN9->CN9_MINCAU//Percentual minimo de caucao
					EndIf
					
					If lFixo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica planilhas do contrato                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNA")
						dbSetOrder(1)
						cFilCod := xFilial("CNA")
						dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
						
						While CNA->CNA_FILIAL = cFilCod .And. CNA->CNA_CONTRA = CN9->CN9_NUMERO .And. CNA->CNA_REVISA = CN9->CN9_REVISA
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica cronograma da planilha se o contrato      ³
							//³ nao for de medicao eventual                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !lMedeve .And. Empty(CNA->CNA_CRONOG)
								Help(" ",1,"CNTA100PLA") //"Todas as planilhas devem pertencer a um cronograma"
								lRet := .F.
								exit
							Else
								//Soma montante das planilhas
								nMotPlan+=CNA->CNA_VLTOT
							EndIf
							nTotPlan++
							dbSkip()
						EndDo
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica contrato fixo/variavel                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("CN100FIX")
						lFixo := ExecBlock("CN100FIX",.F.,.F.)
						if Type("lFixo") <> "L"
							lFixo := .T. // o Contrato é do tipo Fixo
						endif
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o contrato possui planilhas            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. nTotPlan == 0 .and. lFixo
						Help(" ",1,"CNTA100POP") //"O contrato nao possui planilhas"
						lRet := .F.
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Alcada - Controla aprovacao por alcada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDeoÄÄÄÄÄÄÙ
					If lRet .And. lCtrApr .And. cNewSituc == DEF_SVIGE
						Help(" ",1,"CN100ALCADA") //"O contrato possui controle de aprovaçao com alcada. Neste caso é obrigatório passar pelo status de APROVAÇÃO."
						lRet := .F.
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica cronogramas se nao for medicao eventual   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. !lMedeve
					
						If !lFisico	
							dbSelectArea("CNF")
							dbSetOrder(2)
							cFilCod := xFilial("CNF")
							dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
							
							while CNF->CNF_FILIAL = cFilCod .And. CNF->CNF_CONTRA = CN9->CN9_NUMERO .And. CNF->CNF_REVISA = CN9->CN9_REVISA
								//Soma montante dos cronogramas
								nMotCron+=CNF->CNF_VLPREV
								dbSkip()
							EndDo           
		
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Arredonda valores totais de cronograma e planilha    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
							nMotCron := Round(nMotCron,TamSX3("CNF_VLPREV")[2])
							nMotPlan := Round(nMotPlan,TamSX3("CNA_VLTOT")[2])
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica montante dos cronogramas contra montante    ³
							//³ das planilhas                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nMotPlan != nMotCron
								Help(" ",1,"CNTA100MON") //"O montante das planilhas nao equivale ao montante dos cronogramas"
								lRet := .F.
							EndIf
						Else
							cAliasQry := GetNextAlias()
	
							cQuery := "SELECT CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM,SUM(CNS.CNS_PRVQTD) AS CNS_PRVQTD "
							cQuery += "  FROM "+ RetSQLName("CNS") +" CNS "
							cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
							cQuery += "   AND CNS.CNS_CONTRA = '"+CN9->CN9_NUMERO+"'"
							cQuery += "   AND CNS.CNS_REVISA = '"+CN9->CN9_REVISA+"'"
							cQuery += "   AND CNS.D_E_L_E_T_ = ' ' "
							cQuery += " GROUP BY CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM"
							
							cQuery := ChangeQuery( cQuery )			
							dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
	
							TCSetField( cAliasQry, "CNS_PRVQTD", "N", TamSX3("CNS_PRVQTD")[1], TamSX3("CNS_PRVQTD")[2] )
							
							dbSelectArea("CNB")
							dbSetOrder(1)
							
							cFilCod := xFilial("CNB")
							While !(cAliasQry)->(Eof())
								If dbSeek(cFilCod+(cAliasQry)->CNS_CONTRA+(cAliasQry)->CNS_REVISA+(cAliasQry)->CNS_PLANI+(cAliasQry)->CNS_ITEM)
									If CNB->CNB_QUANT != (cAliasQry)->CNS_PRVQTD
										lRet := .F.
										Aviso(STR0088,STR0143+(cAliasQry)->CNS_ITEM+STR0144+(cAliasQry)->CNS_PLANI+STR0145,{"OK"},2)//"Atencao"##"O item "####" da planilha "##" possui saldo em aberto para distribuição no cronograma físico."
										Exit
									EndIf
								EndIf
								(cAliasQry)->(dbSkip())
							EndDo
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica caucoes quando houver controle              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. lCaucao
						dbSelectArea("CN8")
						dbSetOrder(2)
						cFilCod := xFilial("CN8")
						dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
						
						While CN8->CN8_FILIAL = cFilCod .And. CN8->CN8_CONTRA = CN9->CN9_NUMERO .And. CN8->CN8_REVISA = CN9->CN9_REVISA
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Soma montante das caucoes quando nao estiver baixada ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(CN8_DTBX)
								nMotCauc+=CN8->CN8_VLEFET
							EndIf
							dbSkip()
						EndDo
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica percentual minimo de caucao                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (CN9->CN9_VLINI*nPCauc)/100 > nMotCauc
							Help(" ",1,"CNTA100MIN") //"O contrato nao possui o percentual minimo de caucao especificado" 
							lRet := .F.
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica valor inicial do contrato se ele for do tipo flexivel e possuir previsao financeira  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. lMedeve .And. !lFixo .And. lValor
						If CN9->CN9_VLINI <= 0
							Aviso(STR0088,STR0146,{"OK"})//"Atencao !"O tipo de Contrato selecionado não permite vigência com valor inicial zerado!"
							lRet := .F.
						EndIf
					EndIf
				Else
					Help(" ",1,"CNTA100INV") //"Situacao atual invalida"
					lRet := .F.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica configuracao contabil das planilhas         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. lContab
					cQuery := "SELECT CNA.CNA_NUMERO "
					cQuery += "  FROM "+ RetSQLName("CNA") +" CNA "
					cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
					cQuery += "   AND CNA.CNA_CONTRA = '"+CN9->CN9_NUMERO+"'"
					cQuery += "   AND CNA.CNA_REVISA = '"+CN9->CN9_REVISA+"'"
					cQuery += "   AND CNA.CNA_CRONCT = '' "
					cQuery += "   AND D_E_L_E_T_     = ' '"
	
					cAliasQry := GetNextAlias()
	
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
					
					If !(cAliasQry)->(Eof())
						Aviso("CNTA100",OemtoAnsi(STR0135)+(cAliasQry)->CNA_NUMERO+OemtoAnsi(STR0136),{"Ok"})//"A planilha "###" não possui cronograma contábil" 
						lRet := .F.					
					EndIf
					(cAliasQry)->(dbCloseArea())
					
					If lRet
						//Verifica montante das planilhas com o montante dos cronogramas contabeis
						cQuery := "SELECT SUM(CNW_VLPREV) as CNW_VLPREV "
						cQuery += "  FROM "+ RetSQLName("CNW")+" CNW,"+ RetSQLName("CNV")+" CNV,"+ RetSQLName("CNA")+" CNA "
						cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
						cQuery += "   AND CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
						cQuery += "   AND CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
						cQuery += "   AND CNW.CNW_CONTRA = '"+CN9->CN9_NUMERO+"'"
						cQuery += "   AND CNW.CNW_REVISA = '"+CN9->CN9_REVISA+"'"
						cQuery += "   AND CNW.CNW_CONTRA = CNV.CNV_CONTRA "
						cQuery += "   AND CNW.CNW_REVISA = CNV.CNV_REVISA "
						cQuery += "   AND CNW.CNW_NUMERO = CNV.CNV_NUMERO "
						cQuery += "   AND CNV.CNV_CONTRA = CNA.CNA_CONTRA "
						cQuery += "   AND CNV.CNV_REVISA = CNA.CNA_REVISA "
						cQuery += "   AND CNV.CNV_PLANIL = CNA.CNA_NUMERO "
						cQuery += "   AND CNW.D_E_L_E_T_ = ' ' "
						cQuery += "   AND CNV.D_E_L_E_T_ = ' ' "
						cQuery += "   AND CNA.D_E_L_E_T_ = ' '"
	                	
						cAliasQry := GetNextAlias()
	                	
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)					
                    	
                    	nMotCrCt := (cAliasQry)->CNW_VLPREV
                    	
                    	(cAliasQry)->(dbCloseArea())
                    	
  						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Arredonda valores dos cronogramas contabeis          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
						nMotCrCt := Round(nMotCrCt,TamSX3("CNW_VLPREV")[2])
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica montante dos cronogramas contra montante    ³
						//³ das planilhas                                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nMotPlan != nMotCrCt
							Aviso("CNTA100",OemtoAnsi(STR0147),{"Ok"})//"O montante das planilhas não equivale ao montante dos cronogramas contábeis. Verifique a configuração contábil do contrato!"
							lRet := .F.
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alcada - Gerar documento bloqueado com o tipo             ³
				//³"CT" (Contratos) na tela de liberação de documentos (SCR) ³
				//³Somente na mudança para "EM APROVACAO"                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. lSitAprAlc
					If !CN100Alc(cRevisa,cGrpAprov)
						lRet := .F.
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera Base Instalada e Ordem de Serviço³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. SuperGetMv("MV_CNINTFS",.F.,.F.) .And. CN1->CN1_ESPCTR == "2"					
					lRet := CN100BIns(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_DTASSI)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa alteracao quando todas as validacoes estiverem OK ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa contabilizacao do contrato     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					CN100Contab(cLctoVige)
				
					CN100CtrVg(lSitAprAlc)
					Aviso("CNTA100",OemtoAnsi(STR0029) + IIf(lSitAprAlc, CRLF + OemtoAnsi(STR0159) + cGrpAprov+".", ""), {"OK"}) //"Situacao alterada com sucesso" ## "Documento com controle de Alçada gerado. Aguardando aprovação do grupo "
				EndIf
			EndIf
			
			If lRet .And. !lMedeve .And. (GetNewPar( "MV_CNPROVI" ,  "S" ) == "S")
				MsAguarde({||CN100CTit(cContra,cRevisa)},STR0058)//Gera Titulos provisorios
			EndIf
			
		Case cNewSituc == DEF_SFINA
			dbSelectArea("CN9")
			dbSetOrder(1)
			If	dbSeek(xFilial("CN9")+cContra+cRevisa)
				If CN100VerNf(cContra,cRevisa)
					//-- Se veio direto do vigente, processa solicitacao de finalizacao para depois finalizar
					If CN9->CN9_SITUAC == DEF_SVIGE
						CN100SlFin(lCtrApr) //-- Chama funcao que processa codigo relacionado a solicitacao de finalizacao
					EndIf			
				
					RecLock("CN9",.F.)
						CN9->CN9_SITUAC := cNewSituc
						CN9->CN9_DTULST := dDataBase
					MsUnlock()
					
					//-- Libera SCs vinculadas ao contrato
					SC1->(dbSetOrder(1))
					CNB->(dbSetOrder(1))
					CNB->(dbSeek(xFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)))
					While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == xFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)
						If lFilOri .And. !Empty(CNB->CNB_FILORI)
							cFilSC1 := xFilial("SC1",CNB->CNB_FILORI)
						Else
							cFilSC1 := xFilial("SC1")
						EndIf
						If !Empty(CNB->CNB_NUMSC) .And. SC1->(dbSeek(cFilSC1+CNB->(CNB_NUMSC+CNB_ITEMSC)))
							RecLock("SC1",.F.)
							SC1->C1_FLAGGCT := ""
							SC1->(MsUnLock())
						ElseIf CN9->(FieldPos("CN9_CODED")) > 0 .And. !Empty(CN9->CN9_CODED)
							SC1->(dbOrderNickName("GCP01"))
							SC1->(dbSeek(cFilSC1+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT))
							While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == cFilSC1+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT
								RecLock("SC1",.F.)
								SC1->C1_FLAGGCT	:= ""
								SC1->(MsUnlock())
													
								SC1->(dbSkip())
							End
						EndIf
						CNB->(dbSkip())
					End
					
					MsAguarde({||CN100ETit(cContra,cRevisa)},STR0061)//"Estornando títulos"
					Aviso("CNTA100",OemtoAnsi(STR0029),{"Ok"})// "Situacao alterada com sucesso" 
				Else 			
					lRet := .F.
				EndIf
			EndIf              
		Case cNewSituc == DEF_SELAB
			CN9->(dbSetOrder(1))	//CN9_FILIAL+CN9_NUMERO+CN9_REVISA
			CN9->(dbSeek(xFilial("CN9")+cContra+cRevisa))
			                     
			//-- Query para validar itens que geraram base instalada
			If CNB->(FieldPos("CNB_GERBIN")) > 0
				BeginSQL Alias "CNBTMP"
				SELECT CNB_ITEM
				FROM %Table:CNB% CNB
				WHERE CNB.%NotDel% AND
					CNB.CNB_FILIAL = %xFilial:CNB% AND
					CNB.CNB_CONTRA = %Exp:cContra% AND
					CNB.CNB_REVISA = %Exp:cRevisa% AND
					CNB.CNB_GERBIN = '1'		
				EndSQL					
			EndIf

			//-- Query para validar baixas de cauções
			BeginSQL Alias "CN8TMP"
			SELECT CN8_CONTRA
			FROM %Table:CN8% CN8
			WHERE CN8.%NotDel% AND
				CN8.CN8_FILIAL = %xFilial:CN8% AND
				CN8.CN8_CONTRA = %Exp:cContra% AND
				CN8.CN8_REVISA = %Exp:cRevisa% AND
				CN8.CN8_VLBX > 0
			EndSQL
			
			//-- Query para validar medições em outras filiais
			If CN9->(FieldPos("CN9_FILCTR")) > 0
				BeginSQL Alias "CNDTMP"
				SELECT CND.CND_NUMMED
				FROM %Table:CND% CND
				WHERE CND.%NotDel% AND
					CND.CND_FILCTR = %Exp:CN9->CN9_FILCTR% AND
					CND.CND_CONTRA = %Exp:cContra% AND
					CND.CND_REVISA = %Exp:cRevisa%
				EndSQL
			EndIf
					
			CNB->(dbSetOrder(1)) //CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
			CND->(dbSetOrder(2)) //CND_FILIAL+CND_CONTRA+CND_NUMERO            
			CNX->(dbSetOrder(1)) //CNX_FILIAL+CNX_CONTRA+CNX_NUMERO
			COA->(dbSetOrder(2)) //COA_FILIAL+COA_CONTRA+COA_REVISA+COA_AVALIA
			         			
			If  Empty(cRevisa) .And.;	//-- Não revisado
					!COA->(dbSeek(xFilial("COA")+cContra+cRevisa)) .And.; //-- Sem avaliações de contrato
				 	!CND->(dbSeek(xFilial("CND")+cContra)) .And.; //-- Sem medição na filial corrente
					!CNX->(dbSeek(xFilial("CNX")+cContra)) .And.; //-- Sem adiantamentos de contrato
					CN8TMP->(EOF()) .And.; // Sem baixa de caução
					If(CNB->(FieldPos("CNB_GERBIN")) > 0,CNBTMP->(EOF()),.T.) .And.;  //-- Sem base instalada
					If(CND->(FieldPos("CND_FILCTR")) > 0,CNDTMP->(EOF()),.T.)	//-- Sem medição em outras filiais 
                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Altera situacao e datas do contrato  |  
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("CN9",.F.)
				CN9->CN9_SITUAC := cNewSituc
				CN9->CN9_DTULST := dDataBase
				CN9->CN9_DTASSI := CTOD("  /  /  ")
				CN9->(MsUnlock())
				
				//Situação Elaboração
				//Verifica se já existe registro na SCR para deletar
				If SCR->(dbSeek(xFilial("SCR")+"CT"+cContra))
					MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)  
				EndIF
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Limpa o campo Data Aniversario dos itens da Planilha do Contrato |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CNB->(dbSeek(xFilial("CNB")+cContra+cRevisa))
				While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) = xFilial("CNB")+cContra+cRevisa
					If !Empty(CNB->CNB_DTANIV)		 		
						RecLock("CNB", .F.)
						CNB->CNB_DTANIV := CTOD("  /  /  ")
						CNB->(MsUnLock())
					EndIf
					CNB->(dbSkip())
				End			
                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Estornando titulos relacionados ao contrato  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_MEDEVE") # "1" .And. SuperGetMV("MV_CNPROVI",.F.,"S") == "S"
					MsAguarde({||CN100ETit(cContra,cRevisa)},STR0061)
				EndIf
			Else
				Help(" ",1,"CNT100ESTORNA")//"Este Contrato já sofreu movimentação, por isso, sua situação não pode ser alterada."
			EndIf
			
			//-- Fecha arquivos temporarios
			If CNB->(FieldPos("CNB_GERBIN")) > 0                   
				CNBTMP->(dbCloseArea())
			EndIf
			If CN9->(FieldPos("CN9_FILCTR")) > 0                   
				CNDTMP->(dbCloseArea())
			EndIf
			CN8TMP->(dbCloseArea())	                                
						
		Case cNewSituc == DEF_SCANC		
			dbSelectArea("CN9")
			dbSetOrder(1)
			If	dbSeek(xFilial("CN9")+cContra+cRevisa) 
				CN100Cance(.T.,lCtrApr)
			EndIf
			
		Otherwise
			dbSelectArea("CN9")
			dbSetOrder(1)
			If	dbSeek(xFilial("CN9")+cContra+cRevisa)
				RecLock("CN9",.F.)
					CN9->CN9_SITUAC := cNewSituc
					CN9->CN9_DTULST := dDataBase
				MsUnlock()
				
				CN100SlFin(lCtrApr) //-- Chama funcao que processa codigo relacionado a solicitacao de finalizacao
				Aviso("CNTA100",OemtoAnsi(STR0029)+IIf(lEstorna, CRLF+OemtoAnsi(STR0176), ""), {"Ok"})// "Situacao alterada com sucesso" ## "Documento(s) para aprovação na rotina de Liberação foi(ram) estornado(s) automaticamente."
			EndIf
	EndCase
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100DelFor³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida exclusao de fornecedor                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100DelFor                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100DelFor()
Local lRet := .T.
Local nPosForn := aScan(aHeader,{|x| AllTrim(x[2])  == "CNC_CODIGO"})
Local nPosLoja := aScan(aHeader,{|x| AllTrim(x[2])  == "CNC_LOJA"})
Local nPos := oGetDad1:nAt
//Verifica a existencia de planilhas para o fornecedor atual
Local nFornCNA := aScan(oGetDad3:aCols,{|x| x[aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_FORNEC"})] == oGetDad1:aCols[nPos,nPosForn] .And. x[aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_LJFORN"})] == oGetDad1:aCols[nPos,nPosLoja]})
Local nFornCN8

lRet := (nFornCNA == 0)

if lRet
	//Verifica a existencia de caucoes para o fornecedor atual
	nFornCN8 := aScan(oGetDad2:aCols,{|x| x[aScan(aHeader2,{|x| AllTrim(x[2]) == "CN8_FORNEC"})] == oGetDad1:aCols[nPos,nPosForn] .And. x[aScan(aHeader2,{|x| AllTrim(x[2]) == "CN8_LOJA"})] == oGetDad1:aCols[nPos,nPosLoja]})
	lRet := (nFornCN8 == 0)
EndIf

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100DelVen³ Autor ³ Robson Nayland        ³ Data ³04.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida exclusao do Vendedor                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100DelVen                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100DelVen()
Local lRet := .T.
Local nPosVen  := aScan(aHeader,{|x| AllTrim(x[2]) == "CNU_CODVD"})
Local nPos := oGetDad1:nAt
//Verifica a existencia de planilhas para o fornecedor atual
Local nVenCNA := aScan(oGetDad1:aCols,{|x| x[aScan(aHeader1,{|x| AllTrim(x[2]) == "CNU_CODVD"})] == oGetDad1:aCols[nPos,nPosVen]})
Local nVenCN8

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Hist  ³ Autor ³ Marcelo Custodio      ³ Data ³20.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Historico do contrato                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Hist(cExp01)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Contrato                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Hist(cContra)
Local aAntRotina   := If(Type("aRotina") == "A",aRotina,NIL)
Local aIndCNG      := {}
Local cAntCadastro := If(Type("cCadastro") == "C",cCadastro,NIL)
Local cFilter      := 'CNG_FILIAL == "' + xFilial("CNG") + '" .And. CNG_CONTRA == "' + cContra + '"'

Private cCadastro  := OemToAnsi(STR0034) //"Historico"

Private aRotina := 	{ 	{ OemToAnsi(STR0002), "AxPesqui", 0, 1},;//"Pesquisar"
						{ OemToAnsi(STR0003), "AxVisual", 0, 2}} //"Visualizar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra multas do contrato              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FilBrowse("CNG",@aIndCNG,cFilter)

mBrowse(6,1,22,75,"CNG")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira filtro do arquivo de multas     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("CNG",aIndCNG)

If !Empty(cAntCadastro)
	cCadastro := cAntCadastro
EndIf
If !Empty(aAntRotina)
	aRotina   := aAntRotina
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Situac³ Autor ³ Marcelo Custodio      ³ Data ³20.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle de situacoes do contrato                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Situac(cExp01,cExp02,nExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Alias do arquivo                                   ³±±
±±³          ³ cExp02 - Registro atual                                     ³±±
±±³          ³ nExp03 - Opcao atual                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Situac(cAlias,nReg,nOpc)
Local cCadastro := OemToAnsi(STR0035) //"Controle de Situacoes"
Local cSitAtu
Local cSitOrg
Local cContra
Local cRevisa
Local cDocPend	:= ""   //Documentos pendentes
Local cGrpApr	:= ""	//Grupo aprovador - tera tratativa quando contrato possuir alcada

Local aSituac   := RetSx3Box( Posicione("SX3", 2, "CN9_SITUAC", "X3CBox()" ),,, TamSX3("CN9_SITUAC")[1] )
Local aSitTx    := {}

Local oSituCb
Local oDlg
Local oGet01,oGet02,oGet03

Local nOpcA

Local lSituAll := (GetNewPar( "MV_CNSITAL", "S" ) == "S")
Local lDocsOk	:= .T.  //Documentos ok/pronto
Local lCtrApr	:= .F.	//Controle de alcada

If CN240VldUsr(CN9->CN9_NUMERO,DEF_TRASIT,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se o contrato e do tipo que contem        ³
	//³controle de documentos                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDeoÄÄÄÄÙ
	DbSelectArea("CN1") //Tipo de Contrato
	DbSetOrder(1) //CN1_FILIAL+CN1_CODIGO
	If DbSeek(xFilial("CN1")+CN9->CN9_TPCTO) 
	    
	 	If !Empty(CN1->( FieldPos( "CN1_CTRAPR" ))) .AND. !Empty(CN1->( FieldPos( "CN1_GRPSIT" )))
	 		If CN1->CN1_CTRAPR == '1' .AND. !Empty(CN1->CN1_GRPSIT) //Controla alcada na mudanca de situacao do contrato
	 			lCtrApr := .T.
	 			cGrpApr := CN1->CN1_GRPSIT
	 		EndIf
		EndIf

		If !Empty(CN1->( FieldPos( "CN1_CTRDOC" )))
			If CN1->CN1_CTRDOC == '1'  //Controla documentos
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar tipos de documentos realacionados³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("CNJ") //Doc x Situacao
				DbSetOrder(2) //CNJ_FILIAL+CNJ_TPCTO
				If CNJ->(DbSeek(xFilial("CNJ")+CN1->CN1_CODIGO)) .Or. CNJ->(DbSeek(xFilial("CNJ")+Space(TamSx3("CNJ_TPCTO")[1]))) //Verifica se existe algum CNJ_TPCTO em branco para considerar.
			    	
			    	While !CNJ->(Eof()) .AND. CNJ->CNJ_FILIAL+CNJ->CNJ_TPCTO == xFilial("CNJ")+CN1->CN1_CODIGO .AND. CNJ->CNJ_SITUAC == CN9->CN9_SITUAC
	
			    		DbSelectArea("CNK")// Documentos entregues
						DbSetOrder(3) //CNK_FILIAL+CNK_CONTRA+CNK_TPDOC
						
			        	If CNK->(MsSeek(xFilial("CNK")+CN9->CN9_NUMERO+CNJ->CNJ_TPDOC))
							
						   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratativa para o mesmo documento fornecido mais de uma vez ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						   	Do While CNK->(!Eof()) .AND. AllTrim(CNK->(CNK_FILIAL+CNK_CONTRA+CNK_TPDOC)) == AllTrim(xFilial("CNK")+CN9->CN9_NUMERO+CNJ->CNJ_TPDOC)
							   	
							   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verificar validade do documento encontrado³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							   	If CNK_DTVALI < dDataBase
									cDocPend += CNJ->CNJ_TPDOC + " - " + AllTrim(CNJ->CNJ_DESCTD) + " (" + STR0173 + ") (Seq. " + CNK->CNK_CODIGO + ")" + Chr(13)+Chr(10)	//VENCIDO
									lDocsOk  := .F.
							   	EndIf
							   	CNK->(DbSkip())
						   	EndDo						   	
						   	
						Else
							cDocPend += CNJ->CNJ_TPDOC + " - " + AllTrim(CNJ->CNJ_DESCTD) + Chr(13)+Chr(10)
							lDocsOk  := .F.
			        	EndIf
			        	
			        	CNJ->(DbSkip())
			        	
			        EndDo
										
	           		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Mostrar documentos pendentes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	               	If !lDocsOk
						Help(" ",1,"CNNODOC",,STR0188 + Chr(13)+Chr(10) +cDocPend +STR0189,1,0)
				    EndIf	 
			    Else
					Help(" ",1,"CNNOCNJ",,STR0187 +CN1->CN1_CODIGO + ".",1,0)
			        lDocsOk := .F. // Nao tem documento relacionado
			    EndIf    
			EndIf
	    EndIf
	EndIf
		        
	If lDocsOk
    
		dbSelectArea("SX3")
		dbSetOrder(2)
	
		//Situacao atual
		cSitOrg := CN9->CN9_SITUAC
		cSitAtu := AllTrim( aSituac[Ascan( aSituac, { |aBox| substr(aBox[1],1,At("=",aBox[1])-1) = AllTrim(cSitOrg)} )][3] )
	
		dbSelectArea("CN9")
		dbGoto(nReg)
	
		cContra := CN9->CN9_NUMERO
		cRevisa := CN9->CN9_REVISA
		
		If CtrRevisa( CN9->CN9_FILIAL, CN9->CN9_NUMERO, CN9->CN9_REVISA )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Disponibliza as situacoes de acordo    ³
			//³ com a atual                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ De: Elaboracao                         ³
				//³ Para: Emitido, Aprovacao, Vigente      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case AllTrim(CN9->CN9_SITUAC) == DEF_SELAB
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SEMIT})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SAPRO})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SVIGE})][1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ De: Emitido                                        ³
				//³ Para: Elaboracao, Aprovacao, Vigente, Cancelado    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case AllTrim(CN9->CN9_SITUAC) == DEF_SEMIT
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SAPRO})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SVIGE})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ De: Aprovacao                          ³
				//³ Para: Elaboracao, Vigente, Cancelado   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case AllTrim(CN9->CN9_SITUAC) == DEF_SAPRO
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SVIGE})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ De: Vigente                            ³
				//³ Para: Sol. Finalizacao, Cancelado      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case AllTrim(CN9->CN9_SITUAC) == DEF_SVIGE
					//-- Parametro que define se finaliza direto do vigente ou se passa por solicitacao de finalizacao
					If SuperGetMV("MV_CNVGFIN",.F.,.F.)
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SFINA})][1])
					Else
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SSPAR})][1])
					EndIf
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ De: Sol Finalizacao                    ³
				//³ Para: Finalizado, Cancelado            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Case AllTrim(CN9->CN9_SITUAC) == DEF_SSPAR
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SFINA})][1])
					aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
			EndCase
		
			DEFINE MSDIALOG oDlg TITLE cCadastro From 165,115 TO 290,430 PIXEL
	
			@ 7,10 Say STR0036 Of oDlg PIXEL//"Contrato"
			@ 5,50 MsGet oGet01 Var cContra Picture PesqPict("CN9","CN9_NUMERO") When .F. PIXEL  Size 50,5 Of oDlg
	
			@ 7,102 Say STR0037 Of oDlg PIXEL//"Revisão"
			@ 5,125 MsGet oGet02 Var cRevisa Picture PesqPict("CN9","CN9_REVISA") When .F. PIXEL  Size 10,5 Of oDlg
	
			@ 22,10 Say STR0038 Of oDlg PIXEL//"Situacao Atual"
			@ 20,50 MsGet oGet03 Var cSitAtu When .F. Of oDlg PIXEL
	
			@ 37,10 Say STR0039 Of oDlg PIXEL//"Nova Situacao"
			@ 35,50 MsComboBox oSituCb ITEMS aSitTx When (len(aSitTx) > 0) SIZE 60,5 OF oDlg PIXEL
	                                                
			DEFINE SBUTTON FROM 50, 93 TYPE 1 When (len(aSitTx) > 0) ACTION (if(!Empty(oSituCb),(nopca:=1,oDlg:End()),Aviso("CNTA100",OemtoAnsi(STR0040),{"Ok"}))) ENABLE OF oDlg
			DEFINE SBUTTON FROM 50, 123 TYPE 2 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oDlg
	
			ACTIVATE MSDIALOG oDlg CENTERED
		
			If nOpca == 1 .And. Aviso("CNTA100",OemtoAnsi(STR0041),{STR0052,STR0053}) == 1 .And. CN100Doc(nReg,{oSituCb},.T.)//"Confirma a mudanca de situacao do contrato?"
	
		   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Rotina de alteracao da situacao do contrato³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CN100SitCh(CN9->CN9_NUMERO,CN9->CN9_REVISA,oSituCb,cGrpApr)
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Chama ponto de entrada para tratamento de inclusao  ³
					//³ de novas rotinas apos alterar a situacao do contrato³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
					If ExistBlock("CN100SIT")
			  			ExecBlock("CN100SIT",.f.,.f.,{cSitOrg,oSituCb})
					EndIf 
			   
					If (lSituAll .Or. oSituCb == DEF_SPARA .Or. oSituCb == DEF_SSPAR .Or. oSituCb == DEF_SFINA) .And. CN1->CN1_ESPCTR <> "2"
						CN220Aval(cAlias,nReg,nOpc,,.F.,oSituCb)
					EndIf
				EndIf
			EndIf
		Else
			MsgAlert( OemToAnsi(STR0038)+": "+OemToAnsi(STR0037)+CRLF+OemToAnsi(STR0175), OemToAnsi(STR0088) ) //"Atenção!" 
		EndIf
	EndIf //If lDocsOk
EndIf 

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100FilCont³ Autor ³ Marcelo Custodio      ³ Data ³20.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra consulta padrao CN9001 apenas com contratos vigentes  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100FilCont()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100FilCont()

Return "@#CN9_SITUAC == '"+DEF_SVIGE+"'@#"//(AllTrim(CN9_SITUAC) == DEF_SVIGE)        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100Conh ³ Autor ³Sergio Silveira        ³ Data ³15/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada da visualizacao do banco de conhecimento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN100Conh()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CN100Conh()

Local aRotBack := AClone( aRotina )
Local nBack    := 0

If Type( "N" ) == "N" 
	nBack := N	
EndIf 

Private aRotina := {}

Aadd(aRotina,{STR0055,"MsDocument", 0 , 2}) //"Conhecimento"

MsDocument( "CN9", CN9->( Recno() ), 1 )

aRotina := AClone( aRotBack )

If !Empty( nBack )
	N := nBack
EndIf 	

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100CTit ³ Autor ³Marcelo Custodio       ³ Data ³17/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera titulos provisorios a pagar com base no cronograma     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN100CTit(cExp01,cExp02,cExp03,cExp04,nExp05)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do Contrato                                 ³±±
±±³          ³cExp02 - Codigo da revisao                                  ³±±
±±³          ³cExp03 - Numero do cronograma - opcional                    ³±±
±±³          ³cExp04 - Parcela do cronograma - opcional                   ³±±
±±³          ³nExp05 - Saldo restante - opcional                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100CTit(cContra,cRevisa,cCronog,cParcel,nSaldo,cFilCtr)

Local aStrucCNF:= CNF->(dbStruct())
Local aArea    := GetArea()
Local aVend    := CtaVend(cContra)
Local aCond    := {}

Local nComis   := 0
Local nParcel  := 0
Local nValT    := 0
Local nx
Local ny

Local cPlan    := ""
Local cQuery   := ""
Local cMaxTit  := ""
Local cPrefixo
Local cNatTit
Local cEspCtr
Local cFilSE1  := xFilial("SE1")
Local cFilSE2  := xFilial("SE2")
Local cVend    := "1"

Local lPeSE2   := Existblock("CNTPRSE2")
Local lPeSE1   := Existblock("CNTPRSE1")
Local lCnProCP:= GetNewPar( "MV_CNPROCP", "N" ) == "S"
Local lMoeda   := (GetNewPar( "MV_CNMOEDA", "S" ) == "S")

Default cCronog := ""
Default cParcel := ""
Default nSaldo  := -1
Default cFilCtr := cFilAnt

dbSelectArea("CN9")
dbSetOrder(1)
If dbSeek(xFilial("CN9",cFilCtr)+cContra+cRevisa)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Venda ou Compra                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CN9->(FieldPos("CN9_ESPCTR")) > 0
		cEspCtr := CN9->CN9_ESPCTR
	ElseIf !Empty(CN9->CN9_CLIENT)
		cEspCtr := "2"
	Else
		cEspCtr := "1"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a natureza do contrato            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(CN9->(FieldPos("CN9_NATURE"))) .And. !Empty(CN9->CN9_NATURE)
		cNatTit := CN9->CN9_NATURE
	ElseIf cEspCtr == "1"
		cNatTit := PadR(SuperGetMV("MV_CNNAT",.F.,""),Len(SE2->E2_NATUREZ))
	Else
		cNatTit := PadR(SuperGetMV("MV_CNNATCL",.F.,""),Len(SE1->E1_NATUREZ))
	EndIf
	
	If cEspCtr == "1"
		cPrefixo := PadR( GetNewPar( "MV_CNPREF",  "" ), Len( SE2->E2_PREFIXO ) )
		dbSelectArea("SE2")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona sequencia dos titulos a pagar    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If UPPER(TcGetDb()) <> "POSTGRES"
			cQuery := "SELECT MAX(SE2.E2_NUM) as E2_NUM "
			cQuery += "  FROM "+ RetSQLName("SE2") +" SE2 "
			cQuery += " WHERE SE2.E2_FILIAL = '"+xFilial("SE2",cFilCtr)+"'"
			cQuery += "   AND SE2.E2_PREFIXO = '"+ cPrefixo +"'"
			cQuery += "   AND SE2.D_E_L_E_T_ = ' '"
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE2TMP",.F.,.T.)
			
			cMaxTit := Soma1(SE2TMP->E2_NUM)
			
			SE2TMP->(dbCloseArea())      
		Else  
			SE2->(dbSetOrder(1))
			SE2->(dbSeek(xFilial("SE2")+cPrefixo+"ZZZ",.T.))
			SE2->(dbSkip(-1)) 
			cMaxTit := Soma1(SE2->E2_NUM)
		EndIf	
	Else
		cPrefixo := PadR( GetNewPar( "MV_CNPRECL",  "" ), Len( SE1->E1_PREFIXO ) )
		dbSelectArea("SE1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona sequencia dos titulos a pagar    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		If UPPER(TcGetDb()) <> "POSTGRES"
			cQuery := "SELECT MAX(SE1.E1_NUM) as E1_NUM "
			cQuery += "  FROM "+ RetSQLName("SE1") +" SE1 "
			cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1",cFilCtr)+"'"
			cQuery += "   AND SE1.E1_PREFIXO = '"+ cPrefixo +"'"
			cQuery += "   AND SE1.D_E_L_E_T_ = ' '"
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE1TMP",.F.,.T.)
			
			cMaxTit := Soma1(SE1TMP->E1_NUM)    

			SE1TMP->(dbCloseArea())
		Else  
			SE1->(dbSetOrder(1))
			SE1->(dbSeek(xFilial("SE1")+cPrefixo+"ZZZ",.T.))
			SE1->(dbSkip(-1)) 
			cMaxTit := Soma1(SE1->E1_NUM)
		EndIf	

	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona parcelas dos cronogramas         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT distinct CNF.*, CNA.CNA_NUMERO, CNA.CNA_FORNEC, CNA.CNA_LJFORN, CNA.CNA_VLCOMS, CNA_VLTOT, CNA_CLIENT, CNA_LOJACL"
	cQuery += "  FROM "+ RetSQLName("CNF") + " CNF,"+ RetSQLName("CNA") +" CNA "
	cQuery += " WHERE CNF.CNF_FILIAL = '"+ xFilial("CNF",cFilCtr) +"'"
	cQuery += "   AND CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCtr) +"'"
	cQuery += "   AND CNA.CNA_CRONOG = CNF.CNF_NUMERO "
	cQuery += "   AND CNA.CNA_CONTRA = CNF.CNF_CONTRA "
	cQuery += "   AND CNA.CNA_REVISA = CNF.CNF_REVISA "
	cQuery += "   AND "
	If !Empty(cCronog)
		cQuery += "CNA.CNA_CRONOG    = '"+ cCronog +"' AND "
		cQuery += "CNF.CNF_NUMERO    = '"+ cCronog +"' AND "
	EndIf
	If !Empty(cParcel)
		cQuery += "CNF.CNF_PARCEL    = '"+ cParcel +"' AND "
	EndIf
	cQuery += "     CNF.CNF_CONTRA   = '"+ CN9->CN9_NUMERO +"'"
	cQuery += " AND CNF.CNF_REVISA   = '"+ CN9->CN9_REVISA +"'"
	cQuery += " AND CNF.D_E_L_E_T_   <> '*' "
 	cQuery += " AND CNA.D_E_L_E_T_   <> '*' "
	cQuery += " ORDER BY CNF.CNF_CONTRA,CNF.CNF_REVISA,CNF.CNF_NUMERO,CNF.CNF_PARCEL"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNFTMP",.F.,.T.)
	
	For nx:=1 to len(aStrucCNF)
		if CNFTMP->(FieldPos(aStrucCNF[nx,1])) > 0 .And. aStrucCNF[nx,2] <> "C"
			TCSetField( "CNFTMP", aStrucCNF[nx,1], aStrucCNF[nx,2], aStrucCNF[nx,3], aStrucCNF[nx,4] )
		endif
	Next
	
	TCSetField( "CNFTMP", "CNA_VLCOMS", "N", TamSX3("CNA_VLCOMS")[1], TamSX3("CNA_VLCOMS")[2] )
	TCSetField( "CNFTMP", "CNA_VLTOT", "N", TamSX3("CNA_VLTOT")[1], TamSX3("CNA_VLTOT")[2] )
	
	nSaldo := If(nSaldo == -1,CNFTMP->CNF_SALDO,nSaldo)
	
	While !CNFTMP->(Eof())
		If cPlan != CNFTMP->CNA_NUMERO
			cPlan  := CNFTMP->CNA_NUMERO
			nComis := CNFTMP->CNA_VLCOMS
		EndIf
		
		nRateio := (CNFTMP->CNF_VLPREV*100)/CNFTMP->CNA_VLTOT
		nParcel := (nComis*nRateio)/100
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera titulo provisorio de compras          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nSaldo > 0

			If lMoeda
				nValT := nSaldo
			Else
				nValT := xMoeda(nSaldo,CN9->CN9_MOEDA,1,CNFTMP->CNF_PRUMED,,CNFTMP->CNF_TXMOED)
			EndIf
			aCond := {}
			If lCnProCP
				aCond := Condicao(nValT,CN9->CN9_CONDPG,,CNFTMP->CNF_DTVENC)
			Else
				aadd(aCond,{CNFTMP->CNF_DTVENC,nValT})
			EndIf
			
			If cEspCtr =="1"
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2")+CNFTMP->CNA_FORNEC+CNFTMP->CNA_LJFORN)
             
				dbSelectArea("SE2")
				dbSetOrder(1)
				SE2->(dbGoTop())

				For ny := 1 to Len(aCond)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica proximo codigo disponivel         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					While dbSeek(cFilSE2+cPrefixo+cMaxTit)
						cMaxTit := Soma1(cMaxTit)
					EndDo
					
					RecLock("SE2",.T.)
						SE2->E2_FILIAL    := xFilial("SE2",cFilCtr)
						SE2->E2_PREFIXO   := cPrefixo
						SE2->E2_NUM       := cMaxTit
						SE2->E2_PARCELA   := CNFTMP->CNF_PARCEL
						SE2->E2_TIPO      := "PR"
						SE2->E2_FORNECE   := CNFTMP->CNA_FORNEC
						SE2->E2_LOJA      := CNFTMP->CNA_LJFORN
						SE2->E2_NOMFOR    := SA2->A2_NREDUZ
						SE2->E2_EMIS1     := CN9->CN9_DTASSI
						SE2->E2_EMISSAO   := CN9->CN9_DTASSI
						SE2->E2_VENCTO    := aCond[ny][1]
						SE2->E2_VENCREA   := DataValida(aCond[ny][1])
						SE2->E2_VENCORI   := SE2->E2_VENCTO
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o titulo e gerado na moeda corrente ou na moeda informada no contrato  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If	lMoeda
							SE2->E2_VALOR  := aCond[ny][2]
				 			SE2->E2_TXMOEDA:= CNFTMP->CNF_TXMOED
							SE2->E2_MOEDA  := CN9->CN9_MOEDA
						Else
							SE2->E2_VALOR  := aCond[ny][2]
							SE2->E2_MOEDA  := 1
						EndIf
						SE2->E2_SALDO  := SE2->E2_VALOR
						SE2->E2_NATUREZ   := cNatTit
						SE2->E2_VLCRUZ    := xMoeda(aCond[ny][2],SE2->E2_MOEDA,1,dDataBase)
						SE2->E2_ORIGEM    := "CNTA100"
						SE2->E2_RATEIO    := "N"
						SE2->E2_FLUXO     := "S"
						SE2->E2_MDCONTR   := CN9->CN9_NUMERO
						SE2->E2_MDREVIS   := CN9->CN9_REVISA
						SE2->E2_MDPLANI   := CNFTMP->CNA_NUMERO
						SE2->E2_MDCRON    := CNFTMP->CNF_NUMERO
						SE2->E2_MDPARCE   := CNFTMP->CNF_PARCEL      
						If SE2->(FieldPos("E2_FILORIG")) > 0
							SE2->E2_FILORIG	:= cFilAnt
						Endif	
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada criado para alteracoes especificas ³
						//³ no preenchimento do titulo a pagar                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lPeSE2
							ExecBlock("CNTPRSE2",.F.,.F.)
						EndIf
	
					MsUnlock()
					FaAvalSE2(1,SE2->E2_ORIGEM)
				Next
				SE2->(dbCloseArea())
				SA2->(dbCloseArea())
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+CNFTMP->(CNA_CLIENT+CNA_LOJACL))
                
				dbSelectArea("SE1")
				dbSetOrder(1)
				SE1->(dbGoTop())

				For ny := 1 to Len(aCond)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica proximo codigo disponivel         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					While dbSeek(cFilSE1+cPrefixo+cMaxTit)
						cMaxTit := Soma1(cMaxTit)
					EndDo
	
					RecLock("SE1",.T.)
						SE1->E1_FILIAL    := xFilial("SE1",cFilCtr)
						SE1->E1_PREFIXO   := cPrefixo
						SE1->E1_NUM       := cMaxTit
						SE1->E1_PARCELA   := CNFTMP->CNF_PARCEL
						SE1->E1_TIPO      := "PR"
						SE1->E1_CLIENTE   := CNFTMP->CNA_CLIENT
						SE1->E1_LOJA      := CNFTMP->CNA_LOJACL
						SE1->E1_NOMCLI    := SA1->A1_NREDUZ
						SE1->E1_EMIS1     := CN9->CN9_DTASSI
						SE1->E1_EMISSAO   := CN9->CN9_DTASSI
						SE1->E1_VENCTO    := aCond[ny][1]
						SE1->E1_VENCREA   := DataValida(aCond[ny][1])
						SE1->E1_VENCORI   := SE1->E1_VENCTO
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o titulo e gerado na moeda corrente ou na moeda informada no contrato  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lMoeda
							SE1->E1_VALOR     := aCond[ny][2]
							SE1->E1_TXMOEDA:= CNFTMP->CNF_TXMOED
							SE1->E1_MOEDA  := CN9->CN9_MOEDA
						Else
							SE1->E1_VALOR  := aCond[ny][2]
							SE1->E1_MOEDA  := 1
						EndIf
						SE1->E1_SALDO     := SE1->E1_VALOR
						SE1->E1_NATUREZ   := cNatTit
						SE1->E1_VLCRUZ    := xMoeda(aCond[ny][2],SE1->E1_MOEDA,1,dDataBase)
						SE1->E1_ORIGEM    := "CNTA100"
						SE1->E1_FLUXO     := "S"
						SE1->E1_MDCONTR   := CN9->CN9_NUMERO
						SE1->E1_MDREVIS   := CN9->CN9_REVISA
						SE1->E1_MDPLANI   := CNFTMP->CNA_NUMERO
						SE1->E1_MDCRON    := CNFTMP->CNF_NUMERO
						SE1->E1_MDPARCE   := CNFTMP->CNF_PARCEL 
						If SE1->(FieldPos("E1_FILORIG")) > 0 
							SE1->E1_FILORIG   := cFilAnt  
						EndIf
						
						If nComis > 0
							cVend:="1"
							For nx:=1 to len(aVend)
								SE1->&("E1_VEND"+cVend)  := aVend[nx,1]
								SE1->&("E1_COMIS"+cVend) := aVend[nx,2]
								SE1->&("E1_VALCOM"+cVend):= (nParcel*aVend[nx,2])/100
								cVend:=Soma1(cVend)
							Next
						EndIf
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada criado para alteracoes especificas ³
						//³ no preenchimento do titulo a receber                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lPeSE1
							ExecBlock("CNTPRSE1",.F.,.F.)
						EndIf
						
					MsUnlock()
					FaAvalSE1(1,SE1->E1_ORIGEM)
	        	Next
	        	SE1->(dbCloseArea())
	        	SA1->(dbCloseArea())
			EndIf
			cMaxTit := Soma1(cMaxTit)
		EndIf
		
		CNFTMP->(dbSkip())
		nSaldo := CNFTMP->CNF_SALDO
	EndDo
	CNFTMP->(dbCloseArea())
EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100ETit ³ Autor ³Marcelo Custodio       ³ Data ³17/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza exclusao dos titulos provisorios do                 ³±±
±±³          ³contrato/cronograma                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN100ETit(cExp01,cExp02,cExp03,cExp04)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do Contrato                                 ³±±
±±³          ³cExp02 - Codigo da revisao                                  ³±±
±±³          ³cExp03 - Numero do cronograma - opcional                    ³±±
±±³          ³cExp04 - Parcela do cronograma - opcional                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100ETit(cContra,cRevisa,cCronog,cParcel,cFilCtr)
Local cQuery    := ""
Local cEspCtr   := ""
Local aArea     := GetArea()
Local lCn100tit := ExistBlock("CN100TIT")

Default cCronog := ""
Default cParcel := ""
Default cFilCtr := cFilAnt

dbSelectArea("CN9")
dbSetOrder(1)
If dbSeek(xFilial("CN9",cFilCtr)+cContra+cRevisa)
	If CN9->(FieldPos("CN9_ESPCTR")) > 0
		cEspCtr := CN9->CN9_ESPCTR
	ElseIf !Empty(CN9->CN9_CLIENT)
		cEspCtr :="2"
	Else
		cEspCtr :="1"
	EndIf
	
	If cEspCtr == "1"
		dbSelectArea("SE2")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona titulos provisorios              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT SE2.E2_PREFIXO,SE2.E2_NUM, SE2.R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+ RetSQLName("SE2") +" SE2 "
		cQuery += " WHERE SE2.E2_FILIAL = '"+xFilial("SE2",cFilCtr)+"'"
		cQuery += "   AND SE2.E2_MDCONTR = '"+ cContra +"'"
		cQuery += "   AND SE2.E2_MDREVIS = '"+ cRevisa +"'"
		cQuery += "   AND SE2.E2_TIPO    = 'PR'"
		cQuery += "   AND "
		If !Empty(cCronog)
			cQuery += "SE2.E2_MDCRON = '"+ cCronog +"' AND "
		EndIf
		If !Empty(cParcel)
			cQuery += "SE2.E2_MDPARCE = '"+ cParcel +"' AND "	
		EndIf
		cQuery += "SE2.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE2TMP",.F.,.T.)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza exclusao dos titulos               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		While !SE2TMP->(Eof())    
			dbSelectArea("SE2")
  			DbSetOrder(1)
	   		dbSeek(xFilial("SE2",cFilCtr)+SE2TMP->E2_PREFIXO+SE2TMP->E2_NUM)
			
			If lCn100tit
				ExecBlock("CN100TIT",.F.,.F.,{cContra,SE2TMP->E2_PREFIXO,SE2TMP->E2_NUM})
			EndIf

			RecLock("SE2",.F.)
				dbDelete()
				FaAvalSE2(2,"CNTA100")
				FaAvalSE2(3,"CNTA100")
			MsUnlock()
			
			SE2TMP->(dbSkip())
		EndDo
		
		SE2TMP->(dbCloseArea())
	Else
		dbSelectArea("SE1")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona titulos provisorios              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT SE1.E1_PREFIXO,SE1.E1_NUM, SE1.R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("SE1") +" SE1 "
		cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1",cFilCtr)+"'"
		cQuery += "   AND SE1.E1_MDCONTR = '"+ cContra +"'"
		cQuery += "   AND SE1.E1_MDREVIS = '"+ cRevisa +"'"
		cQuery += "   AND SE1.E1_TIPO    = 'PR'"
		cQuery += "   AND "
		If !Empty(cCronog)
			cQuery += "SE1.E1_MDCRON = '"+ cCronog +"' AND "
		EndIf
		If !Empty(cParcel)
			cQuery += "SE1.E1_MDPARCE = '"+ cParcel +"' AND "	
		EndIf
		cQuery += "SE1.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE1TMP",.F.,.T.)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza exclusao dos titulos               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		While !SE1TMP->(Eof())    
			dbSelectArea("SE1")
  			DbSetOrder(1)
	   		dbSeek(xFilial("SE1",cFilCtr)+SE1TMP->E1_PREFIXO+SE1TMP->E1_NUM)      

			If lCn100tit
				ExecBlock("CN100TIT",.F.,.F.,{cContra,SE1TMP->E1_PREFIXO,SE1TMP->E1_NUM})
			EndIf

			RecLock("SE1",.F.)
				dbDelete()
				FaAvalSE1(2,"CNTA100")
				FaAvalSE1(3,"CNTA100")
			MsUnlock()
			
			SE1TMP->(dbSkip())
		EndDo
		
		SE1TMP->(dbCloseArea())
	EndIf
EndIf 

RestArea(aArea)
Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100Track³ Autor ³ Sergio Silveira       ³ Data ³22/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz o tratamento da chamada do System Tracker              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN100Track()

Local aEnt     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Percorre o acols                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aEnt, { "CN9", M->CN9_NUMERO + M->CN9_REVISA } )

MaTrkShow( aEnt )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100IncDoc³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza o documento ou o banco de conhecimento do item    ³±±
±±³          ³ selecionado na tree                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100IncDoc(oExp01,aExp02,cExp03,lExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 - Objeto dbTree                                      ³±±
±±³          ³ aExp02 - Array com as informacoes dos documentos            ³±±
±±³          ³ cExp03 - Codigo do contrato                                 ³±±
±±³          ³ lExp04 - Valida banco de conhecimento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100IncDoc(oTree,aDocs,cContra,lBcVld)
Local nPos   := 0
Local cCargo := oTree:GetCargo()
Local aArea  := GetArea()
Local nPosN  := 0
Local cCod   := ""
Local lValid :=.F.      
Local cRsrc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o item selecionado representa um grupo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "A" $ cCargo
	nPos := val(SubStr(cCargo,2,len(cCargo)))        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama rotina de inclusao                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CN170Manut("CNK",,3,,cContra,aDocs[nPos,1],@cCod)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona registro incluso                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CNK")		
		dbSetOrder(1)
		dbSeek(xFilial("CNK")+cCod)
		
		npos := aScan(aDocs,{|x| x[1] == CNK->CNK_TPDOC})

		If nPos > 0 .And. CNK->CNK_CONTRA == cContra
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o item se encontra vazio               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aDocs[nPos,3])
				nPosN := nPos
				cCargo := "V"+AllTrim(str(nPos))
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se valida banco de conhecimento           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBcVld
				lValid := .F.//Nao valida documento, quando houver controle do banco de conhec.
			Else
				lValid := (CNK->CNK_DTEMIS <= dDataBase .And. CNK->CNK_DTVALI >= dDataBase)//Valida datas do documento
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa contadores dos documentos               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aDocs,{|x| If(x[1] == aDocs[nPos,1],(If(lValid,x[8]++,),x[9]++),)})
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona resource de acordo com a validacao       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cRsrc := If(lValid,"LBTIK","LBNO")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona documento no array                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aDocs,{aDocs[nPos,1],aDocs[nPos,2],CNK->CNK_CODIGO,CNK->CNK_DESCRI,CNK->CNK_DTEMIS,CNK->CNK_DTVALI,CNK->CNK_OBS,aDocs[nPos,8],aDocs[nPos,9],aDocs[nPos,10]})
			
			oTree:BeginUpdate()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o grupo ja possui docs                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oTree:TreeSeek("V"+AllTrim(str(nPos)))
				oTree:DelItem()
			EndIf
			oTree:TreeSeek("A"+AllTrim(str(nPos)))
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera resource da arvore qd o doc estiver valido  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lValid
				oTree:ChangeBmp("LBTIK","LBTIK")
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona item na dbtree                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oTree:AddItem(CNK->CNK_CODIGO+"-"+CNK->CNK_DESCRI,alltrim(str(len(aDocs))),cRsrc,cRsrc,,,2)
			oTree:EndUpdate()	
			oTree:Refresh()
		EndIf
	EndIf
Else
	Aviso("CNTA100",OemtoAnsi(STR0081),{"OK"})
EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VisDoc³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza o documento ou o banco de conhecimento do item    ³±±
±±³          ³ selecionado na tree                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VisDoc(oExp01,aExp02,lExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 - Objeto dbTree                                      ³±±
±±³          ³ aExp02 - Array com as informacoes dos documentos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100VisDoc(oTree,aDocs,lVisBC)
Local nPos := 0
Local cCargo := oTree:GetCargo()
Local aArea := GetArea()

If "A" $ cCargo .OR. "V" $ cCargo
	nPos := val(SubStr(cCargo,2,len(cCargo)))
Else
	nPos := val(cCargo)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe documento para o grupo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Iif(Len(aDocs) > 1 .And. nPos == 1 .And. Empty(aDocs[nPos,3]),nPos++,)
If nPos > 0 .And. !Empty(aDocs[nPos,3])
	dbSelectArea("CNK")
	dbSetOrder(1)
	If dbSeek(xFilial("CNK")+aDocs[npos,3])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama banco de conhecimento ou visualizacao do doc ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lVisBC
			CN170Manut("CNK",CNK->(RECNO()),2)
		Else
			CN170Conh()
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Doc  ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de validacao dos documentos, executada na alteracao ³±±
±±³          ³ de situacao do contrato                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA100Doc(nExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Contrato selecionado                              ³±±
±±³          ³ aExp02 - Situacoes para qual o contrato sera alterado      ³±±
±±³          ³ lExp03 - Valida situacoes inferiores                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100Doc(nReg,aSituac,lAll)

Local oDlDoc
Local oTree                //Objeto dbtree

Local lFirst               //Identifica varredura dos tipos de documento
Local lBsCnh    := (GetNewPar( "MV_CNDOCBC", "S" ) == "S")//Verifica se a validacao leva em consideracao o banco de conhec.
Local lBcoAc    := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRABCO,.F.)
Local lLiber:= .T.
Local lContinua := .T.
Local lCN100DCS := Existblock("CN100DCS")    

Local nTotTree  		   //Total de docs para cada tipo de documento
Local nTotDVld    		   //Total de docs validos para cada tipo de documento
Local nx                                              
Local nPos
Local nTotBc:=0

Local cDescLib  := ""      //Situacao de todos os documentos
Local cDescTpc  := ""      //Tipo do Contrato
Local cCadastro := STR0078 //"Check-List de Documentos"
Local cCod        		   //Codigo do tipo de documento
Local cRsrc       		   //Resource usado
Local cDescSt := ""
Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local cCargo
Local cSituac := ""

Local aCtrs   := Array(11) //Array com os controles de tela
Local aSits   := RetSx3Box( Posicione("SX3", 2, "CN9_SITUAC", "X3CBox()" ),,, 1 )
Local aIfDoc  := {}		   //Array com as informacoes de exibicao
Local aDocs   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controles visuais                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fixa dimensao da dialog                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSize     := MsAdvSize( .F. )//{0,0,300,200,690,422,17}//MsAdvSize( .F. )
Local aObjects  := {}
Local aObjects2 := {}
Local aUsButtons:= {}
Local aPosObj1  := {}
Local aPosObj2  := {}
Local oPanel,oGroup1,oGroup2
Local lInc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta estrutura das situacoes para pesquisa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aSituac) > 1
	For nx:=1 to len(aSituac)
		cSituac+="'"+aSituac[nx]+"',"
		cDescSt+= AllTrim( aSits[Ascan( aSits, { |aBox| substr(aBox[1],1,At("=",aBox[1])-1) = AllTrim(aSituac[nx])} )][3] )+", "
	Next
	cSituac := SubStr(cSituac,1,len(cSituac)-1)
Else
	cDescSt:= AllTrim( aSits[Ascan( aSits, { |aBox| substr(aBox[1],1,At("=",aBox[1])-1) = AllTrim(aSituac[1])} )][3] )	
EndIf

dbSelectArea("AC9")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do aIfDoc                                   ³
//³ aIfDoc[1] - Codigo do tipo de documento               ³
//³ aIfDoc[2] - Descricao do tipo de documento            ³
//³ aIfDoc[3] - Codigo do Documento                       ³
//³ aIfDoc[4] - Descricao do Documento                    ³
//³ aIfDoc[5] - Data de emissao do documento              ³
//³ aIfDoc[6] - Data de validacao do documento            ³
//³ aIfDoc[7] - Obs do documento                          ³
//³ aIfDoc[8] - Total de documentos do tipo de documento  ³
//³ aIfDoc[9] - Total de documentos validos do tipo de doc³
//³ aIfDoc[10]- Total de registros no banco de conhecim.  ³
//³ aIfDoc[11]- Situacao do documento                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aIfDoc := {"","","","",CTOD("  /  /  "),CTOD("  /  /  "),"",0,0,0,""}

dbSelectArea("CN9")
dbGoTo(nReg)

cDescTpc := Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_DESCRI")

dbSelectArea("CNJ")
dbSelectArea("CN5")
dbSelectArea("CNK")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna documentos requisitados pela nova situacao ³
//³ junto com os documentos ja cadastrados             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CN5.CN5_CODIGO, CN5.CN5_DESCRI, CNK.CNK_CODIGO, CNK.CNK_DESCRI, "
cQuery += "       CNK.CNK_DTEMIS, CNK.CNK_DTVALI, CNK.CNK_OBS,    CNJ.CNJ_SITUAC "
cQuery += " FROM "+ RetSQLName("CNJ") +" CNJ , "+ RetSQLName("CN5") +" CN5, "+ RetSQLName("CNK") +" CNK "
cQuery += " WHERE CNJ.CNJ_FILIAL = '"+xFilial("CNJ")+"'"
cQuery += "   AND CN5.CN5_FILIAL = '"+xFilial("CN5")+"'"
cQuery += "   AND CNK.CNK_FILIAL = '"+xFilial("CNK")+"'"
cQuery += "   AND CNJ.CNJ_TPCTO in ('','"+ CN9->CN9_TPCTO +"')"
cQuery += "   AND "
If len(aSituac) > 1
	cQuery += "CNJ.CNJ_SITUAC IN ("+cSituac+") AND "
Else
	cQuery += "CNJ.CNJ_SITUAC = '"+ aSituac[1] +"' AND "
EndIf
cQuery += "      CNJ.CNJ_TPDOC  = CN5.CN5_CODIGO "
cQuery += "  AND CNK.CNK_CONTRA = '"+ CN9->CN9_NUMERO +"'"
cQuery += "  AND CNK.CNK_TPDOC = CN5.CN5_CODIGO"
cQuery += "  AND CNJ.D_E_L_E_T_ <> '*'"
cQuery += "  AND CN5.D_E_L_E_T_ <> '*'"
cQuery += "  AND CNK.D_E_L_E_T_ <> '*' "
cQuery += "UNION "
cQuery += "SELECT CN5.CN5_CODIGO,CN5.CN5_DESCRI,'"+Space(TamSx3("CNK_CODIGO")[1])+"' CNK_CODIGO,'"+Space(TamSx3("CNK_DESCRI")[1])+"' CNK_DESCRI, "
cQuery += "       '        ' CNK_DTEMIS,'        ' CNK_DTVALI,'"+Space(TamSx3("CNK_OBS")[1])+"' CNK_OBS,CNJ_SITUAC "
cQuery += "  FROM "+ RetSQLName("CNJ") +" CNJ , "+ RetSQLName("CN5") +" CN5 "
cQuery += " WHERE CNJ.CNJ_FILIAL = '"+xFilial("CNJ")+"'"
cQuery += "   AND CN5.CN5_FILIAL = '"+xFilial("CN5")+"'"
cQuery += "   AND CNJ.CNJ_TPCTO in ('','"+CN9->CN9_TPCTO +"') AND "
If len(aSituac) > 1
	cQuery += "CNJ.CNJ_SITUAC IN ("+cSituac+") AND "
Else
	If aSituac[1] == DEF_SCANC
		cQuery += "CNJ.CNJ_SITUAC = '"+ aSituac[1] +"' AND "	
	Else
		cQuery += "CNJ.CNJ_SITUAC <= '"+ aSituac[1] +"' AND "
		cQuery += "CNJ.CNJ_SITUAC <> '"+ DEF_SCANC +"' AND "
	EndIf
EndIf
cQuery += " CNJ.CNJ_TPDOC = CN5.CN5_CODIGO AND "
cQuery += " NOT EXISTS (SELECT CNK.CNK_CODIGO "
cQuery += "              FROM "+ RetSQLName("CNK") +" CNK "
cQuery += "				WHERE CNK.CNK_FILIAL = '"+xFilial("CNK")+"'"
cQuery += "               AND CNK.CNK_CONTRA = '"+CN9->CN9_NUMERO+"'"
cQuery += "			      AND CNK.CNK_TPDOC  = CNJ.CNJ_TPDOC "
cQuery += "				  AND CNK.D_E_L_E_T_ = '') "
cQuery += " AND CNJ.D_E_L_E_T_ <> '*'"
cQuery += " AND CN5.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY 1,5"
	
cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

TCSetField(cAlias,"CNK_DTEMIS","D",08,0)
TCSetField(cAlias,"CNK_DTVALI","D",08,0)

lContinua := !((cAlias)->(Eof()))

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena documentos no array aDocs                     ³
	//³ Estrutura do aDocs                                     ³
	//³ aDocs[x,1] - Codigo do tipo de documento               ³
	//³ aDocs[x,2] - Descricao do tipo de documento            ³
	//³ aDocs[x,3] - Codigo do Documento                       ³
	//³ aDocs[x,4] - Descricao do Documento                    ³
	//³ aDocs[x,5] - Data de emissao do documento              ³
	//³ aDocs[x,6] - Data de validacao do documento            ³
	//³ aDocs[x,7] - Obs do documento                          ³
	//³ aDocs[x,8] - Total de documentos validos do tipo de doc³
	//³ aDocs[x,9] - Total de documentos do tipo de documento  ³
	//³ aDocs[x,10]- Total de registros no banco de conhecim.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAlias)->(Eof())
		lInc := .T.
		nTotBc:=0
		If lBsCnh .And. !Empty((cAlias)->CNK_CODIGO)
			cQuery := "SELECT COUNT(AC9.AC9_ENTIDA) AS BS_CONHE "
			cQuery += "  FROM "+ RetSQLName("AC9") +" AC9 "
			cQuery += "WHERE AC9.AC9_FILIAL = '"+xFilial("AC9")+"'"
			cQuery += "  AND AC9.AC9_ENTIDA = 'CNK'"
			cQuery += "  AND AC9.AC9_CODENT = '"+(cAlias)->CNK_CODIGO+"' "
			cQuery += "  AND AC9.D_E_L_E_T_ = ''"
			
			cQuery := ChangeQuery(cQuery)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBAC9",.F.,.T.)
			
			nTotBc := TRBAC9->BS_CONHE
			
			TRBAC9->(dbCloseArea())
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica documentos de situacoes anteriores que    ³
		//³ ja tenham sido validados e nao devem ser           ³
		//³ listados                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If len(aSituac) == 1 .And. aSituac[1] > (cAlias)->CNJ_SITUAC
			If lAll
				lInc := !((cAlias)->CNK_DTEMIS <= dDataBase .AND. (cAlias)->CNK_DTVALI >= dDataBase)
				if lBsCnh
					lInc := (nTotBc == 0)
				EndIf
			Else
				lInc := .F.
			EndIf
		EndIf
		
		If lInc
			aAdd(aDocs,{(cAlias)->CN5_CODIGO,(cAlias)->CN5_DESCRI,(cAlias)->CNK_CODIGO,(cAlias)->CNK_DESCRI,(cAlias)->CNK_DTEMIS,(cAlias)->CNK_DTVALI,(cAlias)->CNK_OBS,0,0,nTotBc})
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea()) 

	dbSelectArea("CN9")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula posicao dos objetos na tela                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}
	AAdd( aObjects, { 230, 030, .T., .F., .T. } )//Painel superior
	AAdd( aObjects, { 120, 144, .T., .T., .F. } )//dbTree
	AAdd( aObjects, { 120, 20, .T., .F., .F. } )//Botoes
	
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj1 := MsObjSize( aInfo, aObjects, .T., .F. )
	
	AAdd( aObjects2, { 120, 144, .T., .T., .F. } )//Group: Tipo de Documento
	AAdd( aObjects2, { 170, 144, .F., .T., .F. } )//Group: Informacoes do documento
	
	aInfo    := { aPosObj1[2,2],aPosObj1[2,1], aPosObj1[2,4], aPosObj1[2,3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo, aObjects2, .F., .T. )
	
	DEFINE MSDIALOG oDlDoc TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] PIXEL
	
	@ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlDoc
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao do contrato                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001,000 Say RetTitle("CN9_SITUAC") Of oPanel PIXEL
	@ 000,024 MsGet oGetSit Var cDescSt When .F. PIXEL  Size 50,5 Of oPanel
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo do contrato                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 001,082 Say RetTitle("CN9_TPCTO") Of oPanel PIXEL
	@ 000,122 MsGet oGetTCto Var cDescTpc When .F. PIXEL  Size 100,5 Of oPanel
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao geral dos documentos                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 013,000 Say STR0063 Of oPanel PIXEL//"Situação Geral"
	@ 012,47 MsGet oGetSLib Var cDescLib When .F. PIXEL  Size 100,5 Of oPanel
	                    
	@ aPosObj1[2,1],aPosObj1[2,2] Say STR0064 Of oDlDoc PIXEL//"Documentos Requisitados"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DBtree - Estrutura                                 ³
	//³ ÀÄNivel 1 - Tipos de Documentos                    ³
	//³ ÀÄÄÄNivel 2 - Documentos cadastrados               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE DBTREE oTree ON CHANGE {CN100AlDoc(@oTree,aDocs,aIfDoc,lBsCnh),aEval(aCtrs,{|x| If (x!=Nil,x:Refresh(),)})} FROM aPosObj2[1,1]+006,aPosObj2[1,2] TO aPosObj2[1,3],aPosObj2[1,4] OF oDlDoc CARGO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Menu de visualizacao do documento                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MENU oMenuTree POPUP
		MENUITEM OemToAnsi(STR0003) Action CN100VisDoc(oTree,aDocs,.F.)//"Visualizar"
		MENUITEM OemToAnsi(STR0080) Action (CN100IncDoc(oTree,aDocs,CN9->CN9_NUMERO,lBsCnh),If(aScan(aDocs,{|x| x[8] == 0})==0,(lLiber:=.T.,cDescLib:=STR0066,oGetSLib:Refresh()),))//If((oTree:GetCargo() $ "A"),CN100IncDoc(oTree,aDocs,.F.,CN9->CN9_NUMERO),Aviso("CNTA100",OemtoAnsi(STR0081),{"OK"}))//"Incluir Documento"
		If lBcoAc//Quando o usuario possui acesso ao banco de conhecimento
			MENUITEM OemToAnsi(STR0056) ACTION CN100VisDoc(oTree,aDocs,.T.)//"Banco de Conhecimento"
		EndIf
	ENDMENU
	
	oTree:bRClicked   := { |oObject,nx,ny| oMenuTree:Activate( nX-80, nY-200, oObject ) }
	
	lFirst := .T.     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arvore principal                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBADDTREE oTree PROMPT cDescTpc OPEN OPENED CARGO "V0000"
	
	for nx:=1 to len(aDocs)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Primeiro registro do tipo de documento             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFirst
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o tipo de documento possui algum       ³
			//³ documento valido                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aDocs,{|x| x[1] = aDocs[nX,1] .And. x[5] <= dDataBase .And. x[6] >= dDataBase .And. If(lBsCnh,x[10]>0,.T.)}) > 0
				cRsrc := "LBTIK"
			Else
				cRsrc := "LBNO"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta arvore do tipo de documento com a identificacao³
			//³ "A" no cargo                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCargo := "A"+alltrim(str(nX))
			DBADDTREE oTree PROMPT aDocs[nX,1]+"-"+aDocs[nX,2] RESOURCE cRsrc CARGO cCargo
			lFirst := .F.
			cCod :=  aDocs[nX,1]
			nTotTree:=0
			nTotDVld:=0
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera item do documento                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If !Empty(aDocs[nx,5])
			If(aDocs[nx,5] <= dDataBase .And. aDocs[nx,6] >= dDataBase .And. If(lBsCnh,aDocs[nx,10]>0,.T.))
				nTotDVlD++
				cRsrc := "LBTIK"
			Else
				cRsrc := "LBNO"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Identifica cargo com a posicao do array aDocs      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			cCargo := alltrim(str(nX))
			DBADDITEM oTree PROMPT aDocs[nx,3]+"-"+aDocs[nx,4] RESOURCE cRsrc CARGO cCargo
			nTotTree++
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se e o ultimo elemento do grupo           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nx == len(aDocs) .Or. aDocs[nX+1,1] != cCod
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza campos totalizadores do grupo             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			aDocs := aEval(aDocs,{|x| If(x[1] == aDocs[nX,1],(x[8]:=nTotDVlD,x[9]:=nTotTree),)})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera item quando o grupo nao possuir documentos    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTotTree==0
				cCargo := "V"+alltrim(str(nX))
				DBADDITEM oTree PROMPT STR0065 CARGO cCargo//"Documento não fornecido"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o tipo de documento foi liberado       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLiber
				lLiber := (nTotTree > 0 .And. nTotDVlD>0)
			EndIf
			nTotTree:=0
			DBENDTREE oTree
			lFirst := .T.
		EndIf
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera elemento quando nao houver estrutura          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aDocs) == 0
		DBADDITEM oTree PROMPT STR0079 CARGO "V0000"//"Vazio"
	EndIf
	
	DBENDTREE oTree
	
	cDescLib := If(lLiber,STR0066,STR0067)//"Docs Liberados"##"Docs Pendentes"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Componentes visuais de identificacao do documento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj2[2,1],aPosObj2[2,2] GROUP oGroup1 To aPosObj2[2,3],aPosObj2[2,4] Label OemToAnsi(STR0068) Of oDlDoc PIXEL//"Tipo do Documento" 
	
	@ aPosObj2[2,1]+008,aPosObj2[2,2]+005 Say oCdTDoc Var RetTitle("CN5_CODIGO") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+008,aPosObj2[2,2]+060 MsGet aCtrs[1] Var aIfDoc[1] Picture PesqPict("CN5","CN5_CODIGO") When .F. Size 60,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+019,aPosObj2[2,2]+005 Say oNmTDoc Var RetTitle("CN5_DESCRI") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+019,aPosObj2[2,2]+060 MsGet aCtrs[2] Var aIfDoc[2] Picture PesqPict("CN5","CN5_DESCRI") When .F. Size 60,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+032,aPosObj2[2,2]+005 Say aCtrs[9] Var OemToAnsi(STR0069)+AllTrim(str(aIfDoc[9])) Size 100,8 Of oGroup1 PIXEL//"Total de Documentos: "
	@ aPosObj2[2,1]+032,aPosObj2[2,2]+075 Say aCtrs[10] Var OemToAnsi(STR0070)+AllTrim(str(aIfDoc[8])) Size __DlgWidth(oDlDoc)-42,8 Of oGroup1 PIXEL//"Documentos Válidos: "
	
	@ aPosObj2[2,1]+047,aPosObj2[2,2]+005 Say OemToAnsi(STR0071) Size 100,8 Of oGroup1 PIXEL//"Detalhes do Documento"
	@ aPosObj2[2,1]+057,aPosObj2[2,2]+005 Say oCdDoc Var RetTitle("CNK_CODIGO") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+057,aPosObj2[2,2]+060 MsGet aCtrs[4] Var aIfDoc[3] Picture PesqPict("CNK","CNK_CODIGO") When .F. Size 60,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+068,aPosObj2[2,2]+005 Say oNmDoc Var RetTitle("CNK_DESCRI") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+068,aPosObj2[2,2]+060 MsGet aCtrs[3] Var aIfDoc[4] Picture PesqPict("CNK","CNK_DESCRI") When .F. Size 60,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+079,aPosObj2[2,2]+005 Say oDeDoc Var RetTitle("CNK_DTEMIS") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+079,aPosObj2[2,2]+060 MsGet aCtrs[5] Var aIfDoc[5] Picture PesqPict("CNK","CNK_DTEMIS") When .F. Size 60,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+090,aPosObj2[2,2]+005 Say oDvDoc Var RetTitle("CNK_DTVALI") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+090,aPosObj2[2,2]+060 MsGet aCtrs[6] Var aIfDoc[6] Picture PesqPict("CNK","CNK_DTVALI") When .F. Size 60,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+101,aPosObj2[2,2]+005 Say oObDoc Var RetTitle("CNK_OBS") Size 50,8 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+101,aPosObj2[2,2]+060 MsGet aCtrs[7] Var aIfDoc[7] Picture PesqPict("CNK","CNK_OBS") When .F. Size 100,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+112,aPosObj2[2,2]+005 Say oStDoc Var OemToAnsi(STR0072) Size 50,8 Of oGroup1 PIXEL//"Status"
	@ aPosObj2[2,1]+112,aPosObj2[2,2]+060 MsGet aCtrs[8] Var aIfDoc[11] When .F. Size 100,5 Of oGroup1 PIXEL
	@ aPosObj2[2,1]+125,aPosObj2[2,2]+005 Say aCtrs[11] Var OemToAnsi(STR0073)+AllTrim(str(aIfDoc[10]))+OemToAnsi(STR0074) Size __DlgWidth(oDlDoc)-42,8 Of oGroup1 PIXEL//"Base de Conhecimento: "##" registro(s)"
	
	DEFINE SBUTTON FROM aPosObj1[3,1], aPosObj1[3,4]-55 TYPE 1 ACTION (If(lCN100DCS, lLiber:=ExecBlock("CN100DCS",.F.,.F.,{oDlDoc,aDocs,lLiber}),If((nPos:=aScan(aDocs,{|x| x[8]==0})==0),(oDlDoc:End()),(Help(" ",1,"CNTA100DOC"),oDlDoc:End())))) ENABLE OF oDlDoc
	DEFINE SBUTTON FROM aPosObj1[3,1], aPosObj1[3,4]-25 TYPE 2 ACTION (lLiber:=.F.,oDlDoc:End()) ENABLE OF oDlDoc
	          
	ACTIVATE MSDIALOG oDlDoc CENTERED

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera validacao quando nao houver documentos relacionados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lLiber:=.T.
	(cAlias)->(dbCloseArea()) 
EndIf

RestArea(aArea)
Return lLiber

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100AlDoc³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza valores de exibicao do elemento selecionado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100AlDoc(oExp01,aExp02,aExp03,lExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp01 - DbTree                                            ³±±
±±³          ³ aExp02 - Array com as informacoes dos documentos           ³±±
±±³          ³ aExp03 - Array com os valores exibidos na dialog           ³±±
±±³          ³ aExp04 - Valida documento com base no banco de conhecimento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100AlDoc(oTree,aDocs,aIfDoc,lBsCnh)
Local nPos := 0
Local cCargo := oTree:GetCargo()                       

aIfDoc := {}//Limpa array de exibicao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica posicao no array aDocs                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "A" $ cCargo .Or. "V" $ cCargo
	nPos := val(SubStr(cCargo,2,len(cCargo)))
Else
	nPos := val(cCargo)
EndIf
If nPos == 0
	aIfDoc := {"","","","",CTOD("  /  /  "),CTOD("  /  /  "),"",0,0,0,""}
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera copia do item do aDocs para o aIfDoc          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aIfDoc:=aClone(aDocs[nPos])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica situacao do documento quando o mesmo existir³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aDocs[nPos,3])
		If aDocs[nPos,5] <= dDataBase .And. aDocs[nPos,6] >= dDataBase
			If !lBsCnh
				aAdd(aIfDoc,STR0075)//"Válido"
			elseIf aDocs[nPos,10]==0
				aAdd(aIfDoc,STR0076)//"Não possui banco de conhecimento"
			else
				aAdd(aIfDoc,STR0075)//"Válido"
			EndIf
		Else
			aAdd(aIfDoc,STR0077)//"Vencido"
		EndIf
	Else
		aAdd(aIfDoc,"")//"Vencido"
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100IncArr³ Autor ³ Marcelo Custodio      ³ Data ³07.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a inclusao de planilhas no array aPlani, durante    ³±±
±±³          ³ a inclusao do contrato                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100IncArr(nExp01,aExp02,aExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±³          ³ aExp02 - Array com as informacoes das planilhas             ³±±
±±³          ³ aExp03 - Array com os itens(acols) das planilhas            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100IncArr(npc,aPlani,aPlIt,aHeaderCNB,aRatCNZ)
Local ny
Local nPosForn   
Local nPosLoja
Local nPosTotP := aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_VLTOT"})
Local nTotPlan := len(aPlani)


Local cPlani   := strzero(1,TamSx3("CNA_NUMERO")[1])
Local cCadBack := cCadastro

Local lIncBack := INCLUI
Local lAltBack := ALTERA     
Local lRet := .T.

Local dTermino

If cEspCtr =="1"
	nPosForn := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})
	nPosLoja := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_LOJA"})
	lRet     := CN100VerFor()
Else  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@¿
	//³Verifica se o campo cliente está preenchido		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ@Ù
	If M->CN9_CLIENT == Nil .Or. Empty(M->CN9_CLIENT) 
		Help("  ",1,"REGNOIS")
		lRet:= .F.
	EndIf
Endif	

If lRet
	cCadastro := STR0084//"Cadastro de Planilhas"
	INCLUI := .T.
	ALTERA := .F.  
	PRIVATE aForn
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera array de fornecedores usado na validacao da planilha ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEspCtr =="1"
	   aForn := aEval(oGetDad1:aCols,{|x| {x[nPosForn],x[nPosLoja]}})
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula data de termino do contrato  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->CN9_UNVIGE)
		dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula numero sequencial da planilha com base nas planilhas existentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aPlani) > 0
		For ny:=1 to len(aPlani)
			If aPlani[ny,CNA->(FieldPos("CNA_NUMERO"))] >= cPlani
				cPlani := Soma1(aPlani[ny,CNA->(FieldPos("CNA_NUMERO"))])
			EndIf
		Next
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa rotina de manutencao das planilhas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CN200Manut("CNA",5000,npc,,.F.,.F.,aPlani,aPlIt,M->CN9_NUMERO,cPlani,M->CN9_DTINIC,dTermino,aHeaderCNB,aRatCNZ)
		If nTotPlan != len(aPlani)
			If len(aCols3)==0 .Or. len(aCols3)>1 .Or. !Empty(aCols3[1,1])
				aAdd(aCols3,Array(len(aHeader3)+1))
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza folder das planilhas com base na inclusao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For ny:=1 to len(aHeader3)
				If CNA->(FieldPos(aHeader3[ny,2])) > 0
					aCols3[len(aCols3),ny] := aPlani[len(aPlani),CNA->(FieldPos(aHeader3[ny,2]))]
				EndIf
			Next
			aCols3[len(aCols3),len(aHeader3)+1] := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza totais do contrato         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M->CN9_VLATU := M->CN9_SALDO := M->CN9_VLINI := M->CN9_VLINI + aCols3[len(aCols3),nPosTotP]
			
			oGetDad3:aCols := aCols3
			oGetDad3:oBrowse:Refresh()
			oGetDad3:Refresh()
		EndIf
	EndIf
EndIf
cCadastro := cCadBack
INCLUI := lIncBack
ALTERA := lAltBack

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100IncPla³ Autor ³ Marcelo Custodio      ³ Data ³07.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a inclusao de planilhas durante a edicao do contrato³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100IncPla()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100IncPla(aRatCNZ)
Local ny
Local nPosForn
Local nPosLoja
Local nPosTotP := aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_VLTOT"})
Local nPosNumP := aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_NUMERO"})
Local nTotPlan := len(oGetDad3:aCols)

Local cPlani := strzero(1,TamSx3("CNA_NUMERO")[1])
Local cCadBack := cCadastro

Local dTermino

Local lIncBack := INCLUI
Local lAltBack := ALTERA

PRIVATE aForn

If cEspCtr =="1"
	nPosForn := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})
	nPosLoja := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_LOJA"})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera array de fornecedores usado na validacao da planilha ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aForn := aEval(oGetDad1:aCols,{|x| {x[nPosForn],x[nPosLoja]}})
Endif	

cCadastro := STR0084//"Cadastro de Planilhas"
INCLUI := .T.
ALTERA := .F.

aCols3 := oGetDad3:aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula data de termino do contrato  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->CN9_UNVIGE) .And. !Empty(M->CN9_VIGE)
	dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica total de planilhas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotPlan == 1 .And. Empty(aCols3[1,nPosNumP])
	nTotPlan := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula numero sequencial da planilha com base nas planilhas existentes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotPlan > 0
	For ny:=1 to len(aCols3)
		If aCols3[ny,nPosNumP] >= cPlani
			cPlani := Soma1(aCols3[ny,nPosNumP])
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina de manutencao das planilhas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CN200Manut("CNA",5000,3,,.F.,.F.,,,M->CN9_NUMERO,@cPlani,M->CN9_DTINIC,dTermino,,aRatCNZ)
	If len(aCols3) == 1 .And. Empty(aCols3[1,1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui linha da planilha em branco              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDel(aCols3,1)
		aSize(aCols3,0)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza item da planilha no folder             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNA")
	dbSetOrder(1)
	If dbSeek(xFilial("CNA")+M->CN9_NUMERO+M->CN9_REVISA+cPlani)
		aAdd(aCols3,Array(len(aHeader3)+1))
		For nY	:= 1 To Len(aHeader3)
			cCampo := Alltrim(aHeader3[nY,2])
			If IsHeadRec(cCampo)
				aCols3[len(aCols3),ny] := CNA->(Recno())
			ElseIf IsHeadAlias(cCampo)
				aCols3[len(aCols3),ny] := "CNA"			
			ElseIf ( aHeader3[nY][10] != "V" )
				aCols3[len(aCols3),nY] := FieldGet(FieldPos(aHeader3[nY][2]))
			Else
				aCols3[len(aCols3),nY] := CriaVar(aHeader3[nY][2])
			EndIf
	 	Next nY
	  	aCols3[len(aCols3),Len(aHeader3)+1] := .F.
	EndIf
	oGetDad3:aCols := aCols3
	oGetDad3:oBrowse:Refresh()
	oGetDad3:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza valores totais do contrato             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CN9")
	dbSetOrder(1)
	If dbSeek(xFilial("CN9")+M->CN9_NUMERO+M->CN9_REVISA)
		M->CN9_VLATU := CN9->CN9_VLATU
		M->CN9_SALDO := CN9->CN9_SALDO
		M->CN9_VLINI := CN9->CN9_VLINI
	EndIf
EndIf

cCadastro := cCadBack
INCLUI := lIncBack
ALTERA := lAltBack

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100AltArr³ Autor ³ Marcelo Custodio      ³ Data ³07.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a alteracao de planilhas no array aPlani, durante   ³±±
±±³          ³ a inclusao do contrato                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100AltArr(nExp01,aExp02,aExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±³          ³ aExp02 - Array com as informacoes das planilhas             ³±±
±±³          ³ aExp03 - Array com os itens(acols) das planilhas            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100AltArr(npc,aPlani,aPlIt,aHeaderCNB,aRatCNZ)

Local ny
Local nPosForn
Local nPosLoja
Local nPlan
Local nPosPlan := aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_NUMERO"})
Local nPosTotP := aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_VLTOT"})
Local cPlani := strzero(1,TamSx3("CNA_NUMERO")[1])
Local nTotPlan := len(aPlani)

Local cCadBack := cCadastro

Local lIncBack := INCLUI
Local lAltBack := ALTERA

Local dTermino

If cEspCtr =="1"
	nPosForn := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})
	nPosLoja := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_LOJA"})
Endif	

cCadastro := STR0084//"Cadastro de Planilhas"
INCLUI := .F.
ALTERA := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera array de fornecedores usado na validacao da planilha ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aForn
If cEspCtr =="1"
   aForn := aEval(oGetDad1:aCols,{|x| {x[nPosForn],x[nPosLoja]}})
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula data de termino do contrato  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->CN9_UNVIGE)
	dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica planilha selecionada                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPlani := oGetDad3:aCols[oGetDad3:nAt,nPosPlan]
nPlan  := aScan(aPlani,{|x| x[CNA->(FieldPos("CNA_NUMERO"))] == cPlani})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina de manutencao de planilhas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CN200Manut("CNA",5000,npc,,.F.,.F.,aPlani,aPlIt,M->CN9_NUMERO,cPlani,M->CN9_DTINIC,dTermino,aHeaderCNB,aRatCNZ)

	If npc != 5//Alteracao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui valor antigo                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->CN9_VLATU := M->CN9_SALDO := M->CN9_VLINI := M->CN9_VLINI - aCols3[nPlan,nPosTotP]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza folder de planilhas                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny:=1 to len(aHeader3)
			If CNA->(FieldPos(aHeader3[ny,2])) > 0
				aCols3[nPlan,ny] := aPlani[nPlan,CNA->(FieldPos(aHeader3[ny,2]))]
			EndIf
		Next
		aCols3[nPlan,len(aHeader3)+1] := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza totais do contrato                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->CN9_VLATU := M->CN9_SALDO := M->CN9_VLINI := M->CN9_VLINI + aCols3[nPlan,nPosTotP]
	Else//Exclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui valor da planilha dos totais do contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->CN9_VLATU := M->CN9_SALDO := M->CN9_VLINI := M->CN9_VLINI - aCols3[nPlan,nPosTotP]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui planilha da folder                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDel(aCols3,nPlan)
		aSize(aCols3,len(aCols3)-1)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza folder                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetDad3:aCols := aCols3
	oGetDad3:oBrowse:Refresh()
	oGetDad3:Refresh()
EndIf

cCadastro := cCadBack
INCLUI := lIncBack
ALTERA := lAltBack

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100AltPla³ Autor ³ Marcelo Custodio      ³ Data ³07.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a alteracao de planilhas durante a edicao do        ³±±
±±³          ³ contrato                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100AltPla(nExp01)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100AltPla(npc,aRatCNZ)//,aHeaderCNB)
Local nPlan
Local nCntFor
Local nRecno := 0
Local nPos   := 0

Local cCampo
Local cCadBack := cCadastro
Local cPlan

Local lIncBack := INCLUI
Local lAltBack := ALTERA 

Local dTermino

cCadastro := STR0084//"Cadastro de Planilhas"
INCLUI := .F.
ALTERA := .T.

aCols3 := oGetDad3:aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula data de termino do contrato  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->CN9_UNVIGE) .And. !Empty(M->CN9_VIGE)
	dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica planilha selecionada                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPlan := oGetDad3:nAt
cPlan := aCols3[nPlan,aScan(aHeader3,{|x| AllTrim(x[2]) == "CNA_NUMERO"})]

dbSelectArea("CNA")
dbSetOrder(1)
dbSeek(xFilial("CNA")+M->CN9_NUMERO+M->CN9_REVISA+cPlan)

nRecNo := CNA->(RecNo())

If nRecno > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa rotina de manutencao da planilha        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CN200Manut("CNA",CNA->(RecNo()),npc,,,,,,,,M->CN9_DTINIC,dTermino,,aRatCNZ)
		If npc == 4 //Alteracao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera registro selecionado                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbGoto(nRecno)
			For nCntFor	:= 1 To Len(aHeader3)
				cCampo := Alltrim(aHeader3[nCntFor,2])
				If (nPos:=FieldPos(aHeader3[nCntFor][2])) > 0
					aCols3[nPlan,nCntFor] := FieldGet(nPos)
				EndIf
	 		Next nCntFor
	  		aCols3[nPlan,Len(aHeader3)+1] := .F.
		Else //Exclusao
			aDel(aCols3,nPlan)
			aSize(aCols3,len(aCols3)-1)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza folder das planilhas                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetDad3:aCols := aCols3
		oGetDad3:oBrowse:Refresh()
		oGetDad3:Refresh()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza campos totais do contrato              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CN9")
		dbSetOrder(1)
		If dbSeek(xFilial("CN9")+M->CN9_NUMERO+M->CN9_REVISA)
			M->CN9_VLATU  := CN9->CN9_VLATU
			M->CN9_SALDO  := CN9->CN9_SALDO
			M->CN9_VLINI  := CN9->CN9_VLINI
		EndIf
	EndIf
EndIf

cCadastro := cCadBack
INCLUI := lIncBack
ALTERA := lAltBack

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100PlGr  ³ Autor ³ Marcelo Custodio      ³ Data ³07.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa gravacao do array de planilhas no banco             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100PlGr(aExp01,aExp02)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Opcao atual                                        ³±±
±±³          ³ aExp02 - Opcao atual                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100PlGr(aPlani,aPlIt,aHeaderCNB)
Local nx        := 0
Local nUsado    := 0
Local nCntFor   := 0
Local nCntFor2  := 0
Local nTot      := 0   
Local nTotComis := 0
Local cFilSC1	:= ""
Local lFilOri	:= CNB->(FieldPos("CNB_FILORI")) > 0

Local dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)
                                                                                                                 
For nx:=1 to len(aPlani)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche campos do cabecalho                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNA")
	Reclock("CNA",.T.)
		For nCntFor := 1 To FCount()
			If (FieldName(nCntFor)=="CNA_FILIAL")
				CNA->CNA_FILIAL := xFilial()
			Else
				FieldPut(nCntFor,aPlani[nx,nCntFor])
			EndIf
		Next nCntFor     
		CNA->CNA_CLIENT := CN9->CN9_CLIENT
		CNA->CNA_LOJACL := CN9->CN9_LOJACL    
			
		If (Empty(M->CN9_DTFIM) .And. dTermino < CNA->CNA_DTFIM) .Or. (!Empty(M->CN9_DTFIM) .And. M->CN9_DTFIM < CNA->CNA_DTFIM)
			CNA->CNA_DTFIM := dTermino
		EndIf
	MsUnlock()                      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa lancamento do PCO    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoDetLan("000354","01","CNTA200")
	
	dbSelectArea("CNB")
	nUsado := Len(aHeaderCNB)        
	
	nTotComis := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche campos dos itens                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 To Len(aPlIt[nx])
		If ( !aPlIt[nx,nCntFor,nUsado+1] )
			dbSelectArea("CNB")
			Reclock("CNB",.T.)
				For nCntFor2 := 1 To nUsado
					If ( aHeaderCNB[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeaderCNB[nCntFor2][2]),aPlIt[nx,nCntFor,nCntFor2])
					EndIf
				Next nCntFor2
				CNB->CNB_FILIAL := xFilial("CNB")
				If CNB->(FieldPos("CNB_FILORI")) > 0
					CNB->CNB_FILORI := M->CN9_FILORI
				EndIf
				CNB->CNB_NUMERO := CNA->CNA_NUMERO
				CNB->CNB_REVISA := CNA->CNA_REVISA
				CNB->CNB_CONTRA := CNA->CNA_CONTRA
				CNB->CNB_DTCAD  := dDataBase   
				CNB->CNB_SLDMED := CNB->CNB_QUANT
				CNB->CNB_SLDREC := CNB->CNB_QUANT      
				nTot += CNB->CNB_VLTOT-CNB->CNB_VLDESC
			MsUnlock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula total da comissao            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			If CNB->CNB_FLGCMS = "1"
				nTotComis += CNB->CNB_VLTOT-CNB->CNB_VLDESC
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa lancamento PCO      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			PcoDetLan("000354","02","CNTA200")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza solicitacao de compra                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			If !Empty(CNB->CNB_NUMSC)
				If lFilOri .And. !Empty(CNB->CNB_FILORI)
					cFilSC1 := xFilial("SC1",CNB->CNB_FILORI)
				Else
					cFilSC1 := xFilial("SC1")
				EndIf
				dbSelectArea("SC1")
				If dbSeek(cFilSC1+CNB->CNB_NUMSC+CNB->CNB_ITEMSC)
					RecLock("SC1",.F.)   
						SC1->C1_FLAGGCT	:= "1" //Solicitacao bloqueada para SIGAGCT
					MsUnlock()
				EndIf					
			EndIf				
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava localizacoes fisicas AGW (TEC) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(aPlani[nX,Len(aPlani[nX])]) == "A" .And. !Empty(aPlani[nX,Len(aPlani[nX])])
		CNB->(dbSetOrder(1))
		For nCntFor := 1 To Len(aPlani[nX,Len(aPlani[nX])])
			If !CNB->(dbSeek(xFilial("CNB")+CNA->(CNA_CONTRA+CNA_REVISA+CNA_NUMERO)+aPlani[nX,Len(aPlani[nX]),nCntFor,1])) .Or.;
						CNB->CNB_BASINS # '1'
				Loop
			EndIf
			
			RecLock("AGW",.T.)
			For nCntFor2 := 1 To Len(aPlani[nX,Len(aPlani[nX]),nCntFor,2])
				AGW->&(aPlani[nX,Len(aPlani[nX]),nCntFor,2,nCntFor2,1]) := aPlani[nX,Len(aPlani[nX]),nCntFor,2,nCntFor2,2]
			Next nCntFor2
			AGW->AGW_FILIAL := xFilial("AGW")
			AGW->AGW_CONTRA := CNA->CNA_CONTRA
			AGW->AGW_PLANIL := CNA->CNA_NUMERO
			AGW->AGW_CLIENT := CNA->CNA_CLIENT
			AGW->AGW_LOJA   := CNA->CNA_LOJACL
			AGW->AGW_PRODUT := CNB->CNB_PRODUT
			AGW->(MsUnLock())
		Next nCntFor
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza valor da comissao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEspCtr == "2"
		RecLock("CNA",.F.)
			CNA->CNA_VLCOMS := nTotComis
		MsUnlock()
	EndIf	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100BxCauc³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa baixa das caucoes de retencao do contrato           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100PlGr(lExp01)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp01 -Informa se a rotina de baixa de caucao foi executada³±±
±±³          ³          pela visualizacao de contrato                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100BxCauc(lVisu)
Local oDlg

Local nVlEft  := 0
Local nVlReg  := 0
Local nOpca   := 0
Local nx        := 0
Local nPosMed   := 0

Local cPicture:= PesqPict("CNT","CNT_VLRET")
Local cTpTit  := ""
Local cNumTit := ""
Local cParcela:= ""
Local cBco    := Space(TamSX3("A6_COD")[1])//Banco
Local cAgc    := Space(TamSX3("A6_AGENCIA")[1])//Agencia
Local cCta    := Space(TamSX3("A6_CONTA")[1])//Conta
Local cRetNat := PadR( GetNewPar( "MV_CNRETNA",  "" ), Len( SE2->E2_NATUREZ ) )//Natureza
Local cRetPrf := PadR( GetNewPar( "MV_CNRETPR", "CRE" ), Len( SE2->E2_PREFIXO ) )//Prefixo
Local cEspCtr	:= ""
Local cCodiCNT := Space(TamSX3("A2_COD")[1])
Local cLojaCNT := Space(TamSX3("A2_LOJA")[1])

Local aNoFields := {"CNT_FILIAL","CNT_CONTRA","CNT_FORNEC","CNT_LJFORN"}
Local aHeader   := {}
Local aCols     := {}

Local lBxPe     := .F.
Local lRet    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida controle de acesso ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !CN240VldUsr(CN9->CN9_NUMERO,DEF_TRARET,.T.)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida natureza informada no parametro MV_CNRETNA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cRetNat )
	Aviso( STR0088, STR0089, { "OK" }, 2 )//"Atencao !"#"Configurar a natureza financeira do titulo de caucao atraves do parametro MV_CNRETNA."
	lRet := .F.
EndIf
	
SED->( dbSetOrder( 1 ) )
	
If lRet .And. !SED->( MsSeek( xFilial( "SED" ) + cRetNat ) )
	Aviso( STR0088, STR0090, { "OK" }, 2 ) // "Atencao !"#"A natureza definida pelo parametro MV_CNRETNA nao esta cadastrada."
	lRet := .F.
EndIf

If ExistBlock("CNTRETPR")
	cRetPrf := If(ValType(cNewPref:=ExecBlock("CNTRETPR",.F.,.F.))=="C",PADR(cNewPref,Len(SE2->E2_PREFIXO)),cRetPrf)
EndIf

If lRet
	DEFAULT lVisu := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Venda ou Compra                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CN9->(FieldPos("CN9_ESPCTR")) > 0
		cEspCtr := CN9->CN9_ESPCTR
	ElseIf !Empty(CN9->CN9_CLIENT)
		cEspCtr :="2"
	Else
		cEspCtr :="1"
	EndIf
   
	cTpTit := PadR( If(cEspCtr=="1",GetNewPar( "MV_CNRETTC",  "NDF" ),GetNewPar( "MV_CNRETTV",  "NCC" )), len( SE2->E2_TIPO ) )//Tipo do titulo - Nota de Debito ao Fornecedor / Nota de Credito ao Cliente

	PRIVATE lBxCNT   := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona campos para a baixa do contrato          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aHeader,{STR0139,FLD_BAIXA,PesqPict("CNT","CNT_VLRET"),15,2,"CN100VldBx()","","N","","V"})//Baixa
	aAdd(aHeader,{STR0140,FLD_SALDO,PesqPict("CNT","CNT_VLRET"),15,2,"","","N","","V"})//Saldo

	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek("CNT")
		Do While !Eof() .And. SX3->X3_ARQUIVO=="CNT"
			If ( X3USO(SX3->X3_USADO)) .And. cNivel >= SX3->X3_NIVEL .And. aScan(aNoFields, {|x| x == AllTrim(SX3->X3_CAMPO)}) == 0
				aAdd(aHeader,{AllTrim(X3Titulo()),;
				AllTrim(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT})
			EndIf
			dbSkip()
		EndDo
	EndIf
	
	//Adiciona o numero da planilha no aHeader	
	aAdd(aHeader,{STR0154,FLD_PLANI,PesqPict("CND","CND_NUMERO"),6,0,"","","C","","V"})				// Planilha
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a dialog de retencao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0091) FROM 0,0 TO 300,590 OF oMainWnd PIXEL // "Baixa da Caução de Retenção"
	
	oGetCNT := MsNewGetDados():New(25,4,__DlgHeight(oDlg)-30,__DlgWidth(oDlg)-4,GD_UPDATE,,,,{FLD_BAIXA,"CNT_HIST"},,,,,,oDlg,aHeader,aCols)
	
	@ __DlgHeight(oDlg)-27,4  Say OemToAnsi(STR0155) Size 60,8 OF oDlg PIXEL//"Total"
	@ __DlgHeight(oDlg)-27,23 MsGet oTotBaix Var nTotBaix PICTURE PesqPict("CNT","CNT_VLRET") WHEN .F. SIZE 60,8 OF oDlg PIXEL
	
	@ 10, 004 Say If(cEspCtr=="1",STR0095,STR0130) Size 60,8 PIXEL//"Fornecedor"/"Cliente"
	@ 09, 034 MsGet cCodiCNT SIZE 25,8 F3 "CNC001" Valid Vazio(cCodiCNT) .Or. CN100VldCauc(CN9->CN9_NUMERO,cCodiCNT,cLojaCNT,@nVlEft,oGetCNT) PIXEL
	
	@ 10, 075 Say OemToAnsi(STR0097) Size 60,8 PIXEL//"Loja"
	@ 09, 088 MsGet cLojaCNT SIZE 25,8 Valid Vazio(cLojaCNT) .Or. CN100VldCauc(CN9->CN9_NUMERO,cCodiCNT,cLojaCNT,@nVlEft,oGetCNT) PIXEL
	
	@ __DlgHeight(oDlg)-27,__DlgWidth(oDlg)-80  BUTTON STR0114 SIZE 35 ,13  FONT oDlg:oFont ACTION (nOpca:=1,oDlg:End()) OF oDlg PIXEL//"Baixar"
	@ __DlgHeight(oDlg)-27,__DlgWidth(oDlg)-40  BUTTON "Sair" SIZE 35 ,13  FONT oDlg:oFont ACTION (nOpca:=0,oDlg:End()) OF oDlg PIXEL//"Baixar"
	
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valor do resgate            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlReg:=0
		nPosBx:=aScan(oGetCNT:aHeader,{|x| AllTrim(x[2])==FLD_BAIXA})
		For nx:=1 to len(oGetCNT:aCols) 
			nVlReg+=Round(oGetCNT:aCols[nx,nPosBx],TamSX3("CNT_VLRET")[2])
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para nao permitir baixa com valor zerado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QtdComp(nVlReg) == QtdComp(0)
			Aviso(STR0088,STR0141,{"Ok"}) //"Não e possivel realizar a baixa de retenção com valor zerado !"
			Return
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa ponto de entrada antes do processamento da baixa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CN100ABAIX")
			ExecBlock("CN100ABAIX",.F.,.F.,{nVlReg,oGetCNT:aCols,oGetCNT:aHeader,cCodiCNT,cLojaCNT})
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa processamento da baixa         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		Processa({|| IF((lRet:=CN100PrcBxRet(CN9->CN9_NUMERO,CN9->CN9_REVISA,cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,@cNumTit,oGetCNT:aCols,oGetCNT:aHeader,@lBxPe,@cParcela)) .And. lVisu,CN100LdAl(2,"CNT",aCols9,aHeader9,"CNT.CNT_CONTRA = '"+ M->CN9_NUMERO +"'",{"CNT_FORNEC","CNT_LJFORN","CNT_DTMED"},oGetDad9,If(cEspCtr=="1",{"CNT_CONTRA","CNT_CLIENT","CNT_LOJACL"},{"CNT_CONTRA","CNT_CLIENT","CNT_LOJACL","CNT_FORNEC","CNT_LJFORN"})),)},,OemToAnsi(STR0103))//"Processando Baixa"
		
		If lRet .And. AliasInDic("CNY")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza tabela de baixas de retencao (CNY)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosMed := aScan(oGetCNT:aHeader,{|x| AllTrim(x[2])=="CNT_NUMMED"})
			For nx:=1 to len(oGetCNT:aCols)
				CN100GrvCNY(CN9->CN9_NUMERO,CN9->CN9_REVISA,cCodiCNT,cLojaCNT,oGetCNT:aCols[nx,nPosBx],cNumTit,cRetPrf,cParcela,cTpTit,oGetCNT:aCols[nx,nPosMed])
			Next
		EndIf
	
		If lRet	.And. !lBxPe
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa ponto de entrada depois do processamento da baixa ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("CN100DBAIX")
				ExecBlock("CN100DBAIX",.F.,.F.,{nVlReg,cRetPrf,cNumTit,cParcela,cTpTit,cCodiCNT,cLojaCNT})
			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe o resumo                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0104) FROM 9,0 TO 25,50 OF oMainWnd //"Resumo"
			@ 00,00 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 30, 120 NOBORDER WHEN .F. PIXEL
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			@ 08,38 SAY OemToAnsi(STR0104) FONT oBold PIXEL//"Resumo"
			
			@ 24,30 TO 26 ,400 LABEL '' OF oDlg   PIXEL
			
			@ 31,38 SAY OemToAnsi(STR0105) PIXEL OF oDlg // "Prefixo"
			@ 41,38 SAY OemToAnsi(STR0106) PIXEL OF oDlg // "Numero do Titulo"
			@ 51,38 SAY OemToAnsi(STR0107) PIXEL OF oDlg // "Tipo"
			@ 61,38 SAY OemToAnsi(STR0108) PIXEL OF oDlg // "Valor"
			
			@ 31,110 SAY cRetPrf SIZE 80, 10 PIXEL   RIGHT
			@ 41,110 SAY cNumTit  SIZE 80, 10 PIXEL   RIGHT
			@ 51,110 SAY cTpTit   SIZE 80, 10 PIXEL   RIGHT
			@ 61,110 SAY Transform(nVlReg  ,PesqPict("SE2","E2_VALOR"))  SIZE 80, 10 PIXEL   RIGHT
			
			@ 90,030 TO 92 ,400 LABEL '' OF oDlg PIXEL
			
			DEFINE SBUTTON oBut FROM 101,162  TYPE 1 ACTION ( oDlg:End() ) ENABLE of oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf	
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldCauc³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o fornecedor informado e calcula o valor retido       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldCauc(cExp01,cExp02,cEpx03,nExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                  ³±±
±±³          ³ cExp02 - Codigo do fornecedor/cliente                        ³±±
±±³          ³ cExp03 - Codigo da loja                                      ³±±
±±³          ³ nExp04 - Valor efetivo - referencia                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100VldCauc(cContra,cCodigo,cLoja,nVlEft,oGetCNT)
Local cQuery	:= ""
Local cNumMed	:= ""
Local cAlias	:= GetNextAlias()
Local lRet		:= .T.
Local aArea	:= GetArea()
Local nX		:= 0
Local cEspCtr	:= ""

Default cCodigo	:= ""
Default cLoja		:= ""

//-- Verifica tipo de contrato
If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr :="2"
Else
	cEspCtr :="1"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o fornecedor                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEspCtr == "1"
	lRet := ExistCpo("SA2",cCodigo+If(Empty(cLoja),"",cLoja))
Else
	lRet := ExistCpo("SA1",cCodigo+If(Empty(cLoja),"",cLoja))
EndIf

oGetCNT:aCols := {}

If lRet .And. !Empty(cCodigo) .And. !Empty(cLoja)
	cQuery := "SELECT CNT.*,(CNT.CNT_VLRET-CNT.CNT_VLBX) AS CNT_SALDO "
	cQuery += "  FROM "+RetSQLName("CNT")+" CNT "
	cQuery += " WHERE CNT.CNT_FILIAL = '"+xFilial("CNT")+"'"
	cQuery += "   AND CNT.CNT_CONTRA = '"+cContra+"'"
	cQuery += "   AND "
	If cEspCtr == "1"
		cQuery += "CNT.CNT_FORNEC = '"+cCodigo+"' AND "
		If !Empty(cLoja)
			cQuery += "CNT.CNT_LJFORN = '"+cLoja+"' AND "
		EndIf
	Else
		cQuery += "CNT.CNT_CLIENT = '"+cCodigo+"' AND "
		If !Empty(cLoja)
			cQuery += "CNT.CNT_LJFORN = '"+cLoja+"' AND "
		EndIf
	EndIf
	cQuery += "      CNT.CNT_VLRET > CNT.CNT_VLBX "
	cQuery += " AND CNT.D_E_L_E_T_ = ' '
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	aStrucCNT := CNT->(dbStruct())
	For nx:=1 to len(aStrucCNT)
		if (cAlias)->(FieldPos(aStrucCNT[nx,1])) > 0 .And. aStrucCNT[nx,2] <> "C"
			TCSetField( cAlias, aStrucCNT[nx,1], aStrucCNT[nx,2], aStrucCNT[nx,3], aStrucCNT[nx,4] )
		endif
	Next

	TCSetField(cAlias,"CNT_SALDO" ,"N",TamSX3("CNT_VLRET")[1],TamSX3("CNT_VLRET")[2])
	
	If (cAlias)->(Eof())
		lRet := .F.
		If cEspCtr == "1"
			Aviso( STR0088, STR0109, {"OK"})//"O fornecedor selecionado não possui valor retido em caução!"
		Else
			Aviso( STR0088, STR0142, {"OK"})//"O cliente selecionado não possui valor retido em caução!"
		EndIf
	Else
		While !(cAlias)->(Eof())
	  		aAdd(oGetCNT:aCols,Array(Len(oGetCNT:aHeader)+1))

  			For nx	:= 1 To Len(oGetCNT:aHeader)
		  		cCampo := Alltrim(oGetCNT:aHeader[nx,2])

				If cCampo == "CNT_NUMMED"
					cNumMed := (cAlias)->( FieldGet( (cAlias)->( FieldPos(oGetCNT:aHeader[nx][2]) ) ) )					
				Endif

  				If ( oGetCNT:aHeader[nx][10] != "V" )
					oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := (cAlias)->( FieldGet( (cAlias)->( FieldPos(oGetCNT:aHeader[nx][2]) ) ) )
				Else
					Do Case
						Case oGetCNT:aHeader[nx][2] == FLD_SALDO
							oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := (cAlias)->CNT_SALDO
						Case oGetCNT:aHeader[nx][2] == FLD_BAIXA
				 			oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := 0	
						Case oGetCNT:aHeader[nx][2] == FLD_PLANI
							DbSelectArea("CND")
							DbSetorder(4)
							If DbSeek(xFilial("CND")+cNumMed)
								oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := If(Empty(CND->CND_NUMERO),"------",CND->CND_NUMERO)
							EndIf
						OtherWise
							oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := CriaVar(oGetCNT:aHeader[nx][2])
					EndCase
		 		EndIf
			Next nX
			oGetCNT:aCols[Len(oGetCNT:aCols), Len(oGetCNT:aHeader)+1] := .F.

			(cAlias)->( dbSkip() )
		EndDo
	EndIf
EndIf

oGetCNT:Refresh()

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldCauc³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera o titulo a pagar para o valor retido do contrato        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldCauc(cExp01,cExp02,cEpx03,cExp04,cExp05,nExp06,cExp07³±±
±±³          ³              ,cExp08,cExp09,cExp10)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Fornecedor                                          ³±±
±±³          ³ cExp02 - Loja do fornecedor                                  ³±±
±±³          ³ cExp03 - Codigo do banco                                     ³±±
±±³          ³ cExp04 - Agencia                                             ³±±
±±³          ³ cExp05 - Conta                                               ³±±
±±³          ³ nExp06 - Valor do titulo                                     ³±±
±±³          ³ cExp07 - Natureza do titulo                                  ³±±
±±³          ³ cExp08 - Prefixo do titulo                                   ³±±
±±³          ³ cExp09 - Tipo do titulo                                      ³±±
±±³          ³ cExp10 - Numero do titulo - referencia                       ³±±
±±³          ³ cExp11 - Tipo da Transacao 1-Retencao,2-Adiantamento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100GerSE2(cForn,cLoja,cBco,cAgc,cCta,nVlRet,cRetNat,cRetPrf,cTpTit,cNumTit,cTipo,cParcela)

Local aAreaSub
Local aRotAuto := {}
Local aAfrBck  := {}
Local aArea    := GetArea()

Local cQuery   := ""
Local cMaxTit  := ""        
Local cMoeda   := ""
Local cFilSE2  := xFilial("SE2")

Local nx

Local lRet     := .T.
Local lExcPms  := IntePMS() .And. (GetNewPar( "MV_CNEXPMS", "N" ) == "S")

PRIVATE lMsErroAuto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona sequencia dos titulos a pagar    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT MAX(SE2.E2_NUM) as E2_NUM "
cQuery += " FROM "+ RetSQLName("SE2") +" SE2 "
cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2")+"'"
cQuery += "   AND SE2.E2_PREFIXO = '"+ cRetPrf +"'"
cQuery += "   AND SE2.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE2TMP",.F.,.T.)

cNumTit := Soma1(SE2TMP->E2_NUM)

cParcela := CriaVar("E2_PARCELA")
cMoeda   := CN9->CN9_MOEDA

SE2TMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe integracao com o PMS    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExcPms
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Simula chamada do FINA050  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRatAfr := {}
	Private lF050Auto := .T.
	Private M->E2_VALOR := nVlRet
	Private M->E2_MOEDA := cMoeda
	Private M->E2_EMISSAO := dDataBase
	Private M->E2_MDCONTR := CN9->CN9_NUMERO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa Dialog para preenchimento do projeto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSub := GetArea()
	PmsDlgFS(3,cRetPrf,cNumTit,cParcela,cTpTit,cForn,cLoja)
	RestArea(aAreaSub)
	aAfrBck  := aRatAfr
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao do rateio do projeto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CNTVLDPMS")
	lRet := ExecBlock("CNTVLDPMS",.F.,.F.,{nVlRet,"1"})
EndIf

If lRet
	dbSelectArea("SE2")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica proximo codigo disponivel ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	While dbSeek(cFilSE2+cRetPrf+cNumTit)
		cNumTit += Soma1(cNumTit)
	EndDo

	BEGIN TRANSACTION
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera nota de debito ao fornecedor          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aRotAuto, { "E2_NUM"    , cNumTit, NIL } )
	AAdd( aRotAuto, { "E2_PREFIXO", cRetPrf, NIL } )
	AAdd( aRotAuto, { "E2_NATUREZ", cRetNat, NIL } )
	AAdd( aRotAuto, { "E2_PARCELA", cParcela, NIL } )
	AAdd( aRotAuto, { "E2_TIPO"   , cTpTit, NIL } )
	AAdd( aRotAuto, { "E2_FORNECE", cForn, NIL } )
	AAdd( aRotAuto, { "E2_LOJA"   , cLoja, NIL } )
	AAdd( aRotAuto, { "E2_VALOR"  , nVlRet, NIL } )
	AAdd( aRotAuto, { "E2_EMISSAO", dDataBase, NIL } )
	AAdd( aRotAuto, { "E2_VENCTO" , dDataBase, NIL } )
	AAdd( aRotAuto, { "E2_VENCREA", DataValida( dDataBase ), NIL } )
	AADD( aRotAuto, { "E2_VENCORI", DataValida( Ddatabase,.T.),NIL })
	AADD( aRotAuto, { "E2_MOEDA"  , cMoeda, NIL})
	AADD( aRotAuto, { "E2_MDCONTR", CN9->CN9_NUMERO, NIL})
	AADD( aRotAuto, { "E2_MDREVIS", CN9->CN9_REVISA, NIL})
	AADD( aRotAuto, { "E2_ORIGEM" , "CNTA100"      , NIL})
	AAdd( aRotAuto, { "AUTBANCO"  , cBco, NIL } )
	AAdd( aRotAuto, { "AUTAGENCIA", cAgc, NIL } )
	AAdd( aRotAuto, { "AUTCONTA"  , cCta, NIL } ) 
	
	MSExecAuto({|x, y| FINA050(x, y)}, aRotAuto, 3)
	
	If !lMsErroAuto
		aRatAfr := aAfrBck
		If !Empty(aRatAfr)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava informacao de despesa do projeto  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsWriteFI(1,"SE2")
			aRatAfr := {}		
		EndIf
	EndIf
	END TRANSACTION

	If lMsErroAuto 	
		MOSTRAERRO()
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100GerSE1 ³ Autor ³ Robson Nayland        ³ Data ³06.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera o titulo a receber para o valor retido do contrato      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100GerSE1(cExp01,cExp02,cEpx03,cExp04,cExp05,nExp06,cExp07 ³±±
±±³          ³              ,cExp08,cExp09,cExp10)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Fornecedor                                          ³±±
±±³          ³ cExp02 - Loja do fornecedor                                  ³±±
±±³          ³ cExp03 - Codigo do banco                                     ³±±
±±³          ³ cExp04 - Agencia                                             ³±±
±±³          ³ cExp05 - Conta                                               ³±±
±±³          ³ nExp06 - Valor do titulo                                     ³±±
±±³          ³ cExp07 - Natureza do titulo                                  ³±±
±±³          ³ cExp08 - Prefixo do titulo                                   ³±±
±±³          ³ cExp09 - Tipo do titulo                                      ³±±
±±³          ³ cExp10 - Numero do titulo - referencia                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100GrSE1(cCliente,cLoja,cBco,cAgc,cCta,nVlRet,cRetNat,cRetPrf,cTpTit,cNumTit,lExbErro,cParcela)

Local aAreaSub
Local aRotAuto := {}
Local aArea    := GetArea()
Local aAftBck  := {}
Local aVend    := CtaVend(CN9->CN9_NUMERO)
Local aCN100RAU:= {}

Local cQuery   := ""
Local cMaxTit  := ""
Local cMoeda   := ""
Local cFilSE1  := xFilial("SE1")     

Local nx

Local lRet     := .T.
Local lExcPms  := IntePMS() .And. (GetNewPar( "MV_CNEXPMS", "N" ) == "S")

Default lExbErro := .T.

PRIVATE lMsErroAuto := .F.

cParcela := CriaVar("E1_PARCELA")
cMoeda   := CN9->CN9_MOEDA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona sequencia dos titulos a pagar    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT MAX(SE1.E1_NUM) as E1_NUM "
cQuery += "  FROM "+ RetSQLName("SE1") +" SE1 "
cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
cQuery += "   AND SE1.E1_PREFIXO = '"+ cRetPrf +"'"
cQuery += "   AND SE1.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE1TMP",.F.,.T.)

cNumTit := Soma1(SE1TMP->E1_NUM)

SE1TMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe integracao com o PMS    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExcPms
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Simula chamada do FINA040  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRatAft := {}
	Private M->E1_VALOR := nVlRet
	Private M->E1_MOEDA := cMoeda
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa Dialog para preenchimento do projeto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSub := GetArea()
	PmsDlgRC(3,cRetPrf,cNumTit,cParcela,cTpTit,cCliente,cLoja)
	RestArea(aAreaSub)
	aAftBck  := aRatAft
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao do rateio do projeto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CNTVLDPMS")
	lRet := ExecBlock("CNTVLDPMS",.F.,.F.,{nVlRet,"2"})
EndIf

If lRet
	dbSelectArea("SE1")
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica codigo disponivel        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While dbSeek(cFilSE1+cRetPrf+cNumTit)
		cNumTit += Soma1(cNumTit)
	EndDo

	BEGIN TRANSACTION
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera nota de debito ao Cliente             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aRotAuto, { "E1_NUM"    , cNumTit, NIL } )
		AAdd( aRotAuto, { "E1_PREFIXO", cRetPrf, NIL } )
		AAdd( aRotAuto, { "E1_NATUREZ", cRetNat, NIL } )
		AAdd( aRotAuto, { "E1_TIPO"   , cTpTit, NIL } )
		AAdd( aRotAuto, { "E1_CLIENTE", cCliente, NIL } )
		AAdd( aRotAuto, { "E1_LOJA"   , cLoja, NIL } )
		AAdd( aRotAuto, { "E1_VALOR"  , nVlRet, NIL } )
		AAdd( aRotAuto, { "E1_EMISSAO", dDataBase, NIL } )
		AAdd( aRotAuto, { "E1_VENCTO" , dDataBase, NIL } )
		AAdd( aRotAuto, { "E1_VENCREA", DataValida( dDataBase ), NIL } )
		AADD( aRotAuto, { "E1_VENCORI", DataValida( Ddatabase,.T.),NIL })
		AADD( aRotAuto, { "E1_MOEDA"  , CN9->CN9_MOEDA, NIL})
		AADD( aRotAuto, { "E1_MDCONTR", CN9->CN9_NUMERO, NIL})
		AADD( aRotAuto, { "E1_MDREVIS", CN9->CN9_REVISA, NIL})
		AADD( aRotAuto, { "E1_ORIGEM" , "CNTA100"     , NIL})
		AADD( aRotAuto, { "AUTBANCO"  , cBco, NIL } )
		AADD( aRotAuto, { "AUTAGENCIA", cAgc, NIL } )
		AADD( aRotAuto, { "AUTCONTA"  , cCta, NIL } )
	
		If ExistBlock("CN100RAU")
			aCN100RAU:= ExecBlock("CN100RAU",.F.,.F.,{aRotAuto})
			If ValType(aCN100RAU) == "A" 
				aRotAuto    := aClone(aCN100RAU)  
			EndIf
		EndIf
		
		MSExecAuto({|x, y| FINA040(x, y)}, aRotAuto, 3)
	
		If !lMsErroAuto
			aRatAft := aAftBck
			If !Empty(aRatAft)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava informacao de despesa do projeto  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PmsWriteRC(1,"SE1")
				aRatAft := {}		
			EndIf
		EndIf
	END TRANSACTION

	If lMsErroAuto .And. lExbErro
		MOSTRAERRO()
	EndIf
EndIf

RestArea(aArea)

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100BxRet  ³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa baixa das retencoes do contrato                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100BxRet(nExp01,cExp02,cEpx03,cExp04,lExp05)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Valor a ser resgatado                               ³±±
±±³          ³ cExp02 - Codigo do contrato                                  ³±±
±±³          ³ cExp03 - Codigo do fornecedor                                ³±±
±±³          ³ cExp04 - Loja do fornecedor                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100BxRet(aCols,aHeader,cContra,cForn,cLoja)
Local nx        := 0
Local ny        := 0
Local nPosBx    := aScan(aHeader,{|x| AllTrim(x[2])==FLD_BAIXA})
Local nPosMed   := aScan(aHeader,{|x| AllTrim(x[2])=="CNT_NUMMED"})
                                                                    
dbSelectArea("CNT")
dbSetOrder(1)

For nx:=1 to len(aCols)
	If dbSeek(xFilial("CNT")+cContra+aCols[nx,nPosMed])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a baixa                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CNT",.F.)
			If	aCols[nx,nPosBx] > 0
				CNT->CNT_DTBX := dDataBase
			EndIf
			CNT->CNT_VLBX += aCols[nx,nPosBx]
			For ny:=1 to len(aHeader)
				If !(aHeader[ny,2] $ "BAIXA|SALDO|CNT_VLBX|CNT_VLRET|CNT_DTBX")
					CNT->&(aHeader[ny,2]) := aCols[nx,ny]
				EndIf
			Next
		MsUnlock()
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100PrcBxRet³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa o processamento da baixa de retencao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100PrcBxRet(cExp01,cExp02,cEpx03,cExp04,cExp05,cExp06,cExp07³±±
±±³          ³               nExp08,cExp09,cEpx10,cExp11,cExp12)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                   ³±±
±±³          ³ cExp02 - Codigo da revisao                                    ³±±
±±³          ³ cExp03 - Codigo do fornecedor/cliente                         ³±±
±±³          ³ cExp04 - Loja do fornecedor                                   ³±±
±±³          ³ cExp05 - Codigo do banco                                      ³±±
±±³          ³ cExp06 - Codigo da agencia                                    ³±±
±±³          ³ cExp07 - Codigo da conta                                      ³±±
±±³          ³ cExp08 - Valor do resgate                                     ³±±
±±³          ³ cExp09 - Natureza do titulo                                   ³±±
±±³          ³ cExp10 - Prefixo do titulo                                    ³±±
±±³          ³ cExp11 - Tipo do titulo                                       ³±±
±±³          ³ cExp12 - Numero do titulo - referencia                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100PrcBxRet(cContra,cRevisa,cCodigo,cLoja,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,cNumTit,aCols,aHeader,lBxPe,cParcela)
Local lRet    := .F.
Local nPosMed := aScan(aHeader,{|x| AllTrim(x[2])=="CNT_NUMMED"})
Local nTotRet := 0
Local nX     := 0

lBxPe := ExistBlock("CN100BxRet")

ProcRegua(2)

dbSelectArea("CNT")
dbSetOrder(1)

For nx:=1 to len(aCols)
	If dbSeek(xFilial("CNT")+cContra+aCols[nx,nPosMed])
		nTotRet += CNT->CNT_VLRET
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe ponto de entrada para baixa da retencao ³
//³ Tratamento especifico para Galvao, para geracao das DAPs   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc()
If lBxPe
	lRet := ExecBlock("CN100BxRet",.F.,.F.,{cCodigo,cLoja,nVlReg,aCols,aHeader})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera o titulo                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(CNT->CNT_CLIENT)
		lRet := CN100GerSE2(cCodigo,cLoja,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,@cNumTit,@cParcela)
	Else
		lRet := CN100GrSE1(cCodigo,cLoja,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,@cNumTit,.F.,@cParcela)	
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a baixa das retencoes                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CN100BxRet(aCols,aHeader,CN9->CN9_NUMERO,cCodigo,cLoja)
	IncProc()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100CtrRet  ³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a baixa dos valores retidos atraves do browse de      ³±±
±±³          ³ contrato                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100CtrRet()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100CtrRet()

Private nTotBaix  := 0
Private oTotBaix

If CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "2"
	CN100BxCauc(.F.)
Else
	Aviso(STR0088,STR0112,{"OK"})//"O contrato selecionado não possui caução de retenção." 
EndIf
Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100CtrAdia³ Autor ³ Robson Nayland       ³ Data ³17.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa Adiantamento de valores dos contratos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100CtrAdia                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100CtrAdia()
Local oDlg

Local nVlAdianta:= 0
Local nOpca     := 0
Local nStack    := GetSX8Len()

Local cTpTit    
Local cEspCtr
Local cPicture  := PesqPict("CNX","CNX_VLADT")
Local cNumTit   := ""
Local cBco      := Space(TamSX3("A6_COD")[1])//Banco
Local cAgc      := Space(TamSX3("A6_AGENCIA")[1])//Agencia
Local cCta      := Space(TamSX3("A6_CONTA")[1])//Conta
Local cRetNat   := PadR( GetNewPar( "MV_CNNATAD",  "" ), Len( SE2->E2_NATUREZ ) )//Natureza
Local cRetPrf   := PadR( GetNewPar( "MV_CNPREAD", "CRE" ), Len( SE2->E2_PREFIXO ) )//Prefixo
Local cNumCNX   := CriaVar("CNX_NUMERO")
Local cNaDitc   := AllTrim(GetNewPar("MV_CNADITC","NDF"))
Local cCodiCNT	 := Space(TamSX3("A2_COD")[1])
Local cLojaCNT := Space(TamSX3("A2_LOJA")[1])

Local lRet      :=.T. 
Local lRetAdo   :=.T.
Local lRetVl   := .F.

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf        

If AllTrim(CN9->CN9_SITUAC) != DEF_SVIGE
	Help(" ",1,"CNTA100ADI") //"Acao disponivel apenas para contratos em Vigencia"
	lRet := .F.
EndIf

If lRet .And. Empty( cRetNat )
	Aviso( STR0088, STR0119, { "OK" }, 2 )//"Configurar a natureza financeira do adiantamento atraves do parametro MV_CNNATAD."
	lRet := .F.
EndIf

SED->( dbSetOrder( 1 ) )
		
If lRet .And. !SED->( MsSeek( xFilial( "SED" ) + cRetNat ) )
	Aviso( STR0088, STR0120, { "OK" }, 2 ) // "A natureza definida pelo parametro MV_CNNATAD nao esta cadastrada."
	lRet := .F.
EndIf        

If ExistBlock("CNTPREAD")
	cRetPrf := If(ValType(cNewPref:=ExecBlock("CNTPREAD",.F.,.F.))=="C",PADR(cNewPref,Len(SE2->E2_PREFIXO)),cRetPrf)
EndIf
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ponto de entrada para permitir a execucao da tela do Adiantamento ou nao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lRet .And. ExistBlock("CN100ADO")    
	lRetAdo :=  ExecBlock("CN100ADO",.F.,.F.)
	If ValType( lRetAdo ) == "L"
		lRet := lRetAdo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida natureza informada no parametro MV_CNRETNA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Venda ou Compra                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If cEspCtr == "2"
      cTpTit := PadR( GetNewPar( "MV_CNADITV",  "NCC" ), Len( SE1->E1_TIPO ) )//Tipo do titulo - PADRAO: NCC//"NCC"
   Else 
      cTpTit := PadR( GetNewPar( "MV_CNADITC",  "NDF" ), Len( SE2->E2_TIPO ) )//Tipo do titulo - PADRAO: Nota de Debito ao Fornecedor "NDF"//"NDF"
   Endif

	PRIVATE lBxCNT   := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria dialog para execucao da baixa     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0118) FROM 0,0 TO 250,410 OF oMainWnd PIXEL // "Adiantamento"
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 55, 1000 NOBORDER WHEN .F. PIXEL
	
	@ 03, 40 SAY OemToAnsi(STR0121) FONT oBold PIXEL // "Adiantamento de Contrato - Compra"
	@ 14, 30 TO 16 ,400 LABEL '' OF oDlg   PIXEL
	@ 30, 40 Say OemToAnsi(STR0125) Size 80,8 PIXEL // "Digite o Valor Total do Adiantamento"

   	@ 45,  40 Say OemToAnsi(STR0131) Size 60,8 PIXEL//"Num. do Adiantamento "
	@ 44, 100 MsGet cNumCNX  Size 55,8 WHEN .F. PIXEL//"Num. do Adiantamento "

   	@ 60, 040 Say OemToAnsi(STR0093) Size 60,8 PIXEL//"Banco"
	@ 59, 060 MsGet cBco SIZE 25,8 F3 "SA6" Valid Vazio(cBco) .Or. ExistCpo("SA6",cBco) PIXEL
   		
   	@ 60, 95 Say OemToAnsi(STR0094) Size 60,8 PIXEL//"Agência"    
	@ 59, 118 MsGet cAgc SIZE 20,8 Valid Vazio(cAgc) .Or. If(!Empty(cBco),ExistCpo("SA6",cBco+cAgc),.T.) PIXEL 
    	
   	@ 60, 150 Say OemToAnsi(STR0096) Size 60,8 PIXEL//"Conta"
   	@ 59, 166 MsGet cCta SIZE 35,8 Valid Vazio(cCta) .Or. If(!Empty(cBco) .And. !Empty(cAgc),ExistCpo("SA6",cBco+cAgc+cCta),.T.) PIXEL 

	If cEspCtr == "1"
		@ 75, 040 Say If(cEspCtr == "1",STR0095,STR0130) Size 60,8 PIXEL//"Fornecedor"/"Cliente"
		@ 74, 070 MsGet cCodiCNT SIZE 25,8 F3 "CNC001" Valid VlCliForAd(cEspCtr,cCodiCNT,cLojaCNT) PIXEL                

		@ 75, 115 Say OemToAnsi(STR0097) Size 60,8 PIXEL//"Loja"
		@ 74, 128 MsGet cLojaCNT Valid VlCliForAd(cEspCtr,cCodiCNT,cLojaCNT) SIZE 25,8  PIXEL
	Else
		cCodiCNT := CN9->CN9_CLIENT
		cLojaCNT := CN9->CN9_LOJACL
	EndIf

	@ 90,  40 Say OemToAnsi(STR0108) Size 60,8 PIXEL//"Valor"
   	@ 90, 100 MsGet oGetAdianta Var nVlAdianta Picture cPicture SIZE 55,8 Valid ValidValor(nVlAdianta,lRetVl) WHEN .T. PIXEL
   	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿             
	//³ Valida os campos                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   	DEFINE SBUTTON FROM 110,145 TYPE 1;
   		ACTION If(Empty(cCodiCNT) .Or. Empty(cLojaCNT),;						//-- Valida preenchimento do fornecedor/cliente
						Aviso(STR0088,If(cEspCtr == "1",STR0110,STR0185),{"OK"}),;		//-- Selecione um fornecedor
					If(cTpTit $ "PA*RA" .And. (Empty(cBco) .Or. Empty(cAgc) .Or. Empty(cCta)),; //-- Valida preenchimento do banco
							Aviso(STR0088,STR0111,{"OK"}),;							//-- Selecione um banco/agência/conta
					If(Empty(nVlAdianta),;											//-- Valida preenchimento do valor
							Aviso(STR0088,STR0125,{"OK"}),;							//-- Informe o Valor do Adiantamento
					(oDlg:End(),nOpcA := 1)))) ENABLE OF oDlg 
	DEFINE SBUTTON FROM 110,175 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ponto de entrada para permitir a execucao da tela do Adiantamento ou nao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If ExistBlock("CN100ACN")    
		lRetAcn :=  ExecBlock("CN100ACN",.F.,.F.,{cTpTit,cBco,cAgc,cCta,cRetNat,cRetPrf,cNumCNX,cTpTit,cCodiCNT,cLojaCNT,cEspCtr})
		If ValType( lRetAcn ) == "L"
			nOpca := iIf(lRetAcn,1,0)
		EndIf
	EndIf

	If nOpca == 1 
		If( Aviso( STR0088, STR0124, { STR0101, STR0102 } )==1) // "Atencao", "Confirma o Adiantamento do valor ?", Sim","Nao"
  			Processa({|| lRet:=CN100ProcAd(cNumCNX,cEspCtr,CN9->CN9_NUMERO,@cCodiCNT,@cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,@cNumTit)},,OemToAnsi(STR0132))//"Processando Adiantamento"
	 	Else
			lRet := .F.
		EndIf

       If lRet                                                               
     	    While GetSX8Len() > nStack
        		ConfirmSX8()
	    	EndDo
			Aviso(STR0088,STR0127,{"OK"}) //"Adiantamento incluso com sucesso."
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe o resumo                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0104) FROM 9,0 TO 26,50 OF oMainWnd //"Resumo"
			@ 00,00 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 35, 130 NOBORDER WHEN .F. PIXEL
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			@ 08,38 SAY OemToAnsi(STR0104) FONT oBold PIXEL//"Resumo"
			
			@ 24,30 TO 26 ,400 LABEL '' OF oDlg   PIXEL
			
			@ 31,38 SAY OemToAnsi(STR0105) PIXEL OF oDlg // "Prefixo"
			@ 41,38 SAY OemToAnsi(STR0106) PIXEL OF oDlg // "Numero do Titulo"
			@ 51,38 SAY OemToAnsi(STR0107) PIXEL OF oDlg // "Tipo"
			@ 61,38 SAY OemToAnsi(STR0108) PIXEL OF oDlg // "Valor"
            @ 71,38 SAY If(cEspCtr ="1",STR0095,STR0130) PIXEL OF oDlg // "Fornecedor"			
			@ 31,110 SAY cRetPrf SIZE 80, 10 PIXEL   RIGHT
			@ 41,110 SAY cNumTit  SIZE 80, 10 PIXEL   RIGHT
      		@ 51,110 SAY cTpTit   SIZE 80, 10 PIXEL   RIGHT
			If cEspCtr ="1"  
				SA2->(DbsetOrder(1))
				SA2->(Dbseek(xFilial("SA2")+cCodiCNT+cLojaCNT))
				@ 61,110 SAY Transform(nVlAdianta ,PesqPict("SE2","E2_VALOR"))  SIZE 80, 10 PIXEL   RIGHT
				@ 71,110 SAY SA2->A2_COD+""+SA2->A2_LOJA  SIZE 80, 10 PIXEL   RIGHT
				@ 81,110 SAY SA2->A2_NOME  SIZE 80, 40 PIXEL   RIGHT
      		Else                                                                       
				SA1->(DbsetOrder(1))
				SA1->(Dbseek(xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL))
				@ 61,110 SAY Transform(nVlAdianta ,PesqPict("SE1","E1_VALOR"))  SIZE 80, 10 PIXEL   RIGHT
				@ 71,110 SAY SA1->A1_COD+""+SA1->A1_LOJA  SIZE 80, 10 PIXEL   RIGHT
				@ 81,110 SAY SA1->A1_NOME SIZE 80, 40 PIXEL   RIGHT
			Endif
			@ 100,030 TO 102 ,400 LABEL '' OF oDlg PIXEL
			DEFINE SBUTTON oBut FROM 111,162  TYPE 1 ACTION ( oDlg:End() ) ENABLE of oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
	   Else
		  	Aviso(STR0088,STR0128,{"OK"}) //"Não foi possível concluir a inclusão do adiantamento."
	   EndIf
	Else
		While GetSX8Len() > nStack
			RollBackSX8()
		EndDo
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc}VlCliForAd()
Validação para os campos Codigo e Loja da tela de adiantamentos 

@author Andre Anjos
@since 03/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function VlCliForAd(cEspCtr,cCodiCNT,cLojaCNT)
Local lRet := .T.
Local cAlias := If(cEspCtr == "1","SA2","SA1")

lRet := Vazio(cCodiCNT) .Or. ExistCpo(cAlias,cCodiCNT+If(!Empty(cLojaCNT),cLojaCNT,""))

CNC->(dbSetOrder(If(cEspCtr == "1",1,3)))
If lRet .And. !Empty(cCodiCNT) .And. !CNC->(dbSeek(xFilial("CNC")+CN9->(CN9_NUMERO+CN9_REVISA)+cCodiCNT+If(!Empty(cLojaCNT),cLojaCNT,"")))
	Help(" ",1,"REGNOIS")
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100ProcAd ³ Autor ³ Marcelo Custodio     ³ Data ³19.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa processa,emto do Adiantamento dos contratos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100ProcAd                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function CN100ProcAd(cNumCNX,cEspCtr,cContra,cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,cNumTit)
Local lRet:=.T.  

ProcRegua(3) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada anterior a gravacao SE1 e SE2 campos customizados referente ao adiantamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("CN100ANT"))
	ExecBlock("CN100ANT",.F.,.F.,{cNumCNX,cEspCtr,cContra,cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,cNumTit})
EndIf

BEGIN TRANSACTION

IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa processamento                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If cEspCtr ="1"   //Compra
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando Contas a Pagar             ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   cTpTit  :=PadR( GetNewPar( "MV_CNADITC",  "NDF" ), Len( SE2->E2_TIPO ) )//Tipo do titulo - PADRAO: Nota de Debito ao Fornecedor "NDF"
   lRet := CN100GerSE2(cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,@cNumTit,"2")
Else                                                                                 
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Atualizando Contas a receber           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
   cTpTit  :=PadR( GetNewPar( "MV_CNADITV",  "NCC" ), Len( SE1->E1_TIPO ) )//Tipo do titulo - PADRAO: NCC//"NCC"
   lRet := CN100GrSE1(cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,@cNumTit,.F.)
Endif
IncProc()

If lRet		   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizando Adiantamento de Contrato   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DbselectArea("CNX")  
	Reclock("CNX",.T.)
	CNX->CNX_FILIAL := xFilial("CNX")
	CNX->CNX_CONTRA := CN9->CN9_NUMERO
	CNX->CNX_NUMMED := "" 
	CNX->CNX_NUMERO := cNumCNX
	CNX->CNX_NUMTIT := cNumTit
	CNX->CNX_PREFIX := cRetPrf
	If cEspCtr == "1"
	   	CNX->CNX_FORNEC := cCodiCNT
	   	CNX->CNX_LJFORN := cLojaCNT
	Else
		CNX->CNX_CLIENT := cCodiCNT
	   	CNX->CNX_LOJACL := cLojaCNT
	EndIf
	CNX->CNX_VLADT  := nVlAdianta
	CNX->CNX_DTADT  := dDataBase
 	MsUnlock()
EndIf

IncProc()

END TRANSACTION     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada anterior a gravacao campos customizados referente ao adiantamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("CN100ADI"))
	ExecBlock("CN100ADI",.F.,.F.)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100CtAdDel³ Autor ³ Robson Nayland       ³ Data ³18.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa deleção do Adiantamento de valores dos contratos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100CtAdDel                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100CtAdDel()
Local nAdit
Local nCntFor
Local nRecno   := 0
Local nOpca	   :=1 
Local nPosNum  := 0

Local cAdit
Local cCampo
Local cCadBack := cCadastro
Local cBco	   := ""
Local cAgc	   := ""
Local cCta     := ""

Local lIncBack := INCLUI
Local lAltBack := ALTERA
Local lRet 	   := .T.
Local lContinua:= .T.

PRIVATE lMsErroAuto := .F.

INCLUI := .F.
ALTERA := .T.

aCols7 := oGetDad7:aCols

nPosNum := aScan(aHeader7,{|x| AllTrim(x[2]) == "CNX_NUMERO"})

If Len(aCols7)=0 .Or. Len(alltrim(aCols7[1][nPosNum]))=0  //verifica se nao ha registro
	Aviso(STR0088,OemToAnsi(STR0133),{"OK"}) //"Nâo existe registro de Adiantamento"
   lContinua:=.F.
   lRet:=.F.
Endif

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica planilha selecionada                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAdit := oGetDad7:nAt
	cAdit := aCols7[nAdit,nPosNum]

	dbSelectArea("CNX")
	dbSetOrder(1)
	dbSeek(xFilial("CNX")+M->CN9_NUMERO+cAdit)
	
	nRecNo := CNX->(RecNo())
	
	If nRecno > 0
        nVlAdianta:=CNX->CNX_VLADT
     	If nOpca == 1     
	   
	   		nOpca2:=Aviso( STR0088, STR0126, { STR0101, STR0102 })//"Atencao !"##"Confirma o Cancelamento do Adiantamento ?"##"Sim"##"Nao"
	   		if nOpca2==1
	   			If Empty(CNX->CNX_NUMMED)
			  		Processa({|| lRet:=CN100EstAd(CN9->CN9_NUMERO,CNX->CNX_NUMERO,cEspCtr)},,OemToAnsi(STR0132))//"Processando Adiantamento"
			  		If lRet
				  		Aviso(STR0088,STR0134,{"OK"})//"Adiantamento Excluído"
		  				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza folder dos adiantamentos               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDel(aCols7,nAdit)
						aSize(aCols7,len(aCols7)-1)
						
						oGetDad7:aCols := aCols7
						oGetDad7:oBrowse:Refresh()
						oGetDad7:Refresh()
			 		EndIf
				Else
					Help(" ",1,"CN100ADE")
				EndIf
			Endif	
		EndIf
	Endif
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100EstAd  ³ Autor ³ Marcelo Custodio     ³ Data ³20.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processa estorno do titulo de adiantamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100EstAd(cExp01,cExp02,cExp03)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do Contrato                                 ³±±
±±³          ³ cExp02 - Codigo do Adiantamento                             ³±±
±±³          ³ cExp03 - Especie do Contrato 1-Compra;2-Venda               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100EstAd(cContra,cNumAd,cEspCtr)
Local lRet     := .T.
Local cPref    := ""
Local cTit     := ""
Local aRotAuto := {}

ProcRegua(2)

dbSelectArea("CNX")
dbSetOrder(1)
If dbSeek(xFilial("CNX")+cContra+cNumAd)
	cPref := CNX->CNX_PREFIX
	cTit  := CNX->CNX_NUMTIT
	
	BEGIN TRANSACTION

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa processamento                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEspCtr ="1"    // se for fornecedor
		DbselectArea("SE2")
		DbSetOrder(1)
		dbSeek(xFilial("SE2")+cPref+cTit)
		If Found()
			
			AAdd( aRotAuto, { "E2_NUM"    , SE2->E2_NUM, NIL } )
			AAdd( aRotAuto, { "E2_PREFIXO", SE2->E2_PREFIXO, NIL } )
			AAdd( aRotAuto, { "E2_NATUREZ", SE2->E2_NATUREZ, NIL } )
			AAdd( aRotAuto, { "E2_TIPO"   , SE2->E2_TIPO, NIL } )
			AAdd( aRotAuto, { "E2_FORNECE", SE2->E2_FORNECE, NIL } )
			AAdd( aRotAuto, { "E2_LOJA"   , SE2->E2_LOJA, NIL } )
			
			MSExecAuto({|x, y, z| FINA050(x, y, z)}, aRotAuto, 5, 5)
		Endif
	Else
		DbselectArea("SE1")   // se for cliente
		DbSetOrder(1)
		dbSeek(xFilial("SE1")+cPref+cTit)
		If Found()
			AAdd( aRotAuto, { "E1_NUM"    , SE1->E1_NUM, NIL } )
			AAdd( aRotAuto, { "E1_PREFIXO", SE1->E1_PREFIXO, NIL } )
			AAdd( aRotAuto, { "E1_NATUREZ", SE1->E1_NATUREZ, NIL } )
			AAdd( aRotAuto, { "E1_TIPO"   , SE1->E1_TIPO, NIL } )
			AAdd( aRotAuto, { "E1_CLIENTE", SE1->E1_CLIENTE, NIL } )
			AAdd( aRotAuto, { "E1_LOJA"   , SE1->E1_LOJA, NIL } )
			
			MSExecAuto({|x, y| FINA040(x, y)}, aRotAuto, 5)
			
		Endif
	Endif
	
	IncProc()
	
	If !lMsErroAuto
		Reclock("CNX",.F.)
			dbDelete()
		MsUnlock()
	EndIf
	
	END TRANSACTION
	
	If lMsErroAuto
		lRet := .F.
		MOSTRAERRO()
	EndIf

	IncProc()
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ValidValor  ³ Autor ³ Robson Nayland       ³ Data ³20.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o valor do adiantamento com o valor do contrato.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidValor                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValidValor(nVlAdianta,lRetVl)
Local cQuery    := ""
Local cAliasCNX := GetNextAlias()     
//Previsao Financeira
Local lValor := (Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_VLRPRV") $ "1 ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida adiantamentos existentes                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SUM(CNX.CNX_VLADT) AS CNX_VLADT "
cQuery += "  FROM "+RetSQLName("CNX")+" CNX "
cQuery += " WHERE CNX.CNX_FILIAL = '"+xFilial("CNX")+"'"
cQuery += "   AND CNX.CNX_CONTRA = '"+CN9->CN9_NUMERO+"'"
cQuery += "   AND CNX.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNX,.F.,.T.)

TCSetField(cAliasCNX,"CNX_VLADT","N",TamSX3("CNX_VLADT")[1],TamSX3("CNX_VLADT")[2])

IF CN9->CN9_SALDO < nVlAdianta+(cAliasCNX)->CNX_VLADT .And. lValor
  	 Aviso(STR0088,STR0172,{"OK"}) //"Valor do Adiantamento superior ao saldo do Contrato"
    lRetVl:=.F.
Else 
    lRetVl:=.T.    
Endif

Return(nVlAdianta,lRetVl) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³31/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()     
PRIVATE aRotina	:= { 	{ OemToAnsi(STR0002), "AxPesqui"	    	, 0, 1, 0, .F.},;	//"Pesquisar"
			 					{ OemToAnsi(STR0003), "CN100Manut"		, 0, 2, 0, NIL},; //"Visualizar"
								{ OemToAnsi(STR0007), "CN100Manut"		, 0, 3, 0, NIL},; //"Incluir"
								{ OemToAnsi(STR0004), "CN100Manut"		, 0, 4, 0, NIL},; //"Atualizar"
								{ OemToAnsi(STR0006), "CN100Manut"		, 0, 5, 0, NIL},; //"Excluir"
								{ OemToAnsi(STR0030), "CN100Situac"		, 0, 6, 0, NIL},; //"Situacao"
								{ OemToAnsi(STR0013), "CN100Legenda"	, 0, 7, 0, .F.},; //"Legenda"
								{ OemToAnsi(STR0082), "CN220Aval"   	, 0, 8, 0, NIL},; //"Avaliação"
								{ OemToAnsi(STR0085), "CN240Acesso"    , 0, 8, 0, NIL},; //"Acesso"
								{ OemToAnsi(STR0055), "MsDocument"     , 0, 4, 0, NIL},; //"Conhecimento"
								{ OemToAnsi(STR0114), "CN100CtrRet"    , 0, 4, 0, nil}}  //"Bx. Retenção"

aAdd(aRotina,{ OemToAnsi(STR0153), "CN100EstBx"     , 0, 4, 0, Nil})//"Est. Retenção"
aAdd(aRotina,{ OemToAnsi(STR0118), "CN100CtrAdia"     , 0, 5, 0, Nil})//"Adiantamento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTA100MNU")
	ExecBlock("CTA100MNU",.F.,.F.)
EndIf
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100LdAl  ³ Autor ³ Marcelo Custodio      ³ Data ³05.01.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina generica para preenchimento dos folders              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100LdAl(nExp01,cExp02,aExp03,aExp04,cExp05,aExp06,oExp07  ³±±
±±³          ³           cExp08,aExo09)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao Atual                                        ³±±
±±³          ³ cExp02 - Alias consultado                                   ³±±
±±³          ³ aExp03 - aCols                                              ³±±
±±³          ³ aExp04 - aHeader                                            ³±±
±±³          ³ cExp05 - Condicao where no formato SQL                      ³±±
±±³          ³ aExp06 - Ordem da consulta                                  ³±±
±±³          ³ oExp07 - GetDados                                           ³±±
±±³          ³ cExp08 - Campos nao exibidos no aheader                     ³±±
±±³          ³ aExp09 - Query especifica                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100LdAl(nOpc,cAlias,aCols,aHeader,cWhere,aOrder,oGetDad,aNoFields,cQuery,cSeek,cWhile,cFilCTR)
Local nX        := 0
Local lExec     := (cQuery == NIL)
Local cOrder    := ""

Default aOrder := {}
Default cWhere := ""   
Default cSeek  := ""
Default cWhile := ""
Default cFilCTR:= cFilAnt

acols := {}

dbSelectArea(cAlias)

If nOpc != 3
	If lExec
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Query  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT "+ cAlias +".* FROM "+ RetSQLName(cAlias) + " " + cAlias + " WHERE "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra filial ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += cAlias+"."+cAlias+"_FILIAL = '"+xFilial(cAlias,cFilCTR)+"' AND "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica condicao Where ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cWhere)
			cQuery += cWhere + " AND "
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra refistros deletados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += cAlias+".D_E_L_E_T_ = ' ' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta ordem dos registros  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aOrder) > 0
			For nX:=1 to len(aOrder)
				cOrder += aOrder[nX]+","
			next
			cQuery += "ORDER BY " + SubStr(cOrder,1,len(cOrder)-1)
		EndIf
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpc,cAlias,1,cSeek,{|| &cWhile },{|| .T. },aNoFields,,,cQuery,,,If(len(aHeader)>0,NIL,aHeader),aCols)
Else
	FillGetDados(nOpc,cAlias,1,,,,aNoFields,,,,,.T.,aHeader,aCols)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a getdados com os cronogramas contabeis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oGetDad != Nil
	oGetDad:aCols := acols
	oGetDad:oBrowse:Refresh()
	oGetDad:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Contab³ Autor ³ Marcelo Custodio      ³ Data ³17.04.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Contabiliza a emissao do contrato                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Contab()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100Contab(cPadrao)

LOCAL aArea     := GetArea()
LOCAL aCtbDia	:= {}

LOCAL cLoteCtb  := ""

LOCAL lDigita   := If(MV_PAR02==1,.T.,.F.)                           
LOCAL lPadrao   := .F.

LOCAL nHdlPrv   := 0
LOCAL nTotal    := 0

Private cArquivo := " "

dbSelectArea("CN9")
dbSetOrder(1)

lPadrao := VerPadrao(cPadrao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento Contabil³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lPadrao .and. MV_PAR01 == 1 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero do lote contabil                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	dbSetOrder(1)
	If MsSeek(xFilial()+"09GCT")
		cLoteCtb := AllTrim(X5Descri())
	Else
		cLoteCtb := "GCT "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o execblock                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At(UPPER("EXEC"),X5Descri()) > 0
		cLoteCtb := &(X5Descri())
	EndIf
	
	nHdlPrv := HeadProva(cLoteCtb,"CNTA100",Substr(cUsuario,7,6),@cArquivo)
	nTotal  += DetProva(nHdlPrv,cPadrao,"CNTA100",cLoteCtb)
	RodaProva(nHdlPrv,nTotal)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para Lancamento Contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "PTG"
		aCtbDia := {{"CN9",CN9->(RECNO()),CN9->CN9_DIACTB,"CN9_NODIA"}}
	Else
	    aCtbDia := {}
	EndIF    
	cA100Incl(cArquivo,nHdlPrv,3,cLoteCtb,lDigita,.F.,,,,,,aCtbDia)
EndIf

RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100EnVl  ³ Autor ³ Marcelo Custodio      ³ Data ³26.04.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Trata campo do valor                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100EnVl()
Local lRet := .F.

If !Empty(M->CN9_TPCTO) .And. (CN1->(FieldPos("CN1_CTRFIX")) > 0)
	dbSelectArea("CN1")
	dbSetOrder(1)
	
	If dbSeek(xFilial("CN1")+M->CN9_TPCTO)
		lRet := (CN1->CN1_CTRFIX == "2" .And. CN1->CN1_VLRPRV $ "1 ")
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN100VldBx³ Autor ³ Marcelo Custodio      ³ Data ³05/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o valor informado na baixa das caucoes de retencao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN100VldBx()
Local lRet    := .T.                        
Local aCols   := o:OMOTHER:ACOLS
Local aHeader := o:OMOTHER:aHeader
Local nAt     := o:nAt
Local nPosBx  := aScan(aHeader,{|x| x[2]==FLD_BAIXA})
Local nPosSld := aScan(aHeader,{|x| x[2]==FLD_SALDO})
Local nPosVl  := aScan(aHeader,{|x| x[2]=="CNT_VLRET"})
Local nPosVlb := aScan(aHeader,{|x| x[2]=="CNT_VLBX"})
Local nx
Local uRet	  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor informado na baixa, e inferior ao saldo da retencao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (M->BAIXA <= (aCols[nAt,nPosVl]-aCols[nAt,nPosVlb]))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica baixa parcial no Ponto de Entrada Cn100BxRet					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCn100BxRet
	lRet := M->BAIXA = aCols[nAt,nPosVl]
	If !lRet
		Aviso(STR0088,STR0184,{"Ok"}) // Ao utilizar o Ponto de Entrada CN100BXRET a baixa não pode ser parcial	
	Endif
Endif

//Ponto de entrada para validacao da baixa
If lRet .And. ExistBlock("CN100VBAIX")
	uRet := ExecBlock("CN100VBAIX",.F.,.F.,{M->BAIXA,aCols,aHeader})
	If Valtype(uRet) == "L"
		lRet := uRet
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza saldo     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nAt,nPosSld] := (aCols[nAt,nPosVl]-aCols[nAt,nPosVlb])-M->BAIXA
	nTotBaix := 0
	For nx:=1 to len(aCols)
		If nx==nAt
			nTotBaix+=Round(M->BAIXA,TamSX3("CNT_VLRET")[2])
		Else
			nTotBaix+=Round(aCols[nx,nPosBx],TamSX3("CNT_VLRET")[2])
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza objetos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
o:Refresh()
oTotBaix:Refresh()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldCli³ Autor ³ Felipe Toledo         ³ Data ³16.04.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida cliente no contrato de Venda                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldCli()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldCli()
Local lRet		:= .T. 

If  M->CN9_CLIENT == Nil .Or. Empty(M->CN9_CLIENT) 
 	M->CN9_LOJACL := '' 
EndIf 

If !Empty(M->CN9_CLIENT)                      
	dbSelectArea("SA1")
	dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
	If M->CN9_LOJACL == Nil .Or. Empty(M->CN9_LOJACL)
		If dbSeek(xFilial("SA1")+M->CN9_CLIENT)   //Verifica se cliente existe
	    	M->CN9_LOJACL := SA1->A1_LOJA  
	    Else
	    	Help("  ",1,"REGNOIS")
	    	lRet := .F.		
	 	EndIf
 	EndIf
EndIf

If !Empty(M->CN9_CLIENT) .and. !Empty(M->CN9_LOJACL)
	lRet := ExistCpo("SA1",M->CN9_CLIENT+M->CN9_LOJACL)   //Verifica se cliente e loja existe
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldLojCli³ Autor ³ Felipe Toledo      ³ Data ³16.04.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida loja do cliente no contrato de Venda                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldLojCli()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldLojCli()
Return(CN100VldCli())

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100GrvCNY³ Autor ³ Felipe Bittar        ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua gravacao da tabela de baixa de retenção             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100GrvCNY(cContra,cRevisa,cCodigo,cLoja,nValor,cNumTit,cRetPrf,cParcela,cTpTit,cNumed)
Local aArea	:= GetArea()
Local cFilCod	:= xFilial("CNY")
Local cEspCtr	:= ""

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

DbSelectArea("CNY")

If nValor > 0
	RecLock("CNY",.T.)
		CNY->CNY_FILIAL := cFilCod
		CNY->CNY_CONTRA := cContra
		CNY->CNY_REVISA := cRevisa
		CNY->CNY_NUMMED := cNumed
		CNY->CNY_VLBAIX := Round(nValor,TamSX3("CNY_VLBAIX")[2])
		CNY->CNY_NUMTIT := cNumTit
		CNY->CNY_PREFIX := cRetPrf
		CNY->CNY_PARCEL := cParcela
		CNY->CNY_TIPO   := cTpTit
		If cEspCtr == "1"
			CNY->CNY_FORNEC := cCodigo
			CNY->CNY_LOJA	  := cLoja
		Else
			CNY->CNY_CLIENT := cCodigo
			CNY->CNY_LOJACL := cLoja
		EndIf
	MsUnLock()
EndIf

RestArea(aArea)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100EstBx ³ Autor ³ Felipe Bittar        ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua estorno da baixa de retencao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100EstBx()                                        

Local oDlg
Local oOk		 := LoadBitmap( GetResources(), "LBTIK" )
Local oNo		 := LoadBitmap( GetResources(), "LBNO" )

Local lRet       := .T.

Local nOpca		 := 0

Local cQuery	 := ""
Local cTpTit     := ""
Local cNumTit    := ""
Local cParcela   := ""
Local cRetPrf    := ""
Local cForn		 := ""
Local cLoja		 := ""
Local cClient    := ""
Local cLjCli     := ""
Local cLine      := ""
Local cArqTit    := ""
Local cEspCtr	 := "1"
Local cTpPref    := PadR( GetNewPar( "MV_CNRETPR", "CRE" ), Len( SE2->E2_PREFIXO ) )//Prefixo
Local cAliasQry

Local aStruTit   := {}
Local aCampos    := {}
Local aTitle     := {}

Local lCN100EsRet:= ExistBlock("CN100ESR")   
Local aRet       := {}
Local nx         := 0

If ExistBlock("CNTRETPR")
	cTpPref := If(ValType(cNewPref:=ExecBlock("CNTRETPR",.F.,.F.))=="C",PADR(cNewPref,Len(SE2->E2_PREFIXO)),cTpPref)
EndIf

If !CN240VldUsr(CN9->CN9_NUMERO,DEF_TRARET,.T.)
	lRet := .F.
EndIf

//Veririca se o contrato possui configuração de caução de retenção
If !(CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "2")
	lRet := .F.
EndIf

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

If lRet
	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao executa processo de estorno padrao quando o PE CN100ESR ³
	//³estiver compilado                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCN100EsRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria Dialog para selecao do titulo                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0148) From 74,7 TO 320,500 PIXEL//"Estorno de Baixa de Retenção - Títulos de Retenção do Contrato"
		
		If cEspCtr == "1"
			aAdd(aStruTit,{"E2_NUM","C",TamSX3("E2_NUM")[1],TamSX3("E2_NUM")[2]})
			aAdd(aStruTit,{"E2_VALOR","N",TamSX3("E2_VALOR")[1],TamSX3("E2_VALOR")[2]})
			aAdd(aStruTit,{"E2_TIPO","C",TamSX3("E2_TIPO")[1],TamSX3("E2_TIPO")[2]})
		Else
			aAdd(aStruTit,{"E1_NUM","C",TamSX3("E1_NUM")[1],TamSX3("E1_NUM")[2]})
			aAdd(aStruTit,{"E1_VALOR","N",TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2]})
			aAdd(aStruTit,{"E1_TIPO","C",TamSX3("E1_TIPO")[1],TamSX3("E1_TIPO")[2]})	
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria arquivo temporario                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqTit := CriaTrab(aStruTit)
		dbUseArea(.T.,,cArqTit,"TRBTIT",.F.,.F.)	
		CN100TrbTit(CN9->CN9_NUMERO,cEspCtr,cTpPref)
		
		If cEspCtr == "1"
			aTitle  := {"",RetTitle("E2_NUM"),RetTitle("E2_VALOR"),RetTitle("E2_TIPO")}
			aCampos := {"",TRBTIT->E2_NUM,TRBTIT->E2_VALOR,TRBTIT->E2_TIPO}
			cLine   := "{If((cNumTit==(TRBTIT->E2_NUM)),oOk,oNo),TRBTIT->E2_NUM,Transform(TRBTIT->E2_VALOR,PesqPict('SE2','E2_VALOR')),TRBTIT->E2_TIPO}"
		
			oBrowse := TWBrowse():New( 4, 4,__DlgWidth(oDlg)-5,__DlgHeight(oDlg)-30, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBTIT", .T. )
			oBrowse:bLine := &( "{ || " + cLine + " }" )
			oBrowse:bLDblClick := {|| If(!Empty(TRBTIT->E2_NUM),((cNumTit := TRBTIT->E2_NUM), oBrowse:Refresh()),) }
		Else
			aTitle  := {"",RetTitle("E1_NUM"),RetTitle("E1_VALOR"),RetTitle("E1_TIPO")}
			aCampos := {"",TRBTIT->E1_NUM,TRBTIT->E1_VALOR,TRBTIT->E1_TIPO}
			cLine   := "{If((cNumTit==(TRBTIT->E1_NUM)),oOk,oNo),TRBTIT->E1_NUM,Transform(TRBTIT->E1_VALOR,PesqPict('SE1','E1_VALOR')),TRBTIT->E1_TIPO}"
		
			oBrowse := TWBrowse():New( 4, 4,__DlgWidth(oDlg)-5,__DlgHeight(oDlg)-30, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBTIT", .T. )
			oBrowse:bLine := &( "{ || " + cLine + " }" )
			oBrowse:bLDblClick := {|| If(!Empty(TRBTIT->E1_NUM),((cNumTit := TRBTIT->E1_NUM), oBrowse:Refresh()),) }	
		EndIf
		
		DEFINE SBUTTON FROM __DlgHeight(oDlg)-24,__DlgWidth(oDlg)-70 When .T. TYPE 1 ACTION (if(Empty(cNumTit),Aviso(STR0088,STR0149,{"OK"}),(oDlg:End(),nOpca:=1))) ENABLE OF oDlg//"Não há títulos selecionados para estorno."
		DEFINE SBUTTON FROM __DlgHeight(oDlg)-24,__DlgWidth(oDlg)-30 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:=2) ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apaga arquivo temporario                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TRBTIT->(dbCloseArea())
		FErase(cArqTit + ".DBF")
		FErase(cArqTit + OrdBagExt() )
			
		If nOpca == 1 .And. !Empty(cNumTit)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CNY - Baixas de Retencao             				 		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CNY")
			
			cAliasQry := GetNextAlias()
			
			cQuery := "SELECT CNY.*, CNY.R_E_C_N_O_ as RECNO "
			cQuery += "  FROM "+RetSQLName("CNY")+" CNY "
			cQuery += " WHERE CNY.CNY_FILIAL = '"+xFilial("CNY")+"'"
			cQuery += "   AND CNY.CNY_NUMTIT = '"+cNumTit+"'"
			cQuery += "   AND CNY.CNY_PREFIX = '"+cTpPref+"'"
			cQuery += "   AND "		
			If cEspCtr == "1"
				cQuery += "CNY.CNY_CLIENT = '' AND "
			Else
				cQuery += "CNY.CNY_FORNEC = '' AND "
			EndIf
			cQuery += "CNY.D_E_L_E_T_ = ' '"
				
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
			TCSetField(cAliasQry,"CNY_VLBAIX" ,"N",TamSX3("CNY_VLBAIX")[1],TamSX3("CNY_VLBAIX")[2])
			
			If !(cAliasQry)->(Eof())
				//Armazena informacoes do titulo a deletar
				cRetPrf := (cAliasQry)->CNY_PREFIX
				cParcela:= (cAliasQry)->CNY_PARCEL
				cTpTit  := (cAliasQry)->CNY_TIPO
				If cEspCtr == "1"
					cForn   := (cAliasQry)->CNY_FORNEC
					cLoja   := (cAliasQry)->CNY_LOJA
				Else
					cClient := (cAliasQry)->CNY_CLIENT
					cLjCli  := (cAliasQry)->CNY_LOJACL			
				EndIf
				
				While !(cAliasQry)->(Eof())
				
					//Apaga registro de baixa da retencao
					CNY->(dbGoTo((cAliasQry)->RECNO))
					RecLock("CNY",.F.)
						dbDelete()
					MsUnlock()
						
					//Devolve o saldo no registro de caucoes retidas
					DbSelectArea("CNT")
					DbSetOrder(1)
					If DbSeek(xFilial("CNT")+CN9->CN9_NUMERO+(cAliasQry)->CNY_NUMMED)
						RecLock("CNT",.F.)           
							CNT->CNT_DTBX := CTOD("  /  /  ")
							CNT->CNT_VLBX := CNT->CNT_VLBX - (cAliasQry)->CNY_VLBAIX			
						MsUnLock()		
					EndIf
					
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				
				//Apaga o tiulo estornado no financeiro
				If cEspCtr == "1"
					DbSelectArea("SE2")
					DbSetOrder(1)
					If DbSeek(xFilial("SE2")+cRetPrf+cNumTit+cParcela+cTpTit+cForn+cLoja)
						RecLock("SE2",.F.)
							DbDelete()
							FaAvalSE2(2,"CNTA100")
							FaAvalSE2(3,"CNTA100")
						MsUnLock()		
					EndIf
				Else
					DbSelectArea("SE1")
					DbSetOrder(2)
					If DbSeek(xFilial("SE1")+cClient+cLjCli+cRetPrf+cNumTit+cParcela+cTpTit)
						RecLock("SE1",.F.)
							DbDelete()
							FaAvalSE1(2,"CNTA100")
							FaAvalSE1(3,"CNTA100")
						MsUnLock()		
					EndIf			
				EndIf
			
				Aviso(STR0152,OemToAnsi(STR0150)+cNumTit+OemToAnsi(STR0151),{"OK"})//"Estorno de Baixa de Retenção"//"O título "######" foi estornado com sucesso."						
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno esperado do PE:                                                   ³
		//³ aRet[1] - Informa se o estorno foi realizado com sucesso                  ³
		//³ aRet[2] - Array contendo as retencoes estornadas, e os respectivos valores³
		//³   aRet[2,1] - Array contendo o codigo da primeira retencao e o valor      ³
		//³     aRet[2,1,1] - Contem o codigo da medicao                              ³
		//³     aRet[2,1,2] - Contem o valor estornado                                ³
		//³   aRet[2,2] - Array contendo o codigo da segunda retencao e o valor       ³
		//³     aRet[2,2,1] - Contem o codigo da medicao                              ³
		//³     aRet[2,2,2] - Contem o valor estornado                                ³
		//³   ...                                                                     ³
		//³   aRet[2,x] - Estrutura criada para cada retencao estornada               ³
		//³     aRet[2,x,1] - Contem o codigo da medicao                              ³
		//³     aRet[2,x,2] - Contem o valor estornado                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := ExecBlock("CN100ESR",.F.,.F.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o retorno  		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If valtype(aRet) == "A" .And. len(aRet) == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o estorno foi realizado com sucesso ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If valtype(aRet[1]) == "L"
				lRet := aRet[1]
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza as retencoes que foram estornadas no PE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If lRet .And. valtype(aRet[2]) == "A"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Percorre as retencoes ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nx:=1 to len(aRet[2])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valida o retorno do PE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If len(aRet[2,nx]) == 2 .And. valtype(aRet[2,nx,1]) == "C" .And. valtype(aRet[2,nx,2]) == "N"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona na retencao e executa o estorno do valor ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNT")
						DbSetOrder(1)
						If DbSeek(xFilial("CNT")+CN9->CN9_NUMERO+aRet[2,nx,1])
							RecLock("CNT",.F.)  
								CNT->CNT_DTBX := CTOD("  /  /  ")
								CNT->CNT_VLBX := 0		
							MsUnLock()		
						EndIf
						DbSelectArea("CNY")
						CNY->(DbSetOrder(1))
						If CNY->(DbSeek(xFilial("CNY")+aRet[2,nx,1]))
							RecLock("CNY",.F.)
							CNY->(DbDelete())
							CNY->(MsUnLock())
						Endif								
					EndIf
				Next
			EndIf
		EndIf
	EndIf
Else
	Aviso(STR0088,STR0112,{"OK"})//"O contrato selecionado não possui caução de retenção."
EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100TrbTit³ Autor ³ Felipe Bittar        ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arquivo de trabalho com os titulos de retencao do  ³±±
±±³          ³ contrato                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                
Function CN100TrbTit(cContra,cEspCtr,cTpPref)

Local cAlias
Local cTpTit := ""
Local cQuery := ""

Local aArea  := GetArea()

If cEspCtr == "1"

	cTpTit := PadR( GetNewPar( "MV_CNRETTC",  "NDF" ), Len( SE2->E2_TIPO ) )//Tipo do titulo - PADRAO: Nota de Debito ao Fornecedor

	dbSelectArea("SE2")
	dbSetOrder(1)	
	cAlias := GetNextAlias()	
	cQuery := "SELECT SE2.E2_NUM, SE2.E2_VALOR, SE2.E2_TIPO, SE2.E2_MDCONTR "
	cQuery += "  FROM "+RetSQLName("SE2")+" SE2 "
	cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2")+"'"
	cQuery += "   AND SE2.E2_MDCONTR = '"+cContra+"'"
	cQuery += "   AND SE2.E2_TIPO    = '"+cTpTit+"'"
	cQuery += "   AND SE2.E2_PREFIXO = '"+cTpPref+"'"
	cQuery += "   AND SE2.E2_VALOR   = SE2.E2_SALDO "
	cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SE2.E2_NUM"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	
	TCSetField(cAlias,"E2_VALOR" ,"N",TamSX3("E2_VALOR")[1],TamSX3("E2_VALOR")[2])
Else
	cTpTit := PadR( GetNewPar( "MV_CNRETTV",  "NCC" ), Len( SE1->E1_TIPO ) )//Tipo do titulo - PADRAO: NCC

	dbSelectArea("SE1")
	dbSetOrder(2)	
	cAlias := GetNextAlias()	
	cQuery := "SELECT SE1.E1_NUM, SE1.E1_VALOR, SE1.E1_TIPO, SE1.E1_MDCONTR "
	cQuery += "  FROM "+RetSQLName("SE1")+" SE1 "
	cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
	cQuery += "   AND SE1.E1_MDCONTR = '"+cContra+"'"
	cQuery += "   AND SE1.E1_TIPO    = '"+cTpTit+"'"
	cQuery += "   AND SE1.E1_PREFIXO = '"+cTpPref+"'"
	cQuery += "   AND SE1.E1_VALOR   = SE1.E1_SALDO "
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SE1.E1_NUM"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	
	TCSetField(cAlias,"E1_VALOR" ,"N",TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa arquivo temporario           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRBTIT")
If RecCount() > 0
	Zap
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Copia titulos filtradas para arquivo temporario   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (cAlias)->(!Eof())
	RecLock("TRBTIT",.T.)
		If cEspCtr == "1"
			TRBTIT->E2_NUM		:= (cAlias)->E2_NUM
			TRBTIT->E2_VALOR	:= (cAlias)->E2_VALOR
			TRBTIT->E2_TIPO		:= (cAlias)->E2_TIPO
		Else
			TRBTIT->E1_NUM		:= (cAlias)->E1_NUM
			TRBTIT->E1_VALOR	:= (cAlias)->E1_VALOR
			TRBTIT->E1_TIPO		:= (cAlias)->E1_TIPO	
		EndIf
	MsUnlock()
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())
TRBTIT->(dbGoTop())

RestArea(aArea)
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³cn100Vld   ³ Autor ³Aline Sebrian Damasceno³ Data ³18/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo CN1_CODIGO			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Static Function cnt100VTP()   
Local lRet        := .T.
Local lCN100VTP   := .T.  
  
If ExistBlock("CN100VTP")
	lCN100VTP := Execblock("CN100VTP",.F.,.F.)
	If ValType(lCN100VTP) == "L" .And. !lCN100VTP
		lRet := .F.
	EndIf 
EndIf  

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³cn100VerFor³ Autor ³Aline Sebrian Damasceno³Data ³29/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe fornecedor cadastrado na grid do folder  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN100VerFor()
Local nI
Local nPosForn := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_CODIGO"})
Local nPosLoja := aScan(aheader1,{|x| AllTrim(x[2]) == "CNC_LOJA"})
Local lRet     := .T.


If Len(oGetDad1:aCols) == 1 .And. Empty(oGetDad1:aCols[1,nPosForn]) .And. Empty(oGetDad1:aCols[1,nPosForn])
	Help(" ",1,"CNTA100FOR") //"Inclua ao menos um fornecedor no contrato"
	lRet := .F.
Else
	nI := 1
	//Verifica itens deletados
	while nI <= len(oGetDad1:aCols) .And. oGetDad1:aCols[nI][len(ogetDad1:aHeader)+1]
		nI++
	EndDo
	
	If nI > len(oGetDad1:aCols)
		Help(" ",1,"CNTA100FOR") //"Inclua ao menos um fornecedor no contrato"
		lRet := .F.
	EndIf
EndIf
Return lRet

  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100PlAtu ³ Autor ³Aline Sebrian Damasceno³Data  ³04/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a planilha do contrato							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN100PlAtu()
Local dTermino := CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)

dbSelectArea("CNA") 
				
cAliasQry := GetNextAlias()
cQuery := "SELECT R_E_C_N_O_ as RECNO "
cQuery += "  FROM "+RetSQLName("CNA")+" CNA "
cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"' "
cQuery += "   AND CNA.CNA_CONTRA = '"+CN9->CN9_NUMERO+"' "
cQuery += "   AND CNA.CNA_REVISA = '"+CN9->CN9_REVISA+"' "
cQuery += "   AND CNA.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )
		
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
	
While !(cAliasQry)->(Eof())	
	CNA->(dbGoTo((cAliasQry)->RECNO))
	RecLock("CNA",.F.)
		If M->CN9_CLIENT<>CNA->CNA_CLIENT .Or. M->CN9_LOJACL<>CNA->CNA_LOJACL  
			CNA->CNA_CLIENT := M->CN9_CLIENT
			CNA->CNA_LOJACL := M->CN9_LOJACL
		EndIF    
		If dTermino < CNA->CNA_DTFIM 
			CNA->CNA_DTFIM := dTermino
		EndIf
	MsUnlock()
	(cAliasQry)->(dbSkip())
EndDo
				
(cAliasQry)->( dbCloseArea() )
				
CNA->(FKCommit()) 

  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100VldPla³ Autor ³Aline Sebrian Damasceno³Data  ³13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o numero do contrato nas planilhas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN100VldPla(aPlani)
Local lRet    := .T.
Local lConCNA := aScan(aPlani,{|x| AllTrim(x[2]) <> AllTrim(M->CN9_NUMERO)})<>0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se numero do contrato esta diferente ao da planilha    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lConCNA
	Help(" ",1,"CNTA100COP") //"Número do contrato cadastrado divergente da planilha."
	lRet := .F.
EndIf 

Return lRet

  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100VerNf ³ Autor ³Aline Sebrian Damasceno³Data  ³19/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se tem medicoes em aberto ou sem NF amarrada	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±   
±±³Sintaxe   ³ CN100LdAl(cExp01,cExp02)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Numero do Contrato                                ³±±
±±³          ³ cExp02 - Numero da Revisao do Contrato                     ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN100VerNf(cContra,cRevisa)
Local lRet      := .T.
Local lCNVerNF  := (GetNewPar( "MV_CNVERNF" ,  "N" ) == "S")
Local cQuery    := ''
Local cAliasCNE := ''            
Local cEspCtr   := ""

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

If lCNVerNF

	cAliasCNE := GetNextAlias()   

	cQuery := "SELECT CNE_PEDIDO, CNE.* " 
	cQuery += "  FROM "+ RetSQLName("CNE")+" CNE " 
	cQuery += " WHERE CNE.CNE_FILIAL = '" +xFilial("CNE")+"'"
	cQuery += "   AND CNE.CNE_CONTRA = '" +cContra+"'"
	cQuery += "   AND CNE.CNE_REVISA = '" +cRevisa+"'"
	cQuery += "   AND CNE.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasCNE, .T., .T. )
           
	While !(cAliasCNE)->(Eof())	    
			If Empty((cAliasCNE)->CNE_PEDIDO)       
				Aviso("CNTA100",OemtoAnsi(STR0156),{"Ok"})
			    lRet:= .F.
			    Exit
			EndIf          
			If cEspCtr == "1"
				cAliasSD1 := GetNextAlias()   
				cQuery := "SELECT D1_PEDIDO, SD1.* "
				cQuery += "  FROM "+ RetSQLName("SD1")+" SD1 " 
				cQuery += " WHERE SD1.D1_FILIAL  = '" +xFilial("SD1")+"'"
				cQuery += "   AND SD1.D1_PEDIDO  = '" +(cAliasCNE)->CNE_PEDIDO+ "'"
				cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
				
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasSD1, .T., .T. )
			
		   		If (cAliasSD1)->(Eof()) 
			   		Aviso("CNTA100",OemtoAnsi(STR0157),{"Ok"})
		   			lRet := .F.
		   			Exit	   		
		   		EndIf         
		   		
				(cAliasSD1)->( dbCloseArea() )	  
			Else
				cAliasSD2 := GetNextAlias()   
				cQuery := "SELECT D2_PEDIDO, SD2.* "
				cQuery += "  FROM "+ RetSQLName("SD2")+" SD2 " 
				cQuery += " WHERE SD2.D2_FILIAL  = '" +xFilial("SD2")+"'"
				cQuery += "   AND SD2.D2_PEDIDO  = '" +(cAliasCNE)->CNE_PEDIDO+ "'" 
				cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
				
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasSD2, .T., .T. )
	  		
		   		If (cAliasSD2)->(Eof()) 
			   		Aviso("CNTA100",OemtoAnsi(STR0158),{"Ok"})
		   			lRet := .F.
		   			Exit	   		
		   		EndIf         
		   		
				(cAliasSD2)->( dbCloseArea() )	  
			EndIf
			(cAliasCNE)->( dbSkip() )			              
	EndDo			
	(cAliasCNE)->( dbCloseArea() )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100TES   ³ Autor ³Julio C.Guerato		 ³Data  ³12/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar a Tes Entrada / Saida de acordo com o tipo de 	  ³±±
±±³			 ³ contrato compra / venda. Chamada pelo gatilho do campo	  ³±±
±±³			 ³ CNB_PRODUT												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN100TES(cTipo)
Local cTES := ""

If cTipo == "E" .And. If(CN9->(FieldPos("CN9_ESPCTR")) > 0,CN9->CN9_ESPCTR == '1',Empty(CN9->CN9_CLIENT))
	cTES := SB1->B1_TE
EndIf
 
If cTipo == "S" .And. If(CN9->(FieldPos("CN9_ESPCTR")) > 0,CN9->CN9_ESPCTR == '2',!Empty(CN9->CN9_CLIENT))
	cTES := SB1->B1_TS
EndIf

Return cTES

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100JOB   ³ Autor ³Andre Lago			 ³Data  ³28/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executada atraves de JOB para transferir para situacao  	  ³±±
±±³			 ³ vigente de acordo com a data de vigencia futura			  ³±±
±±³			 ³ CN9_DTVIGE												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN100JOB()

Local lMedeve
Local lValor
Local lCaucao
Local lFisico
Local lFixo
Local lContab
Local nPCauc := 0
Local cFilCod := ""
Local lRet := .T.
Local nMotPlan := 0
Local nTotPlan := 0
Local nMotCron := 0 
Local nMotCauc := 0      
Local nMotCrCt := 0
Local cQuery := ""
Local cAliasQry := ""
Local aEmpresas := {}
Local nx
Local cLctoVige := "694"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mostra Lancamentos   S/N                          ³
//³ mv_par02 - Aglut Lancamentos    S/N                          ³
//³ mv_par03 - Lancamentos Online   S/N                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mv_par01 := 2 //- Mostra Lancamentos   S/N                          ³
mv_par02 := 2 //- Aglut Lancamentos    S/N                          ³
mv_par03 := 2 //- Lancamentos Online   S/N                          ³

	OpenSm0()
	While SM0->(!Eof())
		Aadd(aEmpresas, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		SM0->(DbSkip())
	End
	nLen := Len(aEmpresas)
	
	For nX := 1 To nLen	
	   // Preparar ambiente
	   RpcSetType(3) //para nao usar licenca.
	   RpcSetEnv(aEmpresas[nX,1],aEmpresas[nX,2],,'GCT')   	
		//Inicio do processamento
		
		dDataAssi := dDataBase
		
		dbSelectArea("CN9")
		dbSetOrder(1)
		dbGoTop()
		
		If !(CN9->(FieldPos("CN9_DTVIGE")) > 0)
		
			ConOut(STR0165 + aEmpresas[nX,1] + STR0166 + aEmpresas[nX,2] + STR0167) //"Job não executado para a Empresa " ## " / Filial " ## " ! É preciso executar o Atualizar CNTAUPD33."
			
		Else		
		
			While !eof()
	         lRet := .T.
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica situação atual do contrato                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (AllTrim(CN9->CN9_SITUAC) == DEF_SELAB .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SEMIT .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SAPRO) .and. !Empty(CN9->CN9_DTVIGE) .and. CN9->CN9_DTVIGE <= dDataBase + 1
					//Medicao Eventual
					lMedeve := (Posicione("CN1",1,xFilial("CN1")+CN9_TPCTO,"CN1_MEDEVE") == "1")
									
					//Previsao Financeira
					lValor := (Posicione("CN1",1,xFilial("CN1")+CN9_TPCTO,"CN1_VLRPRV") $ "1 ")
									
					//Controla ou nao caucao
					lCaucao := (CN9->CN9_FLGCAU == "1" .And. If((CN9->(FieldPos("CN9_TPCAUC")) > 0),(CN9->CN9_TPCAUC == "1"),.T.))
					
					//Controla ou nao cronograma fisico
					lFisico := (CN1->CN1_CROFIS = "1")
					
					//Controla ou nao planilhas
					If (CN1->(FieldPos("CN1_CTRFIX")) > 0)
						lFixo := Empty(CN1->CN1_CTRFIX) .Or. CN1->CN1_CTRFIX = "1"
					EndIf
					
					//Controla ou nao contabil
					lContab := (Posicione("CN1",1,xFilial("CN1")+CN9_TPCTO,"CN1_CROCTB") == "1")
					                
					If lCaucao
						nPCauc := CN9->CN9_MINCAU//Percentual minimo de caucao
					EndIf 
								
					If lFixo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica planilhas do contrato                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNA")
						dbSetOrder(1)
						cFilCod := xFilial("CNA")
						dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
										
						While CNA->CNA_FILIAL = cFilCod .And. CNA->CNA_CONTRA = CN9->CN9_NUMERO .And. CNA->CNA_REVISA = CN9->CN9_REVISA
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica cronograma da planilha se o contrato      ³
							//³ nao for de medicao eventual                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !lMedeve .And. Empty(CNA->CNA_CRONOG)
								Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato " ## "Revisao"
								Conout("Help CNTA100PLA - "+STR0024) //"Todas as planilhas devem pertencer a um cronograma"
								lRet := .F.
								Exit
							Else
								//Soma montante das planilhas
								nMotPlan+=CNA->CNA_VLTOT
							EndIf
							nTotPlan++
							dbSkip()
						EndDo
					EndIf
								
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica contrato fixo/variavel                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("CN100FIX")
						lFixo := ExecBlock("CN100FIX",.F.,.F.)
						if Type("lFixo") <> "L"
							lFixo := .T. // o Contrato é do tipo Fixo
						endif
					endif
								
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o contrato possui planilhas            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. nTotPlan == 0 .and. lFixo
						Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
						Conout("Help CNTA100POP - "+STR0025) //O contrato nao possui planilhas"
						lRet := .F.
					EndIf
								
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica cronogramas se nao for medicao eventual   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if lRet .And. !lMedeve
								
						If !lFisico	
							dbSelectArea("CNF")
							dbSetOrder(2)
							cFilCod := xFilial("CNF")
							dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
										
							while CNF->CNF_FILIAL = cFilCod .And. CNF->CNF_CONTRA = CN9->CN9_NUMERO .And. CNF->CNF_REVISA = CN9->CN9_REVISA
								//Soma montante dos cronogramas
								nMotCron+=CNF->CNF_VLPREV
								dbSkip()
							EndDo           
					
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Arredonda valores totais de cronograma e planilha    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
							nMotCron := Round(nMotCron,TamSX3("CNF_VLPREV")[2])
							nMotPlan := Round(nMotPlan,TamSX3("CNA_VLTOT")[2])
										
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica montante dos cronogramas contra montante    ³
							//³ das planilhas                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nMotPlan != nMotCron
								Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
								Conout("Help CNTA100MON - "+STR0168) //"O montante das planilhas nao equivale ao montante dos cronogramas"
								lRet := .F.
							EndIf
						Else
							cAliasQry := GetNextAlias()
			
							cQuery := "SELECT CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM,SUM(CNS.CNS_PRVQTD) AS CNS_PRVQTD "
							cQuery += "  FROM "+ RetSQLName("CNS") +" CNS "
							cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
							cQuery += "   AND CNS.CNS_CONTRA = '"+CN9->CN9_NUMERO+"'"
							cQuery += "   AND CNS.CNS_REVISA = '"+CN9->CN9_REVISA+"'"
							cQuery += "   AND CNS.D_E_L_E_T_ = ' ' "
							cQuery += " GROUP BY CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM"
									
							cQuery := ChangeQuery( cQuery )			
							dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
				
							TCSetField( cAliasQry, "CNS_PRVQTD", "N", TamSX3("CNS_PRVQTD")[1], TamSX3("CNS_PRVQTD")[2] )
										
							dbSelectArea("CNB")
							dbSetOrder(1)
										
							cFilCod := xFilial("CNB")
							While !(cAliasQry)->(Eof())
								If dbSeek(cFilCod+(cAliasQry)->CNS_CONTRA+(cAliasQry)->CNS_REVISA+(cAliasQry)->CNS_PLANI+(cAliasQry)->CNS_ITEM)
									If CNB->CNB_QUANT != (cAliasQry)->CNS_PRVQTD
										lRet := .F.
										Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
										Conout(STR0088) 																//"Atencao !"
										Conout(STR0143+(cAliasQry)->CNS_ITEM+STR0144+(cAliasQry)->CNS_PLANI+STR0145) 	//"O item " ## " da planilha " ## " possui saldo em aberto para distribuição no cronograma físico."
										Exit
									EndIf
								EndIf
								(cAliasQry)->(dbSkip())
							EndDo
						EndIf
					EndIf
								
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica caucoes quando houver controle              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. lCaucao
						dbSelectArea("CN8")
						dbSetOrder(2)
						cFilCod := xFilial("CN8")
						dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
									
						While CN8->CN8_FILIAL = cFilCod .And. CN8->CN8_CONTRA = CN9->CN9_NUMERO .And. CN8->CN8_REVISA = CN9->CN9_REVISA
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Soma montante das caucoes quando nao estiver baixada ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(CN8_DTBX)
								nMotCauc+=CN8->CN8_VLEFET
							EndIf
							dbSkip()
						EndDo
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica percentual minimo de caucao                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (CN9->CN9_VLINI*nPCauc)/100 > nMotCauc
							Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
							Conout("Help CNTA100MIN - "+STR0027) //"O contrato nao possui o percentual minimo de caucao especificado"
							lRet := .F.
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica valor inicial do contrato se ele for do tipo flexivel e possuir previsao financeira  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. lMedeve .And. !lFixo .And. lValor
						If CN9->CN9_VLINI <= 0
							Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
							Conout(STR0088)	//"Atencao !"
							Conout(STR0146) //"O tipo de Contrato selecionado não permite vigência com valor inicial zerado!"
							lRet := .F.
						EndIf
					EndIf
				Else
					lRet := .F.
				EndIf
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica configuracao contabil das planilhas         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. lContab
					cQuery := "SELECT CNA.CNA_NUMERO "
					cQuery += "  FROM "+ RetSQLName("CNA") +" CNA "
					cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
					cQuery += "   AND CNA.CNA_CONTRA = '"+CN9->CN9_NUMERO+"'"
					cQuery += "   AND CNA.CNA_REVISA = '"+CN9->CN9_REVISA+"'"
					cQuery += "   AND CNA.CNA_CRONCT = '' "
					cQuery += "   AND D_E_L_E_T_     = ' '"
				
					cAliasQry := GetNextAlias()
	
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
								
					If !(cAliasQry)->(Eof())
						Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
						Conout(STR0088) 																//"Atencao !"
						Conout(OemtoAnsi(STR0135)+(cAliasQry)->CNA_NUMERO+OemtoAnsi(STR0136))			//"A planilha " ## " não possui cronograma contábil" 
						lRet := .F.					
					EndIf
					(cAliasQry)->(dbCloseArea())
								
					If lRet
						//Verifica montante das planilhas com o montante dos cronogramas contabeis
						cQuery := "SELECT SUM(CNW_VLPREV) as CNW_VLPREV "
						cQuery += "  FROM "+ RetSQLName("CNW")+" CNW,"+ RetSQLName("CNV")+" CNV,"+ RetSQLName("CNA")+" CNA "
						cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
						cQuery += "   AND CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
						cQuery += "   AND CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
						cQuery += "   AND CNW.CNW_CONTRA = '"+CN9->CN9_NUMERO+"'"
						cQuery += "   AND CNW.CNW_REVISA = '"+CN9->CN9_REVISA+"'"
						cQuery += "   AND CNW.CNW_CONTRA = CNV.CNV_CONTRA "
						cQuery += "   AND CNW.CNW_REVISA = CNV.CNV_REVISA "
						cQuery += "   AND CNW.CNW_NUMERO = CNV.CNV_NUMERO "
						cQuery += "   AND CNV.CNV_CONTRA = CNA.CNA_CONTRA "
						cQuery += "   AND CNV.CNV_REVISA = CNA.CNA_REVISA "
						cQuery += "   AND CNV.CNV_PLANIL = CNA.CNA_NUMERO "
						cQuery += "   AND CNW.D_E_L_E_T_ = ' ' "
						cQuery += "   AND CNV.D_E_L_E_T_ = ' ' "
						cQuery += "   AND CNA.D_E_L_E_T_ = ' '"
				                	
						cAliasQry := GetNextAlias()
				                	
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)					
			                    	
			        	nMotCrCt := (cAliasQry)->CNW_VLPREV
			                    	
			        	(cAliasQry)->(dbCloseArea())
			                    	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Arredonda valores dos cronogramas contabeis          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
						nMotCrCt := Round(nMotCrCt,TamSX3("CNW_VLPREV")[2])
									
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica montante dos cronogramas contra montante    ³
						//³ das planilhas                                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nMotPlan != nMotCrCt
							Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
							Conout(STR0088)			  //"Atencao !"
							Conout(OemtoAnsi(STR0147))//"O montante das planilhas não equivale ao montante dos cronogramas contábeis. Verifique a configuração contábil do contrato!"
							lRet := .F.
						EndIf
					EndIf
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa alteracao quando todas as validacoes estiverem OK ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa contabilizacao do contrato     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					CN100Contab(cLctoVige)
							
					if !Empty(CN9->CN9_DTASSI)
						dDataAssi := CN9->CN9_DTASSI
					EndIf
							
					If lFixo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza data de aniversario dos itens com a data de      ³
						//³ assinatura                                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
						dbSelectArea("CNB")
						dbSetOrder(1)
						cFilCod := xFilial("CNB")
						dbSeek(xFilial("CNB")+CN9->CN9_NUMERO+CN9->CN9_REVISA)
								
						While !CNB->(Eof()) .And. CNB->CNB_FILIAL == cFilCod .And. CNB->CNB_CONTRA == CN9->CN9_NUMERO .And. CNB->CNB_REVISA == CN9->CN9_REVISA
							RecLock("CNB")
								CNB->CNB_DTANIV := dDataAssi
							MsUnlock()
							CNB->(dbSkip())
						EndDo
					EndIf
									
					RecLock("CN9",.F.)
						CN9->CN9_SITUAC := DEF_SVIGE
						If Empty(CN9->CN9_DTASSI)
							CN9->CN9_DTASSI := dDataBase
						EndIf
						CN9->CN9_DTULST := dDataBase
					MsUnlock()
					Conout(STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA) //"Contrato" ## "Revisao"
					Conout(STR0169+" - "+"CNTA100") //"Aviso"
					Conout(OemtoAnsi(STR0029))		// "Situacao alterada com sucesso"
				EndIf
						
				If lRet .And. !lMedeve .And. (GetNewPar( "MV_CNPROVI" ,  "S" ) == "S")
					CN100CTit(CN9->CN9_NUMERO,CN9->CN9_REVISA)
				EndIf
						
				dbSelectArea("CN9")
				dbSetOrder(1)
				dbSkip()
				
			EndDo
	
		EndIf
		
	Next
/*
Else
   Conout("Tentativa de execução via menu")
	Help(" ",1,"CN100JOB",,"Esta função só pode ser executada em um Scheduler") 

EndIf	
*/
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldFor³ Autor ³                       ³ Data ³01.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica de validacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Valida()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Valida()
Local lRet      := .T.      
      
If INCLUI
	If (M->CN9_FLGCAU == "1") .And. Empty(M->CN9_MINCAU)
		Help(" ",1,"CNTA100PER") //"Preencha o percentual minimo de caucao"
		lRet := .F.
	EndIf

	If lRet .And. (M->CN9_FLGREJ == "1") .And. Empty(M->CN9_INDICE)
		Help(" ",1,"CNTA100IND") //"Preencha o indice de reajuste do contrato"
		lRet := .F.
	EndIf
EndIf


Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN100CtrVg ³ Autor ³ Totvs               ³ Data ³01.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera situacao do contrato e grava data de assinatura nos ³±±
±±³          ³ itens do contrato                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100CtrVg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±                                                                         ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100 / MATA097                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100CtrVg(lSitAprAlc)

Local aArea 	:= GetArea()
Local dDataAssi := dDataBase

Default lSitAprAlc := .F.

If !Empty(CN9->CN9_DTASSI)
	dDataAssi := CN9->CN9_DTASSI
EndIf

If Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CTRFIX") <> "2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza data de aniversario dos itens com a data de      ³
	//³ assinatura                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
	dbSelectArea("CNB")
	dbSetOrder(1)
	cFilCod := xFilial("CNB")
	dbSeek(xFilial("CNB")+CN9->CN9_NUMERO+CN9->CN9_REVISA)

	While !CNB->(Eof()) .And. CNB->CNB_FILIAL == xFilial("CNB") .And. CNB->CNB_CONTRA == CN9->CN9_NUMERO .And. CNB->CNB_REVISA == CN9->CN9_REVISA
		RecLock("CNB")
		CNB->CNB_DTANIV := dDataAssi
		MsUnlock()
		CNB->(dbSkip())
	EndDo
EndIf
			
RecLock("CN9",.F.)
	If lSitAprAlc
		CN9->CN9_SITUAC := "04"	//Aprovacao
	Else
		CN9->CN9_SITUAC := "05"	//Vigente
	EndIf
	
	If Empty(CN9->CN9_DTASSI)
		CN9->CN9_DTASSI := dDataAssi
	EndIf
	
	CN9->CN9_DTULST := dDataBase
MsUnlock()
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CtrRevisa  ³ Autor ³Igor Franzoi           ³ Data ³11.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida se o contrato tem revisão em aberto				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtrRevisa												   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtrRevisa( cFilCN9, cNumCN9, cRevCN9 )

Local lRet := .T.

Local cKeyPes := cFilCN9+cNumCN9

Local nOrdCN9 := RetOrdem( "CN9", "CN9_FILIAL+CN9_NUMERO+CN9_REVISA" )

Local aArea := GetArea()

//If Empty(cRevCN9)
	
	dbSelectArea("CN9")
	CN9->(dbSetOrder(nOrdCN9))
	
	CN9->(dbSeek(cKeyPes))
	
	While CN9->(!Eof() .and. CN9_FILIAL+CN9_NUMERO == cKeyPes)
		If !Empty(CN9->CN9_REVISA) .and. CN9->CN9_SITUAC == '09'
			lRet := .F.
			Exit
		EndIf
		CN9->(dbSkip())
	EndDo
	
//EndIf

RestArea(aArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ CN100BIns³ Autor ³ Joao Goncalves de Oliveira ³ Data ³ 16/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Base Instalada e Ordem de Serviço para ítens da Planilha   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CN100BIns(ExpC1,ExpC2,ExpD3) 				          		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Numero do Contrato                                      ³±±
±±³          ³ ExpC2 - Numero da Revisão                                       ³±±
±±³          ³ ExpD3 - Data de Assinatura do Contrato                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Nenhum                       						   		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN100BIns(cNumeCtrt,cNumeRevi,dDataAssi)
Local lRet 		  := .T.
Local aCabeBIns   := {}
Local aItenBIns   := {}
Local aCabeOSer   := {}
Local aItemOSer   := {}
Local aItenOSer   := {}
Local cCodiOcor   := SuperGetMv("MV_OCORROS",.F.,.F.) // Ocorrencia Padrao para Ordem de Serviço
Local nCntFor	  := 0
Local cCodCliAnt  := ""
Local cLojaCliAnt := ""
Local nRegAA3	  := 0
Local aRecAA4     := {}
Local aDadoBIns   := {}
Local aDadoOSer   := {}

AAG->(dbSetOrder(1))
If Empty(cCodiOcor) .Or. !AAG->(dbSeek(xFilial("AAG")+cCodiOcor))
	Help("  ",1,"CNTEC_03")
	lRet := .F.
Else
	Begin Transaction
	
	CNB->(dbSetOrder(1))
	CNB->(dbSeek(xfilial("CNB")+cNumeCtrt+cNumeRevi))
	While AliasInDic("AGW") .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == xfilial("CNB")+cNumeCtrt+cNumeRevi
		aCabeBIns := {}
		aItenBIns := {}
		aCabeOSer := {}
		aItemOSer := {}
		aItenOSer := {}
		
		If CNB->CNB_BASINS == "1" .And. CNB->CNB_GERBIN <> "1" .And. CNB->CNB_SLDMED > 0
			CNA->(dbSetOrder(1))
			CNA->(dbSeek(xfilial("CNA")+cNumeCtrt+cNumeRevi+CNB->CNB_NUMERO))
			
			CN9->(dbSetOrder(1))
			CN9->(dbSeek(xfilial("CN9")+cNumeCtrt+cNumeRevi))
			
			AGW->(dbSetOrder(2))
			If AGW->(dbSeek(xfilial("AGW")+CNB->(CNB_CONTRA+CNB_NUMERO+CNB_ITEM)))
				cNumeSeri := AGW->AGW_NUMSER
				cCodiProd := AGW->AGW_PRODUT
				cCodiFabr := AGW->AGW_CODFAB
				cLojaFabr := AGW->AGW_LOJAFA
				aRecAA4   := {}
				
				//-- Se o equipamento ja estiver instalado
				AA3->(dbSetOrder(4))
				If AA3->(dbSeek(xfilial("AA3")+cCodiFabr+cLojaFabr+cCodiProd+cNumeSeri))
					nRegAA3 := AA3->(Recno())
					//-- E em outro cliente
					If AA3->AA3_CODCLI <> CNA->CNA_CLIENT .Or. AA3->AA3_LOJA <> CNA->CNA_LOJACL
						AA4->(dbSetOrder(3))
						If AA4->(dbSeek(xfilial("AA4")+cCodiFabr+cLojaFabr+cCodiProd+cNumeSeri))
							While AA4->(AA4_CODFAB+AA4_LOJAFA+AA4_CODPRO+AA4_NUMSER) == cCodiFabr+cLojaFabr+cCodiProd+cNumeSeri
								aAdd(aRecAA4,AA4->(Recno()))
								AA4->(dbSkip())
							End
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Efetua transferência de cliente quando o número de série já ³
						//³houver sido instalado e o cliente for diferente do atual    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SA1->(dbSetOrder(1))
						If SA1->(MsSeek(xFilial("SA1")+ CNA->CNA_CLIENT + CNA->CNA_LOJACL))
							AA3->(dbSetOrder(1))
							If !AA3->(MsSeek(xFilial("AA3")+CNA->(CNA_CLIENT+CNA_LOJACL)+AA3->(AA3_CODPRO+AA3_NUMSER)))
								AA3->(MsGoto(nRegAA3))
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Armazena codigo do cliente e loja antes de gravar o AA3³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cCodCliAnt	:= AA3->AA3_CODCLI
								cLojaCliAnt	:= AA3->AA3_LOJA
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza a base instalada                                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								RecLock("AA3",.F.)
								AA3->AA3_CODCLI := CNA->CNA_CLIENT
								AA3->AA3_LOJA   := CNA->CNA_LOJACL
								AA3->AA3_CONTRT := ""
								AA3->AA3_CTAPRE := ""
								AA3->AA3_DTCTAM := CTOD("")
								AA3->(MsUnlock())
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Bloco de Transferencia                                                  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								For nCntFor := 1 To Len(aRecAA4)
									AA4->(MsGoto(aRecAA4[nCntFor]))
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Atualiza historico dos acessorios                                  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									RecLock("AA4",.F.)
									AA4->AA4_CODCLI := CNA->CNA_CLIENT
									AA4->AA4_LOJA   := CNA->CNA_LOJACL
									AA4->(MsUnlock())
								Next nCntFor
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza o historico do equipamento                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Reclock("AAF",.T.)
								AAF->AAF_FILIAL := xFilial("AAF")
								AAF->AAF_CODCLI := CNA->CNA_CLIENT
								AAF->AAF_LOJA   := CNA->CNA_LOJACL
								AAF->AAF_CODPRO := AA3->AA3_CODPRO
								AAF->AAF_NUMSER := AA3->AA3_NUMSER
								AAF->AAF_PRODAC := AA3->AA3_CODPRO
								AAF->AAF_NSERAC := AA3->AA3_NUMSER
								AAF->AAF_DTINI  := dDataBase
								AAF->AAF_LOGINI := Left(STR0177 +cCodCliAnt +"/" +cLojaCliAnt +STR0178 +CNA->CNA_CLIENT +"/" +;
													CNA->CNA_LOJACL,Len(AAF->AAF_LOGINI)) // # ""Transferência do cliente ## para o cliente ##"
								AAF->(MsUnlock())
							EndIf
						EndIf
					EndIf
				Else
					aAdd(aCabeBIns,{"AA3_CODCLI",CNA->CNA_CLIENT,NIL})
					aAdd(aCabeBIns,{"AA3_LOJA"  ,CNA->CNA_LOJACL,NIL})
					aAdd(aCabeBIns,{"AA3_CODPRO",CNB->CNB_PRODUT,NIL})
					aAdd(aCabeBIns,{"AA3_NUMSER",AGW->AGW_NUMSER,NIL})
					aAdd(aCabeBIns,{"AA3_DTVEND",dDataBase,NIL})
					aAdd(aCabeBIns,{"AA3_STATUS",'02',NIL})
					
					If ExistBlock("C100GRBI")
						aDadoBIns := ExecBlock("C100GRBI",.F.,.F.,{aCabeBIns,aItenBIns})
						aCabeBIns := aClone(aDadoBIns[1])
						aItenBIns := aClone(aDadoBIns[2])
					EndIf
					
					If !Empty(aCabeBIns)
						lMsErroAuto := .F.
						MSExecAuto( {|w,x,y,z| TECA040(w,x,y,z)}, NIL, aCabeBIns, aItenBIns, 3)
						If lMsErroAuto
							MostraErro()
							lRet := .F.
						Else
							aAdd(aCabeOSer,{"AB6_CODCLI",CNA->CNA_CLIENT,NIL})
							aAdd(aCabeOSer,{"AB6_LOJA"  ,CNA->CNA_LOJACL,NIL})
							aAdd(aCabeOSer,{"AB6_EMISSA",dDataBase,NIL})
							aAdd(aCabeOSer,{"AB6_CONPAG",CN9->CN9_CONDPG,NIL})
							aAdd(aCabeOSer,{"AB6_MSG",STR0183 +AllTrim(CN9->CN9_NUMERO) +".",NIL}) //OS gerada pelo início de vigência do contrato nº
							
							aAdd(aItemOSer,{"AB7_ITEM",StrZero(1,TamSX3("AB7_ITEM")[1]),NIL})
							aAdd(aItemOSer,{"AB7_CODPRO",CNB->CNB_PRODUT,NIL})
							aAdd(aItemOSer,{"AB7_NUMSER",AGW->AGW_NUMSER,NIL})
							aAdd(aItemOSer,{"AB7_CODPRB",cCodiOcor,NIL})
							aAdd(aItenOSer,aItemOSer)
							
							If ExistBlock("C100GROS")
								aDadoOSer := ExecBlock("C100GROS",.F.,.F.,{aCabeOSer,aItenOSer})
								aCabeOSer := aClone(aDadoOSer[1])
								aItenOSer := aClone(aDadoOSer[2])
							EndIf
							
							If !Empty(aCabeOSer)
								lMsErroAuto := .F.
								MSExecAuto({|w,x,y,z| TECA450(w,x,y,z)},NIL,aCabeOSer,aItenOSer,NIL,3)
				
								If lMsErroAuto
									MostraErro()
									lRet := .F.
									Exit
								Endif
							EndIf
						Endif
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza campo de controle de geração da base instalada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet
					Reclock("CNB",.F.)
					CNB->CNB_GERBIN := "1"
					CNB->(MsUnlock())
				EndIf
			Else
				Help(" ",1,"CNTEC_01",,STR0180 +CNB->CNB_ITEM +STR0181 +CNB->CNB_NUMERO +STR0182,1) //O item ## da planilha ## não possui localização física informada.
				lRet := .F.
				Exit
			EndIf
		EndIf
		CNB->(dbSkip())
	End

	If !lRet
		DisarmTransaction()
	EndIf
	
	End Transaction
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100ZeraPer³ Autor ³ Aline S Damasceno    ³ Data ³26.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Zera o minimo de caucao se opcao Caucao for Nao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100ZeraPer()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100ZeraPer()

If M->CN9_FLGCAU == '2'
   M->CN9_MINCAU := 0
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN100CanceºAutor  ³ Andre Anjos		 º Data ³  16/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que processa o encerramento de um contrato.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lAviso: exibe confirmacao da alteracao da situacao.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Cance(lAviso,lCtrApr,aRet)
Local aAreaAnt	:= GetArea()
Local aAux		:= {}
Local cAliasNew	:= ""
Local cQuery	:= ""
Local cFilSC1	:= ""
Local cSitAnt	:= " "
Local nRecCN9	:= 0
Local lRet      := .T.
Local lEstLiber := .F.
Local lFilOri	:= CNB->(FieldPos("CNB_FILORI")) > 0
Local lReman	:= (ValType(aRet)=="A")
Local lPrjCni	:= FindFunction("ValidaCNI") .And. ValidaCNI() 

Default lAviso := .F.
Default lCtrApr:= .F.

SaveInter()

If CN100VerNf(CN9->CN9_NUMERO,CN9->CN9_REVISA)
	cSitAnt := CN9->CN9_SITUAC
	nRecCN9 := CN9->(Recno())
	If	!lPrjCni .And. lReman
		RecLock("CN9",.F.)
		CN9->CN9_RESREM := "S"
		MsUnlock()
	Else
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := DEF_SCANC
		CN9->CN9_DTULST := dDataBase
		If	lReman
			CN9->CN9_RESREM := "S"
		EndIf
		MsUnlock()
	EndIf				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contabiliza a desativacao do contrato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("CNT100",.F.)
	CN100Contab("696")
	
	//-- Libera SCs vinculadas ao contrato
	SC1->(dbSetOrder(1))
	CNB->(dbSetOrder(1))
	CNB->(dbSeek(xFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)))
	While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == xFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)
		If lFilOri .And. !Empty(CNB->CNB_FILORI)
			cFilSC1 := xFilial("SC1",CNB->CNB_FILORI)
		Else
			cFilSC1 := xFilial("SC1")
		EndIf
		If !Empty(CNB->CNB_NUMSC) .And. SC1->(dbSeek(cFilSC1+CNB->(CNB_NUMSC+CNB_ITEMSC)))
			RecLock("SC1",.F.)
			SC1->C1_FLAGGCT := ""
			SC1->(MsUnLock())
		ElseIf CN9->(FieldPos("CN9_CODED")) > 0 .And. !Empty(CN9->CN9_CODED)
			SC1->(dbOrderNickName("GCP01"))
		  	SC1->(dbSeek(cFilSC1+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT))
		  	While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == cFilSC1+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT
		  		RecLock("SC1",.F.)
				SC1->C1_FLAGGCT	:= ""
				SC1->(MsUnlock())
									
				SC1->(dbSkip())
			End
		EndIf
		CNB->(dbSkip())
	End
			
	If Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_MEDEVE") # "1" .And. GetNewPar("MV_CNPROVI","S") == "S"
		MsAguarde({|| CN100ETit(CN9->CN9_NUMERO,CN9->CN9_REVISA)},STR0061)//"Estornando títulos"
	EndIf
	
	//-- Estorna controle de alcadas
	If lCtrApr
		SCR->(dbSetOrder(1))
		If SCR->(dbSeek(xFilial("SCR")+"CR"+CN9->(CN9_NUMERO+CN9_REVISA)))
			lEstLiber := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,5)
		EndIf
	EndIf
	If lAviso
		Aviso("CNTA100",OemtoAnsi(STR0029)+If(lEstLiber,CRLF+OemtoAnsi(STR0176),""),{"Ok"})// "Situacao alterada com sucesso" ## "Os documentos existentes na rotina de Liberação foram estornados automaticamente."	
	EndIf
	//-- Processa a eliminacao de residuos do SC7
	If	lReman
		cAliasNew := GetNextAlias()
		cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO, CNB.R_E_C_N_O_ CNBRECNO"
		cQuery += " FROM"
		cQuery += " "+RetSqlName('SC7')+" SC7"
		cQuery += " JOIN " +RetSqlName("CNB") +" CNB ON CNB.D_E_L_E_T_ <> '*' AND "
		If CNB->(FieldPos("CNB_FILORI")) == 0
			cQuery += "	CNB.CNB_FILIAL = '" +xFilial('CNB') +"' AND "
		Else
			cQuery += "	CNB.CNB_FILORI = '" +xFilial('CNB') +"' AND "
		EndIf
		cQuery += "	CNB.CNB_CONTRA = SC7.C7_CONTRA AND "
		cQuery += "	CNB.CNB_REVISA = SC7.C7_CONTREV AND "
		cQuery += "	CNB.CNB_NUMERO = SC7.C7_PLANILH AND "
		cQuery += "	CNB.CNB_ITEM   = SC7.C7_ITEMED AND "
		cQuery += "	CNB.CNB_SLDREC > 0 "
		cQuery += " WHERE"
		If	SC7->(FieldPos("C7_FISCORI")) == 0
			cQuery += " C7_FILIAL  = '"+xFilial("SC7")+"'"
		Else
			cQuery += "	C7_FISCORI = '"+xFilial("SC7")+"'"
		EndIf
		cQuery += " AND C7_CONTRA  = '"+CN9->CN9_NUMERO+"'"
		cQuery += " AND C7_CONTREV = '"+CN9->CN9_REVISA+"'"
		cQuery += " AND C7_QUANT - C7_QUJE > 0 "
		cQuery += " AND C7_RESREM <> 'S' "
		cQuery += " AND C7_RESIDUO <> 'S' "
		cQuery += " AND SC7.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	
		While (cAliasNew)->(!Eof())
			SC7->(DbGoTo((cAliasNew)->SC7RECNO))
	
			lRet := SC7->(MA235ElRes())
		
			//-- Restaura SCs vinculadas ao PC
			If	lRet
	
				RecLock("SC7",.F.)
				SC7->C7_RESREM := "S"
				SC7->(MsUnLock())
	
				If	Empty(aScan(aAux,{|x| x == (cAliasNew)->CNBRECNO}))
					CNB->(dbGoTo((cAliasNew)->CNBRECNO))
					aAdd(aRet,{lRet,CNB->CNB_PRODUTO,CNB->CNB_SLDREC,CNB->(CNB_NUMSC+CNB_ITEMSC),(cAliasNew)->CNBRECNO,cSitAnt,nRecCN9})
					aAdd(aAux,(cAliasNew)->CNBRECNO)
				EndIf
		
			EndIf
		
			(cAliasNew)->(DbSkip())
		EndDo
	
		DbSelectarea(cAliasNew)
		DbCloseArea()
		RestArea(aAreaAnt)
	EndIf
Else
	lRet := .F.
EndIf 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN100SlFinºAutor  ³Microsiga           º Data ³  10/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que processa codigo referente a solicitacao de      º±±
±±º          ³ finalizacao de contrato.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN100SlFin(lCtrApr)
Local lEstorna   := .F.
Local aAreaSE2   := SE2->(GetArea())
Local cFiltroSE2 := "SE2->E2_MDCONTR == '" +CN9->CN9_NUMERO +"' .AND. SE2->E2_TIPO == 'PR '"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui registro da tabela SCR (Liberação de Doctos) quando o Tipo do Contrato requer Controle por Alcada  ³
//³ A exclusao nao e valida para as situacoes 07-Sol Finaliz.(DEF_SSPAR) e 08-Finalizado (DEF_SFINA)		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCtrApr .AND. !(CN9->CN9_SITUAC $ DEF_SSPAR+"/"+DEF_SFINA)
	dbSelectArea("SCR")
	SCR->(dbSetOrder(1)) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek(xFilial("SCR")+"CT"+CN9->(CN9_NUMERO+CN9_REVISA))
		lEstorna := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,5)
	EndIf
	
	// Deletar os titulos PR gerados na SE2
	dbSelectArea("SE2")
	SE2->(dbSetFilter({|| &(cFiltroSE2)},cFiltroSE2))
	SE2->(dbGoTop())
	While !SE2->(Eof())
		RecLock("SE2",.F.)
		SE2->(dbDelete())
		SE2->(MsUnlock())
		SE2->(dbSkip())
	EndDo
	SE2->(dbClearFilter())
	RestArea(aAreaSE2)
EndIf
