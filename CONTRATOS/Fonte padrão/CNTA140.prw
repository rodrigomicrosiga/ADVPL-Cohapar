#INCLUDE "CNTA140.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "ApWizard.ch"

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
#DEFINE DEF_CRCTB "8" //Cronograma Contabil
#DEFINE DEF_INDIC "9" //Indice
#DEFINE DEF_FORNE "A" //Fornecedor

//Identificacao da coluna Novo Desconto
#DEFINE DEF_NDESC "CNBNDESC"

//Identificacao da coluna Novo Valor de Desconto
#DEFINE DEF_NVLDESC "CNBNVLDESC"

//Nome de alteracao do campo CNB_DESC
//para impedir execucao do gatilho
#DEFINE DEF_DESCNA "CNBDESC" 

//Nome de alteracao do campo CNB_DESC
//para impedir execucao do gatilho
#DEFINE DEF_VLDECNA "CNBVLDESC"

//Transacoes
#DEFINE DEF_TRAINC "027"//Inclusao de Revisoes
#DEFINE DEF_TRAEDT "028"//Edicao de Revisoes
#DEFINE DEF_TRAEXC "029"//Exclusao de Revisoes
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNTA140  ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Revisoes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140()                                                  ³±±
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
Function CNTA140()
Local aCores := {	{ "Alltrim(CN9->CN9_SITUAC) == '01'", "BR_VERMELHO"},;  // Cancelado
						{ "Alltrim(CN9->CN9_SITUAC) == '02'", "BR_AMARELO"	},;  // Elaboracao
						{ "Alltrim(CN9->CN9_SITUAC) == '03'", "BR_AZUL"		},;  // Emitido
						{ "Alltrim(CN9->CN9_SITUAC) == '04'", "BR_LARANJA"	},;  // Em Aprovacao
						{ "Alltrim(CN9->CN9_SITUAC) == '05'", "BR_VERDE"	},;  // Vigente
						{ "Alltrim(CN9->CN9_SITUAC) == '06'", "BR_CINZA"	},;  // Paralisado
						{ "Alltrim(CN9->CN9_SITUAC) == '07'", "BR_MARRON"	},;  // Sol. Finalizacao
						{ "Alltrim(CN9->CN9_SITUAC) == '08'", "BR_PRETO"	},;  // Finalizado
						{ "Alltrim(CN9->CN9_SITUAC) == '09'", "BR_PINK"		},;  // Revisao   
						{ "Alltrim(CN9->CN9_SITUAC) == '10'", "BR_BRANCO"	}}   // Revisado
Local aIndexCN9 := {}
Local cFiltro   := ""
Local cCn140Fil := "" 
Local cFilRev   := ""     

PRIVATE cCadastro	:= OemToAnsi(STR0001) //"Revisão de Contratos"
PRIVATE aRotina 	:= MenuDef() 
Private bFiltraBrw  := {|| Nil }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi aplicado o update GCTUPD22³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CNS->(FieldPos("CNS_ITOR")) == 0
	Final(OemtoAnsi(STR0138))  //"Aplicar o update GCTUPD22 para atualização do Cronograma Físico!!!"
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Dicionarios SX1                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Gatilhos	SX7                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN140AjSX7() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra MBrowse  			                   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN140FIL")
	cCn140Fil := ExecBlock("CN140FIL",.F.,.F.)
	If ( ValType(cCn140Fil) == "C" ) .And. !Empty(cCn140Fil)
		cFiltro := cCn140Fil
	EndIf   
Else
	cFilRev := "(CN9_SITUAC='05' Or CN9_SITUAC='06' Or CN9_SITUAC='09')"                                   
EndIf      

If !Empty(cFiltro)
	bFiltraBrw := {|| FilBrowse("CN9",@aIndexCN9,@cFiltro) }
	Eval(bFiltraBrw)
EndIf

mBrowse(6,1,22,75,"CN9",,,,,,aCores,,,,,,,,cFilRev)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140Manut³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Revisoes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140(cExp01,nExp02,nExp03)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ -cExp01 - Alias selecionado                                ³±±
±±³          ³ -nExp02 - Registro Atual                                   ³±±
±±³          ³ -nExp03 - Opcao Atual                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140Manut(cAlias,nReg,nOpc)
//Tipo de Revisao
Local cCodTR  := Space(TamSX3("CN0_CODIGO")[1])  
Local cDescTr := ""       
Local cSaldo  := STR0062
Local lCronog := .F.//Permite alterar cronogramas
Local lAltVlr := .F.//Permite alterar valor
Local lAltVig := .F.//Permite alterar vigencia
            
//Procedimento
Local oRadio 
Local oGrRad01

//Contrato
Local cRevisa := ""
Local cNRevisa:= ""

//Paralisacao
Local cCodPr  := Space(TamSX3("CN2_CODIGO")[1])
Local cDescPr := ""                    
Local dDtRein := CTOD("  /  /  ")
                                 
//Reajuste             
Local dDtReaj := dDataBase
Local dDtRefe := dDataBase

//Planilha
Local aPlan := {}
Local aAditPlan := {}//Array com os valores aditivados das planilhas
Local aAditQtd  := {}

//Clausula
Local cClaus := ""
Local oClaus

//Itens
Local oPlan
Local cPlan     := ""
Local cPlanAtu  := ""//Armazena planilha atual

Local aItens    := {}//Itens das planilhas
Local aItensCtb := {}//Itens do Cronograma Contabil
Local aCpoCNB   := {}
Local aColsIt   := {}   
Local aCpoNH    := {"CNB_NUMERO","CNB_REVISA","CNB_OBS","CNB_DTANIV","CNB_CONORC","CNB_CONTRA","CNB_DTCAD","CNB_DTPREV","CNB_SLDMED","CNB_PERC","CNB_RATEIO","CNB_TIPO","CNB_ITSOMA","CNB_VLRGL","CNB_PERCAL","CNB_FILHO","CNB_NUMSC","CNB_ITEMSC","CNB_QTDSOL","CNB_VLTOTR","CNB_QTREAD","CNB_VLREAD","CNB_VLRDGL"}
Local aCpoAlt   := {}//Campos que poderao ser alterados  
Local aAlterCNB := {}  
Local aNalterCNB:= {"CNB_PRODUT","CNB_UM","CNB_QUANT","CNB_VLUNIT","CNB_VLTOT","CNB_DESC","CNB_DESCRI","CNB_PRCORI","CNB_QTDORI","CNB_QTRDAC","CNB_QTRDRZ","CNB_CONTA"}
Local aParAnt	:= {}
Local aParVlR	:= {}

Local nPosDesc	//Posicao do campo de desconto
Local nPosVDes	//Posicao do campo de valor de desconto
Local nPosODes	//Posicao do campo desconto - original
Local nPosOVDe	//Posicao do campo de valor de desconto - original

//Cronograma
Local oArrasto
Local oDist
Local lDist
Local lArrasto
Local aTotCont   := {}
Local nParcel    := 0
Local nSaldPlan  := 0
Local nSaldCont  := 0
Local nPos
Local cCron
Local cCronO //Usado durante a troca de cronogramas

//Cronograma Contabil
Local aCpoCNW  := {"CNW_DTPREV","CNW_VLPREV","CNW_HIST"}  //Campos permitidos na edicao do cronograma contabil
Local aTotCtb  := {}  //Armazena os totais dos cronograma contabeis
Local cCtb     := ""
Local cCtbO    := ""
          
//Justificativa
Local cJust := ""
Local cDescrVig := ""
Local oMemo
Local dFContra := dDataBase
Local nValor   := 0
Local nSaldo   := 0
Local nVlOri   := 0

//Cronograma Fisico
Local aHeadParc := {}
Local aColsParc := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena a estrutura dos cronogramas fisicos                   ³
//³-aFscVl[1]      - Cronograma                                    ³
//³--aFscVl[1,1]   - Primeiro item da planilha                     ³
//³---aItVl[1,1,1] - Valor do item na planilha                     ³
//³---aItVl[1,1,2] - Quantidade total na planilha                  ³
//³---aItVl[1,1,3] - Quantidade a distribuir no cronograma fisico  ³
//³---aItVl[1,1,4] - Item da planilha							   ³
//³---aItVl[1,1,5] - Valor original do item da planilha		       ³
//³---aItVl[1,1,6] - Quantidade original do item da planilha	   ³
//³---aItVl[1,1,7] - Valor de Desconto							   ³
//³--aFscVl[1,2]   - Segundo item da planilha                      ³
//³---aItVl[1,2,1] - Valor do item na planilha                     ³
//³---aItVl[1,2,2] - Quantidade total na planilha                  ³
//³---aItVl[1,2,3] - Quantidade a distribuir no cronograma fisico  ³
//³---aItVl[1,1,4] - Item da planilha							   ³
//³---aItVl[1,1,5] - Valor original do item da planilha		       ³
//³---aItVl[1,1,6] - Quantidade original do item da planilha	   ³ 
//³---aItVl[1,1,7] - Valor de Desconto							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aFscVl    := {}

Local oBtnFsc
Local oBtnNPla
Local lCN140NPla := ExistBlock("CN140NPLA")

//Geral
Private cContra   := ""
Private cTpCron
Private cTpCronCtb
Private cTpRev
Private cEspc
Private cTipoCtr      	  // tipo de revisao (usado para o tratamento do cronograma finac e contabil)
Private cEspec        	  // epecie de revisao )
Private cCronog
Private cNuncron		  //numero do cronograma
Private cCtbCron      
Private cIndAtu   := Space(Len(CN9->CN9_INDICE))
Private cIndNovo  := Space(Len(CN9->CN9_INDICE))
Private aHdFor    := {}
Private aItFor    := {}

Private lRevisad  := .F. //Verifica se esta incluindo ou alterando uma revisao
Private lMedeve   := .F. //Contrato com medicao eventual
Private lFisico   := .F. //Contrato com cronograma fisico
Private lContab   := .F. //Contrato com cronograma contabil
Private lAltPar   := .F. //Permite alterar parcelas

Private oOk       := LoadBitmap( GetResources(), "LBTIK" )
Private oNo       := LoadBitmap( GetResources(), "LBNO" )

Private nParcelas := 0
Private nRevRtp   := 0 //Tipo de Alteracao: 1-Prosseguir,2-Reiniciar,3-Excluir

Private aParcelas := {}
Private aCron     := {}
Private aCronCtb  := {}
Private aHeaderCt := {}
Private aHeader   := {}
Private aParcDelat:= {} // parcelas do cronograma deletados em caso de Decréscimo
Private aTpCron   := {}
Private aHeaderIt := {}
Private aHeaderOb := {}

Private lTpCron   := .T.
Private lMotREvOk := .T. // define se tem Cronograma fisico/Financ e Cronograma Contabil
Private lFixo     := .T. //Contrato com planilha
Private lVlPrv    := .T. //Contrato com previsao financeira

Private dDtPrev

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Cronograma Contabil       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aStruCNV  := CNV->(dbStruct())
Private cArqCNV   := ""
Private oCtbCron
Private oTpCron
Private oTpCronCtb

cArqCNV := CriaTrab(aStruCNV)
dbUseArea(.T.,,cArqCNV,"TRBCNV",.F.,.F.)

Private aStruCNW  := CNW->(dbStruct())
Private cArqCNW   := ""
cArqCNW := CriaTrab(aStruCNW)
dbUseArea(.T.,,cArqCNW,"TRBCNW",.F.,.F.)


//Variaveis do painel de contratos
Private aStruCN9  := CN9->(dbStruct())
Private cArqCN9   := ""
Private oBrowse//Contratos
Private cRevAtu := cRevisa

cArqCN9 := CriaTrab(aStruCN9)
dbUseArea(.T.,,cArqCN9,"TRBCN9",.F.,.F.)

//Variaveis do painel de planilhas
Private aStruCNA  := CNA->(dbStruct())
Private cArqCNA   := ""
Private oBrowse2//Planilhas

cArqCNA := CriaTrab(aStruCNA)
dbUseArea(.T.,,cArqCNA,"TRBCNA",.F.,.F.)

//Variaveis do painel de itens de planilhas
Private oGetDad1
Private cModo		//Modo de alteracao, acrescimo, decrescimo, ambos
Private oGrpPlO		//Grupo original
Private oVlPOri
Private oGrpPlA		//Grupo atual
Private oVlPAtu
Private nVlPAtu := 0

//Variaveis do painel de cronogramas Fisico/Financ
Private aStruCNF  := CNF->(dbStruct())
Private cArqCNF   := ""
Private oBrowse4	//Cronogramas
Private oGetDados
Private oTotCronog
Private oSaldDist
Private oSaldCont
Private oSaldPlan
Private oTotPlan
Private dFCronog //Data maximas dos cronograma
Private oCron
Private nVgAdit := 0

//Variaveis usadas na validacao 
Private nTotPlan   := 0
Private nTotCronog := 0
Private aItVl      := {}
Private cCCusto
Private cItemCt 
Private cClVl

//Variaveis do painel de cronograma contabil
Private oGetCtb

//Variaveis usadas no painel de justificativas
Private aUnVig  := {STR0116,STR0117,STR0118,STR0119}
Private oUnVig

//Variaveis para controle do Ultimo dia do mes
Private oUltimoDia:= NIL
Private lUltimoDia:= .F.    

If !Empty(CNB->(FieldPos("CNB_TE")))
	aAdd(aNalterCNB,"CNB_TE")
EndIf   

If !Empty(CNB->(FieldPos("CNB_TS")))
	aAdd(aNalterCNB,"CNB_TS")
EndIf                          

aAdd(aNalterCNB,"")

cArqCNF := CriaTrab(aStruCNF)
dbUseArea(.T.,,cArqCNF,"TRBCNF",.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche cabecalhos dos itens de planilhas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If dbSeek("CNB", .F.)
	Do While !Eof() .And. SX3->X3_ARQUIVO=="CNB"
		If ( X3USO(SX3->X3_USADO)) .And. (aScan(aCpoNH,{|x| x == Alltrim(SX3->X3_CAMPO)}) = 0) .And. cNivel >= SX3->X3_NIVEL
			aAdd(aHeaderIt,{AllTrim(X3Titulo()),;
			AllTrim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT})
			
			Aadd(aHeaderOb,{AllTrim(X3Titulo()),;
			AllTrim(SX3->X3_CAMPO),;
			SX3->X3_OBRIGAT})
		EndIf

		If SX3->X3_VISUAL == "A" .And. aScan(aNalterCNB,AllTrim(SX3->X3_CAMPO)) == 0
			aAdd(aAlterCNB,SX3->X3_CAMPO)
		EndIf
		
		dbSkip()
	EndDo
EndIf

//Verifica se contrato e do tipo Fisico
dbSelectArea("CN9")     
dbgoto(nReg)    
lFisico := ((CN1->(FieldPos("CN1_CROFIS")) > 0) .And. Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROFIS") == "1")   
If lFisico
	cSaldo := STR0153
EndIf


nPosDesc := aScan(aHeaderIt,{|x| x[2] == "CNB_DESC"})
nPosVDes := aScan(aHeaderIt,{|x| x[2] == "CNB_VLDESC"})
nPosODes := aScan(aHeaderIt,{|x| x[2] == "CNB_DESC"})
nPosOVDe := aScan(aHeaderIt,{|x| x[2] == "CNB_VLDESC"})
 
//Altera nome da coluna do valor de desconto para impedir execucao de gatilho do cadastro de planilhas
aHeaderIt[nPosOVDe][2] := DEF_VLDECNA

//Altera nome da coluna de desconto para impedir execucao de gatilho do cadastro de planilhas
aHeaderIt[nPosODes][2] := DEF_DESCNA

//Inclui novo campo para calculo de desconto 
If FindFunction("cn200MultT")
	aAdd(aHeaderIt,{STR0057,DEF_NDESC,aHeaderIt[nPosDesc][3],;//"Novo Desconto %"
							aHeaderIt[nPosDesc][4],aHeaderIt[nPosDesc][5],"CN140VldDesc().And.cn200MultT()",aHeaderIt[nPosDesc][7],;
							aHeaderIt[nPosDesc][8],aHeaderIt[nPosDesc][9],aHeaderIt[nPosDesc][10],""})    
Else
	aAdd(aHeaderIt,{STR0057,DEF_NDESC,aHeaderIt[nPosDesc][3],;//"Novo Desconto %"
							aHeaderIt[nPosDesc][4],aHeaderIt[nPosDesc][5],"CN140VldDesc()",aHeaderIt[nPosDesc][7],;
							aHeaderIt[nPosDesc][8],aHeaderIt[nPosDesc][9],aHeaderIt[nPosDesc][10],""})    
EndIf
						
//Inclui novo campo para valor de desconto
aAdd(aHeaderIt,{STR0058,DEF_NVLDESC,aHeaderIt[nPosVDes][3],;//"Novo Valor Desconto"
						aHeaderIt[nPosVDes][4],aHeaderIt[nPosVDes][5],"",aHeaderIt[nPosVDes][7],;
						aHeaderIt[nPosVDes][8],aHeaderIt[nPosVDes][9],aHeaderIt[nPosVDes][10],""})
						    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("CNB",aHeaderIt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa lancamento do PCO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000357")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de apresentacao                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard;
TITLE STR0007 ; //"Assitente - Manutenção de Revisões"
HEADER STR0008;//"Revisões de Contrato"
TEXT OemToAnsi(STR0009)+CRLF+CRLF+OemToAnsi(STR0010);//"Assistente responsável pela configuração das revisões de contrato"##"Clique em avancar e inicie o processo"
PANEL NEXT {|| .T. };
FINISH {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de selecao do tipo de revisao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0011 ;//"Tipos de Revisão"
MESSAGE STR0012;//"Selecione o tipo de Revisão"
PANEL NEXT {|| CN140VlP2(@cCodTR,nReg) };
FINISH {|| .T. }
	
@ 030,010 Say STR0013 of oWizard:oMPanel[2] PIXEL//"Código"
@ 027,035 MsGet cCodTR Picture PesqPict("CN0","CN0_CODIGO") F3 "CN0" Valid CN140VldCodTr(cCodTR,@cDescTR,@cTipoCtr) of oWizard:oMPanel[2] PIXEL

@ 030,75 Say STR0014 of oWizard:oMPanel[2] PIXEL//"Descrição"
@ 027,115 MsGet cDescTR Picture PesqPict("CN0","CN0_DESCRI") Size 150,0 When .F. of oWizard:oMPanel[2] PIXEL
	  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de selecao do contrato                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CREATE PANEL oWizard;
HEADER STR0018 ;//"Contratos"
MESSAGE STR0019;//"Selecione o Contrato"
PANEL NEXT {|| CN140VlP3(@cCodTR,@cContra,@cRevisa,@cNrevisa,cDescTR,@dFContra,@lCronog,@lAltPar,@oTpCron,@nVgAdit,@nValor,@lAltVlr,@lAltVig,@nSaldo,@nVlOri)};
FINISH {|| .T. }               
oBrowse	  := TWBrowse():New( 000, 000, __DlgWidth(oWizard:oMPanel[3]), __DlgHeight(oWizard:oMPanel[3]),,;
					{ "",RetTitle("CN9_NUMERO"),RetTitle("CN9_REVISA"),RetTitle("CN9_DTINIC"),RetTitle("CN9_DTFIM"),RetTitle("CN9_SALDO") },;
					{ 030,090,030,030,030,030,030,030 }, oWizard:oMPanel[3],,,,,,,,,,,,,"TRBCN9", .T. )	
oBrowse:bLine := {|| { If((cContra==TRBCN9->CN9_NUMERO .And. cRevisa==TRBCN9->CN9_REVISA),oOk,oNo),TRBCN9->CN9_NUMERO,TRBCN9->CN9_REVISA,TRBCN9->CN9_DTINIC,TRBCN9->CN9_DTFIM,Transform(TRBCN9->CN9_SALDO,PesqPict("CN9","CN9_SALDO"))}}
oBrowse:bLDblClick := {|| CN140MkContra(@cContra,@cRevisa,@cClaus,@cCodPr,@cDescPr,@dDtRein,@dDtReaj,@cJust), oBrowse:Refresh() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para customizar assistente da seleção dos contratos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN140CAN")
	ExecBlock("CN140CAN",.F.,.F.)
EndIf              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de processo da revisao, usado quando o        ³
//³ contrato já possuir uma revisao não aprovada         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0020;//"Processo"
MESSAGE STR0021;//"Selecione o andamento da revisao"
PANEL NEXT {|| CN140VlP4(@cCodTR,cContra,cRevisa,@cClaus,@cCodPr,@cDescPr,@dDtRein,@dDtReaj,@cJust,@lCronog,@lAltPar,@dFContra,@nValor) };
FINISH {|| .T. }    

@ 030,010 Say STR0022 of oWizard:oMPanel[4] PIXEL//"Contrato"
@ 027,045 MsGet cContra Picture PesqPict("CN9","CN9_NUMERO") Size 55,5 When .F. of oWizard:oMPanel[4] PIXEL

@ 030,105 Say STR0023 of oWizard:oMPanel[4] PIXEL//"Revisão Atual"
@ 027,145 MsGet Posicione("CN9",1,xFilial("CN9")+cContra+cRevisa,"CN9_REVATU") Picture PesqPict("CN9","CN9_REVISA") Size 20,5 When .F. of oWizard:oMPanel[4] PIXEL

@ 045,010 Say STR0027 of oWizard:oMPanel[4] PIXEL//"Tipo Revisão"
@ 042,045 MsGet Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_DESCRI") Size 150,5 When .F. of oWizard:oMPanel[4] PIXEL

@ 065,045  RADIO oGrRad01 VAR nRevRtp PROMPT STR0024,STR0025,STR0026 SIZE 70, 10 OF oWizard:oMPanel[4] PIXEL//"Prosseguir Revisão"##"Reiniciar Revisão"##"Excluir Revisão"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de selecao do tipo de paralisacao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0028;//"Paralisação"
MESSAGE STR0029;//"Informe o motivo e a data prevista de reinício"
PANEL NEXT {|| CN140VlP5(cCodPr,dDtRein) };
BACK {|| CN140BckPn(cCodTR,lCronog)};
FINISH {|| .T. }    

@ 030,010 Say STR0030 of oWizard:oMPanel[5] PIXEL//"Motivo"
@ 027,045 MsGet cCodPr Picture PesqPict("CN2","CN2_CODIGO") F3 "CN2" Valid CN140VldMPar(cCodPr,@cDescPr) of oWizard:oMPanel[5] PIXEL

@ 045,010 Say STR0014 of oWizard:oMPanel[5] PIXEL//"Descrição"
@ 042,045 MsGet cDescPr Size 200,0 When .F. of oWizard:oMPanel[5] PIXEL

@ 060,010 Say STR0031 of oWizard:oMPanel[5] PIXEL//"Previsão de Reinício"
@ 057,065 MsGet dDtRein Valid dDtRein > dDataBase of oWizard:oMPanel[5] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de reajuste                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0032;//"Reajuste"
MESSAGE STR0033;//"Informe a data de inicio do reajuste"
PANEL NEXT {|| CN140VlP6(dDtReaj,dDtRefe) };
BACK {|| CN140BckPn(cCodTR,lCronog)};
FINISH {|| .T. } 

@ 030,010 Say STR0034 of oWizard:oMPanel[6] PIXEL//"Data Inicial"
@ 027,053 MsGet dDtReaj Valid CN140VdRea(dDtReaj) of oWizard:oMPanel[6] PIXEL   

If CN9->(FieldPos("CN9_DREFRJ")) > 0
	@ 055,010 Say STR0154 of oWizard:oMPanel[6] PIXEL//"Data Referencia"
	@ 052,053 MsGet dDtRefe of oWizard:oMPanel[6] PIXEL VALID Empty(dDtRefe) .Or. CN150VdApr(dDtRefe,dDtReaj,CN9->CN9_INDICE)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de alteracao de clausula                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0049;//"Alteração de Clausula"
MESSAGE STR0050;//"Informe as clausulas alteradas"
PANEL NEXT {|| CN140VlP7(cClaus) };
BACK {|| CN140BckPn(cCodTR,lCronog)};
FINISH {|| .T. }

@ 030,010 Say STR0051 of oWizard:oMPanel[7] PIXEL//"Clausula"
oClaus := tMultiget():New(030,050,{|u| if(Pcount()>0,cClaus:=u,cClaus)},oWizard:oMPanel[7],200,50,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de selecao das planilhas                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0035 ;//"Planilhas"
MESSAGE STR0036;//"Selecione as planilhas"
PANEL NEXT {|| CN140VlP8(cContra,If((lRevisad .And. (nRevRtp==1)),cNrevisa,cRevisa),cCodTr,aPlan,aItens,aHeaderIt,aColsIt,aCpoAlt,oPlan,aAlterCNB) };
BACK {|| CN140BckPn(cCodTR,lCronog,,aPlan,@cPlanAtu)};
FINISH {|| .T. }

oBrowse2	  := TWBrowse():New( 000, 000, __DlgWidth(oWizard:oMPanel[8]),If(lCN140NPla, __DlgHeight(oWizard:oMPanel[8])-12,__DlgHeight(oWizard:oMPanel[8])),,;
					{ "",RetTitle("CNA_NUMERO"),RetTitle("CNA_DTINI"),RetTitle("CNA_VLTOT"),RetTitle("CNA_DTFIM"),"Forn./Cliente","Loja",RetTitle("CNA_CRONOG")},;
					{ 030,090,030,030,030,030,030 }, oWizard:oMPanel[8],,,,,,,,,,,,,"TRBCNA", .T. )
			oBrowse2:bLine := {|| { If(aScan(aPlan,{|x| x[1]==TRBCNA->CNA_NUMERO})>0,oOk,oNo),TRBCNA->CNA_NUMERO,TRBCNA->CNA_DTINI,Transform(TRBCNA->CNA_VLTOT,PesqPict("CNA","CNA_VLTOT")),TRBCNA->CNA_DTFIM,If(!Empty(TRBCNA->CNA_FORNEC),TRBCNA->CNA_FORNEC,TRBCNA->CNA_CLIENT),If(!Empty(TRBCNA->CNA_LJFORN),TRBCNA->CNA_LJFORN,TRBCNA->CNA_LOJACL),TRBCNA->CNA_CRONOG}}
			oBrowse2:bLDblClick := {|| CN140MkPlan(aPlan,TRBCNA->CNA_NUMERO,TRBCNA->CNA_VLTOT,TRBCNA->CNA_CRONOG), oBrowse2:Refresh(), If(len(aPlan)>0,( oPlan:aItems := CN140PlanCb(aPlan), oPlan:nAt := 1, cPlanAtu := oPlan:aItems[1]),)}

If lCN140NPla
	@ 125 ,001 BUTTON oBtnNPla Prompt OemToAnsi(STR0004) SIZE 29 ,13 ACTION ExecBlock("CN140NPla",.F.,.F.,{cContra,If(lRevisad .And. nRevRtp==1,cNrevisa,cRevisa),nRevRtp}) OF oWizard:oMPanel[8] PIXEL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de itens de planilhas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;                 
HEADER STR0035 ;//"Planilhas"         
MESSAGE STR0044 ;//"Itens"
PANEL NEXT {|| CN140LoadIt(cPlan,aItens,aPlan,@cPlanAtu,cCodTR) .And. CN140VLIT(aPlan,aHeaderIt,aItens) .And. CN140VlP9(cContra,cRevisa,cNRevisa,cCodTR,aAditPlan,aPlan,aHeaderIt,aItens,aAditQtd,@dFContra) };
PANEL BACK {|| (Aviso("CNTA140",STR0090,{STR0091,STR0092})==2) .And. CN140BckPn(cCodTR,lCronog,,,@cPlanAtu) }//"As alterações serão perdidas, deseja realmente voltar?"##"Não"##"Sim"

@ 010,001 Say STR0035 Of oWizard:oMPanel[9] PIXEL//"Planilhas"

@ 008,026 ComboBox oPlan Var cPlan SIZE 40,8 ON CHANGE (If(oWizard:NPanel==9,(If(CN140LoadIt(cPlan,aItens,aPlan,@cPlanAtu,cCodTR),(oGetDad1:nAt:=1,CN140ChgGet(Posicione("CN0",1,xFilial("CN0")+cCodTr,"CN0_TIPO"),aAlterCNB),oGetDad1:oBrowse:Refresh()),(cPlan:=cPlanAtu,oPlan:Refresh()))),)) OF oWizard:oMPanel[9] PIXEL

If Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_ESPCTR") == '2' .And. AliasInDic("AGW") .And. SuperGetMV("MV_CNINTFS",.F.,.F.) .And. FindFunction("CN200Loca")
	@ 008,230 BUTTON oButAGW Prompt STR0132 SIZE 50,10 ACTION CN200Loca(cContra,cRevisa,TRBCNA->CNA_NUMERO,oGetDad1,aTail(aPlan[oPlan:nAt]),aPlan,.F.,TRBCNA->CNA_CLIENT,TRBCNA->CNA_LOJACL) OF oWizard:oMPanel[9] PIXEL //-- Local. Física
EndIf

@ 005,090 GROUP oGrpPlO To 020,180 Label STR0097 Of oWizard:oMPanel[9] PIXEL//"Valor Original"
@ 010,130 Say oVlPOri Var 0 Size 50,8 Picture PesqPict("CNA","CNA_VLTOT") Of oWizard:oMPanel[9] PIXEL

@ 005,190 GROUP oGrpPlA To 020,280 Label STR0098 Of oWizard:oMPanel[9] PIXEL//"Valor Atual"
@ 010,230 Say oVlPAtu Var nVlPAtu Size 50,8 Picture PesqPict("CNA","CNA_VLTOT") Of oWizard:oMPanel[9] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de selecao dos cronogramas                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE  PANEL oWizard;
HEADER STR0059;//"Cronogramas - Alteraão"
MESSAGE STR0060;//"Selecione o cronograma e informe os dados de alteração do cronograma"
NEXT {|| CN140VlP10(@aParcelas,aTotCont,cContra,cRevisa,aCron,lArrasto,lDist,@oTpCron,nParcel,@cCronO,@dFContra,cCodTR,aAditPlan,@nVgAdit,aHeadParc,aColsParc,aFscVl,aAditQtd,aHeaderIT,aItens,oBtnFsc,aParAnt,aParVlR) };
PANEL BACK {|| CN140BckPn(cCodTR,lCronog,aCron) };
FINISH {|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura browse com arquivo temporario CNF         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


oBrowse4 := TWBrowse():New( 000, 000, __DlgWidth(oWizard:oMPanel[10]), __DlgHeight(oWizard:oMPanel[10])-50,,;
{ "",RetTitle("CNF_CONTRA"),RetTitle("CNF_REVISA"),RetTitle("CNF_NUMERO"),RetTitle("CNF_COMPET"),RetTitle("CNF_SALDO") }, ;
{ 050,050,050,050,050 }, oWizard:oMPanel[10], , , ,,,,,,,,,,"TRBCNF", .T. )
oBrowse4:bLine := {|| { If(aScan(aCron,TRBCNF->CNF_NUMERO)>0,oOk,oNo), TRBCNF->CNF_CONTRA,TRBCNF->CNF_REVISA,TRBCNF->CNF_NUMERO,TRBCNF->CNF_COMPET,Transform(TRBCNF->CNF_SALDO,PesqPict("CNF","CNF_SALDO")) } }
oBrowse4:bLDblClick := {|| CN140MkCron(aCron,TRBCNF->CNF_NUMERO), oBrowse4:Refresh(),oCron:aItems := ASort(aCron), oCron:nAt := 1 }

// Considera o ultimo dia do mês, quando não houver o dia do vencimento da parcela
@ 110,030 Checkbox oUltimoDia VAR lUltimoDia PROMPT STR0152 OF oWizard:oMPanel[10] PIXEL SIZE 60,09 //"Último dia do mês"

@ 120,030 CheckBox oArrasto VAR lArrasto PROMPT STR0061 OF oWizard:oMPanel[10] PIXEL SIZE 60,09 ON CLICK( ( oDist:lActive := lArrasto ))//"Arrasto"
@ 130,030 CheckBox oDist VAR lDist PROMPT STR0062 OF oWizard:oMPanel[10] PIXEL SIZE 60,09 WHEN lArrasto//"Redistribuir Saldos"

@ 110,140 Say STR0065 Of oWizard:oMPanel[10] PIXEL//"Tipo"
@ 110,185 ComboBox oTpCron Var cTpCron When lAltPar ON CHANGE lTpCron := .T. SIZE 60,5 OF oWizard:oMPanel[10] PIXEL

@ 125,140 Say STR0063 Of oWizard:oMPanel[10] PIXEL//"Nº. de Parcelas"
@ 125,185 MsGet nParcel Picture "999" When lAltPar Size 60,5 Of oWizard:oMPanel[10] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de parcelas dos cronogramas                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE  PANEL oWizard;
HEADER STR0059;//"Cronogramas - Alteração"
MESSAGE STR0066;//"Parcelas e confirmação do cronograma"
NEXT {|| CN140VlP11(cContra,cRevisa,cCron,@aParcelas,aCron,aTotCont,aFscVl,aColsParc,aHeadParc)};
PANEL BACK {|| CN140BckPn(cCodTR,lCronog,aCron,,,@cCron)};
FINISH {|| .T. }

@ 010,001 Say STR0079 Of oWizard:oMPanel[11] PIXEL//"Cronogramas"
@ 008,036 ComboBox oCron Var cCron SIZE 40,8 ON CHANGE If(oWizard:NPanel==11,CN140LoadPr(@cCron,@aParcelas,aCron,aTotCont,@cCronO,oCron,aHeadParc,aColsParc,aFscVl),) OF oWizard:oMPanel[11] PIXEL

@ 023,005 GROUP oGroup To 038,090 Label STR0067 Of oWizard:oMPanel[11] PIXEL//"Montante das Planilhas "
@ 028,040 Say oTotPlan Var nTotPlan Picture PesqPict("CNA","CNA_VLTOT") Of oWizard:oMPanel[11] PIXEL

@ 023,100 GROUP oGroup To 038,190 Label STR0068 Of oWizard:oMPanel[11] PIXEL//"Montante do Cronograma "
@ 028,140 Say oTotCronog Var nTotCronog Size 50,8 Picture PesqPict("CNF","CNF_VLPREV") Of oWizard:oMPanel[11] PIXEL

@ 023,200 GROUP oGroup To 038,285 Label STR0069 Of oWizard:oMPanel[11] PIXEL//"Saldo a Distribuir "
@ 028,240 Say oSaldDist Var nTotPlan-nTotCronog Size 50,8 Picture PesqPict("CNA","CNA_VLTOT") Of oWizard:oMPanel[11] PIXEL

@ 120,005 GROUP oGroup To 135,090 Label STR0070 Of oWizard:oMPanel[11] PIXEL//"Saldo do Contrato"
@ 125,040 Say oSaldCont Var nSaldCont Size 50,8 Picture PesqPict("CN9","CN9_VLATU") Of oWizard:oMPanel[11] PIXEL

@ 120,100 GROUP oGroup To 135,185 Label STR0071 Of oWizard:oMPanel[11] PIXEL//"Saldo das Planilhas"
@ 125,140 Say oSaldPlan Var nSaldPlan Size 50,8 Picture PesqPict("CN9","CN9_VLATU") Of oWizard:oMPanel[11] PIXEL

@ 120 ,256 BUTTON oBtnFsc Prompt OemToAnsi(STR0101) SIZE 29 ,13 ACTION {(nPos:=aScan(aCron,cCron),CN140Fisico(4,@aParcelas[nPos],oGetDados:nAt,aColsParc[nPos],aHeadParc,aFscVl[nPos],cCodTR),oGetDados:aCols:=aParcelas[nPos],CN110AtuVal(),oGetDados:oBrowse:Refresh(),aFscVl[nPos] := aItVl) } OF oWizard:oMPanel[11] PIXEL//Fisico

If FindFunction("CN110ReSld") .And. !lFisico
	@ 122 ,200 BUTTON oBtlDSld Prompt STR0125 Size 40,13 ACTION CN110ReSld(aParAnt[aScan(aParAnt,{|x| x[1] == cCron}),2],aParVlR[aScan(aParVlR,{|x| x[1] == cCron}),2]) OF oWizard:oMPanel[11] PIXEL //Redistribuir
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel dos Cronogramas Contabeis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE  PANEL oWizard;
HEADER STR0104; //"Cronogramas Contábeis - Revisão"
MESSAGE OemToAnsi(STR0017);//"Selecione o cronograma e informe os dados de alteração do cronograma"
BACK {|| CN140BckPn(cCodTR,lCronog)};
NEXT {|| CN140RvPlCt(@aCronCtb,@aItensCtb,cContra,If((lRevisad .And. (nRevRtp==1)),cNrevisa,cRevisa),cNrevisa,aAditPlan,aCpoCNW,@nVgAdit,@dFContra,@cCtbO,aTotCtb)};
FINISH {|| .T. }		

If(!Empty(cArqCNV))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura browse com arquivo temporario CNV         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowse5 := TWBrowse():New( 000, 000, __DlgWidth(oWizard:oMPanel[12])-1, __DlgHeight(oWizard:oMPanel[12])-60,,;
   { "",RetTitle("CNV_NUMERO"),RetTitle("CNV_PLANIL"),RetTitle("CNV_CONTRA")}, ;
   { 050,050,050}, oWizard:oMPanel[12],,,,,,,,,,,,,"TRBCNV",.T.)
   oBrowse5:bLine := {|| {If(aScan(aCronCtb,TRBCNV->CNV_NUMERO)>0,oOk,oNo),TRBCNV->CNV_NUMERO,TRBCNV->CNV_PLANIL,TRBCNV->CNV_CONTRA} }
   oBrowse5:bLDblClick := {|| CN140MkCtbCron(aCronCtb,TRBCNV->CNV_NUMERO),oBrowse5:Refresh(),oCtbCron:aItems:=ASort(aCronCtb), oCtbCron:nAt := 1 }
EndIf          
      
@ 100,140 Say STR0102 Of oWizard:oMPanel[12] PIXEL//"Tipo"
@ 100,185 ComboBox oTpCronCtb Var cTpCronCtb When lAltPar ON CHANGE lTpCron := .T. SIZE 60,5 OF oWizard:oMPanel[12] PIXEL
@ 115,140 Say STR0103 Of oWizard:oMPanel[12] PIXEL//"Nº. de Parcelas"
@ 115,185 MsGet nParcelas Picture "999" When lAltPar Size 60,5 Of oWizard:oMPanel[12] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de parcelas dos cronogramas Contabeis        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE  PANEL oWizard;
HEADER STR0105; //"Finalização"
MESSAGE STR0106;//"Parcelas e confirmação do cronograma"
NEXT {|| CN140VldCtb(cCtbCron,aCronCtb,aTotCtb,aItensCtb) };
BACK {|| CN140BckPn(cCodTR,lCronog)};
FINISH {|| .T. }

@ 005,001 Say STR0079 Of oWizard:oMPanel[13] PIXEL//"Cronogramas"
@ 005,036 ComboBox oCtbCron Var cCtbCron SIZE 40,8 ON CHANGE If(oWizard:NPanel==13,(CN140CtbLoad(@cCtbCron,@aItensCtb,@aCronCtb,aAditPlan,cContra,aCpoCNW,@cCtbO,oCtbCron,aTotCtb),CN140Get2Chg(aCpoCNW),oGetCtb:oBrowse:Refresh()),) OF oWizard:oMPanel[13] PIXEL

@ 023,001 GROUP oGroup To 038,085 Label STR0067 Of oWizard:oMPanel[13] PIXEL//"Montante das Planilhas "
@ 028,040 Say oTotPlan Var nTotPlan Picture PesqPict("CNW","CNW_VLPREV") Of oWizard:oMPanel[13] PIXEL

@ 023,100 GROUP oGroup To 038,185 Label STR0068 Of oWizard:oMPanel[13] PIXEL//"Montante do Cronograma "
@ 028,140 Say oTotCronog Var nTotCronog Size 50,8 Picture PesqPict("CNW","CNW_VLPREV") Of oWizard:oMPanel[13] PIXEL

@ 023,200 GROUP oGroup To 038,275 Label STR0069 Of oWizard:oMPanel[13] PIXEL//"Saldo a Distribuir "
@ 028,235 Say oSaldDist Var nTotPlan-nTotCronog Size 50,8 Picture PesqPict("CNW","CNW_VLPREV") Of oWizard:oMPanel[13] PIXEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel Troca de Indice DEF_INDIC                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0140;			//"Troca de Indice"
MESSAGE STR0021;//"Selecione o andamento da revisao"
PANEL NEXT {|| CN140Indice("2",cIndAtu,cIndNovo) };                
BACK {|| CN140Indice("3",cIndAtu,@cIndNovo) }

@ 030,010 Say STR0022 of oWizard:oMPanel[14] PIXEL//"Contrato"
@ 027,045 MsGet cContra Picture PesqPict("CN9","CN9_NUMERO") Size 55,5 When .F. of oWizard:oMPanel[14] PIXEL

@ 045,010 Say STR0027 of oWizard:oMPanel[14] PIXEL//"Tipo Revisão"
@ 042,045 MsGet Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_DESCRI") Size 150,5 When .F. of oWizard:oMPanel[14] PIXEL

//-- Solicita a troca do indice      

@ 060,010 Say STR0141 Of oWizard:oMPanel[14] PIXEL		//"Indice Atual"
@ 060,045 MsGet cIndAtu Picture PesqPict("CN9","CN9_INDICE") When .F. Of oWizard:oMPanel[14] PIXEL
@ 060,075 MsGet Posicione("CN6",1,xFilial("CN6")+cIndAtu,"CN6_DESCRI") When .F. of oWizard:oMPanel[14] PIXEL

@ 075,010 Say STR0142 Of oWizard:oMPanel[14] PIXEL		//"Novo Indice"
@ 075,045 MsGet cIndNovo Picture PesqPict("CN9","CN9_INDICE") F3 "CN6" Valid NaoVazio() .And. ExistCpo("CN6") .And. CN140Indice("1",cIndAtu,cIndNovo) Of oWizard:oMPanel[14] PIXEL
@ 075,075 MsGet Posicione("CN6",1,xFilial("CN6")+cIndNovo,"CN6_DESCRI") When .F. of oWizard:oMPanel[14] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel Troca de Fornecedor DEF_FORNE                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER If(CNC->(FieldPos("CNC_CLIENT"))>0,STR0143,STR0158);		//"Troca de Fornecedor/Cliente"
MESSAGE If(CNC->(FieldPos("CNC_CLIENT"))>0,STR0159,STR0160);	//"Informe os novos Fornecedores/Clientes que irão substituir os atuais."
PANEL NEXT {|| CN140Forne("3") };                
BACK {|| CN140Forne("4") }

@ 010,010 Say STR0022 of oWizard:oMPanel[15] PIXEL//"Contrato"
@ 010,045 MsGet cContra Picture PesqPict("CN9","CN9_NUMERO") Size 55,5 When .F. of oWizard:oMPanel[15] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Painel de justificativa - finalizacao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CREATE PANEL oWizard;
HEADER STR0040;//"Finalização"
MESSAGE STR0041;//"Informe a justificativa da revisao"
PANEL NEXT {|| .T. };                
BACK {|| CN140BckPn(cCodTR,lCronog,,,,,,aHeaderIt,aItens,aPlan,cRevisa)};
FINISH {||  Cn140VldGCP(cContra,cRevisa,dFContra) .And. CN140GerRev(cContra,cRevisa,cCodTR,cJust,cCodPr,dDtRein,dDtReaj,cClaus,aItens,aPlan,@aParcelas,aCron,dFContra,aHeaderIt,aHeadParc,aColsParc,aItensCtb,nValor,lAltVlr,nVgAdit,,,,dDtRefe) }

@ 030,012 Say STR0042 of oWizard:oMPanel[16] PIXEL//"Justificativa"
oMemo := tMultiget():New(030,050,{|u|if(Pcount()>0,cJust:=u,cJust)},oWizard:oMPanel[16],200,50,,,,,,.T.)

@ 090,012 Say STR0022 of oWizard:oMPanel[16] PIXEL//"Contrato"
@ 087,050 MsGet cContra Picture PesqPict("CN9","CN9_NUMERO") Size 55,5 When .F. of oWizard:oMPanel[16] PIXEL

@ 090,112 Say STR0043 of oWizard:oMPanel[16] PIXEL//"Revisão Gerada"
@ 087,155 MsGet Soma1(if(Empty(cRevisa),strzero(0,TamSX3("CN9_REVISA")[1]),cRevisa)) Picture PesqPict("CN9","CN9_REVISA") Size 20,5 When .F. of oWizard:oMPanel[16] PIXEL

@ 105,012 Say RetTitle("CN9_VIGE") Of oWizard:oMPanel[16] PIXEL//"Vigencia"
@ 102,050 MsGet nVgAdit Picture PesqPict("CN9","CN9_VIGE") VALID CN140DtFim(@dFContra,nVgAdit,cContra,cRevisa) Size 55,5 When (lAltPar .AND. lAltVig) of oWizard:oMPanel[16] PIXEL

@ 105,112 Say RetTitle("CN9_UNVIGE") Of oWizard:oMPanel[16] PIXEL//"Unid. Vigencia"
@ 102,155 ComboBox oUnVig VAR cDescrVig ITEMS aUnVig VALID CN140AtuDtFim(@dFContra,cContra,cRevisa) Size 55,5 When (lAltPar .AND. lAltVig) of oWizard:oMPanel[16] PIXEL

@ 120,012 Say STR0095 Of oWizard:oMPanel[16] PIXEL//"Dt Termino"
@ 117,050 MsGet dFContra Picture PesqPict("CN9","CN9_DTFIM") Valid CN140VldDFim(dFContra,cCodTR,cContra,cRevisa) Size 55,5 When .F. of oWizard:oMPanel[16] PIXEL

@ 120,112 Say STR0114 Of oWizard:oMPanel[16] PIXEL//"Valor"
@ 117,155 MsGet nValor Picture PesqPict("CN9","CN9_VLATU") Valid CN140VldVl(nSaldo,nVlOri,nValor,cCodTR) Size 55,5 When lAltVlr of oWizard:oMPanel[16] PIXEL

ACTIVATE WIZARD oWizard CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo temporario dos cronogramas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cArqCN9)
	TRBCN9->(dbCloseArea())
	FErase(cArqCN9 + ".DBF")
	FErase(cArqCN9 + OrdBagExt() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo temporario das planilhas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ         
If !Empty(cArqCNA)
	TRBCNA->(dbCloseArea())
	FErase(cArqCNA + ".DBF")
	FErase(cArqCNA + OrdBagExt() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo temporario dos cronogramas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cArqCNF)
	TRBCNF->(dbCloseArea())
	FErase(cArqCNF + ".DBF")
	FErase(cArqCNF + OrdBagExt() )
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo temporario dos cronogramas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cArqCNV)
	TRBCNV->(dbCloseArea())
	FErase(cArqCNV + ".DBF")
	FErase(cArqCNV + OrdBagExt() )
EndIf   

If !Empty(cArqCNW)
	TRBCNW->(dbCloseArea())
	FErase(cArqCNW + ".DBF")
	FErase(cArqCNW + OrdBagExt() )
EndIf   

//Finaliza lancamentos do SIGAPCO		
PcoFinLan("000357")  
PcoFreeBlq("000357")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldMPar³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Motivo de paralisacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldMPar(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ -cExp01 - Codigo de paralisacao selecionado                  ³±±
±±³          ³ -cExp02 - Descricao do codigo de paralisacao - referencia    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/     
Function CN140VldMPar(cCodPr,cDescPr)
Local lRet := .T.
      
dbSelectArea("CN2")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona motivo de paralisacao do contrato e       ³
//³ preenche descricao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek(xFilial("CN2")+cCodPr)
	cDescPr := CN2->CN2_DESCRI
Else
	Help("CNTA140", 1, "REGNOIS")
	lRet := .F.
EndIf 

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldCodTr³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida tipo de revisao selecionado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldCodTr(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ -cExp01 - Codigo do tipo de revisao                           ³±±
±±³          ³ -cExp02 - Descricao do tipo de revisao - referencia           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldCodTr(cCodTr,cDescTR,cTipoCtr)
Local lRet := .T.
      
dbSelectArea("CN0")
dbSetOrder(1)                                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona tipo de revisao do contrato e preenche    ³
//³ descricao                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek(xFilial("CN0")+cCodTr)
	cDescTr := CN0->CN0_DESCRI
	cTipoCtr:= CN0->CN0_TIPO
   cEspec  := CN0->CN0_ESPEC
   
Else
	Help("CNTA140", 1, "REGNOIS")
	lRet := .F.
EndIf 

Return lRet               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140LContra ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega contratos filtrando pelo tipo de revisao e pela       ³±±
±±³          ³ situacao                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LContra(cExp01,nExp02)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Tipo de Revisao                                      ³±±
±±³          ³ nExp02 - Registro Atual                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140LContra(cCodTR,nReg)
Local cQuery      := ""     
Local cQueryPE    := ""
Local cEspCtr	  := ""
Local lRet        := .T.       
Local aArea       := GetArea()   
Local cEspec      := CN0->CN0_ESPEC  

cTpRev := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_TIPO")     

dbSelectArea("CN9")     
dbgoto(nReg)

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf    

cContra := CN9->CN9_NUMERO
cIndAtu := CN9->CN9_INDICE

cQuery := "SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_DTINIC, CN9.CN9_DTFIM, CN9.CN9_CONDPG, "
cQuery += "       CN9.CN9_SITUAC, CN9.CN9_SALDO,  CN9.CN9_TIPREV, CN9.CN9_REVATU "
cQuery += "  FROM "+RetSqlName("CN9")+" CN9, "+RetSqlName("CN1")+" CN1 "
cQuery += " WHERE CN9.CN9_FILIAL = '"+xFilial("CN9")+"'"
cQuery += "   AND CN1.CN1_FILIAL = '"+xFilial("CN1")+"'"
cQuery += "   AND CN9.CN9_TPCTO  = CN1.CN1_CODIGO "
cQuery += "   AND CN9.CN9_NUMERO = '"+cContra+"'"
cQuery += "   AND "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra contratos vigentes ou paralisados quando     ³
//³ for revisao de reinicio                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cTpRev == DEF_REINI                         
	cQuery += " CN9.CN9_SITUAC in ('"+ DEF_SPARA +"') AND "
Else
	cQuery += " CN9.CN9_SITUAC in ('"+ DEF_SVIGE +"') AND "    
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra os contratos com controle contabil           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTpRev == DEF_CRCTB
	cQuery += " CN1.CN1_CROCTB = '1' AND "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra contratos com controle de reajuste           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTpRev == DEF_REAJU//Aceita reajuste
	cQuery += "CN9.CN9_FLGREJ = '1' AND "
EndIf
If (CN1->( FieldPos("CN1_CTRFIX") ) > 0) .AND. ((cTpRev == DEF_ADITI .And. cEspec = '1') .OR. (cTpRev == DEF_READQ))
	cQuery += " CN1.CN1_CTRFIX = '1' AND "
EndIf
//-- Fornecedor somente contrato compra
If	cTpRev == DEF_FORNE .And. CNC->(FieldPos("CNC_CLIENT")) == 0
	cQuery += " CN1.CN1_ESPCTR = '1' AND "
EndIf

//-- Nao permite revisar contrato de edital quando nao tiver a regra ou quando for troca de fornecedor 
If	CN9->(FieldPos("CN9_CODED")) > 0 .And. (CO1->(FieldPos("CO1_REFORM")) == 0 .Or. cTpRev == DEF_FORNE)
	cQuery += " CN9.CN9_CODED = '' AND "
EndIf

cQuery += " CN9.D_E_L_E_T_ = ' ' AND "
cQuery += " CN1.D_E_L_E_T_ = ' ' "    

If Existblock('CN140QRY')
	cQueryPE := Execblock('CN140QRY', .F., .F., {cQuery})
	cQuery   := If(ValType(cQueryPE)=='C', cQueryPE, cQuery)
Endif
				
cQuery += " ORDER BY "+SqlOrder(CN9->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

//Configura campos especificos
TCSetField("TRB","CN9_DTINIC","D",08,0)
TCSetField("TRB","CN9_DTFIM" ,"D",08,0)
TCSetField("TRB","CN9_SALDO" ,"N",TamSX3("CN9_SALDO")[1],TamSX3("CN9_SALDO")[1])

dbSelectArea("TRB")
dbGoTop()
	
If !Eof()
	
	dbSelectArea("TRBCN9")
	If RecCount() > 0
		Zap
	Endif
	
	dbSelectArea("TRB")
	While !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona registros filtrados ao arquivo temporario  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("TRBCN9",.T.)
			TRBCN9->CN9_NUMERO := TRB->CN9_NUMERO
			TRBCN9->CN9_REVISA := TRB->CN9_REVISA
			TRBCN9->CN9_DTINIC := TRB->CN9_DTINIC
			TRBCN9->CN9_DTFIM  := TRB->CN9_DTFIM
			TRBCN9->CN9_CONDPG := TRB->CN9_CONDPG
			TRBCN9->CN9_SITUAC := TRB->CN9_SITUAC
			TRBCN9->CN9_SALDO  := TRB->CN9_SALDO
			TRBCN9->CN9_TIPREV := TRB->CN9_TIPREV
			TRBCN9->CN9_REVATU := TRB->CN9_REVATU
		MsUnlock()
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRBCN9->(dbGoTop())	
Else
	Help("CNTA140",1,"CNTA140_20")//"Não há contratos vigentes"##"Atenção"
	lRet := .F.
Endif

TRB->(dbCloseArea())   
cContra:= ""
RestArea(aArea)

Return lRet    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140LPlan³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega planilhas do contrato                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LPlan(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do Contrato                                ³±±
±±³          ³ cExp02 - Codigo da Revisao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140LPlan(cContra,cRevisa)
Local cQuery := ""     
Local lRet := .T.       
Local aArea := GetArea()
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra planilhas do contrato                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNA.CNA_NUMERO, CNA.CNA_DTINI, CNA.CNA_VLTOT, CNA.CNA_DTFIM, CNA.CNA_FORNEC, "
cQuery += "       CNA.CNA_LJFORN, CNA.CNA_CRONOG, CNA.CNA_CONTRA, CNA.CNA_REVISA, CNA.CNA_CLIENT, CNA.CNA_LOJACL "
cQuery += "  FROM "+RetSqlName("CNA")+" CNA "
cQuery += " WHERE CNA.CNA_FILIAL =  '"+xFilial("CNA")+"'"
cQuery += "   AND CNA.CNA_CONTRA = '"+cContra+"'"
cQuery += "   AND CNA.CNA_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNA.D_E_L_E_T_ = ' '"    

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

//Configura campos especificos
TCSetField("TRB","CNA_DTINI","D",08,0)
TCSetField("TRB","CNA_DTFIM" ,"D",08,0)
TCSetField("TRB","CNA_VLTOT" ,"N",TamSX3("CNA_VLTOT")[1],TamSX3("CNA_VLTOT")[2])

dbSelectArea("TRB")
dbGoTop()
	
If !Eof()
	
	dbSelectArea("TRBCNA")
	If RecCount() > 0
		Zap
	Endif
	
	dbSelectArea("TRB")
	While !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona registros filtrados ao arquivo temporario  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("TRBCNA",.T.)
			TRBCNA->CNA_CONTRA := TRB->CNA_CONTRA
			TRBCNA->CNA_REVISA := TRB->CNA_REVISA
			TRBCNA->CNA_NUMERO := TRB->CNA_NUMERO
			TRBCNA->CNA_DTINI  := TRB->CNA_DTINI
			TRBCNA->CNA_VLTOT  := TRB->CNA_VLTOT
			TRBCNA->CNA_DTFIM  := TRB->CNA_DTFIM
			TRBCNA->CNA_FORNEC := TRB->CNA_FORNEC
			TRBCNA->CNA_LJFORN := TRB->CNA_LJFORN
			TRBCNA->CNA_CRONOG := TRB->CNA_CRONOG
			TRBCNA->CNA_CLIENT := TRB->CNA_CLIENT
			TRBCNA->CNA_LOJACL := TRB->CNA_LOJACL			
		MsUnlock()
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRBCNA->(dbGoTop())	
Else
	Help("CNTA140",1,"CNTA140_02")//"Não há planilha para o contrato selecionado"##"Atenção"
	lRet := .F.
Endif

TRB->(dbCloseArea())   

RestArea(aArea)
 
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140LCron³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Cronogramas                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LCron(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ -cExp01 - Codigo do Contrato                               ³±±
±±³          ³ -cExp02 - Codigo da Revisao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140LCron(cContra,cRevisa)
Local cQuery := ""     
Local lRet := .T.       
Local aArea := GetArea()
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra cronogramas do contrato                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNF.CNF_FILIAL, CNF.CNF_NUMERO, CNF.CNF_CONTRA, CNF.CNF_REVISA, "
cQuery += "       Min(CNF.CNF_COMPET) as CNF_COMPET, Sum(CNF.CNF_SALDO) as CNF_SALDO "
cQuery += "  FROM "+RetSqlName("CNF")+" CNF "
cQuery += " WHERE CNF.CNF_FILIAL =  '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNF.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY CNF.CNF_FILIAL, CNF.CNF_NUMERO, CNF.CNF_CONTRA, CNF.CNF_REVISA"
  
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

//Configura campos especificos
TCSetField("TRB","CNF_SALDO" ,"N",TamSX3("CNF_SALDO")[1],TamSX3("CNF_SALDO")[2])

dbSelectArea("TRB")
dbGoTop()
	
If !Eof()
	
	dbSelectArea("TRBCNF")
	If RecCount() > 0
		Zap
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia cronogramas para arquivo temporario           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRB")
	While !Eof()
		RecLock("TRBCNF",.T.)
			TRBCNF->CNF_NUMERO := TRB->CNF_NUMERO
			TRBCNF->CNF_CONTRA := TRB->CNF_CONTRA
			TRBCNF->CNF_REVISA := TRB->CNF_REVISA
			TRBCNF->CNF_COMPET := TRB->CNF_COMPET
			TRBCNF->CNF_SALDO  := TRB->CNF_SALDO
			MsUnlock()
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRBCNF->(dbGoTop())	
Else
	Help("CNTA140",1,"CNTA140_03")//"O contrato não possui cronogramas"##"Atenção"
	lRet := .F.
Endif

TRB->(dbCloseArea())   

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140MkContra   ³ Autor ³ Marcelo Custodio            ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza selecao do contrato na tela e atualiza campos de controle      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140MkContra(cExp01,cExp02,cExp03,cExp04,cExp05,dExp06,dExp07,cExp08) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ -cExp01 - Contrato - Referencia                                        ³±±
±±³          ³ -cExp02 - Revisao  - Referencia                                        ³±±
±±³          ³ -cExp03 - Clausula - Referencia                                        ³±±
±±³          ³ -cExp04 - Codigo de paralisacao - Referencia                           ³±±
±±³          ³ -cExp05 - Descricao do tipo de paralisacao - Referencia                ³±±
±±³          ³ -dExp06 - Data de reinicio - Referencia                                ³±±
±±³          ³ -dExp07 - Data de Reajuste - Referencia                                ³±±
±±³          ³ -cExp08 - Justificativa - Referencia                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140MkContra(cContra,cRevisa,cClaus,cCodPr,cDescPr,dDtRein,dDtReaj,cJust,cIndAtu)
cContra :=TRBCN9->CN9_NUMERO
cRevisa :=TRBCN9->CN9_REVISA
cIndAtu :=TRBCN9->CN9_INDICE
//Limpa parametros de revisao
cClaus  := ""
cCodPr  := Space(TamSX3("CN2_CODIGO")[1])
cDescPr := ""
dDtRein := CTOD("  /  /  ")
dDtReaj := CTOD("  /  /  ")
cJust   := ""
Return                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP2 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 2 - Tipo de revisao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP2(cExp01,nExp02)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do tipo de revisao                         ³±±
±±³          ³ nExp02 - Registro Atual				                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP2(cCodTR,nReg)
Local lRet := .T.
Local lCn140ctaut := ExistBlock("CN140CTAUT")
Local cCn140ctaut := ""
                                                                   
if Empty(cCodTR)
	lRet := .F.
	Help("CNTA140",1,"CNTA140_04")//"Selecione o tipo de revisão"
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Ponto de Entrada para selecao automatica do contrato |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCn140ctaut .and. Valtype(cCn140ctaut := ExecBlock("CN140CTAUT",.F.,.F.))=="C"
		cContra := cCn140ctaut
	EndIf
	lRet := CN140LContra(cCodTR,nReg)
	//-- a funcao cn140lcontra, posiciona a tabela cn9 e preenche a variavel cTpRev
EndIf

Return lRet  
             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP5 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 5 - Tipo de Paralisacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP5(cExp01,dExp02)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo de paralisacao                             ³±±
±±³          ³ dExp02 - Data de reinicio                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP5(cCodPr,dDtRein)
Local lRet := .T.
                                 
if Empty(cCodPr)
	Help("CNTA140",1,"CNTA140_05")//"Preencha o motivo de paralisação"
	lRet := .F.
ElseIf Empty(dDtRein)
	Help("CNTA140",1,"CNTA140_05")//"Preencha a data de previsão de reinício"
	lRet := .F.
EndIf            

If lRet
	oWizard:NPanel := 15//Segue para painel final
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP6 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Painel numero 6 - Reajuste                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP6(dExp01)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp01 - Data de Reajuste                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP6(dDtReaj,dDtRef)
Local lRet := .T.
                                 
If Empty(dDtReaj)
	Help("CNTA140",1,"CNTA140_07")//"Preencha a data de início do reajuste"
	lRet := .F.
EndIf

If Empty(dDtRef)
	Help("CNTA140",1,"CNTA140_24")//"Preencha a data de referência do reajuste"
	lRet := .F.
EndIf            

If lRet
	oWizard:NPanel := 15//Segue para painel final
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP3 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 3 - Contratos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP3(cExp01,cExp02,cExp03,cExp04,cExp05,dExp06,lExp07,³±±
±±³          ³           lExp08,oExp09,nExp10)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do tipo de revisao - referencia            ³±±
±±³          ³ cExp02 - Codigo do contrato selecionado                    ³±±
±±³          ³ cExp03 - Codigo da revisao selecionada                     ³±±
±±³          ³ cExp04 - Codigo da nova revisao - referencia               ³±±
±±³          ³ cExp05 - Descricao do tipo de revisao - referencia         ³±±
±±³          ³ dExp06 - Data de termino do contrato - referencia          ³±±
±±³          ³ lExp07 - Altera cronograma  - referencia                   ³±±
±±³          ³ lExp08 - Altera parcelas de cronograma  - referencia       ³±±
±±³          ³ oExp09 - Campo para selecao de acrescimo/decrescimo para   ³±±
±±³          ³          cronogramas                                       ³±±
±±³          ³ nExp10 - Vigencia do contrato - referencia                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP3(cCodTR,cContra,cRevisa,cNrevisa,cDescTR,dFContra,lCronog,lAltPar,oTpCron,nVgAdit,nValor,lAltVlr,lAltVig,nSaldo,nVlOri)

Local lRet      := .T.  
Local lRedParc  := GetMv("MV_CNREDUP")
Local lCn140vct := .T. 
Local cQuery    := ""
Local cAlias    := "" 
Local cAliasCNA := ""
Local cUnVig

If Empty(cContra)
	lRet := .F.
	Help("CNTA140",1,"CNTA140_08")//"Selecione um contrato"
EndIf

If lRet
	dbSelectArea("CN9")
	dbSetOrder(1)
	If dbSeek(xFilial("CN9")+cContra+cRevisa)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica vigencia do contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dDataBase < CN9_DTINIC
			Aviso("CNTA140",STR0115,{"OK"})//"O contrato não se encontra dentro do período de vigência"
			lRet := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe medicao em aberto para o contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			cAlias := GetNextAlias()
			
			cQuery := "SELECT COUNT(*) AS QTD "
			cQuery += "  FROM "+RetSQLName("CND")+" CND "
			cQuery += " WHERE CND.CND_FILIAL = '"+xFilial("CND")+"'"
			cQuery += "   AND CND.CND_CONTRA = '"+cContra+"'"
			cQuery += "   AND CND.CND_DTFIM  = ''"
			cQuery += "   AND CND.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
			
			If (cAlias)->QTD > 0
				Aviso("CNTA140",STR0122,{"OK"})//"O contrato selecionado possui medição em aberto. Encerre a medição antes de gerar a revisão."
				lRet := .F.
			EndIf
			
			(cAlias)->(dbCloseArea())
		EndIf
	Else
		lRet := .F.
	EndIf                                
EndIf

If lRet                                                           
	dbSelectArea("CN0")
	dbSetOrder(1)
	dbSeek(xFilial("CN0")+cCodTR)
	
	cTpRev  := CN0->CN0_TIPO
	cEspc   := CN0->CN0_ESPEC
	cModo   := CN0->CN0_MODO

	lMedeve  := (Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_MEDEVE") == "1")
	lFisico  := ((CN1->(FieldPos("CN1_CROFIS")) > 0) .And. Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROFIS") == "1")
	
	If  (CN1->(FieldPos("CN1_CTRFIX")) > 0) .AND. (CN1->(FieldPos("CN1_VLRPRV")) > 0)
		lFixo := Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CTRFIX") == "1"
		lVlPrv:= Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_VLRPRV") == "1"
	EndIf
	
	lContab  := (Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROCTB") == "1")
	dFContra := dFCronog := CN9->CN9_DTFIM
	nVlOri   := nValor   := CN9->CN9_VLATU
	nSaldo   := CN9->CN9_SALDO
	lAltVig  := (CN9->CN9_UNVIGE != "4")//Contrato com vigencia indeterminada

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o contrato possui revisao nao aprovada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If (AllTrim(CN9->CN9_SITUAC) == DEF_SVIGE .OR. AllTrim(CN9->CN9_SITUAC) == DEF_SPARA) .And. !Empty(CN9->CN9_REVATU)
		lRevisad := .T.
		cNrevisa:=CN9->CN9_REVATU
		oWizard:NPanel := 3//Segue para painel de processos     
		cDescTR := CN0->CN0_DESCRI
		lCronog := ((cTpRev == DEF_ADITI .And. cEspc $ "134") .OR. cTpRev == DEF_REINI)//Altera cronogramas
		lAltPar := (cTpRev == DEF_ADITI .And. cEspc $ "134")//Altera parcelas
		lAltVlr := (cTpRev == DEF_REALI .And. !lFixo .And. lVlPrv)//Altera total do contrato
		
		If cTpRev != DEF_READQ
			oGrpPlO:Hide()
			oGrpPlA:Hide()
			oVlPAtu:Hide()
			oVlPOri:Hide()
		Else
			oGrpPlO:Show()
			oGrpPlA:Show()
			oVlPAtu:Show()
			oVlPOri:Show()
		EndIf
	Else
		lRet := CN240VldUsr(cContra,DEF_TRAINC,.T.)//Valida inclusao

		If lRet
			If !lFixo//Contrato Flexivel
				lRet := .F.
				Do Case
					Case cTpRev == DEF_ADITI
						If cEspc == "3"
							lRet := .T.
						EndIf
					Case cTpRev == DEF_REAJU
						lRet := lVlPrv
					Case cTpRev == DEF_REALI
						lRet    := lVlPrv
						lAltVlr := lVlPrv
					Case cTpRev == DEF_CLAUS
						lRet := .T.        
					Case cTpRev == DEF_REINI
						lRet := .T.
					Case cTpRev == DEF_PARAL
						lRet := .T.
					Case cTpRev == DEF_INDIC
						lRet := .T.
					Case cTpRev == DEF_FORNE
						lRet := .T.
				EndCase
			EndIf
		EndIf

		If lRet
			lCronog := .F.
			lAltPar := .F.
			
			If cTpRev != DEF_READQ
				oGrpPlO:Hide()
				oGrpPlA:Hide()
				oVlPAtu:Hide()
				oVlPOri:Hide()
			Else
				oGrpPlO:Show()
				oGrpPlA:Show()
				oVlPAtu:Show()
				oVlPOri:Show()
			EndIf
			
			Do Case
				Case cTpRev == DEF_ADITI
					If cEspc == "4" .Or. cEspc == "1"//Prazo+Quantidade
						lCronog := .T.//Altera cronogramas
						lAltPar := .T.//Altera parcelas
						lRet := CN140LPlan(cContra,cRevisa)//Carrega Planilhas
						If lRet .And. !lMedeve
							lRet := CN140LCron(cContra,cRevisa)//Carrega Cronogramas
						EndIf
						If lRet
							oWizard:NPanel := 7//Segue para o painel de planilhas
						EndIf
					Else
						lCronog := .T.//Altera cronogramas
						lAltPar := .T.//Altera parcelas
						If !lMedeve
							If lRet := CN140LCron(cContra,cRevisa)//Carrega Cronogramas
								oWizard:NPanel := 9//Segue para cronograma
							EndIf
						Else
							oWizard:NPanel := 15//Segue para painel final
						EndIf
					EndIf
				Case cTpRev == DEF_REALI
					If lFixo
						lRet := CN140LPlan(cContra,cRevisa)//Carrega Planilhas
						If	lRet
							oWizard:NPanel := 7//Segue para o painel das planilhas
						EndIf
					Else
						oWizard:NPanel := 15//Segue para painel final
					EndIf
				Case cTpRev == DEF_READQ
					lRet := CN140LPlan(cContra,cRevisa)//Carrega Planilhas
					If lRet
						oWizard:NPanel := 7//Segue para o painel das planilhas
					EndIf
				Case cTpRev == DEF_REAJU
					oWizard:NPanel := 5//Segue para o painel de reajuste
				Case cTpRev == DEF_PARAL
					oWizard:NPanel := 4//Segue para o painel de paralisacao
				Case cTpRev == DEF_REINI
					lCronog := .T.//Altera cronogramas
					If !lMedeve
						If lRet := CN140LCron(cContra,cRevisa)//Carrega Cronogramas
							oWizard:NPanel := 9//Segue para cronograma
						EndIf
					Else
					   oWizard:NPanel := 15//Segue para painel final
					EndIf
				Case cTpRev == DEF_CLAUS
					oWizard:NPanel := 6//Segue para o painel de alteracao de clausulas
				Case cTpRev == DEF_CRCTB //Contabil 
					nParcelas:=0
					lCronog := .T.//Altera cronogramas
					lAltPar := .T.//Altera parcelas
					lRet := CN140PlnCt(cContra,cRevisa,@lRet,@aCron)//Carrega Planilhas  
					If lRet
					   oWizard:NPanel := 11//Segue para o painel de planilhas
					Endif     
				Case cTpRev == DEF_INDIC
					oWizard:NPanel := 13	//Segue para o painel troca indice
				Case cTpRev == DEF_FORNE
					If lFixo
						If lRet := CN140LPlan(cContra,If(nRevRtp == 1,cNRevisa,cRevisa)) //Carrega Planilhas
							oWizard:NPanel := 7//Segue para o painel de planilhas
						EndIf
					Else
						CN140Forne("1",cRevisa)
					EndIf
			EndCase
			lRevisad := .F.
		Else
			Aviso("CNTA140",STR0113,{"OK"})//"O tipo de revisão selecionado permite alterar apenas contratos com estrutura fixa" 
		EndIf
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe planilhas com reajustes.  ³   
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet	
		If cTpRev == DEF_REAJU
			cAliasCNA := GetNextAlias()  
			
			cQuery := "SELECT COUNT(*) AS QTD "
			cQuery += "  FROM "+RetSQLName("CNA")+" CNA "
			cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
			cQuery += "   AND CNA.CNA_CONTRA = '"+cContra+"'"
			cQuery += "   AND CNA.CNA_REVISA = '"+cRevisa+"'"
			cQuery += "   AND CNA.CNA_FLREAJ = '1'"
			cQuery += "   AND CNA.D_E_L_E_T_ = ' '"   
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNA,.F.,.T.)
			
			If (cAliasCNA)->QTD = 0
				Help("CNTA140",1,"CNTA140_19")//Não há planilha para o contrato selecionado com opção de Reajuste.
				lRet := .F.
			EndIf
			(cAliasCNA)->(dbCloseArea())    
		EndIf
    EndIf 
	
	If lRet
		nVgAdit := CN9->CN9_VIGE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche array responsavel pela alteracao de parcelas quando for aditivo ³
		//³ de prazo ou quantidade/prazo                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cTpRev == DEF_ADITI .And. cEspc $ "134") .Or. cTpRev ==  DEF_CRCTB
			aTpCron := {}
			If cModo == "1" 
				aTpCron := {STR0055}//"Acréscimo"
			ElseIf cModo == "2" .And.lRedParc
				aTpCron := {STR0056}//"Decréscimo"
			Else          
				aTpCron := {STR0055}//"Acréscimo"
				If lRedParc
					aAdd(aTpCron,STR0056)//"Decréscimo"
				EndIf
			EndIf
			oTpCron:aItems := aTpCron
			oTpCronCtb:aItems := aTpCron
		EndIf
	EndIf
EndIf

//Carrega Unidade de Vigencia do Contrato
cUnVig := Posicione("CN9",1,xFilial("CN9")+cContra+cRevisa,"CN9_UNVIGE")
//Seleciona a vigencia atual do Contrato no Combo do ultimo painel (Justificativas)
If cUnVig == "1"
	oUnVig:nat := 1
ElseIf cUnVig == "2"
	oUnVig:nat := 2
ElseIf cUnVig == "3"
	oUnVig:nat := 3
Else
	oUnVig:nat := 4
EndIf

If ExistBlock("CN140VCT")
	lCn140vct := ExecBlock("CN140VCT",.F.,.F.,{cCodTr,cContra})
	If valtype(lCn140vct) == "L"
		lRet := lCn140vct
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP7 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel 7 - Alteracao de Clausula                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP7(cExp01)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Clausula alterada                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP7(cClaus)
Local lRet := .T.
    
If Empty(cClaus)
	Help("CNTA140",1,"CNTA140_09")//"Preencha as clausulas alteradas"
	lRet := .F.
Else
	oWizard:NPanel := 15//Segue para painel final
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP8 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 8 - Planilhas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP8(cExp01,cExp02,cExp03,aExp04,aExp05,aExp06,aExp07,³±±
±±³          ³           cExp08,oExp09)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato selecionado                    ³±±
±±³          ³ cExp02 - Codigo da revisao selecionada                     ³±±
±±³          ³ cExp03 - Codigo do tipo de revisao                         ³±±
±±³          ³ aExp04 - Array com as planilhas marcadas                   ³±±
±±³          ³ aExp05 - Array com os itens das planilhas                  ³±±
±±³          ³ aExp06 - Array com o cabecalho para os itens               ³±±
±±³          ³ aExp07 - Array com as linhas da getdados                   ³±±
±±³          ³ aExp08 - Array com os campos que poderao ser alterados     ³±±
±±³          ³ oExp09 - Combo de selecao das planilhas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP8(cContra,cRevisa,cCodTr,aPlan,aItens,aHeaderIt,aColsIt,aCpoAlt,oPlan,aAlterCNB)
Local lRet := .T.             
Local cTipRev := Posicione("CN0",1,xFilial("CN0")+cCodTr,"CN0_TIPO") 
Local cEsp    := Posicione("CN0",1,xFilial("CN0")+cCodTr,"CN0_ESPEC")
Local nPosDBR := 0//Data base de realinhamento
Local nPosReal:= 0//valor realinhado
Local aAlter  := {}  
Local cEspCtr := ""

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

oPlan:nAt := 1
oPlan:Refresh()

cModo   := Posicione("CN0",1,xFilial("CN0")+cCodTr,"CN0_MODO")

If Len(aPlan) = 0
	Help("CNTA140",1,"CNTA140_10")//"Selecione uma planilha"
	lRet := .F.
Else
	If cTipRev != DEF_REALI .AND. (nPosReal := aScan(aHeaderIt,{|x| x[2]=="CNB_REALI"})) > 0
		aDel(aHeaderIt,nPosReal)
		aSize(aHeaderIt,len(aHeaderIt)-1)
		If (nPosReal := aScan(aHeaderIt,{|x| x[2]=="CNB_DTREAL"})) > 0
			aDel(aHeaderIt,nPosReal)
			aSize(aHeaderIt,len(aHeaderIt)-1)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa getdados                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oGetDad1 == NIL
		oGetDad1 := MsNewGetDados():New(025,000, __DlgHeight(oWizard:oMPanel[9]), __DlgWidth(oWizard:oMPanel[9]),If((cModo $ "13" .AND. cTipRev == DEF_ADITI),GD_UPDATE+GD_DELETE+GD_INSERT,GD_UPDATE),"CN140VldIt()",,'+CNB_ITEM',,,9999,,,"CN140DelGet()",oWizard:oMPanel[9],aHeaderIt,aColsIt)
		If cTipRev == DEF_ADITI
			oGetDad1:bChange := {|| CN140ChgGet(cTipRev,aAlterCNB)}
		EndIf
		oGetDad1:oBrowse:bLostFocus := {|| CN140VldIt()}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche itens                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := CN140LItem(cContra,cRevisa,aPlan,aItens,aHeaderIt,cCodTr)     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa campos de alteracao                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cTipRev == DEF_ADITI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Durante a inclusao de itens habilita a edicao dos    ³
			//³principais campos, na revisao habilita apenas os     ³
			//³campos relativos ao tipo de revisao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oGetDad1:aCols[oGetDad1:nAt][aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_PRCORI"})]!=0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Libera apenas campo de quantidade para edicao        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAlter := aClone(aAlterCNB)
				aAdd(aAlter,"CNB_QUANT")  
				aAdd(aAlter,DEF_NDESC)
				oGetDad1:OBROWSE:aAlter := aAlter
				oGetDad1:SetEditLine(.F.)				
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Libera campos para inclusao de item                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAlter := aClone(aAlterCNB)
				aAdd(aAlter,"CNB_PRODUT")
				aAdd(aAlter,"CNB_DESCRI")				
				aAdd(aAlter,"CNB_QUANT")
				aAdd(aAlter,"CNB_VLUNIT")
				aAdd(aAlter,"CNB_DESC")
				aAdd(aAlter,"CNB_CONTA")
				aAdd(aAlter,DEF_NDESC) 
				If !Empty(CNB->(FieldPos("CNB_TE"))) 
					If cEspCtr == "1"
						aAdd(aAlter,"CNB_TE")
					EndIf
				EndIf         
				
				If !Empty(CNB->(FieldPos("CNB_TS"))) 
					If cEspCtr == "2"
						aAdd(aAlter,"CNB_TS") 
					EndIf
				EndIf
				oGetDad1:OBROWSE:aAlter := aAlter
				oGetDad1:SetEditLine(.F.)				
			EndIf   
			If lRet .And. !lMedeve .And. cEspc == "4"//Prazo+Quantidade
				lRet := CN140MntCron(cContra,cRevisa,aPlan)//Carrega Cronogramas de acordo com as planilhas selecionadas
			EndIf
		Case cTipRev == DEF_READQ
			aAlter := aClone(aAlterCNB)
			aAdd(aAlter,"CNB_QUANT")
			oGetDad1:OBROWSE:aAlter := aAlter
			oGetDad1:SetEditLine(.F.)				
		Case cTipRev == DEF_REALI
			aAlter := aClone(aAlterCNB)
			aAdd(aAlter,"CNB_REALI")
			aAdd(aAlter,"CNB_DTREAL")
			oGetDad1:OBROWSE:aAlter := aAlter
			oGetDad1:SetEditLine(.F.)				
		Case cTipRev == DEF_FORNE
			CN140Forne("1",cRevisa,aPlan)

	EndCase
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP4 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 4 - Alteracao de revisao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP4(cExp01,cExp02,cExp03,cExp04,cExp05,cExp06,dExp07,³±±
±±³          ³           dExp08,cExp09,lExp10,lExp11,dExp12)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do tipo de revisao                         ³±±
±±³          ³ cExp02 - Codigo do contrato selecionado                    ³±±
±±³          ³ cExp03 - Codigo da revisao selecionada                     ³±±
±±³          ³ cExp04 - Clausula alterada - Referencia                    ³±±
±±³          ³ cExp05 - Codigo de paralisacao - Referencia                ³±±
±±³          ³ cExp06 - Descricao do tipo de paralisacao - Referencia     ³±±
±±³          ³ dExp07 - Data de reinicio - referencia                     ³±±
±±³          ³ dExp08 - Data de reajuste - referencia                     ³±±
±±³          ³ cExp09 - Justificativa - referencia                        ³±±
±±³          ³ lExp10 - Altera cronograma - Referencia                    ³±±
±±³          ³ lExp11 - Altera parcelas do cronograma - Referencia        ³±±
±±³          ³ dExp12 - Data de termino do contrato - referencia          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP4(cCodTR,cContra,cRevisa,cClaus,cCodPr,cDescPr,dDtRein,dDtReaj,cJust,lCronog,lAltPar,dFContra,nValor)
Local lRet		 := .T. 
Local lCN140GRP4 := .F.

If nRevRtp == 0
	MsgAlert(STR0139) // "Para continuar é necessário selecionar uma opção"
	lRet := .F.
	Return lRet
Endif

If nRevRtp == 3
	lRet := .F. //Finaliza Wizard
	If CN240VldUsr(cContra,DEF_TRAEXC,.T.)
		If MsgYesNo(OemToAnsi(STR0085))//"Confirma exclusão da revisão?"
			dbSelectArea("CN9")
			dbSetOrder(1)
			dbSeek(xFilial("CN9")+cContra+cRevisa)//Encontra contrato original
	
			cRevAtu := CN9->CN9_REVATU
			
			CN140DelRev(cContra,cRevisa,cRevAtu,cCodTR)
			
			oWizard:SetFinish()
		EndIf
	EndIf  
Else
	lRet := 	CN240VldUsr(cContra,DEF_TRAEDT,.T.)
	
	If nRevRtp == 1  
		lRet := CN140ProRev(cContra,cRevisa,cCodTR,cTpRev)
		
		If !lRet   
			oWizard:SetFinish()
		EndIf
    EndIf
	
	If lRet
		dbSelectArea("CN0")
		dbSetOrder(1)
		dbSeek(xFilial("CN0")+cCodTR)
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona especificacoes do tipo de revisao         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTpRev  := CN0->CN0_TIPO
		cEspc   := CN0->CN0_ESPEC
		cModo   := CN0->CN0_MODO
		
		dbSelectArea("CN9")
		dbSetOrder(1)
		dbSeek(xFilial("CN9")+cContra+cRevisa)//Encontra contrato original
		nValor := CN9->CN9_VLATU
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando nRevRtp = 1, entao prossege revisao, caso    ³
		//³ contrario carrega as informacaoes originais         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRevRtp == 1
			cRevAtu := CN9->CN9_REVATU
			dbSeek(xFilial("CN9")+cContra+cRevAtu)//Encontra revisao gerada		
			nValor := CN9->CN9_VLATU
		EndIf
		
		dFContra:= CN9->CN9_DTFIM
		cJust := MSMM(CN9->CN9_CODJUS)
		lAltPar := lCronog := .F.
		
		Do Case
			Case cTpRev == DEF_ADITI
				If cEspc == "1"
					CN140LPlan(cContra,cRevAtu)//Carrega Planilhas
					oWizard:NPanel := 7//Segue para o painel de planilhas  
				ElseIf cEspc == "3"
					lCronog := .T.
					lAltPar := .T.
					If !lMedeve
						CN140LCron(cContra,cRevAtu)//Carrega Cronogramas
					   oWizard:NPanel := 9//Segue para cronograma
					 Else
					   oWizard:NPanel := 15//Segue para painel final
					 EndIf
				Else
				    lCronog := .T.
					 lAltPar := .T.
					 If !lMedeve
					    CN140LCron(cContra,cRevAtu)//Carrega Cronogramas
					 EndIf
				    CN140LPlan(cContra,cRevAtu)//Carrega Planilhas
					 oWizard:NPanel := 7//Segue para o painel de planilhas  
				EndIf		
			Case cTpRev == DEF_REALI
			   if lFixo
					CN140LPlan(cContra,cRevisa)//Carrega Planilhas
					oWizard:NPanel := 7//Segue para o painel das planilhas
				Else
					oWizard:NPanel := 15//Segue para painel final
				EndIf
			Case cTpRev == DEF_READQ
				CN140LPlan(cContra,cRevisa)//Carrega Planilhas
				oWizard:NPanel := 7//Segue para o painel das planilhas
			Case cTpRev == DEF_REAJU               
				dDtReaj := CN9->CN9_DTREAJ
				oWizard:NPanel := 5//Segue para o painel de reajuste
			Case cTpRev == DEF_PARAL     
				cCodPr  := CN9->CN9_MOTPAR
				dDtRein := CN9->CN9_DTFIMP                               
				cDescPr := Posicione("CN2",1,xFilial("CN2")+cCodPr,"CN2_DESCRI")
				oWizard:NPanel := 4//Segue para o painel de paralisacao
			Case cTpRev == DEF_REINI
				lCronog := .T.
				lAltPar := .F.
				If !lMedeve
					CN140LCron(cContra,cRevAtu)//Carrega Cronogramas
				   oWizard:NPanel := 9//Segue para cronograma
				Else
					oWizard:NPanel := 15//Segue para painel final
				EndIf
			Case cTpRev == DEF_CLAUS
				cClaus := MSMM(CN9->CN9_CODCLA)
				oWizard:NPanel := 6//0Segue para o painel finaç 
			Case cTpRev == DEF_CRCTB //Contabil 
		      nParcelas:=0
				lCronog := .T.//Altera cronogramas
				lAltPar := .T.//Altera parcelas
				CN140PlnCt(cContra,cRevAtu,@lRet,@aCron)//Carrega Planilhas
				oWizard:NPanel := 11//Segue para o painel de planilhas  
			Case cTpRev == DEF_INDIC
				oWizard:NPanel := 13	//Segue para o painel troca indice
			Case cTpRev == DEF_FORNE
				If lFixo
					If lRet := CN140LPlan(cContra,If(nRevRtp == 1,cRevAtu,cRevisa))//Carrega Planilhas
						oWizard:NPanel := 7//Segue para o painel de planilhas
					EndIf
				Else
					CN140Forne("1",cRevisa)
				EndIf
		EndCase
	EndIf
EndIf      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada executado após a validação do Painel 4   .³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN140GRP4")
	lCN140GRP4 := ExecBlock("CN140GRP4",.F.,.F.)
	If ValType(lCN140GRP4) == "L"
		lRet := lCN140GRP4
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140DelRev³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui e revisao gerada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140DelRev(cExp01,cExp02,cExp03,cExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                 ³±±
±±³          ³ cExp02 - Codigo da revisao original                         ³±±
±±³          ³ cExp03 - Codigo da revisao gerada                           ³±± 
±±³          ³ cExp04 - Codigo do tipo de revisao                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140DelRev(cContra,cORevisa,cNRevisa,cCodTR)
Local cQuery    := ""
Local lCN140EXREV  := ExistBlock("CN140EXREV")    
Local lCnRevMd     := SuperGetMV("MV_CNREVMD",.F.,.T.)       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada antes da exclusao da revisao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN140EXV") 
	ExecBlock("CN140EXV",.F.,.F.,{cContra,cORevisa,cNRevisa,cCodTR})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui medicao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
If lCnRevMd      
	cQuery := "SELECT CNE.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNE")+" CNE "
	cQuery += " WHERE CNE.CNE_FILIAL = '"+xFilial("CNE")+"'"
	cQuery += "   AND CNE.CNE_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNE.CNE_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNE.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNETMP", .F., .F. )    
	      
	dbSelectArea("CNE")	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui item da Medição           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNETMP->(Eof())   
		CNE->(dbGoTo(CNETMP->RECNO))
		RecLock("CNE",.F.)
			dbDelete()
		MsUnlock()
		CNETMP->(dbSkip())
	EndDo
	CNETMP->(dbCloseArea())	   
			                                         
	cQuery := "SELECT CND.CND_NUMMED,CND.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CND")+" CND "
	cQuery += " WHERE CND.CND_FILIAL = '"+xFilial("CND") +"'"
	cQuery += "   AND CND.CND_CONTRA = '"+cContra+"'"
	cQuery += "   AND CND.CND_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CND.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNDTMP", .F., .F. )    
		      
	dbSelectArea("CND")	
	
	While !CNDTMP->(Eof()) 
		CND->(dbGoTo(CNDTMP->RECNO))
		RecLock("CND",.F.)
			dbDelete()
		MsUnlock()
		CNDTMP->(dbSkip())
	EndDo             
	CNDTMP->(dbCloseArea())     		
EndIf

If lFisico
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o cronograma fisico do contrato             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNS.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNS")+" CNS "
	cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
	cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNS.CNS_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNS.D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNSTMP",.F.,.T.)
	
	dbSelectArea("CNS")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os itens do cronograma fisico                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNSTMP->(Eof())
		CNS->(dbGoTo(CNSTMP->RECNO))
		RecLock("CNS",.F.)
			dbDelete()
		MsUnlock()
		CNSTMP->(dbSkip())
	EndDo
	
	CNSTMP->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona itens das planilhas do contrato           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNB.R_E_C_N_O_ as RECNO "
cQuery += "  FROM "+RetSQLName("CNB")+" CNB "
cQuery += " WHERE CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
cQuery += "   AND CNB.CNB_CONTRA = '"+cContra+"'"
cQuery += "   AND CNB.CNB_REVISA = '"+cNRevisa+"'"
cQuery += "   AND CNB.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNBTMP",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui itens das planilhas do contrato              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
dbSelectArea("CNB")
dbSetOrder(1)
While !CNBTMP->(Eof())
	//-- Exclui localizacoes fisicas criadas nesta revisao   

	If AliasInDic("AGW") 
		AGW->(dbSetOrder(2))
		If AGW->(dbSeek(xFilial("AGW")+CNB->(CNB_CONTRA+CNB_NUMERO+CNB_ITEM))) .And.;
			!CNB->(dbSeek(xFilial("CNB")+AGW->(AGW_CONTRA+cORevisa+AGW_PLANIL+AGW_ITEM)))
			RecLock("AGW",.F.)
			AGW->(dbDelete())
			AGW->(MsUnLock())
		EndIf 
	EndIf 

	CNB->(dbGoTo(CNBTMP->RECNO))
	RecLock("CNB",.F.)
		dbDelete()
	MsUnlock()
	CNBTMP->(dbSkip())
EndDo      

CNBTMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona planilhas do contrato                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNA.R_E_C_N_O_ as RECNO "
cQuery += "  FROM "+RetSQLName("CNA")+" CNA "
cQuery += " WHERE CNA.CNA_FILIAL  = '"+xFilial("CNA")+"'"
cQuery += "   AND CNA.CNA_CONTRA  = '"+cContra+"'"
cQuery += "   AND CNA.CNA_REVISA  = '"+cNRevisa+"'"
cQuery += "   AND CNA.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNATMP",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga planilhas do contrato                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CNA")
While !CNATMP->(Eof())
	CNA->(dbGoTo(CNATMP->RECNO))
	RecLock("CNA",.F.)
		dbDelete()
	MsUnlock()
	CNATMP->(dbSkip())
EndDo

CNATMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona cronogramas do contrato                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNF.R_E_C_N_O_ as RECNO "
cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
cQuery += " WHERE CNF.CNF_FILIAL  = '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA  = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA  = '"+cNRevisa+"'"
cQuery += "   AND CNF.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNFTMP",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga cronogramas do contrato                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CNF")
While !CNFTMP->(Eof())
	CNF->(dbGoTo(CNFTMP->RECNO))   
	PcoDetLan("000357","01","CNTA110",.T.)	
	RecLock("CNF",.F.)
		dbDelete()
	MsUnlock()
	CNFTMP->(dbSkip())
EndDo

CNFTMP->(dbCloseArea())      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona cronogramas do contrato para a Revisao Anterior     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNF.R_E_C_N_O_ as RECNO "
cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
cQuery += " WHERE CNF.CNF_FILIAL  = '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA  = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA  = '"+cORevisa+"'"
cQuery += "   AND CNF.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNFTMP",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa lancamento do PCO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CNF")
While !CNFTMP->(Eof())
	CNF->(dbGoTo(CNFTMP->RECNO))
	PcoDetLan("000357","01","CNTA110")
	CNFTMP->(dbSkip())
EndDo

CNFTMP->(dbCloseArea())


If lContab
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona parcelas do cronograma contabil           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNW.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNW")+" CNW "
	cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNF")+"'"
	cQuery += "   AND CNW.CNW_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNW.CNW_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNW.D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNWTMP",.F.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga parcelas do cronograma contabil               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNW")
	While !CNWTMP->(Eof())
		CNW->(dbGoTo(CNWTMP->RECNO))
		RecLock("CNW",.F.)
			dbDelete()
		MsUnlock()
		CNWTMP->(dbSkip())
	EndDo
	
	CNWTMP->(dbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona cronogramas contabeis do contrato         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNV.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNV")+" CNV "
	cQuery += " WHERE CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
	cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNV.CNV_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNV.D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CNVTMP",.F.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga cronogramas do contrato                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNV")
	While !CNVTMP->(Eof())
		CNV->(dbGoTo(CNVTMP->RECNO))
		RecLock("CNV",.F.)
			dbDelete()
		MsUnlock()
		CNVTMP->(dbSkip())
	EndDo
	
	CNVTMP->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga fornecedores gerados						    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CNC->(FieldPos("CNC_REVISA")) > 0
	dbSelectArea("CNC")
	dbSetOrder(1)
	While dbSeek(xFilial("CNC")+cContra+cNRevisa)
		RecLock("CNC",.F.)
			dbDelete()
		MsUnLock()
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga contrato gerado                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CN9")
dbSetOrder(1)
If dbSeek(xFilial("CN9")+cContra+cNRevisa)
	RecLock("CN9",.F.)
		dbDelete()
	MsUnlock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa campo REVATU da revisao original              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek(xFilial("CN9")+cContra+cORevisa)
	RecLock("CN9",.F.)
		CN9->CN9_REVATU := ""
	MsUnlock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada apos exclusao da revisao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCN140EXREV
	ExecBlock("CN140EXREV",.F.,.F.,{cContra,cORevisa,cNRevisa,cCodTR})
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140MkPlan³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a selecao de planilhas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140MkPlan(aExp01,cExp02,nExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Array com as planilhas                             ³±±
±±³          ³ cExp02 - Planilha selecionada                               ³±±
±±³          ³ nExp02 - Valor total da planilha                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140MkPlan(aPlan,cPlan,nVlTot,cCronog)
Local nPos      := aScan(aPlan,{|x| x[1]==cPlan})
Default cCronog := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a planilha ja esta marcada              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPos = 0
	aAdd(aPlan,{cPlan,nVlTot,nVlTot,cCronog,If(FindFunction("CNAGWLoad"),CNAGWLoad(4,TRBCN9->CN9_NUMERO,cPlan),{})})
Else
	aDel(aPlan,nPos)
	aSize(aPlan,len(aPlan)-1)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140MkCron³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a selecao dos cronogramas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140MkCron(aExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Array responsavel pelos cronogramas selecionados   ³±±
±±³          ³ cExp02 - Cronograma selecionado                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140MkCron(aCron,cCron)
Local nPos := aScan(aCron,cCron)

If nPos = 0
	aAdd(aCron,cCron)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140MkCtbCron³ Autor ³                    ³ Data ³14.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a selecao dos cronogramas contabeis                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140MkCtbCron(aExp01,cExp02)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Array responsavel pelos cronogramas selecionados   ³±±
±±³          ³ cExp02 - Cronograma selecionado                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140MkCtbCron(aCronCtb,cCronCtb)
Local nPos := aScan(aCronCtb,cCronCtb)

If nPos = 0
	aAdd(aCronCtb,cCronCtb)
Else
	aDel(aCronCtb,nPos)
	aSize(aCronCtb,len(aCronCtb)-1)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140LItem³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega itens das planilhas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LItem(cExp01,cExp02,aExp03,aExp04,aExp05,cExp06)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Contrato Selecionado                              ³±±
±±³          ³ cExp02 - Revisao selecionada                               ³±±
±±³          ³ aExp03 - Planilhas selecionadas                            ³±±
±±³          ³ aExp04 - Array com os itens das planilhas                  ³±±
±±³          ³ cExp05 - Estrutua do cabecalho de itens                    ³±±
±±³          ³ cExp06 - Codigo do tipo de revisao                         ³±±
±±³          ³ lExp07 - Indica se irá  atualizar itens com a getDados     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140LItem(cContra,cRevisa,aPlan,aItens,aHeaderIt,cCodTR,lAtuGDad)

Local lRet      := .T.    

Local aRet      := {}
Local aArea     := GetArea()                                           
Local aCN140ADC := {}  
Local aStruCNB  := {}

Local nX  
Local nY
Local nZ
Local nPos   
Local nPosCnt
Local nQtdTot          

Local cQuery := ""
Local cPlan  := ""
Local cTipRev:= Posicione("CN0",1,xFilial("CN0")+cCodTr,"CN0_TIPO") 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao dos campos das planilhas                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPosPrcOr := aScan(aHeaderIT,{|x| x[2] == "CNB_PRCORI"})		//Preco original
Local nPosQtdOr := aScan(aHeaderIT,{|x| x[2] == "CNB_QTDORI"})		//Quantidade original
Local nPosQtdAc := aScan(aHeaderIT,{|x| x[2] == "CNB_QTRDAC"})		//Quantidade acrescida
Local nPosQtdDc := aScan(aHeaderIT,{|x| x[2] == "CNB_QTRDRZ"})		//Quantidade reduzida
Local nPosODesc := aScan(aHeaderIT,{|x| x[2] == DEF_DESCNA})		//Desconto
Local nPosOVDes := aScan(aHeaderIT,{|x| x[2] == DEF_VLDECNA})		//Valor do desconto
Local nPosNDesc := aScan(aHeaderIT,{|x| x[2] == DEF_NDESC})		//Novo desconto
Local nPosNVDes := aScan(aHeaderIT,{|x| x[2] == DEF_NVLDESC})		//Novo valor de desconto
Local nPosVlUnt := aScan(aHeaderIT,{|x| x[2] == "CNB_VLUNIT"})		//Valor Unitario
Local nPosVlRel := aScan(aHeaderIT,{|x| x[2] == "CNB_REALI"})		//Valor Realinhado
Local nPosDtRel := aScan(aHeaderIT,{|x| x[2] == "CNB_DTREAL"})		//Data base do realinhamento
Local nPosConta := aScan(aHeaderIT,{|x| x[2] == "CNB_CONTA"})		//Conta Contabil        
Local lCN140ITEM:= ExistBlock("CN140ITEM") 
Local lCN140ITF := ExistBlock("CN140ITF") 
Local lRevReal  := (cTipRev==DEF_REALI)

Default lAtuGDad := .T.//Por padrão carrega itens com GetDados 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Converte os numeros das planilhas selecionadas      ³
//³ para query                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItens := Array(len(aPlan))
For nX:=1 to len(aPlan)
	cPlan+="'"+aPlan[nX,1]+"',"
Next
cPlan:=SubStr(cPlan,1,len(cPlan)-1)      
dbSelectArea("CNB")
CNB->(dbSetOrder(1))           

cQuery := "SELECT CNB.*, CNB.R_E_C_N_O_ RECNOCNB, 0 CNB_REC_WT, '' CNB_ALI_WT "
cQuery += "  FROM "+RetSqlName("CNB")+" CNB "
cQuery += " WHERE CNB.CNB_FILIAL =  '"+xFilial("CNB")+"'"
cQuery += "   AND CNB.CNB_CONTRA = '"+cContra+"'"
cQuery += "   AND CNB.CNB_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNB.CNB_NUMERO in ("+cPlan +")"
cQuery += "   AND "  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Considera os itens que já passaram por revisões de realinhamento anteriormente,                 ³
//³com o saldo a medir (CNB_SLDMED) maior que 0(zero) e mais todos os itens que ainda não passaram ³
//³por revisões de realinhamento e os itens totalmente medidos CNB_QTDORI=CNB_QUANT.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += "  (((CNB.CNB_SLDMED > 0 AND CNB.CNB_VLTOTR>0) OR "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Disponibiliza parcelas já medidas caso o saldo do contrato seja zero                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery += " CNB.CNB_VLTOTR=0) OR (CNB.CNB_QTDORI=CNB.CNB_QUANT) "
If CNB->(FieldPos("CNB_ITMDST")) > 0 
	cQuery += " AND (CNB.CNB_ITMDST='') "
EndIf

cQuery += ") AND CNB.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY " + SqlOrder(CNB->(IndexKey())) 

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

//Configura campos especificos
TCSetField("TRB","CNB_QUANT"  ,"N",TamSX3("CNB_QUANT")[1] ,TamSX3("CNB_QUANT")[2])
TCSetField("TRB","CNB_VLUNIT" ,"N",TamSX3("CNB_VLUNIT")[1],TamSX3("CNB_VLUNIT")[2])
TCSetField("TRB","CNB_VLTOT " ,"N",TamSX3("CNB_VLTOT ")[1],TamSX3("CNB_VLTOT ")[2])
TCSetField("TRB","CNB_DESC"   ,"N",TamSX3("CNB_DESC")[1]  ,TamSX3("CNB_DESC")[2])
TCSetField("TRB","CNB_PERC"   ,"N",TamSX3("CNB_PERC")[1]  ,TamSX3("CNB_PERC")[2])
TCSetField("TRB","CNB_QTDMED" ,"N",TamSX3("CNB_QTDMED")[1],TamSX3("CNB_QTDMED")[2])
TCSetField("TRB","CNB_SLDMED" ,"N",TamSX3("CNB_SLDMED")[1],TamSX3("CNB_SLDMED")[2])
TCSetField("TRB","CNB_PRCORI" ,"N",TamSX3("CNB_PRCORI")[1],TamSX3("CNB_PRCORI")[2])
TCSetField("TRB","CNB_QTDORI" ,"N",TamSX3("CNB_QTDORI")[1],TamSX3("CNB_QTDORI")[2])
TCSetField("TRB","CNB_QTRDAC" ,"N",TamSX3("CNB_QTRDAC")[1],TamSX3("CNB_QTRDAC")[2]) 
TCSetField("TRB","CNB_QTRDRZ" ,"N",TamSX3("CNB_QTRDRZ")[1],TamSX3("CNB_QTRDRZ")[2]) 
TCSetField("TRB","CNB_REALI"  ,"N",TamSX3("CNB_REALI")[1] ,TamSX3("CNB_REALI")[2])
TCSetField("TRB","CNB_REC_WT" ,"N",10,0)

TCSetField("TRB","CNB_DTANIV" ,"D",8,0)
TCSetField("TRB","CNB_DTREAL" ,"D",8,0)

TCSetField("TRB","CNB_PROXAV" ,"D",8,0)
TCSetField("TRB","CNB_ULTAVA" ,"D",8,0)


If !Eof() 
	dbSelectArea("TRB")
	dbGoTop()

	While !Eof()         
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona registros filtrados ao arquivo temporario  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := aScan(aPlan,{|x| x[1]==TRB->CNB_NUMERO})
		If (nPos > 0)                     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa array referente a planilha quando ler    ³
			//³ o primeiro item                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType(aItens[nPos]) != "A"
				aItens[nPos] := {}
			EndIf 
	
			nY := len(aItens[nPos])+1
			aSize(aItens[nPos],nY)
			aItens[nPos][nY] := Array(Len(aHeaderIt)+1)
	 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche os itens da planilha para o array aItens[nPlanilha] ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX:=1 to TRB->(FCount())    
				nPosCnt := aScan(aHeaderIt,{|x| x[2] == TRB->(FieldName(nX))})
				If nPosCnt > 0
					If	IsHeadRec(TRB->(FieldName(nX)))
						aItens[nPos][nY][nPosCnt] := TRB->RECNOCNB
					ElseIf IsHeadAlias(TRB->(FieldName(nX)))
						aItens[nPos][nY][nPosCnt] := "CNB"
					Else			
						aItens[nPos][nY][nPosCnt] := TRB->(FieldGet(nX))	
					EndIf	
				EndIf
			Next       
			
			dbSelectArea("CNB")       
			dbSetOrder(1)
			CNB->(dbGoto(TRB->RECNOCNB))
			aStruCNB := CNB->(dbStruct())
						
			For nZ:=1 to len(aStruCNB)  	
				If aStruCNB[nZ][2]=="M" 
					nMemCustom := aScan(aHeaderIT,{|x| x[2] ==  aStruCNB[nZ][1]}) 				
					aItens[nPos][nY][nMemCustom] :=&(CNB->(aStruCNB[nZ][1])) 
				EndIf	
			Next      
	
			If lCN140ITEM
				aRet := ExecBlock("CN140ITEM",.F.,.F.,{aHeaderIT,aItens[nPos][nY]})
				If valtype(aRet) == "A"
					aItens[nPos][nY] := aRet
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche campos especificos                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(TRB->CNB_DTANIV)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao preenche campos de origem quando o item nao possuir ³
				//³ data de aniverssario, pois significa que o mesmo ainda  ³
				//³ nao foi adicionado ao contrato, faz parte apenas de     ³
				//³ revisao que ainda nao foi aprovada                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRevisad .And. nRevRtp == 1    
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando se tratar de uma alteracao de revisao         ³
					//³ recarrega estado dos itens como na geracao da revisao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					nTot := TRB->CNB_QUANT
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Decrementa quantidade adicionada para poder dividir ³
					//³ os descontos em original e novo                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TRB->CNB_QTRDAC > 0
						nTot -= TRB->CNB_QTRDAC
					EndIf
					nTot := nTot*TRB->CNB_VLUNIT
					
					aItens[nPos][nY][nPosPrcOr] := TRB->CNB_VLUNIT
					aItens[nPos][nY][nPosQtdOr] := TRB->CNB_QUANT
					aItens[nPos][nY][nPosODesc] := TRB->CNB_DESC
					aItens[nPos][nY][nPosOVDes] := ((nTot*TRB->CNB_DESC)/100)
					aItens[nPos][nY][nPosNDesc] := TRB->CNB_DESC
	
					If nPosVlRel > 0
						aItens[nPos][nY][nPosVlRel] := TRB->CNB_REALI
						aItens[nPos][nY][nPosDtRel] := TRB->CNB_DTREAL
						aItens[nPos][nY][nPosQtdAc] := 0
						aItens[nPos][nY][nPosQtdDc] := 0						
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se houve acrescimo do item e calcula o     ³
					//³ novo desconto                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TRB->CNB_QTRDAC > 0
						nTot := TRB->CNB_QTRDAC*TRB->CNB_VLUNIT
						aItens[nPos][nY][nPosNVDes] := ((nTot*TRB->CNB_DESC)/100)
					Else
						aItens[nPos][nY][nPosNVDes] := 0
					EndIf
				else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Quando se tratar de reinicio ou inclusao de revisao ³
					//³ carrega os itens do arquivo                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aItens[nPos][nY][nPosPrcOr] := TRB->CNB_VLUNIT
					aItens[nPos][nY][nPosQtdOr] := TRB->CNB_QUANT
					aItens[nPos][nY][nPosODesc] := TRB->CNB_DESC
					aItens[nPos][nY][nPosOVDes] := TRB->CNB_VLDESC
					aItens[nPos][nY][nPosNVDes] := 0
					aItens[nPos][nY][nPosNDesc] := TRB->CNB_DESC
					aItens[nPos][nY][nPosQtdAc] := 0
					aItens[nPos][nY][nPosQtdDc] := 0
					
					If nPosVlRel > 0
						aItens[nPos][nY][nPosVlRel] := TRB->CNB_VLUNIT
						aItens[nPos][nY][nPosDtRel] := dDataBase
					EndIf
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Quando se tratar de um item incluso nao preenche    ³
				//³ campos de origem                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aItens[nPos][nY][nPosPrcOr] := 0
				aItens[nPos][nY][nPosQtdOr] := 0
				aItens[nPos][nY][nPosODesc] := 0
				aItens[nPos][nY][nPosOVDes] := 0
				aItens[nPos][nY][nPosNVDes] := TRB->CNB_VLDESC
				aItens[nPos][nY][nPosNDesc] := TRB->CNB_DESC		
			EndIf                                            
			aItens[nPos][nY][nPosConta] := TRB->CNB_CONTA
			aItens[nPos][nY][Len(aItens[nPos][nY])] := .F.
		EndIF  
		
		If lCN140ITF
			aRet := ExecBlock("CN140ITF",.F.,.F.,{aHeaderIT,aItens[nPos][nY]})
			If valtype(aRet) == "A"
				aItens[nPos][nY] := aRet
			EndIf
		EndIf
	
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRB->(dbCloseArea())   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para customizacao dos itens da planilha ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If ExistBlock("CN140ADC") 
		aCN140ADC := ExecBlock("CN140ADC",.F.,.F.,{aPlan,aHeaderIT,aItens,cTipRev})
		If valtype(aCN140ADC) == "A"
			aItens := aClone(aCN140ADC)
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche itens das planilhas                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAtuGDad
		CN140LoadIt(aPlan[1,1],aItens,aPlan,,cCodTR)   
	EndIf   
Else
 Aviso("CNTA140",STR0123,{"Ok"})//"Planilha não possui itens para Inclusão da Revisão."
 lRet := .F.
 TRB->(dbCloseArea())   
EndIf

                     
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNTA140  ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a troca do acols de acordo com o array aItens      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LoadIt(cExp01,aExp02,aExp03,cExp04,cExp05)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Planilha selecionada                              ³±±
±±³          ³ aExp02 - Array com os itens das planilhas                  ³±±
±±³          ³ aExp03 - Array com as planilhas selecionadas               ³±±
±±³          ³ cExp04 - Planilha selecionada - referencia                 ³±±
±±³          ³ cExp05 - Codigo do tipo de revisao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140LoadIt(cPlan,aItens,aPlan,cPlanAtu,cCodTR)
//Verifica posicao da planilha no 'array
Local nPos := aScan(aPlan,{|x| Alltrim(x[1]) == Alltrim(cPlan)})
Local nPosO//Posicao da planilha de origem
Local cTipRev := ""
Local lRet    := .T.

If nPos > 0
	cTipRev := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_TIPO")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe planilha seleciona e atualiza as ³
	//³ informacaoes antes de realizar a troca              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPlanAtu != Nil
		nPosO := aScan(aPlan,{|x| x[1]==cPlanAtu})
		If nPosO > 0
			If cTipRev == DEF_READQ .And. Round(nVlPAtu,TamSx3("CNA_VLTOT")[2]) != Round(aPlan[nPosO,2],TamSx3("CNA_VLTOT")[2])
				lRet := .F.
				Aviso("CNTA140",STR0096,{"OK"})//"Na revisão de readequação, o valor da planilha não pode ser alterado"
			EndIf
			
			If lRet
				aItens[nPosO] := oGetDad1:aCols
			EndIf
		EndIf

		If lRet
			cPlanAtu := cPlan
		EndIf
	EndIf
	
	If lRet 
		If cTipRev == DEF_READQ
			oVlPOri:cTitle := Transform(aPlan[nPos,2],PesqPict("CNA","CNA_VLTOT"))
			nVlPAtu := aPlan[nPos,3]
		EndIf
		
	
		//Carrega acols do aItens de acordo com a posicao da planilha
		oGetDad1:aCols :=  aItens[nPos]
		oGetDad1:oBrowse:nAt   :=  1
		oGetDad1:oBrowse:Refresh()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140BckPn³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina responsavel pela navegacao de retorno do wizard     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140BckPn(cExp01,lExp02,aExp01,aExp02)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Tipo de revisao                                   ³±±
±±³          ³ lExp02 - Altera cronograma                                 ³±±
±±³          ³ aExp03 - Array com as informacoes de marcacao dos cronog.  ³±±
±±³          ³ aExp04 - Array com as informacoes de marcacao das planil.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140BckPn(cCodTR,lCronog,aCron,aPlan,cPlanAtu,cCron,lContab,aHeaderIt,aItens,aPlan,cRevisa)
Local lRet      := .T.      
Local nPnAtu    := oWizard:NPanel	//Painel atual
Local cTpEspc   := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_ESPEC")    
Local cItmDst   := ""
Local cQuery    := ""
Local nX        := 0
Local nItmPla   := 0
Local aStrucCNB := CNB->(dbStruct())

DEFAULT cPlanAtu := ""
DEFAULT cCron    := ""
DEFAULT aCron    := {}   
DEFAULT aHeaderIt:= {}
DEFAULT aItens   := {}
DEFAULT aPlan    := {}
DEFAULT cRevisa  := ""

cTpRev := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_TIPO")

If cPlanAtu != Nil
	cPlanAtu := ""
EndIf

If cCron != Nil .And. aCron!= Nil     
	If len(aCron) >0
		cCron := aCron[1]
	EndIf
EndIf                   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove os itens já medidos em historico do array.³
//³para nao exibi-los no dialog .                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If !Empty(cRevisa)
	For nItmPla := 1 to len(aPlan) 
		cQuery := "SELECT * FROM " +RetSQLName("CNB")+" CNB WHERE CNB_FILIAL = '"+xFilial("CNB")+"' AND "
		cQuery += "CNB_CONTRA = '"+cContra         +"' AND CNB_REVISA = '"+cRevisa+"' AND "     
		cQuery += "CNB_NUMERO = '"+aPlan[nItmPla,1]+"' AND "
		cQuery += "D_E_L_E_T_ <> '*' ORDER BY CNB_NUMERO,CNB_ITEM"
		cQuery := ChangeQuery( cQuery )
	
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNBZERO", .F., .F. ) 
			    
		For nX :=1 To Len(aStrucCNB)
		     If CNBZERO->(FieldPos(aStrucCNB[nx,1])) > 0 .And. aStrucCNB[nx,2] <> "C"
		       TCSetField("CNBZERO",aStrucCNB[nx,1],aStrucCNB[nx,2],aStrucCNB[nx,3],aStrucCNB[nx,4])
		     Endif
		Next nX
		
		CNBZERO->(dbGoTop())	
		While !CNBZERO->(Eof())   
			
				If CNB->(FieldPos("CNB_ITMDST")) > 0 
					cItmDst := CNBZERO->CNB_ITMDST
				EndIf  
			
				If !(((CNBZERO->CNB_SLDMED > 0 .AND. CNBZERO->CNB_VLTOTR>0) .OR. (CNBZERO->CNB_SLDMED > 0 .And. CNBZERO->CNB_VLTOTR==0)).AND. (CNBZERO->CNB_QTDORI==CNBZERO->CNB_QUANT).OR.(cItmDst=='') )  
				nItemCNB := aScan(aItens[nItmPla],{|x| x[1] == CNBZERO->CNB_ITEM})
				If CNBZERO->CNB_SLDMED == 0 .And.(nItemCNB> 0)//Para evitar diferenças do banco
				    aDel(aItens[nItmPla],nItemCNB) 
				    aSize(aItens[nItmPla],len(aItens[nItmPla])-1) 	    
				EndIf
			EndIf
		    CNBZERO->(dbSkip())
		End
		CNBZERO->(dbCloseArea())         
	Next   
EndIf

Do Case            
	Case nPnAtu = 12	//Cronograma contabil 
        aItensCtb:={}
        aHeaderCt:={}  
        
		If cTpRev == DEF_ADITI	//ADIT. QUANT/PRAZO
			If(cTpEspc == "1")	//Quantidade
				oWizard:NPanel := 10	//planilha
			ElseIf (cTpEspc == "3")//Prazo
		   		oWizard:NPanel := If(lMedeve,5,12)//Inicio ou Cronograma Financeiro
			ElseIf (cTpEspc == "4")	//QTD/Prazo
		   		oWizard:NPanel := If(lMedeve,10,12)//Planilha ou Cronograma financeiro
			EndIf
		ElseIf cTpRev == DEF_CRCTB	//Cronograma contabil
			oWizard:NPanel := if(lRevisad,5,4)//Alteracao de Revisao ou Contratos
		EndIf		
		
	Case nPnAtu = 13	//Parcelas cronograma financeiro
        aItensCtb:={}
        aHeaderCt:={}  
        
	Case nPnAtu = 14	//Finalizacao
		If lRevisad .And. nRevRtp == 3//Exclusao
			lRet := .F.	//Nao permite retorno
		ElseIf cTpRev == DEF_PARAL	//Paralisacao
			oWizard:NPanel := 6	//Prev. Reinicio
		ElseIf cTpRev == DEF_REAJU	//Reajuste
			oWizard:NPanel := 7	//Data Reajuste
		ElseIf cTpRev == DEF_CLAUS	//Clausula
			oWizard:NPanel := 8	//Alteracao de Clausula
		ElseIf cTpRev == DEF_REINI .OR. !lFixo	//Reinicio 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se e uma alteracao de revisao              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWizard:NPanel := if(lRevisad,5,4)//Alteracao de Revisao ou Contratos
		ElseIf cTpRev == DEF_CRCTB	//Cronograma Contabil
   			aItensCtb:={}
	         aHeaderCt:={}
    		oWizard:NPanel := 14 //Cronograma Contabil
		ElseIf !lCronog	//Altera cronograma
			oWizard:NPanel := 10 //Planilha
		ElseIf cTpRev == DEF_ADITI //ADIT. QUANT/PRAZO
			If(cTpEspc == "1") //Quantidade
				oWizard:NPanel := 10 //Planilha
			ElseIf (cTpEspc == "3") //Prazo
				If !lContab //Sem cronograma contabil
			   		oWizard:NPanel := If(lMedeve,If(lRevisad,5,4),12)//Alteracao da Revisao, Contratos ou Cronograma Financeiro
				Else 
					oWizard:NPanel := 14 //Cronograma contabil
				Endif
			ElseIf (cTpEspc == "4") //QTD/Prazo
				If !lContab //Sem cronograma contabil
			   		oWizard:NPanel := If(lMedeve,10,12) //Planilha ou Cronograma Financeiro
				Else 
					oWizard:NPanel := 14 //Cronograma Contabil
				Endif
			EndIf
		ElseIf lMedeve
			oWizard:NPanel := if(lRevisad,5,4) //Alteração da Revisão ou Contratos
		EndIf
		
	Case nPnAtu = 10 //Cronograma Financeiro
		If cTpEspc != "4"//ADIT. QUANT/PRAZO
			oWizard:NPanel := if(lRevisad,5,4)//Alteração da Revisão ou Contratos   
		Else             
			oWizard:NPanel := 9     
		EndIf
		aCron := {} //limpa array com as marcacoes dos cronograma	
		
	Case nPnAtu = 11 //Cronograma Financeiro
		oWizard:NPanel :=11//Alteração da Revisão ou Contratos
		aCron := {} //limpa array com as marcacoes dos cronograma                   
		
	Case nPnAtu = 8 //Planilha
		aPlan := {} //limpa array com as marcacoes das planilhas
		oWizard:NPanel := if(lRevisad,5,4)//Alteração da Revisão ou Contratos
		
	Case nPnAtu = 7 .Or. nPnAtu = 6 .Or. nPnAtu = 5//Clausula,Data de reajuste ou Prev. Reinicio
		oWizard:NPanel := if(lRevisad,5,4)//Alteração da Revisão ou Contratos
	
	Case nPnAtu = 16 // Contrato Flexivel, retornar para escolha do contrato
		oWizard:NPanel := 3
EndCase                                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para gravacoes especificas no retorno   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
If ExistBlock("CN140BCK")
	ExecBlock("CN140BCK",.F.,.F.,{cContra,cRevisa,aPlan,oWizard:NPanel,aCron,aItens})  
EndIf

Return lRet                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140GerRev³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera contrato de revisao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140(cExp01,cExp02,cExp03,cExp04,cExp05,dExp06,dExp07,   ³±±
±±³          ³         cExp08,aExp09,aExp10,aExp11,aExp12,dExp13,aExp14,   ³±±
±±³          ³         cExp15,aExp16)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                 ³±±
±±³          ³ cExp02 - Codigo da revisao                                  ³±±
±±³          ³ cExp03 - Codigo do tipo de revisao                          ³±±
±±³          ³ cExp04 - Justificativa                                      ³±±
±±³          ³ cExp05 - Codigo de paralisacao                              ³±±
±±³          ³ cExp06 - Data de Reinicio                                   ³±±
±±³          ³ dExp07 - Data de reajuste                                   ³±±
±±³          ³ dExp08 - Clausulas alteradas                                ³±±
±±³          ³ cExp09 - Itens das planilhas                                ³±±
±±³          ³ aExp10 - Planilhas selecionadas                             ³±±
±±³          ³ aExp11 - Parcelas dos cronogramas                           ³±±
±±³          ³ aExp12 - Cronogramas selecionados                           ³±±
±±³          ³ dExp13 - Data de termino do contrato                        ³±±
±±³          ³ aExp14 - Array com a estrutura dos itens de planilha        ³±±
±±³          ³ aExp15 - Array com o cabecalho do cronograma fisico         ³±±
±±³          ³ aExp16 - Array com as parcelas do cronograma fisico         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140GerRev(cContra,cRevisa,cCodTR,cJust,cCodPr,dDtRein,dDtReaj,cClaus,aItens,aPlan,aParcelas,aCron,dFContra,aHeaderIt,aHeadParc,aColsParc,aItensCtb,nValor,lAltVlr,nVgAdit,aReman,cFornec,cLoja,dDtRefe)
Local aContra := {}       

Local cNrevisa := Soma1(if(Empty(cRevisa),strzero(0,TamSX3("CN9_REVISA")[1]),cRevisa))
Local cEspRev  := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_ESPEC")
Local cUnVig   := ""       

Local nX                               
Local nTContra     
Local nValAdit := 0
Local nSldAdit := 0
Local nVlInd   := 0 
Local nOrigAdt := 0//Valor aditivado da revisao original
Local nOrigSld := 0//Saldo da revisao original
Local nOrigAtu := 0//valor atual da revisao original

Local lRet     := .T.
Local lPERev   := ExistBlock("CN140GREV") 
Local lCN140BRV:= .T.

Local dFimOld  := dFContra
DEFAULT aReman :={}
DEFAULT cFornec:=""
DEFAULT cLoja  :=""

cTpRev   := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_TIPO")
                     
If Empty(cJust)
	Help("CNTA140", 1, "CNTA140_16")
	lRet := .F.
EndIf                                    

If	Type("oUnVig")=="O"
	If oUnVig:nat == 1
		cUnVig := "1"
	ElseIf oUnVig:nat == 2
		cUnVig := "2"
	ElseIf oUnVig:nat == 3
		cUnVig := "3"
	Else
		cUnVig := "4"
	EndIf
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que confirma a gravação da revisão ou não.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN140BRV")
	lCN140BRV := ExecBlock("CN140BRV",.F.,.F.,{cContra,cRevisa,cCodTR,cJust,cCodPr,dDtRein,dDtReaj,cClaus,aItens,aPlan,aParcelas,aCron,dFContra,aHeaderIt,aHeadParc,aColsParc,nValor,lAltVlr,nVgAdit})
	If valtype(lCN140BRV) == "L"
		lRet := lCN140BRV
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona revisao anterior                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNF.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNF")+" CNF "  
	cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
	cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
	cQuery += "   AND CNF.D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui lancamento do PCO  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNFTMP->(Eof())
		CNF->(dbGoTo(CNFTMP->RECNO))
		PcoDetLan("000357","01","CNTA110",.T.)		
		CNFTMP->(dbSkip())
	EndDo
	
	CNFTMP->(dbCloseArea())

	Begin Transaction
	dbSelectArea("CN9")
	dbSetOrder(1)     
	dbSeek(xFilial("CN9")+cContra+cRevisa)
	
	If	(!Empty(aReman) .Or. !Empty(cFornec)) .And. CN9->(!Eof())
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := DEF_SREVD
		MsUnlock()
	EndIf
	
	If	Type("lMedeve")!="L"
		lMedeve  := (Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_MEDEVE") == "1")
	EndIf
	If	Type("lFisico")!="L"
		lFisico  := ((CN1->(FieldPos("CN1_CROFIS")) > 0) .And. Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROFIS") == "1")
	EndIf
	If	Type("lContab")!="L"
		lContab  := (Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROCTB") == "1")
	EndIf
	If	Type("oUnVig")!="O"
		cUnVig:=CN9->CN9_UNVIGE
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando alteracao nao cria registro, caso contrario  ³
	//³ adiciona o mesmo.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRevisad
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Total de campos do arquivo CN9                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTContra := FCount()
	
		aContra := Array(nTContra)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Transmite campos para o array                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX:=1 to nTContra
			aContra[nX]:=FieldGet(nX)
		Next
	
		//Atualiza origem
		RecLock("CN9",.F.)
			CN9->CN9_REVATU := cNrevisa
		MsUnlock()
	               
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Registro de Revisao	                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		RecLock("CN9",.T.)
		For nX:=1 to nTContra
			FieldPut(nX,aContra[nX])
		Next
	
	Else
		If nRevRtp == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena valores do contrato original quando reinicio³
			//³ de revisao                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			nOrigAdt := CN9->CN9_VLADIT
			nOrigSld := CN9->CN9_SALDO
			nOrigAtu := CN9->CN9_VLATU
		EndIf
	
		dbSeek(xFilial("CN9")+CN9->CN9_NUMERO+CN9->CN9_REVATU)
		RecLock("CN9",.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia campos especificos                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	CN9->CN9_REVISA := cNrevisa
	CN9->CN9_SITUAC := DEF_SREVS
	CN9->CN9_TIPREV := cCodTR   
	CN9->CN9_DTREV  := dDataBase
	CN9->CN9_REVATU := ""
	CN9->CN9_VIGE   := nVgAdit
	CN9->CN9_UNVIGE := cUnVig
	If	(!Empty(aReman) .Or. !Empty(cFornec))
		CN9->CN9_RESREM := " "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza valores do contrato       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If lAltVlr
		If nValor < CN9->CN9_SALDO
			CN9->CN9_SALDO -= (CN9->CN9_VLATU-nValor)
		Else
			CN9->CN9_SALDO += (nValor-CN9->CN9_VLATU)
		EndIf
		CN9->CN9_VLATU := nValor
	EndIf

	
	Do Case
		Case cTpRev = DEF_PARAL//Paralisacao
			CN9->CN9_MOTPAR := cCodPr
			CN9->CN9_DTFIMP := dDtRein
		Case cTpRev = DEF_REAJU//Reajuste
			CN9->CN9_DTREAJ := dDtReaj
			If CN9->(FieldPos("CN9_DREFRJ")) > 0
				CN9->CN9_DREFRJ := dDtRefe
			EndIf
	EndCase
	
	MsUnlock()
	
	MSMM(,,,cJust,1,,,"CN9","CN9_CODJUS")
	
	If cTpRev == DEF_CLAUS
		MSMM(,,,cClaus,1,,,"CN9","CN9_CODCLA")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera copia dos fornecedores do contrato             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        			
	CN140RevCNC(cContra,cRevisa,cNRevisa)	
	
	If cTpRev == DEF_ADITI
		If cEspRev == "1" //Aditivo de quantidade
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das planilhas                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt)
			CNA->(dbCommit())
			CNB->(dbCommit())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das Medicoes                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
			CN140RevMed(cContra,cRevisa,cNRevisa)
			
			If !lRevisad .Or. (lRevisad .And. nRevRtp == 2)
				If !lMedeve
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera copia de todos os cronogramas                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
					CN140CopCron(cContra,cRevisa,cNRevisa)
				
					If lFisico
						CNA->(dbCommit())
						CNB->(dbCommit())
						CNF->(dbCommit())
						CNS->(dbCommit())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza valores do cronograma com base nos valores ³
						//³ realinhados e no cronograma fisico                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						CN140AtuFsc(cContra,cNRevisa,.T.,cRevisa)
					EndIf
				EndIf
				If lContab
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera copia dos cronogramas contabeis                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					CN140CopCtb(cContra,cRevisa,cNRevisa)
				EndIf
			EndIf    
		
			If  (lRevisad .And. nRevRtp == 1)  //Atualiza Cronograma na Opcao PROSSEGUIR
	 			If lFisico .And. !lMedeve
					CNA->(dbCommit())
	  				CNB->(dbCommit())
					CNF->(dbCommit())
					CNS->(dbCommit())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza valores do cronograma com base nos valores ³
					//³ realinhados e no cronograma fisico                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					CN140AtuFsc(cContra,cNRevisa,.T.,cRevisa)
				EndIf 
			EndIf
			
			RecLock("CN9",.F.)
				If lRevisad .And. nRevRtp == 2//Reinicio de revisao
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados quantitativos do contrato com base   ³
					//³ nos valores do contrato de origem                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
					CN9->CN9_VLADIT := nOrigAdt + nValAdit
					CN9->CN9_VLATU  := nOrigAtu + nValAdit
					CN9->CN9_SALDO  := nOrigSld + nValAdit
				Else                            
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Incrementa dados quantitativos do contrato          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
					CN9->CN9_VLADIT += nValAdit
					CN9->CN9_VLATU  += nValAdit
					CN9->CN9_SALDO  += nValAdit
				EndIf
			MsUnlock()
	
		ElseIf cEspRev == "3"
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas alterados                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140GerCron(@aParcelas,aCron,cContra,cRevisa,cNRevisa,aHeadParc,aColsParc)
			EndIF

			If lContab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas contabeis                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140GerCt(aItensCtb,cContra,cRevisa,cNRevisa)
			EndIf

			If !lRevisad
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia das planilhas quando nao for alteracao   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt)      
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia das Medicoes                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    				
				CN140RevMed(cContra,cRevisa,cNRevisa)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica data maxima dos cronogramas                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			dFimOld := CN9->CN9_DTFIM
			RecLock("CN9",.F.)
				CN9->CN9_DTFIM := dFContra
			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajusta datas da planilha   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			CN140AjuDt(cContra,cNRevisa,dFimOld,CN9->CN9_DTFIM,lMedeve)
			
		Else //Aditivo de Quantidade e Prazo
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas alterados                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140GerCron(@aParcelas,aCron,cContra,cRevisa,cNRevisa,aHeadParc,aColsParc)
			EndIF

			If lContab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas contabeis                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140GerCt(aItensCtb,cContra,cRevisa,cNRevisa)
			EndIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das planilhas alteradas                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt,      ,.T.   ,        ,aReman)   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das Medicoes                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
			CN140RevMed(cContra,cRevisa,cNRevisa)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualzia cabecalho do contrato                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			dFimOld := CN9->CN9_DTFIM
			RecLock("CN9",.F.)
				CN9->CN9_DTFIM := dFContra
				If lRevisad .And. nRevRtp == 2
					CN9->CN9_VLADIT := nOrigAdt + nValAdit
					CN9->CN9_VLATU  := nOrigAtu + nValAdit
					CN9->CN9_SALDO  := nOrigSld + nValAdit
				Else
					CN9->CN9_VLADIT += nValAdit
					CN9->CN9_VLATU  += nValAdit
					CN9->CN9_SALDO  += nValAdit
				EndIf
			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajusta datas da planilha   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			CN140AjuDt(cContra,cNRevisa,dFimOld,CN9->CN9_DTFIM,lMedeve)
		EndIf
		
	ElseIf cTpRev == DEF_REINI
		If !lMedeve
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia dos cronogramas alterados                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			CN140GerCron(@aParcelas,aCron,cContra,cRevisa,cNRevisa,aHeadParc,aColsParc)
		EndIf
		If lContab
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia dos cronogramas contabeis                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CN140CopCtb(cContra,cRevisa,cNRevisa)
		EndIf
		If !lRevisad
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das planilhas quando nao for alteracao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das Medicoes                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
			CN140RevMed(cContra,cRevisa,cNRevisa)	
		EndIf
		
	ElseIf cTpRev == DEF_REALI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava alteracao das planilhas                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt,.T.,.F.,@nSldAdit)           
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das Medicoes                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		CN140RevMed(cContra,cRevisa,cNRevisa)	
		
		If !lRevisad .Or. (lRevisad .And. nRevRtp == 2)
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia de todos os cronogramas                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140CopCron(cContra,cRevisa,cNRevisa)
				
				If lFisico
					CNA->(dbCommit())
					CNB->(dbCommit())
					CNF->(dbCommit())
					CNS->(dbCommit())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza valores do cronograma com base nos valores ³
					//³ realinhados e no cronograma fisico                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					CN140AtuFsc(cContra,cNRevisa,.T.,cRevisa)
				EndIf
			EndIf
			If lContab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas contabeis                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140CopCtb(cContra,cRevisa,cNRevisa)
			EndIf
		EndIf    
		
		If  (lRevisad .And. nRevRtp == 1)  //Atualiza Cronograma na Opcao PROSSEGUIR
	 		If lFisico .And. !lMedeve
				CNA->(dbCommit())
	  			CNB->(dbCommit())
				CNF->(dbCommit())
				CNS->(dbCommit())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza valores do cronograma com base nos valores ³
				//³ realinhados e no cronograma fisico                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140AtuFsc(cContra,cNRevisa,.T.,cRevisa)
			EndIf 
		EndIf
		
		RecLock("CN9",.F.)
			If lRevisad .And. nRevRtp == 2//Reinicio de revisao
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza dados quantitativos do contrato com base   ³
				//³ nos valores do contrato de origem                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN9->CN9_VLATU  := nOrigAtu + nValAdit
				CN9->CN9_SALDO  := nOrigSld + nSldAdit
			Else                            
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Incrementa dados quantitativos do contrato          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN9->CN9_VLATU  += nValAdit
				CN9->CN9_SALDO  += nSldAdit
			EndIf
		MsUnlock()
		
	ElseIf cTpRev == DEF_READQ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das planilhas readequadas                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt,,.T.)   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das Medicoes                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		CN140RevMed(cContra,cRevisa,cNRevisa)		
		
		If !lRevisad .Or. (lRevisad .And. nRevRtp == 2)
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia de todos os cronogramas                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140CopCron(cContra,cRevisa,cNRevisa)
			EndIf
			If lContab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas contabeis                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140CopCtb(cContra,cRevisa,cNRevisa)
			EndIf
		EndIf
		
	ElseIf cTpRev == DEF_CRCTB
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia dos cronogramas contabeis                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		CN140GerCt(aItensCtb,cContra,cRevisa,cNRevisa)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das planilhas quando nao for alteracao   ³
		//³ para todas as revisoes                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRevisad .Or. (lRevisad .And. nRevRtp == 2)
			CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt)          
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das Medicoes                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
			CN140RevMed(cContra,cRevisa,cNRevisa)		
		
			
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia de todos os cronogramas                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140CopCron(cContra,cRevisa,cNRevisa)
			EndIf
		EndIf
		
	ElseIf cTpRev == DEF_INDIC
		//-- Troca o indice do contrato
		RecLock("CN9",.F.)
		CN9->CN9_INDICE := cIndNovo
		MsUnLock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das planilhas                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt)
		CNA->(dbCommit())
		CNB->(dbCommit())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das Medicoes                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
		CN140RevMed(cContra,cRevisa,cNRevisa)		

		If !lMedeve
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia de todos os cronogramas                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			CN140CopCron(cContra,cRevisa,cNRevisa)
		EndIf
		If lContab
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia dos cronogramas contabeis                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CN140CopCtb(cContra,cRevisa,cNRevisa)
		EndIf

		CN140Indice("4",,,cRevisa,cNRevisa)

	ElseIf cTpRev == DEF_FORNE

		If	Type("oGetDad1")=="O"
			aItFor := AClone(oGetDad1:aCols)
		Else
			CN140Forne("1",cNRevisa)
		EndIf    

		If	lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das planilhas                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt)
			CNA->(dbCommit())
			CNB->(dbCommit())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das Medicoes                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
			CN140RevMed(cContra,cRevisa,cNRevisa)		
	
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia de todos os cronogramas                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140CopCron(cContra,cRevisa,cNRevisa)
			EndIf
	
			If lContab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas contabeis                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140CopCtb(cContra,cRevisa,cNRevisa)
			EndIf

			CN140Forne("5",cNRevisa,,cFornec,cLoja)

		EndIf
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera copia das planilhas quando nao for alteracao   ³
		//³ para todas as revisoes                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRevisad .Or. (lRevisad .And. nRevRtp == 2)
			CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,@nValAdit,aHeaderIt)    
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera copia das Medicoes                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
			CN140RevMed(cContra,cRevisa,cNRevisa)		
		
			
			If !lMedeve
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia de todos os cronogramas                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				CN140CopCron(cContra,cRevisa,cNRevisa)
			EndIf
			If lContab
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera copia dos cronogramas contabeis                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN140CopCtb(cContra,cRevisa,cNRevisa)
			EndIf
		EndIf
	EndIf                                        
	If cTpRev == DEF_REAJU .And. CN9->(FieldPos("CN9_DREFRJ")) > 0
		CN150VdApr(CN9->CN9_DREFRJ,CN9->CN9_DTREAJ,CN9->CN9_INDICE,@nVlInd)
		Processa({|| lRet := CN150Reaj(cContra,cNRevisa,cRevisa,lMedeve,CN9->CN9_DTREAJ,CN9->CN9_DREFRJ,nVlInd,lFisico,lFixo,lContab)})
	Endif
	End Transaction
	If lRet .And. lPERev
	   ExecBlock("CN140GREV",.F.,.F.,{cContra,cRevisa,cNRevisa,cCodTR,cJust,cClaus})
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140CronF³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna data da ultima parcela do maior cronograma         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140CronF(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                ³±±
±±³          ³ cExp02 - Codigo da revisao gerada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140CronF(cContra,cNRevisa)
Local dRet   := dDataBase
Local cQuery := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona data maxima das parcelas dos cronogramas  ³
//³ alterados                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT MAX(CNF.CNF_PRUMED) as CNF_PRUMED "
cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
cQuery += " WHERE CNF.CNF_FILIAL  = '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA  = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA  = '"+cNRevisa+"'"
cQuery += "   AND CNF.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFMAX", .F., .F. )  

TCSetField("CNFMAX","CNF_PRUMED","D",8,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna data maxima                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dRet := CNFMAX->CNF_PRUMED

CNFMAX->(dbCloseArea())

Return dRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140GerCron³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera cronogramas alterados para a nova revisao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140GerCron(aExp01,aExp02,cExp03,cExp04,cExp05,aExp06,aExp07)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Parcelas dos cronogramas                             ³±±
±±³          ³ aExp02 - Cronogramas selecionados                             ³±±
±±³          ³ cExp03 - Contrato selecionado                                 ³±±
±±³          ³ cExp04 - Revisao selecionada                                  ³±±
±±³          ³ cExp05 - Codigo da nova revisao                               ³±±
±±³          ³ aExp06 - Array com o cabecalho do cronograma fisico           ³±±
±±³          ³ aExp07 - Array com as parcelas do cronograma fisico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140GerCron(aParcelas,aCron,cContra,cRevisa,cNRevisa,aHeadParc,aColsParc)

Local nPosCpo :=0
Local nPos1   := 0
Local nPos2   := 0
Local nPos3   := 0
Local nPos4   := 0
Local nPos5   := 0
Local nPos6   := 0
Local nPos7   := 0
Local nPos8   := 0
Local nX
Local nY
Local nZ
Local nCron
Local nParc
Local nReg
Local nPosDPar
Local nPosPeri

Local cFilCod  := xFilial("CNF")
Local cQuery   := ""
Local cCrons   := ""
Local cPlan    :=""

Local lDeleta  := .F.
Local lEditad  := .F.
Local lRet     := .T.
Local lPeriod  := (CNF->(FieldPos("CNF_PERIOD")) > 0)
Local lRetorna := .F.

Local aNCron   := {}//Armazena cronogramas nao alterados
Local aArea    := GetArea()

If lPeriod .And. !Empty(aParcelas)
	nPosDPar := aScan(oGetDados:aHeader,{ |x| UPPER(AllTrim(x[2])) == "CNF_DIAPAR"})
	nPosPeri := aScan(oGetDados:aHeader,{ |x| UPPER(AllTrim(x[2])) == "CNF_PERIOD"})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando em alteracao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRevisad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza variavel de revisao, para a revisao gerada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CN9")
	dbSetORder(1)
	If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
		cNRevisa := CN9->CN9_REVATU
	EndIf
	
	For nX:=1 to Len(aCron)
		cCrons += "'"+aCron[nX]+"',"
	Next
	
	cCrons:=SubStr(cCrons,1,len(cCrons)-1)

	If lFisico
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona cronogramas fisicos              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT CNS.R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("CNS")+" CNS "
		cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
		cQuery += "   AND CNS.CNS_CRONOG in ("+cCrons+")"
		cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
		cQuery += "   AND CNS.CNS_REVISA = '"+cNRevisa+"'"
		cQuery += "   AND CNS.D_E_L_E_T_ = ' ' "
	
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNSTMP", .F., .F. )    
	       
		dbSelectArea("CNS")	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga cronogramas alterados                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !CNSTMP->(Eof()) 
			dbGoTo(CNSTMP->RECNO)
			RecLock("CNS")
				dbDelete()
			MsUnlock()
				
			CNSTMP->(dbSkip())
		EndDo
	
		CNSTMP->(dbCloseArea())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra cronogramas alterados                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNF.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
	cQuery += " WHERE CNF.CNF_FILIAL  = '"+xFilial("CNF")+"'"
	cQuery += "   AND CNF.CNF_NUMERO in ("+cCrons+")"
	cQuery += "   AND CNF.CNF_CONTRA  = '"+cContra+"'" 
	cQuery += "   AND CNF.CNF_REVISA  = '"+cNRevisa+"'"
	cQuery += "   AND CNF.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY CNF.CNF_NUMERO,CNF.CNF_PARCEL"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )    
       
	dbSelectArea("CNF")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga cronogramas alterados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNFTMP->(Eof()) 
		dbGoTo(CNFTMP->RECNO)
		RecLock("CNF")
			dbDelete()
		MsUnlock()
			
		CNFTMP->(dbSkip())
	EndDo

	CNFTMP->(dbCloseArea())
EndIf       

cQuery := "SELECT DISTINCT CNF.CNF_NUMERO "
cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNF.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza cronogramas alterados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !CNFTMP->(Eof())
	nX := aScan(aCron,CNFTMP->CNF_NUMERO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o cronograma foi alterado               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nX > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona o codigo da planilha do contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFisico
			CNA->(dbSetOrder(2))
			CNA->(dbSeek(xFilial("CNA")+CNFTMP->CNF_NUMERO))
			cPlan := CNA->CNA_NUMERO
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera valores do cronograma                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY:=1 to len(aParcelas[nX])
			RecLock("CNF",.T.)
		      	For nZ:=1 to len(oGetDados:aHeader)
		      		If oGetDados:aHeader[nZ,10] != "V"
			      		CNF->&(oGetDados:aHeader[nZ,2]) := aParcelas[nX,nY,nZ]
			      	EndIf
		      	Next
		
				CNF->CNF_CONTRA := cContra
				CNF->CNF_REVISA := cNRevisa
				CNF->CNF_MAXPAR := len(aParcelas[nX])
				CNF->CNF_NUMERO := aCron[nX]
				CNF->CNF_FILIAL := xFilial("CNF")
				If lPeriod
					CNF->CNF_PERIOD := aParcelas[nX,1,nPosPeri]
					CNF->CNF_DIAPAR := aParcelas[nX,1,nPosDPar]
				EndIf
			MsUnlock()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa lancamento do PCO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoDetLan("000357","01","CNTA110")
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o cronograma fisico                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFisico
				For nZ:=1 to len(aColsParc[nx,ny])
					RecLock("CNS",.T.)
						CNS->CNS_FILIAL := xFilial("CNS")
						CNS->CNS_CONTRA := CNF->CNF_CONTRA
						CNS->CNS_REVISA := CNF->CNF_REVISA
						CNS->CNS_CRONOG := CNF->CNF_NUMERO
						CNS->CNS_PARCEL := CNF->CNF_PARCEL
						CNS->CNS_PLANI  := cPlan
						For nPosCpo:=1 to len(aHeadParc)
							CNS->&(aHeadParc[nPosCpo,2]) := aColsParc[nX,nY,nZ,nPosCpo]
						Next    
					MsUnlock()
				Next
			EndIf
		Next
	ElseIf !lRevisad
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona cronograma para geracao de copia           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aNCron,CNFTMP->CNF_NUMERO)	
	EndIf
	CNFTMP->(dbSkip())
EndDo

CNFTMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza alteracao de cronogramas                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aNCron) > 0
	CN140CopCron(cContra,cRevisa,cNRevisa,@aNCron)
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140CopCron³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera copia dos cronogramas do contrato                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140CopCron(cExp01,cExp02,cExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato seleciona                        ³±±
±±³          ³ cExp02 - Codigo da revisao selecionada                       ³±±
±±³          ³ cExp03 - Codigo da revisao gerada                            ³±±
±±³          ³ aExp04 - Cronogramas que devem ser copiados                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140CopCron(cContra,cRevisa,cNRevisa,aCron)
Local nX       := 0
Local aAreaCN9 := {}
Local cCrons   := ""
Local cAlias   := ""
Local cFilCNS  := ""
local cCronCtr := ""
Local aStrucCNF:= CNF->(dbStruct())
Local aStrucCNS:= CNS->(dbStruct())

DEFAULT aCron := {}

If lFisico
	cFilCNS := xFilial("CNS")
EndIf

If len(aCron) > 0
	For nX:=1 to Len(aCron)
		cCrons += "'"+aCron[nX]+"',"
	Next
	
	cCrons:=SubStr(cCrons,1,len(cCrons)-1)
EndIf
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando em alteracao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRevisad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza variavel de revisao, para a revisao gerada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaCN9 := CN9->(GetArea())
	dbSelectArea("CN9")
	dbSetOrder(1)
	If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
		cNRevisa := CN9->CN9_REVATU
	EndIf
	RestArea(aAreaCN9)

	cQuery := "SELECT CNS.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNS")+" CNS "
	cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
	cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNS.CNS_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND "
	If !Empty(cCrons)	//Filtra cronogramas que serao copiados
		cQuery += " CNS.CNS_NUMERO in ("+ cCrons +") AND "
	EndIF
	cQuery += " CNS.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNSTMP", .F., .F. )    
       
	For nx:=1 to len(aStrucCNS)
		if CNSTMP->(FieldPos(aStrucCNS[nx,1])) > 0 .And. aStrucCNS[nx,2] <> "C"
			TCSetField( "CNSTMP", aStrucCNS[nx,1], aStrucCNS[nx,2], aStrucCNS[nx,3], aStrucCNS[nx,4] )
		endif
	Next	
	dbSelectArea("CNS")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui cronograma fisico                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNSTMP->(Eof()) 
		dbGoTo(CNSTMP->RECNO)
		RecLock("CNS")
			dbDelete()
		MsUnlock()
			
		CNSTMP->(dbSkip())
	EndDo

	CNSTMP->(dbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra cronogramas da revisao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNF.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
	cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
	cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNF.CNF_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND "
	If !Empty(cCrons)//Filtra cronogramas que serao copiados
		cQuery += " CNF.CNF_NUMERO in ("+ cCrons +") AND "
	EndIF
	cQuery += " CNF.D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )    
       
	For nx:=1 to len(aStrucCNF)
		if CNFTMP->(FieldPos(aStrucCNF[nx,1])) > 0 .And. aStrucCNF[nx,2] <> "C"
			TCSetField( "CNFTMP", aStrucCNF[nx,1], aStrucCNF[nx,2], aStrucCNF[nx,3], aStrucCNF[nx,4] )
		endif
	Next  
	dbSelectArea("CNF")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga cronogramas da revisao                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNFTMP->(Eof()) 
		dbGoTo(CNFTMP->RECNO)
		RecLock("CNF")
			dbDelete()
		MsUnlock()
			
		CNFTMP->(dbSkip())
	EndDo

	CNFTMP->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra cronogramas da revisao original              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNF.* "
cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
cQuery += "   AND "
If !Empty(cCrons)//Filtra cronogramas que serao copiados
	cQuery += " CNF.CNF_NUMERO in ("+ cCrons +") AND "
EndIF
cQuery += " CNF.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )    

For nx:=1 to len(aStrucCNF)
	if CNFTMP->(FieldPos(aStrucCNF[nx,1])) > 0 .And. aStrucCNF[nx,2] <> "C"
		TCSetField( "CNFTMP", aStrucCNF[nx,1], aStrucCNF[nx,2], aStrucCNF[nx,3], aStrucCNF[nx,4] )
	EndIf
Next   
dbSelectArea("CNF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera copia dos cronogramas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !CNFTMP->(Eof())
	RecLock("CNF",.T.)
		For nx:=1 to CNF->(FCount())
			If  aStrucCNF[nx,2]<>"M"
				FieldPut(nx,CNFTMP->&(CNF->( FieldName(nX) ))) 
			EndIf
		Next
		CNF->CNF_REVISA := cNRevisa
	MsUnlock()
	
	If lFisico
		If Empty(cAlias) .Or. cCronCtr != CNFTMP->CNF_NUMERO
			cCronCtr := CNFTMP->CNF_NUMERO
			If !Empty(cAlias)
				(cAlias)->(dbCloseArea())
			EndIf
			//Itens sem valor antigo, significa que foi incluso na revisao
			cQuery := "SELECT CNA.CNA_NUMERO,CNB.CNB_ITEM "
			cQuery += "  FROM "+RetSQLName("CNB")+" CNB, "+RetSQLName("CNA")+" CNA "
			cQuery += " WHERE CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
			cQuery += "   AND CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
			cQuery += "   AND CNB.CNB_CONTRA = '"+cContra+"'"
			cQuery += "   AND CNB.CNB_CONTRA = CNA.CNA_CONTRA "
			cQuery += "   AND CNB.CNB_REVISA = '"+cNRevisa+"'"
			cQuery += "   AND CNB.CNB_REVISA = CNA.CNA_REVISA"
			cQuery += "   AND CNB.CNB_NUMERO = CNA.CNA_NUMERO"
			cQuery += "   AND CNA.CNA_CRONOG = '"+CNFTMP->CNF_NUMERO+"'"
			cQuery += "   AND CNB.CNB_PRCORI = 0 "
			cQuery += "   AND CNB.D_E_L_E_T_ = ' '"
			cQuery += "   AND CNA.D_E_L_E_T_ = ' '"
	
			cQuery := ChangeQuery( cQuery )
			cAlias := GetNextAlias()
			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlias, .F., .F. )
		EndIf

		(cAlias)->(dbGoTop())
		dbSelectArea("CNS")
		While !(cAlias)->(Eof())
			RecLock("CNS",.T.)
				CNS->CNS_FILIAL := cFilCNS
				CNS->CNS_CONTRA := CNFTMP->CNF_CONTRA
				CNS->CNS_REVISA := cNRevisa
				CNS->CNS_CRONOG := CNFTMP->CNF_NUMERO
				CNS->CNS_PARCEL := CNFTMP->CNF_PARCEL
				CNS->CNS_ITEM   := (cAlias)->CNB_ITEM
				CNS->CNS_PLANI  := (cAlias)->CNA_NUMERO 
			MsUnlock()
			(cAlias)->(dbSkip())
		EndDo
	EndIf
	CNFTMP->(dbSkip())
EndDo

If !Empty(cAlias)
	(cAlias)->(dbCloseArea())
EndIf

CNFTMP->(dbCLoseArea())

If lFisico
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona cronograma fisico                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNS.* "
	cQuery += "  FROM "+RetSQLName("CNS")+" CNS "
	cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
	cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNS.CNS_REVISA = '"+cRevisa+"'"
	cQuery += "   AND "
	If !Empty(cCrons)//Filtra cronogramas que serao copiados
		cQuery += " CNS.CNS_CRONOG in ("+ cCrons +") AND "
	EndIF
	cQuery += " CNS.D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNSTMP", .F., .F. )    
	
	For nx:=1 to len(aStrucCNS)
		if CNSTMP->(FieldPos(aStrucCNS[nx,1])) > 0 .And. aStrucCNS[nx,2] <> "C"
			TCSetField( "CNSTMP", aStrucCNS[nx,1], aStrucCNS[nx,2], aStrucCNS[nx,3], aStrucCNS[nx,4] )
		endif
	Next	 
	dbSelectArea("CNS")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera copia do cronograma fisico            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNSTMP->(Eof())
		RecLock("CNS",.T.)
			For nx:=1 to CNS->(FCount())
				If  aStrucCNS[nx,2]<>"M"
					FieldPut(nx,CNSTMP->&(CNS->( FieldName(nX) )))
				EndIf
			Next
			CNS->CNS_REVISA := cNRevisa
		MsUnlock()
		
		CNSTMP->(dbSkip())
	EndDo
	CNSTMP->(dbCLoseArea())
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140GerPlan³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera copia das planilhas de contrato                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN140GerPlan(cExp01,cExp02,cExp03,aExp04,aExp05,nExp06,aExp07)³±±
±±³          ³             lExp08,lExp09)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato seleciona                        ³±±
±±³          ³ cExp02 - Codigo da revisao selecionada                       ³±±
±±³          ³ cExp03 - Codigo da revisao gerada                            ³±±
±±³          ³ aExp04 - Itens das planilhas                                 ³±±
±±³          ³ aExp05 - Planilhas selecionadas                              ³±±
±±³          ³ nExp06 - Valor aditivado - Referencia                        ³±±
±±³          ³ aExp07 - Array com a estrutura do Header                     ³±±
±±³          ³ lExp08 - Realinhamento                                       ³±±
±±³          ³ lExp09 - Readequacao                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140GerPlan(cContra,cRevisa,cNRevisa,aItens,aPlan,nValAdit,aHeader,lReali,lReadq,nSldAdit,aReman)
Local cFilCod
Local cQuery     := ""
Local cEspCtr    := ""

Local aNPlanH:={}
Local aNPlanI:={}
Local aStrucCNA  := CNA->(dbStruct())
Local aStrucCNB  := CNB->(dbStruct())
Local aAreaCN9	 := {}

Local nTotPlH
Local nTotPlI        
Local nX
Local nY
Local nIt
Local nPlanT     := 0//Total de Planilhas
Local nPosPlan   := 0
Local nMotPlan   := 0
Local nPosVODes  := aScan(aHeader,{|x| x[2] == DEF_VLDECNA}) //Valor de desconto original
Local nPosVDesc  := aScan(aHeader,{|x| x[2] == DEF_NVLDESC}) //Novo valor de desconto
Local nPosDesc   := aScan(aHeader,{|x| x[2] == DEF_NDESC})   //Novo Desconto
Local nPosQtd    := aScan(aHeader,{|x| x[2] == "CNB_QUANT"}) //Quantidade
Local nPosQtdAc  := aScan(aHeader,{|x| x[2] == "CNB_QTRDAC"})//Quantidade Acrescida
Local nPosQtdRd  := aScan(aHeader,{|x| x[2] == "CNB_QTRDRZ"})//Quantidade Reduzida
Local nPosVlTot  := aScan(aHeader,{|x| x[2] == "CNB_VLTOT"}) //Valor Total
Local nPosVlUnit := aScan(aHeader,{|x| x[2] == "CNB_VLUNIT"})//Valor Unitario
Local nPosIt     := aScan(aHeader,{|x| x[2] == "CNB_ITEM"})  //Item
Local nPosProd   := aScan(aHeader,{|x| x[2] == "CNB_PRODUT"})//Produto
Local nPosDescr  := aScan(aHeader,{|x| x[2] == "CNB_DESCRI"})//Descricao do Produto
Local nPosUmed   := aScan(aHeader,{|x| x[2] == "CNB_UM"})    //Unidade de Medida
Local nPosQtdOr  := aScan(aHeader,{|x| x[2] == "CNB_QTDORI"})//Quantidade original
Local nPosPrcOr  := aScan(aHeader,{|x| x[2] == "CNB_PRCORI"})//Preco original
Local nPosVlRel  := aScan(aHeader,{|x| x[2] == "CNB_REALI"})//Valor Realinhado
Local nPosDtRel  := aScan(aHeader,{|x| x[2] == "CNB_DTREAL"})//Data base de Realinhamento
Local nVlTReal   := 0
Local nVlDMReal  := 0         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro que informa se havera realinhamento das medicoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRealMed := (GetNewPar("MV_CNREALM", "S") == "S")
Local lContinua:= .T.
Local lCalcReal:= .F.
Local nplmn    := 0   
Local nPlani   := 0    
Local nItMed   := 0
Local aItAtd   := {}
Local aRecParc := {}

DEFAULT lReali   := .F.
DEFAULT lReadq   := .F. 
DEFAULT nSldAdit := 0
DEFAULT aReman   := {}

If lRevisad .And. nRevRtp == 1 //Quando alteracao de revisao
	aAreaCN9 := CN9->(GetArea())
	dbSelectArea("CN9")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza campo cRevisa para a revisao gerada        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
		cRevisa := CN9->CN9_REVATU
	EndIf
	RestArea(aAreaCN9)
EndIf  
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Retorna total dos itens medidos mas nao recebidos    	   ³
//³antes da data atual                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ  
If FindFunction("VerItNMed")
	aItAtd:= VerItNMed(cContra,cRevisa,lRealMed)	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra planilhas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNA.*,CNA.R_E_C_N_O_ as RECNO "
cQuery += "  FROM "+ RetSQLName("CNA")+" CNA "
cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
cQuery += "   AND CNA.CNA_CONTRA = '"+cContra+"'"
cQuery += "   AND CNA.CNA_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNA.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CNA.CNA_NUMERO"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNATMP", .F., .F. )    

For nx:=1 to len(aStrucCNA)
	if CNATMP->(FieldPos(aStrucCNA[nx,1])) > 0 .And. aStrucCNA[nx,2] <> "C"
		TCSetField( "CNATMP", aStrucCNA[nx,1], aStrucCNA[nx,2], aStrucCNA[nx,3], aStrucCNA[nx,4] )
	endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui itens adicionados quando for reinicio de     ³
//³ revisao                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRevisad .And. nRevRtp == 2
	cQuery := "SELECT CNB.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNB")+" CNB "
	cQuery += " WHERE CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
	cQuery += "   AND CNB.CNB_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNB.CNB_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNB.CNB_DTANIV = '' "  //Filtra pela data de aniversario em branco
	cQuery += "   AND CNB.D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNBTMP", .F., .F. )    

	dbSelectArea("CNB")
	While !CNBTMP->(Eof())
		dbGoTo(CNBTMP->RECNO)
		RecLock("CNB",.F.)
			dbDelete()
		MsUnlock()
		CNBTMP->(dbSkip())
	EndDo
	
	CNBTMP->(dbCloseArea())
EndIf

cQuery := "SELECT CNB.*,CNB.R_E_C_N_O_ as RECNO  "
cQuery += "  FROM " +RetSQLName("CNB")+" CNB "
cQuery += " WHERE CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
cQuery += "   AND CNB.CNB_CONTRA = '"+cContra+"'"
cQuery += "   AND CNB.CNB_REVISA = '"+cRevisa+"'"
cQuery += "   AND "
cQuery += " CNB.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY CNB.CNB_NUMERO,CNB.CNB_ITEM"
                                                                             	
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNBTMP", .F., .F. )    

For nx:=1 to len(aStrucCNB)
	if CNBTMP->(FieldPos(aStrucCNB[nx,1])) > 0 .And. aStrucCNB[nx,2] <> "C"
		TCSetField( "CNBTMP", aStrucCNB[nx,1], aStrucCNB[nx,2], aStrucCNB[nx,3], aStrucCNB[nx,4] )
	endif
Next
                     
cFilCod := xFilial("CNA")

TotPlH := CNATMP->(FCount())//Total de campos do CNA

While !CNATMP->(Eof())
	
	nPlanT++   	 	//Total de planilhas
	nIt      := 1 	//Total de itens
	nMotPlan := 0 	//Valor total da planilha        
	nVlTReal := 0 //Valor já realizado
	nTotPlI  := CNB->(FCount())	//Total de campos do CNB
	cEspCtr := If(Empty(CNATMP->CNA_CLIENT),"1","2")

	aSize(aNPlanI,nPlanT)
	aNPlanI[nPlanT] := {}
	
	nPosPlan := aScan(aPlan,{|x| x[1]==CNATMP->CNA_NUMERO})
			
	While !CNBTMP->(Eof()) .And. CNBTMP->CNB_NUMERO == CNATMP->CNA_NUMERO
		aRecParc:={}
		nVlTReal := 0		
		
		//-- O vetor areman contem os produtos que estao passando pelo processo remanescente, portanto nao gere contrato com esses produtos
		If	!Empty(aReman) .And. AScan(aReman,{|x| x[3]==CNBTMP->CNB_PRODUT})>0
			//-- houve recebimento parcial
			If	CNBTMP->CNB_SLDREC > 0 .And. CNBTMP->CNB_SLDREC <= CNBTMP->CNB_QUANT
				//-- Ex: CNB_QUANT( 100 ) - saldo a receber CNB_SLDREC( 97 ) = recebeu 3
				aRecParc:={CNBTMP->CNB_QUANT-CNBTMP->CNB_SLDREC}
			EndIf
		EndIf

		dbSelectArea("CNB")
		dbSetOrder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera itens quando revisao, ou gera uma copia      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRevisad       
			RecLock("CNB",.T.)
		Else
			If nRevRtp == 2
				dbSeek(xFilial("CNB")+cContra+cNRevisa+CNBTMP->CNB_NUMERO+CNBTMP->CNB_ITEM)
			Else
				dbGoTo(CNBTMP->RECNO)
			EndIf
         	RecLock("CNB",.F.)
  		EndIf
		 
		//Posiciona o array aitens confome item corrente
		    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche campos do CNB                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		For nx:=1 to nTotPlI
			cField := AllTrim( CNB->( FieldName(nX) ) )
 			If (nPosField := aScan(aHeader,{|x| AllTrim(x[2]) == cField})) > 0 .And. nPosPlan > 0 .And. (nIt:= aScan(aItens[nPosPlan],{|x| AllTrim(x[1]) == CNBTMP->CNB_ITEM })) > 0
				if valtype(aItens[nPosPlan][nIt][nPosField]) <>  'U'
					FieldPut(nx,aItens[nPosPlan][nIt][nPosField])
				EndIf
			Else 			
                if CNBTMP->(FieldPos(aStrucCNB[nx,1])) > 0 
					FieldPut(nx,CNBTMP->&(CNB->( FieldName(nX) )))
				EndIf	
			EndIf
		Next
		                
		CNB->CNB_REVISA := cNRevisa
		If	!Empty(aRecParc)
			CNB->CNB_QUANT := aRecParc[1]
			CNB->CNB_VLTOT := CNB->CNB_QUANT*CNB->CNB_VLUNIT
			CNB->CNB_SLDREC:= 0
			CNB->CNB_SLDMED:= 0
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche campos alterados na revisao                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosPlan > 0 .And. nIt >0
			If !aItens[nPosPlan][nIt][len(aHeader)+1]
				CNB->CNB_VLTOT  := aItens[nPosPlan][nIt][nPosVlTot]
				CNB->CNB_VLDESC := aItens[nPosPlan][nIt][nPosVDesc]+aItens[nPosPlan][nIt][nPosVODes]
				CNB->CNB_QUANT  := aItens[nPosPlan][nIt][nPosQtd]
				CNB->CNB_QTRDAC := aItens[nPosPlan][nIt][nPosQtdAc]
				CNB->CNB_QTRDRZ := aItens[nPosPlan][nIt][nPosQtdRd]
				CNB->CNB_QTDORI := aItens[nPosPlan][nIt][nPosQtdOr]
				CNB->CNB_PRCORI := aItens[nPosPlan][nIt][nPosPrcOr]
				CNB->CNB_DESC   := (CNB->CNB_VLDESC*100)/CNB->CNB_VLTOT//Calcula novo desconto
				
				If lReali 
					If  CNBTMP->CNB_SLDMED == 0 //Somente realinha o item se o saldo para ser medido for maior que 0 e parametro MV_CNREALM='S'
						CNB->CNB_REALI := 0
						CNB->CNB_DTREAL:= CTOD("  /  /  ")			
						CNB->CNB_VLTOTR:= 0 
						nMotPlan	   += CNB->CNB_VLTOT 
						lContinua      := .F.
					Else
						CNB->CNB_REALI := aItens[nPosPlan][nIt][nPosVlRel]
						CNB->CNB_DTREAL:= aItens[nPosPlan][nIt][nPosDtRel]			
						CNB->CNB_VLTOTR:= (CNB->CNB_QTDMED*CNB->CNB_VLUNIT)+(CNB->CNB_SLDMED*CNB->CNB_REALI)//Calcula valor total realinhado
						lContinua := .T.
					EndIf 
					
					If lContinua	     
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o item possui valor a ser recebido  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPlani := aScan(aItAtd,{|x| x[1,1] == CNB->CNB_NUMERO})
						If nPlani > 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Considera apenas valores anteriores a data base ³
							//³ de realinhamento, pois as medicoes posteriores  ³
							//³ serao recalculadas                              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nItMed := 0
							aEval(aItAtd[nPlani],{|x| nItMed += If(x[2] == CNB->CNB_ITEM .AND. x[4] < DTOS(CNB->CNB_DTREAL),x[3],0)})
						Else
							nItMed := 0
						EndIf   
							
						If lRealMed .And. (nItMed == 0)       
							nVlTReal   := (CNB->CNB_SLDMED*(CNB->CNB_REALI-((CNB->CNB_REALI*CNB->CNB_DESC)/100))) +((CNB->CNB_QTDMED*(CNB->CNB_REALI-((CNB->CNB_REALI*CNB->CNB_DESC)/100)))-(CNB->CNB_REALI*(CNB->CNB_QUANT-CNB->CNB_SLDREC)))+(CNB->CNB_VLUNIT*(CNB->CNB_QUANT-CNB->CNB_SLDREC)) //Calcula valor total realinhado
						Else                                                                                                                                                                                               
							nVlTReal   := (CNB->CNB_QTDMED*(CNB->CNB_VLUNIT-((CNB->CNB_VLUNIT*CNB->CNB_DESC)/100)))+(CNB->CNB_SLDMED*(CNB->CNB_REALI-((CNB->CNB_REALI*CNB->CNB_DESC)/100)))//Calcula valor total realinhado					
						EndIf     
					EndIf
				EndIf
				
				//Limpa readequacao
				CNB->CNB_QTREAD := 0
				CNB->CNB_VLREAD := 0
				CNB->CNB_VLRDGL := 0
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Nao sera atualizado se for item de historico que passou por revisao de realinhamento ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CNB->CNB_SLDMED += (CNB->CNB_QUANT-CNB->CNB_QTDORI)-(CNBTMP->CNB_QUANT-CNB->CNB_QTDORI)
				CNB->CNB_SLDREC += (CNB->CNB_QUANT-CNB->CNB_QTDORI)-(CNBTMP->CNB_QUANT-CNB->CNB_QTDORI)
			

				if CNB->CNB_QTRDAC > 0
					If lReadq
						CNB->CNB_QTREAD := CNB->CNB_QTRDAC	//Quantidade readequada
						CNB->CNB_VLREAD := CNB->CNB_QTRDAC*CNB->CNB_VLUNIT	//Valor readequado
						CNB->CNB_VLRDGL := CNB->CNB_QTRDAC*(CNB->CNB_VLUNIT-((CNB->CNB_VLUNIT*CNB->CNB_DESC)/100))	//Valor readequado global
					Endif
				elseif CNB->CNB_QTRDRZ > 0
					If lReadq
						CNB->CNB_QTREAD := CNB->CNB_QTRDRZ	//Quantidade readequada
						CNB->CNB_VLREAD := CNB->CNB_QTRDRZ*CNB->CNB_VLUNIT	//Valor readequado
						CNB->CNB_VLRDGL := CNB->CNB_QTRDRZ*(CNB->CNB_VLUNIT-((CNB->CNB_VLUNIT*CNB->CNB_DESC)/100))	//Valor readequado global
					Endif
				EndIf
			Else
				dbDelete()
			EndIf
		Else
			If lRevisad .And. nRevRtp == 1  .And. lReali   
				lCalcReal := .T.
				If lRealMed
					nVlTReal   := (CNB->CNB_SLDMED*(CNB->CNB_REALI-((CNB->CNB_REALI*CNB->CNB_DESC)/100))) +((CNB->CNB_QTDMED*(CNB->CNB_REALI-((CNB->CNB_REALI*CNB->CNB_DESC)/100)))-(CNB->CNB_REALI*(CNB->CNB_QUANT-CNB->CNB_SLDREC)))+(CNB->CNB_VLUNIT*(CNB->CNB_QUANT-CNB->CNB_SLDREC)) //Calcula valor total realinhado
				Else                                                                                                                                                                                               
					nVlTReal   := (CNB->CNB_QTDMED*(CNB->CNB_VLUNIT-((CNB->CNB_VLUNIT*CNB->CNB_DESC)/100)))+(CNB->CNB_SLDMED*(CNB->CNB_REALI-((CNB->CNB_REALI*CNB->CNB_DESC)/100)))//Calcula valor total realinhado					
				EndIf 
			EndIf
			
			CNB->CNB_QTDORI := CNB->CNB_QUANT
			CNB->CNB_PRCORI := CNB->CNB_VLUNIT
		EndIf     
			                                                                                    
		If !deleted()
			If !lCalcReal .And. (!lReali .Or. nPosPlan == 0)
				nMotPlan+=CNB->CNB_VLTOT-CNB->CNB_VLDESC			
			Else
				nMotPlan +=nVlTReal
			EndIf		
		EndIf	
		
		MsUnLock()
		      
		nIt++  
		CNBTMP->(dbSkip())
	EndDo
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica e inclui itens adicionados nas planilhas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTpRev == DEF_ADITI 
	  	If nPosPlan > 0 .And. len(aItens[nPosPlan]) > nIt-1
	  		For nX:=nIt to len(aItens[nPosPlan])
	  			If !aItens[nPosPlan][nX][len(aHeader)+1]
	  				// Verifica se o item ja existe
	  				CNB->(dBSetOrder(1))
	  				If !CNB->(DbSeek(xFilial('CNB')+CNATMP->CNA_CONTRA+cNRevisa+CNATMP->CNA_NUMERO+aItens[nPosPlan,nX,nPosIt]))
		  				RecLock("CNB",.T.)
		  			Else
		  				RecLock("CNB",.F.)
		  			Endif
		  				CNB->CNB_FILIAL := xFilial("CNB")
		  				nplmn:=0
		  				For nplmn:=1 to FCount()
		  					If aScan(aHeader,{|x| AllTrim(x[2])==CNB->(FieldName(nplmn))})>0
		  						FieldPut(nplmn,aItens[nPosPlan,nX,aScan(aHeader,{|x| x[2]==CNB->(FieldName(nplmn))})])
		  					EndIf
		  				Next
		  				CNB->CNB_NUMERO := CNATMP->CNA_NUMERO
		  				CNB->CNB_REVISA := cNRevisa
			  			CNB->CNB_CONTRA := CNATMP->CNA_CONTRA
						CNB->CNB_DTCAD  := dDataBase
						CNB->CNB_SLDMED := CNB->CNB_QUANT
						CNB->CNB_SLDREC := CNB->CNB_QUANT    
						CNB->CNB_DTANIV := dDataBase
						CNB->CNB_DESC   := aItens[nPosPlan,nX,nPosDesc]
						CNB->CNB_VlDESC := aItens[nPosPlan,nX,nPosVDesc]  
					MsUnLock()
	  				nMotPlan+=CNB->CNB_VLTOT-CNB->CNB_VLDESC 
	  			EndIf
	  		Next
	  	EndIf                                                                                         
	EndIf                                                                                           	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza ou gera copia das planilhas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CNA")
	dbSetOrder(1)
	if !lRevisad
	   RecLock("CNA",.T.)
	Else
		dbSeek(xFilial("CNA")+cContra+cNRevisa+CNATMP->CNA_NUMERO)
		RecLock("CNA",.F.)
	EndIf
   
   nTotPlH := CNA->( FCount() )//Total de campos da planilha

	for nx:=1 to nTotPlH                                 
		If  aStrucCNA[nx,2]<>"M"
			FieldPut(nx,CNATMP->&(CNA->( FieldName(nX) )))
		EndIf
	Next
	
	//Calcula aditivo
	nValAdit += nMotPlan-CNA->CNA_VLTOT     
	nSldAdit += (nMotPlan-CNA->CNA_VLTOT)
	 
	CNA->CNA_REVISA := cNRevisa
	CNA->CNA_SALDO  += (nMotPlan-CNA->CNA_VLTOT)
	CNA->CNA_VLTOT  := nMotPlan

	MsUnlock()   

	CNATMP->(dbSkip())
EndDo

//-- Grava localizacoes fisicas        
If AliasInDic("AGW") .And. ValType(aPlan)=="A" 
	CNB->(dbSetOrder(1))
	AGW->(dbSetOrder(2))
	For nX := 1 To Len(aPlan)
		If ValType(aTail(aPlan[nX])) == "A"
			For nIt := 1 To Len(aTail(aPlan[nX]))	
				If CNB->(dbSeek(xFilial("CNB")+cContra+cNRevisa+aPlan[nX,1]+aTail(aPlan[nX])[nIt,1])) .And. CNB->CNB_BASINS == '1'
					RecLock("AGW",!AGW->(dbSeek(xFilial("AGW")+cContra+aPlan[nX,1]+aTail(aPlan[nX])[nIt,1])))
					For nY := 1 To Len(aTail(aPlan[nX])[nIt,2])
						AGW->&(aTail(aPlan[nX])[nIt,2,nY,1]) := aTail(aPlan[nX])[nIt,2,nY,2]
					Next nY
					AGW->AGW_FILIAL := xFilial("AGW")
					AGW->AGW_PLANIL := CNB->CNB_NUMERO
					AGW->AGW_PRODUT := CNB->CNB_PRODUT
					AGW->(MsUnLock())
				ElseIf AGW->(dbSeek(xFilial("AGW")+cContra+aPlan[nX,1]+aTail(aPlan[nX])[nIt,1]))
					RecLock("AGW",.F.)
					AGW->(dbDelete())
					AGW->(MsUnLock())
				EndIf		
			Next nIt
		EndIf
	Next nX    
EndIf

CNBTMP->( dbCloseArea() )
CNATMP->( dbCloseArea() )

Return nPlanT
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldQtd³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina responsavel pela alteracao de quantidade dos itens   ³±±
±±³          ³ das planilhas, executa validacao especifica para o programa ³±±
±±³          ³ CNTA140                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldQtd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldQtd()

Local lRet     := .T. 
Local lRotAuto := Type("lMsHelpAuto") == "L" .And. lMsHelpAuto 
Local nPosSld  := 0
Local nPosQOri := 0
Local nDif     := 0
Local nPosAcre := 0
Local nPosDecr := 0
Local nPosODesc:= 0	//Desconto Original
Local nPosOVDes:= 0	//Valor Desconto original
Local nPosNDesc:= 0	//Novo Desconto
Local nPosNVDes:= 0	//Novo Valor de Desconto
Local nPosVlUn := 0	//Valor unitario
Local nPosVlTot:= 0           
Local nPosQtd  := 0 
Local nX       := 0     
Local nTotItens:= 0  
Local nPlanVlT := 0 

//Rotina especifica para revisao             
If FunName() == "CNTA140" .And. !lRotAuto   
	nPlanVlT := Posicione("CNA",1,xFilial("CNA")+cContra+cRevAtu,"CNA_VLTOT")
	nPosSld  := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QTDMED"})
	nPosQOri := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QTDORI"})
	
	lRet := (M->CNB_QUANT >= oGetDad1:aCols[oGetDad1:nAt][nPosSld])
	
	If lRet
		if cModo == "1"		//Quando for apenas acrescimo
			lRet     := (M->CNB_QUANT >= oGetDad1:aCols[oGetDad1:nAt][nPosQOri])
		ElseIf cModo == "2"	//Quando for apenas decrescimo
			lRet     := (M->CNB_QUANT <= oGetDad1:aCols[oGetDad1:nAt][nPosQOri])
		EndIf
	EndIf  
	
	If lRet
		nPosAcre  := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QTRDAC"})
		nPosDecr  := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QTRDRZ"})
		nPosNDesc := aScan(oGetDad1:aHeader,{|x| x[2] == DEF_NDESC})
		nPosNVDes := aScan(oGetDad1:aHeader,{|x| x[2] == DEF_NVLDESC})
		nPosODesc := aScan(oGetDad1:aHeader,{|x| x[2] == DEF_DESCNA})
		nPosOVDes := aScan(oGetDad1:aHeader,{|x| x[2] == DEF_VLDECNA})
		nPosVlUn  := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_VLUNIT"})
		nPosVlTot := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_VLTOT"})
		nPosQtd   := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QUANT"})
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula diferenca                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		nDif := M->CNB_QUANT - oGetDad1:aCols[oGetDad1:nAt][nPosQOri]
	
		nTotItens := 0
   		For nx := 1 to Len(oGetDad1:aCols)
  			If nx != n
 				nTotItens += oGetDad1:aCols[nx,nPosQtd]*oGetDad1:aCols[nx,nPosVlUn]-((ogetDad1:aCols[nx,nPosVlUn]*ogetDad1:aCols[nx,nPosNDesc])/100)
 			EndIf
		Next

		nVlPAtu := nTotItens // valor dos demais itens
		
		if nDif > 0
			oGetDad1:aCols[oGetDad1:nAt][nPosAcre] := nDif
			oGetDad1:aCols[oGetDad1:nAt][nPosDecr] := 0
			ogetDad1:aCols[oGetDad1:nAt][nPosNVDes]:= ((nDif*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn])*ogetDad1:aCols[oGetDad1:nAt][nPosNDesc])/100
			ogetDad1:aCols[oGetDad1:nAt][nPosOVDes]:= (((M->CNB_QUANT-nDif)*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn])*ogetDad1:aCols[oGetDad1:nAt][nPosODesc])/100
		 	nVlPAtu += M->CNB_QUANT*(ogetDad1:aCols[oGetDad1:nAt][nPosVlUn]-((ogetDad1:aCols[oGetDad1:nAt][nPosVlUn]*ogetDad1:aCols[oGetDad1:nAt][nPosNDesc])/100))
		 	If (nPlanVlT-nVlPAtu >0) .And. (nPlanVlT-nVlPAtu <=0.01)
		  		nVlPAtu += nPlanVlT-nVlPAtu
			EndIf 
		Else
			oGetDad1:aCols[oGetDad1:nAt][nPosDecr] := nDif*-1
			oGetDad1:aCols[oGetDad1:nAt][nPosAcre] := 0
			ogetDad1:aCols[oGetDad1:nAt][nPosNVDes]:= 0
			ogetDad1:aCols[oGetDad1:nAt][nPosOVDes]:= ((M->CNB_QUANT*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn])*ogetDad1:aCols[oGetDad1:nAt][nPosODesc])/100
			nVlPAtu += M->CNB_QUANT*(ogetDad1:aCols[oGetDad1:nAt][nPosVlUn]-((ogetDad1:aCols[oGetDad1:nAt][nPosVlUn]*ogetDad1:aCols[oGetDad1:nAt][nPosODesc])/100))
		EndIf
	EndIf
	oVlPAtu:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldDesc³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida desconto dos itens                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldDesc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldDesc()
Local lRet  := .T.   
Local nDesc := M->&(DEF_NDESC)
Local nPosAcre := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QTRDAC"})
Local nPosQtd  := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QUANT"})
Local nPosVlUn := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_VLUNIT"})
Local nPosNVDes:= aScan(oGetDad1:aHeader,{|x| x[2] == DEF_NVLDESC})
Local nPosVlOri:= aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_PRCORI"})

If nDesc < 0 .Or. nDesc > 100
	lRet := .F.
Else
	If ogetDad1:aCols[oGetDad1:nAt][nPosVlOri] != 0	//Item antigo
		if ogetDad1:aCols[oGetDad1:nAt][nPosAcre] > 0  
			ogetDad1:aCols[oGetDad1:nAt][nPosNVDes] := NoRound(((ogetDad1:aCols[oGetDad1:nAt][nPosAcre]*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn])*nDesc)/100,TamSX3("CNE_VLDESC")[2])
		Else
			ogetDad1:aCols[oGetDad1:nAt][nPosNVDes] := 0	
		EndIf
	Else	//Item novo
		if ogetDad1:aCols[oGetDad1:nAt][nPosQtd] > 0
			ogetDad1:aCols[oGetDad1:nAt][nPosNVDes] := NoRound(((ogetDad1:aCols[oGetDad1:nAt][nPosQtd]*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn])*nDesc)/100,TamSX3("CNE_VLDESC")[2])
		Else
			ogetDad1:aCols[oGetDad1:nAt][nPosNVDes] := 0	
		EndIf	
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP11³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 11 - valida cronograma atual          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN140VlP11(cExp01,cExp02,cExp03,aExp04,aExp05,aExp06,aExp07 ³±±
±±³Sintaxe   ³           aExp08,aExp09)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                ³±±
±±³          ³ cExp02 - Codigo da revisao                                 ³±±
±±³          ³ cExp03 - Cronograma atual                                  ³±±
±±³          ³ aExp04 - Parcelas dos cronogramas                          ³±±
±±³          ³ aExp05 - Cronogramas selecionsados                         ³±±
±±³          ³ aExp06 - Array com os totalizadores dos cronogramas        ³±±
±±³          ³ aExp07 - Array contendo estrutura fisica do contrato       ³±±
±±³          ³ aExp08 - Parcelas dos cronogramas fisicos                  ³±±
±±³          ³ aExp09 - Cabecalho das parcelas fisicas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP11(cContra,cRevisa,cCron,aParcelas,aCron,aTotCont,aFscVl,aColsParc,aHeadParc)
Local lRet       := .T.
Local nPos       := aScan(aCron,cCron)
Local nx         := 0
Local ny         := 0
Local nPosItm    := 0       
Local nPosPrumed := aScan(aHeader,{|x| x[2] == "CNF_PRUMED"}) 
Local nPosSaldo  := aScan(aHeader,{|x| x[2] == "CNF_SALDO"}) 
Local dRevisao   := Posicione("CN9",1,xFilial("CN9")+cContra+cRevisa,"CN9_DTREV")

If !lFisico
	If nTotPlan != nTotCronog
		Help("CNTA140",1,"CNTA140_11")  //"O montante do cronograma deve ser igual ao montante da planilha"
		lRet := .F.
	EndIf
Else
	For nx:=1 to len(aFscVl[nPos])  //Valida o cronograma fisico
		If aFscVl[nPos,nx,3] != 0
			nPosItm := aScan(aHeadParc,{|x| AllTrim(x[2]) == "CNS_ITEM"})
			Aviso("CNTA140",OemToAnsi(STR0099)+aColsParc[nPos,1,nx,nPosItm]+OemToAnsi(STR0100)+cCron,{"OK"})//"O saldo físico do item "###" não foi distríbuido corretamente entre as parcelas do cronograma "
			lRet := .F.
			Exit
		EndIf
	Next
EndIf      

If lRet .And. cTipoCtr$"6" 
	For nX:=1 to len(oGetDados:aCols)  //Valida a revisão de reinicio
	    If  oGetDados:aCols[nX,nPosPrumed]<=dDataBase .And. oGetDados:aCols[nX,nPosPrumed]>=dRevisao .And. oGetDados:aCols[nX,nPosSaldo]>0
	    	Aviso("CNTA140",OemtoAnsi(STR0127),{"Ok"})//"Existem saldos para serem medidos durante o período de paralisação, reestruture os cronogramas antes de aprovar a revisão"
			lRet := .F.  
			Exit
	    EndIf
	Next nX
EndIf

If lRet
	If nPos > 0            
		aTotCont[nPos,1] := nTotCronog
		aTotCont[nPos,8] := nTotPlan
		aParcelas[nPos]  := oGetDados:aCols	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida saldo de todos os cronograma                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 to len(aCron)
		If !lFisico
			If aTotCont[nX,1] != 	aTotCont[nX,8]
				Aviso("CNTA140",STR0093+aCron[nX]+STR0094,{"OK"})//"O cronograma "##" possui saldo a ser distribuído"
				lRet := .F.
				Exit
			EndIf
		Else
			For nY:=1 to len(aFscVl[nX])  //Valida o cronograma fisico
				If aFscVl[nX,nY,3] != 0
					nPosItm := If(nPosItm=0,aScan(aHeadParc,{|x| AllTrim(x[2]) == "CNS_ITEM"}),nPosItm)
					Aviso("CNTA140",OemToAnsi(STR0099)+aColsParc[nX,1,nY,nPosItm]+OemToAnsi(STR0100)+aCron[nX],{"OK"})//"O saldo físico do item "###" não foi distríbuido corretamente entre as parcelas do cronograma "
					lRet := .F.
					Exit
				EndIf
			Next
		EndIf
	Next     
	
	If cTipoCtr$"1/6/8" .And.  cEspec $ "3/4/5" .And. lContab
		CN140PlnCt(cContra,cRevisa,@lRet,@aCron)  //Carrega Planilhas
		IF lRet .and. lMotREvOk
			oWizard:NPanel := 11  //Segue para o painel de planilhas  
		Else
			oWizard:NPanel := 15  //Segue para painel final		
		Endif   
	Else   
		If lRet
		   	oWizard:NPanel := 15  //Segue para painel final
		EndIf
	Endif   
EndIf

If ExistBlock("CN140BLQ")
 	aRetCnv := ExecBlock("CN140BLQ",.F.,.F.,{cTpCron,nParcel,lAltPar})
	If ValType(aRetCnv)=="A"
		If Len(aRetCnv)>=1 .And. ValType(aRetCnv[1]) == "C"
			cTpCronCtb  := aRetCnv[1]
		Endif
		If Len(aRetCnv)>=2 .And. ValType(aRetCnv[2]) == "N"
			nParcelas := aRetCnv[2]
		Endif
		If Len(aRetCnv)>=3 .And. ValType(aRetCnv[3]) == "L"
			lAltPar := aRetCnv[3]
		Endif
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140LoadPr³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega parcelas do cronograma selecionado                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LoadPr(cExp01,aExp02,aExp03,aExp04,cExp05,oExp06)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Cronogram selecionado - Referencia                 ³±±
±±³          ³ aExp02 - Parcelas dos cronogramas                           ³±±
±±³          ³ aExp03 - Cronogramas selecionados                           ³±±
±±³          ³ aExp04 - Array com os totalizadores dos cronogramas         ³±±
±±³          ³ aExp05 - Cronograma atual - Referencia                      ³±±
±±³          ³ aExp06 - Combo com os cronogramas                           ³±±
±±³          ³ aExp07 - Cabecalho do cronograma fisico                     ³±±
±±³          ³ aExp08 - Parcelas dos cronogramas fisicos                   ³±±
±±³          ³ aExp09 - Array contendo estrutura da planilha, usado pelas  ³±±
±±³          ³          parcelas do cronograma fisico                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140LoadPr(cCron,aParcelas,aCron,aTotCont,cCronO,oCron,aHeadParc,aColsParc,aFscVl,cCodTR)

Local lRet    := .T.
Local nPos    := aScan(aCron,cCron)
local nPosO   := aScan(aCron,cCronO)
Local nPosItm := 0
Local nx
Default cCodTR := ""

If cCron != cCronO
	If !lFisico
		If nTotPlan != nTotCronog
			Help("CNTA140",1,"CNTA140_11")//"O montante do cronograma deve ser igual ao montante da planilha"
			lRet      := .F.
			oCron:nAt := nPosO
			cCron     := cCronO
		EndIf
	Else
		For nx:=1 to len(aFscVl[nPosO])
			If aFscVl[nPosO,nx,3] != 0//Valida o cronograma fisico
				nPosItm := aScan(aHeadParc,{|x| AllTrim(x[2]) == "CNS_ITEM"})
				Aviso("CNTA140",OemToAnsi(STR0099)+aColsParc[nPosO,1,nx,nPosItm]+OemToAnsi(STR0100)+cCronO,{"OK"})//"O saldo físico do item "###" não foi distríbuido corretamente entre as parcelas do cronograma "
				lRet      := .F.
				oCron:nAt := nPosO
				cCron     := cCronO
				Exit
			EndIf
		Next
	EndIf
	
	If lRet .And. nPos > 0
		If !Empty(cCronO) .And. cCronO != cCron
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza array de controle com as variaveis privates usadas ³
			//³pela validacao do CNTA110                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosO := aScan(aCron,cCronO)
			aTotCont[nPosO,1] := nTotCronog
			aTotCont[nPosO,8] := nTotPlan
			
			aParcelas[nPosO] := oGetDados:aCols
		EndIf
		
		oGetDados:aCols := aParcelas[nPos]    
		oGetDados:nMax  :=Len(aParcelas[nPos])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega rotina do cronograma fisico simulando chamada atraves ³
		//³do array aItVL                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFisico
			aItVl := aFscVl[nPos]
			oGetDados:oBrowse:bLDblClick := {|| If(oGetDados:oBrowse:COLPOS==3,(CN140Fisico(4,@aParcelas[nPos],oGetDados:nAt,aColsParc[nPos],aHeadParc,aFscVl[nPos],cCodTR),oGetDados:aCols:=aParcelas[nPos],CN110AtuVal(),oGetDados:oBrowse:Refresh(),aFscVl[nPos] := aItVl),oGetDados:EDITCELL()) }
		EndIf

		oGetDados:oBrowse:Refresh()
	
		oTotPlan:cTitle   := Transform(aTotCont[nPos,8],PesqPict("CNA","CNA_VLTOT"))
		oTotCronog:cTitle := Transform(aTotCont[nPos,1],PesqPict("CNA","CNA_VLTOT"))
		oSaldDist:cTitle  := Transform(aTotCont[nPos,8]-aTotCont[nPos,1],PesqPict("CNA","CNA_VLTOT"))
		oSaldCont:cTitle  := Transform(aTotCont[nPos,9],PesqPict("CN9","CN9_SALDO"))
		oSaldPlan:cTitle  := Transform(aTotCont[nPos,7],PesqPict("CNA","CNA_SALDO"))
		
		//Atualiza variaveis privates usadas pela validacao do CNTA110
		nTotCronog := aTotCont[nPos,1]
		nTotPlan   := aTotCont[nPos,8]
		
		//Atualiza variavel de controle da troca de cronogramas
		cCronO := cCron
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP10³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 10 - Selecao de cronogramas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP10(aExp01,aExp02,cExp03,cExp04,aExp05,lExp06,      ³±±
±±³          ³           lExp07,oExp08,nExp09,cExp10,dExp11,cExp12,aExp13,³±±
±±³          ³           nExp14,aExp15,aExp16,aExp17,aExp18,aExp19,aExp20)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Parcelas dos cronogramas                          ³±±
±±³          ³ aExp02 - Array com os totalizadores dos cronogramas        ³±±
±±³          ³ cExp03 - Contrato                                          ³±±
±±³          ³ cExp04 - Revisao                                           ³±±
±±³          ³ aExp05 - Array com os cronogramas selecionados             ³±±
±±³          ³ lExp06 - Realiza arrasto do saldo                          ³±±
±±³          ³ lExp07 - Realiza distribuicao dos saldos                   ³±±
±±³          ³ oExp08 - Acrescimo/Decrescimo de parcelas                  ³±±
±±³          ³ nExp09 - Total de parcelas para acres\decres               ³±±
±±³          ³ cExp10 - Cronograma atual                                  ³±±
±±³          ³ dExp11 - Data de termino do contrato - referencia          ³±±
±±³          ³ cExp12 - Codigo do tipo de revisao                         ³±±
±±³          ³ aExp13 - Array com os valores aditivados das planilhas     ³±±
±±³          ³ nExp14 - Aditivo da vigencia em dias                       ³±±
±±³          ³ aExp15 - Cabecalho das parcelas fisicas do cronograma      ³±±
±±³          ³ aExp16 - Parcelas fisicas do cronograma                    ³±±
±±³          ³ aExp17 - Array de controle do cronograma fisico            ³±±
±±³          ³ aExp18 - Quantidade aditiva nas planilhas do contrato      ³±±
±±³          ³ aExp19 - Cabecalho dos itens da planilha                   ³±±
±±³          ³ aExp20 - Itens das planilhas                               ³±±
±±³          ³ oExp21 - Botao de manutencao do cronograma fisico          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP10(aParcelas,aTotCont,cContra,cRevisa,aCron,lArrasto,lDist,oTpCron,nParcel,cCronO,dFContra,cCodTR,aAditPlan,nVgAdit,aHeadParc,aColsParc,aFscVl,aAditQtd,aHeaderIT,aItens,oBtnFsc,aParAnt,aParVlR)

Local lRet     := .T.

Local cCrons   := ""
Local cQuery   := ""
Local cCampos  := "CNF_NUMERO|CNF_CONTRA|CNF_MAXPAR|CNF_REVISA|CNF_PERANT"
Local cEspRev  := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_ESPEC")

Local aNCpo    := {}
Local aCpo     := {}
Local aStrucCNF:= CNF->(dbStruct())
Local aRetPac  := {}
Local aItmAdt  := {}

Local nTotAdit	:= 0
Local nPosDtF	:= 0
Local nX		:= 0
Local nY		:= 0
Local nPos		:= 0
Local nPosPlan	:= 0
Local nDif		:= 0
Local nPosVPrv	:= 0
Local nPosVRea	:= 0

Local dAvc
Local dMaxDate := Posicione("CN9",1,xFilial("CN9")+cContra+cRevisa,"CN9_DTINIC")

If lFisico
	aAdd(aNCpo,"CNF_VLPREV")
	oBtnFsc:lVisibleControl := .T.
	oBtnFsc:Refresh()
Else
	oBtnFsc:lVisibleControl := .F.
	oBtnFsc:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza cRevisa quando alteracao de revisao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lRevisad .And. (nRevRtp==1))
	dbSelectArea("CN9")
	dbSetOrder(1)
	If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
		cRevisa := CN9->CN9_REVATU
	EndIf
EndIf

// atualiza objeto do cronograma
oBrowse4:Refresh()
oCron:aItems := ASort(aCron)
oCron:nAt := 1

aTotCont := {}//Armazena totais dos cronogramas

If Len(aCron) == 0
	Help("CNTA140",1,"CNTA140_12")//"Selecione um cronograma"
	lRet := .F.
EndIf
If !lFisico
	oWizard:NPanel := 15
EndIf
If lRet .And. lFisico
	For nX:=1 to Len(aCron)
		cCrons += "'"+aCron[nX]+"',"
	Next
	
	cCrons:=SubStr(cCrons,1,len(cCrons)-1)
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek("CNF", .F.)
		While !Eof() .And. SX3->X3_ARQUIVO=="CNF"
			If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .And. !(AllTrim(SX3->X3_CAMPO) $ cCampos)
				AAdd(aHeader,{AllTrim(X3Titulo()),;
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

			If SX3->X3_VISUAL == "A" .And. (aScan(aNCpo,AllTrim(SX3->X3_CAMPO)) == 0)
				aAdd(aCpo,AllTrim(SX3->X3_CAMPO))
			EndIf
			dbSkip()
		EndDo
	EndIf
	
	//Verifica data dos cronogramas nao selecionados
	If TRBCNF->(RecCount()) != len(aCron)
		cQuery := "SELECT Max(CNF.CNF_PRUMED) as CNF_PRUMED "
		cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
		cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
		cQuery += "   AND CNF.CNF_NUMERO not in ("+cCrons +")"
		cQuery += "   AND CNF.CNF_CONTRA = '"+cContra +"'"
		cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa +"'"
		cQuery += "   AND CNF.D_E_L_E_T_ <> '*'"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )

		TCSetField("CNFTMP","CNF_PRUMED","D",8,0)
		
		dMaxDate := CNFTMP->CNF_PRUMED
		
		CNFTMP->(dbCloseArea())
	EndIf
	
	cQuery := "SELECT * "
	cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
 	cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
	cQuery += "   AND CNF.CNF_NUMERO in ("+cCrons+")"
	cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
	cQuery += "   AND CNF.D_E_L_E_T_ <> '*' "
	cQuery += " Order by CNF.CNF_NUMERO,CNF.CNF_PARCEL"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNFTMP", .F., .F. )
	
	For nx:=1 to len(aStrucCNF)
		if ("CNFTMP")->(FieldPos(aStrucCNF[nx,1])) > 0 .And. aStrucCNF[nx,2] <> "C"
			TCSetField( "CNFTMP", aStrucCNF[nx,1], aStrucCNF[nx,2], aStrucCNF[nx,3], aStrucCNF[nx,4] )
		endif
	Next
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do aTotCont                          ³
	//³aTotCont[x][1] - Montante do Cronograma        ³
	//³aTotCont[x][2] - Saldo do cronograma           ³
	//³aTotCont[x][3] - Saldo das parcelas medidas    ³
	//³aTotCont[x][4] - Montante das parcelas medidas ³
	//³aTotCont[x][5] - Total de parcelas nao medidas ³
	//³aTotCont[x][6] - Primeira parcela nao medidas  ³
	//³aTotCont[x][7] - Saldo da Planilha             ³
	//³aTotCont[x][8] - Total da Planilha             ³
	//³aTotCont[x][9] - Saldo do Contrato             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotCont  := Array(len(aCron))
	aParcelas := Array(len(aCron))
	
	If lFisico
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa os controles fisicos do contrato  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColsParc := {}
		aItVl     := {}
		aFscVl    := {}
		If len(aHeadParc) == 0
			CN110MtFsc(aHeadParc)
		EndIf
	Endif
	
	While !CNFTMP->(Eof())
		nPos := aScan(aCron,CNFTMP->CNF_NUMERO)
		if valtype(aTotCont[nPos]) != "A"
			aTotCont[nPos] := {0,0,0,0,0,0,0,0,0}
			aParcelas[nPos]:= {}
		EndIf
		
		aAdd(aParcelas[nPos],Array(len(aHeader)+1))
		
		For nx:=1 to len(aHeader)
			If CNFTMP->( FieldPos( aHeader[nx,2] ) ) > 0
				aParcelas[nPos,len(aParcelas[nPos]),nX] := CNFTMP->( &(aHeader[nx,2]) )
			Else
				aParcelas[nPos,len(aParcelas[nPos]),nX] := CriaVar( aHeader[nx,2] )
			EndIf
		Next

		aParcelas[nPos,len(aParcelas[nPos]),len(aHeader)+1] := .F.
		
		aTotCont[nPos,1] += CNFTMP->CNF_VLPREV
		aTotCont[nPos,2] += CNFTMP->CNF_SALDO
		
		if !Empty(CNFTMP->CNF_DTREAL)
			aTotCont[nPos,3] += CNFTMP->CNF_SALDO//Soma saldo medido
			aTotCont[nPos,4] += Round(CNFTMP->CNF_VLPREV,TamSX3("CNF_VLPREV")[2])//Soma montante medido
		Else
			aTotCont[nPos,5]++//Incrementa parcelas nao medidas
			if Empty(aTotCont[nPos,6])
				aTotCont[nPos,6] := CNFTMP->CNF_PARCEL//Primeira parceça nao medida
			EndIf
		EndIf
		
		CNFTMP->(dbSkip())
	EndDo
	
	CNFTMP->(dbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula total aditivado de todas as planilhas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY:=1 to len(aAditPlan)
		nTotAdit += aAditPlan[nY,2]
	Next
	
	For nx:=1 to len(aCron)
		cQuery := "SELECT CNA.CNA_VLTOT, CNA.CNA_SALDO, CNA.CNA_NUMERO "
		cQuery += "  FROM "+RetSQLName("CNA")+" CNA "
		cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
		cQuery += "   AND CNA.CNA_CONTRA = '"+cContra +"'"
		cQuery += "   AND CNA.CNA_REVISA = '"+cRevisa +"'"
		cQuery += "   AND CNA.CNA_CRONOG = '"+aCron[nx]+"'"
		cQuery += "   AND CNA.D_E_L_E_T_ <> '*'"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNATMP", .F., .F. )
		
		TCSetField("CNATMP","CNA_VLTOT","N",TamSX3("CNA_VLTOT")[1],TamSX3("CNA_VLTOT")[2])
		TCSetField("CNATMP","CNA_SALDO","N",TamSX3("CNA_SALDO")[1],TamSX3("CNA_SALDO")[2])
		
		aTotCont[nX,7] := A410Arred(CNATMP->CNA_SALDO,"CNA_SALDO")
		aTotCont[nX,8] := A410Arred(CNATMP->CNA_VLTOT,"CNA_VLTOT")
		
		nPosPlan := aScan(aAditPlan,{|x| x[1] = CNATMP->CNA_NUMERO})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma valores aditivados das planilhas        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nPosPlan > 0
			aTotCont[nX,7] += A410Arred(aAditPlan[nPosPlan,2],"CNA_SALDO")
			aTotCont[nX,8] += A410Arred(aAditPlan[nPosPlan,2],"CNA_VLTOT")
		EndIf
		
		dbSelectArea("CN9")
		dbSetOrder(1)
		
		If dbSeek(xFilial("CN9")+cContra+cRevisa)
			aTotCont[nX,9] := CN9->CN9_SALDO

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Soma valores aditivados das planilhas        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	aTotCont[nX,9] += A410Arred(nTotAdit,"CN9_SALDO")
		EndIf
		
		If lFisico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega e altera os cronogramas fisicos do contrato³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      CN140AltFis(@aParcelas,aColsParc,aHeadParc,aFscVl,cContra,cRevisa,aCron[nx],aTotCont[nx],CNATMP->CNA_NUMERO,nPosPlan,aHeaderIT,aHeader,aAditQtd,aItens,lDist)
	 	EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do aTotCont                          ³
		//³aTotCont[x][1] - Montante do Cronograma        ³
		//³aTotCont[x][2] - Saldo do cronograma           ³
		//³aTotCont[x][3] - Saldo das parcelas medidas    ³
		//³aTotCont[x][4] - Montante das parcelas medidas ³
		//³aTotCont[x][5] - Total de parcelas nao medidas ³
		//³aTotCont[x][6] - Primeira parcela nao medidas  ³
		//³aTotCont[x][7] - Saldo da Planilha             ³
		//³aTotCont[x][8] - Total da Planilha             ³
		//³aTotCont[x][9] - Saldo do Contrato             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera parcelas de todos os cronogramas selecionados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		If lFisico
			aItVl := aFscVl[nX]
		EndIf

		If nPosPlan > 0
			aItmAdt:= aAditPlan[nx]
		EndIf

		CN140AltPar(@aParcelas[nx],nParcel,oTpCron,aTotCont[nX],Posicione("CN9",1,xFilial("CN9")+cContra+cRevisa,"CN9_CONDPG"),lArrasto,lDist,aCron[nx],cCodTR,aHeadParc,If(lFisico,aColsParc[nx],NIL),aHeader,nTotAdit,aItVl,aItmAdt)
        	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa ponto de entrada para customização das parcelas do cronograma ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CN140PAC")
			aRetPac := ExecBlock("CN140PAC",.F.,.F.,{aTotCont[nX],aParcelas[nX],aHeader,aColsParc,aHeadParc,lArrasto,lDist,aFscVL,nParcel})
			If ValType(aRetPac)=="A"
				If Len(aRetPac)>=1 .And. ValType(aRetPac[1]) == "A"
					aTotCont[nX] := aRetPac[1]
				Endif
				If Len(aRetPac)>=2 .And. ValType(aRetPac[2]) == "A"
					aParcelas[nX] := aRetPac[2]
				Endif
				If Len(aRetPac)>=3 .And. ValType(aRetPac[3]) == "A"
					aHeader := aRetPac[3]
				Endif
				If Len(aRetPac)>=4 .And. ValType(aRetPac[4]) == "A"
					aColsParc := aRetPac[4]
				Endif
				If Len(aRetPac)>=5 .And. ValType(aRetPac[5]) == "A"
					aHeadParc := aRetPac[5]
				Endif
				If Len(aRetPac)>=6 .And. ValType(aRetPac[6]) == "L"
					lArrasto := aRetPac[6]
				Endif  
				If Len(aRetPac)>=7 .And. ValType(aRetPac[7]) == "L"
					lDist := aRetPac[7]
				Endif  		
				If Len(aRetPac)>=8 .And. ValType(aRetPac[8]) == "A"
					aFscVL := aRetPac[8]
				Endif				
				If Len(aRetPac)>=9 .And. ValType(aRetPac[9]) == "N"
					nParcel := aRetPac[9]
				Endif				
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica ultima data do cronograma para alteracao do³
		//³ contrato                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If (nPosDtF := aScan(aHeader,{|x| AllTrim(x[2]) == "CNF_PRUMED"})) > 0 .And. aParcelas[nx,len(aParcelas[nx]),nPosDtF] > dMaxDate
			dMaxDate := aParcelas[nx,len(aParcelas[nx]),nPosDtF]
		EndIf
		
		CNATMP->(dbCloseArea())
	Next
	dFCronog :=	dMaxDate
	
	//Verifica se o primeiro vencimento eh anterior a data de inicio do contrato
	If Len(aParcelas) > 0 .And. !Empty(aParcelas[1,1,7]) .And. aParcelas[1,1,7] < CN9->CN9_DTINIC
		dMaxDate += CN9->CN9_DTINIC - aParcelas[1,1,7]
	Endif
	
	nVgAdit := CN140Dif(CN9->CN9_DTFIM,dMaxDate,CN9->CN9_UNVIGE)
	
	nVgAdit := CN9->CN9_VIGE+nVgAdit
	
	dFContra := CN100DtFim(CN9->CN9_UNVIGE,CN9->CN9_DTINIC,nVgAdit)
	
	//Carrega primeiro cronograma
	If oGetDados == NIL 
		If !lFisico
			oGetDados:= MSNewGetDados():New(043,005,118,285,GD_UPDATE,,,,,,len(aParcelas[1]),,,,oWizard:oMPanel[11],aHeader,aParcelas[1])
		Else
			oGetDados:= MSNewGetDados():New(043,005,118,285,GD_UPDATE,,,,{"CNF_DTVENC","CNF_PRUMED"},,len(aParcelas[1]),,,,oWizard:oMPanel[11],aHeader,aParcelas[1])		
		EndIf
	Else
		oGetDados:aCols := aParcelas[1]
	EndIf
	
	If lFisico
		aItVl := aFscVl[1]
		oGetDados:oBrowse:bLDblClick := {|| If(oGetDados:oBrowse:COLPOS==3,(CN140Fisico(4,aParcelas[1],oGetDados:nAt,aColsParc[1],aHeadParc,aFscVl[1],cCodTR),oGetDados:aCols:=aParcelas[1],CN110AtuVal(),oGetDados:oBrowse:Refresh(),aFscVl[1] := aItVl),oGetDados:EDITCELL()) }
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Altera objetos visuais do cronograma                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oTotPlan:cTitle   := Transform(aTotCont[1,8],PesqPict("CNA","CNA_VLTOT"))
	oTotCronog:cTitle := Transform(aTotCont[1,1],PesqPict("CNA","CNA_VLTOT"))
	oSaldDist:cTitle  := Transform(aTotCont[1,8]-aTotCont[1,1],PesqPict("CNA","CNA_VLTOT"))
	oSaldCont:cTitle  := Transform(aTotCont[1,9],PesqPict("CN9","CN9_SALDO"))
	oSaldPlan:cTitle  := Transform(aTotCont[1,7],PesqPict("CNA","CNA_SALDO"))
	
	//Atualiza variaveis privates usadas pela validacao do CNTA110
	nTotCronog := aTotCont[1,1]
	nTotPlan   := aTotCont[1,8]
	
	//Carrega variavel de controle para troca de cronograma
	cCronO := aCron[1]
	
	nPosVPrv := aScan(aHeader,{|x| AllTrim(x[2]) == "CNF_VLPREV"})
	nPosVRea := aScan(aHeader,{|x| AllTrim(x[2]) == "CNF_VLREAL"})
	If lRet .And. ValType(aParAnt) == "A" .And. ValType(aParVlR) == "A"
		//-- Alimenta arrays para utilizacao na redistribuicao
		For nX := 1 To Len(aParcelas)
			If aScan(aParAnt,{|x| x[1] == aCron[nX]}) == 0
				aAdd(aParAnt,{aCron[nX],{}})
			EndIf
			If aScan(aParVlR,{|x| x[1] == aCron[nX]}) == 0
				aAdd(aParVlR,{aCron[nX],{}})
			EndIf
			For nY := 1 To Len(aParcelas[nX])
				If !Empty(aParcelas[nX,nY,nPosVPrv]) .And. aScan(aParAnt[nX,2],{|x| x[1] == nY}) == 0
					aAdd(aParAnt[nX,2],{nY,aParcelas[nX,nY,nPosVPrv]})
					If !Empty(aParcelas[nX,nY,nPosVRea]) .And. aScan(aParVlR[nX,2],{|x| x[1] == nY}) == 0
						aAdd(aParVlR[nX,2],{nY,aParcelas[nX,nY,nPosVPrv]})
					EndIf
				Else
					Exit
				EndIf
			Next nY
		Next nX
	EndIf
EndIf


Return lRet      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140AltPar³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Revisoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140AltPar(aExp01,nExp02,oExp03,aExp04,cExp05,lExp06,      ³±±
±±³          ³             lExp07,cExp08,cExp09,aExp10,aExp11)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Parcelas do cronograma                             ³±±
±±³          ³ nExp02 - Total de parcelas para acrescer/decrescer          ³±±
±±³          ³ oExp03 - Acrescer/Decrescer parcelas                        ³±±
±±³          ³ aExp04 - Array com os totalizadores dos cronogramas         ³±±
±±³          ³ cExp05 - Condicao de pagamento                              ³±±
±±³          ³ lExp06 - Realiza arrasto                                    ³±±
±±³          ³ lExp07 - Realiza distribuicao                               ³±±
±±³          ³ cExp08 - Numero do cronograma                               ³±±
±±³          ³ cExp09 - Codigo do tipo de revisao                          ³±±
±±³          ³ aExp10 - Cabecalho das parcelas fisicas do cronograma       ³±±
±±³          ³ aExp11 - Parcelas fisicas dos cronogramas                   ³±±
±±³          ³ aExp12 - Campos do alias CNF                                ³±±
±±³          ³ aExp13 - Valor Total Aditivado                              ³±±
±±³          ³ aExp14 - Estrutura dos cronogramas fisicos                  ³±±
±±³          ³ aExp15 - Array com os valores aditivados das planilhas      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140AltPar(aParcelas,nParc,oTpCron,aTotCont,cCond,lArrasto,lDist,cCron,cCodTR,aHeadParc,aColsParc,aHeaderCNF,nTotAdit,aFscVl,aAditPlan)

Local lRet     := .T.
Local lAcres   := .T.

Local aCond    := {}

Local dPrevista:= dDatabase
Local dComp    := dDatabase

Local cMod     := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_MODO")

Local nX
Local nY
Local nZ
Local nParcQt  := nParc
Local nAvanco  := 0
Local nMes     := 0
Local nAno     := 0
Local nParcAlt := 0
Local nParcDis := 0
Local nPosDtf  := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_PRUMED"})
Local nPosParc := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_PARCEL"})
Local nPosPrev := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_VLPREV"})
Local nPosReal := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_VLREAL"})
Local nPosSald := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_SALDO"})
Local nPosDtRe := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_DTREAL"})       
Local nPosComp := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_COMPET"})     
Local nNovParc := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do aTotCont                          ³
//³aTotCont[1] - Montante do Cronograma           ³
//³aTotCont[2] - Saldo do cronograma              ³
//³aTotCont[3] - Saldo das parcelas medidas       ³
//³aTotCont[4] - Montante das parcelas medidas    ³
//³aTotCont[5] - Total de parcelas nao medidas    ³
//³aTotCont[6] - Primeira parcela nao medidas     ³
//³aTotCont[7] - Saldo da Planilha                ³
//³aTotCont[8] - Total da Planilha                ³
//³aTotCont[9] - Saldo do Contrato                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cParnMed  := aTotCont[6]
Local cParce    := strzero(0,TamSx3("CNF_PARCEL")[1])//Controla a Sequencia das parcelas

Local nTotnMed  := aTotCont[5]
Local nSaldoCro := aTotCont[2]
Local nTotMed   := aTotCont[4]
Local nParnMed  := aTotCont[5]     
Local nSaldoMed := aTotCont[3]     
Local nPosQtd   := 0
Local nPosSld   := 0
Local nPosRlz   := 0
Local nQtdDist  := 0
Local nDiaPar	:= 30
Local nPosDPar  := 0
Local nSldDist  := 0
Local nTotParc  := 0     
Local nAcumParc := 0
 

Local aArtFsc   := {}
Local aArtDist  := {}
Local aArtAdt   := {} 
Local aQtdMed   := {}

Local lAjFim	:= .F.
Local lAjFev	:= .F.
Local lAjFimC	:= .F.
Local lAjFevC	:= .F.

DEFAULT nTotAdit := 0
DEFAULT aAditPlan:= {}

If lFisico
	nPosQtd := aScan(aHeadParc,{|x| x[2]=="CNS_PRVQTD"})
	nPosSld := aScan(aHeadParc,{|x| x[2]=="CNS_SLDQTD"})
	nPosRlz := aScan(aHeadParc,{|x| x[2]=="CNS_RLZQTD"})
	nPosItO := aScan(aHeadParc,{|x| x[2]=="CNS_ITOR"})
	nPosTQt := aScan(aHeadParc,{|x| x[2]=="CNS_TOTQTD"})  
EndIf

//Verifica se existe a periodicidade entre as parcelas
If (CNF->(FieldPos("CNF_PERIOD")) > 0)
	nPosDPar := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_DIAPAR"})
	nDiaPar  := aParcelas[1,nPosDPar]
EndIf

//Verifica modo de alteracao de parcelas
If cMod == "1"
	lAcres := .T.
ElseIf cMod == "2"
   lAcres := .F.
Else
	lAcres := (oTpCron:nAt == 1)
EndIf

If lUltimoDia // Verifica se utiliza ultimo dia do mes
	lAjFim := .T.
	lAjFev := .T.
	lAjFimC:= .T.
	lAjFevC:= .T.
Endif
	
if lAcres //Acrescenta Parcelas
	dPrevista := aParcelas[len(aParcelas),nPosDtf]//Seleciona ultima data   
	dComp	  := aParcelas[len(aParcelas),nPosComp]//Seleciona ultima competencia
	dComp	  := CTOD(Str(Day(dPrevista))+"/"+dComp)   
	nDiaIni   := Day(aParcelas[1,nPosDtf]) //Seleciona o dia da primeira parcela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica primeira parcela nao medida quando nao      ³
	//³houver no cronograma atual                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cParnMed)
		cParnMed := strzero(val(aParcelas[len(aParcelas),nPosParc])+1,3) 
	EndIf
	cParce := Soma1(aParcelas[len(aParcelas),nPosParc])
	for nx:=1 to nParcQt
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula data da proxima parcela                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nMes     :=Month(dPrevista)
		nAno     :=Year(dPrevista)
		If nDiaPar == 30 
			nAvanco  := CalcAvanco(dPrevista,lAjFim,lAjFev,nDiaIni)
		Else
			nAvanco := nDiaPar
		EndIf

		dPrevista += nAvanco						
		If nDiaPar == 30
			nAvanco  :=CalcAvanco(dComp,lAjFimC,lAjFevC,nDiaIni)
		Else
			nAvanco := nDiaPar
		EndIf
		dComp    += nAvanco
		
		aCond := Condicao(0,cCond,,dPrevista)//Calcula data de acordo com a condicao
		aAdd(aParcelas,Array(len(aHeaderCNF)+1))

		For nY:=1 to len(aHeaderCNF)
			Do Case
				Case AllTrim(aHeaderCNF[nY,2]) == "CNF_PARCEL"
					aParcelas[len(aParcelas),nY] := cParce
				Case AllTrim(aHeaderCNF[nY,2]) == "CNF_COMPET"
					aParcelas[len(aParcelas),nY] := strzero(Month(dComp),2)+"/"+str(Year(dComp),4)
				Case AllTrim(aHeaderCNF[nY,2]) == "CNF_DTVENC"
					aParcelas[len(aParcelas),nY] := 	If(len(aCond)>0,aCond[1][1],dPrevista)			
				Case AllTrim(aHeaderCNF[nY,2]) == "CNF_PRUMED"
					aParcelas[len(aParcelas),nY] := dPrevista
				OtherWise
					aParcelas[len(aParcelas),nY] := CriaVar(aHeaderCNF[nY,2])
			EndCase
		Next
		aParcelas[len(aParcelas),len(aHeaderCNF)+1] := .F.

		cParce := Soma1(cParce)
		If lFisico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Replica as parcelas fisicas do cronograma            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aColsParc,aClone(aColsParc[len(aColsPArc)]))
			aEval(aColsParc[len(aColsPArc)],{|x| (x[nPosQtd]:=0,x[nPosRlz]:=0,x[nPosSld]:=0)})
		EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona parcelas nao medidas                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotnMed += nParcQt
Else // Decrementa
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem parcelas nao medidas a serem     ³
	//³reduzidas                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nParcQt > nTotnMed-1
		lRet := .F.
		Help("CNTA140",1,"CNTA140_13")//"O número de redução de parcelas não pode ser maior que o número de parcelas não medidas"
	EndIf
	if lRet
		for nx:=1 to nParcQt
			nY := len(aParcelas)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica parcela que sera excluida desconsiderando   ³
			//³as parcelas ja medidas                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			while !Empty(aParcelas[nY,nPosDtRe]) .And. nY > 0
				aParcelas[nY,nPosParc] := strzero(val(aParcelas[nY,nPosParc])-1,nPosPrev)
				nY--
			EndDo
			nParcAlt := nY
			nY--
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica parcela que recebera os valores da parcela  ³
			//³excluida desconsiderando as parcelas ja medidas      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			while !Empty(aParcelas[nY,nPosDtRe]) .And. nY > 0
				nY--
			EndDo
			nParcDis := nY
			aParcelas[nParcDis,nPosPrev]+=aParcelas[nParcAlt,nPosPrev]
			aParcelas[nParcDis,nPosReal]+=aParcelas[nParcAlt,nPosReal]
			aParcelas[nParcDis,nPosSald]+=aParcelas[nParcAlt,nPosSald]
			If lFisico
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Troca as quantidades do cronograma fisico entre as   ³
				//³parcelas fisicas                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nZ:=1 to len(aColsParc[nParcAlt])
					aColsParc[nParcDis,nZ,nPosQtd] += aColsParc[nParcAlt,nZ,nPosQtd]
					aColsParc[nParcDis,nZ,nPosRlz] += aColsParc[nParcAlt,nZ,nPosRlz]
					aColsParc[nParcDis,nZ,nPosSld] += aColsParc[nParcAlt,nZ,nPosSld]
				Next
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Apaga a parcela fisica                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aDel(aColsParc,nParcAlt)
				aSize(aColsParc,len(aColsParc)-1)
			EndIf			
			aDel(aParcelas,nParcAlt)
			aSize(aParcelas,len(aParcelas)-1)
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Decrementa parcelas nao medidas                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotnMed -= nParcQt
	EndIf
EndIf

If lRet
	if lArrasto
		if nSaldoCro == 0
			Aviso("CNTA140",STR0080+cCron,{"OK"})//"Não existe saldo em aberto para o cronograma"##
			lRet := .F.
		ElseIf nTotnMed == 0
			Aviso("CNTA140",STR0081+cCron,{"OK"})//"Não existem parcelas em aberto para o cronograma"##
			lRet := .F.
		EndIf
		if lRet
			If lFisico
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa arrays para controlar o arrasto e a distribuicao ³
				//³dos cronogramas                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				aArtFsc := Array(len(aColsParc[len(aColsParc)]))							
			EndIf    
			
			if lDist                                                  
				CN140DstCron(@aParcelas,aHeaderCNF,@aColsParc,aHeadParc,lFisico,nTotParc,@aFscVl,@aTotCont,aAditPlan,@aArtFsc,@nTotMed,nParcQt)
			Else                        			
				For nX := 1 to len(aParcelas)
					if !Empty(aParcelas[nx,nPosDtRe])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Retira o saldo restante das parcelas medidas         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aParcelas[nX,nPosPrev] -= aParcelas[nX,nPosSald]
						nTotMed	  	    -= Round(aParcelas[nX,nPosSald],TamSX3("CNF_VLPREV")[2])
						aParcelas[nX,nPosSald] := 0
						if lFisico
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Soma as quantidades de arrasto                             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nY:=1 to len(aColsParc[nX])
								If aArtFsc[nY] == Nil
									aArtFsc[nY] := 0
								EndIf
								aArtFsc[nY] += aColsParc[nX,nY,nPosSld]       
								
								If CNS->(FieldPos("CNS_ITOR"))>0    
									If Empty(aColsParc[nX,nY,nPosItO])	
										aColsParc[nX,nY,nPosQtd] -= aColsParc[nX,nY,nPosSld]
										aColsParc[nX,nY,nPosSld] := 0
									EndIf                            
								Else
									aColsParc[nX,nY,nPosQtd] -= aColsParc[nX,nY,nPosSld]
									aColsParc[nX,nY,nPosSld] := 0															
								EndIf 
								
							Next
						EndIf
					ElseIf aParcelas[nx,nPosParc] == cParnMed
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Incrementa o valor nas parcelas nao medidas    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
						aParcelas[nx,nPosSald] += nSaldoMed
						aParcelas[nx,nPosPrev] += nSaldoMed
						nTotMed	              += Round(aParcelas[nX,nPosPrev],TamSX3("CNF_VLPREV")[2])
						if lFisico     
							//Verifica se possui saldo aditivado e calcula no cronograma financeiro
							If !Empty(aAditPlan)	
								aParcelas[nx,nPosSald] += aAditPlan[2]
								aParcelas[nx,nPosPrev] += aAditPlan[2]  
								aTotCont[1]			   += aAditPlan[2] 
								nTotParc               :=(aAditPlan[2]/len(aColsParc[nX])) 
							EndIf      
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Soma as quantidades de arrasto na primeira parcela nao     ³
							//³ medida                                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nY:=1 to len(aColsParc[nX])
								If aArtFsc[nY] == Nil
									aArtFsc[nY] := 0
								EndIf
								
								If aArtFsc[nY] != NIL
									aColsParc[nX,nY,nPosSld] += aArtFsc[nY]
									aColsParc[nX,nY,nPosQtd] += aArtFsc[nY]
									aArtFsc[nY] := 0
								EndIf    
								
								//Verifica se possui saldo aditivado e calcula no cronograma físico
								If aFscVl[nY,3]  > 0  
									aColsParc[nX,nY,nPosSld] += aFscVl[nY,3] 
									aColsParc[nX,nY,nPosQtd] += aFscVl[nY,3] 					
								EndIf
							Next    
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Zera os valores a distribuir ja incluido nas parcelas fisicas³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lFisico
								For nY:= 1 To len(aFscVl)       
									aFscVl[nY,3] := 0
								Next
							EndIf
						EndIf
					Else
						nTotMed += Round(aParcelas[nX,nPosPrev],TamSX3("CNF_VLPREV")[2])
					EndIf
				Next
			EndIf
			
			 
			If lDist 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se houve diferenca entre o valor do         ³
				//³cronograma e o valor arrastado                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aTotCont[1] > nTotMed
					aParcelas[len(aParcelas),nPosPrev] += (aTotCont[1] - nTotMed)
					aParcelas[len(aParcelas),nPosSald] += (aTotCont[1] - nTotMed)
				Elseif aTotCont[1] < nTotMed
					aParcelas[len(aParcelas),nPosPrev] -= (nTotMed - aTotCont[1])
					aParcelas[len(aParcelas),nPosSald] -= (nTotMed - aTotCont[1])
				EndIf   
						
			
				If lFisico							
					If aTotCont[1] <> aTotCont[8]
						aParcelas[len(aParcelas),nPosPrev] += (aTotCont[8]-aTotCont[1])
						aParcelas[len(aParcelas),nPosSald] += (aTotCont[8]-aTotCont[1])   		
					
						For nY:=1 to len(aColsParc[len(aParcelas)])
							nAcumParc += Round((aColsParc[len(aParcelas),ny,nPosQtd]*aFscVl[ny,1])-(((aColsParc[len(aParcelas),nY,nPosQtd]*aFscVl[ny,1])*aFscVl[ny,7])/100),TamSX3("CNS_PRVQTD")[2])
						Next nY
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   			//³ Soma a diferenca na ultima parcela³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
						If Round(aParcelas[len(aParcelas),nPosPrev],TamSX3("CNF_VLPREV")[2]) <> Round(nAcumParc,TamSX3("CNF_VLPREV")[2])
							nAcumParc:= Round(aParcelas[len(aParcelas),nPosPrev] - nAcumParc,TamSX3("CNF_VLPREV")[2])
				 			aColsParc[len(aParcelas),len(aColsParc[len(aParcelas)]),nPosSld] := Round(((aColsParc[len(aParcelas),len(aColsParc[len(aParcelas)]),nPosSld] * aFscVl[len(aColsParc[len(aParcelas)]),1] )+nAcumParc)/aFscVl[len(aColsParc[len(aParcelas)]),1] ,TamSX3("CNS_PRVQTD")[2])
							aColsParc[len(aParcelas),len(aColsParc[len(aParcelas)]),nPosQtd] := Round(((aColsParc[len(aParcelas),len(aColsParc[len(aParcelas)]),nPosQtd] * aFscVl[len(aColsParc[len(aParcelas)]),1] )+nAcumParc)/aFscVl[len(aColsParc[len(aParcelas)]),1] ,TamSX3("CNS_PRVQTD")[2])
						EndIf  					          
					EndIf
					aTotCont[1] += (aTotCont[8]-aTotCont[1])    
				Else       
				   If !Empty(aAditPlan)	
						If aTotCont[1] <> (aTotCont[8]-aAditPlan[2])	
							aParcelas[len(aParcelas),nPosPrev] += ((aTotCont[8]-aAditPlan[2])-aTotCont[1])
							aParcelas[len(aParcelas),nPosSald] += ((aTotCont[8]-aAditPlan[2])-aTotCont[1])    
							aTotCont[1] += ((aTotCont[8]-aAditPlan[2])-aTotCont[1]) 
						EndIf				
					EndIf
				EndIf   
			EndIf
			
			If lFisico
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma o restante das quantidades do arredondamento          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nY:=1 to len(aArtFsc)
					If aArtFsc[nY] != 0
						aColsParc[len(aParcelas),nY,nPosSld] += aArtFsc[nY]
						aColsParc[len(aParcelas),nY,nPosQtd] += aArtFsc[nY]
					EndIf
				Next
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VlP9 ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida painel numero 9 - Itens de Planilhas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VlP9(cExp01,cExp02,cExp03,cExp04,aExp02,aExp03,aExp04,³±±
±±³Sintaxe   ³           aExp05,aExp06,aExp07,aExp08,aExp09)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                ³±±
±±³          ³ cExp02 - Codigo da revisao original                        ³±±
±±³          ³ cExp03 - Codigo da nova revisao                            ³±±
±±³          ³ cExp04 - Codigo do tipo de revisao                         ³±±
±±³          ³ aExp05 - Array com os valores aditivados das planilhas     ³±±
±±³          ³ aExp06 - Array com as planilhas selecionadas na revisao    ³±±
±±³          ³ aExp07 - Array com os campos dos itens de planilha         ³±±
±±³          ³ aExp08 - Array com os itens atualizados das planilhas      ³±±
±±³          ³ aExp09 - Quantidades aditividas nas planilhas              ³±±
±±³          ³ dExp10 - Data de termino do contrato - referencia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VlP9(cContra,cRevisa,cNRevisa,cCodTR,aAditPlan,aPlan,aHeaderIT,aItens,aAditQtd,dFContra)
Local lRet     	 := .T.
Local lDelItm    := .F.

Local cTpEspec 	 := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_ESPEC")
Local cEspecie   := ""
Local cQuery     := ""
Local cAlias     := ""
Local cItmDst    := ""

Local nX := 0
Local nY := 0
Local nPosPrcor  := 0	//Preco unitario original
Local nPosVlUnit := 0	//Valor unitario
Local nPosODesc  := 0	//Desconto original
Local nPosDesc   := 0	//Desconto atual   
Local nPosVDesc  := 0   //Valor Desconto
Local nPosQtd    := 0	//Quantidade
Local nPosQAcr   := 0	//Quantidade acrescida
Local nPosQDcr   := 0	//Quantidade decrescida
Local nPosItm    := 0	//Item da planilha
Local nAdit      := 0
Local nTot       := 0
Local nVDesc     := 0
Local nAditAnt   := 0	//Valor aditivo em caso de alteracao de revisao
Local nQtd       := 0
Local nPos       
Local nItmPla    := 0                                               
Local nPreco     := 0
Local nTotal     := 0
Local nPosObr		:= 0                                          

Local aStrucCNB := CNB->(dbStruct())
Local nPosIt     := aScan(aHeaderIt,{|x| x[2] == "CNB_ITEM"})  //Item
Local aItCopia := {}

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspecie := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspecie := "2"
Else
	cEspecie := "1"
Endif

aItCopia := aClone(aItens)

// Valida obrigatoriedade de preenchimento dos campos
For nX := 1 To Len(aHeaderOb)
	If aHeaderOb[nX,3] == 'S'
		nPosObr := Ascan(aHeaderIt,{|x| x[2] == aHeaderOb[nX,2] })
		If nPosObr > 0
			For nY := 1 To Len(aItens[1])
				If Empty(aItens[1,nY,nPosObr])
					Help("",1,"GETOBG",,aHeaderIt[nPosObr,1],2)
					Return .F.
				Endif			
			Next nY
		Endif
		nPosObr := 0
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Adiciona itens com saldo zero para copiá-los |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nItmPla := 1 to len(aPlan) 
	cQuery := "SELECT * FROM " +RetSQLName("CNB")+" CNB WHERE CNB_FILIAL = '"+xFilial("CNB")+"' AND "
	cQuery += "CNB_CONTRA = '"+cContra         +"' AND CNB_REVISA = '"+cRevisa+"' AND "     
	cQuery += "CNB_NUMERO = '"+aPlan[nItmPla,1]+"' AND "
	cQuery += "D_E_L_E_T_ <> '*' ORDER BY CNB_NUMERO,CNB_ITEM"
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNBZERO", .F., .F. ) 
		    
	For nX :=1 To Len(aStrucCNB)
	     If CNBZERO->(FieldPos(aStrucCNB[nx,1])) > 0 .And. aStrucCNB[nx,2] <> "C"
	       TCSetField("CNBZERO",aStrucCNB[nx,1],aStrucCNB[nx,2],aStrucCNB[nx,3],aStrucCNB[nx,4])
	     Endif
	Next nX
	
	CNBZERO->(dbGoTop())	
	While !CNBZERO->(Eof())    
			
			If CNB->(FieldPos("CNB_ITMDST")) > 0 
				cItmDst := CNBZERO->CNB_ITMDST
			EndIf  
	
			If !(((CNBZERO->CNB_SLDMED > 0 .AND. CNBZERO->CNB_VLTOTR>0) .OR. (CNBZERO->CNB_SLDMED > 0 .And. CNBZERO->CNB_VLTOTR==0)).AND. (CNBZERO->CNB_QTDORI==CNBZERO->CNB_QUANT).OR. (cItmDst=='') )  
			nItemCNB := aScan(aItCopia[nItmPla],{|x| x[1] == CNBZERO->CNB_ITEM})
			If CNBZERO->CNB_SLDMED == 0 .And.(nItemCNB== 0)//Para evitar diferenças do banco
				aAdd(aItCopia[nItmPla],Array(Len(aHeaderIt)+1))
			 	For nx := 1 To Len(aHeaderIt)
		        	If CNB->(FieldPos(AllTrim(aHeaderIt[nx,2]))) > 0 
			        	If Type("CNBZERO->"+AllTrim(aHeaderIt[nx,2])) <> 'U'
			          		aTail(aItCopia[nItmPla])[nx] := &("CNBZERO->"+AllTrim(aHeaderIt[nx,2]))
			         	EndIf
			        ElseIf aHeaderIt[nx,2] == DEF_NDESC .Or. aHeaderIt[nx,2] == DEF_NVLDESC
		            	aTail(aItCopia[nItmPla])[nx] := 0 
			      	ElseIf aHeaderIt[nx,2] == DEF_DESCNA
		        		aTail(aItCopia[nItmPla])[nx] := CNBZERO->CNB_DESC
		          	ElseIf aHeaderIt[nx,2] == DEF_VLDECNA
		         		aTail(aItCopia[nItmPla])[nx] := CNBZERO->CNB_VLDESC
			  		EndIf
				 Next nx
				 aTail(aItCopia[nItmPla])[Len(aHeaderIt)] := CNBZERO->R_E_C_N_O_
		    	 aTail(aItCopia[nItmPla])[Len(aHeaderIt)-1] := "CNB"
		         aTail(aItCopia[nItmPla])[Len(aHeaderIt)] := .F.
			        
				 If !Empty(aItCopia[nItmPla])
			   	      aSort(aItCopia[nItmPla],,,{|x,y| x[nPosIt] < y[nPosIt]})
				 EndIf
					    
	     	EndIf
		EndIf
	    CNBZERO->(dbSkip())
	End
	CNBZERO->(dbCloseArea())         
Next

aItens := aClone(aItCopia)

dFContra := CN100DtFim(CN9->CN9_UNVIGE,CN9->CN9_DTINIC,nVgAdit)

aAditPlan := Array(len(aPlan))
If lFisico
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa array de controle das quantidade aditivadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAditQtd  := Array(len(aPlan))
EndIf

If (cTpEspec != "4" .And. cTpRev <> "1") .OR. lMedeve
	If !SuperGetMv("MV_CNINTFS",.F.,.F.) .Or. cEspecie <> "2"  
		If cTpRev $ "9|A"
			oWizard:NPanel := 13
		Else
			oWizard:NPanel := 15
		EndIf
	EndIf	
Else	//ADIT. QUANT/PRAZO
	nPosPrcor  := aScan(aHeaderIT,{|x| x[2] == "CNB_PRCORI"})
	nPosVlUnit := aScan(aHeaderIT,{|x| x[2] == "CNB_VLUNIT"})
	nPosQtd    := aScan(aHeaderIT,{|x| x[2] == "CNB_QUANT"})
	nPosQAcr   := aScan(aHeaderIT,{|x| x[2] == "CNB_QTRDAC"})
	nPosQDcr   := aScan(aHeaderIT,{|x| x[2] == "CNB_QTRDRZ"})
	nPosItm    := aScan(aHeaderIT,{|x| x[2] == "CNB_ITEM"})
	nPosODesc  := aScan(aHeaderIT,{|x| x[2] == DEF_DESCNA})
	nPosDesc   := aScan(aHeaderIT,{|x| x[2] == DEF_NDESC})
	nPosVDesc  := aScan(aHeaderIT,{|x| x[2] == DEF_NVLDESC})

	For nX:=1 to len(aPlan)
		nAdit := 0
		If lFisico
			aAditQtd[nX] := {}
		EndIf
		For nY:=1 to len(aItens[nX])
			If !aItens[nX,nY,len(aHeaderIT)+1]//Valida itens deletados
				nQtd := 0
				If aItens[nX,nY,nPosPrcor] == 0//Item incluso
					nTot   := Round(aItens[nX,nY,nPosQtd]*aItens[nX,nY,nPosVlUnit],TamSX3("CNB_VLUNIT")[2])
					
					//Calcula valor de desconto para o item
				    If cEspecie = '1'
						nVDesc := A410Arred((nTot*aItens[nX,nY,nPosDesc])/100,"CNB_VLDESC")					
					Else
						nPreco := A410Arred(aItens[nX,nY,nPosVlUnit] * (1-(aItens[nX,nY,nPosDesc]/100)),"CNB_VLUNIT")
						nTotal := A410Arred(nPreco* aItens[nX,nY,nPosQAcr],"CNB_VLTOT")

						nVDesc := A410Arred(nTot-nTotal,"CNB_VLDESC")
					EndIf
					
					nAdit  += nTot-nVDesc
					If lFisico
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calcula a quantidade aditivada           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nQtd:=aItens[nX,nY,nPosQtd]
					EndIf
				Else
					If aItens[nX,nY,nPosQAcr] > 0//Item acrescido
						nTot   := Round(aItens[nX,nY,nPosQAcr]*aItens[nX,nY,nPosVlUnit],TamSX3("CNB_VLUNIT")[2])
				
						//Calcula valor de desconto para o item
					    If cEspecie = '1'
							nVDesc := A410Arred((nTot*aItens[nX,nY,nPosDesc])/100,"CNB_VLDESC")					
						Else
							nPreco := A410Arred(aItens[nX,nY,nPosVlUnit] * (1-(aItens[nX,nY,nPosDesc]/100)),"CNB_VLUNIT")
							nTotal := A410Arred(nPreco* aItens[nX,nY,nPosQAcr],"CNB_VLTOT")

							nVDesc := nTot-nTotal
						EndIf
					
						nAdit  += nTot-nVDesc
						If lFisico
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calcula a quantidade aditivada           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nQtd:=aItens[nX,nY,nPosQAcr]
						EndIf
					ElseIf aItens[nX,nY,nPosQDcr] > 0//Item decrescido
						nTot   := aItens[nX,nY,nPosQDcr]*aItens[nX,nY,nPosVlUnit]

					    If cEspecie = '1'
							nVDesc := A410Arred((nTot*aItens[nX,nY,nPosDesc])/100 ,"CNB_VLDESC")					
						Else
							nPreco := A410Arred(aItens[nX,nY,nPosVlUnit] * (1-(aItens[nX,nY,nPosDesc]/100)),"CNB_VLUNIT")
							nTotal := A410Arred(nPreco* aItens[nX,nY,nPosQAcr],"CNB_VLTOT")

							nVDesc := nVDesc-nTotal
						EndIf
					
						nAdit  -= nTot-nVDesc
						If lFisico
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calcula a quantidade aditivada           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nQtd:=aItens[nX,nY,nPosQDcr]*-1
						EndIf
					EndIf
				EndIf
				
				If lFisico
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Preenche a quantidade aditivada          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aAditQtd[nX],nQtd)
				EndIf
			Else
				If lFisico
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Preenche NIL para informar que o item foi³
					//³excluido                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aAditQtd[nX],NIL)
				EndIf
			EndIf
		Next

		If lRevisad .And. (nRevRtp==1)//Alteracao de revisao
			dbSelectArea("CNA")
			dbSetOrder(1)
		
			If lFisico .AND. len(aAditQtd[nx]) > 0
				dbSelectArea("CNS")
				cAlias := GetNextAlias()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seleciona o cronograma fisico para verificar as quantidades ³
				//³aditivadas e as quantidades originais                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := "SELECT CNS.CNS_ITEM, SUM(CNS.CNS_PRVQTD) as CNS_PRVQTD "
				cQuery += "  FROM "+RetSQLName("CNS")+" CNS "
				cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
				cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
				cQuery += "   AND CNS.CNS_REVISA = '"+cNRevisa+"'"
				cQuery += "   AND CNS.CNS_PLANI  = '"+aPlan[nX,1]+"'"
				cQuery += "   AND D_E_L_E_T_     = ' ' "
				cQuery += " GROUP BY CNS.CNS_ITEM ORDER BY CNS.CNS_ITEM"
				
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlias, .F., .F. )
				
				TCSetField(cAlias,"CNS_PRVQTD","N",TamSX3("CNS_PRVQTD")[1],TamSX3("CNS_PRVQTD")[2])
				
				While !(cAlias)->(Eof())
					If (nPos := aScan(aItens[nx],{|x| x[nPosItm] == (cAlias)->CNS_ITEM})) > 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calcula a quantidade aditiva da com base na revisao original³
						//³e a revisao atual                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aAditQtd[nx,nPos] := aItens[nx,nPos,nPosQtd] - (cAlias)->CNS_PRVQTD
					EndIf
					(cAlias)->(dbSkip())
				EndDo
				
				(cAlias)->(dbCloseArea())
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche array com as informacoes de aditivo das     ³
		//³planilhas, que sera usado durante a execucao dos     ³
		//³cronogramas                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		aAditPlan[nX] := {aPlan[nX,1],Round( nAdit, GetSx3Cache("CNB_VLTOT","X3_DECIMAL") ) }
	Next
EndIf

If SuperGetMv("MV_CNINTFS",.F.,.F.) .And. cEspecie == "2" .And. lRet
	oWizard:NPanel := 13
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140Cron ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a chamada para alteracao de cronogramas do contrato³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140Cron()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Alias selecionado                                 ³±±
±±³          ³ nExp02 - Registro Atual                                    ³±±
±±³          ³ nExp03 - Opcao Atual                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140Cron(cAlias,nReg,nOpc)
Local lMedeve  := .F.
Local lRet     :=.F.

Local aArea    := GetArea()
Local aRadio   := {}

Local oRadio   := NIL
Local oDlg     := NIL

Local nOpcTp   := 1
Local nRadio   := 1

Local cTipo    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o Tipo de Revisão. De acordo com o tipo     ³
//³não irá permitir que manutenção no cronograma        ³
//|005 = Paralisação                                    |
//|006 = Reinicio                                       |
//|007 = Alteração de Clausula                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CN0")
dbSetOrder(1)
dbSeek(xFilial("CN0")+CN9->CN9_TIPREV)
If !Eof()
    cTipo:=CN0_TIPO
EndIf

If !cTipo$"5!6!7"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Selecionando o tipo de Cronograma                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRadio,STR0108)
	aAdd(aRadio,STR0109)
	DEFINE MSDIALOG oDlg FROM 0,0 TO 80,300 PIXEL TITLE STR0107
	@ 001,003 TO 040,110 LABEL "" OF oDlg PIXEL
	@ 008,008 RADIO oRadio VAR nRadio ITEMS aRadio[1],aRadio[2] SIZE 100,009 ;
	PIXEL OF oDlg 
	DEFINE SBUTTON FROM 003,116 TYPE 1 OF oDlg ENABLE ONSTOP STR0110 ACTION oDlg:End()
	DEFINE SBUTTON FROM 020,116 TYPE 2 OF oDlg ENABLE ONSTOP STR0111 ACTION (oDlg:End(),nOpcTp := 2)
	
	oDlg:bStart:={|| }
	   
	ACTIVATE MSDIALOG oDlg CENTER 
	
	If nOpcTp = 2       // cancelando a operação
	   RestArea(aArea)
	   Return
	Endif   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Revisão Cronograma Contábil, não permite alterar cronograma físico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nRadio=1 .And. cTipo=="8"
		Aviso("CNTA140",STR0124,{"OK"}) //"Tipo de Revisão não permite manutenção do cronograma"
		RestArea(aArea)
  	    Return
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona no crontrato                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CN9")
	dbGoTo(nReg)
	
	if nRadio=1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica medicao eventual                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lMedeve := (Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_MEDEVE") == "1")             
		
		If lMedeve
			Help("CNTA140",1,"CNTA140_14")//"Contratos de medição eventual não possuem cronogramas"
		Else
			dbSelectArea("CNF")
			dbSetOrder(2)
			dbSeek(xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA)
			CN110Manut("CNF",CNF->(Recno()),4,,CN9->CN9_NUMERO,CN9->CN9_REVISA,,,,.T.)//Altera cronogramas
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ajusta datas da planilha   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			CN140AjuDt(CN9->CN9_NUMERO,CN9->CN9_REVISA,NIL,NIL,.F.)
		EndIf
	Elseif nRadio=2
		dbSelectArea("CNV")
		dbSetOrder(1)
		dbSeek(xFilial("CNV")+CN9->CN9_NUMERO+CN9->CN9_REVISA)
		lRet := CN270Manut("CNV",CNV->(Recno()),4,,CN9->CN9_NUMERO,CN9->CN9_REVISA)//Altera cronogramas
	Endif	
Else
	Aviso("CNTA140",STR0124,{"OK"}) //"Tipo de Revisão não permite manutenção do cronograma"
Endif
		
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldDFim³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data de termino do contrato contra data do cronograma ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldDFim(dExp01,cExp02.cExp03,cExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp01 - Data de termino do contrato                         ³±±
±±³          ³ cExp02 - Tipo de Revisao                                     ³±±
±±³          ³ cExp03 - Contrato                                            ³±±
±±³          ³ cExp04 - Revisao                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldDFim(dFContra,cTpRev,cContra,cRevisa)
Local lRet := .T.
Local cMod := Posicione("CN0",1,xFilial("CN0")+cTpRev,"CN0_MODO")
Local dFim := dDataBase
Local dIni := dDataBase
 
dbSelectArea("CN9")
dbSetOrder(1)

If dbSeek(xFilial("CN9")+cContra+cRevisa)
	dFim := CN9->CN9_DTFIM
	dIni := CN9->CN9_DTINIC
EndIf

//valida data de inicio do contrato e data atual
lRet := (dFContra > dIni) .And. (dFContra > dDataBase)
 
//Valida data do cronograma quando nao med. eventual
If !lMedeve
	lRet := (dFContra >= dFCronog)
EndIf

//Valida acrescimo
if lRet .And. cMod == "1"
	lRet := (dFContra >= dFim)
EndIf

//Valida decrescimo
if lRet .And. cMod == "2"
	lRet := (dFContra <= dFim)
EndIf

//Exibe mensagem
If !lRet
	Help("CNTA140",1,"CNTA140_15")//"Data de término inválida"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140DelGet ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida exclusao de itens da getdados dos itens de planilha   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140DelGet()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140DelGet()
Local lRet := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apenas permite exclusao de itens que tenham sido     ³
//³adicionados na revisao, ou seja nao possui preco     ³
//³original                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (oGetDad1:aCols[oGetDad1:nAt][aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_PRCORI"})]==0)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140ChgGet ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina chamada pela getdados para bloquear/liberar os campos ³±±
±±³          ³ dos itens de planilha                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140ChgGet()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140ChgGet(cTipRev,aAlterCNB)
Local aAlter  := {}    
Local cEspCtr := ""

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

If cTipRev == DEF_ADITI
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Durante a inclusao de itens habilita a edicao dos    ³
	//³principais campos, na revisao habilita apenas os     ³
	//³campos relativos ao tipo de revisao                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oGetDad1:aCols[oGetDad1:nAt][aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_PRCORI"})]!=0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Libera apenas campo de quantidade para edicao        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAlter := aClone(aAlterCNB)
		aAdd(aAlter,"CNB_QUANT")  
		aAdd(aAlter,DEF_NDESC) 
		oGetDad1:OBROWSE:aAlter := aAlter
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Libera campos para inclusao de item                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAlter := aClone(aAlterCNB)
		aAdd(aAlter,"CNB_PRODUT")
		aAdd(aAlter,"CNB_DESCRI")		
		aAdd(aAlter,"CNB_QUANT")
		aAdd(aAlter,"CNB_VLUNIT") 
		aAdd(aAlter,"CNB_DESC")
		aAdd(aAlter,"CNB_CONTA")
		aAdd(aAlter,DEF_NDESC) 
		If !Empty(CNB->(FieldPos("CNB_TE"))) 
			If cEspCtr == "1"
				aAdd(aAlter,"CNB_TE")
			EndIf
		EndIf         
				
		If !Empty(CNB->(FieldPos("CNB_TS"))) 
			If cEspCtr == "2"
				aAdd(aAlter,"CNB_TS") 
			EndIf
		EndIf
		oGetDad1:OBROWSE:aAlter := aAlter
	EndIf
	
ElseIf cTipRev ==  DEF_REALI
	aAlter := aClone(aAlterCNB)
	aAdd(aAlter,"CNB_REALI")
	aAdd(aAlter,"CNB_DTREAL")
	oGetDad1:OBROWSE:aAlter := aAlter
	
ElseIf cTipRev ==  DEF_READQ
	aAlter := aClone(aAlterCNB)
	aAdd(aAlter,"CNB_QUANT")
	oGetDad1:OBROWSE:aAlter := aAlter
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldIt  ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida itens das planilhas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldIt()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldIt()
Local lRet    := .T.
Local aCols   := ogetDad1:aCols
Local nA      := oGetDad1:nAt
Local nPosVlt := aScan(aHeaderIt,{|x| x[2] == "CNB_VLTOT"})//Valor total
Local nPosVlu := aScan(aHeaderIt,{|x| x[2] == "CNB_VLUNIT"})//Valor unitário
Local nPosQtd := aScan(aHeaderIt,{|x| x[2] == "CNB_QUANT"})//Quantidade
Local nPosOri := aScan(aHeaderIt,{|x| x[2] == "CNB_PRCORI"})//Preco original
Local nPosPrd := aScan(aHeaderIt,{|x| x[2] == "CNB_PRODUT"})//Produto       
Local nPosTS  := aScan(aHeaderIt,{|x| x[2] == "CNB_TS"})//TS       
Local cEspCtr := ""

If CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA) # xFilial("CN9")+cContra+cRevAtu 
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9")+cContra+cRevAtu))
EndIf
If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

aHeaderIt := oGetDad1:aHeader
If aCols[nA,nPosOri] == 0//Verifica se o item e uma inclusao
	lRet := 	(aCols[na,nPosVlt] > 0) .And. ;		//-- Valida valor total
				(aCols[na,nPosVlu] > 0) .And. ;		//-- Valida valor unitario
				(aCols[na,nPosQtd] > 0) .And. ;		//-- Valida quantidade
				!Empty(aCols[na,nPosPrd])			//-- Valida produto
	
	If lRet .And. cEspCtr == "2" .And. !Empty(CNB->(FieldPos("CNB_TS"))) 
		lRet := !Empty(aCols[na,nPosTS])			//-- Valida TS para contratos de vendas
	EndIf
EndIf
        
If !lRet .And. !aCols[na,Len(aHeaderIt)+1]   
	If cEspCtr == "2"                                                                                               
		Aviso("CNTA140",STR0128,{"OK"})//"Os campos de quantidade, produto, valor unitário, total e TES são obrigatórios!"
	Else
		Aviso("CNTA140",STR0089,{"OK"})//"Os campos de quantidade, produto, valor unitário e total são obrigatórios!"
	EndIf
	oGetDad1:oBrowse:SetFocus()
EndIf                                                                                                   

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140Dif    ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula diferenca de acordo com to tipo de vigencia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140Dif(dExp01,dExp02,cExp03)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp01 - Data de inicio                                      ³±±
±±³          ³ dExp02 - Data de termino                                     ³±±
±±³          ³ cExp03 - Tipo de vigencia       1 - Dias                     ³±±
±±³          ³                                 2 - Meses                    ³±±
±±³          ³                                 3 - Anos                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140Dif(dFim,dFimN,cUnVgc)
Local nDif
Local dAvc

Do Case
	Case cUnVgc=="1"//Dias
		nDif := dFimN-dFim
	Case cUnVgc=="2"//Meses
		nDif := 0
		dAvc := dFim
		while dAvc < dFimN
			nDif++
			dAvc += CalcAvanco(dAvc,.T.) 
		EndDo
	Case cUnVgc=="3"//Anos
		nDif := 0
		If year(dFim) < year(dFimN)
			nDif := year(dFimN)-year(dFim)
		EndIf
	Case cUnVgc=="4"//Indeterminada
		nDif := 0
EndCase

Return nDif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140DtFim  ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida alteracao da data de vigencia do contrato             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140DtFim(dExp01,nExp02,cExp03,cExp04)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp01 - Data de inicio                                      ³±±
±±³          ³ nExp02 - Valor da vigencia                                   ³±±
±±³          ³ cExp03 - Codigo do contrato                                  ³±±
±±³          ³ cExp04 - Codigo da revisao                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140DtFim(dFContra,nVgAdit,cContra,cRevisa,cUnVig)
Local aArea := GetArea()
Local dDtPrv
Local lRet := .T.           

DEFAULT cUnVig := ""

If nVgAdit >= 0              
	dbSelectArea("CN9")
	dbSetOrder(1)	
	dbseek(xFilial("CN9")+cContra+cRevisa)
	
	If Empty(cUnVig) 
		If oUnVig:nat == 1
			cUnVig := "1"
		ElseIf oUnVig:nat == 2
			cUnVig := "2"
		ElseIf oUnVig:nat == 3
			cUnVig := "3"
		Else
			cUnVig := "4"
		EndIf	
	EndIf
	
	dDtPrv := CN100DtFim(cUnVig,CN9->CN9_DTINIC,nVgAdit)
	
	If dDtPrv >= dFCronog .or. lMedeve
		dFContra := dDtPrv
	else
		Aviso("CNTA140",OemToAnsi(STR0120) +DTOC(dFCronog)+ OemToAnsi(STR0121),{"Ok"})
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf
            
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldRel ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida valor do realinhamento de acordo com o modo da revisao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldRel()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldRel()
Local lRet := .T. 

If cModo == "1"//Acrescimo
	lRet := (M->CNB_REALI > 0 .And. M->CNB_REALI >= oGetDad1:aCols[oGetDad1:nAt,aScan(oGetDad1:aHeader,{|x| x[2]=="CNB_VLUNIT"})])
ElseIf cModo == "2"//Decrescimo
	lRet := (M->CNB_REALI > 0 .And. M->CNB_REALI <= oGetDad1:aCols[oGetDad1:nAt,aScan(oGetDad1:aHeader,{|x| x[2]=="CNB_VLUNIT"})])
Else
	lRet := M->CNB_REALI > 0
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldDtr ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida data base de realinhamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldDtR()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldDtR()

Return (M->CNB_DTREAL <= dDataBase)       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140PlanCb ³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Ordena array com as planilhas selecionadas, e retorna apenas  ³±±
±±³          ³a primeira dimensao do array, para ser usado no combo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140PlanCb(aExp01)                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140PlanCb(aPlan)
Local aPlanOrd := Array(len(aPlan))
Local nX := 0

aPlan := aSort(aPlan,,,{|x,y| x[1] < y[1]})

For nX:=1 to len(aPlan)
	aPlanOrd[nX] := aPlan[nX,1]
Next

Return aPlanOrd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140AltFis ³ Autor ³ Marcelo Custodio      ³ Data ³23.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Carrega e altera as informacoes do cronograma fisico de acordo³±±
±±³          ³com as alteracoes das planilhas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140AltFis(aExp01,aExp02,aExp03,aExp04,cExp05,cExp06,cExp07,³±±
±±³          ³             aExp08,cExp09,nExp10,aExp11,aExp12,aExp13,aExp14)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExp01 - Parcelas financeiras dos cronogramas                 ³±±
±±³          ³aExp02 - Parcelas fisicas dos cronogramas                     ³±±
±±³          ³aExp03 - Cabecalho das parcelas fisicas                       ³±±
±±³          ³aExp04 - Controle dos itens das parcelas fisicas              ³±±
±±³          ³cExp05 - Codigo do contrato                                   ³±±
±±³          ³cExp06 - Codigo da revisao                                    ³±±
±±³          ³cExp07 - Codigo do Cronograma                                 ³±±
±±³          ³aExp08 - Totalizadores dos cronogramas e planilhas            ³±±
±±³          ³aExp09 - Codigo da planilha                                   ³±±
±±³          ³aExp10 - Posiciao atual no array de planilhas                 ³±±
±±³          ³aExp11 - Cabecalho dos itens de planilha                      ³±±
±±³          ³aExp12 - Cabecalho das parcelas do cronograma financeiro      ³±±
±±³          ³aExp13 - Quantidades aditivadas ao contrato                   ³±±
±±³          ³aExp14 - Itens das planilhas                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140AltFis(aParcelas,aColsParc,aHeadParc,aFscVl,cContra,cRevisa,cCron,aTotCont,cPlan,nPosPlan,aHeaderIT,aHeader,aAditQtd,aItens,lDist)

Local aParcFsc	:= {}
Local aDelParc 	:= {}

Local nY
Local nZ
Local nVlUnit
Local nDesc
Local nPosCpo   := 0
Local nIncIt  	:= 0
Local nTotIts  	:= 0
Local nDelParc 	:= 0
Local nTotCron 	:= 0
Local nTotDelIt	:= 0
Local nPosItFsc	:= 0
Local nPosCNSIt	:= 0
Local nPosCNSQt	:= 0
Local nPosVlPrv	:= 0
Local nPosVlSld	:= 0
Local nQtdOri   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena estrutura dos itens, usada na inclusao de  ³
//³ itens para preenchimento do cronograma fisico       ³
//³ 1 - Posicao do campo Item no array aHeaderIT        ³
//³ 2 - Posicao do campo Produto no array aHeaderIT     ³
//³ 3 - Posicao do campo Descricao no array aHeaderIT   ³
//³ 4 - Posicao do campo Vl Unitario no array aHeaderIT ³
//³ 5 - Posicao do campo Desconto no array aHeaderIT    ³
//³ 6 - Posicao do campo Quantidade no array aHeaderIT  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aStruIts  := {}

If len(aHeaderIT) > 0
	//Item
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == "CNB_ITEM"}))
	//Produto
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == "CNB_PRODUT"}))
	//Descricao
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == "CNB_DESCRI"}))
	//Valor unitario
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == "CNB_VLUNIT"}))
	//Desconto
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == DEF_NDESC}))
	//Quantidade
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == "CNB_QUANT"}))
	//Quantidade Original
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == "CNB_QTDORI"}))   
	//Valor Desconto
	aAdd(aStruIts,aScan(aHeaderIT,{|x| AllTrim(x[2]) == DEF_NVLDESC}))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicoes dos itens do cronograma fisico             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosCNSIt := aScan(aHeadParc,{|x| AllTrim(x[2]) == "CNS_ITEM"})
nPosCNSQt := aScan(aHeadParc,{|x| AllTrim(x[2]) == "CNS_PRVQTD"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicoes das parcelas do cronograma financeiro      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosVlPrv := aScan(aHeader  ,{|x| AllTrim(x[2]) == "CNF_VLPREV"})
nPosVlSld := aScan(aHeader  ,{|x| AllTrim(x[2]) == "CNF_SALDO"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa arrays                                              ³
//³ -aColsParc - armazena as parcelas fisicas                      ³
//³ -aFscVl    - armazena os valores e totais dos itens de planilha³
//³ -aParcFsc  - usado na inclusao de itens em n parcelas (cache)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aColsParc,{})
aAdd(aFscVl,{})
aParcFsc := {}

nTotCron := len(aColsParc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o cronograma fisico da planilha                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN110LdFsc(aColsParc[nTotCron],aHeadParc,aFscVl[len(aFscVl)],cContra,cRevisa,cCron,cPlan)

If nPosPlan > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Total de itens pela parcela do cronograma fisico               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotIts := len(aColsParc[nTotCron,1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foram incluidos novos itens na planilha            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nIncIt := len(aAditQtd[nPosPlan]) - nTotIts) > 0
		For nY:=1 to len(aColsParc[nTotCron])
			nPosCpo := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os itens adicionados a planilha                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=nTotIts+1 to len(aAditQtd[nPosPlan])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o item foi excluido               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aAditQtd[nPosPlan,nZ] != Nil
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona o item no cronograma fisico          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aColsParc[nTotCron,nY],Array(len(aHeadParc)+1))
					nPosItFsc := len(aColsParc[nTotCron,nY])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preenche os campos do cronograma fisico       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nPosCpo:=1 to len(aHeadParc)
						Do Case
							Case aHeadParc[nPosCpo,2] == "CNS_ITEM"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := aItens[nPosPlan,nZ,aStruIts[1]]
							Case aHeadParc[nPosCpo,2] == "CNS_PRODUT"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := aItens[nPosPlan,nZ,aStruIts[2]]
							Case aHeadParc[nPosCpo,2] == "CNS_DESCRI"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := aItens[nPosPlan,nZ,aStruIts[3]]
							Case aHeadParc[nPosCpo,2] == "CNS_PRVQTD"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := 0
							Case aHeadParc[nPosCpo,2] == "CNS_RLZQTD"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := 0
							Case aHeadParc[nPosCpo,2] == "CNS_SLDQTD"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := 0
							Case aHeadParc[nPosCpo,2] == "CNS_TOTQTD"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := aItens[nPosPlan,nZ,aStruIts[6]]
							Case IsHeadRec(aHeadParc[nPosCpo,2])
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := 0
		  					Case IsHeadAlias(aHeadParc[nPosCpo,2])
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := "CNS"
							Case aHeadParc[nPosCpo,10] == "V"
								aColsParc[nTotCron,nY,nPosItFsc,nPosCpo] := CriaVar(aHeadParc[nPosCpo,2])
						EndCase
					Next
					aColsParc[nTotCron,nY,nPosItFsc,len(aHeadParc)+1] := .F.
						
				EndIf
			Next
		Next
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os itens adicionados e excluidos para controle³
	//³ do cronograma fisico e financeiro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ny:=1 to len(aAditQtd[nPosPlan])
		If aAditQtd[nPosPlan,ny] != Nil
			nZ := ny
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o item foi incluido na planilha e preenche ³
			//³ o array de controle aFscVl                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If len(aFscVl[nTotCron]) < ny
				nVlUnit := aItens[nPosPlan,nY,aStruIts[4]]//Valor unitario
				nDesc   := aItens[nPosPlan,nY,aStruIts[5]]//Desconto
				nQtdOri := aItens[nPosPlan,nY,aStruIts[7]]//Desconto
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Preenche o array aFscVl para controle do cronograma fisico ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aFscVl[nTotCron],{nVlUnit,aItens[nPosPlan,nY,aStruIts[6]],0,aItens[nPosPlan,nY,aStruIts[1]],nVlUnit,nQtdOri,nDesc})
				nZ := len(aFscVl[nTotCron])
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma a quantidade aditivada no array aFscVl                ³   			
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aFscVl[nTotCron,nZ,3]+=aAditQtd[nPosPlan,ny]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o item foi excluido da planilha                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aItens[nPosPlan,nY,len(aHeaderIt)+1]
				nDelParc := 0
				For nZ:=1 to len(aColsParc[nTotCron])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Encontra o item na parcela fisica do cronograma            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nDelParc := If(nDelParc==0,aScan(aColsParc[nTotCron,nZ],{|x| x[nPosCNSIt] == aItens[nPosPlan,nY,aStruIts[1]]}),nDelParc)
					If (nDelParc > 0)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Retira o valor do item do cronograma financeiro            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aParcelas[nTotCron,nZ,nPosVlPrv] -= aFscVl[nTotCron,nDelParc+nTotDelIt,1]*aColsParc[nTotCron,nZ,nDelParc,nPosCNSQt]
						aParcelas[nTotCron,nZ,nPosVlSld] -= aFscVl[nTotCron,nDelParc+nTotDelIt,1]*aColsParc[nTotCron,nZ,nDelParc,nPosCNSQt]
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Exclui o item do array aColsParc que armazena o cronograma ³
						//³ fisico                                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aDel(aColsParc[nTotCron,nZ],nDelParc)
						aSize(aColsParc[nTotCron,nZ],len(aColsParc[nTotCron,nZ])-1)
					EndIf
				Next
				If nDelParc > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Subtrai o valor do item do saldo e montante do cronograma  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aTotCont[1] -= aFscVl[nTotCron,nDelParc+nTotDelIt,1]*aItens[nPosPlan,nY,aStruIts[6]]
					aTotCont[2] -= aFscVl[nTotCron,nDelParc+nTotDelIt,1]*aItens[nPosPlan,nY,aStruIts[6]]

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Armazena a posicao do item para futura exclusao do array   ³
					//³ aFscVl                                                     ³					
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAdd(aDelParc,nDelParc)
					nTotDelIt++
				EndIf
			EndIf
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre os itens excluidos e retira do array aFscVl          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nY:=1 to len(aDelParc)
		aDel(aFscVl[nTotCron],aDelParc[nY])
		aSize(aFscVl[nTotCron],len(aFscVl[nTotCron])-1)
	Next
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140AtuFsc ³ Autor ³ Marcelo Custodio      ³ Data ³23.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Calcula os valores das parcelas financeiras com base no       ³±±
±±³          ³cronograma fisico, ao finalizar revisao do tipo realinhamento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140AtuFsc(cExp01,cExp02)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do contrato                                   ³±±
±±³          ³cExp02 - Codigo da revisao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140AtuFsc(cContra,cRevisa,lReali,cORevisa)
Local cQuery   := ""
Local cAliasCNF:= ""
Local cAliasCNS:= ""
Local cPlanAtu := ""
Local cPlanAnt := ""
Local nVlUnto  := 0                          
Local nVlUnt   := 0    
Local nQtdTot  := 0
Local lRealMed := (GetNewPar( "MV_CNREALM", "S" ) == "S")
Local aReali   := {}
Local nParc    := 0  
Local nAcmVlr  := 0
Local nAcmSld  := 0
Local cUltParc := ""
Local nTotPlan := 0
Local nTotDistr:= 0
Local nDifArred:= 0

DEFAULT lReali := .F.
DEFAULT cORevisa := ""

cAliasCNF := GetNextAlias()  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os itens e parcelas realinhados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNF.CNF_CONTRA,CNF.CNF_REVISA,CNF.CNF_NUMERO, CNF.CNF_PARCEL, CNF.R_E_C_N_O_ as RECNO " 
cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
cQuery += " WHERE  CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNF.D_E_L_E_T_ = ' ' "
cQuery += "   ORDER BY CNF.CNF_CONTRA,CNF.CNF_REVISA,CNF.CNF_NUMERO, CNF.CNF_PARCEL"

cQuery := ChangeQuery( cQuery )
cAlias := GetNextAlias()
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasCNF, .F., .F. )

// Seleciona o codigo da ultima parcela
If Select(cAliasCNF) > 0
	CNF->(DbSetOrder(1))
	CNF->(dbGoTo((cAliasCNF)->RECNO))
	While CNF->(!Eof()) .And. CNF->CNF_FILIAL == xFilial("CNF") .And. CNF->CNF_CONTRA == cContra .And. CNF->CNF_REVISA == cRevisa
		cUltParc := CNF->CNF_PARCEL
		CNF->(dbSkip())
	EndDo
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o cronograma fisico do contrato             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
cAliasCNS := GetNextAlias()  
cQuery := "SELECT CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_CRONOG, CNS.CNS_PARCEL ,CNS.CNS_ITEM, CNS.CNS_SLDQTD, CNS.CNS_RLZQTD, CNS.CNS_PRVQTD,CNS.R_E_C_N_O_ as RECNO , "

If CNS->(FieldPos("CNS_ITOR")) > 0  
	cQuery += "       CNS.CNS_ITOR,  "          
EndIf
cQuery += "       CNB.CNB_VLUNIT, CNB.CNB_REALI, CNB.CNB_SLDREC,CNB.CNB_SLDMED, CNB.CNB_DESC, CNB.CNB_NUMERO "
cQuery += "  FROM "+RetSQLName("CNS")+" CNS ,"+ RetSQLName("CNB")+" CNB "
cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
cQuery += "   AND CNS.CNS_REVISA = '"+cRevisa+"'" 
cQuery += "   AND CNS.CNS_CONTRA = CNB.CNB_CONTRA "
cQuery += "   AND CNS.CNS_REVISA = CNB.CNB_REVISA "
cQuery += "   AND CNS.CNS_PLANI  = CNB.CNB_NUMERO "
cQuery += "   AND CNS.CNS_ITEM   = CNB.CNB_ITEM   "
cQuery += "   AND CNB.D_E_L_E_T_ = ' ' "
cQuery += "   AND CNS.D_E_L_E_T_ =' '"   
cQuery += "   ORDER BY CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_CRONOG, CNS.CNS_PARCEL ,CNS.CNS_ITEM "
	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNS,.F.,.T.)

TCSetField(cAliasCNS,"CNS_RLZQTD","N",TamSX3("CNB_VLUNIT")[1],TamSX3("CNB_VLUNIT")[2])
TCSetField(cAliasCNS,"CNS_SLDQTD","N",TamSX3("CNB_REALI")[1] ,TamSX3("CNB_REALI")[2])
TCSetField(cAliasCNS,"CNS_PRVQTD","N",TamSX3("CNB_DESC")[1]  ,TamSX3("CNB_DESC")[2])     
TCSetField(cAliasCNS,"CNB_VLUNIT","N",TamSX3("CNB_VLUNIT")[1],TamSX3("CNB_VLUNIT")[2])
TCSetField(cAliasCNS,"CNB_REALI" ,"N",TamSX3("CNB_REALI")[1] ,TamSX3("CNB_REALI")[2])
TCSetField(cAliasCNS,"CNB_DESC"  ,"N",TamSX3("CNB_DESC")[1]  ,TamSX3("CNB_DESC")[2])
	

dbSelectArea("CNF")
While !(cAliasCNF)->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na parcela do cronograma                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	CNF->(dbGoTo((cAliasCNF)->RECNO)) 
   
	
	While !(cAliasCNS)->(Eof())  .And. ((cAliasCNS)->CNS_CONTRA+(cAliasCNS)->CNS_REVISA+(cAliasCNS)->CNS_CRONOG+(cAliasCNS)->CNS_PARCEL==(cAliasCNF)->CNF_CONTRA+(cAliasCNF)->CNF_REVISA+(cAliasCNF)->CNF_NUMERO+(cAliasCNF)->CNF_PARCEL)
		CNS->(dbGoTo((cAliasCNS)->RECNO)) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valores unitarios, original e realinhado           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		nVlUnto := (cAliasCNS)->CNB_VLUNIT-(((cAliasCNS)->CNB_VLUNIT*(cAliasCNS)->CNB_DESC)/100)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para itens que nao foram selecionados para o realinhamento        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If (cAliasCNS)->CNB_REALI-(((cAliasCNS)->CNB_REALI*(cAliasCNS)->CNB_DESC)/100)> 0
			nVlUnt := (cAliasCNS)->CNB_REALI-(((cAliasCNS)->CNB_REALI*(cAliasCNS)->CNB_DESC)/100)   
		Else
			nVlUnt := (cAliasCNS)->CNB_VLUNIT-(((cAliasCNS)->CNB_VLUNIT*(cAliasCNS)->CNB_DESC)/100)  
		EndIf

   		nQtdTot := CN140PrEnt(cContra,cORevisa,lRealMed,CNF->CNF_COMPET,(cAliasCNS)->CNS_ITEM)	

 
   		nParc++
		If CNS->CNS_SLDQTD > 0 .and. CNS->CNS_RLZQTD == 0
			nAcmVlr += Round(CNS->CNS_SLDQTD*nVlUnt,TamSX3("CNS_SLDQTD")[2])
			nAcmSld += Round(CNS->CNS_SLDQTD*nVlUnt,TamSX3("CNS_SLDQTD")[2]) 
		EndIf
		
        If CNS->CNS_SLDQTD == 0
           nAcmVlr += Round(CNS->CNS_RLZQTD*nVlUnto,TamSX3("CNS_RLZQTD")[2])
        EndIf  
        
        If CNS->CNS_SLDQTD > 0 .and. CNS->CNS_RLZQTD > 0
           nAcmVlr += (Round(CNS->CNS_RLZQTD*nVlUnto,TamSX3("CNS_RLZQTD")[2])+ Round(CNS->CNS_SLDQTD*nVlUnt,TamSX3("CNS_SLDQTD")[2]))  
           nAcmSld += Round(CNS->CNS_SLDQTD*nVlUnt,TamSX3("CNS_SLDQTD")[2]) 
        EndIf
  	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Considera no array os itens já medidos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If CNS->(FieldPos("CNS_ITOR")) > 0  
			If !Empty((cAliasCNS)->CNS_ITOR) 	
				Aadd(aReali,(cAliasCNS)->CNS_RLZQTD)
			EndIf		 
			                                                                                           
			//Considera as quantidades parcialmente entregues
			If !Empty(aReali)
				If !Empty(aReali[Len(aReali)]) .And. aReali[Len(aReali)] == (cAliasCNS)->CNS_RLZQTD .And. (cAliasCNS)->CNS_RLZQTD>0 .And. (cAliasCNS)->CNS_SLDQTD>0 .And. Empty((cAliasCNS)->CNS_ITOR) 
				 	nAcmVlr  += CNS->CNS_RLZQTD*(nVlUnt-nVlUnto)
					nAcmSld  += CNS->CNS_RLZQTD*(nVlUnt-nVlUnto)
				EndIf			 
			EndIF
		EndIf

		
		//Executado quando parametro MV_CNREALM = S 
		If lRealMed .And. lReali .And. nQtdTot== 0 .And. CNF->CNF_VLREAL > 0 .And. (cAliasCNS)->CNB_SLDREC<>(cAliasCNS)->CNB_SLDMED
			vPrevAnt:= (CNS->CNS_RLZQTD*nVlUnto)+(CNS->CNS_SLDQTD*nVlUnto)
			vPrevPos:= (CNS->CNS_RLZQTD*nVlUnt)+(CNS->CNS_SLDQTD*nVlUnt)  
		
			If nAcmSld == 0
				nAcmVlr += (vPrevPos-vPrevAnt)-(cAliasCNS)->CNS_SLDQTD*nVlUnto      		
				nAcmSld:= nAcmVlr+nAcmSld
			EndIf  
		  
			If nAcmSld > 0 .And. CNS->CNS_SLDQTD > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma valor realinhado              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  	nAcmVlr := CNS->CNS_SLDQTD*nVlUnt      
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna com valor antigo no saldo  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nAcmSld := CNS->CNS_SLDQTD*nVlUnt   
				nAcmVlr  := CNF->CNF_VLREAL+nAcmSld
			EndIf  
					
		EndIf

		cPlanAtu:= CNF->CNF_NUMERO
		(cAliasCNS)->(dbSkip()) 
	EndDo   
 
	RecLock("CNF",.F.)     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Subtrai valor original             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		CNF->CNF_VLPREV := nAcmVlr
		CNF->CNF_SALDO  := nAcmSld
		      
		//Calcula Valor Total Distribuido entre as Parcelas
		If !Empty(cPlanAnt) .And. cPlanAtu != cPlanAnt
			nTotDistr := 0
		EndIf
		nTotDistr += Round(nAcmVlr,2)
	
		//Quando for a ultima parcela a realinhar verificar se houve diferença de arredondamento
		If CNF->CNF_PARCEL == cUltParc .And. !lRealMed
			nTotPlan := Posicione("CNA",1,xFilial("CNA")+cContra+cRevisa+CNS->CNS_PLANI,"CNA_VLTOT")
			nDifArred := nTotPlan - nTotDistr
			CNF->CNF_VLPREV:= CNF->CNF_VLPREV+ nDifArred
			CNF->CNF_SALDO := CNF->CNF_SALDO + nDifArred 
		Endif	
		     

	MsUnLock()
	
	nParc:=0
	nAcmVlr := 0  
	nAcmSld := 0
	cPlanAnt:= CNF->CNF_NUMERO

	(cAliasCNF)->(dbSkip())
EndDo

(cAliasCNS)->(dbCloseArea())
(cAliasCNF)->(dbCloseArea())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldVl  ³ Autor ³ Marcelo Custodio      ³ Data ³23.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida o valor informado para contratos sem planilha          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VldVl(nExp01,nExp02,nExp03,cExp04)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp01 - Saldo do contrato                                    ³±±
±±³          ³nExp02 - Valor original                                       ³±±
±±³          ³nExp03 - Valor atualizado                                     ³±±
±±³          ³cExp04 - Codigo do tipo da revisao                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldVl(nSaldo,nVlOri,nValor,cCodTR)
Local lRet := .T.

If nValor < (nVlOri - nSaldo)
	lRet := .F.
Else
	dbSelectArea("CN0")
	dbSetOrder(1)
	
	If dbSeek(xFilial("CN0")+cCodTR)
		Do Case
			Case nValor < nVlOri//Decrescimo
				lRet := (CN0->CN0_MODO $ "23")
			Case nValor > nVlOri//Acrescimo
				lRet := (CN0->CN0_MODO $ "13")
		EndCase
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³19/10/2006³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
PRIVATE aRotina	:= { 	{ OemToAnsi(STR0002), "AxPesqui"  , 0, 1, 0, .F.},;//"Pesquisar"
				   	 		{ OemToAnsi(STR0003), "CN100Manut", 0, 2, 0, nil},;//"Visualizar"
								{ OemToAnsi(STR0086), "CN140Manut", 0, 3, 0, nil},;//"Revisar"
								{ OemToAnsi(STR0079), "CN140Cron" , 0, 3, 0, .F.},;//"Cronogramas"
								{ OemToAnsi(STR0006), "CN140Excl", 0, 5, 0, .F.},;//"Excluir"
								{ OemToAnsi(STR0015), "CN100Legenda",0,6, 0, .F.}} //"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTA140MNU")
	ExecBlock("CTA140MNU",.F.,.F.)
EndIf
Return(aRotina)          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140PlnCt³ Autor ³ Marcelo Custodio      ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega planilhas do Cronograma Contabil                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LPlan(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do Contrato                                ³±±
±±³          ³ cExp02 - Codigo da Revisao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140PlnCt(cContra,cRevisa,lRet,aCronCtb)
Local cQuery := ""     
Local aArea := GetArea()

lRet := .T.
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra planilhas do contrato                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNV.* "
cQuery += "  FROM "+RetSqlName("CNV")+" CNV "
cQuery += " WHERE CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
cQuery += "   AND CNV.CNV_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNV.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY CNV.CNV_NUMERO"  
  
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

dbSelectArea("TRB")
dbGoTop()
	
If !Eof()
	
	dbSelectArea("TRBCNV")
	If RecCount() > 0
		Zap
	Endif
	
	dbSelectArea("TRB")
	
	cCronog:=TRB->CNV_NUMERO
	While !Eof()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona registros filtrados ao arquivo temporario  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("TRBCNV",.T.)
		    TRBCNV->CNV_FILIAL := TRB->CNV_FILIAL
			TRBCNV->CNV_CONTRA := TRB->CNV_CONTRA
			TRBCNV->CNV_NUMERO := TRB->CNV_NUMERO
			TRBCNV->CNV_PLANIL := TRB->CNV_PLANIL
		MsUnlock()         
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	
	TRBCNV->(dbGoTop())	
Else
	If cTpRev=="8" .and.  nRevRtp = 0
		Help("CNTA140",1,"CNTA140_17")//"Não há Cronograma contabil selecionado"##"Atenção"
		lRet := .F.
		lMotREvOk :=.T.
	Else 
		MsgInfo(STR0112)
		lMotREvOk :=.F.
	Endif	
Endif

TRB->(dbCloseArea())   

RestArea(aArea)
 
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140RvPlCt³ Autor ³ Robson Nayland       ³ Data ³13.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega parcelas do Cronograma Contabil                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140RvPlCt(aExp01,aExp02,cExp03,cExp04)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - array com os cronog selecionados                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140RvPlCt(aCronCtb,aItensCtb,cContra,cRevisa,cNrevisa,aAditPlan,aCpo,nVgAdit,dFContra,cCtbO,aTotCtb)

Local cCnum
Local cAlias   := ""
Local cQuery   := ""     

Local aArea    := GetArea()
Local aCpoCtb  := {"CNW_FILIAL","CNW_NUMERO","CNW_CC","CNW_ITEMCT","CNW_CLVL","CNW_REVISA","CNW_CONTRA"}//Campos nao exibidos na getdados
Local aStrucCNW:= CNW->(dbStruct())
Local aRetCnv  := {}

Local cNumero  := ""

Local nItemNum := 1
Local nPlan    := 0
Local NY       := 1
Local X

Local lRet     := .T.

Local dDtMax1  := dDatabase
Local dDtMax2  := dDatabase

aItensCtb:={}
aHeaderCt:={}
aTotCtb  :={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche cabecalhos dos itens de planilhas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If dbSeek("CNW", .F.)
	Do While !Eof() .And. SX3->X3_ARQUIVO=="CNW"
		If ( X3USO(SX3->X3_USADO)) .And. (aScan(aCpoCtb,{|x| x == Alltrim(SX3->X3_CAMPO)}) == 0) .And. cNivel >= SX3->X3_NIVEL
			aAdd(aHeaderCt,{AllTrim(X3Titulo()),;
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no contrato                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN9->(dbSetOrder(1))
CN9->(dbSeek(xFilial("CN9")+cContra+cRevisa))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa getdados                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oGetCtb == NIL
	oGetCtb := MsNewGetDados():New(045,000, __DlgHeight(oWizard:oMPanel[13])-10, __DlgWidth(oWizard:oMPanel[13])-10,If((cModo $ "13" ),GD_UPDATE,GD_UPDATE),,,,aCpo,,,,,,oWizard:oMPanel[13],aHeaderCt,aItensCtb)
	oGetCtb:bChange := {|| CN140Get2Chg(aCpo)}
EndIf

For x:=1 to Len(aCronCtb)
    cNumero+=aCronCtb[X]
    If X< Len(aCronCtb)
      cNumero+="','"
    Endif    
Next X
lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os totais dos cronogramas contabeis       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNV.CNV_NUMERO, CNV.CNV_PLANIL, SUM(CNW.CNW_VLPREV) AS CNW_VLPREV, "
cQuery += "       CNA.CNA_VLTOT,  MAX(CNW.CNW_DTPREV) AS CNW_DTPREV "
cQuery += "  FROM "+RetSQLName("CNW")+" CNW, "+RetSQLName("CNV")+" CNV, "+RetSQLName("CNA")+" CNA "
cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
cQuery += "   AND CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
cQuery += "   AND CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
cQuery += "   AND CNW.CNW_NUMERO = CNV.CNV_NUMERO "
cQuery += "   AND CNW.CNW_CONTRA = CNV.CNV_CONTRA "
cQuery += "   AND CNW.CNW_REVISA = CNV.CNV_REVISA "
cQuery += "   AND CNA.CNA_NUMERO = CNV.CNV_PLANIL "
cQuery += "   AND CNA.CNA_REVISA = CNV.CNV_REVISA "
cQuery += "   AND CNA.CNA_CONTRA = CNV.CNV_CONTRA "
cQuery += "   AND CNV.CNV_NUMERO in ('"+cNumero+"')"
cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
cQuery += "   AND CNV.CNV_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNA.D_E_L_E_T_ = ' '"
cQuery += "   AND CNW.D_E_L_E_T_ = ' '"
cQuery += "   AND CNV.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY CNV.CNV_NUMERO,CNV_PLANIL,CNA.CNA_VLTOT "
cQuery += " ORDER BY CNV.CNV_NUMERO"

cQuery := ChangeQuery(cQuery)
cAlias := GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

TCSetField(cAlias,"CNW_VLPREV","N",TamSX3("CNW_VLPREV")[1],TamSX3("CNW_VLPREV")[2])
TCSetField(cAlias,"CNW_DTPREV","D",TamSX3("CNW_DTPREV")[1],TamSX3("CNW_DTPREV")[2])
TCSetField(cAlias,"CNA_VLTOT","N",TamSX3("CNA_VLTOT")[1],TamSX3("CNA_VLTOT")[2])

While !(cAlias)->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutua do aTotCtb                                 ³
	//³ -aTotCtb[x,1] - Numero do cronograma                ³
	//³ -aTotCtb[x,2] - Numero da planilha                  ³
	//³ -aTotCtb[x,3] - Total do cronograma                 ³
	//³ -aTotCtb[x,4] - Total da planilha                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aTotCtb,{(cAlias)->CNV_NUMERO,(cAlias)->CNV_PLANIL,(cAlias)->CNW_VLPREV,(cAlias)->CNA_VLTOT})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica valores aditivados na planilha             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If (nPlan := aScan(aAditPlan,{|x| x[1] == (cAlias)->CNV_PLANIL})) > 0
		aTotCtb[len(aTotCtb),4] += aAditPlan[nPlan,2]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica data maxima dos cronogramas contabeis      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If dDtMax2 < (cAlias)->CNW_DTPREV
		dDtMax2 := (cAlias)->CNW_DTPREV
	EndIf

	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona parcelas dos cronogramas contabeis        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNW.* "
cQuery += "  FROM "+RetSqlName("CNW")+" CNW "
cQuery += " WHERE CNW.CNW_FILIAL =  '"+xFilial("CNW")+"'"
cQuery += "   AND CNW.CNW_NUMERO IN ('"+cNumero+"')"
cQuery += "   AND CNW.CNW_CONTRA = '"+cContra+"'"
cQuery += "   AND CNW.CNW_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNW.D_E_L_E_T_ = ' '"    

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)

For X:=1 to len(aStrucCNW)
	if TRB->(FieldPos(aStrucCNW[X,1])) > 0 .And. aStrucCNW[X,2] <> "C"
		TCSetField( "TRB", aStrucCNW[X,1], aStrucCNW[X,2], aStrucCNW[X,3], aStrucCNW[X,4] )
	endif
Next

dbSelectArea("TRB")
dbGoTop()

aItensCtb:=Array(Len(aCronCtb))
	
If !Eof()
	
	dbSelectArea("TRBCNW")
	If RecCount() > 0
		Zap
	Endif

	aItensCtb[nItemNum] := {}
	aItensCtb[nItemNum] := {NY}

	dbSelectArea("TRB")
	cCnum:=TRB->CNW_NUMERO
	While !Eof()
      aItensCtb[nItemNum][NY]:=Array(len(aHeaderCt)+1)
		For x:=1 to len(aHeaderCt)
			If aHeaderCt[x,10] != "V"
				aItensCtb[nItemNum,ny,x] := TRB->&(aHeaderCt[x,2])
			Else
				aItensCtb[nItemNum,ny,x] := CriaVar(aHeaderCt[x,2])
			EndIf
		Next
		aItensCtb[nItemNum,ny,len(aHeaderCt)+1] := .F.

		dbSelectArea("TRB")
		nNrParcela:=Val(TRB->CNW_PARCEL)
		dUltData  :=TRB->CNW_DTPREV
		dbSkip()
		If TRB->CNW_NUMERO<>cCnum
         If !Eof()
	         cCnum:=TRB->CNW_NUMERO
				nItemNum++
				aItensCtb[nItemNum]:={}
				aItensCtb[nItemNum] := {NY}
				NY:=1
			Endif	
		Else                            
			NY++
			aSize(aItensCtb[nItemNum],NY)
      Endif
	Enddo
	dbSelectArea("TRB")
	DbGoTop()
	While !Eof()
		TRB->( dbGoTop() )
		cCCusto :=TRB->CNW_CC
        cItemCt :=TRB->CNW_ITEMCT
        cClVl   :=TRB->CNW_CLVL
		dDtPrev := TRB->CNW_DTPREV
		TRB->( dbSkip() )
		dDtPrev := If(Eof(),30,(TRB->CNW_DTPREV-dDtPrev))
		TRB->( dbGoTop() )
		EXIT
   Enddo
	cCtbCron   := aCronCtb[1]
	TRBCNW->(dbGoTop())	
	cCtbO := cCtbCron := aCronCtb[1]
	
	For x:=1 to len(aCronCtb)
		CN140CalcParc(aItensCtb,aCronCtb[x],@dDtMax1)
		If dDtMax1 > dDtMax2
			dDtMax2 := dDtMax1
		EndIf
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla vigencia de termino do contrato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dFCronog == NIL .Or. dFCronog < dDtMax2
		dFCronog :=	dDtMax2
	EndIf
	nVgAdit := CN140Dif(CN9->CN9_DTFIM,dFCronog,CN9->CN9_UNVIGE)
	nVgAdit := CN9->CN9_VIGE+nVgAdit
	dFContra := CN100DtFim(CN9->CN9_UNVIGE,CN9->CN9_DTINIC,nVgAdit)

 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa ponto de entrada para customização das parcelas do cronograma ³
	//³ contabil															  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("CN140CNV")
		aRetCnv := ExecBlock("CN140CNV",.F.,.F.,{aCronCtb,aItensCtb,cContra,cRevisa,cNrevisa,aAditPlan,aTotCtb})
		If ValType(aRetCnv)=="A"
			If Len(aRetCnv)>=1 .And. ValType(aRetCnv[1]) == "A"
				aCronCtb  := aRetCnv[1]
			Endif
			If Len(aRetCnv)>=2 .And. ValType(aRetCnv[2]) == "A"
				aItensCtb := aRetCnv[2]
			Endif		
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o primeiro cronograma        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	oGetCtb:aCols := aItensCtb[1]
 	nTotCronog     := aTotCtb[1,3]
 	nTotPlan       := aTotCtb[1,4]
 	
	CN140Get2Chg(aCpo)
	oGetCtb:oBrowse:nAt :=  1
	oGetCtb:oBrowse:Refresh()
	oTotPlan:Refresh()
	oTotCronog:Refresh()
	oSaldDist:Refresh()
Else
	Help("CNTA140",1,"CNTA140_17")//"Não há cronograma contabil selecionado"##"Atenção"
	lRet := .F.
Endif

TRB->(dbCloseArea())   
RestArea(aArea)
 
Return lRet  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN140CtbLoad ³ Autor ³ Robson Nayland    ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a troca do acols de acordo com o array aItensCtb   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140CtbLoad(cExp01,aExp02,aExp03,aExp04,cExp05,aExp06,    ³±±
±±³          ³              cExp07,oExp08,aExp09)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Cronograma selecionado                            ³±±
±±³          ³ aExp02 - Array com as parcelas dos cronogramas             ³±±
±±³          ³ aExp03 - Array com os cronogramas selecionados             ³±±
±±³          ³ aExp04 - Aditivo das planilhas                             ³±±
±±³          ³ cExp05 - Codigo do contrato                                ³±±
±±³          ³ aExp06 - Campos alterados na edicao do cronograma          ³±±
±±³          ³ cExp07 - Codigo original do cronograma contabil            ³±±
±±³          ³ oExp08 - Objeto de selecao do cronograma contabil          ³±±
±±³          ³ aExp09 - Totais dos cronogramas contabeis                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140CtbLoad(cCtbCron,aItensCtb,aCronCtb,aAditPlan,cContra,aCpo,cCtbO,oCtbCron,aTotCtb)
//Verifica posicao da planilha no 'array
Local nPos  := aScan(aCronCtb,cCtbCron)
Local nPos2 := aScan(aCronCtb,cCtbO)
Local cPlan := ""
Local lRet  := .T.
Local x

If nTotPlan != nTotCronog
	Help("CNTA140",1,"CNTA140_11")//"O montante do cronograma deve ser igual ao montante da planilha"
	oCtbCron:nAt := nPos2
	cCtbCron     := cCtbO
	lRet := .F.
Else
	cCtbO      := cCtbCron
	nPosVlPrev := aScan(aHeaderCt,{|x| x[2] == "CNW_VLPREV"}) 
	
	If lRet .And. nPos > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena os totais do cronograma original ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aTotCtb[nPos2,3] := nTotCronog
    	aTotCtb[nPos2,4] := nTotPlan
	
		CNV->(dbSetOrder(1))
					
		oGetCtb:aCols       := aItensCtb[nPos]
		oGetCtb:oBrowse:nAt :=  1
		oGetCtb:oBrowse:Refresh()

  		nTotCronog:=aTotCtb[nPos][3]
    	nTotPlan  :=aTotCtb[nPos][4]

		oTotPlan:Refresh()
		oTotCronog:Refresh()
		oSaldDist:Refresh()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN140CalcParc³ Autor ³ Robson Nayland    ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o calculo das Parcelas Acrecimos/Decrescimo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140CalcParc(aExp01)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Array com as parcelas dos cronogramas contabeis   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140CalcParc(aItensCtb,cCtbCron,dDataMax)

Local nX 
Local nX2
Local nY
Local nPos2      := aScan(aCronCtb,cCtbCron)
Local nPosDtPrev := aScan(aHeaderCt,{|x| x[2] == "CNW_DTPREV"}) 
Local nPosVlPrev := aScan(aHeaderCt,{|x| x[2] == "CNW_VLPREV"}) 
Local nPosParc   := aScan(aHeaderCt,{|x| x[2] == "CNW_PARCEL"}) 
Local nVlDecres  :=0
Local nPosNCron  := 0
Local nDiaPar    := 30
Local nAvanco	 := 0

Local cNrParcela := ""

Local dUltData   := aItensCtb[nPos2,len(aItensCtb[nPos2]),nPosDtPrev]

Local lRet       := .T.
Local lAcres	 := .T.

//Verifica modo de alteracao de parcelas
If cModo == "1"
	lAcres := .T.
ElseIf cModo == "2"
   lAcres := .F.
Else
	lAcres := (oTpCronCtb:nAt == 1)
EndIf

//Verifica se existe a periodicidade entre as parcelas
If (CNV->(FieldPos("CNV_DIAPAR")) > 0) .And. CNV->(Dbseek(xFilial("CNV")+cContra+"   "+cCtbCron))
	nDiaPar := CNV->CNV_DIAPAR
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpando Arrays caso valor for  0                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nParcelas > 0
	For nX:=Len(aItensCtb[nPos2]) to  1  STEP - 1
		if aItensCtb[nPos2][nX][nPosVlPrev]==0
			aDel(aItensCtb[nPos2],nX)
			aSize(aItensCtb[nPos2],Len(aItensCtb[nPos2])-1) 
		Endif
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adicionando ou Excluido Parcelas do Cronograma Contabil  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cNrParcela := aItensCtb[nPos2,len(aItensCtb[nPos2]),nPosParc]
     
	If lAcres	       // Se for opção Acrescimo (adiciona novas parcelas)
	   For nX:=1 to nParcelas
          cNrParcela := Soma1(cNrParcela) 
          If nDiaPar == 30
			nAvanco  :=Day(LastDay(dUltData))
	      Else
			nAvanco := nDiaPar
		  EndIf
		  dUltData := dUltData + nAvanco
          aAdd(aItensCtb[nPos2],Array(len(aHeaderCt)+1))
          nPosNCron := len(aItensCtb[nPos2])
          For nX2:=1 to len(aHeaderCt)
          	Do Case
          		Case aHeaderCt[nX2,2] == "CNW_PARCEL"
          			aItensCtb[nPos2,nPosNCron,nX2] := cNrParcela
          		Case aHeaderCt[nX2,2] == "CNW_DTPREV"
          	 		aItensCtb[nPos2,nPosNCron,nX2] := dUltData
          		Case aHeaderCt[nX2,2] == "CNW_COMPET"
          	 		aItensCtb[nPos2,nPosNCron,nX2] := StrZero(Month(dUltData),2)+"/"+Str(Year(dUltData),4)
          	 	OtherWise
          	 		aItensCtb[nPos2,nPosNCron,nX2] := CriaVar(aHeaderCt[nX2,2])
          	 End Case
          Next
	      aItensCtb[nPos2,nPosNCron,len(aHeaderCt)+1]:=.F.
	   Next nX
	Else// Se for opção Decrescimo (retira as parcelas)
      If Len(aItensCtb[nPos2])> nParcelas
	      For nX2:=Len(aItensCtb[nPos2]) to ((Len(aItensCtb[nPos2])-nParcelas)+1) STEP - 1
	          nVlDecres+=aItensCtb[nPos2][nX2][nPosVlPrev]
	          aDel(aItensCtb[nPos2],nX2)
		   Next nX2  
	     	ASize(aItensCtb[nPos2],Len(aItensCtb[nPos2])-nParcelas)
	     	aItensCtb[nPos2][Len(aItensCtb[nPos2])][nPosVlPrev]+=nVlDecres
	    Else
    	    Help("CNTA140",1,"CNTA140_18")//"Parcelas a decrescer maior que o numero das parcelas existentes"
    	    lRet:=.F. 	
	   Endif  	
  	Endif	                                  
EndIf
 
dDataMax := aItensCtb[nPos2][Len(aItensCtb[nPos2])][nPosDtPrev]

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140GerCt  ³ Autor ³ Marcelo Custodio      ³ Data ³04.12.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Salva alteracoes dos cronogramas contabeis                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140GerCt(aExp01,cExp02,cExp03,cExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Itens dos cronogramas contabeis                     ³±±
±±³          ³ cExp02 - Codigo do contrato                                  ³±±
±±³          ³ cExp03 - Codigo da revisao original                          ³±±
±±³          ³ cExp04 - Codigo da nova revisao gerada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140GerCt(aItensCtb,cContra,cRevisa,cNRevisa)

Local nX
Local nY
Local nZ

Local cFilCNV := xFilial("CNV")
Local cFilCNW := xFilial("CNW")
Local cQuery  := ""
Local cCrons  := ""
Local cPoName := ""

Local aNCron := {}//Armazena cronogramas nao alterados
Local aArea  := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando em alteracao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRevisad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza variavel de revisao, para a revisao gerada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CN9")
	dbSetORder(1)
	If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
		cNRevisa := CN9->CN9_REVATU
	EndIf
	
	For nX:=1 to Len(aCronCtb)
		cCrons += "'"+aCronCtb[nX]+"',"
	Next
	
	cCrons:=SubStr(cCrons,1,len(cCrons)-1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona cronogramas fisicos              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNW.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNW")+" CNW "
	cQuery += " WHERE CNW.CNW_FILIAL = '"+cFilCNW+"'"
	cQuery += "   AND CNW.CNW_NUMERO in ("+cCrons+")"
	cQuery += "   AND CNW.CNW_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNW.CNW_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNW.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNWTMP", .F., .F. )    
       
	dbSelectArea("CNW")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga cronogramas alterados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNWTMP->(Eof()) 
		dbGoTo(CNWTMP->RECNO)
		RecLock("CNW")
			dbDelete()
		MsUnlock()
			
		CNWTMP->(dbSkip())
	EndDo

	CNWTMP->(dbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra cronogramas alterados                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNV.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNV")+" CNV "
	cQuery += " WHERE CNV.CNV_FILIAL = '"+cFilCNV+"'"
	cQuery += "   AND CNV.CNV_NUMERO in ("+cCrons+")"
	cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNV.CNV_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNV.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY CNV.CNV_NUMERO"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNVTMP", .F., .F. )    
       
	dbSelectArea("CNV")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga cronogramas alterados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNVTMP->(Eof()) 
		dbGoTo(CNVTMP->RECNO)
		RecLock("CNV")
			dbDelete()
		MsUnlock()
			
		CNVTMP->(dbSkip())
	EndDo

	CNVTMP->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona cronogramas originais                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT * "
cQuery += "  FROM "+RetSQLName("CNV")+" CNV "
cQuery += " WHERE CNV.CNV_FILIAL = '"+cFilCNV+"'"
cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
cQuery += "   AND CNV.CNV_REVISA = '"+cRevisa+"'"
cQuery += "   AND CNV.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNVTMP", .F., .F. )    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza cronogramas alterados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !CNVTMP->(Eof())
	nX := aScan(aCronCtb,CNVTMP->CNV_NUMERO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o cronograma foi alterado               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nX > 0		
		RecLock("CNV",.T.)
			For nY:=1 to FCount()
				cPoName := FieldName(nY)
				Do Case
					Case cPoName == "CNV_FILIAL"
						CNV->CNV_FILIAL := cFilCNV
					Case cPoName == "CNV_REVISA"
						CNV->CNV_REVISA := cNRevisa
					OtherWise
						FieldPut(nY,CNVTMP->&(cPoName))
				End Case
			Next
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera valores do cronograma                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY:=1 to len(aItensCtb[nX])
			RecLock("CNW",.T.)
				For nZ:=1 to len(aHeaderCt)
					CNW->&(aHeaderCt[nZ,2]) := aItensCtb[nX,NY,nZ]
				Next
				CNW->CNW_CONTRA := cContra
				CNW->CNW_REVISA := cNRevisa
				CNW->CNW_NUMERO := aCronCtb[nX]
				CNW->CNW_FILIAL := cFilCNW
			MsUnlock()
		Next
	ElseIf !lRevisad
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona cronograma para geracao de copia           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aNCron,CNVTMP->CNV_NUMERO)	
	EndIf
	CNVTMP->(dbSkip())
EndDo

CNVTMP->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza alteracao de cronogramas                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aNCron) > 0
	CN140CopCtb(cContra,cRevisa,cNRevisa,@aNCron)
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140CopCtb ³ Autor ³ Marcelo Custodio      ³ Data ³04.12.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Copia os cronogramas contabeis                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140CopCtb(cExp01,cExp02,cExp03,aExp04)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                  ³±±
±±³          ³ cExp02 - Codigo da revisao                                   ³±±
±±³          ³ cExp03 - Codigo da nova revisao                              ³±±
±±³          ³ aExp04 - Array com os cronogramas que serao copiados - opc.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140CopCtb(cContra,cRevisa,cNRevisa,aCron)
Local nX       := 0
Local aAreaCN9 := {}
Local cCrons   := ""  
Local aStrucCNV:= CNV->(dbStruct())
Local aStrucCNW:= CNW->(dbStruct())

DEFAULT aCron := {}

If len(aCron) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta sequencia para filtro dos cronogramas         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 to Len(aCron)
		cCrons += "'"+aCron[nX]+"',"
	Next
	
	cCrons:=SubStr(cCrons,1,len(cCrons)-1)
EndIf
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando em alteracao                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRevisad
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza variavel de revisao, para a revisao gerada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaCN9 := CN9->(GetArea())
	dbSelectArea("CN9")
	dbSetOrder(1)
	If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
		cNRevisa := CN9->CN9_REVATU
	EndIf
	RestArea(aAreaCN9)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as parcelas dos cronogramas contabeis        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNW.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNW")+" CNW "
	cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
	cQuery += "   AND CNW.CNW_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNW.CNW_REVISA = '"+cNRevisa+"'"
	If !Empty(cCrons)//Filtra cronogramas que serao copiados
		cQuery += " AND CNW.CNW_NUMERO in ("+ cCrons +")"
	EndIF
	cQuery += " AND CNW.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNWTMP", .F., .F. )    
       
	For nx:=1 to len(aStrucCNW)
		if CNWTMP->(FieldPos(aStrucCNW[nx,1])) > 0 .And. aStrucCNW[nx,2] <> "C"
			TCSetField( "CNWTMP", aStrucCNW[nx,1], aStrucCNW[nx,2], aStrucCNW[nx,3], aStrucCNW[nx,4] )
		endif
	Next	
	dbSelectArea("CNW")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui cronograma fisico                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNWTMP->(Eof()) 
		dbGoTo(CNWTMP->RECNO)
		RecLock("CNW")
			dbDelete()
		MsUnlock()
			
		CNWTMP->(dbSkip())
	EndDo

	CNWTMP->(dbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra cronogramas da revisao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNV.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CNV")+" CNV "
	cQuery += " WHERE CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
	cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNV.CNV_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND "
	If !Empty(cCrons)//Filtra cronogramas que serao copiados
		cQuery += " CNV.CNV_NUMERO in ("+ cCrons +") AND "
	EndIF
	cQuery += " CNV.D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNVTMP", .F., .F. )    
       
	For nx:=1 to len(aStrucCNV)
		if CNVTMP->(FieldPos(aStrucCNV[nx,1])) > 0 .And. aStrucCNV[nx,2] <> "C"
			TCSetField( "CNVTMP", aStrucCNV[nx,1], aStrucCNV[nx,2], aStrucCNV[nx,3], aStrucCNV[nx,4] )
		endif
	Next	
	dbSelectArea("CNV")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga cronogramas da revisao                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNVTMP->(Eof()) 
		dbGoTo(CNVTMP->RECNO)
		RecLock("CNV")
			dbDelete()
		MsUnlock()
			
		CNVTMP->(dbSkip())
	EndDo

	CNVTMP->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra cronogramas da revisao original              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CNV.* "
cQuery += "  FROM "+RetSQLName("CNV")+" CNV "
cQuery += " WHERE CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
cQuery += "   AND CNV.CNV_CONTRA = '"+cContra+"'"
cQuery += "   AND CNV.CNV_REVISA = '"+cRevisa+"'"
cQuery += "   AND "
If !Empty(cCrons)//Filtra cronogramas que serao copiados
	cQuery += " CNV.CNV_NUMERO in ("+ cCrons +") AND "
EndIF
cQuery += " CNV.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNVTMP", .F., .F. )    

For nx:=1 to len(aStrucCNV)
	If CNVTMP->(FieldPos(aStrucCNV[nx,1])) > 0 .And. aStrucCNV[nx,2] <> "C"
		TCSetField( "CNVTMP", aStrucCNV[nx,1], aStrucCNV[nx,2], aStrucCNV[nx,3], aStrucCNV[nx,4] )
	Endif
Next	
dbSelectArea("CNV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera copia dos cronogramas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !CNVTMP->(Eof())
	RecLock("CNV",.T.)
		For nx:=1 to CNV->(FCount())
			If  aStrucCNV[nx,2]<>"M"
				FieldPut(nx,CNVTMP->&(CNV->( FieldName(nX) )))
			EndIf			
		Next
		CNV->CNV_REVISA := cNRevisa
	MsUnlock()
	
	cQuery := "SELECT * "
	cQuery += "  FROM "+RetSQLName("CNW")+" CNW "
	cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
	cQuery += "   AND CNW.CNW_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNW.CNW_REVISA = '"+cRevisa+"'"
	cQuery += "   AND CNW.CNW_NUMERO = '"+CNVTMP->CNV_NUMERO+"'"
	cQuery += "   AND CNW.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNWTMP", .F., .F. )

	For nx:=1 to len(aStrucCNW)
		If CNWTMP->(FieldPos(aStrucCNW[nx,1])) > 0 .And. aStrucCNW[nx,2] <> "C"
			TCSetField( "CNWTMP", aStrucCNW[nx,1], aStrucCNW[nx,2], aStrucCNW[nx,3], aStrucCNW[nx,4] )
		Endif
	Next	
	dbSelectArea("CNW")
	While !CNWTMP->(Eof())
		RecLock("CNW",.T.)
			For nX:=1 to CNW->( FCount() )   
				If  aStrucCNW[nx,2]<>"M"
					FieldPut(nX,CNWTMP->&(CNW->( FieldName(nX) )))
				EndIf
			Next
			CNW->CNW_REVISA := cNRevisa
		MsUnlock()
		CNWTMP->(dbSkip())
	EndDo

	CNWTMP->(dbCloseArea())
	CNVTMP->(dbSkip())
EndDo

CNVTMP->(dbCLoseArea())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140Get2Chg³ Autor ³ Marcelo Custodio      ³ Data ³04.12.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera a edicao dos campos na selecao da parcela             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140Get2ChgcExp01,aExp02,aExp03,aExp04)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Campos de alteracao do cronograma contabil          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140Get2Chg(aCpo)

Local nPosFlgApr := aScan(oGetCtb:aHeader,{|x| x[2] == "CNW_FLGAPR"})

If nPosFlgApr > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permite alterar parcelas que nao tenham sido  apropriadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oGetCtb:aCols[oGetCtb:nAt,nPosFlgApr]=="1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Bloqueia edicao     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetCtb:OBROWSE:aAlter := {}
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Libera campos para edicao             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGetCtb:OBROWSE:aAlter := aCpo
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140VldCtb³ Autor ³ Marcelo Custodio      ³ Data ³04.12.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida os cronogramas contabeis                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA140VldCtb(cExp01,aExp02,aExp03,aExp04)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do cronograma contabil                      ³±±
±±³          ³ aExp02 - Array com os cronogramas contabeis selecionados    ³±±
±±³          ³ aExp03 - Array com os totais dos cronogramas contabeis      ³±±
±±³          ³ aExp04 - Parcelas dos cronogramas contabeis                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VldCtb(cCtbCron,aCronCtb,aTotCtb,aItensCtb)
Local lRet := .T.
Local nPos := aScan(aCronCtb,cCtbCron)
Local nx

If nTotPlan != nTotCronog
	Help("CNTA140",1,"CNTA140_11")//"O montante do cronograma deve ser igual ao montante da planilha"
	lRet := .F.
Else
	If nPos > 0            
		aTotCtb[nPos,3] := nTotCronog
		aItensCtb[nPos] := oGetCtb:aCols	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida saldo de todos os cronograma                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 to len(aCronCtb)
		If aTotCtb[nX,3] != aTotCtb[nX,4]
			Aviso("CNTA140",STR0093+aCronCtb[nX]+STR0094,{"OK"})//"O cronograma "##" possui saldo a ser distribuído"
			lRet := .F.
			Exit
		EndIf
	Next
EndIf

oWizard:NPanel := 15  //Segue para painel final

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140AjuDt  ³ Autor ³ Marcelo Custodio      ³ Data ³23.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Corrige as datas das planilhas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140AjuDt(cExp01,cExp02,dExp03,dExp04,lExp05)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do contrato                                   ³±±
±±³          ³cExp02 - Codigo da revisao                                    ³±±
±±³          ³dExp03 - Data fim original do contrato                        ³±±
±±³          ³dExp04 - Data fim atual do contrato                           ³±±
±±³          ³lExp05 - Informa se o contrato possui medicao eventual        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140AjuDt(cContra,cNRevisa,dFContra,dFAtu,lMedeve)
Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local cAlias2 := ""

If lMedeve //Medicao eventual
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona as planilhas que possuirem vigencia igual ao contrato  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNA.R_E_C_N_O_ AS RECNO "
	cQuery += "  FROM "+RetSQLName("CNA")+" CNA "
	cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
	cQuery += "   AND CNA.CNA_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNA.CNA_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNA.CNA_DTFIM  = '"+DTOS(dFContra)+"'"
	cQuery += "   AND CNA.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlias, .F., .F. )
	
	While !( cAlias )->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza data final da planilha  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CNA->( dbGoto( (cAlias)->RECNO ) )
		RecLock("CNA",.F.)
			CNA->CNA_DTFIM := dFAtu
		MsUnlock()
		(cAlias)->(dbSkip())
	EndDo
Else//Contrato com cronograma
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona maior data dos cronogramas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNF.CNF_NUMERO,MAX(CNF.CNF_PRUMED) AS CNF_PRUMED "
	cQuery += "  FROM "+RetSQLName("CNF")+" CNF "
	cQuery += " WHERE CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
	cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNF.CNF_REVISA = '"+cNRevisa+"'"
	cQuery += "   AND CNF.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY CNF.CNF_FILIAL, CNF.CNF_CONTRA, CNF.CNF_REVISA, CNF.CNF_NUMERO"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlias, .F., .F. )
	
	TCSetField(cAlias,"CNF_PRUMED","D",8,0)

	cAlias2 := GetNextAlias()
	While !(cAlias)->(Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona planilha referente ao cronograma  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT CNA.R_E_C_N_O_ AS RECNO "
		cQuery += "  FROM "+RetSQLName("CNA")+" CNA "
		cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
		cQuery += "   AND CNA.CNA_CONTRA = '"+cContra+"'"
		cQuery += "   AND CNA.CNA_REVISA = '"+cNRevisa+"'"
		cQuery += "   AND CNA.CNA_CRONOG = '"+(cAlias)->CNF_NUMERO+"'"
		cQuery += "   AND CNA.D_E_L_E_T_ = ' '"		

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlias2, .F., .F. )		
		
		If !(cAlias2)->(Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona na planilha  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CNA->( dbGoto( (cAlias2)->RECNO ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica data final da planilha em relacao ao cronograma ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CNA->CNA_DTFIM < (cAlias)->CNF_PRUMED
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza data final    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("CNA",.F.)
					CNA->CNA_DTFIM := (cAlias)->CNF_PRUMED
				MsUnlock()
			EndIf
		EndIf
		
		(cAlias2)->( dbCloseArea() )
		
		(cAlias)->(dbSkip())
	EndDo
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140AtuDtFim ³ Autor ³ Felipe Bittar       ³ Data ³01/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Atualiza Data Final do Contrato de acordo com a unidade       ³±±
±±³          |de vigencia selecionada 		                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140AtuDtFim(dExp01,cExp02,dExp03			                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³dExp01 - Data de termino do contrato - referencia             ³±±
±±³          ³cExp02 - Codigo do contrato                                   ³±±
±±³          ³cExp02 - Codigo da revisao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140AtuDtFim(dFContra,cContra,cRevisa)

Local cUnVig

If oUnVig:nat == 1
	cUnVig := "1"
ElseIf oUnVig:nat == 2
	cUnVig := "2"
ElseIf oUnVig:nat == 3
	cUnVig := "3"
Else
	cUnVig := "4"
EndIf

Return CN140DtFim(@dFContra,nVgAdit,cContra,cRevisa,cUnVig)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CN140AjSX7³ Autor ³ Felipe Bittar         ³ Data ³28.10.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta gatilho de valor total de itens da planilha		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN140AjSX7()

Local aAreaAnt := GetArea()
Local aAreaSX7 := SX7->(GetArea())
Local cCampo 	:= ""
Local cSeq	 	:= "001"
Local cRegraOri := 'NoRound(M->CNB_QUANT*M->CNB_VLUNIT,TamSX3("CNB_VLTOT")[2])'
Local cRegraNew := 'If(FunName()="CNTA140",CN140Qtd(),Round(M->CNB_QUANT*M->CNB_VLUNIT,TamSX3("CNB_VLTOT")[2]))'

dbSelectArea("SX7")
dbSetOrder(1)

cCampo := "CNB_QUANT "
If dbSeek(cCampo+cSeq) .AND. AllTrim(SX7->X7_REGRA) <> cRegraNew
	RecLock("SX7",.F.)
		Replace X7_REGRA With cRegraNew
	MsUnLock()
EndIf

cCampo := "CNB_VLUNIT"
If dbSeek(cCampo+cSeq) .AND. AllTrim(SX7->X7_REGRA) == cRegraOri
	RecLock("SX7",.F.)
		Replace X7_REGRA With cRegraNew
	MsUnLock()
EndIf

RestArea(aAreaSX7)
RestArea(aAreaAnt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140ItMed 	³ Autor ³ Aline Sebrian       ³ Data ³06/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula os itens da planilha já medidos que passaram por     ³±±
±±³          ³ Revisão de Realinhamento 			   					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140ItMed(cExp01,cExp02,cExp03)			  				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³cExp01 - Codigo do contrato                                   ³±±
±±³          ³cExp02 - Codigo da revisão                                    ³±±
±±³          ³cExp03 - Codigo da planilha                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140ItMed(cContra,cRevisa,cPlanilha)
Local nTotMed     := 0
Local cQuery      := "" 
Local aAreaAnt    := GetArea()
Local aAreaCNB    := CNB->(GetArea())                

Default cContra   := ''
Default cRevisa   := ''
Default cPlanilha := ''


If !Empty(cContra)
	cQuery := "SELECT CNB.CNB_VLTOT, CNB.CNB_VLDESC "
	cQuery += "  FROM " + RetSQLName("CNB")+" CNB "
	cQuery += " WHERE CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
	cQuery += "   AND CNB.CNB_CONTRA = '"+cContra+"'"
	cQuery += "   AND "
	If !Empty(cRevisa)
		cQuery += "   CNB.CNB_REVISA = '" + cRevisa + "' AND "  
	EndIf
	If !Empty(cPlanilha)
		cQuery += "   CNB.CNB_NUMERO = '" + cPlanilha + "' AND "  
	EndIf
	cQuery += " ((CNB.CNB_SLDMED <= 0 AND CNB.CNB_VLTOTR<=0) OR (CNB.CNB_SLDMED <= 0 And CNB.CNB_VLTOTR>0)) "
	cQuery += "  AND CNB.D_E_L_E_T_ = '' "
	                                                                          	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNBQRY", .F., .F. )    
		
	TCSetField( "CNBQRY", "CNB_VLTOT", "N", TamSX3("CNB_VLTOT")[1], TamSX3("CNB_VLTOT")[2] )
			
	While CNBQRY->( !Eof() )   
		
		nTotMed+= CNBQRY->CNB_VLTOT
		CNBQRY->(dbSkip())
	EndDo

	CNBQRY->( dbCloseArea() )  
EndIf
          
               
RestArea(aAreaCNB)
RestArea(aAreaAnt)

Return nTotMed                                        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN140VrCp    ³ Autor ³ Aline Sebrian       ³ Data ³06/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o item da planilha tem cópias                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VrCp(cExp01,cExp02)				     	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³cExp01 - Codigo do contrato                                   ³±±
±±³          ³cExp02 - Codigo da revisao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140VrCp(cContra,cRevisa)
Local lCopia    := .F.
Local lDtCopia  := .F.
Local cQuery    := ""
Local cAliasCNB := GetNextAlias() 
Local nCount    := 0

cQuery := "SELECT COUNT(*),CNB.CNB_DTREAL, CNB.CNB_SLDMED "
cQuery += "  FROM "+RetSQLName("CNB")+" CNB "
cQuery += " WHERE CNB.CNB_FILIAL  = '"+xFilial("CNB")+"'"
cQuery += "   AND CNB.CNB_CONTRA  = '"+cContra+"'"
cQuery += "   AND CNB.CNB_REVISA  = '"+cRevisa+"'"
cQuery += "   AND CNB.D_E_L_E_T_ <> '*' "  
cQuery += " GROUP BY CNB.CNB_DTREAL, CNB.CNB_SLDMED "
cQuery := ChangeQuery(cQuery)  

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNB,.F.,.T.)
			
While !(cAliasCNB)->(Eof()) 
	nCount++

	If Empty((cAliasCNB)->CNB_DTREAL) .Or. (cAliasCNB)->CNB_SLDMED == 0
		lDtCopia:= .T. 
	EndIf 

	(cAliasCNB)->(dbSkip())
EndDo
(cAliasCNB)->(dbCloseArea())    

If nCount>1 .And. lDtCopia 
	lCopia := .T.
EndIf

Return lCopia       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN140VLIT ³ Autor ³ Aline Sebrian          ³ Data ³28/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao geral da planilha									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140VLIT()							     	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/      
Function CN140VLIT(aPlan,aHeaderIt,aItens)
Local lRet			:= .T.
Local lCN140VNPL	:= ExistBlock("CN140VNPL")
Local nPerc		:= 0 
Local nVlTot		:= 0
Local nVlMin		:= 0
Local nVlMax		:= 0
Local nX			:= 0
Local nY			:= 0
Local cCampoVl	:= If(cTpRev == DEF_REALI,"CNB_REALI","CNB_VLUNIT")
Local cMsg			:= ""
Local cPicture	:= PesqPict("CN9","CN9_VLINI")

//-- Valida se valor após revisão está dentro do percentual determinado por lei
If CN9->(FieldPos("CN9_CODED")) > 0 .And. !Empty(CN9->CN9_CODED) .And. CO1->(FieldPos("CO1_REFORM")) > 0
	//-- Soma valor total de todos os itens das planilhas revisadas

	For nY := 1 To Len(aItens)
		aEval(aItens[nY],{|z| nVlTot += z[GDFieldPos(cCampoVl,aHeaderIt)] * z[GDFieldPos("CNB_QUANT",aHeaderIt)]})
	Next nY	

	CNA->(dbSetOrder(1))
	CNA->(dbSeek(xFilial("CNA")+CN9->(CN9_NUMERO+CN9_REVISA)))
	While !CNA->(EOF()) .And. CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA) == xFilial("CNA")+CN9->(CN9_NUMERO+CN9_REVISA)
		If aScan(aPlan,{|x| x[1] == CNA->CNA_NUMERO}) == 0
			nVlTot += CNA->CNA_VLTOT
		EndIf
		CNA->(dbSkip())
	End

	//-- Posiciona no edital para ver qual a regra
	CO1->(dbSetOrder(1))
	CO1->(dbSeek(xFilial("CO1")+CN9->(CN9_CODED+CN9_NUMPR)))	
	If CO1->CO1_REFORM == "1" //-- Reformas: 50%
		nPerc := 0.50
		cMsg  := STR0150
	ElseIf CO1->CO1_REFORM == "2" //-- Obras e servicos: 25%
		nPerc := 0.25
		cMsg  := STR0149
	EndIf
	
	BeginSQL Alias "TMPREAJ"
		SELECT SUM(CN9_VLREAJ) TOTREAJ, SUM(CN9_VLADIT) TOTADIT
		FROM %Table:CN9% CN9
		JOIN %Table:CN0% CN0 ON
			CN0.%NotDel% AND 
			CN0.CN0_FILIAL = %xFilial:CN0% AND 
			CN0.CN0_CODIGO = CN9.CN9_TIPREV AND ( CN0_TIPO = '1' OR CN0_TIPO = '2' )
		WHERE CN9.%NotDel% AND 
			CN9.CN9_FILIAL = %xFilial:CN9% AND
			CN9_NUMERO = %Exp:CN9->CN9_NUMERO% AND
			CN9_REVATU = ' '
	EndSQL  
	GetLastQuery()
	
	nVlMax := (CN9->CN9_VLINI + TMPREAJ->TOTREAJ + TMPREAJ->TOTADIT) * (1+nPerc) 
	nVlMin := (CN9->CN9_VLINI + TMPREAJ->TOTREAJ + TMPREAJ->TOTADIT) * (1-nPerc)
	
	If nVlTot > nVlMax .Or. nVlTot < nVlMin
		//-- "Conforme Artigo 65 Parágrafo 1o da Lei 8.666; # não poderão sofrer acréscimos ou supressões superiores à #% do valor inicial do contrato. O valor total tem que ser entre R$ " ## " até R$."
		Aviso("EDITAL",cMsg +LTrim(Transform(nVlMin,cPicture)) +STR0151 +LTrim(Transform(nVlMax,cPicture)) +".",{"OK"},2)
		lRet := .F.
	EndIf	 
	
	TMPREAJ->(dbCloseArea())

EndIf

If lRet .And. lCN140VNPL
   lRet := ExecBlock("CN140VNPL", .F., .F.)
EndIf

Return lRet
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140RevMed ³ Autor ³ Aline Sebrian	      ³ Data ³11.12.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera copia das medicoes de contrato                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN140RevMed(cExp01,cExp02,cExp03)  							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato seleciona                        ³±±
±±³          ³ cExp02 - Codigo da revisao selecionada                       ³±±
±±³          ³ cExp03 - Codigo da revisao gerada                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140RevMed(cContra,cRevisa,cNRevisa)
Local nX       := 0
Local nZ       := 0
Local nMemo    := 0

Local aAreaCN9 := {}  
Local aMemos   := {}
Local aStruCND := {}
Local aStruCNE := {}  

Local cAlias   := ""
Local cField   := ""  
Local lCnRevMd := SuperGetMV("MV_CNREVMD",.F.,.T.)
                      
If lCnRevMd                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando em alteracao                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRevisad
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza variavel de revisao, para a revisao gerada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaCN9 := CN9->(GetArea())
		dbSelectArea("CN9")
		dbSetOrder(1)
		If dbSeek(xFilial("CN9")+cContra+cRevisa) .And. !Empty(CN9->CN9_REVATU)
			cNRevisa := CN9->CN9_REVATU
		EndIf
		RestArea(aAreaCN9)
		cQuery := "SELECT CND.CND_NUMMED,CND.R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("CND")+" CND "
		cQuery += " WHERE CND.CND_FILIAL = '"+xFilial("CND")+"'"
		cQuery += "   AND CND.CND_CONTRA = '"+cContra+"'"
		cQuery += "   AND CND.CND_REVISA = '"+cNRevisa+"'"
		cQuery += "   AND CND.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNDTMP", .F., .F. )    
		      
		dbSelectArea("CND")	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui medicao                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !CNDTMP->(Eof()) 
			CND->(dbGoTo(CNDTMP->RECNO))
			RecLock("CND",.F.)
				dbDelete()
			MsUnlock()
				          
			cQuery := "SELECT CNE.R_E_C_N_O_ as RECNO "
			cQuery += "  FROM "+RetSQLName("CNE")+" CNE "
			cQuery += " WHERE CNE.CNE_FILIAL = '"+xFilial("CNE")+"'"
			cQuery += "   AND CNE.CNE_CONTRA = '"+cContra+"'"                
			cQuery += "   AND CNE.CNE_REVISA = '"+cNRevisa+"'"
			cQuery += "   AND CNE.CNE_NUMMED = '"+CNDTMP->CND_NUMMED +"'"
			cQuery += "   AND CNE.D_E_L_E_T_ = ' '"
		
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNETMP", .F., .F. )    
		      
			dbSelectArea("CNE")	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui item da Medição           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !CNETMP->(Eof()) 
				CNE->(dbGoTo(CNETMP->RECNO))
				RecLock("CNE",.F.)
					dbDelete()
				MsUnlock()
				CNETMP->(dbSkip())
			EndDo
			CNETMP->(dbCloseArea())	   
				
			CNDTMP->(dbSkip())
		EndDo
	
		CNDTMP->(dbCloseArea())
	EndIf
	
	cQuery := "SELECT CND.*,CND.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("CND")+" CND "
	cQuery += " WHERE CND.CND_FILIAL = '"+xFilial("CND")+"'"
	cQuery += "   AND CND.CND_CONTRA = '"+cContra+"'"
	cQuery += "   AND CND.CND_REVISA = '"+cRevisa+"'"
	cQuery += "   AND CND.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNDTMP", .F., .F. )    
	      
	dbSelectArea("CND")	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Revisão da Medição                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !CNDTMP->(Eof())   

		CND->(dbGoto(CNDTMP->RECNO))
		aStruCND := CND->(dbStruct())        
		
		//Obtem conteudo dos campos do tipo memo			
		For nZ:=1 to len(aStruCND)  	
			If aStruCND[nZ][2]=="M" 
				Aadd(aMemos,{aStruCND[nZ][1],&("CND->"+(aStruCND[nZ][1]))}) 
			EndIf	
		Next      
			
		RecLock("CND",.T.)
			For nx:=1 to CND->(FCount())    
				cField := FieldName(nX)     
				If  Type("CNDTMP->"+cField)!= "U" 
					FieldPut(nx,CNDTMP->&(CND->( FieldName(nX) )))    
				EndIf      
                
				//Grava conteudo dos campos do tipo memo
				If  Type("CND->"+cField)== "M"  
					nMemo:= aScan(aMemos,{|x| x[1]==FieldName(nX)})   
					If nMemo>0
						FieldPut(nx,aMemos[nMemo][2])
					EndIf
				EndIf
			Next
			CND->CND_REVISA := cNRevisa
		MsUnlock()  
	    aMemos := {}
	
		cQuery := "SELECT CNE.*,CNE.R_E_C_N_O_ as RECNO "
		cQuery += "  FROM "+RetSQLName("CNE")+" CNE "
		cQuery += " WHERE CNE.CNE_FILIAL = '"+xFilial("CNE")+"'"
		cQuery += "   AND CNE.CNE_CONTRA = '"+cContra+"'"
		cQuery += "   AND CNE.CNE_REVISA = '"+cRevisa+"'"
		cQuery += "   AND CNE.CNE_NUMMED = '"+CNDTMP->CND_NUMMED+"'"
		cQuery += "   AND CNE.D_E_L_E_T_ = ' '"
	
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "CNETMP", .F., .F. )    
	      
		dbSelectArea("CNE")	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Revisão do item da Medição            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !CNETMP->(Eof())  
			CNE->(dbGoto(CNETMP->RECNO))
			aStruCNE := CNE->(dbStruct())     
			
			//Obtem conteudo dos campos do tipo memo			
			For nZ:=1 to len(aStruCNE)  	
				If aStruCNE[nZ][2]=="M" 
					Aadd(aMemos,{aStruCNE[nZ][1],&("CNE->"+(aStruCNE[nZ][1]))}) 
				EndIf	
			Next   
			
			RecLock("CNE",.T.)	
				For nx:=1 to CNE->(FCount())  
					cField := FieldName(nX)     
					If  Type("CNETMP->"+cField)!= "U" 
						FieldPut(nx,CNETMP->&(CNE->( FieldName(nX) )))
					EndIf    
					
					//Grava conteudo dos campos do tipo memo
					If  Type("CNE->"+cField)== "M"  
						nMemo:= aScan(aMemos,{|x| x[1]==FieldName(nX)})   
						If nMemo>0
							FieldPut(nx,aMemos[nMemo][2])
						EndIf
					EndIf	
				Next
			 	CNE->CNE_REVISA := cNRevisa
			MsUnlock()       
			aMemos:= {}	
			
			CNETMP->(dbSkip())
		EndDo
		CNETMP->(dbCloseArea())	   
		
				
		CNDTMP->(dbSkip())
	EndDo
	CNDTMP->(dbCloseArea())	
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AjustaSX1  ³ Autor ³ Aline Sebrian         ³ Data ³13/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Configura as perguntas na rotina da planilha do contrato    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustaSX1()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX1()
Local aAreaAnt := GetArea()       

PutHelp("PCNTA140_19",{"Não há planilha para o contrato  "," selecionado com opção de Reajuste."},;   			      
			 		  {"No worksheet for the contract    "," selected with Readjust opcion."},;    
  					  {"No hay planilla para el contrato "," seleccionado con opción del Reajuste."},.F.)
	
PutHelp("SCNTA140_19",{"Verificar a planilha deste      ","contrato."},;
	    	          {"Check the worksheet of this     ","contract."},;
                      {"Verifique el planilha del       ","contrato."},.F.)	  
                      
PutHelp("PCNTA140_20",{"O contrato selecionado no browser","não está disponível para a Revisão    ","selecionada."},;
	   			      {"The selected contract on the     ","browser isn't available for the       ","selected Revision."},;
			 		  {"El contracto seleccionado en     ","browser no estas disponible para el   ","Revision seleccionada."},.F.)  
	
PutHelp("SCNTA140_20",{"Selecione através do browser o  ","contrato apropriado para a revisão    ","selecionada."},;
	    	          {"Select through of browser the   ","appropried contract for to selected   ","Revision."},;
                      {"Seleccione a traves del browser ","el conctracto atribuido para el       "," Revision seleccionada."},.F.)

PutHelp("PCNTA140_24",{"Preencha a data de referência do","reajuste."},;
	   			      {"Fill in the adjustment reference","date."},;
			 		  {"Rellene la fecha de referência","del reajuste."},.F.)  

RestArea(aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN140QTD   ³ Autor ³Aline Sebrian  		 ³Data  ³03/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar a Valor Total do Item de acordo com a quantidade. ³±±
±±³			 ³ Chamada pelo gatilho do campo CNB_VLTOT.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN140QTD()
Local nPosVlUn := 0
Local nPlanVlT := 0   
Local nPosQtd  := 0
Local nValor   := 0   
Local lRotAuto := Type("lMsHelpAuto") == "L" .And. lMsHelpAuto 

If !lRotAuto   
	nPosVlUn := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_VLUNIT"})    
	nPosQtd  := aScan(oGetDad1:aHeader,{|x| x[2] == "CNB_QUANT"}) 
	nPlanVlT := Posicione("CNA",1,xFilial("CNA")+cContra+cRevAtu,"CNA_VLTOT")
	If (nPlanVlT-Round(ogetDad1:aCols[oGetDad1:nAt][nPosQtd]*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn],2))>0 .And. (nPlanVlT-Round(ogetDad1:aCols[oGetDad1:nAt][nPosQtd]*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn],2))<=0.01
		nValor := Round(ogetDad1:aCols[oGetDad1:nAt][nPosQtd]*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn],2)+nPlanVlT-Round(M->CNB_QUANT*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn],2)
	Else
	    nValor := Round(ogetDad1:aCols[oGetDad1:nAt][nPosQtd]*ogetDad1:aCols[oGetDad1:nAt][nPosVlUn],2)
	EndIf
EndIf


Return nValor  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN140PrEnt ³ Autor ³Aline Sebrian  		 ³Data  ³17/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a parcela do cronograma ja foi entregue.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato seleciona                      ³±±
±±³          ³ cExp02 - Codigo da revisao selecionada                     ³±±
±±³          ³ cExp03 - Competencia da parcela                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function CN140PrEnt(cContra,cRevisa,lRealMed,cCompet,cItem)	 
Local aAreaCN9 := CN9->(GetArea())
Local aAreaCND := CND->(GetArea())

Local cQuery:= ""
Local nQtdEnt := 0   
Local cEspCtr := Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_ESPCTR")

If lRealMed
	If cEspCtr == "1"
		cQuery += " SELECT SUM(SC7.C7_QUJE) AS QUANT     "
		cQuery += "   FROM "+ RetSQLName("SC7") +" SC7, "+ RetSQLName("CND") +" CND   "
		cQuery += "  WHERE CND.CND_FILIAL = '"+xFilial("CND")+"' " 
		cQuery += "    AND SC7.C7_FILIAL  = '"+xFilial("SC7")+"' " 
		cQuery += "    AND CND.CND_CONTRA = '"+cContra+"'"                  
		cQuery += "    AND CND.CND_REVISA = '"+cRevisa+"'"
		cQuery += "    AND CND.CND_COMPET = '"+cCompet+"'"
		cQuery += "    AND SC7.C7_MEDICAO = CND.CND_NUMMED" 
		cQuery += "    AND SC7.C7_ITEM    = '"+cItem  +"' "
		cQuery += "    AND SC7.D_E_L_E_T_ = ' '" 
	Else
		cQuery := " SELECT SUM(SC6.C6_QTDENT) AS QUANT "
		cQuery += "   FROM "+ RetSQLName("SC5") +" SC5, "+ RetSQLName("SC6") +" SC6, "+ RetSQLName("CND") +" CND   "
		cQuery += "  WHERE CND.CND_FILIAL = '"+xFilial("CND")+"' " 
		cQuery += "    AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"' " 
		cQuery += "    AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"' " 
		cQuery += "    AND CND.CND_CONTRA = '"+cContra+"'"             
		cQuery += "    AND CND.CND_REVISA = '"+cRevisa+"'"
		cQuery += "    AND CND.CND_COMPET = '"+cCompet+"'"
		cQuery += "    AND SC5.C5_MDNUMED = CND.CND_NUMMED "
		cQuery += "    AND SC5.C5_NUM     = SC6.C6_NUM "
		cQuery += "    AND SC6.C6_ITEMED  = '"+cItem  +"' "
		cQuery += "    AND SC5.D_E_L_E_T_ = ' ' " 
		cQuery += "    AND SC6.D_E_L_E_T_ = ' ' "
	EndIf      

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCND",.F.,.T.)       
	While !TRBCND->(Eof())
		nQtdEnt += TRBCND->QUANT 
		TRBCND->(dbSkip())
	EndDo
	TRBCND->(dbCloseArea())
	
EndIf

RestArea(aAreaCND)
RestArea(aAreaCN9)
Return nQtdEnt


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140MntCron³ Autor ³ Aline S Damasceno   ³ Data ³08/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Cronogramas de acordo com as planilhas selecionadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140LCron(cExp01,cExp02,aExp01)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ -cExp01 - Codigo do Contrato                               ³±±
±±³          ³ -cExp02 - Codigo da Revisao                                ³±±
±±³          ³ -aExp01 - Array com as planilhas selecionadas	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140MntCron(cContra,cRevisa,aPlan)
Local cQuery := ""     
Local lRet   := .T.          
Local nX     := 0
Local aArea := GetArea()  

dbSelectArea("TRBCNF")
If RecCount() > 0
	Zap	
Endif
		
For nX:= 1 To Len(aPlan)      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra cronogramas do contrato                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CNF.CNF_FILIAL, CNF.CNF_NUMERO, CNF.CNF_CONTRA, CNF.CNF_REVISA, "
	cQuery += "       Min(CNF.CNF_COMPET) as CNF_COMPET, Sum(CNF.CNF_SALDO) as CNF_SALDO "
	cQuery += "  FROM "+RetSqlName("CNF")+" CNF "
	cQuery += " WHERE CNF.CNF_FILIAL =  '"+xFilial("CNF")+"'"
	cQuery += "   AND CNF.CNF_CONTRA = '"+cContra+"'"
	cQuery += "   AND CNF.CNF_REVISA = '"+cRevisa+"'"
	cQuery += "   AND CNF.CNF_NUMERO = '"+aPlan[nX][4]+"'"
	cQuery += "   AND CNF.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY CNF.CNF_FILIAL, CNF.CNF_NUMERO, CNF.CNF_CONTRA, CNF.CNF_REVISA"
	  
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
	
	//Configura campos especificos
	TCSetField("TRB","CNF_SALDO" ,"N",TamSX3("CNF_SALDO")[1],TamSX3("CNF_SALDO")[2])
	
	dbSelectArea("TRB")
	dbGoTop()
		
	If !Eof()
			 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Copia cronogramas para arquivo temporario           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("TRB")
		While !Eof()    
			RecLock("TRBCNF",.T.)
				TRBCNF->CNF_NUMERO := TRB->CNF_NUMERO
				TRBCNF->CNF_CONTRA := TRB->CNF_CONTRA
				TRBCNF->CNF_REVISA := TRB->CNF_REVISA
				TRBCNF->CNF_COMPET := TRB->CNF_COMPET
				TRBCNF->CNF_SALDO  := TRB->CNF_SALDO
			MsUnlock()      
		
			dbSelectArea("TRB")
			dbSkip()
		Enddo
		
		TRBCNF->(dbGoTop())	
	Else
		Help("CNTA140",1,"CNTA140_03")//"O contrato não possui cronogramas"##"Atenção"
		lRet := .F.
	Endif
	
	TRB->(dbCloseArea())  
Next nX 

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |CN140Fisico ³ Autor ³ Aline S Damasceno     ³ Data ³16.06.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina responsavel pelo cronograma fisico de cada parcela     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN140Fisico(nExp01,aExp02,nExp03,aExp04,aExp05,aExp06)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao atual                                         ³±±
±±³          ³ aExp02 - Array com as parcelas financeiras do cronograma     ³±±
±±³          ³ nExp03 - Parcela atual                                       ³±±
±±³          ³ aExp04 - Array contendo os itens do cronograma fisico        ³±±
±±³          ³ aExp05 - Array contento o cabecalho do cronograma fisico     ³±±
±±³          ³ aExp06 - Array contendo os valores e quantidades dos itens   ³±±
±±³          ³          do cronograma ficiso (planilha)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA110                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN140Fisico(nOpc,aCols,nAt,aColsParc,aHeadParc,aItVl,cCodTR)

Local oDlg                
Local ogetFsc

Local nOpca      := 2  

Local aCpo       := {"CNS_PRVQTD"}
Local aTotQtd    := {}
Local aCN110CPO  := {}       
Local aAux       := {}
Local aItAux     := {}

Local nx         := 0
Local ny         := 0          
Local nCount     := 0          
Local nPosItm    := aScan(aHeadParc,{|x| AllTrim(x[2])=="CNS_ITEM"})
Local nPosQtd    := aScan(aHeadParc,{|x| AllTrim(x[2])=="CNS_PRVQTD"})
Local nPosSld    := aScan(aHeadParc,{|x| AllTrim(x[2])=="CNS_DISTSL"})
Local nPosRlz    := aScan(aHeadParc,{|x| AllTrim(x[2])=="CNS_RLZQTD"})
Local nPosItOr   := aScan(aHeadParc,{|x| AllTrim(x[2])=="CNS_ITOR"})  
Local nPosSlz    := aScan(aHeadParc,{|x| AllTrim(x[2])=="CNS_SLDQTD"})
Local nPosVlPrv  := aScan(aHeader,{|x| AllTrim(x[2])=="CNF_VLPREV"})
Local nPosSaldo  := aScan(aHeader,{|x| AllTrim(x[2])=="CNF_SALDO"})
Local nPosVlRlz  := aScan(aHeader,{|x| AllTrim(x[2])=="CNF_VLREAL"})
Local nDifFsc    := 0
Local nTotParc   := 0
Local nTotalDec  := TamSx3("CNF_VLPREV")[2]
Local nTotUltima := 0    
Local nDesc      := 0

Local cTpRev     := ""
Local cEspCtr    := ""

Local lDifFsc    := .T.

Default cCodTR     := ""
cTpRev     := Posicione("CN0",1,xFilial("CN0")+cCodTR,"CN0_TIPO")   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do aColsParc                                               ³
//³-aColsParc[1]       - aCols do cronograma fisico da parcela 01       ³
//³--aColsParc[1,1]    - primeiro item da parcela 01                    ³
//³---aColsParc[1,1,1] - primeiro campo do primeiro item da parcela 01  ³
//³-aColsParc[2]       - aCols do cronograma fisico da parcela 02       ³
//³--aColsParc[2,1]    - primeiro item da parcela 02                    ³
//³---aColsParc[2,1,1] - primeiro campo do primeiro item da parcela 02  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do aItVl                                           ³
//³-aItVl[1]    - Primeiro item da planilha                     ³
//³--aItVl[1,1] - Valor do item na planilha                     ³
//³--aItVl[1,2] - Quantidade total na planilha                  ³
//³--aItVl[1,3] - Quantidade a distribuir no cronograma fisico  ³
//³--aItVl[1,4] - Item da planilha								³
//³--aItVl[1,5] - Valor original do item da planilha			³
//³--aItVl[1,6] - Quantidade original do item da planilha		³
//³--aItVl[1,7] - Valor de Desconto do item da planilha   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE oTotFsc
PRIVATE nTotFsc:=0             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que permite definir os campos da tabela CNS para       ³
//³edição na getdados do Cronograma Físico								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN110CPO")
	aCN110CPO := ExecBlock("CN110CPO",.F.,.F.,{aCpo})
	If ( ValType(aCN110CPO) == "A" )
		aCpo := aCN110CPO
	EndIf
EndIf

If CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA) # xFilial("CN9")+cContra+cRevAtu 
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9")+cContra+cRevAtu))
EndIf
If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf                                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula total da parcela            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx:=1 to len(aColsParc[nat])       
	If cEspCtr == "2"
		nDesc := cn140Desc(aItVl[nx,1],aItVl[nx,7],aColsParc[nat,nx,nPosQtd])   
	Else
		nDesc := a410Arred((((aColsParc[nat,nx,nPosQtd]*aItVl[nx,1])*aItVl[nx,7])/100),"CNB_VLDESC")    
	EndIf
	aColsParc[nat,nx,nPosSld] := aItVl[nx,3] 
	nTotFsc += (aColsParc[nat,nx,nPosQtd]*aItVl[nx,1])-nDesc
	aAdd(aTotQtd, 0)
Next

nTotFsc := Round(nTotFsc,nTotalDec)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for a ultima parcela, deve somar a diferenca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nAt == Len(aCols))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o total das parcelas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotParc := 0
	For nx := 1 to Len(aColsParc)
		For ny := 1 to Len(aColsParc[nx]) 
			If cEspCtr == "2"
				nDesc := cn140Desc(aItVl[ny,1],aItVl[ny,7],aColsParc[nx,ny,nPosQtd])   
			Else
				nDesc := a410Arred((((aColsParc[nX,nY,nPosQtd]*aItVl[ny,1])*aItVl[ny,7])/100),"CNB_VLDESC")
			EndIf
			
			nTotParc += Round((aColsParc[nx,ny,nPosQtd]*aItVl[ny,1])-nDesc,nTotalDec)
			aTotQtd[ny] += aColsParc[nx,ny,nPosQtd]
		Next ny		
	Next nx
	
	For nx := 1 to Len(aItVl)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se algum item esta com quantidade diferente da qtde. original da planilha. ³
		//³ Se estiver, entao nao devemos adicionar a diferenca pois o calculo deve respeitar   ³
		//³ a quantidade informada pelo usuario.                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (aItVl[nx,3]+aItVl[nx,2]) != aTotQtd[nx]
			lDifFsc := .F.
			Exit
		EndIf
	Next nx
	
	If lDifFsc
		nDifFsc := nTotPlan - nTotParc
		nTotFsc += nDifFsc
	EndIf
EndIf                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove os itens já medidos em historico do array.³
//³para nao exibi-los no dialog .                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CNS->(FieldPos("CNS_ITOR")) > 0  
	nX:=1        
	While nx <= Len(aColsParc) 
		nY   := 1       
		nCount:= 1
		While ny <= Len(aColsParc[nx])
			If !Empty(aColsParc[nx,ny,nPosItOr])         				
				aAdd(aAux,{})
				aAdd(aAux[nX],Array(len(aHeadParc)+1))
	 			aAux[nx,nCount] = aClone(aColsParc[nx,ny])    
	 			
			    aDel(aColsParc[nX],nY) 
			    aSize(aColsParc[nX],len(aColsParc[nX])-1) 	    
			    nCount++ 
			    ny--			 
			EndIf             
			ny++
		Enddo   
		nX++
	Enddo    
	                  
	If Len(aAux)>0
		nX:=1 
		While nx<= len(aAux[nat])         
  		  	If !Empty(aAux[nat,nx,nPosItOr])
				Aadd(aItAux,{})
				aItAux[nx] = aClone(aItVl[nx])
				
			    aDel(aItVl,nx) 
			    aSize(aItVl,len(aItVl)-1) 	   	
			EndIf 
			nX++
		EndDo   
	EndIf

EndIf
                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Dialog                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0135) FROM 009,000 TO 025,060 OF oMainWnd//"Cronograma Fisico"

@ 002,110 GROUP oGroup To 020,145 Label OemToAnsi(STR0136) Of oDlg PIXEL//"Parcela"
@ 008,130 Say oParc Var aCols[nat,1] Size 040,050 Picture PesqPict("CNF","CNF_PARCEL") Of oDlg PIXEL

@ 002,150 GROUP oGroup To 020,232 Label OemToAnsi(STR0137) Of oDlg PIXEL//"Total"
@ 008,190 Say oTotFsc Var nTotFsc Size 110,008 Picture PesqPict("CNF","CNF_VLPREV") Of oDlg PIXEL

ogetFsc := MsNewGetDados():New(022,005,100,232,IIF(nOpc==2 .OR. nOpc==5,0,GD_UPDATE),,,,aCpo,,,,,,oDlg,aHeadParc,aColsParc[nat])

DEFINE SBUTTON FROM 105, 173 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 105, 203 TYPE 2 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os itens já medidos em historico do array. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CNS->(FieldPos("CNS_ITOR")) > 0  
		If Len(aAux)>0
			For nx:=1 to len(aAux)
				For ny:=1 to len(aAux[nX])
					aadd(aColsParc[nX],aaux[nx,nY])
		   		    aSort(aColsParc[nX],,,{|x,y| x[nPosItm] < y[nPosItm]})
				Next
			Next   
			
			For nx:=1 to len(aAux[nat])
				aadd(ogetFsc:aCols,aaux[nat,nX])	
				aSort(ogetFsc:aCols,,,{|x,y| x[nPosItm] < y[nPosItm]})
			Next  
			
	        For nx:=1 to len(aItAux)
				aadd(aItVl,aItAux[nX]) 
				aSort(aItVl,,,{|x,y| x[4] < y[4]})
			Next
		EndIf		
	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula total da parcela e soma no cronograma financeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotQtd  := {}
	nTotParc := 0
	For nx:=1 to len(ogetFsc:aCols)        
		If cEspCtr == "2"
			nDesc := cn140Desc(aItVl[nx,1],aItVl[nx,7],oGetFsc:aCols[nx,nPosQtd])
		Else
			nDesc := a410Arred(((oGetFsc:aCols[nx,nPosQtd]*aItVl[nx,1]) * aItVl[nx,7] )/100,"CNB_VLDESC")
		EndIf
			
		aItVl[nx,3]          := ogetFsc:aCols[nx,nPosSld] 
  		nTotParc             +=(oGetFsc:aCols[nx,nPosQtd]*aItVl[nx,1])-nDesc
		aAdd(aTotQtd, oGetFsc:aCols[nx,nPosQtd])	 
		
		If cTpRev==DEF_REALI 
			If  aItVl[nx,1]==0     //Item com realinhamento ja aprovado
				nTotParc    += Round((oGetFsc:aCols[nx,nPosRlz]*aItVl[nx,5])-nDesc,nTotalDec)  
			EndIf       
		
			If Empty(aItAux) .And. oGetFsc:aCols[nx,nPosRlz]>0 .And. aItVl[nx,1]>0   //Redistribuicao do cronograma na revisao de realinhamento
				nTotParc      -= Round((oGetFsc:aCols[nx,nPosQtd]*aItVl[nx,1])-nDesc,nTotalDec) 
				nTotParc      += Round((oGetFsc:aCols[nx,nPosSlz]*aItVl[nx,1])-nDesc,nTotalDec)  
				nTotParc      += Round((oGetFsc:aCols[nx,nPosRlz]*aItVl[nx,5])-nDesc,nTotalDec)   
			EndIf		
			If oGetFsc:aCols[nx,nPosRlz]==0 .And. aItVl[nx,1]==0  //Realinhamento do cronograma se item não foi selecionado
		   		nTotParc      += Round((oGetFsc:aCols[nx,nPosQtd]*aItVl[nx,5])-nDesc,nTotalDec)  
			EndIf
		EndIf
	Next   
	nTotParc := Round(nTotParc,nTotalDec)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zera o saldo financeiro da parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
	If nTotParc > 0
		aCols[nat,nPosVlPrv] := nTotParc
		aCols[nat,nPosSaldo] := 0
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somar a diferenca na ultima parcela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotParc   := aCols[nat,nPosVlPrv]
	nTotUltima := 0
	For nx := 1 to Len(aColsParc)
		For ny := 1 to Len(aColsParc[nx])  
			If cEspCtr == "2"
				nDesc := cn140Desc(aItVl[nY,1],aItVl[nY,7],oGetFsc:aCols[ny,nPosQtd])
			Else
				nDesc :=a410Arred((((oGetFsc:aCols[ny,nPosQtd]*aItVl[nY,1])*aItVl[nY,7])/100),"CNB_VLDESC")
			EndIf
		                                                   
			//Obtem o total da parcel			                                      
			nTotParc    +=(oGetFsc:aCols[ny,nPosQtd]*aItVl[ny,1])-nDesc
			aTotQtd[ny] += oGetFsc:aCols[ny,nPosQtd]
			
			// Obtem o valor da ultima parcela     
			If nx == Len(aColsParc)
				nTotUltima +=(oGetFsc:aCols[ny,nPosQtd]*aItVl[ny,1])-nDesc						
			EndIf
		Next ny
		nTotParc :=  Round(nTotParc,nTotalDec) 
	Next nx
	nTotUltima :=  Round(nTotUltima,nTotalDec)     

	lDifFsc  := .T.
	For nx := 1 to Len(aItVl)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se algum item esta com quantidade diferente da qtde. original da planilha. ³
		//³ Se estiver, entao nao devemos adicionar a diferenca pois o calculo deve respeitar   ³
		//³ a quantidade informada pelo usuario.                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aItVl[nx,2] != aTotQtd[nx]
			lDifFsc := .F.
			Exit
		EndIf
	Next nx
	
	If lDifFsc
		nDifFsc := nTotPlan - nTotParc
		If nAt != Len(aCols) .And. nDifFsc > 0
			aCols[Len(aCols),nPosVlPrv] := nTotUltima + nDifFsc
			aCols[Len(aCols),nPosSaldo] := aCols[Len(aCols),3]
		Else
			aCols[nAt,3] += nDifFsc
		EndIf
	EndIf
	   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza array com os itens fisicos   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	aColsParc[nat] := ogetFsc:aCols

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para tratamento especifico    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If ExistBlock("CN110CRF")
		aCN110CRF := ExecBlock("CN110CRF",.F.,.F.,{aHeader,aCols,aHeadParc,aColsParc})
		If Valtype(aCN110CRF) == "A"
			If Len(aCN110CRF)>=1 .And. Valtype(aCN110CRF[1]) == "A"
				aHeader   := aClone(aCN110CRF[1])
			EndIf
			If Len(aCN110CRF)>=2 .And. Valtype(aCN110CRF[2]) == "A"
				aCols     := aClone(aCN110CRF[2])
			EndIf	 
			If Len(aCN110CRF)>=3 .And. Valtype(aCN110CRF[3]) == "A"
				aHeadParc := aClone(aCN110CRF[3])
			EndIf	
			If Len(aCN110CRF)>=4 .And. Valtype(aCN110CRF[4]) == "A"
				aColsParc := aClone(aCN110CRF[4])
			EndIf			
		EndIf
	EndIf     
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os itens já medidos em historico do array. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CNS->(FieldPos("CNS_ITOR")) > 0  
		If Len(aAux)>0
			For nx:=1 to len(aAux)
				For ny:=1 to len(aAux[nX])
					aadd(aColsParc[nX],aaux[nx,nY])
		   		    aSort(aColsParc[nX],,,{|x,y| x[nPosItm] < y[nPosItm]})
				Next
			Next   
			
			For nx:=1 to len(aAux[nat])
				aadd(ogetFsc:aCols,aaux[nat,nX])	
				aSort(ogetFsc:aCols,,,{|x,y| x[nPosItm] < y[nPosItm]})
			Next  
			
	        For nx:=1 to len(aItAux)
				aadd(aItVl,aItAux[nX]) 
				aSort(aItVl,,,{|x,y| x[4] < y[4]})
			Next
		EndIf
    EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |cn140Desc   ³ Autor ³ Aline S Damasceno     ³ Data ³17.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina responsavel pela atualização do desconto na parcela    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN140Fisico(nExp01,nExp02,nExp03) 		      				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Valor Unitario do item                              ³±±
±±³          ³ aExp02 - Valor de Desconto 									³±±
±±³          ³ nExp03 - Quantidade do Item                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA140                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function cn140Desc(nPrUnit,nDesc,nQuant)     
Local nPreco := 0
Local nTotal := 0
Local nVDesc := 0  
Local nTotItm:= 0
                                   
nDesc  := a410Arred(nDesc/nQuant,"CNB_VLUNIT")
nPreco := A410Arred(nPrUnit-nDesc,"CNB_VLUNIT")

nTotal := A410Arred(nPreco* nQuant,"CNB_VLTOT")
nTotItm:= A410Arred(nPrUnit* nQuant,"CNB_VLTOT")

nVDesc := A410Arred(nTotItm-nTotal,"CNB_VLDESC")
Return nVDesc
                       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |CN140DstCron³ Autor ³ Aline S Damasceno     ³ Data ³16.06.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Rotina responsavel em redistribuir as parcelas do cronograma  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN140DstCron(aExp01,aExp02,aExp03,aExp04,aExp05,lExp06,)      ³±±
±±³          ³             nExp07,aExp08,aExp09)    					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Parcelas do cronograma financeiro                   ³±±
±±³          ³ aExp02 - Cabeçalho das parcelas do cronograma financeiro     ³±±
±±³          ³ aExp03 - Parcelas do cronograma fisico                       ³±±
±±³          ³ aExp04 - Cabeçalho das parcelas do cronograma fisico         ³±±
±±³          ³ lExp05 - Verifica se e cronograma fisico					    ³±±
±±³          ³ nExp06 - total das parcelas									³±±  
±±³          ³ aExp07 - Estrutura dos cronogramas fisicos         			³±±     
±±³          ³ aExp08 - Array com os totalizadores dos cronogramas          ³±±
±±³          ³ aExp09 - Array com os valores aditivados das planilhas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA140                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN140DstCron(aParcelas,aHeaderCNF,aColsParc,aHeadParc,lFisico,nTotParc,aFscVl,aTotCont,aAditPlan,aArtFsc,nTotMed,nParc)
Local nX        := 0
Local nY        := 0
Local nNovParc  := 0    
Local nQtdAdtv  := 0
Local nTotProv  := 0                       
Local nQtdDist  := 0                                                                                      
Local nAcumParc := 0
                
Local nPosQtd   := {}
Local nPosSld   := {}
Local nPosRlz   := {}
Local nPosItO   := {}
Local nPosTQt   := {}    
Local nPosPrev := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_VLPREV"})
Local nPosReal := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_VLREAL"})
Local nPosSald := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_SALDO"})    
Local nPosDtRe := aScan(aHeaderCNF,{|x| AllTrim(x[2]) == "CNF_DTREAL"})    

Local nTotnMed  := aTotCont[5]+nParc
Local nSaldoCro := aTotCont[2]
Local nParnMed  := aTotCont[5]   
Local nSldDist  := 0

Local aArtAdt   := {}
Local aQtdMed   := {}
Local aArtDist  := {}     


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa arrays para controlar a distribuicao dos cronogramas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lFisico
	nPosQtd := aScan(aHeadParc,{|x| x[2]=="CNS_PRVQTD"})
	nPosSld := aScan(aHeadParc,{|x| x[2]=="CNS_SLDQTD"})
	nPosRlz := aScan(aHeadParc,{|x| x[2]=="CNS_RLZQTD"})
	nPosItO := aScan(aHeadParc,{|x| x[2]=="CNS_ITOR"})
	nPosTQt := aScan(aHeadParc,{|x| x[2]=="CNS_TOTQTD"})  
		
	aQtdMed := Array(len(aColsParc[len(aColsParc)]))								
	aArtDist:= Array(len(aColsParc[len(aColsParc)]))
	aArtAdt := Array(len(aColsParc[len(aColsParc)])) 
EndIf
			
nNovParc := nSaldoCro / nTotnMed//Divide o saldo nao medido pelas parcelas em aberto
				
For nX := 1 to len(aParcelas)
	If lFisico
		For nY:=1 to len(aColsParc[nX])
			If aColsParc[nX,nY,nPosItO] == NIL
				aColsParc[nX,nY,nPosItO] := ""
			EndIf
		Next
	EndIf
					
	if !Empty(aParcelas[nx,nPosDtRe])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retira o saldo restante das parcelas medidas         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !lFisico
			aParcelas[nX,nPosPrev] -= aParcelas[nX,nPosSald]
			nTotMed		            -= Round(aParcelas[nX,nPosSald],TamSX3("CNF_VLPREV")[2])
			aParcelas[nX,nPosSald] := 0
		Else                      			
			aParcelas[nX,nPosPrev] -= aParcelas[nX,nPosSald]
			nTotMed		            -= Round(aParcelas[nX,nPosSald],TamSX3("CNF_VLPREV")[2])
			aParcelas[nX,nPosSald] := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Soma as quantidades de arrasto                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY:=1 to len(aColsParc[nX])
				If aArtFsc[nY] == Nil
					aArtFsc[nY] := 0
				EndIf         
				
				If aQtdMed[nY] == Nil
					aQtdMed[nY] := 0
				EndIf       
								
				If aColsParc[nX,nY,nPosSld]>0 .And. aColsParc[nX,nY,nPosRlz]==0
					aArtFsc[nY] += aColsParc[nX,nY,nPosSld]
				EndIf
				
				aColsParc[nX,nY,nPosQtd] := 	aColsParc[nX,nY,nPosRlz]	
				aColsParc[nX,nY,nPosSld] := aColsParc[nX,nY,nPosQtd] - aColsParc[nX,nY,nPosRlz]	
				aArtFsc[nY] += aColsParc[nX,nY,nPosSld]
				If CNS->(FieldPos("CNS_ITOR"))>0    
					If Empty(aColsParc[nX,nY,nPosItO])	
						aColsParc[nX,nY,nPosSld] := 0									
					EndIf
				Else
					aColsParc[nX,nY,nPosQtd] := 0
					aColsParc[nX,nY,nPosSld] := 0									
				EndIf
								
				aQtdMed[nY] += aColsParc[nX,nY,nPosRlz]   						
			Next   
							
			nTotMed		            += Round(nTotParc,TamSX3("CNF_VLPREV")[2])       													
			nTotParc := 0
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incrementa o valor nas parcelas nao medidas          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParcelas[nX,nPosSald] := nNovParc
		aParcelas[nX,nPosPrev] := nNovParc
		nTotMed		           += Round(aParcelas[nX,nPosPrev],TamSX3("CNF_VLPREV")[2])
		if lFisico                      							
			For nY:=1 to len(aColsParc[nX])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma as quantidades distribuidas entre as parcelas nao     ³
				//³ medidas                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
				If aArtAdt[nY] == NIL
					aArtAdt[nY] := 0
				EndIf
								
				If aArtFsc[nY] == Nil
					aArtFsc[nY] := 0
				EndIf
								
				If aArtDist[nY] == NIL
					aArtDist[nY] := aFscVl[nY,3]
				EndIf   

				If aQtdMed[nY] == Nil
					aQtdMed[nY] := 0
				EndIf     				  
											          			 
				If nPosItO > 0					 
					If Empty(aColsParc[nX,nY,nPosItO])	  							 
				  		aArtAdt[nY] := aFscVl[nY,3]  
				  		nQtdAdtv    := ((aColsParc[nX,nY,nPosTQt]+aArtAdt[nY])-aQtdMed[nY])
				  		nQtdAdtv    := Round(nQtdAdtv/nTotnMed,TamSX3("CNS_PRVQTD")[2])  			  		       

						aColsParc[nX,nY,nPosSld] := nQtdAdtv
						aColsParc[nX,nY,nPosQtd] := nQtdAdtv   	
					Else
						aFscVl[nY,3] := 0
					EndIf									              
				Else
					nQtdDist := Round(aArtDist[nY]/nTotnMed,TamSX3("CNS_PRVQTD")[2])
					aArtFsc[nY]              -= nQtdDist
					aColsParc[nX,nY,nPosSld] += nQtdDist
					aColsParc[nX,nY,nPosQtd] += nQtdDist 
				EndIf				
			Next 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma o saldo aditivado		     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If !Empty(aAditPlan)						
				nSldDist := Round(aAditPlan[2]/nTotnMed,TamSX3("CNF_VLPREV")[2])
			EndIf                                    
				
			aParcelas[nX,nPosSald] += Round(nSldDist,TamSX3("CNF_VLPREV")[2])
			aParcelas[nX,nPosPrev] += Round(nSldDist,TamSX3("CNF_VLPREV")[2])
			aTotCont[1]            += Round(nSldDist,TamSX3("CNF_VLPREV")[2])   
			nTotMed                += Round(nSldDist,TamSX3("CNF_VLPREV")[2]) 							
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma a diferenca na ultima parcela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			For nY:=1 to len(aColsParc[nX])
  				nAcumParc += Round((aColsParc[nx,ny,nPosQtd]*aItVl[ny,1])-(((aColsParc[nX,nY,nPosQtd]*aFscVl[ny,1])*aFscVl[ny,7])/100),TamSX3("CNS_PRVQTD")[2])
	 		Next nY
							

			If Round(aParcelas[nX,nPosSald],TamSX3("CNF_VLPREV")[2]) <> Round(nAcumParc,TamSX3("CNF_VLPREV")[2])
				aColsParc[nX,len(aColsParc[nX]),nPosSld] := Round(((aColsParc[nX,len(aColsParc[nX]),nPosSld] * aFscVl[len(aColsParc[nX]),1] )+aParcelas[nX,nPosSald]-nAcumParc)/aFscVl[len(aColsParc[nX]),1] ,TamSX3("CNS_PRVQTD")[2])
				aColsParc[nX,len(aColsParc[nX]),nPosQtd] := Round(((aColsParc[nX,len(aColsParc[nX]),nPosQtd] * aFscVl[len(aColsParc[nX]),1] )+aParcelas[nX,nPosSald]-nAcumParc)/aFscVl[len(aColsParc[nX]),1] ,TamSX3("CNS_PRVQTD")[2])
			EndIf  
							
			nAcumParc := 0
		EndIf

	EndIf
Next     
				          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os valores a distribuir ja incluido nas parcelas fisicas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFisico
	For nY:= 1 To len(aFscVl)       
		aFscVl[nY,3] := 0
	Next
EndIf

If (aTotCont[1] - nTotMed) == 0.01	
	aTotCont[1]-= 0.01
EndIf    
		
If (aTotCont[1] - nTotMed) == -0.01	
	aTotCont[1]+= 0.01
EndIf
				
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140ProRev³ Autor ³ Aline S Damasceno     ³ Data ³10.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao na opcao PROSSEGUIR                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN140DelRev(cExp01,cExp02,cExp03,cExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                 ³±±
±±³          ³ cExp02 - Codigo da revisao original                         ³±±
±±³          ³ cExp03 - Codigo do tipo de revisao                          ³±± 
±±³          ³ cExp04 - Tipo de revisao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140ProRev(cContra,cRevisa,cCodTR,cTpRev)
Local cContraTR := ""   
Local cNRevisa  := ""
Local lRet      := .T.

dbSelectArea("CN9")
dbSetOrder(1)
dbSeek(xFilial("CN9")+cContra+cRevisa)//Encontra contrato original para posicionar na revisao atual   
cNRevisa  := CN9->CN9_REVATU

dbSelectArea("CN9")
dbSetOrder(1)
dbSeek(xFilial("CN9")+cContra+cNRevisa)//Encontra contrato com a revisao em aberto    
cContraTR := CN9->CN9_TIPREV
		
If cCodTR <> cContraTR
	Aviso("CNTA140",STR0133 + cContraTR,{"OK"})//"Opcao PROSSEGUIR somente é permitido para o Cod Tp Revisão 001"
	lRet := .F.
EndIf                         

dbSelectArea("CN0")
dbSetOrder(1)
dbSeek(xFilial("CN0")+cCodTR)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao realiza a opção PROSSEGUIR para Revisoes do Tipo Reajuste   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTpRev  := CN0->CN0_TIPO
		
If lRet .And. cTpRev == DEF_REAJU  
	lRet := .F. //Finaliza Wizard
	Aviso("CNTA140",STR0134,{"OK"})//"Opcao PROSSEGUIR não é permitida para Revisões do tipo Reajuste"		
EndIF 

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140Indice³ Autor ³ Alex Egydio           ³ Data ³01.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao no painel Troca Indice                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - 1=Valida se o indice esta igual                    ³±±
±±³          ³          2=Validacoes no botao avancar                      ³±±
±±³          ³          3=Acoes no botao voltar                            ³±±
±±³          ³ ExpC02 - Indice Economico Atual                             ³±±
±±³          ³ ExpC03 - Indice Economico Novo                              ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CN140Indice(cAcao,cIndAtu,cIndNovo,cRevisa,cNRevisa)
Local lRet := .T.
If	cAcao=="1"
	If	cIndNovo==cIndAtu	
		Help("",1,"CNTA140_21",,cIndAtu,4,1)	//"Para alterar o índice econômico, selecione um índice diferente de:"
		lRet := .F.
	EndIf
//-- Botao Avancar do painel Troca Indice
ElseIf cAcao=="2"
	If	cIndNovo==cIndAtu	
		Help("",1,"CNTA140_21",,cIndAtu,4,1)	//"Para alterar o índice econômico, selecione um índice diferente de:"
		lRet := .F.
	EndIf
	lRet := NaoVazio(cIndNovo)
	oWizard:NPanel := 15//Segue para painel final
//-- Botao Voltar do painel Troca Indice
ElseIf cAcao=="3"
	cIndNovo  := Space(Len(CN9->CN9_INDICE))
	//-- Volta para o painel Selecao do Contrato
	oWizard:NPanel := 4
EndIf	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140Forne ³ Autor ³ Alex Egydio           ³ Data ³01.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Acoes do painel troca fornecedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - 1=Montagem da Getdados para troca do fornecedor    ³±±
±±³          ³          2=Linha ok da getdados da troca do fornecedor      ³±±
±±³          ³          3=Acoes no botao avancar                           ³±±
±±³          ³          4=Acoes no botao voltar                            ³±±
±±³          ³          5=Efetua a troca do fornecedor                     ³±±
±±³          ³ ExpC02 - Nr. da revisao do contrato                         ³±±
±±³          ³ ExpA01 - Planilhas selecionadas no painel planilhas         ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN140Forne(cAcao,cRevisa,aPlan,cFornec,cLoja)
Local aAlter   := {}
Local n1Cnt	   := 0
Local lRet 	   := .T.
Local lDelCNC  := .F.
Local nPosPlan := 0
Local nPosFAtu := 0
Local nPosLAtu := 0
Local nPosFNov := 0
Local nPosLNov := 0 
Local nPosCNov := 0
Local nPosLCNov:= 0   
Local nPosCAtu := 0
Local nPosCLAtu:= 0
Local cEspCtr  := ""
DEFAULT cFornec:= ""
DEFAULT cLoja  := ""

If	Type("aHdFor")=="A"
	nPosPlan := GDFieldPos("CPLANIL",aHdFor)
	nPosFAtu := GDFieldPos("CFORATU",aHdFor)
	nPosLAtu := GDFieldPos("CLOJATU",aHdFor)
	nPosFNov := GDFieldPos("CFORNOV",aHdFor)
	nPosLNov := GDFieldPos("CLOJNOV",aHdFor)
	nPosCAtu := GDFieldPos("CCLIATU",aHdFor)
	nPosCLAtu:= GDFieldPos("CCLJATU",aHdFor)
	nPosCNov := GDFieldPos("CCLINOV",aHdFor)
	nPosLCNov:= GdFieldPos("CCLJNOV",aHdFor)
EndIf	

If CN9->(FieldPos("CN9_ESPCTR")) > 0
	cEspCtr := CN9->CN9_ESPCTR
ElseIf !Empty(CN9->CN9_CLIENT)
	cEspCtr := "2"
Else
	cEspCtr := "1"
EndIf

//-- Monta getdados do painel troca fornecedor
If cAcao == "1"
	
	//-- Preenche aHeader
	If Empty(aHdFor)
		If cEspCtr == "1"
			aAlter   := {"CFORNOV","CLOJNOV"}			
			SX3->(dbSetOrder(2))
			If aPlan # NIL
				SX3->(dbSeek("CNA_NUMERO"))
				aAdd(aHdFor,{AllTrim(X3Titulo()),"CPLANIL","@!",SX3->X3_TAMANHO,SX3->X3_DECIMAL,".T.",,"C","",,,})
			EndIf
			SX3->(dbSeek("CNA_FORNEC"))
			aAdd(aHdFor,{AllTrim(X3Titulo()),"CFORATU","@!",SX3->X3_TAMANHO,SX3->X3_DECIMAL,".T.",,"C","",,,})
			SX3->(dbSeek("CNA_LJFORN"))
			aAdd(aHdFor,{AllTrim(X3Titulo()),"CLOJATU","@!",SX3->X3_TAMANHO,SX3->X3_DECIMAL,".T.",,"C","",,,})  
		
			aAdd(aHdFor,{STR0146,"CFORNOV","@!",TamSX3("CNA_FORNEC")[1],TamSX3("CNA_FORNEC")[2],".T.",,"C","SA2A",,,}) //-- Novo Fornec.
			aAdd(aHdFor,{STR0147,"CLOJNOV","@!",TamSX3("CNA_LJFORN")[1],TamSX3("CNA_LJFORN")[2],".T.",,"C","",,,}) //-- Nova Lj.Fornec.
		Else              
			aAlter   := {"CCLINOV","CCLJNOV"}
			SX3->(dbSetOrder(2))
			If aPlan # NIL
				SX3->(dbSeek("CNA_NUMERO"))
				aAdd(aHdFor,{AllTrim(X3Titulo()),"CPLANIL","@!",SX3->X3_TAMANHO,SX3->X3_DECIMAL,".T.",,"C","",,,})
			EndIf
			SX3->(dbSeek("CNA_CLIENT"))
			aAdd(aHdFor,{AllTrim(X3Titulo()),"CCLIATU","@!",SX3->X3_TAMANHO,SX3->X3_DECIMAL,".T.",,"C","",,,})
			SX3->(dbSeek("CNA_LOJACL"))
			aAdd(aHdFor,{AllTrim(X3Titulo()),"CCLJATU","@!",SX3->X3_TAMANHO,SX3->X3_DECIMAL,".T.",,"C","",,,})  
		
			aAdd(aHdFor,{STR0156,"CCLINOV","@!",TamSX3("CNA_CLIENT")[1],TamSX3("CNA_CLIENT")[2],".T.",,"C","SA1",,,}) //-- Novo Cliente.
			aAdd(aHdFor,{STR0157,"CCLJNOV","@!",TamSX3("CNA_LOJACL")[1],TamSX3("CNA_LOJACL")[2],".T.",,"C","",,,}) //-- Nova Loja.Cliente.			
		EndIf
	Endif

	//-- Preenche aCols
	If aPlan # NIL //-- Contrato fixo
		aItFor := {}
		CNA->(dbSetOrder(1))
		For n1Cnt := 1 To Len(aPlan)
			If CNA->(dbSeek(xFilial("CNA")+cContra+cRevisa+aPlan[n1Cnt,1])) .And. cEspCtr == "1"
	 			aAdd(aItFor,Array(Len(aHdFor)+1))
	 			aTail(aItFor)[1] := aPlan[n1Cnt,1]
	 			aTail(aItFor)[2] := CNA->CNA_FORNEC
	 			aTail(aItFor)[3] := CNA->CNA_LJFORN
	 			aTail(aItFor)[4] := Space(Len(CNC->CNC_CODIGO))
	 			aTail(aItFor)[5] := Space(Len(CNC->CNC_LOJA))
				aTail(aItFor)[Len(aHdFor)+1] := .F.
			Else
				CNC->(dbSetOrder(3))
				CNC->(dbSeek(xFilial("CNC")+cContra+cRevisa+CNA->CNA_CLIENT+CNA->CNA_LOJACL))
	 			aAdd(aItFor,Array(Len(aHdFor)+1))
	 			aTail(aItFor)[1] := aPlan[n1Cnt,1]
	 			aTail(aItFor)[2] := CNC->CNC_CLIENT
	 			aTail(aItFor)[3] := CNC->CNC_LOJACL
	 			aTail(aItFor)[4] := Space(Len(CNC->CNC_CLIENT))
	 			aTail(aItFor)[5] := Space(Len(CNC->CNC_LOJACL))
				aTail(aItFor)[Len(aHdFor)+1] := .F.
			EndIf
		Next n1Cnt
	Else	//-- Contrato variavel                                       
		CNC->(dbSetOrder(1))
		CNC->(dbSeek(xFilial("CNC")+cContra+cRevisa))
		While !CNC->(EOF()) .And. CNC->(CNC_FILIAL+CNC_NUMERO+CNC_REVISA) == xFilial("CNC")+cContra+cRevisa
			If cEspCtr == "1"
				aAdd(aItFor,Array(Len(aHdFor)+1))
	 			aTail(aItFor)[1] := CNC->CNC_CODIGO
	 			aTail(aItFor)[2] := CNC->CNC_LOJA
	 			aTail(aItFor)[3] := Space(Len(CNC->CNC_CODIGO))
	 			aTail(aItFor)[4] := Space(Len(CNC->CNC_LOJA))
				aTail(aItFor)[Len(aHdFor)+1] := .F.
			Else
				aAdd(aItFor,Array(Len(aHdFor)+1))
	 			aTail(aItFor)[1] := CNC->CNC_CLIENT
	 			aTail(aItFor)[2] := CNC->CNC_LOJACL
	 			aTail(aItFor)[3] := Space(Len(CNC->CNC_CLIENT))
	 			aTail(aItFor)[4] := Space(Len(CNC->CNC_LOJACL))
				aTail(aItFor)[Len(aHdFor)+1] := .F.				
			Endif
			CNC->(dbSkip())
		End
	EndIf

	//-- Ponto de entrada para permitir a edicao do aHeader e aCols
	If ExistBlock("CN140CNC")
		aRetPE := ExecBlock("CN140CNC",.F.,.F.,{1,aHdFor,aItFor,,aAlter})
		If ValType(aRetPE) == "A" 
			If Len(aRetPE) > 0 .And. ValType(aRetPE[1]) == "A"
				aHdFor := aClone(aRetPE[1])
			EndIf
			If Len(aRetPE) > 1 .And. ValType(aRetPE[2]) == "A"
				aItFor := aClone(aRetPE[2])
			EndIf
			If Len(aRetPE) > 2 .And. ValType(aRetPE[3]) == "A"
				aAlter := aClone(aRetPE[3])
			EndIf
		EndIf
	EndIf

	oGetDad1 := MsNewGetDados():New(025,000, __DlgHeight(oWizard:oMPanel[15]), __DlgWidth(oWizard:oMPanel[15]),GD_UPDATE+GD_INSERT+GD_DELETE,"CN140Forne('2')",,,,,999,,,"Empty(oGetDad1:aCols[n,1])",oWizard:oMPanel[15],aHdFor,aItFor)
	oGetDad1:oBrowse:aAlter := aAlter

	//Carrega acols do aItens de acordo com a posicao da planilha
	oGetDad1:aCols := aClone(aItFor)
	oGetDad1:oBrowse:nAt := 1
	oGetDad1:oBrowse:Refresh()

	oWizard:NPanel := 14//Segue para painel troca fornecedor
	
	
//-- Linha ok painel troca fornecedor
ElseIf cAcao == "2"
    If cEspCtr == "1"
		If !Empty(oGetDad1:aCols[oGetDad1:nAT,nPosFNov]+oGetDad1:aCols[oGetDad1:nAT,nPosLNov])
			lRet := ExistCpo("SA2",oGetDad1:aCols[oGetDad1:nAT,nPosFNov]+oGetDad1:aCols[oGetDad1:nAT,nPosLNov])
		EndIf
		
		If lRet .And. If(Empty(nPosPlan),.T.,!Empty(oGetDad1:aCols[oGetDad1:nAT,nPosPlan]))
			If oGetDad1:aCols[oGetDad1:nAT,nPosFAtu]+oGetDad1:aCols[oGetDad1:nAT,nPosLAtu] == oGetDad1:aCols[oGetDad1:nAT,nPosFNov]+oGetDad1:aCols[oGetDad1:nAT,nPosLNov]
				Help("",1,"CNTA140_22",,oGetDad1:aCols[oGetDad1:nAT,nPosFNov]+"/"+oGetDad1:aCols[oGetDad1:nAT,nPosLNov],4,1)
				lRet := .F.
			EndIf
		EndIf
	Else
		If !Empty(oGetDad1:aCols[oGetDad1:nAT,nPosCNov]+oGetDad1:aCols[oGetDad1:nAT,nPosLCNov])
			lRet := ExistCpo("SA1",oGetDad1:aCols[oGetDad1:nAT,nPosCNov]+oGetDad1:aCols[oGetDad1:nAT,nPosLCNov])
		EndIf
		
		If lRet .And. If(Empty(nPosPlan),.T.,!Empty(oGetDad1:aCols[oGetDad1:nAT,nPosPlan]))
			If oGetDad1:aCols[oGetDad1:nAT,nPosCAtu]+oGetDad1:aCols[oGetDad1:nAT,nPosCLAtu] == oGetDad1:aCols[oGetDad1:nAT,nPosCNov]+oGetDad1:aCols[oGetDad1:nAT,nPosLCNov]
				Help("",1,"CNTA140_22",,oGetDad1:aCols[oGetDad1:nAT,nPosCNov]+"/"+oGetDad1:aCols[oGetDad1:nAT,nPosLCNov],4,1)
				lRet := .F.
			EndIf
		EndIf
	EndIf

//-- Botao avancar do painel troca fornecedor
ElseIf cAcao == "3"

	oWizard:NPanel := 15//Segue para painel justificativa

//-- Botao voltar do painel troca fornecedor
ElseIf cAcao == "4"

	If Aviso(STR0016,STR0090,{STR0091,STR0092})==2		//"Atencao"##"Não"##"Sim"
		oGetDad1:aCols := {}
		aItFor := {}
		If Empty(nPosPlan)
			oWizard:NPanel := 4//Segue para o painel de contratos
		Else
			oWizard:NPanel := 9//Segue para o painel de planilhas
		EndIf
	Else
		lRet := .F.
	EndIf

//-- Troca o Fornecedor/Cliente
ElseIf cAcao=="5"

	CNA->(dbSetOrder(1))  	
	
	For n1Cnt := 1 To Len(aItFor)

		If	!Empty(cFornec) .And. cEspCtr == "1"
			aItFor[n1Cnt,nPosFNov]:=cFornec
			aItFor[n1Cnt,nPosLNov]:=cLoja
		ElseIf !Empty(cFornec) .And. cEspCtr == "2"
			aItFor[n1Cnt,nPosCNov+2]:=cFornec
			aItFor[n1Cnt,nPosLCNov+2]:=cLoja
		EndIf

		If cEspCtr == "1"
			CNC->(dbSetOrder(1))
			If !aTail(aItFor[n1Cnt]) .And. !Empty(aItFor[n1Cnt,nPosFNov]) .And. !Empty(aItFor[n1Cnt,nPosLNov])
				//-- Cria novo fornecedor na CNC
				If !CNC->(dbSeek(xFilial("CNC")+cContra+cRevisa+aItFor[n1Cnt,nPosFNov]+aItFor[n1Cnt,nPosLNov]))
					RecLock("CNC",.T.)
						CNC->CNC_FILIAL	:= xFilial("CNC")
						CNC->CNC_NUMERO	:= cContra
						CNC->CNC_REVISA	:= cRevisa
						CNC->CNC_CODIGO	:= aItFor[n1Cnt,nPosFNov]
						CNC->CNC_LOJA	:= aItFor[n1Cnt,nPosLNov]
					CNC->(MsUnLock())
				EndIf
			Endif
		Else                                
			CNC->(dbSetOrder(3))
			If !aTail(aItFor[n1Cnt]) .And. !Empty(aItFor[n1Cnt,nPosCNov]) .And. !Empty(aItFor[n1Cnt,nPosLCNov])
				//-- Cria novo cliente na CNC
				If !CNC->(dbSeek(xFilial("CNC")+cContra+cRevisa+aItFor[n1Cnt,nPosCNov]+aItFor[n1Cnt,nPosLCNov]))
					RecLock("CNC",.T.)
						CNC->CNC_FILIAL	:= xFilial("CNC")
						CNC->CNC_NUMERO	:= cContra
						CNC->CNC_REVISA	:= cRevisa
						CNC->CNC_CLIENT	:= aItFor[n1Cnt,nPosCNov]
						CNC->CNC_LOJACL	:= aItFor[n1Cnt,nPosLCNov]
					CNC->(MsUnLock())
				EndIf			
			Endif
		Endif    
		//-- Troca fornecedor da planilha
		If cEspCtr == "1"
			If (!Empty(nPosPlan) .Or. !Empty(cFornec)) .And. CNA->(dbSeek(xFilial("CNA")+cContra+cRevisa+Iif(nPosPlan>0,aItFor[n1Cnt,nPosPlan],"")))
				RecLock("CNA",.F.)
					CNA->CNA_FORNEC := aItFor[n1Cnt,nPosFNov] 
					CNA->CNA_LJFORN := aItFor[n1Cnt,nPosLNov]
					CNA->(MsUnLock())
			EndIf
		Else
			If (!Empty(nPosPlan) .Or. !Empty(cFornec)) .And. CNA->(dbSeek(xFilial("CNA")+cContra+cRevisa+Iif(nPosPlan>0,aItFor[n1Cnt,nPosPlan],"")))
				RecLock("CNA",.F.)
					CNA->CNA_CLIENT := aItFor[n1Cnt,nPosCNov] 
					CNA->CNA_LOJACL := aItFor[n1Cnt,nPosLCNov]
				CNA->(MsUnLock())
			EndIf
		EndIf
		//-- Ponto de entrada para permitir a gravacao de campos customizados
		If ExistBlock("CN140CNC")
			ExecBlock("CN140CNC",.F.,.F.,{2,aHdFor,aItFor,n1Cnt})
		EndIf
	Next n1Cnt
	
	//-- Remove fornecedores substituidos da CNC
	CNC->(dbSeek(xFilial("CNC")+cContra+cRevisa))
	While !CNC->(EOF()) .And. CNC->(CNC_FILIAL+CNC_NUMERO+CNC_REVISA) == xFilial("CNC")+cContra+cRevisa	
		If cEspCtr == "1"
			//-- Somente processa para os fornecedores que foram trocados na revisao
			If aScan(aItFor,{|x| x[nPosFAtu]+x[nPosLAtu] == CNC->(CNC_CODIGO+CNC_LOJA) .And.;
								 !Empty(x[nPosFNov]) .And. !Empty(x[nPosLNov])}) == 0
				CNC->(dbSkip())
				Loop
			EndIf
		Else
			//-- Somente processa para os clientes que foram trocados na revisao
			If aScan(aItFor,{|x| x[nPosCNov]+x[nPosLCNov] == CNC->(CNC_CLIENT+CNC_LOJACL) .And.;
								 !Empty(x[nPosCNov]) .And. !Empty(x[nPosLCNov])}) == 0
				CNC->(dbSkip())
				Loop
			EndIf
		Endif	
		lDelCNC := .T.
		
		If Empty(nPosPlan)
			//-- Para contrato nao fixo:
			//-- Se o fornecedor nao e novo de outro, deleta
			If cEspCtr == "1"
				lDelCNC := aScan(aItFor,{|x| x[nPosFNov]+x[nPosLNov] == CNC->(CNC_CODIGO+CNC_LOJA)}) == 0
			Else
				lDelCNC := aScan(aItFor,{|x| x[nPosCNov]+x[nPosLCNov] == CNC->(CNC_CLIENT+CNC_LOJACL)}) == 0				
			Endif
		Else
			//-- Para contrato fixo:
			//-- Verifica se o fornecedor ficou sem planilhas, se sim deleta
			CNA->(dbSeek(xFilial("CNA")+cContra+cRevisa))
			While !CNA->(EOF()) .And. CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA) == xFilial("CNA")+cContra+cRevisa
				If (cEspCtr == "1" .And. CNA->(CNA_FORNEC+CNA_LJFORN) == CNC->(CNC_CODIGO+CNC_LOJA)) ;
				.Or. (cEspCtr == "2" .And. CNA->(CNA_CLIENT+CNA_LOJACL) == CNC->(CNC_CLIENT+CNC_LOJACL))
					//-- Se nao, cancela exclusao
					lDelCNC := .F.
					Exit
				EndIf
				
				CNA->(dbSkip())
			End
		EndIf
		
		//-- Deleta CNC
		If lDelCNC
			RecLock("CNC",.F.)
				CNC->(dbDelete())
			CNC->(MsUnLock())
		EndIf		
		
		CNC->(dbSkip())
	End
EndIf

Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN140RevCNC³ Autor ³   Eduardo Dias        ³ Data ³27/11/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera copia dos dados dos fornecedores                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA140                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN140RevCNC(cContra,cRevisa,cNRevisa)
Local aArea		:= GetArea()
Local nX		:= 0    
Local nY		:= 0   
Local aFornece	:= {}

dbSelectArea("CNC")
dbSetOrder(1)

//-- Deleta itens da CNC quando reinicio de revisao
If lRevisad .And. nRevRtp == 2
	While dbSeek(xFilial("CNC")+cContra+cNRevisa)
		RecLock("CNC",.F.)
			dbDelete()
		MsUnLock()
	End
EndIf

If nRevRtp # 1 .And. CNC->(FieldPos("CNC_REVISA")) > 0
	//-- Copia dados da revisao anterior
	If dbSeek(xFilial("CNC")+cContra+cRevisa)
		While !EOF() .And. CNC_FILIAL+CNC_NUMERO+CNC_REVISA == xFilial("CNC")+cContra+cRevisa
			aAdd(aFornece,Array(FCount()))
			For nX := 1 to FCount()
				aTail(aFornece)[nX] := FieldGet(nX)
			Next nX   
			dbSkip()
		Enddo
	Endif
		    
	//-- Grava na nova revisao
	For nX := 1 to Len(aFornece)
		RecLock("CNC",.T.)
		For nY := 1 to Len(aFornece[nX])
			If FieldName(nY) == "CNC_REVISA"
				FieldPut(nY,cNRevisa)
			Else
				FieldPut(nY,aFornece[nX,nY])
			EndIf
		Next nY
		MsUnlock()
	Next nX
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN140Excl ºAutor  ³Andre Anjos         º Data ³  29/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exclusao de revisao pendente.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN140Excl(cAlias,nReg,nOpc)
Local lRet     := .T.
Local cContra  := CN9->CN9_NUMERO
Local cRevisao := CN9->CN9_REVISA
Local cRevAnt  := NIL

PRIVATE nRevRtp := 3
PRIVATE lFisico := (CN1->(FieldPos("CN1_CROFIS")) > 0 .And. Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROFIS") == "1")
PRIVATE lContab := Posicione("CN1",1,xFilial("CN1")+CN9->CN9_TPCTO,"CN1_CROCTB") == "1"

If CN9->CN9_SITUAC # '09'
	Aviso(STR0016,STR0126,{"Ok"}) //Somente revisões em andamento podem ser excluídas.
	lRet := .F.
EndIf

If lRet .And. CN240VldUsr(CN9->CN9_NUMERO,DEF_TRAEXC,.T.) .And. MsgYesNo(STR0085)//"Confirma exclusão da revisão?"
	dbSelectArea("CN9")
	dbSetOrder(8)
	dbSeek(xFilial("CN9")+cRevisao)
	While !EOF() .And. CN9_FILIAL+CN9_REVATU == xFilial("CN9")+cRevisao
		If CN9_NUMERO == cContra
			cRevAnt := CN9_REVISA
			Exit
		EndIf
		dbSkip()
	End
	If cRevAnt # NIL
		CN140DelRev(cContra,cRevAnt,cRevisao)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN140VdReaºAutor  ³Cleber Maldonado	º Data ³  12/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida a data de inicio do reajuste.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN140VdRea(dDtReaj)
Local lRet := .T.

If dDtReaj > dDataBase
	Aviso(STR0016,STR0155,{"OK"}) //"A data de início do reajuste não pode ser posterior a data atual."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Cn140VldGCP(cContra,cRevisa,dFContra)


@author alexandre.gimenez

@param cContra Contrato
@param cRevisa Revisão do contrato
@param dFContra Data final do contrato
@return lRet
@since 27/09/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function Cn140VldGCP(cContra,cRevisa,dFContra)
Local aArea		:= GetArea()
Local cLei		:= "X"
local cPrazo		:= "X"
Local lRet 		:= .T.

If !Empty(CN9->CN9_CODED) .And. AliasInDic("CO0") .And. CO1->(FieldPos("CO1_REVISA")) > 0
	BeginSQL Alias "TMPCO1"
		SELECT CN9.CN9_DTINIC, CO0.CO0_LEI
		FROM %table:CN9% CN9
		JOIN %table:CO1% CO1 ON CO1.%NotDel% AND 
			CO1.CO1_FILIAL = %xfilial:CO1% AND 
			CO1.CO1_CODEDT = CN9.CN9_CODED AND 
			CO1.CO1_NUMPRO = CN9.CN9_NUMPR AND
			CO1.CO1_REVISA = (SELECT MAX(CO1_2.CO1_REVISA) FROM %table:CO1% CO1_2
									WHERE CO1_2.CO1_CODEDT = CO1.CO1_CODEDT
									AND CO1_2.CO1_NUMPRO = CO1.CO1_NUMPRO)
		JOIN %table:CO0% CO0 ON CO0.%NotDel% AND 
			 CO0.CO0_FILIAL = %xfilial:CO0% AND 
			 CO0.CO0_REGRA = CO1.CO1_REGRA
		WHERE CN9.%NotDel% AND
			CN9.CN9_NUMERO = %Exp:cContra% AND 
			CN9.CN9_REVISA = %Exp:cRevisa%	
	EndSQL
	
	Do Case
		Case TMPCO1->CO0_LEI  == '1' //-- Lei 8.66
		Case TMPCO1->CO0_LEI  == '2' //-- RLC
			If dFContra > (TMPCO1->CN9_DTINIC + 1826) 
				cPrazo := "60 Meses"
				cLei	:= "RLC"
				lRet	:= .F.	
			EndIf
		Case TMPCO1->CO0_LEI  == '3' //-- Lei 10.520
	EndCase
	
	If !lRet 
		Help("GCP",1,"MAXPRAZO",,STR0161 +cPrazo +STR0162 +cLei +".",1,1) //-- A vigência do contrato excedeu o limite de ### estabelecido pela lei ###. 
	EndIf
	
	TMPCO1->(dbCloseArea())
	RestArea(aArea)
EndIf
	
Return lRet
