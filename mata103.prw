#INCLUDE "MATA103.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"     
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#DEFINE FRETE   04	// Valor total do Frete                       
#DEFINE VALDESP 05	// Valor total da despesa
#DEFINE SEGURO  07	// Valor total do seguro

Static lFWCodFil := FindFunction("FWCodFil")
Static __aAliasInDic                        
Static aBkpHeader := {}   
Static aCposSN1 := {} 
Static lN1Staus	 
Static lN1Especie 
Static lN1NFItem  
Static lN1Prod    
Static lN1Orig        
Static lN1CstPis 
Static lN1AliPis  
Static lN1CstCof  
Static lN1AliCof  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA103  ³ Autor ³ Edson Maricate        ³ Data ³ 24.01.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Notas Fiscais de Entrada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Function MATA103(xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xAutoImp,xAutoAFN,xParamAuto)
Local nPos      	:= 0
Local bBlock    	:= {|| Nil}
Local nX	   		:= 0
Local nAutoPC		:= 0
Local aCores    	:= {	{'Empty(F1_STATUS)'	,'ENABLE'		},;	// NF Nao Classificada
							{'F1_STATUS=="B"'	,'BR_LARANJA'	},;	// NF Bloqueada
							{'F1_STATUS=="C"'	,'BR_VIOLETA'   },;	// NF Bloqueada s/classf.
							{'F1_TIPO=="N"'		,'DISABLE'   	},;	// NF Normal
							{'F1_TIPO=="P"'		,'BR_AZUL'   	},;	// NF de Compl. IPI
							{'F1_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
							{'F1_TIPO=="C"'		,'BR_PINK'   	},;	// NF de Compl. Preco/Frete
							{'F1_TIPO=="B"'		,'BR_CINZA'  	},;	// NF de Beneficiamento
							{'F1_TIPO=="D"'		,'BR_AMARELO'	} }	// NF de Devolucao
Local aCoresUsr  	:= {}
Local cFiltro    	:= ""
Local lPrjCni 		:= FindFunction("ValidaCNI") .And. ValidaCNI()
Local lIntDl  		:= (SuperGetMV("MV_INTDL",.F.,"N")=="S")
PRIVATE l103Auto	:= (xAutoCab<>NIL .And. xAutoItens<>NIL)
PRIVATE aAutoCab	:= {}
PRIVATE aAutoImp    := {}
PRIVATE aAutoItens 	:= {}
PRIVATE aParamAuto 	:= {}
PRIVATE aRotina 	:= MenuDef() // Foi modificado para o SIGAGSP.
PRIVATE cCadastro	:= OemToAnsi(STR0009) //"Documento de Entrada"
PRIVATE aBackSD1    := {}
PRIVATE aBackSDE    := {} 
PRIVATE aNFEDanfe   := {}
PRIVATE bBlockSev1         	      
PRIVATE bBlockSev2
PRIVATE aAutoAFN	:= {}  	  
PRIVATE aDanfeComp  := {}
PRIVATE aRegsLock	:={}
PRIVATE lMT100TOK   := .T.
PRIVATE lImpPedido	:= .F.

PRIVATE _aDivPNF    := {}	  // Inicializa array do cadastro de divergencias - FW

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os parametros DEFAULTS da rotina                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lWhenGet := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(FindFunction("SIGACUSB_V") .And. SIGACUSB_V() >= 20070507)
	Final(STR0220) //"Atualizar SIGACUSB.PRX !!!"
EndIf
If !(FindFunction("CarregaTipoFrete"))
	Final(STR0378) //"Atualizar MATXFUNA.PRX !!!"
EndIf

//-- Forca a criacao do arq. dcf pois o sigamdi nao cria o arq.
If	lIntDl
	DbSelectArea("DCF")
EndIf

If lPrjCni   
	//------------------------------------------------
	// Abre arquivo de divergencias             
	//------------------------------------------------
	dbSelectArea("COF")
	dbSetOrder(1)
	dbSeek(xFilial("COF"))
EndIf

If l103Auto   
	For nX:= 1 To Len(xAutoItens)
		If (nAutoPC := Ascan(xAutoItens[nx],{|x| x[1]== "D1_PEDIDO"})) > 0
		     If Empty(xAutoItens[nX][nAutoPC][3])
		     	xAutoItens[nX][nAutoPC][3]:= "vazio().or. A103PC()"
			 EndIf
		EndIf
	Next
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Utilizado para adicionar botoes ao Menu Principal       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("MA103OPC") .And. !l103Auto
	aRotNew := ExecBlock("MA103OPC",.F.,.F.,aRotina)
	For nX := 1 to len(aRotNew)
		aAdd(aRotina,aRotNew[nX])
	Next
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aba Danfe 	  										         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If FindFunction("NfeFldDiv")
	A103CheckDanfe(1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta as cores se utilizar coletor de dados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
	aCores    := {}
	AAdd(aCores,{ 'Empty(F1_STATUS) .And.((F1_STATCON $ "1|4") .Or. Empty(F1_STATCON))','ENABLE'			})	// NF Nao Classificada 		
	AAdd(aCores,{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="N" .AND. (F1_STATUS<>"B" .AND. F1_STATUS<>"C")', 'DISABLE'		})  // NF Normal
	AAdd(aCores,{ 'F1_STATUS=="B"'															, 'BR_LARANJA'	})  // NF Bloqueada
	AAdd(aCores,{ 'F1_STATUS=="C"'															, 'BR_VIOLETA'	})  // NF Bloqueada s/classf.
	AAdd(aCores,{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="P"'	 	, 'BR_AZUL'		})  // NF de Compl. IPI
	AAdd(aCores,{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="I"'		, 'BR_MARROM'	})  // NF de Compl. ICMS
	AAdd(aCores,{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="C"'		, 'BR_PINK'		})  // NF de Compl. Preco/Frete
	AAdd(aCores,{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="B"'		, 'BR_CINZA'	})  // NF de Beneficiamento
	AAdd(aCores,{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="D"'    	, 'BR_AMARELO'	})  // NF de Devolucao
	AAdd(aCores,{ '!(F1_STATCON $ "1|4") .AND. !EMPTY(F1_STATCON)'							, 'BR_PRETO'	})  // NF Bloq. para Conferencia
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do programa em relacao aos modulos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AMIIn(2,4,11,12,14,17,39,41,42,43,97,44,67,69,72)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a pilha fiscal                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	MaFisSave()
	MaFisEnd()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de rotina a ser executada                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	aAutoAFN   := Iif(xAutoAFN<>Nil,xAutoAFN,{})
	aAutoImp   := IIf(xAutoImp<>NIL,xAutoImp,{})
	aParamAuto := IIf(xParamAuto<>NIL,xParamAuto,{})
	Do Case
	Case lWhenGet .Or. ( !l103Auto .And. nOpcAuto <> Nil )

		Do Case
		Case nOpcAuto == 3
			INCLUI := .T.
			ALTERA := .F.
		Case nOpcAuto == 4
			INCLUI := .F.
			ALTERA := .T.
		OtherWise	
			INCLUI := .F.
			ALTERA := .F.
		EndCase		

		DbSelectArea('SF1')
		nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
		If ( nPos <> 0 )
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock, Alias(), (Alias())->(Recno()),nPos,lWhenGet)
		EndIf
	Case l103Auto
		AAdd( aRotina, {OemToAnsi(STR0006), "A103NFiscal", 3, 20 } ) //"Exclusao EIC"
		AAdd( aRotina, {OemToAnsi(STR0006), "A103NFiscal", 3, 21 } ) //"Exclusao TMS"		
		DEFAULT nOpcAuto := 3//alteraw
		MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"SF1")
	OtherWise
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Interface com o usuario via Mbrowse                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Set Key VK_F12 To FAtiva()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para pre-validar os dados a serem  ³
		//³ exibidos.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ExistBlock("M103BROW")
			ExecBlock("M103BROW",.f.,.f.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para inclusão de nova COR da legenda       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( ExistBlock("MT103COR") )			
			aCoresUsr := ExecBlock("MT103COR",.F.,.F.,{aCores})
			If ( ValType(aCoresUsr) == "A" )
				aCores := aClone(aCoresUsr)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para verificacao de filtros na Mbrowse      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  ExistBlock("M103FILB") 
			cFiltro := ExecBlock("M103FILB",.F.,.F.)
			If Valtype(cFiltro) <> "C"
				cFiltro := ""		
			EndIf
		EndIf

		mBrowse(6,1,22,75,"SF1",,,,,,aCores,,,,,,,, IF(!Empty(cFiltro),cFiltro, NIL))
		Set Key VK_F12 To
	EndCase
	MaFisRestore()
EndIf 
If aBkpHeader <> Nil
	 aBkpHeader:= Nil 
Endif
If aCposSN1 <> Nil
	aCposSN1 := Nil
Endif
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103NFiscal³ Autor ³ Edson Maricate       ³ Data ³24.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Incl/Alter/Excl/Visu.de NF Entrada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103NFiscal(ExpC1,ExpN1,ExpN2,ExpL1,ExpL2)	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±³          ³ ExpL1 = lWhenGet (default = .F.)                           ³±±
±±³          ³ ExpL2 = Estorno de NF Classificada (chamada MATA140)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103NFiscal(cAlias,nReg,nOpcx,lWhenGet,lEstNfClass)
Local lContinua		:= .T.
Local l103Inclui	:= .F.
Local l103Exclui	:= .F.
Local lClaNfCfDv 	:= .F.
Local lDigita		:= .F.
Local lAglutina		:= .F.
Local lQuery		:= .F.
Local lGeraLanc		:= .F.
Local lExcViaEIC	:= .F.
Local lExcViaTMS	:= .F.
Local lProcGet		:= .T.
Local lTxNeg        := .F.
Local lConsMedic    := .F.
Local lRatLiq       := .T.
Local lRatImp       := .F.
Local nTaxaMoeda	:= 0

Local lMT103NFE		:= Existblock("MT103NFE")
Local lTMT103NFE	:= ExistTemplate("MT103NFE")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local lPyme			:= If( Type( "__lPyme" ) <> "U", __lPyme, .F. )
Local lClassOrd		:= ( SuperGetMV( "MV_CLASORD" ) == "1" )  //Indica se na classificacao do documento de entrada os itens devem ser ordenados por ITEM+COD.PRODUTO
Local lNfeOrd		:= ( GetNewPar( "MV_NFEORD" , "2" ) == "1" ) // Indica se na visualizacao do documento de entrada os itens devem ser ordenados por ITEM+COD.PRODUTO
Local lFimp			:= SF1->(FieldPos("F1_FIMP")) > 0
Local lNfVcOri		:= GetNewPar("MV_NFVCORI","2") == "1"
Local lMvAtuComp    := SuperGetMV("MV_ATUCOMP",,.F.)
Local lVisDirf		:= SuperGetMv("MV_VISDIRF",.F.,"1") == "1"
Local lNgMnTes		:= SuperGetMV("MV_NGMNTES") == "S"
Local lNgValOsLot	:= FindFunction("NGVALOSLOT")
Local lHasLocEquip  := FindFunction("At800AtNFEnt") .And. AliasInDic("TEW")
Local lRet          := .T.
Local aArea2        := {}

Local nRecSF1		:= 0
Local nOpc			:= 0
Local nItemSDE		:= 0
Local nTpRodape		:= 1
Local nX			:= 0
Local nY			:= 0
Local nCounterSD1	:= 0
Local nMaxCodes		:= SetMaxCodes( 9999 )
Local nIndexSE2		:= 0
Local nScanBsPis	:= 0
Local nScanVlPis	:= 0
Local nScanAlPis	:= 0
Local nScanBsCof	:= 0
Local nScanVlCof	:= 0
Local nScanAlCof	:= 0
Local nLoop			:= 0
Local nHoras 		:= 0
Local nTamTjOrd		:= TamSX3("TJ_ORDEM")[1]

Local lPCCBaixa		:= SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local cModRetPIS	:= GetNewPar( "MV_RT10925", "1" )

Local aStruSF3		:= {}
Local aStruSDE		:= {}
Local aStruSE2		:= {}
Local aStruSD1		:= {}
Local aRecSD1		:= {}
Local aRecSE1		:= {}
Local aRecSE2		:= {}
Local aRecSF3		:= {}
Local aRecSC5		:= {}
Local aRecSDE		:= {}
Local aHeadSDE		:= {}
Local aHeadSE2		:= {}
Local aColsSE2		:= {}
Local aHeadSEV		:= {}
Local aColsSEV		:= {}
Local aColsSDE		:= {}
Local aHistor		:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosGet		:= {}
Local aPosObj		:= {}
Local aPages		:= {"HEADER"}
Local aInfForn		:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"","","",""}
Local a103Var		:= {0,0,0,0,0,0,0,0,0}
Local aButControl	:= {}
Local aTitles		:= {} // foi alterado por causa do SIGAGSP.
Local aSizeAut		:= {}
Local aButVisual	:= {}
Local aButtons		:= {}
Local aMemUser      := {}
Local aRateio		:= {0,0,0}
Local aFldCBAtu	    // foi alterado por causa do SIGAGSP.
Local aRecClasSD1	:= {}
Local aRelImp		:= MaFisRelImp("MT100",{ "SD1" })
Local aFil10925		:= {}
Local aMultas       := {}
Local cDoc 			:= SF1->F1_DOC
Local cSer 			:= SF1->F1_SERIE

Local cTituloDlg	:= IIf(Type("cCadastro") == "C" .And. Len(cCadastro) > 0,cCadastro,OemToAnsi(STR0009)) //"Documento de Entrada" 
Local cPrefixo		:= IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)
Local cHistor		:= ""
Local cItem			:= ""
Local cItemSDE		:= ""
Local cQuery		:= ""
Local cAliasSF3		:= "SF3"
Local cAliasSDE		:= "SDE"
Local cAliasSE2		:= "SE2"
Local cAliasSD1		:= "SD1"
Local cAliasSB1		:= "SB1"
Local cFornIss		:= Space(Len(SE2->E2_FORNECE))
Local cLojaIss		:= Space(Len(SE2->E2_LOJA))
Local dVencISS		:= CtoD("")
Local nSpedExc 		:= GetNewPar("MV_SPEDEXC",24)
Local dDtDigit 		:= dDataBase

Local cVarFoco		:= "     "
Local cIndex		:= ""
Local cCond			:= ""
Local cNatureza		:= ""

Local cCpBasePIS	:= ""
Local cCpValPIS		:= ""
Local cCpAlqPIS		:= ""
Local cCpBaseCOF	:= ""
Local cCpValCOF		:= ""
Local cCpAlqCOF		:= ""

Local nPosRec		:= 0
Local nCombo		:= 2
Local nItValido		:= 0
Local oDlg
Local oHistor
Local oLivro
Local oCombo
Local oCodRet

Local bKeyF12		:= Nil
Local bPMSDlgNF		:= {||PmsDlgNF(nOpcx,cNFiscal,cSerie,cA100For,cLoja,cTipo)} // Chamada da Dialog de Gerenc. Projetos
Local bCabOk		:= {|| .T.}
Local bIPRefresh	:= {|| MaFisToCols(aHeader,aCols,,"MT100"),Eval(bRefresh),Eval(bGdRefresh)}	// Carrega os valores da Funcao fiscal e executa o Refresh
Local bWhileSD1		:= { || .T. }
Local lMT103NAT		:= Existblock("MT103NAT")
Local nTitles1		:= 1
Local nTitles2		:= 2
Local nTitles3		:= 3
Local nTitles4		:= 4
Local nTitles5		:= 5
Local nTitles6		:= 6
Local nTitles7		:= 7
Local lGspInUseM	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local lLojaAtu		:= ( GetNewPar( "MV_LJ10925", "1" ) == "1" )
Local aAUTOISS		:= &(GetNewPar("MV_AUTOISS",'{"","","",""}'))
Local lNfeDanfe     := FindFunction("NfeFldDiv")
Local aNFEletr		:= {}
Local aNoFields     := {}
Local nNFe			:= 0
Local nConfNF       := 0
Local cDelSDE 	    := ""
Local aCodR	        :=	{}
Local cRecIss	    :=	"1"
Local oRecIss
Local nLancAp		:= 0
Local nInfDiv       := 0
Local nInfAdic      := 0
Local nPosGetLoja   := IIF(TamSX3("A2_COD")[1]< 10,(2.5*TamSX3("A2_COD")[1])+(110),(2.8*TamSX3("A2_COD")[1])+(100))
Local aHeadCDA		:= {}
Local aColsCDA		:= {}
Local lRatAFN       := .T.
Local aCtbInf       := {} //Array contendo os dados para contabilizacao online:
					    //		[1] - Arquivo (cArquivo)
						//		[2] - Handle (nHdlPrv)
						//		[3] - Lote (cLote)
						//      [4] - Habilita Digitacao (lDigita)
						//      [5] - Habilita Aglutinacao (lAglutina)
						//      [6] - Controle Portugal (aCtbDia)
						//		[7,x] - Campos flags atualizados na CA100INCL
						//		[7,x,1] - Descritivo com o campo a ser atualizado (FLAG)
						//		[7,x,2] - Conteudo a ser gravado na flag
						//		[7,x,3] - Alias a ser atualizado
						//		[7,x,4] - Recno do registro a ser atualizado
Local aMT103CTB  := {}
						
Local lExcCmpAdt := .T.
Local cStatCon   := ""
Local nQtdConf   := 0
Local oList
Local aListBox   := {}
Local oEnable    := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable   := LoadBitmap( GetResources(), "DISABLE" )
Local lCompAdt	 := .F.
Local aPedAdt	 := {}
Local aRecGerSE2 := {}
Local nPosPC 		:= 0
Local nPosItPC   	:= 0
Local nPosItNF	:= 0
Local nPosRat		:= 0

//Verifica se a funcionalidade Lista de Presente esta ativa e aplicada
Local lUsaLstPre := SuperGetMV("MV_LJLSPRE",,.F.) .And. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local a			 := 0
Local aDigEnd	   	:= {} 
Local lVer116		:= (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6"  .Or.  VAL(GetVersao(.F.))  > 11)
Local lDistMov		:= SuperGetMV("MV_DISTMOV",.F.,.F.)

//Variaveis utilizadas na integracao NG
Local nG 		:= 0
Local nPORDEM	:= 0

//Variaveis de Posicoes no Browse
Local nNumCol 		
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

//Chamado SDFPWW
Local cAglutFil := SuperGetMV("MV_PCCAGFL",,"1")
Local aAreaSM0  := {}
Local cCGCSM0   := ""
Local cEmpAtu   := ""

//Tratamendo de ISS por municipio.
Local nInfISS := 0
Local lISSxMun := SuperGetMV("MV_ISSXMUN",.F.,.F.) .And. FindFunction("ISSFldDiv")
Local aInfISS	:= Iif(lISSxMun,{{CriaVar("F1_INCISS"),CriaVar("CC2_MUN"),CriaVar("F1_ESTPRES"),CriaVar("CC2_MDEDMA"),CriaVar("CC2_MDEDSR"),;
					CriaVar("CC2_PERMAT"),CriaVar("CC2_PERSER")},;
					{CriaVar("D1_TOTAL"),CriaVar("D1_ABATISS"),CriaVar("D1_ABATMAT"),CriaVar("D1_BASEISS"),CriaVar("D1_VALISS")},;
           	        {CriaVar("D1_TOTAL"),CriaVar("D1_ABATINS"),CriaVar("D1_ABATINS"),CriaVar("D1_BASEINS"),CriaVar("D1_VALINS")}},{})
Local aObjetos := aClone(aInfISS)

Local lIntegGFE := SuperGetMV("MV_INTGFE",.F.,.F.) .And. SuperGetMV("MV_INTGFE2",.F.,"2") $ "1" .And. SuperGetMv("MV_GFEI10",.F.,"2") == "1"
Local lCmpPLS := SC7->(FieldPos("C7_LOTPLS")) > 0 .And. SC7->(FieldPos("C7_CODRDA")) > 0 

Local aRetMaFisAjIt   := {}

// Informacoes Adicionais do Documento

//Local aInfAdic := IIf(SF1->(FieldPos("F1_INCISS")) > 0, {CriaVar("F1_INCISS")},{})
Local oDescMun
Local cDescMun := ""

// foi alterado por causa do SIGAGSP.
aAdd(aTitles, OemToAnsi(STR0010)) //"Totais"
aAdd(aTitles, OemToAnsi(STR0011)) //"Inf. Fornecedor/Cliente"
aAdd(aTitles, OemToAnsi(STR0012)) //"Descontos/Frete/Despesas"
aAdd(aTitles, OemToAnsi(STR0014)) //"Livros Fiscais"
aAdd(aTitles, OemToAnsi(STR0015)) //"Impostos"
aAdd(aTitles, OemToAnsi(STR0013)) //"Duplicatas"

aFldCBAtu	:= Array(Len(aTitles)) // foi alterado por causa do SIGAGSP.

PRIVATE oLancApICMS
PRIVATE oFisRod
PRIVATE cDirf		:= Space(Len(SE2->E2_DIRF))
PRIVATE cCodRet		:= Space(Len(SE2->E2_CODRET))
PRIVATE l103Visual	:= .F.
PRIVATE lReajuste	:= .F.
PRIVATE lAmarra		:= .F.
PRIVATE lConsLoja	:= .F.
PRIVATE lPrecoDes	:= .F.
PRIVATE cTipo		:= ""
PRIVATE cFormul		:= ""
PRIVATE cNFiscal	:= ""
PRIVATE cSerie		:= ""
PRIVATE cA100For	:= ""
PRIVATE cLoja		:= ""
PRIVATE cEspecie	:= ""
PRIVATE cCondicao	:= ""
PRIVATE cForAntNFE	:= ""
PRIVATE dDEmissao	:= dDataBase
PRIVATE n			:= 1
PRIVATE nMoedaCor	:= 1
PRIVATE nTaxa       := 0
PRIVATE aCols		:= {}
PRIVATE aHeader		:= {}
PRIVATE aRatVei		:= {}
PRIVATE aRatFro		:= {}
PRIVATE aArraySDG	:= {}
PRIVATE aRatAFN		:= {}	//Variavel utilizada pela Funcao PMSDLGRQ - Gerenc. Projetos
PRIVATE aHdrAFN		:= {}	//Variavel utilizada pela Funcao PMSDLGRQ - Gerenc. Projetos (Cabecalho da aRatAFN)
PRIVATE aMemoSDE    := {}
PRIVATE aOPBenef    := {}
PRIVATE xUserData	:= NIL
PRIVATE lCondFor := .F.

PRIVATE bRefresh	:= {|nX| NfeFldChg(nX,nY,,aFldCBAtu)}
PRIVATE bGDRefresh	:= {|| IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.) }		// Efetua o Refresh da GetDados
PRIVATE oGetDados
PRIVATE oFolder
PRIVATE oFoco103
PRIVATE l240		:=.F.
PRIVATE l241		:=.F.
PRIVATE aBaseDup
PRIVATE aBackColsSDE:={}
PRIVATE l103TolRec  := .F.
PRIVATE l103Class   := .F.
PRIVATE lMudouNum   := .F.
PRIVATE lNfMedic    := .F.
PRIVATE aColsD1		:=	aCols   
PRIVATE aHeadD1		:=	aHeader
PRIVATE cCodDiario  := ""
PRIVATE cAliasTPZ   := ""
PRIVATE cUfOrig		:= ""
PRIVATE bIRRefresh	:= {|nX| NfeFldChg(nX,oFolder:nOption,oFolder,aFldCBAtu)}
PRIVATE lContDCL   := .T.

//Variáveis para tratamento para aba de Duplicatas
PRIVATE dEmisOld	:= ""
PRIVATE cCA100ForOld:= ""
PRIVATE cCondicaoOld:= "" 
PRIVATE lMoedTit	:= (SuperGetMv("MV_MOEDTIT",.F.,"N") == "S")
PRIVATE dNewVenc	:= CTOD('  /  /  ')

//Tratamento PLS
PRIVATE lUsouLtPLS	:= .F.
PRIVATE cLotPLS		:= ""
PRIVATE cCodRDA		:= ""
PRIVATE cOpeLt		:= ""

PRIVATE aInfApurICMS := {}

PRIVATE aInfAdic := IIf(SF1->(FieldPos("F1_INCISS")) > 0, {CriaVar("F1_INCISS")},{})
DEFAULT lEstNfClass	:= .F.
&("M->F1_CHVNFE") := ""

If !Empty(aRotina[nOpcx][1])
	If STR0006 $ aRotina[nOpcx][1]	// "Excluir"
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
	EndIf
EndIf

dDtdigit 	:= IIf(SF1->(FieldPos('F1_DTDIGIT'))>0 .And. !Empty(SF1->F1_DTDIGIT),SF1->F1_DTDIGIT,SF1->F1_EMISSAO)

If ( Type("aAutoImp") == "U" )
	PRIVATE aAutoImp := {}
EndIf

If ( Type("aNFEDanfe") == "U" )
	PRIVATE aNFEDanfe := {}
EndIf

If ( Type("aDanfeComp") == "U" )
	Private aDanfeComp:= {}
Else
	aDanfeComp:= {}
EndIf

If nOpcX == 6
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario tem permissao de delecao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
		aArea2 := GetArea()
		SD1->(dbSeek(xFilial("SD1")+cDoc+cSer))
		While !SD1->(Eof()) .And. lRet .And. SD1->D1_DOC == cDoc .And. SD1->D1_SERIE == cSer
			If IsInCallStack("MATA103") //Documento de Entrada
				lRet := MaAvalPerm(1,{SD1->D1_COD,"MTA103",5})
			ElseIf IsInCallStack("MATA102N") // Remito de Entrada
				lRet := MaAvalPerm(1,{SD1->D1_COD,"MT102N",5})
			ElseIf IsInCallStack("MATA101N") // Factura de Entrada
				lRet := MaAvalPerm(1,{SD1->D1_COD,"MT101N",5})
			EndIf
			SD1->(dbSkip())
		End
		RestArea(aArea2)
		If !lRet
			Help(,,1,'SEMPERM')
		EndIf
	EndIf
	// Valida exclusao de NF gerada pelo SIGAGFE
	If SF1->(FieldPos("F1_ORIGEM"))>0 .And. !IsInCallStack("GFEA065") .And. Alltrim(SF1->F1_ORIGEM) $ "GFEA065"
		MsgAlert(STR0408) //"Notas geradas pelo módulo SIGAGFE não podem ser excluídas através dessa rotina."
		lRet := .F.
		Return lRet
	Endif
EndIf

If lRet
	//Exec.Block p/Executar Ponto de Entrada de Multiplas Naturezas - MT103MNT
	bBlockSev1	:= {|nX| A103MNat(@aHeadSev, @aColsSev)}     
	bBlockSev2  := {|nX| NfeTOkSEV(@aHeadSev, @aColsSev,.F.)}
	
	//Arquivo temporario utilizado na integracao com SIGAMNT
	aCAMPTPZ := {}
	AADD(aCAMPTPZ,{"TPZ_ITEM"   ,"C",04,0}) //Numero do item
	AADD(aCAMPTPZ,{"TPZ_CODIGO" ,"C",15,0}) //Codigo do produto
	AADD(aCAMPTPZ,{"TPZ_LOCGAR" ,"C",06,0}) //Localizacao
	AADD(aCAMPTPZ,{"TPZ_ORDEM"  ,"C",06,0}) //Ordem de servico
	AADD(aCAMPTPZ,{"TPZ_QTDGAR" ,"N",09,0}) //Quantidade de garantia
	AADD(aCAMPTPZ,{"TPZ_UNIGAR" ,"C",01,0}) //Unidade de garantia
	AADD(aCAMPTPZ,{"TPZ_CONGAR" ,"C",01,0}) //Tipo do contador da garantia
	AADD(aCAMPTPZ,{"TPZ_QTDCON" ,"N",09,0}) //Quantidade do contador da garantia
	
	cArqTPZ := CriaTrab(aCAMPTPZ)
	cAliasTPZ := GetNextAlias()
	dbUseArea(.T.,,cArqTPZ,cAliasTPZ,.f.)  
	cIndTrbTPZ := CriaTrab(Nil, .F.)
	  
	IndRegua(cAliasTPZ,cIndTrbTPZ,"TPZ_ITEM",,,STR0283) //"Selecionando Registros..."
	  
	If !InTransact()  
		dbClearIndex()
	EndIf    
	
	dbSetIndex(cIndTrbTPZ + OrdBagExt())
	
	cDelSDE := If(lEstNfClass,GetNewPar("MV_DELRATC","1"),"1")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenche automaticamente o fornecedor/loja ISS atraves do parâmetro                   ³
	//³MV_AUTOISS = {Fornecedor,Loja,Dirf,CodRet}                                            ³
	//³Apenas efetua o processamento se todas as posicoes do parametro estiverem preenchidas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAUTOISS <> NIL .And. Len(aAUTOISS) == 4	//Sempre vai entrar, o default eh todas as posicoes do array vazio, porem quando for
		//	vazio temos de manter a qtd de caracteres definidas na declaracao LOCAL das variaveis cFornIss,
		//	cLojaIss, cDirf e cCodRet, senao nao eh permitido a digitacao no rodape da NF devido ao tamanho
		//	ser ZERO (declaracao LOCAL do aAUTOISS).
		cFornIss	:= Iif (Empty (aAUTOISS[01]), cFornIss, aAUTOISS[01])
		cLojaIss	:= Iif (Empty (aAUTOISS[02]), cLojaIss, aAUTOISS[02])
		cDirf		:= Iif (Empty (aAUTOISS[03]), cDirf, aAUTOISS[03])
		cCodRet		:= Iif (Empty (aAUTOISS[04]), cCodRet, aAUTOISS[04])
	
		If !Empty( cCodRet )
			If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
				aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
			Else
				aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2]	:=	cCodRet
			EndIf
		EndIf
	
		// Somente ira preencher se o cadastro no SA2 existir
		If !SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
			cFornIss := Space(Len(SE2->E2_FORNECE))
			cLojaIss := Space(Len(SE2->E2_LOJA))
		Endif
	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
	//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
	//| cliente, assim verificando a necessidade de uma atualizacao     |
	//| nestes fontes. NAO REMOVER !!!							        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(FindFunction("SIGACUS_V") .And. SIGACUS_V() >= 20050512)
		Final(STR0218) //"Atualizar SIGACUS.PRW !!!"
	EndIf
	If !(FindFunction("SIGACUSA_V") .And. SIGACUSA_V() >= 20100201)
		Final(STR0219) //"Atualizar SIGACUSA.PRX !!!"
	EndIf
	If !(FindFunction("SIGACUSB_V") .And. SIGACUSB_V() >= 20050512)
		Final(STR0220) //"Atualizar SIGACUSB.PRX !!!"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao utilizada para verificar a ultima versao do ATUALIZADOR  ³
	//³ do dicionario do modulo de Compras necessario para o uso do     |
	//| recurso de grade produtos no MP10 Relese I deverá ser retirado  |
	//| no proximo Release da Versao quando o dicionario for Atualizado |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(FindFunction("UPDCOM01_V") .And. UPDCOM01_V() >= 20070820)
		Final(STR0275) // "Atualizar UPDCOM01_V.PRW ou checar o processamento deste UPDATE !!!"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o tratamento eh pela baixa e disabilita a altera ³
	//³ cao do tipo de retencao                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPccBaixa
		cModRetPis	:= "3"
	Endif	
	
	aBackSDE	:= If(Type('aBackSDE')=='U',{},aBackSDE)
	aAdd(aButtons, {'PEDIDO',{||A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE,aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda),aBackColsSDE:=ACLONE(aColsSDE)},OemToAnsi(STR0024+" - <F5> "),STR0061} ) //"Selecionar Pedido de Compra"
	aAdd(aButtons, {'pedido',{||A103ItemPC( NIL,NIL,NIL,lNfMedic,lConsMedic,aHeadSDE,@aColsSDE, ,@lTxNeg, @nTaxaMoeda),aBackColsSDE:=ACLONE(aColsSDE)},OemToAnsi(STR0025+" - <F6> "),STR0148} ) //"Selecionar Pedido de Compra ( por item )"
	If !lGspInUseM
		aAdd(aButtons, {'RECALC',{||A103NFORI()},OemToAnsi(STR0026+" - <F7> "),STR0062} ) //"Selecionar Documento Original ( Devolucao/Beneficiamento/Complemento )"
		If SD3->(FieldPos("D3_CHAVEF1")) > 0 .And. SuperGetMV("MV_PRNFBEN",.F.,.F.) .And. FindFunction("ARetBenef")
			SF5->(dbSetOrder(1))
			If SF5->(dbSeek(xFilial("SF5")+GetMV("MV_TMPAD")))
				aAdd(aButtons, {'RECALC',{||ARetBenef()},STR0396,STR0397} ) //"Retorno de Beneficiamento#Retorno Ben."
			EndIf
		EndIf
		aAdd(aButtons, {'bmpincluir',{||A103LoteF4()},OemToAnsi(STR0027+" - <F8> "),STR0149} ) //"Selecionar Lotes Disponiveis"
		If ! lPyme
			aAdd(aButVisual,{"budget",{|| a120Posic(cAlias,nReg,nOpcX,"NF")},OemToAnsi(STR0254),OemToAnsi(STR0303)}) //"Consulta Aprovacao"
		EndIf
		If ( aRotina[ nOpcX, 4 ] == 2 .Or. aRotina[ nOpcX, 4 ] == 6 ) .And. !AtIsRotina("A103TRACK")
			AAdd(aButtons  ,{ "bmpord1", {|| A103Track() }, OemToAnsi(STR0150), OemToAnsi(STR0150) } )  // "System Tracker"
			AAdd(aButVisual,{ "bmpord1", {|| A103Track() }, OemToAnsi(STR0150), OemToAnsi(STR0150) } )  // "System Tracker"
		EndIf 	

		If aRotina[ nOpcX, 4 ] == 2
			AAdd(aButVisual,{ "clips", {|| A103Conhec() }, STR0188, STR0189 } ) // "Banco de Conhecimento", "Conhecim."
		EndIf 	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite pesquisar docs de saida de devolucao para vincular   ³
	//³ com compra - Projeto Oleo e Gas                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNfVcOri .And. !Empty(SD1->(FieldPos("D1_NFVINC")))
		aAdd(aButtons, {"NOTE",{||NfeVincOri()},OemToAnsi(STR0295),STR0295} )//"Pesquisa Doc Saida - Vínculo" 
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para rotina automatica                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type('l103Auto') == 'U'
		PRIVATE l103Auto	:= .F.
	EndIf
	lWhenGet   := IIf(ValType(lWhenGet) <> "L" , .F. , lWhenGet)
	
	lConsMedic := FINDFUNCTION( "A103GCDISP" ) .And. A103GCDisp()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case aRotina[nOpcx][4] == 2
		l103Visual := .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)	
	Case aRotina[nOpcx][4] == 3
		l103Inclui	:= .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)		
	Case aRotina[nOpcx][4] == 4
		l103Class	:= .T.
		l103TolRec  := .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)		
	Case aRotina[nOpcx][4] == 5 .Or. aRotina[nOpcx][4] == 20 .or. aRotina[nOpcx][4] == 21
		l103Exclui	:= .T.
		l103Visual	:= .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica a chamada de exclusao via SIGAEIC                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRotina[ nOpcx, 4 ] == 20
			lExcViaEIC := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Encontra o nOpcx referente ao tipo 5 - Exclusao padrao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScan := AScan( aRotina, { |x| x[4] == 5 } ) )
				nOpcx := nScan
			EndIf 	
		EndIf 	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica a chamada de exclusao via SIGATMS                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRotina[ nOpcx, 4 ] == 21
			lExcViaTMS := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Encontra o nOpcx referente ao tipo 5 - Exclusao padrao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScan := AScan( aRotina, { |x| x[4] == 5 } ) )
				nOpcx := nScan
			EndIf 	
		EndIf
	
	OtherWise
		l103Visual := .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)	
	EndCase
	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementado o tratamento  para trazer o codigo de Retencao gravado na tabela³
	//|SE2 qdo ultilizada o parametro MV_VISDIRF=1                                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If lVisDirf .And. l103Visual
		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(dbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC))
		If !Empty(SE2->E2_DIRF) .And. !Empty(SE2->E2_CODRET)
			cDirf   := SE2->E2_DIRF
			cCodRet := SE2->E2_CODRET
				
			If !Empty( cCodRet )
				If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
					aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
				Else
					aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2]	:=	cCodRet
				EndIf
			EndIf
		EndIf	
	EndIf
	
	nRecSF1	 := IIF(INCLUI,0,SF1->(RecNo()))
	
	If l103Class
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica data da emissao de acordo com a data base           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dDataBase < SF1->F1_EMISSAO
			lContinua := .F.		
			Aviso(OemToAnsi(STR0119),OemToAnsi(STR0292),{"Ok"})//"Não é possível classificar notas emitidas posteriormente a data corrente do sistema."
		EndIf
		
		If lContinua
			If !Empty( nScanBsPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) ) .And. ;
					!Empty( nScanVlPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) ) .And. ;
					!Empty( nScanAlPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )		
				cCpBasePIS  := aRelImp[nScanBsPis,2]
				cCpValPIS   := aRelImp[nScanVlPis,2]
				cCpAlqPIS   := aRelImp[nScanAlPis,2]		
			EndIf
		
			If !Empty( nScanBsCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) ) .And. ;
					!Empty( nScanVlCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) ) .And. ;
					!Empty( nScanAlCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
				cCpBaseCOF  := aRelImp[nScanBsCOF,2]
				cCpValCOF   := aRelImp[nScanVlCOF,2]
				cCpAlqCOF   := aRelImp[nScanAlCOF,2]
			EndIf
		EndIf
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as Hot-keys da rotina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l103Auto .And. (l103Inclui .Or. l103Class .Or. lWhenGet)
		SetKey( VK_F4 , { || A103F4() } )
		SetKey( VK_F5 , { || A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE, aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda ),aBackColsSDE:=ACLONE(aColsSDE) } )
		SetKey( VK_F6 , { || A103ItemPC( NIL,NIL,NIL,lNfMedic,lConsMedic,aHeadSDE,@aColsSDE,,@lTxNeg, @nTaxaMoeda),aBackColsSDE:=ACLONE(aColsSDE) } )
		SetKey( VK_F7 , { || A103NFORI() } )
		SetKey( VK_F8 , { || A103LoteF4() } )	
		SetKey( VK_F9 , { |lValidX3| NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class,lValidX3),aBackColsSDE:=ACLONE(aColsSDE)})
		bKeyF12 := SetKey( VK_F12 , Nil )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o modulo de Projetos                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If IntePms()		// Integracao PMS
			SetKey( VK_F10, { || Eval(bPmsDlgNF)} )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o modulo de Transportes                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTMS()		// Integracao TMS
			SetKey( VK_F11, { || oGetDados:oBrowse:lDisablePaint:=.T.,A103RatVei(),oGetDados:oBrowse:lDisablePaint:=.F.} )
		EndIf
	ElseIf !l103Auto .Or. lWhenGet
		bKeyF12 := SetKey( VK_F12 , Nil )  
		If nOPCX<>6
			SetKey( VK_F9 , { |lValidX3| oGetDados:oBrowse:lDisablePaint:=.T.,NfeRATCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class,lValidX3),oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSDE:=ACLONE(aColsSDE) } )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o modulo de Projetos                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If IntePms()		// Integracao PMS
		aadd(aButtons	, {'PROJETPMS',{||Eval(bPmsDlgNF)},OemToAnsi(STR0029+" - <F10> "),OemToAnsi(STR0151)}) //"Projetos"
		aadd(aButVisual	, {'PROJETPMS',{||Eval(bPmsDlgNF)},OemToAnsi(STR0029+" - <F10> "),OemToAnsi(STR0151)}) //"Projetos"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o modulo de Transportes                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntTMS()		// Integracao TMS
		Aadd(aButtons	, {'CARGA'		,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103RATVEI(),oGetDados:oBrowse:lDisablePaint:=.F. },STR0030+" - <F11>" , STR0152}) //"Rateio por Veiculo/Viagem"
		Aadd(aButVisual	, {'CARGA'		,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103RATVEI(),oGetDados:oBrowse:lDisablePaint:=.F. },STR0030+" - <F11>", STR0152 }) //"Rateio por Veiculo/Viagem"
		Aadd(aButtons	, {'CARGASEQ'	,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103FROTA(),oGetDados:oBrowse:lDisablePaint:=.F. },STR0031,STR0153}) //"Rateio por Frota"
		Aadd(aButVisual	, {'CARGASEQ'	,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103FROTA(),oGetDados:oBrowse:lDisablePaint:=.F. },STR0031,STR0153}) //"Rateio por Frota"
	EndIf
	If !lGSPInUseM
		Aadd(aButtons	, {'S4WB013N' ,{||oGetDados:oBrowse:lDisablePaint:=.T.,NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class),oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSDE:=ACLONE(aColsSDE) },OemToAnsi(STR0032+" - <F9> "),STR0154} ) //"Rateio do item por Centro de Custo"
		Aadd(aButVisual	, {'S4WB013N' ,{||oGetDados:oBrowse:lDisablePaint:=.T.,NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class),oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSDE:=ACLONE(aColsSDE) },OemToAnsi(STR0032+" - <F9> "),STR0154} ) //"Rateio do item por Centro de Custo"
		aadd(aButVisual	, {"S4WB005N" ,{|| NfeViewPrd() },STR0142,STR0034}) //"Historico de Compras"
	EndIf	
	       
	If lPrjCni  
		If l103Inclui .or. l103Class
			Aadd(aButtons,{'DESTINOS',{|| F641RatFin("MATA103") },"Incluir Rateio Financeiro","Rat.Financ."}) 
		ElseIf l103Visual .or. l103Exclui
			Aadd(aButVisual,{'DESTINOS',{|| F641AltRat("MATA103",2) },"Visualizar Rateio Financeiro","Rat.Financ."}) 
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para exportar dados para EXCEL                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("RemoteType") .And. RemoteType() == 1
		aAdd(aButtons   , {PmsBExcel()[1],{|| DlgToExcel({ {"CABECALHO",OemToAnsi(STR0009),{RetTitle("F1_TIPO"),RetTitle("F1_FORMUL"),RetTitle("F1_DOC"),RetTitle("F1_SERIE"),RetTitle("F1_EMISSAO"),RetTitle("F1_FORNECE"),RetTitle("F1_LOJA"),RetTitle("F1_ESPECIE"),RetTitle("F1_EST")},{cTipo,cFormul,cNFiscal,cSerie,dDEmissao,cA100For,cLoja,cEspecie,cUfOrig}},{"GETDADOS",OemToAnsi(STR0190),aHeader,aCols},{"GETDADOS",OemToAnsi(STR0013),aHeadSE2,aColsSE2}})},PmsBExcel()[2],PmsBExcel()[3]})
		aAdd(aButVisual , {PmsBExcel()[1],{|| DlgToExcel({ {"CABECALHO",OemToAnsi(STR0009),{RetTitle("F1_TIPO"),RetTitle("F1_FORMUL"),RetTitle("F1_DOC"),RetTitle("F1_SERIE"),RetTitle("F1_EMISSAO"),RetTitle("F1_FORNECE"),RetTitle("F1_LOJA"),RetTitle("F1_ESPECIE"),RetTitle("F1_EST")},{cTipo,cFormul,cNFiscal,cSerie,dDEmissao,cA100For,cLoja,cEspecie,cUfOrig}},{"GETDADOS",OemToAnsi(STR0190),aHeader,aCols},{"GETDADOS",OemToAnsi(STR0013),aHeadSE2,aColsSE2}})},PmsBExcel()[2],PmsBExcel()[3]})
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecao de multas - SIGAGCT                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FINDFUNCTION( "A103GCDISP" ) .And. A103GCDisp()
		AAdd(aButtons, { "checked", {|| A103Multas(dDEmissao,cA100For,cLoja,aMultas) }, STR0249, STR0250 } )  //"Seleciona Multas", "Multas"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento p/ Nota Fiscal geradas no SIGAEIC            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l103Inclui .And. SF1->F1_IMPORT == "S"
		If !lExcViaEIC .And. l103Exclui
			Help( "", 1, "A103EXCIMP" )  // "Este documento nao pode ser excluido pois foi criado pelo SIGAEIC. A exclusao devera ser efetuada pelo SIGAEIC."
		Else
			A103NFEIC(cAlias,nReg,nOpcx)
		EndIf 	
		lContinua := .F.
	EndIf
	
	//Verifica se o Produto é do tipo armamento.
	If l103Exclui .And. SB5->(FieldPos("B5_TPISERV")) > 0
		 	
	 		aArea2 := GetArea()
	 		
	 		If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE))
		 		
		 		DbSelectArea('SB5')
				SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA
				
				If SB5->(DbSeek(xFilial('SB5')+SD1->D1_COD)) // Filial: 01, Código: 000001, Loja: 02
					If FindFunction("aT720Mov") .AND. SB5->B5_TPISERV=='2' 
	  					lRetorno := aT720Mov(SD1->D1_DOC,SD1->D1_SERIE)
	  					If !lRetorno
	  						lContinua := lRetorno
	  						Help( "", 1, "At720Mov" )	
	  					EndIf			
					ElseIf FindFunction("aT710Mov") .AND. SB5->B5_TPISERV=='1' 
	  					lRetorno := aT710Mov(SD1->D1_DOC,SD1->D1_SERIE)
	  					If !lRetorno
	  						lContinua := lRetorno
	  						Help( "", 1, "At710Mov" )	
	  					EndIf
	  				ElseIf FindFunction("aT730Mov") .AND. SB5->B5_TPISERV=='3' 
	  					lRetorno := aT730Mov(SD1->D1_DOC,SD1->D1_SERIE)
	  					If !lRetorno
	  						lContinua := lRetorno
	  						Help( "", 1, "At730Mov" )	
	  					EndIf		
					EndIf
					 
				EndIf
				
			EndIf
			
			RestArea(aArea2)
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Notas Fiscais NAO Classificadas geradas pelo SIGAEIC NAO deverao ser visualizadas no MATA103 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l103Visual .And. !Empty(SF1->F1_HAWB) .And. Empty(SF1->F1_STATUS)
		Aviso("A103NOVIEWEIC",STR0344,{"Ok"}) // "Este documento foi gerado pelo SIGAEIC e ainda NÃO foi classificado, para visualizar utilizar a opção classificar ou no Modulo SIGAEIC opção Desembaraço/recebimento de importação/Totais. Apos a classificação o documento pode ser visualizado normalmente nesta opção."
		lContinua := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTipo		:= IIf(l103Inclui,CriaVar("F1_TIPO",.F.),SF1->F1_TIPO)
	cFormul		:= IIf(l103Inclui,CriaVar("F1_FORMUL",.F.),SF1->F1_FORMUL)
	cNFiscal	:= IIf(l103Inclui,CriaVar("F1_DOC"),SF1->F1_DOC)
	cSerie		:= IIf(l103Inclui,CriaVar("F1_SERIE"),SF1->F1_SERIE)
	dDEmissao	:= IIf(l103Inclui,CriaVar("F1_EMISSAO"),SF1->F1_EMISSAO)
	cA100For	:= IIf(l103Inclui,CriaVar("F1_FORNECE",.F.),SF1->F1_FORNECE)
	cLoja		:= IIf(l103Inclui,CriaVar("F1_LOJA",.F.),SF1->F1_LOJA)
	cEspecie	:= IIf(l103Inclui,CriaVar("F1_ESPECIE"),SF1->F1_ESPECIE)
	cCondicao	:= IIf(l103Inclui,CriaVar("F1_COND"),SF1->F1_COND)
	cUfOrig		:= IIf(l103Inclui,CriaVar("F1_EST"),SF1->F1_EST)
	cRecIss		:= IIf(l103Inclui,CriaVar("F1_RECISS"),SF1->F1_RECISS)
	
	If lISSxMun .And. SF1->(FieldPos("F1_ESTPRES")) > 0 .And. SF1->(FieldPos("F1_INCISS")) > 0
		aInfISS[1,1] := IIf(l103Inclui,CriaVar("F1_INCISS"),SF1->F1_INCISS)
		aInfISS[1,3] := IIf(l103Inclui,CriaVar("F1_ESTPRES"),SF1->F1_ESTPRES)
		aInfAdic[1]  := aInfISS[1,1]
		cDescMun     := Posicione("CC2",1,xFilial("CC2")+aInfISS[1,3]+aInfISS[1,1],"CC2_MUN")
	ElseIf SF1->(FieldPos("F1_INCISS")) > 0
		aInfAdic[1] := IIf(l103Inclui,CriaVar("F1_INCISS"),SF1->F1_INCISS)
		cDescMun    := Posicione("CC2",3,xFilial("CC2")+aInfAdic[1],"CC2_MUN")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata codigo do diario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
		cCodDiario := IIf(l103Inclui,CriaVar("F1_DIACTB"),SF1->F1_DIACTB)
	EndIf
	
	If (!cTipo$"DB" .And. !Empty(cA100For) .And. cA100For+cLoja <> SA2->A2_COD+SA2->A2_LOJA)
		SA2->(DbSetOrder(1))
		SA2->(MsSeek(xFilial("SA2")+cA100For+cLoja))
	EndIf
	
	If cPaisLoc == "BRA"
		If l103Inclui
			aNFEletr  := {CriaVar("F1_NFELETR"),CriaVar("F1_CODNFE"),CriaVar("F1_EMINFE"),CriaVar("F1_HORNFE"),CriaVar("F1_CREDNFE"),CriaVar("F1_NUMRPS"),;
				    	  Iif(SF1->(FieldPos("F1_MENNOTA")) > 0,CriaVar("F1_MENNOTA"),Nil),;
				    	  Iif(SF1->(FieldPos("F1_MENPAD")) > 0,CriaVar("F1_MENPAD"),Nil)}
			If lNfeDanfe  
			    A103CheckDanfe(2)
				If l103Auto
					If aScan(aAutoCab,{|x| AllTrim(x[1])=="F1_TPFRETE"})>0
						aNFEDanfe[14]:=aAutoCab[aScan(aAutoCab,{|x| AllTrim(x[1])=="F1_TPFRETE"})][2]
					EndIF
				EndIf
			EndIf	
		Else
			aNFEletr  := {SF1->F1_NFELETR,SF1->F1_CODNFE,SF1->F1_EMINFE,SF1->F1_HORNFE,SF1->F1_CREDNFE,SF1->F1_NUMRPS,;
				    	  Iif(SF1->(FieldPos("F1_MENNOTA")) > 0,SF1->F1_MENNOTA,Nil),;
				    	  Iif(SF1->(FieldPos("F1_MENPAD")) > 0,SF1->F1_MENPAD,Nil)}
			If lNfeDanfe    
				A103CargaDanfe()
			EndIf	
		Endif
	Endif
	
	If l103Class .And. Empty(cCondicao) .And. SF1->F1_STATUS <> 'C'
		DbSelectArea("SA2")
		DbSetOrder(1)
		If MsSeek(xFilial("SA2")+cA100For+cLoja)
			cCondicao  := SA2->A2_COND
			lCondFor	:= .T.
		EndIf
		DbSelectArea("SF1")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis do pergunte                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX3()
	AjustaSX1()
	AjustaHlp()
	
	Pergunte("MTA103",.F.)
	//Carrega as variaveis com os parametros da execauto
	Ma103PerAut()
	
	lDigita     := (mv_par01==1)
	lAglutina   := (mv_par02==1)
	lReajuste   := (mv_par04==1)
	lAmarra     := (mv_par05==1)
	lGeraLanc   := (mv_par06==1)
	lConsLoja   := (mv_par07==1)
	IsTriangular(mv_par08==1)
	nTpRodape   := (mv_par09)
	lPrecoDes   := (mv_par10==1)
	lDataUcom   := (mv_par11==1)
	lAtuAmarra  := (mv_par12==1)
	lRatLiq     := (mv_par13==2)
	lRatImp     := (mv_par13==1 .And. mv_par14==2)
	If lContinua
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para adicao de campos memo do usuario       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "MT103MEM" )
			If Valtype(	aMemUser := ExecBlock( "MT103MEM", .F., .F. ) ) == "A"
				aEval( aMemUser, { |x| aAdd( aMemoSDE, x ) } )
			EndIf
		EndIf 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Template acionando ponto de entrada                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTMt103NFE
			ExecTemplate("MT103NFE",.F.,.F.,nOpcx)
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada no inicio do Documento de Entrada         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMt103NFE
			Execblock("MT103NFE",.F.,.F.,nOpcx)
		EndIf
		If l103Inclui .Or. l103Class
			If l103Class
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada na Classificacao da NF                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("MT100CLA")
					ExecBlock("MT100CLA",.F.,.F.)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Validacoes para Inclusao/Classificacao de NF de Entrada    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !NfeVldIni(l103Class,lGeraLanc,@lClaNfCfDv)
				lContinua := .F.
			EndIf
		ElseIf l103Exclui
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ As Validacoes para Exclusao de NF de Entrada serao aplicadas³
			//³ somente quando a NFE nao esteja Bloqueada.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !SF1->F1_STATUS $ "BC" 
				If !MaCanDelF1(nRecSF1,@aRecSC5,aRecSE2,Nil,Nil,Nil,Nil,aRecSE1,lExcViaEIC,lExcViaTMS)
					lContinua := .F.
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ As Validacoes para Exclusao de NF de Entrada serao aplicadas³
			//³ somente quando a O.S. no modulo de manutenca o de ativos    ³
			//³ esteja aberta.                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNgMnTes .And. lNgValOsLot .And. lContinua
				lContinua := NGVALOSLOT(nRecSF1)
			EndIf

			// quando a nota for de devolução, valida se já houve uma nova movimentaçao no equipamento
			If lContinua .And. SF1->F1_TIPO == 'D'.And. lHasLocEquip .And. !At800ExcD1( nRecSF1 ) 
				lContinua := .F.
			EndIf
			
		EndIf
	EndIf	
	If lContinua
		If !l103Inclui .And. !l103Auto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa as veriaveis utilizadas na exibicao da NF         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//NfeCabOk(l103Visual,/*oTipo*/,/*oNota*/,/*oEmissao*/,/*oFornece*/,/*oLoja*/,/*lFiscal*/,cUfOrig,aInfISS[1,1],aInfISS[1,3])
			
			If lISSxMun
				NfeCabOk(l103Visual,/*oTipo*/,/*oNota*/,/*oEmissao*/,/*oFornece*/,/*oLoja*/,/*lFiscal*/,cUfOrig,aInfISS[1,1],aInfISS[1,3])
			Else
				NfeCabOk(l103Visual,/*oTipo*/,/*oNota*/,/*oEmissao*/,/*oFornece*/,/*oLoja*/,/*lFiscal*/,cUfOrig)
			EndIf
	
		Else
			If !l103Inclui
				MaFisIni(SF1->F1_FORNECE,SF1->F1_LOJA,IIf(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,!l103Visual,,,,,,,,,,,,,,,,,dDEmissao)
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aBackSD1")=="U" .Or. Empty(aBackSD1)
			aBackSD1 := {}
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trava os registros do SF1 - Alteracao e Exclusao       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Class .Or. l103Exclui
			If !SoftLock("SF1")
				lContinua := .F.
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da exclusão da nota fiscal de entrada - NF-e SEFAZ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Exclui 
			If SF1->F1_FORMUL == "S" .And. "SPED"$cEspecie .And. lFimp .And. (cAlias)->F1_FIMP$"TS" //verificacao apenas da especie como SPED e notas que foram transmitidas ou impressoo DANFE
				//nHoras := SubtHoras( dDtdigit, SF1->F1_HORA, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
				nHoras := SubtHoras(IIF(SF1->(FieldPos("F1_DAUTNFE"))<>0 .And. !Empty(SF1->F1_DAUTNFE),SF1->F1_DAUTNFE,dDtdigit),IIF(SF1->(FieldPos("F1_HAUTNFE"))<>0 .And. !Empty(SF1->F1_HAUTNFE),SF1->F1_HAUTNFE,SF1->F1_HORA), dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
				If nHoras > nSpedExc .And. SF1->F1_STATUS<>"C"
					MsgAlert("Não foi possivel excluir a(s) nota(s), pois o prazo para o cancelamento da(s) NF-e é de " + Alltrim(STR(nSpedExc)) +" horas")
					lContinua := .F.
				ElseiF SF1->(FieldPos("F1_STATUS"))>0.And. SF1->F1_STATUS=="C" .And. l103Exclui
					Aviso(STR0327,STR0328,{"Ok"}) //Não foi possivel excluir a nota, pois a mesma já foi transmitida e encotra-se bloqueada. Será necessário realizar a primeiro a classificação da nota e posteriormente a exclusão!"		
					lContinua := .F.			
				Else	
					lContinua := .T.
			    EndIf
			EndIf
		EndIf
	
		If lContinua
			If l103Class .Or. l103Visual .Or. l103Exclui
				aadd(aTitles,(STR0034)) //"Historico"
	
				If !l103Class .And. !Empty( MaFisScan("NF_RECISS",.F.) )
					MaFisAlt("NF_RECISS",SF1->F1_RECISS)					
				EndIf
				cRecIss	:=	MaFisRet(,"NF_RECISS")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega o Array contendo os Registros Fiscais.(SF3)     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SF3")
				DbSetOrder(4)
				#IFDEF TOP
					If TcSrvType()<>"AS/400"
						lQuery    := .T.
						cAliasSF3 := "A103NFISCAL"
						aStruSF3  := SF3->(dbStruct())
	
						cQuery    := "SELECT SF3.*,SF3.R_E_C_N_O_ SF3RECNO "
						cQuery    += "  FROM "+RetSqlName("SF3")+" SF3 "
						cQuery    += " WHERE SF3.F3_FILIAL     = '"+xFilial("SF3")+"'"
						cQuery    += "   AND SF3.F3_CLIEFOR	   = '"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SF3.F3_LOJA	   = '"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SF3.F3_NFISCAL	   = '"+SF1->F1_DOC+"'"
						cQuery    += "   AND SF3.F3_SERIE	   = '"+SF1->F1_SERIE+"'"
						cQuery    += "   AND SF3.F3_FORMUL	   = '"+SF1->F1_FORMUL+"'"
						cQuery    += "   AND SF3.D_E_L_E_T_	   = ' ' "
						cQuery    += " ORDER BY "+SqlOrder(SF3->(IndexKey()))
	
						cQuery := ChangeQuery(cQuery)
	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
						For nX := 1 To Len(aStruSF3)
							If aStruSF3[nX,2]<>"C"
								TcSetField(cAliasSF3,aStruSF3[nX,1],aStruSF3[nX,2],aStruSF3[nX,3],aStruSF3[nX,4])
							EndIf
						Next nX
					Else
				#ENDIF						
					MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE)
					#IFDEF TOP
					EndIf
					#ENDIF
				While !Eof() .And. lContinua .And.;
						xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
						SF1->F1_FORNECE == (cAliasSF3)->F3_CLIEFOR .And.;
						SF1->F1_LOJA == (cAliasSF3)->F3_LOJA .And.;
						SF1->F1_DOC == (cAliasSF3)->F3_NFISCAL .And.;
						SF1->F1_SERIE == (cAliasSF3)->F3_SERIE
					If Substr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_FORMUL == SF1->F1_FORMUL
						aadd(aRecSF3,If(lQuery,(cAliasSF3)->SF3RECNO,SF3->(RecNo())))
					EndIf
					DbSelectArea(cAliasSF3)
					dbSkip()
				EndDo
				If lQuery
					DbSelectArea(cAliasSF3)
					dbCloseArea()
					DbSelectArea("SF3")
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta o Array contendo as registros do SDE           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SDE")
				DbSetOrder(1)		
				#IFDEF TOP
					If TcSrvType()<>"AS/400"
						lQuery    := .T.
						aStruSDE  := SDE->(dbStruct())
						cAliasSDE := "A103NFISCAL"
						cQuery    := "SELECT SDE.*,SDE.R_E_C_N_O_ SDERECNO "
						cQuery    += "  FROM "+RetSqlName("SDE")+" SDE "
						cQuery    += " WHERE SDE.DE_FILIAL	 ='"+xFilial("SDE")+"'"
						cQuery    += "   AND SDE.DE_DOC		 ='"+SF1->F1_DOC+"'"
						cQuery    += "   AND SDE.DE_SERIE	 ='"+SF1->F1_SERIE+"'"
						cQuery    += "   AND SDE.DE_FORNECE  ='"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SDE.DE_LOJA     ='"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SDE.D_E_L_E_T_  =' ' "
						cQuery    += " ORDER BY "+SqlOrder(SDE->(IndexKey()))
	
						cQuery := ChangeQuery(cQuery)
	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDE,.T.,.T.)
						For nX := 1 To Len(aStruSDE)
							If aStruSDE[nX,2]<>"C"
								TcSetField(cAliasSDE,aStruSDE[nX,1],aStruSDE[nX,2],aStruSDE[nX,3],aStruSDE[nX,4])
							EndIf
						Next nX
					Else
				#ENDIF
					MsSeek(xFilial("SDE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
					#IFDEF TOP
					EndIf
					#ENDIF
				While ( !Eof() .And. lContinua .And.;
						xFilial('SDE') == (cAliasSDE)->DE_FILIAL .And.;
						SF1->F1_DOC == (cAliasSDE)->DE_DOC .And.;
						SF1->F1_SERIE == (cAliasSDE)->DE_SERIE .And.;
						SF1->F1_FORNECE == (cAliasSDE)->DE_FORNECE .And.;
						SF1->F1_LOJA == (cAliasSDE)->DE_LOJA )
					If Empty(aBackSDE)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem do aHeader                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SX3")
						DbSetOrder(1)
						MsSeek("SDE")
						While ( !EOF() .And. SX3->X3_ARQUIVO == "SDE" )
							If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO"$SX3->X3_CAMPO
								aadd(aBackSDE,{ TRIM(X3Titulo()),;
									SX3->X3_CAMPO,;
									SX3->X3_PICTURE,;
									SX3->X3_TAMANHO,;
									SX3->X3_DECIMAL,;
									SX3->X3_VALID,;
									SX3->X3_USADO,;
									SX3->X3_TIPO,;
									SX3->X3_F3,;
									SX3->X3_CONTEXT })
							EndIf
							DbSelectArea("SX3")
							dbSkip()
						EndDo
					EndIf
					aHeadSDE  := aBackSDE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ADHeadRec("SDE",aHeadSDE)
	
					aadd(aRecSDE,If(lQuery,(cAliasSDE)->SDERECNO,SDE->(RecNo())))
					If cItemSDE <> 	(cAliasSDE)->DE_ITEMNF
						cItemSDE	:= (cAliasSDE)->DE_ITEMNF
						aadd(aColsSDE,{cItemSDE,{}})
						nItemSDE++
					EndIf
	
					aadd(aColsSDE[nItemSDE][2],Array(Len(aHeadSDE)+1))
					For nY := 1 to Len(aHeadSDE)
						If IsHeadRec(aHeadSDE[nY][2])
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := IIf(lQuery , (cAliasSDE)->SDERECNO , SDE->(Recno())  )
						ElseIf IsHeadAlias(aHeadSDE[nY][2])
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := "SDE"
						ElseIf ( aHeadSDE[nY][10] <> "V")
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := (cAliasSDE)->(FieldGet(FieldPos(aHeadSDE[nY][2])))
						Else
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := (cAliasSDE)->(CriaVar(aHeadSDE[nY][2]))
						EndIf
						aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][Len(aHeadSDE)+1] := .F.
					Next nY
	
					DbSelectArea(cAliasSDE)
					dbSkip()
				EndDo
				aBackColsSDE:=ACLONE(aColsSDE)
				If lQuery
					DbSelectArea(cAliasSDE)
					dbCloseArea()
					DbSelectArea("SDE")
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta o Array contendo as duplicatas SE2             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF1->F1_TIPO$"DB"
					cPrefixo := PadR( cPrefixo, Len( SE1->E1_PREFIXO ) )
					DbSelectArea("SE1")
					DbSetOrder(2)
					MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC)
					While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
							SF1->F1_FORNECE == SE1->E1_CLIENTE .And.;
							SF1->F1_LOJA == SE1->E1_LOJA .And.;
							cPrefixo == SE1->E1_PREFIXO .And.;
							SF1->F1_DOC == SE1->E1_NUM
						If (SE1->E1_TIPO $ MV_CRNEG)
							aadd(aRecSe1,SE1->(Recno()))
						EndIf
						DbSelectArea("SE1")
						dbSkip()
					EndDo
				Else
					If Empty(aRecSE2)
						cPrefixo := PadR( cPrefixo, Len( SE2->E2_PREFIXO ) )
						DbSelectArea("SE2")
						DbSetOrder(6)
						#IFDEF TOP
							If TcSrvType()<>"AS/400"
								lQuery    := .T.
								aStruSE2  := SE2->(dbStruct())
								cAliasSE2 := "A103NFISCAL"
								cQuery    := "SELECT SE2.*,SE2.R_E_C_N_O_ SE2RECNO "
								cQuery    += "  FROM "+RetSqlName("SE2")+" SE2 "
								cQuery    += " WHERE SE2.E2_FILIAL  ='"+xFilial("SE2")+"'"
								cQuery    += "   AND SE2.E2_FORNECE ='"+SF1->F1_FORNECE+"'"
								cQuery    += "   AND SE2.E2_LOJA    ='"+SF1->F1_LOJA+"'"
								cQuery    += "   AND SE2.E2_PREFIXO ='"+cPrefixo+"'"
								cQuery    += "   AND SE2.E2_NUM     ='"+SF1->F1_DUPL+"'"
								cQuery    += "   AND SE2.E2_TIPO    ='"+MVNOTAFIS+"'"
								cQuery    += "   AND SE2.D_E_L_E_T_ =' ' "
								cQuery    += "ORDER BY "+SqlOrder(SE2->(IndexKey()))
	
								cQuery := ChangeQuery(cQuery)
	
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
								For nX := 1 To Len(aStruSE2)
									If aStruSE2[nX][2]<>"C"
										TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
									EndIf
								Next nX
							Else
						#ENDIF
							MsSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DUPL)
							#IFDEF TOP
							EndIf
							#ENDIF
						While ( !Eof() .And. lContinua .And.;
								xFilial("SE2")    == (cAliasSE2)->E2_FILIAL  		   .And.;
								SF1->F1_FORNECE   == (cAliasSE2)->E2_FORNECE 		   .And.;
								SF1->F1_LOJA      == (cAliasSE2)->E2_LOJA    		   .And.;
								AllTrim(cPrefixo) == AllTrim((cAliasSE2)->E2_PREFIXO) .And.;
								SF1->F1_DUPL      == (cAliasSE2)->E2_NUM )
								
								If AllTrim((cAliasSE2)->E2_TIPO) == AllTrim(MVNOTAFIS)
									aadd(aRecSE2,If(lQuery,(cAliasSE2)->SE2RECNO,(cAliasSE2)->(RecNo())))
								EndIf
								DbSelectArea(cAliasSE2)
							dbSkip()
						Enddo
						If lQuery
							DbSelectArea(cAliasSE2)
							dbCloseArea()
							DbSelectArea("SE2")
						EndIf
					EndIf
				EndIf
			EndIf
	
			If !l103Inclui
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a montagem do aCols com os dados do SD1                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD1")
				DbSetOrder(1)
				#IFDEF TOP        
					aStruSD1  := SD1->(dbStruct()) 
					If TcSrvType()<>"AS/400" .And. Ascan(aStruSD1,{|x| x[2] == "M" }) == 0
						lQuery    := .T.
						cAliasSD1 := "A103NFISCAL"
						cAliasSB1 := "A103NFISCAL"
						cQuery    := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO, B1_GRUPO,B1_CODITE,B1_TE,B1_COD "
						cQuery    += "  FROM "+RetSqlName("SD1")+" SD1, "
						cQuery    += RetSqlName("SB1")+" SB1 "					
						cQuery    += " WHERE SD1.D1_FILIAL	= '"+xFilial("SD1")+"'"
						cQuery    += "   AND SD1.D1_DOC		= '"+SF1->F1_DOC+"'"
						cQuery    += "   AND SD1.D1_SERIE	= '"+SF1->F1_SERIE+"'"
						cQuery    += "   AND SD1.D1_FORNECE	= '"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SD1.D1_LOJA	= '"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SD1.D1_TIPO	= '"+SF1->F1_TIPO+"'"
						cQuery    += "   AND SD1.D_E_L_E_T_	= ' '"
						cQuery    += "   AND SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"
						cQuery    += "   AND SB1.B1_COD 	= SD1.D1_COD "
						cQuery    += "   AND SB1.D_E_L_E_T_ =' ' " 					
	
						If (l103Class .And. lClassOrd) .Or. (l103Visual .And. lClassOrd) .Or. lNfeOrd
							cQuery    += "ORDER BY "+SqlOrder( "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD" )
						Else
							cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
						EndIf
	
						cQuery := ChangeQuery(cQuery)
	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
						For nX := 1 To Len(aStruSD1)
							If aStruSD1[nX][2]<>"C"
								TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
							EndIf
						Next nX
					Else
				#ENDIF
					lQuery := .F.
					MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
					#IFDEF TOP
					EndIf
					#ENDIF
	
				bWhileSD1 := { || ( !Eof().And. lContinua .And. ;
					(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
					(cAliasSD1)->D1_DOC == SF1->F1_DOC .And. ;
					(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
					(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
					(cAliasSD1)->D1_LOJA == SF1->F1_LOJA ) }
	
				If !lQuery .And. ((l103Class .And. lClassOrd) .Or. (l103Visual .And. lClassOrd) .Or. lNfeOrd)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Este procedimento eh necessario para fazer a montagem        ³
					//³ do acols na ordem ITEM + COD quando classificacao em CDX     ³
					//³ e o parametro MV_CLASORD estiver ativado                     ³				
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRecClasSD1 := {}
					While ( !Eof().And. lContinua .And. ;
							(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
							(cAliasSD1)->D1_DOC == SF1->F1_DOC .And. ;
							(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
							(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
							(cAliasSD1)->D1_LOJA == SF1->F1_LOJA )
	
						AAdd( aRecClasSD1, { ( cAliasSD1 )->D1_ITEM + ( cAliasSD1 )->D1_COD, ( cAliasSD1 )->( Recno() ) } )
	
					( cAliasSD1 )->( dbSkip() )
				EndDo 				

				ASort( aRecClasSD1, , , { |x,y| y[1] > x[1] } )

				nCounterSD1 := 1
				bWhileSD1 := { || nCounterSD1 <= Len( aRecClasSD1 ) .And. lContinua  }
			EndIf	
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Portaria CAT83  - Se o parâmetro não estiver ativo, não inclui o campo no acols ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SuperGetMv("MV_CAT8309",.F.,.F.)
			If SD1->(FieldPos("D1_CODLAN"))>0
				aAdd(aNoFields,"D1_CODLAN")
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FILLGETDADOS (Monstagem do aHeader e aCols)                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       ³
		//³				  cQuery, bMountFile, lInclui )                                                                ³
		//³nOpcx			- Opcao (inclusao, exclusao, etc).                                                         ³
		//³cAlias		- Alias da tabela referente aos itens                                                          ³
		//³nOrder		- Ordem do SINDEX                                                                              ³
		//³cSeekKey		- Chave de pesquisa                                                                            ³
		//³bSeekWhile	- Loop na tabela cAlias                                                                        ³
		//³uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar ³
		//³				  o registro)                                                                                  ³
		//³aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader                         ³
		//³aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader                         ³
		//³lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   ³
		//³cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     ³
		//³	           parametros cSeekKey e bSeekWhiele)                                                              ³
		//³bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     ³
		//³lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 ³
		//³aHeaderAux	-                                                                                              ³
		//³aColsAux		-                                                                                              ³
		//³bAfterCols	- Bloco executado apos inclusao de cada linha no aCols                                         ³
		//³bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols                                     ³
		//³bAfterHeader -                                                                                              ³
		//³cAliasQry	- Alias para a Query                                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFimp .And. SF1->F1_FIMP$'TS' .And. SF1->F1_STATUS='C' .And. l103Class//Tratamento para bloqueio de alteracoes na classificacao de uma nota bloqueada e ja transmitida.
			nOpcX:= 2			
			FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,{|| MontaaCols(bWhileSD1,lQuery,l103Class,lClassOrd,lNfeOrd,aRecClasSD1,@nCounterSD1,cAliasSD1,cAliasSB1,@aRecSD1,@aRateio,cCpBasePIS,cCpValPIS,cCpAlqPIS,cCpBaseCOF,cCpValCOF,cCpAlqCOF,@aHeader,@aCols,l103Inclui,aHeadSDE,aColsSDE,@lContinua) },Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/)
		Else
			FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,{|| MontaaCols(bWhileSD1,lQuery,l103Class,lClassOrd,lNfeOrd,aRecClasSD1,@nCounterSD1,cAliasSD1,cAliasSB1,@aRecSD1,@aRateio,cCpBasePIS,cCpValPIS,cCpAlqPIS,cCpBaseCOF,cCpValCOF,cCpAlqCOF,@aHeader,@aCols,l103Inclui,aHeadSDE,aColsSDE,@lContinua) },Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/)
        EndIf

		If lQuery
			DbSelectArea(cAliasSD1)
			dbCloseArea()
			DbSelectArea("SD1")
		EndIf
		If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compatibilizacao da Base X.07 p/ X.08       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(SF1->F1_RECBMTO) .And. !l103Class .And. !l103Visual
			MaFisAlt("NF_VALIRR",SF1->F1_IRRF,)
			MaFisAlt("NF_VALINS",SF1->F1_INSS,)
			MaFisAlt("NF_DESPESA",SF1->F1_DESPESA,)
			MaFisAlt("NF_FRETE",SF1->F1_FRETE,)
			MaFisAlt("NF_SEGURO",SF1->F1_SEGURO,)
		EndIf
		If !l103Class
			MaFisAlt("NF_FUNRURAL",SF1->F1_CONTSOC,)
		EndIf
		If l103Visual
			MaFisAlt("NF_TOTAL",SF1->F1_VALBRUT,)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRateio[1] <> 0
			MaFisAlt("NF_SEGURO",aRateio[1])
		EndIf
		If aRateio[2] <> 0
			MaFisAlt("NF_DESPESA",aRateio[2])
		EndIf
		If aRateio[3] <> 0
			MaFisAlt("NF_FRETE",aRateio[3])
		EndIf
		If aRateio[1]+aRateio[2]+aRateio[3] <> 0
			MaFisToCols(aHeader,aCols,,"MT100")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o Array contendo os Historico da NF                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHistor := A103Histor(SF1->(RecNo()))
	EndIf
	EndIf

	If (l103Inclui .Or. l103Class) .And. !l103Auto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PNEUAC - Ponto de Entrada definicao da Operacao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT103PN")
			If !Execblock("MT103PN",.F.,.F.,)
				lContinua := .F.
			EndIf
		EndIf
	EndIf
	If lContinua .And. !l103Auto .And. !Len(aCols) > 0
		lContinua := .F.
		Help(" ",1,"RECNO")
	EndIf
	If lContinua

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³********************A T E N C A O ***************************³
		//³Quando for feita manutencao em alguma VALIDACAO dos GETs,    ³
		//³atualize as funcoes que se encontram no array aValidGet      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If ( l103Auto )
			aValidGet := {}
			aVldBlock := {}
			aNFeAut	  := aClone(aNFEletr)
			aDanfe    := aClone(aNFEDanfe)
			aIISS	  := aClone(aInfISS)
			aAdd(aVldBlock,{||NFeTipo(cTipo,@cA100For,@cLoja)})
			aAdd(aVldBlock,{||NfeFormul(cFormul,@cNFiscal,@cSerie)})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_DOC")})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_SERIE")})
			aAdd(aVldBlock,{||CheckSX3('F1_EMISSAO') .And. NfeEmissao(dDEmissao)})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_FORNECE",cA100For)})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_LOJA",cLoja)})
			aAdd(aVldBlock,{||CheckSX3('F1_ESPECIE',cEspecie)})
			aAdd(aVldBlock,{||CheckSX3('F1_EST',cUfOrig)})
			aAdd(aVldBlock,{||Vazio(cNatureza).Or.(ExistCpo('SED',cNatureza).And.NfeVldRef("NF_NATUREZA",cNatureza)) .And. If(lMt103Nat,ExecBlock("MT103NAT",.F.,.F.,cNatureza),.T.)})
			For nX = 11 to 55
				aAdd(aVldBlock,"")
			Next nX

			If l103Inclui
				Aadd(aValidGet,{"cTipo"    ,aAutoCab[ProcH("F1_TIPO"),2],"Eval(aVldBlock[1])",.F.})
				Aadd(aValidGet,{"cFormul"  ,aAutoCab[ProcH("F1_FORMUL"),2],"Eval(aVldBlock[2])",.F.})
				Aadd(aValidGet,{"cNFiscal" ,aAutoCab[ProcH("F1_DOC"),2],"Eval(aVldBlock[3])",.F.})
				Aadd(aValidGet,{"cSerie"   ,aAutoCab[ProcH("F1_SERIE"),2],"Eval(aVldBlock[4])",.F.})
				Aadd(aValidGet,{"dDEmissao",aAutoCab[ProcH("F1_EMISSAO"),2],"Eval(aVldBlock[5])",.F.})
				Aadd(aValidGet,{"cA100For" ,aAutoCab[ProcH("F1_FORNECE"),2],"Eval(aVldBlock[6])",.F.})
				Aadd(aValidGet,{"cLoja"    ,aAutoCab[ProcH("F1_LOJA"),2],"Eval(aVldBlock[7])",.F.})
				Aadd(aValidGet,{"cEspecie" ,aAutoCab[ProcH("F1_ESPECIE"),2],"Eval(aVldBlock[8])",.F.})
				
				If ProcH("F1_MOEDA") > 0
					Aadd(aValidGet,{"nMoedaCor" ,aAutoCab[ProcH("F1_MOEDA"),2],"",.F.})
				EndIf
				
				If ProcH("F1_TXMOEDA") > 0
					Aadd(aValidGet,{"nTaxa"     ,aAutoCab[ProcH("F1_TXMOEDA"),2],"",.F.})
				EndIf
				
				If ProcH("F1_EST") > 0
					Aadd(aValidGet,{"cUfOrig"  ,aAutoCab[ProcH("F1_EST"),2],"Eval(aVldBlock[9])",.F.})
				EndIf

				If cPaisLoc == "BRA"
				    // NFE				    
					If ProcH("F1_NFELETR") > 0
						aVldBlock[11] := {||CheckSX3('F1_NFELETR',aNFeAut[01])}
						Aadd(aValidGet,{"aNFeAut[01]",aAutoCab[ProcH("F1_NFELETR"),2],"Eval(aVldBlock[11])",.F.}) 	 	
						aNFEletr[01] := aAutoCab[ProcH("F1_NFELETR"),2]
					Endif
					If ProcH("F1_CODNFE") > 0
						aVldBlock[12] := {||CheckSX3('F1_CODNFE',aNFeAut[02])}
						Aadd(aValidGet,{"aNFeAut[02]",aAutoCab[ProcH("F1_CODNFE"),2],"Eval(aVldBlock[12])",.F.}) 	 	
						aNFEletr[02] := aAutoCab[ProcH("F1_CODNFE"),2]
					Endif
					If ProcH("F1_EMINFE") > 0
						aVldBlock[13] := {||A103NFe('EMINFE',aNFeAut) .And. CheckSX3('F1_EMINFE',aNFeAut[03])}
						Aadd(aValidGet,{"aNFeAut[03]",aAutoCab[ProcH("F1_EMINFE"),2],"Eval(aVldBlock[13])",.F.}) 	 	
						aNFEletr[03] := aAutoCab[ProcH("F1_EMINFE"),2]
					Endif
					If ProcH("F1_HORNFE") > 0
						aVldBlock[14] := {||CheckSX3('F1_HORNFE',aNFeAut[04])}
						Aadd(aValidGet,{"aNFeAut[04]",aAutoCab[ProcH("F1_HORNFE"),2],"Eval(aVldBlock[14])",.F.}) 	 	
						aNFEletr[04] := aAutoCab[ProcH("F1_HORNFE"),2]
					Endif
					If ProcH("F1_CREDNFE") > 0
						aVldBlock[15] := {||A103NFe('CREDNFE',aNFeAut) .And. CheckSX3('F1_CREDNFE',aNFeAut[05])}
						Aadd(aValidGet,{"aNFeAut[05]",aAutoCab[ProcH("F1_CREDNFE"),2],"Eval(aVldBlock[15])",.F.}) 	 	
						aNFEletr[05] := aAutoCab[ProcH("F1_CREDNFE"),2]
					Endif
					If ProcH("F1_NUMRPS") > 0
						aVldBlock[16] := {||CheckSX3('F1_NUMRPS',aNFeAut[06])}
						Aadd(aValidGet,{"aNFeAut[06]",aAutoCab[ProcH("F1_NUMRPS"),2],"Eval(aVldBlock[16])",.F.}) 	 	
						aNFEletr[06] := aAutoCab[ProcH("F1_NUMRPS"),2]
					Endif
					If ProcH("F1_MENNOTA") > 0
						aVldBlock[29] := {||CheckSX3('F1_MENNOTA',aNFeAut[07])}
						Aadd(aValidGet,{"aNFeAut[07]",aAutoCab[ProcH("F1_MENNOTA"),2],"Eval(aVldBlock[29])",.F.}) 	 	
						aNFEletr[07] := aAutoCab[ProcH("F1_MENNOTA"),2]
					Endif
					If ProcH("F1_MENPAD") > 0
						aVldBlock[30] := {||CheckSX3('F1_MENPAD',aNFeAut[08])}
						Aadd(aValidGet,{"aNFeAut[08]",aAutoCab[ProcH("F1_MENPAD"),2],"Eval(aVldBlock[30])",.F.}) 	 	
						aNFEletr[08] := aAutoCab[ProcH("F1_MENPAD"),2]
					Endif    
					
					//Danfe
					If lNfeDanfe
						If ProcH("F1_TRANSP") > 0
		 					aVldBlock[17] := {|| ExistCpo("SA4",aDanfe[01],1,NIL,.T.)}
							Aadd(aValidGet,{"aDanfe[01]",aAutoCab[ProcH("F1_TRANSP"),2],"Eval(aVldBlock[17])",.F.}) 	 	
							aNfeDanfe[01] := aAutoCab[ProcH("F1_TRANSP"),2]
						Endif
					
						If ProcH("F1_PLIQUI") > 0
		 					aVldBlock[18] := {||CheckSX3('F1_PLIQUI',aDanfe[02])}
							Aadd(aValidGet,{"aDanfe[02]",aAutoCab[ProcH("F1_PLIQUI"),2],"Eval(aVldBlock[18])",.F.}) 	 	
							aNfeDanfe[02] := aAutoCab[ProcH("F1_PLIQUI"),2]
						Endif
					
						If ProcH("F1_PBRUTO") > 0
		 					aVldBlock[19] := {||CheckSX3('F1_PBRUTO',aDanfe[03])}
							Aadd(aValidGet,{"aDanfe[03]",aAutoCab[ProcH("F1_PBRUTO"),2],"Eval(aVldBlock[19])",.F.}) 	 	
							aNfeDanfe[03] := aAutoCab[ProcH("F1_PBRUTO"),2]
						Endif
					
						If ProcH("F1_ESPECI1") > 0
	 						aVldBlock[20] := {||CheckSX3('F1_ESPECI1',aDanfe[04])}
							Aadd(aValidGet,{"aDanfe[04]",aAutoCab[ProcH("F1_ESPECI1"),2],"Eval(aVldBlock[20])",.F.}) 	 	
							aNfeDanfe[04] := aAutoCab[ProcH("F1_ESPECI1"),2]
						Endif
					
						If ProcH("F1_VOLUME1") > 0
	 						aVldBlock[21] := {||CheckSX3('F1_VOLUME1',aDanfe[05])}
							Aadd(aValidGet,{"aDanfe[05]",aAutoCab[ProcH("F1_VOLUME1"),2],"Eval(aVldBlock[21])",.F.}) 	 	
							aNfeDanfe[05] := aAutoCab[ProcH("F1_VOLUME1"),2]
						Endif
						
						If ProcH("F1_ESPECI2") > 0
	 						aVldBlock[22] := {||CheckSX3('F1_ESPECI2',aDanfe[06])}
							Aadd(aValidGet,{"aDanfe[06]",aAutoCab[ProcH("F1_ESPECI2"),2],"Eval(aVldBlock[22])",.F.}) 	 	
							aNfeDanfe[06] := aAutoCab[ProcH("F1_ESPECI2"),2]
						Endif
					
						If ProcH("F1_VOLUME2") > 0
	 						aVldBlock[23] := {||CheckSX3('F1_VOLUME2',aDanfe[07])}
							Aadd(aValidGet,{"aDanfe[07]",aAutoCab[ProcH("F1_VOLUME2"),2],"Eval(aVldBlock[23])",.F.}) 	 	
							aNfeDanfe[07] := aAutoCab[ProcH("F1_VOLUME2"),2]
						Endif
						
						If ProcH("F1_ESPECI3") > 0
	 						aVldBlock[24] := {||CheckSX3('F1_ESPECI3',aDanfe[08])}
							Aadd(aValidGet,{"aDanfe[08]",aAutoCab[ProcH("F1_ESPECI3"),2],"Eval(aVldBlock[24])",.F.}) 	 	
							aNfeDanfe[08] := aAutoCab[ProcH("F1_ESPECI3"),2]
						Endif
					
						If ProcH("F1_VOLUME3") > 0
	 						aVldBlock[25] := {||CheckSX3('F1_VOLUME3',aDanfe[09])}
							Aadd(aValidGet,{"aDanfe[09]",aAutoCab[ProcH("F1_VOLUME3"),2],"Eval(aVldBlock[25])",.F.}) 	 	
							aNfeDanfe[09] := aAutoCab[ProcH("F1_VOLUME3"),2]
						Endif
					
						If ProcH("F1_ESPECI4") > 0
	 						aVldBlock[26] := {||CheckSX3('F1_ESPECI4',aDanfe[10])}
							Aadd(aValidGet,{"aDanfe[10]",aAutoCab[ProcH("F1_ESPECI4"),2],"Eval(aVldBlock[26])",.F.}) 	 	
							aNfeDanfe[10] := aAutoCab[ProcH("F1_ESPECI4"),2]
						Endif
					
						If ProcH("F1_VOLUME4") > 0
	 						aVldBlock[27] :=  {||CheckSX3('F1_VOLUME4',aDanfe[11])}
							Aadd(aValidGet,{"aDanfe[11]",aAutoCab[ProcH("F1_VOLUME4"),2],"Eval(aVldBlock[27])",.F.}) 	 	
							aNfeDanfe[11] := aAutoCab[ProcH("F1_VOLUME4"),2]
						Endif
					
						If ProcH("F1_PLACA") > 0
	 						aVldBlock[28] := {||CheckSX3('F1_PLACA',aDanfe[12])}
							Aadd(aValidGet,{"aDanfe[12]",aAutoCab[ProcH("F1_PLACA"),2],"Eval(aVldBlock[28])",.F.}) 	 	
							aNfeDanfe[12] := aAutoCab[ProcH("F1_PLACA"),2]
						Endif
					
						If ProcH("F1_CHVNFE") > 0
		 					aVldBlock[29] := {||CheckSX3('F1_CHVNFE',aDanfe[13]),A103ConsNfeSef()}
							Aadd(aValidGet,{"aDanfe[13]",aAutoCab[ProcH("F1_CHVNFE"),2],"Eval(aVldBlock[29])",.F.}) 	 	
							aNfeDanfe[13] := aAutoCab[ProcH("F1_CHVNFE"),2]
						Endif
						
						If ProcH("F1_TPFRETE") > 0
		 					aVldBlock[30] := {||CheckSX3('F1_TPFRETE',aDanfe[14])}
							Aadd(aValidGet,{"aDanfe[14]",aAutoCab[ProcH("F1_TPFRETE"),2],"Eval(aVldBlock[30])",.F.}) 	 	
							aNfeDanfe[14] := aAutoCab[ProcH("F1_TPFRETE"),2]
						Endif
						
						If ProcH("F1_VALPEDG") > 0
	 						aVldBlock[31] := {||CheckSX3('F1_VALPEDG',aDanfe[15])}
							Aadd(aValidGet,{"aDanfe[15]",aAutoCab[ProcH("F1_VALPEDG"),2],"Eval(aVldBlock[31])",.F.}) 	 	
							aNfeDanfe[15] := aAutoCab[ProcH("F1_VALPEDG"),2]
						Endif  
						
						If ProcH("F1_FORRET") > 0
	 						aVldBlock[32] := {||CheckSX3('F1_FORRET',aDanfe[16])}
							Aadd(aValidGet,{"aDanfe[16]",aAutoCab[ProcH("F1_FORRET"),2],"Eval(aVldBlock[32])",.F.}) 	 	
							aNfeDanfe[16] := aAutoCab[ProcH("F1_FORRET"),2]
						Endif  
						
						If ProcH("F1_LOJARET") > 0
	 						aVldBlock[33] := {||CheckSX3('F1_LOJARET',aDanfe[17])}
							Aadd(aValidGet,{"aDanfe[17]",aAutoCab[ProcH("F1_LOJARET"),2],"Eval(aVldBlock[33])",.F.}) 	 	
							aNfeDanfe[17] := aAutoCab[ProcH("F1_LOJARET"),2]
						Endif
						
						If ProcH("F1_TPCTE") > 0
		 					aVldBlock[34] := {||CheckSX3('F1_TPCTE',aDanfe[18])}
							Aadd(aValidGet,{"aDanfe[18]",aAutoCab[ProcH("F1_TPCTE"),2],"Eval(aVldBlock[34])",.F.}) 	 	
							aNfeDanfe[18] := aAutoCab[ProcH("F1_TPCTE"),2]
						Endif  
						
						If ProcH("F1_FORENT") > 0
	 						aVldBlock[35] := {||CheckSX3('F1_FORENT',aDanfe[19])}
							Aadd(aValidGet,{"aDanfe[19]",aAutoCab[ProcH("F1_FORENT"),2],"Eval(aVldBlock[35])",.F.}) 	 	
							aNfeDanfe[19] := aAutoCab[ProcH("F1_FORENT"),2]
						Endif 
						
						If ProcH("F1_LOJAENT") > 0
	 						aVldBlock[36] := {||CheckSX3('F1_LOJAENT',aDanfe[20])}
							Aadd(aValidGet,{"aDanfe[20]",aAutoCab[ProcH("F1_LOJAENT"),2],"Eval(aVldBlock[36])",.F.}) 	 	
							aNfeDanfe[20] := aAutoCab[ProcH("F1_LOJAENT"),2]
						Endif 
						
						If ProcH("F1_NUMAIDF") > 0
	 						aVldBlock[37] := {||CheckSX3('F1_NUMAIDF',aDanfe[21])}
							Aadd(aValidGet,{"aDanfe[21]",aAutoCab[ProcH("F1_NUMAIDF"),2],"Eval(aVldBlock[37])",.F.}) 	 	
							aNfeDanfe[21] := aAutoCab[ProcH("F1_NUMAIDF"),2]
						Endif 
						
						If ProcH("F1_ANOAIDF") > 0
	 						aVldBlock[38] := {||CheckSX3('F1_ANOAIDF',aDanfe[22])}
							Aadd(aValidGet,{"aDanfe[22]",aAutoCab[ProcH("F1_ANOAIDF"),2],"Eval(aVldBlock[38])",.F.}) 	 	
							aNfeDanfe[22] := aAutoCab[ProcH("F1_ANOAIDF"),2]
						Endif 
						If ProcH("F1_MODAL") > 0
	 						aVldBlock[39] := {||CheckSX3('F1_MODAL',aDanfe[23])}
							Aadd(aValidGet,{"aDanfe[23]",aAutoCab[ProcH("F1_MODAL"),2],"Eval(aVldBlock[39])",.F.}) 	 	
							aNfeDanfe[23] := aAutoCab[ProcH("F1_MODAL"),2]
						Endif
					EndIf
						
					If cPaisLoc = "BRA" .And. lISSxMun .And. Ascan(aAutoCab,{|x| x[1] == 'A2_COD_MUN'}) > 0
						//DADOS DO MUNICIPIO
						aVldBlock[39] := {||CheckSX3('A2_COD_MUN',aIISS[1][1])}
						Aadd(aValidGet,{"aIISS[1][1]",aAutoCab[ProcH("A2_COD_MUN"),2],"Eval(aVldBlock[39])",.F.})
						aInfISS[1][1] := aAutoCab[ProcH("A2_COD_MUN"),2]
						
						aVldBlock[40] := {||CheckSX3('CC2_MUN',aIISS[1][2])}
						Aadd(aValidGet,{"aIISS[1][2]",aAutoCab[ProcH("CC2_MUN"),2],"Eval(aVldBlock[40])",.F.})
						aInfISS[1][2] := aAutoCab[ProcH("CC2_MUN"),2]
                        
						aVldBlock[41] := {||CheckSX3('CC2_EST',aIISS[1][3])}
						Aadd(aValidGet,{"aIISS[1][3]",aAutoCab[ProcH("CC2_EST"),2],"Eval(aVldBlock[41])",.F.})
						aInfISS[1][3] := aAutoCab[ProcH("CC2_EST"),2]

						aVldBlock[42] := {||CheckSX3('CC2_MDEDMA',aIISS[1][4])}
						Aadd(aValidGet,{"aIISS[1][4]",aAutoCab[ProcH("CC2_MDEDMA"),2],"Eval(aVldBlock[42])",.F.})
						aInfISS[1][4] := aAutoCab[ProcH("CC2_MDEDMA"),2]						
						
						aVldBlock[43] := {||CheckSX3('CC2_MDEDSR',aIISS[1][5])}
						Aadd(aValidGet,{"aIISS[1][5]",aAutoCab[ProcH("CC2_MDEDSR"),2],"Eval(aVldBlock[43])",.F.})
						aInfISS[1][5] := aAutoCab[ProcH("CC2_MDEDSR"),2]
						
						aVldBlock[44] := {||CheckSX3('CC2_PERMAT',aIISS[1][6])}
						Aadd(aValidGet,{"aIISS[1][6]",aAutoCab[ProcH("CC2_PERMAT"),2],"Eval(aVldBlock[44])",.F.})
						aInfISS[1][6] := aAutoCab[ProcH("CC2_PERMAT"),2]
						
						aVldBlock[45] := {||CheckSX3('CC2_PERSER',aIISS[1][7])}
						Aadd(aValidGet,{"aIISS[1][7]",aAutoCab[ProcH("CC2_PERSER"),2],"Eval(aVldBlock[45])",.F.})
						aInfISS[1][7] := aAutoCab[ProcH("CC2_PERSER"),2]
												
						//ISS APURADO						
						aVldBlock[46] := {||CheckSX3('D1_TOTAL',aIISS[2][1])}
						Aadd(aValidGet,{"aIISS[2][1]",aAutoCab[ProcH("D1_TOTAL"),2],"Eval(aVldBlock[46])",.F.})
						aInfISS[2][1] := aAutoCab[ProcH("D1_TOTAL"),2]
						
						aVldBlock[47] := {||CheckSX3('D1_ABATISS',aIISS[2][2])}
						Aadd(aValidGet,{"aIISS[2][2]",aAutoCab[ProcH("D1_ABATISS"),2],"Eval(aVldBlock[47])",.F.})
						aInfISS[2][2] := aAutoCab[ProcH("D1_ABATISS"),2]
						
						aVldBlock[48] := {||CheckSX3('D1_ABATMAT',aIISS[2][3])}
						Aadd(aValidGet,{"aIISS[2][3]",aAutoCab[ProcH("D1_ABATMAT"),2],"Eval(aVldBlock[48])",.F.})
						aInfISS[2][3] := aAutoCab[ProcH("D1_ABATMAT"),2]
						
						aVldBlock[49] := {||CheckSX3('D1_BASEISS',aIISS[2][4])}
						Aadd(aValidGet,{"aIISS[2][4]",aAutoCab[ProcH("D1_BASEISS"),2],"Eval(aVldBlock[49])",.F.})
						aInfISS[2][4] := aAutoCab[ProcH("D1_BASEISS"),2]
						
						aVldBlock[50] := {||CheckSX3('D1_VALISS',aIISS[2][5])}
						Aadd(aValidGet,{"aIISS[2][5]",aAutoCab[ProcH("D1_VALISS"),2],"Eval(aVldBlock[50])",.F.})
						aInfISS[2][5] := aAutoCab[ProcH("D1_VALISS"),2]
						
						//INSS APURADO
						aVldBlock[51] := {||CheckSX3('D1_TOTAL',aIISS[3][1])}
						Aadd(aValidGet,{"aIISS[3][1]",aAutoCab[ProcH("D1_TOTAL"),2],"Eval(aVldBlock[51])",.F.})
						aInfISS[3][1] := aAutoCab[ProcH("D1_TOTAL"),2]
						
						aVldBlock[52] := {||CheckSX3('D1_ABATINS',aIISS[3][2])}
						Aadd(aValidGet,{"aIISS[3][2]",aAutoCab[ProcH("D1_ABATINS"),2],"Eval(aVldBlock[52])",.F.})
						aInfISS[3][2] := aAutoCab[ProcH("D1_ABATINS"),2]
						                                                 
						aVldBlock[53] := {||CheckSX3('D1_AVLINSS',aIISS[3][3])}
						Aadd(aValidGet,{"aIISS[3][3]",aAutoCab[ProcH("D1_AVLINSS"),2],"Eval(aVldBlock[53])",.F.})
						aInfISS[3][3] := aAutoCab[ProcH("D1_AVLINSS"),2]
						
						aVldBlock[54] := {||CheckSX3('D1_BASEINS',aIISS[3][4])}
						Aadd(aValidGet,{"aIISS[3][4]",aAutoCab[ProcH("D1_BASEINS"),2],"Eval(aVldBlock[54])",.F.})
						aInfISS[3][4] := aAutoCab[ProcH("D1_BASEINS"),2]
						
						aVldBlock[55] := {||CheckSX3('D1_VALINS',aIISS[3][5])}
						Aadd(aValidGet,{"aIISS[3][5]",aAutoCab[ProcH("D1_VALINS"),2],"Eval(aVldBlock[55])",.F.})
						aInfISS[3][5] := aAutoCab[ProcH("D1_VALINS"),2]					
					EndIf
				Endif

				If !lWhenGet
					nOpc := 1  	
				EndIf
				If !SF1->(MsVldGAuto(aValidGet))
					nOpc := 0
				EndIf
				If ProcH("F1_COND") > 0
					cCondicao := aAutoCab[ProcH("F1_COND"),2]
				EndIf

				If ProcH("F1_RECISS") > 0
					cRecIss := aAutoCab[ProcH("F1_RECISS"),2]
				EndIf
				If ( nOpc == 1 .Or. lWhenGet ) .And. l103Inclui
					MaFisIni(cA100For,cLoja,IIf(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,.F.,,,,,,,,,,,,,,,,,dDEmissao)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza UF de Origem apos a inicializacao das rotinas fiscais ³			
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisAlt("NF_UFORIGEM",cUfOrig)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Especie do documento apos a inicializacao das rotinas fiscais ³			
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If(Type("cEspecie")<>"U" .And. cEspecie<>Nil)
					MaFisAlt("NF_ESPECIE",cEspecie)			
				EndIf
			Else
				If ALTERA .and. (cPaisLoc == "BRA") .and. lNfeDanfe .and. (ProcH("F1_CHVNFE") > 0)
 					aVldBlock[29] := {||CheckSX3('F1_CHVNFE',aDanfe[13])}
					Aadd(aValidGet,{"aDanfe[13]",aAutoCab[ProcH("F1_CHVNFE"),2],"Eval(aVldBlock[29])",.F.}) 	 	
					aNfeDanfe[13] := aAutoCab[ProcH("F1_CHVNFE"),2]
				Endif
				nOpc := 1	
			EndIf
			If nOpc == 1 .Or. lWhenGet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o preenchimento do campo D1_ITEM                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cItem := StrZero(1,Len(SD1->D1_ITEM))
				For nX := 1 To Len(aAutoItens)
					nY := aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})
					If nY == 0
						aSize(aAutoItens[nX],Len(aAutoItens[nX])+1)
						For nLoop := Len(aAutoItens[nX]) To 2 STEP -1
							aAutoItens[nX][nLoop]	:=	aAutoItens[nX][nLoop-1]
						Next nLoop
						aAutoItens[nX][1] := {"D1_ITEM", cItem, Nil}
					EndIf
					cItem := Soma1(cItem)
				Next nX
				If ProcH("F1_COND") > 0
					cCondicao := aAutoCab[ProcH("F1_COND"),2]
				EndIf
				If !Empty( ProcH( "E2_NATUREZ" ))
					cNatureza := aAutoCab[ProcH("E2_NATUREZ"),2]
					Eval(aVldBlock[10])
				EndIf
				If GetMV("MV_INTPMS",,"N") == "S"
					If GetMV("MV_PMSIPC",,2) == 1 //Se utiliza amarracao automatica dos itens da NFE com o Projeto
						For nX := 1 To Len(aAutoItens)				
							PMS103IPC(Val(aAutoItens[nX][aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})][2]))					
						Next nX
					Else
						If Empty(aAutoAFN)
							lRatAFN := .F.
						EndIf
						For nX := 1 To Len(aAutoAFN)
							If lRatAFN
								lRatAFN := !Empty(aAutoAFN[nX]) 
							EndIf
						Next nX
						If lRatAFN
							For nX := 1 To Len(aAutoItens)
								aRatAFN := aClone(aAutoAFN)
								If !PmsVldAFN(Val(aAutoItens[nX][aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})][2]))//Se as validacoes estiverem ok, continua o processo de amarracao
									aRatAFN := {}
									Exit
								EndIf
							Next nX
						EndIf							
					EndIf
				EndIf
				If !MsGetDAuto(aAutoItens,"A103LinOk",{|| A103TudOk()},aAutoCab,aRotina[nOpcx][4])
					If lWhenGet	 
						IF !IsBlind()
							MostraErro()
                        Else
							Aviso(STR0119,STR0157,{STR0148}, 2)
						EndIf
						lProcGet := .F.
					Endif	
					nOpc := 0
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿
				//³ Se o item estiver amarrado a um PC com rateio, copia rateio.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù
				If l103Auto
					nPosPC		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
					nPosItPC  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
					nPosRat  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_RATEIO"})
					nPosItNF	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
					If nPosPC > 0 .And. nPosItPc > 0 .And. nPosRat > 0
						If Empty(aHeadSDE)
							dbSelectArea("SX3")
							dbSetOrder(1)
							MsSeek("SDE")
							While !EOF() .And. (SX3->X3_ARQUIVO == "SDE")
								IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO"$SX3->X3_CAMPO
									AADD(aHeadSDE,{ TRIM(x3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT } )
								EndIf
								dbSelectArea("SX3")
								dbSkip()
							EndDo
						EndIf
						dbSelectArea("SC7")
						SC7->(dbSetOrder(1))
						For nX := 1 To Len(aCols)
							If !Empty(aCols[nX][nPosPC]) .And. !Empty(aCols[nX][nPosItPC]) .And. aCols[nX][nPosRat] == "1"
								If SC7->(MsSeek(xFilial("SC7")+aCols[nX][nPosPC]+aCols[nX][nPosItPC]))	
									RatPed2NF(aHeadSDE,@aColsSDE,aCols[nX][nPosItNF],SC7->(RecNo()))	
								EndIf
							EndIf
						Next nX
					EndIf
				EndIf
				
				For nX := 1 to Len(aAutoImp)
					MaFisAlt(aAutoImp[nX][1],aAutoImp[nX][2])
				Next nX
				If ProcH("F1_DESCONT") > 0 .And. !cTipo$"PI"
					MaFisAlt("NF_DESCONTO",aAutoCab[ProcH("F1_DESCONT"),2])
				EndIf
				If ProcH("F1_DESPESA") > 0
					MaFisAlt("NF_DESPESA",aAutoCab[ProcH("F1_DESPESA"),2])
				EndIf
				If ProcH("F1_SEGURO") > 0
					MaFisAlt("NF_SEGURO",aAutoCab[ProcH("F1_SEGURO"),2])
				EndIf
				If ProcH("F1_FRETE") > 0
					MaFisAlt("NF_FRETE",aAutoCab[ProcH("F1_FRETE"),2])
				EndIf
				If ProcH("F1_BASEICM") > 0
					MaFisAlt("NF_BASEICM",aAutoCab[ProcH("F1_BASEICM"),2])
				EndIf
				If ProcH("F1_VALICM") > 0
					MaFisAlt("NF_VALICM",aAutoCab[ProcH("F1_VALICM"),2])
				EndIf
				If ProcH("F1_BASEIPI") > 0
					MaFisAlt("NF_BASEIPI",aAutoCab[ProcH("F1_BASEIPI"),2])
				EndIf
				If ProcH("F1_VALIPI") > 0
					MaFisAlt("NF_VALIPI",aAutoCab[ProcH("F1_VALIPI"),2])
				EndIf
				If ProcH("F1_BRICMS") > 0
					MaFisAlt("NF_BASESOL",aAutoCab[ProcH("F1_BRICMS"),2])
				EndIf
				If ProcH("F1_ICMSRET") > 0
					MaFisAlt("NF_VALSOL",aAutoCab[ProcH("F1_ICMSRET"),2])
				EndIf
				If ProcH("F1_RECISS") > 0
					MaFisAlt("NF_RECISS",aAutoCab[ProcH("F1_RECISS"),2])
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajusta os dados de acordo com a nota fiscal original         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lWhenGet
					Ascan(aAutoItens,{|X| !Empty( nPosRec := Ascan(  x, { |Y| Alltrim( y[1] ) == "D1RECNO"}))} )
					If nPosRec > 0
						For nX := 1 to Len(aAutoItens)
							nPosRec := Ascan(aAutoItens[nX], { |y| Alltrim( y[1] ) == "D1RECNO"})						
							MaFisAlt("IT_RECORI",aAutoItens[nX,nPosRec,2],nX)
							MaFisAlt("NF_UFORIGEM",SF2->F2_EST)						
						Next
						MaFisToCols(aHeader,aCols,Len(aCols),'MT100')						
					Endif	
				Endif	

				If nOpc == 1 .Or. lWhenGet
					NfeFldFin(,l103Visual,aRecSE2,0,aRecSE1,@aHeadSE2,@aColsSE2,@aHeadSEV,@aColsSEV,@aFldCbAtu[6],NIL,@cModRetPIS,lPccBaixa,@lTxNeg,@cNatureza,@nTaxaMoeda)
					Eval(aFldCbAtu[6])
					Eval(bRefresh,6,6)
				EndIf
			EndIf
				
			//Se for Rotina Troca do modulo SIGALOJA, a funcao MaFisAjIt nao retorna um array preenchido
			If  nOpc == 1 .And. !( nModulo==12 .AND. FunName()=="LOJA720" ) .And. SuperGetMV("MV_EASY",.F.,"N") == "N" 
				//Gerando informacoes dos lanctos da apuracao de ICMS.
				For nX := 1 To Len(aAutoItens)
					aRetMaFisAjIt := MaFisAjIt( Val( aAutoItens[nX][ aScan( aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"} ) ][2] ) )
					If !Empty(aRetMaFisAjIt)
						aAdd(aInfApurICMS, aRetMaFisAjIt)
					EndIf
				Next nX
			EndIf

			If lWhenGet
				l103Auto := .F.
			EndIf		
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000054")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Tela da Nota fiscal de entrada                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!l103Auto .Or. lWhenGet) .And. lProcGet		
			aObjects 	:= {}
			aSizeAut	:= MsAdvSize(,.F.,400)
			AAdd( aObjects, { 0,    41, .T., .F. } )
			AAdd( aObjects, { 100, 100, .T., .T. } )
			AAdd( aObjects, { 0,    75, .T., .F. } )

			aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

			aPosObj := MsObjSize( aInfo, aObjects )
			aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
				{If(cPaisLoc<>"PTG",{8,35,75,100,194,220,260,280},{8,35,78,100,140,160,200,230,250,270}),;
				If( l103Visual .Or. l103Class .Or. !lConsMedic,{8,35,75,100,nPosGetLoja,194,220,260,280},{8,35,75,108,135,160,190,220,244,265} ) ,;
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,75,103,148,164,230,253},;
				{6,34,200,218,280},;
				{11,50,150,190},;
				{273,130,190,293,205},;
				{005,035,075,105,145,175,215,245},;
				{11,35,80,110,165,190},;
				{3,35,95,150,205,255,170,230,265,;
				55,115,155,217,185,245,280,167,222,272},;
				{3, 4}}) // 12 - Folder Informações Adicionais

			DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cTituloDlg Of oMainWnd PIXEL //"Documento de Entrada"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Objeto criado para receber o foco quando pressionado o botao confirma ³
			//³ da dialog. Usado para identificar quando foi pressionado o botao      ³
			//³ confirma, atraves do parametro passado ao lostfocus                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ 100000,100000 MSGET oFoco103 VAR cVarFoco SIZE 12,09 PIXEL OF oDlg
			oFoco103:Cargo := {.T.,.T.}
			oFoco103:Disable()			
			If (lFimp .And. SF1->F1_FIMP$'ST'.And. SF1->F1_STATUS='C')
				NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l103Class.Or.l103Visual,NIL,cUfOrig,.F.,,@nCombo,@oCombo,@cCodRet,@oCodRet,@lNfMedic,@aCodR,@cRecIss,@cNatureza)
            Else
 				NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l103Class.Or.l103Visual,NIL,cUfOrig,l103Class,,@nCombo,@oCombo,@cCodRet,@oCodRet,@lNfMedic,@aCodR,@cRecIss,@cNatureza)           
	        EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao com SIGAMNT - NG Informatica             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPORDEM := GDFieldPos("D1_ORDEM")
			If SuperGetMV("MV_NGMNTNO",.F.,"2") == "1" .And. !Empty(nPORDEM)
				STJ->(dbSetOrder(1))
				SC7->(dbSetOrder(19))
				SC1->(dbSetOrder(1))
				
				For nG := 1 To Len(aCols)
					//Se a Ordem de Servico nao estiver definida e a Ordem de Producao estiver preenchida, recebe a O.S. dela caso seja valida
					If Empty(aCols[nG,nPORDEM])
						If STJ->(dbSeek(xFilial("STJ")+SubStr(aCols[nG,GDFieldPos("D1_OP")],1,nTamTjOrd)))
							aCols[nG,nPORDEM] := STJ->TJ_ORDEM
						ElseIf 	SC7->(dbSeek(xFilial("SC7")+aCols[nG,GDFieldPos("D1_COD")]+aCols[nG,GDFieldPos("D1_PEDIDO")]+aCols[nG,GDFieldPos("D1_ITEMPC")])) .And. ;
								SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC)) .And. ;
							 	STJ->(dbSeek(xFilial("STJ")+SubStr(SC1->C1_OP,1,At("OS",SC1->C1_OP)-1)))
							aCols[nG,nPORDEM] := SubStr(SC1->C1_OP,1,At("OS",SC1->C1_OP)-1)
						EndIf
					EndIf
				Next nG
			EndIf

			oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A103LinOk','A103TudOk','+D1_ITEM',!l103Visual,,,,IIf(l103Class,Len(aCols),9999),,,,IIf(l103Class,'AllwaysFalse()',"NfeDelItem"))
			oGetDados:oBrowse:bGotFocus	:= bCabOk     
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida TES de Entrada Padrao do Produto na Classificacao de NF			  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Class
				nPosTes := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "D1_TES" })
				If !Empty(aCols[n][nPosTes])
 					SF4->(dbSetOrder(1))
					If SF4->(MsSeek(xFilial("SF4")+RetFldProd(SB1->B1_COD,"B1_TE")))
						If !RegistroOk("SF4",.F.)
							Aviso("A103NTES",STR0391+CHR(10)+STR0392+RetFldProd(SB1->B1_COD,"B1_TE"),{STR0163})
							aCols[n][nPosTes] := ""
			   			Endif              
					EndIf
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o pedido foi gerado pelo SIGAPLS								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCmpPLS .And. !lUsouLtPLS
				nPosPed := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "D1_PEDIDO" })
				If !Empty(aCols[n][nPosPed])
					dbSelectArea("SC7")
					SC7->(dbSetOrder(1))
					// Grava Lote do PLS e o codigo de RDA
					If SC7->(MsSeek(xFilial("SC7")+aCols[n][nPosPed])) .And. !Empty(SC7->C7_LOTPLS) .And. !Empty(SC7->C7_CODRDA)
						lUsouLtPLS 	:= .T.
						cLotPLS		:= SC7->C7_LOTPLS
						cCodRDA		:= SC7->C7_CODRDA
						cOpeLt      := Iif(SC7->(Fieldpos("C7_PLOPELT")) > 0,SC7->C7_PLOPELT,PLSINTPAD())
					Endif
 				Endif
			Endif	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apenas ira montar o folder de Nota Fiscal Eletronica se os campos existirem³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				Aadd(aTitles,STR0255) // "Nota Fiscal Eletrônica"
				nNFe 	:= 	Len(aTitles)
				If AliasInDic("CDA")
					aAdd(aTitles,STR0280)	//"Lançamentos da Apuração de ICMS"
					nLancAp	:=	Len(aTitles)
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Habilita o folder de conferencia fisica se necessario        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Visual .AND. !l103Exclui .AND. !Empty(SF1->F1_STATUS) .And. ((SA2->(FieldPos('A2_CONFFIS'))>0) .And. (((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "2") .Or. SA2->A2_CONFFIS == "2");
			.And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .Or. ;
			(cTipo == "B" .And. (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. (SuperGetMV("MV_TPCONFF",.F.,"1") == "2")))
				aadd(aTitles,STR0347) // "Conferencia Fisica"
				nConfNF := Len(aTitles)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apenas ira montar o folder de Informacoes Diversas se os campos existirem  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNfeDanfe .And. cPaisLoc == "BRA"
				Aadd(aTitles,STR0348) // "Informações DANFE"
				nInfDiv := 	Len(aTitles)
			EndIf	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apenas ira montar o folder de Informacoes Diversas se os campos existirem  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc = "BRA" .And. lISSxMun
				Aadd(aTitles,STR0395) // "Apuração ISS/INSS"
				nInfISS := 	Len(aTitles)
			EndIf				
			
			If Len(aInfAdic) > 0
				aAdd(aTitles, STR0407) //"Informações Adicionais"
				nInfAdic := 	Len(aTitles)
			EndIf
					
			oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
			oFolder:bSetOption := {|nDst| NfeFldChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}
			bRefresh := {|nX| NfeFldChg(nX,oFolder:nOption,oFolder,aFldCBAtu)}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Totalizadores                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			NfeFldTot(oFolder:aDialogs[1],a103Var,aPosGet[3],@aFldCBAtu[1])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Fornecedores                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[2]:oFont := oDlg:oFont
			NfeFldFor(oFolder:aDialogs[2],aInfForn,{aPosGet[4],aPosGet[5],aPosGet[6]},@aFldCBAtu[2])

			If !lGspInUseM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder das Despesas acessorias e descontos                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[3]:oFont := oDlg:oFont			
			 	If(lFimp .And. SF1->F1_FIMP$'ST'.And. SF1->F1_STATUS='C' .And. l103Class) //Tratamento para bloqueio de alteracoes na classificacao de uma nota bloqueada e ja transmitida.
			 		l103Visual := .T.
			 		NfeFldDsp(oFolder:aDialogs[3],a103Var,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			 		l103Visual := .F.
			 	Else
					NfeFldDsp(oFolder:aDialogs[3],a103Var,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			  	EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder dos Livros Fiscais                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[4]:oFont := oDlg:oFont	
				oLivro := MaFisBrwLivro(oFolder:aDialogs[4],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,53},.T.,IIf(!l103Class,aRecSF3,Nil), IIf(!lWhenGet , IIf( l103Class , .T. , l103Visual ) , .T. ) )
				aFldCBAtu[4] := {|| oLivro:Refresh()}         
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Impostos                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[5]:oFont := oDlg:oFont

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder do Financeiro                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			oFolder:aDialogs[6]:oFont := oDlg:oFont
			NfeFldFin(oFolder:aDialogs[6],l103Visual,aRecSE2,( aPosObj[3,4]-aPosObj[3,2] ) - 101,aRecSe1,@aHeadSE2,@aColsSE2,@aHeadSEV,@aColsSEV,@aFldCbAtu[6],NIL,@cModRetPIS,lPccBaixa,@lTxNeg,@cNatureza,@nTaxaMoeda)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ As Notas incluidas pelo MATA100 nao terao o rodape da MATXFIS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Visual .And. Empty(SF1->F1_RECBMTO) 
				oFisRod	:=	A103Rodape(oFolder:aDialogs[5])
			ElseIf (lFimp .And. SF1->F1_FIMP$'ST'.And. SF1->F1_STATUS='C' .And. l103Class) 				 //Tratamento para bloqueio de alteracoes na classificacao de uma nota bloqueada e ja transmitida.
				l103Visual := .T.
				oFisRod	:=	MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@bIPRefresh,l103Visual,@cFornIss,@cLojaIss,aRecSE2,@cDirf,@cCodRet,@oCodRet,@nCombo,@oCombo,@dVencIss,@aCodR,@cRecIss,@oRecIss)
			Else
				oFisRod	:=	MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@bIPRefresh,l103Visual,@cFornIss,@cLojaIss,aRecSE2,@cDirf,@cCodRet,@oCodRet,@nCombo,@oCombo,@dVencIss,@aCodR,@cRecIss,@oRecIss)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos historicos do Documento de entrada                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Visual .Or. l103Class
				oFolder:aDialogs[7]:oFont := oDlg:oFont
				@ 05,04 LISTBOX oHistor VAR cHistor ITEMS aHistor PIXEL SIZE ( aPosObj[3,4]-aPosObj[3,2] )-10,53 Of oFolder:aDialogs[7]
				Eval(bRefresh,oFolder:nOption)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada utilizado na classificação da nota para alterar Combobox ³
			//³ da aba Impostos que informa se gera DIRF e os códigos de retencao         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Class .And. ExistBlock("MT103DRF")
				aDirfRt := ExecBlock("MT103DRF",.F.,.F.,{nCombo,cCodRet,@oCombo,@oCodRet})		
				if len(aDirfRt) > 1
					for a:=1 to len(aDirfRt)
						nCombo  := aDirfRt[a][2]
						cCodRet := ""
						if nCombo = 1 
							cCodRet := aDirfRt[a][3]
						endif   
					    If !Empty(cCodRet) 
							If aScan(aCodR,{|aX| aX[4]==aDirfRt[a][1]})==0
							   aAdd( aCodR,{99, cCodRet,1,aDirfRt[a][1]})
							Else
							   aCodR[aScan(aCodR, {|aX| aX[4]==aDirfRt[a][1]})][2] := cCodRet
							EndIf
						EndIf
					next
				else
					nCombo  := Iif(aDirfRt[1][2] > 2, 2, aDirfRt[1][2])
					cCodRet := aDirfRt[1][3]
					If !Empty( cCodRet ) 
						If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
							aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
						Else
							aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2] :=	cCodRet
						EndIf
					EndIf
				Endif
				If ValType( oCombo ) == "O"
					oCombo:Refresh()
				Endif	
				If ValType( oCodRet ) == "O"
					oCodRet:Refresh()
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder com os dados da Nota Fiscal Eletronica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				oFolder:aDialogs[nNFe]:oFont := oDlg:oFont
				NfeFldNfe(oFolder:aDialogs[nNFe],@aNFEletr,{aPosGet[10],aPosGet[8]},@aFldCBAtu[3])
				
				If AliasIndic("CDA") .And. nLancAp>0
					oFolder:aDialogs[nLancAp]:oFont := oDlg:oFont
					oLancApICMS := a103xLAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@aHeadCDA,@aColsCDA,l103Visual,(l103Inclui.Or.l103Class))
					If lWhenGet
						Eval({||GetLanc()})
					EndIf
					If l103Class
						a103AjuICM()
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder de conferencia para os coletores                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nConfNF > 0  .And. SF1->(FieldPos("F1_STATCON")) > 0
				oFolder:aDialogs[nConfNF]:oFont := oDlg:oFont
				Do Case
				Case SF1->F1_STATCON $ "1 "
					cStatCon := STR0349 // "NF conferida"
				Case SF1->F1_STATCON == "0"
					cStatCon := STR0350 //"NF nao conferida"
				Case SF1->F1_STATCON == "2"
					cStatCon := STR0351 // "NF com divergencia"
				Case SF1->F1_STATCON == "3"
					cStatCon := STR0352 // "NF em conferencia"
				Case SF1->F1_STATCON == "4"
					cStatCon := "NF Clas. C/ Diver."
				EndCase
				nQtdConf := SF1->F1_QTDCONF
				@ 06 ,aPosGet[6,1] SAY STR0353 OF oFolder:aDialogs[nConfNF] PIXEL SIZE 49,09 // "Status"
				@ 05 ,aPosGet[6,2] MSGET oStatCon VAR Upper(cStatCon) COLOR CLR_RED OF oFolder:aDialogs[nConfNF] PIXEL SIZE 70,9 When .F.
				@ 25 ,aPosGet[6,1] SAY STR0354 OF oFolder:aDialogs[nConfNF] PIXEL SIZE 49,09 // "Conferentes"
				@ 24 ,aPosGet[6,2] MSGET oConf Var nQtdConf OF oFolder:aDialogs[nConfNF] PIXEL SIZE 70,09 When .F.
				@ 05 ,aPosGet[5,3] LISTBOX oList Fields HEADER "  ",STR0355,STR0356 SIZE 170, 48 OF oFolder:aDialogs[nConfNF] PIXEL // "Codigo","Quantidade Conferida"
				oList:BLDblclick := {||A103DetCon(oList,aListBox)}

				DEFINE TIMER oTimer INTERVAL 3000 ACTION (A103AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,,oTimer)) OF oDlg
				oTimer:Activate()

				@ 30 ,aPosGet[5,3]+180 BUTTON STR0357 SIZE 40 ,11  FONT oDlg:oFont ACTION (A103AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,.T.,oTimer)) OF oFolder:aDialogs[nConfNF] PIXEL When SF1->F1_STATCON == '2' .And. !lClaNfCfDv // "Recontagem"
				@ 42 ,aPosGet[5,3]+180 BUTTON STR0358 SIZE 40 ,11  FONT oDlg:oFont ACTION (A103DetCon(oList,aListBox)) OF oFolder:aDialogs[nConfNF] PIXEL // "Detalhes"

				A103AtuCon(oList,aListBox,oEnable,oDisable)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder com Informacoes Diversas              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNfeDanfe .And. cPaisLoc == "BRA"
				oFolder:aDialogs[nInfDiv]:oFont := oDlg:oFont
				NfeFldDiv(oFolder:aDialogs[nInfDiv],{aPosGet[9]})
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder com Informacoes ISS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA" .And. lISSxMun
				oFolder:aDialogs[nInfISS]:oFont := oDlg:oFont
				ISSFldDiv(oFolder:aDialogs[nInfISS],{aPosGet[11]},@aObjetos,@aInfISS)
				If l103Visual
					Eval(bRefresh)
				EndIf 
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder Informacoes Adicionais do Documeno    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aInfAdic) > 0
				oFolder:aDialogs[nInfAdic]:oFont := oDlg:oFont
				NfeFldAdic(oFolder:aDialogs[nInfAdic],{aPosGet[12]}, @aInfAdic, @oDescMun, @cDescMun)
			EndIf
			
			If lWhenGet .Or. l103Class
				Eval(bRefresh,oFolder:nOption)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transfere o foco para a getdados - nao retirar                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
			oFoco103:bGotFocus := { || oGetDados:oBrowse:SetFocus() }			

			aButControl := {{ |x,y| aColsSEV := aClone( x ), aHeadSEV := aClone( y ) }, aColsSev,aHeadSEV }
			
		    // Atenção: Conserve a ordem de execução dos ExecBlocks abaixo a fim de facilitar a compreenção
            // e manutenções futuras....!          
   			ACTIVATE MSDIALOG oDlg ON INIT (IIf(lWhenGet,oGetDados:oBrowse:Refresh(),Nil),;
				A103Bar(oDlg,{|| oFoco103:Enable(),oFoco103:SetFocus(),oFoco103:Disable(),;
				IIf(((!l103Inclui.And.!l103Class).Or.( Eval(bRefresh,6)          .And. ;
				If(l103Inclui.Or.l103Class,NfeTotFin(aHeadSE2,aColsSE2,.F.),.T.) .And. ;
				oGetDados:TudoOk()))											   .And. ;
				A103VldEXC(l103Exclui,cPrefixo)									   .And. ;  
				A103VldDanfe(aNFEDanfe)											   .And. ;
				a103xLOk() .And. oFoco103:Cargo[1]    							   .And. ;
				NfeVldSEV(oFoco103:Cargo[2],aHeader,aCols,aHeadSEV,aColsSEV)  	   .And. ;
			    EVAL(bBlockSev2)												   .And. ;
				    IIf(FindFunction("A103ChamaHelp") .And. ( l103Inclui .or. l103Class ),A103ChamaHelp(),.T.)	.And. ;
				NfeNextDoc(@cNFiscal,@cSerie,l103Inclui)   					   	   .And. ;
				A103TmsVld(l103Exclui) 					   					   	   .And. ;
				A103MultOk( aMultas, aColsSE2, aHeadSE2 )  					   	   .And. ; 
				A103VldGer( aNFEletr )                                             .And. ;
				A103VlIGfe( l103Inclui,l103Class, .F. ),;
				(nOpc:=1,oDlg:End()),Eval({||nOpc:=0,oFoco103:Cargo[1] :=.T.}))},;
				{||nOpc:=0,oDlg:End()},IIf(l103Inclui.Or.l103Class,aButtons,aButVisual),aButControl))
		EndIf
		
		If nOpc == 1 .And. (l103Inclui.Or.l103Class.Or.l103Exclui)

			If (ExistBlock("MT100AG"))
				ExecBlock("MT100AG",.F.,.F.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa a gravacao atraves nas funcoes MATXFIS         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisWrite(1)

			If A103Trava() .And. IIf(lIntegGFE .And. l103Exclui,ExclDocGFE(),.T.)

				#IFNDEF TOP
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Indregua para o PIS / COFINS / CSLL                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

							aFil10925 := {}
							aAreaSM0  := SM0->(GetArea())
							cEmpAtu   := SM0->M0_CODIGO
							cCGCSM0   := SM0->M0_CGC
							SM0->(DbSetOrder(1))
							SM0->(MsSeek(cEmpAnt))

					    //Se parametro "MV_PCCAGFR" existe com conteudo diferente de 1
						If cAglutFil == "2" .Or. cAglutFil == "3"
							Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAtu
								//Verifica se a filial tem o mesmo CGC/Raiz de CGC
								AAdd(aFil10925,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))
								SM0->(DbSkip())
							EndDo

						ElseIf ExistBlock( "MT103FRT" )
							aFil10925 := ExecBlock( "MT103FRT", .F., .F. )
						Else
							aFil10925 := { xFilial( "SE2" ) }  				
						EndIf				
						SM0->(RestArea(aAreaSM0))

						cIndex := CriaTrab(,.f.)
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega as filiais no filtro                                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
						cCond := "("
						For nLoop := 1 to Len( aFil10925 )
							cCond  += "E2_FILIAL='" + aFil10925[ nLoop ] + "' .OR. "
						Next nLoop 						
	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Retira o .OR. do final                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cCond  := Left( cCond, Len( cCond ) - 5 )
	
						cCond  += ") .AND. "                       				
						cCond  += "E2_FORNECE='"     + cA100For           + "'" 	
						If lLojaAtu
							cCond  += " .AND. E2_LOJA='"        + cLoja              + "'"
						Endif
	
						IndRegua("SE2",cIndex,"DTOS(E2_VENCREA)",, cCond,OemToAnsi(""))	
						nIndexSE2 := RetIndex("SE2")+1
	
						dbSetIndex(cIndex+OrdBagExt())
	
					#ENDIF			
	
					If lEstNfClass .And. cDelSDE == "3"  .And. (Len(aRecSDE) > 0)
						cDelSDE:=Str(Aviso(OemToAnsi(STR0236),STR0263,{STR0264,STR0265},2),1,0)
					EndIf
	
					// Valida retorno valido
					If !(cDelSDE $ "123")
						cDelSDE:="1"					
					EndIf
					If !l103Auto
						SetKey(VK_F4,Nil)
						SetKey(VK_F5,Nil)
						SetKey(VK_F6,Nil)
						SetKey(VK_F7,Nil)
						SetKey(VK_F8,Nil)
						SetKey(VK_F9,Nil)
						SetKey(VK_F10,Nil)
						SetKey(VK_F11,Nil)	
						SetKey(VK_F12,bKeyF12)
					EndIf
					Begin Transaction
						a103Grava(l103Exclui,lGeraLanc,lDigita,lAglutina,aHeadSE2,aColsSE2,aHeadSEV,aColsSEV,nRecSF1,aRecSD1,aRecSE2,aRecSF3,aRecSC5,aHeadSDE,aColsSDE,aRecSDE,.F.,.F.,,aRatVei,aRatFro,cFornIss,cLojaIss,A103TemBlq(l103Class), l103Class,cDirf,cCodRet,cModRetPIS,nIndexSE2,lEstNfClass,dVencIss,lTxNeg,aMultas,lRatLiq,lRatImp,aNFEletr,cDelSDE,aCodR,cRecIss,cAliasTPZ,aCtbInf,aNfeDanfe,@lExcCmpAdt, @aDigEnd,@lCompAdt,aPedAdt,aRecGerSE2,aInfAdic)
						If !lContDCL // Da Rollback na transacao caso ocorra algum erro quando existir o Template DCL
							DisarmTransaction()
						EndIf
						If !(l103Exclui .and. !lExcCmpAdt) .And. lContDCL
							a103GrvCDA(l103Exclui,"E",cEspecie,cFormul,cNFiscal,cSerie,cA100For,cLoja, aInfApurICMS)
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza dados dos complementos SPED automaticamente ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lMvAtuComp .And. l103Inclui
								AtuComp(cNFiscal,cSerie,cEspecie,cA100For,cLoja,"E",cTipo)
							EndIf
		
						Endif	
												
						If lIntegGFE .And. ( l103Inclui .Or. l103Class ) .And. (!l103Auto .Or. lWhenGet) .And. lProcGet .And. lContDCL
							A103VlIGfe( l103Inclui,l103Class, .T. )
						EndIf
						lContDCL := .T.
						// ----------------------------------------------------
						//  Atualiza os dados do movimento na locação de equipamentos
						If lHasLocEquip .And. SF1->F1_TIPO == 'D'
							At800AtNFEnt( l103Exclui )
						EndIf
						
					End Transaction
	                 
					//Verifica se está na versao 11.6 e se o endereçamento na produção está ativo.
				    IF lVer116 .And. lDistMov .And. Len(aDigEnd) > 0
				    	//Chama a rotina de endereçamento no recebimento / produção
						A103DigEnd(aDigEnd)
				    endif
	
					//Função que excluirá fisicamente as temporárias do banco de dados.
					If UPPER(Alltrim(TCGetDb()))=="POSTGRES"
						Fa050Drop()
					Endif
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa gravacao da contabilidade     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(l103Exclui .and. !lExcCmpAdt)
						If Len(aCtbInf) != 0      
						
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para tratamentos especificos     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                         
							If ( ExistBlock("MT103CTB") )			
								aMT103CTB := ExecBlock("MT103CTB",.F.,.F.,{aCtbInf,l103Exclui,lExcCmpAdt})
								If ( ValType(aMT103CTB) == "A" )
									aCtbInf := aClone(aMT103CTB)
								EndIf
							EndIf    
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Cria nova transacao para garantir atualizacao do documento ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Begin Transaction
							cA100Incl(aCtbInf[1],aCtbInf[2],3,aCtbInf[3],aCtbInf[4],aCtbInf[5],,,,aCtbInf[7],,aCtbInf[6])
							End Transaction		
						EndIf
						If lCompAdt	// Compensacao do Titulo a Pagar quando trata-se de pedido com Adiantamento
							A103CompAdR(aPedAdt,aRecGerSE2)
						EndIf
					Endif	
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Apaga o arquivo da Indregua                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					#IFNDEF TOP				
						RetIndex( "SE2" )
						FErase( cIndex+OrdBagExt() )
					#ENDIF		
	
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para a localizacao Mexico, sera processada a funcao do ponto de entrada MT100AGR no padrao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "MEX"
					PgComMex()
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Integracao o modulo ACD - Realiza o enderecamento automatico p/ o CQ 		³
				//³ na classificacao da nota						  							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(l103Exclui .and. !lExcCmpAdt)
	
					If lIntACD .And. FindFunction("CBMT100AGR")
						CBMT100AGR()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Template acionando ponto de entrada                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf ExistTemplate("MT100AGR")
						ExecTemplate("MT100AGR",.F.,.F.)
					EndIf			
					If ExistBlock("MT100AGR",.T.,.T.)
						ExecBlock("MT100AGR",.F.,.F.)
					EndIf			
				Endif	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chama a integracao via Mensagem unica TOTVS ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Chama o adapter na Inclusao, Alteracao (Classificacao) e Exclusao
				If l103Inclui .Or. l103Class .Or. l103Exclui
				   fwIntegDef("MATA103")
				EndIf
			    
                //Trade-Easy
			    //RRC - 18/07/2013 - Integração SIGACOM x SIGAESS: Geração automática das invoices e parcelas de câmbio a partir do documento de entrada
			    If GetMv("MV_COMSEIC",,.F.) .And. SF1->F1_TIPO == "N" .And. GetMv("MV_ESS0012",,.F.)
			       PS400BuscFat("A","SIGACOM",,SF1->F1_DOC,SF1->F1_SERIE,.T.)
			    EndIf	
			Else
				//Libera Lock de Pedidos Bloqueados//
				If Type("aRegsLock")<>"U"
					If Len(aRegsLock)>0
						A103UnlkPC()
					EndIf
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada para verificar se o usuário clicou no botão Cancelar no Documento de Entrada   		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("MT103CAN"))
					ExecBlock("MT103CAN",.F.,.F.)   
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO e apaga lancamentos de bloqueio nao utilizados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(l103Exclui .and. !lExcCmpAdt)
				PcoFinLan("000054")
				PcoFreeBlq("000054")
			Endif	
		EndIf
	EndIf
	MaFisEnd()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Destrava os registros na alteracao e exclusao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l103Class .Or. l103Exclui
		MsUnlockAll()
	EndIf
	If !l103Auto
		SetKey(VK_F4,Nil)
		SetKey(VK_F5,Nil)
		SetKey(VK_F6,Nil)
		SetKey(VK_F7,Nil)
		SetKey(VK_F8,Nil)
		SetKey(VK_F9,Nil)
		SetKey(VK_F10,Nil)
		SetKey(VK_F11,Nil)	
		SetKey(VK_F12,bKeyF12)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Protecao para evitar ERRORLOG devido ao fato do objeto oLancApICMS   ³
	//³ nao ser destruido corretamente ao termino da rotina. Todos os demais ³
	//³ objetos sao destruidos corretamente.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("oLancApICMS") == 'O'
		FreeObj(oLancApICMS)
	EndIf 
	
	If lPrjCni
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa array Divergencias                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  Type("_aDivPNF") != "U"
		   _aDivPNF := {}
		Endif                                                             
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto no final da rotina, para o usuario completar algum processo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(l103Exclui .and. !lExcCmpAdt)
		If ExistTemplate("MT103FIM")                          
			ExecTemplate("MT103FIM",.F.,.F.,{aRotina[nOpcX,4],nOpc})
		EndIf
		If ExistBlock("MT103FIM")                          
			Execblock("MT103FIM",.F.,.F.,{aRotina[nOpcX,4],nOpc})
		EndIf
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna ao valor original de maxcodes ( utilizado por MayiUseCode() ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetMaxCodes( nMaxCodes )
	
	dbSelectArea(cAliasTPZ)
	dbCloseArea()  
	FErase(cArqTPZ + GetDbExtension())
	FErase(cIndTrbTPZ + OrdBagExt())
EndIf
	
Return lRet


Static Function ProcH(cCampo)
Return aScan(aAutoCab,{|x|Trim(x[1])== cCampo })

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A103NFEic ³ Autor ³ Edson Maricate       ³ Data ³24.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Class/Visualizacao/Exclusao de NF SIGAEIC      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103NFEic(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103NFEic(cAlias,nReg,nOpcx)

DbSelectArea("SD1")
DbSetOrder(1)
MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Class/Visual/Exclusao)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
Case aRotina[nOpcx][4] == 2
	MATA100(,,2)
Case aRotina[nOpcx][4] == 4
	MATA100(,,4)
Case aRotina[nOpcx][4] == 5
	MATA100(,,5)
EndCase
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103TudOk ³ Autor ³ Edson Maricate        ³ Data ³08.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da TudoOk                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103Tudok()
Local aCodFol  	  := {}
Local aPrdBlq     := {}
Local cProdsBlq   := ""
Local cAlerta     := ""
Local cMRetISS    := GetNewPar("MV_MRETISS","1")
Local cVerbaFol	  := ""
Local cNatValid	  := MaFisRet(,"NF_NATUREZA")
Local lRestNFE	  := SuperGetMV("MV_RESTNFE")=="S"
Local nPValDesc   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Local nPosTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPosIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})
Local nPosNFOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
Local nPosItmOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
Local nPosSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
Local nPosTes     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nPosCfo     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CF"})
Local nPosPc      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosItPc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
Local nPosQtd     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosVlr     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPosOp      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_OP"})
Local nPosCod     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nPosMed     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMMED"})
Local nPosQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nItens      := 0
Local nPosAFN 	  := 0
Local nPosQtde	  := 0
Local nTotAFN	  := 0
Local nA		  := 0
Local nX          := 0
Local n_SaveLin
Local lGspInUseM  := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local lContinua	  := .T.
Local lPE		  := .T.
Local lRet        := .T.
Local lItensMed   := .F.
Local lItensNaoMed:= .F.
Local lEECFAT	  := SuperGetMv("MV_EECFAT",.F.,.F.)
Local lMT103PBLQ  := .F.
Local lF4VlZero	  := SF4->(FieldPos("F4_VLRZERO")) > 0
Local aAreaSC7    := SC7->(GetArea())    
Local aMT103GCT   := {}
Local aItensPC	  := {}
Local nY		  := 0
Local nItemPc	  := 0
Local nQtdItPc	  := 0
Local aAreaSX3	  := SX3->(GetArea())
Local lVldItPc	  := SuperGetMv("MV_VLDITPC",.F.,.F.)
Local lVerChv	  := SuperGetMv("MV_VCHVNFE",.F.,.F.)
Local cNFForn	  := ""
Local nNFNum	  := ""
Local nNFSerie	  := ""
Local lAvulsa	  := .F.
Local lVtrasef	  := SuperGetMv("MV_VTRASEF",.F.,"N") == "S"
Local aAreaSB5	  := {}

For nx:=1 to len(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o poder de terceiro                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nx][Len(aCols[nx])] .And. nPosNfOri > 0 .And. nPosSerOri > 0 .And. nPosIdentB6 > 0 .And. ;
			nPosQuant > 0 .And. nPosTotal > 0 .And. nPValDesc > 0 .And. nPosCod > 0 .And. nPosTES > 0 .And. ;
			lRet .And. !lGspInUseM

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o conteudo do aCols[nX][nPosIdentB6]         ³
		//³ confere com o do documento original (SD2) em casos onde  ³
		//³ o usuario altera manualmente o docto orignal ao retornar ³
		//³ devolucoes de beneficiamento pela opcao Retornar.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(DbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4") + aCols[nX][nPosTES]))

		If SF4->F4_PODER3 == "D"

			SD2->(DbSetOrder(4))
			SD2->(MsSeek(xFilial("SD2") + aCols[nX][nPosIdentB6]))
			If aCols[nX][nPosNfOri] + aCols[nX][nPosSerOri] <> SD2->D2_DOC + SD2->D2_SERIE
				cAlerta := STR0266 + aCols[nX][nPosCod]   + " " + chr(13)	//"O campo documento original do Produto "
				cAlerta += STR0267 + aCols[nX][nPosNfOri] + "." + chr(13)	//"foi alterado manualmente para o numero "
				cAlerta += STR0268 + " " + chr(13)	      					//"O sistema necessita que esta operação seja realizada atraves"
				cAlerta += STR0269 + " " + chr(13)					      	//"do botão SELECIONAR DOCUMENTO ORIGINAL - F7 para atualizar a"
				cAlerta += STR0270 + " " + chr(13)	      					//"baixa da tabela SB6."
				Aviso("IDENTSB6",cAlerta,{"Ok"})
				lRet := .F.
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Validacao utilizada para nao permitir que o usuario altere o     ³
			//| fornecedor quando utilizado devolucao de poder de terceiros,     |
			//| pois o fornecedor do documento de entrada deve ser o mesmo       |
			//| fornecedor informado no documento original. Somente quando utili-| 
			//| zada operacao triangular sera possivel alterar o fornecedor.     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. !IsTriangular(mv_par08==1)
				SD2->(DbSetOrder(4))
				If SD2->(MsSeek(xFilial("SD2") + aCols[nX][nPosIdentB6])) .And.;
				   SD2->D2_CLIENTE+SD2->D2_LOJA <> cA100for+cLoja
					cAlerta := IIf(cTipo=="B",STR0288,STR0284) + " " + cA100For + "/" + cLoja + " " + STR0285 + " " + chr(13)  //"O conteudo dos campos fornecedor/loja : ###### / ## esta incompativel"
					cAlerta += STR0286 + " " + chr(13) 												 							 //"com a amarração dos itens informados referente a devolução de poder de terceiros."
					cAlerta += IIf(cTipo=="B",STR0289,STR0287) + chr(13) 													     //"Por favor informe o fornecedor/loja correto."
				   	Aviso("IDENTSB6",cAlerta,{"Ok"})
					lRet := .F.					
				EndIf
			EndIf
		EndIf

	EndIf

	///////////////////////////////////
	// Valida qtde com a Integracao PMS
	If !aCols[nx][Len(aCols[nx])]
		If IntePms() .And. Len(aRatAFN)>0
			If Len(aHdrAFN) == 0
				aHdrAFN := FilHdrAFN()
			Endif
			nPosAFN  := Ascan(aRatAFN,{|x|x[1]==(StrZero(n,4))})
			nPosQtde := Ascan(aHdrAFN,{|x|Alltrim(x[2])=="AFN_QUANT"})
			nTotAFN	:= 0

			If nPosAFN>0 .And. nPosQtde>0 .And. nPosQuant>0
				For nA := 1 To Len(aRatAfn[nPosAFN][2])
					If !aRatAFN[nPosAFN][2][nA][LEN(aRatAFN[nPosAFN][2][nA])]
						nTotAFN	+= aRatAfn[nPosAFN][2][nA][nPosQtde]

						If !PmsVldTar("AFN", aHdrAFN, aRatAFN[nPosAFN][2]) .AND. PMSHLPAFN()
							Help("   ",1,"PMSUSRNFE")
							lRet := .F.
							Exit
						EndIf

					Endif
				Next nA
				If nTotAFN > aCols[n][nPosQuant]
					Help("   ",1,"PMSQTNF")
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o preenchimaneto da TES dos itens devido a importacao do pedido de compras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nx][Len(aCols[nx])]
		nItens ++
		If nPosCFO>0 .And. nPosTES>0 .And. Empty(aCols[nx][nPosCFO]) .Or. Empty(aCols[nx][nPosTES])
			Help("  ",1,"A100VZ")
			lRet := .F.
			Exit
		Endif

		If nPosCod>0 .And. nPosItem>0 .And. lRet .And. SB1->(MsSeek(xFilial("SB1")+aCols[nx][nPosCod])) .And. !RegistroOk("SB1",.F.)
			Aadd(aPrdBlq,aCols[nx][nPosItem])
		Endif

		If !Empty( nPosMed )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a existencia de itens de medicao junto com itens sem medicao               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lItensMed    := lItensMed .Or. aCols[ nX, nPosMed ] == "1"
			lItensNaoMed := lItensNaoMed .Or. aCols[ nX, nPosMed ] $ " |2"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada permite incluir itens não-pertinentes ao gct ou não.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistBlock("MT103GCT"))
				aMT103GCT := ExecBlock("MT103GCT",.F.,.F.,{aCols,nX,nPosMed}) 
				
				If ValType(aMT103GCT) == "A" 
					If Len(aMT103GCT) >= 1 .And. ValType(aMT103GCT[1]) == "L"
						lItensMed    := aMT103GCT[1]
					EndIf
					If Len(aMT103GCT) >= 2 .And. ValType(aMT103GCT[2]) == "L" 
						lItensNaoMed := aMT103GCT[2]
					EndIf	 
				EndIf  
			EndIf	            

			If lItensMed .And. lItensNaoMed
				Help( " ", 1, "A103MEDIC" )
				lRet := .F. 		
				Exit
			EndIf 		
		EndIf 	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os pedidos amarrados a NFE estao bloqueados "Classificacao" ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nx][Len(aCols[nx])] .And. lRet
		If l103Class .And. lRestNFE
			SC7->(dbSetOrder(14))
			If SC7->(dbSeek(xFilEnt(xFilial('SC7'))+aCols[nx,nPosPc]) )
				If SC7->C7_CONAPRO == 'B'
					Help( "", 1, "A120BLQ" )
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se o valor do desconto no item D1_VALDESC e maior ou igual ao valor total do item ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nX][Len(aCols[nX])] .And. lRet   
		If aCols[nX,nPValDesc] >= aCols[nX,nPosTotal] .And. aCols[nX,nPValDesc] <> 0
			If !lF4VlZero .Or. (lF4VlZero .And. SF4->F4_VLRZERO$"2 ")
				Aviso("A103VLDESC",STR0315,{"Ok"}) //"Existe algum item onde o valor de desconto é maior ou igual ao valor total do item, verifique o conteúdo do campo ou realize novo rateio do desconto no folder de descontos/Frete/Despesas."
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a Amarração com o Pedido de Compras Centralizado - Referente Central de Compras   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nX][Len(aCols[nX])] .And. lRet
	    If !A103ValPCC(nX)
	   		lRet := .F.
			Exit
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se um item de pedido de compras consta mais de uma vez nos itens do documento e ultrapassa a quantidade do PC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lVldItPc .And. !l103Class .And. !aCols[nX][Len(aHeader)+1] .And. !Empty(aCols[nX][nPosPc]) .And. !Empty(aCols[nX][nPosItPc])
		Aadd(aItensPC,{aCols[nX][nPosPc],aCols[nX][nPosItPc],aCols[nX][nPosQtd]})
		nItemPc  := 0
		nQtdItPc := 0
		For nY := 1 To Len(aItensPC)
			If aScan(aItensPC,{|x| x[1]==aCols[nX][nPosPc] .And. x[2]==aCols[nX][nPosItPc]},nY,1) > 0
				nItemPc++
				nQtdItPc += aItensPC[nY][3]
			EndIf
			If nItemPc > 1
				SC7->(dbSetOrder(1))
				If SC7->(dbSeek(xFilial('SC7')+aCols[nY,nPosPc]+aCols[nX][nPosItPc] ))
					If nQtdItPc > ( SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA) .And. !l103Auto
						Help( "", 1, "A103ITDUPL" )
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
	    Next nY
	EndIf
	
	If lRet
	    lRet := ( Empty(aCols[nX][nPosTES]) .Or. Iif(Posicione("SF4",1,xFilial("SF4")+aCols[nX][nPosTES],"F4_MSBLQL") == '1',;
		ExistCpo("SF4",Alltrim(aCols[nX][nPosTES]),1),.T.) )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--¿
    //³ Verifica se data do movimento n„o ‚ menor que data limite de   ³
	//³ movimentacao no financeiro configurada no parametro MV_DATAFIN |   								     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--Ù
	If Posicione("SF4",1,xFilial("SF4")+aCols[nX][nPosTES],"F4_DUPLIC") == "S"
		lRet:= DtMovFin()
	EndIf	
Next

If Len(aPrdBlq) > 0 .And. lRet
	If ExistBlock("MT103PBLQ")  
		lMT103PBLQ:=ExecBlock("MT103PBLQ",.F.,.F.,{aPrdBlq})
		If ValType(lMT103PBLQ)<>'L'
			lMT103PBLQ:=.F.       
		EndIf
		lRet:=lMT103PBLQ
	Else
		For nX:= 1 To Len(aPrdBlq)
			If nX == 1
				cProdsBlq := aPrdBlq[nX]
			Else
				cProdsBlq += " / "+aPrdBlq[nX]
			Endif	
		Next       
	
		Aviso("REGBLOQ",OemToAnsi(STR0204)+cProdsBlq,{STR0163}, 2) //"Itens Bloqueados: "
		lRet := .F.
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha empenho da OP e dispara o Alerta para continuar. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx:=1 to len(aCols)
	If nPosOp>0 .And. !aCols[nx][Len(aCols[nx])] .And. nX <> n
		If !lGspInUseM .And. lRet .And. !Empty(aCols[nx][nPosOp])
			If ! A103ValSD4(nx)
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf
Next 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impede a inclusao de documentos sem nenhum item ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItens == 0
	Help("  ",1,"A100VZ")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o preenchimento dos campos.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(ca100For) .Or. Empty(dDEmissao) .Or. Empty(cTipo) .Or. (Empty(cNFiscal).And.cFormul<>"S")
	Help(" ",1,"A100FALTA")
	lRet := .F.
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a condicao de pagamento.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(cCondicao) .And. cTipo<>"D"
	Help("  ",1,"A100COND")
	If ( Type("l103Auto") == "U" .Or. !l103Auto )
		oFolder:nOption := 6
	EndIf
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a natureza                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(MaFisRet(,"NF_NATUREZA")) .And. cTipo<>"D"
	If SuperGetMV("MV_NFENAT") .And. !SuperGetMV("MV_MULNATP")
		Help("  ",1,"A103NATURE")
		If ( Type("l103Auto") == "U" .Or. !l103Auto )
			oFolder:nOption := 6
		EndIf
		lRet := .F.
	EndIf
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Frete	                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !A103ValFrete()
	lRet:=.F.
EndIf

//Verifica se o Produto e do tipo Munição e se sua Unidade é Caixa
If FindFunction("At730Prod") .And. Alltrim(SF1->F1_ESPECIE) == "NFE" .And. SB5->(FieldPos("B5_TPISERV")) > 0
	
	aAreaSB5	:= SB5->(GetArea())	
	
	For nX := 1 To Len(aCols)

		DbSelectArea('SB5')
		SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA
		If SB5->(DbSeek(xFilial('SB5')+aCols[nX][nPosCod])) // Filial: 01, Código: 000001, Loja: 02
			
			If SB5->B5_TPISERV=='3' .AND. !At730Prod(aCols[nX][nPosCod])
				Help("  ",1,"AT730Prod")
				lRet := .F.
			EndIf
		EndIf
		
	Next nX
		
	RestArea(aAreaSB5)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o total da NF esta negativo devido ao valor do desconto |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMRetISS == "1"
	If MaFisRet(,"NF_TOTAL")<0  .Or. (MaFisRet(,"NF_BASEDUP")>0 .And. MaFisRet(,"NF_BASEDUP")-MaFisRet(,"NF_VALIRR")-MaFisRet(,"NF_VALINS")-MaFisRet(,"NF_VALISS")<0)
		Help("  ",1,'TOTAL')
		lRet := .F.
	EndIf
Else
	If MaFisRet(,"NF_TOTAL")<0  .Or. (MaFisRet(,"NF_BASEDUP")>0 .And. MaFisRet(,"NF_BASEDUP")-MaFisRet(,"NF_VALIRR")-MaFisRet(,"NF_VALINS")<0)
		Help("  ",1,'TOTAL')
		lRet := .F.
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
//³             MV_SIGAGSP - 0-Nao / 1-Integra                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
If SuperGetMV("MV_SIGAGSP",.F.,"0") == "1"
	If ! GSPF030()
		lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
		lContinua	:= lRet
	EndIf
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha bloqueio em algum item do pco qdo valida for por grade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If PcoBlqFim({{"000054","07"},{"000054","05"},{"000054","01"}})
		n_SaveLin := n
		For nx:=1 to len(aCols)
			If !aCols[nx][Len(aCols[nx])]
				n := nX
				If lRet
					Do Case
					Case cTipo == "B"
						lRet	:=	PcoVldLan("000054","07","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					Case cTipo == "D"
						lRet	:=	PcoVldLan("000054","05","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					OtherWise
						lRet	:=	PcoVldLan("000054","01","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					EndCase
				Endif
				If !lRet
					Exit
				EndIf	
			EndIf
		Next
		n := n_SaveLin
	EndIf
	If lRet
		Do Case
		Case cTipo == "B"
			lRet	:=	PcoVldLan("000054","20","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		Case cTipo == "D"
			lRet	:=	PcoVldLan("000054","19","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		OtherWise
			lRet	:=	PcoVldLan("000054","03","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		EndCase
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o PMS     											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. IntePms()
		For nX := 1 To Len(aCols)
			If aCols[nX][Len(aCols[nX])] // Item Deletado
				nPosAFN  := Ascan(aRatAFN,{|x|x[1]==(StrZero(nX,4))})
				If nPosAFN >  0
					aDel( aRatAFN, nPosAFN )
					aSize( aRatAFN, Len(aRatAFN)-1)
				Endif
			Endif
		Next nX
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o EEC     											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lRet .And. FindFunction("EECFAT3") .And. lEECFAT )
		lRet := EECFAT3("VLD",.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
	//³ Pontos de Entrada 											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
	If (ExistTemplate("MT100TOK"))
		lPE := ExecTemplate("MT100TOK",.F.,.F.,{lRet})
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf
	
	If nModulo == 72
		lPE := KEXF870(lRet)
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf

	If lRet .And. (Inclui .Or. l103Class) .And. !(cTipo$"DB") .And. SA2->(FieldPos("A2_NUMRA"))<>0 .And. SF1->(FieldPos("F1_NUMRA"))<>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida a verba quando pagto de autonomo                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SA2")
		DbSetOrder(1)
		If MsSeek(xFilial("SA2")+cA100For+cLoja) .And. !Empty(SA2->A2_NUMRA)
			SF4->(DbSetOrder(1))
			For nx:=1 to len(aCols)
				SF4->(MsSeek(xFilial("SF4") + aCols[nX][nPosTES]))
				If SF4->F4_DUPLIC == "S"
					dbSelectArea("SRV")
					dbSetOrder(2)
					MsSeek(xFilial("SRV") + "001",.T.)
					If Eof()
						Help("  ",1,"A103VERBAU")
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Identifica o funcionario                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  						DbSelectArea("SRA")
						DbSetOrder(13)
						If MsSeek(SA2->A2_NUMRA) .And. FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Obtem o codigo da verba                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cVerbaFol := aCodFol[218,001] //Pagamento de autonomos
						EndIf
					EndIf
					If Empty(cVerbaFol)
					   lRet := .F.
					EndIf
					Exit
				EndIf
			Next
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se documento de entrada tem condicao de pagamento com adiantamento                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
		If lRet .and. cPaisLoc $ "BRA|MEX" .and. AliasInDic("FIE") .and. AliasInDic("FR3")
			If A120UsaAdi(cCondicao) .and. !cTipo $ "B|D"
				lRet := A103Adiant(cCondicao,cA100For,cLoja)
			Endif	
		Endif	
	#ENDIF	

	If lRet	    
		If SED->(FieldPos("ED_TIPO")> 0) .and. !Empty(cNatValid)
			DbSelectArea("SED")
			DbSetOrder(1)
			DbSeek (xFilial("SED")+cNatValid)  
			
			If !Eof() .And. SED->ED_TIPO == "1"  
				Help("  ",1,"A103VLDNAT")
		     	lRet:= .F.
		 	EndIf
		EndIf  
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida obrigatoriedade de preenchimento do campo F1_CHVNFE   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. alltrim(cEspecie) $ "SPED|CTE"
		DbSelectArea("SX3")
		DbSetOrder(2)
		If MsSeek("F1_CHVNFE")
			If SX3->X3_VISUAL == "A" .And. X3Uso(SX3->X3_USADO) .And. (SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .And. Empty(aNfeDanfe[13])
				Aviso(STR0119,STR0393,{STR0163})
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. lVerChv .And. cFormul == "N" .And. !Empty(aNfeDanfe[13])
			cNFForn := SubStr(aNfeDanfe[13],7,14)			// CNPJ Emitente conforme manual Nota Fiscal Eletrônica
			nNFNota := Val(SubStr(aNfeDanfe[13],26,9))		// Número da nota conforme manual Nota Fiscal Eletrônica
			nNFSerie:= Val(SubStr(aNfeDanfe[13],23,3))		// Série da nota conforme manual Nota Fiscal Eletrônica
			If nNFSerie >= 890 .And. nNFSerie <= 899
				lAvulsa := .T.
			EndIf
			If ( AllTrim(SA2->A2_CGC) == cNFForn .Or. lAvulsa ) .And. Val(cNFiscal) == nNFNota .And. (Val(cSerie) == nNFSerie .Or. Existblock("M103ALTS"))
				lRet := .T.
			Elseif (cTipo == 'B' .Or. cTipo == 'D') .And. ( AllTrim(SA1->A1_CGC) == cNFForn .Or. lAvulsa ) .And. Val(cNFiscal) == nNFNota .And. (Val(cSerie) == nNFSerie .Or. Existblock("M103ALTS"))// tratamento para beneficiamento e devolução
				lRet := .T.
			Else
				Aviso(STR0119,STR0394,{STR0163})
				lRet := .F.
			EndIf
		ElseIf lRet .And. lVerChv .And. cFormul == "S" .And. !Empty(aNfeDanfe[13]) 
			Aviso(STR0119,STR0400,{STR0163})
			lRet := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida obrigatoriedade de preenchimento do campo F1_CHVNFE   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. lVtrasef .And. AllTrim(cEspecie) $ "SPED" .And. cFormul == "S"
		lRet := A103CODRSEF(aHeader,aCols)
	EndIf

	If (ExistBlock("MT100TOK"))
		lPE := ExecBlock("MT100TOK",.F.,.F.,{lRet})
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf    

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Bloqueia Pedidos Amarrados ao Processo e checa tolerancia ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		If ( INCLUI .Or. ALTERA) .And. !l103Class .And. Type("aRegsLock")<>"U" .And. FindFunction("A103LockPC")
			lRet := A103LockPC(aHeader,aCols)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a natureza informada esta bloqueado por ED_MSBLQL ou ED_MSBLQD ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If lRet
		SED->(dbSetOrder(1))
		If !Empty(cNatValid) .And. SED->(MsSeek(xFilial("SED")+cNatValid))
			If !RegistroOk("SED")
				lRet := .F.
			EndIf
    	EndIf
	EndIf

EndIf	
RestArea(aAreaSX3)
RestArea(aAreaSC7)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103LinOk  ³ Autor ³ Edson Maricate       ³ Data ³24.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de validacao da LinhaOk                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103LinOk()
Local aArea			:= GetArea()
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSF4		:= SF4->(GetArea())
Local aAreaSB6		:= SB6->(GetArea())
Local aSldSB6		:= {}
Local cAlerta       := ""
Local cRvSB5	    := ""
Local cBlqSG5	    := ""
Local cStatus		:= ""
Local lRet			:= .T.
Local nRet		    := 0
Local nX         	:= 0
Local nPosCod    	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nRevisao  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_REVISAO"})
Local nPosLocal  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
Local nPosPC     	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosQuant  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosVUnit  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPosTotal  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPValDesc  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Local nPosTes    	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nPosCfo    	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_CF"})
Local nPosItemPC 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
Local nPosOp     	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_OP"})
Local nPosIdentB6	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})
Local nPosNFOri  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
Local nPosItmOri 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
Local nPosSerOri 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
Local nPosLote   	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_NUMLOTE"})
Local nPosLoteCtl	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOTECTL"})
Local nPosDtvalid   := aScan(aHeader,{|x| Alltrim(x[2])=="D1_DTVALID"})
Local nPosConta  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_CONTA"})
Local nPosCC     	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})
Local nPosCLVL   	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_CLVL"})
Local nPosItemCTA	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMCTA"})
Local nPosItemNF	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nPosPCCENTR   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PCCENTR"})
Local nPosITPCCEN   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITPCCEN"})
Local nPosOrdem     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ORDEM"})
Local nQtdPoder3 	:= 0
Local nSldPoder3 	:= 0
Local nSldQtdDev 	:= 0
Local nSldVlrDev 	:= 0
Local nItensNf		:= 0
Local lPCNFE     	:= GetNewPar( "MV_PCNFE", .F. ) //-- Nota Fiscal tem que ser amarrada a um Pedido de Compra ?
Local lRevProd      := SuperGetMv("MV_REVPROD",.F.,.F.)         
Local lVer116       := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11)
Local cTesPcNf      := SuperGetMV("MV_TESPCNF") // Tes que nao necessita de pedido de compra amarrado
Local lGspInUseM 	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local nPreco        := 0
Local cAltPrcCtr    := A103PrCom()
Local nPosAFN  	    := 0
Local nPosQtde 	    := 0
Local nTotAFN		:= 0
Local nA			:= 0
Local cRetTes       := ""
Local cHelpPD3      := ""
Local lVlrZero		:= .F.
Local lF4VlZero		:= SF4->(FieldPos("F4_VLRZERO")) > 0
Local i				:= 0
Local lAvalPerm		:= FindFunction("MaAvalPerm")
Local lBlqLoc		:= FindFunction('AvalBlqLoc')
Local lVldNfo		:= FindFunction("A103VldNFO")
Local lNGLinok		:= FindFunction("NG103LINOK")
Local lNgMnTes		:= SuperGetMV("MV_NGMNTES",.F.,"N") == "S"
Local lNgMntPc		:= SuperGetMV("MV_NGMNTPC",.F.,"N") == "S"
Local lVldNfe		:= SuperGetMV("MV_VLDNFO",.F.,.F.) == .T.
Local lBloqSb6		:= SuperGetMv("MV_BLOQSB6",.F.,.F.)
Local lLibeSb6		:= SuperGetMv("MV_LIBESB6",.F.,.F.)
Local lPcFilEn		:= SuperGetMv("MV_PCFILEN")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| MV_LOTVENC - Parametro utilizado para verificar se       |
//| permite utilizar lotes com data de validade vencida.     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lLoteVenc	    := SuperGetMV("MV_LOTVENC") == "S"
Local lDAmarCt		:= SuperGetMV("MV_DAMARCT",.F.,.F.)
Local cVldPDev		:= SuperGetMV("MV_VLDPDEV",.F.,"T")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o ExecAuto MATA103 foi chamada atraves do TOTVS Colaboracao (MATA140I)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
Local lColab 	    := l103Auto .And. aScan(aAutoCab, {|x| x[1] == "COLAB" .And. x[2] == "S"}) > 0
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Ponto de entrada para alterar as TES que sao permitidas  |
//| na inclusao de nota avulsa (sem pedido de compra)        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT103TPC")
	cRetTes := ExecBlock("MT103TPC",.F.,.F.,{cTesPcNf})
	If ValType( cRetTes ) == "C"
		cTesPcNf := cRetTes
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica preenchimento dos campos da linha do acols      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CheckCols(n,aCols)
	SF4->(DbSetOrder(1))
	SC2->(DbSetOrder(1))
	If !aCols[n][Len(aCols[n])]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a permissao do armazem. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. lAvalPerm
			lRet := MaAvalPerm(3,{aCols[n][nPosLocal],aCols[n][nPosCod]})
		EndIf

		///////////////////////////////////
		// Valida qtde com a Integracao PMS
		If lRet .And. IntePms() .And. Len(aRatAFN)>0
			If Len(aHdrAFN) == 0
				aHdrAFN := FilHdrAFN()
			Endif
			nPosAFN  := Ascan(aRatAFN,{|x|x[1]==aCols[n][nPosItemNF]})
			nPosQtde := Ascan(aHdrAFN,{|x|Alltrim(x[2])=="AFN_QUANT"})
			nTotAFN	:= 0

			If (nPosAFN > 0) .And. (nPosQtde > 0)
				For nA := 1 To Len(aRatAfn[nPosAFN][2])
					If !aRatAFN[nPosAFN][2][nA][LEN(aRatAFN[nPosAFN][2][nA])]
						nTotAFN	+= aRatAfn[nPosAFN][2][nA][nPosQtde]
					EndIf
				Next nA
				If nPosQuant>0 .And.;
						nTotAFN > aCols[n][nPosQuant]

					Help("   ",1,"PMSQTNF")
					lRet := .F.
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando Informado Armazem em branco considerar o B1_LOCPAD   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. nPosLocal>0 .And. Empty(aCols[n][nPosLocal])
			SB1->(DbSetOrder(1))
			If nPosCod>0 .And.;
					SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosCod]))

				aCols[n][nPosLocal] := SB1->B1_LOCPAD
				If Valtype(l103Auto) == "L" .And. !l103Auto
					Aviso(OemToAnsi(STR0119),OemToAnsi(STR0225),{"Ok"}) //"O Armazem informado e Invalido, o campo sera ajustando com o armazem padrão do cadastro de produtos"
				EndIf	
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Flag que indica se o valor da nota fiscal podera ser zero   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. SF4->(MsSeek(xFilial("SF4")+aCols[n][nPostes])) .And. lF4VlZero
			lVlrZero	:=	Iif(SF4->F4_VLRZERO == "1", .T., .F.)
		Endif 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o produto est  sendo inventariado.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			Do Case
			Case nPosCod>0 .And. nPosLocal>0 .And.;
					BlqInvent(aCols[n][nPosCod],aCols[n][nPosLocal])

				Help(" ",1,"BLQINVENT",,aCols[n][nPosCod]+STR0058+aCols[n][nPosLocal],1,11) //" Almox: "
				lRet := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analisa se o tipo do armazem permite a movimentacao |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case  nPosCod>0 .And. nPosLocal>0 .And. nPosTes>0 .And. nPosOP>0  .And. ;
			      lBlqLoc .And. AvalBlqLoc(aCols[n][nPosCod],aCols[n][nPosLocal],aCols[n][nPosTES],,,,,,,aCols[n][nPosOp])
				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica os campos obrigatorios                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case (nPosCod>0 .And. Empty(aCols[n][nPosCod])) .Or. ;
					(nPosQuant>0 .And. nPosTes>0 .And. Empty(aCols[n][nPosQuant]).And.cTipo$"NDB".And.!MaTesSel(aCols[n,nPosTes])).Or. ;
					(nPosVUnit>0 .And. Empty(aCols[n][nPosVUnit]) .And. !lVlrZero) .Or. ;
					(nPosQuant>0 .And. nPosVUnit>0 .And. nPosTotal>0 .And. !Empty(aCols[n][nPosQuant]) .And. Empty(aCols[n][nPosTotal]) .And. ;
					 NoRound( aCols[n][nPosQuant] * aCols[n][nPosVUnit],TamSX3("D1_TOTAL")[2] ) <> aCols[n][nPosTotal]) .And. !lVlrZero .Or. ;
					(nPosQuant>0 .And. nPosVUnit>0 .And. nPosTotal>0 .And. Empty(aCols[n][nPosQuant]) .And. ( Empty(aCols[n][nPosVUnit]) .Or. ;
					 (Empty(aCols[n][nPosTotal]))) .And. !lVlrZero ) .Or.;
					(nPosCFO>0 .And. Empty(aCols[n][nPosCFO]))  .Or. ;
					(nPosLocal>0 .And. Empty(aCols[n][nPosLocal])).Or. ;
					(nPosTES>0 .And. Empty(aCols[n][nPosTES]))

				Help("  ",1,"A100VZ")
				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o codigo da TES                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nPosTes>0 .And.;
					aCols[n][nPosTes] > "500"

				Help("   ",1,"A100INVTES")
				lRet := .F.		

			Case nPostes>0 .And.;
					!SF4->(MsSeek(xFilial("SF4")+aCols[n][nPostes]))

				Help("   ",1,"D1_TES")
				lRet := .F.    

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o Pedido de compra                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nPosPc>0 .And. nPosItemPC>0 .And.;
					!Empty(aCols[n][nPosPc]) .And. Empty(aCols[n][nPosItemPC])

				Help("  ",1,"A100PC")
				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o valor total                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nPosTes>0 .And. nPosVUnit>0 .And. nPosQuant>0 .And. nPosTotal>0 .And. ;
					cPaisLoc <> "BRA".AND.cTipo <> "C" .And.!MaTesSel(aCols[n,nPosTes]) .And. ;
					Round(aCols[n][nPosVUnit]*aCols[n][nPosQuant],SuperGetMV("MV_RNDLOC")) <> Round(aCols[n][nPosTotal],SuperGetMV("MV_RNDLOC"))

				Help(" ",1,"A100VALOR")
				lRet := .F.		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o preenchimento da Nota Original           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nPosNFOri>0 .And.;
					!lGspInUseM .And. cTipo == 'D' .And. cPaisLoc <> "ARG" .And. Empty(aCols[n][nPosNFOri])

				Help("  ",1,"A100NFORI")
				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a Ratreabilidade                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case nPosNFOri>0 .And. nPosLote>0 .And.;
					!lGspInUseM .And. SF4->F4_ESTOQUE == "S" .And. cTipo == 'D' .And. (Rastro(aCols[n][nPosCod],"S")) .And. Empty(aCols[n][nPosLote])

				Help(" ",1,"A100S/LOT")
				lRet := .F.

			Case nPosCod>0 .And. nPosLoteCtl>0 .And.;
					!lGspInUseM .And. SF4->F4_ESTOQUE == "S" .And. cTipo == 'D' .And. (Rastro(aCols[n][nPosCod],"L")) .And. Empty(aCols[n][nPosLoteCtl])

				Help(" ",1,"A100S/LOT")
				lRet := .F.		
			// Valida o preenchimento de D1_LOTECTL para produtos que nao controlam Rastro
			Case nPosCod>0 .And. nPosLoteCtl>0 .And. nPosLote>0 .And. (Rastro(aCols[n][nPosCod],"N")) .And. (!Empty(aCols[n][nPosLoteCtl]) .Or. !Empty(aCols[n][nPosLote]))

				Help(" ",1,"NAORASTRO")
				lRet := .F.		

			Case nPosOp>0 .And.;
					!lGspInUseM .And. !Empty(aCols[n][nPosOp]) .And. (!SC2->(dbSeek(xFilial("SC2")+aCols[n][nPosOp])) .Or. !Empty(SC2->C2_DATRF))

				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Integracao com SIGAMNT - NG Informatica             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPosOrdem > 0
					If lNgMnTes .and. lNgMntPc .and. !Empty(aCols[n][nPosOrdem])
				         If aCols[n][nPosOrdem] == Substr(aCols[n][nPosOp],1,Len(SC2->C2_NUM))
				         	lRet := .T.
							dDTULMES := SuperGetMV("MV_ULMES",.F.,STOD(""))
							If !Empty(dDTULMES) .and. SC2->C2_DATRF <= dDTULMES
								lRet := .F.
							Endif
				         Endif
					Endif
				Endif
				
				If !lRet
					Help(" ",1,"A100OPEND")
					lRet := .F.
				Endif

			Case nPosNFOri>0 .And.;
					!lGspInUseM .And. cTipo $'CPI' .And. Empty(aCols[n][nPosNFOri]) .And. !lColab

				Help(" ",1,"A100COMPIP")
				lRet := .F.		

			Case nPosIdentB6>0 .And.;
					!lGspInUseM .And. SF4->F4_PODER3 == 'D' .And. Empty(aCols[n][nPosIdentB6])

				Help(" ",1,"A103USARF7")
				lRet := .F.		

			Case nPosQuant>0 .And.;
					SF4->F4_ATUATF == 'S' .And. SF4->F4_BENSATF == "1" .And. INT(aCols[n][nPosQuant]) <> aCols[n][nPosQuant]

				Help(" ",1,"A103BENATF")
				lRet := .F.		

			Case nPosCod>0 .And. nPosLocal>0 .And.;
					SF4->F4_ESTOQUE == 'S' .And. !A103Alert(Acols[n][nPosCod],aCols[n][nPosLocal],( Type('l103Auto') <> 'U' .And. l103Auto ))

				lRet := .F.

			Case nPosTes>0 .And. nPosTotal>0 .And. nPosVUnit>0 .And. nPosQuant>0 .And.;
					cTipo$'NDB' .And. !MaTesSel(aCols[n,nPosTes]) .And. (aCols[n][nPosTotal]>(aCols[n][nPosVUnit]*aCols[n][nPosQuant]+0.49);
					.Or. aCols[n][nPosTotal]<(aCols[n][nPosVUnit]*aCols[n][nPosQuant]-0.49))

				Help("  ",1,'TOTAL')
				lRet := .F.		

			Case nPosTes>0 .And. nPosQuant>0 .and.;
					MaTesSel(aCols[n,nPosTes]) .And. aCols[n][nPosQuant] > 0

				Help("  ",1,'A103ZROTES')
				lRet := .F.

			Case nPosConta <> 0 .And. nPosCC>0 .And. nPosItemCta <> 0 .And. nPosClVl <> 0 .And.;
					!lGspInUseM .And. ((!lDAmarCt .And. !CtbAmarra(aCols[n,nPosConta],aCols[n,nPosCC],aCols[n,nPosItemCTA],aCols[n,nPosCLVL])) .Or.;
					(!Empty(aCols[n,nPosConta]) .And. !Ctb105Cta(aCols[n,nPosConta])) .Or.;
					(!Empty(aCols[n,nPosCC]) .And. !Ctb105CC(aCols[n,nPosCC])) .Or.;
					(!Empty(aCols[n,nPosItemCTA]) .And. !Ctb105Item(aCols[n,nPosItemCTA])) .Or.;
					(!Empty(aCols[n,nPosCLVL]) .And. !Ctb105ClVl(aCols[n,nPosCLVL])))

				lRet := .F.	

			Case nPosPC>0 .And. nPosTes>0 .And.;
					!lGspInUseM .And. cTipo == 'N' .And. lPCNFE .And. Empty(aCols[n,nPosPC]) .And. SF4->F4_PODER3=="N"

				If Empty(cTesPcNf) .Or. (!Empty(cTesPcNf) .And. !aCols[n][nPosTes] $ cTesPcNf)
					Aviso(STR0119,STR0186,{STR0163}, 2 ) //-- "Atencao"###"Informe o No. do Pedido de Compras ou verifique o conteudo do parametro MV_PCNFE"###"Ok"
					lRet := .F.
				Endif	

			Case nPosCod>0 .And. !lGspInUseM .And. SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosCod])) .And. !ExistBlock("MT103PBLQ") 
					IF !RegistroOk("SB1")
						lRet := .F.
					EndIf

			Case nPosPCCENTR>0 .And. nPosITPCCEN>0 .And. !lGspInUseM
			     If !A103VALPCC(n)   
					lRet := .F.
				 EndIf

			OtherWise
				lRet := .T.
			EndCase
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a quantidade e o valor devolvido                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosNFOri>0 .And. nPosSerOri>0 .And. nPosCod>0 .And. nPosItmOri>0 .And. nPosQuant>0 .And. nPosTotal>0 .And.;
				lRet .And. !lGspInUseM .And. lRet .And. cTipo=="D" .And. !Empty(aCols[n][nPosNFOri])

			DbSelectArea("SF2")
			DbSetOrder(1)
			MsSeek(xFilial("SF2") + aCols[n][nPosNfOri] + aCols[n][nPosSerOri] )

			DbSelectArea("SD2")
			DbSetOrder(3)
			If MsSeek(xFilial("SD2")+aCols[n][nPosNFOri]+aCols[n][nPosSerOri]+SF2->F2_CLIENTE+SF2->F2_LOJA+aCols[n][nPosCod]+aCols[n][nPosItmOri])
				nSldQtdDev := SD2->D2_QUANT-SD2->D2_QTDEDEV
				nSldVlrDev := SD2->D2_TOTAL+SD2->D2_DESCON+SD2->D2_DESCZFR-SD2->D2_VALDEV
				For nX := 1 to Len(aCols)
					If !aCols[nX][Len(aCols[nX])] .And.;
							aCols[nX][nPosCod]    == SD2->D2_COD   .And. ;
							aCols[nX][nPosNfOri]  == SD2->D2_DOC   .And. ;
							aCols[nX][nPosSerOri] == SD2->D2_SERIE .And. ;
							Alltrim(aCols[nX][nPosItmOri]) == Alltrim(SD2->D2_ITEM)
						If n <> nX
							nSldQtdDev -= aCols[nX][nPosQuant]
							nSldVlrDev -= aCols[nX][nPosTotal]
						EndIf
					EndIf
				Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o valor devolvido                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cVldPDev == "U" 	//-- Valida pelo preco unitario (devera ser igual)
					If QtdComp(aCols[n,nPosVUnit]) # QtdComp(nSldVlrDev/nSldQtdDev)
						Help(" ",1,"A410UNIDIF")
						lRet := .F.
					EndIf
				Else				//-- Valida pelo preco total (devera ser menor ou igual ao saldo a receber
					If aCols[n][nPosTotal] > nSldVlrDev
						Help(" ",1,"A410UNIDIF")
						lRet := .F.
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a quantidade                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SD2->D2_QTDEDEV == SD2->D2_QUANT  .And. SD2->D2_QUANT<>0
					lRet := .F.
					Help(" ",1,"A100QDEV")
				Else
					If aCols[n][nPosQuant] > nSldQtdDev
						lRet := .F.
						Help(" ",1,"A100DEVPAR",,Str(nSldQtdDev,18,2),4,1)
					EndIf
				EndIf
			ElseIf MsSeek(xFilial("SD2")+aCols[n][nPosNFOri]+aCols[n][nPosSerOri]+SF2->F2_CLIENTE+SF2->F2_LOJA)
				While SD2->(!Eof()) .And.;										// Encontrou a nota e o item,
					SD2->D2_FILIAL == xFilial("SD2") .And.;					// porem o codigo do produto esta diferente.
					SD2->D2_DOC == aCols[n][nPosNFOri] .And.;					// Neste caso nao deve permitir a devolucao.
					SD2->D2_SERIE == aCols[n][nPosSerOri] .And.;
					SD2->D2_CLIENTE == SF2->F2_CLIENTE .And.;
					SD2->D2_LOJA == SF2->F2_LOJA
					If SD2->D2_ITEM == AllTrim(aCols[n][nPosItmOri])
						AVISO(STR0119,STR0401,{STR0238})						// Atencao # O codigo do produto para devolucao deve ser igual ao do item da nota original. # Ok
						lRet := .F.
					EndIf
					SD2->(dbSkip())
				EndDo
			Else
    	    	SX6->(DbSetOrder(1))
    	    	If !SX6->(dbSeek(xFilial("SX6")+"MV_VLDNFO"))
    	    		SX6->(dbSeek(Space(FWGETTAMFILIAL)+"MV_VLDNFO"))
    	    	EndIf
				If !Empty(aCols[n][nPosItmOri]) .And. SX6->(EOF())
					lRet := .F.
					Help(" ",1,"A100ITDEV")
				EndIf
			EndIf
		EndIf 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Notas de Complemento/Devolução vinculadas a NFE ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		If lRet .And. (Type ( "l103Auto" ) == "U" .Or. !l103Auto) .And. lVldNfe .And.;
		lVldNfo .And. ((nPosNfOri>0 .Or. nPosItmOri>0 .OR. nPosSerOri>0) .and. !lGspInUseM)
		     lRet :=A103VldNFO(n)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o poder de terceiro                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosNfOri>0 .And. nPosSerOri>0 .And. nPosIdentB6>0 .And. nPosQuant>0 .And. nPosTotal>0 .And. nPValDesc>0 .And. nPosCod>0 .And. nPosTES>0 .And.;
				lRet .And. !lGspInUseM .And. lRet .And. SF4->F4_PODER3 == 'D'

			For nX := 1 to Len(aCols)
				If 	aCols[nX][nPosNfOri]  == aCols[n][nPosNfOri]  .And. ;
						aCols[nX][nPosSerOri] == aCols[n][nPosSerOri] .And. ;
						aCols[nX][nPosIdentB6] == aCols[n][nPosIdentB6]  .And. ;
						!aCols[nX][Len(aCols[nX])]
					nQtdPoder3 += aCols[nX][nPosQuant]
					nSldPoder3 += aCols[nX][nPosTotal]-aCols[nX][nPValDesc]
				EndIf
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o conteudo do aCols[nX][nPosIdentB6]         ³
			//³ confere com o do documento original (SD2) em casos onde  ³
			//³ o usuario altera manualmente o docto orignal ao retornar ³
			//³ devolucoes de beneficiamento pela opcao Retornar.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD2->(DbSetOrder(4))
			SD2->(MsSeek(xFilial("SD2") + aCols[n][nPosIdentB6]))             
			If aCols[n][nPosNfOri] + aCols[n][nPosSerOri] <> SD2->D2_DOC + SD2->D2_SERIE
				cAlerta := STR0266 + aCols[n][nPosCod] + " " + chr(13)	    //"O campo documento original do Produto "
				cAlerta += STR0267 + aCols[n][nPosNfOri] + "." + chr(13)     //"foi alterado manualmente para o numero "
				cAlerta += STR0268 + " " + chr(13)	      //"O sistema necessita que esta operação seja realizada atraves"
				cAlerta += STR0269 + " " + chr(13)	      //"do botão SELECIONAR DOCUMENTO ORIGINAL - F7 para atualizar a"
				cAlerta += STR0270 + " " + chr(13)	      //"baixa da tabela SB6."
				Aviso("IDENTSB6",cAlerta,{"Ok"})
				lRet := .F.
			EndIf

			aSldSB6 := CalcTerc(aCols[n][nPosCod],cA100For,cLoja,aCols[n][nPosIdentB6],aCols[n][nPosTES],cTipo)
			If nQtdPoder3 > aSldSB6[1]
				Help(" ",1,"A100N/PD3")
				lRet := .F.
			EndIf

			If lRet   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Somente se o parametro estiver no SX6 como .T. sera executada a validacao a seguir onde ³
				//³nao e permitido digitar um valor unitario na devolucao diferente do B6_PRUNIT disparando³
				//³o Help A100VALOR, caso o parametro nao esteja no SX6 ou seu conteudo esteja .F. sera    ³
				//³executada a validacao do ELSE que consiste o valor total da remessa de saida com o valor³
				//³total de todas as devolucoes vinculadas a remessa original permitindo que em cada       ³
				//³devolucao seja digitado um valor unitario diferente da remessa, contudo a soma total    ³
				//³destas devolucoes tem que bater com o valor da remessa.                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lBloqSb6
					SB6->(DbSetOrder(3))
					SB6->(dbSeek(xFilial("SB6") + aCols[n][nPosIdentB6]))
					If (Abs(A410Arred(SB6->B6_PRUNIT, 'D1_TOTAL') - A410Arred(aCols[n][nPosVUnit], 'D1_TOTAL')) >= 0.01)
						Help(" ",1,"A100VALOR")
						lRet := .F.
					EndIf
				Else
					If A410Arred(nSldPoder3,"D1_TOTAL")	> a410Arred((aSldSB6[5]-aSldSB6[4]),"D1_TOTAL")+0.01 .And. Valtype(l103Auto) == "L" .And. !l103Auto
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³O Valor Total do Item a ser devolvido é maior que o saldo disponível no poder de terceiros de                      ³
						//³O valor original da remessa é de 999.999,99 E foram encontradas devoluções anteriores totalizando 99999999         ³
						//|No saldo disponível em poder de terceiros, já está sendo considerada a existência de notas de complemento 		  |
						//³Para continuar é necessario que o valor total das devoluçoes deste item não ultrapasse o valor original da remessa ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cHelpPD3 := STR0308+" "+Transform((aSldSB6[5]-aSldSB6[4]),PesqPict("SD1","D1_TOTAL"))+" "+CRLF
						cHelpPD3 += STR0309+" "+aCols[n][nPosNfOri]+" "+aCols[n][nPosSerOri]+" "+STR0310+Transform(SD2->D2_TOTAL ,PesqPict("SD1","D1_TOTAL"))+" "+CRLF
						cHelpPD3 += STR0311+" "+Transform(aSldSB6[4],PesqPict("SD1","D1_TOTAL"))+CRLF
						cHelpPD3 += STR0316+" "+CRLF
						cHelpPD3 += STR0312+" "+CRLF       
	
						Aviso("A103VALOR",cHelpPD3,{"Ok"})          
						lRet := .F.                               
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atencao! a variavel l103Auto portege o bloco a seguir para nao ser apresentado quando   ³
						//³a devolucao for realizada pela opcao RETORNAR disparando o LOG da rotina automatica     ³
						//³antes da tela de entrada impedindo que o usuario fizesse a devolucao quando ha saldo    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³A quantidade informada neste item ira encerrar o saldo da remessa efetuada para   ³
						//³terceiros. Este procedimento ira finalizar o controle de terceiros em quantidade  ³
						//|e valor, porem o valor informado e inferior ao saldo de remessa.                  |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nQtdPoder3 == aSldSB6[1].And. ;
							A410Arred(nSldPoder3,"D1_TOTAL")+0.01 < a410Arred((aSldSB6[5]-aSldSB6[4]),"D1_TOTAL") .And. Valtype(l103Auto) == "L" .And. !l103Auto
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³O saldo em quantidade do Poder de Terceiros sera finalizado com esta devolucao,   ³
							//³Contudo ainda existe um saldo financeiro de 999.999.999,99                        ³
							//³Este saldo deve ser consumido neste momento para que o valor total das devolucoes ³
							//³corresponda ao valor original da remessa                                          ³
							//|No saldo disponivel em poder de terceiros, ja esta sendo considerada a existencia |
							//|de notas de complemento                                                           |
							//|MV_LIBESB6 - Parametro utilizado para liberar a inclusao de devolucoes de P3      |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !(lLibeSb6 .And. cTipo=='B')
								cHelpPD3 := STR0313+Transform(a410Arred((aSldSB6[5]-aSldSB6[4]),"D1_TOTAL") - A410Arred(nSldPoder3,"D1_TOTAL")+0.01 ,PesqPict("SD1","D1_TOTAL"))+" "+CRLF
								cHelpPD3 += STR0314+" "+aCols[n][nPosNfOri]+" "+aCols[n][nPosSerOri]+CRLF
								cHelpPD3 += STR0316+" "+CRLF     
								Aviso("A103SLDPD3",cHelpPD3,{"Ok"})
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impede que dois identificadores sejam carregados ao mesmo tempo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosIdentB6>0 .and. lRet .And. !lGspInUseM .And. lRet .And. !GDDeleted()
			If !Empty( aCols[ n, nPosIdentB6 ] )
				lRet := MayIUseCode( "SD1_D1_IDENTB6" + aCols[ n, nPosIdentB6 ] )
			EndIf 	

			If !lRet
				Help( " ", 1, "A103P3SIM" ) // "O identificador de poder de terceiros utilizado ja esta em uso por outra estacao.Selecione outro item de NF original."
				lRet := .F.
			EndIf			
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as validacoes do WMS                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !lGspInUseM .And. lRet
			lRet := A103WMSOk()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ha empenho da OP                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosOp>0 .And. lRet .And. !lGspInUseM .And. lRet .And. !Empty(aCols[n][nPosOp])
			lRet := A103ValSD4(n)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as validacoes da integracao com o QIE           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosCod>0 .And. lRet .And. Localiza(aCols[n][nPosCod])
			DbSelectArea("SB1")
			DbSetOrder(1)
			If MsSeek(xFilial("SB1")+aCols[n][nPosCod]) .And. RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q' .And. (!(SuperGetMV('MV_CQ') $ SuperGetMV('MV_DISTAUT')) .And. !Empty(SuperGetMV('MV_DISTAUT'))) 

				Help(" ",1,"A103CQUALY")
				lRet:=.F. 	
			EndIf 
			
			If lRet .AND. SB1->B1_TIPOCQ == 'Q'
			     lRet := QIEVDOCENT(aCols) //ATENÇÃO: Tentar centralizar todas as validações do Quality nesta função
			EndIf
		Else
			DbSelectArea("SB1")
			DbSetOrder(1)
			If lRet .AND. MsSeek(xFilial("SB1")+aCols[n][nPosCod]) .AND. SB1->B1_TIPOCQ == 'Q'
			     lRet := QIEVDOCENT(aCols) //ATENÇÃO: Tentar centralizar todas as validações do Quality nesta função
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se Produto x Fornecedor foi Bloquedo pela Qualidade.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosCod>0 .And. lRet .and. !(cTipo$'DB')
			lRet := QieSitFornec(cA100For,cLoja,aCols[n][nPosCod],.T.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o preco digitado esta divergente do PC ou da AE.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosPc>0 .And. nPosItemPC>0 .And. nPosVUnit>0 .And.;
				lRet .And. cAltPrcCtr <> "0" .And. !Empty(aCols[n][nPosPc]) .And. !Empty(aCols[n][nPosItemPC])

			SC7->(DbSetOrder(1))
			If SC7->(MsSeek(xFilial("SC7")+aCols[n][nPosPc]+aCols[n][nPosItemPC]))
				nPreco := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,M->dDEmissao,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a NF for do SIGAEIC, a comparação entre a NF e o Pedido de Compra, não tenha efeito    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(SC7->C7_SEQUEN)
					If (cAltPrcCtr == "1" .And. SC7->C7_TIPO == 1) .Or.;
						(cAltPrcCtr == "2" .And. SC7->C7_TIPO == 2) .Or.;
						(cAltPrcCtr == "5" .And. SC7->C7_TIPO == 2) .Or.;
						cAltPrcCtr $ "3#6"
				   		If aCols[n][nPosVUnit] <> nPreco
					 		Aviso(STR0119,STR0221+IIF(SC7->C7_TIPO == 1,STR0222,STR0223)+STR0224,{STR0163}, 2 ) //-- "Atencao"###""PreÇo informado divergente "###do Pedido de Compras."###"da AutorizaçÃo de Entrega."###"Ok"###" Verifique o conteúdo do parâmetro MV_ALTPREC"
							lRet := .F.
						Endif
					Endif	
				Endif
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o lote esta com data de validade vencida.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If nPosCod>0 .And. nPosLote>0 .And. nPosOp>0 .And. nPosDtvalid>0 .And.;
				lRet .And. !lGspInUseM .And. SF4->F4_ESTOQUE == "S" .And.;
				(Rastro(aCols[n][nPosCod],"S")) .And. !Empty(aCols[n][nPosLote]) .And.;
				!Empty(aCols[n][nPosOp]) .And. aCols[n][nPosDtvalid] < dDatabase

			Help(" ",1,"LOTEVENC")
			If !lLoteVenc
				lRet := .F.
			EndIf	
		Endif
		If nPosCod>0 .And. nPosLoteCtl>0 .And. nPosOp>0 .And. nPosDtvalid>0 .And.;
				lRet .And. !lGspInUseM .And. SF4->F4_ESTOQUE == "S" .And.;
				(Rastro(aCols[n][nPosCod],"L")) .And. !Empty(aCols[n][nPosLoteCtl]) .And.;
				!Empty(aCols[n][nPosOp]) .And. aCols[n][nPosDtvalid] < dDatabase

			Help(" ",1,"LOTEVENC")
			If !lLoteVenc
				lRet := .F.
			EndIf	
		Endif
		If nPosCod>0 .And. nPosLoteCtl>0 .And. nPosDtvalid>0 .And. lRet .And. SF4->F4_ESTOQUE == "S" .And.; 
		(Rastro(aCols[n][nPosCod],"L")) .And. !Empty(aCols[n][nPosLoteCtl]) 
			For i:=1 To Len(aCols)
				If aCols[i, nPosCod] == aCols[n, nPosCod] .And. aCols[i,nPosLoteCtl] == aCols[n,nPosLoteCtl] .And. !aCols[n,nPosDtvalid]==aCols[i,nPosDtvalid] .And. (!n = i .Or. n == 1)
					HelpAutoma(" ",1,"A240DTVALI",,,,,,,,,.F.)
					aCols[n,nPosDtvalid] := aCols[i,nPosDtvalid]
				EndIf
			Next i    
		EndIf	
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Analisa incompatibilidade entre os modos de compartilhamento entre as tabelas.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If lRet .And. nPosPc>0 .And. nPosItemPC>0 .And. !Empty(aCols[n][nPosPc]) .And. !Empty(aCols[n][nPosItemPC])
			If lPcFilEn .And. FWModeAccess("SC7")=="E" .And. FWModeAccess("SB2")=="C" //!Empty(SB2->(SC7->(xFilEnt(SC7->C7_FILENT))))  .And. Empty(xFilial("SB2"))
				Aviso(OemToAnsi(STR0119),OemToAnsi(STR0282),{"Ok"}) //"Quando o parâmetro MV_PCFILENT estiver configurado para trabalhar com filial de entrega (.T.) a tabela de controle de estoques físicos e financeiros (SB2) necessariamente devem estar em modo exclusivo." 
				lRet := .F.
			Endif	
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Analisa transferencia entre filiais                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lRet
			lRet:=A103TrFil(GdFieldGet('D1_TES',n),cTipo,ca100For,cLoja,cNFiscal,cSerie,GdFieldGet('D1_COD',n),GdFieldGet('D1_QUANT',n))	
		EndIf
	Else
		lRet := .T.
	EndIf       
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o numero maximo de itens permitido para a nota de formulario proprio = S   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		If lRet .And. cFormul == "S"
			aEval(aCols,{|x| nItensNf += IIF(x[Len(x)],0,1)})
			If nItensNf > a460NumIt(cSerie,.T.)
		   		lRet:= .F.
		   		Help(" ",1,"A100NITENS")
			Endif
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o total da NF esta negativo devido ao valor do desconto |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. MaFisRet(n,"IT_TOTAL")<0
		Help(" ",1,"A100VALDES")
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exec.Block para Ponto de Entrada: MT103MNT - Multiplas Naturezas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Eval(bBlockSev1)   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa os pontos de entrada                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (ExistTemplate("MT100LOK"))
		lRet := ExecTemplate("MT100LOK",.F.,.F.,{lRet})
	EndIf
	If lRet .And. (ExistBlock("MT100LOK"))
		lRet := ExecBlock("MT100LOK",.F.,.F.,{lRet})
	EndIf 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pontos de entrada                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (ExistBlock("MTA103OK"))
		lRet := ExecBlock("MTA103OK",.F.,.F.,{lRet})
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacoes pertinentes a integracao com o Manutencao de Ativos          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lNgMnTes
	If lRet .AND. lNGLinok
		lRet := NG103LINOK()
	Endif
EndIf

If lRet .and. !aCols[n,Len(aHeader)+1]
	Do Case
	Case cTipo == "B"
		lRet	:=	PcoVldLan("000054","07","MATA103",/*lUsaLote*/,/*lDeleta*/, .T./*lVldLinGrade*/)
	Case cTipo == "D"
		lRet	:=	PcoVldLan("000054","05","MATA103",/*lUsaLote*/,/*lDeleta*/, .T./*lVldLinGrade*/)
	OtherWise
		lRet	:=	PcoVldLan("000054","01","MATA103",/*lUsaLote*/,/*lDeleta*/, .T./*lVldLinGrade*/)
	EndCase
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto est  em revisao vigente e envia para armazem de CQ para ser validado pela engenharia    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If lRet .And. lVer116 .And. lRevProd
	cRvSB5 := Posicione("SB5",1,xFilial("SB5")+aCols[n][nPosCod],"B5_REVPROD")
	cBlqSG5:= Posicione("SG5",1,xFilial("SG5")+aCols[n][nPosCod]+aCols[n][nRevisao],"G5_MSBLQL")
	cStatus:= Posicione("SG5",1,xFilial("SG5")+aCols[n][nPosCod]+aCols[n][nRevisao],"G5_STATUS")
	If cRvSB5="1"
		If Empty(cRvSB5)
			Aviso(STR0178,STR0382,{STR0163})//"Não foi encontrado registro do produto selecionado na rotina de Complemento de Produto."   
			lRet:= .F.
		ElseIf Empty(cBlqSG5)
			Aviso(STR0178,STR0383,{STR0163})//"O produto selecionado não possui revisão em uso. Verifique o cadastro de Revisões."		
			lRet:= .F.
		ElseIf cBlqSG5="1"
			Help(" ",1,"REGBLOQ")
			lRet:= .F. 
		ElseIf cStatus=="2" .AND. aCols[n][nPosTes]<= "500"
			Aviso(STR0178,STR0390,{STR0163})//"Esta revisão não pode ser alimentada pois está inativa."
			lRet:= .F.	
		ElseIf aCols[n][nRevisao] <> Posicione("SB5",1,xFilial("SB5")+aCols[n][nPosCod],"B5_VERSAO") .AND. aCols[n][nPosLocal] <> SuperGetMV("MV_CQ",.F.,"98")
		   	If ExistCpo("SG5",aCols[n][nPosCod]+aCols[n][nRevisao])
				nRet := Aviso(STR0384,STR0385 + AllTrim(aCols[n][nPosCod]) + STR0386 ,{STR0387,STR0388},1,STR0389) //"O Produto xxxxx " foi informado com revisão diferente da revisão vigente, este produto será enviado para o Armazém de CQ."		
				If nRet==1
					aCols[n][nPosLocal]:= SuperGetMV("MV_CQ",.F.,"98")		
				Else
					lRet:= .F. 
				EndIf
			Else
				lRet:= .F.	
			EndIf       
		EndIf     
	EndIf		
EndIf

RestArea(aAreaSF4)
RestArea(aAreaSB6)
RestArea(aAreaSD2)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A103F4   ³ Autor ³ Edson Maricate        ³ Data ³26.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a consulta aos pedidos de compra em aberto.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103F4()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103F4()
Local cVariavel	:= ReadVar()
Local bKeyF4	:=  SetKey( VK_F4 )
Local lContinua := .T.

SetKey( VK_F4,Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua
	Do Case
		Case cVariavel == "M->D1_OP" .And. cTipo $ 'NIPBC'
			A103ShowOp()
		Case SF1->F1_IMPORT=="S"
			A103NBMItens(oGet)
	EndCase
Endif
SetKey( VK_F4,bKeyF4 )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ForF4 ³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Pedidos de Compra.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Pedido()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A103ForF4(lUsaFiscal,aGets,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV, lTxNeg, nTaxaMoeda)

Local nSldPed    := 0
Local nOpc       := 0
Local nx         := 0
Local cQuery     := ""
Local cAliasSC7  := "SC7"
Local cQueryQPC  := ""
Local lQuery     := .F.
Local bSavSetKey := SetKey(VK_F4,Nil)
Local bSavKeyF5  := SetKey(VK_F5,Nil)
Local bSavKeyF6  := SetKey(VK_F6,Nil)
Local bSavKeyF7  := SetKey(VK_F7,Nil)
Local bSavKeyF8  := SetKey(VK_F8,Nil)
Local bSavKeyF9  := SetKey(VK_F9,Nil)
Local bSavKeyF10 := SetKey(VK_F10,Nil)
Local bSavKeyF11 := SetKey(VK_F11,Nil)
Local cChave     := ""
Local cCadastro  := ""
Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local nF4For     := 0
Local oOk        := LoadBitMap(GetResources(), "LBOK")
Local oNo        := LoadBitMap(GetResources(), "LBNO")
Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi(STR0059),OemToAnsi(STR0061)} } //"Visualiza Pedido"
Local oDlg,oListBox
Local cNomeFor   := ''
Local aTitCampos := {}
Local aConteudos := {}
Local aUsCont    := {}
Local aUsTitu    := {}
Local bLine      := { || .T. }
Local cLine      := ""
Local lMa103F4I  := ExistBlock( "MA103F4I" )
Local nLoop      := 0
Local lMt103Vpc  := ExistBlock("MT103VPC")
Local lRet103Vpc := .T.                   
Local lContinua  := .T.
Local lMT103APC  := ExistBlock("MT103APC")  
Local lRetAPC    := .F.
Local lRestNfe	 := SuperGetMV("MV_RESTNFE")=="S"
Local oPanel
Local nNumCampos := 0

PRIVATE aF4For     := {}
PRIVATE aRecSC7    := {}

DEFAULT lUsaFiscal := .T.
DEFAULT aGets      := {}
DEFAULT lNfMedic   := .F.
DEFAULT lConsMedic := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando algum campo estiver em edicao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. IsInCallStack("EDITCELL")
	lContinua:=.F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a importacao se ja houver lote do PLS informado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lUsouLtPLS")<>"U" .And. lUsouLtPLS
	lContinua := .F.
	Aviso("A103ForF4",STR0405,{"Ok"}) // "Para documentos com lote do PLS, é permitido somente um pedido."
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informa que houve importação de pedido no documento					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lImpPedido")<>"U"
	lImpPedido := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacoes da importacao do Pedido de Compras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lMT103APC
	lRetAPC := ExecBlock("MT103APC",.F.,.F.)
	If ValType(lRetAPC)=="L"   
		lContinua:= lRetAPC
	EndIf
EndIf

If lContinua

	If MaFisFound("NF") .Or. !lUsaFiscal
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o aCols esta vazio, se o Tipo da Nota e'     ³
		//³ normal e se a rotina foi disparada pelo campo correto    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipo == "N"
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+cA100For+cLoja)
			cNomeFor	:= SA2->A2_NOME

			#IFDEF TOP
				DbSelectArea("SC7")
				If TcSrvType() <> "AS/400"
					SC7->( DbSetOrder( 9 ) ) 				
					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery := "SELECT R_E_C_N_O_ RECSC7 FROM "
					cQuery += RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
					
					If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
						cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
					Else
						cQuery += "C7_FORNECE = '"+cA100For+"' AND "		    		
					EndIf
					cQuery += "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND "
					cQuery += "C7_RESIDUO=' ' AND "
					cQuery += "C7_TPOP<>'P' AND "

					If lRestNfe
						cQuery += "C7_CONAPRO<>'B' AND "
					EndIf 										

					If ( lConsLoja )		    		
						cQuery += "C7_LOJA = '"+cLoja+"' AND "		    							
					Endif		

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os pedidos de compras de acordo com os contratos             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If lConsMedic
						If lNfMedic
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos oriundos de medicoes                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos que nao possuem medicoes                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						EndIf
					EndIf 					

					cQuery += "SC7.D_E_L_E_T_ = ' '"
					cQuery += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) )

					cQuery := ChangeQuery(cQuery)
					
					//---------------------------//
					//Ponto de Entrada: MT103QPC //
					//---------------------------//
					If ExistBlock("MT103QPC")    
						cQueryQPC := ExecBlock("MT103QPC",.F.,.F.,{cQuery,1})    
						If (ValType(cQueryQPC) == 'C' )
							cQuery := cQueryQPC  
							cQuery := ChangeQuery(cQuery)
						EndIf
					EndIf

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
				Else
			#ENDIF
				DbSelectArea("SC7")
				DbSetOrder(9)
				If ( lConsLoja )
					cChave := cA100For+CLOJA
				Else
					cChave := cA100For
				EndIf
				MsSeek(xFilEnt(xFilial("SC7"))+cChave,.T.)
				#IFDEF TOP
				Endif
				#ENDIF
			Do While If(lQuery, ;
					(cAliasSC7)->(!Eof()), ;
					(cAliasSC7)->(!Eof()) .And. xFilEnt(xFilial('SC7'))+cA100For==(cAliasSC7)->C7_FILENT+(cAliasSC7)->C7_FORNECE .And. If(lConsLoja, CLOJA==(cAliasSC7)->C7_LOJA, .T.))

				If lQuery
					('SC7')->(MsGoto((cAliasSC7)->RECSC7))
				EndIf

				lRet103Vpc := .T.

				If lMt103Vpc
					lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
				Endif

				If lRet103Vpc
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Saldo do Pedido de Compra                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSldPed := ('SC7')->C7_QUANT-('SC7')->C7_QUJE-('SC7')->C7_QTDACLA
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
					//³ se esta liberado por alcadas se houver controle.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And.;
							If(lRestNfe,('SC7')->C7_CONAPRO <> "B",.T.).And.;
							('SC7')->C7_TPOP <> "P" )

						If lConsMedic .And. lNfMedic
							nF4For := aScan(aF4For,{|x|x[5]==('SC7')->C7_LOJA .And. x[6]==('SC7')->C7_NUM})							
						Else							
							nF4For := aScan(aF4For,{|x|x[2]==('SC7')->C7_LOJA .And. x[3]==('SC7')->C7_NUM})
						EndIf 							

						If ( nF4For == 0 )
							If lConsMedic .And. lNfMedic
								aConteudos := {.F.,('SC7')->C7_MEDICAO,('SC7')->C7_CONTRA,('SC7')->C7_PLANILHA,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
							Else
								aConteudos := {.F.,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
							EndIf 															

							If lMa103F4I
								If ValType( aUsCont := ExecBlock( "MA103F4I", .F., .F. ) ) == "A"
									AEval( aUsCont, { |x| AAdd( aConteudos, x ) } )
								EndIf
							EndIf

							aAdd(aF4For , aConteudos )
							aAdd(aRecSC7, ('SC7')->(Recno()))
						EndIf
					EndIf
				Endif
				(cAliasSC7)->(dbSkip())
			EndDo

			If ExistBlock("MA103F4L")
				ExecBlock("MA103F4L", .F., .F., { aF4For, aRecSC7 } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe os dados na Tela                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty(aF4For) )

				If lConsMedic .And. lNfMedic
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exibe os campos de medicao do contrato                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					aTitCampos := {" ",RetTitle("C7_MEDICAO"),RetTitle("C7_CONTRA"),RetTitle("C7_PLANILH"),OemToAnsi(STR0060),OemToAnsi(STR0061),OemToAnsi(STR0039),OemToAnsi(STR0062)} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Emissao"###"Origem"
					cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][8]"
				Else

					aTitCampos := {" ",OemToAnsi(STR0060),OemToAnsi(STR0061),OemToAnsi(STR0039),OemToAnsi(STR0062)} //"Loja"###"Pedido"###"Emissao"###"Origem"

					cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5]"

				EndIf 					

				If ExistBlock( "MA103F4H" )
					If ValType( aUsTitu := ExecBlock( "MA103F4H", .F., .F. ) ) == "A"
						nNumCampos := Len(aTitCampos)
						For nLoop := 1 To Len( aUsTitu )
							AAdd( aTitCampos, aUsTitu[ nLoop ] )
							cLine += ",aF4For[oListBox:nAT][" + AllTrim( Str( nLoop + nNumCampos ) ) + "]"
						Next nLoop
					EndIf
				EndIf

				cLine += " } "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta dinamicamente o bline do CodeBlock                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				bLine := &( "{ || " + cLine + " }" )
				
				DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi(STR0024+" - <F5> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra"

				@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
				oPanel:Align := CONTROL_ALIGN_TOP

				oListBox := TWBrowse():New( 27,4,243,86,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oListBox:SetArray(aF4For)
				oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1] }
				oListBox:bLine := bLine

				oListBox:Align := CONTROL_ALIGN_ALLCLIENT

				@ 6  ,4   SAY OemToAnsi(STR0028) Of oPanel PIXEL SIZE 47 ,9 //"Fornecedor"
				@ 4  ,35  MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oPanel PIXEL SIZE 120,9

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,nF4For := oListBox:nAt,oDlg:End())},{||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},,aButtons)

				Processa({|| a103procPC(aF4For,nOpc,cA100For,cLoja,@lRet103Vpc,@lMt103Vpc,@nSldPed,lUsaFiscal,aGets,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda)})

			Else
				Help(" ",1,"A103F4")
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integrida dos dados de Entrada                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	DbSelectArea(cAliasSC7)
	dbCloseArea()
	DbSelectArea("SC7")
Endif
SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ProcPC| Autor ³ Alex Lemes            ³ Data ³09/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o carregamento do pedido de compras para a NFE    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os itens do pedido de compras            ³±±
±±³          ³ ExpN1 = Opcao valida                                       ³±±
±±³          ³ ExpC1 = Fornecedor                                         ³±±
±±³          ³ ExpC2 = loja fornecedor                                    ³±±
±±³          ³ ExpL1 = retorno do ponto de entrada                        ³±±
±±³          ³ ExpL2 = Uso do ponto de entrada                            ³±±
±±³          ³ ExpN2 = Saldo do pedido                                    ³±±
±±³          ³ ExpL3 = Usa funcao fiscal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a103procPC(aF4For,nOpc,cA100For,cLoja,lRet103Vpc,lMt103Vpc,nSldPed,lUsaFiscal,aGets,lNfMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV, lTxNeg, nTaxaMoeda)
Local nx         := 0
Local cSeek      := ""
Local cFilialOri :=""
Local cItem		 := StrZero(1,Len(SD1->D1_ITEM))
Local lZeraCols  := .T.
Local aRateio    := {0,0,0} 
Local aMT103NPC  := {}
Local aColsBkp   := Aclone(Acols)
Local cPrdNCad   := ""
Local nSavNF  	 := MaFisSave()
Local aRatFin	:= {}
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local lCmpPLS := SC7->(FieldPos("C7_LOTPLS")) > 0 .And. SC7->(FieldPos("C7_CODRDA")) > 0
Local n103TXPC	 := 0
Local cSeekTXPC	 := ""
Local nPosPc	 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosVlr	 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local lPlopelt	 := SC7->(Fieldpos("C7_PLOPELT")) > 0

DEFAULT lUsaFiscal := .T.
DEFAULT aGets      := {}
DEFAULT lNfMedic   := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}

If ( nOpc == 1 )
	If lPrjCni
   		U_COMA120(@aF4For,lNfMedic,lUsaFiscal)	   
	EndIf   
	For nx	:= 1 to Len(aF4For)
		If aF4For[nx][1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Fornecedor                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+cA100For+cLoja)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Pedido de Compra                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SC7")
			DbSetOrder(9)
			cSeek := ""
			cSeek += xFilEnt(xFilial("SC7"))+cA100For
			cSeek += If( lNfMedic, aF4For[nx,5]+aF4For[nx,6], aF4For[nx][2]+aF4For[nx][3] )
			MsSeek(cSeek)
			If lZeraCols
				aCols		:= {}
				lZeraCols	:= .F.
				MaFisClear()
			EndIf
			
			// Grava Lote do PMS e o codigo de RDA
			If lCmpPLS .And. Type("lUsouLtPLS")<>"U" .And. !lUsouLtPLS .And. !Empty(SC7->C7_LOTPLS) .And. !Empty(SC7->C7_CODRDA)
				lUsouLtPLS 	:= .T.
				cLotPLS		:= SC7->C7_LOTPLS
				cCodRDA		:= SC7->C7_CODRDA
				cOpeLt      := Iif(lPlopelt,SC7->C7_PLOPELT,PLSINTPAD())
			Endif

			// Muda ordem para trazer ordenado por item
			If !Eof()
				cSeek      :=xFilEnt(xFilial("SC7")) + If( lNfMedic, aF4For[nx,6], aF4For[nx][3] )
				cFilialOri :=C7_FILIAL
				DbSetOrder(14)
				dbSeek(cSeek)
			EndIf
			
			While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_NUM==cSeek )
				// Verifica se o fornecedor esta correto
				If C7_FILIAL+C7_FORNECE+C7_LOJA == cFilialOri+cA100For+ If( lNfMedic, aF4For[nx,5], aF4For[nx][2] )
				    // Verifica se o Produto existe Cadastrado na Filial de Entrada
				    DbSelectArea("SB1")
					DbSetOrder(1)
					MsSeek(xFilial("SB1") + SC7->C7_PRODUTO)
					IF !Eof()
					    DbSelectArea("SC7")
						lRet103Vpc := .T.
						If lMt103Vpc
							lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
						Endif
						If lRet103Vpc
							nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
							If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
								NfePC2Acol(SC7->(RecNo()),,nSlDPed,cItem,,@aRateio,aHeadSDE,@aColsSDE)
								cItem := SomaIt(cItem)
							EndIf
						Endif
					Else
					   cPrdNCad += STR0061+": "+SC7->C7_NUM+"  "+STR0063+": "+SC7->C7_PRODUTO+CHR(10)
			   		EndIf
				EndIf    
				
				If lPrjCni       
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Controle do Rateio Financeiro                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SC7->C7_RATFIN == "1"
						cChaveRat := "SC7"+SC7->C7_FILIAL+SC7->C7_NUM
						F641TrfRat(cChaveRat,@aRatFin,SC7->C7_TOTAL)
			   		EndIf
				EndIf

				If SC7->C7_MOEDA == 2
					cSeekTXPC := cSeek
				EndIf

				DbSelectArea("SC7")         
				dbSkip()             
			EndDo
		EndIf
	Next   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe Lista dos Produtos não Cadastrados na Filial de Entrega |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Len(cPrdNCad)>0 .And. !l103Auto
	   Aviso("A103ProcPC",STR0300+CHR(10)+STR0301+CHR(10)+cPrdNCad,{"Ok"})
	EndIf
         
	If lPrjCni
		//Grava rateio financeiro
		If Len(aRatFin) > 0
			cChaveRat := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja
			F641GrvRat(cChaveRat,aRatFin)
			aRatFin := {}
		EndIf
	EndIf
         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o Acols caso o mesmo estiver vazio |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Acols)=0
	    aCols:= aColsBKP
	    MaFisRestore(nSavNF)
	EndIf
         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para manipular o array de multiplas naturezas por titulo no Pedido de Compras .  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("MT103NPC"))
		aMT103NPC := ExecBlock("MT103NPC",.F.,.F.,{aHeadSEV,aColsSEV})
	 	If (ValType(aMT103NPC) == "A")
	   		aColsSEV := aClone(aMT103NPC)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para alterar a moeda, taxa, e check box de taxa negociada de acordo com o Pedido de Compras |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT103TXPC") .And. !Empty(cSeekTXPC)
		MsSeek(cSeekTXPC)
		nPosItPc := aScan(aCols,{|x| AllTrim(x[nPosPc])==AllTrim(SC7->C7_NUM)})
		n103TXPC := ExecBlock("MT103TXPC",.F.,.F.)
		If ValType(n103TXPC) == "N"
			If n103TXPC > 0
				nTaxaMoeda := n103TXPC
			ElseIf nPosItPc > 0
				nTaxaMoeda := aCols[nPosItPc][nPosVlr] / SC7->C7_PRECO
			EndIf
			lTxNeg := .T.
			nMoedaCor := SC7->C7_MOEDA
		EndIf
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type( "oGetDados" ) == "O" 	
		oGetDados:lNewLine:=.F.  
		oGetDados:oBrowse:Refresh()
		
	EndIf 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaFiscal
		Eval(bRefresh)
	Else
		aGets[SEGURO] := aRateio[1]
		aGets[VALDESP]:= aRateio[2]
		aGets[FRETE]  := aRateio[3]
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ItemPC³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela de importacao de Pedidos de Compra por Item.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103ItemPC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103ItemPC(lUsaFiscal,aPedido,oGetDAtu,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aGets, lTxNeg, nTaxaMoeda)

Local cSeek			:= ""
Local nOpca			:= 0
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSC7		:= SC7->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aRateio       := {0,0,0}
Local aNew			:= {}
Local aTamCab		:= {}
Local lGspInUseM	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},OemToAnsi(STR0059),OemToAnsi(STR0061)},; //"Visualiza Pedido"
	{'pesquisa',{||A103PesqP(aCab,aCampos,aArrayF4,oQual)},OemToAnsi(STR0001)} } //"Pesquisar"
Local aEstruSC7		:= SC7->( dbStruct() )
Local bSavSetKey	:= SetKey(VK_F4,Nil)
Local bSavKeyF5		:= SetKey(VK_F5,Nil)
Local bSavKeyF6		:= SetKey(VK_F6,Nil)
Local bSavKeyF7		:= SetKey(VK_F7,Nil)
Local bSavKeyF8		:= SetKey(VK_F8,Nil)
Local bSavKeyF9		:= SetKey(VK_F9,Nil)
Local bSavKeyF10	:= SetKey(VK_F10,Nil)
Local bSavKeyF11	:= SetKey(VK_F11,Nil)
Local nFreeQt		:= 0
Local nPosPRD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
Local nPosPDD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
Local nPosITM		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC" })
Local nPosQTD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT" })
Local nPosTes       := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nLinACols     := N
Local cVar			:= aCols[n][nPosPrd]
Local cQuery		:= ""
Local cAliasSC7		:= "SC7"
Local cQueryQPC     := ""
Local cCpoObri		:= ""
Local nSavQual
Local nPed			:= 0
Local nX			:= 0
Local nAuxCNT		:= 0
Local lMt103Vpc		:= ExistBlock("MT103VPC")
Local lMt100C7D		:= ExistBlock("MT100C7D")
Local lMt100C7C		:= ExistBlock("MT100C7C")
Local lMt103Sel		:= ExistBlock("MT103SEL")
Local nMT103Sel     := 0
Local nSelOk        := 1
Local lRet103Vpc	:= .T.
Local lMT103BPC 	:= ExistBlock("MT103BPC")  
Local lRetBPC    	:= .F.
Local lContinua		:= .T.
Local lQuery		:= .F.
Local lRestNfe		:= SuperGetMV("MV_RESTNFE") == "S"
Local oQual
Local oDlg
Local oPanel
Local aUsButtons  := {}
Local aRatFin	:= {}
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local lToler		:= FindFunction("MA103CkAIC") .And. MA103CkAIC(cA100For,cLoja,cVar)
Local nPosPc		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosVlr		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPosItPc		:= 0
Local n103TXPC		:= 0

PRIVATE aCab	   := {}
PRIVATE aCampos	   := {}
PRIVATE aArrSldo   := {}
PRIVATE aArrayF4   := {}

DEFAULT lUsaFiscal := .T.
DEFAULT aPedido	   := {}
DEFAULT lNfMedic   := .F.
DEFAULT lConsMedic := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}
DEFAULT aGets      := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MTIPCBUT" )
	If ValType( aUsButtons := ExecBlock( "MTIPCBUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacoes da importacao do Pedido de Compras por item  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lMT103BPC
	lRetBPC := ExecBlock("MT103BPC",.F.,.F.)
	If ValType(lRetBPC)=="L"   
		lContinua:= lRetBPC
	EndIf
EndIf

If lContinua

	If MaFisFound('NF') .Or. !lUsaFiscal
		If cTipo == 'N'
			#IFDEF TOP
				DbSelectArea("SC7")
				If TcSrvType() <> "AS/400"

					If Empty(cVar)
						DbSetOrder(9)
					Else
						DbSetOrder(6)
					EndIf

					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery	  := "SELECT "
					For nAuxCNT := 1 To Len( aEstruSC7 )
						cQuery += aEstruSC7[ nAuxCNT, 1 ]
						cQuery += ", "
					Next
					cQuery += " R_E_C_N_O_ RECSC7 " 
					cQuery += " FROM "+RetSqlName("SC7") + " SC7 "
					cQuery += " WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "

					If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
						cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
					Else
					If Empty(cVar)
						If lConsLoja
							cQuery += " C7_FORNECE = '"+cA100For+"' AND "
							cQuery += " C7_LOJA = '"+cLoja+"' AND "
						Else
							cQuery += " C7_FORNECE = '"+cA100For+"' AND "
						Endif	
					Else
						If lConsLoja
							cQuery += " C7_FORNECE = '"+cA100For+"' AND "
							cQuery += " C7_LOJA = '"+cLoja+"' AND "
							cQuery += " C7_PRODUTO = '"+cVar+"' AND "
						Else
							cQuery += " C7_FORNECE = '"+cA100For+"' AND "
							cQuery += " C7_PRODUTO = '"+cVar+"' AND "
						Endif
					Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os pedidos de compras de acordo com os contratos             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lConsMedic
						If lNfMedic
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos oriundos de medicoes                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos que nao possuem medicoes                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						EndIf
					EndIf 					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados e Previstos.                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += "C7_TPOP <> 'P' AND "
					If lRestNfe
						cQuery += "C7_CONAPRO <> 'B' AND "
					EndIf					
					If !lToler
						cQuery += " SC7.C7_ENCER='"+Space(Len(SC7->C7_ENCER))+"' AND "
					EndIf
					cQuery += " SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "					

					cQuery += " SC7.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY "+SqlOrder(SC7->(IndexKey()))	

					cQuery := ChangeQuery(cQuery)
					
					//---------------------------//
					//Ponto de Entrada: MT103QPC //
					//---------------------------//
					If ExistBlock("MT103QPC")    
						cQueryQPC := ExecBlock("MT103QPC",.F.,.F.,{cQuery,2})    
						If (ValType(cQueryQPC) == 'C' )
							cQuery := cQueryQPC  
							cQuery := ChangeQuery(cQuery)
						EndIf
					EndIf                                                          
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
					
					For nX := 1 To Len(aEstruSC7)
						If aEstruSC7[nX,2]<>"C"
							TcSetField(cAliasSC7,aEstruSC7[nX,1],aEstruSC7[nX,2],aEstruSC7[nX,3],aEstruSC7[nX,4])
						EndIf
					Next nX										
				Else
			#ENDIF			
				If Empty(cVar)
					DbSelectArea("SC7")
					DbSetOrder(9)
					If lConsLoja
						cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
						cSeek := cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_FORNECE"
						cSeek := cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				Else
					DbSelectArea("SC7")
					DbSetOrder(6)
					If lConsLoja
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
						cSeek := cVar+cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE"
						cSeek := cVar+cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				EndIf
				#IFDEF TOP
				EndIf
				#ENDIF

			If Empty(cVar)
				cCpoObri := "C7_LOJA|C7_PRODUTO|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Else
				cCpoObri := "C7_LOJA|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Endif				

			If (cAliasSC7)->(!Eof())

				DbSelectArea("SX3")
				DbSetOrder(2)

				If lNfMedic .And. lConsMedic

					MsSeek("C7_MEDICAO")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

					MsSeek("C7_CONTRA")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

					MsSeek("C7_PLANILH")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				EndIf 			

				MsSeek("C7_NUM")

				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				DbSelectArea("SX3")
				DbSetOrder(1)
				MsSeek("SC7")
				While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
					IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM" .And.;
							If( lConsMedic .And. lNfMedic, AllTrim(SX3->X3_CAMPO)<>"C7_MEDICAO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_CONTRA" .And. AllTrim(SX3->X3_CAMPO)<>"C7_PLANILH", .T. )).Or.;
							(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
						AAdd(aCab,x3Titulo())
						Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
						aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
					EndIf
					dbSkip()		
				Enddo					

				DbSelectArea(cAliasSC7)
				Do While If(lQuery, ;
						(cAliasSC7)->(!Eof()), ;
						(cAliasSC7)->(!Eof()) .And. xFilEnt(cFilial)+cSeek == &(cCond))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados, Previstos e Eliminados por residuo   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lQuery
						If (lRestNfe .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. ;
								(cAliasSC7)->C7_TPOP == "P" .Or. !Empty((cAliasSC7)->C7_RESIDUO)
							dbSkip()
							Loop
						EndIf
					Endif

					nFreeQT := 0
					nPed    := aScan(aPedido,{|x| x[1] = (cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM})
					nFreeQT -= If(nPed>0,aPedido[nPed,2],0)

					For nAuxCNT := 1 To Len( aCols )
						If (nAuxCNT # n) .And. ;
							(aCols[ nAuxCNT,nPosPRD ] == (cAliasSC7)->C7_PRODUTO) .And. ;
							(aCols[ nAuxCNT,nPosPDD ] == (cAliasSC7)->C7_NUM)     .And. ;
							(aCols[ nAuxCNT,nPosITM ] == (cAliasSC7)->C7_ITEM)    .And. ;
							!ATail( aCols[ nAuxCNT ] )
							nFreeQT += aCols[ nAuxCNT,nPosQTD ]
						EndIf
					Next
					
					lRet103Vpc := .T.

					If lMt103Vpc
						If lQuery
							('SC7')->(MsGoto((cAliasSC7)->RECSC7))
						EndIf															
						lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
					Endif

					If lRet103Vpc
						nFreeQT := (cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT
						If	lToler .And. nFreeQT < 0 
							nFreeQT := 0
						EndIf 

						If nFreeQT > 0 .Or. lToler
							Aadd(aArrayF4,Array(Len(aCampos)))							

							SB1->(DbSetOrder(1))
							SB1->(MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))							
							For nX := 1 to Len(aCampos)

								If aCampos[nX][3] != "V"
									If aCampos[nX][2] == "N"
										If Alltrim(aCampos[nX][1]) == "C7_QUANT"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nX][1]))
										ElseIf Alltrim(aCampos[nX][1]) == "C7_QTSEGUM"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(ConvUm(SB1->B1_COD,nFreeQt,nFreeQt,2),PesqPict("SC7",aCampos[nX][1]))
										Else
											aArrayF4[Len(aArrayF4)][nX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SC7",aCampos[nX][1]))
										Endif											
									Else
										aArrayF4[Len(aArrayF4)][nX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1])))								
									Endif	
								Else
									aArrayF4[Len(aArrayF4)][nX] := CriaVar(aCampos[nX][1],.T.)
									If Alltrim(aCampos[nX][1]) == "C7_CODGRP"
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_GRUPO                            									
									EndIf
									If Alltrim(aCampos[nX][1]) == "C7_CODITE"
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_CODITE
									EndIf
								Endif

							Next

							aAdd(aArrSldo, {nFreeQT, IIF(lQuery,(cAliasSC7)->RECSC7,(cAliasSC7)->(RecNo()))})

							If lMT100C7D
								If lQuery
									('SC7')->(MsGoto((cAliasSC7)->RECSC7))
								EndIf									
								aNew := ExecBlock("MT100C7D", .f., .f., aArrayF4[Len(aArrayF4)])
								If ValType(aNew) = "A"
									aArrayF4[Len(aArrayF4)] := aNew
								EndIf
							EndIf
						EndIf
					Endif
					(cAliasSC7)->(dbSkip())
				EndDo

				If ExistBlock("MT100C7L")
					ExecBlock("MT100C7L", .F., .F., { aArrayF4, aArrSldo })
				EndIf

				If !Empty(aArrayF4)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta dinamicamente o bline do CodeBlock                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi(STR0025+" - <F6> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"

					If lMT100C7C
						aNew := ExecBlock("MT100C7C", .f., .f., aCab)
						If ValType(aNew) == "A"
							aCab := aNew      
							    
							DbSelectArea("SX3")
			 				DbSetOrder(2)								
							
							For nX := 1 to Len(aCab)
						    	If aScan(aCampos,{|x| x[1]= aCab[nX]})==0
        						 If SX3->(MsSeek(aCab[nX]))				
        						 		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
        						 EndIf
   								EndIf
							Next nX
						EndIf
					EndIf

					@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
					oPanel:Align := CONTROL_ALIGN_TOP

					oQual := TWBrowse():New( 29,4,243,85,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					oQual:SetArray(aArrayF4)
					oQual:bLine := { || aArrayF4[oQual:nAT] }
					OQual:nFreeze := 1 

					oQual:Align := CONTROL_ALIGN_ALLCLIENT

					If !Empty(cVar)
						@ 6  ,4   SAY OemToAnsi(STR0063) Of oPanel PIXEL SIZE 47 ,9 //"Produto"
						@ 4  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanel PIXEL SIZE 100,9
					Else
						@ 6  ,4   SAY OemToAnsi(STR0064) Of oPanel PIXEL SIZE 120 ,9 //"Selecione o Pedido de Compra"
					EndIf

					ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
					
				  	If lMt103Sel .And. !Empty(nSavQual)		
				   		nOpca := If(ValType(nMT103Sel:=ExecBlock("MT103SEL",.F.,.F.,{aArrSldo[nSavQual][2]}))=='N',nMT103Sel,nOpca)
				   	Endif     
					If nOpca == 1
						DbSelectArea("SC7")
						MsGoto(aArrSldo[nSavQual][2])
						
   				        // Verifica se o Produto existe Cadastrado na Filial de Entrada
					    DbSelectArea("SB1")
						DbSetOrder(1)
						MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)
						If !Eof()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Qdo digitado o produto no aCols para buscar o PC via F6 e carregado uma TES vinda do  ³
							//³ SB1 se esta for igual a TES digitada no PC o recalculo dos impostos nao e acionado    ³
							//³ na matxfis,para forcar o recalculo o TES do aCols e limpa neste ponto.                ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lUsaFiscal
								aCols[nLinACols][nPosTes] := CriaVar(aHeader[nPosTes][2]) 
								MaFisAlt("IT_TES",aCols[nLinACols][nPosTes],nLinACols)
                            EndIf
                            
							If	!ATail( aCols[ n ] )
								NfePC2Acol(aArrSldo[nSavQual][2],n,aArrSldo[nSavQual][1],,,@aRateio,aHeadSDE,@aColsSDE)
	        				Else
								NfePC2Acol(aArrSldo[nSavQual][2],n+1,aArrSldo[nSavQual][1],,,@aRateio,aHeadSDE,@aColsSDE)        				
	        				EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ValType( oGetDAtu ) == "O"
								oGetDAtu:lNewLine := .F.
								oGetDAtu:oBrowse:Refresh()
							Else
								If Type( "oGetDados" ) == "O"
									oGetDados:lNewLine:=.F. 
									oGetDados:oBrowse:Refresh()
								EndIf
							EndIf
							If ExistBlock("M103PCIT")
								ExecBlock("M103PCIT",.F.,.F.)
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para alterar a moeda, taxa, e check box de taxa negociada de acordo com o Pedido de Compras |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ExistBlock("MT103TXPC") .And. SC7->C7_MOEDA == 2
								nPosItPc := aScan(aCols,{|x| AllTrim(x[nPosPc])==AllTrim(SC7->C7_NUM)})
								n103TXPC := ExecBlock("MT103TXPC",.F.,.F.)
								If ValType(n103TXPC) == "N"
									If n103TXPC > 0
										nTaxaMoeda := n103TXPC
									ElseIf nPosItPc > 0
										nTaxaMoeda := aCols[nPosItPc][nPosVlr] / SC7->C7_PRECO
									EndIf
									lTxNeg := .T.
									nMoedaCor := SC7->C7_MOEDA
								EndIf
							EndIf

							If lPrjCni  
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Controle do Rateio Financeiro                                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If SC7->C7_RATFIN == "1"
									cChaveRat := "SC7"+SC7->C7_FILIAL+SC7->C7_NUM
									F641TrfRat(cChaveRat,@aRatFin,SC7->C7_TOTAL)
								EndIf							
							EndIf
						Else
  						   Aviso("A103ItemPC",STR0302,{"Ok"})
						EndIf
					EndIf
					
					If lPrjCni
						//Grava rateio financeiro
						If Len(aRatFin) > 0
							cChaveRat := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja
							F641GrvRat(cChaveRat,aRatFin)
							aRatFin := {}
						EndIf

					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFiscal
						Eval(bRefresh)
					Else
						aGets[SEGURO] += aRateio[1]
						aGets[VALDESP]+= aRateio[2]
						aGets[FRETE]  += aRateio[3]
					EndIf
				Else
					Help(" ",1,"A103F4")
				EndIf
			Else
				Help(" ",1,"A103F4")
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf

Endif

If lQuery
	DbSelectArea(cAliasSC7)
	dbCloseArea()
	DbSelectArea("SC7")
Endif	

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)
RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aArea)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a103PesqP ³ Autor ³ Henry Fila            ³ Data ³17.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Seek no browse de itens de pedidos de compra                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array das descricoes dos cabecalhos                  ³±±
±±³          ³ExpA2 : Array com os campos                                  ³±±
±±³          ³ExpA3 : Array com os conteudos                               ³±±
±±³          ³ExpO4 : Objeto do listbox                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo abrir uma janela de pesquisa   ³±±
±±³          ³em browses de getdados poisicionando na llinha caso encontre ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function a103PesqP(aCab,aCampos,aArrayF4,oQual)

Local aCpoBusca	:= {}
Local aCpoPict	:= {}
Local aComboBox	:= { AllTrim( STR0168 ) , AllTrim( STR0169 ) , AllTrim( STR0170 ) } //"Exata"###"Parcial"###"Contem"

Local bAscan	:= { || .F. }

Local cPesq		:= Space(30)
Local cBusca	:= ""
Local cTitulo	:= OemtoAnsi(STR0001)  //"Pesquisar"
Local cOpcAsc	:= aComboBox[1]	//"Exata"
Local cAscan	:= ""

Local nOpca		:= 0
Local nPos		:= 0
Local nx		:= 0
Local nTipo		:= 1
Local nBusca	:= Iif(oQual:nAt == Len(aArrayF4) .Or. oQual:nAt == 1, oQual:nAt, oQual:nAt+1 )

Local oDlg
Local oBusca
Local oPesq1
Local oPesq2
Local oPesq3
Local oPesq4
Local oComboBox

For nX := 1 to Len(aCampos)
	AAdd(aCpoBusca,aCab[nX])
	AAdd(aCpoPict,aCampos[nX][4])
Next	

If Len(aCampos) > 0 .And. Len(aArrayF4) > 0

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(cTitulo)  FROM 00,0 TO 100,490 OF oMainWnd PIXEL

	@ 05,05 MSCOMBOBOX oBusca VAR cBusca ITEMS aCpoBusca SIZE 206, 36 OF oDlg PIXEL ON CHANGE (nTipo := oBusca:nAt,A103ChgPic(nTipo,aCampos,@cPesq,@oPesq1,@oPesq2,@oPesq3,@oPesq4))

	@ 022,005 MSGET oPesq1 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL
	@ 022,005 MSGET oPesq2 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL
	@ 022,005 MSGET oPesq3 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL
	@ 022,005 MSGET oPesq4 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL

	oPesq1:Hide()
	oPesq2:Hide()
	oPesq3:Hide()	
	oPesq4:Hide()		

	Do Case
		Case aCampos[1][2] == "C"
			DbSelectArea("SX3")
			DbSetOrder(2)
			If MsSeek(aCampos[1][1])
				If !Empty(SX3->X3_F3)
					oPesq2:cF3 := SX3->X3_F3
					oPesq1:Hide()				
					oPesq2:Show()				
					oPesq3:Hide()
					oPesq4:Hide()
				Else	
					oPesq1:Show()			
					oPesq2:Hide()
					oPesq3:Hide()				
					oPesq4:Hide()				
				Endif
			Endif		

		Case aCampos[1][2] == "D"
			oPesq1:Hide()
			oPesq2:Hide()				
			oPesq3:Show()
			oPesq4:Hide()
			
		Case aCampos[1][2] == "N"
			oPesq1:Hide()
			oPesq2:Hide()				
			oPesq3:Hide()
			oPesq4:Show()						
	EndCase

	cPesq := CriaVar(aCampos[1][1],.F.)
	cPict := aCampos[1][4]

	DEFINE SBUTTON oBut1 FROM 05, 215 TYPE 1 ACTION ( nOpca := 1, oDlg:End() ) ENABLE of oDlg		 	
	DEFINE SBUTTON oBut1 FROM 20, 215 TYPE 2 ACTION ( nOpca := 0, oDlg:End() )  ENABLE of oDlg		

	@ 037,005 SAY OemtoAnsi(STR0035) SIZE 050,10 OF oDlg PIXEL //Tipo
	@ 037,030 MSCOMBOBOX oComboBox VAR cOpcAsc ITEMS aComboBox SIZE 050,10 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		Do Case
			Case aCampos[nTipo][2] == "C"
				IF ( cOpcAsc == aComboBox[1] )	//Exata
					cAscan := Padr( Upper( cPesq ) , TamSx3(aCampos[nTipo][1])[1] )
					bAscan := { |x| cAscan == Upper( x[ nTipo ] ) }
				ElseIF ( cOpcAsc == aComboBox[2] )	//Parcial
					cAscan := Upper( AllTrim( cPesq ) )
					bAscan := { |x| cAscan == Upper( SubStr( Alltrim( x[nTipo] ) , 1 , Len( cAscan ) ) ) }
				ElseIF ( cOpcAsc == aComboBox[3] )	//Contem
					cAscan := Upper( AllTrim( cPesq ) )
					bAscan := { |x| cAscan $ Upper( Alltrim( x[nTipo] ) ) }
				EndIF
				nPos := Ascan( aArrayF4 , bAscan )
				
			Case aCampos[nTipo][2] == "N"		
				nPos := Ascan(aArrayF4,{|x| Transform(cPesq,PesqPict("SC7",aCampos[nTipo][1])) == x[nTipo]},nBusca)	
				
			Case aCampos[nTipo][2] == "D"
				nPos := Ascan(aArrayF4,{|x| Dtos(cPesq) == Dtos(x[nTipo])},nBusca)
		EndCase

		If nPos > 0
			oQual:bLine := { || aArrayF4[oQual:nAT] }
			oQual:nFreeze := 1
			oQual:nAt := nPos                		
			oQual:Refresh()
			oQual:SetFocus()
		Else
			Help(" ",1,"REGNOIS")	
		Endif	
	EndIf
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a103ChgPic³ Autor ³ Henry Fila            ³ Data ³17.07.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Atualiza picture na funcao a103PespP                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Posicao do campo no Array                            ³±±
±±³          ³ExpA2 : Array com os dados dos campos                        ³±±
±±³          ³ExpX3 : Pesquisa                                             ³±±
±±³          ³ExpO4 : Objeto de pesquisa                                   ³±±
±±³          ³ExpO5 : Objeto de pesquisa                                   ³±±
±±³          ³ExpO6 : Objeto de pesquisa                                   ³±±
±±³          ³ExpO7 : Objeto de pesquisa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo tratar a picture do campo sele ³±±
±±³          ³cionado na funcao GdSeek                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103ChgPic(nTipo,aCampos,cPesq,oPesq1,oPesq2,oPesq3,oPesq4)

Local cPict   := ""
Local aArea   := GetArea()
Local aAreaSX3:= SX3->(GetArea())
Local bRefresh


DbSelectArea("SX3")
DbSetOrder(2)
If MsSeek(aCampos[nTipo][1])
	Do case
		Case aCampos[nTipo][2] == "C"
			If !Empty(SX3->X3_F3)
				oPesq2:cF3 := SX3->X3_F3
				oPesq1:Hide()
				oPesq2:Show()			
				oPesq3:Hide()
				oPesq4:Hide()			
				bRefresh := { || oPesq2:oGet:Picture := cPict,oPesq2:Refresh() }
			Else	
				oPesq1:Show()
				oPesq2:Hide()
				oPesq3:Hide()			
				oPesq4:Hide()			                                     			
				bRefresh := { || oPesq1:oGet:Picture := cPict,oPesq1:Refresh() }		
			Endif

		Case aCampos[nTipo][2] == "D"
			oPesq1:Hide()
			oPesq2:Hide()
			oPesq3:Show()			
			oPesq4:Hide()			                                                    		
			bRefresh := { || oPesq3:oGet:Picture := cPict,oPesq3:Refresh() }				
			
		Case aCampos[nTipo][2] == "N"
			oPesq1:Hide()
			oPesq2:Hide()
			oPesq3:Hide()
			oPesq4:Show()
			bRefresh := { || oPesq4:oGet:Picture := cPict,oPesq4:Refresh() }				
	EndCase
Endif		

If nTipo > 0
	cPesq := CriaVar(aCampos[nTipo][1],.F.)
	cPict := aCampos[nTipo][4]
EndIf							

Eval(bRefresh)

RestArea(aAreaSX3)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103GrvAtf³ Autor ³ Edson Maricate        ³ Data ³ 06.01.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao do Ativo Fixo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpc    : 1 - Inclusao / 2 - Exclusao                       ³±±
±±³          ³cBase   : Codigo Base do Ativo                              ³±±
±±³          ³cItem   : Item da Nota Fiscal                               ³±±
±±³          ³cCodCiap: Codigo do Ciap Gerado                             ³±±
±±³          ³nVlrCiap: Valor do Ciap Gerado                              ³±±
±±³          ³aRateio	-> Array: Rateio de compras que integrara com o   		³±±
±±³          ³			rateio da ficha de ativo (SNV)					  		³±±
±±³          ³	aRateio[i,1] -> char: Item do Documento de Entrada		  		³±±
±±³          ³	aRateio[i,2] -> array: acols do rateio do item do Doc. Entrada	³±±
±±³          ³		aRateio[i,2,j] -> array: linha do acols 					³±±
±±³          ³		aRateio[i,2,j,1] -> char: item do rateio 					³±±
±±³          ³		aRateio[i,2,j,2] -> Numeric: Percentual 					³±±
±±³          ³		aRateio[i,2,j,3] -> char: Centro de Custo 					³±±
±±³          ³		aRateio[i,2,j,4] -> char: Conta Contabil 					³±±
±±³          ³		aRateio[i,2,j,5] -> char: Item da Conta Contabil			³±±
±±³          ³		aRateio[i,2,j,6] -> char: Classe de valor					³±±
±±³          ³		aRateio[i,2,j,7] -> boolean: 								³±±
±±³          ³cChave  : Chave de busca para excluir ajuste de Nt. Cr/Db.        ³±±
±±³          ³aDIfDec : Array com controle das diferenças de decimais a partir  ³±±
±±³          ³          Da terceira casa decimal para o ICMS do bem.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Este Programa grava um ativo por item de NF, alterando-se o       ³±±
±±³          ³Item do ativo. Nem todos os dados do Ativo serao gravados         ³±±
±±³          ³pois nao ha todas as informacoes na nota fiscal e o classidor     ³±±
±±³          ³da Nota Fiscal nao tem condicoes de faze-lo.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador         ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			 ³					   ³Incluida a integracao do rateio de compras  ³±±
±±³27/04/2011³Fernando Radu Muscalu³com o rateio de gastos da depreciacao dos   ³±±
±±³          ³                     ³bens  									 	³±±
±±³ 15/06/11 ³ Danilo Dias         ³ Gravação/Exclusão de ajuste de Nt. Cr/Db   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103GrvAtf( nOpc, cBase, cItem, cCodCiap, nVlrCiap, aCIAP, aVlrAcAtf,aRateio, cChave,aDIfDec )

Local aArea      := GetArea()
Local aSavaHead  := aClone(aHeader)
Local aSavaCols  := aClone(aCols)
Local nSavN      := N
Local nUsado     := 0
Local nCntFor    := 0
Local nVlRatF    := 0
Local nQtdD1     := Iif((SD1->D1_TIPO == "C" .Or. SD1->D1_TIPO == "I").And. SD1->D1_ORIGLAN <>"FR",GetQOri(xFilial("SD1"),SD1->D1_NFORI,SD1->D1_SERIORI,SD1->D1_ITEMORI,SD1->D1_COD,SD1->D1_FORNECE,SD1->D1_LOJA),Iif((SD1->D1_TIPO == "C" .Or.SD1->D1_TIPO == "I").And. SD1->D1_ORIGLAN =="FR",1,SD1->D1_QUANT))
Local lGravou    := .F.
Local lAtuSX6    := .F.
Local lIncAnt    := .F.
Local nMoeda     := iif(cPaisLoc == "BRA",1,SF1->F1_MOEDA)
Local nAtfQtdIt  := iif(SF4->F4_BENSATF == "1".And.nQtdD1>=1,nQtdD1,1)
Local bValAtf    := { || &( SuperGetMv( "MV_VLRATF",.F.,'(SD1->D1_TOTAL-SD1->D1_VALDESC)+If(SF4->F4_CREDIPI=="S",0,SD1->D1_VALIPI)-IIf(SF4->F4_CREDICM=="S",SD1->D1_VALICM,0)' ) ) }
Local aRetAtf    := {}
Local nVlrMoed   := 0
Local aTamVOrig  := {}
Local lF4BensATF := iif(SF4->(FieldPos("F4_BENSATF")) > 0,iif(SF4->F4_BENSATF == "1".And.nQtdD1>=1,.T.,.F.),.F.)
Local lATFDCBA   := GETMV("MV_ATFDCBA",.F.,"0") == "1" // "0"- Desmembra itens / "1" - Desmembra codigo base
Local aATFPMS    := {}
Local aParamAFN  := aClone(aRatAFN)
//Salva ambiente
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSN1  := SN1->(GetArea())
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN4  := SN4->(GetArea())
Local aTmpSN1   := {}
Local aTmpSN3   := {}
Local aTmpSD1   := {}
Local aTmpSN4   := {}

//Variáveis locais
Local lMultMoed  := FindFunction("AtfMoedas")
Local lAjustaNCD := SuperGetMV( "MV_ATFNCRD", .T., .F. )
Local cRotBaixa  := SuperGetMV( "MV_ATFRTBX", .T., "ATFA030")
Local lATFNFIN   := SuperGetMV( "MV_ATFNFIN", .T., .T. )  
Local lATFVdProp := SuperGetMV( "MV_ATFVDPR", .T., .T. )
Local lRet       := .T.
Local nQtdBaixa  := 0
Local cCodBase   := ""
Local nI         := 0
Local nJ         := 0
Local nX         := 0
Local nMoedas    := IIf( lMultMoed, AtfMoedas(), 5 )
Local cMoeda     := ""
Local nVlrOrig   := 0
Local cQuery     := ""
Local cAliasQry  := ""
Local nItens     := 0 
Local cUltItem   := ""
Local cUltCBase  := ""
Local nRecno     := 0
Local aVlrTipo01 := {}
Local cIdMov     := ""
Local aStruct    := {}
Local cCriDepr  := "" 
Local lMontaRat  := .F. 
Local aNewRat    := {}
Local aRelImp    := MaFisRelImp("MT100",{ "SD1" })
Local nScanPis 	 := 0
Local cCpBsPisEn :=	 ""
Local nScanCof 	 := 0
Local cCpBsCofEn := ""
Local lStrutNCD  := !Empty( SN1->( IndexKey(8) ) ) .And. SN1->(FieldPos("N1_NFESPEC")) > 0 .And. SN1->(FieldPos("N1_NFITEM")) > 0       
Local nPosCv	:= 0
Local cLoopEnt	 := ""
Local cEntConDB	 := ""
Local cEntConCR	 := ""
Local nPosEntCon := 0
Local aEntCon	 := {}
Local lCompone	 := SF4->(FIELDPOS("F4_COMPONE")) > 0

STATIC aCrVSN3	:= {}
STATIC lCarrega	:= .T.

Default aCIAP	:= {}
Default aVlrAcAtf	:=	{0,0,0,0,0}
Default aRateio		:= {}
Default cChave		:= ""
DEFAULT aDIfDec		:= {0,.F.}

DEFAULT lN1Staus	 := SN1->(FieldPos("N1_STATUS")) > 0      
DEFAULT lN1Especie := SN1->(FieldPos("N1_NFESPEC")) > 0 .And. SF1->(FieldPos("F1_ESPECIE")) > 0
DEFAULT lN1NFItem  :=SN1->(FieldPos("N1_NFITEM")) > 0 .And. SD1->(FieldPos("D1_ITEM")) > 0
DEFAULT lN1Prod    :=SN1->(FieldPos("N1_PRODUTO")) > 0
DEFAULT lN1Orig    :=SN1->(FieldPos("N1_ORIGCRD")) > 0      
DEFAULT lN1CstPis  :=SN1->(FieldPos("N1_CSTPIS")) > 0
DEFAULT lN1AliPis   :=SN1->(FieldPos("N1_ALIQPIS")) > 0
DEFAULT lN1CstCof  :=SN1->(FieldPos("N1_CSTCOFI")) > 0
DEFAULT lN1AliCof  :=SN1->(FieldPos("N1_ALIQCOF")) > 0


If (ExistBlock ("ATFA006102"))
	aRetAtf	:=	ExecBlock ("ATFA006102", .F., .F., {nOpc, cBase, cItem, cCodCiap, nVlrCiap})
	If (aRetAtf[1])
		cBase	:=	aRetAtf[2]
		Return (.T.)
	EndIf
EndIf

If Len(aRateio) == 0 .Or. ValType(aRateio) <> "A"
	aRateio   := {}
	lMontaRat := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para arredondamento das casas decimais dos valores a gravar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aTamVOrig,TamSx3("N3_VORIG1"))
AADD(aTamVOrig,TamSx3("N3_VORIG2"))
AADD(aTamVOrig,TamSx3("N3_VORIG3"))
AADD(aTamVOrig,TamSx3("N3_VORIG4"))
AADD(aTamVOrig,TamSx3("N3_VORIG5"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A rotina a seguir e uma protecao devido a falha no dicionario padrao    ³
//³onde a expressao cadastrada no parametro MV_VLRATF foi cadastrada com   ³
//³Aspas, isso faz com que a macro do codblock retorne uma string.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlRatF := Eval( bValAtf )
If ValType(nVlRatF) <> "N"
	nVlRatF := &(nVlRatF)
EndIf

If nOpc == 1
	PRIVATE uCampo	:= ""
	PRIVATE aHeader := {}
	PRIVATE aCols	:= {}
	PRIVATE N       := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o Codigo Base do Ativo                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT103AFN")
		aATFPMS := ExecBlock("MT103AFN",.F.,.F.,{aParamAFN,SF4->F4_ATUATF,SF4->F4_BENSATF,lATFDCBA})
		If ValType(aATFPMS) == "A" .and. ValType(aATFPMS[1]) == "C" .and. ValType(aATFPMS[2]) == "C"
			cBase    := aATFPMS[1]                   
			cItem    := aATFPMS[2]
		EndIf	                       
    Endif

	If (Empty(cBase)) .OR. (lF4BensATF .AND. lATFDCBA)
		SuperGetMV("MV_CBASEAF",.F.)
		If ( RecLock("SX6") )
			cBase := &(SuperGetMV("MV_CBASEAF",.F.))
			If ( AllTrim(cBase) $ SuperGetMV("MV_CBASEAF",.F.) )
				lAtuSX6 := .T.
			EndIf
		EndIf                                          
		DbSelectArea("SN1")
		DbSetOrder(1)
		While MsSeek(xFilial("SN1")+cBase)
			cBase := Soma1(cBase,Len(SN1->N1_CBASE))
		EndDo
		If ( lAtuSX6 )
			PutMV("MV_CBASEAF",'"'+Soma1(cBase,Len(SN1->N1_CBASE))+'"')
		EndIf
		SX6->(MsUnLock())
	EndIf
	If ( !Empty(cBase) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as Variaveis do SN1                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aCposSN1) == "A" .And. Len(aCposSN1)>=1
        	For nX :=1 to Len(aCposSN1)
				M->&(aCposSN1[nX,1]) := aCposSN1[nX,3]
        	Next nX
		Else
			DbSelectArea("SX3")
			DbSetOrder(1)
			MsSeek("SN1")
			While ( !Eof() .And. SX3->X3_ARQUIVO == "SN1" )
				uCampo := SX3->X3_CAMPO
			
				M->&(uCampo) := CriaVar(SX3->X3_CAMPO,IIF(SX3->X3_CONTEXT=="V",.F.,.T.))
				If ValType(aCposSN1) == "A"
					aAdd(aCposSN1,{SX3->X3_CAMPO,SX3->X3_CONTEXT,M->&(uCampo)})
				EndIf	
				DbSelectArea("SX3")
				dbSkip()
			EndDo
	    EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o aHeader do SN3                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aBkpHeader) == "A" .And. Len(aBkpHeader) >= 1
			For nX := 1 to Len(aBkpHeader)
				Aadd(aHeader,aBkpHeader[nX])
				nUsado++
			Next nX
		Else
			DbSelectArea("SX3")
			DbSetOrder(1)
			MsSeek("SN3")
			While ( !Eof() .And. SX3->X3_ARQUIVO == "SN3" )
				If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
					Aadd(aHeader ,{ Trim(X3TITULO()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT } )
					nUsado++
				EndIf
				DbSelectArea("SX3")
				dbSkip()
			EndDo
			If ValType(aBkpHeader) == "A" 
				aBkpHeader := aClone(aHeader)
			EndIf
		EndIf	
		//Posiciono o campo correto com a aliquota do PIS da tabela SD1
		If !Empty( nScanPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
			cCpBsPisEn := aRelImp[nScanPis,2]
		EndIf
		
		//Posiciono o campo correto com a aliquota da COFINS da tabela SD1
		If !Empty( nScanCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
			cCpBsCofEn := aRelImp[nScanCof,2]
		EndIf 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona Registros Necessarios                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		DbSetOrder(1)
		MsSeek(xFilial("SB1")+SD1->D1_COD)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o aCols                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aCols,Array(nUsado+1))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento das Variaveis referentes ao SN1                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->N1_CBASE		:= cBase
		M->N1_ITEM		:= cItem
		M->N1_AQUISIC	:= SD1->D1_DTDIGIT
		M->N1_DESCRIC	:= SB1->B1_DESC
		M->N1_QUANTD	:= nQtdD1 / nAtfQtdIt
		M->N1_FORNEC	:= SD1->D1_FORNECE
		M->N1_LOJA		:= SD1->D1_LOJA
		M->N1_NSERIE	:= SD1->D1_SERIE
		M->N1_NFISCAL	:= SD1->D1_DOC
		M->N1_CHASSI	:= SD1->D1_CHASSI
		M->N1_PLACA		:= SD1->D1_PLACA
		M->N1_PATRIM	:= "N"
		M->N1_CODCIAP	:= cCodCiap		
		M->N1_ICMSAPR	:= NoRound((nVlrCiap / nAtfQtdIt),2)
		
		//Acumula valor da diferenca a partir da 3 casa decimal em aDIfDec[1]
		aDIfDec[1]+= (nVlrCiap / nAtfQtdIt) - NoRounD(nVlrCiap / nAtfQtdIt,2)
		
		//Se aDIfDec[2] == .T. então quer dizer que é o último bem, e neste será somado os valores de diferenças a partir da 3 casa decimal dos bens anteriores.
		If aDIfDec[2] == .T.
			M->N1_ICMSAPR	:= M->N1_ICMSAPR + aDIfDec[1]
		EndIF
		
		If lN1Staus
			M->N1_STATUS	:= "0"
		EndIf
		If lN1Especie
		    M->N1_NFESPEC := SF1->F1_ESPECIE
		EndIf                               
		If lN1NFItem
		    M->N1_NFITEM := SD1->D1_ITEM
		EndIf                               
		If lN1Prod
		    M->N1_PRODUTO := SD1->D1_COD
		EndIf                                                                                                  
		
		If lN1Orig
		    M->N1_ORIGCRD := Iif(Left(SD1->D1_CF,1)=="3","1","0")
		EndIf
		If lN1CstPis 
		    M->N1_CSTPIS := SF4->F4_CSTPIS
		EndIf
		If lN1AliPis
		    M->N1_ALIQPIS := SD1->&(cCpBsPisEn)
		EndIf
		If lN1CstCof
		    M->N1_CSTCOFI := SF4->F4_CSTCOF
		EndIf
		If lN1AliCof
		    M->N1_ALIQCOF := SD1->&(cCpBsCofEn)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenchimento das Variaveis referentes ao SN3                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aBkpAcols")=="A" .And. Len(aBkpAcols) >= 1
			aCols := aClone(aBkpAcols)
		Else
			For nCntFor := 1 To nUsado
				Do Case
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_TIPO" )
					aCols[1][nCntFor] := If(lCompone, If( SF4->F4_COMPONE == '1', "03","01"), "01")
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_BAIXA" )
					aCols[1][nCntFor] := "0"
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_CCONTAB" )
					aCols[1][nCntFor] := "" // SD1->D1_CONTA
					// Nao grava este campo em hipotese alguma
					// pois o controle de classificacao do Ativo
					// eh feito por este campo
					// Wagner Xavier e Eduardo Riera
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_CCUSTO" )		// Centro de Custo
					aCols[1][nCntFor] := SD1->D1_CC
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_SUBCCON" )		// Item Contabil
					aCols[1][nCntFor] := SD1->D1_ITEMCTA
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_CLVLCON" )		// Classe de Valor
					aCols[1][nCntFor] := SD1->D1_CLVL
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_VORIG1" )
					
					nVlrMoed	:=	Round(xMoeda( nVlRatF,nMoeda,1,SD1->D1_DTDIGIT,aTamVOrig[1][2]+1,SF1->F1_TXMOEDA),aTamVOrig[1][2])
					aCols[1][nCntFor] := nVlrMoed/nAtfQtdIt
					
					If aVlrAcAtf[1]+aCols[1][nCntFor]>nVlrMoed
						aCols[1][nCntFor]	:=	nVlrMoed-aVlrAcAtf[1]
					EndIf
					aVlrAcAtf[1]	+=	Round(aCols[1][nCntFor],aTamVOrig[1][2])
					
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_VORIG2" )
	
					nVlrMoed	:=	Round(xMoeda( nVlRatF,nMoeda,2,SD1->D1_DTDIGIT,aTamVOrig[2][2]+1,SF1->F1_TXMOEDA),aTamVOrig[2][2])
					aCols[1][nCntFor] := nVlrMoed/nAtfQtdIt
	
					If aVlrAcAtf[2]+aCols[1][nCntFor]>nVlrMoed
						aCols[1][nCntFor]	:=	nVlrMoed-aVlrAcAtf[2]
					EndIf
					aVlrAcAtf[2]	+=	Round(aCols[1][nCntFor],aTamVOrig[2][2])
	
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_VORIG3" )
	
					nVlrMoed	:=	Round(xMoeda( nVlRatF,nMoeda,3,SD1->D1_DTDIGIT,aTamVOrig[3][2]+1,SF1->F1_TXMOEDA),aTamVOrig[3][2])
					aCols[1][nCntFor] := nVlrMoed/nAtfQtdIt
	
					If aVlrAcAtf[3]+aCols[1][nCntFor]>nVlrMoed
						aCols[1][nCntFor]	:=	nVlrMoed-aVlrAcAtf[3]
					EndIf
					aVlrAcAtf[3]	+=	Round(aCols[1][nCntFor],aTamVOrig[3][2])
	
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_VORIG4" )
	
					nVlrMoed	:=	Round(xMoeda( nVlRatF,nMoeda,4,SD1->D1_DTDIGIT,aTamVOrig[4][2]+1,SF1->F1_TXMOEDA),aTamVOrig[4][2])
					aCols[1][nCntFor] := nVlrMoed/nAtfQtdIt
	
					If aVlrAcAtf[4]+aCols[1][nCntFor]>nVlrMoed
						aCols[1][nCntFor]	:=	nVlrMoed-aVlrAcAtf[4]
					EndIf
					aVlrAcAtf[4]	+=	Round(aCols[1][nCntFor],aTamVOrig[4][2])
	
				Case ( AllTrim(aHeader[nCntFor][2]) == "N3_VORIG5" )
	
					nVlrMoed	:=	Round(xMoeda( nVlRatF,nMoeda,5,SD1->D1_DTDIGIT,aTamVOrig[5][2]+1,SF1->F1_TXMOEDA),aTamVOrig[5][2])
					aCols[1][nCntFor] := nVlrMoed/nAtfQtdIt
	
					If aVlrAcAtf[5]+aCols[1][nCntFor]>nVlrMoed
						aCols[1][nCntFor]	:=	nVlrMoed-aVlrAcAtf[5]
					EndIf
					aVlrAcAtf[5]	+=	Round(aCols[1][nCntFor],aTamVOrig[5][2])
	
				OtherWise
				If lCarrega 
					Aadd(aCrVSN3,{ aHeader[nCntFor][2],;
					CriaVar(aHeader[nCntFor][2],IIF(SX3->X3_CONTEXT=="V",.F.,.T.))} )
				Endif 	
				If Ascan(aEntCon,{|x| x == AllTrim(aHeader[nCntFor][2])}) == 0
					nPosCv:= Ascan(aCrVSN3,{|x| x [1]== aHeader[nCntFor][2]})
					aCols[1][nCntFor] := aCrVSN3[nPosCv][2]
				EndIf
				EndCase

				// Tratamento para levar as entidades contabeis para classificacao de compras no ATF
				cLoopEnt  := PADL(cValToChar(nCntFor),2,"0")
				cEntConDB := "EC"+cLoopEnt+"DB"
				cEntConCR := "EC"+cLoopEnt+"CR"
				If ( nPosEntCon := aScan( aHeader, { |x| Alltrim(x[2]) == ("N3_"+cEntConDB) } )) > 0 .And.;
				   SD1->(FieldPos("D1_"+cEntConDB)) > 0
					aCols[1][nPosEntCon] := SD1->&("D1_"+cEntConDB)
					AADD(aEntCon,("N3_"+cEntConDB))
				EndIf
				If ( nPosEntCon := aScan( aHeader, { |x| Alltrim(x[2]) == ("N3_"+cEntConCR) } )) > 0 .And.;
				   SD1->(FieldPos("D1_"+cEntConCR)) > 0
					aCols[1][nPosEntCon] := SD1->&("D1_"+cEntConCR)
					AADD(aEntCon,("N3_"+cEntConCR))
				EndIf
			Next nCntFor   
			lCarrega := .F.
			If Type("aBkpAcols")=="A"
				aBkpAcols := aClone(aCols)
			EndIf
	    EndIf

		aCols[1][nUsado+1] := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa as Variaveis Privates utilizadas pela funcao af010Grava      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCopia			:= .F.
		lContabiliza	:= .F.
		lHeader			:= .F.
		lTrailler		:= .F.
		lCProva			:= .F.
		Inclui			:= .T.

        //Incluido por Fernando Radu Muscalu em 28/04/2011
        //Monta o Rateio de Despesas de Depreciacao da Ficha do ativo para o cItem (item corrente do Doc Entrada) passado como
        //conteudo do array aRateio e proveniente de aRatCC, que foi adquirido na tela do documento de 
        //entrada.
        aNewRat := A103SetRateioBem( aRateio, SD1->D1_ITEM )
        
		DbSelectArea("SN1")
		Pergunte("AFA010",.F.)
		lGravou := Af010Grava("SN1","SN3",.F.,.T.,.F.,,,,,,aNewRat)
		If ( lGravou )
			RecLock("SD1")
			SD1->D1_CBASEAF := cBase+cItem
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna ao Estado de Entrada                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:= aClone(aSavaHead)
	aCols	:= aClone(aSavaCols)
	N       := nSavN
	Pergunte("MTA103",.F.)
ElseIf nOpc == 100 .And. lAjustaNCD .And. lStrutNCD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Integração de Notas de Crédito com Ativo para ajuste no valor do bem ³
//³Ajusta o valor do bem efetuando uma baixa no valor da nota.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//Variáveis private para a função de baixa do ativo Af035Grava/Af030Grava e Af035Parcial.    
	Private	dBaixa030  := dDataBase
	Private lSN7       := .F.
	Private cMotivo	   := "14"
	Private lQuant	   := .F.
	Private lPrim	   := .T.
	Private cLoteAtf   := LoteCont("ATF")                                                                      
	Private nPercBaixa := 100 
	Private lAuto      := .T. 
	Private lUmaVez	   := .T.
	Private cMoedaAtf  := GetMV("MV_ATFMOEDA")
	Private aVlrAtual  := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
	Private aVlResid   := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
	Private aValBaixa  := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
	Private aValDepr   := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
	Private aDepr 	   := If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )

	//Localiza o documento de entrada original (Nota Fiscal ou Remito). 
	//O SD2 deve estar aberto e ter sido posicionado no registro do bem a ajustar.
	dbSelectArea("SD1")	
	SD1->( dbSetOrder(1) )	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->( dbSeek( xFilial("SD2") + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_ITEMORI ) ) 
	                           
	//Localiza o ativo gerado através do documento de entrada.
	dbSelectArea("SN1")
	SN1->( dbSetOrder(8) )	//N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM
	If ( SN1->( dbSeek( xFilial("SD1") + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ESPECIE + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_ITEM ) ) )
	
		dbSelectArea("SN3")
		SN3->( dbSetOrder(1) )	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
		
		A103QtItem( "SD1", @nItens )	//Verifica quantos itens foram gerados pelo documento de entrada
		
		//Atualiza todos os bens gerados pelo item do documento de entrada, independente
		//de código base, tratando TES configurada para desmembrar o item ou não.	   
		While SN1->(!Eof()) .And.;
			  SN1->N1_FORNEC  == SD1->D1_FORNECE .And.;
			  SN1->N1_LOJA    == SD1->D1_LOJA    .And.;
			  SN1->N1_NFESPEC == SD1->D1_ESPECIE .And.;
			  SN1->N1_NFISCAL == SD1->D1_DOC     .And.;
			  SN1->N1_NSERIE  == SD1->D1_SERIE   .And.;
			  SN1->N1_NFITEM  == SD1->D1_ITEM      
			
			SN3->( dbSeek( xFilial("SN1") + SN1->N1_CBASE + SN1->N1_ITEM ) )
		    
			//Atualiza os valores para cada tipo de depreciação criada na classificação do bem.
			//Trata apenas os tipos "01" e o tipo "10" se o parâmetro MV_ATFNFIN estiver igual a .T.
			While SN3->(!Eof()) .And.; 
			      SN3->N3_CBASE + SN3->N3_ITEM == SN1->N1_CBASE + SN1->N1_ITEM
			
				If SN3->N3_TIPO == "01" .And. SN3->N3_BAIXA == "0"	//Trata se for tipo 01 e se não é baixa
					For nI := 1 to nMoedas
						cMoeda := Alltrim(Str(nI))
						aVlrAtual[nI]  := Abs( SN3->&( "N3_VORIG" + cMoeda ) )
						IIf ( aVlrAtual[nI] == 0, aValBaixa[nI] := 0, aValBaixa[nI] := ( SD2->D2_TOTAL / nItens ) ) 
						aAdd( aVlrTipo01, aVlrAtual[nI] )				
					Next nI	
				ElseIf SN3->N3_TIPO == "10" .And. lATFNFIN .And. SN3->N3_BAIXA == "0"	//Trata se for tipo 10 e parâmetro MV_ATFNFIN for True
					For nI := 1 to nMoedas                              
						cMoeda := Alltrim(Str(nI))
						nVlrOrig := Abs( SN3->&( "N3_VORIG" + cMoeda ) )
						
						If aVlrTipo01[nI] != 0
							aValBaixa[nI] := ( SD2->D2_TOTAL * ( nVlrOrig / aVlrTipo01[nI] ) ) / nItens
						Else
							aValBaixa[nI] := 0 
						EndIf
						
						aVlrAtual[nI] := nVlrOrig
					Next nI
				Else	//Se não for tipo 01 ou 10 com MV_ATFNFIN=.T. não faz nada
					SN3->(dbSkip())
					Loop				
				EndIf			
				
				//Salva ambiente antes de gravar
				aTmpSN1 := SN1->(GetArea())
				aTmpSN3 := SN3->(GetArea())
				aTmpSD1 := SD1->(GetArea())
				
				//Atualiza valor do ativo
				If AllTrim(cRotBaixa) == "ATFA030"
					Af030Calc( "SN3", SN1->N1_NFISCAL, SN1->N1_NSERIE, .F., 0, SN1->N1_QUANTD , .T., @cIdMov )
				Else
			    	Af035Grava( "SN3", SN1->N1_NFISCAL, SN1->N1_NSERIE, .F., 0, SN1->N1_QUANTD , .T., @cIdMov ) 
				EndIf
			    
			    //Restaura ambiente
			    RestArea(aTmpSN1)
			    RestArea(aTmpSN3)
			    RestArea(aTmpSD1)
			    
			    //Grava ID do movimento (SN4) no item da nota
			    If SN3->N3_TIPO == "01"
					Reclock("SD2")
					Replace SD2->D2_CBASEAF With cIdMov
					MSUnlock()
			    EndIf
			    
				SN3->(dbSkip())
			EndDo	//While SN3
			
		    SN1->(dbSkip())
		EndDo	//While SN1                                                                                 	
		               
		lGravou := .T.
	
	EndIf //If do Seek no SN1
	
	//Restaura areas usadas
	RestArea(aAreaSN1)
	RestArea(aAreaSD1)

ElseIf nOpc == 101 .And. lAjustaNCD .And. lStrutNCD	   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Integração de Notas de Débito com Ativo para ajuste no valor do bem. ³
//³Incorpora novo item para cada bem gerado pelo documento de entrada.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Private aHeader := {}
    Private aCols   := {}
    
    //Inicializa aHeader do SN3 para gravação do ativo
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SN3"))
	While ( !Eof() .And. SX3->X3_ARQUIVO == "SN3" )
		If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL ) .Or. "N3_AMPLIA" $ SX3->X3_CAMPO
			Aadd( aHeader, { Trim(X3TITULO()),;
				             SX3->X3_CAMPO,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
							 SX3->X3_DECIMAL,;
							 SX3->X3_VALID,;
							 SX3->X3_USADO,;
							 SX3->X3_TIPO,;
							 SX3->X3_ARQUIVO,;
							 SX3->X3_CONTEXT } )
			nUsado++
		EndIf
		SX3->(dbSkip())
	EndDo 
		
	//Reabre SD1 com outro alias para manipular a nota original
	If !ChkFile( "SD1", .F., "SD1ORI" )
		lRet := .F.	
		Help( " ", 1, "A103GrvAtf", , STR0375, 1, 0 )	//"Erro ao criar área de trabalho temporária.
	EndIf

	//Localiza o documento de entrada original (Nota Fiscal ou Remito). 
	//O SD1 deve estar aberto e ter sido posicionado no registro do bem a incorporar,
	//antes da chamada da função.
	If lRet
        
    	//Verifica se rateio foi digitado manualmente, se não usa lMontaRat
    	//para forçar verificação de rateio do bem origianl
		If aScan( aRateio, { |x| AllTrim(x[1]) == Alltrim(SD1->D1_ITEM) } )	<= 0
	    	lMontaRat := .T.
		EndIf
		
		dbSelectArea("SD1ORI")	
		SD1ORI->( dbSetOrder(1) )	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If ( SD1ORI->( dbSeek( xFilial("SD1") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI ) ) )
		                           
			//Localiza o ativo gerado através do documento de entrada.
			dbSelectArea("SN1")
			SN1->( dbSetOrder(8) )	//N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM
			If ( SN1->( dbSeek( xFilial("SD1") + SD1ORI->D1_FORNECE + SD1ORI->D1_LOJA + SD1ORI->D1_ESPECIE +;
			                    SD1ORI->D1_DOC + SD1ORI->D1_SERIE + SD1ORI->D1_ITEM ) ) )
			                    
				dbSelectArea("SN3")
				SN3->( dbSetOrder(1) )	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
				
				//Atualiza todos os bens gerados pelo item do documento de entrada, independente
				//de código base, tratando TES configurada para desmembrar o item ou não.	   
				While SN1->(!Eof()) .And.;
					  SN1->N1_FORNEC  == SD1ORI->D1_FORNECE .And.;
					  SN1->N1_LOJA    == SD1ORI->D1_LOJA    .And.;
					  SN1->N1_NFESPEC == SD1ORI->D1_ESPECIE .And.;
					  SN1->N1_NFISCAL == SD1ORI->D1_DOC     .And.;
					  SN1->N1_NSERIE  == SD1ORI->D1_SERIE   .And.;
					  SN1->N1_NFITEM  == SD1ORI->D1_ITEM			        
					
					//Verifica se é o mesmo código base do loop anterior,
					//se for, não cria um novo item
					If cUltCBase == SN1->N1_CBASE
						cUltCBase := SN1->N1_CBASE
						SN1->(dbSkip())
						Loop
					EndIf
					
					A103QtItem( "SD1ORI", @nItens, .T. )
					
					If ( SN3->( dbSeek( xFilial("SN1") + SN1->N1_CBASE + SN1->N1_ITEM ) ) )
					
						//Preenchimento das Variáveis referentes ao SN1
						For nI := 1 To SN1->(FCount())
							M->&(SN1->(Field(nI))) := SN1->(FieldGet(nI))
						Next nI                          
						
						cUltItem :=  ATFXProxIt(cFilAnt,SN1->N1_CBASE)
						
						M->N1_ITEM		:= cUltItem
						M->N1_AQUISIC	:= SD1->D1_DTDIGIT
						M->N1_QUANTD	:= 1	//Quantidade fixa, apenas o valor é atualizado 
						M->N1_FORNEC	:= SD1->D1_FORNECE
						M->N1_LOJA		:= SD1->D1_LOJA
						M->N1_NSERIE	:= SD1->D1_SERIE
						M->N1_NFISCAL	:= SD1->D1_DOC
						M->N1_CHASSI	:= SD1->D1_CHASSI
						M->N1_PLACA		:= SD1->D1_PLACA
						If lN1Staus
							M->N1_STATUS := "1"
						EndIf  
						If lN1Especie
						    M->N1_NFESPEC := SD1->D1_ESPECIE
						EndIf                               
						If lN1NFItem
						    M->N1_NFITEM := SD1->D1_ITEM
						EndIf                               
						If lN1Prod
						    M->N1_PRODUTO := SD1->D1_COD
						EndIf
			  			
			  			nJ    := 1		  			
			  			aCols := {}
			  			IIf ( lMontaRat, aNewRat := {}, aNewRat )
			  					  
				    	//Varre todos os tipos do ativo para verificar se foram depreciados	  
						While SN3->(!Eof()) .And.; 
				      	  	  SN3->N3_CBASE + SN3->N3_ITEM == SN1->N1_CBASE + SN1->N1_ITEM     	  			      	  
				      	    
				      	    //Não inclui baixa no aCols
				      	    If SN3->N3_BAIXA == "0"
					      	  	//Inicializa aCols
								aAdd( aCols, Array( nUsado + 1 ) )
			
								//Monta aCols para gravação do item
								For nI := 1 to nUsado
									If AllTrim(aHeader[nI][2]) == "N3_ITEM"
										aCols[nJ][nI] := M->N1_ITEM
									ElseIf AllTrim(aHeader[nI][2]) == "N3_VORIG1"
										aCols[nJ][nI] := SD1->D1_TOTAL / nItens								
							   		ElseIf "N3_VRDACM" $ AllTrim(aHeader[nI][2])
								   		aCols[nJ][nI] := 0								
									Else
										aCols[nJ][nI] := &("SN3->" + AllTrim( aHeader[nI][2] ) )
									EndIf
								Next nI
								
								//Se item não possui dados de rateio preenchidos manualmente
								//verifica se item original possui para copiar rateio do bem original
								If lMontaRat								
									If SN3->N3_RATEIO == "1" .And. !Empty(SN3->N3_CODRAT)  
				       					AF010LoadR( aNewRat, SN3->N3_CODRAT, nJ )
				       					aNewRat[nJ,1] := ""
				       					aNewRat[nJ,2] := ""
				    				EndIf				        	    	
				        		EndIf
	    					
								aCols[nJ][nUsado + 1] := .F.
								nJ += 1
							EndIf
							
							SN3->(dbSkip())
						EndDo						 
	    						
	    				//Atualiza dados da depreciação
						If !lATFVdProp
							If FindFunction("A103CalcTx")
								A103CalcTx()
							EndIf
						EndIf				
						
						//Chamada a rotina de gravação do ativo
						//Inicializa as Variaveis Privates utilizadas pela funcao af010Grava
						lCopia			:= .F.
						lContabiliza	:= .F.
						lHeader			:= .F.
						lTrailler		:= .F.
						lCProva			:= .F.
						Inclui			:= .T.
				        Altera			:= .F.
				        
				        //Formata array de rateio caso tenha sido informado pelo 
				        //usuário manualmente para o item da nota
				        If !lMontaRat
				        	aNewRat := A103SetRateioBem( aRateio, SD1->D1_ITEM )
				        	aNewRat[1,3] := "3"
				        EndIf
				        
						DbSelectArea("SN1")
						Pergunte("AFA010", .F.)
						lGravou := Af010Grava( "SN1", "SN3", .F., .T., .F.,,,,,,, aNewRat )
				    
					EndIf	//If do seek no SN3
					cUltCBase := SN1->N1_CBASE
				    SN1->(dbSkip())
				EndDo	//While SN1                                                                                 		
			EndIf //If do seek no SN1
		Else
			lGravou := .T.
		EndIf	//If do seek no SD1ORI
		
		//Fecha area temporária
		dbSelectArea("SD1ORI")
		dbCloseArea()
	
	EndIf	//lRet
	
	//Restaura areas usadas
	RestArea(aAreaSN1)
	RestArea(aAreaSD1)

ElseIf nOpc == 102 .And.  lAjustaNCD .And. lStrutNCD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta os ajustes gerados pela nota de débito.                         ³ 	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(cChave) )
		dbSelectArea("SN1")
		SN1->(dbSetOrder(8))	//N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM
		
		If ( SN1->( dbSeek( cChave ) ) )
			
			While SN1->(!Eof()) .And.;
				  cChave == SN1->N1_FILIAL + SN1->N1_FORNEC + SN1->N1_LOJA + SN1->N1_NFESPEC + SN1->N1_NFISCAL + SN1->N1_NSERIE					  
				
				Af010DelAtu( "SN3", , , , @aCIAP )				
				SN1->(dbSkip())
			EndDo	
		EndIf
	EndIf
	
	RestArea(aAreaSN1)

ElseIf nOpc == 103 .And.  lAjustaNCD .And. lStrutNCD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta os ajustes gerados pela nota de crédito.                        ³ 	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Private cMoedaAtf := GetMV("MV_ATFMOEDA")
	Private cMoeda
	Private lPrimlPad := .T.
	Private nTotal    := 0
	Private nHdlPrv   := 0
	Private LUSAMNTAT := .F.
	Private lAuto	  := .T.

	dbSelectArea("SN3")
	SN3->(dbSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	dbSelectArea("SN4")
	SN4->(dbSetOrder(6))	//N4_FILIAL+N4_IDMOV+N4_OCORR
	
	If ( SN4->(dbSeek( xFilial("SF2") + cChave ) ) )	//cChave = ID do SN4 gravado no SD2 durante gravação do ajuste
		
		//Procura todas as baixas realizadas pela nota
		While lRet .And. SN4->N4_IDMOV == cChave
	
			If ( SN3->(dbSeek( xFilial("SN4") + SN4->N4_CBASE + SN4->N4_ITEM + "01" + "1" + SN4->N4_SEQ ) ) .Or.;
		     	 SN3->(dbSeek( xFilial("SN4") + SN4->N4_CBASE + SN4->N4_ITEM + "10" + "1" + SN4->N4_SEQ ) ) )
		        
		     	aTmpSN4 := SN4->(GetArea())
		     	
				If AllTrim(cRotBaixa) == "ATFA030"
					lRet := AF030Cance( "SN3", SN3->(Recno()),,, .T. )
				Else
					lRet := AF035Cance( "SN3", SN3->(Recno()),,, .T. )
				EndIf	
		        
				RestArea(aTmpSN4)
				
			EndIf
			SN4->(dbSkip())
		EndDo	
	EndIf         
	
	lGravou := lRet
	
	RestArea(aAreaSN3)
	RestArea(aAreaSN4)
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta a integracao com o ativo Fixo.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(cBase) )
		DbSelectArea("SN1")
		DbSetOrder(1)
		cBase := Alltrim(cBase)
	    cBase := PADR(Left(cBase,len(cBase)-len(SN1->N1_ITEM)),len(SN1->N1_CBASE))+Right(cBase,len(SN1->N1_ITEM))
		If ( MsSeek(xFilial("SN1")+cBase))
			//Incluido por Fernando Radu Muscalu em 28/04/2011
		    //Monta o Rateio de Despesas de Depreciacao da Ficha do ativo para todos os itens (do Doc. entrada) passado
		    //como conteudo do array aRateio que e proveniente de aRatCC, que foi adquirido na tela do documento de 
		    //entrada.
			aNewRat	:= A103SetRateioBem(aRateio)
			Af010DelAtu("SN3",,,,@aCIAP,aNewRat)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(lGravou)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³ A103CalcTx ºAutor  ³ Danilo Dias      º Data ³ 17/06/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição  ³ Recalcula a taxa de depreciação de acordo com o tempo de   º±±
±±º           ³ depreciação restante do bem original, para bens ajustados  º±±
±±º           ³ através de incorporação por nota de débito, fazendo com    º±±
±±º           ³ que o bem incorporado termine de depreciar junto com o     º±±
±±º           ³ bem original.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros ³ 												           º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso        ³ A103GRVATF                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103CalcTx()

Local dUltDepr   := GetMV("MV_ULTDEPR")	//Data do último cálculo de depreciação
Local nPTxDepr   := 0 
Local nPDtInDep  := 0	                                     
Local nPCritDep  := 0                         
Local cCritDepr  := ""	//Critério de depreciação do bem
Local nTxDepr    := 0	//Taxa de depreciação do bem 
Local dInicDepr  := StoD("//")	//Data inical de depreciação do bem
Local nTempoTot  := 0	//Vida útil do bem em meses
Local nTempoRest := 0	//Vida útil restante do bem em meses
Local nTempoDepr := 0	//Tempo já depreciado do bem em meses
Local nI         := 0
Local nMoedas    := IIf( FindFunction("AtfMoedas"), AtfMoedas(), 5 )
Local nY		 := 0
Local lCridepr	 := SN3->(FieldPos("N3_CRIDEPR")) > 0
                             
For nI:= 1 To Len(aCols)
    
	//Carrega dados do bem original
	For nY := 1 to nMoedas 
		nPTxDepr  := aScan( aHeader, { |x| AllTrim(x[2]) == IIf( nMoedas > 9,'N3_TXDEP','N3_TXDEPR') + cValToChar(nY) } )
		nTxDepr   := aCols[nI,nPTxDepr]		//Taxa de depreciação do bem original
		nPDtInDep := aScan( aHeader, { |x| Alltrim(x[2]) == "N3_DINDEPR" } )
		dInicDepr := aCols[nI,nPDtInDep]	//Data inicial de depreciação do bem original	
		If lCridepr
	 		nPCritDep := aScan( aHeader, { |x| AllTrim(x[2]) == "N3_CRIDEPR" } )
	 		cCritDepr := AllTrim(aCols[nI,nPCritDep])	//Critério de depreciação do bem original
	 	EndIf
		
		nTempoTot  := ( 100 / nTxDepr ) * 12   		//Tempo total de depreciação do bem em meses	
		nTempoDepr := ( dUltDepr - dInicDepr ) / 30 //Tempo total já depreciado em meses
		
		IIf( nTempoDepr < 0, nTempoDepr := 0, nTempoDepr := nTempoDepr )	
		
		nTempoRest := nTempoTot - ( Round( nTempoDepr,0 ) )	//Tempo restante a depreciar do bem em meses
		
		//Nova taxa de depreciação para a incorporação
		If nTempoRest > 0
			nTxDepr := ( 100 / nTempoRest ) * 12	
			aCols[nI,nPTxDepr] := nTxDepr
		EndIf	
    Next nY
	//Se for calendário completo, calcula acúmulo da depreciação
	If FindFunction( "AF010VLAEC" ) .And. cCritDepr = "03"
		AF010VLAEC( nI )
	EndIf	
	
Next nI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³ A103ExAjNC ºAutor  ³ Danilo Dias      º Data ³ 09/06/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição  ³ Exclui o ajuste realizado por notas de crédito ou débito,  º±±
±±º           ³ validando se o ajuste já foi depreciado, não permitindo a  º±±
±±º           ³ exclusão se sim.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros ³ cAlias  = Alias do cabeçalho da nota. (SF1 ou SF2)         º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso        ³ LOCXNF (LocxDelNF)                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103ExAjNC( cAlias )

Local aArea      := GetArea()			//Salva alias atual
Local aAreaSN1   := SN1->(GetArea())	//Salva alias SN1
Local aAreaSN3   := SN3->(GetArea())	//Salva alias SN3
Local aAreaSD2   := SD2->(GetArea())	//Salva alias SD2
Local lRet       := .T.	//Retorno
Local nI         := 0	//Uso Geral    
Local cNota      := ""	//Número da NF
Local cSerie     := "" 	//Série da NF
Local cEspecie   := ""	//Espécie da NF
Local cLoja      := ""	//Loja da NF
Local cFornece   := ""	//Fornecedor da NF 
Local nRecno     := 0   //Guarda recno para reposicionar ponteiro
Local cChave     := ""  //Dados a serem passado para a A103GRVATF para exclusão
Local aChave     := {}  //Para múltiplas chaves
Local dDtUltDepr := GetMV("MV_ULTDEPR")	//Data da última depreciação 

If cAlias == "SF1"	//Nota de débito				

	//Pega dados da nota
	cNota    := SF1->F1_DOC
	cSerie   := SF1->F1_SERIE
	cEspecie := SF1->F1_ESPECIE
	cLoja    := SF1->F1_LOJA
	cFornece := SF1->F1_FORNECE
	cChave   := xFilial("SF1") + cFornece + cLoja + cEspecie + cNota + cSerie
	
	dbSelectArea("SN1")
	SN1->(dbSetOrder(8))	//N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM
	dbSelectArea("SN3")
	SN3->(dbSetOrder(1))	//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	
	If ( SN1->(dbSeek( cChave ) ) )
	    
	    nRecno := SN1->(recno())
		
		//Varre todos os bens gerados pela nota
		While SN1->(!Eof()) .And.; 
			  cChave == SN1->N1_FILIAL + SN1->N1_FORNEC + SN1->N1_LOJA + SN1->N1_NFESPEC + SN1->N1_NFISCAL + SN1->N1_NSERIE
		  	
		  	If ( SN3->(dbSeek( xFilial("SN1") + SN1->N1_CBASE + SN1->N1_ITEM ) ) )
		  					  
			    //Varre todos os tipos do ativo para verificar se foram depreciados	  
				While SN3->(!Eof()) .And.; 
			      	  SN3->N3_CBASE + SN3->N3_ITEM == SN1->N1_CBASE + SN1->N1_ITEM		
						
					//Se houve depreciação, termina e retorna Falso
					If dDtUltDepr > SN3->N3_AQUISIC
						lRet := .F.
						Help( " ", 1, "A103GrvAtf", , STR0377, 1, 0 )	//"Não é possível excluir essa nota. Os ajustes do ativo fixo causados por ela já foram depreciados."
						Return lRet
					EndIf					
					SN3->(dbSkip())
				EndDo
			EndIf	//End If SN3
			SN1->(dbSkip())
		EndDo
		
		//Exclui os bens gerados pela nota de débito para fazer o ajuste no ativo fixo.
		A103GrvAtf( 102, , , , , , , , cChave )
								
	EndIf	//End if SN1 
    
ElseIf cAlias == "SF2"	//Nota de crédito
	
	//Se bem foi depreciado após baixa efetuada pela nota de crédito não permite exclusão
	If dDtUltDepr > SF2->F2_EMISSAO
		lRet := .F.
		Help( " ", 1, "A103GrvAtf", , STR0377, 1, 0 )	//"Não é possível excluir essa nota. Os ajustes do ativo fixo causados por ela já foram depreciados."
		Return lRet
	EndIf
	
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
	
	cChave := xFilial("SF2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
	
	//Varre todos os itens da Nota e exclui os ajustes				    
	If ( SD2->( dbSeek( cChave ) ) ) 
		While SD2->(!Eof()) .And.;
		      cChave == xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA
		
			aAdd( aChave, AllTrim(SD2->D2_CBASEAF) )
			SD2->(dbSkip())
		EndDo
		
		//Exclui os bens gerados pela nota de débito para fazer o ajuste no ativo fixo.
		For nI := 1 To Len(aChave)
			lRet := A103GrvAtf( 103,,,,,,,, aChave[nI] )
		Next nI  
	EndIf
EndIf

RestArea(aAreaSN1)	//Restaura alias SN1
RestArea(aAreaSN3)	//Restaura alias SN3
RestArea(aAreaSD2)	//Restaura alias SD2
RestArea(aArea)		//Restaura último alias ativo

Return lRet
			
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³ A103VlNCD ºAutor  ³ Danilo Dias       º Data ³ 09/06/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição  ³ Valida se o item foi classificado, permitindo a integração º±±
±±º           ³ do ativo fixo com o compras, para notas de Crédito ou de   º±±
±±º           ³ débito e se o usuário informou dados da NF original, caso  º±±
±±º           ³ a TES esteja configurada para atualizar ativo.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros ³ cAlias  = Alias da nota fiscal de crédito/débito (SD1/SD2) º±±
±±º           ³ aHeader = Cabeçalho da nota.                               º±±
±±º           ³ aCols   = Itens da nota.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso        ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103VlNCD( cAlias, aHeader, aCols )

Local aArea     := GetArea()
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSN1  := SN1->(GetArea())
Local aAreaSF4  := SF4->(GetArea())
Local nPosTES   := aScan( aHeader, { |x| AllTrim(x) == "D1_TES"})
Local nPosNFOri := aScan( aHeader, { |x| AllTrim(x) == "D1_NFORI"})
Local nPosSeOri := aScan( aHeader, { |x| AllTrim(x) == "D1_SERIORI"})
Local nPosItOri := aScan( aHeader, { |x| AllTrim(x) == "D1_ITEMORI"})
Local lRet      := .T. 
Local nItem     := 0
Local nPos      := 0

//Dados da nota
Local cFornece  := ""
Local cLoja	    := ""
Local cNF	    := ""
Local cSerie    := ""
Local cItem	    := ""
Local cProd	    := ""

Default cAlias  := ""
Default aHeader := {}
Default aCols   := {}

//Valida parâmetros recebidos
If ValType(aCols) == "A" .And. ValType(aHeader) == "A" .And. ( cAlias == "SD1" .Or. cAlias == "SD2" )
    
	//Valida os itens no aCols
	For nItem := 1 To Len(aCols)
	    
	    //Valida se dados do documento de entrada original foram informados, caso o TES gere ativo.
	    If lRet .And. cAlias == "SD1"
			If nPosTES > 0			
				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))	//F4_FILIAL+F4_CODIGO
				If SF4->(dbSeek( xFilial("SD1") + aCols[nItem,nPosTES] ) )
					If SF4->F4_ATUATF == "S"
						If AllTrim(aCols[nItem,nPosNFOri]) == "" .Or.;
						   AllTrim(aCols[nItem,nPosSeOri]) == "" .Or.;
						   AllTrim(aCols[nItem,nPosItOri]) == ""
							lRet := .F.
							Help( " ", 1, "A103VLNCDA" )	//"Digite os dados do documento de entrada ou informe um TES que não gere Ativo Fixo!"
						EndIf
					EndIf
				EndIf
			EndIf	    
	    EndIf
	    
	    //Valida se os itens gerados pelo documento original foram classificados
		If lRet
		    //Pega dados do documento de entrada original
			nPos   := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_NFORI" } )
			cNF    := aCols[nItem][nPos]
			nPos   := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_SERIORI" } )
			cSerie := aCols[nItem][nPos]
			nPos   := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_ITEMORI" } )
			cItem  := aCols[nItem][nPos]
			nPos   := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_COD" } )
			cProd  := aCols[nItem][nPos]
			nPos   := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_LOJA" } )
			cLoja  := aCols[nItem][nPos]
			
			If cAlias == "SD1"
				nPos     := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_FORNECE" } )
				cFornece := aCols[nItem][nPos]
			Else
				nPos     := aScan( aHeader, { |nPos| AllTrim(nPos) == AllTrim( PrefixoCpo( cAlias ) ) + "_CLIENTE" } )
			 	cFornece := aCols[nItem][nPos]
			EndIf 
			
			//Encontra documento de entrada original
			dbSelectArea("SD1")	
			SD1->( dbSetOrder(1) )	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		   	If ( SD1->( dbSeek( xFilial(cAlias) + cNF + cSerie + cFornece + cLoja + cProd + cItem ) ) )
			
				//Localiza o ativo gerado através do documento de entrada.
				dbSelectArea("SN1")
				SN1->( dbSetOrder(8) )	//N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM
				If ( SN1->( dbSeek( xFilial("SD1") + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ESPECIE +;
				                    SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_ITEM ) ) )						   
					
					//Valida os ativos gerados pelo documento de entrada
					While SN1->(!Eof()) .And. lRet .And.;
						  SN1->N1_FORNEC  == SD1->D1_FORNECE .And.;
						  SN1->N1_LOJA    == SD1->D1_LOJA    .And.;
						  SN1->N1_NFESPEC == SD1->D1_ESPECIE .And.;
						  SN1->N1_NFISCAL == SD1->D1_DOC     .And.;
						  SN1->N1_NSERIE  == SD1->D1_SERIE   .And.;
						  SN1->N1_NFITEM  == SD1->D1_ITEM    
						
						//Se item não classificado termina validação 
						If SN1->N1_STATUS == "0"
							lRet := .F.
							Help( " ", 1, "A103VLNCDB" )	//"Existem bens não classificados no ativo para o documento de entrada original informado."
						EndIf
						If !lRet
							Loop
						EndIf
						
						SN1->(dbSkip())				  
					EndDo	//While SN1
				EndIf	//Seek SN1
		   	EndIf	//Seek SD1
		EndIf	//lRet
	Next nItem 

EndIf

//Restaura ambiente
RestArea(aAreaSD1)
RestArea(aAreaSN1)
RestArea(aAreaSF4)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103QtItem ºAutor  ³ Danilo Dias        º Data ³ 08/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conta quantos bens do ativo foram gerados pelo documento   º±±
±±º          ³ de entrada original da nota de crédito/débito e qual é o   º±±
±±º          ³ último item cadastrado para cada bem.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros ³ cAlias = Alias usado para o SD1 na rotina chamadora.      º±±
±±º           ³ nItens = Passado por ref., quantidade de itens gerados    º±±
±±º           ³          pela nota.                                       º±±
±±º           ³ cUltItem = Passado por ref., último item gerado para o    º±±
±±º           ³            código base.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºUso       ³ A103GRVATF                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103QtItem( cAlias, nQtdItens, lCBase )

Local aArea     := GetArea()
Local cQuery    := ""  
Local nRecno    := 0
Local cCBase    := "" 
Local cAliasQry := ""

Default nQtdItens := 0
Default lCBase    := .F.

cCBase := SN1->N1_CBASE

//Verifica tipo de conexão com banco.
#IFDEF TOP
	cQuery := "Select COUNT(*) QTDITENS From "
	If lCBase
		cQuery += "( Select N1_CBASE From "
	EndIf
	cQuery += RetSqlName("SN1")
 	cQuery += " Where N1_FILIAL  = '" + xFilial("SD1") + "'"
    cQuery += " And N1_FORNEC = '"    + (cAlias)->D1_FORNECE + "'"
    cQuery += " And N1_LOJA = '"      + (cAlias)->D1_LOJA + "'"
    cQuery += " And N1_NFISCAL = '"   + (cAlias)->D1_DOC + "'"
    cQuery += " And N1_NSERIE = '"    + (cAlias)->D1_SERIE + "'"
    cQuery += " And N1_NFESPEC = '"   + (cAlias)->D1_ESPECIE + "'"
    cQuery += " And N1_NFITEM = '"    + (cAlias)->D1_ITEM + "'"
    cQuery += " And D_E_L_E_T_ <> '*'"
	If lCBase
		cQuery += " Group By N1_CBASE ) A"
	EndIf
	    
    cQuery	  := ChangeQuery(cQuery)
    cAliasQry := CriaTrab(Nil,.F.)
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .T., .T. )
	DbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	nQtdItens := (cAliasQry)->qtdItens	//Quantidade de bens gerados pela nota.
	dbCloseArea()
	
#ELSE
	nRecno := SN1->(Recno())
	While SN1->(!Eof()) .And.;
		  SN1->N1_FORNEC  == (cAlias)->D1_FORNECE .And.;
	      SN1->N1_LOJA    == (cAlias)->D1_LOJA    .And.;
	      SN1->N1_NFESPEC == (cAlias)->D1_ESPECIE .And.;
	      SN1->N1_NFISCAL == (cAlias)->D1_DOC     .And.;
	      SN1->N1_NSERIE  == (cAlias)->D1_SERIE   .And.;
	      SN1->N1_NFITEM  == (cAlias)->D1_ITEM	  
	     
	     If SN1->(!Deleted()) 
	     	nQtdItens++
	     EndIf
	     SN1->(dbSkip()) 
	EndDo
	SN1->(MsGoTo(nRecno))
#ENDIF 

RestArea(aArea)
		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GrvPV ³ Autor ³ Edson Maricate        ³ Data ³ 19.01.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Gravacao dos Pedidos de Venda                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103GrvPV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a103GrvPV(nOpc,aPedPV,aRecSC5)

Local aArea     := { Alias() , IndexOrd() , Recno() }
Local aSavaCols := aClone(aCols)
Local aSavaHead := aClone(aHeader)

Local nMaxFor   := nCntFor := 0
Local nMaxFor1  := nCntFor1:= 0
Local nPos1     := 0
Local nUsado    := 0
Local nItSC6    := 0
Local nAcols    := 0
Local lContinua := .F.
Local lPedido   := .F.
Local nParcTp9  := SuperGetMV("MV_NUMPARC")
Local nSaveSX8  := GetSX8Len()
Local cCampo    := ""
Local bCampo    := {|x| FieldName(x) }
Local nCntFor1  := 0
Local nCntFor   := 0


If nOpc == 1
	PRIVATE aCols   := {}
	PRIVATE aHeader := {}
	nMaxFor := Len(aPedPV)
	If ( nMaxFor > 0 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader do SC6                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SX3")
		DbSetOrder(1)
		MsSeek("SC6",.T.)
		While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
			If (  ((X3Uso(SX3->X3_USADO) .And. ;
					!( Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And.;
					Trim(SX3->X3_CAMPO) <> "C6_QTDEMP"   .And.;
					Trim(SX3->X3_CAMPO) <> "C6_QTDENT")  .And.;
					cNivel >= SX3->X3_NIVEL) )
				Aadd(aHeader,{ Trim(X3TITULO()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_ARQUIVO,;
					SX3->X3_CONTEXT } )
			EndIf
			DbSelectArea("SX3")
			dbSkip()
		EndDo
		For nCntFor := 1 To nMaxFor
			lContinua := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Registros                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SD2")
			DbSetOrder(3)
			MsSeek(xFilial("SD2")+aPedPV[nCntFor,2]+aPedPV[nCntFor,1]+aPedPV[nCntFor,4],.F.)

			While (!Eof() .And. xFilial("SD2") == SD2->D2_FILIAL     .And.;
					aPedPV[nCntFor,2] == SD2->D2_DOC                  .And.;
					aPedPV[nCntFor,1] == SD2->D2_SERIE                .And.;
					aPedPv[nCntFor,4] == SD2->D2_CLIENTE+SD2->D2_LOJA .And.;
					!lContinua )
				If ( AllTrim(SD2->D2_ITEM) == AllTrim(aPedPv[nCntFor,3]) )
					lContinua := .T.
				Else
					DbSelectArea("SD2")
					dbSkip()
				EndIf
			EndDo
			If ( lContinua )
				DbSelectArea("SC5")
				DbSetOrder(1)
				MsSeek(xFilial("SC5")+SD2->D2_PEDIDO,.F.)
				If ( Found() )
					DbSelectArea("SC6")
					DbSetOrder(1)
					MsSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F.)
					If ( !lPedido )
						lPedido := .T.
						DbSelectArea("SC5")
						nMaxFor1 := FCount()
						For nCntFor1 := 1 To nMaxFor1
							M->&(EVAL(bCampo,nCntFor1)) := CriaVar(FieldName(nCntFor1),.T.)
						Next nCntFor1
						M->C5_TIPO    := SC5->C5_TIPO
						M->C5_CLIENTE := SC5->C5_CLIENTE
						M->C5_LOJAENT := SC5->C5_LOJAENT
						M->C5_LOJACLI := SC5->C5_LOJACLI
						M->C5_TIPOCLI := SC5->C5_TIPOCLI
						M->C5_CONDPAG := SC5->C5_CONDPAG
						M->C5_TABELA  := SC5->C5_TABELA
						M->C5_DESC1   := SC5->C5_DESC1
						M->C5_DESC2   := SC5->C5_DESC2
						M->C5_DESC3   := SC5->C5_DESC3
						M->C5_DESC4   := SC5->C5_DESC4
						For nCntFor1 :=  1 To nParcTp9
							cCampo := IIF(nCntFor1<=9,StrZero(nCntFor1,1),Chr(55+nCntFor1))
							cCampo := "C5_PARC"+cCampo
							nPos1 := SC5->(FieldPos(cCampo))
							M->&(cCampo) := SC5->(FieldGet(nPos1))
							cCampo := IIF(nCntFor1<=9,StrZero(nCntFor1,1),Chr(55+nCntFor1))
							cCampo := "C5_DATA"+cCampo
							nPos1 := SC5->(FieldPos(cCampo))
							M->&(cCampo) := SC5->(FieldGet(nPos1))
						Next nCntFor1
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preenche aCols                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nUsado := Len(aHeader)
					aadd(aCols,Array(nUsado+1))
					nAcols := Len(aCols)
					aCols[nAcols,nUsado+1] := .F.
					For nCntFor1 := 1 To nUsado
						Do Case
							Case ( AllTrim(aHeader[nCntFor1,2]) $ "C6_ITEM" )
								aCols[nAcols,nCntFor1] := StrZero(++nItSC6,Len(SC6->C6_ITEM))
							Case ( AllTrim(aHeader[nCntFor1,2]) $ "C6_QTDVEN" )
								aCols[naCols,nCntFor1] := aPedPv[nCntFor,5]
							Case ( AllTrim(aHeader[nCntFor1,10]) <> "V" )
								aCols[nAcols,nCntFor1] := SC6->(FieldGet(FieldPos(aHeader[nCntFor1,2])))
							Otherwise
								aCols[nAcols,nCntFor1] := CriaVar(aHeader[nCntFor1,2],.T.)
						EndCase
					Next nCntFor1
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aqui e'atualizado o numero de pedido gerado no sd1       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( lContinua )
				DbSelectArea("SD1")
				MsGoto(aPedPV[nCntFor,6])
				RecLock("SD1",.F.)
				SD1->D1_NUMPV  := M->C5_NUM
				SD1->D1_ITEMPV := StrZero(nItSC6,Len(SC6->C6_ITEM))
			EndIf
		Next nCntFor
		If ( lPedido )
			lGrade   := .F.
			cBloqc6  := ""
			PRIVATE lMTA410TE	:= (ExistTemplate("MTA410"))
			PRIVATE lMTA410		:= (ExistBlock("MTA410"))
			PRIVATE lMTA410I	:= (ExistBlock("MTA410I"))
			PRIVATE lM410ABN	:= (ExistBlock("M410ABN"))
			PRIVATE lMTA410E	:= (ExistBlock("MTA410E"))
			PRIVATE lA410EXC	:= (ExistBlock("A410EXC"))
			PRIVATE lM410LIOKT	:= (ExistTemplate("M410LIOK"))
			PRIVATE lM410LIOK	:= (ExistBlock("M410LIOK"))
			PRIVATE lMta410TTE	:= (ExistTemplate("MTA410T"))
			PRIVATE lMta410T	:= (ExistBlock("MTA410T"))
			PRIVATE l410DEL		:= (ExistBlock("M410DEL"))
			If Type("nAutoAdt") == "U"
				PRIVATE nAutoAdt:= 0
			EndIf
			a410Grava(.F.,.F.)
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSx8()
			EndDo
			MsgAlert(STR0065+M->C5_NUM) //"Gerada Ped.de Venda N.: "
		EndIf
	EndIf
	aCols   := aSavaCols
	aHeader := aSavaHead
	DbSelectArea(aArea[1])
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de estorno.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIf
DbSetOrder(aArea[2])
MsGoto(aArea[3])
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103VisuPC³ Autor ³ Edson Maricate       ³ Data ³16.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama a rotina de visualizacao dos Pedidos de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - Campo:D1_TOTAL                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103VisuPC(nRecSC7)

Local aArea			:= GetArea()
Local aAreaSC7		:= SC7->(GetArea())
Local nSavNF		:= MaFisSave()
Local cSavCadastro	:= cCadastro
Local cFilBak		:= cFilAnt
Local nBack       	:= n
PRIVATE nTipoPed	:= 1
PRIVATE cCadastro	:= OemToAnsi(STR0066) //"Consulta ao Pedido de Compra"
PRIVATE l120Auto	:= .F.
PRIVATE l123Auto	:= .F.
PRIVATE aBackSC7	:= {}  //Sera utilizada na visualizacao do pedido - MATA120
MaFisEnd()

DbSelectArea("SC7")
MsGoto(nRecSC7)

nTipoPed  := SC7->C7_TIPO   
cCadastro := iif(nTipoPed==1 ,OemToAnsi(STR0066),OemToAnsi(STR0406)) //"Consulta ao Pedido de Compra"
cFilAnt   := IIf(!Empty(SC7->C7_FILIAL),SC7->C7_FILIAL,cFilAnt)

If SC7->C7_TIPO <> 3
	A120Pedido(Alias(),RecNo(),2)
Else
    nTipoPed := 3  
	A123Pedido(Alias(),RecNo(),2)
EndIf

cFilant := cFilBak

n := nBack
cCadastro	:= cSavCadastro
MaFisRestore(nSavNF)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103NFORI³ Autor ³ Edson Maricate        ³ Data ³16.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a chamada da Tela de Consulta a NF original            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103NFORI()

Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local bSavKeyF5 := SetKey(VK_F5,Nil)
Local bSavKeyF6 := SetKey(VK_F6,Nil)
Local bSavKeyF7 := SetKey(VK_F7,Nil)
Local bSavKeyF8 := SetKey(VK_F8,Nil)
Local bSavKeyF9 := SetKey(VK_F9,Nil)
Local bSavKeyF10:= SetKey(VK_F10,Nil)
Local bSavKeyF11:= SetKey(VK_F11,Nil)
Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_COD'})
Local nPosLocal := aScan(aHeader,{|x| AllTrim(x[2])=='D1_LOCAL'})
Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_TES'})
Local nPLocal	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_LOCAL'})
Local nPosOP 	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_OP'})
Local nRecSD1   := 0
Local nRecSD2   := 0
Local lContinua := .T.
Local nTpCtlBN  := If(FindFunction("A410CtEmpBN"), A410CtEmpBN(), If(SD4->(FieldPos("D4_NUMPVBN")) > 0, 1, 0))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua

	DbSelectArea("SF4")
	DbSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[n][nPosTes])

	If MaFisFound("NF") .And. Empty(Readvar())
		Do Case
			Case cTipo $ "ND" .And. SF4->F4_PODER3=="N"
				If F4NFORI(,,"M->D1_NFORI",cA100For,cLoja,aCols[n][nPosCod],"A100",aCols[n][nPLocal],@nRecSD2) .And. nRecSD2<>0
					NfeNfs2Acols(nRecSD2,n)
				EndIf			
			Case cTipo$"CPI"
				If F4COMPL(,,,cA100For,cLoja,aCols[n][nPosCod],"A100",@nRecSD1,"M->D1_NFORI",cTipo) .And. nRecSD1<>0
					NfeNfe2ACols(nRecSD1,n)
				EndIf
			Case cTipo$"NB" .And. SF4->F4_PODER3=="D"
				If cPaisLoc=="BRA"
					If F4Poder3(aCols[n][nPosCod],aCols[n][nPosLocal],cTipo,"E",cA100For,cLoja,@nRecSD2,SF4->F4_ESTOQUE) .And. nRecSD2<>0
						NfeNfs2Acols(nRecSD2,n)
						If nPosOp > 0 .And. cTipo == "N" .And. (nTpCtlBN != 0)
                    	    If Empty(aCols[n][nPosOp])
								aCols[n][nPosOp] := A103OPBen(nil,nTpCtlBN)
	                        EndIf 
						EndIf
					EndIf
				Else
					If A440F4("SB6",aCols[n][nPosCod],aCols[n][nPosLocal],"B6_PRODUTO","E",cA100For,cLoja,.F.,.F.,@nRecSD2,IIF(cTipo=="N","F","C")) > 0
						NfeNfs2Acols(nRecSD2,n)
					EndIf
				EndIf		
			OtherWise
				If Empty(aCols[n][nPosCod]) .Or. Empty(aCols[n][nPosTes])
					Help('   ',1,'A103TPNFOR')
				ElseIf cTipo == "D" .And. SF4->F4_PODER3 <> "N"	
					Help('   ',1,'A103TESNFD')
				ElseIf cTipo$"B" .And. SF4->F4_PODER3 <> "D"	
					Help('   ',1,'A103TESNFB')
				EndIf
		EndCase
	Else
		Help('   ',1,'A103CAB')
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PNEUAC - Ponto de Entrada,gravar na coluna Lote o numero baseado na nf Original       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PNEU002")
		ExecBlock("PNEU002",.F.,.F.)
	EndIf
Endif

// Atualiza valores na tela
If Type( "oGetDados" ) == "O" 	
	oGetDados:oBrowse:Refresh()	
EndIf 	

SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)
// Atualiza valores na tela
Eval(bRefresh)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103LoteF4³ Autor ³ Edson Maricate       ³ Data ³16.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a chamada da Tela de Consulta a NF original            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103LoteF4()

Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local bSavKeyF5 := SetKey(VK_F5,Nil)
Local bSavKeyF6 := SetKey(VK_F6,Nil)
Local bSavKeyF7 := SetKey(VK_F7,Nil)
Local bSavKeyF8 := SetKey(VK_F8,Nil)
Local bSavKeyF9 := SetKey(VK_F9,Nil)
Local bSavKeyF10:= SetKey(VK_F10,Nil)
Local bSavKeyF11:= SetKey(VK_F11,Nil)
Local lContinua := .T.
Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD" })
Local nPosLocal := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOCAL" })

PRIVATE nPosLote   := aScan(aHeader,{|x|Alltrim(x[2])=="D1_NUMLOTE"})
PRIVATE nPosLotCTL := aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOTECTL"})
PRIVATE nPosDvalid := aScan(aHeader,{|x|Alltrim(x[2])=="D1_DTVALID"})
PRIVATE nPosPotenc := aScan(aHeader,{|x|Alltrim(x[2])=="D1_POTENCI"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua
	If MaFisFound('NF')
		If cTipo=="D"
			F4Lote(,,,"A103",aCols[n][nPosCod],aCols[n][nPosLocal])
		Else
			Help('  ',1,'A103TIPOD')
		EndIf
	Else
		Help('  ',1,'A103CAB')
	EndIf
Endif

SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FAtiva   ³ Autor ³ Edson Maricate        ³ Data ³ 18.10.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a pergunte do mata103                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FAtiva()
AjustaSX1()
Pergunte("MTA103",.T.)
If ExistBlock("MT103SX1")
	ExecBlock("MT103SX1",.F.,.F.)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103EstNCC³ Autor ³ Edson Maricate        ³ Data ³02.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Estorna os titulos de NCC gerados ao Cliente.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a103EstNCC()

Local cPref		:= PadR(&(SuperGetMV("MV_2DUPREF")), Len( SE1->E1_PREFIXO ) )
Local lTpComis	:= SuperGetMV("MV_TPCOMIS")=="O"

If cTipo == "D"
	DbSelectArea("SE1")
	DbSetOrder(2)
	MsSeek(xFilial("SE1")+cA100For+cLoja+cPref+cNFiscal)
	While !Eof() .And. xFilial("SE1")+cA100For+cLoja+cPref+cNFiscal ==;
			E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
		If If(cPaisLoc == "BRA",!(E1_TIPO $ MV_CRNEG),AllTrim(E1_TIPO) <> AllTrim(cEspecie))		
			DbSelectArea("SE1")
			dbSkip()
		Else
			DbSelectArea("SA1")
			DbSetOrder(1)
			If MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
				AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
				DbSelectArea("SE1")
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Refaz  os valores da Comissao.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTpComis
				Fa440DeleE("MATA100")
			EndIf
			RecLock("SE1",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndIf
	EndDo
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ToFC030 ³Autor³ Edson Maricate        ³ Data ³06.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Compatibilizacao de variaveis utilizadas no FINC030/FINC010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103TOFC030(cOper)
Local aArea			:= GetArea()
Local nposN			:= n
Local cSavCadastro	:= cCadastro
Local aSavaCols		:= aClone(aCols)
Local aSavaHeader	:= aClone(aHeader)
Local oBSomaItBKP
Local aoSbxBKP			
Local oLstFinBKP
Local oLstImpBKP
Local cDocBKP
Local cSerieBKP
Local dEmissBKP

cOper := IIf(cOper == Nil, "E",cOper)

If (cOper=="E".And.cTipo$'DB') .Or. (cOper=="S".And.!(cTipo$'DB'))
	DbSelectArea('SA1')
	If Pergunte("FIC010",.T.)
		Fc010Con('SA1',RecNo(),3)
	EndIf
	Pergunte("MTA103",.F.)
Else
	If Pergunte("FIC030",.T.)
		If cPaisLoc != "BRA"
			oBSomaItBKP	:= oBSomaItens
			aoSbxBKP 	:= aClone(aoSbx)
			oLstFinBKP	:= oLstFin
			oLstImpBKP  := oLstImp
			cDocBKP  	:= F1_DOC       //essas variaveis estão no get
			cSerieBKP   := F1_SERIE
			dEmissBKP	:= F1_EMISSAO
			MaFisSave()
			Finc030("Fc030Con")
			oBSomaItens	:= oBSomaItBKP
			aoSbx 		:= aClone(aoSbxBKP)
			oLstFin		:= oLstFinBKP
			oLstImp 	:= oLstImpBKP
			F1_DOC 		:= cDocBKP
			F1_SERIE 	:= cSerieBKP
			F1_EMISSAO 	:= dEmissBKP
			MaFisRestore()
		Else
			Finc030("Fc030Con")		
		EndIf
	EndIf
	Pergunte("MTA103",.F.)
EndIf

cCadastro	:= cSavCadastro
aCols		:= aClone(aSavaCols)
aHeader		:= aClone(aSavaHeader)
n			:= nposN
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103Histor³ Prog. ³Edson Maricate         ³Data  ³20.05.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria uma array contendo o Historic de Opercoes da NF.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Histor(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = 01.Registro da NF no SF1                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array contendo os Historicos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103Histor(nRecSF1)

Local aHistor	:= {}
Local aRet		:= {}
Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local cPrefixo	:= IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)

DbSelectArea('SF1')
MsGoto(nRecSF1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui no historico a data de Recebimento da Mercadoria      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SF1->F1_RECBMTO)
	aAdd(aHistor,{SF1->F1_RECBMTO,"A",STR0075}) //"  Recebimento do Documento de Entrada."
Else
	aAdd(aHistor,{SF1->F1_RECBMTO,"A",STR0076}) //"  Este Documento de Entrada foi incluido em versões anteriores do sistema."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui no historico a data de Classificacao da NF            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SF1->F1_STATUS)
	aAdd(aHistor,{SF1->F1_DTDIGIT,"B",STR0077}) //"  Classificacao do Documento de Entrada."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui no historico a data de Contabilizacao da NF           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SF1->F1_DTLANC)
	aAdd(aHistor,{SF1->F1_DTLANC,"C",STR0078}) //"  Contabilizacao do Documento de Entrada."
EndIf

DbSelectArea("SD1")
DbSetOrder(1)
MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
		xFilial("SD1")+cNFiscal+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui no historico a data de Contabilizacao da NF           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case cTipo == 'N'
		If SD1->D1_QTDEDEV <> 0
			DbSelectArea("SD2")
			DbSetOrder(8)
			MsSeek(xFilial("SD2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_DOC+SD1->D1_SERIE)
			While !Eof() .And. xFilial("SD2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_DOC+SD1->D1_SERIE==;
					SD2->D2_FILIAL+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_NFORI+SD2->D2_SERIORI
				If aScan(aHistor,{|x| x[3]==STR0079+SD2->D2_DOC+"/"+SD2->D2_SERIE}) == 0 //"  Devolucao efetuada : "
					aAdd(aHistor,{SD2->D2_EMISSAO,"D",STR0079+SD2->D2_DOC+"/"+SD2->D2_SERIE}) //"  Devolucao efetuada : "
				EndIf
				dbSkip()
			End
		EndIf
	EndCase
	DbSelectArea("SD1")
	dbSkip()
EndDo

aSort(aHistor,,,{|x,y| x[2]+DTOC(x[1]) < y[2]+DTOC(y[1])})
aEval(aHistor,{|x| aAdd(aRet,DTOC(x[1])+x[3]) })

RestArea(aAreaSF1)
RestArea(aARea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103Rodape³ Prog. ³Edson Maricate         ³Data  ³20.05.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria o Rodape compativel para NF incluidas pelo MATA100     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Rodape(ExpO1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Janela principal                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103, Compatibilizacao com Notas do MATA100             ³±±
±±³          ³          nas telas de visualizacao e exclusao.             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103Rodape(oFolderWnd)
Local nValMerc	:= SF1->F1_VALMERC
Local nFrete	:= SF1->F1_FRETE
Local nValDesp	:= SF1->F1_DESPESA
Local nDesconto	:= SF1->F1_DESCONT
Local nAcessori	:= SF1->F1_BASEFD
Local nBsIcms	:= SF1->F1_BASEICM
Local nIPI		:= SF1->F1_VALIPI
Local nIcms		:= SF1->F1_VALICM
Local nBsIcmRet	:= SF1->F1_BRICMS
Local nVIcmRet	:= SF1->F1_ICMSRET
Local nValFun	:= SF1->F1_CONTSOC

@ 5  ,5   SAY STR0080 Of oFolderWnd PIXEL SIZE 32 ,9 //'Mercadorias'
@ 4  ,45  MSGET nValMerc  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 5  ,105 SAY STR0081 Of oFolderWnd PIXEL SIZE 43 ,9 //'Frete'
@ 4  ,130 MSGET nFrete  PICTURE '@E 999,999,999.99' When .F.  OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 5  ,200 SAY STR0082 Of oFolderWnd PIXEL SIZE 35 ,9 //'Despesas'
@ 4  ,230 MSGET nValDesp  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 20 ,6   SAY STR0083 Of oFolderWnd PIXEL SIZE 27 ,9 //'Descontos'
@ 19 ,45  MSGET nDesconto  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 20 ,150 SAY STR0084 Of oFolderWnd PIXEL SIZE 95 ,9 //'Base das Despesas Acessorias'
@ 19 ,230 MSGET nAcessori  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 35 ,6   SAY STR0085 Of oFolderWnd PIXEL SIZE 39 ,9 //'Base de ICMS'
@ 34 ,45  MSGET nBsIcms  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 35 ,105 SAY STR0086 Of oFolderWnd PIXEL SIZE 25 ,9 //'IPI'
@ 34 ,130 MSGET nIpi  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

@ 35 ,205 SAY STR0087 Of oFolderWnd PIXEL SIZE 20 ,9 //'ICMS'
@ 34 ,230 MSGET nICMS  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

If nBsIcmRet+nVIcmRet > 0
	@ 50 ,6   SAY STR0088 Of oFolderWnd PIXEL SIZE 40 ,9 //'Bs. ICMS Ret.'
	@ 49 ,45  MSGET nBsIcmRet  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9

	@ 50 ,100 SAY STR0089 Of oFolderWnd PIXEL SIZE 24 ,9 //'ICMS Ret'
	@ 49 ,130 MSGET nVIcmRet  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9
EndIf

If nValFun > 0
	@ 50 ,194 SAY STR0090 Of oFolderWnd PIXEL SIZE 31 ,9 //'FunRural'
	@ 49 ,230 MSGET nValFun  PICTURE '@E 999,999,999.99' When .F. OF oFolderWnd PIXEL RIGHT SIZE 48 ,9
EndIf

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Legenda³ Autor ³ Edson Maricate       ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103Legenda()
Local aLegenda := {}
Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)

aAdd(aLegenda, {"ENABLE"    ,STR0091}) //"Docto. nao Classificado"
aAdd(aLegenda, {"BR_LARANJA",STR0147}) //"Docto. Bloqueado"
aAdd(aLegenda, {"BR_VIOLETA",STR0326}) //"Doc. C/Bloq. de Mov."
aAdd(aLegenda, {"DISABLE"   ,STR0092}) //"Docto. Normal"
If !lGspInUseM
	aAdd(aLegenda, {"BR_AZUL"   ,STR0093}) //"Docto. de Compl. IPI"
	aAdd(aLegenda, {"BR_MARROM" ,STR0094}) //"Docto. de Compl. ICMS"
	aAdd(aLegenda, {"BR_PINK"   ,STR0095}) //"Docto. de Compl. Preco/Frete/Desp. Imp."
	aAdd(aLegenda, {"BR_CINZA"  ,STR0096}) //"Docto. de Beneficiamento"
	aAdd(aLegenda, {"BR_AMARELO",STR0097}) //"Docto. de Devolucao" 
Endif	

If SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
	aAdd(aLegenda,{"BR_PRETO",STR0098}) //"Docto. em processo de conferencia"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novo STATUS da legenda    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("MT103LEG") )
	aLegeUsr := ExecBlock("MT103LEG",.F.,.F.,{aLegenda})
	If ( ValType(aLegeUsr) == "A" )
		aLegenda := aClone(aLegeUsr)
	EndIf
EndIf
BrwLegenda(cCadastro,STR0008 ,aLegenda) //"Legenda"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A103Bar  ³ Prog. ³ Sergio Silveira       ³Data  ³23/02/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria a enchoicebar.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103Bar( ExpO1, ExpB1, ExpB2, ExpA1 )                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto dialog                                      ³±±
±±³          ³ ExpB1 = Code block de confirma                             ³±±
±±³          ³ ExpB2 = Code block de cancela                              ³±±
±±³          ³ ExpA1 = Array com botoes ja incluidos.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna o retorno da enchoicebar                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103Bar(oDlg,bOk,bCancel,aButtonsAtu, aInfo  )

Local aUsButtons := {}
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

If lPrjCni	
	aadd(aButtonsAtu,{"BUDGET",   {|| _MA103Div1()},"Cadastro de divergencias","Divergencias" })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistTemplate( "MA103BUT" )
	If ValType( aUsButtons := ExecTemplate( "MA103BUT", .F., .F.,{aInfo} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtonsAtu, x ) } )
	EndIf
EndIf
If ExistBlock( "MA103BUT" )
	If ValType( aUsButtons := ExecBlock( "MA103BUT", .F., .F.,{aInfo} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtonsAtu, x ) } )
	EndIf
EndIf

Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtonsAtu))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103EstDCF³ Prog. ³Fernando Joly Siquini  ³Data  ³06.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua o estorno dos registros do DCF (Servico WMS).        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103EstDCF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103EstDCF(lEstorna)
Local aAreaAnt   := GetArea()
Local cSeekDCF   := ''
Local lRet       := .T.

Default lEstorna := .F.

If !Empty(SD1->D1_SERVIC) .And. (SuperGetMV('MV_INTDL')=='S')
	DbSelectArea('DCF')
	DbSetOrder(2) //-- FILIAL+SERVIC+DOCTO+SERIE+CLIFOR+LOJA+CODPRO
	If MsSeek(cSeekDCF:=xFilial('DCF')+SD1->D1_SERVIC+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD, .F.)
		Do While !Eof() .And. cSeekDCF==DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO
			If DCF->DCF_NUMSEQ==SD1->D1_NUMSEQ
				If DCF_STSERV<>'1' .And. lEstorna
					DLA220Esto(.F.)
				EndIf
				If DCF_STSERV=='1'
					RecLock('DCF',.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			DCF->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaAnt)
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Devol³ Autor ³ Henry Fila             ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta de Historicos da Revisao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103Devol(cAlias,nReg,nOpcx)

Local oDlgEsp
Local oLbx
Local lCliente  := .F.
Local aRotina   := {{"&"+STR0005,"A103DevFec(cNomeCdx),A103ProcDv",0,4}} //"Retornar"
Local nOpca     := 0
Local aHSF2     := {}
Local aSF2      := {}
Local aCpoSF2   := {}
Local dDataDe   := CToD('  /  /  ')
Local dDataAte  := CToD('  /  /  ')
Local nCnt      := 0
Local nPosDoc   := 0
Local nPosSerie := 0
Local cDocSF2   := ''
Local cIndex    := ''
Local cQuery    := ''    
Local cCampos   := ''
Local lMT103CAM	:= Existblock("MT103CAM")
Local lFilCliFor:= .T.
Local lAllCliFor:= .T.
Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0 .And. GetNewPar("MV_FLAGDEV",.F.)
Local aSize		:= {}

Private cCliente := CriaVar("F2_CLIENTE",.F.)
Private cLoja    := CriaVar("F2_LOJA",.F.)    
Private cQrDvF2  := ""

SF2->(dbSetOrder(1))

If Inclui
	//-- Valida filtro de retorno de doctos fiscais.
	If A103FRet(@lCliente,@dDataDe,@dDataAte,@lFilCliFor,@lAllCliFor)
		If lCliente
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. Utilizado para adicionar novos campos na GetDados       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If lMT103CAM
		    	cCampos := ExecBlock("MT103CAM",.F.,.F.)
		    EndIf
			Aadd( aHSF2, ' ' )
			SX3->(DbSetOrder(1))
			SX3->(DbSeek("SF2"))
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SF2" 
			    If (SX3->X3_BROWSE == "S" .And. (AllTrim(SX3->X3_CAMPO) == 'F2_DOC' .Or. AllTrim(SX3->X3_CAMPO) == 'F2_SERIE')) .Or. (AllTrim(SX3->X3_CAMPO) $ cCampos)
					Aadd( aHSF2, X3Titulo() )
					Aadd( aCpoSF2, SX3->X3_CAMPO )
					//-- Armazena a posicao do documento e serie
					If AllTrim(SX3->X3_CAMPO) == 'F2_DOC'
						nPosDoc := Len(aHSF2)
					ElseIf AllTrim(SX3->X3_CAMPO) == 'F2_SERIE'
						nPosSerie := Len(aHSF2)
					EndIf
				EndIf

				SX3->(DbSkip())
			EndDo
			//-- Retorna as notas que atendem o filtro.
			aSF2 := A103RetNF(aCpoSF2,dDataDe,dDataAte,lFilCliFor,lAllCliFor)
			If !Empty(aSF2)
				aSize := {00,12,300,610}
				DEFINE MSDIALOG oDlgEsp TITLE STR0099 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL
				oLbx:= TWBrowse():New( aSize[1], (aSize[2]-12), aSize[3], (aSize[4]-470), NIL, ;
					aHSF2, NIL, oDlgEsp, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
				oLbx:SetArray( aSF2 )
				oLbx:bLDblClick  := { || { aSF2[oLbx:nAT,1] := !aSF2[oLbx:nAT,1] }}
				oLbx:bLine := &('{ || A103Line(oLbx:nAT,aSF2) }')
				ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca := 1, oDlgEsp:End()},{||oDlgEsp:End()}) CENTERED
				//-- Processa Devolucao				
				If nOpca == 1
					ASort( aSF2,,,{|x,y| x[1] > y[1] })
					For nCnt := 1 To Len(aSF2)
						If !aSF2[nCnt,1]
							Exit
						EndIf
						#IFDEF TOP
							cDocSF2 += IIF(Len(cDocSF2)>0,",","")+"'"+aSF2[nCnt,nPosDoc]+aSF2[nCnt,nPosSerie]+"'"
						#ELSE
							cDocSF2 += "( SD2->D2_DOC == '" + aSF2[nCnt,nPosDoc] + "' .And. SD2->D2_SERIE == '" + aSF2[nCnt,nPosSerie] + "' ) .Or. "
						#ENDIF
					Next nCnt
					If !Empty(cDocSF2)
						#IFDEF TOP
							cDocSF2 := "("+Subs(cDocSF2,1,Len(cDocSF2))+")"
						#ELSE
							cDocSF2 := SubStr(cDocSF2,1,Len(cDocSF2)-5) + " )"
						#ENDIF
					EndIf
					A103ProcDv(cAlias,nReg,nOpcx,lCliente,cCliente,cLoja,cDocSF2)
				EndIf			
			EndIf
		Else
			DbSelectArea("SF2")
			cIndex := CriaTrab(NIL,.F.)
			
   			If ExistBlock("MT103RET")//Ponto de entrada para complemento de filtro na query
       		   cQuery := ExecBlock("MT103RET",.F.,.F.,{dDataDe,dDataAte})
            Else  
		       cQuery := "F2_FILIAL == '" + xFilial("SF2") + "' "
		  	   cQuery += ".AND. F2_TIPO <> 'D' "
               
               If !lAllCliFor
				   If lFilCliFor 		
				  	   	cQuery += ".And. F2_TIPO <> 'B' "
	               Else
				  	   	cQuery += ".And. F2_TIPO <> 'N' "                  
	               EndIf
               EndIf

			   If !Empty(cCliente)
			      cQuery += " .And. F2_CLIENTE == '" + cCliente + "' "
			   EndIf
			   If !Empty(cLoja)
				  cQuery += " .And. F2_LOJA    == '" + cLoja    + "' "
			   EndIf
			   If !Empty(dDataDe)
				  cQuery += " .And. DtoS(F2_EMISSAO) >= '" + DtoS(dDataDe)  + "'"
			   EndIf
			   If !Empty(dDataAte)
				  cQuery += " .And. DtoS(F2_EMISSAO) <= '" + DtoS(dDataAte) + "' "
			   EndIf         
			   If lFlagDev                                                        
				   cQuery += " .And. F2_FLAGDEV <> '1' "
			   Endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para passar por parametro as informacoes na MaWndBrowse³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRotina[1,2] :=	 StrTran(aRotina[1,2],"cNomeCdx","'" + cIndex + "'")
   			cQrDvF2 := cQuery

			IndRegua("SF2",cIndex,SF2->(IndexKey()),,cQuery)
			If SF2->(!Eof())
				MaWndBrowse(0,0,300,600,STR0099,"SF2",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
			EndIf
			RetIndex( "SF2" )
			FErase( cIndex+OrdBagExt() )
		EndIf
	EndIf
EndIf

Inclui := !Inclui

Return .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta funcao tem a finalidade de excluir o indice temporario criado     ³
//³para o SF2. Esse indice e criado para filtrar as notas fiscais a serem ³
//³apresentadas pelo browse da funcao MaWndBrowse. Ocorre que o           ³
//³indice e excluido somente quando este browse e fechado e isso so       ³
//³acontece quando clica-se no botao "fechar". Com isso, todos os         ³
//³"dbsetorder" do SF2 usados nas funcoes subsequentes ocasionariam       ³
//³erro se o indice selecionado nao fosse o 1 (criado pelo indregua).     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function A103DevFec(cIndex)

Local nRecSF2 := SF2->(Recno())
RetIndex("SF2")
FErase(cIndex+OrdBagExt())

SF2->(MsGoto(nRecSF2))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103ProcDvºAutor  ³Henry Fila          º Data ³  06/29/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre a tela da nota fiscal de entrada de acordo com a nota º±±
±±º          ³ de saida escolhida no browse                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103ProcDv(cAlias,nReg,nOpcx,lCliente,cCliente,cLoja,cDocSF2)

Local aArea     := GetArea()
Local aAreaSF2  := SF2->(GetArea())
Local aCab      := {}
Local aLinha    := {}
Local aItens    := {}
Local cTipoNF   := ""
Local lDevolucao:= .T.
Local lPoder3   := .F.
Local aHlpP		:=	{}
Local aHlpE		:=	{}
Local aHlpS		:=	{} 
Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)
Local cIndex	:= ""  
Local lRestDev	:= .T.
Local nPFreteI  := 0
Local nPFreteC  := 0
Local nPSegurI  := 0
Local nPSegurC  := 0
Local nPDespI   := 0
Local nPDespC   := 0
Local nX        := 0 
Local cMvNFEAval :=	GetNewPar( "MV_NFEAFSD", "000" )
Local nHpP3     := 0

Default lCliente := .F.
Default cCliente := SF2->F2_CLIENTE
Default cLoja    := SF2->F2_LOJA
Default cDocSF2  := ''                                
Default	cQrDvF2  := ''

If Type("cTipo") == "U"
	PRIVATE cTipo:= ""
EndIf

If Empty(cQrDvF2)
	cQrDvF2 := "F2_FILIAL == '" + xFilial("SF2") + "' "
	cQrDvF2 += ".AND. F2_TIPO <> 'D' "
Endif

If !SF2->(Eof())

	lDevolucao := M103FilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,,@nHpP3)
	
	If lDevolucao .and. Len(aItens)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do Cabecalho da Nota fiscal de Devolucao/Retorno       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aCab, { "F1_DOC"    , CriaVar("F1_DOC",.F.)			, Nil } )	// Numero da NF : Obrigatorio
		AAdd( aCab, { "F1_SERIE"  , CriaVar("F1_SERIE",.F.)		, Nil } )	// Serie da NF  : Obrigatorio
		
		If !lPoder3
			AAdd( aCab, { "F1_TIPO"   , "D"                  		, Nil } )	// Tipo da NF   : Obrigatorio
		Else
			AAdd( aCab, { "F1_TIPO"   , IIF(cTipoNF=="B","N","B")	, Nil } )	// Tipo da NF   : Obrigatorio		
		EndIf
		
		AAdd( aCab, { "F1_FORNECE", cCliente    				, Nil } )	// Codigo do Fornecedor : Obrigatorio
		AAdd( aCab, { "F1_LOJA"   , cLoja    	   		   	    , Nil } )	// Loja do Fornecedor   : Obrigatorio
		AAdd( aCab, { "F1_EMISSAO", dDataBase           		, Nil } )	// Emissao da NF        : Obrigatorio
		AAdd( aCab, { "F1_FORMUL" , "S"                 		, Nil } )  // Formulario
		AAdd( aCab, { "F1_ESPECIE", If(Empty(CriaVar("F1_ESPECIE",.T.)),;
			PadR("NF",Len(SF1->F1_ESPECIE)),CriaVar("F1_ESPECIE",.T.)), Nil } )  // Especie
		AAdd( aCab, { "F1_FRETE",0,Nil})
		AAdd( aCab, { "F1_SEGURO",0,Nil})
		AAdd( aCab, { "F1_DESPESA",0,Nil})	
		
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Agrega o Frete/Desp/Seguro  referente a NF Retornada  ³
		//| de acordo com o parametro MV_NFEAFSD 				  ³
		//ÀÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
		nPFreteC := aScan(aCab,{|x| AllTrim(x[1])=="F1_FRETE"})
		nPFreteI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_VALFRE"})
   		nPSegurC := aScan(aCab,{|x| AllTrim(x[1])=="F1_SEGURO"})
		nPSegurI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_SEGURO"})
   		nPDespC := aScan(aCab,{|x| AllTrim(x[1])=="F1_DESPESA"})
		nPDespI := aScan(aItens[1],{|x| AllTrim(x[1])=="D1_DESPESA"})
		    
		For nX = 1 to Len(aItens)
		    If len(cMvNFEAval)>=1
		        If Substr(cMvNFEAval,1,1)=="1"
  		   			aCab[nPFreteC][2] := aCab[nPFreteC][2] + aItens[nX][nPFreteI][2]
  		  	    EndIf
  		  	EndIf
  		  	If len(cMvNFEAval)>=2
		        If Substr(cMvNFEAval,2,1)=="1"
  		    		aCab[nPSegurC][2] := aCab[nPSegurC][2] + aItens[nX][nPSegurI][2]
  		  	    EndIf
  		  	EndIf
   		  	If len(cMvNFEAval)=3
		        If Substr(cMvNFEAval,3,1)=="1"
  		    		aCab[nPDespC][2] := aCab[nPDespC][2] + aItens[nX][nPDespI][2]
  		  	    EndIf
  		  	EndIf
		Next nX
		
		Mata103( aCab, aItens , 3 , .T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se nao ha mais saldo para devolucao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFlagDev
			lRestDev := M103FilDv(@aLinha,@aItens,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)		
			If !lRestDev
				RecLock("SF2",.F.)
				SF2->F2_FLAGDEV := "1"
				MsUnLock()
			Endif         
		Endif
	Else
		aHlpP	:=	{}
		aHlpE	:=	{}
		aHlpS	:=	{}
		aAdd (aHlpP, STR0191)	//"Nota Fiscal de Devolução já gerada ou o"
		aAdd (aHlpP, STR0192)	//"saldo devedor em poder de terceiro está"
		aAdd (aHlpP, STR0193)	//"zerado."
		aAdd (aHlpE, STR0191)	//"Nota Fiscal de Devolução já gerada ou o"
		aAdd (aHlpE, STR0192)	//"saldo devedor em poder de terceiro está"
		aAdd (aHlpE, STR0193)	//"zerado."
		aAdd (aHlpS, STR0191)	//"Nota Fiscal de Devolução já gerada ou o"
		aAdd (aHlpS, STR0192)	//"saldo devedor em poder de terceiro está"
		aAdd (aHlpS, STR0193)	//"zerado."
		PutHelp ("PNFDGSPTZ", aHlpP, aHlpE, aHlpS, .F.)
		//
		aHlpP	:=	{}
		aHlpE	:=	{}
		aHlpS	:=	{}
		aAdd (aHlpP, STR0194)	//"É necessário excluir a NFcorrespondente"
		aAdd (aHlpP, STR0195)	//"para gerar a devolução novamente ou o"
		aAdd (aHlpP, STR0196)	//"saldo devedor em poder de terceiro está"
		aAdd (aHlpP, STR0197)	//"zerado para o item."
		aAdd (aHlpE, STR0194)	//"É necessário excluir a NFcorrespondente"
		aAdd (aHlpE, STR0195)	//"para gerar a devolução novamente ou o"
		aAdd (aHlpE, STR0196)	//"saldo devedor em poder de terceiro está"
		aAdd (aHlpE, STR0197)	//"zerado para o item."
		aAdd (aHlpS, STR0194)	//"É necessário excluir a NFcorrespondente"
		aAdd (aHlpS, STR0195)	//"para gerar a devolução novamente ou o"
		aAdd (aHlpS, STR0196)	//"saldo devedor em poder de terceiro está"
		aAdd (aHlpS, STR0197)	//"zerado para o item."
		PutHelp ("SNFDGSPTZ", aHlpP, aHlpE, aHlpS, .F.)
		
		/*
		nHpP3 = Situacao 0 -> Mostra a mensagem
		nHpP3 = Situacao 1 -> Nao mostra a mensagem
		*/
		If (nHpP3 == 0) .And. lPoder3
			Help(" ",1,"NFDGSPTZ")	//Nota Fiscal de Devolução já gerada ou o saldo devedor em poder de terceiro está zerado.
		EndIf
	EndIf
	
	MsUnLockAll()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Refaz o filtro quando a selecao e por documento, visto que a tela com os³
	//³documentos que podem ser devolvidos e montada novamente.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCliente
		DbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		cIndex := CriaTrab(NIL,.F.)
		IndRegua("SF2",cIndex,SF2->(IndexKey()),,cQrDvF2)
	Endif
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a entrada da rotina                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSF2)
RestArea(aArea)
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M103FilDv ºAutor  ³Mary C. Hergert     º Data ³19/03/2008   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica os itens que podem ser devolvidos do documento    º±±
±±º          ³ selecionado.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ ExpA1 = Linhas com os itens de devoluvao                   ³±±
±±³          ³ ExpA2 = Itens de devolucao                                 ³±±
±±³          ³ ExpC3 = Documentos do SF2 a serem processados              ³±±
±±³          ³ ExpC4 = Cliente do filtro                                  ³±±
±±³          ³ ExpC5 = Loja do cliente do filtro                          ³±±
±±³          ³ ExpL6 = Se a tela e por cliente/fornecedor                 ³±±
±±³          ³ ExpL7 = Tipo do documento - normal, devolucao, benefic.    ³±±
±±³          ³ ExpL8 = Se tem controle de terceiros no estoque            ³±±
±±³          ³ ExpL9 =                                                    ³±±
±±³          ³ ExpL10 = Ativa mensagem de poder de terceiros              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M103FilDv(aLinha,aItens,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3,lHelp,nHpP3)

Local cAliasSD2 := "SD2"
Local cAliasSF4 := "SF4"
Local nSldDev   := 0
Local nSldDevAux:= 0  
Local nDesc     := 0
Local nTotal	:= 0
Local lDevolucao:= .T.
Local lQuery    := .F.
Local lMt103FDV := ExistBlock("MT103FDV")
Local lDevCode	:= .F.
Local cCfop     := ""
Local cFilSX5   := xFilial("SX5")
Local cNFORI  	:= ""
Local cSERIORI	:= ""
Local cITEMORI	:= ""
Local cTesICMR  := "" 
Local nVlCompl  := 0
Local aAreaAnt  := {}
Local aSaldoTerc:= {}

Local lCompl    := (GetNewPar("MV_RTCOMPL","S") == "S")

Local nTpCtlBN  := If(FindFunction("A410CtEmpBN"), A410CtEmpBN(), If(SD4->(FieldPos("D4_NUMPVBN")) > 0, 1, 0))
Local aAreaAnt	:= GetArea()
Local cNewDSF2	:= ""
Local cDSF2Aux	:= ""
Local nPosDiv	:= 0
Local nX		:= 0
Local nY		:= 0
Local lTravou	:= .F.
Local lExit		:= .F.

#IFDEF TOP
	Local aStruSD2 := {}
	Local cQuery   := ""
	Local cAliasCpl := ""
#ELSE
	Local cIndex   := ""
	Local cIndexCpl:= ""
	Local aAreaSD2 := {}
#ENDIF

Default lHelp := .T.

If !Empty(cDocSF2)												// Selecao foi feita por "Cliente/Fornecedor"
	#IFDEF TOP
		cNewDSF2 := StrTran(StrTran(cDocSF2,"('",),"')",)		// Retira parêteses e aspas da string do documento, caso houver
	#ELSE
		cDSF2Aux := cDocSF2										// Para ambiente diferente de TOP equaliza string que contem as notas a devolver para continuar a validacao de reserva de registro
		For nY := 1 To Len(cDSF2Aux)
			nPosDiv := At("'",cDSF2Aux)
			If nPosDiv > 0
				cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
				nPosDiv := At("'",cDSF2Aux)
				cNewDSF2 += SubStr(cDSF2Aux,1,(nPosDiv-1))					// Numero
				cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
				nPosDiv := At("'",cDSF2Aux)
				cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
				nPosDiv := At("'",cDSF2Aux)
				cNewDSF2 += SubStr(cDSF2Aux,1,(nPosDiv-1))					// Serie
				cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+1),Len(cDSF2Aux))
				nPosDiv := At("'",cDSF2Aux)
				If nPosDiv > 0
					cNewDSF2 += "','"										// Separador entre notas
				Else
					Exit
				EndIf
			EndIf
		Next nY
	#ENDIF
	nPosDiv := At("','",cNewDSF2)								// String ',' identifica que foi selecionada mais de uma nota de saida
	If nPosDiv == 0												// Se foi selecionada apenas uma nota de saida
		DbSelectArea("SF2")
		DbSetOrder(1)
		If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
			lTravou := SoftLock("SF2")							// Tenta reservar o registro para prosseguir com o processo
		Else
			dbGoTop()
		EndIf
	Else														// Se foi selecionada mais de uma nota de saida 
		cDSF2Aux := cNewDSF2
		For nX := 1 to Len(cDSF2Aux)
			nPosDiv := At("','",cDSF2Aux)
			If nPosDiv > 0
				cNewDSF2 := SubStr(cDSF2Aux,1,(nPosDiv-1))		// Extrai a primeira nota/serie da string
				cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+3),Len(cDSF2Aux)) // Grava nova string sem a primeira nota/serie
			Else
				cNewDSF2 := cDSF2Aux
				lExit := .T.
			EndIf
			If !Empty(cNewDSF2)
				DbSelectArea("SF2")
				DbSetOrder(1)
				If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
					lTravou := SoftLock("SF2")					// Tenta reservar todos os registros para prosseguir com o processo
				Else
					dbGoTop()
				EndIf
			EndIf
			If lExit
				Exit
			EndIf
		Next nX
	EndIf
	RestArea(aAreaAnt)
Else
	lTravou := SoftLock("SF2")
EndIf

If lTravou
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem dos itens da Nota Fiscal de Devolucao/Retorno          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD2")
	DbSetOrder(3)
	#IFDEF TOP
		lQuery    := .T.
		cAliasSD2 := "Oms320Dev"
		cAliasSF4 := "Oms320Dev"
		aStruSD2  := SD2->(dbStruct())
		cQuery    := "SELECT SF4.F4_CODIGO, SF4.F4_CF, SF4.F4_PODER3, SD2.*, SD2.R_E_C_N_O_ SD2RECNO "
		cQuery    += " FROM "+RetSqlName("SD2")+" SD2,"
		cQuery    += RetSqlName("SF4")+" SF4 "
		cQuery    += " WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
		If !lCliente
			cQuery    += "SD2.D2_DOC   = '"+SF2->F2_DOC+"' AND "
			cQuery    += "SD2.D2_SERIE = '"+SF2->F2_SERIE+"' AND "   
		Else
			If !Empty(cDocSF2)     
				If UPPER(Alltrim(TCGetDb()))=="POSTGRES" 
					cQuery += " Concat(D2_DOC,D2_SERIE) IN "+cDocSF2+" AND "
				Else
					cQuery += " D2_DOC||D2_SERIE IN "+cDocSF2+" AND "
				EndIf
			EndIf
		EndIf
		cQuery    += " SD2.D2_CLIENTE   = '"+cCliente+"' AND "
		cQuery    += " SD2.D2_LOJA      = '"+cLoja+"' AND "
		cQuery    += " ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
		cQuery    += " (SD2.D2_VALDEV  = 0)) AND "		
		cQuery    += " SD2.D_E_L_E_T_  = ' ' AND "
		cQuery    += " SF4.F4_FILIAL   = '"+xFilial("SF4")+"' AND "
		cQuery    += " SF4.F4_CODIGO   = (SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
		cQuery    += " F4_FILIAL	   = '"+xFilial("SF4")+"' AND "
		cQuery    += " F4_CODIGO	   = SD2.D2_TES AND "
		cQuery    += " D_E_L_E_T_	   = ' ' ) AND "
		cQuery    += " SF4.D_E_L_E_T_  = ' ' "
		cQuery    += " ORDER BY "+SqlOrder(SD2->(IndexKey()))	

		cQuery    := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2]<>"C"
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX

		If Eof()    
			If lHelp  
				Help(" ",1,"DSNOTESDT")
				nHpP3 := 1
			Endif
			lDevolucao := .F.
		EndIf
	#ELSE
		If lCliente
			cIndex := CriaTrab(NIL,.F.)
			cQuery := " SD2->D2_FILIAL == '" + xFilial("SD2") + "' "
			cQuery += " .And. SD2->D2_CLIENTE == '" + cCliente + "' "
			cQuery += " .And. SD2->D2_LOJA    == '" + cLoja    + "' "
			If !Empty(cDocSF2)
				cQuery += " .And. ( "
				cQuery += cDocSF2
			EndIf
			IndRegua("SD2",cIndex,SD2->(IndexKey()),,cQuery)
			nIndex := RetIndex("SD2")
			dbSetIndex(cIndex+OrdBagExt())
			dbSetOrder(nIndex+1)
			SD2->(DbGotop())
		Else
			MsSeek( xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+cCliente+cLoja)
		EndIf
	#ENDIF
	While !Eof() .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
			(cAliasSD2)->D2_CLIENTE 		   == cCliente 		  .And.;
			(cAliasSD2)->D2_LOJA			   == cLoja 		  .And.;
			If(!lCliente,(cAliasSD2)->D2_DOC  == SF2->F2_DOC     .And.;
			(cAliasSD2)->D2_SERIE			   == SF2->F2_SERIE,.T.)

		If ((cAliasSD2)->D2_QTDEDEV < (cAliasSD2)->D2_QUANT) .Or. ((cAliasSD2)->D2_VALDEV == 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe um tes de devolucao correspondente           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lQuery
				DbSelectArea("SF4")
				DbSetOrder(1)
				If MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
					If Empty(SF4->F4_TESDV) .Or. !(SF4->(MsSeek(xFilial("SF4")+SF4->F4_TESDV)))
						lDevolucao := .F.
						Exit
					EndIf
					If SF4->F4_PODER3=="D"
						lPoder3 := .T.
					EndIf
					If lPoder3 .And. !cTipo$"B|N"
						cTipo := IIF(cTipoNF=="B","N","B")
					ElseIf !cTipo$"B|N"
						cTipo := "D"
					EndIf
				EndIf
			Else
				If (cAliasSD2)->F4_PODER3=="D"
					lPoder3 := .T.
				EndIf
				If lPoder3 .And. !cTipo$"B|N"
					cTipo := IIF(cTipoNF=="B","N","B")
				ElseIf !cTipo$"B|N"
					cTipo := "D"
				EndIf				
			EndIf
			If !lMt103FDV .Or. ExecBlock("MT103FDV",.F.,.F.,{cAliasSD2})
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Destroi o Array, o mesmo é carregado novamente pela CalcTerc    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If Len(aSaldoTerc)>0 
					aSize(aSaldoTerc,0)
				EndIf 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o Saldo a devolver                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				cTipoNF := (cAliasSD2)->D2_TIPO
				
				Do Case
					Case (cAliasSF4)->F4_PODER3=="D"
						aSaldoTerc := CalcTerc((cAliasSD2)->D2_COD,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_IDENTB6,(cAliasSD2)->D2_TES,cTipoNF)
						nSldDev :=iif(Len(aSaldoTerc)>0,aSaldoTerc[1],0)
					Case cTipoNF == "N"
						nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
					OtherWise
						nSldDev := 0
				EndCase

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetua a montagem da Linha                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nSldDev > 0 .Or. (cTipoNF$"CIP" .And. (cAliasSD2)->D2_VALDEV == 0) .Or.;
				   ( (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_VALDEV == 0 .And. (cAliasSD2)->D2_TOTAL > 0 )

					lDevCode := .T.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se deve considerar o preco das notas de complemento    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCompl
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe nota de complemento de preco                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lQuery
							aAreaAnt  := GetArea()
							cAliasCpl := GetNextAlias()
							cQuery    := "SELECT SUM(SD2.D2_PRCVEN) AS D2_PRCVEN "
							cQuery    += "  FROM "+RetSqlName("SD2")+" SD2 "
							cQuery    += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
							cQuery    += "   AND SD2.D2_TIPO    = 'C' "
							cQuery    += "   AND SD2.D2_NFORI   = '"+SF2->F2_DOC+"'"
							cQuery    += "   AND SD2.D2_SERIORI = '"+SF2->F2_SERIE+"'"
							cQuery    += "   AND SD2.D2_ITEMORI = '"+(cAliasSD2)->D2_ITEM +"'"
							cQuery    += "   AND ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
							cQuery    += "       (SD2.D2_VALDEV = 0))"
							cQuery    += "   AND SD2.D2_TES         = '"+(cAliasSD2)->D2_TES+"'"
							cQuery    += "   AND SD2.D_E_L_E_T_     = ' ' "
					
							cQuery    := ChangeQuery(cQuery)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCpl,.T.,.T.)
	
							TcSetField(cAliasCpl,"D2_PRCVEN","N",TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])
	
							If !(cAliasCpl)->(Eof())
								nVlCompl := (cAliasCpl)->D2_PRCVEN
							Else
								nVlCompl := 0
							EndIf
	
							(cAliasCpl)->(dbCloseArea())
							RestArea(aAreaAnt)
						Else
							aAreaSD2 := SD2->(GetArea())
							SD2->(dbSetOrder(3))
							cIndexCpl := CriaTrab(NIL,.F.)
							cQuery := "       SD2->D2_FILIAL  == '" + xFilial("SD2") + "' "
							cQuery += " .And. SD2->D2_TIPO    == 'C' "
							cQuery += " .And. SD2->D2_NFORI   == '"+SF2->F2_DOC   +"' "
							cQuery += " .And. SD2->D2_SERIORI == '"+SF2->F2_SERIE +"' "
							cQuery += " .And. AllTrim(SD2->D2_ITEMORI) == '"+(cAliasSD2)->D2_ITEM +"' "
							cQuery += " .And. SD2->D2_TES     == '"+(cAliasSD2)->D2_TES+"' "
	
							IndRegua("SD2",cIndexCpl,SD2->(IndexKey()),,cQuery)
							SD2->(DbGotop())
							
							nVlCompl := 0
							While !SD2->(Eof())							
								nVlCompl += SD2->D2_PRCVEN
								SD2->(dbSkip())
							EndDo
							
						    nIndex := RetIndex("SD2")
							FErase( cIndexCpl+OrdBagExt() )
	
						    If lCliente
								dbSetIndex(cIndex+OrdBagExt())
								dbSetOrder(nIndex+1)
                            EndIf
	
							RestArea(aAreaSD2)
						EndIf
					EndIf
		
					aLinha := {}				
					nDesc  := 0
	  				AAdd( aLinha, { "D1_COD"    , (cAliasSD2)->D2_COD    , Nil } )
					AAdd( aLinha, { "D1_QUANT"  , nSldDev, Nil } )					
					If (cAliasSD2)->D2_QUANT==nSldDev
						If Len(aSaldoTerc)=0   // Nf sem Controle Poder Terceiros                      
							If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
							   	AAdd( aLinha, { "D1_VUNIT"  , (cAliasSD2)->D2_PRCVEN, Nil })
							Else 
							    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
								AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+nDesc)/(cAliasSD2)->D2_QUANT, Nil })
							EndIf
						Else                   // Nf com Controle Poder Terceiros 
							If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
								AAdd( aLinha, { "D1_VUNIT"  , (aSaldoTerc[5]-aSaldoTerc[4])/nSldDev, Nil })
							Else
							    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
							    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
								AAdd( aLinha, { "D1_VUNIT"  , ((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev, Nil })
							EndIf
						EndIf
						nTotal:= A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL")
						If nTotal == 0 .And. (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_PRCVEN == (cAliasSD2)->D2_TOTAL
							nTotal:= (cAliasSD2)->D2_TOTAL
						EndIf
	 					AAdd( aLinha, { "D1_TOTAL"  , nTotal,Nil } )						
						AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )						
						AAdd( aLinha, { "D1_VALFRE", (cAliasSD2)->D2_VALFRE, Nil } )  
						AAdd( aLinha, { "D1_SEGURO", (cAliasSD2)->D2_SEGURO, Nil } )  
						AAdd( aLinha, { "D1_DESPESA", (cAliasSD2)->D2_DESPESA, Nil } )
					Else
						nSldDevAux:= (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
						If Len(aSaldoTerc)=0	// Nf sem Controle Poder Terceiros  
						    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
						    nDesc:=iif(nDesc>0,(nDesc/(cAliasSD2)->D2_QUANT)*IIf(nSldDevAux==0,1,nSldDevAux),0)
						    AAdd( aLinha, { "D1_VUNIT"  ,((((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR))-(cAliasSD2)->D2_VALDEV)/IIf(nSldDevAux==0,1,nSldDevAux), Nil })
					    Else  					// Nf com Controle Poder Terceiros
						    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
						    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
							AAdd( aLinha, { "D1_VUNIT"  , ((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev, Nil })
					    EndIf
						
	 					AAdd( aLinha, { "D1_TOTAL"  , A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL"),Nil } )
						AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )						
						AAdd( aLinha, { "D1_VALFRE" , A410Arred(((cAliasSD2)->D2_VALFRE/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_VALFRE"),Nil } )						
						AAdd( aLinha, { "D1_SEGURO" , A410Arred(((cAliasSD2)->D2_SEGURO/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_SEGURO"),Nil } )						
						AAdd( aLinha, { "D1_DESPESA" , A410Arred(((cAliasSD2)->D2_DESPESA/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_DESPESA"),Nil } )						
					EndIf
					AAdd( aLinha, { "D1_IPI"    , (cAliasSD2)->D2_IPI    , Nil } )	
					AAdd( aLinha, { "D1_LOCAL"  , (cAliasSD2)->D2_LOCAL  , Nil } )
					AAdd( aLinha, { "D1_TES" 	, (cAliasSF4)->F4_CODIGO , Nil } )
					If ("000"$AllTrim((cAliasSF4)->F4_CF) .Or. "999"$AllTrim((cAliasSF4)->F4_CF))
						cCfop := AllTrim((cAliasSF4)->F4_CF)
					Else
                        cCfop := SubStr("123",At(SubStr((cAliasSD2)->D2_CF,1,1),"567"),1)+SubStr((cAliasSD2)->D2_CF,2)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe CFOP equivalente considerando a CFOP do documento de saida  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SX5->( dbSetOrder(1) )
						If !SX5->(MsSeek( cFilSX5 + "13" + cCfop ))
							cCfop := AllTrim((cAliasSF4)->F4_CF)
						EndIf
					EndIf
					AAdd( aLinha, { "D1_CF"		, cCfop, Nil } )
					AAdd( aLinha, { "D1_UM"     , (cAliasSD2)->D2_UM , Nil } )
                    If (nTpCtlBN != 0)
     					AAdd( aLinha, { "D1_OP" 	, A103OPBen(cAliasSD2, nTpCtlBN) , Nil } )
                    EndIf
					If Rastro((cAliasSD2)->D2_COD)
						AAdd( aLinha, { "D1_LOTECTL", (cAliasSD2)->D2_LOTECTL, ".T." } )
						If (cAliasSD2)->D2_ORIGLAN == "LO"
							If Rastro((cAliasSD2)->D2_COD,"L") .AND. !Empty((cAliasSD2)->D2_NUMLOTE)
								AAdd( aLinha, { "D1_NUMLOTE", Nil , ".T." } )							
							Else
								AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )													
							EndIf
						Else
							AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )						
						EndIf

						AAdd( aLinha, { "D1_DTVALID", (cAliasSD2)->D2_DTVALID, ".T." } )
						AAdd( aLinha, { "D1_POTENCI", (cAliasSD2)->D2_POTENCI, ".T." } )
						SB8->(dbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID
						If SB8->(FieldPos('B8_DFABRIC')) > 0 .And.;
						 	SB8->(MsSeek(xFilial("SB8")+(cAliasSD2)->D2_COD + (cAliasSD2)->D2_LOCAL + (cAliasSD2)->D2_LOTECTL + (cAliasSD2)->D2_NUMLOTE))  
								AAdd( aLinha, { "D1_DFABRIC", SB8->B8_DFABRIC, ".T." } )
						Endif
					EndIf
					cNFORI  := (cAliasSD2)->D2_DOC
					cSERIORI:= (cAliasSD2)->D2_SERIE
					cITEMORI:= (cAliasSD2)->D2_ITEM 
					If cTipo == "D"
						SF4->(dbSetOrder(1))
						If SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) .And. SF4->F4_PODER3$"D|R"
							If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "N"
								cNFORI  := ""
								cSERIORI:= ""
								cITEMORI:= ""
								Help(" ",1,"A100NOTES")
							EndIf
							If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "R"
								cNFORI  := ""
								cSERIORI:= ""
								cITEMORI:= ""
							    Help(" ",1,"A103TESNFD")
							EndIf
						EndIf
					EndIf
					AAdd( aLinha, { "D1_NFORI"  , cNFORI   			      , Nil } )
					AAdd( aLinha, { "D1_SERIORI", cSERIORI  		      , Nil } )
					AAdd( aLinha, { "D1_ITEMORI", cITEMORI   			  , Nil } )
					cTesICMR := GetAdvFVal("SF4","F4_CREDICM",xFilial("SF4") + (cAliasSF4)->F4_CODIGO,1,"")
					AAdd( aLinha, { "D1_ICMSRET", IIf(cTesICMR=="N",0,((cAliasSD2)->D2_ICMSRET / (cAliasSD2)->D2_QUANT )*nSldDev) , Nil })
					If (cAliasSF4)->F4_PODER3=="D"
						AAdd( aLinha, { "D1_IDENTB6", (cAliasSD2)->D2_NUMSEQ, Nil } )								
					Endif

					//Obtém o valor do Acrescimo Financeiro na Nota de Origem e faz o rateio //
					If (cAliasSD2)->D2_VALACRS >0                                
						AAdd( aLinha, { "D1_VALACRS", ((cAliasSD2)->D2_VALACRS / (cAliasSD2)->D2_QUANT )*nSldDev , Nil })
					Endif

					If ExistBlock("MT103LDV")
						aLinha := ExecBlock("MT103LDV",.F.,.F.,{aLinha,cAliasSD2})
					EndIf

					AAdd( aLinha, { "D1RECNO",    Iif(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RECNO()) ), Nil } )

					AAdd( aItens, aLinha)
				EndIf
			Endif	
		Else
			nHpP3 := 1 
		Endif
		DbSelectArea(cAliasSD2)
		dbSkip()
	EndDo
	If lQuery
		DbSelectArea(cAliasSD2)
		dbCloseArea()
	Else
		If lCliente
			RetIndex( "SD2" )
			FErase( cIndex+OrdBagExt() )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nenhum item foi processado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDevCode
		lDevolucao := .F.
	Endif
	DbSelectArea("SD2")

Endif               

Return lDevolucao

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103ShowOP³ Autor ³Alexandre Inacio Lemes³ Data ³ 19/07/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta OP em Aberto atraves da tecla F4                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103ShowOP()      				                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103ShowOp()

Local oDlg, nOAT
Local nHdl    := GetFocus()
Local nOpt1   := 0
Local aArray  := {}
Local cAlias  := Alias()
Local nOrder  := IndexOrd()
Local nRecno  := Recno()
Local cCampo  := ReadVar()
Local cPicture:= PesqPictQt("C2_QUANT",16)
Local nOrdSC2 := SC2->(IndexOrd())
Local cMascara:= SuperGetMV("MV_MASCGRD")
Local nTamRef := Val(Substr(cMascara,1,2))
Local nPosOp  := AScan(aHeader,{|x| AllTrim(x[2])=='D1_OP'})
Local nPosCod := aScan(aHeader,{|x| AllTrim(x[2])=='D1_COD'})
Local cProdRef:= IIf(MatGrdPrrf(aCols[n][nPosCod]),Alltrim(aCols[n][nPosCod]),aCols[n][nPosCod])
Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local bSavKeyF5 := SetKey(VK_F5,Nil)
Local bSavKeyF6 := SetKey(VK_F6,Nil)
Local bSavKeyF7 := SetKey(VK_F7,Nil)
Local bSavKeyF8 := SetKey(VK_F8,Nil)
Local bSavKeyF9 := SetKey(VK_F9,Nil)
Local bSavKeyF10:= SetKey(VK_F10,Nil)
Local bSavKeyF11:= SetKey(VK_F11,Nil)
Local lContinua	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto e' referencia (Grade)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MatGrdPrrf(aCols[n][nPosCod])
	nTamRef	 := Val(Substr(cMascara,1,2))
	cProdRef    := Alltrim(aCols[n][nPosCod])
Else
	nTamRef	 := Len(SC2->C2_PRODUTO)
	cProdRef    := aCols[n][nPosCod]
EndIf

If cCampo <> "M->D1_OP"
	SetKey(VK_F4,bSavKeyF4)
	SetKey(VK_F5,bSavKeyF5)
	SetKey(VK_F6,bSavKeyF6)
	SetKey(VK_F7,bSavKeyF7)
	SetKey(VK_F8,bSavKeyF8)
	SetKey(VK_F9,bSavKeyF9)
	SetKey(VK_F10,bSavKeyF10)
	SetKey(VK_F11,bSavKeyF11)	
	lContinua := .F.
EndIf

If lContinua
	DbSelectArea("SC2")
	DbSetOrder(2)
	If MsSeek(xFilial("SC2")+cProdRef)
		While !Eof() .And. C2_FILIAL+Substr(C2_PRODUTO,1, nTamRef) == xFilial("SC2")+cProdRef
			If Empty(C2_DATRF)
				AADD(aArray,{C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,DTOC(C2_DATPRI),DTOC(C2_DATPRF),Transform(aSC2Sld(),cPicture),C2_ITEMGRD})
			EndIf
			dbSkip()
		EndDo
	EndIf

	If !Empty(aArray)

		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0100) From 03,0 To 17,50 OF oMainWnd //"OPs em Aberto deste Produto"
		@ 0.5,  0 TO 7, 20.0 OF oDlg
		@ 1,.7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0101),OemToAnsi(STR0102),OemToAnsi(STR0103),OemToAnsi(STR0063),OemToAnsi(STR0104),OemToAnsi(STR0105),OemToAnsi(STR0106),OemToAnsi(STR0107)  SIZE 150,80 ON DBLCLICK (nOpt1 := 1,oDlg:End()) //"Numero"###"Item"###"Sequencia"###"Produto"###"Dt. Prev. Inicio"###"Dt. Prev. Fim"###"Saldo"###" It. Grade"
		oQual:SetArray(aArray)
		oQual:bLine := { || {aArray[oQual:nAT][1],aArray[oQual:nAT][2],aArray[oQual:nAT][3],aArray[oQual:nAT][4],aArray[oQual:nAT][5],aArray[oQual:nAT][6],aArray[oQual:nAT][7],aArray[oQual:nAT][8]}}
		DEFINE SBUTTON FROM 10  ,166  TYPE 1 ACTION (nOpt1 := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 22.5,166  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg VALID (nOAT := oQual:nAT, .T.)
		If nOpt1 == 1
			M->D1_OP :=aArray[nOAT][1]+aArray[nOAT][2]+aArray[nOAT][3]+aArray[nOAT][8]
			If nPosOp > 0
				aCols[n][nPosOp] := M->D1_OP
			EndIf
		EndIf
		SetFocus(nHdl)
	Else
		Help(" ",1,"A250NAOOP")
	EndIf
	DbSelectArea(cAlias)
	DbSetOrder(nOrder)
	MsGoto(nRecno)
	SC2->(DbSetOrder(nOrdSC2))
	CheckSx3("D1_OP")
	SetKey(VK_F4,bSavKeyF4)
	SetKey(VK_F5,bSavKeyF5)
	SetKey(VK_F6,bSavKeyF6)
	SetKey(VK_F7,bSavKeyF7)
	SetKey(VK_F8,bSavKeyF8)
	SetKey(VK_F9,bSavKeyF9)
	SetKey(VK_F10,bSavKeyF10)
	SetKey(VK_F11,bSavKeyF11)
EndIf	
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuSE2³ Autor ³ Edson Maricate        ³ Data ³11.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de integracao com o modulo financeiro                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Codigo de operacao                                    ³±±
±±³          ³       [1] Inclusao de Titulos                               ³±±
±±³          ³       [2] Exclusao de Titulos                               ³±±
±±³          ³ExpA2: Array com os recnos dos titulos financeiros. Utilizado³±±
±±³          ³       somente na exclusao                                   ³±±
±±³          ³ExpA3: AHeader dos titulos financeiros                       ³±±
±±³          ³ExpA4: ACols dos titulos financeiro                          ³±±
±±³          ³ExpA5: AHeader das multiplas naturezas                       ³±±
±±³          ³ExpA2: ACols das multiplas naturezas                         ³±±
±±³          ³ExpC6: Fornecedor dos ISS                                    ³±±
±±³          ³ExpC7: Loja do ISS                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±                       
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a integracao entre o   ³±±
±±³          ³documento de entrada e os titulos financeiros.               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A103AtuSE2(nOpcA,aRecSE2,aHeadSE2,aColsSE2,aHeadSEV,aColsSEV,cFornIss,cLojaIss,cDirf,cCodRet,cModRetPIS,nIndexSE2,aSEZ,dVencIss,cMdRtISS,nTaxa,lTxNeg,aRecGerSE2,cA2FRETISS,cB1FRETISS,aMultas,lRatLiq,lRatImp,aCodR,cRecIss)

Local aArea     := GetArea()
Local aAreaSA2  := SA2->(GetArea())
Local aAreaSE2  := {}
Local aAreaAt   := {}
Local aRetIrrf  := {}
Local aProp     := {}
Local aCtbRet   := {0,0,0}
Local cPrefixo  := SF1->F1_PREFIXO
Local cNatureza	:= MaFisRet(,"NF_NATUREZA")
Local cPrefOri  := ""
Local cNumOri   := ""
Local cParcOri  := ""
Local cTipoOri  := ""
Local cCfOri    := ""
Local cLojaOri  := ""

Local lMulta    := .F.

Local nPParcela := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_PARCELA"})
Local nPVencto  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"})
Local nPValor   := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VALOR"})
Local nPIRRF    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_IRRF"})
Local nPISS     := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_ISS"})
Local nPINSS    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_INSS"})
Local nPPIS     := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_PIS"})
Local nPCOFINS  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_COFINS"})
Local nPCSLL    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_CSLL"})
Local nPSEST    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_SEST"})
Local nPFETHAB  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_FETHAB"})
Local nPFABOV	:= aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_FABOV"}) 
Local nPFACS    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_FACS"}) 
Local nSEST		:= 0

Local nBaseDup  := 0
Local nVlCruz   := MaFisRet(,"NF_BASEDUP")
Local nLoop     := 0
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nRateio   := 0
Local nRateioSEZ:= 0
Local nMaxFor   := IIF(aColsSE2==Nil,0,Len(aColsSE2))
Local nRetOriPIS := 0
Local nRetOriCOF := 0
Local nRetOriCSLL:= 0
Local nValor    := 0
Local nValTot   := 0
Local nBasePis  := MaFisRet(,"NF_BASEPIS")
Local nBaseCof  := MaFisRet(,"NF_BASECOF")
Local nBaseCsl  := MaFisRet(,"NF_BASECSL")
Local nBaseIrf  := MaFisRet(,"NF_BASEIRR")
Local nBaseIns	:= MaFisRet(,"NF_BASEINS")
Local nSaldoIrf := nBaseIrf
Local nSaldoPis := nBasePis
Local nSaldoCof := nBaseCof
Local nSaldoCsl := nBaseCsl
Local nSaldoIns := nBaseIns
Local nSaldoProp:= 0
Local nProp     := 0
Local nVlRetPIS := 0
Local nVlRetCOF := 0
Local nVlRetCSLL:= 0
Local nSaldoMult:= 0
Local nSaldoBoni:= 0
Local nBaixaMult:= 0
Local nTamEzPer := TamSX3("EZ_PERC")[2]
Local lVisDirf  := SuperGetMv("MV_VISDIRF",.F.,"2") == "1"
Local nValMinRet:= GetNewPar( "MV_VL10925", 0 )
Local aAutoISS		:=  &(GetNewPar("MV_AUTOISS",'{"","","",""}'))
Local lAutoISS		:= .F.	
Local lImpostos		:= .F.
Local lRestValImp	:= .F. 				
Local lRetParc		:= .T.				
Local cAplVlMn		:= "1"
// Modo de retencao do ISS: 1 = Pela Emissao, 2 = Pela Baixa
Local cMRetISS		:= GetNewPar("MV_MRETISS","1")
Local nValFet   	:= MaFisRet(,"NF_VALFET")
Local nValFab   	:= MaFisRet(,"NF_VALFAB")  
Local nValFac   	:= MaFisRet(,"NF_VALFAC")   
Local cForMinISS 	:= GetNewPar("MV_FMINISS","1")
Local lMT103ISS := ExistBlock("MT103ISS")
Local aMT103ISS:= {}
Local nInss := 0
Local aDadosImp	:= Array(3)
Local nVlRetIR 		:= SuperGetMV("MV_VLRETIR")
Local lPCCBaixa		:= SuperGetMv("MV_BX10925") == "1"
Local lISSNat		:= .T.
Local lRatPIS	:= SuperGetMV("MV_RATPIS",.F.,.T.) 
Local lRatCOFINS:= SuperGetMV("MV_RATCOF",.F.,.T.) 
Local lRatCSLL	:= SuperGetMV("MV_RATCSLL",.F.,.T.)

//Verifica se a retencao de IRRF sera na baixa do titulo.
Local lIRPFBaixa := IIf(	!Empty( SA2->( FieldPos( "A2_CALCIRF" ) ) ), SA2->A2_CALCIRF == "2", .F.) .And. ;
									!Empty( SE2->( FieldPos( "E2_VRETIRF" ) ) ) .And. ;
									!Empty( SE2->( FieldPos( "E2_PRETIRF" ) ) ) .And. ;
									!Empty( SE5->( FieldPos( "E5_VRETIRF" ) ) ) .And. ;
									!Empty( SE5->( FieldPos( "E5_PRETIRF" ) ) ) 

Local lBaseIRPF	:= (	!Empty(SE2->(FieldPos( "E2_BASEIRF" ) ) ) .and.;
								!Empty(SE5->(FieldPos( "E5_BASEIRF" ) ) ) .and.;
								!Empty(SED->(FieldPos( "ED_BASEIRF" ) ) ) )

//Verifica se existe controle de retencao de contrato - SIGAGCT
Local lGCTRet     := (GetNewPar( "MV_CNRETNF", "N" ) == "S") .And. (SE2->(FieldPos("E2_RETCNTR")) > 0)
Local nGCTRet     := 0
Local lGCTDesc    := (SE2->(FieldPos("E2_MDDESC")) > 0)
Local nGCTDesc    := 0
Local lGCTMult    := (SE2->(FieldPos("E2_MDMULT")) > 0)
Local nGCTMult    := 0
Local lGCTBoni    := (SE2->(FieldPos("E2_MDBONI")) > 0)
Local nGCTBoni    := 0
Local lGCTBloq    := (SE2->(FieldPos("E2_MSBLQL")) > 0)
Local aContra     := {}
Local nMinInss		:= SuperGetMv("MV_MININSS",.T.,0)
Local nValInss		:= 0
Local lISSTes		:= SuperGetMv("MV_ISSRETD",.F.,.F.)
Local lAtuSldNat := FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")
Local nValIrrf		:= 0     
Local lTCpsINSS := SE2->(FieldPos("E2_VRETINS")) > 0 .And. SE2->(FieldPos("E2_PRETINS")) > 0 .And. SFQ->(FieldPos("FQ_TPIMP")) > 0
Local aRatFin		:= {}
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local cMVInsAcpj    := GetNewPar("MV_INSACPJ","1")     
Local aDadosRet     := Array(8)
// Verifica os campos utilizados para o imposto CIDE
Local lCIDE			:=  SE2->(FieldPos('E2_CIDE')) > 0 .And. SE2->(FieldPos('E2_PARCCID')) > 0 .And.;
						SED->(FieldPos('ED_CALCCID')) > 0 .And. SED->(FieldPos('ED_BASECID')) > 0 .AND.;
						SED->(FieldPos('ED_PERCCID')) > 0 .AND. SA2->(FieldPos('A2_RECCIDE')) > 0
Local nValCIDE		:= MaFisRet(,"NF_VALCIDE")
Local lAcumINSS		:= SE2->(FieldPos("E2_VRETINS")) > 0 .And. SE2->(FieldPos("E2_PRETINS")) > 0
Local lContpre		:= SA2->(FieldPos("A2_CONTPRE")) > 0
Local lBaseIns		:= SE2->(FieldPos("E2_BASEINS")) > 0
Local lFethab		:= SE2->(FieldPos("E2_FETHAB")) > 0
Local lFabov		:= SE2->(FieldPos("E2_FABOV")) > 0
Local lFacs			:= SE2->(FieldPos("E2_FACS")) > 0
Local lCtRetNf		:= GetNewPar("MV_CTRETNF","1")=="2"
Local lMulNats		:= SuperGetMv( "MV_MULNATS", .F., .F. )
Local cAprov			:= If(SuperGetMV("MV_FINCTAL",.F.,"1") == "2",SuperGetMV("MV_FINALAP",.F.,""),"")
Local cForCIDE		:= PadR(SuperGetMV("MV_FORCIDE",.F.,""),Len( SE2->E2_FORNECE ))

DEFAULT cModRetPIS	:= "1"
DEFAULT cMdRtISS	:= "1"
DEFAULT nTaxa		:= 0
DEFAULT lTxNeg	    := .F.
DEFAULT cA2FRETISS	:=	""
DEFAULT cB1FRETISS	:=	""
DEFAULT aMultas     := {}
DEFAULT lRatLiq    := .T.
DEFAULT lRatImp    := .F.
DEFAULT aCodR      := {}
DEFAULT cRecIss	   :=	"1"         
DEFAULT aDadosRet := Array(8)

PRIVATE nValFun		:= MaFisRet(,"NF_FUNRURAL")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica se o tratamento de valor minimo para retencao (R$ 5.000,00) deve ser aplicado:³
//³Controle pela variavel cAplVlMn, onde :                                              ³
//³1 = Aplica o valor minimo                                                            ³
//³2 = Nao aplica o valor minimo                                                        ³
//³Quando o tratamento da retencao for pela emissao, sera forcada a retencao em cada    ³
//³aquisicao. Quando o tratamento da retencao for pela baixa, o financeiro ira usar o   ³
//³campo E2_APLVLMN para identificar se utilizara ou nao o valor minimo para retencao.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisRet(,"NF_PIS252") > 0 .Or. MaFisRet(,"NF_COF252") > 0
	If cModRetPis <> "3"
		// Forca a retencao sempre - Apenas para retencao na emissao do titulo
		cModRetPis := "2"
	Endif
	cAplVlMn := "2"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Taxa da Moeda nao foi negociada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If NMOEDACOR != 1 .And. RecMoeda(M->dDemissao,NMOEDACOR) != nTaxa //se a taxa for diferente da cadastrada na dDataBase a moeda foi negociada
	lTxNeg := .T.                         //para poder gravar e calcular corretamente os titulos financeiros
EndIf
If !lTxNeg
	nTaxa := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o prefixo do titulo a ser gerado                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPrefixo)
	cPrefixo := &(SuperGetMV("MV_2DUPREF"))
	cPrefixo += Space(Len(SE2->E2_PREFIXO) - Len(cPrefixo))
EndIf

If nOpcA == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o total de multas e / ou bonificacoes de contrato         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AEval( aMultas, { |x| If( x[5] == "1", nSaldoMult += x[3], nSaldoBoni += x[3] ) } )

	lMulta := ( nSaldoMult > nSaldoBoni )

	If lMulta
		nSaldoMult := nSaldoMult - nSaldoBoni
	Else 			
		nSaldoBoni := nSaldoBoni - nSaldoMult 			
	EndIf 		

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula valor da retencao,desconto e multa de contrato            ³
	//³ pelo total de parcelas                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If lGCTRet .Or. lGCTDesc .Or. lGCTMult .Or. lGCTBoni .Or. lGCTBloq
	   CntProcGct(lGCTRet,lGCTDesc,lGCTMult,lGCTBoni,@nGCTRet,@nGCTDesc,@nGCTMult,@nGCTBoni,aContra,@lGCTBloq)
	   nGCTRet  := nGCTRet/nMaxFor
	   nGCTDesc := nGCTDesc/nMaxFor
	   nGCTMult := nGCTMult/nMaxFor
	   nGCTBoni := nGCTBoni/nMaxFor
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona registros                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SED")
	DbSetOrder(1)
	MsSeek(xFilial("SED")+cNatureza)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a natureza indica que deva ser calculado/retido o ISS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lISSNAT := SED->ED_CALCISS <> "N" .Or. lISSTes
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o valor total das duplicatas                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 To nMaxFor
		nBaseDup += aColsSE2[nX][nPValor]
		If nPIRRF > 0 
			nValIrrf += aColsSE2[nX][nPIRRF]
		Else
			nValIrrf := 0
		EndIf
	Next nX
	nBaseDup -= nValFun
	nBaseDup -= nValFet	
	nBaseDup -= nValFab	
	nBaseDup -= nValFac
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula os percentuais de raeio do SEZ                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRateioSEZ := 0
	For nZ := 1 To Len(aSEZ)
		nRateioSEZ += aSEZ[nZ][5]
	Next nZ
	For nZ := 1 To Len(aSEZ)
		aSEZ[nZ][4] := NoRound(aSEZ[nZ][5]/nRateioSEZ,nTamEzPer)
	Next nZ
	nRateioSEZ := 0
	For nZ := 1 To Len(aSEZ)
		nRateioSEZ += aSEZ[nZ][4]
		If nZ == Len(aSEZ)
			aSEZ[nZ][4] += 1-nRateioSEZ
		EndIf
	Next nZ	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a gravacao dos titulos financeiros a pagar                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	nValPis := 0
	nValCof := 0
	nValCsl := 0

	For nX := 1 to nMaxFor
		nValTot += aColsSE2[nX][nPValor]
	Next

	aProp := {}

	nSaldoProp := 1

	For nX := 1 to nMaxFor
		If nX == nMaxFor
			nProp := nSaldoProp
		Else 			
			nProp := Round(aColsSE2[nX][nPValor] / nValTot,6)
			nSaldoProp -= nProp
		EndIf	
		AAdd( aProp, nProp )
	Next nX

	For nX := 1 To nMaxFor
	    If aColsSE2[nX][nPValor] > 0   
		  	RecLock("SE2",.T.) 
			If cForMinISS == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atendimento ao DECRETO 5.052, DE 08/01/2004 para o municipio de ARARAS. ³
				//³Mais especificamente o paragrafo unico do Art 2.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ("2"$cA2FRETISS) .And. ("2"$cB1FRETISS)
					SE2->E2_FRETISS	:=	"2"
				Else
					SE2->E2_FRETISS	:=	"1"
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atendimento a Lei 3.968 de 23/12/2003 - Americana / SP                                      ³
				//³para alguns produtos, a retencao deve ocorrer apenas para valores maiores que R$ 3.000,00   ³
				//³como um mesmo fornecedor pode prestar mais de um tipo de servico (com minimo e sem minimo   ³					
				//³de retencao, a configuracao e diferenciada. O default sera reter sempre.                    ³					
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ("1"$cA2FRETISS) .And. ("1"$cB1FRETISS)
					SE2->E2_FRETISS	:=	"1"
				Else
					SE2->E2_FRETISS	:=	"2"
				EndIf
			Endif

			SE2->E2_FILIAL  := xFilial("SE2")
			SE2->E2_PREFIXO := cPrefixo
			SE2->E2_NUM     := cNFiscal
			SE2->E2_TIPO    := MVNOTAFIS
			SE2->E2_NATUREZ := cNatureza
			SE2->E2_EMISSAO := dDEmissao
			SE2->E2_EMIS1   := SF1->F1_DTDIGIT
			SE2->E2_FORNECE := SA2->A2_COD
			SE2->E2_LOJA    := SA2->A2_LOJA
			SE2->E2_NOMFOR  := SA2->A2_NREDUZ
			SE2->E2_MOEDA   := nMoedaCor
			SE2->E2_TXMOEDA := nTaxa
			SE2->E2_LA      := "S"
			SE2->E2_PARCELA := aColsSE2[nX][nPParcela]
			SE2->E2_VENCORI := aColsSE2[nX][nPVencto]
			SE2->E2_VENCTO  := aColsSE2[nX][nPVencto]
			SE2->E2_VENCREA := DataValida(aColsSE2[nX][nPVencto],.T.)
			SE2->E2_NATUREZ := cNatureza
			SE2->E2_CODAPRO := cAprov
			
			//Gravacao de campos PLS
			If Type("lUsouLtPLS")<>"U" .And. lUsouLtPLS
				SE2->E2_CODRDA	:= cCodRDA
				SE2->E2_PLLOTE	:= cLotPLS
				SE2->E2_ANOBASE	:= Substr(cLotPLS,1,4)
				SE2->E2_MESBASE	:= Substr(cLotPLS,5,2)
				SE2->E2_PLOPELT	:= cOpeLt
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Modo de Retencao de ISS - Municipio de Sao Bernardo do Campo                         ³
			//³1 = Retencao Normal                                                                  ³
			//³2 = Retencao por Base                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE2->E2_MDRTISS := cMdRtISS

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Implementacao do SEST/SENAT                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPSEST > 0 
				nSEST := SE2->E2_SEST := aColsSE2[nX][nPSEST]
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Indica se o tratamento de valor minimo para retencao (R$ 5.000,00) deve ser aplicado:³
			//³1 = Aplica o valor minimo                                                            ³
			//³2 = Nao aplica o valor minimo                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE2->E2_APLVLMN := cAplVlMn

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava a filial de origem quando existir o campo no SE2            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE2->E2_FILORIG := Iif(Empty(CriaVar("E2_FILORIG",.T.)),cFilAnt,CriaVar("E2_FILORIG",.T.))

			lRetParc := .T. 							

			If aScan( aCodR, {|aX|aX[4]=="IRR"})>0
				cDirf	:=	AllTrim( Str( aCodR[aScan( aCodR, {|aX|aX[4]=="IRR"})][3] ) )
				cCodRet	:=	aCodR[aScan( aCodR, {|aX|aX[4]=="IRR"})][2]
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os impostos dos titulos financeiros                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				SE2->E2_IRRF    := aColsSE2[nX][nPIRRF]
				//Gravar base IRPF
				If lIrpfBaixa .and. lBaseIrpf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionalizacao da base do PIS pela duplicata                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nX == nMaxFor
						SE2->E2_BASEIRF := nSaldoIrf	
					Else
						SE2->E2_BASEIRF := nBaseIrf * aProp[nX]
						nSaldoIrf -= SE2->E2_BASEIRF					
					Endif	
				Endif

				If SE2->E2_IRRF >= nVlRetIR .OR. nValIrrf >= nVlRetIR
					RecLock("SF1",.F.)
				    SF1->F1_VALIRF := nValIrrf
					SF1->( MsUnlock() )
				Endif

				If SubStr( cRecIss,1,1 )<>"1" .And. lISSNAT
					SE2->E2_ISS     := aColsSE2[nX][nPISS]
					If cFornIss <> Nil .And. cLojaIss <> Nil .And. aColsSE2[nX][nPISS] > 0

						If lMT103ISS
							aMT103ISS	:=	ExecBlock( "MT103ISS" , .F. , .F. , { cFornIss , cLojaIss , cDirf , cCodRet , dVencIss })
							If Len( aMT103ISS )==5
								cFornIss	:=	aMT103ISS[1]
								cLojaIss	:=	aMT103ISS[2]
								cDirf		:=	aMT103ISS[3]
								cCodRet		:=	aMT103ISS[4]
								dVencIss	:=	aMT103ISS[5]
							EndIf
						EndIf

						SE2->E2_FORNISS := cFornIss
						SE2->E2_LOJAISS := cLojaIss

						If dVencIss <> Nil 							
							SE2->E2_VENCISS := dVencIss
						EndIf
					Endif	
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravacao dos codigos de receita conforme selecionado na aba impostos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aScan( aCodR, {|aX|aX[4]=="PIS"})>0
					SE2->E2_CODRPIS  := aCodR[aScan( aCodR, {|aX|aX[4]=="PIS"})][2]
				EndIf
				If aScan( aCodR, {|aX|aX[4]=="COF"})>0
					SE2->E2_CODRCOF  := aCodR[aScan( aCodR, {|aX|aX[4]=="COF"})][2]
				EndIf
				If aScan( aCodR, {|aX|aX[4]=="CSL"})>0
					SE2->E2_CODRCSL  := aCodR[aScan( aCodR, {|aX|aX[4]=="CSL"})][2]
				EndIf
				//-------------------------------------------------------------------------------------------------------------------------------
				//Tratamento para acumulo do INSS, conforme parametro MV_MININSS   															   
				//Caso o parametro MV_INSACPJ seja igual a '2' nao deve gerar o valor de INSS com acumulo dos titulos anteriores, gerar no campo
				//E2_INSS apenas o valor calculado na NF atual (Alinhado com equipe de Materiais)
				//-------------------------------------------------------------------------------------------------------------------------------
				If lAcumINSS
					SE2->E2_VRETINS := aColsSE2[nX][nPINSS]
					SE2->E2_PRETINS := "1"  
					// Salva a area atual da SE2 e depois restaura para garantir que voltará na SE2 após retornar da função VerInssCalc
					aAreaAt:= GetArea()    
					DbSelectArea("SE2")
					aAreaSE2:= GetArea()    
				  	If lTCpsINSS .And. cMVInsAcpj == "1"
					    nValInss := VerInssCalc(SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NREDUZ,SE2->E2_EMISSAO,SE2->E2_VENCREA,)	
					Else
						nValInss := 0
					EndIf
				    RestArea(aAreaSE2)
				    RestArea(aAreaAt)     
				    
					//Se o fornecedor for contribuinte previdênciário verifica se o valor do INSS atinge o valor mínimo
					If 	!Empty(nMinInss) .And. (nValInss + aColsSE2[nX][nPINSS])< nMinInss .And.;
					Iif(lContpre .And. SA2->A2_TIPO == "F",!(SA2->A2_CONTPRE == "2"),.T.)
						SE2->E2_INSS:= 0
					Else
						SE2->E2_INSS:= nValInss + aColsSE2[nX][nPINSS]
					EndIf
				Else
					SE2->E2_INSS:= aColsSE2[nX][nPINSS]
				EndIf                
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para calculo do IRRF                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("MT100IR"))
					aRetIrrf := ExecBlock( "MT100IR",.F.,.F., {SE2->E2_IRRF,aColsSE2[nX][nPValor],nX} )
					Do Case
						Case ValType(aRetIrrf)  == "N"
							SE2->E2_IRRF := aRetIrrf
							If SE2->E2_IRRF >= nVlRetIR
								RecLock("SF1",.F.)
								SF1->F1_VALIRF := SE2->E2_IRRF
								SF1->( MsUnlock() )
							Endif
						Case ValType(aRetIrrf)  == "A"
							SE2->E2_IRRF := aRetIrrf[1]
							SE2->E2_ISS  := Iif(lISSNat,aRetIrrf[2],0)
							If SE2->E2_IRRF >= nVlRetIR
								RecLock("SF1",.F.)
								SF1->F1_VALIRF := SE2->E2_IRRF
								SF1->( MsUnlock() )
							Endif
					EndCase
				EndIf
				If nPINSS > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para calculo do INSS                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE2->E2_INSS > 0
						If ExistBlock("MT100INS")
							SE2->E2_INSS := ExecBlock( "MT100INS",.F.,.F.,{SE2->E2_INSS})
						EndIf
					EndIf

					nInss := Iif( SED->ED_DEDINSS=="2",0,SE2->E2_INSS )  
					
					IF lBaseIns
						If nX == nMaxFor
							SE2->E2_BASEINS := nSaldoIns						
						Else
							SE2->E2_BASEINS := nBaseIns * aProp[nX]
							nSaldoIns -= SE2->E2_BASEINS					
						Endif
					EndIf
				EndIf
				If nPPIS > 0
					SE2->E2_PIS     := aColsSE2[nX][nPPIS]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para calculo do PIS                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("MT100PIS")
						SE2->E2_PIS := ExecBlock( "MT100PIS",.F.,.F.,{SE2->E2_PIS})
					EndIf					

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionalizacao da base do PIS pela duplicata                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nX == nMaxFor
						SE2->E2_BASEPIS := nSaldoPis						
					Else
						SE2->E2_BASEPIS := nBasePis * aProp[nX]
						nSaldoPis -= SE2->E2_BASEPIS					
					Endif	

				EndIf

				IF nPCOFINS > 0
					SE2->E2_COFINS  := aColsSE2[nX][nPCOFINS]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para calculo do COFINS                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("MT100COF")
						SE2->E2_COFINS := ExecBlock( "MT100COF",.F.,.F.,{SE2->E2_COFINS})
					EndIf										

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionalizacao da base do COFINS pela duplicata               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nX == nMaxFor
						SE2->E2_BASECOF := nSaldoCof
					Else
						SE2->E2_BASECOF := nBaseCof * aProp[nX]
						nSaldoCof -= SE2->E2_BASECOF
					Endif	
				EndIf

				If nPCSll > 0
					SE2->E2_CSLL    := aColsSE2[nX][nPCSLL]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para calculo do CSLL                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("MT100CSL")
						SE2->E2_CSLL := ExecBlock( "MT100CSL",.F.,.F.,{SE2->E2_CSLL})
					EndIf					

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Proporcionalizacao da base do CSLL pela duplicata                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nX == nMaxFor
						SE2->E2_BASECSL := nSaldoCsl
					Else
						SE2->E2_BASECSL := nBaseCsl * aProp[nX]
						nSaldoCsl -= SE2->E2_BASECSL
					Endif	

				EndIf

				If nPFETHAB > 0
					SE2->E2_FETHAB := aColsSE2[nX][nPFETHAB]
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para calculo do FETHAB                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("MT100FET")
						SE2->E2_FETHAB := ExecBlock( "MT100FET",.F.,.F.,{SE2->E2_FETHAB})
					EndIf					
				EndIf

				If nPFACS > 0
					SE2->E2_FACS := aColsSE2[nX][nPFACS]
				EndIf

				If nPFABOV > 0
					SE2->E2_FABOV := aColsSE2[nX][nPFABOV]
				EndIf
				
				If aAutoISS <> NIL .And. Len(aAutoISS) == 4 .And. !Empty(aAutoISS[3]) 
					lAutoISS := .T.
					If aColsSE2[nX][nPIRRF] > 0 .Or. aColsSE2[nX][nPISS] > 0 .Or. aColsSE2[nX][nPINSS] > 0 .Or. aColsSE2[nX][nPPIS] > 0;
					.Or. aColsSE2[nX][nPCOFINS] > 0 .Or. aColsSE2[nX][nPCSLL] > 0 .Or. aColsSE2[nX][nPSEST] > 0 .Or. aColsSE2[nX][nPFETHAB] > 0
						lImpostos := .T.
					EndIf
				EndIf
				
			   	If (lVisDirf .And. !lAutoISS) .Or. (lVisDirf .And. lAutoISS .And. lImpostos)
					SE2->E2_DIRF   := cDirf
					SE2->E2_CODRET := cCodRet
				Endif
				
				// Somente deduz o valor do ISS no titulo principal se a forma de retencao do ISS for pela baixa
				If cMRetISS == "1" .Or. (cMRetISS == "2" .And. SA2->A2_TIPO == "F" )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Converto o valor da duplicata para moeda corrente para subtrair³
					//³os impostos. Apos subtrair os impostos, converto o valor da    ³
					//³duplicata para moeda 2.                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   		If nMoedaCor <> 1
						If SA2->A2_CALCIRF == "2" .And. SE2->E2_IRRF > 0 // IR na baixa
							SE2->E2_VALOR   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-SE2->E2_ISS-nInss-nSEST)/SF1->F1_TXMOEDA
							SE2->E2_SALDO   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-SE2->E2_ISS-nInss-nSEST)/SF1->F1_TXMOEDA
						Else
							SE2->E2_VALOR   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-SE2->E2_IRRF-SE2->E2_ISS-nInss-nSEST)/SF1->F1_TXMOEDA
							SE2->E2_SALDO   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-SE2->E2_IRRF-SE2->E2_ISS-nInss-nSEST)/SF1->F1_TXMOEDA
						EndIf
					Else    
						If SA2->A2_CALCIRF == "2" .And. SE2->E2_IRRF > 0 // IR na baixa
							SE2->E2_VALOR   := aColsSE2[nX][nPValor]-nValFun-SE2->E2_ISS-nInss-nSEST
							SE2->E2_SALDO   := aColsSE2[nX][nPValor]-nValFun-SE2->E2_ISS-nInss-nSEST
						Else											// IR na emissão
							SE2->E2_VALOR   := aColsSE2[nX][nPValor]-nValFun-SE2->E2_IRRF-SE2->E2_ISS-nInss-nSEST
							SE2->E2_SALDO   := aColsSE2[nX][nPValor]-nValFun-SE2->E2_IRRF-SE2->E2_ISS-nInss-nSEST
						EndIf
					Endif	
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Converto o valor da duplicata para moeda corrente para subtrair³
					//³os impostos. Apos subtrair os impostos, converto o valor da    ³
					//³duplicata para moeda 2.  									  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realizado tratamento para valor do titulo, quando pessoa       ³
					//³Juridica, opcao 2 no CALCIRF e IRRF maior que 0 				  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nMoedaCor <> 1
						If SA2->A2_CALCIRF == "2" .AND. SA2->A2_TIPO == "J" .AND. SE2->E2_IRRF > 0
							SE2->E2_VALOR   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-nInss-nSEST)/SF1->F1_TXMOEDA
							SE2->E2_SALDO   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-nInss-nSEST)/SF1->F1_TXMOEDA
						ElseIf SA2->A2_CALCIRF == "2" .AND. SA2->A2_TIPO == "F"
							SE2->E2_VALOR   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-nSEST)/SF1->F1_TXMOEDA
							SE2->E2_SALDO   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-nSEST)/SF1->F1_TXMOEDA
						Else	
							SE2->E2_VALOR   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-SE2->E2_IRRF-nInss-nSEST)/SF1->F1_TXMOEDA
							SE2->E2_SALDO   := ((Round(aColsSE2[nX][nPValor]*SF1->F1_TXMOEDA,2))-nValFun-SE2->E2_IRRF-nInss-nSEST)/SF1->F1_TXMOEDA
						EndIf
					Else
						If SA2->A2_CALCIRF == "2" .AND. SA2->A2_TIPO == "J".AND. SE2->E2_IRRF > 0
							SE2->E2_VALOR   := aColsSE2[nX][nPValor]-nValFun-nInss-nSEST
							SE2->E2_SALDO   := aColsSE2[nX][nPValor]-nValFun-nInss-nSEST
						ElseIf SA2->A2_CALCIRF == "2" .AND. SA2->A2_TIPO == "F"
							SE2->E2_VALOR   := aColsSE2[nX][nPValor]-nValFun-nSEST
							SE2->E2_SALDO   := aColsSE2[nX][nPValor]-nValFun-nSEST
						Else
							SE2->E2_VALOR   := aColsSE2[nX][nPValor]-nValFun-SE2->E2_IRRF-nInss-nSEST
							SE2->E2_SALDO   := aColsSE2[nX][nPValor]-nValFun-SE2->E2_IRRF-nInss-nSEST						
						EndIf
					Endif	
				Endif      

				// Grava a forma de retencao do ISS (1=Emissao / 2=Baixa)
				If SE2->E2_ISS > 0
					SE2->E2_TRETISS := cMRetISS
				Endif

				lRestValImp := .F.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava a Marca de "pendente recolhimento" dos demais registros    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				If ( !Empty( SE2->E2_PIS ) .Or. !Empty( SE2->E2_COFINS ) .Or. !Empty( SE2->E2_CSLL ) )
					SE2->E2_PRETPIS := "1"
					SE2->E2_PRETCOF := "1"
					SE2->E2_PRETCSL := "1"
				EndIf	

				If !lPCCBaixa
					Do Case
					Case cModRetPIS == "1"

						nVlRetPIS	:= 0
						nVlRetCOF	:= 0
						nVlRetCSLL	:= 0

						If SE2->E2_PIS == 0 .And. SE2->E2_COFINS == 0 .And. SE2->E2_CSLL == 0 .And. lRatPIS .And. lRatCOFINS .And. lRatCSLL
							AFill( aDadosRet, 0 )	// Preenche as posicoes do array com 0
                     Else 
							If aScan( aColsSE2 , {|x| x[nPPIS] > 0 .Or. x[nPCOFINS] > 0 .Or. x[nPCSLL] > 0 } ) > 0
								aDadosRet	:= NfeCalcRet( SE2->E2_VENCREA, nIndexSE2 , @aDadosImp )
							Else
								AFill( aDadosRet, 0 )	// Preenche as posicoes do array com 0
							EndIf
						EndIf
						
						lRetParc	:= .F.

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se ha residual de retencao para ser somada a retencao do titulo atual³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aDadosRet[ 6 ] > nValMinRet .And. IIf( lRatPIS , SE2->E2_PIS > 0 , aScan( aColsSE2 , {|x| x[nPPIS] > 0 } ) > 0 )  // PIS
							lRetParc	:= .T.
							nVlRetPis += aDadosImp[1]
						EndIf

						If aDadosRet[ 7 ] > nValMinRet .And. IIf( lRatCOFINS , SE2->E2_COFINS > 0 , aScan( aColsSE2 , {|x| x[nPCOFINS] > 0 } ) > 0 )  // COFINS
							lRetParc	:= .T.
							nVlRetCof += aDadosImp[2]
						EndIf

						If aDadosRet[ 8 ] > nValMinRet .And. IIf( lRatCSLL , SE2->E2_CSLL > 0 , aScan( aColsSE2 , {|x| x[nPCSLL] > 0 } ) > 0 )  // CSLL
							lRetParc	:= .T.
							nVlRetCSLL += aDadosImp[3]
						EndIf

						If lRetParc 							

							nTotARet	:= nVlRetPIS + nVlRetCOF + nVlRetCSLL

							nSobra		:= SE2->E2_VALOR - nTotARet

							If nSobra < 0

								nSavRec		:= SE2->( Recno() )

								nFatorRed	:= 1 - ( Abs( nSobra ) / nTotARet )

								nVlRetPIS	:= NoRound( nVlRetPIS * nFatorRed, 2 )
								nVlRetCOF	:= NoRound( nVlRetCOF * nFatorRed, 2 )  						

								nVlRetCSLL	:= SE2->E2_VALOR - ( nVlRetPIS + nVlRetCOF ) - 0.01

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava o valor de NDF caso a retencao seja maior   ³
								//³ que o valor do titulo                             ³							
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If FindFunction("ADUPCREDRT")								
									ADupCredRt(Abs(nSobra),"501",SE2->E2_MOEDA)
								Endif	

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Restaura o registro do titulo original            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								SE2->( MsGoto( nSavRec ) ) 								

								Reclock( "SE2", .F. ) 								

							EndIf

							lRestValImp := .T.

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Guarda os valores originais                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nRetOriPIS  := SE2->E2_PIS
							nRetOriCOF  := SE2->E2_COFINS
							nRetOriCSLL := SE2->E2_CSLL

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Grava os novos valores de retencao para este registro ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SE2->E2_PIS    := nVlRetPIS 					
							SE2->E2_COFINS := nVlRetCOF 										
							SE2->E2_CSLL   := nVlRetCSLL 										

							nSavRec := SE2->( Recno() )

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Exclui a Marca de "pendente recolhimento" dos demais registros   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aRecnos := aClone( aDadosRet[ 5 ] )

							cPrefOri  := SE2->E2_PREFIXO
							cNumOri   := SE2->E2_NUM
							cParcOri  := SE2->E2_PARCELA
							cTipoOri  := SE2->E2_TIPO
							cCfOri    := SE2->E2_FORNECE
							cLojaOri  := SE2->E2_LOJA

							For nLoop := 1 to Len( aRecnos )

								SE2->( MsGoto( aRecnos[ nLoop ] ) )

								RecLock( "SE2", .F. )

								If !Empty( nVlRetPIS )
									SE2->E2_PRETPIS := "2"
								EndIf

								If !Empty( nVlRetCOF )
									SE2->E2_PRETCOF := "2"
								EndIf

								If !Empty( nVlRetCSLL )
									SE2->E2_PRETCSL := "2"
								EndIf

								SE2->( MsUnlock() )  																								

								If AliasIndic("SFQ")
									If nSavRec <> aRecnos[ nLoop ]
										DbSelectArea("SFQ")
										RecLock("SFQ",.T.)
										SFQ->FQ_FILIAL  := xFilial("SFQ")
										SFQ->FQ_ENTORI  := "SE2"
										SFQ->FQ_PREFORI := cPrefOri
										SFQ->FQ_NUMORI  := cNumOri
										SFQ->FQ_PARCORI := cParcOri
										SFQ->FQ_TIPOORI := cTipoOri										
										SFQ->FQ_CFORI   := cCfOri
										SFQ->FQ_LOJAORI := cLojaOri

										SFQ->FQ_ENTDES  := "SE2"
										SFQ->FQ_PREFDES := SE2->E2_PREFIXO
										SFQ->FQ_NUMDES  := SE2->E2_NUM
										SFQ->FQ_PARCDES := SE2->E2_PARCELA
										SFQ->FQ_TIPODES := SE2->E2_TIPO
										SFQ->FQ_CFDES   := SE2->E2_FORNECE
										SFQ->FQ_LOJADES := SE2->E2_LOJA

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Grava a filial de destino caso o campo exista                    ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										SFQ->FQ_FILDES := SE2->E2_FILIAL

										MsUnlock()
									Endif								
								Endif					

							Next nLoop

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Retorna do ponteiro do SE1 para a parcela         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							SE2->( MsGoto( nSavRec ) )
							Reclock( "SE2", .F. )

						Else 	
							lRetParc := .F. 							  	
						EndIf

					Case cModRetPIS == "2"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Efetua a retencao                                                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lRetParc := .T.
					Case cModRetPIS == "3" 			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Nao efetua a retencao                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lRetParc := .F.
					EndCase 			
				Else
					If lPccBaixa
						lRetParc := .F.
					Else
						lRetParc := .T.
					EndIf
				EndIf 					

				SE2->E2_VALOR	-= SE2->E2_PIS
				SE2->E2_SALDO	-= SE2->E2_PIS
				nVlCruz			-= SE2->E2_PIS

				SE2->E2_VALOR	-= SE2->E2_COFINS
				SE2->E2_SALDO	-= SE2->E2_COFINS
				nVlCruz			-= SE2->E2_COFINS					

				SE2->E2_VALOR	-= SE2->E2_CSLL
				SE2->E2_SALDO	-= SE2->E2_CSLL
				nVlCruz			-= SE2->E2_CSLL

				If lFethab
					SE2->E2_VALOR   -= SE2->E2_FETHAB
					SE2->E2_SALDO   -= SE2->E2_FETHAB
					nVlCruz         -= SE2->E2_FETHAB					
				EndIf
				
				If lFabov
					SE2->E2_VALOR   -= SE2->E2_FABOV
					SE2->E2_SALDO   -= SE2->E2_FABOV
					nVlCruz         -= SE2->E2_FABOV
				EndIf	

				If lFacs
					SE2->E2_VALOR   -= SE2->E2_FACS
					SE2->E2_SALDO   -= SE2->E2_FACS
					nVlCruz         -= SE2->E2_FACS					
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravacao do imposto CIDE no titulo principal                                                  ³
				//³ Caso seja utilizada cond. pagto. parcelada, grava o valor total somente na primeira parcela   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCIDE .And. nX == 1
					SE2->E2_CIDE := nValCIDE
				EndIf

			Else
				SE2->E2_VALOR   := aColsSE2[nX][nPValor]
				SE2->E2_SALDO   := aColsSE2[nX][nPValor]
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ha necessidade da gravacao das multiplas naturezas    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRateio := 0
			If lRatLiq
				nValor := SE2->E2_VALOR
				If !lRetParc
					nValor   += SE2->E2_PIS
				EndIf
				If !lRetParc
					nValor  += SE2->E2_COFINS
				EndIf
				If !lRetParc
					nValor   += SE2->E2_CSLL
				EndIf
			Else
				nValor   := aColsSE2[nX][nPValor]
			EndIf
			For nY := 1 To Len(aColsSEV)
				If !aColsSEV[nY][Len(aColsSEV[1])] .And. !Empty(aColsSEV[nY][1]) .OR. lMulNats
					SE2->E2_MULTNAT := "1"
					RecLock("SEV", .T. )
					For nZ := 1 To Len(aHeadSEV)
						If aHeadSEV[nZ][10]<>"V"
							SEV->(FieldPut(FieldPos(aHeadSEV[nZ][2]),aColsSEV[nY][nZ]))
						EndIf
					Next nZ

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Habilita a geracao dos rateios financeiros para integracao com NFE ³
					//³mesmo com natureza simples mas com rateios de c.custo por itens no ³
					//³documento de entrada. Vinculado ao MV_MULNATP e MV_MULNATS.        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPercSEV 		 := SEV->EV_PERC
					If Empty(aColsSEV[nY][1])
						nPercSEV		:= 100
						SEV->EV_NATUREZ	:= SE2->E2_NATUREZ
					EndIf

					SEV->EV_FILIAL   := xFilial("SEV")
					SEV->EV_PREFIXO  := SE2->E2_PREFIXO
					SEV->EV_NUM      := SE2->E2_NUM
					SEV->EV_PARCELA  := SE2->E2_PARCELA
					SEV->EV_CLIFOR   := SE2->E2_FORNECE
					SEV->EV_LOJA     := SE2->E2_LOJA
					SEV->EV_TIPO     := SE2->E2_TIPO
					SEV->EV_VALOR    := IIf(nY==Len(aColsSEV),nValor-nRateio,NoRound(nValor*nPercSEV/100,2))
					SEV->EV_PERC     := nPercSEV/100
					SEV->EV_RECPAG   := "P"
					SEV->EV_LA       := ""
					SEV->EV_IDENT    := "1"
					nRateio += SEV->EV_VALOR
					nRateioSEZ := 0
					If lAtuSldNat
						AtuSldNat(SEV->EV_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, If(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG,"3","2"), "P", SEV->EV_VALOR, SE2->E2_VLCRUZ*SEV->EV_PERC, If(SE2->E2_TIPO $ MVABATIM, "-", "+"),,FunName(),"SEV", SEV->(Recno()),nOpca)
					Endif
					For nZ := 1 To Len(aSEZ)
						SEV->EV_RATEICC := "1"
						RecLock("SEZ",.T.)
						SEZ->EZ_FILIAL := xFilial("SEZ")
						SEZ->EZ_PREFIXO:= SEV->EV_PREFIXO
						SEZ->EZ_NUM    := SEV->EV_NUM
						SEZ->EZ_PARCELA:= SEV->EV_PARCELA
						SEZ->EZ_CLIFOR := SEV->EV_CLIFOR
						SEZ->EZ_LOJA   := SEV->EV_LOJA
						SEZ->EZ_TIPO   := SEV->EV_TIPO
						SEZ->EZ_PERC   := aSEZ[nZ][4]
						SEZ->EZ_VALOR  := IIf(nZ==Len(aSEZ),SEV->EV_VALOR-nRateioSEZ,NoRound(SEV->EV_VALOR*SEZ->EZ_PERC,2))
						SEZ->EZ_NATUREZ:= SEV->EV_NATUREZ
						SEZ->EZ_CCUSTO := aSEZ[nZ][1]
						SEZ->EZ_ITEMCTA:= aSEZ[nZ][2]
						SEZ->EZ_CLVL   := aSEZ[nZ][3]
						SEZ->EZ_RECPAG := SEV->EV_RECPAG
						SEZ->EZ_LA     := ""
						SEZ->EZ_IDENT  := SEV->EV_IDENT
						SEZ->EZ_SEQ    := SEV->EV_SEQ
						SEZ->EZ_SITUACA:= SEV->EV_SITUACA
						nRateioSEZ += SEZ->EZ_VALOR
						MsUnLock()
					Next nZ					
				EndIf
			Next nY			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa alteracoes da NF com base no contrato - SIGAGCT ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGCTRet .Or. lGCTDesc .Or. lGCTMult .Or. lGCTBoni .Or. lGCTBloq
				CNTAvalGCT(nGCTRet,nGCTDesc,nGCTMult,nGCTBoni,@nVlCruz,aContra,lGCTBloq)
			EndIf

			FaAvalSE2(1, "MATA100",(nX==1),MaFisRet(,"NF_VALIRR"),MaFisRet(,"NF_VALINS"),lRetParc,MaFisRet(,"NF_VALISS"),MaFisRet(,"NF_BASEISS"),lRatImp,cRecIss)
			If cPaisLoc == "BRA"
				If !lRetParc
					SE2->E2_VALOR	+= SE2->E2_PIS
					SE2->E2_SALDO	+= SE2->E2_PIS
					nVlCruz			+= SE2->E2_PIS
				EndIf
				If !lRetParc
					SE2->E2_VALOR	+= SE2->E2_COFINS
					SE2->E2_SALDO	+= SE2->E2_COFINS
					nVlCruz			+= SE2->E2_COFINS					
				EndIf
				If !lRetParc
					SE2->E2_VALOR	+= SE2->E2_CSLL
					SE2->E2_SALDO	+= SE2->E2_CSLL
					nVlCruz			+= SE2->E2_CSLL					
				EndIf
			EndIf			
			If lRetParc
				aCtbRet[1] += SE2->E2_PIS
				aCtbRet[2] += SE2->E2_COFINS
				aCtbRet[3] += SE2->E2_CSLL
			EndIf
			If lRestValImp
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura os valores originais de PIS / COFINS / CSLL  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SE2->E2_PIS    := nRetOriPIS
				SE2->E2_COFINS := nRetOriCOF
				SE2->E2_CSLL   := nRetOriCSLL
			EndIf
			nInss			:=	Iif( SED->ED_DEDINSS=="2",0,SE2->E2_INSS )
			SE2->E2_VLCRUZ 	:= 	xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,NIL,SF1->F1_TXMOEDA)
			If cMRetISS == "1" .Or. (cMRetISS == "2" .And. SA2->A2_TIPO == "F" )
				nVlCruz -= SE2->E2_VLCRUZ+(nValFun+SE2->E2_IRRF+SE2->E2_ISS+nInss+nSEST)
			Else
				nVlCruz -= SE2->E2_VLCRUZ+(nValFun+SE2->E2_IRRF+nInss+nSEST)
			Endif
			If nX == nMaxFor
				SE2->E2_VLCRUZ += nVlCruz
			EndIf			

			If lMulta
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava as multas de contrato ( SIGAGCT ) na parcela                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nBaixaMult := Min( nSaldoMult, SE2->E2_SALDO )
				SE2->E2_DECRESC := nBaixaMult
				SE2->E2_SDDECRE := nBaixaMult

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Baixa o saldo a gravar                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nSaldoMult -= nBaixaMult
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o valor da bonificacao ( SIGAGCT ) na parcela               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty( nSaldoBoni )
					SE2->E2_ACRESC  := nSaldoBoni
					SE2->E2_SDACRES := nSaldoBoni
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Zera o saldo a gravar                                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSaldoBoni := 0
				EndIf 					
			EndIf 	
			
			If lPrjCni 
						//Verifica se existe rateio financeiro e processa rateio.
				cChave1 := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja
				FRZ->(dbSetOrder(2))
				FRZ->(MsSeek(xFilial("FRZ")+SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1])))
				While FRZ->(!eof()) .and. SubStr(cChave1+Space(TamSX3("FRZ_CHAVE")[1]),1,TamSX3("FRZ_CHAVE")[1]) == FRZ->FRZ_CHAVE
					
					Aadd(aRatFin, {	FRZ->FRZ_EMPDES,;          //01
							FRZ->FRZ_UNDDES,;                  //02
							FRZ->FRZ_FILDES,;                  //03
							FRZ->FRZ_TPENT,;                   //04
							FRZ->FRZ_PEREMP,;                  //05
							FRZ->FRZ_PERUND,;                  //06
							FRZ->FRZ_PERCEN,;                  //07
							0,; 						  //08
							0,;           			      //09
							FRZ->FRZ_HIST,;                    //10
							FRZ->FRZ_RATEIO,;                  //11
							FRZ->FRZ_CLIENT,;                  //12
							FRZ->FRZ_LOJCLI,;                  //13
							FRZ->FRZ_FORNEC,;                  //14
							FRZ->FRZ_LOJFOR,;                  //15
							"",;                               //16
							FRZ->FRZ_DEBITO,;                  //17
							FRZ->FRZ_CCD,;                     //18
							FRZ->FRZ_ITEMD,;                   //19
							FRZ->FRZ_CLVLDB,;                  //20
							FRZ->FRZ_CREDIT,;                  //21
							FRZ->FRZ_CCC,;                     //22
							FRZ->FRZ_ITEMC,;                   //23
							FRZ->FRZ_CLVLCR } )                //24
					
					FRZ->(dbSkip())
				EndDo
	
				//Grava rateio financeiro
				If Len(aRatFin) > 0
					cChaveRat := "SE2"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
					F641GrvRat(cChaveRat,aRatFin)
					aRatFin := {}
		
					SE2->E2_RATFIN := "1"
				EndIf
	
				If SE2->E2_RATFIN == "1"
				
					IF !l103Auto .and. SuperGetMv("MV_TRFCPA",,.F.) .And. SuperGetMv("MV_DSTCPA",,.F.) //rotina automatica
						nRadio	:= 1
						DEFINE MSDIALOG oRatFin FROM  94,1 TO 250,310 TITLE "Opcoes Disponiveis Rateio Financeiro"  PIXEL // 
						@ 10,17 Say "Escolha a Opção desejada" SIZE 150,7 OF oRatFin PIXEL  // 
						@ 27,07 TO 58, 150 OF oRatFin  PIXEL
						@ 35,10 Radio 	oRadio 	VAR nRadio;
						ITEMS   "Distribuição"	,;		// 
						"Transferência";			// 
						3D SIZE 100,10 OF oRatFin PIXEL
							
						DEFINE SBUTTON oBtn FROM 060,120 TYPE 1 ENABLE OF oRatFin;
						ACTION  {|| If(nRadio == 1, nRateio := 1, nRateio := 0),oRatFin:End() }
							
						ACTIVATE MSDIALOG oRatFin CENTERED
					Else
						nRateio := 0
					EndIf
					Fa621Auto(SE2->(Recno()),xFilial("FRZ"),, .T. , .T. ,'S',If(nRateio==1,"D","T"))		
				ElseIf !SuperGetMv("MV_TRFCPA",,.F.) .And. SuperGetMv("MV_DSTCPA",,.F.) //rotina automatica
					Fa621Auto(SE2->(Recno()),xFilial("FRZ"),, .T. , .T. ,'S',"D")		
				ElseIf SuperGetMv("MV_TRFCPA",,.F.) .And. !SuperGetMv("MV_DSTCPA",,.F.) //rotina automatica
					Fa621Auto(SE2->(Recno()),xFilial("FRZ"),, .T. , .T. ,'S',"T")		
				EndIF
			EndIf	
			
			If lAtuSldNat .And. SE2->E2_MULTNAT <> "1"
				AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, If(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG,"3","2"), "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, If(SE2->E2_TIPO $ MVABATIM, "-", "+"),,FunName(),"SE2", SE2->(Recno()),nOpca)
			Endif	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Template acionando ponto de entrada                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistTemplate("MT100GE2")
				ExecTemplate("MT100GE2",.F.,.F.)
			EndIf			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada apos a gravacao do titulo a pagar                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Existblock("MT100GE2")
				ExecBlock("MT100GE2",.F.,.F.,{aColsSE2[nX],nOpcA,aHeadSE2})				
			EndIf  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O funrural somente deve ser gerado para a primeira parcela        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			nValFun	:= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A FETHAB somente deve ser gerada para a primeira parcela          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			nValFet	:= 0			
			nValFab	:= 0						
			nValFac	:= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena o recno dos titulos gerados                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If ValType( aRecGerSE2 ) == "A"
				AAdd( aRecGerSE2, SE2->( Recno() ) )
			EndIf 			

		EndIf	
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o valor de retencao do PIS/COFINS/CSLL para contabilizacao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCtRetNf
		RecLock("SF1")
		SF1->F1_VALPIS := aCtbRet[1]
		SF1->F1_VALCOFI := aCtbRet[2]
		SF1->F1_VALCSLL := aCtbRet[3]
	EndIf	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorno dos titulos a pagar                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFAULT aRecSE2 := {}  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca titulo CIDE e inclui seu Recno no array aRecSE2 para ser excluido junto com os demais titulos  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCide .And. Len(aRecSE2) > 0			
		DbSelectArea("SE2")
		MsGoto(aRecSE2[1])
		DbSetOrder(1)
		If (MsSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+"1"+"CID"+cForCIDE))
			AADD(aRecSE2,SE2->(Recno()))
		EndIf
	EndIf

	For nX := 1 To Len(aRecSE2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorno dos titulos financeiros                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE2")
		MsGoto(aRecSE2[nX])	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao de registros do SE5 na exclusao C.Pagar	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		If FindFunction("MT103GrvSE5")
			MT103GrvSE5() 
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Template acionando ponto de entrada                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistTemplate("M103DSE2")
			ExecTemplate("M103DSE2",.F.,.F.)
		EndIf			

		If (Existblock("M103DSE2"))
			ExecBlock("M103DSE2",.F.,.F.)
		EndIf
		If lAtuSldNat .And. SE2->E2_MULTNAT <> "1"
			AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, If(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG,"3","2"), "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, If(SE2->E2_TIPO $ MVABATIM, "+", "-"),,FunName(),"SE2", SE2->(Recno()),nOpca)
		Endif	
		RecLock("SE2",.F.)
		dbDelete()
		FaAvalSE2(2, "MATA100")
		FaAvalSE2(3, "MATA100")
	Next nX
EndIf

RestArea(aAreaSA2)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103RatVEI³ Autor ³Patricia A. Salomao     ³ Data ³19.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela rateios por Veiculo/Viagem                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 / MATA240 / MATA241                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a103RatVei()

Local bSavKeyF4   := SetKey(VK_F4,Nil)
Local bSavKeyF5   := SetKey(VK_F5,Nil)
Local bSavKeyF6   := SetKey(VK_F6,Nil)
Local bSavKeyF7   := SetKey(VK_F7,Nil)
Local bSavKeyF8   := SetKey(VK_F8,Nil)
Local bSavKeyF9   := SetKey(VK_F9,Nil)
Local bSavKeyF10  := SetKey(VK_F10,Nil)
Local bSavKeyF11  := SetKey(VK_F11,Nil)
Local aSavaRotina := aClone(aRotina)
Local nOpc		  := 0
Local nY,nT
Local oDlg, oGetDados
Local nPosItem	
Local nPosRat		
Local nPosRatFro
Local nItem
Local nOpcx
Local cCposSDG		:= ""
Local aCposSDG		:= {}
Local lRet			:= .T.
Local lMA103SDG		:= ExistBlock("MA103SDG")
Local nCont			:= 0

Private aSavCols	:= {}
Private aSavHeader	:= {}
Private nSavN		:= 0
Private nTotValor	:= 0
Private M->DG_CODDES := CriaVar("DG_CODDES")  //-- Esta variavel e' utilizada pelo programa TMSA070

If l240 .Or. l241
	nPosItem	  := If(l241,StrZero(n,Len(SDG->DG_ITEM)),StrZero(1,Len(SDG->DG_ITEM)) )
	nPosRat	      := aScan(aRatVei,{|x| x[1] == nPosItem })
	nPosRatFro    := aScan(aRatFro,{|x| x[1] == nPosItem })		
	nItem         := nPosItem
Else
	nPosItem	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM" })
	nPosRat	      := aScan(aRatVei,{|x| x[1] == aCols[n][nPosItem] })
	nPosRatFro    := aScan(aRatFro,{|x| x[1] == aCols[n][nPosItem] })
	nItem         := aCols[n][nPosItem]
EndIf

If !l240
	aSavCols 	  := aClone(aCols)
	aSavHeader	  := aClone(aHeader)
	nSavN	  	  := n
EndIf

If nPosRatFro > 0
	For nY := 1 To Len(aRatFro)
		If aRatFro[nY][1] == nItem
			For nT := 1 to Len(aRatFro[nY][2])
				If !aRatFro[nY][2][nT] [Len(aRatFro[nY][2][nT])] //Verifica se nao esta deletado
					Help(" ",1,"A103RATFRO") // "Foi Informado Rateio por Frota"
					lRet := .F.
					Exit
				EndIf
			Next nT
		EndIf
		If !lRet
			Exit
		EndIf
	Next	
EndIf	

If lRet
	n        := 1
	aCols	   := {}
	aHeader	:= {}
	aRotina[2][4]	:= 2
	aRotina[3][4]	:= 3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCposSDG := "DG_ITEM|DG_CODVEI|DG_FILORI|DG_VIAGEM|DG_TOTAL"
	If Inclui //-- Estes campos so' deverao ser mostrados na inclusao do Rateio
		cCposSDG += "|DG_COND|DG_NUMPARC|DG_PERVENC"
	EndIf
	
	If lMA103SDG    //-- Ponto de Entrada para adicionar campos no aHeader do SDG.
		aCposSDG := ExecBlock("MA103SDG",.F.,.F.,cCposSDG)
		If ValType(aCposSDG) == "A"
			For nCont := 1 To Len(aCposSDG)
				cCposSDG += "|" + aCposSDG[nCont]
			Next nCont
		EndIf
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(1)
	MsSeek("SDG")
	While !EOF() .And. (x3_arquivo == "SDG")
		IF X3USO(x3_usado) .And. cNivel >= x3_nivel .And. Alltrim(x3_campo)$ cCposSDG
			//-- Altera o Valid do campo DG_CODVEI
			If AllTrim(X3_CAMPO) == 'DG_CODVEI' .And. !("TMSA070VAL"$UPPER(X3_VALID))
				RecLock('SX3',.F.)
				SX3->X3_VALID := "(Vazio() .Or. ExistCpo('DA3')) .And. TMSA070Val()"
				MsUnLock()
			EndIf   	
			AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		EndIf
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aRatVei:                              ³
	//³ aRatVei[n,1] - Item da Nota                              ³
	//³ aRatVei[n,2] - aCols do Rateio de Veiculo/Viagem         ³
	//³ aRatVei[n,3] - Codigo da Despesa de Transporte           ³		
	//³ aRatVei[n,4] - Valor Total informado no Rateio           ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    	
	If nPosRat > 0
		aCols	     := aClone(aRatVei[nPosRat][2])
		M->DG_CODDES := aRatVei[nPosRat][3]
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aCols,Array(Len(aHeader)+1))
		For ny := 1 to Len(aHeader)
			If Trim(aHeader[ny][2]) == "DG_ITEM"
				aCols[1][ny] 	:= "01"
			Else
				aCols[1][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[1][Len(aHeader)+1] := .F.
		Next ny
	EndIf

	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		DEFINE MSDIALOG oDlg TITLE STR0120 Of oMainWnd PIXEL  FROM 94 ,104 TO 330,590 //'Rateio por Veiculo/Viagem'
		If l240 .Or. l241     	
			nOpcx := IIf(Inclui,3,2)		
			@ 18,3   SAY STR0121  Of oDlg PIXEL SIZE 56 ,9 //"Codigo da Despesa : "
			@ 18,60 MSGET M->DG_CODDES  Picture PesqPict("SDG","DG_CODDES") F3 CpoRetF3('DG_CODDES');
				When Inclui Valid CheckSX3('DG_CODDES',M->DG_CODDES,.T.) ; 		
				OF oDlg PIXEL SIZE 60 ,9							   		  		  	
			oGetDados := MSGetDados():New(32,2,113,243,nOpcx,'A103VeiLOK()','A103VeiTOK()','+DG_ITEM',.T.,,,,100,,,,If(nOpcx==2,"AlwaysFalse",NIL))		
		Else	
			@ 18 ,3   SAY OemToAnsi(STR0072) Of oDlg PIXEL SIZE 56 ,9 //"Documento : "
			@ 18 ,96  SAY OemToAnsi(STR0073) Of oDlg PIXEL SIZE 20 ,9 //"Item :"
			@ 18 ,36  SAY cSerie+" "+cNFiscal Of oDlg PIXEL SIZE 70 ,9
			@ 18 ,115 SAY aSavCols[nSavN][nPosItem] Of oDlg PIXEL SIZE 37 ,9
			@ 28,3   SAY STR0121  Of oDlg PIXEL SIZE 56 ,9 //"Codigo da Despesa : "
			@ 28,60 MSGET M->DG_CODDES  Picture PesqPict(STR0122,"DG_CODDES") F3 CpoRetF3('DG_CODDES'); //"SDG"
				When !l103Visual  Valid CheckSX3('DG_CODDES',M->DG_CODDES,.T.) ; 		
				OF oDlg PIXEL SIZE 60 ,9							   		  		
			oGetDados := MSGetDados():New(45,2,113,243,IIF(l103Visual,2,3),'A103VeiLOK()','A103VeiTOK()','+DG_ITEM',.T.,,,,100,,,,If(l103Visual,"AlwaysFalse",NIL))		  			
		EndIf	

		ACTIVATE MSDIALOG oDlg ON INIT (oGetdados:Refresh(),EnchoiceBar(oDlg,   {||IIF(oGetDados:TudoOk(),(nOpc:=1,oDlg:End()),(nOpc:=0))},{||oDlg:End()}) )
	Else
		nOpc := 1
	EndIf

	If nOpc == 1 .And. IIf(l240 .Or. l241, nOpcx<>2, !l103Visual)
		If nPosRat > 0
			aRatVei[nPosRat][2]	:= aClone(aCols)
			aRatVei[nPosRat][3]	:= 	M->DG_CODDES	
		Else
			aADD(aRatVei,{ IIf( l240.Or.l241,nPosItem,aSavCols[nSavN][nPosItem] ) , aClone(aCols), M->DG_CODDES, nTotValor })
		EndIf
	EndIf

	aRotina	:= aClone(aSavaRotina)
	aCols	   := aClone(aSavCols)
	aHeader	:= aClone(aSavHeader)
	n		   := nSavN

EndIf	
SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103VeiLOk³ Autor ³Patricia A. Salomao     ³ Data ³18.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a Linha Digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 / MATA240 / MATA241                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103VeiLOk()
Local lRet := .T.
Local cSeek:= ""
Local lIdent := SDG->(FieldPos("DG_IDENT")) > 0 .And. nModulo<>43

If !GdDeleted(n)

	//-- Analisa se ha itens duplicados na GetDados.
	If Inclui
		If lIdent
			lRet := GDCheckKey( { "DG_CODVEI","DG_IDENT" }, 4 )
		Else
			lRet := GDCheckKey( { "DG_CODVEI","DG_FILORI","DG_VIAGEM" }, 4 )
		EndIf
	EndIf

	If lRet
		If (Empty(GdFieldGet('DG_CODVEI',n)) .And. Iif(lIdent, Empty( GdFieldGet('DG_IDENT',n)) ,Empty(GdFieldGet('DG_VIAGEM',n)))) .Or. ;
				Empty(GdFieldGet('DG_TOTAL',n) )
			Help('',1,'OBRIGAT2',,RetTitle('DG_CODVEI')+' '+Iif(lIdent,RetTitle('DG_IDENT'),RetTitle('DG_VIAGEM'))+' '+RetTitle('DG_TOTAL'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse				
			lRet := .F.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o veiculo informado esta amarrado na viagem, caso a mesma seja informada. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !Empty(GdFieldGet('DG_CODVEI',n)) .And. Iif(lIdent,!Empty(GdFieldGet('DG_IDENT',n)),!Empty(GdFieldGet('DG_VIAGEM',n))) 
			If lIdent
				cSeek :=  GDFieldGet( 'DG_IDENT', n ) + GdFieldGet('DG_CODVEI',n)
			Else
				cSeek :=  GDFieldGet( 'DG_FILORI', n ) +  GDFieldGet( 'DG_VIAGEM', n ) + GdFieldGet('DG_CODVEI',n)
			EndIf
			DTR->(DbSetOrder(3))
			If DTR->(!MsSeek(xFilial("DTR")+cSeek))
				Help(" ",1,"TMSA07013") //-- O veiculo nao existe no complemento da viagem.
				lRet:= .F.
			EndIf
		EndIf
	EndIf

	If lRet .And. !Empty(GdFieldGet('DG_FILORI',n)) .And. !Empty(GdFieldGet('DG_VIAGEM',n))
		lRet := TMSChkViag(GdFieldGet('DG_FILORI',n),GdFieldGet('DG_VIAGEM',n),.F.,.F.,.F.,.T.,.F.,.F.,.F.,.F.,.F.,,.F.,.F.,.F.,.F.,.F.,.F.)
	EndIf

EndIf	

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103VeiTOk³ Autor ³Patricia A. Salomao     ³ Data ³19.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TudOk da GetDados da Tela de rateios por Veiculo/Viagem      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 / MATA240 / MATA241                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103VeiTOk()
Local nx:=0
Local nPosValor  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DG_TOTAL" })
Local nPosCodVei := Ascan(aHeader,{|x| Alltrim(x[2]) == "DG_CODVEI"})
Local nPosViagem := Ascan(aHeader,{|x| Alltrim(x[2]) == "DG_VIAGEM"})
Local nPosIdent  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DG_IDENT"})
Local lRet       := .T.
Local nPosValRat := 0
Local lIdent	 := SDG->(FieldPos("DG_IDENT")) > 0 .and. nModulo<>43

nTotValor := 0
For nx := 1 to Len(aCols)
	If !GdDeleted(nx)
		nTotValor += aCols[nx][nPosValor]
	EndIf
Next

If !l240 .And. !l241
	nPosValRat  := Ascan(aSavHeader,{|x| AllTrim(x[2]) == "D1_TOTAL"} )	
	If nPosValRat > 0 .And. nTotValor > 0 .And. nTotValor <> aSavCols[nSavN][nPosValRat]
		Help(' ', 1, 'A103TOTRAT') // Valor a ser rateado nao confere com o total.
		lRet := .F.
	EndIf
EndIf

If lRet .And. !GdDeleted(n) .And. Empty(aCols[n][nPosCodVei]) .And. Iif(lIdent,Empty(aCols[n][nPosIdent]),Empty(aCols[n][nPosViagem]))
	Help(' ', 1, 'A103VEVIVA') // Os Campos de Veiculo e Viagem estao Vazios.
	lRet := .F.	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Frota ³ Autor ³Patricia A. Salomao     ³ Data ³20.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de rateio por Frota                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 / MATA240 / MATA241                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a103Frota()
Local oDlg
Local nY,nT
Local aRet        := {}
Local nOpc		  := 0
Local nPosItem	  := 0
Local nPosValor   := 0
Local nPosRat	  := 0
Local nPosRatVei  := 0
Local nItem       := 0
Local lRet		  := .T.
Private M->DG_CODDES:= CriaVar("DG_CODDES") //-- Esta variavel e' utilizada pelo programa TMSA070

If l240 .Or. l241
	nPosItem	 := If(l241,StrZero(n,Len(SDG->DG_ITEM)),StrZero(1,Len(SDG->DG_ITEM)) )
	nPosRat	     := aScan(aRatFro,{|x| x[1] == nPosItem })
	nPosRatVei   := aScan(aRatVei,{|x| x[1] == nPosItem })	
	nItem        := nPosItem
	nPosValor    := 100
Else
	nPosItem	 := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM" })
	nPosRat	     := aScan(aRatFro,{|x| x[1] == aCols[n][nPosItem] })
	nPosRatVei   := aScan(aRatVei,{|x| x[1] == aCols[n][nPosItem]})
	nItem        := aCols[n][nPosItem]
	nPosValor    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TOTAL"} )		
EndIf

If nPosRatVei > 0
	For nY := 1 To Len(aRatVei)
		If aRatVei[nY][1] == nItem
			For nT := 1 to Len(aRatVei[nY][2])
				If !aRatVei[nY][2][nT] [Len(aRatVei[nY][2][nT])] //Verifica se nao esta deletado
					Help("",1,"A103RATVEI") // "Foi Informado Rateio por Veiculo/Viagem"				
					lRet := .F.
					Exit
				EndIf
			Next nT
		EndIf
		If !lRet
			Exit
		EndIf
	Next		
EndIf	

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aRatFro:                              ³
	//³ aRatFro[n,1] - Item da Nota                              ³
	//³ aRatFro[n,2] - aCols do Rateio de Frota                  ³
	//³ aRatFro[n,3] - Codigo da Despesa de Transporte           ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    	
	If nPosRat > 0
		aRet	 := aClone(aRatFro[nPosRat][2])
		M->DG_CODDES := aRatFro[nPosRat][3]	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aRet,{"01",IIf(l240 .Or.  l241, nPosValor,aCols[n][nPosValor]),.F.})
	EndIf

	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		DEFINE MSDIALOG oDlg TITLE STR0123 Of oMainWnd PIXEL FROM 94 ,30 TO 200,430 //'Rateio por Frota'
		If l240 .Or. l241	
			@ 20,3   SAY STR0121  Of oDlg PIXEL SIZE 56 ,9 //"Codigo da Despesa : "
			@ 20,60 MSGET M->DG_CODDES  Picture PesqPict("SDG","DG_CODDES") F3 CpoRetF3('DG_CODDES');
				When Inclui Valid CheckSX3('DG_CODDES',M->DG_CODDES) ; 		
				OF oDlg PIXEL SIZE 60 ,9							   		  		  	
		Else		
			@ 18 ,3   SAY OemToAnsi(STR0072) Of oDlg PIXEL SIZE 56 ,9 //"Documento : "
			@ 18 ,96  SAY OemToAnsi(STR0073) Of oDlg PIXEL SIZE 20 ,9 //"Item :"
			@ 18 ,36  SAY cSerie+" "+cNFiscal Of oDlg PIXEL SIZE 70 ,9
			@ 18 ,115 SAY aCols[n][nPosItem] Of oDlg PIXEL SIZE 37 ,9
			@ 30,3   SAY STR0121  Of oDlg PIXEL SIZE 56 ,9 //"Codigo da Despesa : "
			@ 30,60 MSGET M->DG_CODDES  Picture PesqPict("SDG","DG_CODDES") F3 CpoRetF3('DG_CODDES');
				When !l103Visual  Valid CheckSX3('DG_CODDES',M->DG_CODDES) ; 		
				OF oDlg PIXEL SIZE 60 ,9							   		  		
		EndIf	
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOpc:=1,oDlg:End())},{||oDlg:End()} )		
	Else
		nOpc := 1
	EndIf
	If nOpc == 1
		If nPosRat > 0
			aRatFro[nPosRat][2]	:= aClone(aRet)
			aRatFro[nPosRat][3]	:= M->DG_CODDES
		Else
			AAdd(aRatFro,{ IIf( l240.Or.l241,nPosItem,aCols[n][nPosItem] ) , aClone(aRet), M->DG_CODDES })		
		EndIf
	EndIf
EndIf
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103GrvSDG³ Autor ³Patricia A. Salomao     ³ Data ³20.11.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava no SDG o Rateio por Veiculo/Viagem e o Rateio por Frota³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1- Alias do Arquivo                                      ³±±
±±³          ³ExpA1- Array contendo os Rateios informados na Tela de Rateio³±±
±±³          ³ExpC2- Tipo do Rateio (V=Veiculo/Viagem ; F=Frota)           ³±±
±±³          ³ExpC3- Item do SD1 ou SD3 que esta sendo gravado             ³±±
±±³          ³ExpL1- Lancamento Contabil OnLine (mv_par06)                 ³±±
±±³          ³ExpN1- Cabecalho do Lancamento Contabil                      ³±±
±±³          ³ExpN2- Total do Lancamento Contabil (@)                      ³±±
±±³          ³ExpC4- Lote para Lancamento Contabil                         ³±±
±±³          ³ExpC5- Programa que esta executando a funcao                 ³±±
±±³          ³ExpD1- Data de emissao inicial                 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 / MATA240 / MATA241                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103GrvSDG(cAlias,aArraySDG,cTpRateio,cItem,lCtbOnLine,nHdlPrv,nTotalLcto,cLote,cProg,dDataEmi)

Local nValRat    := 0
Local aCustoVei  := {}
Local aRecSDGBai := {}
Local aRecSDGEmi := {}
Local nW,nT,cCodDesp,cDoc
Local aParcelas  := {}
Local nParcela   := 0
Local nPerVenc   := 0

Local dDataVenc  := dDataBase
Local nCnt       := 0
Local cCond      := ""
Local cCodVei    := ""
Local cFilOri    := ""
Local cViagem    := ""
Local cIdent	 := ""
Local lBaixa     := .F.
Local lMovim     := .F.
Local lIdent	 := SDG->(FieldPos("DG_IDENT")) > 0
Local lDtlanc	 := SDG->(FieldPos('DG_DTLANC')) > 0
Local lDtlaemi	 := SDG->(FieldPos('DG_DTLAEMI')) > 0

Local nValCob    := 0
Local nTotValCob := 0
Local nSbCusto1  := 0
Local nValTotRat := 0
Local nPerc      := 0
Local nTotPerc   := 0
Local nSbCusto2  := 0
Local nSbCusto3  := 0
Local nSbCusto4  := 0
Local nSbCusto5  := 0
Local nCntFor    := 0
Local nDecCusto1 := TamSx3("DG_CUSTO1")[2]
Local nDecCusto2 := TamSx3("DG_CUSTO2")[2]
Local nDecCusto3 := TamSx3("DG_CUSTO3")[2]
Local nDecCusto4 := TamSx3("DG_CUSTO4")[2]
Local nDecCusto5 := TamSx3("DG_CUSTO5")[2]
Local nDecValCob := TamSx3("DG_VALCOB")[2]
Local nDecPerc   := TamSx3("DG_PERC")[2]

DEFAULT aArraySDG  := {}
DEFAULT cTpRateio  := ""
DEFAULT nTotalLcto := 0
DEFAULT lCtbOnLine := .F.
DEFAULT nHdlPrv    := 0
DEFAULT cLote      := ""
DEFAULT cProg      := "MATA103"
DEFAULT dDataEmi   := dDataBase

dDataVenc := dDataEmi

For nW := 1 to Len(aArraySDG)			    					        				
	cCodDesp := aArraySDG[nW][3] //-- Despesa
	cDoc     := NextNumero("SDG",1,"DG_DOC",.T.)	
	If cTpRateio=="V"
		nValTotRat := aArraySDG[nW][4] //-- Valor Total do Rateio
	Else
		nValTotRat := IIf(cAlias=="SD1", SD1->D1_TOTAL, SD3->D3_CUSTO1)
	EndIf	
	For  nT:=1 to Len(aArraySDG[nW][2])
		If aArraySDG[nW][1] == cItem .And. !(aArraySDG[nW][2][nT] [Len(aArraySDG[nW][2][nT])]) // Verifica se esta deletado
			aCustoVei  := Array(6)
			If cTpRateio=="V"
				cCodVei  := aArraySDG[nW][2][nT][2] //-- Codigo Veiculo
				cFilOri  := aArraySDG[nW][2][nT][3] //-- Filial Origem
				cViagem  := aArraySDG[nW][2][nT][4] //-- Viagem
				cCond    := aArraySDG[nW][2][nT][6] //-- Condicao
				nParcela := aArraySDG[nW][2][nT][7] //-- Numero Parcelas
				nPerVenc := aArraySDG[nW][2][nT][8] //-- Periodo Vencimento
				If lIdent .And. nModulo==39
					cIdent	 := aArraySDG[nW][2][nT][10]//-- Identificador Viagem/Carga
				EndIf
			EndIf
			If cAlias == 'SD1'
				nValRat := If(cTpRateio=="V",aArraySDG[nW][2][nT][5], SD1->D1_TOTAL ) //-- Valor do Rateio			
				lMovim  := .F.
			ElseIf cAlias == 'SD3'
				nValRat := If(cTpRateio=="V",aArraySDG[nW][2][nT][5], SD3->D3_CUSTO1 ) //-- Valor do Rateio
				lMovim  := .T.	
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o arquivo SDG - Movim. de Custo de Transporte (Integracao TMS) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Retorna a quantidade de parcelas
			aParcelas := {}
			If cTpRateio == "V"
				If !Empty(cCond)
					aParcelas:= Condicao(nValRat,cCond,,dDataEmi)
				Else					
					nParcela  := Iif(nParcela==0,1,nParcela) //-- Inicializa o numero de parcelas
					nDataVenc := dDataBase
					For nCnt := 1 To nParcela
						dDataVenc := dDataVenc + nPerVenc	
						Aadd( aParcelas, { dDataVenc, nValRat / nParcela } )
					Next nCnt
				EndIf
			Else
				Aadd( aParcelas, { dDataBase, nValRat } )
			EndIf

			nPerc        := Round( (nValRat / nValTotRat) * 100, nDecPerc )    //-- Percentual Total do Item
			aCustoVei[6] := Round( nPerc / Len(aParcelas ) , nDecPerc ) //-- Percentual de cada Parcela do item

			If cAlias == 'SD1'
				//-- Armazena o Total do custo
				nSbCusto1 := ( ( SD1->D1_CUSTO  * nPerc ) / 100 )
				nSbCusto3 := ( ( SD1->D1_CUSTO2 * nPerc ) / 100 )
				nSbCusto4 := ( ( SD1->D1_CUSTO3 * nPerc ) / 100 )
				nSbCusto5 := ( ( SD1->D1_CUSTO4 * nPerc ) / 100 )
				nSbCusto5 := ( ( SD1->D1_CUSTO5 * nPerc ) / 100 )

				//-- Rateio das parcelas
				aCustoVei[1] := Round( ( (SD1->D1_CUSTO  * nPerc) / 100 ) / Len(aParcelas), nDecCusto1 )
				aCustoVei[2] := Round( ( (SD1->D1_CUSTO2 * nPerc) / 100 ) / Len(aParcelas), nDecCusto2 )
				aCustoVei[3] := Round( ( (SD1->D1_CUSTO3 * nPerc) / 100 ) / Len(aParcelas), nDecCusto3 )
				aCustoVei[4] := Round( ( (SD1->D1_CUSTO4 * nPerc) / 100 ) / Len(aParcelas), nDecCusto4 )
				aCustoVei[5] := Round( ( (SD1->D1_CUSTO5 * nPerc) / 100 ) / Len(aParcelas), nDecCusto5 )
			Else
				//-- Armazena o Total do custo
				nSbCusto1 := ( ( SD3->D3_CUSTO1 * nPerc ) / 100 )
				nSbCusto2 := ( ( SD3->D3_CUSTO2 * nPerc ) / 100 )
				nSbCusto3 := ( ( SD3->D3_CUSTO3 * nPerc ) / 100 )
				nSbCusto4 := ( ( SD3->D3_CUSTO4 * nPerc ) / 100 )
				nSbCusto5 := ( ( SD3->D3_CUSTO5 * nPerc ) / 100 )

				//-- Rateio das parcelas
				aCustoVei[1] := Round( ( (SD3->D3_CUSTO1 * nPerc)  / 100 ) / Len(aParcelas), nDecCusto1 )
				aCustoVei[2] := Round( ( (SD3->D3_CUSTO2 * nPerc)  / 100 ) / Len(aParcelas), nDecCusto2 )
				aCustoVei[3] := Round( ( (SD3->D3_CUSTO3 * nPerc)  / 100 ) / Len(aParcelas), nDecCusto3 )
				aCustoVei[4] := Round( ( (SD3->D3_CUSTO4 * nPerc)  / 100 ) / Len(aParcelas), nDecCusto4 )
				aCustoVei[5] := Round( ( (SD3->D3_CUSTO5 * nPerc)  / 100 ) / Len(aParcelas), nDecCusto5 )              			
			EndIf	

			nTotValCob   := nValRat  //-- Valor Total do Item
			nValCob      := Round(nValRat / Len(aParcelas), nDecValCob ) //-- Valor de cada parcela

			//-- E' necessario controlar a diferenca de arrendondamento no calculo do Percentual dos itens informados na Tela de Rateio
			//-- ( a soma do percentual dos itens deve ser igual a 100%) e controlar a diferenca de arrendondamento no calculo do percentual
			//-- das parcelas de cada Item (a soma dos percentuais das parcelas tem que ser igual ao percentual Total do item)

			//-- Gravacao das parcelas
			For nCnt := 1 To Len(aParcelas)
				lBaixa := .F.
				//-- Atualiza os itens
				If Val(cNewItSDG) == 0
					cNewItSDG := aArraySDG[nW][2][nT][1] //-- Item
				Else
					cNewItSDG := Soma1(cNewItSDG)
					aArraySDG[nW][2][nT][1] := cNewItSDG
				EndIf

				//-- Para evitar diferenca de arrendamento, armazena a sobra do rateio na ultima parcela
				If nCnt == Len(aParcelas)
					aCustoVei[1]	:= nSbCusto1
					aCustoVei[2]	:= nSbCusto2
					aCustoVei[3]	:= nSbCusto3
					aCustoVei[4]	:= nSbCusto4
					aCustoVei[5]	:= nSbCusto5
					//-- Se for a Ultima Parcela do Ultimo Item
					If Len(aArraySDG[nW][2]) > 1 .And. nT == Len(aArraySDG[nW][2])                                                          	
						nPerc     := 100 - nTotPerc 	 					   				
					Else
						nTotPerc  += Round( nPerc, nDecPerc ) //-- Acumula os Percentuais calculados de todos os itens																			
					EndIf					
					aCustoVei[6]	:= nPerc			         		   					      		
					nValCob			:= nTotValCob
				Else
					nSbCusto1	-= aCustoVei[1]
					nSbCusto2	-= aCustoVei[2]
					nSbCusto3	-= aCustoVei[3]
					nSbCusto4	-= aCustoVei[4]
					nSbCusto5	-= aCustoVei[5]
					nPerc		-= aCustoVei[6]              										
					nTotValCob	-= nValCob
					nTotPerc	+= Round( aCustoVei[6], nDecPerc ) //-- Acumula os Percentuais calculados de todos os itens																			
				EndIf

				//-- Grava o movimento de custo
				GravaSDG(cAlias,cTpRateio,aArraySDG[nW][2][nT],aCustoVei,cDoc,cCodDesp,lMovim,ProxNum(),aParcelas[nCnt,1],nValCob)

				If cTpRateio == "V"
					//-- Caso a viagem seja informada baixa o movimento de custo
					If (!Empty(cFilOri) .And. !Empty(cViagem)) .Or.  (!Empty(cIdent) .And. lIdent .And. nModulo==39)
						lBaixa := .T.
					Else
						//-- Caso a veiculo seja proprio baixa o movimento de custo
						DA3->(DbSetOrder(1))
						If DA3->(MsSeek(xFilial("DA3")+cCodVei))
							If DA3->DA3_FROVEI == "1"
								lBaixa := .T.
							EndIf
						EndIf
					EndIf	
				Else
					lBaixa := .T.
				EndIf
				//-- Baixa o movimento de custo de transporte
				If lBaixa
					If lIdent .And. nModulo==39
						TMSA070Bx("1",SDG->DG_NUMSEQ,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,,,SDG->DG_VALCOB,,SDG->DG_IDENT)
					Else 
						TMSA070Bx("1",SDG->DG_NUMSEQ,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,,,SDG->DG_VALCOB,,"")
					EndIf
					If lCtbOnLine .And. lDtlanc .And. SDG->DG_STATUS == StrZero(3,Len(SDG->DG_STATUS)) .And. Empty(SDG->DG_DTLANC)
						nTotalLcto += DetProva(nHdlPrv,"901",cProg,cLote)
						AAdd(aRecSDGBai, SDG->(Recno()) )                 			
					EndIf													   								
				EndIf
				If lCtbOnLine .And. lDtlaemi
					nTotalLcto	+= DetProva(nHdlPrv,"903",cProg,cLote)
					AAdd(aRecSDGEmi, SDG->(Recno()) )                 																					 	
				EndIf	
			Next nCnt
		EndIf
	Next nT
Next nW		

For nCntFor := 1 To Len(aRecSDGBai)
	SDG->(MsGoTo(aRecSDGBai[nCntFor]))
	RecLock('SDG',.F.)
	SDG->DG_DTLANC  := dDataBase  //-- Data de lancamento contabil a partir da Baixa da Despesa
	MsUnLock()
Next

For nCntFor := 1 To Len(aRecSDGEmi)
	SDG->(MsGoTo(aRecSDGEmi[nCntFor]))
	RecLock('SDG',.F.)
	SDG->DG_DTLAEMI := dDataBase  //-- Data de lancamento contabil a partir da Inclusao da Despesa
	MsUnLock()
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A103WMSOk ³ Autor ³Fernando Joly Siquini   ³ Data ³15.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao ref. integracao com modulo SIGAWMS.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Acao executada pela funcao                          ³±±
±±³          ³         1 = Valida os campos referentes ao WMS na GetDados. ³±±
±±³          ³             Tambem pode ser utilizada no X3_VALID           ³±±
±±³          ³             dos campos D1_SERVIC, D1_ENDER ou D1_TPESTR.    ³±±
±±³          ³         2 = Valida a classif. da PreNota com Servico de WMS ³±±
±±³          ³             de conferencia pendente.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103WMSOk(cAcao,cAliasSD1)
Local aAreaAnt   := {}
Local aAreaDC5   := {}
Local aAreaSBE   := {}
Local aAreaDC8   := {}

Local cCod       := ''
Local cArmazem   := ''
Local cServico   := ''
Local cEndereco  := ''
Local cEstrutura := ''
Local cWMSVar    := ''
Local cSeekDC8   := ''
Local cString    := ''
Local cMsg1      := STR0124 //'O campo'
Local cMsg2      := STR0125 //'deve ser preenchido'
Local cMsg3      := STR0126 //'quando se utiliza a integracao com o modulo de WMS.'
Local cMsgItem   := ''
Local cMsgItem1  := STR0127 //'(Item numero'
Local cMsgItem2  := STR0128 //'do Documento)'

Local lRet       := .T.
Local nPosCod    := aScan(aHeader,{|x|Alltrim(x[2])=='D1_COD'})
Local nPosArmaz  := aScan(aHeader,{|x|Alltrim(x[2])=='D1_LOCAL'})
Local nPosServ   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_SERVIC'})
Local nPosEnd    := aScan(aHeader,{|x|Alltrim(x[2])=='D1_ENDER'})
Local nPosEst    := aScan(aHeader,{|x|Alltrim(x[2])=='D1_TPESTR'})
Local nTamD1It	 := TamSX3('D1_ITEM')[1]

Default cAcao     := "1"
Default cAliasSD1 := "SD1"

If Type("l103Class")=="U"
	l103Class := .F.
EndIf

Do Case 
	Case cAcao == "1"
		While (IntDL().And.Type('aHeader')=='A'.And.Type('aCols')=='A'.And.Type('n')=='N'.And.!aCols[n,Len(aCols[n])])
			aAreaAnt := GetArea()
			aAreaDC5 := DC5->(GetArea())
			aAreaSBE := SBE->(GetArea())
			aAreaDC8 := DC8->(GetArea())
			cWMSVar  := ReadVar()
			cMsgItem := If(n>1,' '+cMsgItem1+' '+StrZero(n,nTamD1It)+' '+cMsgItem2,'')
			If !Empty(cWMSVar) .And. Upper(cWMSVar)$'M->D1_SERVIC/M->D1_ENDER/M->D1_TPESTR' //-- Quando a funcao for chamada pelo SX3
				If Empty(&(cWMSVar))
					Aviso('A103WMSOK1', cMsg1+' '+AllTrim(RetTitle(SubStr(cWMSVar,At('>',cWMSVar)+1)))+' '+cMsg2+' '+cMsg3+cMsgItem, {'Ok'})
					lRet := .F.
					Exit
				EndIf
				cCod       := If(nPosCod>0,aCols[n,nPosCod],'')
				cArmazem   := If(nPosArmaz>0,aCols[n,nPosArmaz],'')
				cServico   := If('M->D1_SERVIC'$Upper(cWMSVar),&(cWMSVar),If(nPosServ>0,aCols[n,nPosServ],''))
				cEndereco  := If('M->D1_ENDER' $Upper(cWMSVar),&(cWMSVar),If(nPosEnd >0,aCols[n,nPosEnd], ''))
				cEstrutura := If('M->D1_TPESTR'$Upper(cWMSVar),&(cWMSVar),If(nPosEst >0,aCols[n,nPosEst], ''))
			ElseIf Empty(cWMSVar) //-- Quando a funcao for chamada do A103LinOK
				cString := If(nPosCod  ==0.Or.(nPosCod  >0.And.Empty(cCod      :=aCols[n,nPosCod])),AllTrim(RetTitle('D1_COD')),'')
				cString += If(nPosArmaz==0.Or.(nPosArmaz>0.And.Empty(cArmazem  :=aCols[n,nPosArmaz])),If(!Empty(cString),', ','')+AllTrim(RetTitle('D1_LOCAL')),'')
				cString += If(nPosServ ==0.Or.(nPosServ >0.And.Empty(cServico  :=aCols[n,nPosServ])),If(!Empty(cString),', ','')+AllTrim(RetTitle('D1_SERVIC')),'')
				cString += If(nPosEnd  ==0.Or.(nPosEnd  >0.And.Empty(cEndereco :=aCols[n,nPosEnd])),If(!Empty(cString),', ','')+AllTrim(RetTitle('D1_ENDER')),'')
				cString += If(nPosEst  ==0.Or.(nPosEst  >0.And.Empty(cEstrutura:=aCols[n,nPosEst])),If(!Empty(cString),', ','')+AllTrim(RetTitle('D1_TPESTR')),'')
				If !Empty(cServico) .And. !Empty(cString)
					If At(', ',cString) > 0
						cMsg1   := STR0129 //'Os campos'
						cMsg2   := STR0130 //'devem ser preenchidos'
						cString := Stuff(cString, RAt(', ', cString), (Len(STR0131)-1), STR0131) //' e '###' e '
					EndIf
					Aviso('A103WMSOK2', cMsg1+' '+cString+' '+cMsg2+' '+cMsg3+cMsgItem, {'Ok'})
					lRet := .F.
					Exit
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente a Prods que Controle Enderecamento e Servico atribuido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(Localiza(cCod).And.!Empty(cServico))
				Exit
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida o Servico digitado, que deve ser do tipo "Entrada"     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cServico)
				DbSelectArea('DC5')
				DbSetOrder(1)
				If !(MsSeek(xFilial('DC5')+cServico, .F.).And.DC5_TIPO=='1')
					Aviso('A103WMSOK3', STR0132+cMsgItem, {'Ok'}) //'Somente Servicos de WMS do tipo "Entrada" podem ser utilizados.'
					lRet := .F.
					Exit
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o Endereco digitado possui Estrura "BOX/DOCA"       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cArmazem) .And. !Empty(cEndereco)
				DbSelectArea('SBE')
				DbSetOrder(7)
				If !MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.)
					Aviso('A103WMSOK4', STR0133+AllTrim(cEndereco)+STR0134+cMsgItem, {'Ok'}) //'O Endereco '###' nao foi encontrado.'
					lRet := .F.
					Exit
				Else
					DbSelectArea('DC8')
					DbSetOrder(1)
					If !MsSeek(cSeekDC8:=xFilial('DC8')+SBE->BE_ESTFIS, .F.)
						Aviso('A103WMSOK5', STR0135+AllTrim(cEndereco)+STR0136+cMsgItem, {'Ok'}) //'A Estrutura Fisica do Endereco '###' nao foi encontrada.'
						lRet := .F.
						Exit
					Else
						Do While !Eof() .And. cSeekDC8==DC8_FILIAL+DC8_CODEST
							If DC8_LOCPAD==cArmazem .And. !(DC8_TPESTR=='5')
								Aviso('A103WMSOK6', STR0137+cMsgItem, {'Ok'}) //'Somente Enderecos pertencentes a Estruturas Fisicas do tipo BOX/DOCA podem ser utilizados.'
								lRet := .F.
								Exit
							EndIf
							dbSkip()
						EndDo
						If !lRet
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida a Estrutura digitada, que deve ser do tipo "BOX/DOCA"  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cArmazem) .And. !Empty(cEstrutura)
				DbSelectArea('DC8')
				DbSetOrder(1)
				If !MsSeek(cSeekDC8:=xFilial('DC8')+cEstrutura, .F.)
					Aviso('A103WMSOK7', STR0138+AllTrim(cEstrutura)+STR0136+cMsgItem, {'Ok'}) //'A Estrutura Fisica '###' nao foi encontrada.'
					lRet := .F.
					Exit
				Else
					Do While !Eof() .And. cSeekDC8==DC8_FILIAL+DC8_CODEST
						If DC8_LOCPAD==cArmazem .And. !(DC8_TPESTR=='5')
							Aviso('A103WMSOK8', STR0139+cMsgItem, {'Ok'}) //'Somente Estruturas Fisicas do tipo BOX/DOCA podem ser utilizadas.'
							lRet := .F.
							Exit
						EndIf
						dbSkip()
					EndDo
					If !lRet
						Exit
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida a amarracao entre o Endereco e a Estrutura digitados   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cArmazem) .And. !Empty(cEndereco) .And. !Empty(cEstrutura)
				DbSelectArea('SBE')
				DbSetOrder(7)
				If !MsSeek(xFilial('SBE')+cArmazem+cEndereco+cEstrutura, .F.)
					Aviso('A103WMSOK9', STR0140+AllTrim(cEndereco)+STR0141+AllTrim(cEstrutura)+'.'+cMsgItem, {'Ok'}) //'O Endereco '###' nao faz parte da Estrutura Fisica '
					lRet := .F.
					Exit
				EndIf
			EndIf
			RestArea(aAreaDC8)
			RestArea(aAreaSBE)
			RestArea(aAreaDC5)
			RestArea(aAreaAnt)
			Exit
		EndDo
	Case cAcao == "2"
		//-- Impede a classif. da PreNota com Servico de WMS conferencia pendente
		If	FindFunction("WmsChkDCF") .And. WmsChkDCF("SD1",,,(cAliasSD1)->D1_SERVIC,,,;
			SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,;
			(cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,/*D1_NUMSEQ*/,(cAliasSD1)->D1_ITEM)
			
			If	DCF->DCF_STSERV $ "1,2"
				lRet := .F.
			ElseIf	FindFunction("WmsChkDCF") .And. WmsChkSDB('3')
				lRet := .F.
			EndIf
			
			If	!lRet
				Aviso("SIGAWMS",STR0294,{'Ok'}) //"Atencao"###"Documento nao pode ser classificado porque possui servicos de Conferencia WMS pendentes."
			EndIf
		EndIf
	EndCase	
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A103Impri ³ Autor ³Alexandre Inacio Lemes³ Data ³10/06/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a chamada do relatorio padrao ou do usuario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpX1 := A103Impri( ExpC1, ExpN1, ExpN2 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Alias do arquivo                                  ³±±
±±³          ³ ExpN1 -> Recno do registro                                 ³±±
±±³          ³ ExpN2 -> Opcao do Menu                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpX1 -> Retorno do relatorio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A103Impri( cAlias, nRecno, nOpc )

Local aArea    := GetArea()
Local cPrinter := SuperGetMv("MV_PIMPNFE")
Local xRet     := .T.

If !Empty( cPrinter ) .And. Existblock( cPrinter )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a chamada do relatorio de usuario                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecBlock( cPrinter, .F., .F., { cAlias, nRecno, nOpc } )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a chamada do relatorio padrao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet := MATR170( cAlias, nRecno, nOpc ) 		
EndIf

RestArea( aArea )
Return( xRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A103Grava ³ Autor ³ Edson Maricate       ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao da Nota Fiscal de Entrada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103Grava(ExpC1,ExpN2,ExpA3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExpC1 : Controle de Gravacao  1,                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a103Grava(lDeleta,lCtbOnLine,lDigita,lAglutina,aHeadSE2,aColsSE2,aHeadSEV,aColsSEV,nRecSF1,aRecSD1,aRecSE2,aRecSF3,aRecSC5,aHeadSDE,aColsSDE,aRecSDE,lConFrete,lConImp,aRecSF1Ori,aRatVei,aRatFro,cFornIss,cLojaIss,lBloqueio,l103Class,cDirf,cCodRet,cModRetPIS,nIndexSE2,lEstNfClass,dVencIss,lTxNeg,aMultas,lRatLiq,lRatImp,aNFEletr,cDelSDE,aCodR,cRecIss,cAliasTPZ,aCtbInf,aNfeDanfe,lExcCmpAdt, aDigEnd,lCompAdt,aPedAdt,aRecGerSE2,aInfAdic)
Local aPedPV	:= {}
Local aCustoEnt := {}
Local aCustoSDE := {}
Local aSEZ      := {}
Local aContratos:= {}
Local aRecGerSE2:= {}
Local aAreaAnt  := {}
Local aDataGuia := {}
Local aDadosSF1 := {}
Local aDIfDec   := {0,.F.}
Local lGeraGuia := .T.
Local cArquivo  := ""
Local cLote     := ""
Local cAux      := ""
Local cBaseAtf	:= ""
Local cItemAtf	:= ""
Local nPosMemo  := ""	
Local cB1FRETISS:= ""
Local cA2FRETISS:= ""
Local cMes      := ""
Local cCIAP		:= ""
Local cQuery    := ""
Local cMT103APV := ""
Local cMdRtISS	:= "1"
Local cAliasSE1 := "SE1"
Local cLcPadICMS:= Substr(GetMv("MV_LPADICM"),1,3)					
Local cParcela  := SuperGetMV("MV_1DUP",.F.,"A")					

Local nHdlPrv   := 0
Local nTotalLcto:= 0
Local nV        := 0
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nW        := 0
Local nM        := 0
Local nOper     := 0
Local nTaxaNCC  := 0
Local cSql      := ""
Local nItRat    := 0
Local nTotalDev := 0
Local nRecSD1SDE:= 0
Local nValIcmAnt:= 0
Local nDedICM   := 0
Local nTamParc  := TamSx3("E2_PARCELA")[1]
Local nSTTrans	:= 0
Local nTamN1It	:= TAMSX3("N1_ITEM")[1]
Local nTamN1CBas:= TamSX3("N1_CBASE")[1]

Local lVer640	:= .F.
Local lVer641	:= .F.
Local lVer650	:= .F.
Local lVer651	:= .F.
Local lVer656	:= .F.
Local lVer660	:= .F.
Local lVer642	:= .F.
Local lVer655	:= .F.
Local lVer665	:= .F.
Local lVer955   := .F.
Local lVer950   := .F.
Local lVer116	:= (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6"  .Or.  VAL(GetVersao(.F.))  > 11)
Local lGeraPV   := .F.
Local lQuery    := .F.
Local lAchou    := .F.
Local lRet665   := .T.
Local lRetGrv   := .T.
Local lContinua := .T.
Local lGeraSD9  := .T.	// Valida se gera numero SD9
Local lIcmsTit  := .F.
Local lIcmsGuia := .F.
Local lCAT83    := .F.
Local lConfFor  := .F.
Local lConfBen  := .F.
Local l116Auto  := Iif(Type("l116Auto")== "L",l116Auto,.F.)
Local lF4Varatac:= SF4->(FieldPos("F4_VARATAC")) > 0
Local lD1Varatac:= SD1->(FieldPos("D1_VARATAC")) > 0
Local lRetiss	:= SF4->(FieldPos("F4_RETISS")) > 0
Local lDatori	:= SD1->(FieldPos("D1_DATORI")) > 0
Local lNumra	:= SF1->(FieldPos("F1_NUMRA")) > 0
Local lAtuPrev	:= FindFunction("A103AtuPrev")
Local lTrfSldP3 := FindFunction("TrfSldPoder3")
Local l103TrfSld:= FindFunction("A103TrfSld")
Local lEstCBED1 := FindFunction("EstCBED1")
Local lTxmMoenc := GetMV( "MV_TXMOENC" ) == "2"
Local lNgMnTes	:= SuperGetMV("MV_NGMNTES") == "S"
Local lNgMntCm	:= SuperGetMV("MV_NGMNTCM",.F.,"N") == "S"
Local lSigaGsp	:= SuperGetMV("MV_SIGAGSP",.F.,"0") == "1"
Local lCheckNf	:= SuperGetMv("MV_CHECKNF",.F.,.F.)
Local lTpComis	:= SuperGetMV("MV_TPCOMIS",.F.,"O")=="O"

Local nUsadoSDE    := Len(aHeadSDE)
Local lUsaGCT      := FindFunction( "A103GCDISP" ) .And. A103GCDisp()
Local lIntGH       := GETMV("MV_INTGH",.F.,.F.)  //Verifica Integracao com GH
Local lCompensa    := SuperGetMv("MV_CMPDEVV",.F.,.F.)
Local lFlagDev	   := SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)
Local lDISTMOV	   := SuperGetMV("MV_DISTMOV",.F.,.F.)

Local aRecSe1      := {}
Local aRecNCC      := {}
Local aStruSE1     := {}
Local aDetalheMail := {}
Local aCtbDia 	   := {}
Local aCIAP		   := {}                   
Local aMT103RTE    := {}
Local aDadosMail   := ARRAY(7) // Doc,Serie,Fornecedor,Loja,Nome,Opcao,Natureza

Local cGrupo       := SuperGetMv("MV_NFAPROV")
Local cTipoNf      := SuperGetMv("MV_TPNRNFS")
Local lIntACD	   := SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local nPParcela    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_PARCELA"})
Local nPVencto     := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"})
Local nPValor      := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VALOR"})
Local nPosCod      := aScan(aHeader ,{|x| Alltrim(x[2])=='D1_COD'})
Local nPosVUnit    := aScan(aHeader ,{|x| AllTrim(x[2])=="D1_VUNIT"}) 
Local nPosNfOri    := aScan(aHeader ,{|x| AllTrim(x[2])=="D1_NFORI"})
Local nPosSerOri   := aScan(aHeader ,{|x| AllTrim(x[2])=="D1_SERIORI"})
Local nPosItem	   := aScan(aHeader ,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nPosTes      := 0
Local nPosAC		:= 0	
Local nQTDDev      := 0
Local nXCDanfe     := 0
Local lConfere     := .F.

Local lImpRel	   := Existblock("QIEIMPRL")
Local lMT103RTC    := ExistBlock('MT103RTC')
Local lMT103RTE    := ExistBlock('MT103RTE')
Local lMsDOC       := ExistBlock('MT103MSD')
Local lExcMSDoc    := .T. 
                                   
Local cLocCQ       := GetMV('MV_CQ')
Local lATFDCBA     := GetMV("MV_ATFDCBA",.F.,"0") == "1" // "0"- Desmembra itens / "1" - Desmembra codigo base
Local aVlrAcAtf	   := {0,0,0,0,0}
Local oDlgDiaCtb
Local aGetDiaCtb
Local aGNRE        := {}
Local lChkDup	   := .F.
Local nCntAdt      := 0
Local aPedAdt      := {}
Local nPosAdt      := 0
Local lUsaACC	   := If(FindFunction("WebbConfig"),WebbConfig(),.F.)
Local cDocACC      := ""
Local cSoma1	   := ""
//Verifica se a funcionalidade Lista de Presente esta ativa e aplicada
Local lUsaLstPre   := SuperGetMV("MV_LJLSPRE",,.F.) // .And. IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local cNumero	   := ""
Local nPosDeIt	   := 0
                   
// Integração GFE
Local aFieldValue  := {}
Local aStruModel   := {}
Local lIntGFE	   := SuperGetMv("MV_INTGFE",,.F.)
Local cItBonif	   := ""   

Local cUpDate	   := ""
Local nrecno	   := SF1->(recno())
Local lPrjCni      := FindFunction("ValidaCNI") .And. ValidaCNI()
Local nF1docs	   := 0
Local aAreaSF1	   := {}
Local cAliasAnt    := "" 
Local cAno         := Right(Str(Year(dDataBase)),2)
Local cMvfsnciap   := SuperGetMV("MV_FSNCIAP")   
Local nRec         := 0
Local oMdl		   := Nil	
Local nPosGERAPV   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_GERAPV"})
Local nDespesa	:= 0
Local nDesconto	:= 0
Local nValParc	:= 0

Private aDupl      := {}
Private cNewItSDG  := ""


//-- Variaveis utilizadas pela funcao wmsexedcf
Private aLibSDB	 := {}
Private aWmsAviso:= {}

DEFAULT lCtbOnLine:= .F.
DEFAULT lDeleta   := .F.
DEFAULT aHeadSE2  := {}
DEFAULT aColsSE2  := {}
DEFAULT aHeadSEV  := {}
DEFAULT aColsSEV  := {}
DEFAULT aHeadSDE  := {}
DEFAULT aColsSDE  := {}
DEFAULT nRecSF1   := 0
DEFAULT aRecSD1   := {}
DEFAULT aRecSE2   := {}
DEFAULT aRecSF3   := {}
DEFAULT aRecSC5   := {}
DEFAULT aRecSDE   := {}
DEFAULT lConFrete := .F.
DEFAULT lConImp   := .F.
DEFAULT aRecSF1Ori:= {}
DEFAULT aRatVei   := {}
DEFAULT aRatFro   := {}
DEFAULT lBloqueio := .F.
DEFAULT l103Class := .F.
DEFAULT lTxNeg	  := .F.
DEFAULT lRatLiq   := .T.
DEFAULT lRatImp   := .F.
DEFAULT aNFEletr  := {}
DEFAULT lEstNfClass := .F. //-- Estorno de Nota Fiscal Classificada (MATA140)
DEFAULT aMultas     := {}
DEFAULT cDelSDE     := "1"
DEFAULT cAliasTPZ   := "TRBTPZ"//Alias de integracao com o SIGAMNT
DEFAULT aCtbInf     := {}
DEFAULT aNfeDanfe   := {}
DEFAULT aInfAdic := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Portaria CAT83   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If V103CAT83()
	lCAT83:= .T.
EndIf

If lDeleta
	oMdl := MaEnvEAI(,,5,"MATA103",,,.F.)
EndIf

If ExistBlock("A1031DUP")
	lChkDup:= ExecBlock("A1031DUP",.F.,.F.)
	If ValType(lChkDup) <> "L"
		lChkDup:= .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificação das parcelas de titulo financeiro quando utilizado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lChkDup") == "L" .And. lChkDup
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste tamanho do campo de parcelas e parametro MV_1DUP³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MaFisRet(,"NF_BASEDUP")>0 .And. ( Len(aColsSE2) > 1 ) .And. ( nTamParc <> Len(cParcela) )
		Help('',1,'A1031DUP')
		lContinua:= .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste numero de parcelas da condicao e o maximo suportado pelo tamanho do campo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lContinua .And. ( Len(aColsSE2) > ( IIF ( STRZERO(0,nTamParc) == cParcela .Or. Val(cParcela) > 0,35,25) ** nTamParc ) )
		Help('',1,'A103PARC',,STR0342+Alltrim(STR(( IIF ( STRZERO(0,nTamParc) == cParcela .Or.; //##Numero maximo de parcelas:
		Val(cParcela) > 0,35,25) ** nTamParc )) )+Chr(10)+Chr(13)+STR0343+Alltrim(STR(Len(aColsSE2))),5,1)//##Parcelas da condicao de pagamento
		lContinua:= .F.
	EndIf
	If !lContinua
		Final()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informa que houve importação de pedido no documento					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lImpPedido")<>"L"
	lImpPedido := .F.
Endif

//Verifica se o Produto é do tipo armamento.
If lDeleta .And. SB5->(FieldPos("B5_TPISERV")) > 0
	
	aAreaSB5 := SB5->(GetArea())
	
	For nX := 1 to Len(aRecSD1)
		DbSelectArea("SD1")
		MsGoto(aRecSD1[nx,1])
				 	
		If lContinua	
			
			DbSelectArea('SB5')
			SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA
			
			//Verifico se algum dos itens foram movimentados ou alguns deles não podem ser excluidos
			//de acordo com a vontade do usuario, se alguma das respostas for Negativa a nota não será Excluida
			If SB5->(DbSeek(xFilial('SB5')+SD1->D1_COD)) // Filial: 01, Código: 000001, Loja: 02
				If FindFunction("aT720Exc") .AND. SB5->B5_TPISERV=='2' 		
		       		lRetorno := aT720Exc(SD1->D1_DOC,SD1->D1_SERIE,.F.)
		       		If !lRetorno
		       			lContinua := lRetorno
		       		EndIf
		       	ElseIf FindFunction("aT710Exc") .AND. SB5->B5_TPISERV=='1' 		
		       		lRetorno := aT710Exc(SD1->D1_DOC,SD1->D1_SERIE,.F.)
		       		If !lRetorno
		       			lContinua := lRetorno
		       		EndIf
		      	ElseIf FindFunction("aT730Exc") .AND. SB5->B5_TPISERV=='3' 		
		       		lRetorno := aT730Exc(SD1->D1_DOC,SD1->D1_SERIE,.F.)
		       		If !lRetorno
		       			lContinua := lRetorno
		       		EndIf	
				EndIf 
			EndIf
		
		EndIf	
	
	Next nX
	
	RestArea(aAreaSB5)

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Template acionando ponto de entrada                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("MT100GRV")
	ExecTemplate("MT100GRV",.F.,.F.,{lDeleta})
EndIf			

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada anterior a gravacao do Documento de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("MT100GRV"))
	lRetGrv := ExecBlock("MT100GRV",.F.,.F.,{lDeleta})
	If ValType( lRetGrv ) == "L"
		lContinua := lRetGrv
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de para validacao dos codigos de retencao - DIRF       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. !lDeleta .And. ExistBlock("MT103DIRF")
	lRetGrv := ExecBlock("MT103DIRF",.F.,.F.,{acodR})
	If ValType( lRetGrv ) == "L"
		lContinua := lRetGrv
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estorna o PR0 quando o apontamento for gerado atraves do documento de entrada |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lDeleta .And. FindFunction("MTEstornPR")
	lContinua := MTEstornPR(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza das etiquetas (CB0) quando geradas no pedido de compra ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. If(FindFunction("UsaCB0"),UsaCB0("01"),.F.) 
	If FindFunction("CBAtuItNFE")
		CBAtuItNFE()
	ElseIf FindFunction("T_CBAtuItNFE")
		T_CBAtuItNFE()
	EndIf	
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha rotina automatica                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	l103Auto := If(Type("L103AUTO")=="U",.F.,l103Auto)
	l103Auto := If(Type("L116AUTO")=="U",l103Auto,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha contabilizacao                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCtbOnLine .Or. ( lDeleta .And. !Empty(SF1->F1_DTLANC))
		lCtbOnLine := .T.
		DbSelectArea("SX5")
		DbSetOrder(1)
		MsSeek(xFilial("SX5")+"09COM")
		cLote := IIf(Found(),Trim(X5DESCRI()),"COM ")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa um execblock                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If At(UPPER("EXEC"),X5Descri()) > 0
			cLote := &(X5Descri())
		EndIf
		nHdlPrv := HeadProva(cLote,"MATA103",Subs(cUsuario,7,6),@cArquivo)
		If nHdlPrv <= 0
			lCtbOnLine := .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica quais os lancamentos que estao habilitados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCtbOnLine
		lVer640	:= VerPadrao("640") // Entrada de NF Devolucao/Beneficiamento ( Cliente ) - Itens
		lVer650	:= VerPadrao("650") // Entrada de NF Normal ( Fornecedor ) - Itens
		lVer660	:= VerPadrao("660") // Entrada de NF Normal ( Fornecedor ) - Total
		lVer642	:= VerPadrao("642") // Entrada de NF Devol.Vendas - Total (SF1)
		lVer655	:= VerPadrao("655") // Exclusao de NF ( Fornecedor ) - Itens
		lVer665	:= VerPadrao("665") // Exclusao de NF ( Fornecedor ) - Total
		lVer955 := VerPadrao("955") // Do SIGAEIC - Importacao
		lVer950 := VerPadrao("950") // Do SIGAEIC - Importacao
		lVer641	:= VerPadrao("641")	// Entrada de NF Devolucao/Beneficiamento ( Cliente ) - Itens do Rateio
		lVer651	:= VerPadrao("651")	// Entrada de NF Normal ( Fornecedor ) - Itens do Rateio
		lVer656	:= VerPadrao("656")	// Exclusao de NF ( Fornecedor ) - Itens do Rateio
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona registros                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipo$"DB"
		DbSelectArea("SA1")
		DbSetOrder(1)
		MsSeek(xFilial("SA1")+cA100For+cLoja)
	Else
		DbSelectArea("SA2")
		DbSetOrder(1)
		MsSeek(xFilial("SA2")+cA100For+cLoja)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a operacao a ser realizada (Inclusao ou Exclusao )  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDeleta
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do cabecalho do documento de entrada             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SF1")
		DbSetOrder(1)
		If nRecSF1 <> 0
			MsGoto(nRecSF1)
			RecLock("SF1",.F.)
			nOper := 2
			If lBloqueio .And. mv_par17==2
				MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",SF1->F1_VALBRUT,,,SF1->F1_APROV,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,3)
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem numero do documento quando utilizar ³
			//³ numeracao pelo SD9 (MV_TPNRNFS = 3)       ³
			//³ Se a chamada for do SIGALOJA nao pode     ³
			//³ gerar outro numero no SD9.                ³		
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	
	
			If ( FUNNAME() $ "LOJA720|FATA720" .OR. FUNNAME() $ "LOJA701|FATA701" .or. IsInCallStack("LJ601DEVSD2") )
		    	If !Empty( cNFiscal )
					lGeraSD9	:= .F.
				Endif	
			Endif    
			
			If cTipoNf == "3" .AND. cFormul == "S" .AND. lGeraSD9 
				SX3->(DbSetOrder(1))
				If (SX3->(dbSeek("SD9")))
					// Se cNFiscal estiver vazio, busca numeração no SD9, senao, respeita o novo numero
					// digitado pelo usuario.
					cNFiscal := MA461NumNf(.T.,cSerie,cNFiscal)
				EndIf 			
			Endif
			RecLock("SF1",.T.)
			nOper := 1
			cDocACC := cNFiscal+cSerie+cA100For+cLoja
		EndIf
		
        If l103Auto                                           
			For nX := 1 To Len(aAutoCab)
				SF1->(FieldPut(FieldPos(aAutoCab[nX][1]),aAutoCab[nX][2]))
			Next nX                 
		EndIf
		
		//--Atualiza status da nota para 'em conferencia'
		If SA2->(FieldPos('A2_CONFFIS')) > 0 .And. SF1->(FieldPos("F1_STATCON")) > 0
			If (cTipo == "N" .And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. ((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "2") .Or. SA2->A2_CONFFIS == "2")
				lConfFor := .T.
			EndIf
			If (cTipo == "B" .And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "2")
				lConfBen := .T.
			Endif
		EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera conferencia havendo 1 TES com controle de estoque            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConfFor .Or. lConfBen
			lConfere := .F.
			nPosTes  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
			//--Verifica se o documento possui bloqueio de movimentos, pois se nao ha atualizacao de estoque nao deve haver conferencia fisica
			If MV_PAR17 == 2
				If nPosTes > 0
					SF4->(DbSelectArea("SF4"))
					SF4->(DbSetOrder(1))
					For nX := 1 to Len(aCols)
						If !aCols[nx][Len(aHeader)+1]
							If !Empty(aCols[nX][nPosTes])
								SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPosTes]))
								If SF4->F4_ESTOQUE == "S"
			                        lConfere := .T.
			                        Exit
		    	                EndIf
	    	                EndIf
	                    EndIf
					Next
				EndIf
			EndIf
			If lConfere
				SF1->F1_STATCON := "0"
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atendimento ao DECRETO 5.052, DE 08/01/2004 para o municipio de ARARAS. ³
		//³Mais especificamente o paragrafo unico do Art 2.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cA2FRETISS		:=	SA2->(FieldGet (FieldPos ("A2_FRETISS")))
		SF1->F1_FILIAL  := xFilial("SF1")
		SF1->F1_DOC     := cNFiscal
		SF1->F1_STATUS  := "A"
		SF1->F1_SERIE   := cSerie
		SF1->F1_FORNECE := cA100For
		SF1->F1_LOJA    := cLoja
		SF1->F1_COND    := cCondicao
		
		If SA2->(FieldPos("A2_NUMRA"))==0 .Or. Empty(SA2->A2_NUMRA)
			SF1->F1_DUPL    := IIf(MaFisRet(,"NF_BASEDUP")>0,cNFiscal,"")
		ElseIf lNumra
			SF1->F1_NUMRA   := SA2->A2_NUMRA
		EndIf
		
		SF1->F1_TXMOEDA := MaFisRet(,"NF_TXMOEDA")
		SF1->F1_EMISSAO := dDEmissao
		SF1->F1_EST     := IIF(cTipo$"DB",SA1->A1_EST,SA2->A2_EST)
		SF1->F1_TIPO    := cTipo

		If Empty( SF1->F1_RECBMTO )
			SF1->F1_RECBMTO := dDataBase
		Endif	

		SF1->F1_DTDIGIT := IIf( (GetMv("MV_DATAHOM",NIL,"1") == "1") , dDataBase, SF1->F1_RECBMTO )
		
		SF1->F1_FORMUL  := IIF(cFormul=="S","S"," ")
		SF1->F1_ESPECIE := cEspecie
		SF1->F1_PREFIXO := IIf(MaFisRet(,"NF_BASEDUP")>0,&(SuperGetMV("MV_2DUPREF")),"")
		SF1->F1_ORIGLAN := IIf(lConFrete,"F"+SubStr(SF1->F1_ORIGLAN,2),SF1->F1_ORIGLAN)
		SF1->F1_ORIGLAN := IIf(lConImp,SubStr(SF1->F1_ORIGLAN,1,1)+"D",SF1->F1_ORIGLAN)
	    
	    If SuperGetMv("MV_HORANFE",.F.,.F.) .And. Empty(SF1->F1_HORA)
			SF1->F1_HORA := Time()
	    EndIf  
	    
		If SF1->(FieldPos("F1_STATCON")) > 0 .And. SF1->F1_STATCON == "2" .And. SuperGetMv("MV_CLACFDV",.F.,.F.)
			SF1->F1_STATCON	:= "4" // Atualiza status da conferencia do ACD para "NF classificada com divergencia"
		EndIf  

		If lBloqueio .Or. (mv_par17==1 .And. cFormul=="S" .And. FunName()$"MATA103|FATA720")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para alterar o Grupo de Aprovacao 	 										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("MT103APV")
				cMT103APV := ExecBlock("MT103APV",.F.,.F.)
				If ValType(cMT103APV) == "C"
					cGrupo := cMT103APV
				EndIf
			EndIf
			
			cGrupo:= If(Empty(SF1->F1_APROV),cGrupo,SF1->F1_APROV)
			If !Empty(cGrupo) .And. mv_par17==2 .Or. (mv_par17==1 .And. cFormul=="N" .And. FunName()$"MATA103|FATA720")
				MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",0,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,1,SF1->F1_DOC+SF1->F1_SERIE)
				DbSelectArea("SF1")
				SF1->F1_STATUS := "B"
				SF1->F1_APROV  := cGrupo
			ElseIf mv_par17==1 .And. cFormul=="S" .And. FunName()$"MATA103|FATA720"
				DbSelectArea("SF1")
				SF1->F1_STATUS := "C"
			Else
				lBloqueio := .F.
			EndIf
		EndIf
		
		
		// Informações Adicionais
		If Len(aInfAdic) > 0
			SF1->F1_INCISS := aInfAdic[1]		
		EndIf		

		If SuperGetMV("MV_ISSXMUN",.F.,.F.) .And. SF1->(FieldPos("F1_ESTPRES")) > 0 .And. SF1->(FieldPos("F1_INCISS")) > 0 
			SF1->F1_INCISS := MaFisRet(,"NF_CODMUN")
			SF1->F1_ESTPRES:= MaFisRet(,"NF_UFPREISS")
		EndIf
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos da Nota Fiscal Eletronica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			If Len(aNFEletr) > 0
				SF1->F1_NFELETR	:= aNFEletr[01]
				SF1->F1_CODNFE	:= aNFEletr[02]
				SF1->F1_EMINFE	:= aNFEletr[03]
				SF1->F1_HORNFE 	:= aNFEletr[04]
				SF1->F1_CREDNFE	:= aNFEletr[05]
				SF1->F1_NUMRPS	:= aNFEletr[06]
				
				If SF1->(FieldPos("F1_MENNOTA")) > 0
					SF1->F1_MENNOTA	:= aNFEletr[07]
				EndIf
				If SF1->(FieldPos("F1_MENPAD")) > 0
					SF1->F1_MENPAD	:= aNFEletr[08]
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos DANFE-NF                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aNfeDanfe) > 0  
				If SF1->(FieldPos("F1_TRANSP"))>0
					SF1->F1_TRANSP := aNfeDanfe[01]
				EndIf
				If SF1->(FieldPos("F1_PLIQUI"))>0
					SF1->F1_PLIQUI := aNfeDanfe[02]
				EndIf   
				If SF1->(FieldPos("F1_PBRUTO"))>0
					SF1->F1_PBRUTO := aNfeDanfe[03]
				EndIf
				If SF1->(FieldPos("F1_ESPECI1"))>0
					SF1->F1_ESPECI1:= aNfeDanfe[04]
				EndIf
				If SF1->(FieldPos("F1_VOLUME1"))>0
					SF1->F1_VOLUME1:= aNfeDanfe[05]
				EndIf
				If SF1->(FieldPos("F1_ESPECI2"))>0
					SF1->F1_ESPECI2:= aNfeDanfe[06]
				EndIf
				If SF1->(FieldPos("F1_VOLUME2"))>0
					SF1->F1_VOLUME2:= aNfeDanfe[07]
				EndIf
				If SF1->(FieldPos("F1_ESPECI3"))>0
					SF1->F1_ESPECI3:= aNfeDanfe[08]
				EndIf
				If SF1->(FieldPos("F1_VOLUME3"))>0
					SF1->F1_VOLUME3:= aNfeDanfe[09]
				EndIf    
				If SF1->(FieldPos("F1_ESPECI4"))>0
					SF1->F1_ESPECI4:= aNfeDanfe[10]
				EndIf
				If SF1->(FieldPos("F1_VOLUME4"))>0
					SF1->F1_VOLUME4:= aNfeDanfe[11]
				EndIf
				If SF1->(FieldPos("F1_PLACA"))> 0
					SF1->F1_PLACA  := aNfeDanfe[12]
				EndIf 
				
				If SF1->(FieldPos("F1_CHVNFE"))> 0
					SF1->F1_CHVNFE := aNfeDanfe[13]
				EndIf
				
				If SF1->(FieldPos("F1_TPFRETE"))> 0              
					SF1->F1_TPFRETE := aNfeDanfe[14]
				EndIf
				
				If SF1->(FieldPos("F1_VALPEDG"))> 0
					SF1->F1_VALPEDG := aNfeDanfe[15]
				EndIf  
				
				If SF1->(FieldPos("F1_FORRET"))> 0
					SF1->F1_FORRET  := aNfeDanfe[16]
				EndIf 
				
				If SF1->(FieldPos("F1_LOJARET"))> 0
					SF1->F1_LOJARET  := aNfeDanfe[17]
				EndIf
			
				If SF1->(FieldPos("F1_TPCTE"))> 0
					SF1->F1_TPCTE  := aNfeDanfe[18]
				EndIf
				
				If SF1->(FieldPos("F1_FORENT"))> 0
					SF1->F1_FORENT  := aNfeDanfe[19]
				EndIf 
				
				If SF1->(FieldPos("F1_LOJAENT"))> 0
					SF1->F1_LOJAENT  := aNfeDanfe[20]
				EndIf
				
				If SF1->(FieldPos("F1_NUMAIDF"))> 0
					SF1->F1_NUMAIDF  := aNfeDanfe[21]
				EndIf 
				
				If SF1->(FieldPos("F1_ANOAIDF"))> 0
					SF1->F1_ANOAIDF  := aNfeDanfe[22]
				EndIf
			
				If SF1->(FieldPos("F1_MODAL"))> 0
					SF1->F1_MODAL  := aNfeDanfe[23]
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa a gravação do Array ADanfeComp retornado pelo ponto de  ³
			//³ entrada MT103DCF                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("MT103DCF") .And. Type("aDanfeComp") == "A"
				If Len(aDanfeComp)>0    
			    	For nXCDanfe:=1 to Len(aDanfeComp)
			    		If FieldPos(aDanfeComp[nXCDanfe][1]) > 0
			    			SF1->(FieldPut(FieldPos(aDanfeComp[nXCDanfe][1]),aDanfeComp[nXCDanfe][2]))
			    		EndIf
					Next nXCDanfe
					aDanfeComp := {}
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campo de controle para identificacao do titulo gerado referente a tributos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cTipo$"DB")
				If SF1->(FieldPos("F1_NUMTRIB")) > 0
					SF1->F1_NUMTRIB := "N"
				EndIf
			EndIf

		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variavel tipo private aCpoEsp para armazenar campos especificos  ³
		//³ do cabecalho (SF1) na rotina automatica                         ³
		//³                                                                 ³
		//³           Usada pelo sistema de importação - TSF                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aCpoEsp") == "A"
			For nX := 1 to len(aCpoEsp)
				If SF1->(FieldPos(aCpoEsp[nX][1])) > 0
					FieldPut(FieldPos(aCpoEsp[nX][1]),aCpoEsp[nX][2])
				EndIf
			Next nY
		Endif		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos F1_DESPESA e F1_DESCONT da nota de conhecimento de frete ³
		//³ passados atraves da rotina automatica (MATA116)                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l116Auto .And. Len(aAutoCab)>=22
        	nPosAC := aScan(aAutoCab,{|x| x[1] == "F1_DESPESA" })
            If nPosAC > 0
				SF1->F1_DESPESA := aAutoCab[nPosAC][2]
				MaFisAlt("NF_DESPESA",aAutoCab[nPosAC][2])
				nDespesa := aAutoCab[nPosAC][2]
		 	EndIf
		 	nPosAC := aScan(aAutoCab,{|x| x[1] == "F1_DESCONT" })
		    If nPosAC > 0
				SF1->F1_DESCONT := aAutoCab[nPosAC][2]
				MaFisAlt("NF_DESCONTO",aAutoCab[nPosAC][2])
				nDesconto := aAutoCab[nPosAC][2]
		 	EndIf
			msUnlock()
			nValParc := (nDespesa - nDesconto) / Len(aColsSE2)
			For nX := 1 To Len(aColsSE2)
				If (aColsSE2[nX][nPValor] > 0)
					aColsSE2[nX][nPValor] += nValParc	
				EndIf 
			Next nX
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento da gravacao do SF1 na Integridade Referencial            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		SF1->(FkCommit())	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados para envio de email do messenger                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aDadosMail[1]:=SF1->F1_DOC
		aDadosMail[2]:=SF1->F1_SERIE
		aDadosMail[3]:=SF1->F1_FORNECE
		aDadosMail[4]:=SF1->F1_LOJA
		aDadosMail[5]:=If(cTipo$"DB",SA1->A1_NOME,SA2->A2_NOME)
		aDadosMail[6]:=If(lDeleta,5,If(l103Class,4,3))
		aDadosMail[7]:=MaFisRet(,"NF_NATUREZA")	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao dos impostos calculados no cabecalho do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(MaFisWrite(2,"SF1",Nil))	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do array aDupl                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aColsSE2)
			aadd(aDupl,cSerie+"³"+cNFiscal+"³ "+aColsSE2[nX][nPParcela]+" ³"+DTOC(aColsSE2[nX][nPVencto])+"³ "+Transform(aColsSE2[nX][nPValor],PesqPict("SE2","E2_VALOR")))	
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao dos itens do documento de entrada                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aCols)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a regua de processamento                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aCols[nx][Len(aHeader)+1]
				DbSelectArea("SD1")
				If (nRec := aScan(aRecSD1,{|x| x[2] == acols[nx][nPosItem]})) > 0
					SD1->(MsGoto(aRecSD1[nRec][1]))
					RecLock("SD1",.F.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna os acumulados da Pre-Nota                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaAvalSD1(2)
				Else
					RecLock("SD1",.T.)
				EndIf
				lGeraPV := .F.
				For nY := 1 To Len(aHeader)
					If aHeader[nY][10] # "V"
						SD1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
					If AllTrim(aHeader[ny,2]) == "D1_GERAPV"
						lGeraPV := If(aCols[nX,nY]=="S",.T.,.F.)
					Endif	
				Next nY
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados padroes e dados fiscais.                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atendimento ao DECRETO 5.052, DE 08/01/2004 para o municipio de ARARAS. ³
				//³Mais especificamente o paragrafo unico do Art 2.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cB1FRETISS <> "2"
					cB1FRETISS	:=	SB1->B1_FRETISS
				EndIf
				SD1->D1_FILIAL  := xFilial("SD1")
				SD1->D1_FORNECE := cA100For
				SD1->D1_LOJA    := cLoja
				SD1->D1_DOC     := cNFiscal
				SD1->D1_SERIE   := cSerie
				SD1->D1_EMISSAO := dDEmissao
				SD1->D1_DTDIGIT := SF1->F1_DTDIGIT
				SD1->D1_TIPO    := cTipo
				SD1->D1_NUMSEQ  := ProxNum()
				SD1->D1_FORMUL  := IIF(cFormul=="S","S"," ")
				SD1->D1_ORIGLAN := IIf(lConFrete,"FR",SD1->D1_ORIGLAN)
				SD1->D1_ORIGLAN := IIf(lConImp,"DP",SD1->D1_ORIGLAN)
				SD1->D1_TIPODOC := SF1->F1_TIPODOC
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza as informacoes relativas aos impostos              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF4->(MaFisWrite(2,"SD1",nX))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona a TES conforme codigo usado no item					³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Desconta o Valor do ICMS DESONERADO do valor do Item D1_VUNIT³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_AGREG$"R"
					nDedICM += MaFisRet(nX,"IT_DEDICM")
					SD1->D1_TOTAL -= MaFisRet(nX,"IT_DEDICM")
					SD1->D1_VUNIT := A410Arred(SD1->D1_TOTAL/IIf(SD1->D1_QUANT==0,1,SD1->D1_QUANT),"D1_VUNIT")
    			EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma o ICMS Antecipado para geracao Titulo/Guia Recolhimento.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lF4Varatac
				    IF (SF4->F4_VARATAC$"12") .And. (SD1->D1_ICMSRET > 0)           
						nValIcmAnt += SD1->D1_ICMSRET
					Else
						nValIcmAnt += SD1->D1_VALANTI
					Endif
				ElseIf lD1Varatac
					nValIcmAnt += SD1->D1_VALANTI	 
				Endif
				
				If Alltrim(SF1->F1_ESPECIE)$"CTR/CTE/NFST" .And. SD1->D1_ICMSRET>0 .And. Alltrim(SF4->F4_CREDST)=="4"
					nSTTrans += SD1->D1_ICMSRET
				EndIf				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Analisa se o documento deve ser bloqueado                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lBloqueio .Or. (mv_par17==1 .And. cFormul=="S" .And. FunName()$"MATA103|FATA720")
					SD1->D1_TESACLA := SD1->D1_TES
					SD1->D1_TES := ""
					SD1->D1_RATEIO 	:= "2"
				EndIf
				//Caio.Santos - 11/01/13 - Req.72
				If lPrjCni
					RSTSCLOG("CLS",1,/*cUser*/)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava CAT83	                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
				If lCAT83
					GravaCAT83("SD1",{SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM},"I",1,SD1->D1_CODLAN)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona registros                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SB1")
				DbSetOrder(1)
				MsSeek(xFilial("SB1")+SD1->D1_COD)
	
				DbSelectArea("SF4")
				DbSetOrder(1)
				MsSeek(xFilial("SF4")+SD1->D1_TES)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retencao de ISS - Municipio de SBC/SP                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				If cPaisLoc != "PTG" .And. lRetiss
					If SF4->F4_RETISS == "N"
						cMdRtISS := "2"		//Retencao por Base
					Else
						cMdRtISS := "1"		//Retencao Normal					
					Endif
				EndIf	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizacao dos arquivos vinculados ao item do documento     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				SD1->D1_TP     := SB1->B1_TIPO
				SD1->D1_GRUPO  := SB1->B1_GRUPO	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calculo do custo de entrada                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCustoEnt := SB1->(A103Custo(nX,aHeadSE2,aColsSE2))
				SD1->D1_CUSTO	:= aCustoEnt[1]
				SD1->D1_CUSTO2	:= aCustoEnt[2]
				SD1->D1_CUSTO3	:= aCustoEnt[3]
				SD1->D1_CUSTO4	:= aCustoEnt[4]
				SD1->D1_CUSTO5	:= aCustoEnt[5]				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravação do campo D1_DATORI    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  nPosNfOri >0 .And. nPosSerOri>0 .And. lDatori
					If cTipo$"DB"     
						DbSelectArea("SF2")
						DbSetOrder(2)
						MsSeek(xFilial("SF2")+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nX][nPosNfOri] + aCols[nX][nPosSerOri])
						If !EOF()
						    SD1->D1_DATORI = SF2->F2_EMISSAO
						EndIf
					EndIf
				EndIf				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizacao dos acumulados do SD1                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaAvalSD1(If(SF1->F1_STATUS=="A",4,1),"SD1",lAmarra,lDataUcom,lPrecoDes,lAtuAmarra,aRecSF1Ori,@aContratos,MV_PAR15==2)
	
				If SF1->F1_STATUS$"AB" //Classificada: Sem bloqueio (NORMAL) / Com Bloqueio 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualizacao do rateio dos itens do documento de entrada                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCustoSDE := aClone(aCustoEnt)
					AFill(aCustoSDE,0)					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para visualizacao do rateio por centro de custo customizado       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					If lMT103RTC
						aMt103RTC := ExecBlock( "MT103RTC", .F., .F.,{aHeadSDE,aColsSDE})     
						If ( ValType(aMt103RTC) == 'A' )
							aColsSDE := aMt103RTC
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para visualizacao do rateio por centro de custo customizado       ³
					//³ com esse ponto pode-se manipular aHeadSDE,aColsSDE                                ³					
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ										     
					If lMT103RTE
						aMT103RTE := ExecBlock( "MT103RTE", .F., .F.,{aHeadSDE,aColsSDE,nX})     
						If ( ValType(aMT103RTE) == 'A' )
							aHeadSDE := aClone(aMT103RTE[1])
							aColsSDE := aClone(aMT103RTE[2])  
						EndIf
					EndIf					        
					
					If (nY	:= aScan(aColsSDE,{|x| x[1] == SD1->D1_ITEM})) > 0
						For nZ := 1 To Len(aColsSDE[nY][2])
							If !aColsSDE[nY][2][nZ][nUsadoSDE+1]                              				
								SDE->(DbSetOrder(1))
								lAchou:=SDE->(MsSeek(xFilial("SDE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM+GdFieldGet("DE_ITEM",nz,NIL,aHeadSDE,ACLONE(aColsSDE[NY,2]))))
								RecLock("SDE",!lAchou)
								For nW := 1 To nUsadoSDE
									If aHeadSDE[nW][10]<>"V" .And. aColsSDE[nY][2][nZ][nW]<>Nil
										SDE->(FieldPut(FieldPos(aHeadSDE[nW][2]),aColsSDE[nY][2][nZ][nW]))
									EndIf
								Next nW
								SDE->DE_FILIAL	:= xFilial("SDE")
								SDE->DE_DOC		:= SD1->D1_DOC
								SDE->DE_SERIE	:= SD1->D1_SERIE
								SDE->DE_FORNECE	:= SD1->D1_FORNECE
								SDE->DE_LOJA	:= SD1->D1_LOJA
								SDE->DE_ITEMNF	:= SD1->D1_ITEM
								For nW:= 1 To Len(aCustoEnt)
									SDE->(FieldPut(FieldPos("DE_CUSTO"+Alltrim(str(nW))),aCustoEnt[nW]*(SDE->DE_PERC/100)))
									aCustoSDE[nW] += SDE->(FieldGet(FieldPos("DE_CUSTO"+Alltrim(str(nW)))))
								Next nW
								If SF4->F4_DUPLIC=="S"
									nW := aScan(aSEZ,{|x| x[1] == SDE->DE_CC .And. x[2] == SDE->DE_ITEMCTA .And. x[3] == SDE->DE_CLVL })
									If nW == 0
										aadd(aSEZ,{SDE->DE_CC,SDE->DE_ITEMCTA,SDE->DE_CLVL,0,0})
										nW := Len(aSEZ)
									EndIf
									If nZ <> Len(aColsSDE[nY][2])
										aSEZ[nW][5] += SDE->DE_CUSTO1
									EndIf
								EndIf
	
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava os campos Memos Virtuais da Tabela SDE       				  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Type("aMemoSDE") == "A"
									For nM := 1 to Len(aMemoSDE)
										nPosMemo := aScan(aHeadSDE,{|x| AllTrim(x[2])== aMemoSDE[nM][2] })	
										If nPosMemo <> 0 .And. !Empty(aColsSDE[nY][2][nZ][nPosMemo])
											MSMM(aMemoSDE[nM][1],,,aColsSDE[nY][2][nZ][nPosMemo],1,,,"SDE",aMemoSDE[nM][1])
										EndIf
									Next nM
								EndIf
	
							EndIf
							If nZ == Len(aColsSDE[nY][2])
								For nW := 1 To Len(aCustoEnt)
									SDE->(FieldPut(FieldPos("DE_CUSTO"+Alltrim(str(nW))),FieldGet(FieldPos("DE_CUSTO"+Alltrim(str(nW))))+aCustoEnt[nW]-aCustoSDE[nW]))
								Next nW
								nW := aScan(aSEZ,{|x| x[1] == SDE->DE_CC .And. x[2] == SDE->DE_ITEMCTA .And. x[3] == SDE->DE_CLVL })
								If nW <> 0
									aSEZ[nW][5] += SDE->DE_CUSTO1
								EndIf
							EndIf				
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Ponto de Entrada para o Template                                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (ExistTemplate("SDE100I"))
								ExecTemplate("SDE100I",.F.,.F.,{lConFrete,lConImp,nOper,Len(aColsSDE[nY][2])})
							EndIf
							If (ExistBlock("SDE100I"))
								ExecBlock("SDE100I",.F.,.F.,{lConFrete,lConImp,nOper,Len(aColsSDE[nY][2])})
							Endif
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Gera Lancamento contabil 641- Devolucao / Beneficiamento ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
							If SF1->F1_STATUS == "A"
								If lCtbOnLine
									If cTipo $ "BD"
										If lVer641
											nTotalLcto	+= DetProva(nHdlPrv,"641","MATA103",cLote)
										EndIf
									Else
										If lVer651
											nTotalLcto	+= DetProva(nHdlPrv,"651","MATA103",cLote)
										EndIf
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Do Case
									Case cTipo == "B"
										PcoDetLan("000054","11","MATA103")
									Case cTipo == "D"
										PcoDetLan("000054","10","MATA103")
									OtherWise
										PcoDetLan("000054","09","MATA103")
								EndCase
							EndIf
						Next nZ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Elimina Registros na SDE que não existem mais no Acols							 |
						//|Esta situacao podera ocorrer quando a SDE ja estiver gravada seja através de      |
						//|Pre-Nota ou bloqueio de Tolerancia e em seguida no momento da classificacao o     |
						//|Array ser manipulado                                                              |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosDeIt := aScan(aHeadSDE,{|x| Alltrim(x[2])=='DE_ITEM'})
						DbSelectArea("SDE")
						DbSetOrder(1)
						MsSeek(xFilial("SDE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM)
						While !Eof() .And. DE_FILIAL == xFilial("SDE") .And. DE_DOC == SF1->F1_DOC .And. DE_SERIE == SF1->F1_SERIE .And.;
						              DE_FORNECE == SF1->F1_FORNECE .And. DE_LOJA == SF1->F1_LOJA .And. DE_ITEMNF == SD1->D1_ITEM
							nW:=0
							For nZ:=1 to Len(aColsSDE[nY][2])							              
								If aColsSDE[nY][2][nZ][nPosDeIt]==DE_ITEM
									nW:=nW+1 
									exit 
								EndIf
							Next nZ  
							If nW==0
								RecLock("SDE",.F.)
								dbDelete()
							EndIf
							DbSkip()
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tratamento da gravacao do SDE na Integridade Referencial            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SDE->(FkCommit())			
				EndIf
					
				If SF1->F1_STATUS == "A" //Classificada sem bloqueio (NORMAL)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Integracao com Gestao Hospitalar, valorizacao pela Ultima Compra    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lIntGH
						#IFDEF TOP
							cSql := " UPDATE "+ RetSqlName("GCB")
							cSql += "    SET GCB_PRCVEN =  " + Alltrim(Str(aCols[nX][nPosVUnit])) + ",GCB_PRCVUC = " + Alltrim(Str(aCols[nX][nPosVUnit])) 
							cSql += "  WHERE GCB_PRODUT = '" + aCols[nX][nPosCod] + "' AND GCB_ATIVO = '1' AND D_E_L_E_T_ <> '*' "
							cSql += "    AND GCB_VALUC = '1'  "
							
							If TcSqlExec(cSql)  < 0
								Hs_MsgInf(TcSqlError(),STR0119,STR0334)
								Return(nil)
							EndIf
							
							cSql := " UPDATE "+ RetSqlName("GCB")
							cSql += "    SET GCB_PRCVEN =  (GCB_PRCVUC + " + AllTrim(Str(aCols[nX][nPosVUnit])) + " ) / 2 ,GCB_PRCVUC = (GCB_PRCVUC + " + Alltrim(Str(aCols[nX][nPosVUnit])) + " ) / 2 "
							cSql += "  WHERE GCB_PRODUT = '" + Alltrim(aCols[nX][nPosCod]) + "' AND GCB_ATIVO = '1' AND D_E_L_E_T_ <> '*' "
							cSql += "    AND GCB_VALUC = '2'  "
							
							If TcSqlExec(cSql)  < 0
								Hs_MsgInf(TcSqlError(),STR0119,STR0334)
								Return(nil)
							EndIf
						#ENDIF
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetua a Gravacao do Ativo Imobilizado                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( SF4->F4_ATUATF=="S" )
						INCLUI := .T.
						ALTERA := .F.
						cBaseAtf := ""
						If ( SF4->F4_BENSATF == "1" .And. At(SF1->F1_TIPO,"CIP")==0 ) .And. SD1->D1_QUANT >= 1
							If (SD1->D1_TIPO == "C") .Or. (SD1->D1_TIPO == "I")
								nQtdD1 := GetQOri(xFilial("SD1"),SD1->D1_NFORI,SD1->D1_SERIORI,SD1->D1_ITEMORI,;
									SD1->D1_COD,SD1->D1_FORNECE,SD1->D1_LOJA)
							Else
								nQtdD1 := Int(SD1->D1_QUANT)
							Endif
							aDIfDec	:= {0,.F.}							
							aVlrAcAtf	:=	{0,0,0,0,0}
							//inicia cAux zerado, de acordo com o tamanho do campo item (Ex. '0000')
							cAux := Replicate("0", Len(SN1->N1_ITEM))

							For nV := 1 TO nQtdD1	  
								If !lATFDCBA .OR. ( lATFDCBA .AND. nV == 1 )
									cAux		:= Soma1( cAux,,, .F. )
									cItemAtf	:= PadL( cAux, Len( SN1->N1_ITEM ), "0" )
								EndIf   
								
								
							If SF4->F4_CIAP == "S"  
							    if cMvfsnciap == "2"
									cCIAP	:=  IIF (nV == 1,SD1->D1_CODCIAP, Soma1(substr(cSoma1,1,4))+ cAno )
							   		cSoma1 := cCIAP 
						   		else
							   		cCIAP	:=  IIF (nV == 1,SD1->D1_CODCIAP, Soma1(cSoma1))
							   		cSoma1 := cCIAP 
							   	Endif	
							   		
							Else
								cCIAP	:= ""
							EndIf

								//Se for o último então indica TRUE para gravar a diferença dos valores das casas decimais.
								IF nV == nQtdD1
									aDIfDec[2] := .T.
								EndIF
									
								a103GrvAtf(1,@cBaseAtf,cItemAtf,cCIAP,SD1->D1_VALICM+SD1->D1_ICMSCOM,,@aVlrAcAtf,,,@aDIfDec)
							Next nV
						Else
							cItemAtf := StrZero(1,Len(SN1->N1_ITEM))
							aVlrAcAtf:=	{0,0,0,0,0}
							a103GrvAtf(1,@cBaseAtf,cItemAtf,SD1->D1_CODCIAP,SD1->D1_VALICM+SD1->D1_ICMSCOM,,@aVlrAcAtf)
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Integracao TMS                                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If IntTMS() .And. (Len(aRatVei)>0  .Or. Len(aRatFro)>0)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿			
						//³Verifica se o Item da NF foi rateado por Veiculo/Viagem ou por Frota    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			                                           		
						nItRat := aScan(aRatVei,{|x| x[1] == SD1->D1_ITEM})
						If nItRat > 0
							A103GrvSDG('SD1',aRatVei,"V",SD1->D1_ITEM,lCtbOnLine,nHdlPrv,@nTotalLcto,cLote,"MATA103")
						Else
							nItRat := aScan(aRatFro,{|x| x[1] == SD1->D1_ITEM})
							If nItRat > 0
								A103GrvSDG('SD1',aRatFro,"F",SD1->D1_ITEM,lCtbOnLine,nHdlPrv,@nTotalLcto,cLote,"MATA103")				
							EndIf
						EndIf	
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de entrada apos a gravacao do SD1 e todas atualizacoes.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lNgMnTes .or. lNgMntCm
						NGSD1100I(cAliasTPZ)
					EndIf			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
					//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
					//³             MV_SIGAGSP - 0-Integra / 1-Nao                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
					If lSigaGsp
						GSPF160()
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de Entrada para o Template                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (ExistTemplate("SD1100I"))
						ExecTemplate("SD1100I",.F.,.F.,{lConFrete,lConImp,nOper})
					EndIf
					If nModulo == 72
						KEXF980(lConFrete,lConImp,nOper)
					Endif				
					If (ExistBlock("SD1100I"))
						ExecBlock("SD1100I",.F.,.F.,{lConFrete,lConImp,nOper})
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa a Baixa da NFE X Tabela de Quantidade Prevista  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lAtuPrev
						A103AtuPrev(lDeleta)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Contabilizacao do item do documento de entrada                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lCtbOnline
						If cTipo $ "BD" .And. lVer640
							nTotalLcto	+= DetProva(nHdlPrv,"640","MATA103",cLote)
						Else
							If lVer650
								nTotalLcto	+= DetProva(nHdlPrv,"650","MATA103",cLote)
							EndIf
						EndIf
					EndIf			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
						Case cTipo == "B"
							PcoDetLan("000054","07","MATA103")
						Case cTipo == "D"
							PcoDetLan("000054","05","MATA103")
						OtherWise
							PcoDetLan("000054","01","MATA103")
					EndCase
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava Pedido de Venda                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPosGERAPV > 0 .And. aCols[nX,nPosGERAPV]=="S"
					aadd(aPedPV,{SD1->D1_SERIORI,;
								 SD1->D1_NFORI ,;
								 SD1->D1_ITEMORI,;
								 SD1->D1_FORNECE+SD1->D1_LOJA,;
								 SD1->D1_QUANT ,;
								 SD1->(Recno()) })
				EndIf			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza saldo no Armazem de Poder de Terceiros                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTrfSldP3
					TrfSldPoder3(SD1->D1_TES,"SD1",SD1->D1_COD)
				EndIf	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza Consumo Medio SB3 somente para os casos abaixo:                ³
				//³- Devolucao de Vendas                                                   ³
				//³- Devolucao de produtos em Poder de Terceiros                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SD1->D1_TIPO == "D" .Or. SF4->F4_PODER3 == "D"
					aAreaAnt := GetArea()
					cMes := "B3_Q"+StrZero(Month(SD1->D1_DTDIGIT),2)
					SB3->(dbSeek(xFilial("SB3")+SD1->D1_COD))
					If SB3->(Eof())
						RecLock("SB3",.T.)
						Replace B3_FILIAL With xFilial("SB3"), B3_COD With SD1->D1_COD
					Else
						RecLock("SB3",.F.)
					EndIf
					Replace &(cMes) With &(cMes) - SD1->D1_QUANT
					MsUnlock()
					RestArea(aAreaAnt)
				EndIf	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza saldo no Armazem de Transito - MV_LOCTRAN	                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If l103Class .And. l103TrfSld
					A103TrfSld(lDeleta,1)
				EndIf	 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o Indicador F2_FLAGDEV quando devolução for Manual    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFlagDev .And. SD1->D1_TIPO$"DB" .And. !IsInCallStack("A103PROCDV")
				    //Verifica se todos os itens referente a nota indicada foram devolvidos
				    nQTDDEV :=0
					DbSelectArea("SD2")
					DbSetOrder(3)
					MsSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SF1->F1_FORNECE+SF1->F1_LOJA)
					While !Eof() .And. D2_FILIAL  == xFilial("SD2");
					              .And. D2_DOC     == SD1->D1_NFORI;
					              .And. D2_SERIE   == SD1->D1_SERIORI;
		   						  .And. D2_CLIENTE == SF1->F1_FORNECE;
		   						  .And. D2_LOJA    == SF1->F1_LOJA   
		   						  
		   				//Verifica se possui Tes de Devolução amarrada
		   				DbSelectArea("SF4")
						DbSetOrder(1)
						If MsSeek(xFilial("SF4")+SD2->D2_TES)
							If !Empty(SF4->F4_TESDV) 
							    MsSeek(xFilial("SF4")+SF4->F4_TESDV)
							    IF SF4->F4_PODER3<>"D"  //Quando for Tes Devolução, não considera pois poderá ter Controle de Terceiros
							        nQTDDEV:=nQTDDEV + SD2->D2_QUANT-SD2->D2_QTDEDEV
							    EndIf
							EndIf
						EndIf
						
						//Verifica se Possui Controle em Terceiros
						If SD2->D2_QTDEDEV == 0 .And. !Empty(SD2->D2_IDENTB6)
							DbSelectArea("SB6")
							DbSetOrder(3)
							If MsSeek(xFilial("SB6")+SD2->D2_IDENTB6+SD2->D2_COD+"R")
								nQTDDEV:=nQTDDEV+SB6->B6_SALDO
							EndIf
						EndIf
						
						DbSelectArea("SD2")
						dbSkip()
					EndDo       
					
					//Grava indicador de devolucao se a nota já estiver totalmente devolvida
					if nQTDDEV == 0 
						DbSelectArea("SF2")
						DbSetOrder(2)
						MsSeek(xFilial("SF2")+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_NFORI+SD1->D1_SERIORI)
						If !EOF()
							RecLock("SF2",.F.)
							SF2->F2_FLAGDEV := "1"
							MsUnLock()           
						EndIf
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dados para envio de email do messenger                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				AADD(aDetalheMail,{SD1->D1_ITEM,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_TOTAL})			
			Else
				If  nX <= Len(aRecSD1)
					SD1->(MsGoto(aRecSD1[nx,1]))
					RecLock("SD1",.F.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna os acumulados da Pre-Nota                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaAvalSD1(2)
					SD1->(dbDelete())
					SD1->(MsUnLock())
					//Caio.Santos - 11/01/13 - Req.72
					If lPrjCni
						RSTSCLOG("CLS",2,/*cUser*/)
					EndIf
				EndIf
			EndIf
			If lVer116 .AND. lDistMov .and. Localiza(SD1->D1_COD) .And. SF4->F4_ESTOQUE == 'S'
				aADD(aDigEnd,{;
								SD1->D1_ITEM,;
								SD1->D1_COD,;
								SD1->D1_LOCAL,;
								SD1->D1_LOTECTL,;
								SD1->D1_NUMLOTE,;
								SD1->D1_DTVALID,;
								SD1->D1_QUANT,;
								SD1->D1_NUMSEQ,;
								SD1->D1_DOC,;
								SD1->D1_SERIE,;
								SD1->D1_FORNECE,;
								SD1->D1_LOJA,;
								.F.;
							 })
			endif
			
		 	//Só irá incluir o Armamento quando a Nota ser do tipo NFE
		 	If Alltrim(SF1->F1_ESPECIE) == "NFE" .And. SB5->(FieldPos("B5_TPISERV")) > 0
		 		
		 		aAreaSB5 := SB5->(GetArea())
		 		
		 		DbSelectArea('SB5')
				SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA
				
				If SB5->(DbSeek(xFilial('SB5')+SD1->D1_COD)) // Filial: 01, Código: 000001, Loja: 02
	
			       	Do Case
			       		Case SB5->B5_TPISERV=='1' 
					       	If FindFunction("aT710Imp") 
					       		aT710Imp()
							EndIf
	       				Case SB5->B5_TPISERV=='2' 
			       			If FindFunction("aT720Imp") 
			       				aT720Imp()
							EndIf
						Case SB5->B5_TPISERV=='3' 
							If FindFunction("aT730Imp")
			       				aT730Imp()
							EndIf
					EndCase
					
				EndIf
				
				RestArea(aAreaSB5)
				
			EndIf
		
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acerta gravação da tabela SD1 após importação de pedido com itens diferentes da Pre Nota³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Class .And. (nX <= Len(aRecSD1) .Or. lImpPedido)  // Verifica se houve importação de pedidos ou itens deletados
			For nZ := 1 to Len(aRecSD1)
				If (nRec := aScan(aCols,{|x| x[nPosItem] == aRecSD1[nZ,2]})) = 0
					SD1->(MsGoto(aRecSD1[nZ,1]))
					RecLock("SD1",.F.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna os acumulados da Pre-Nota                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaAvalSD1(2)
					SD1->(dbDelete())
					SD1->(MsUnLock())
					//Caio.Santos - 11/01/13 - Req.72
					If lPrjCni
						RSTSCLOG("CLS",2,/*cUser*/)
					EndIf
				Endif
			Next
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os acumulados do Cabecalho do documento         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaAvalSF1(4)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera os titulos no Contas a Pagar SE2                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF1->F1_STATUS == "A" //Classificada sem bloqueio
			If !(cTipo$"DB")    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para definir se irá gerar lançamento futuro(SRK) ou título no financeiro (SE2)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("M103GERT"))
					ExecBlock("M103GERT",.F.,.F.,{1,aRecSE2,aHeadSE2,aColsSE2,aHeadSEV,aColsSEV,cFornIss,cLojaIss,cDirf,cCodRet,cModRetPIS,nIndexSE2,aSEZ,dVencIss,cMdRtISS,SF1->F1_TXMOEDA,lTxNeg,aRecGerSE2,cA2FRETISS,cB1FRETISS,aMultas,lRatLiq,lRatImp,aCodR,cRecIss})
				Else                    
					If !lNumra .Or. Empty(SF1->F1_NUMRA)
						A103AtuSE2(1,aRecSE2,aHeadSE2,aColsSE2,aHeadSEV,aColsSEV,cFornIss,cLojaIss,cDirf,cCodRet,cModRetPIS,nIndexSE2,aSEZ,dVencIss,cMdRtISS,SF1->F1_TXMOEDA,lTxNeg,aRecGerSE2,cA2FRETISS,cB1FRETISS,aMultas,lRatLiq,lRatImp,aCodR,cRecIss)
						#IFDEF TOP
							If cPaisLoc $ "BRA|MEX" .and. AliasInDic("FIE") .and. AliasInDic("FR3")
								If A120UsaAdi(cCondicao) .and. MaFisRet(,"NF_BASEDUP") > 0
									aAreaAnt := GetArea()
									For nCntAdt := 1 to Len(aCols)
										If !Empty(gdFieldGet("D1_PEDIDO",nCntAdt)) .and. !Empty(gdFieldGet("D1_ITEMPC",nCntAdt)) .and. !gdDeleted(nCntAdt)
											If AvalTes(gdFieldGet("D1_TES",nCntAdt),,"S")
												If Len(aPedAdt) > 0
													nPosAdt := aScan(aPedAdt,{|x| x[1] == gdFieldGet("D1_PEDIDO",nCntAdt)})
												Endif	
												If nPosAdt <= 0
								 	  		 		aAdd(aPedAdt,{gdFieldGet("D1_PEDIDO",nCntAdt),IIf(MaFisFound("IT",nCntAdt),MaFisRet(nCntAdt,"IT_TOTAL"),gdFieldGet("D1_QUANT",nCntAdt)*gdFieldGet("D1_VUNIT",nCntAdt))})
								   			 	Else
								   			 		aPedAdt[nPosAdt][2] += IIf(MaFisFound("IT",nCntAdt),MaFisRet(nCntAdt,"IT_TOTAL"),gdFieldGet("D1_QUANT",nCntAdt)*gdFieldGet("D1_VUNIT",nCntAdt))
								    			Endif	
											EndIf	
										Endif	
									Next nCntAdt
									lCompAdt := .T.
									RestArea(aAreaAnt)
								Endif
							Endif
						#ENDIF			
					Else
						A103AtuSRK(1,aHeadSE2,aColsSE2)
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Desconta o Valor do ICMS DESONERADO do valor do Item D2_PRCVEN         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nDedICM > 0
					SF1->F1_VALMERC -= nDedICM
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera Guia de Recolhimento ou Titulo ICMS no Contas a pagar quando houver no documento de  ³
				//³entrada ICMS por Antecipacao Tributaria.                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  nValIcmAnt > 0 .And. cPaisLoc=="BRA" .And. ( FunName()=="MATA103" .Or. (IsBlind() .And. IsInCallStack("MATA103")) )
					lIcmsTit  := Iif(mv_par18==Nil,.F.,(mv_par18==1))
					lIcmsGuia := Iif(mv_par19==Nil,.F.,(mv_par19==1))
					lGeraGuia := .T.
					If lIcmsTit .Or. lIcmsGuia
				       If ExistBlock("MT103GUIA")
				          lGeraGuia := ExecBlock("MT103GUIA",.F.,.F.,{"SF1","SA2",xFilial("SA2"),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_ESPECIE})				          
  					   Endif					
					   if lGeraGuia
						  aDataGuia := DetDatas(Month(SF1->F1_DTDIGIT),Year(SF1->F1_DTDIGIT),3,1)
						  //Armazenamento dos dados para ser utilizado na Guia de Recolhimento
						  aadd(aDadosSF1,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO,"1", SuperGetMV("MV_ESTADO") })
				    	  GravaTit(lIcmsTit,nValIcmAnt,"ICMS","IC",cLcPadICMS,aDataGuia[1]/*Dt inic*/,aDataGuia[2]/*Dt Fim*/,DataValida(aDataGuia[2]+1,.T.) /*Dt Venc*/,1,lIcmsGuia,Month(SF1->F1_DTDIGIT),Year(SF1->F1_DTDIGIT),0,nValIcmAnt,"MATA103",lCtbOnLine,cNFiscal,@aGNRE,,,,,,,,,,0,aDadosSF1)
					   Endif
					Endif
				Endif
               // Aproveitar o ponto de E
				If  nSTTrans > 0 .And. cPaisLoc=="BRA" .And. ( FunName()=="MATA103" .Or. (IsBlind() .And. IsInCallStack("MATA103")) )    
					lIcmsTit  := Iif(mv_par20==Nil,.F.,(mv_par20==1))
					lIcmsGuia := Iif(mv_par21==Nil,.F.,(mv_par21==1))
					lGeraGuia := .T.
					If lIcmsTit .Or. lIcmsGuia
				       	If ExistBlock("MT103GUIA")
				          	lGeraGuia := ExecBlock("MT103GUIA",.F.,.F.,{"SF1","SA2",xFilial("SA2"),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_ESPECIE})				          
  					   	Endif
  					   	If lGeraGuia
						  	aDataGuia := DetDatas(Month(SF1->F1_DTDIGIT),Year(SF1->F1_DTDIGIT),3,1)
						  	//Armazenamento dos dados para ser utilizado na Guia de Recolhimento
						  	aadd(aDadosSF1,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO,"1", SuperGetMV("MV_ESTADO") })
				    	  	GravaTit(lIcmsTit,nSTTrans,"ICMS","IC",cLcPadICMS,aDataGuia[1]/*Dt inic*/,aDataGuia[2]/*Dt Fim*/,DataValida(aDataGuia[2]+1,.T.) /*Dt Venc*/,1,lIcmsGuia,Month(SF1->F1_DTDIGIT),Year(SF1->F1_DTDIGIT),0,nSTTrans,"MATA103",lCtbOnLine,cNFiscal,@aGNRE,,,,,,,,,,0,aDadosSF1)
				    	EndIf
					Endif
				Endif

			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera titulo de NCC ao cliente                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTipo == "D" .And. MaFisRet(,"NF_BASEDUP") > 0
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considera a taxa informada para geracao da NCC           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTxmMoenc .Or. lMoedTit
					nTaxaNCC := MaFisRet(,"NF_TXMOEDA")
				Else
					nTaxaNCC := 0
				EndIf
	
				Aadd(aRecNCC,ADupCred(xmoeda(MaFisRet(,"NF_BASEDUP"),1,nMoedaCor,NIL,NIL,NIL,nTaxaNCC),"001",nMoedaCor,MaFisRet(,"NF_NATUREZA"),nTaxaNCC,aColsSE2[1][2]))
				If lCompensa  //Compensacao automatica do titulo
					DbSelectArea("SE1")
					DbSetOrder(2)
					#IFDEF TOP
						lQuery    := .T.
						aStruSE1  := SE1->(dbStruct())
						cAliasSE1 := "A103DEV"
						cQuery    := "SELECT SE1.*,SE1.R_E_C_N_O_ SE1RECNO "
						cQuery    += "  FROM "+RetSqlName("SE1")+" SE1 "
						cQuery    += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
						cQuery    += "   AND SE1.E1_CLIENTE = '"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SE1.E1_LOJA    = '"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SE1.E1_SERIE   = '"+SD1->D1_SERIORI+"'"
						cQuery    += "   AND SE1.E1_NUM     = '"+SD1->D1_NFORI+"'"
						cQuery    += "   AND SE1.E1_TIPO    = 'NF '"
						cQuery    += "   AND SE1.D_E_L_E_T_ = ' ' "
						cQuery    += " ORDER BY "+SqlOrder(SE1->(IndexKey()))
	
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
						
						For nX := 1 To Len(aStruSE1)
							If aStruSE1[nX][2]<>"C"
								TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
							EndIf
						Next nX
					#ELSE
						MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_SERIORI+SD1->D1_NFORI)
					#ENDIF
					While !Eof() .And. xFilial("SE1") == (cAliasSE1)->E1_FILIAL .And.;
							SF1->F1_FORNECE  == (cAliasSE1)->E1_CLIENTE .And.;
							SF1->F1_LOJA     == (cAliasSE1)->E1_LOJA    .And.;
							SD1->D1_SERIORI  == (cAliasSE1)->E1_SERIE   .And.;
							SD1->D1_NFORI    == (cAliasSE1)->E1_NUM     
							
						If (cAliasSE1)->E1_TIPO == "NF " .And. (cAliasSE1)->E1_SITUACA == "0"
							If !lCheckNf
								aadd(aRecSE1,If(lQuery,(cAliasSE1)->SE1RECNO,(cAliasSE1)->(RecNo())))
								If lMoedTit
									nTotalDev += (cAliasSE1)->E1_VLCRUZ
								Else
									nTotalDev += (cAliasSE1)->E1_VALOR
								EndIf
							Endif
						Endif
						DbSelectArea(cAliasSE1)
						dbSkip()
					EndDo
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna os valores da Comissao.              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTpComis
						Fa440CalcE("MATA100",,,"-")
					EndIf
	
					//Compensacao automatica do titulo, somente para devolucao total
					If Round(MaFisRet(,"NF_BASEDUP"),2) == Round(nTotalDev,2)
						MaIntBxCR(3,aRecSe1,,aRecNcc,,{lCtbOnLine,.F.,.F.,.F.,.F.,.T.})
					EndIf
					If lQuery
						DbSelectArea(cAliasSE1)
						dbCloseArea()
						DbSelectArea("SE1")
					EndIf
				Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estorna os valores da Comissao.              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTpComis
					Fa440CalcE("MATA100")
				EndIf
			EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
			//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
			//³             MV_SIGAGSP - 0-Integra / 1-Nao                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
			If lSigaGsp
				GSPF01I()
			EndIf
	
			If cFormul == "S" .And. cTipoNf == "2"
				While ( __lSX8 )
					ConfirmSX8()
				EndDo
			EndIf
			
			If lPrjCni
				If SF1->F1_TIPO == "N"
			
					cUpDate := " UPDATE "+RetSqlName("SC1")
					cUpDate += " SET C1_XDTFIM = '"+Dtos(dDataBase)+"',C1_XHRFIM = '"+SubStr(Time(),1,5)+"' "
					cUpDate += " FROM "
					cUpDate += RetSqlName("SD1")+" SD1 "
					cUpDate += " LEFT OUTER JOIN "
					cUpDate += RetSqlName("SC7")+" SC7 ON "
					cUpDate += " 	C7_FILIAL = '"+xFilial("SC7")+"' "
					cUpDate += " 	AND C7_NUM = D1_PEDIDO "
					cUpDate += " 	AND C7_ITEM = D1_ITEMPC "
					cUpDate += " 	AND SC7.D_E_L_E_T_ = ' ' "
					cUpDate += " LEFT OUTER JOIN "
					cUpDate += RetSqlName("SC1")+" SC1 ON "
					cUpDate += " 	C1_FILIAL = '"+xFilial("SC1")+"' "
					cUpDate += " 	AND C1_NUM = C7_NUMSC "
					cUpDate += " 	AND C1_ITEM = C7_ITEMSC "
					cUpDate += " 	AND SC1.D_E_L_E_T_ = ' ' "
					cUpDate += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
					cUpDate += " AND D1_DOC = '"+SF1->F1_DOC+"' "
					cUpDate += " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
					cUpDate += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
					cUpDate += " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
					cUpDate += " AND SD1.D_E_L_E_T_ = ' ' "
					
					TCSQLExec(cUpDate)
							
				EndIf
				
				//----------------------------------------------------------------------------	
				//FSW - 05/05/2011 - Rotina implementa a inclusao e alteracao das Divergencias        
				//----------------------------------------------------------------------------
				
			    IF  (Inclui .or. Altera)                                
			 
					if lPrjCni   
					    IF Type("_aDivPNF") <> "U" .and. Len( _aDivPNF ) > 0
				             CA040MAN(@_aDivPNF)
				        ENDIF
			        Else
				        IF  Len( _aDivPNF ) > 0              
				             CA040MAN(@_aDivPNF)
				        ENDIF
			        EndIf
			        
			    Endif         
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificacao da Lista de Presentes - Vendas CRM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lUsaLstPre .And. cTipo == "D"
				If !M103LstPre()
					//DisarmTransaction()
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pontos de Entrada 										   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistTemplate("SF1100I"))
				ExecTemplate("SF1100I",.f.,.f.)
			EndIf
			If (ExistBlock("SF1100I"))
				ExecBlock("SF1100I",.f.,.f.)
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Pedido de Venda qdo solicitado pelo campo D1_GERAPV  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			a103GrvPV(1,aPedPV)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o arquivo de Livros  (SF3)                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAtuSF3(1,"E",0,"SF1")
			If nRecSf1 == 0
				nRecSF1	:= SF1->(RecNo())
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contabilizacao do documento de entrada                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCtbOnLine
				If lVer660 .And. !(cTipo $"DB")
					DbSelectArea("SF1")
					MsGoto(nRecSF1)
					nTotalLcto	+= DetProva(nHdlPrv,"660","MATA103",cLote)
				EndIf
				If lVer642 .And. cTipo $"DB"
					DbSelectArea("SF1")
					MsGoto(nRecSF1)
					nTotalLcto	+= DetProva(nHdlPrv,"642","MATA103",cLote)
				EndIf
				If lVer950 .And. !Empty(SD1->D1_TEC)
					nTotalLcto +=DetProva(nHdlPrv,"950","MATA103",cLote)
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case SF1->F1_TIPO == "B"
					PcoDetLan("000054","20","MATA103")
				Case cTipo == "D"
					PcoDetLan("000054","19","MATA103")
				OtherWise
					PcoDetLan("000054","03","MATA103")
			EndCase
	
			If lUsaGCT 			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava as multas no historico do contrato                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				A103HistMul( 1, aMultas, cNFiscal, cSerie, cA100For, cLoja )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os movimentos de caucao do contratos - SIGAGCT  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				A103AtuCauc( 1, aContratos, aRecGerSE2, cA100For, cLoja, cNFiscal, cSerie, dDEmissao, SF1->F1_VALBRUT )
			EndIf
	
		ElseIf SF1->F1_STATUS == "C" //Nota com Bloqueio de Movimentaõutilizo esta função para gravação do CD2.
		
			If cFormul == "S" .And. cTipoNf == "2"
				While ( __lSX8 )
					ConfirmSX8()
				EndDo
			EndIf
			
			MaFisAtuSF3(1,"E",0,"SF1","","","",1) 
		EndIf
		//-- Integrado ao wms devera avaliar as regras para convocacao do servico e disponibilizar os 
		//-- registros do SDB para convocacao
		If	IntDL() .And. !Empty(aLibSDB)
			WmsExeDCF('2')
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada dos execblocks no termino do documento de entrada              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If (ExistTemplate("GQREENTR"))
			ExecTemplate("GQREENTR",.F.,.F.)
		EndIf
		If (ExistBlock("GQREENTR"))
			ExecBlock("GQREENTR",.F.,.F.)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³faz a chamada da funcao abaixo para gravar os apontamentos da OP ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FindFunction("MTIncluiPR") .And. Type("aOPBenef") == "A" .And. !Empty(aOPBenef)
			lContinua := MTIncluiPR(aOPBenef)
		EndIf
	Else
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for processo de adiantamento e o titulo estiver baixado   ³
		//³ exclui a compensacao                                         ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			If cPaisLoc $ "BRA|MEX"
				If Len(aRecSE2) > 0		
					If A120UsaAdi(SF1->F1_COND) .and. AliasInDic("FR3") .and. AliasInDic("FIE")
						SE2->(MsGoto(aRecSE2[1]))
						If SE2->(Recno()) = aRecSE2[1]
							If !Empty(SE2->E2_BAIXA) .and. SE2->E2_VALOR != SE2->E2_SALDO
								If !A103CCompAd(aRecSE2)
									lExcCmpAdt := .F. 
									Aviso(STR0119,STR0338 + CRLF + STR0339,{"Ok"}) //"Atenção"#"Não foi possível excluir a compensação associada ao título deste Documento de Entrada."#"Não será possível excluir o Documento de Entrada."
									DisarmTransaction()
	
									Return()
								Endif
							Endif
						Endif			
					Endif
				Endif	
			Endif
		#ENDIF			
		
		If lUsaGCT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem os contratos desta NF - SIGAGCT                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A103GetContr( aRecSD1, @aContratos )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os movimentos de caucao do contratos - SIGAGCT  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A103AtuCauc( 2, aContratos, aRecSE2, cA100For, cLoja, cNFiscal, cSerie )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga as multas do historico do contrato                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A103HistMul( 2, NIL, cNFiscal, cSerie, cA100For, cLoja )
	
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case SF1->F1_TIPO == "B"
				PcoDetLan("000054","20","MATA103",.T.)
			Case cTipo == "D"
				PcoDetLan("000054","19","MATA103",.T.)
			OtherWise
				PcoDetLan("000054","03","MATA103",.T.)
		EndCase
	                                                         
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada M103L665    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ExistBlock("M103L665"))   
            ExecBlock("M103L665",.F.,.F.,{cLote,nHdlPrv,cArquivo,lDigita,lAglutina})  
            aCtbInf	:= {}   // Zera o Array para que não ocorra duplicação após retornar do PE
  		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Lancamento contabil 665- Exclusao - Total       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVer665.And.!Empty(SF1->F1_DTLANC)
				nTotalLcto	+= DetProva(nHdlPrv,"665","MATA103",cLote)
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o Titulo a Pager de ICMS Antecipado SE2 se Houver e a Guia de Recolhimento ICMS SF6 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc=="BRA"
			If SF1->(FieldPos("F1_NUMTRIB")) > 0				
				If Empty(SF1->F1_NUMTRIB) 
					cNumero := SF1->F1_DOC
				Else
					cNumero := SF1->F1_NUMTRIB
				EndIf
			Else
				cNumero := SF1->F1_DOC
			EndIf							

			SE2->(DbsetOrder(1))
			If SE2->(dbSeek(xFilial("SE2") + "ICM" + cNumero))
				// Verifica se existe mais de uma nota com o mesmo numero. Se existir mantem SE2 para nao excluir o registro errado pois nao e possivel posicionar no titulo ICM por fornecedor, sendo necessario excluir manualmente.
				cAliasAnt := Alias()
				aAreaSF1 := SF1->(GetArea())
				SF1->(dbSetOrder(1))
				SF1->(dbSeek(xFilial("SF1")+cNFiscal+cSerie))
				While !SF1->(Eof()) .And. SF1->F1_DOC == cNFiscal .And. SF1->F1_SERIE == cSerie
					nF1docs++
					SF1->(dbSkip())
				End
				RestArea(aAreaSF1)
				DbSelectArea(cAliasAnt)

				If !(nF1docs > 1) .Or. SE2->E2_NUM != SF1->F1_DOC .Or. SE2->E2_NUM == SF1->F1_NUMTRIB
					Do While SE2->(!Eof()).And. SE2->E2_PREFIXO+SE2->E2_NUM == "ICM" + cNumero
						If ALLTRIM(SE2->E2_TIPO)== Alltrim(MVTAXA) .And. ALLTRIM(SE2->E2_ORIGEM) == "MATA103"
							RecLock("SE2")
							SE2->(dbDelete())
							SE2->(MsUnLock())
						Endif
						SE2->(DbSkip())
					EndDo
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a NFE gerou Guia ICMS Antecipado e Exclui o SF6  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF6->(DbsetOrder(3))
			If SF6->(MsSeek(xFilial("SF6")+"1"+SF1->F1_TIPO+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a NFE gerou Complemento da Guia                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ChkFile("CDC")
					DbSelectArea("CDC")
					CDC->(dbSetOrder(1))
					If CDC->(MsSeek(xFilial("CDC")+"S"+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF6->F6_NUMERO+SF6->F6_EST))
						RecLock("CDC")
						CDC->(dbDelete())
						CDC->(MsUnLock())
					Endif
				Endif
		
				RecLock("SF6")
				SF6->(dbDelete())
				SF6->(MsUnLock())
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga o pedido de vendas quando gerado pelo D1_GERAPV      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		a103GrvPV(2,,aRecSC5)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga o arquivo de Livros Fiscais (SF3)                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAtuSF3(2,"E",SF1->(RecNo()))    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga o Flag Devolução quando possuir Nota Saída relacionada |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		DbSelectArea("SD1")
        DbSetOrder(1)   
        DbClearFilter() 
        MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
     	While !Eof() .And. D1_FILIAL  == xFilial("SD1");
              .And. D1_DOC     == SF1->F1_DOC;
              .And. D1_SERIE   == SF1->F1_SERIE;
			  .And. D1_FORNECE == SF1->F1_FORNECE;
			  .And. D1_LOJA    == SF1->F1_LOJA   
        
			  DbSelectArea("SF2")
  			  DbSetOrder(2)  
		      DbClearFilter() 
		      MsSeek(xFilial("SF2")+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_NFORI+SD1->D1_SERIORI)
		      If !EOF()
		    	 RecLock("SF2",.F.)
		   		 SF2->F2_FLAGDEV := ""
				 MsUnLock()           
	  		  EndIf
	  		  DbSelectArea("SD1")
	  		  DbSkip()
	  	EndDo	  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera os titulos no Contas a Pagar SE2                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(SF1->F1_TIPO$"DB") 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada para definir se irá gerar lançamento futuro(SRK) ou título no financeiro (SE2)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistBlock("M103GERT"))
				ExecBlock("M103GERT",.F.,.F.,{2,aRecSE2})
			Else      
				If !lNumra .Or. Empty(SF1->F1_NUMRA)
					A103AtuSE2(2,aRecSE2)
				Else
					A103AtuSRK(2)
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os acumulados do Cabecalho do documento         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaAvalSF1(5)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna os titulos de NCC ao cliente                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A103EstNCC()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusao do rateio dos itens do documento de entrada                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aRecSDE)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona registro na tabela SDE                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SDE")
			SDE->(MsGoto(aRecSDE[nX]))	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona registro na tabela SD1                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecSD1SDE := ASCAN(aRecSD1,{|x| x[2] == SDE->DE_ITEMNF})
			If nRecSD1SDE > 0
				SD1->(MsGoto(aRecSD1[nRecSD1SDE,1]))
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui campos Memos Virtuais da tabela SYP vinculado aos memos SDE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("aMemoSDE") == "A" 
				If Len(aMemoSDE) > 0
					MSMM(&(aMemoSDE[1][1]),,,,2)
	            EndIf
			EndIf
	
			DbSelectArea("SF4")
			DbSetOrder(1)
			MsSeek(xFilial("SF4")+SD1->D1_TES)
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek(xFilial("SB1")+SD1->D1_COD)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case cTipo == "B"
					PcoDetLan("000054","11","MATA103",.T.)
				Case cTipo == "D"
					PcoDetLan("000054","10","MATA103",.T.)
				OtherWise
					PcoDetLan("000054","09","MATA103",.T.)
			EndCase
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Lancamento contabil 656- Exclusao - Itens de Rateio ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVer656.And.!Empty(SF1->F1_DTLANC)
				nTotalLcto	+= DetProva(nHdlPrv,"656","MATA103",cLote)
			EndIf
			If !lEstNfClass	.Or. (lEstNfClass .And. cDelSDE == "1")
				RecLock("SDE")
				dbDelete()
				MsUnLock()
			EndIf
		Next nX	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclusao da rotina para tratar a eliminacao do rateio por item na tabela de rateio.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AliasInDic("SCH")
			nSpace		:= TamSx3("CH_PEDIDO")[1]
			cPedido		:= SC7->C7_NUM+Space(nSpace-Len(SC7->C7_NUM))
	
			dbSelectArea("SDE")
			dbSetOrder(1) // DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
			If dbSeek(xFilial("SDE")+cPedido+cSerie+SC7->C7_FORNECE+SC7->C7_LOJA)
				While !Eof() .And. SDE->DE_FILIAL+SDE->DE_DOC	+SDE->DE_SERIE	+SDE->DE_FORNECE+SDE->DE_LOJA ==;
								   xFilial("SDE")+cPedido		+cSerie			+SC7->C7_FORNECE+SC7->C7_LOJA
					RecLock("SDE",.F.)
						dbDelete()					
	             	MsUnlock()
	
					dbSelectArea("SDE")
		    		dbSkip()	    		
				EndDo
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento da gravacao do SDE na Integridade Referencial            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SDE->(FkCommit())
	
		For nX := 1 to Len(aRecSD1)
			DbSelectArea("SD1")
			MsGoto(aRecSD1[nx,1])
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Lancamento contabil 955- Exclusao - Total EIC   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nX == 1 .And. lVer955 .And.!Empty(SD1->D1_TEC) .And. !Empty(SF1->F1_DTLANC)
				nTotalLcto +=DetProva(nHdlPrv,"955","MATA103",cLote)
			Endif
			DbSelectArea("SF4")
			DbSetOrder(1)
			MsSeek(xFilial("SF4")+SD1->D1_TES)
	
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek(xFilial("SB1")+SD1->D1_COD)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua o Estorno do Ativo Imobilizado                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			cAux := Replicate("0", nTamN1It)
			If ( SF4->F4_BENSATF == "1" ) .And. SD1->D1_QUANT >= 1
				For nV := 1 TO Int(SD1->D1_QUANT)   
					cAux		:= Soma1( cAux,,, .F. )
					cItemAtf	:= PadL( cAux, Len( SN1->N1_ITEM ), "0" )	
					cCodATVF := SubsTR(Trim(SD1->D1_CBASEAF),1,Len(Trim(SD1->D1_CBASEAF))-Len(cItemAtf))
					cCodATVF := cCodATVF+Space(nTamN1CBas-Len(cCodATVF))
					a103GrvAtf(2,cCodATVF+cItemAtf,,,,@aCIAP)
				Next nV
			Else
				a103GrvAtf(2,Trim(SD1->D1_CBASEAF),,,,@aCIAP)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case SD1->D1_TIPO == "B"
					PcoDetLan("000054","07","MATA103",.T.)
				Case SD1->D1_TIPO == "D"
					PcoDetLan("000054","05","MATA103",.T.)
				OtherWise
					PcoDetLan("000054","01","MATA103",.T.)
			EndCase
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Lancamento contabil 655- Exclusao - Itens       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVer655.And.!Empty(SF1->F1_DTLANC)
				nTotalLcto	+= DetProva(nHdlPrv,"655","MATA103",cLote)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorna o Servico do WMS (DCF)                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A103EstDCF()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Estorna o Movimento de Custo de Transporte - Integracao TMS             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IntTMS()  .And. (Len(aRatVei)>0 .Or. Len(aRatFro)>0)
				EstornaSDG("SD1",SD1->D1_NUMSEQ,lCtbOnLine,nHdlPrv,@nTotalLcto,cLote,"MATA103")
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza Consumo Medio SB3 somente para os casos abaixo:                ³
			//³- Devolucao de Vendas                                                   ³
			//³- Devolucao de produtos em Poder de Terceiros                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SD1->D1_TIPO == "D" .Or. SF4->F4_PODER3 == "D"
				aAreaAnt := GetArea()
				cMes := "B3_Q"+StrZero(Month(SD1->D1_DTDIGIT),2)
				SB3->(dbSeek(xFilial("SB3")+SD1->D1_COD))
				If SB3->(Eof())
					RecLock("SB3",.T.)
					Replace B3_FILIAL With xFilial("SB3"), B3_COD With SD1->D1_COD
				Else
					RecLock("SB3",.F.)
				EndIf
				Replace &(cMes) With &(cMes) + SD1->D1_QUANT
				MsUnlock()
				RestArea(aAreaAnt)
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Estorna o Saldo do Armazem de Transito - MV_LOCTRAN                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103TrfSld
				A103TrfSld(lDeleta,1)
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizacao dos acumulados do SD1                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaAvalSD1(If(SF1->F1_STATUS=="A",5,2),"SD1",lAmarra,lDataUcom,lPrecoDes, NIL, NIL, @aContratos,MV_PAR15==2,@aCIAP,lEstNfClass)
			MaAvalSD1(If(SF1->F1_STATUS=="A",6,3),"SD1",lAmarra,lDataUcom,lPrecoDes, , ,,MV_PAR15==2)
		   	
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui o item da CBE quando utilizado ACD                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEstCBED1 .And. lIntACD .And. lDeleta			
				EstCBED1(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD) 
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui o item da NF SD1                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lNgMnTes .or. lNgMntCm
				NGSD1100E()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
			//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
			//³             MV_SIGAGSP - 0-Integra / 1-Nao                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
			If lSigaGsp
				GSPF170()
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza saldo no armazem de poder de terceiros                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTrfSldP3
				TrfSldPoder3(SD1->D1_TES,"SD1",SD1->D1_COD,.T.)
			EndIf	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa a Baixa da NFE X Tabela de Quantidade Prevista  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAtuPrev
				A103AtuPrev(lDeleta)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
			//³ Pontos de Entrada 											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
			If (ExistTemplate("SD1100E"))
				ExecTemplate("SD1100E",.F.,.F.,{lConFrete,lConImp})
			Endif
			If (ExistBlock("SD1100E"))
				ExecBlock("SD1100E",.F.,.F.,{lConFrete,lConImp})
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dados para envio de email do messenger                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			AADD(aDetalheMail,{SD1->D1_ITEM,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_TOTAL})			
	
			If !lEstNfClass //-- Se nao for estorno de Nota Fiscal Classificada (MATA140)
				//Volta o Status da NFe.
				If AliasIndic("SDS")
					SDS->(DbSetOrder(1))
					If SDS->(MsSeek(xFilial("SDS")+cNFiscal+cSerie+cA100For+cLoja))
						SDS->(RecLock("SDS",.F.))
						Replace SDS->DS_STATUS 	With If(SDS->DS_TIPO == "N"," ",SDS->DS_TIPO)
						Replace SDS->DS_USERPRE With CriaVar("DS_USERPRE")
						Replace SDS->DS_DATAPRE With CriaVar("DS_DATAPRE")
						Replace SDS->DS_HORAPRE With CriaVar("DS_HORAPRE")
						SDS->(MsUnlock())
					EndIf
				EndIf
				RecLock("SD1",.F.,.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava CAT83 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCAT83
					GravaCAT83("SD1",{SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM},"E",1,SD1->D1_CODLAN)
				EndIf
				dbDelete()
				MsUnlock()
				//Caio.Santos - 11/01/13 - Req.72
				If lPrjCni
					RSTSCLOG("CLS",2,/*cUser*/)
				EndIf
			Else
				RecLock("SD1",.F.,.T.)		
				SD1->D1_TESACLA := CriaVar('D1_TESACLA',.F.)			
				SD1->D1_TES     := CriaVar('D1_TES',.F.)			
				SD1->D1_CODCIAP := CriaVar('D1_CODCIAP',.F.)			
				If lEstNFClass
					If cDelSDE == "1"
						SD1->D1_RATEIO := "2"		// volta para "Nao (2) para permitir a reclassificacao
					EndIf
				Else
					SD1->D1_RATEIO := "2"		// volta para "Nao (2) para permitir a reclassificacao			
				EndIf
				If lEstNfClass .AND. SD1->D1_LOCAL == cLocCQ   // Caso seja um estorno e o armazem seja 98 devo limpa-lo
					SD1->D1_LOCAL := ""
				EndIf			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava CAT83 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCAT83
					GravaCAT83("SD1",{SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM},"E",1,SD1->D1_CODLAN)
				EndIf
				MsUnLock()
				//Caio.Santos - 11/01/13 - Req.72
				If lPrjCni
					RSTSCLOG("CLS",3,/*cUser*/)
				EndIf
				If cPaisLoc=="BRA"
					MaAvalSD1(1,"SD1")
				ElseIf cPaisLoc == "ARG"
					If SD1->D1_TIPO_NF == "5"	//Factura Fob
						MaAvalSD1(1,"SD1")
					EndIf
				ElseIf cPaisLoc == "CHI"		
					If SD1->D1_TIPO_NF == "9"	//Factura Aduana
						MaAvalSD1(1,"SD1")
					EndIf			
				Endif			
			EndIf	
	
		Next nX
		
		cDocACC := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento da gravacao do SD1 na Integridade Referencial            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD1->(FkCommit())
	
		DbSelectArea("SF1")
		MsGoto(nRecSF1)
		RecLock("SF1",.F.,.T.)
		nOper := 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
		//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
		//³             MV_SIGAGSP - 0-Integra / 1-Nao                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
		If lSigaGsp
			GSPF01E()
		EndIf
		If !Empty(SF1->F1_APROV)
			MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",SF1->F1_VALBRUT,,,SF1->F1_APROV,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,3,SF1->F1_DOC+SF1->F1_SERIE)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o ACD - Faz ajuste do CB0 apos a exclusao da Nota - Somente Protheus 	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SuperGetMV("MV_INTACD",.F.,"0") == "1" .And. FindFunction("CBSF1100E")
			CBSF1100E()				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Template acionando ponto de entrada           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf ExistTemplate("SF1100E")
			ExecTemplate("SF1100E",.F.,.F.)
		EndIf
		
		If lPrjCni 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//  FSW - 05/05/2011 - Rotina Exclui Divergencias
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	       
	       	CA040EXC()
		EndIf  
		
		If (ExistBlock("SF1100E"))
			ExecBlock("SF1100E",.F.,.F.)
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados para envio de email do messenger                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		aDadosMail[1]:=SF1->F1_DOC
		aDadosMail[2]:=SF1->F1_SERIE
		aDadosMail[3]:=SF1->F1_FORNECE
		aDadosMail[4]:=SF1->F1_LOJA
		aDadosMail[5]:=If(cTipo$"DB",SA1->A1_NOME,SA2->A2_NOME)
		aDadosMail[6]:=If(lDeleta,5,If(l103Class,4,3))
		aDadosMail[7]:=MaFisRet(,"NF_NATUREZA")	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui a amarracao com os conhecimentos                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEstNfClass .And. lMsDOC     
			lExcMsDoc:=ExecBlock("MT103MSD",.F.,.F.,{})
			If ValType(lExcMsDoc)<>"L"   
				lExcMsDoc:=.F.
			EndIf
		EndIf 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a NF for de Devolucao originada do LOJA720 e a forma de devolucao for dinheiro, deve-se excluir o Movimento Bancario|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SF1->F1_TIPO == "D" .AND. SF1->F1_ORIGLAN == "LO"
			aAreaAnt := GetArea()
			DbSelectArea("SE5")
			DbSetOrder(2)	//E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DATA)+E5_CLIFOR+E5_LOJA
			If SE5->( MsSeek(SF1->F1_FILIAL + "LJ" + SF1->F1_PREFIXO + SF1->F1_DOC + PADR( SuperGetMV("MV_1DUP"), TamSX3("E5_PARCELA")[1]) + ;
					PADR( SuperGetMV("MV_SIMB1"), TamSX3("E5_TIPO")[1] )  + DtoS(SF1->F1_EMISSAO) + SF1->F1_FORNECE + SF1->F1_LOJA) )
				RecLock("SE5",.F.)
				SE5->( DbDelete() )
				SE5->( MsUnlock() )
			EndIf
			RestArea(aAreaAnt)
		EndIf
		
		If lExcMsDoc
			MsDocument( "SF1", SF1->( RecNo() ), 2, , 3 )
		EndIf	
	
		If !lEstNfClass //-- Se nao for estorno de Nota Fiscal Classificada (MATA140)
			MaAvalSF1(6)
			
			//A partir da versão 11.7
			//Irá eliminar o documento/Serie/Fornecedor/Loja da conferência embarque no WMS
			//dos documentos de origem de lançamento que sejam originados MATA103 F1_ORIGLAN == '  '
			If SF1->F1_ORIGLAN == '  ' .And. GetRpoRelease() >= 'R7' .And. IntDL()
				If FindFunction("WMSExcDoc")
					WmsExcDoc(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
				EndIf
			EndIf			
			
			RecLock("SF1")
			dbDelete()
			MsUnlock()
		Else
			RecLock("SF1",.F.,.T.)		
			SF1->F1_STATUS := CriaVar('F1_STATUS',.F.)
			SF1->F1_DTLANC := Ctod("")
			SF1->F1_VALIRF := 0
			MsUnLock()
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento da gravacao do SF1 na Integridade Referencial            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF1->(FkCommit())
	
	EndIf
	
	If lUsaACC .And. !Empty(cDocACC)
		MsgRun(STR0345,STR0346,{|| Webb582(cDocACC,lDeleta)})//"Aguarde, comunicando recebimento ao portal... ## Portal ACC
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de e-mails para o evento 030       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MEnviaMail("030",{aDadosMail[1],aDadosMail[2],aDadosMail[3],aDadosMail[4],aDadosMail[5],aDadosMail[6],aDetalheMail,aDadosMail[7]})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao dos dados contabeis                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCtbOnLine .And. nTotalLcto > 0
		RodaProva(nHdlPrv,nTotalLcto)
		If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
			aCtbDia := {{"SF1",SF1->(RECNO()),cCodDiario,"F1_NODIA","F1_DIACTB"}}
		Else
			aCtbDia := {}
		EndIF    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena array com as informacoes para a contabilizacao online         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aCtbInf,cArquivo)
		aAdd(aCtbInf,nHdlPrv)
		aAdd(aCtbInf,cLote)
		aAdd(aCtbInf,lDigita)
		aAdd(aCtbInf,lAglutina)
		aAdd(aCtbInf,aCtbDia)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ So passar este campo quando nao for estorno de classificacao da NFE    ³
		//³ caso contrario a CA100Incl colocara novamente a data no campo F1_DTLANC³
		//³ impedindo que na nova classificacao a contabilizacao OFF-LINE gere um  ³
		//³ novo lancamento.                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lEstNfClass //-- Se nao for estorno de Nota Fiscal Classificada (MATA140)
			aAdd(aCtbInf,{{"F1_DTLANC",dDataBase,"SF1",SF1->(Recno()),0,0,0}})
        Else
			aAdd(aCtbInf,{{,,,0,0,0,0}})
		EndIf

	EndIf
	
	For nX := 1 to Len(aRecSD1)
		DbSelectArea("SD1")
		MsGoto(aRecSD1[nx,1])
			
		//Verifica se o Produto é do tipo armamento.
		If SB5->(FieldPos("B5_TPISERV")) > 0
					
			aAreaSB5 := SB5->(GetArea())
						 	
			DbSelectArea('SB5')
			SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA
			
			//Realiza a exclusão dos armamentos		
			If SB5->(DbSeek(xFilial('SB5')+SD1->D1_COD)) // Filial: 01, Código: 000001, Loja: 02
				If FindFunction("aT720Exc") .AND. SB5->B5_TPISERV=='2' 		
					lRetorno := aT720Exc(SD1->D1_DOC,SD1->D1_SERIE,.T.)
	
				 ElseIf FindFunction("aT710Exc") .AND. SB5->B5_TPISERV=='1' 		
				 	lRetorno := aT710Exc(SD1->D1_DOC,SD1->D1_SERIE,.T.)
	
				 ElseIf FindFunction("aT730Exc") .AND. SB5->B5_TPISERV=='3' 		
				 	lRetorno := aT730Exc(SD1->D1_DOC,SD1->D1_SERIE,.T.)
	
EndIf
			EndIf
				
			RestArea(aAreaSB5)
				
		EndIf
	Next nX
	
EndIf
//Ponto de Entrada Utilizado na integracao com o QIE                        
If lImpRel
	ExecBlock("QIEIMPRL",.F.,.F.,{nOper})
Endif
//Ponto de Entrada para Consulta de NF
If !lDeleta
   If (ExistBlock("CONAUXNF"))
      ExecBlock("CONAUXNF",.F.,.F.,{"SF1"})
   Endif   
Endif
	//-- aStruModel
	//-- [1] - Alias
	//-- [2] - Model da Estrutura
	//-- [3] - bSeek
	//-- [4] - nOrdem
	//-- [5] - bWhile    
	//-- [6] - aFieldValue
	//-- [6,1] Nome do Campo
	//-- [6,2] Bloco de execucao para o valor 
	//--       a ser atribuido ao campo
	
	If lIntGFE

	   aFieldValue := { { "F1_CDTPDC", { || AllTrim(Tabela('MQ',AllTrim(SF1->F1_TIPO)+"E",.F.)) } } }              
		
		Aadd(aStruModel, { "SA2", "REMETENTE_SA2"   , {|| xFilial("SA2") + SF1->(F1_FORNECE+F1_LOJA) }, 1, NIL, NIL } )
		Aadd(aStruModel, { "SA1", "REMETENTE_SA1"   , {|| xFilial("SA1") + SF1->(F1_FORNECE+F1_LOJA) }, 1, NIL, NIL } )
		Aadd(aStruModel, { "SA2", "REMETENTE_SM0"   , {|| xFilial("SA2") + SM0->M0_CGC }, 1, NIL, NIL } )
		Aadd(aStruModel, { "SA1", "DESTINATARIO_SA1", {|| xFilial("SA1") + SM0->M0_CGC }, 3, NIL, NIL } )
	EndIf   	              
	
	Aadd(aStruModel, { "SF1", "MATA103_SF1"     , NIL, NIL, NIL, aFieldValue } )
	Aadd(aStruModel, { "SD1", "MATA103_SD1"     , {|| SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) }, 1, {|| SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) }, NIL } )
	
	If FindFunction("MaEnvEAI") .and. !( FWIsInCallStack( "FWFORMEAI" ) )
 		If lIntGFE
			MaEnvEAI(,,Iif(!lDeleta,4,5),"MATA103",aStruModel)
		Else
			MaEnvEAI(,,Iif(!lDeleta,3,5),"MATA103",aStruModel,,,If(lDeleta,.F.,.T.),If(lDeleta .And. oMdl <> Nil,oMdl,Nil))
		EndIf
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103Custo³ Autor ³ Edson Maricate         ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o custo de entrada do Item                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Custo(nItem)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Item da NF                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103 , A103Grava()                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103Custo(nItem,aHeadSE2,aColsSE2)

Local aCusto     := {}
Local aRet       := {}
Local nPos       := 0
Local nValIV     := 0
Local nX         := 0
Local nZ         := 0
Local nFatorPS2  := 1
Local nFatorCF2  := 1
Local nValPS2    := 0
Local nValCF2    := 0
Local lCustPad   := .T.
Local uRet       := Nil
Local lBonif     := !Empty( SF4->( FieldPos( "F4_BONIF"   ) ) )
Local lCredICM   := SuperGetMV("MV_CREDICM", .F., .F.) 	// Parametro que indica o abatimento do credito de ICMS no custo do item, ao utilizar o campo F4_AGREG = "I"
Local lValCMaj   := !Empty(MaFisScan("IT_VALCMAJ",.F.))	// Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
Local lValPMaj   := !Empty(MaFisScan("IT_VALPMAJ",.F.))	// Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o percentual para credito do PIS / COFINS   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( SF4->F4_BCRDPIS )
	nFatorPS2 := SF4->F4_BCRDPIS / 100
EndIf 	

If !Empty( SF4->F4_BCRDCOF )
	nFatorCF2 := SF4->F4_BCRDCOF / 100
EndIf 	

nValPS2 := MaFisRet(nItem,"IT_VALPS2") * nFatorPS2
nValCF2 := MaFisRet(nItem,"IT_VALCF2") * nFatorCF2

l103Auto := Type("l103Auto") <> "U" .And. l103Auto

If l103Auto .And. (nPos:= aScan(aAutoItens[nItem],{|x|Trim(x[1])== "D1_CUSTO" })) > 0
	aADD(aCusto,{	aAutoItens[nItem,nPos,2],;
					0.00,;
					0.00,;
					SF4->F4_CREDIPI,;
					SF4->F4_CREDICM,;
					MaFisRet(nItem,"IT_NFORI"),;
					MaFisRet(nItem,"IT_SERORI"),;
					SD1->D1_COD,;
					SD1->D1_LOCAL,;
					SD1->D1_QUANT,;
					If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
					SF4->F4_CREDST,;
					MaFisRet(nItem,"IT_VALSOL"),;
					MaRetIncIV(nItem,"1"),;
					SF4->F4_PISCOF,;
					SF4->F4_PISCRED,;
					nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
					nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
					IIf(SF4->(FieldPos("F4_ESTCRED")) > 0 .And. SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0),;
					IIf(SD1->(FieldPos("D1_CRPRSIM")) >0, MaFisRet(nItem,"IT_CRPRSIM"), 0 ),;   
					MaFisRet(nItem,"IT_VALANTI");
				})
Else
	nValIV	:=	MaRetIncIV(nItem,"2")

	If SD1->D1_COD == Left(SuperGetMV("MV_PRODIMP"), Len(SD1->D1_COD))
		aADD(aCusto,{	MaFisRet(nItem,"IT_TOTAL")-IIF(cTipo == "P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+MaFisRet(nItem,"IT_VALICM")+If((SF4->F4_CIAP=="S".And.SF4->F4_CREDICM=="S").Or.((SF4->(FieldPos("F4_ANTICMS")) > 0).And.SF4->F4_ANTICMS=="1"),0,MaFisRet(nItem,"IT_VALCMP"))-If(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0)-nValIV+IF(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)+IF(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0,MaFisRet(nItem,"IT_DEDICM"),0)-MaFisRet(nItem,"IT_CRPRESC")-MaFisRet(nItem,"IT_CRPREPR")+MaFisRet(nItem,"IT_VLINCMG"),;
						MaFisRet(nItem,"IT_VALIPI"),;
						MaFisRet(nItem,"IT_VALICM"),;
						SF4->F4_CREDIPI,;
						SF4->F4_CREDICM,;
						MaFisRet(nItem,"IT_NFORI"),;
						MaFisRet(nItem,"IT_SERORI"),;
						SD1->D1_COD,;
						SD1->D1_LOCAL,;
						SD1->D1_QUANT,;
						If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0) ,;
						SF4->F4_CREDST,;
						MaFisRet(nItem,"IT_VALSOL"),;
						MaRetIncIV(nItem,"1"),;
						SF4->F4_PISCOF,;
						SF4->F4_PISCRED,;
						nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
						nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
						IIf(SF4->(FieldPos("F4_ESTCRED")) > 0 .And. SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0),;
						IIf(SD1->(FieldPos("D1_CRPRSIM")) >0, MaFisRet(nItem,"IT_CRPRSIM"), 0 ),;
						MaFisRet(nItem,"IT_VALANTI");
					})
	Else
		aADD(aCusto,{	MaFisRet(nItem,"IT_TOTAL")-IIF(cTipo == "P".Or.SF4->F4_IPI=="R",0,MaFisRet(nItem,"IT_VALIPI"))+If((SF4->F4_CIAP=="S".And. SF4->F4_CREDICM=="S").Or.((SF4->(FieldPos("F4_ANTICMS")) > 0).And.SF4->F4_ANTICMS=="1"),0,MaFisRet(nItem,"IT_VALCMP"))-If(SF4->F4_INCSOL<>"N",MaFisRet(nItem,"IT_VALSOL"),0)-nValIV+IF(SF4->F4_ICM=="S" .And. SF4->F4_AGREG$'A|C',MaFisRet(nItem,"IT_VALICM"),0)+IF(SF4->F4_AGREG=='D' .And. SF4->F4_BASEICM == 0,MaFisRet(nItem,"IT_DEDICM"),0)-MaFisRet(nItem,"IT_CRPRESC")-MaFisRet(nItem,"IT_CRPREPR")+MaFisRet(nItem,"IT_VLINCMG")-IIf(lCredICM .And. SF4->F4_AGREG$"I|B",MaFisRet(nItem,"IT_VALICM"),0),;
						MaFisRet(nItem,"IT_VALIPI"),;
						MaFisRet(nItem,"IT_VALICM"),;
						SF4->F4_CREDIPI,;
						SF4->F4_CREDICM,;
						MaFisRet(nItem,"IT_NFORI"),;
						MaFisRet(nItem,"IT_SERORI"),;
						SD1->D1_COD,;
						SD1->D1_LOCAL,;
						SD1->D1_QUANT,;
						If(SF4->F4_IPI=="R",MaFisRet(nItem,"IT_VALIPI"),0),;
						SF4->F4_CREDST,;
						MaFisRet(nItem,"IT_VALSOL"),;
						MaRetIncIV(nItem,"1"),;
						SF4->F4_PISCOF,;
						SF4->F4_PISCRED,;
						nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
						nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
						IIf(SF4->(FieldPos("F4_ESTCRED")) > 0 .And. SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0),;
						IIf(SD1->(FieldPos("D1_CRPRSIM")) >0, MaFisRet(nItem,"IT_CRPRSIM"), 0 ),;
						MaFisRet(nItem,"IT_VALANTI");
					})
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao considerar o custo de uma entrada por devolucao ou bonificacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SD1->D1_TIPO == "D" .And. SF4->F4_DEVZERO == "2") .Or. (lBonif .And. SF4->F4_BONIF == "S")
	aRet := {{0,0,0,0,0}}
Else
	aRet := RetCusEnt(aDupl,aCusto,cTipo)
	If SF4->F4_AGREG == "N"
		For nX := 1 to Len(aRet[1])
			aRet[1][nX] := If(aRet[1][nX]>0,aRet[1][nX],0)
		Next nX
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A103CUST - Ponto de entrada utilizado para manipular os valores |
//|            do custo de entrada nas 5 moedas.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A103CUST")
	uRet := ExecBlock("A103CUST",.F.,.F.,{aRet})
	If Valtype(uRet) == "A" .And. Len(uRet) > 0
		For nX := 1 To Len(uRet)
			For nZ:=1 To 5
				If Valtype(uRet[nX,nZ]) != "N"	//Uso o array original se retorno nao for numerico
					lCustPad := .F.
					Exit
				EndIf
			Next nZ
		Next nX
		If lCustPad
			aRet := aClone(uRet)
		EndIf
	EndIf
EndIf

Return aRet[1]

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjustaSX1 ³ Autor ³ Marcos V. Ferreira    ³ Data ³18.06.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao utilizada para ajustar as tabelas de perguntas e     ³±±
±±³          ³ help's de campos.                                           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()   

Local aAreaSF1   :=SF1->(GetArea())

PutHelp("PA103NEXCOR",{"Este Documento de entrada não ","pode ser excluído."},;
	{"This Entrance Document can not be excluded."},;
	{"Este Documento del entrada no puede descartarse."},.F.)

PutHelp("SA103NEXCOR",{"Verifique os Documentos de ","Entrada vinculados ao mesmo."},;
	{"Check Entrance Document tied to it."},;
	{"Verifique los documentos del entrada vinculados a ésta."},.F.)

PutHelp("PA120BLQ",{"O Pedido de compras amarrado ao item do ","documento de entrada se encontra","BLOQUEADO."},;
	{"The Order of purchases moored to the item of","entrance document if finds","BLOCKED."},;
	{"El Pedido de Compras artículo del ao del amarrado","documento del entrada si encontra","BLOQUEADO."},.F.)

PutHelp("SA120BLQ",{"Favor verificar as aprovações pendentes","para este pedido de compras."},;
	{"Check the approver's pending","for this order of purchases."},;
	{"Favor verificar las aprobaciones pendientes","para este pedido de compras."},.F.)

PutHelp("PA103VERBAU",{"Nao existe a verba para pagamento do ","autonomo, no Cadastro de Verbas ","da Folha de Pagamento."},;
               		  {"No wage to pay the self-employed worked"," according to the Payroll File.    ","   "},;
                      {"No existe el concepto para pago de ","Autonomo en el Archivo de Conceptos ","de la Planilla de Haberes."},.F.)

PutHelp("SA103VERBAU",{"Cadastrar a verba, na Folha de ","Pagamento, com o identificador 218."},;
                      {"Enter the wage using identifier 218 ","in the Payroll."},;
                      {"Registrar el concepto en la Planilla ","de Haberes con el identificador 218."},.F.)

PutHelp("PA103ZROTES",{"A TES informada está configurada para"," permitir quantidade zerada."},;
               		 {"Se configuró la TES informada para "," permitir cantidad cero."},;
               		 {"The TES is set to allow informed zerada quantity."},.T.)

PutHelp("SA103ZROTES",{"Verifique no cadastro da TES informada ","o campo 'Qtd. Zerada' (F4_QTDZERO)"},;
                      {"Verifique en el archivo de la TES que se informo"," el campo 'Ctd. Cero' (F4_QTDZERO)"},;
                      {"Check the register of TES informed "," the 'Qt. Zero'"},.T.)                  

PutHelp("PA103USARF7",{"A quantidade informada para o retorno","deste documento não esta correta ou não","está vinculada ao Documento de Origem."},;
					  {"La cantidad informada para el retorno de","este documento no es correcta o no","esta vinculada al Documento de Origen."},;
					  {"The quantity entered for return of this","document is not correct or is not","linked to the source document"},.F.)

PutHelp("SA103USARF7",{"Verificar se a quantidade informada é ","superior ao saldo de Poder Terceiro.","Utilize a tecla <F7> para vincular","a quantidade ao saldo de/em poder","terceiros deste produto."},;
					  {"Verifique si la cantidad informada es","superior al saldo de Poder Terceros.","Utilice la tecla <F7> para vincular la","cantidad al saldo de/en poder terceros","de este producto."},;
					  {"Check if the quantity entered is higher","than the balance of Third Parties'Power.","Use the <F7>key to link the quantity","entered of power in/from third","parties' power of this product."},.F.)

PutHelp("PA1031DUP",{"O tamanho da parcela inicial informada","no parâmetro MV_1DUP está diferente do","tamanho do campo de parcela do título."},;
					{""},;
					{""},.F.)
					
PutHelp("SA1031DUP",{"Verifique o conteúdo do parâmetro","MV_1DUP em relação ao tamanho do","grupo de campos de parcela."},;
					{""},;
					{""},.F.)

PutHelp("PA103PARC",{"O número de parcelas utilizado na","condição de pagamento é maior que","o limite suportado pelo campo de","parcelas do título."},;
					{""},;
					{""},.F.)
					
PutHelp("SA103PARC",{"Verifique o tamanho do campo no grupo de campos","de parcela e a condição de pagamento","utilizada."},;
					{""},;
					{""},.F.)
					
//MV_PAR13 - Rateia Valor
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Indica o valor a ser utilizado no rateio")
Aadd( aHelpPor, "de multiplas naturezas, Bruto (Valor do ")
Aadd( aHelpPor, "título mais os impostos) ou Líquido ")
Aadd( aHelpPor, "(valor sem os impostos). Somente sera ")
Aadd( aHelpPor, "aplicado caso a opcao de rateio  valor ")
Aadd( aHelpPor, "seja informada como bruto.")

Aadd( aHelpEng, "Indicates the value to be used in the ")
Aadd( aHelpEng, "assessment of multiple natures (Gross ")
Aadd( aHelpEng, "Value of Title plus taxes) or Net ")
Aadd( aHelpEng, "(value without taxes). Only if the ")
Aadd( aHelpEng, "option will be applied pro rata value ")
Aadd( aHelpEng, "is reported as gross.")

Aadd( aHelpSpa, "Indica el valor a ser utilizado en el ")
Aadd( aHelpSpa, "rateio de multiplas naturalezas, Bruto")
Aadd( aHelpSpa, "(Valor del título más los impuestos) ou")
Aadd( aHelpSpa, "Líquido valor sin impuestos).Solamente ")
Aadd( aHelpSpa, "sera aplicado si la opcao de rateio ")
Aadd( aHelpSpa, "valor sea informada como bruto.")


PutHelp("P.MTA10313.",aHelpPor,aHelpEng,aHelpSpa,.T.)	
		
		  

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
If SX1->(dbSeek(Padr("MTA103",Len(SX1->X1_GRUPO))+'16')) .And. Empty(Trim(SX1->X1_PERSPA))
	If RecLock('SX1',.F.)
		dbDelete()
		msUnLock()
	EndIf
EndIf

Aadd( aHelpPor, "Indica que o documento de entrada poderá")
Aadd( aHelpPor, "ser carregado de um pedido do fornecedor")
Aadd( aHelpPor, "e dos fabricantes associados pelo cadas-")
Aadd( aHelpPor, "tro de produtos x fornecedor.")
Aadd( aHelpPor, "Pergunta utilizada apenas para o Templa-")
Aadd( aHelpPor, "te de Drogaria")

PutSx1(	Padr("MTA103",Len(SX1->X1_GRUPO)) ,"16","NF de bonificacao?","NF de bonificacao?","NF de bonificacao?","mv_che","N",1,0,1,"C","","", "","",;
		"mv_par16","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
			

//MV_PAR17 - Bloq. Movimento
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}

Aadd( aHelpPor, "Campo utilizado para bloquear as")
Aadd( aHelpPor, "movimentações  de integração com outros")
Aadd( aHelpPor, "módulos, caso o mesmo seja configurado ")
Aadd( aHelpPor, "como SIM não serão geradas as movimenta-")
Aadd( aHelpPor, "ções de Estoque,Financeiro e Fiscal.Este")
Aadd( aHelpPor, "tratamento irá funcionar somente para")
Aadd( aHelpPor, "documentos de formulário próprio.")

aHelpEng:=aHelpSpa:=aHelpPor	
			
PutSx1(	Padr("MTA103",Len(SX1->X1_GRUPO)) ,"17","Bloq. Movimento?","Bloq. Movimento?","Bloq. Movimento?","mv_chg",;
"N",1,0,2,"C","", "", "","","mv_par17","Sim","Sim","Sim","",;
"Nao","Nao","Nao","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

//Inclusao de novas perguntas para que o usuario tenha a opcao de recolhe a guia e gerar o titulo no Documentacao de Entrada
aHelpPor:= {}
aHelpEng:= {}
aHelpSpa:= {}
Aadd( aHelpPor, "Informe se deverá ser gerado o título a ")
Aadd( aHelpPor, "pagar do ICMS por Antecipação Tributaria") 

aHelpEng:=aHelpSpa:=aHelpPor	

PutSx1(Padr("MTA103",Len(SX1->X1_GRUPO)),"18","Gera Titulo ICMS Antecipação ?","Gera Titulo ICMS Antecipação ?","Gera Titulo ICMS Antecipação ?","mv_chh","N",01,0,2,"C","","","","","mv_par18","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor:= {}
aHelpEng:= {}
aHelpSpa:= {}
Aadd( aHelpPor, "Informe se deverá ser gerada uma Guia de") 
Aadd( aHelpPor, " Recolhimento do ICMS por Antecipação Tr") 
Aadd( aHelpPor, "ibutaria.O sistema irá apresentar uma te") 
Aadd( aHelpPor, "la para que as informações necessárias a") 
Aadd( aHelpPor, " geração da Guia sejam preenchidas.     ") 

aHelpEng:=aHelpSpa:=aHelpPor	

PutSx1(Padr("MTA103",Len(SX1->X1_GRUPO)),"19","Guia Recolhimento ICMS Atecip?","Guia Recolhimento ICMS Atecip?","Guia Recolhimento ICMS Atecip?","mv_chi","N",01,0,2,"C","","","","","mv_par19","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

PutHelp("PA103VLDNAT",{"Não é permitido utilizar Natureza do ","tipo Sintética para efetuar este ","lançamento !"},;
                      {"Synthetic Class not allowed for this "," entry!"},;
                      {"¡No se permite utilizar Modalidad de ","tipo Sintética para efectuar este ","asiento !"},.F.)

PutHelp("SA103VLDNAT",{"Verifique a Natureza vinculada ao "," mesmo."},;
                      {"Check Class tied to it."},;
   					  {"Verifique el Modalidad vinculada a ésta."},.F.)

PutHelp("PA103FRETE", {"Campo Tipo de Frete na aba: DANFE não"," poderá ser preenchido quando houver"," pedido vinculado a nota !"},;
                      {"Field Type of freight in tab: DANFE ","cannot be field out when there is an"," order linked to the invoice!"},;
                      {"","",""},.t.)

PutHelp("SA103FRETE",{"Deixe este campo sem conteudo !","",""},;
                      {"Leave this field without content!","",""},;
	    		      {"","",""},.t.)

PutHelp("PA100VALDES",{"O valor de Desconto está superior ","ao valor do item."},;
                      {"The Discount value is greater than"," the Item total."},;
                      {"El valor del descuento es mayor ","que el total del artículo."},.t.)

PutHelp("PA103ITDUPL",{"Existem itens de pedido de compras ","em duplicidade no documento."},;
                      {"There are items of purchase order in"," duplicate in the document."},;
                      {"Hay artículos de la orden de compra ","por duplicado en el documento."},.t.)

PutHelp("SA103ITDUPL",{"Exclua um item do pedido ","ou ajuste a quantidade."},;
                      {"Delete an item or adjust the ","requested amount."},;
	    		      {"Eliminar un elemento o ajustar ","la cantidad solicitada."},.t.)

aHelpPor:= {}
Aadd( aHelpPor, "Informe se deverá ser gerado o título a ")
Aadd( aHelpPor, "pagar do ICMS ST por Transporte") 
aHelpEng:=aHelpSpa:=aHelpPor                      
PutSx1(Padr("MTA103",Len(SX1->X1_GRUPO)),"20","Gera Titulo ST Transp ?","Gera Titulo ST Transp ?","Gera Titulo ST Transp ?","mv_chj","N",01,0,2,"C","","","","","mv_par20","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor:= {}
Aadd( aHelpPor, "Informe se deverá ser gerada a Guia a")
Aadd( aHelpPor, "pagar do ICMS ST por Transporte") 
aHelpEng:=aHelpSpa:=aHelpPor                      
PutSx1(Padr("MTA103",Len(SX1->X1_GRUPO)),"21","Guia Recolhimento ST Transp?","Guia Recolhimento ST Transp?","Guia Recolhimento ST Transp?","mv_chk","N",01,0,2,"C","","","","","mv_par21","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor:= {}
Aadd( aHelpPor, "Habilitar o preenchimento auto-")
Aadd( aHelpPor, "mático de tipos de operação no ")
Aadd( aHelpPor, "processo de entrada.           ")
aHelpEng:=aHelpSpa:=aHelpPor                      
PutSx1(Padr("MTA103",Len(SX1->X1_GRUPO)),"22","Replicar Tp.Oper?","Replicar Tp.Oper?","Replicar Tp.Oper?","mv_chl","N",01,0,2,"C","","","","","mv_par22","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


RestArea(aAreaSF1)                                               
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MyMata103 ³ Autor ³ Eduardo Riera         ³ Data ³06.11.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de teste da rotina automatica do programa MATA103     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar testes na rotina de    ³±±
±±³          ³documento de entrada                                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
MAIN Function MyMata103()

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.
PRIVATE lMsErroAuto := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ConOut(Repl("-",80))
ConOut(PadC(OemToAnsi(STR0205),80)) //"Teste de Inclusao de 10 documentos de entrada com 30 itens cada"
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SF1","SD1","SA1","SA2","SB1","SB2","SF4"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificacao do ambiente para teste                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB1")
DbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
	lOk := .F.
	ConOut(OemToAnsi(STR0206)) //"Cadastrar produto: PA001"
EndIf
DbSelectArea("SF4")
DbSetOrder(1)
If !SF4->(MsSeek(xFilial("SF4")+"001"))
	lOk := .F.
	ConOut(OemToAnsi(STR0207)) //"Cadastrar TES: 001"
EndIf
DbSelectArea("SE4")
DbSetOrder(1)
If !SE4->(MsSeek(xFilial("SE4")+"001"))
	lOk := .F.
	ConOut(OemToAnsi(STR0208)) //"Cadastrar condicao de pagamento: 001"
EndIf
If !SB1->(MsSeek(xFilial("SB1")+"PA002"))
	lOk := .F.
	ConOut(OemToAnsi(STR0209)) //"Cadastrar produto: PA002"
EndIf
DbSelectArea("SA2")
DbSetOrder(1)
If !SA2->(MsSeek(xFilial("SA2")+"F0000101"))
	lOk := .F.
	ConOut(OemToAnsi(STR0210)) //"Cadastrar fornecedor: F0000101"
EndIf
If lOk
	ConOut(OemToAnsi(STR0211)+Time()) //"Inicio: "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Verifica o ultimo documento valido para um fornecedor        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF1")
	DbSetOrder(2)
	MsSeek(xFilial("SF1")+"F0000101z",.T.)
	dbSkip(-1)
	cDoc := SF1->F1_DOC
	For nY := 1 To 10
		aCabec := {}
		aItens := {}

		If Empty(cDoc)
			cDoc := StrZero(1,Len(SD1->D1_DOC))
		Else
			cDoc := Soma1(cDoc)
		EndIf
		aadd(aCabec,{"F1_TIPO"   ,"N"})
		aadd(aCabec,{"F1_FORMUL" ,"N"})
		aadd(aCabec,{"F1_DOC"    ,(cDoc)})
		aadd(aCabec,{"F1_SERIE"  ,"UNI"})
		aadd(aCabec,{"F1_EMISSAO",dDataBase})
		aadd(aCabec,{"F1_FORNECE","F00001"})
		aadd(aCabec,{"F1_LOJA"   ,"01"})
		aadd(aCabec,{"F1_ESPECIE","NFE"})
		aadd(aCabec,{"F1_COND","001"})
		aadd(aCabec,{"F1_DESPESA"   ,10})		
		aadd(aCabec,{"F1_RECISS"   ,"2"})
		aadd(aCabec,{"E2_NATUREZ","NAT01"})

		For nX := 1 To 30
			aLinha := {}
			aadd(aLinha,{"D1_COD"  ,"PA001",Nil})
			aadd(aLinha,{"D1_QUANT",1,Nil})
			aadd(aLinha,{"D1_VUNIT",100,Nil})
			aadd(aLinha,{"D1_TOTAL",100,Nil})
			aadd(aLinha,{"D1_TES","001",Nil})
			aadd(aItens,aLinha)
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Teste de Inclusao                                            |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MATA103(aCabec,aItens)
		If !lMsErroAuto
			ConOut(OemToAnsi(STR0212)+cDoc)	 //"Incluido com sucesso! "
		Else
			ConOut(OemToAnsi(STR0213)) //"Erro na inclusao!"
		EndIf
	Next nY
	ConOut(OemToAnsi(STR0214)+Time()) //"Fim  : "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Teste de exclusao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"F1_TIPO"   ,"N"})
	aadd(aCabec,{"F1_FORMUL" ,"N"})
	aadd(aCabec,{"F1_DOC"    ,(cDoc)})
	aadd(aCabec,{"F1_SERIE"  ,"UNI"})
	aadd(aCabec,{"F1_EMISSAO",dDataBase})
	aadd(aCabec,{"F1_FORNECE","F00001"})
	aadd(aCabec,{"F1_LOJA"   ,"01"})
	aadd(aCabec,{"F1_ESPECIE","NFE"})
	aadd(aCabec,{"F1_RECISS","2"})

	For nX := 1 To 30
		aLinha := {}
		aadd(aLinha,{"D1_ITEM",StrZero(nX,Len(SD1->D1_ITEM)),Nil})
		aadd(aLinha,{"D1_COD","PA002",Nil})
		aadd(aLinha,{"D1_QUANT",2,Nil})
		aadd(aLinha,{"D1_VUNIT",100,Nil})
		aadd(aLinha,{"D1_TOTAL",200,Nil})
		aadd(aItens,aLinha)
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Teste de Exclusao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut(PadC(OemToAnsi(STR0215),80)) //"Teste de exclusao"
	ConOut(OemToAnsi(STR0211)+Time()) //"Inicio: "
	MATA103(aCabec,aItens,5)
	If !lMsErroAuto
		ConOut(OemToAnsi(STR0216)+cDoc)	 //"Exclusao com sucesso! "
	Else
		ConOut(OemToAnsi(STR0217)) //"Erro na exclusao!"
	EndIf
	ConOut(OemToAnsi(STR0214)+Time()) //"Fim  : "
	ConOut(Repl("-",80))
EndIf
RESET ENVIRONMENT
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma103Track³ Autor ³ Aline Correa do Vale  ³ Data ³05/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz o tratamento da chamada do System Tracker              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103Track()

Local aEnt     := {}
Local cKey     := cNFiscal + cSerie + cA100For + cLoja
Local nPosItem := GDFieldPos( "D1_ITEM" )
Local nPosCod  := GDFieldPos( "D1_COD"  )
Local nLoop    := 0
Local aArea    := GetArea()
Local aAreaSF1 := SF1->( GetArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLoop := 1 To Len( aCols )
	AAdd( aEnt, { "SD1", cKey + aCols[ nLoop, nPosCod ] + aCols[ nLoop, nPosItem ] } )
Next nLoop

MaFisSave()
MaFisEnd()

MaTrkShow( aEnt )

MaFisRestore()

RestArea(aAreaSF1)
RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AliasInDic³ Autor ³ Sergio Silveira       ³ Data ³02/01/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica se um determinado alias esta presente no dicionario ³±±
±±³          ³ de dados                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := AliasInDic( ExpC1, ExpL2 )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> .T. - Tabela presente / .F. - tabela nao presente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Alias                                             ³±±
±±³          ³ ExpL2 -> Indica se exibe help de tabela inexistente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AliasInDic(cAlias,lHelp)
Local aArea     := {}
Local aAreaSX2  := {}
Local aAreaSX3  := {}
Local lRet		:= .F.
Local nAt

Default __aAliasInDic := {}

nAt := Ascan( __aAliasInDic, {|x| x[1]==cAlias})

If ( nAt == 0 )
	aArea		:= GetArea()
	aAreaSX2	:= SX2->( GetArea() )
	aAreaSX3	:= SX3->( GetArea() )
	
	
	DEFAULT lHelp	:= .F.
	
	SX2->( DbSetOrder( 1 ) )
	SX3->( DbSetOrder( 1 ) )
	
	lRet := ( SX2->( dbSeek( cAlias ) ) .And. SX3->( dbSeek( cAlias ) ) )

	Aadd(__aAliasInDic, {cAlias,lRet})
	
	SX3->( RestArea( aAreaSX3 ) )
	SX2->( RestArea( aAreaSX2 ) )
	RestArea( aArea )
Else 
	lRet := __aAliasInDic[nAt][2]
EndIf

If !lRet .And. lHelp
	Help( "", 1, "ALIASINDIC",,cAlias )
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NfeCalcRet³ Autor ³Sergio Silveira        ³ Data ³05/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua o calculo do valor de titulos financeiros que        ³±±
±±³          ³calcularam a retencao do PIS / COGINS / CSLL e nao          ³±±
±±³          ³criaram os titulos de retencao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpA1 := NfeCalcRet( ExpD1 )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 - Data de referencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 -> Array com os seguintes elementos                   ³±±
±±³          ³       1 - Valor dos titulos                                ³±±
±±³          ³       2 - Valor do PIS                                     ³±±
±±³          ³       3 - Valor do COFINS                                  ³±±
±±³          ³       4 - Valor da CSLL                                    ³±±
±±³          ³       5 - Array contendo os recnos dos registos processados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NfeCalcRet( dReferencia, nIndexSE2, aDadosImp )

Local aAreaSE2  := SE2->( GetArea() )
Local aDadosRef := Array(8)
Local aRecnos   := {}

Local nAdic     := 0

Local dDataIni  := FirstDay( dReferencia )
Local dDataFim  := LastDay( dReferencia )
Local cModTot   := GetNewPar( "MV_MT10925", "1" )
Local lBaseImp  := ( SuperGetMv("MV_BS10925",.F.,"1") == "1")
Local lIrfMp232 :=	!Empty( SA2->( FieldPos( "A2_CALCIRF" ) ) ) .and. SA2->A2_CALCIRF == "2"

//Chamado SDFPWW
Local cAglutFil := SuperGetMV("MV_PCCAGFL",,"1")
Local aAreaSM0  := {}
Local cCGCSM0   := ""
Local cEmpAtu   := ""

#IFDEF TOP
	Local aStruct   := {}
	Local aCampos   := {}
	Local aFil10925 := {}

	Local cAliasQry := ""
	Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
	Local cSepProv  := If("|"$MVPROVIS,"|",",")
	Local cSepRec   := If("|"$MVPAGANT,"|",",")
	Local cQuery    := ""
	Local cQryFil   := ""	

	Local nLoop     := 0

	Local lLojaAtu  := ( GetNewPar( "MV_LJ10925", "1" ) == "1" )

#ENDIF

Default aDadosImp := Array(3)

AFill( aDadosRef, 0 )
AFill( aDadosImp, 0 )

#IFDEF TOP

	aFil10925 := {}
	aAreaSM0  := SM0->(GetArea())
	cEmpAtu   := SM0->M0_CODIGO
	cCGCSM0   := SM0->M0_CGC
	SM0->(DbSetOrder(1))
	SM0->(MsSeek(cEmpAnt))
	
	//Se parametro "MV_PCCAGFR" existe com conteudo diferente de 1
	If cAglutFil == "2" .Or. cAglutFil == "3"
		Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAtu
			//Verifica se a filial tem o mesmo CGC/Raiz de CGC
			If (cAglutFil == "2" .And. cCGCSM0 == SM0->M0_CGC) .Or. (cAglutFil == "3" .And. Left(cCGCSM0,8) == Left(SM0->M0_CGC,8))
				AAdd(aFil10925,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ))
			EndIf
			SM0->(DbSkip())
		EndDo

	ElseIf ExistBlock( "MT103FRT" )
		aFil10925 := ExecBlock( "MT103FRT", .F., .F. )
	Else
		aFil10925 := { xFilial( "SE2" ) }  				
	EndIf
	SM0->(RestArea(aAreaSM0))

	aCampos := { "E2_VALOR","E2_IRRF","E2_ISS","E2_INSS","E2_PIS","E2_COFINS","E2_CSLL","E2_VRETPIS","E2_VRETCOF","E2_VRETCSL" }
	aStruct := SE2->( dbStruct() ) 	

	SE2->( dbCommit() )

	cAliasQry := GetNextAlias()

	cQuery := "SELECT E2_VALOR,E2_PIS,E2_COFINS,E2_EMISSAO,E2_CSLL,E2_ISS,E2_INSS,E2_IRRF,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,R_E_C_N_O_ RECNO "
	cQuery += ",E2_BASEPIS,E2_BASECOF,E2_BASECSL,E2_VRETIRF "	
	Aadd(aCampos,"E2_BASEPIS")
	Aadd(aCampos,"E2_BASECOF")
	Aadd(aCampos,"E2_BASECSL")		


	cQuery += "FROM "+RetSqlName( "SE2" ) + " SE2 "
	cQuery += "WHERE "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as filiais do filtro                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQryFil := "("

	For nLoop := 1 to Len( aFil10925 )
		cQryFil += "E2_FILIAL='" + aFil10925[ nLoop ] + "' OR "
	Next nLoop 						

	cQryFil := Left( cQryFil, Len( cQryFil ) - 3 )

	cQryFil  += ") AND "

	cQuery += cQryFil

	cQuery += " E2_FORNECE='"   + cA100For             + "' AND " 	
	If lLojaAtu
		cQuery += " E2_LOJA='"  + cLoja                + "' AND "
	Endif	
	cQuery += " E2_VENCREA>= '" + DToS( dDataIni )      + "' AND "		
	cQuery += " E2_VENCREA<= '" + DToS( dDataFim )      + "' AND "
	cQuery += " E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
	cQuery += " E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
	cQuery += " E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
	cQuery += " E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " AND "
	cQuery += " D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	For nLoop := 1 To Len( aStruct )
		If !Empty( AScan( aCampos, AllTrim( aStruct[nLoop,1] ) ) )
			TcSetField( cAliasQry, aStruct[nLoop,1], aStruct[nLoop,2],aStruct[nLoop,3],aStruct[nLoop,4])
		EndIf 			
	Next nLop

	While !( cAliasQRY )->( Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena os valores calculados de PIS/COFINS/CSLL para cada titulo.               ³
		//³Este valor sera utilizado para se calcular o residual nao retido (quando o titulo ³
		//³onde a retencao deveria ter sido feita tiver o valor menor que o valor total a ser³
		//³retido).                                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( cAliasQRY )->E2_PIS > 0
			aDadosImp[1] += ( cAliasQRY )->E2_PIS
		EndIf

		If ( cAliasQRY )->E2_COFINS > 0
			aDadosImp[2] += ( cAliasQRY )->E2_COFINS
		EndIf

		If ( cAliasQRY )->E2_CSLL > 0
			aDadosImp[3] += ( cAliasQRY )->E2_CSLL
		EndIf

		nAdic := 0

		nAdic += ( ( cAliasQRY )->E2_VALOR + ( cAliasQRY )->E2_ISS + ( cAliasQRY )->E2_INSS + ( cAliasQRY )->E2_IRRF )

		If Empty( ( cAliasQRY )->E2_PRETPIS )
			nAdic += If( Empty( ( cAliasQRY )->E2_VRETPIS ), ( cAliasQRY )->E2_PIS, ( cAliasQRY )->E2_VRETPIS )
			// Armazena os valores calculados por titulo, retirando os valores retidos
			If ( cAliasQRY )->E2_VRETPIS + ( cAliasQRY )->E2_VRETCOF + ( cAliasQRY )->E2_VRETCSL + IF(lIrfMP232, ( cAliasQRY )->E2_VRETIRF , 0 ) > 0
				aDadosImp[1] -= (cAliasQRY)->E2_VRETPIS
			Endif
		EndIf

		If Empty( ( cAliasQRY )->E2_PRETCOF )
			nAdic += If( Empty( ( cAliasQRY )->E2_VRETCOF ), ( cAliasQRY )->E2_COFINS, ( cAliasQRY )->E2_VRETCOF )
			//Armazena os valores calculados por titulo, retirando os valores retidos
			If ( cAliasQRY )->E2_VRETPIS + ( cAliasQRY )->E2_VRETCOF + ( cAliasQRY )->E2_VRETCSL + IF(lIrfMP232, ( cAliasQRY )->E2_VRETIRF , 0 ) > 0
				aDadosImp[2] -= (cAliasQRY)->E2_VRETCOF
			Endif
		EndIf

		If Empty( ( cAliasQRY )->E2_PRETCSL )
			nAdic += If( Empty( ( cAliasQRY )->E2_VRETCSL ), ( cAliasQRY )->E2_CSLL, ( cAliasQRY )->E2_VRETCSL )
			//Armazena os valores calculados por titulo, retirando os valores retidos
			If ( cAliasQRY )->E2_VRETPIS + ( cAliasQRY )->E2_VRETCOF + ( cAliasQRY )->E2_VRETCSL + IF(lIrfMP232, ( cAliasQRY )->E2_VRETIRF , 0 ) > 0
				aDadosImp[3] -= (cAliasQRY)->E2_VRETCSL
			Endif
		EndIf

		If cModTot == "1"
			aDadosRef[1] += nAdic

			If  lBaseImp
				If ( cAliasQRY )->E2_BASEPIS > 0 .Or. ( cAliasQRY )->E2_BASECOF > 0 .Or. ( cAliasQRY )->E2_BASECSL > 0
					aDadosRef[6] += ( cAliasQRY )->E2_BASEPIS
					aDadosRef[7] += ( cAliasQRY )->E2_BASECOF
					aDadosRef[8] += ( cAliasQRY )->E2_BASECSL
				Else
					aDadosRef[6] += nAdic
					aDadosRef[7] += nAdic
					aDadosRef[8] += nAdic
				EndIf
			Else
				aDadosRef[6] += nAdic
				aDadosRef[7] += nAdic
				aDadosRef[8] += nAdic
			EndIf
		Endif


		If ( !Empty( ( cAliasQRY )->E2_PIS ) .Or. !Empty( ( cAliasQRY )->E2_COFINS ) .Or. !Empty( ( cAliasQRY )->E2_CSLL ) )

			If cModTot == "2"	
				aDadosRef[1] += nAdic

				If  lBaseImp
					If ( cAliasQRY )->E2_BASEPIS > 0 .Or. ( cAliasQRY )->E2_BASECOF > 0 .Or. ( cAliasQRY )->E2_BASECSL > 0
						aDadosRef[6] += ( cAliasQRY )->E2_BASEPIS
						aDadosRef[7] += ( cAliasQRY )->E2_BASECOF
						aDadosRef[8] += ( cAliasQRY )->E2_BASECSL
					Else
						aDadosRef[6] += nAdic
						aDadosRef[7] += nAdic
						aDadosRef[8] += nAdic
					EndIf
				Else
					aDadosRef[6] += nAdic
					aDadosRef[7] += nAdic
					aDadosRef[8] += nAdic
				EndIf
			Endif	

			If ( Empty( ( cAliasQRY )->E2_VRETPIS ) .Or. Empty( ( cAliasQry )->E2_VRETCOF ) .Or. Empty( ( cAliasQry )->E2_VRETCSL ) ) ;
					.And. ( ( cAliasQRY )->E2_PRETPIS == "1" .Or. ( cAliasQry )->E2_PRETCOF == "1" .Or. ( cAliasQry )->E2_PRETCSL == "1" )

				If Empty( ( cAliasQRY )->E2_VRETPIS ) .And. ( cAliasQRY )->E2_PRETPIS == "1"
					aDadosRef[2] += ( cAliasQRY )->E2_PIS
				EndIf

				If Empty( ( cAliasQRY )->E2_VRETCOF )	.And. ( cAliasQRY )->E2_PRETCOF == "1"
					aDadosRef[3] += ( cAliasQRY )->E2_COFINS
				EndIf

				If Empty( ( cAliasQRY )->E2_VRETCSL ) .And. ( cAliasQRY )->E2_PRETCSL == "1"
					aDadosRef[4] += ( cAliasQRY )->E2_CSLL
				EndIf
				AAdd( aRecnos, ( cAliasQRY )->RECNO )
			EndIf

		Endif

		( cAliasQRY )->( dbSkip())

	EndDo

	// Fecha a area de trabalho da query

	( cAliasQRY )->( dbCloseArea() )
	DbSelectArea( "SE2" )

#ELSE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³ Verifica se foi criada a indregua                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType( nIndexSE2 ) == "N"

		SE2->( DbSetOrder( nIndexSE2 ) )
		SE2->( dbSeek( DTOS( dDataIni ), .T. ) )

		While !SE2->( Eof() ) .And. SE2->E2_VENCREA >= dDataIni .And. SE2->E2_VENCREA <= dDataFim
			If !( SE2->E2_TIPO $ ( MVABATIM + "/" + MV_CPNEG + "/" + MVPROVIS + "/" + MVPAGANT ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena os valores calculados de PIS/COFINS/CSLL para cada titulo.               ³
				//³Este valor sera utilizado para se calcular o residual nao retido (quando o titulo ³
				//³onde a retencao deveria ter sido feita tiver o valor menor que o valor total a ser³
				//³retido).                                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SE2->E2_PIS > 0
					aDadosImp[1] += SE2->E2_PIS
				EndIf

				If SE2->E2_COFINS > 0
					aDadosImp[2] += SE2->E2_COFINS
				EndIf

				If SE2->E2_CSLL > 0
					aDadosImp[3] += SE2->E2_CSLL
				EndIf

				nAdic := 0		

				nAdic += ( SE2->E2_VALOR + SE2->E2_ISS + SE2->E2_INSS + SE2->E2_IRRF )

				If Empty( SE2->E2_PRETPIS )
					nAdic += If( Empty( SE2->E2_VRETPIS ), SE2->E2_PIS, SE2->E2_VRETPIS )
					// Armazena os valores calculados por titulo, retirando os valores retidos
					If SE2->E2_VRETPIS + SE2->E2_VRETCOF + SE2->E2_VRETCSL + IF(lIrfMP232, SE2->E2_VRETIRF , 0 ) > 0
						aDadosImp[1] -= SE2->E2_VRETPIS
					Endif
				EndIf

				If Empty( SE2->E2_PRETCOF )
					nAdic += If( Empty( SE2->E2_VRETCOF ), SE2->E2_COFINS, SE2->E2_VRETCOF )
					//Armazena os valores calculados por titulo, retirando os valores retidos
					If SE2->E2_VRETPIS + SE2->E2_VRETCOF + SE2->E2_VRETCSL + IF(lIrfMP232, SE2->E2_VRETIRF , 0 ) > 0
						aDadosImp[2] -= SE2->E2_VRETCOF
					Endif
				EndIf

				If Empty( SE2->E2_PRETCSL )
					nAdic += If( Empty( SE2->E2_VRETCSL ), SE2->E2_CSLL, SE2->E2_VRETCSL )
					//Armazena os valores calculados por titulo, retirando os valores retidos
					If SE2->E2_VRETPIS + SE2->E2_VRETCOF + SE2->E2_VRETCSL + IF(lIrfMP232, SE2->E2_VRETIRF , 0 ) > 0
						aDadosImp[3] -= SE2->E2_VRETCSL
					Endif
				EndIf

				If cModTot == "1"
					aDadosRef[1] += nAdic

					If lBaseImp

						If SE2->E2_BASEPIS > 0 .Or. SE2->E2_BASECOF > 0 .Or. SE2->E2_BASECSL > 0
							aDadosRef[6] += SE2->E2_BASEPIS
							aDadosRef[7] += SE2->E2_BASECOF
							aDadosRef[8] += SE2->E2_BASECSL
						Else
							aDadosRef[6] += nAdic
							aDadosRef[7] += nAdic
							aDadosRef[8] += nAdic
						EndIf
					Else
						aDadosRef[6] += nAdic
						aDadosRef[7] += nAdic
						aDadosRef[8] += nAdic
					EndIf
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona ao array apenas os titulos que calcularam retencao         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If	( !Empty( SE2->E2_PIS ) .Or. !Empty( SE2->E2_COFINS ) .Or. !Empty( SE2->E2_CSLL ) )
					If cModTot == "2"
						aDadosRef[1] += nAdic
						If lBaseImp
							If SE2->E2_BASEPIS > 0 .Or. SE2->E2_BASECOF > 0 .Or. SE2->E2_BASECSL > 0
								aDadosRef[6] += SE2->E2_BASEPIS
								aDadosRef[7] += SE2->E2_BASECOF
								aDadosRef[8] += SE2->E2_BASECSL
							Else
								aDadosRef[6] += nAdic
								aDadosRef[7] += nAdic
								aDadosRef[8] += nAdic
							EndIf
						Else
							aDadosRef[6] += nAdic
							aDadosRef[7] += nAdic
							aDadosRef[8] += nAdic
						EndIf
					Endif		

					If ( Empty( SE2->E2_VRETPIS ) .Or. Empty( SE2->E2_VRETCOF ) .And. Empty( SE2->E2_VRETCSL ) ) .And. ;
							( SE2->E2_PRETPIS == "1" .Or. SE2->E2_PRETCOF == "1" .Or. SE2->E2_PRETCSL == "1" )

						If Empty( SE2->E2_VRETPIS ) .And. SE2->E2_PRETPIS == "1"
							aDadosRef[2] += SE2->E2_PIS
						EndIf

						If Empty( SE2->E2_VRETCOF ) .And. SE2->E2_PRETCOF == "1"
							aDadosRef[3] += SE2->E2_COFINS
						EndIf

						If Empty( SE2->E2_VRETCSL ) .And. SE2->E2_PRETCSL == "1"
							aDadosRef[4] += SE2->E2_CSLL
						EndIf

						AAdd( aRecnos, SE2->( RECNO() ) )
					EndIf
				Endif	
			EndIf
			
			SE2->( dbSkip() )
		EndDo

	EndIf

#ENDIF

aDadosRef[ 5 ] := AClone( aRecnos )

SE2->( RestArea( aAreaSE2 ) )

Return( aDadosRef )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103TmsVld³ Autor ³Eduardo de Souza       ³ Data ³ 30/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida exclusao do movimentos de custos de transporte.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := A103TmsVld( ExpL1 )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 - Verifica se eh exclusao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaTMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A103TmsVld(l103Exclui)

Local lRet     := .T.
Local nCnt     := 0                                                                                  
Local aAreaSD1 := SD1->(GetArea())                                                                  

Local aHlpPor     := {"Existe movimento de custo de","trasporte baixado para o documento,","a exclusão não será permitida."}		   
Local aHlpEng     := {"There is a cost of trasport ","movement posted for the document,","the deletion will not e allowed."}
Local aHlpSpa	  := {"Existe movimiento de costos","de trasporte dado de baja en","el documento,","la exclusion no sera permitida."}

PutHelp("PA103NODEL" , aHlpPor , aHlpEng , aHlpSpa , .F. )

If l103Exclui .And. IntTMS() // Integracao TMS
	SD1->(DbSetOrder(1))
	For nCnt := 1 To Len(aCols)	
		If SD1->(MsSeek(xFilial("SD1")+cNFiscal+cSerie+cA100For+cLoja+GDFieldGet("D1_COD",nCnt)+GDFieldGet("D1_ITEM",nCnt)))
			SDG->(DbSetOrder(7))
			If SDG->(MsSeek(xFilial("SDG")+"SD1"+SD1->D1_NUMSEQ))
				While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_ORIGEM + SDG->DG_SEQMOV == xFilial("SDG") + "SD1" + SD1->D1_NUMSEQ
					If SDG->DG_STATUS <> StrZero(1,Len(SDG->DG_STATUS)) //-- Em Aberto
						//-- Caso somente a viagem esteja informada ou Frota, estorna o movimento de custo de transporte.
						If !( Empty(SDG->DG_CODVEI) .And. Empty(SDG->DG_FILORI) .And. Empty(SDG->DG_VIAGEM) ) .And. ;
								!( Empty(SDG->DG_CODVEI) .And. !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM) )
							//-- Caso a veiculo seja proprio estorna o movimento de custo de transporte.
							If !Empty(SDG->DG_CODVEI) .And. Empty(SDG->DG_FILORI) .And. Empty(SDG->DG_VIAGEM)								
								DA3->(DbSetOrder(1))
								If DA3->(MsSeek(xFilial("DA3")+SDG->DG_CODVEI))
									If DA3->DA3_FROVEI <> "1"
										lRet := .F.
										Exit
									EndIf
								EndIf
							Else                                                        
							   //-- Origem MATA103, nao há validação na inclusão pelo TMSA070
								If SDG->DG_ORIGEM <> 'SD1' .And. SDG->DG_ORIGEM <> 'SD3'
									lRet := .F.
									Exit
								EndIf	
							EndIf
						EndIf
					EndIf
					SDG->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nCnt
	RestArea( aAreaSD1 )
EndIf

If !lRet
	Help(" ",1,"A103NODEL") //-- Existe movimento de custo de transporte baixado, nao sera permitida a exclusao.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103TemBlq³ Autor ³ Edson Maricate        ³ Data ³17.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da TudoOk                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103TemBlq(l103Class)

Local aArea     := GetArea()
Local aAreaSC7  := SC7->(GetArea())
Local aSldItem	:= {}
Local lRet      := .F.
Local lVerifica := .T.
Local lGCPSldIt := FindFunction("GCPSldItem")
Local lRestCla	:= SuperGetMV("MV_RESTCLA",.F.,"2")=="2"
Local nX        := 0
Local nPosPc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosItPc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
Local nPosQtd   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosVlr   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nUsado    := len(aHeader)
Local nDecimalPC:= TamSX3("C7_PRECO")[2]
Local nQuJE		:= 0
Local nQtde		:= 0
Local nQaCl		:= 0
Local nQtdItem	:= 0
Local nVlritem	:= 0
Local nY			:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o preenchimaneto da tes dos itens devido a importacao do pedido de compras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l103Class
	DbSelectArea("SD1")
	DbSetOrder(1)
	MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
EndIf
If ( l103Class .And. Empty(SD1->D1_TESACLA) .And. Empty(SD1->D1_TEC) );
   .Or. ( lRestCla .And. l103Class .And. SF1->F1_STATUS == "B" .And. (!Empty(SD1->D1_TESACLA) .Or. !Empty(SD1->D1_TEC)));
   .Or. !l103Class
	For nX :=1 To Len(aCols)
		If !aCols[nx][nUsado+1]
			If !Empty(aCols[nx][nPosPc])
				If l103Class
					If lRestCla .And. SF1->F1_STATUS == "B" 
						lVerifica:= .F.
						Exit
					EndIf
					DbSelectArea("SD1")
					DbSetOrder(1)
					MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nx][nPosCod]+aCols[nx][nPosItem])
					If Empty(SF1->F1_STATUS) .And. SD1->D1_QUANT == aCols[nx][nPosQtd] .And. SD1->D1_VUNIT == aCols[nx][nPosVlr]
						lVerifica:= .F.
					EndIf
				EndIf    

			    If !lVerifica .And. ExistBlock("MT103NBL")
        			lVerifica:=ExecBlock("MT103NBL",.F.,.F.,{})
		        EndIf
								
				If lVerifica 
					DbSelectArea("SC7")
					DbSetOrder(14)   
					If MsSeek(xFilEnt(xFilial("SC7"))+aCols[nx][nPosPc]+aCols[nx][nPosItPc])   
						nQuJE := SC7->C7_QUJE
						nQaCl := SC7->C7_QTDACLA
						nQtde := SC7->C7_QUANT         
						If	lGCPSldIt
							aSldItem := {}
							GCPSldItem("2",aSldItem)
							If	!Empty(aSldItem)
								nQuJE := aSldItem[1]
								nQaCl := aSldItem[2]
								nQtde := aSldItem[3]
							EndIf
						EndIf
						nQtdItem := aCols[nx][nPosQtd]
						nVlrItem := aCols[nx][nPosVlr]
						For nY := nX+1 To Len(aCols)
							If aCols[nY][nPosCod] == aCols[nx][nPosCod] .And. aCols[nY][nPosItPc] == aCols[nx][nPosItPc] .And. aCols[nY][nPosPc] == aCols[nX][nPosPc]
								nVlrItem := (((aCols[nY][nPosVlr]*aCols[nY][nPosQtd])+(nVlrItem*nQtdItem))/(nQtdItem+aCols[nY][nPosQtd]))
								nQtdItem += aCols[nY][nPosQtd]
							EndIf
						Next nY
						lRet := MaAvalToler(SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_PRODUTO,nQtdItem+nQuJE+nQaCl-IIf(l103Class,SD1->D1_QUANT,0),nQtde,nVlrItem,xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,,M->dDEmissao,nDecimalPC,SC7->C7_TXMOEDA,))[1]
						If lRet
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

If ExistBlock("A103BLOQ")
	lRet:= ExecBlock("A103BLOQ",.F.,.F.,{lRet})
Endif

RestArea(aAreaSC7)
RestArea(aArea)
Return ( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ValSD4³ Autor ³Alexandre Inacio Lemes ³ Data ³07/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de empenhos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function A103ValSD4(nItem)

Local aArea		:= GetArea()
Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPosQuant	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosOp	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_OP"})
Local nPosOrdem	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ORDEM"})
Local cAlerta	:= ""
Local cProduto	:= ""
Local lRetorno	:= .F.
Local lValida	:= .T. 
Local lPyme		:= If( Type( "__lPyme" ) <> "U", __lPyme, .F. )
Local nQuantD4  := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETRO MV_NFESD4: (V)isualizar / (S)im / (N)ao  	   ³
//| VV - Sempre mostra janela de confirmacao (Default)     |
//| SV - Quando o produto nao faz parte do empenho da OP   |
//|		 confirmar item.                     		       |
//| NV - Quando o produto nao faz parte do empenho da OP   |
//|		 nao confirmar item.                      	   	   |
//| VS - Quando a qtde empenhada e menor que qtde do item  |
//|		 confirmar movimentacao.                           |
//| VN - Quando a qtde empenhada e menor que qtde do item  |
//|		 nao confirmar movimentacao.					   |	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cNfeSD4	:= Upper(SuperGetMv("MV_NFESD4",.T.,"VV"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe empenho                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[nItem][nPosOp])

	DbSelectArea("SD4")
	DbSetOrder(1)
	If !dbSeek(xFilial("SD4")+aCols[nItem][nPosCod]+aCols[nItem][nPosOp])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ P.E. que permite ativar ou nao a checagem da estrutura ³
		//³ do produto.                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("A103VSG1")
			lValida:=ExecBlock("A103VSG1",.f.,.f.)
			If Valtype(lValida) # "L"
				lValida:=.T.
			EndIf
		EndIf
		If lValida				
			DbSelectArea("SC2")
			DbSetOrder(1)
			If dbSeek(xFilial("SC2")+aCols[nItem][nPosOp])
				cProduto:=SC2->C2_PRODUTO
			EndIf
			DbSelectArea("SG1")
			DbSetOrder(2)
			If (!MsSeek(xFilial("SG1")+aCols[nItem][nPosCod]+cProduto)) .And.  (IIF(nPosOrdem >0 .And. !lPyme,Empty(aCols[nItem][nPosOrdem]),.T.) .Or. !("OS001" $ aCols[nItem][nPosOp]))
				If SubsTr(cNfeSD4,1,1) $ " V"
					cAlerta := OemToAnsi(STR0174)+chr(13)		                  //"O produto digitado n„o faz parte da"
					cAlerta += OemToAnsi(STR0175+cProduto)+chr(13)	              //"Estrutura do Produto "
					cAlerta += OemToAnsi(STR0176+ aCols[nItem][nPosOp] )+chr(13)//"da OP - "
					cAlerta += OemToAnsi(STR0177)+chr(13)		 	              //"Confirma movimenta‡„o ?"
					If MsgYesNo(cAlerta,OemToAnsi(STR0178))			              //"ATENCAO"
						lRetorno :=.T.
					EndIf
				Else
					If SubsTr(cNfeSD4,1,1) == "S"
						lRetorno := .T.
					ElseIf SubsTr(cNfeSD4,1,1) == "N"
						cAlerta := OemToAnsi(STR0174)+chr(13)		        	//"O produto digitado nao faz parte da"
						cAlerta += OemToAnsi(STR0175+cProduto)+chr(13)	    	//"Estrutura do Produto "
						cAlerta += OemToAnsi(STR0176+ aCols[nItem][nPosOp])	//"da OP - "
						Aviso(OemToAnsi(STR0178),cAlerta,{"Ok"})
						lRetorno := .F.
					EndIf
				EndIf	
			Else
				lRetorno :=.T.
			EndIf
			DbSelectArea("SG1")
			DbSetOrder(1)
		Else
			lRetorno := .T.				
		EndIf
	Else
		While !EOF() .And. SD4->(D4_FILIAL+D4_COD+D4_OP) == xFilial("SD4")+aCols[nItem][nPosCod]+aCols[nItem][nPosOp]
			nQuantD4 += SD4->D4_QUANT
			
			SD4->(dbSkip())
		End
		If nQuantD4 < aCols[nItem][nPosQuant] .And. Posicione("SB1",1,xFilial("SB1")+aCols[nItem][nPosCod],"B1_TIPO") # "BN"
			If SubsTr(cNfeSD4,2,1) $ " V"
				cAlerta := OemToAnsi(STR0179+Transform(nQuantD4,PesqPict("SD1","D1_QUANT")))+chr(13) //"A quantidade empenhada"
				cAlerta += OemToAnsi(STR0180)+chr(13)														//"e menor que a quantidade do item"
				cAlerta += OemToAnsi(STR0177)+chr(13)														//"Confirma movimenta‡„o ?"
				If MsgYesNo(cAlerta,OemToAnsi(STR0178))														//"ATENCAO"
					lRetorno :=.T.
				EndIf
			ElseIf SubsTr(cNfeSD4,2,1) == "S"
				lRetorno := .T.			
			ElseIf SubsTr(cNfeSD4,2,1) == "N"
				cAlerta := OemToAnsi(STR0179+Transform(nQuantD4,PesqPict("SD1","D1_QUANT")))+chr(13) //"A quantidade empenhada"
				cAlerta += OemToAnsi(STR0180)																//"e menor que a quantidade do item"
				Aviso(OemToAnsi(STR0178),cAlerta,{"Ok"})
				lRetorno := .F.
			EndIf	
		Else
			lRetorno := .T.
		EndIf
	EndIf

EndIf

RestArea(aArea)
Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A103Line  ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do documento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103Line(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103Line(nAT,aSF2)

Static oNoMarked := LoadBitmap( GetResources(),'LBNO'			)
Static oMarked	  := LoadBitmap( GetResources(),'LBOK'			)
Local abLine     := {}
Local nCnt       := 0

For nCnt := 1 To Len(aSF2[nAT])
	If nCnt == 1
		Aadd( abLine, Iif(aSF2[ nAT, nCnt ] , oMarked, oNoMarked ) )
	Else
		Aadd( abLine, aSF2[ nAT, nCnt ] )
	EndIf
Next nCnt

Return abLine

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A103RetNF ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as notas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103RetNF(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Campos que deverao ser apresentados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A103RetNF(aCpoSF2,dDataDe,dDataAte,lFilCliFor,lAllCliFor)

Local aSF2      := {}
Local aAux      := {}
Local nCnt      := 0
Local cAliasSF2 := 'SF2'
Local cQuery    := ''
Local cIndex    := ''
Local nIndexSF2 := 0
Local lFlagDev	:= SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)

#IFDEF TOP
	cAliasSF2 := GetNextAlias()
	If ExistBlock("MT103DEV")//Ponto de entrada para complemento de filtro na query
       cQuery := ExecBlock("MT103DEV",.F.,.F.,{dDataDe,dDataAte})
    Else
	   cQuery := " SELECT * "
	   cQuery += "   FROM " + RetSqlName("SF2")
	   cQuery += "   WHERE F2_FILIAL  = '" + xFilial("SF2") + "' "
	   cQuery += "     AND F2_TIPO <> 'D' "

       If !lAllCliFor
	       If lFilCliFor 		
	          cQuery += " AND F2_TIPO <> 'B' "
	       Else
	          cQuery += " AND F2_TIPO <> 'N' "                  
	       EndIf
       EndIf

	   cQuery += "     AND F2_CLIENTE = '" + cCliente + "' "
	   cQuery += "     AND F2_LOJA    = '" + cLoja    + "' "
	   cQuery += "     AND F2_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
	   If lFlagDev
		   cQuery += "     AND F2_FLAGDEV <> '1' "
	   Endif
	   cQuery += "     AND D_E_L_E_T_ = ' ' "
	   cQuery += "     ORDER BY F2_FILIAL,F2_DOC,F2_SERIE "
	EndIf
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSF2, .F., .T. )
#ELSE
	DbSelectArea("SF2")
	cIndex := CriaTrab(NIL,.F.)
	If ExistBlock("MT103DEV")//Ponto de entrada para complemento de filtro na query
       cQuery := ExecBlock("MT103DEV",.F.,.F.,{dDataDe,dDataAte})
    Else
	   cQuery := " F2_FILIAL == '" + xFilial("SF2") + "' "
	   cQuery += " .And. F2_TIPO <> 'D' "

       If !lAllCliFor
	       If lFilCliFor
	          cQuery += ".And. F2_TIPO <> 'B' "
	       Else
	          cQuery += ".And. F2_TIPO <> 'N' "
	       EndIf
       EndIf 

	   cQuery += " .And. F2_CLIENTE == '" + cCliente + "' "
	   cQuery += " .And. F2_LOJA    == '" + cLoja    + "' "
	   cQuery += " .And. DtoS(F2_EMISSAO) >= '" + DtoS(dDataDe)  + "'"
	   cQuery += " .And. DtoS(F2_EMISSAO) <= '" + DtoS(dDataAte) + "' "
	   If lFlagDev
		   cQuery += " .And. F2_FLAGDEV <> '1' "	   
	   Endif
	EndIf
	IndRegua("SF2",cIndex,"F2_FILIAL+F2_DOC+F2_SERIE",,cQuery)
	SF2->(DbGotop())
#ENDIF

While (cAliasSF2)->(!Eof())
	aAux := {}
	Aadd( aAux, .F. )
	For nCnt := 1 To Len(aCpoSF2)
		Aadd( aAux, &(aCpoSF2[nCnt]) )
	Next nCnt
	aAdd( aSF2, aClone(aAux) )
	(cAliasSF2)->(DbSkip())
EndDo

#IFDEF TOP
	(cAliasSF2)->(DbCloseArea())
#ELSE
	RetIndex( "SF2" )
	FErase( cIndex+OrdBagExt() )
#ENDIF

Return aSF2

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A103FRet ³ Autor ³ Eduardo de Souza      ³ Data ³ 20/07/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro para retornar de doctos fiscais.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103FRet()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A103FRet(lCliFor,dDataDe,dDataAte,lFilCliFor,lAllCliFor)

Local oDlgEsp
Local oCliente
Local oFornece
Local oDocto
Local lDocto   := .T.
Local nOpcao   := 0
Local aSize    := MsAdvSize(.F.)
Private cCodCli  := CriaVar("F2_CLIENTE",.F.)
Private cLojCli  := CriaVar("F2_LOJA",.F.)
Private cCodFor  := CriaVar("F1_FORNECE",.F.)
Private cLojFor  := CriaVar("F1_LOJA",.F.)

DEFINE MSDIALOG oDlgEsp From aSize[7],0 To aSize[6]/1.5,aSize[5]/1.5 OF oMainWnd PIXEL TITLE STR0099

@ 06,005 SAY RetTitle("F2_CLIENTE") PIXEL
@ 05,040 MSGET cCodCli F3 'SA1' SIZE 95,10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA1',cCodCli+AllTrim(cLojCli),1)  WHEN Empty(cCodFor)

@ 06,145 SAY RetTitle("F2_LOJA") PIXEL
@ 05,160 MSGET cLojCli SIZE 20,10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA1',cCodCli+AllTrim(cLojCli),1)  WHEN Empty(cLojFor)

@ 21,005 SAY RetTitle("F1_FORNECE") PIXEL
@ 20,040 MSGET cCodFor F3 'FOR' SIZE 95, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+AllTrim(cLojFor),1)  WHEN Empty(cCodCli)

@ 21,145 SAY RetTitle("F1_LOJA") PIXEL
@ 20,160 MSGET cLojFor SIZE 20, 10 OF oDlgEsp PIXEL VALID Vazio() .Or. ExistCpo('SA2',cCodFor+AllTrim(cLojFor),1) WHEN Empty(cLojCli)

@ 36,05 SAY STR0181 PIXEL
@ 35,40 MSGET dDataDe PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL

@ 36,120 SAY STR0182 PIXEL
@ 35,160 MSGET dDataAte PICTURE "@D" SIZE 60, 10 OF oDlgEsp PIXEL

@ 060,005 TO __DlgHeight(oDlgEsp)-045,__DlgWidth(oDlgEsp)-5 LABEL STR0185 OF oDlgEsp PIXEL // 'Tipo de Selecao'

//-- 'Cliente'
@ 85,010 CHECKBOX oCliente VAR lCliFor PROMPT AllTrim(RetTitle("F2_CLIENTE"))+" / "+AllTrim(RetTitle("F1_FORNECE")) SIZE 100,010 ON CLICK( lDocto := .F., oDocto:Refresh() ) OF oDlgEsp PIXEL

//-- 'Documento'
@ 85,__DlgWidth(oDlgEsp)-60 CHECKBOX oDocto VAR lDocto PROMPT OemToAnsi(STR0184) SIZE 50,010 ON CLICK( lCliFor := .F., oCliente:Refresh() ) OF oDlgEsp PIXEL

DEFINE SBUTTON FROM 05,__DlgWidth(oDlgEsp)-50 TYPE 1 OF oDlgEsp ENABLE PIXEL ACTION ;
Eval({||cCliente := IIF(Empty(cCodCli),cCodFor,cCodCli),;
cLoja := IIF(Empty(cLojCli),cLojFor,cLojCli),;
IIF(Empty(cCliente).And.Empty(cLoja),lAllCliFor:=.T.,lAllCliFor:=.F.),;
IIF(!Empty(cCodCli),lFilCliFor:=.T.,lFilCliFor:=.F.),.t.});
.and.If((!Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(dDataDe) .And. !Empty(dDataAte) .And. lCliFor) .Or.;
lDocto,(nOpcao := 1,oDlgEsp:End()),.F.)

DEFINE SBUTTON FROM 20,__DlgWidth(oDlgEsp)-50 TYPE 2 OF oDlgEsp ENABLE PIXEL ACTION (nOpcao := 0,oDlgEsp:End())

ACTIVATE MSDIALOG oDlgEsp CENTERED



Return ( nOpcao == 1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103Conhec³ Autor ³Sergio Silveira        ³ Data ³15/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada da visualizacao do banco de conhecimento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Conhec()                                                ³±±
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

Static Function A103Conhec()

Local aRotBack := AClone( aRotina )
Local nBack    := N

Private aRotina := {}

Aadd(aRotina,{STR0187,"MsDocument", 0 , 2}) //"Conhecimento"

MsDocument( "SF1", SF1->( Recno() ), 1 )

aRotina := AClone( aRotBack )
N := nBack

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ A103TrFil                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 08/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Verifica se o movimento e de transferencia entre filiais   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³cTes       Codigo da tes que esta sendo avaliada            ³±±
±±³           ³cTipo      Tipo da nota que esta sendo avaliada             ³±±
±±³           ³cClifor    Codigo do cliente/fornecedor avaliado            ³±±
±±³           ³cLoja      Loja do cliente/fornecedor avaliado              ³±±
±±³           ³cDoc       Documento avaliado                               ³±±
±±³           ³cSerie     Serie do documento avaliado                      ³±±
±±³           ³cCod       Codigo do produto do documento avaliado          ³±±
±±³           ³nQuant     Quantidade do documento avaliado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103TrFil(cTes,cTipo,cCliFor,cLoja,cDoc,cSerie,cCod,nQuant)
Local lRet       := .T.
Local cCGC       := ""
Local cCGCOri    := ""
Local cArqCliFor := ""
Local cAchoCGC   := ""
Local cAchoCli   := ""
Local cAchoLoja  := ""
Local cFilBack   := cFilAnt
Local aArea      := GetArea()
Local aAreaSM0   := SM0->(GetArea())
Local lAchoCli   := .F.
Local lPoder3    := .F.
Local lUsaFilTrf := IIF(FindFunction('UsaFilTrf'), UsaFilTrf(), .F.)
Local cCodFil    := ""
Local cCodFilOri := ""
Local cAchoFil   := ""
Local cIndex     := "" 
Local cArqIdx    := ""
Local nIndex     := 0

If SF4->(MsSeek(xFilial("SF4")+cTes)) .And. SF4->F4_TRANFIL == "1" 

	// Verifica se utiliza poder de terceiros
	lPoder3 := (SF4->F4_PODER3 $ "R|D") 
	
	If !lUsaFilTRF // procedimento padrao, localizar filial atraves do CNPJ do cliente/fornecedor

		// Itens de nota fiscal de entrada
		If cTipo $ "DB"
			cArqCliFor:="SA2" // Cliente na nota fiscal de entrada fornecedor na nota de saida
			DbSelectArea("SA1")
			DbSetOrder(1)
			If MsSeek(xFilial("SA1")+cCliFor+cLoja)
				cCGC:=SA1->A1_CGC
			EndIf
		Else
	   		cArqCliFor:="SA1" // Fornecedor na nota fiscal de entrada cliente na nota de saida
	   		
			DbSelectArea("SA2")
			DbSetOrder(1)
			If MsSeek(xFilial("SA2")+cCliFor+cLoja)
				cCGC:=SA2->A2_CGC
			EndIf
		EndIf
		// Checa se cliente / fornecedor esta configurado como filial do sistema
	   	If !Empty(cCGC) .And. !lPoder3
				DbSelectArea("SM0")
				dbSeek(cEmpAnt)
				Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
					// Verifica codigo da filial caso encontre CGC
					If SM0->M0_CGC == cCGC
//						cAchoCGC:=FWGETCODFILIAL
						cAchoCGC:=FWCodfil()
						Exit
					EndIf
					dbSkip()
				End
			RestArea(aAreaSM0)
			// Obtem o CGC da filial da nota fiscal de entrada
//			If SM0->M0_CODIGO+FWGETCODFILIAL == cEmpAnt+cFilAnt
			If SM0->M0_CODIGO+FWCodfil() == cEmpAnt+cFilAnt
				cCGCOri:=SM0->M0_CGC
			Else
				dbSeek(cEmpAnt)
				Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
					// Verifica codigo da filial caso encontre CGC
//					If FWGETCODFILIAL == cFilAnt
					If FWCodfil() == cFilAnt
						cCGCOri:=SM0->M0_CGC
						Exit
					EndIf
					dbSkip()
				End
				RestArea(aAreaSM0)
			EndIf	
			// Caso achou procura documento na filial
			If !Empty(cAchoCGC)
				// Muda para filial de saida do documento
				cFilAnt:=cAchoCGC
				// Obtem codigo do cliente/fornecedor atraves do CGC
				DbSelectArea(cArqCliFor)
				DbSetOrder(3)
				If MsSeek(xFilial(cArqClifor)+IIf(Type("l310PODER3") == "L" .And. l310PODER3, cCGC, cCGCOri))
	   				lAchoCli := CliForOrig(cArqClifor, @cAchoCli, @cAchoLoja)
					If lAchoCli
						// Pesquisa documento
						DbSelectArea("SD2")
						DbSetOrder(3)
						If dbSeek(xFilial("SD2")+cDoc+cSerie+cAchoCli+cAchoLoja+cCod)
							lRet:=.F.
							While !Eof() .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD == xFilial("SD2")+cDoc+cSerie+cAchoCli+cAchoLoja+cCod
								If QtdComp(nQuant) == QtdComp(SD2->D2_QUANT)
									lRet:=.T.
									Exit
								EndIf
								dbSkip()
							End
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para nao validar Qtde divergente SD1 x SD2  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ExistBlock("A103VLQT")
								lRet := ExecBlock("A103VLQT",.F.,.F.,{lRet})
								If ValType(lRet) <> "L"
									lRet := .F.
								EndIf
							EndIf
							If !lRet
								Aviso(STR0119,STR0199,{"Ok"},1)
							EndIf
						Else
							lRet:=.F.
							Aviso(STR0119,STR0200,{"Ok"},1)
						EndIf
					Else
						lRet:=.F.
						Aviso(STR0119,STR0200,{"Ok"},1)
					EndIf
				Else
					lRet:=.F.
					Aviso(STR0119,STR0201,{"Ok"},1)
				EndIf
			Else
				lRet:=.F.
				Aviso(STR0119,STR0203,{"Ok"},1)
			EndIf
		ElseIf !lPoder3
			lRet:=.F.
			Aviso(STR0119,STR0202,{"Ok"},1)
		EndIf

	Else // procedimento novo, localizar a filial atraves dos campos A1_FILTRF e A2_FILTRF
	    
	    cCodFil    := ""
	    cCodFilOri := ""

		// Itens de nota fiscal de entrada
		If cTipo $ "DB"
			cArqCliFor:="SA2" // Cliente na nota fiscal de entrada fornecedor na nota de saida
			DbSelectArea("SA1")
			DbSetOrder(1)
			If MsSeek(xFilial("SA1")+cCliFor+cLoja)
				cCodFil := SA1->A1_FILTRF
			EndIf
		Else
	   		cArqCliFor:="SA1" // Fornecedor na nota fiscal de entrada cliente na nota de saida
			DbSelectArea("SA2")
			DbSetOrder(1)
			If MsSeek(xFilial("SA2")+cCliFor+cLoja)
				cCodFil := SA2->A2_FILTRF
			EndIf
		EndIf
		// Checa se cliente / fornecedor esta configurado como filial do sistema
		If !Empty(cCodFil) .And. !lPoder3
			DbSelectArea("SM0")
			dbSeek(cEmpAnt)
			Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
				// Verifica codigo da filial caso encontre
				If Trim(SM0->M0_CODFIL) == Trim(cCodFil)
//					cAchoFil := FWGETCODFILIAL
					cAchoFil := FWCodfil()
					Exit
				EndIf
				dbSkip()
			End
			RestArea(aAreaSM0)
			// Obtem o codigo da filial da nota fiscal de entrada
//			If SM0->M0_CODIGO+FWGETCODFILIAL == cEmpAnt+cFilAnt
//				cCodFilOri := FWGETCODFILIAL
			If SM0->M0_CODIGO+FWCodfil() == cEmpAnt+cFilAnt
				cCodFilOri := FWCodfil()
			Else
				dbSeek(cEmpAnt)
				Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
					// Verifica codigo da filial caso encontre CGC
//					If FWGETCODFILIAL == cFilAnt
//						cCodFilOri := FWGETCODFILIAL
					If FWCodfil() == cFilAnt
						cCodFilOri := FWCodfil()
						Exit
					EndIf
					dbSkip()
				End
				RestArea(aAreaSM0)
			EndIf
			// Caso achou procura documento na filial
			If !Empty(cAchoFil)
				
				// Muda para filial de saida do documento
				cFilAnt:=cAchoFil
				// Obtem codigo do cliente/fornecedor
				DbSelectArea(cArqCliFor)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta filtro e indice temporario na SA1 ou SA2               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cArqCliFor == "SA1"
					cIndex := "A1_FILIAL+A1_FILTRF"
				Else
					cIndex := "A2_FILIAL+A2_FILTRF"
				EndIf
				
				cArqIdx := CriaTrab(,.F.)
				IndRegua(cArqCliFor, cArqIdx, cIndex,,,STR0283) //"Selecionando Registros ..."
				nIndex := RetIndex(cArqCliFor)
				#IFNDEF TOP
					dbSetIndex(cArqIdx+OrdBagExt())
				#ENDIF
				dbSetOrder(nIndex+1) // A1_FILIAL+A1_FILTRF ou A2_FILIAL+A2_FILTRF
				If dbSeek(xFilial(cArqClifor)+IIf(Type("l310PODER3") == "L" .And. l310PODER3, cCodFil, cCodFilOri))
					lAchoCli := CliForOrig(cArqClifor, @cAchoCli, @cAchoLoja, lUsaFilTrf)
					If lAchoCli
						// Pesquisa documento
						DbSelectArea("SD2")
						DbSetOrder(3)
						If dbSeek(xFilial("SD2")+cDoc+cSerie+cAchoCli+cAchoLoja+cCod)
							lRet:=.F.
							While !Eof() .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD == xFilial("SD2")+cDoc+cSerie+cAchoCli+cAchoLoja+cCod
								If QtdComp(nQuant) == QtdComp(SD2->D2_QUANT)
									lRet:=.T.
									Exit
								EndIf
								dbSkip()
							End
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para nao validar Qtde divergente SD1 x SD2  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ExistBlock("A103VLQT")
								lRet := ExecBlock("A103VLQT",.F.,.F.,{lRet})
								If ValType(lRet) <> "L"
									lRet := .F.
								EndIf
							EndIf
							If !lRet
								Aviso(STR0119,STR0199,{"Ok"},1)
							EndIf
						Else
							lRet:=.F.
							Aviso(STR0119,STR0200,{"Ok"},1)
						EndIf
					Else
						lRet:=.F.
						Aviso(STR0119,STR0200,{"Ok"},1)
					EndIf
				Else
					lRet:=.F.
					Aviso(STR0119,STR0201,{"Ok"},1)
				EndIf
			
				dbSelectArea(cArqCliFor)
				RetIndex(cArqCliFor)
				Ferase( cArqIdx + OrdBagExt() )
			
			Else
				lRet:=.F.
				Aviso(STR0119,STR0203,{"Ok"},1)
			EndIf
		ElseIf !lPoder3
			lRet:=.F.
			Aviso(STR0119,STR0202,{"Ok"},1)
		EndIf
		
	EndIf
EndIf
RestArea(aArea)

cFilAnt:=cFilBack
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103PrCom³ Autor ³ Nereu Humberto Junior ³ Data ³03.03.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compatibilizacao dos parametros MV_ALTPREC e MV_ALTPRCC   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA120 e MATA103                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103PrCom()

Local aArea     := GetArea()
Local cContOrig := "0"

DbSelectArea("SX6")
If !GetMV("MV_ALTPRCC",.T.)
	If GetMV("MV_ALTPREC",.T.) .And. Alltrim(SX6->X6_CONTEUD) $ "0123456"
		cContOrig:=GetMV("MV_ALTPREC")
		PutMv("MV_ALTPREC","T")
	Endif
	RecLock( "SX6",.T. )
	SX6->X6_FIL     := xFilial( "SX6" )
	SX6->X6_VAR     := "MV_ALTPRCC"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Permite alterar o preco que veio sugerido do"
	SX6->X6_DESC1   := "pedido de compras, autorizacao de entrega ou"
	SX6->X6_DESC2   := "contrato de parceria."
	SX6->X6_DSCSPA  := "Permite modificar precio que vino sugerido"
	SX6->X6_DSCSPA1 := "de pedido de compras, autorizacion de entre-"
	SX6->X6_DSCSPA2 := "ga o contrato de asociacion."
	SX6->X6_DSCENG  := "Allows editing the price suggested from the"
	SX6->X6_DSCENG1 := "purchase order, delivery authorization or"
	SX6->X6_DSCENG2 := "partnership contract."
	SX6->X6_CONTEUD := cContOrig
	SX6->X6_CONTSPA := cContOrig
	SX6->X6_CONTENG := cContOrig
	MsUnLock()
EndIf

RestArea(aArea)

Return(GetMV("MV_ALTPRCC"))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuSRK³ Autor ³ Eduardo Riera         ³ Data ³14.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de integracao com a folha de pagamento                ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Codigo da operação                                    ³±±
±±³          ³       [1] Inclusao de Verba                                 ³±±
±±³          ³       [2] Exclusao de Verba                                 ³±±
±±³          ³ExpA2: Header das duplicatas                                 ³±±
±±³          ³ExpA3: aCols das duplicatas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a integracao entre o   ³±±
±±³          ³documento de entrada e os titulos financeiros.               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103AtuSRK(nOpcA,aHeadSE2,aColsse2)

Local aArea     := GetArea()
Local aCodFol   := {}
Local cVerbaFol := ""
Local cDocFol   := ""
Local nParcela  := 0
Local nValor    := MaFisRet(,"NF_BASEDUP")
Local aRecSRK   := {}
Local nX        := 0
Local nPVencto  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"})
Local nPValor   := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VALOR"})


Do Case
Case nOpcA == 1 .And. nValor > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica o funcionario                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SRA")
	DbSetOrder(13)
	If MsSeek(SF1->F1_NUMRA) .And. FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem o código da verba                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerbaFol := aCodFol[218,001] //Pagamento de autonomos
		If !Empty(cVerbaFol)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o proximo numero de documento                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SRK")
			DbSetOrder(1)
			MsSeek(xFilial("SRK")+SF1->F1_NUMRA+Soma1(cVerbaFol),.T.)
			dbSkip(-1)
			If xFilial("SRK")+SF1->F1_NUMRA+cVerbaFol == xFilial("SRK")+SRK->RK_MAT+SRK->RK_PD
				cDocFol := Soma1(SRK->RK_DOCUMEN)
			Else
				cDocFol := StrZero(1,Len(SRK->RK_DOCUMEN))
			EndIf
			For nX := 1 To Len(aColsSE2)
				RecLock("SRK",.T.)
				SRK->RK_FILIAL  := xFilial("SRK")
				SRK->RK_MAT     := SF1->F1_NUMRA
				SRK->RK_PD      := cVerbaFol
				SRK->RK_VALORTO := aColsSE2[nX][nPValor]
				SRK->RK_PARCELA := nX
				SRK->RK_VALORPA := aColsSE2[nX][nPValor]
				SRK->RK_DTMOVI  := dDataBase
				SRK->RK_DTVENC  := aColsSE2[nX][nPVencto]
				SRK->RK_DOCUMEN := cDocFol
				SRK->RK_CC      := SRA->RA_CC
				MsUnLock()
			Next nX
			RecLock("SF1")
			SF1->F1_DOCFOL   := cDocFol
			SF1->F1_VERBAFO  := cVerbaFol
			MsUnLock()				
		EndIf
	EndIf	
Case nOpcA == 2 .And. !Empty(SF1->F1_NUMRA) .And. !Empty(SF1->F1_DOCFOL)	
	DbSelectArea("SRA")
	DbSetOrder(13)
	If MsSeek(SF1->F1_NUMRA)
		cVerbaFol := SF1->F1_VERBAFO
		If !Empty(cVerbaFol)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analise se o documento foi pago                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SRK")
			DbSetOrder(1)
			If MsSeek(xFilial("SRK")+SF1->F1_NUMRA+cVerbaFol+SF1->F1_DOCFOL)
				While !Eof() .And. xFilial("SRK") == SRK->RK_FILIAL .And.;
						SF1->F1_NUMRA == SRK->RK_MAT .And.;
						cVerbaFol == SRK->RK_PD .And.;
						SF1->F1_DOCFOL == SRK->RK_DOCUMEN

					aadd(aRecSRK,SRK->(Recno()))

					DbSelectArea("SRK")
					dbSkip()
				EndDo
				For nX := 1 To Len(aRecSRK)

					SRK->(MsGoto(aRecSRK[nX]))

					RecLock("SRK")
					If SRK->RK_VLRPAGO == 0
						dbDelete()
						MsUnLock()
					Else
						nValor := SRK->RK_VALORTO

						DbSelectArea("SRK")
						DbSetOrder(1)
						MsSeek(xFilial("SRK")+SF1->F1_NUMRA+cVerbaFol+Soma1(SF1->F1_DOCFOL),.T.)
						dbSkip(-1)
						nParcela := SRK->RK_PARCELA+1

						RecLock("SRK",.T.)
						SRK->RK_FILIAL  := xFilial("SRK")
						SRK->RK_MAT     := SF1->F1_NUMRA
						SRK->RK_PD      := cVerbaFol
						SRK->RK_VALORTO := -1*nValor
						SRK->RK_PARCELA := nParcela
						SRK->RK_VALORPA := -1*nValor
						SRK->RK_DTMOVI  := dDataBase
						SRK->RK_DTVENC  := dDataBase
						SRK->RK_DOCUMEN := cDocFol
						SRK->RK_CC      := SRA->RA_CC
						MsUnLock()
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf
EndCase
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ A103AtuCauc( )                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Sergio Silveira                          ³ Data ³ 08/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Atualiza a movimentacao de caucao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³A103AtuCauc(ExpN1,ExpA2,ExpA3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8,³±±
±±³           ³ ExpN9 )                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpN1 -> Codigo da operacao : 1 - Inclusao / 2 - Exclusao   ³±±
±±³           ³ExpA2 -> Contratos do documento fiscal                      ³±±
±±³           ³ExpA3 -> Array com os recnos dos titulos gerados            ³±±
±±³           ³ExpC4 -> Codigo do fornecedor                               ³±±
±±³           ³ExpC5 -> Loja do fornecedor                                 ³±±
±±³           ³ExpC6 -> Numero da NF                                       ³±±
±±³           ³ExpC7 -> Serie da NF                                        ³±±
±±³           ³ExpC8 -> Data de emissao                                    ³±±
±±³           ³ExpN9 -> Valor bruto da NF                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function A103AtuCauc( nOper, aContratos, aRecGerSE2, cFornece, cLoja, cNFiscal, cSerie, dDEmissao, nValBrut )

Local nLoop := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua o processamento apenas se gerar titulos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty( aRecGerSE2 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre os contratos da NF de entrada                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 to Len( aContratos )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera os abatimentos das caucoes                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CtaAbatCauc( nOper, aContratos[ nLoop ], aRecGerSE2, cFornece, cLoja, cNFiscal, cSerie, dDEmissao, nValBrut )
	Next nLoop

EndIf 	

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ A103GetContr( )                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Sergio Silveira                          ³ Data ³ 08/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Obtem os contratos de uma nota ( grupo de SD1 )            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ A103GetContr( ExpA1, ExpA2 )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpA1 -> Array contendo os recnos do SD1                    ³±±
±±³           ³ExpA2 -> Array com os codigos dos contratos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function A103GetContr( aRecSD1, aContratos )

Local nLoop := 0

For nLoop := 1 To Len( aRecSD1 )

	SD1->( MsGoto( aRecSD1[ nLoop,1 ] ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pedido de Compra                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SD1->D1_PEDIDO)
		DbSelectArea("SC7")
		DbSetOrder(19)
		If MsSeek(xFilial("SC7")+SD1->D1_COD+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena os contratos desta NF ( gestao de contratos )                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Empty( AScan( aContratos, {|x| x[1] == SC7->C7_CONTRA .And. x[2] == SC7->C7_CONTREV } ) )
				AAdd( aContratos, { SC7->C7_CONTRA, SC7->C7_CONTREV } ) 				
			EndIf
		EndIf
	EndIf		

Next nLoop 	

Return( nil )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103Multas³ Autor ³ Sergio Silveira       ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecao e aplicacao de multas do modulo SIGAGCT              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Multas( ExpD1, ExpC2, ExpC3, ExpA4 )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 -> Data de emissao                                    ³±±
±±³          ³ ExpC2 -> Codigo do fornecedor                               ³±±
±±³          ³ ExpC3 -> Loja do fornecedor                                 ³±±
±±³          ³ ExpA4 -> Array de multas do documento de entrada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103Multas(dDEmissao,cA100For,cLoja,aMultas)

Local aArea      := GetArea()
Local aListBox   := {}
Local aContratos := {}
Local aMedicoes  := {}

Local bSavSetKey := SetKey(VK_F4,Nil)
Local bSavKeyF5  := SetKey(VK_F5,Nil)
Local bSavKeyF6  := SetKey(VK_F6,Nil)
Local bSavKeyF7  := SetKey(VK_F7,Nil)
Local bSavKeyF8  := SetKey(VK_F8,Nil)
Local bSavKeyF9  := SetKey(VK_F9,Nil)
Local bSavKeyF10 := SetKey(VK_F10,Nil)
Local bSavKeyF11 := SetKey(VK_F11,Nil)

Local cQuery     := ""
Local cAliasQry  := ""

Local nOpca      := 0
Local nLoop      := 0
Local nPosPedido := GDFieldPos( "D1_PEDIDO" )
Local nPosItem   := GDFieldPos( "D1_ITEMPC" )

Local lProcessa  := .F.

Local oOk        := LoadBitmap( GetResources(), "LBOK" )
Local oNOk       := LoadBitmap( GetResources(), "LBNO" )
Local oDlgMult
Local oList

Local oBold
Local oBmp
Local oBut1
Local oBut2

SC7->( DbSetOrder( 1 ) ) 		

For nLoop := 1 to Len( aCols )

	If !ATail( aCols[ nLoop ] ) 	

		If SC7->( MsSeek( xFilial( "SC7" ) + aCols[ nLoop, nPosPedido ] + aCols[ nLoop, nPosItem ] ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alimenta o array de medicoes / item desta NF                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If !Empty( SC7->C7_CONTRA ) .And. !Empty( SC7->C7_PLANILH )
				If Empty( AScan( aMedicoes, { |x| x[1] == SC7->C7_CONTRA .And. x[2] == SC7->C7_CONTREV .And. ;
						x[3] == SC7->C7_PLANILH .And. x[4] == SC7->C7_MEDICAO .And. x[5] == SC7->C7_ITEMED } ) )
					AAdd( aMedicoes, { SC7->C7_CONTRA, SC7->C7_CONTREV, SC7->C7_PLANILH, SC7->C7_MEDICAO, SC7->C7_ITEMED } )
				EndIf		

				If Empty( AScan( aContratos, SC7->C7_CONTRA ) )
					AAdd( aContratos, SC7->C7_CONTRA )
				EndIf		

			EndIf

		EndIf

	EndIf 	

Next nLoop

If !Empty( aMedicoes ) .Or. !Empty( aMultas )

	If Empty( aMultas ) 	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa as multas                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A103ProcMul( aMedicoes, @aListBox )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as multas do array                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AEval( aMultas, { |x| AAdd( aListBox,  { .T., x[1], x[2], x[3], x[4], x[5] } ) } )
	EndIf 	

	If Empty( aListBox )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se estiver vazio, preenche uma linha em branco                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aListBox, { .F., "", "", 0, 0, "" } )
	EndIf 	

	DEFINE MSDIALOG oDlgMult TITLE STR0226 FROM 0,0 TO 400, 700 OF oMainWnd PIXEL // "Selecao de multas"

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

	@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgMult SIZE 55, 1000 NOBORDER WHEN .F. PIXEL

	@ 03, 40 SAY STR0227 FONT oBold PIXEL // "Selecao de multas aplicadas ao documento de entrada"

	@ 14, 30 TO 16 ,400 LABEL '' OF oDlgMult PIXEL

	@ 24, 223 BUTTON STR0228   SIZE 35,11 ACTION A103RepMult( oList, @aListBox, aMedicoes ) OF oDlgMult PIXEL //"Reprocessar"
	@ 24, 265 BUTTON STR0251   SIZE 35,11 ACTION A103AltMul( oList, @aListBox, aContratos ) OF oDlgMult PIXEL // "Alterar"
	@ 24, 307 BUTTON STR0229   SIZE 35,11 ACTION A103AdMult( oList, @aListBox, aContratos ) OF oDlgMult PIXEL // "Adicionar"

	oList := TWBrowse():New( 43, 40, 303, 125,,{ "", "Tipo", STR0230, STR0231, STR0232,STR0233 },,oDlgMult,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // "Tipo", "Contrato", "Descricao", "Valor","Insercao"

	oList:SetArray(aListBox)
	oList:bLine := { || { If( aListBox[oList:nAT,1], oOk, oNOK ), If( aListBox[oList:nAt,6] == "1", "Multa    ","Bonificacao" ), aListBox[oList:nAT,2], aListBox[oList:nAT,3], Transform( aListBox[oList:nAT,4],"@E 999,999,999.99" ), If( aListBox[oList:nAT,5] == 1,STR0234,If( aListBox[oList:nAT,5] == 2,STR0235,"" ) ) } } // "Automatica",	"Manual"
	oList:bLDblClick := { || aListBox[oList:nAt,1] := If( Empty( aListBox[ oList:nAt,2 ]), aListBox[oList:nAt,1],!aListBox[oList:nAt,1] ) }

	DEFINE SBUTTON oBut2 FROM 178, 280 TYPE 1 ACTION ( nOpca := 1, oDlgMult:End() )  ENABLE of oDlgMult		
	DEFINE SBUTTON oBut3 FROM 178, 312 TYPE 2 ACTION ( nOpca := 0, oDlgMult:End() )  ENABLE of oDlgMult

	ACTIVATE MSDIALOG oDlgMult CENTERED

	If nOpca == 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as multas no array aMultas                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aMultas := {}

		For nLoop := 1 to Len( aListBox )

			If aListBox[ nLoop, 1 ]
				AAdd( aMultas, { aListBox[nLoop,2],aListBox[nLoop,3], aListBox[nLoop,4], aListBox[nLoop,5], aListBox[nLoop,6] } )
			EndIf

		Next nLoop

	EndIf

Else
	Aviso( STR0236, STR0237, { STR0238 }, 2 ) // "Atencao !", "Nao existem contratos vinculados a este documento de entrada.", "Ok"
EndIf 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados de entrada                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

RestArea( aArea )

Return( .T. )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AdMult³ Autor ³ Sergio Silveira       ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Inclusao de multa avulsa - SIGAGCT                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 -> Objeto listbox                                     ³±±
±±³          ³ ExpA2 -> Array da listbox ( alimentado por referencia )     ³±±
±±³          ³ ExpA3 -> Array de contratos do documento de entrada         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103AdMult( oList, aListBox, aContr )

Local cDescri   := Space( 50 )
Local cContrato := ""

Local nValor    := 0
Local nOpca     := 0

Local oBut1
Local oBut2
Local oBmp
Local oBold
Local oDlgMult
Local oTipo
Local oContrato

aTipos := { STR0256, STR0257 } // "Multa", "Bonificacao"

DEFINE MSDIALOG oDlgMult TITLE STR0239 FROM 0,0 TO 340, 550 OF oMainWnd PIXEL // "Inclusao de multas"

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgMult SIZE 55, 1000 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0240 FONT oBold PIXEL // "Inclusao de multas avulsas"

@ 14, 30 TO 16 ,400 LABEL '' OF oDlgMult   PIXEL

@  30, 40 SAY STR0241 OF oDlgMult PIXEL // "Contrato"
@  40, 40 MSCOMBOBOX oContrato VAR cContrato ITEMS aContr SIZE 100, 36 OF oDlgMult PIXEL

@  60, 40 SAY STR0242 OF oDlgMult PIXEL // "Descricao"
@  70, 40 GET cDescri SIZE 200, 11 VALID NaoVazio( cDescri ) PICTURE "@!" OF oDlgMult PIXEL

@  90, 40 SAY STR0243 OF oDlgMult PIXEL // "Valor"
@ 100, 40 GET nValor SIZE 70, 11   VALID NaoVazio( nValor ) .And. Positivo( nValor ) PICTURE "@E 999,999,999.99" OF oDlgMult PIXEL

@  120, 40 SAY STR0258 OF oDlgMult PIXEL // "Tipo"
@  130, 40 MSCOMBOBOX oTipo VAR cTipo ITEMS aTipos SIZE 100, 36 OF oDlgMult PIXEL

DEFINE SBUTTON oBut1 FROM 150, 207 TYPE 1 ACTION ( If( A103VldMult( cDescri,nValor,cContrato, Str(oTipo:nAt,1) ),( nOpca := 1, cTipo := Str(oTipo:nAt,1) , oDlgMult:End()), ) )  ENABLE of oDlgMult		
DEFINE SBUTTON oBut2 FROM 150, 239 TYPE 2 ACTION ( nOpca := 0, oDlgMult:End() )  ENABLE of oDlgMult

ACTIVATE MSDIALOG oDlgMult CENTERED

If nOpca == 1
	If Len( aListBox ) == 1 .And. Empty( aListBox[ 1, 2 ] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se tiver uma linha em branco, apaga                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aListBox := {}
	EndIf 	
	AAdd( aListBox, { .T., cContrato, cDescri, nValor, 2, cTipo } )

	bLine := oList:bLine
	oList:SetArray(aListBox)
	oList:bLine := bLine

EndIf

Return( .T. )



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AltMul³ Autor ³ Sergio Silveira       ³ Data ³05/05/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Alterecao de multa - SIGAGCT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 -> Objeto listbox                                     ³±±
±±³          ³ ExpA2 -> Array da listbox ( alimentado por referencia )     ³±±
±±³          ³ ExpA3 -> Array de contratos do documento de entrada         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103AltMul( oList, aListBox, aContr )

Local cDescri   := Space( 50 )
Local cContrato := ""
Local cTipo     := ""

Local nValor    := 0
Local nOpca     := 0

Local oBut1
Local oBut2
Local oBmp
Local oBold
Local oDlgMult
Local oContrato

If !( Len( aListBox ) == 1 .And. Empty( aListBox[ 1, 2 ] ) )

	cContrato := aListBox[ oList:nAt, 2 ]
	cDescri   := aListBox[ oList:nAt, 3 ]
	nValor    := aListBox[ oList:nAt, 4 ]
	cTipo     := aListBox[ oList:nAt, 6 ]	

	DEFINE MSDIALOG oDlgMult TITLE STR0252 FROM 0,0 TO 300, 550 OF oMainWnd PIXEL // "Alteracao de multas"

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

	@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgMult SIZE 55, 1000 NOBORDER WHEN .F. PIXEL

	@ 03, 40 SAY STR0252 FONT oBold PIXEL //"Alteracao de multas"

	@ 14, 30 TO 16 ,400 LABEL '' OF oDlgMult   PIXEL

	@  30, 40 SAY STR0241 OF oDlgMult PIXEL // "Contrato"
	@  40, 40 MSCOMBOBOX oContrato VAR cContrato ITEMS aContr SIZE 100, 36 OF oDlgMult PIXEL

	@  60, 40 SAY STR0242 OF oDlgMult PIXEL // "Descricao"
	@  70, 40 GET cDescri SIZE 200, 11 VALID NaoVazio( cDescri ) PICTURE "@!" OF oDlgMult PIXEL

	@  90, 40 SAY STR0243 OF oDlgMult PIXEL // "Valor"
	@ 100, 40 GET nValor SIZE 70, 11   VALID NaoVazio( nValor ) .And. Positivo( nValor ) PICTURE "@E 999,999,999.99" OF oDlgMult PIXEL

	DEFINE SBUTTON oBut1 FROM 130, 207 TYPE 1 ACTION ( If( A103VldMult( cDescri,nValor,cContrato, cTipo ),( nOpca := 1, oDlgMult:End()), ) )  ENABLE of oDlgMult
	DEFINE SBUTTON oBut2 FROM 130, 239 TYPE 2 ACTION ( nOpca := 0, oDlgMult:End() )  ENABLE of oDlgMult

	ACTIVATE MSDIALOG oDlgMult CENTERED

	If nOpca == 1

		aListBox[ oList:nAt, 2 ] := cContrato  		
		aListBox[ oList:nAt, 3 ] := cDescri
		aListBox[ oList:nAt, 4 ] := nValor  		

		bLine := oList:bLine
		oList:SetArray(aListBox)
		oList:bLine := bLine

	EndIf

Else

	Aviso( STR0236, STR0253, { STR0238 } ) // "Atencao", "Este item nao pode ser alterado !", "Ok"

EndIf 	

Return( .T. )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103VldMult³ Autor ³ Sergio Silveira      ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao dos campos de descricao e valor - Inclusao de multa³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 :=  A103VldMult( ExpC2, ExpN3 )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC2 -> Descricao da multa                                 ³±±
±±³          ³ ExpN3 -> Valor da multa                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103VldMult( cDescri, nValor, cContrato, cTipo )

Local cMulMan  := ""
Local lRet     := !Empty( cDescri )

If lRet
	lRet := !Empty( nValor )
EndIf

If !lRet
	Help( " ", 1, "NVAZIO" )
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se permite a inclusao ou alteracao manual deste movimento     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CN9->( DbSetOrder( 1 ) )
	If CN9->( MsSeek( xFilial( "CN9" ) + cContrato ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o tipo de contrato                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CN1->( DbSetOrder( 1 ) )
		If CN1->( MsSeek( xFilial( "CN1" ) + CN9->CN9_TPCTO ) )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se permite multas no recebimento                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CN1->CN1_TPMULT == "1"
				lRet := .T.
			Else
				lRet := .F.	
				Aviso( STR0236, STR0259, { STR0238 }, 2 ) // "Atencao!", "Nao sao permitidas inclusoes ou alteracoes em multas ou bonificacoes deste contrato no recebimento !","Ok"
			EndIf 	

			If lRet

				cMulMan := CN1->CN1_MULMAN

				Do Case
				Case cMulMan == "1"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Nao permite alteracoes manuais                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lRet := .F.
					Aviso( STR0236, STR0260, { STR0238 }, 2 ) // "Atencao!", "Nao sao permitidas inclusoes ou alteracoes em multas ou bonificacoes deste contrato !","Ok"
				Case cMulMan == "2"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Permite apenas multas                                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If cTipo == "1"
						lRet := .T.
					Else
						lRet := .F. 				
						Aviso( STR0236, STR0261, { STR0238 }, 2 ) // "Atencao!", "Nao sao permitidas inclusoes ou alteracoes em bonificacoes deste contrato !", "Ok"
					EndIf

				Case cMulMan == "3"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Permite apenas bonificacoes                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If cTipo == "2"
						lRet := .T.
					Else
						lRet := .F. 				
						Aviso( STR0236, STR0262, {STR0238}, 2 ) // "Atencao!", "Nao sao permitidas inclusoes ou alteracoes em multas deste contrato !", "Ok"
					EndIf

				Case cMulMan == "4"
					lRet := .T.
				EndCase	

			EndIf 					

		EndIf

	EndIf

EndIf

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103RepMult³ Autor ³ Sergio Silveira      ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 -> Objeto listbox                                     ³±±
±±³          ³ ExpA2 -> Array de multas do listbox                         ³±±
±±³          ³ ExpA3 -> Array de medicoes                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua o reprocessamento de multas das medicoes              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103RepMult( oList, aListBox, aMedicoes )

If Aviso( STR0236, STR0244, { STR0245, STR0246 }, 2 ) == 1 // "Atencao !", "Os dados informados serao sobrepostos. Confirma o reprocessamento das multas deste documento de entrada ?", "Sim","Nao"

	aListBox := {} 						
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua o reprocessamento                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A103ProcMul( aMedicoes, @aListBox )

	If Empty( aListBox )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se estiver vazio, preenche uma linha em branco                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aListBox, { .F., "", "", 0, 0, "" } )
	EndIf 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reinicializa o listBox                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bLine := oList:bLine
	oList:SetArray(aListBox)
	oList:bLine := bLine

EndIf

Return( Nil )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103ProcMul³ Autor ³ Sergio Silveira      ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua o processamento de multas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103ProcMul( ExpA1, ExpA2 )                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array contendo as medicoes                         ³±±
±±³          ³ ExpA2 -> Array do listbox de multas a ser preenchido        ³±±
±±³          ³          ( passado por referencia )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103ProcMul( aMedicoes, aListBox )

Local cCompet    := ""
Local cCronog    := ""
Local cAliasQry  := ""
Local cQuery     := ""
Local lProcessa  := .T.  
Local lFormula   := .F.

Local nLoop      := 0
Local nValor     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Percorre os itens das medicoes                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nLoop := 1 to Len( aMedicoes )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no contrato                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	CN9->( DbSetOrder( 1 ) )
	CN9->( MsSeek( xFilial( "CN9" ) + aMedicoes[ nLoop, 1 ] + aMedicoes[ nLoop, 2 ] ) )

	lProcessa := .T. 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de contrato                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CN1->( DbSetOrder( 1 ) )
	If CN1->( MsSeek( xFilial( "CN1" ) + CN9->CN9_TPCTO ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se permite multas no recebimento                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lProcessa := ( CN1->CN1_TPMULT == "1" )
	EndIf

	If lProcessa 		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no item da medicao                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cAliasQry := GetNextAlias()

		cQuery := ""
		cQuery += "SELECT R_E_C_N_O_ CNERECNO FROM " + RetSqlName( "CNE" ) + " CNE "
		cQuery += "WHERE "		
		cQuery += "CNE_FILIAL='" + xFilial( "CNE" )   + "' AND "
		cQuery += "CNE_CONTRA='" + aMedicoes[nLoop,1] + "' AND "
		cQuery += "CNE_REVISA='" + aMedicoes[nLoop,2] + "' AND "
		cQuery += "CNE_NUMERO='" + aMedicoes[nLoop,3] + "' AND "		
		cQuery += "CNE_NUMMED='" + aMedicoes[nLoop,4] + "' AND "		
		cQuery += "CNE_ITEM='"   + aMedicoes[nLoop,5] + "' AND "				
		cQuery += "CNE.D_E_L_E_T_=' '"		

		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .F., .T. )

		If !( cAliasQry )->( Eof() )
			CNE->( MsGoto( ( cAliasQry )->CNERECNO ) )  			
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho da query                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		( cAliasQRY )->( dbCloseArea() )
		DbSelectArea( "CNE" ) 	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o cabecalho da medicao                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CND->( DbSetOrder( 1 ) ) 	
		CND->( MsSeek( xFilial( "CND" ) + aMedicoes[nLoop,1] + aMedicoes[nLoop,2] + aMedicoes[nLoop,3] + aMedicoes[nLoop,4] ) )

		cCompet := CND->CND_COMPET

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o cabecalho da planilha                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CNA->( DbSetOrder( 1 ) ) 	
		CNA->( MsSeek( xFilial( "CNA" ) + aMedicoes[nLoop,1] + aMedicoes[nLoop,2] + aMedicoes[nLoop,3] ) )

		cCronog := CNA->CNA_CRONOG

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no cronograma / competencia                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CNF->( DbSetOrder( 2 ) ) 	
		CNF->( MsSeek( xFilial( "CNF" ) + aMedicoes[nLoop,1] + aMedicoes[nLoop,2] + cCronog + cCompet ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Percorre as multas / bonificacoes deste contrato                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAliasQry := GetNextAlias()
		cQuery := ""

		cQuery += "SELECT CN4_CODIGO,CN4_DESCRI,CN4_VALID,CN4_FORMUL,"
		cQuery += "	      CN4_TIPO,CNH_NUMERO,CN4_VLDALT,CN4_VLRALT "
		cQuery += " FROM " + RetSqlName( "CNH" ) + " CNH,"
		cQuery += RetSqlName( "CN4" ) + " CN4 "
		cQuery += " WHERE CNH_FILIAL 	  = '"+xFilial("CNH")+"'"
		cQuery += "   AND CNH_NUMERO	  = '"+aMedicoes[nLoop,1]+"'"
		cQuery += "   AND CNH.D_E_L_E_T_  = ' '"
		cQuery += "   AND CNH_CODIGO	  = CN4_CODIGO"
		cQuery += "   AND CN4_FILIAL	  = '" +xFilial("CN4")+"'"
		cQuery += "   AND CN4.D_E_L_E_T_  = ' ' "
		cQuery += " ORDER BY CNH_NUMERO,CN4_CODIGO" 		

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .F., .T. )

		While !( cAliasQry )->( Eof() )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Avalia a aplicacao da multa                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If Empty( ( cAliasQry )->CN4_VLDALT ) 
				lFormula := Formula(( cAliasQry )->CN4_VALID )  
			Else 			
				lFormula := &( ( cAliasQry )->CN4_VLDALT )			
			EndIf 			
	
			If lFormula			
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem o valor da multa                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty( ( cAliasQry )->CN4_VLRALT ) 
					nValor := Formula( ( cAliasQry )->CN4_FORMUL ) 
				Else 			
					nValor := &( ( cAliasQry )->CN4_VLRALT )			
				EndIf 

				AAdd( aListBox, { .F., ( cAliasQRY )->CNH_NUMERO, ( cAliasQRY )->CN4_DESCRI, nValor, 1, ( cAliasQRY )->CN4_TIPO } )
			EndIf

			( cAliasQry )->( dbSkip() )

		EndDo 	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho da query                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		( cAliasQRY )->( dbCloseArea() ) 	

		DbSelectArea( "CN4" )

	EndIf 			

Next nLoop

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103MultOk ³ Autor ³ Sergio Silveira      ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a validacao das multas de contratos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := A103MultOk( ExpA1, ExpA2, ExpA3 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array contendo as multas                           ³±±
±±³          ³ ExpA2 -> Acols do SE2 ( titulos )                           ³±±
±±³          ³ ExpA3 -> aHeader do SE2                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Indica validacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103MultOk( aMultas, aColsSE2, aHeadSE2 )

Local aContratos := {}

Local lRet       := .T.

Local nPosPedido := GDFieldPos( "D1_PEDIDO" )
Local nPosItem   := GDFieldPos( "D1_ITEMPC" )
Local nPValor    := GDFieldPos( "E2_VALOR", aHeadSE2 )
Local nLoop      := 0
Local nValDup    := 0
Local nValMult   := 0
Local nValBoni   := 0

If !Empty( aMultas )

	SC7->( DbSetOrder( 1 ) ) 		
	For nLoop := 1 to Len( aCols )

		If !ATail( aCols[ nLoop ] ) 	

			If SC7->( MsSeek( xFilial( "SC7" ) + aCols[ nLoop, nPosPedido ] + aCols[ nLoop, nPosItem ] ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta o array de medicoes / item desta NF                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty( SC7->C7_CONTRA ) .And. !Empty( SC7->C7_PLANILH )

					If Empty( AScan( aContratos, SC7->C7_CONTRA ) )
						AAdd( aContratos, SC7->C7_CONTRA )
					EndIf		

				EndIf

			EndIf

		EndIf 	

	Next nLoop

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe alguma multa para um contrato que nao esta na NF    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nLoop := 1 to Len( aMultas )

		If Empty( AScan( aContratos, aMultas[ nLoop, 1 ] ) )  	
			Aviso( STR0236, STR0247, { STR0238 }, 2 ) // "Atencao !", "Nao e possivel inserir multas para um contrato que nao esta nos itens do documento de entrada.","Ok"
			lRet := .F.
			Exit 				

		EndIf

	Next nLoop	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se eh possivel aplicar as multas para o valor de titulos existente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o total de multas e / ou bonificacoes de contrato         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AEval( aMultas, { |x| If( x[5] == "1", nValMult += x[3], nValBoni += x[3] ) } )

		If nValMult > nValBoni

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a diferenca entre multas e bonificacoes                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMult := nValMult - nValBoni

			nValDup := 0

			For nLoop := 1 to Len( aColsSE2 )
				nValDup += aColsSE2[ nLoop, nPValor ]
			Next nLoop

			If nValMult > nValDup
				lRet := .F.
				Aviso( STR0236, STR0248, { STR0238 }, 2 ) // "Atencao !", "O valor de multas nao pode ser superior ao valor de duplicatas do documento.", { "Ok" }
			EndIf 		

		EndIf 			

	EndIf 	

EndIf

Return( lRet )


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103HistMul³ Autor ³ Sergio Silveira      ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a manutencao do historico das multas no contratos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103HistMul( ExpN1,ExpA2,ExpC3,ExpC4,ExpC5,ExpC6)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Tipo : 1 - Inclusao / 2 - Exclusao                 ³±±
±±³          ³ ExpA2 -> Array de multas                                    ³±±
±±³          ³ ExpC3 -> Documento                                          ³±±
±±³          ³ ExpC4 -> Serie                                              ³±±
±±³          ³ ExpC5 -> Fornecedor                                         ³±±
±±³          ³ ExpC6 -> Loja                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103HistMul( nTipo, aMultas, cDoc, cSerie, cFornec, cLoja )

Local cHora     := ""
Local cAliasQry := ""
Local cQuery    := ""

Local nLoop     := 0

If nTipo == 1

	cHora := Time()

	For nLoop := 1 to Len( aMultas )

		RecLock( "CNG", .T. )

		CNG->CNG_FILIAL  := xFilial( "CNG" )
		CNG->CNG_CONTRA  := aMultas[ nLoop, 1 ]
		CNG->CNG_DATA    := dDataBase
		CNG->CNG_HORA    := cHora
		CNG->CNG_DESCRI  := aMultas[ nLoop, 2 ]
		CNG->CNG_VALOR   := aMultas[ nLoop, 3 ]
		CNG->CNG_DOC     := cDoc
		CNG->CNG_SERIE   := cSerie
		CNG->CNG_FORNEC  := cFornec
		CNG->CNG_LOJA    := cLoja

		CNG->( MsUnlock() )

	Next nLoop 	

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o historico desta NF no contrato                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cAliasQry := GetNextAlias()

	cQuery := "SELECT R_E_C_N_O_ CNGRECNO 
	cQuery += "  FROM "+RetSqlName("CNG")
	cQuery += " WHERE CNG_DOC     ='"+cDoc    + "'"
	cQuery += "   AND CNG_SERIE	  ='"+cSerie  + "'"
	cQuery += "   AND CNG_FORNEC  ='"+cFornec + "'"
	cQuery += "   AND CNG_LOJA    ='"+cLoja   + "'"
	cQuery += "   AND D_E_L_E_T_  =' '" 		

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )

	While !( cAliasQry )->( Eof() ) 		

		CNG->( MsGoto( ( cAliasQry )->CNGRECNO ) )

		RecLock( "CNG", .F. )

		CNG->( dbDelete())
		CNG->( MsUnlock())

		( cAliasQry )->( dbSkip() ) 	

	EndDo 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a area de trabalho da query                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	( cAliasQry )->( dbCloseArea() ) 		

EndIf 	

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA103   ºAutor  ³Luciana P. Munhoz   º Data ³ 08/08/2006   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função GetQOri - Retorna a quantidade da Nota Fiscal Originalº±±
±±º          ³caso seja uma Nota Fiscal de Complemento(D1_TIPO=="C" e "I") º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Quando os campos F4_BENSATF e F4_ATUATF == "Sim"            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetQOri (cFil, cNFOri, cSerieOri, cItemOri, cCodi, cForn, cLoj)

Local aAreaSD1	:= SD1->(GetArea())
Local nQtdD1	:= 0

SD1->(DbSetOrder(1))
If SD1->(MsSeek(cFil+cNFOri+cSerieOri+cForn+cLoj+cCodi+cItemOri))
	nQtdD1 	:= 	Int(SD1->D1_QUANT)
Else
	nQtdD1 	:= 	0
Endif

RestArea(aAreaSD1)

Return(nQtdD1)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³06/11/2006³±±
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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Local aRotina3  := {	{STR0002,"NfeDocVin",0,2,0,nil},;	//"Visualizar"
						{STR0164,"NfeDocVin",0,4,0,nil},;	//"Alterar"
						{STR0006,"NFeDocVin",0,5,0,nil}}	//"Excluir"

Local aRotina4  := {	{STR0009,"NfeDocCob",0,4,0,nil},;	//"Documento de Entrada"
						{STR0198,"NfsDocCob",0,4,0,nil}}	//"Documento de Saida"

Local aRotina2  := {	{STR0165,aRotina3,0,4,0,nil},;		//"Vincular"
						{STR0166,aRotina4,0,4,0,nil}}		//"Cobertura"

Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.)
PRIVATE aRotina	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa aRotina para ERP/CRM ou SIGAGSP                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aRotina,{OemToAnsi(STR0001), "AxPesqui"   , 0 , 1, 0, .F.}) 		//"Pesquisar"
aAdd(aRotina,{OemToAnsi(STR0002), "A103NFiscal", 0 , 2, 0, nil}) 		//"Visualizar"
aAdd(aRotina,{OemToAnsi(STR0003), "A103NFiscal", 0 , 3, 0, nil}) 		//"Incluir"
aAdd(aRotina,{OemToAnsi(STR0004), "A103NFiscal", 0 , 4, 0, nil}) 		//"Classificar"
If !lGspInUseM
	aAdd(aRotina,{OemToAnsi(STR0005), "A103Devol"  , 0 , 3, 0, nil})	//"Retornar"
Endif
aAdd(aRotina,{OemToAnsi(STR0006), "A103NFiscal", 3 , 5, 0, nil})		//"Excluir"
If !lGspInUseM
	aAdd(aRotina,{OemToAnsi(STR0007), "A103Impri"  , 0 , 4, 0, nil})	//"Imprimir"
Endif
aAdd(aRotina,{OemToAnsi(STR0008), "A103Legenda", 0 , 2, 0, .F.})		//"Legenda"

//If !lPyme
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do banco de conhecimento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aRotina,{STR0187,"MsDocument", 0 , 4, 0, nil})	//"Conhecimento"
If !lPyme
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao da rotina do documento vinculado                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aRotina,{STR0167   , aRotina2, 0, 4, 0, nil})		//"Doc.Vinculado"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno do saldo contido no Armazem de Transito              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aRotina,{OemToAnsi(STR0296), 'A103RetTrf' , 0 , 3, 0, nil})	//"Transito"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do Rastreio de Contratos Fornecedores                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aRotina,{OemToAnsi(STR0374), "A103Contr", 0 , 2, 0, nil})//"Rastr.Contrato"

If ExistTemplate("MTA103MNU")
	ExecTemplate("MTA103MNU",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA103MNU")
	ExecBlock("MTA103MNU",.F.,.F.)
EndIf
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103VldGer³ Autor ³ Mary C. Hergert       ³ Data ³29/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para implemetacao de validacoes gerais na confirmacao³±±
±±³          ³da nota fiscal de entrada.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F., confirmando ou nao o documento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Array com os campos da Nota Fiscal Eletronica:              ³±±
±±³          ³[01]: Numero da NF-e                                        ³±±
±±³          ³[02]: Codigo de Verificacao                                 ³±±
±±³          ³[03]: Emissao                                               ³±±
±±³          ³[04]: Hora da Emissao                                       ³±±
±±³          ³[05]: Valor do credito                                      ³±±
±±³          ³[06]: Numero do RPS                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103VldGer(aNFEletr)

Local lRetVldGer := .T.

If cPaisLoc == "BRA"
	If ExistBlock("MTCHKNFE")
		lRetVldGer := Execblock("MTCHKNFE",.F.,.F.,{aNFEletr})
	Endif
Endif

Return lRetVldGer


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MontaaCols³ Autor ³ Marco Bianchi         ³ Data ³ 10/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montagem do aCols para GetDados.                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaaCols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaaCols(bWhileSD1,lQuery,l103Class,lClassOrd,lNfeOrd,aRecClasSD1,nCounterSD1,cAliasSD1,cAliasSB1,aRecSD1,aRateio,cCpBasePIS,cCpValPIS,cCpAlqPIS,cCpBaseCOF,cCpValCOF,cCpAlqCOF,aHeader,aCols,l103Inclui,aHeadSDE,aColsSDE,lContinua)

Local nUsado     := 0
Local nPosTes    := 0
Local aAuxRefSD1 := MaFisSXRef("SD1")
Local nBasePIS	 := 0
Local nValorPIS	 := 0
Local nAliqPIS	 := 0
Local nBaseCOF	 := 0
Local nValorCOF	 := 0
Local nAliqCOF	 := 0
Local cItemSDG	 := ""
Local nItRatFro	 := 0
Local nItRatVei	 := 0
Local nPos       := 0
Local nX         := 0
Local nY         := 0
Local cTesPed    := ""
Local nPosServic := 0
Local nPosTpEstr := 0
Local nPosEnder  := 0
Local nPosStServ := 0
Local nPosRegWMS := 0
Local nPosDesEst := 0
LOCAL lA103CLAS  := ExistBlock("A103CLAS")

If !Empty(aBackSD1)
	aHeader := aBackSD1
EndIf
nUsado := Len(aHeader)


If l103Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aCols,Array(Len(aHeader)+1))
	For nY := 1 To Len(aHeader)
		If Trim(aHeader[nY][2]) == "D1_ITEM"
			aCols[1][nY] 	:= StrZero(1,Len(SD1->D1_ITEM))
		Else
			If AllTrim(aHeader[nY,2]) == "D1_ALI_WT" 
				aCOLS[Len(aCols)][nY] := "SD1"
			ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
				aCOLS[Len(aCols)][nY] := 0
			Else
				aCols[1][nY] := CriaVar(aHeader[nY][2])
			EndIf
		EndIf
		aCols[1][nUsado+1] := .F.
	Next nY
Else

	While Eval( bWhileSD1 )   
	    // -- Compara o Tipo da NF Selecionada SF1 X Tipo da NF SD1 --
   		If !lQuery 
		    If !Eof() .And. (CALIASSD1)->D1_TIPO <> SF1->F1_TIPO
				(cAliasSD1)->(dbSkip())
				Loop
			EndIf
		EndIf

		If !lQuery .And. ((l103Class .And. lClassOrd) .Or. (l103Visual .And. lClassOrd) .Or. lNfeOrd)
			SD1->( MsGoto( aRecClasSD1[ nCounterSD1, 2 ] ) )
		EndIf

		//-- SIGAWMS = Impede a classif. da PreNota com Servico de WMS conferencia pendente
		If	IntDL() .And. l103Class .And. !Empty((cAliasSD1)->D1_SERVIC)
			lContinua := A103WMSOk("2",cAliasSD1)
			If	!lContinua
				Loop
			EndIf
		EndIf

		If !lQuery
			SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
		Endif

		aadd(aRecSD1,{If(lQuery,(cAliasSD1)->SD1RECNO,(cAliasSD1)->(RecNo())),(cAliasSD1)->D1_ITEM})

		aadd(aCols,Array(nUsado+1))
		cTesPed := ""
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a funcao fiscal                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisIniLoad(Len(aCols))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza numero do item de acordo com o acols na classificacao de uma pre-nota³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Class
			MaFisAlt("IT_ITEM",(cAliasSD1)->D1_ITEM,Len(aCols))
		Endif

		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES))

		For nX := 1 To Len(aAuxRefSD1)
	 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desconta o Valor do ICMS DESONERADO do valor do Item D1_VUNIT - Ajuste para visualizacao da NFE com desoneracao de ICMS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aAuxRefSD1[nX][2] == "IT_VALMERC" .And. SF4->F4_AGREG$"R"
				MaFisLoad(aAuxRefSD1[nX][2],(cAliasSD1)->(FieldGet(FieldPos(aAuxRefSD1[nX][1])))+(cAliasSD1)->D1_DESCICM,Len(aCols))
            Else
   			    MaFisLoad(aAuxRefSD1[nX][2],(cAliasSD1)->(FieldGet(FieldPos(aAuxRefSD1[nX][1]))),Len(aCols))
		    EndIf
		Next nX
		MaFisEndLoad(Len(aCols),2)

		If l103Class .And. SuperGetMV("MV_EASY") == "S"
			MaFisLoad("IT_POSIPI",(cAliasSD1)->D1_TEC,Len(aCols))
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a condicao de pagamento com base no Pedido de compra³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( (Empty(cCondicao) .Or. l103Class) .And. !Empty((cAliasSD1)->D1_PEDIDO) )
			DbSelectArea("SC7")
			DbSetOrder(19)
			If MsSeek(xFilial("SC7")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC)
				If !l103Class .Or. Empty(cCondicao) .Or. (Type('lCondFor')=='L' .And. lCondFor) //se a condição tiver sido carregada pelo fornecedor ela deve ser sobreposta pelo C7_COND, conceito padrão
					cCondicao := SC7->C7_COND
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os dados do acols com base no Pedido de compra      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( !Empty((cAliasSD1)->D1_PEDIDO) .And. l103Class)
			DbSelectArea("SC7")
			DbSetOrder(19)
			If MsSeek(xFilial("SC7")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC)
				cTesPed := SC7->C7_TES
				If Empty(SC7->C7_SEQUEN)
					NfePC2Acol(SC7->(RecNo()),Len(aCols),(cAliasSD1)->D1_QUANT,(cAliasSD1)->D1_ITEM,l103Class,@aRateio,aHeadSDE,@aColsSDE,(cAliasSD1)->D1_VUNIT)
					aBackColsSDE:=ACLONE(aColsSDE)
					//-- Atualiza as despesas de acordo com a pre-nota.
					If aRateio[1] == 0 .And. aRateio[2] == 0 .And. aRateio[3] == 0
						aRateio[1] := SF1->F1_SEGURO
						aRateio[2] := SF1->F1_DESPESA
						aRateio[3] := SF1->F1_FRETE
					EndIf
				EndIf
			EndIf
			MaFisAlt("IT_DESPESA",(cAliasSD1)->D1_DESPESA,Len(aCols))
			MaFisAlt("IT_SEGURO",(cAliasSD1)->D1_SEGURO,Len(aCols))
			MaFisAlt("IT_FRETE",(cAliasSD1)->D1_VALFRE,Len(aCols))
		EndIf

		// Preenchimento do aCols
		DbSelectArea(cAliasSD1)
		For nY := 1 To nUsado
			If ( aHeader[nY][10] <> "V")
				aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
				If (l103Class .Or. l103Visual) .And. Alltrim(aHeader[ny][2]) == "D1_TES" .And. Empty((cAliasSD1)->D1_TES)
					If !Empty((cAliasSD1)->D1_TESACLA)
						aCols[Len(aCols)][ny] := (cAliasSD1)->D1_TESACLA
						MaFisAlt("IT_TES",(cAliasSD1)->D1_TESACLA,Len(aCols))
					ElseIf !Empty(cTesPed)
						aCols[Len(aCols)][ny] := cTesPed
					Else						
						aCols[Len(aCols)][ny] := RetFldProd((cAliasSB1)->B1_COD,"B1_TE",cAliasSB1)
					EndIf
				EndIf
				
				If l103Class .And. Alltrim(aHeader[ny][2]) == "D1_RATEIO" .And. Empty((cAliasSD1)->D1_RATEIO)
					aCols[Len(aCols)][ny] := "2"
				EndIf
			Else
				If AllTrim(aHeader[nY,2]) == "D1_ALI_WT"
					aCOLS[Len(aCols)][nY] := "SD1"
				ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
					aCOLS[Len(aCols)][nY] := If(lQuery,(cAliasSD1)->SD1RECNO,(cAliasSD1)->(RecNo()))
				Else
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
				EndIf
				Do Case
				Case Alltrim(aHeader[nY][2]) == "D1_CODITE"
					aCols[Len(aCols)][ny] := (cAliasSB1)->B1_CODITE
				Case Alltrim(aHeader[nY][2]) == "D1_CODGRP"
					aCols[Len(aCols)][ny] := (cAliasSB1)->B1_GRUPO
				EndCase
			EndIf
			If Trim(aHeader[ny][2]) == "D1_TES"
				nPosTes := nY
			EndIf                              
			
			
			aCols[Len(aCols)][nUsado+1] := .F.
		Next nY
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada que permite manipular o item do aCols              	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
	    If lA103Clas .And. !l103Visual .And. l103Class
			ExecBlock("A103CLAS",.F.,.F.,{cAliasSD1})
		EndIf		

		DbSelectArea(cAliasSD1)
		If l103Class .And. nPosTes > 0 .And. !Empty(aCols[Len(aCols),nPosTes])
			MaFisLoad("IT_TES","",Len(aCols))
			MaFisAlt("IT_TES",aCols[Len(aCols)][nPosTes],Len(aCols))
			MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
			If ExistTrigger("D1_TES")
				RunTrigger(2,Len(aCols),,"D1_TES")
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento especial para a Average                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Class .And. Empty((cAliasSD1)->D1_TES)                         
			If Empty(aCols[Len(aCols),nPosTes])
				MaFisLoad("IT_TES",(cAliasSD1)->D1_TES,Len(aCols))		
			Endif
				
			If (cAliasSD1)->D1_BASEIPI > 0
				MaFisAlt("IT_BASEIPI",(cAliasSD1)->D1_BASEIPI,Len(aCols))
				MaFisAlt("IT_ALIQIPI",(cAliasSD1)->D1_IPI,Len(aCols))
				MaFisAlt("IT_VALIPI",(cAliasSD1)->D1_VALIPI,Len(aCols))
			EndIf
			If (cAliasSD1)->D1_BASEICM > 0
				MaFisAlt("IT_BASEICM",(cAliasSD1)->D1_BASEICM,Len(aCols))
				MaFisAlt("IT_ALIQICM",(cAliasSD1)->D1_PICM,Len(aCols))
				MaFisAlt("IT_VALICM",(cAliasSD1)->D1_VALICM,Len(aCols))
			EndIf

			If !Empty( cCpBasePIS ) .And. !Empty( cCpValPIS ) .And. !Empty( cCpAlqPIS )
				nBasePIS    := ( cAliasSD1 )->( FieldGet( (  cAliasSD1 )->( FieldPos( cCpBasePIS ) ) ) )
				nValorPIS   := ( cAliasSD1 )->( FieldGet( (  cAliasSD1 )->( FieldPos( cCpValPIS ) ) ) )
				nAliqPIS    := ( cAliasSD1 )->( FieldGet( (  cAliasSD1 )->( FieldPos( cCpAlqPIS ) ) ) )

				If !Empty( nBasePIS )
					MaFisAlt("IT_BASEPS2", nBasePIS ,Len(aCols))
					MaFisAlt("IT_VALPS2" , nValorPIS,Len(aCols))
					MaFisAlt("IT_ALIQPS2" , nAliqPIS,Len(aCols))
				EndIf
			EndIf

			If !Empty( cCpBaseCOF ) .And. !Empty( cCpValCOF ) .And. !Empty( cCpAlqCOF )
				nBaseCOF    := ( cAliasSD1 )->( FieldGet( (  cAliasSD1 )->( FieldPos( cCpBaseCOF ) ) ) )
				nValorCOF   := ( cAliasSD1 )->( FieldGet( (  cAliasSD1 )->( FieldPos( cCpValCOF ) ) ) )
				nAliqCOF    := ( cAliasSD1 )->( FieldGet( (  cAliasSD1 )->( FieldPos( cCpAlqCOF ) ) ) )
				If !Empty( nBaseCOF )
					MaFisAlt("IT_BASECF2", nBaseCOF ,Len(aCols))
					MaFisAlt("IT_VALCF2" , nValorCOF,Len(aCols))
					MaFisAlt("IT_ALIQCF2" , nAliqCOF ,Len(aCols))
				EndIf
			EndIf

			MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o modulo de Transportes                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTMS()
			DbSelectArea("SDG")
			DbSetOrder(7)
			If MsSeek(xFilial("SDG")+"SD1"+(cAliasSD1)->D1_NUMSEQ)
				If cItemSDG <> (cAliasSD1)->D1_ITEM
					cItemSDG	:= (cAliasSD1)->D1_ITEM
					If Empty(SDG->DG_CODVEI) .And. Empty(SDG->DG_VIAGEM) //Verifica se o Rateio foi por Veiculo/Viagem ou por Frota
						aadd(aRatFro,{cItemSDG,{},SDG->DG_CODDES})
						nItRatFro++
					Else
						aadd(aRatVei,{cItemSDG,{},SDG->DG_CODDES})
						nItRatVei++
					EndIf
				EndIf
				Do While !Eof() .And. xFilial("SDG")+"SD1"+(cAliasSD1)->D1_NUMSEQ == DG_FILIAL+DG_ORIGEM+DG_SEQMOV
					If Empty(SDG->DG_CODVEI) .And. Empty(SDG->DG_VIAGEM) //Verifica se o Rateio foi por Veiculo/Viagem ou por Frota
						aadd(aRatFro[nItRatFro][2],{SDG->DG_ITEM, SDG->DG_TOTAL,.F.})
					Else
						If ( nPos := Ascan(aRatVei[nItRatVei][2], { |x| x[2] == SDG->DG_CODVEI } ) ) == 0
							aadd(aRatVei[nItRatVei][2],{SDG->DG_ITEM,SDG->DG_CODVEI, SDG->DG_FILORI, SDG->DG_VIAGEM, SDG->DG_TOTAL," ",0,0,.F.})
						EndIf
					EndIf
					dbSkip()
				EndDo
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o modulo de Armazenagem - SIGAWMS                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando se tratar de Pre-Nota apaga os campos referentes ao servico de WMS apos            ³
		//³ a execucao, permitindo que o servico (enderecamento) seja informado apos classificacao    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Class .And. IntDL()
			nPosServic := aScan(aHeader,{|x|AllTrim(x[2])=='D1_SERVIC'})
			nPosStServ := aScan(aHeader,{|x|AllTrim(x[2])=='D1_STSERV'})
			nPosEnder  := aScan(aHeader,{|x|AllTrim(x[2])=='D1_ENDER' })
			nPosTpEstr := aScan(aHeader,{|x|AllTrim(x[2])=='D1_TPESTR'})
			nPosDesEst := aScan(aHeader,{|x|AllTrim(x[2])=='D1_DESEST'})
			nPosRegWMS := aScan(aHeader,{|x|AllTrim(x[2])=='D1_REGWMS'})
			aCols[Len(aCols),nPosServic] := CriaVar('D1_SERVIC', .T.)
			aCols[Len(aCols),nPosStServ] := CriaVar('D1_STSERV', .T.) //-- Neste caso SEMPRE deixa o servico com status de NAO EXECUTADO
			aCols[Len(aCols),nPosEnder ] := CriaVar('D1_ENDER' , .T.)
			aCols[Len(aCols),nPosTpEstr] := CriaVar('D1_TPESTR', .T.)
			aCols[Len(aCols),nPosDesEst] := ''
			aCols[Len(aCols),nPosRegWMS] := CriaVar('D1_REGWMS', .T.)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ao Visualizar uma NFE com F4_AGREG=R o valor da base ja esta DESONERADO por isso deve se ajustado no NF_VALMERC³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Visual .And. SF4->F4_AGREG$"R"
			MaFisLoad("NF_VALMERC",SF1->F1_VALMERC)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua skip na area SD1 ( regra geral ) ou incrementa o contador ³
		//³ quando ordem por ITEM + CODIGO DE PRODUTO                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lQuery .And. ((l103Class .And. lClassOrd) .Or. (l103Visual .And. lClassOrd) .Or. lNfeOrd)
			nCounterSD1++
		Else
			DbSelectArea(cAliasSD1)
			dbSkip()
		EndIf
	EndDo
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjustaSX3 ³ Autor ³Nereu Humberto Junior  ³ Data ³26/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta o X3_VALID de campos do  SD1 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX3()
Local aAreaAnt := GetArea()
Local aAreaSX3 := SX3->(GetArea())   
Local cUsado1
Local cReserv1

DbSelectArea("SX3")
DbSetOrder(2)

If dbSeek("D1_COD") 
	If !'MAFISREF("IT_PRODUTO","MT100",M->D1_COD)' $ Upper(SX3->X3_VALID)
		Reclock("SX3",.F.)
		SX3->X3_VALID := Alltrim(SX3->X3_VALID) + '.And.MaFisRef("IT_PRODUTO","MT100",M->D1_COD)'
		MsUnlock()
	Endif	
Endif

If dbSeek("D1_QUANT")
	If !"A103TOLER" $ SX3->X3_VALID
		Reclock("SX3",.F.)
		SX3->X3_VALID := "A103TOLER().And."+Alltrim(SX3->X3_VALID)
		MsUnlock()
	Endif	
Endif

If dbSeek("D1_VUNIT")
	If !"A103TOLER" $ SX3->X3_VALID
		Reclock("SX3",.F.)
		SX3->X3_VALID := "A103TOLER().And."+Alltrim(SX3->X3_VALID)
		MsUnlock()
	Endif	
Endif

If dbSeek("D1_SERVIC")
	cUsado := SX3->X3_USADO
	If dbSeek("D1_TPESTR") .And. SX3->X3_USADO <> cUsado
		Reclock("SX3",.F.)
		SX3->X3_USADO := cUsado
		MsUnlock()
	Endif
Endif

If dbSeek("D1_REGWMS") .And. SX3->X3_PYME == "S"
	Reclock("SX3",.F.)
	SX3->X3_PYME := "N"
	MsUnlock()
Endif

If dbSeek("D1_PEDIDO") 
	If 'EXISTCPO("SC7",,14)' $ Upper(SX3->X3_VALID)
		Reclock("SX3",.F.)
		SX3->X3_VALID := 'vazio().or.(existcpo("SC7").And.A103PC())'
		MsUnlock()
	Endif	
Endif                 

If dbSeek("D1_OPER") .and. !'MTA103TROP' $ Upper(SX3->X3_VALID) .and. FindFunction("MTA103TROP")
	Reclock("SX3",.F.)
	SX3->X3_VALID := 'ExistCpo("SX5","DJ"+M->D1_OPER) .and. MTA103TROP(n) '
	MsUnlock()
Endif                 

If dbSeek("D1_TOTAL") .and. !'MTA103OPER' $ Upper(SX3->X3_VALID) .and. FindFunction("MTA103OPER")
	Reclock("SX3",.F.)
	SX3->X3_VALID := 'A103Total(M->D1_TOTAL) .and. MaFisRef("IT_VALMERC","MT100",M->D1_TOTAL) .AND. MTA103OPER(n) '
	MsUnlock()
Endif                 

If dbSeek("D1_GARANTI")
	If dbSeek("D1_GARANTI") .And. "NGGARANSD1()" $ SX3->X3_VALID
		Reclock("SX3",.F.)
		SX3->X3_VALID := STRTRAN(SX3->X3_VALID,"NGGARANSD1()","NGGARANSD1(cAliasTPZ)")
		MsUnlock()
	Endif
Endif

If dbSeek("D1_DESC") .And. !'A103VLDDSC()'$SX3->X3_WHEN
	Reclock("SX3",.F.)
	SX3->X3_WHEN := "A103VLDDSC()"+If(Empty(SX3->X3_WHEN),"",".And."+AllTrim(SX3->X3_WHEN))
	MsUnlock()
EndIf

If dbSeek("D1_VALDESC") .And. !'A103VLDDSC()'$SX3->X3_WHEN
	Reclock("SX3",.F.)
	SX3->X3_WHEN := "A103VLDDSC()"+If(Empty(SX3->X3_WHEN),"",".And."+AllTrim(SX3->X3_WHEN))
	MsUnlock()
EndIf

If dbSeek("D1_QUANT")
	cUsado1	:= SX3->X3_USADO
	cReserv1:= SX3->X3_RESERV
	If dbSeek("D1_OP") .And. !(cUsado$SX3->X3_USADO .Or. cReserv1$SX3->X3_RESERV)
		Reclock("SX3",.F.)
		SX3->X3_USADO  := cUsado1
		SX3->X3_RESERV := cReserv1
		MsUnlock()
	EndIf
EndIf

If dbSeek("D1_CODITE")
	cUsado1	:= SX3->X3_USADO
	cReserv1:= SX3->X3_RESERV	
	If dbSeek("D1_PCCENTR")
		If SX3->X3_RESERV <> cReserv1
			Reclock("SX3",.F.)
			SX3->X3_RESERV:=cReserv1
			MsUnlock()
		Endif	
	Endif
	If dbSeek("D1_ITPCCEN")
		If SX3->X3_RESERV <> cReserv1
			Reclock("SX3",.F.)
			SX3->X3_RESERV:=cReserv1
			MsUnlock()
		Endif	
	Endif 
EndIf       
If dbSeek("EV_SITUAC")
	cUsado1 :=SX3->X3_USADO
	cReserv1 :=SX3->X3_RESERV	
	If dbSeek("EV_PARCELA")
		Reclock("SX3",.F.)
		SX3->X3_USADO := cUsado1
		SX3->X3_RESERV := cReserv1
		MsUnlock()
	EndIf
EndIf

If dbSeek("F1_VOLUME4") 
	Reclock("SX3",.F.)
	SX3->X3_PICTURE:= "@E 999999"
	MsUnlock()
Endif

If dbSeek("F1_IPI")
	cUsado1 :=SX3->X3_USADO
	cReserv1 :=SX3->X3_RESERV	
	If dbSeek("F1_PESOL")
		Reclock("SX3",.F.)
		SX3->X3_USADO := cUsado1
		SX3->X3_RESERV := cReserv1
		MsUnlock()
	EndIf
EndIf

If dbSeek("DH_FORNECE") 
    If FindFunction("A103FIniLoj")
		Reclock("SX3",.F.)
		SX3->X3_VALID := 'Vazio() .or. A103FIniLoj()'
		MsUnlock()
	EndIf
EndIf

If dbSeek("DH_CLIENTE") 
    If FindFunction("A103CIniLoj")
		Reclock("SX3",.F.)
		SX3->X3_VALID := 'Vazio() .or. A103CIniLoj()'
		MsUnlock()
	EndIf
Endif

//Habilita os campos da tabela SF6 Guia de Recolhimento para o modulo de compras
If dbSeek("F6_TIPOIMP")
	cUsado1 :=SX3->X3_USADO
	If dbSeek("F6_NUMERO")  
		If SX3->X3_USADO <> cUsado1
			Reclock("SX3",.F.)
			SX3->X3_USADO := cUsado1
			MsUnlock()
		EndIf
	EndIf
	If dbSeek("F6_EST") 
		If SX3->X3_USADO <> cUsado1
			Reclock("SX3",.F.)
			SX3->X3_USADO := cUsado1
			MsUnlock()
		EndIf
	EndIf
	If dbSeek("F6_VALOR")
		If SX3->X3_USADO <> cUsado1
			Reclock("SX3",.F.)
			SX3->X3_USADO := cUsado1
			MsUnlock()
		EndIf
	EndIf
EndIf 

If dbSeek("DE_CC")// ajusta a validação do centro de custo, se vazio ou existente no cadastro
	If Alltrim(SX3->X3_VALID) <> '((Vazio() .Or. CTB105CC()) .And. A103VldCC({.F.,.T.,.T.,.T.}))'
		Reclock("SX3",.F.)
		SX3->X3_VALID := '((Vazio() .Or. CTB105CC()) .And. A103VldCC({.F.,.T.,.T.,.T.}))'
		MsUnlock()
	EndIf
Endif

RestArea(aAreaSX3)
RestArea(aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103Toler ³ Autor ³Nereu Humberto Junior  ³ Data ³26/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se nf bloqueada por tolerancia ja foi liberada e nao ³±±
±±³          ³permite que a quantidade/preco seja alterado pelo MATA103.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Toler( ) //Funcao no X3_VALID -> D1_QUANT/D1_VUNIT      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103Toler()

Local aArea    := GetArea()
Local aAreaSC7 := SC7->(GetArea())
Local nPosPc   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosItPc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"}) 
Local nPosQtd  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosVlUn := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local lRet     := .T.
Local lRestCla := SuperGetMV("MV_RESTCLA",.F.,"2")=="1"
Local cCampo   := ReadVar()

l103TolRec := If(Type('l103TolRec') == 'L',l103TolRec,.F.)  

If (nModulo <> 12)   // Se for SigaLoja, não entra
	DbSelectArea("SC7")
	SC7->(dbSetOrder(1)) 
	If nPosPc > 0 .And. nPosItPc > 0 
		If SC7->(MsSeek(xFilial("SC7")+aCols[n][nPosPc]+aCols[n][nPosItPc]))
			If !Empty(SC7->C7_CODED)  
				If (cCampo == "M->D1_QUANT" .And. aCols[n][nPosQtd] != &cCampo) .Or.;
					 (cCampo == "M->D1_VUNIT" .And. aCols[n][nPosVlUn] != &cCampo)
					Help("",1,STR0402,,STR0403,4,1) // "EDITAL" ## "Este documento pertence à um Edital e nao poderá ocorrer alteração na Quantidade e/ou Valor."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
	
If lRet .And. lRestCla .And. l103TolRec
	If !Empty(aCols[n][nPosPc]) .And. !Empty(aCols[n][nPosItPc])
		SC7->(dbSetOrder(1))
		If SC7->(MsSeek(xFilial("SC7")+aCols[n][nPosPc]+aCols[n][nPosItPc]))   			
			SCR->(dbSetOrder(1))
			If SCR->(MsSeek(xFilial("SCR")+"NF"+Padr(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,Len(SCR->CR_NUM)))) ;
					.And. SCR->CR_STATUS == "03"
				lRet := .F.
				Aviso(OemToAnsi(STR0178),OemToAnsi(STR0271+IIF("QUANT"$cCampo,STR0272,STR0273)+STR0274),{OemToAnsi(STR0238)},2) //"O campo de "##"quantidade"##"preço unitário"##" só poderá ser alterado através da pré-nota de entrada, pois a Nota Fiscal já foi liberada do bloqueio de tolerância de recebimento."
			Endif
		Endif	
	Endif	
Endif	

If lRet
	lRet:= A103RecAc()
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return(lRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103RecAC   ³ Autor ³Julio C.Guerato      ³ Data ³25/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz Recalculo do Valor do Acrescimo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103RecAC()
Local nPQuant    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPValAcRS  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALACRS"})    
Local cCampo     := ReadVar() 
Local lRet       := .T.
             
If "D1_QUANT"$cCampo
	If nPQuant>0 .And. nPValAcRs >0
		If !Empty(aCols[n][nPQuant]) .And. !Empty(aCols[n][nPValAcRs])
	    	 If (aCols[n][nPQuant])>0 .And. (aCols[n][nPValAcRs])>0
	    	 	If (M->D1_QUANT-aCols[n][nPQuant])<>0 .And. M->D1_QUANT<>0
	    	 		aCols[n][nPValAcRS]:= (aCols[n][nPValAcRs]/aCols[n][nPQuant])* M->D1_QUANT
	    	 	Else    
	    	 	    // Zerou Quantidada, retorna falso para garantir valor do rateio
		    	 	If M->D1_QUANT = 0              
		    	 		lRet:= .F.   
    	 				Aviso((STR0119),OemToAnsi(STR0317),{"Ok"})
		    	 	EndIf
	    	 	EndIf
		     EndIf
		EndIf
	EndIf
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103VldDsc³ Autor ³ Ricardo Berti         ³ Data ³15/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao para habilitar ou nao a edicao dos campos de      ³±±
±±³          ³descontos no item.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103VldDsc( ) //Funcao no X3_WHEN -> D1_DESC/D1_VALDESC     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103VldDsc()

Local lRet     := .T.
Local cCampo   := ReadVar() 
If Left(FunName(),7)=="MATA103" .And. cTipo$"PI" .And. (cCampo == "M->D1_DESC" .Or. cCampo == "M->D1_VALDESC")
	lRet := .F.
EndIf
Return(lRet)	


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103PrdGrd³Autor  ³Alexandre Inacio Lemes ³ Data ³10/08/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Interface de Grade de Produtos para Pre-Nota e Doc.Entrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se Valido ou .F. se Invalido                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Getdados do MATA103.PRW disparada pelo X3_VALID do D1_COD    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103PrdGrd()

Local aArea	      := GetArea()
Local aHlpPor     := {"Para incluir um produto com referência  ","de grade e necessário estar em uma nova ","linha do documento de entrada.          "}  
Local aHlpEng     := {"To include a product with bars reference"," and necessary to be in a new line of   ","the entrance document.                  "}    
Local aHlpSpa     := {"Para incluir un producto con referencia ","de las barras y requisito estar en una  ","nueva línea del documento de la entrada."}   

Local cDescri     := ""
Local cItem       := ""
Local cNewItem    := ""
Local cPrdOrig    := ""
Local cCpoName	  := StrTran(ReadVar(),"M->","")
Local cSaveReadVar:= __READVAR

Local nSaveN      := N
Local nNewItem    := Len(aCols)
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nPosProd    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPosGrade	  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_GRADE"})
Local nPosItGrd   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMGRD"})
Local nPosQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosQtSegum := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QTSEGUM"}) 
Local nPosVUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"}) 
Local nPosTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"}) 
Local nLinX       := 0
Local nColY       := 0
Local nY          := 0
Local nTamD1Tot	  := TamSX3("D1_TOTAL")[2]

Local lGrade	  := MaGrade()
Local lReferencia := .F.
Local lAadd       := .F.
Local lRet 		  := .T.

Local oDlg
  
PutHelp("PA103PRDGRD" , aHlpPor , aHlpEng , aHlpSpa , .F. )

If Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario tem permissao de inclusao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
		If IsInCallStack("MATA140") //Pre-Nota
			lRet := MaAvalPerm(1,{M->D1_COD,"MTA140",3})
		ElseIf IsInCallStack("MATA103") //Documento de Entrada
			lRet := MaAvalPerm(1,{M->D1_COD,"MTA103",3})
		ElseIf IsInCallStack("MATA102N") // Remito de Entrada
			lRet := MaAvalPerm(1,{M->D1_COD,"MT102N",3})
		ElseIf IsInCallStack("MATA101N") // Factura de Entrada
			lRet := MaAvalPerm(1,{M->D1_COD,"MT101N",3})
		EndIf
		If !lRet
			Help(,,1,'SEMPERM')
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a grade esta ativa e se o produto digitado e uma referencia e Monta o AcolsGrade e o AheadGrade para este item ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !Empty(&(ReadVar())) .And. lGrade 
	
	PRIVATE oGrade	  := MsMatGrade():New('oGrade',,"D1_QUANT",,"A103VldGrd()",,;
	{{"D1_QUANT"  ,.T. , {{"D1_QTSEGUM",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2) } }} },;
	{"D1_VUNIT"  ,NIL ,NIL},;
	{"D1_ITEM"	 ,NIL ,NIL},;
	{"D1_QTSEGUM",NIL , {{"D1_QUANT",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} };
	})
	
	cProdRef := &(ReadVar())
	
	lReferencia := MatGrdPrrf(@cProdRef)
	
	If lReferencia
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ So aceita a entrada de dados via interface de grade se o usr ³
		//³ estiver posicionado na ultima linha da MsGetdados (NewLine). ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If N >= Len(aCols) .And. Empty(aCols[Len(aCols)][nPosProd])
			
			oGrade:MontaGrade(1,cProdRef,.T.,,lReferencia,.T.)
			oGrade:nPosLinO := 1
			oGrade:cProdRef	:= cProdRef
			oGrade:lShowMsgDiff := .F. // Desliga apresentacao do "A410QTDDIF" 

			cItem    := aCols[nSaveN][nPosItem]
			nNewItem := Len(aCols)
			lAadd    := .F.
			
			DEFINE MSDIALOG oDlg TITLE STR0276 OF oMainWnd PIXEL FROM 000,000 TO 220,520  //"Interface para Grade de Produtos"
			
			@ 025,010 BUTTON STR0277 SIZE 70,15 FONT oDlg:oFont ACTION ;
			{|| __READVAR:="M->D1_QUANT"  ,M->D1_QUANT  := 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Quantidade"
			@ 045,010 BUTTON STR0278 SIZE 70,15 FONT oDlg:oFont ACTION ;
			{|| __READVAR:="M->D1_VUNIT"  ,M->D1_VUNIT  := 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Valor Unitário"
			@ 065,010 BUTTON STR0279 SIZE 70,15 FONT oDlg:oFont ACTION ;
			{|| __READVAR:="M->D1_QTSEGUM",M->D1_QTSEGUM:= 0,cCpoName := StrTran(ReadVar(),"M->",""),oGrade:Show(cCpoName) } OF oDlg PIXEL //"Segunda Und Medida"
			
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()}) CENTERED
 			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somente realiza a carga do item para o aCols se pelo menos uma celula do D1_QUANT contiver valor.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oGrade:SomaGrade("D1_QUANT",oGrade:nPosLinO,aCols[nSaveN,nPosQuant]) > 0
				For nLinX := 1 To Len(oGrade:aColsGrade[1])
					For nColY := 2 To Len(oGrade:aHeadGrade[1])
						If oGrade:aColsFieldByName("D1_QUANT",1,nLinX,nColY) <> 0
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Faz a montagem de uma nova linha em branco no aCols para     ³
							//³ adicionar novos itens vindos das celulas da Grade.           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lAadd
								aadd(aCols,Array(Len(aHeader)+1))
								nNewItem := Len(aCols)
								cNewItem := StrZero(nNewItem,Len(SD1->D1_ITEM))
								For nY := 1 to Len(aHeader)
									If Trim(aHeader[nY][2]) == "D1_ITEM"
										aCols[nNewItem][nY] := cNewItem
									ElseIf IsHeadRec(aHeader[nY][2])
										aCols[nNewItem][nY] := 0
									ElseIf IsHeadAlias(aHeader[nY][2])
										aCols[nNewItem][nY] := "SD1"
									Else
										aCols[nNewItem][nY] := CriaVar(aHeader[nY][2])
									EndIf
									aCols[nNewItem][Len(aHeader)+1] := .F.
								Next nY
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Efetua a carga dos itens digitados do grid para o aCols e sincro ³
							//³niza os novos itens carregando a Matxfis.                        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							N := nNewItem
							aCols[nNewItem][nPosProd]:= PadR(oGrade:GetNameProd(cProdRef,nLinX,nColY),Len(SD1->D1_COD))
							
							M->D1_COD := aCols[nNewItem][nPosProd]
							MaFisRef("IT_PRODUTO","MT100",M->D1_COD)
							A103IniCpo()
							
							aCols[nNewItem][nPosQuant]:= oGrade:aColsFieldByName("D1_QUANT",1,nLinX,nColY)
							M->D1_QUANT := oGrade:aColsFieldByName("D1_QUANT",1,nLinX,nColY)
							A100SegUm()
							MaFisRef("IT_QUANT","MT100",M->D1_QUANT)

							aCols[nNewItem][nPosQtSegum]:= oGrade:aColsFieldByName("D1_QTSEGUM",1,nLinX,nColY)
							M->D1_QTSEGUM := oGrade:aColsFieldByName("D1_QTSEGUM",1,nLinX,nColY)
							A100SegUm()

							aCols[nNewItem][nPosVUnit]:= oGrade:aColsFieldByName("D1_VUNIT",1,nLinX,nColY)
							M->D1_VUNIT := oGrade:aColsFieldByName("D1_VUNIT",1,nLinX,nColY)
							MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)

							aCols[nNewItem][nPosTotal]:= NoRound(aCols[nNewItem][nPosQuant] * aCols[nNewItem][nPosVUnit],nTamD1Tot)
							M->D1_TOTAL := aCols[nNewItem][nPosTotal]
							A103Total(M->D1_TOTAL)
							MaFisRef("IT_VALMERC","MT100",M->D1_TOTAL)

							If !lAadd
                                cPrdOrig := aCols[nNewItem][nPosProd]  
								lAadd := .T.
							Endif
							
						EndIf
					Next nColY
				Next nLinX
				
			Else
				lRet := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Restaura os valores originais do N da GetDados, e da Public      ³
			//³__READVAR que fora manipulada pela interface de grade.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			N := nSaveN
			__READVAR   := cSaveReadVar
            M->D1_COD   := cPrdOrig
			
			If cPaisLoc <> "BRA"
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  ³Atualiza o browse de quantidade de produtos.³
				  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				AtuLoadQt(.T.)
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para incluir um produto com referencia de grade e necessario esta³
			//³r em uma nova linha da NFE.                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Help(" ",1,"A103PRDGRD") 
			lRet := .F.
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o Produto nao for um produto de grade executa a validacao no SB1 ³
		//³ carrega o item na MATXFIS e inicializa os campos na getdados.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		If !MsSeek(xFilial("SB1")+cProdRef,.F.)
			Help("  ",1,"REGNOIS")
			lRet := .F.
		EndIf
		
		If lRet
			MaFisRef("IT_PRODUTO","MT100",M->D1_COD)
			A103IniCpo()
		Endif
	EndIf
ElseIf lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o Produto nao for um produto de grade executa a validacao no SB1 ³
	//³ carrega o item na MATXFIS e inicializa os campos na getdados.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistBlock("MT103PBLQ")	
		lRet := ExistCpo("SB1")
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ O P.E. MT103PBLQ permite validar se produtos que estao bloqueados, podem  ³
		//³  ou nao ser utilizados na NFE ao realizar um RETORNO de doctos de Saida . ³
	 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	   DbSelectArea("SB1")
	   DbSetorder(1)
	   MsSeek(xFilial("SB1")+M->D1_COD)
	   lRet:=iif(eof(),.f.,.t.)
	EndIf
	If lRet
		MaFisRef("IT_PRODUTO","MT100",M->D1_COD)
		A103IniCpo()
	Endif
EndIf

RestArea(aArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103VldGrd³Autor  ³Alexandre Inacio Lemes ³ Data ³22/08/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos itens do Grid na grade de produtos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. se Valido e .F. se Invalido                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Objeto de Grade do MATA103                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103VldGrd()

Local lValido := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Houver necessidade de novas validacoes na entrada de dados nas   ³
//³ celulas do Grid elas deverao ser inseridas nessa funcao.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Positivo() 
	lValido := .T.
EndIf

Return lValido
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a103AjuICM³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para atualizar o objeto do mata103 (TFOLDER) com as  ³±±
±±³          ³ informacoes referentes ao lancamento fiscal.               ³±±
±±³          ³                                                            ³±±
±±³          ³Chamada: MAFISALT da MATXFIS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nZ -> Numero do item do documento fiscal.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a103AjuICM(nZ)
Local	nI			:=	0
Local	aGrava		:=	{0,"","","1",0,0,0}
Local 	cMvEstado	:= 	SuperGetMV("MV_ESTADO")
Local 	nPosIt		:=	0
Local 	nPosSeq		:=	0
Local 	nPosCLan	:=	0
Local 	nPosCSis	:=	0
Local 	nPos		:=	0
Local 	nPosX		:=	0
Local	cSeq		:=	"000"
Local	aBkpaCls	:=	{}
Local	cItem		:=	Iif(MaFisRet(,"NF_OPERNF")=="E","0001","01")
Local	lApagTudo	:=	.T.
Local	nTes		:=	0
Local	nTesI		:=	0
Local	nTesF		:=	0
Local	lIfcomp		:=	CDA->(FieldPos("CDA_IFCOMP")) > 0
Local	lTplanc		:=	CDA->(FieldPos("CDA_TPLANC")) > 0

Default	nZ	:=	0	//Por enquanto soh vem ZERO quando se tratar de uma nota fiscal que estah sendo classificada.

nTesI	:=	Iif (nZ==0, 1, nZ)
nTesF	:=	Iif (nZ==0, Len(aCols), nZ)

For nZ := nTesI To nTesF

	aGrava	:=	MaFisAjIt(nZ)
	
	If Len(aGrava)>0
		nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
		nPosSeq	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_SEQ"})
		nPosCLan:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CODLAN"})
		nPosCSis:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
		
		If nPosIt>0 .And. nPosSeq>0 .And. nPosCLan>0 .And. nPosCSis>0
			For nI := Len(oLancApICMS:aCols) To 1 Step -1
				If (!oLancApICMS:aCols[nI,Len(oLancApICMS:aCols[nI])] .And. Iif(nZ==1,cItem,MaFisRet(nZ,"IT_ITEM"))==oLancApICMS:aCols[nI,nPosIt]) .Or.;
					(Empty(oLancApICMS:aCols[nI,nPosIt]) .And. Len(oLancApICMS:aCols)==1)
					aDel(oLancApICMS:aCols,nI)
					aSize(oLancApICMS:aCols,Len(oLancApICMS:aCols)-1)
				EndIf
			Next nI
	
			If Len(oLancApICMS:aCols)>0
				aBkpaCls	:=	aClone(oLancApICMS:aCols)
				aSort(aBkpaCls,,,{|aX,aY| aX[nPosSeq]<aY[nPosSeq]})
				cSeq	:=	aBkpaCls[Len(aBkpaCls),nPosSeq]
			EndIf
	
			For nI := 1 To Len(aGrava)
				cSeq	:=	Soma1(cSeq)
				nPos	:=	aScan(oLancApICMS:aCols,{|aX| aX[nPosIt]==aGrava[nI,1] .And.;
														 aX[nPosCLan]==aGrava[nI,2] .And.;
														 aX[nPosCSis]==aGrava[nI,3] .And.;
														 aX[Len(oLancApICMS:aHeader)+1]==.F.})
				If nPos>0
					nPosX	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_BASE"})
					oLancApICMS:aCols[1,nPosX]	+=	aGrava[nI,4]
					nPosX	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_ALIQ"})
					oLancApICMS:aCols[1,nPosX]	:=	aGrava[nI,5]
					nPosX	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_VALOR"})
					oLancApICMS:aCols[1,nPosX]	+=	aGrava[nI,6]
				Else
					//Novo campo criado pelo compatibilizador UPDFIS
					If lIfcomp
	                	IF lTplanc
							aAdd(oLancApICMS:aCols,array(10))
							oLancApICMS:aCols[len(oLancApICMS:aCols),9] := aGrava[nI,9]
							oLancApICMS:aCols[len(oLancApICMS:aCols),10] := .F.                                                                                               
						Else
							aAdd(oLancApICMS:aCols,array(9))
							oLancApICMS:aCols[len(oLancApICMS:aCols),9] := .F.
						EndIf
						oLancApICMS:aCols[len(oLancApICMS:aCols),1] :=  aGrava[nI,1]
						oLancApICMS:aCols[len(oLancApICMS:aCols),2] :=  cSeq
						oLancApICMS:aCols[len(oLancApICMS:aCols),3] :=  aGrava[nI,2]
						oLancApICMS:aCols[len(oLancApICMS:aCols),4] :=  aGrava[nI,3]
						oLancApICMS:aCols[len(oLancApICMS:aCols),5] :=  aGrava[nI,4]
						oLancApICMS:aCols[len(oLancApICMS:aCols),6] :=  aGrava[nI,5]
						oLancApICMS:aCols[len(oLancApICMS:aCols),7] :=  aGrava[nI,6]
						oLancApICMS:aCols[len(oLancApICMS:aCols),8] :=  aGrava[nI,8]
					Else
						aAdd(oLancApICMS:aCols, {aGrava[nI,1],;
						cSeq,;
						aGrava[nI,2],;
						aGrava[nI,3],;
						aGrava[nI,4],;
						aGrava[nI,5],;
						aGrava[nI,6],;
						.F.})
					EndIf
				EndIf
			Next nI
		EndIf
	Else
		nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
		
		If nPosIt>0
			For nI := Len(oLancApICMS:aCols) To 1 Step -1
				If oLancApICMS:aCols[nI,nPosIt]==Iif(nZ==1,cItem,MaFisRet(nZ,"IT_ITEM")) .Or.;
					(Empty(oLancApICMS:aCols[nI,nPosIt]) .And. Len(oLancApICMS:aCols)==1)
					aDel(oLancApICMS:aCols,nI)
					aSize(oLancApICMS:aCols,Len(oLancApICMS:aCols)-1)
				Else
					lApagTudo	:=	.F.
				EndIf
			Next nI
			
			If lApagTudo
				oLancApICMS:aCols:=	{Array(Len(oLancApICMS:aHeader)+1)}
				oLancApICMS:aCols[1,Len(oLancApICMS:aHeader)+1]:=	.F.
				
				For nI := 1 To Len(oLancApICMS:aHeader)
					If oLancApICMS:aHeader[nI,10]#"V"
						oLancApICMS:aCols[1,nI]	:=	CriaVar(oLancApICMS:aHeader[nI,2])
					EndIf
			
					If "_SEQ"$oLancApICMS:aHeader[nI,2]
						oLancApICMS:aCols[1,nI]	:=	StrZero(1,oLancApICMS:aHeader[nI,4])
					EndIf
				Next
			EndIf
		EndIf
	EndIf
Next nZ
oLancApICMS:Refresh()
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³a103GrvCDA³ Autor ³ Gustavo G. Rueda      ³ Data ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de gravacao/exclusao das informacoes do documento    ³±±
±±³          ³ fiscal referente ao lancamento fiscal da apuracao de icms. ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lExclui -> Flag que indica exclusao do registro.            ³±±
±±³          ³cTipMov -> (E)nttrada ou (S)aida                            ³±±
±±³          ³cEspecie -> Especie do documento fiscal para montar a chave.³±±
±±³          ³cFormul -> Indicador de formulario proprio (S)im/(N)ao para ³±±
±±³          ³ montar a chave.                                            ³±±
±±³          ³cNFiscal -> Numero da nota fiscal para montar a chave.      ³±±
±±³          ³cSerie -> Serie do documento fiscal para montar a chave.    ³±±
±±³          ³cForn -> Codigo do fornecedor para montar a chave.          ³±±
±±³          ³cLoja -> Codigo da loja do fornecedor para montar a chave.  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a103GrvCDA(lExclui,cTipMov,cEspecie,cFormul,cNFiscal,cSerie,cForn,cLoja, aInfApurICMS)
Local	lRet	:=	.T.
Local	aArea	:=	GetArea()
Local	nI		:=	0
Local	nPosIte	:=	0
Local	nPosSeq	:=	0 
Local	cTPLanc	:=	0
Local	nTamCdaNu := TamSx3("CDA_NUMITE")[1]
Local	lIfcomp :=	CDA->(FieldPos("CDA_IFCOMP")) > 0
Local	lTplanc :=	CDA->(FieldPos("CDA_TPLANC")) > 0

Default aInfApurICMS := {};

cFormul	:=	IIF(cFormul=="S","S"," ")

If (((AliasIndic("CDA").And.Type("oLancApICMS")="O")) .Or. (Type("L103AUTO") <> "U" .And. (l103Auto)))

	dbSelectArea("CDA")
	CDA->(dbSetOrder(1))

	If lExclui

		If CDA->(MsSeek(xFilial("CDA")+cTipMov+cEspecie+cFormul+cNFiscal+cSerie+cForn+cLoja))
			While !CDA->(Eof()) .And.;
				xFilial("CDA")+cTipMov+cEspecie+cFormul+cNFiscal+cSerie+cForn+cLoja==;
				CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA)

				RecLock("CDA",.F.)
				CDA->(dbDelete())
				MsUnLock()
				CDA->(FkCommit())
				CDA->(dbSkip())		
			End
		EndIf
		
	Else
		If Type("L103AUTO") <> "U" .And. l103Auto
			If Len(aInfApurICMS) > 0	
				For nI := 1 To Len(aInfApurICMS)	
					
					If Empty(aInfApurICMS[nI][1][2])
						Loop
					EndIf
					
					cNumItem :=	aInfApurICMS[nI][1][1] 
					cCodLan	 := aInfApurICMS[nI][1][2]
					cCalPro	 :=	aInfApurICMS[nI][1][3]			
					nBase	 :=	aInfApurICMS[nI][1][4]
					nAliq	 :=	aInfApurICMS[nI][1][5]
					nValor	 :=	aInfApurICMS[nI][1][6]
					cNumSeq	 := aInfApurICMS[nI][1][7]	
				    cIFCOMP	 := aInfApurICMS[nI][1][8]			
				    cTPLanc	 :=	aInfApurICMS[nI][1][9]
					
					If CDA->(MsSeek(xFilial("CDA")+cTipMov+cEspecie+cFormul+cNFiscal+cSerie+cForn+cLoja+PadR(cNumItem,nTamCdaNu)+cNumSeq))
						RecLock("CDA",.F.)
					Else
						RecLock("CDA",.T.)
						CDA->CDA_FILIAL	:=	xFilial("CDA")
						CDA->CDA_TPMOVI	:=	cTipMov
						CDA->CDA_ESPECI	:=	cEspecie
						CDA->CDA_FORMUL	:=	cFormul
						CDA->CDA_NUMERO	:=	cNFiscal
						CDA->CDA_SERIE	:=	cSerie
						CDA->CDA_CLIFOR	:=	cForn
						CDA->CDA_LOJA	:=	cLoja
						CDA->CDA_NUMITE	:=	cNumItem
						CDA->CDA_SEQ	:=	cNumSeq		
					EndIf
					
					CDA->CDA_CODLAN	:=	cCodLan
					CDA->CDA_CALPRO	:=	cCalPro
					CDA->CDA_BASE	:=	nBase
					CDA->CDA_ALIQ	:=	nAliq
					CDA->CDA_VALOR	:=	nValor
					
					If lIfcomp
					   	CDA->CDA_IFCOMP	:=	cIFCOMP
					EndIf
					
					If lTplanc
					   	CDA->CDA_TPLANC	:=	cTPLanc
					EndIf 
					
					MsUnLock()
					CDA->(FkCommit())
				Next nI
			EndIf
		Else
			For nI := 1 To Len(oLancApICMS:aCols)
				If oLancApICMS:aCols[nI,Len(oLancApICMS:aCols[nI])]
					Loop
				EndIf
	
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CODLAN"})
				cCodLan	:=	oLancApICMS:aCols[nI,nPos]
				If Empty(cCodLan)
					Loop
				EndIf
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
				cNumItem:=	oLancApICMS:aCols[nI,nPos]
					
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_SEQ"})
				cNumSeq	:=	oLancApICMS:aCols[nI,nPos]
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
				cCalPro	:=	oLancApICMS:aCols[nI,nPos]
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_BASE"})
				nBase	:=	oLancApICMS:aCols[nI,nPos]
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_ALIQ"})
				nAliq	:=	oLancApICMS:aCols[nI,nPos]
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_VALOR"})
				nValor	:=	oLancApICMS:aCols[nI,nPos]
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_IFCOMP"})			
				cIFCOMP	:=	Iif(nPos==0,"",oLancApICMS:aCols[nI,nPos])
				
				nPos:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_TPLANC"})			
				cTPLanc	:=	Iif(nPos==0,"",oLancApICMS:aCols[nI,nPos])
				
				If CDA->(MsSeek(xFilial("CDA")+cTipMov+cEspecie+cFormul+cNFiscal+cSerie+cForn+cLoja+PadR(cNumItem,nTamCdaNu)+cNumSeq))
					RecLock("CDA",.F.)
				Else
					RecLock("CDA",.T.)
					CDA->CDA_FILIAL	:=	xFilial("CDA")
					CDA->CDA_TPMOVI	:=	cTipMov
					CDA->CDA_ESPECI	:=	cEspecie
					CDA->CDA_FORMUL	:=	cFormul
					CDA->CDA_NUMERO	:=	cNFiscal
					CDA->CDA_SERIE	:=	cSerie
					CDA->CDA_CLIFOR	:=	cForn
					CDA->CDA_LOJA	:=	cLoja
					CDA->CDA_NUMITE	:=	cNumItem
					CDA->CDA_SEQ	:=	cNumSeq
				EndIf
				CDA->CDA_CODLAN	:=	cCodLan
				CDA->CDA_CALPRO	:=	cCalPro
				CDA->CDA_BASE	:=	nBase
				CDA->CDA_ALIQ	:=	nAliq
				CDA->CDA_VALOR	:=	nValor
				
				If lIfcomp
					CDA->CDA_IFCOMP	:=	cIFCOMP
				EndIf
				If lTplanc
					CDA->CDA_TPLANC	:=	cTPLanc
				EndIf
				MsUnLock()
				CDA->(FkCommit())
			Next nI
			
			//Tratamento para deletar os registros que nao foram reaproveitados acima no caso de reutilizacao de numeracao de nota
			If CDA->(MsSeek(xFilial("CDA")+cTipMov+cEspecie+cFormul+cNFiscal+cSerie+cForn+cLoja))
				nPosIte:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
				nPosSeq:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_SEQ"})
				While !CDA->(Eof()) .And.;
					CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA)==;
					xFilial("CDA")+cTipMov+cEspecie+cFormul+cNFiscal+cSerie+cForn+cLoja
					
					If aScan(oLancApICMS:aCols,{|aX|PadR(aX[nPosIte],nTamCdaNu)==CDA->CDA_NUMITE .And. aX[nPosSeq]==CDA->CDA_SEQ})==0
						RecLock("CDA",.F.)
						dbDelete()
						MsUnLock()
						CDA->(FkCommit())
					EndIf
					
					CDA->(dbSkip())
				End
			EndIf
		EndIf		
	EndIf
EndIf
	           
RestArea(aArea)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetLanc   ³ Autor ³ Gustavo G. Rueda      ³ Data  ³13/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Quando estiver utilizando o flag de whenget(abre nota fiscal)³±±
±±³          ³ com valores a serem alterados.(funcao retornar) utilizo esta³±±
±±³          ³ funcao para carregar os lancamentos das TES do acols da NFE.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetLanc()
Local	nPosTes		:=	0
Local	nZ			:=	0
Local	aLancFis	:=	{}

If Len(aHeader)>0
	nPosTes	:=	aScan(aHeader,{|aX| aX[2]==PadR("D1_TES",Len(SX3->X3_CAMPO))})
    If Len(aCols)>0 .And. nPosTes>0
    	For nZ := 1 To Len(aCols)
			a103AjuICM(nZ)
		Next nI
    EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103TrfSld³ Autor ³ Microsiga S/A         ³ Data ³23/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao utilizada para transferir o saldo classificado para  ³±±
±±³          ³o Armazem de Transito definido pelo parametro MV_LOCTRAN.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lDeleta - .T. = Exclusao NFE                                ³±±
±±³          ³          .F. = Classificao da Pre-Nota                     ³±±
±±³          ³nTipo   - 1 = Transferencia para Armazem de Transito        ³±±
±±³          ³          2 = Retorno do saldo para o armazem orginal       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A103TrfSld(lDeleta,nTipo)
Local aAreaAnt   := GetArea()
Local aAreaSF4   := SF4->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local aAreaSB2   := SD3->(GetArea())
Local cLocTran   := SuperGetMV("MV_LOCTRAN",.F.,"95")
Local cLocCQ     := SuperGetMV("MV_CQ",.F.,"98")
Local aArray     := {}
Local aStruSD3   := {}
Local cSeek      := ''
Local cQuery     := ''
Local cAliasSD3  := 'SD3'
Local cChave     := Space(TamSX3("D3_CHAVE")[1])
Local nX         := 0
Local lQuery     := .F.
Local lContinua  := .F.
Local lVldPE  	 := .T.

Default lDeleta     := .F.
Default nTipo       := 1

Private lMsErroAuto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para validar se permite a operacao			|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A103TRFVLD")
	lVldPE:= ExecBlock("A103TRFVLD",.F.,.F.,{nTipo,lDeleta})
	If Valtype (lVldPE) != "L"
		lVldPE:= .T.
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remessa para o Armazem de Transito                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 .And. lVldPE
	If SF4->(FieldPos('F4_TRANSIT')) > 0 .And. SD1->(FieldPos('D1_TRANSIT')) > 0
		If !Localiza(SD1->D1_COD) .And. Empty(SD1->D1_OP) .And. AllTrim(SD1->D1_LOCAL) # AllTrim(cLocCQ)
			dbSelectArea("SF4")
			dbSetOrder(1)
			//-- Tratamento para Transferencia de Saldos		
			If MsSeek(xFilial("SF4")+SD1->D1_TES) .And. SF4->F4_ESTOQUE == 'S' .And. ;
	           SF4->F4_TRANSIT == 'S' .And. SF4->F4_CODIGO <= '500'
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estorno da transferencia para o Armazem de Terceiros        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lDeleta .And. !Empty(SD1->D1_TRANSIT)
					//-- Retira o Flag que indica produto em transito
					RecLock("SD1",.F.)
					SD1->D1_TRANSIT := " "
					MsUnLock()
					lMsErroAuto := .F.
					cSeek:=xFilial("SD3")+SD1->D1_NUMSEQ+cChave+SD1->D1_COD
					#IFDEF TOP
					If TcSrvType()<>"AS/400"
						aStruSD3 := SD3->(dbStruct())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Selecionar os registros da SD3 pertencentes a movimentacao de transferencia         ³
						//³ e recebimento do armazem de transito. Pode ser que a nota ja tenha sido recebida    ³
						//³ atraves do botao "Docto. em transito" e entao o saldo do armazem de transito tambem ³
						//³ deve ser estornado. Primeiro as saidas, depois as entradas.                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cQuery := "SELECT D3_FILIAL, D3_COD, D3_LOCAL, D3_NUMSEQ, D3_CF, D3_TM, D3_ESTORNO "
						cQuery +=  " FROM "+RetSQLTab('SD3')
						cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
						cQuery +=   " AND D_E_L_E_T_  = ' ' "
						cQuery +=   " AND D3_ESTORNO <> 'S' "
						cQuery += 	" AND D3_COD      = '"+SD1->D1_COD+"' "
						cQuery += 	" AND D3_NUMSEQ   = '"+SD1->D1_NUMSEQ+"' "
						cQuery += " ORDER BY D3_FILIAL, D3_COD, D3_TM DESC "
	
						//--Executa a Query
						lQuery    := .T.
						cAliasSD3 := GetNextAlias()
						cQuery    := ChangeQuery( cQuery )
						DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasSD3, .T., .F. )
						For nX := 1 To Len(aStruSD3)
							If aStruSD3[nX,2]<>"C"
								TcSetField(cAliasSD3,aStruSD3[nX,1],aStruSD3[nX,2],aStruSD3[nX,3],aStruSD3[nX,4])
							EndIf
						Next nX
					Else
					#ENDIF
						dbSelectArea(cAliasSD3)
						dbSetOrder(4)
						dbSeek(cSeek)
					#IFDEF TOP
					EndIf
					#ENDIF
					
					Do While !(cAliasSD3)->(Eof()) .And. cSeek == xFilial("SD3")+(cAliasSD3)->D3_NUMSEQ+cChave+(cAliasSD3)->D3_COD
						//-- Nao considerar estornos
						If (cAliasSD3)->D3_ESTORNO == 'S'
							(cAliasSD3)->(dbSkip())
							Loop
						EndIf
						aAdd(aArray,{{"D3_FILIAL"	,(cAliasSD3)->D3_FILIAL , NIL},;
									 {"D3_COD"		,(cAliasSD3)->D3_COD	, NIL},;
								     {"D3_LOCAL"	,(cAliasSD3)->D3_LOCAL	, NIL},;
									 {"D3_NUMSEQ"	,(cAliasSD3)->D3_NUMSEQ , NIL},;
									 {"D3_CF"		,(cAliasSD3)->D3_CF     , NIL},;
									 {"D3_TM"		,(cAliasSD3)->D3_TM     , NIL},;
									 {"INDEX"		,3						, NIL} })
						
						(cAliasSD3)->(dbSkip())
					EndDo
					
					// Ordenar o vetor para que as saidas sejam estornadas primeiro
					aSort(aArray,,,{|x,y| x[1,2]+x[2,2]+x[5,2] > y[1,2]+y[2,2]+y[5,2]})
                                              
					// Percorre todo o vetor com os registros a estornar
					For nX := 1 to Len(aArray)
                        
						// Se for movimento de entrada e do armazem de transito
						If (aArray[nX][6][2] <= "500") .And. (aArray[nX][3][2] == cLocTran)
							//-- Desbloqueia o armazem de terceiro
							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
								RecLock("SB2",.F.)
								Replace B2_STATUS With "1"
								MsUnLock()
							EndIf	
						EndIf
						
						MATA240(aArray[nX], 5) // Operacao de estorno do movimento interno (SD3)

						// Se for movimento de entrada e do armazem de transito
						If (aArray[nX][6][2] <= "500") .And. (aArray[nX][3][2] == cLocTran)
							//-- Bloqueia o armazem de terceiro
							dbSelectArea("SB2")
							dbSetOrder(1)
							If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
								RecLock("SB2",.F.)
								Replace B2_STATUS With "2"
								MsUnLock()
							EndIf	
						EndIf
					Next nX						
					
					If lQuery
						//--Fecha a area corrente
						dbSelectArea(cAliasSD3)
						dbCloseArea()
						dbSelectArea("SD3")
					EndIf
					
					//-- Tratamento de erro para rotina automatica
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						Break
					EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Transferencia para o Armazem de Terceiros                   |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf !lDeleta
					//-- Grava Flag que indica produto em transito
					RecLock("SD1",.F.)
					SD1->D1_TRANSIT := "S"
					MsUnLock()
					//-- Requisita o produto do armazem origem (Valorizado)
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
						RecLock("SD3",.T.)
						SD3->D3_FILIAL	:= xFilial("SD3")
						SD3->D3_COD		:= SD1->D1_COD
						SD3->D3_QUANT	:= SD1->D1_QUANT
						SD3->D3_TM		:= "999"
						SD3->D3_OP		:= SD1->D1_OP
						SD3->D3_LOCAL	:= SD1->D1_LOCAL
						SD3->D3_DOC		:= SD1->D1_DOC
						SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
						SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
						SD3->D3_UM		:= SD1->D1_UM
						SD3->D3_GRUPO	:= SD1->D1_GRUPO
						SD3->D3_TIPO	:= SD1->D1_TP
						SD3->D3_SEGUM	:= SD1->D1_SEGUM
						SD3->D3_CONTA	:= SD1->D1_CONTA
						SD3->D3_CF		:= "RE6"
						SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
						SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
						SD3->D3_CUSTO1	:= SD1->D1_CUSTO
						SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
						SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
						SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
						SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
						SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
						SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
						SD3->D3_DTVALID	:= SD1->D1_DTVALID
						SD3->D3_POTENCI	:= SD1->D1_POTENCI
						MsUnLock()
						dbSelectArea("SB2")
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						lContinua := .T.
					EndIf	
					//-- Devolucao do produto para o armazem destino (Valorizado)
					If lContinua
						dbSelectArea("SB2")
						dbSetOrder(1)
						If !dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							CriaSB2(SD1->D1_COD,cLocTran)
						EndIf
						//-- Desbloqueia o armazem de terceiro
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							RecLock("SB2",.F.)
							Replace B2_STATUS With "1"
							MsUnLock()
						EndIf	
						RecLock("SD3",.T.)
						SD3->D3_FILIAL	:= xFilial("SD3")
						SD3->D3_COD		:= SD1->D1_COD
						SD3->D3_QUANT	:= SD1->D1_QUANT
						SD3->D3_TM		:= "499"
						SD3->D3_LOCAL	:= cLocTran
						SD3->D3_DOC		:= SD1->D1_DOC
						SD3->D3_EMISSAO	:= SD1->D1_DTDIGIT
						SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
						SD3->D3_UM		:= SD1->D1_UM
						SD3->D3_GRUPO	:= SD1->D1_GRUPO
						SD3->D3_TIPO	:= SD1->D1_TP
						SD3->D3_SEGUM	:= SD1->D1_SEGUM
						SD3->D3_CONTA	:= SD1->D1_CONTA
						SD3->D3_CF		:= "DE6"
						SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
						SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
						SD3->D3_CUSTO1	:= SD1->D1_CUSTO
						SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
						SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
						SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
						SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
						SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
						SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
						SD3->D3_DTVALID	:= SD1->D1_DTVALID
						SD3->D3_POTENCI	:= SD1->D1_POTENCI
						MsUnLock()
						dbSelectArea("SB2")
						B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
						//-- Bloqueia o armazem de terceiro
						dbSelectArea("SB2")
						dbSetOrder(1)
						If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
							RecLock("SB2",.F.)
							Replace B2_STATUS With "2"
							MsUnLock()
						EndIf	
			    	EndIf
			    EndIf	
			EndIf
		EndIf	
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno para o Armazem Original                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nTipo == 2 .And. lVldPE
	//-- Grava Flag que indica produto em transito
	RecLock("SD1",.F.)
	SD1->D1_TRANSIT := " "
	MsUnLock()
	//-- Desbloqueia o armazem de terceiro
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
		RecLock("SB2",.F.)
		Replace B2_STATUS With "1"
		MsUnLock()
	EndIf	
	//-- Requisita o produto do armazem de transito (Valorizado)
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
		RecLock("SD3",.T.)
		SD3->D3_FILIAL	:= xFilial("SD3")
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_TM		:= "999"
		SD3->D3_OP		:= SD1->D1_OP
		SD3->D3_LOCAL	:= cLocTran
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_GRUPO	:= SD1->D1_GRUPO
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_SEGUM	:= SD1->D1_SEGUM
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_CF		:= "RE6"
		SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
		SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
		SD3->D3_CUSTO1	:= SD1->D1_CUSTO
		SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
		SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
		SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
		SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
		SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
		SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
		SD3->D3_DTVALID	:= SD1->D1_DTVALID
		SD3->D3_POTENCI	:= SD1->D1_POTENCI
		MsUnLock()
		dbSelectArea("SB2")
		B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
		MsUnLock()
		//-- Bloqueia o armazem de terceiro
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+SD1->D1_COD+cLocTran)
			RecLock("SB2",.F.)
			Replace B2_STATUS With "2"
			MsUnLock()
		EndIf	
		lContinua := .T.
	EndIf	
	//-- Devolucao do produto para o armazem destino (Valorizado)
	dbSelectArea("SB2")
	dbSetOrder(1)
	If lContinua .And. dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
		RecLock("SD3",.T.)
		SD3->D3_FILIAL	:= xFilial("SD3")
		SD3->D3_COD		:= SD1->D1_COD
		SD3->D3_QUANT	:= SD1->D1_QUANT
		SD3->D3_TM		:= "499"
		SD3->D3_LOCAL	:= SD1->D1_LOCAL
		SD3->D3_DOC		:= SD1->D1_DOC
		SD3->D3_EMISSAO	:= dDataBase
		SD3->D3_NUMSEQ	:= SD1->D1_NUMSEQ
		SD3->D3_UM		:= SD1->D1_UM
		SD3->D3_GRUPO	:= SD1->D1_GRUPO
		SD3->D3_TIPO	:= SD1->D1_TP
		SD3->D3_SEGUM	:= SD1->D1_SEGUM
		SD3->D3_CONTA	:= SD1->D1_CONTA
		SD3->D3_CF		:= "DE6"
		SD3->D3_QTSEGUM	:= SD1->D1_QTSEGUM
		SD3->D3_USUARIO	:= SubStr(cUsuario,7,15)
		SD3->D3_CUSTO1	:= SD1->D1_CUSTO
		SD3->D3_CUSTO2	:= SD1->D1_CUSTO2
		SD3->D3_CUSTO3	:= SD1->D1_CUSTO3
		SD3->D3_CUSTO4	:= SD1->D1_CUSTO4
		SD3->D3_CUSTO5	:= SD1->D1_CUSTO5
		SD3->D3_NUMLOTE	:= SD1->D1_NUMLOTE
		SD3->D3_LOTECTL	:= SD1->D1_LOTECTL
		SD3->D3_DTVALID	:= SD1->D1_DTVALID
		SD3->D3_POTENCI	:= SD1->D1_POTENCI
		MsUnLock()
		dbSelectArea("SB2")
		B2AtuComD3({SD3->D3_CUSTO1,SD3->D3_CUSTO2,SD3->D3_CUSTO3,SD3->D3_CUSTO4,SD3->D3_CUSTO5})
		MsUnLock()
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada finalidades diversas na rotina de transferência de Armazem de Trânsito³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT103TRF") 
	ExecBlock("MT103TRF",.F.,.F.,{nTipo,SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM})
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSD1)
RestArea(aAreaSD3)
RestArea(aAreaSF4)
RestArea(aAreaAnt)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103RetTrf³ Autor ³ Microsiga S/A         ³ Data ³23/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para retornar o saldo das notas fiscais em ³±±
±±³          ³transito.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103RetTrf()
Local lContinua	:= .T.
Local nOpca     := 0
Local nCnt      := 0
Local nPosDoc   := 0
Local nPosSerie := 0
Local nPosItem  := 0
Local nPosLoja  := 0
Local nPosForn  := 0
Local nPosCod   := 0
Local aCabSD1   := {}
Local aSD1      := {}
Local aCpoSD1   := {}
Local aAux      := {}
Local aButtons  := {}
Local cDocTran  := CriaVar("D1_DOC",.F.)
Local cSerTran  := CriaVar("D1_SERIE",.F.)
Local oDlg, oListBox, oPanel, oBut1, dDataFec

If SD1->(FieldPos('D1_TRANSIT')) > 0 .And. SF4->(FieldPos('F4_TRANSIT')) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar data do ultimo fechamento                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDataFec := If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
	If dDataFec >= dDataBase
		Help( " ", 1, "FECHTO" )
		lContinua := .F.
    EndIf
	If lContinua
		Aadd( aCabSD1, 'Ok' )
		SX3->(DbSetOrder(1))
		SX3->(DbSeek("SD1"))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SD1" 
			If AllTrim(SX3->X3_CAMPO) $ "D1_DOC|D1_SERIE|D1_ITEM|D1_COD|D1_LOCAL|D1_QUANT|D1_TRANSIT|D1_FORNECE|D1_LOJA|D1_COD"
				Aadd( aCabSD1, X3Titulo() )
				Aadd( aCpoSD1, SX3->X3_CAMPO )
				If AllTrim(SX3->X3_CAMPO) == "D1_DOC"
					nPosDoc   := 1+Len(aCpoSD1)
				ElseIf AllTrim(SX3->X3_CAMPO) == "D1_SERIE"
					nPosSerie := 1+Len(aCpoSD1)
				ElseIf AllTrim(SX3->X3_CAMPO) == "D1_ITEM"
					nPosItem  := 1+Len(aCpoSD1)
				ElseIf AllTrim(SX3->X3_CAMPO) == "D1_FORNECE"
					nPosForn  := 1+Len(aCpoSD1)
				ElseIf AllTrim(SX3->X3_CAMPO) == "D1_LOJA"
					nPosLoja  := 1+Len(aCpoSD1)
				ElseIf AllTrim(SX3->X3_CAMPO) == "D1_COD"
					nPosCod  := 1+Len(aCpoSD1)
				EndIf
			EndIf	
			SX3->(DbSkip())
		EndDo
		//-- Carrega Registro em Branco
		aAux := {}
		Aadd( aAux, .F. )
		For nCnt := 1 To Len(aCpoSD1)
			Aadd( aAux, CriaVar(aCpoSD1[nCnt],.F.) )
		Next nCnt
		aAdd( aSD1, aClone(aAux) )
		//-- Adiciona botao para exibir os documentos em transito
		Aadd(aButtons, {'RECALC',{||A103FilTRF(@oListBox,@aCpoSD1,@aSD1,cDocTran,cSerTran)},STR0298,STR0298}) //"Visualizar documento em transito"
	
		//-- Monta Dialog
		DEFINE MSDIALOG oDlg TITLE STR0297 FROM 00,00 TO 300,600 PIXEL
	
		@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
		oPanel:Align := CONTROL_ALIGN_TOP
	
		oListBox:= TWBrowse():New( 012, 000, 300, 140, NIL, aCabSD1, NIL, oDlg, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
		oListBox:SetArray( aSD1 )
		oListBox:bLDblClick  := { || { aSD1[oListBox:nAT,1] := !aSD1[oListBox:nAT,1] }}
		oListBox:bLine := &('{ || A103Line(oListBox:nAT,aSD1) }')
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	
		@ 6  ,4   SAY SD1->(RetTitle("D1_DOC"))			Of oPanel PIXEL
		@ 4  ,35  MSGET cDocTran PICTURE '@!' When .T.	Of oPanel PIXEL
	
		@ 6  ,150  SAY SD1->(RetTitle("D1_SERIE"))		Of oPanel PIXEL
		@ 4  ,175  MSGET cSerTran PICTURE '@!' When .T.	Of oPanel PIXEL
	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpca := 1,,oDlg:End())},{||(nOpca := 0,,oDlg:End())},,aButtons)
	
		//-- Processando Retorno de saldo em Transito
		If nOpca == 1
			For nCnt := 1 to Len(aSD1)
				If aSD1[nCnt,1]
					dbSelectArea("SD1")
					dbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					If dbSeek(xFilial("SD1")+aSD1[nCnt,nPosDoc]+aSD1[nCnt,nPosSerie]+aSD1[nCnt,nPosForn]+aSD1[nCnt,nPosLoja]+aSD1[nCnt,nPosCod]+aSD1[nCnt,nPosItem])
						Processa({|| A103TrfSld(.F.,2) })
					EndIf
				EndIf
			Next nCnt
		EndIf
	EndIf
Else
	Aviso(STR0178,STR0299,{"Ok"}) //"ATENÇÃO"##"Para utilizar o processo de transferencia para o armazem de transito, voce devera executar o compatibilizador de estoque numero 23 - 'UPDEST23'"
EndIf
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103FilRet³ Autor ³ Microsiga S/A         ³ Data ³23/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao utilizada para carregar a TWBrowse com os documentos ³±±
±±³          ³de entrada em transito.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oListBox - Objeto TWBrowse()                               ³±±
±±³          ³ aCpoSD1  - Array com o cabecalho da TWBrowse               ³±±
±±³          ³ aSD1     - Array com os itens da TWBrowse                  ³±±
±±³          ³ cDocTran - Documento selecionado pelo usuario              ³±±
±±³          ³ cSerTran - Serie selecionada pelo usuario                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A103FilTRF(oListBox,aCpoSD1,aSD1,cDocTran,cSerTran)
Local cQuery    := ''
Local cIndex    := ''
Local cAliasSD1 := 'SD1'
Local aAux      := {}
Local aStruSD1  := {}
Local nCnt      := 0

#IFDEF TOP
	cAliasSD1 := GetNextAlias()
	aStruSD1  := SD1->( dbStruct() ) 	
	cQuery := " SELECT SD1.* "
	cQuery +=   " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery +=  " WHERE D1_FILIAL  = '" + xFilial("SD1") + "' "
	cQuery +=        " AND D1_TRANSIT = 'S' "
	If !Empty(cDocTran)
		cQuery +=    " AND D1_DOC = '"+cDocTran+"' "
	EndIf
	If !Empty(cSerTran)
		cQuery +=    " AND D1_SERIE = '"+cSerTran+"' "
	EndIf
	cQuery +=        " AND D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSD1, .F., .T. )
	For nCnt := 1 To Len(aStruSD1)
		If aStruSD1[nCnt,2]<>"C"
			TcSetField(cAliasSD1,aStruSD1[nCnt,1],aStruSD1[nCnt,2],aStruSD1[nCnt,3],aStruSD1[nCnt,4])
		EndIf
	Next nCnt
#ELSE
	dbSelectArea("SD1")
	cIndex := CriaTrab(NIL,.F.)
	cQuery := " D1_FILIAL == '" + xFilial("SD1") + "' "
	cQuery += " .AND. D1_TRANSIT  == 'S' "
	If !Empty(cDocTran)
		cQuery +=  " .AND. D1_DOC == '"+cDocTran+"' "
	EndIf
	If !Empty(cSerTran)
		cQuery +=  " .AND. D1_SERIE == '"+cSerTran+"' "
	EndIf
	IndRegua("SD1",cIndex,"D1_FILIAL+D1_DOC+D1_SERIE+D1_ITEM",,cQuery)
	SD1->(DbGotop())
#ENDIF
//-- Limpa array aSD1
For nCnt := 1 To Len(aSD1)
	aDel(aSD1,1)
	aSize(aSD1,Len(aSD1)-1)
Next
//-- Carrega Itens em Transito
Do While (cAliasSD1)->(!Eof())
	aAux := {}
	Aadd( aAux, .F. )
	For nCnt := 1 To Len(aCpoSD1)
		Aadd( aAux, &(aCpoSD1[nCnt]) )
	Next nCnt
	aAdd( aSD1, aClone(aAux) )
	(cAliasSD1)->(DbSkip())
EndDo
//-- Carrega Registro em Branco
aAux := {}
If Len(aSD1) == 0
	Aadd( aAux, .F. )
	For nCnt := 1 To Len(aCpoSD1)
		Aadd( aAux, CriaVar(aCpoSD1[nCnt],.F.) )
	Next nCnt
	aAdd( aSD1, aClone(aAux) )
EndIf	
//-- Atualiza TWBrowse()
oListBox:Refresh()
//-- Apaga arquivo temporario
#IFDEF TOP
	(cAliasSD1)->(DbCloseArea())
#ELSE
	RetIndex( "SD1" )
	FErase(cIndex+OrdBagExt())
#ENDIF
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A103OPBenºAutor  ³Andre Anjos         º Data ³  14/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Sugere a ordem de producao de acordo com a remessa.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA103                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103OPBen(cAliasSD2, nTpCtlBN)
Local aArea       := GetArea()
Local cRet        := Space(TamSX3("D1_OP")[1])
Default cAliasSD2 := 'SD2'
Default nTpCtlBN  := 1 // Para manter o comportamento padrao da funcao

If !Empty((cAliasSD2)->(D2_PEDIDO+D2_ITEMPV))
	If nTpCtlBN == 1 // metodo antigo: um unico envio
		dbSelectArea("SD4")
		dbSetOrder(6)
		If MsSeek(xFilial("SD4")+(cAliasSD2)->(D2_PEDIDO+D2_ITEMPV))
			cRet := SD4->D4_OP
		EndIf
	Else // metodo novo: multiplos envios
		dbSelectArea("SGO")
		dbSetOrder(2) // GO_FILIAL+GO_NUMPV+GO_ITEMPV+GO_OP+GO_COD+GO_LOCAL
		MsSeek(xFilial("SGO")+(cAliasSD2)->(D2_PEDIDO+D2_ITEMPV))
		If !Eof() .And. ( GO_FILIAL+GO_NUMPV+GO_ITEMPV == (cAliasSD2)->(D2_FILIAL+D2_PEDIDO+D2_ITEMPV) )
			cRet := SGO->GO_OP
		EndIf
	EndIf
	// Se nao encontrou referencia na SD4 nem na SGO entao procura na SDC
	If Empty(cRet)
		dbSelectArea("SDC")
		dbSetOrder(1)
		If !Empty((cAliasSD2)->(D2_COD+D2_LOCAL+"SC2"+D2_PEDIDO+D2_ITEMPV)) .And. MsSeek(xFilial("SDC")+(cAliasSD2)->(D2_COD+D2_LOCAL+"SC2"+D2_PEDIDO+D2_ITEMPV))
			cRet := SDC->DC_OP
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A103MNat ºAutor  ³Julio C.Guerato     º Data ³  02/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para carregar aColsSev quando carregado pelo PE     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ aHeadSev - Header Multiplas Naturezas                      ³±±
±±³          ³ aColsSev - ACOLS Multiplas Naturezas        		          ³±±
±±ºUso       ³ MATA103                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103MNat(aHeadSev, aColsSev) 
Local aCR := {}    

If SuperGetMv("MV_MULNATP") .And. !__lPyme    
	If ( ExistBlock("MT103MNT") )			
		aCR := ExecBlock("MT103MNT",.F.,.F.,{aHeadSev, aColsSev})
		If ( ValType(aCR) == "A" )
			aColsSev := aClone(aCR)     
			Eval(bRefresh,6,6)
		EndIf
	EndIf
EndIf
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103ATUPREV³Autor 	   ³Vitor Raspa       ³Data  ³ 20.Jun.08³±±
±±³          ³           ³Padronização ³Julio C.Guerato   ³Data  ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o saldo previsto de entrada na tabela que faz o     ³±±
±±³			 ³ controle de amarração entre Filial Centralizadora X Entrega  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103AtuPrev( lExclusao )

Local cFilCen  := ''

Local aArea    := {}
Local aAreaSDP := {}
Local aAreaSM0 := {}
Local aAreaSA2 := {}
Local nQTPCCEN := 0

If SD1->( FieldPos('D1_PCCENTR') ) > 0 .And. SD1->( FieldPos('D1_ITPCCEN') ) > 0
	If !Empty( SD1->D1_PCCENTR ) .And. !Empty( SD1->D1_ITPCCEN )	
		aArea    := GetArea()
		aAreaSDP := SDP->( GetArea() )
		aAreaSM0 := SM0->( GetArea() )
		aAreaSA2 := SA2->( GetArea() )

		//--Obtem a filial de onde esta vindo o produto
		SA2->( DbSetOrder(1) )
		SA2->( MsSeek( xFilial('SA2') + SD1->(D1_FORNECE + D1_LOJA) ) )

		SM0->( DbSetOrder(1) )
		SM0->( DbSeek( cEmpAnt ) )
		While !SM0->( Eof() ) .And. Empty( cFilCen )
			If AllTrim( SA2->A2_CGC ) == AllTrim( SM0->M0_CGC )
				cFilCen := FWGETCODFILIAL
			EndIf
			SM0->( DbSkip() )
		End

		RestArea( aAreaSM0 )
		RestArea( aAreaSA2 )

		//--Atualiza o saldo da Qtd. Prevista a entrar...
		SDP->( DbSetOrder(2) ) //--DP_FILIAL+DP_FILCEN+DP_FILNEC+DP_PEDCEN+DP_ITPCCN
		If SDP->( MsSeek( xFilial('SDP') + cFilCen + cFilAnt + SD1->(D1_PCCENTR + D1_ITPCCEN) ) )

			RecLock('SDP',.F.)
			If lExclusao
			    If SDP->DP_QTDENT<SD1->D1_QUANT
				    SDP->DP_QTDENT := 0
				Else
					SDP->DP_QTDENT := SDP->DP_QTDENT - SD1->D1_QUANT			
				EndIf  
		    Else
			    If (SDP->DP_QUANT-DP_QTDENT)<SD1->D1_QUANT
				    If (SDP->DP_QUANT-DP_QTDENT)>0 .And. (SDP->DP_QUANT-DP_QTDENT)<SD1->D1_QUANT
					    nQTPCCEN :=SDP->DP_QUANT-DP_QTDENT
					Else
						nQTPCCEN := 0
					EndIf
				    SDP->DP_QTDENT := SDP->DP_QUANT
				Else
					SDP->DP_QTDENT := SDP->DP_QTDENT + SD1->D1_QUANT
					nQTPCCEN := SD1->D1_QUANT
				EndIf
				RecLock('SD1',.F.)
				   SD1->D1_QTPCCEN := nQTPCCEN
				SD1->( MsUnLock() )
			EndIf		
			SDP->( MsUnLock() )
		EndIf
		RestArea( aAreaSDP )
		RestArea( aArea )
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103VALPCC ³Autor 	   ³Julio C.Guerato   ³Data  ³ 30.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida amarração entre NFE X Pedido de Compras Centralizado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nItem = Número do Item no Acols                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103ValPCC(nItem)

Local aArea    	   := GetArea()
Local nPosCod  	   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"}) 
Local nPosQuant    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosPC	   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"}) 
Local nPosItemPC   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"}) 
Local nPosPCCENTR  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PCCENTR"}) 
Local nPosITPCCEN  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITPCCEN"}) 
Local nQTPrev      := 0
Local nX           := 0
Local nVPCCNFE     := SuperGetMv("MV_VPCCNFE",.F.,1)
Local lRet     	   := .T. 
Local lPyme		   := If(Type("__lPyme") <> "U",__lPyme,.F.)

If AliasInDic("SDP") .And. cTipo=="N" .And. !lPyme
	If nPosPC>0 .And. nPosItemPc>0 .And. nPosPCCENTR>0 .And. nPosITPCCEN>0 .And. nPosCod>0 .And. nPosQuant>0
	   //Verifica se o Pedido que está sendo recebido na NFE é o Pedido de Compras da Filial Centralizadora
	   //. Se NÃO for fim de arquivo, significa o Pedido Centralizado está sendo recebido e não exige amarração
	   //  ou não existe pedido de compras vinculado a Nota Fiscal 
	   //. Se for fim de arquivo, exige amarração com o Pedido Centralizado para baixar o saldo previsto na tabela SDP
   	   DbSelectArea("SDP")
	   DbSetOrder(4)
	   MsSeek(xFilial('SDP')+xFilial('SD1')+aCols[nItem][nPosPC]+aCols[nItem][nPosItemPC])
	   If Eof()     
	       //Verifica se o Pedido que está sendo recebido possui amarração com um Pedido de Vendas.
	       //Se Não for fim de arquivo, possui vinculo com o Pedido de Compras da Filial Centralizadora
	       //Se for fim de arquivo, não possui vinculo com o Pedido de Compras da Filial Centralizadora
	       DbSelectArea("SC7")
	       DbSetOrder(14)
		   MsSeek(xFilEnt(xFilial('SC7'))+aCols[nItem][nPosPC]+aCols[nItem][nPosItemPC])
	   	   DbSelectArea("SC6")
	   	   DbSetOrder(10)
	 	   MsSeek(SC7->C7_FILCEN+xFilial('SD1')+aCols[nItem][nPosPC]+aCols[nItem][nPosItemPC])
	 	   If !Eof()                   
	 	        //Permite vincular o PC a NFe somente se o PV estiver faturado
	 	        If (SC6->C6_QTDVEN-SC6->C6_QTDENT)<>0
	 	           Aviso("A103ValPCC6",STR0329+"  "+STR0323+STRZERO(nItem,TamSX3("D1_ITEM")[1])+"  "+CHR(13)+STR0330+SC6->C6_NUM,{"Ok"})
			 	   lRet := .F.
			 	EndIf                                               
			 	//Valida vinculo com o PC centralizado
			 	If lRet
					If Empty(aCols[nItem][nPosPCCENTR]) .Or. Empty(aCols[nItem][nPosITPCCEN])
					   If nVPCCNFE<>0
			   			   Aviso("A103ValPCC1",STR0319+CHR(13)+STR0323+STRZERO(nItem,TamSX3("D1_ITEM")[1]),{"Ok"})
				 		   lRet := .F.
					   EndIf
			 		Else
					   DbSelectArea("SDP")
					   DbSetOrder(5)
					   MsSeek(xFilial('SDP')+xFilial('SD1')+aCols[nItem][nPosCod])
					   If !Eof()   
					      //Verifica quantidade já relacionada a NFE referente ao Pedido Centralizado//
			       		  For nX := 1 to Len(aCols) 
					       	    If !GdDeleted(nx)
				   			       If nx<>nItem .And. aCols[nX][nPosCod]==Acols[nItem][nPosCod]
				   			          nQTPrev := nQTPrev+Acols[nX][nPosQuant]
				   			       Endif
				   			 	Endif
			   			  Next NX   
			   			  
			   			  //Pedido está sendo baixado, porém o parâmetro MV_VPCCNFE não está configurado com o valor correto //
			   			  If nVPCCNFE=0   
				   			  Aviso("A103ValPCC5",STR0325,{"Ok"})
					   		  lRet := .F.
					   	  EndIf
			   			  
			   			  //Saldo Disponível não suficiente para NFE e Parâmetro = 1, não permite vinculo//
			   			  If nVPCCNFE=1
				   			  If (((SDP->DP_QUANT-SDP->DP_QTDENT) == 0) .Or.;
			   				     ((SDP->DP_QUANT-SDP->DP_QTDENT-nQTPrev)<Acols[nItem][nPosQuant]))
			   				      Aviso("A103ValPCC2",STR0320+CHR(13)+STR0322+Transform((SDP->DP_QUANT-SDP->DP_QTDENT-nQTPrev),PesqPict("SD1","D1_QUANT")),{"Ok"})
				   				  lRet := .F.
				   	          EndIf
				   	      EndIf        
				   	      
			   	      	  //Saldo Disponível não suficiente para NFE e Parâmetro = 2, permite vinculo 
			   			  If nVPCCNFE=2
					   		 If (SDP->DP_QUANT-SDP->DP_QTDENT-nQTPrev)<=0
					   			 lRet := .T.
					   	      EndIf
					   	  EndIf
					   Else
					      Aviso("A103ValPCC3",STR0321,{"Ok"})
				   		  lRet := .T.
			  		   EndIf	  
			  		EndIf
			  	EndIf
		   EndIf
	  	EndIf
	Else
		If nVPCCNFE<>0
			Aviso("A103ValPCC4",STR0324,{"OK"})
		    lRet := .F.
		EndIf
	EndIf
EndIf 

RestArea(aArea)
Return (lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103VldDanfe³ Autor ³ Julio C.Guerato     ³ Data ³09/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função para Validação dos Campos do Folder Danfe			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F., confirmando a Validação		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Array com os campos da Folder com campos da Danfe           ³±±
±±³          ³[01]: Cod.Transportadora      	                          ³±±
±±³          ³[02]: Peso Liquido		                                  ³±±
±±³          ³[03]: Peso Bruto                                            ³±±
±±³          ³[04]: Especie 1        		                              ³±±
±±³          ³[05]: Volume  1		                                      ³±±
±±³          ³[06]: Especie 2        		                              ³±±
±±³          ³[07]: Volume  2		                                      ³±±
±±³          ³[08]: Especie 3        		                              ³±±
±±³          ³[09]: Volume  3		                                      ³±±
±±³          ³[10]: Especie 4        		                              ³±±
±±³          ³[11]: Volume  4		                                      ³±±
±±³          ³[12]: Placa 			                                      ³±±
±±³          ³[13]: Chave NFe		                                      ³±±
±±³          ³[14]: Tipo de Frete	                                      ³±±
±±³          ³[15]: Valor Pedágio	                                      ³±±
±±³          ³[16]: Fornecedor Retirada                                   ³±±
±±³          ³[17]: Loja Retirada	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103VldDanfe(aNFEDanfe)

Local lRetDanfe := .T.

If cPaisLoc == "BRA"  .And. !l103Visual
	If ExistBlock("MT103DNF")
		lRetDanfe := Execblock("MT103DNF",.F.,.F.,{aNFEDanfe})
	Endif
Endif

Return lRetDanfe

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103VLDEXC  ³ Autor ³ Julio C.Guerato     ³ Data ³04/02/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função para Validar se existem vinculos da NFe em outras    ³±±
±±³			 ³tabelas													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. = Não existem vinculos   				                  ³±±
±±³			 ³.F. = Existe vinculos 	  				                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³[01]: Indica se está em exclusão 	                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103VldEXC(lExclui,cPrefixo)

Local lRet      := .T.
Local lContinua := .T.
Local nx        := 0        
Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"}) 
Local nItem     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"}) 
Local cDesc     := ""            
Local aAreaSD1  := SD1->(GetArea())

Default cPrefixo := ""

If lExclui
	
	If ExistBlock("A103VLEX")
		lContinua := ExecBlock("A103VLEX",.F.,.F.)
		If ValType(lContinua) != "L"
			lContinua := .T.
		EndIf
	EndIf    
	
	If lContinua

		//Verifica vinculo com Pedidos de Venda //
		For nX = 1 to len(aCols)
		     DbSelectArea("SC6") 
		     DbSetOrder(5) 
		     MsSeek(xFilial("SC6")+CA100FOR+CLOJA+aCols[nX][nPosCod]+CNFISCAL+CSERIE+aCols[nX][nItem])
		     If !EOF()
		         lRet:=.F.  
		         cDesc:= STR0331+CHR(13)+STR0332+CHR(13)+STR0333+C6_FILIAL+" "+C6_NUM+" "+C6_ITEM+" "+C6_PRODUTO
			     AVISO("A103ValExc",cDesc,{"Ok"})
		         Exit
		     EndIf   
		Next nX    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se Existe baixa no Contas a Pagar                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		If lRet .And. !A120UsaAdi(cCondicao)
			dbSelectArea("SE2")
			SE2->(dbSetOrder(6))
			SE2->(DbGotop())     
			
			MsSeek(xFilial("SE2")+cA100For+cLoja+cPrefixo+SF1->F1_DUPL) 
			
			While ( !Eof() .And.;
				xFilial("SE2")  == SE2->E2_FILIAL  .And.;
				cA100For        == SE2->E2_FORNECE .And.;
				cLoja           == SE2->E2_LOJA    .And.;
				cPrefixo	    == SE2->E2_PREFIXO .And.;
				SF1->F1_DUPL	== SE2->E2_NUM )
				If SE2->E2_TIPO == MVNOTAFIS	
					If !FaCanDelCP("SE2","MATA100")
						lRet := .F.
						Exit
					EndIf    
				EndIf 
			
				dbSelectArea("SE2")
		   		dbSkip()
			EndDo 
		EndIf		
	
		//... Inserir outros Vinculos daqui para baixo .. //

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum produto ja foi distribuido                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If lRet
		dbSelectArea('SD1')
		dbSetOrder(1)
		MsSeek(xFilial("SD1")+cNFiscal+cSerie+cA100For+cLoja) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			While(!Eof() .And.;
				xFilial("SD1") == SD1->D1_FILIAL .And.;
				cNFiscal       == SD1->D1_DOC .And.;
				cSerie         == SD1->D1_SERIE .And.;
				cA100For       == SD1->D1_FORNECE .And.;
				cLoja          == SD1->D1_LOJA)
					If Localiza(SD1->D1_COD)
						dbSelectArea('SDA')
						dbSetOrder(1)
						MsSeek(xFilial('SDA')+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
						If !(SDA->DA_QTDORI == SDA->DA_SALDO)
							Help(" ",1,"SDAJADISTR")
							lRet := .F.
							Exit
						EndIf
					EndIf
				   SD1->(dbSkip())					
			EndDo
	EndIf	
	//=================================================================
	
	EndIf
EndIf

RestArea(aAreaSD1)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103Adiant  ³ Autor ³Totvs                ³ Data ³20.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a existencia de pedidos de compra para o documento,  º±±
±±³          ³caso seja usada condicao de pagto com Adiantamento.         º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se existe Pedido de Compra associado ao Docu- ³±±
±±³          ³mento.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Condicao de Pagamento deste documento de entrada     ³±±
±±³          ³ExpC2: Codigo do fornecedor                                 ³±±
±±³          ³ExpC3: Loja do fornecedor                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103Adiant(cCondicao,cCodForn,cCodLoja)

Local aArea	   := GetArea()
Local nCnt 	   := 0
Local nCnt1    := 0
Local lRet 	   := .T.
Local aPedidos := {}
Local aPedAdt  := {}
Local nValAdt  := 0
Local aAreaSE2 := SE2->(GetArea())
Local lGeraDup := .F.
Local lIntGH   := GETMV("MV_INTGH",.F.,.F.)  //Verifica Integracao com GH

For nCnt := 1 to Len(aCols)
	If !gdDeleted(nCnt)
		If !Empty(gdFieldGet("D1_PEDIDO",nCnt)) .and. !Empty(gdFieldGet("D1_ITEMPC",nCnt))
			If AvalTes(gdFieldGet("D1_TES",nCnt),,"S")  // Soh considera este pedido se o TES usada gerar duplicata
				lGeraDup := .T.
				If aScan(aPedAdt,{|x| x == gdFieldGet("D1_PEDIDO",nCnt)}) <= 0
  		 			aAdd(aPedAdt,gdFieldGet("D1_PEDIDO",nCnt))
	  			Endif	
			EndIf	
		Else
			If AvalTes(gdFieldGet("D1_TES",nCnt),,"S")  // Soh considera este pedido se o TES usada gerar duplicata
				lGeraDup := .T.
			Endif
		Endif		
	Endif	
Next nCnt
If Len(aPedAdt) > 0
	For nCnt := 1 to Len(aPedAdt)
		// Carrega array de Adiantamentos relacionados ao pedido
		aPedidos := FPedAdtPed("P", aPedAdt, .F. )
		For nCnt1 := 1 To Len(aPedidos)
			// checa se o saldo atual do adiantamento eh igual ou maior que o valor relacionado no pedido
			SE2->(MsGoto(aPedidos[nCnt1][2]))
			If SE2->(Recno()) = aPedidos[nCnt1][2]
				If SE2->E2_SALDO >= SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,dDataBase,,SE2->E2_LOJA,,0,1)
					nValAdt += aPedidos[nCnt1][3]
				Endif
			Endif	
		Next nCnt1
		If !Empty(nValAdt)
			Exit // se houver pelo menos um adiantamento, jah eh o bastante para prosseguir a geracao do documento	
		EndIf			
	Next nCnt
	If Empty(nValAdt)
		Aviso(STR0119,STR0336 + CRLF + STR0337,{"Ok"}) // "O Documento não poderá ser incluído, pois não existe nenhum adiantamento relacionado ao(s) pedido(s) de compra e a condição de pagamento está cadastrada para uso de Adiantamento."#CRLF#"Na rotina de Pedido de Compra, relacione pelo menos um adiantamento ao(s) pedido(s) de compra."
		lRet := .F.
	Endif	
Else
	If lGeraDup
		If lIntGH
			Aviso(STR0236,STR0334 + CRLF + STR0335,{"Ok"}) // "Não há nenhum Pedido de Compra relacionado com este documento de entrada, ou o TES usado para este(s) Pedido(s) de Compra não gera(m) duplicata."#CRLF#"Para usar condição de pagamento com Adiantamento é necessário relacionar um item do documento de entrada, cujo TES gera duplicata, com um Pedido de Compra."
			lRet := .F.
		Else
			Aviso(STR0236,STR0335,{"Ok"}) // "Não há nenhum Pedido de Compra relacionado com este documento de entrada, ou o TES usado para este(s) Pedido(s) de Compra não gera(m) duplicata."#CRLF#"Para usar condição de pagamento com Adiantamento é necessário relacionar um item do documento de entrada, cujo TES gera duplicata, com um Pedido de Compra."
	   		lRet := .F.
	  	EndIf
	Endif	
EndIf 
			
RestArea(aAreaSE2)
RestArea(aArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103NCompAd ³ Autor ³Totvs                ³ Data ³25.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a compensacao do Titulo a Pagar quando trata-se da  ³±±
±±³          ³parcela a Vista e o pedido utilizou Adiantamento.           º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se realizou a Compensacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com os Pedidos de Compra                       ³±±
±±³          ³ExpA2: Array com o Recno dos titulos gerados                ³±±
±±³          ³ExpL3: Indica se eh compensacao do contas a pagar           ³±±
±±³          ³ExpC4: Numero do Documento de Entrada                       ³±±
±±³          ³ExpC5: Serie do Documento de Entrada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103NCompAd(aPedAdt,aRecGerSE2,lCmp,cDoc,cSerie)

Local aArea := GetArea()
Local aAreaSE2 := SE2->(GetArea())
Local lContabiliza := .F.
Local lDigita := .F.       
Local lAglutina := .F.  
Local aCodPedidos	:= {} 	// Recebe o codigo dos Pedidos
Local aRecRet := {}	// Retorno da funcao que carrega os titulos de Adiantamento
Local nI := 0 	// Variavel utilizado em loop
Local nAux := 0 	// Variavel utilizado em loop
Local aRecNo := {}	// Recebe o Recno do Titulo de Adiantamento
Local aRecVlr := {}	// Recebe o valor limite para compensação do Titulo de Adiantamento
Local nVlrParc1 := 0	// Valor da primeira parcela da Nota Fiscal        
Local aPedidos	:= {}	// Array para ajuste do saldo no relacionamento do Financeiro
Local lRet := .F.
Local lTemPA := .F.
Local aPA := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se há ao menos 1 parcela nesta venda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRecGerSE2) > 0 .and. Len(aPedAdt) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os titulos de Adiantamentos relacionados aos³
	//³Pedidos da Nota.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aPedAdt)
		aPedidos := {}			
		nVlrParc1 := aPedAdt[nI][2]
			
		// PA's
		aRecRet := FPedAdtPed( "P", { aPedAdt[nI][1] }, .F. )
		For nAux := 1 To Len(aRecRet)
			lTemPA := .F.
			If !Empty(aRecRet[nAux, 3])
				// checa se o saldo atual do adiantamento eh igual ou maior que o valor relacionado no pedido
				SE2->(MsGoto(aRecRet[nAux][2]))
				If SE2->(Recno()) = aRecRet[nAux][2]
					If SE2->E2_SALDO >= SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,dDataBase,,SE2->E2_LOJA,,0,1)
						If nVlrParc1 >= aRecRet[nAux, 3] 
							lTemPA := .T.
							aAdd(aRecVlr,	aRecRet[nAux, 3])
							nVlrParc1 -= aRecRet[nAux, 3]
						ElseIf nVlrParc1 > 0
							lTemPA := .T.
		           	 	aAdd(aRecVlr,	nVlrParc1)
		           		nVlrParc1 := 0
						Endif
						If lTemPA
							aAdd(aRecNo, 	aRecRet[nAux, 2])
							// Array para ajuste do saldo do relacionamento no Financeiro
							aAdd( aPedidos, {aRecRet[nAux, 1], aRecRet[nAux, 2], aRecVlr[Len(aRecVlr)]} )			

							// artificio usado para resolver o fato da rotina MaIntBxCP nao ter parametro para compensar o valor informado em um array ( compensacao parcial ),
							// como tem a rotina MaIntBxCR, desta forma, eh passado o parametro recebido como aNDFDados com os valores parciais das compensacoes e a rotina 
							// MaIntBxCP irah usar estes valores para realizar a compensacao do PA, ao inves do saldo total do PA.
							SE2->(MsGoto(aRecRet[nAux, 2]))
							If SE2->(Recno()) = aRecRet[nAux, 2]
								aAdd(aPA,{aRecRet[nAux, 2],,FaVlAtuCP("SE2")})
								aPA[Len(aPA)][3][11] := aRecVlr[Len(aRecVlr)]
								aPA[Len(aPA)][3][12] := aRecVlr[Len(aRecVlr)]
							Endif	
						Endif	
					Endif	
				Endif
			Endif
		Next nAux			
		aAdd(aCodPedidos, {aPedAdt[nI][1], aClone(aPedidos)} )
	Next nI 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o pergunte da rotina de compensação financeira³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("AFI340",.F.)

	lContabiliza 	:= MV_PAR11 == 1
	lDigita			:= MV_PAR09 == 1 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compensa os valores no Financeiro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE2->(MsGoTo(aRecGerSE2[1]))
	If SE2->(Recno()) = aRecGerSE2[1] .and. Len(aRecNo) > 0 .and. Len(aRecVlr)	> 0
		lRet := MaIntBxCP(2,{aRecGerSE2[1]},,aRecNo,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,aPA,SE2->E2_VALOR)
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o pergunte da MATA103                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MTA103",.F.)
	
	If lRet .and. Len(aCodPedidos) > 0
		SE2->(MsGoTo(aRecGerSE2[1]))
		If SE2->(Recno()) = aRecGerSE2[1]
			If SE2->E2_VALOR != SE2->E2_SALDO .and. !Empty(SE2->E2_BAIXA) // verifica se o titulo foi baixado
				For nI := 1 To Len(aCodPedidos)	
             
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ajuste do saldo do relacionamento no Financeiro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				    FPedAdtGrv( "P", 4, aCodPedidos[nI, 1], aCodPedidos[nI, 2], lCmp, cDoc, cSerie )
				Next nI      

				// grava registro do titulo principal na tabela FR3
				SE2->(MsGoTo(aRecGerSE2[1]))			
				If SE2->(Recno()) = aRecGerSE2[1]
					FaGrvFR3("P",aPedAdt[1][1],SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_VALOR,cDoc,cSerie)
				Endif	
			Else
				lRet := .F.	
			Endif	
		Endif
	Endif		
EndIf         

RestArea(aAreaSE2)
RestArea(aArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103CCompAd ³ Autor ³Totvs                ³ Data ³20.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz o cancelamento da compensacao do adiantamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a Compensacao foi excluida                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com o Recno dos titulos gerados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103CCompAd(aRecSE2)

Local aArea	:= GetArea()
Local aAreaSE2	:= SE2->(GetArea())
Local lContabiliza := .T.
Local lDigita := .T.       
Local lAglutina := .F.  
Local aRecRetPA := {}	// Retorno da funcao que carrega os titulos de Adiantamento
Local nCnt := 0 	// Variavel utilizado em loop
Local aRecNoPA := {}	// Recebe o Recno do Titulo de Adiantamento
Local cQ := ""
Local aDocCmp := {}
/* estrutura array aDocCmp
//1 - E5_PREFIXO
//2 - E5_NUMERO
//3 - E5_PARCELA
//4 - E5_TIPO
//5 - E5_CLIFOR 
//6 - E5_LOJA
//7 - E5_VALOR
//8 - F1_DOC
//9 - F1_SERIE
//10 - Logico - indica se compensacao foi realizada no momento da geracao do documento de saida
*/
Local nTamPref    := TamSX3("E2_PREFIXO")[1]
Local nTamNum     := TamSX3("E2_NUM")[1]
Local nTamParc    := TamSX3("E2_PARCELA")[1]
Local nTamTipoT   := TamSX3("E2_TIPO")[1]
Local nTamFornece := TamSX3("E2_FORNECE")[1]
Local nTamLoja    := TamSX3("E2_LOJA")[1]
Local nPos 		  := 0
Local aRecnoFR3   := {} // array para guardar o recno dos registros da tabela FR3, referente aos adiantamentos compensados com a nota fiscal, no momento da geracao da nota
Local lRet        := .T.
Local aEstorno    := {} // array para guardar o conteudo do campo E5_DOCUMEN dos registros usados na compensacao
Local aEstornoTmp := {}
Local aDocCmpTmp  := {}
Local nTamE5Doc	  := TamSX3("E5_DOCUMEN")[1]
Local cCposSelect :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se há ao menos 1 parcela nesta entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRecSE2) >= 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega array com titulos compensados nesta nota    ³
	//³fiscal                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQ	:= "SELECT E5_DOCUMEN,E5_VALOR,E5_NUMERO,E5_PREFIXO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_SEQ "
	cQ += "   FROM "+RetSqlName("SE5")+" "
	cQ += "  WHERE E5_FILIAL  = '"+xFilial("SE5")+"' "
	cQ += "    AND E5_RECPAG  = 'P' "
	cQ += "	   AND E5_SITUACA <> 'C' "
	cQ += "	   AND E5_DATA    = '"+dTos(SF1->F1_DTDIGIT)+"'"
	cQ += "	   AND E5_NUMERO  = '"+SF1->F1_DUPL+"'"
	cQ += "	   AND E5_PREFIXO = '"+SF1->F1_PREFIXO+"'"
	cQ += "	   AND E5_CLIFOR  = '"+SF1->F1_FORNECE+"'"
	cQ += "	   AND E5_LOJA    = '"+SF1->F1_LOJA+"'"
	cQ += "	   AND E5_MOTBX   = 'CMP' "
	cQ += "	   AND E5_TIPODOC = 'CP' "
	cQ += "	   AND E5_TIPO    = '"+MVNOTAFIS+"' "
	cQ += "	   AND D_E_L_E_T_ = ' ' "

	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBSE5",.T.,.T.)
	TcSetField("TRBSE5","E5_VALOR","N",TamSX3("E5_VALOR")[1],TamSX3("E5_VALOR")[2])

   While !Eof()
		If !TemBxCanc(TRBSE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.)
	   	aAdd(aDocCmpTmp,{Subs(TRBSE5->E5_DOCUMEN,1,nTamPref),Subs(TRBSE5->E5_DOCUMEN,nTamPref+1,nTamNum),Subs(TRBSE5->E5_DOCUMEN,nTamPref+nTamNum+1,nTamParc),;
   		Subs(TRBSE5->E5_DOCUMEN,nTamPref+nTamNum+nTamParc+1,nTamTipoT),Subs(TRBSE5->E5_DOCUMEN,nTamPref+nTamNum+nTamParc+nTamTipoT+1,nTamFornece),;
   		Subs(TRBSE5->E5_DOCUMEN,nTamPref+nTamNum+nTamParc+nTamTipoT+nTamFornece+1,nTamLoja),TRBSE5->E5_VALOR,SF1->F1_DOC,SF1->F1_SERIE,.F.})
   	Endif	
   	dbSkip()
   Enddo	
   
   TRBSE5->(dbCloseArea())
   SX3->(DbSetOrder(1))
   SX3->(DbSeek("FR3"))
   While !SX3->(EOF()) .and. SX3->X3_ARQUIVO="FR3"
      cCposSelect+=SX3->X3_CAMPO+","
      SX3->(DbSkip())
   Enddo   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega array com titulos compensados nesta nota    ³
	//³fiscal, da tabela de Documento X Adiantamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQ	:= "SELECT "+cCposSelect+"R_E_C_N_O_ AS FR3_RECNO "
	cQ += "   FROM "+RetSqlName("FR3")+" "
	cQ += "  WHERE FR3_FILIAL = '"+xFilial("FR3")+"' "
	cQ += "    AND FR3_CART   = 'P' "
	cQ += "    AND FR3_TIPO   IN "+FormatIn(MVPAGANT,"/")+" "
	cQ += "	   AND FR3_FORNEC = '"+SF1->F1_FORNECE+"'"
	cQ += "    AND FR3_LOJA   = '"+SF1->F1_LOJA+"'"
	cQ += "	   AND FR3_DOC    = '"+SF1->F1_DOC+"'"
	cQ += "	   AND FR3_SERIE  = '"+SF1->F1_SERIE+"'"
	cQ += "	   AND D_E_L_E_T_ = ' ' "

	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBFR3",.T.,.T.)
	TcSetField("TRBFR3","FR3_VALOR","N",TamSX3("FR3_VALOR")[1],TamSX3("FR3_VALOR")[2])
   
   While !Eof()
   	nPos := aScan(aDocCmpTmp,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+Alltrim(Str(x[7]))+x[8]+x[9] == ;
		TRBFR3->(FR3_PREFIX+FR3_NUM+FR3_PARCEL+FR3_TIPO+FR3_FORNEC+FR3_LOJA)+Alltrim(Str(TRBFR3->FR3_VALOR))+TRBFR3->(FR3_DOC+FR3_SERIE)})
   	If nPos > 0
	   	aDocCmpTmp[nPos][10] := .T.
	   Endif	
	   aAdd(aRecnoFR3,TRBFR3->FR3_RECNO)
   	dbSkip()
   Enddo	
	   
   TRBFR3->(dbCloseArea())

	//grava no array aDocCmp soh os adiantamentos que pertencem a compensacao referente a geracao da nota fiscal
	For nCnt:=1 To Len(aDocCmpTmp)
		If aDocCmpTmp[nCnt][10]
			aAdd(aDocCmp,aDocCmpTmp[nCnt])
		Endif
	Next nCnt		
 
   If Len(aDocCmp) > 0				
   	//grava array aEstorno com a mesma chave do campo E5_DOCUMEN, para uso na rotina MaIntBxPg
   	For nCnt:=1 To Len(aDocCmp)
	   	aAdd(aEstornoTmp,aDocCmp[nCnt][1]+aDocCmp[nCnt][2]+aDocCmp[nCnt][3]+aDocCmp[nCnt][4]+aDocCmp[nCnt][5]+aDocCmp[nCnt][6]+;
	   	Space(nTamE5Doc-(nTamPref+nTamNum+nTamParc+nTamTipoT+nTamFornece+nTamLoja)))
   	Next nCnt	
   	If Len(aEstornoTmp) > 0
   		aAdd(aEstorno,aEstornoTmp)
   	Endif	
   	// grava recno dos adiantamentos compensados
   	dbSelectArea("SE2")
   	dbSetOrder(6) // filial+fornece+loja+prefixo+numero+parcela+tipo
   	For nCnt:=1 To Len(aDocCmp)
	   	If MsSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+aDocCmp[nCnt][1]+aDocCmp[nCnt][2]+aDocCmp[nCnt][3]+aDocCmp[nCnt][4])
	   		aAdd(aRecnoPA,SE2->(Recno()))
	   	Endif
	   Next nCnt
	   If Len(aRecnoPA) > 0.and. Len(aEstorno) > 0
	   		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega o pergunte da rotina de compensação financeira³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Pergunte("AFI340",.F.)

			lContabiliza 	:= MV_PAR11 == 1
			lDigita			:= MV_PAR09 == 1 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Excluir Compensacao dos valores no Financeiro³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE2->(MsGoTo(aRecSE2[1]))
			If SE2->(Recno()) = aRecSE2[1]
				lRet := .F.
				lRet := MaIntBxCP(2,{aRecSE2[1]},,aRecNoPA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,aEstorno,,SE2->E2_VALOR)
			Endif	

			Pergunte("MTA103",.F.)
	         
			// busca todas as compensacoes referentes a esta nota fiscal e ajusta o valor compensado para cada pedido de compra
			If Len(aRecnoFR3) > 0 .and. lRet
				SE2->(MsGoTo(aRecSE2[1]))
				If SE2->(Recno()) = aRecSE2[1]
					If SE2->E2_VALOR = SE2->E2_SALDO .and. Empty(SE2->E2_BAIXA) // verifica se o titulo esta em aberto
						For nCnt:=1 To Len(aRecnoFR3)
							dbSelectArea("FR3")
							MsGoto(aRecnoFR3[nCnt])
							If Recno() = aRecnoFR3[nCnt]
								SE2->(dbSetOrder(6))
								If SE2->(MsSeek(xFilial("SE2")+FR3->(FR3_FORNEC+FR3_LOJA+FR3_PREFIXO+FR3_NUM+FR3_PARCELA+FR3_TIPO)))
		
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Ajuste do saldo do relacionamento no Financeiro³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
								    FPedAdtGrv("P",4,FR3->FR3_PEDIDO,{{FR3->FR3_PEDIDO,SE2->(RecNo()),(FR3->FR3_VALOR*-1)}},.T.,SF1->F1_DOC,SF1->F1_SERIE)
							   Endif 
							Endif
						Next nCnt
						
						//exclui registro do titulo principal da tabela FR3
						SE2->(MsGoTo(aRecSE2[1]))
						If SE2->(Recno()) = aRecSE2[1]
							dbSelectArea("FR3")
							dbSetOrder(3)
							If dbSeek(xFilial("FR3")+"P"+SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+SF1->F1_DOC+SF1->F1_SERIE)
								RecLock("FR3",.F.)
								dbDelete()
								MsUnlock()
							Endif	
						Endif	
					Else
						lRet := .F.	
					Endif		
				Endif
			Endif				   
		Endif	
	Endif	
EndIf         

SE2->(RestArea(aAreaSE2))
RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A103CAT83 ºAutor   ³TOTVS 			 º Data ³  08/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para Atualizar o Cod.Lanc.CAT83 através do Produto  º±±
±±º			 ³ ou da TES												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ nLinha = Nro da Linha do aCols						  	  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³          |															  ³±±
±±ºUso       ³ MATA103                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103CAT83(nLinha)
Local cRet  	 := "" 
Local cCodLan    := ""
Local aArea	  	 := GetArea()     
Local nPosCodLan := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CODLAN"})
Local nPosCodTes := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})  
Local nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})  

Default nLinha:=N

If SuperGetMv("MV_CAT8309",.F.,.F.) .And. nPosCodLan>0 .And. nPosCodTes>0 .And. nPosCod>0       
	cCodLan:= aCols[nLinha][nPosCodLan]
    dbSelectArea("SF4")                                                                   
    dbSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[nLinha][nPosCodTes])
	if !Eof() .And. SF4->(FieldPos("F4_CODLAN"))>0
		cRet:=SF4->F4_CODLAN
	EndIf
		
	If Len(Trim(cRet)) == 0  //Cod.Lancamento, nao esta preenchido na TES, verifica no Produto
	    dbSelectArea("SB1")
	    dbSetOrder(1)
		MsSeek(xFilial("SB1")+aCols[nLinha][nPosCod])
		If !Eof() .And. SB1->(FieldPos("B1_CODLAN"))>0
			cRet:=SB1->B1_CODLAN
		EndIf
    EndIf    
    
    //Nao achou o Cod.Lancamento preenchido nos cadastros, porém já foi digitado no aCols, mantém o que foi digitado
    //Caso contrário, será retornado valor obtido na base independente do valor preenchido no aCols
    If Len(Trim(cRet)) == 0 .And. Len(Trim(cCodLan))>0
    	cRet:=cCodLan
  	EndIf                                                         
EndIf

RestArea(aArea)
Return (cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaCAT83ºAutor   ³TOTVS 			 º Data ³  09/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao de Dados da CAT83								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ cOrigem, cChave, cOperacao, nIndice, cCAT83                ³±±
±±³          |															  ³±±
±±ºUso       ³ Materiais                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaCAT83(cOrigem, aChave, cOperacao, nIndice, cCAT83)

If SuperGetMV("MV_CAT8309",.F.,.F.) .And. FindFunction("FISA023") .And. Len(AllTrim(cCAT83))>0
	//FISA023(cOrigem, aChave, cOperacao, nIndice)
EndIF

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³V103CAT83 ³ Autor ³TOTVS 				    ³ Data ³16/09/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna se a CAT83 esta ativa ou nao                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function V103CAT83()   
Local lRet:=.F.

If SuperGetMv("MV_CAT8309",.F.,.F.)
	If SD1->(FieldPos("D1_CODLAN"))>0
		lRet:=.T.
	EndIf      
EndIf
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuCon³ Prog. ³ TOTVS                 ³Data  ³01/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza folder de conferencia fisica                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103ConfPr( ExpO1, ExpA1)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do list box                                 ³±±
±±³          ³ ExpA2 = Array com o contudo da list box                    ³±±
±±³          ³ ExpO3 = Objeto para flag do list box                       ³±±
±±³          ³ ExpO4 = Objeto para flag do list box                       ³±±
±±³          ³ ExpO5 = Objeto com total de conferentes na nota            ³±±
±±³          ³ ExpN6 = Variavel de quantidade de conferentes              ³±±
±±³          ³ ExpN7 = Objeto com o status da nota                        ³±±
±±³          ³ ExpN8 = Variavel com a descricao do status da nota         ³±±
±±³          ³ ExpL9 = Habilita recontagem na conferencia (limpa o que foi³±±
±±³          ³         gravado)                                           ³±±
±±³          ³ ExpO10= Objeto timer                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103AtuCon(oList,aListBox,oEnable,oDisable,oConf,nQtdConf,oStatCon,cStatCon,lReconta,oTimer)

Local aArea     := {}
Local cAliasOld := Alias()

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf
lReconta := If (lReconta == nil,.F.,lReconta)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita recontagem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReconta .And. (Aviso("AVISO","Voce realmente quer fazer a recontagem?",{"Sim","Nao"}) == 1)
	If Reclock("SF1",.F.)
		SF1->F1_STATCON := "0"
		SF1->(msUnlock())
	EndIf
	dbSelectArea("CBE")
	dbsetOrder(2)
	MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While !eof() .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
			CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA
		If reclock("CBE",.F.)
			CBE->(dbDelete())
			CBE->(msUnlock())
		EndIf
		dbSelectArea("CBE")
		dbSkip()
	EndDo
Else
	lReconta := .F.
EndIf

aListBox := {}
dbSelectArea("SD1")
aArea := GetArea()

MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE)

While !EOF() .and. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE == SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for a opcao RECONTAGEM, zera tudo o que foi conferido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReconta
		Reclock("SD1",.F.)
		SD1->D1_QTDCONF := 0
		SD1->(msUnlock())
	EndIf
	aAdd(aListBox,{SD1->D1_COD,SD1->D1_QTDCONF,SD1->D1_QUANT})
	dbSkip()
End
If ValType(oList) == "O"
	oList:SetArray(aListBox)
	oList:bLine := { || {If (aListBox[oList:nAT,2] == aListBox[oList:nAT,3],oEnable,oDisable), aListBox[oList:nAT,1], aListBox[oList:nAT,2]} }
	oList:Refresh()
EndIf
RestArea(aArea)
dbSelectArea(cAliasOld)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os Gets³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oConf) == "O"
	SF1->(dbSkip(-1))
	If !SF1->(BOF())
		SF1->(dbSkip())
	EndIf
	nQtdConf := SF1->F1_QTDCONF
	oConf:Refresh()
EndIf

If ValType(oStatCon) == "O"
	Do Case
	Case SF1->F1_STATCON == '1'
		cStatCon := "NF conferida"
	Case SF1->F1_STATCON == '0'
		cStatCon := "NF nao conferida"
	Case SF1->F1_STATCON == '2'
		cStatCon := "NF com divergencia"
	Case SF1->F1_STATCON == '3'
		cStatCon := "NF em conferencia"
	Case SF1->F1_STATCON == '4'
		cStatCon := "NF Clas. C/ Diver."
	EndCase
	nQtdConf := SF1->F1_QTDCONF
	oStatCon:Refresh()
EndIf
If ValType(oTimer) == "O"
	oTimer:Activate()
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103DetCon³ Prog. ³ TOTVS                 ³Data  ³01/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta listbox com dados da conferencia do produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103DetCon(oList,aListBox)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do list box                                 ³±±
±±³          ³ ExpA2 = Array com o contudo da list box                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103DetCon(oList,aListBox)
Local cCodPro := aListBox[oList:nAt,1]
Local aListDet := {}
Local oListDet
Local oDlgDet
Local aArea := sGetArea()
Local oTimer
Local bBlock := {|cCampo|(SX3->(MsSeek(cCampo)),X3TITULO())}
Local oIndice
Local aIndice := {}
Local cIndice
Local aIndOrd := {}
Local cKeyCBE  := "CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO"
Local aColunas := {}
Local aCpoCBE  := {}
Local nI

sGetArea(aArea,"CBE")
sGetArea(aArea,"SB1")
sGetArea(aArea,"SX3")
sGetArea(aArea,"SIX")

SIX->(DbSetOrder(1))
SIX->(MsSeek("CBE"))
While !SIX->(Eof()) .and. SIX->INDICE == "CBE"
	If SubStr(SIX->CHAVE,1,Len(cKeyCBE)) == cKeyCBE
		aadd(aIndice,SIX->(SixDescricao()))
		If IsDigit(SIX->ORDEM)     // se for numerico o conteudo do ORDEM assume ele mesmo, senao calcula o numero do indice (ex: "A" => 10, "B" => 11, "C" => 12, etc)
			aadd(aIndOrd,Val(SIX->ORDEM))
		Else
			aadd(aIndOrd,Asc(SIX->ORDEM)-55)
		EndIf
	EndIf
	SIX->(DbSkip())
EndDo

dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("CBE")
While !EOF() .And. (x3_arquivo == "CBE")
	If ( x3uso(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO) $ cKeyCBE))
		aadd(aCpoCBE,{X3_CAMPO,X3_CONTEXT})
	Endif
	dbSkip()
EndDo

SX3->(DbSetOrder(2))
SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCodPro))

cIndice := aIndice[1]

For nI := 1 to Len(aCpoCBE)
	aadd(aColunas,Eval(bBlock,aCpoCBE[nI,1]))
Next

CBE->(dbsetOrder(2))

DEFINE MSDIALOG oDlgDet TITLE OemToAnsi("Detalhes de Conferencia do Produto "+cCodPro+" "+SB1->B1_DESC) From 0, 0 To 25, 67 OF oMainWnd
oListDet := TWBrowse():New( 02, 2, (oDlgDet:nRight/2)-5, (oDlgDet:nBottom/2)-30,,aColunas,, oDlgDet,,,,,,,,,,,, .F.,, .T.,, .F.,,, )

A103AtuDet(cCodPro,oListDet,aListDet,,aCpoCBE)

@ (oDlgDet:nBottom/2)-25, 005 Say "Ordem " PIXEL OF oDlgDet
@ (oDlgDet:nBottom/2)-25, 025 MSCOMBOBOX oIndice VAR cIndice    ITEMS aIndice    SIZE 180,09 PIXEL OF oDlgDet
oIndice:bChange := {||CBE->(DbSetOrder(aIndOrd[oIndice:nAt])),A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)}
@  (oDlgDet:nBottom/2)-25, (oDlgDet:nRight/2)-50 BUTTON "&Retorna" SIZE 40,10 ACTION ( oDlgDet:End() ) Of oDlgDet PIXEL

DEFINE TIMER oTimer INTERVAL 1000 ACTION (A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)) OF oDlgDet
oTimer:Activate()

ACTIVATE MSDIALOG oDlgDet CENTERED

sRestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuDet³ Prog. ³ TOTVS                 ³Data  ³01/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza array para listbox dos detalhes de conferencia    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103AtuDet(cCodPro,oListDet,aListDet,oTimer)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPro  - Codigo do produto a procurar no CBE             ³±±
±±³          ³ oListDet - Objeto listbox a atualizar                      ³±±
±±³          ³ aListDet - Array do listbox                                ³±±
±±³          ³ oTimer   - Objeto timer a desativar para o processo        ³±±
±±³          ³ aCpoCBE  - Campos do LISTBOX                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)
Local aLine := {},nI
Local uConteudo

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf

aListDet := {}

CBE->(MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cCodPro))

While !CBE->(eof()) .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
		CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA .and. CBE->CBE_CODPRO == cCodPro

	aLine := {}
	For nI := 1 to Len(aCpoCBE)
		If Empty(aCpoCBE[nI,2])
			uConteudo := CBE->&(aCpoCBE[nI,1])
		Else
			uConteudo := CriaVar(aCpoCBE[nI,1])
		EndIf
		aadd(aLine,uConteudo)
	Next
	aadd(aListDet,aLine)

	CBE->(DbSkip())
EndDo
If Empty(aListDet)
	aLine := {}
	For nI := 1 To Len(aCpoCBE)
		aadd(aLine,CriaVar(aCpoCBE[nI,1],.f.))
	Next
	aadd(aListDet,aLine)
EndIf

oListDet:SetArray( aListDet )
oListDet:bLine := { || RetDetLine(aListDet,oListDet:nAT)  }

oListDet:Refresh()

If ValType(oTimer) == "O"
	oTimer:Activate()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RetDetLine³ Prog. ³ TOTVS                 ³Data  ³01/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para retornar campos para o bLine do listbox        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetDetLine(aListDet,nAt)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aListDet - Array com dados do listbox                      ³±±
±±³          ³ nAt      - Linha do listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103AtuDet                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetDetLine( aListDet,nAt)
Local aRet := {}
Local nX:= 0
For nX:= 1 to len(aListDet[nAt])
	aadd(aRet,aListDet[nAt,nx])
Next nX
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103CheckDanfeºAutor  ³TOTVS		     º Data ³  24/05/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria Array com Estrutura dos Campos da Danfe				   º±±  
±±º          ³Embora nem todos os campos possam existir na base, o array   º±±  
±±º          ³será criado com todos os elementos, a fim de manter a com-   º±±  
±±º          ³patibilidade com pontos de entrada e com o programa.	       º±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo  1 = Verif.se campos existem na base e emite aviso	   ³±±
±±³			 ³ 		  2 = Verif.se campos existem na base e não emite aviso³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103CheckDanfe(nTipo)          
Local aAreaDanfe:= GetArea()
Local nCposD	:= 0
Local nCposNfe  := 0
Local cAviso    := ""      

// Para Ativar a Aba: Danfe com todos os campos, execute o UPDCOM18: Ele Substitui os UPDATES: 05,07,17 
// Ao incluir novos campos na Aba, atualize também a documentação do ponto de entrada: MT103DNF 
DbSelectArea("SF1")       
aNFEDanfe   := {}         
aaDD(aNFEDanfe, iif(FieldPos("F1_TRANSP")>0,  CriaVar("F1_TRANSP")  ,""));iif(FieldPos("F1_TRANSP")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_PLIQUI")>0,  CriaVar("F1_PLIQUI")  ,""));iif(FieldPos("F1_PLIQUI")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_PBRUTO")>0,  CriaVar("F1_PBRUTO")  ,""));iif(FieldPos("F1_PBRUTO")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI1")>0, CriaVar("F1_ESPECI1") ,""));iif(FieldPos("F1_ESPECI1")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME1")>0, CriaVar("F1_VOLUME1") ,""));iif(FieldPos("F1_VOLUME1")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI2")>0, CriaVar("F1_ESPECI2") ,""));iif(FieldPos("F1_ESPECI2")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME2")>0, CriaVar("F1_VOLUME2") ,""));iif(FieldPos("F1_VOLUME2")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI3")>0, CriaVar("F1_ESPECI3") ,""));iif(FieldPos("F1_ESPECI3")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME3")>0, CriaVar("F1_VOLUME3") ,""));iif(FieldPos("F1_VOLUME3")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI4")>0, CriaVar("F1_ESPECI4") ,""));iif(FieldPos("F1_ESPECI4")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME4")>0, CriaVar("F1_VOLUME4") ,""));iif(FieldPos("F1_VOLUME4")==0,nCposD++,nil)   
aaDD(aNFEDanfe, iif(FieldPos("F1_PLACA")>0,   CriaVar("F1_PLACA")   ,""));iif(FieldPos("F1_PLACA")==0,nCposD++,nil)   
aaDD(aNFEDanfe, iif(FieldPos("F1_CHVNFE")>0,  CriaVar("F1_CHVNFE")  ,""));iif(FieldPos("F1_CHVNFE")==0,nCposNfe++,nil)      
aaDD(aNFEDanfe, iif(FieldPos("F1_TPFRETE")>0, CriaVar("F1_TPFRETE") ,""));iif(FieldPos("F1_TPFRETE")==0,nCposD++,nil)   
aaDD(aNFEDanfe, iif(FieldPos("F1_VALPEDG")>0, CriaVar("F1_VALPEDG") ,""));iif(FieldPos("F1_VALPEDG")==0,nCposD++,nil)      
aaDD(aNFEDanfe, iif(FieldPos("F1_FORRET")>0,  CriaVar("F1_FORRET")  ,""));iif(FieldPos("F1_FORRET")==0,nCposD++,nil)      
aaDD(aNFEDanfe, iif(FieldPos("F1_LOJARET")>0, CriaVar("F1_LOJARET") ,""));iif(FieldPos("F1_LOJARET")==0,nCposD++,nil)      
aaDD(aNFEDanfe, iif(FieldPos("F1_TPCTE")>0,   CriaVar("F1_TPCTE")   ,""));iif(FieldPos("F1_TPCTE")==0,,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_FORENT")>0,  CriaVar("F1_FORENT")  ,""));iif(FieldPos("F1_FORENT")==0,nCposD++,nil)      
aaDD(aNFEDanfe, iif(FieldPos("F1_LOJAENT")>0, CriaVar("F1_LOJAENT") ,""));iif(FieldPos("F1_LOJAENT")==0,nCposD++,nil)
aaDD(aNFEDanfe, iif(FieldPos("F1_NUMAIDF")>0, CriaVar("F1_NUMAIDF") ,""))      
aaDD(aNFEDanfe, iif(FieldPos("F1_ANOAIDF")>0, CriaVar("F1_ANOAIDF") ,""))      
aaDD(aNFEDanfe, iif(FieldPos("F1_MODAL")>0, CriaVar("F1_MODAL") ,""))      
//Emite aviso para aplicar Update, somente se não for execauto //
If nTipo == 1
	If (nCposD>0 .Or. nCposNfe>0) .And. !l103Auto
	    cAviso:=STR0178+CHR(13)+STR0369+CHR(13)+STR0370+STR0371
	    cAviso+=iif(nCposD>0,STR0372,"")+iif(nCposNfe>0,iif(nCposD>0," / ","")+STR0373,"")
		Aviso("A103CheckDanfe",cAviso,{STR0238})
	EndIf
EndIf

RestArea(aAreaDanfe)         
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103CargaDanfeºAutor  ³TOTVS		     º Data ³  24/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega Array com os Campos da Danfe				  		  º±±  
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103CargaDanfe()  
Local aAreaCargaDanfe:= GetArea()

DbSelectArea("SF1")
aNFEDanfe   := {}
aaDD(aNFEDanfe, iif(FieldPos("F1_TRANSP")>0,  SF1->F1_TRANSP  ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_PLIQUI")>0,  SF1->F1_PLIQUI  ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_PBRUTO")>0,  SF1->F1_PBRUTO  ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI1")>0, SF1->F1_ESPECI1 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME1")>0, SF1->F1_VOLUME1 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI2")>0, SF1->F1_ESPECI2 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME2")>0, SF1->F1_VOLUME2 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI3")>0, SF1->F1_ESPECI3 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME3")>0, SF1->F1_VOLUME3 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_ESPECI4")>0, SF1->F1_ESPECI4 ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_VOLUME4")>0, SF1->F1_VOLUME4 ,""))   
aaDD(aNFEDanfe, iif(FieldPos("F1_PLACA")>0,   SF1->F1_PLACA   ,""))   
aaDD(aNFEDanfe, iif(FieldPos("F1_CHVNFE")>0,  SF1->F1_CHVNFE  ,""))   
aaDD(aNFEDanfe, iif(FieldPos("F1_TPFRETE")>0, RetTipoFrete(SF1->F1_TPFRETE),""))   
aaDD(aNFEDanfe, iif(FieldPos("F1_VALPEDG")>0, SF1->F1_VALPEDG ,""))   
aaDD(aNFEDanfe, iif(FieldPos("F1_FORRET")>0,  SF1->F1_FORRET  ,""))   
aaDD(aNFEDanfe, iif(FieldPos("F1_LOJARET")>0, SF1->F1_LOJARET ,"")) 
aaDD(aNFEDanfe, iif(FieldPos("F1_TPCTE")>0  ,  RetTipoCte(SF1->F1_TPCTE),""))
aaDD(aNFEDanfe, iif(FieldPos("F1_FORENT")	>0,SF1->F1_FORENT  ,"")) 
aaDD(aNFEDanfe, iif(FieldPos("F1_LOJAENT")	>0,SF1->F1_LOJAENT ,""))
aaDD(aNFEDanfe, iif(FieldPos("F1_NUMAIDF")	>0,SF1->F1_NUMAIDF ,"")) 
aaDD(aNFEDanfe, iif(FieldPos("F1_ANOAIDF")	>0,SF1->F1_ANOAIDF ,"")) 
aaDD(aNFEDanfe, iif(FieldPos("F1_MODAL")	>0,RetModCte(SF1->F1_MODAL) ,"")) 

RestArea(aAreaCargaDanfe)   
Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A103Contr  ³ Autor ³ TOTVS       		  ³ Data ³ 12/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para rastreio de contratos a partir da Nota Fiscal    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A103Contr(ExpC1,ExpN1,ExpN2)							        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACOM													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103Contr(cAlias,nReg,nOpc)
LOCAL aAreaCN9   := CN9->(GetArea())
LOCAL aAreaSC7   := SC7->(GetArea())
LOCAL aAreaSD1   := SD1->(GetArea())
LOCAL cAliasSD1  := "SD1"
LOCAL aPedidos   := {}
LOCAL aContratos := {}
LOCAL aRastrContr:= {}
LOCAL oDlgCtr
LOCAL oPanelCtr
LOCAL oLbxCtr
LOCAL aTitCampos := {" ",OemToAnsi("Contrato"),OemToAnsi("Rev.Contrato"),OemToAnsi("Inicio Contrato"),OemToAnsi("Final Contrato")}
LOCAL oOk        := LoadBitMap(GetResources(), "LBOK")
LOCAL oNo        := LoadBitMap(GetResources(), "LBNO")
LOCAL nOpcCtr    := 0
LOCAL nPos
LOCAL nX
LOCAL cQuery
LOCAL nTamCn9Tpd := TamSX3("CN9_TPCTO")[01]
LOCAL nTamCn9Sit := TamSX3("CN9_SITUAC")[01]
LOCAL nTamB1Cod	 := TamSX3("B1_COD")[01]

//Busca Pedidos de Compras relacionados com a Nota de Entrada posicionada:
#IFDEF TOP
	cAliasSD1 := "SD1TMP"          
	cQuery	  := "  SELECT * FROM " + RetSqlName('SD1')
	cQuery	  += "  WHERE D1_FILIAL   = '" + xFilial('SD1') + "'"
	cQuery	  += "    AND D1_DOC      = '" + SF1->F1_DOC + "'"
	cQuery	  += "    AND D1_SERIE    = '" + SF1->F1_SERIE + "'"
	cQuery	  += "    AND D1_FORNECE  = '" + SF1->F1_FORNECE + "'"
	cQuery	  += "    AND D1_LOJA     = '" + SF1->F1_LOJA + "'"
	cQuery	  += "    AND D1_PEDIDO  <> ' '" 
	cQuery	  += "    AND D_E_L_E_T_  = ' '"
	cQuery    := ChangeQuery(cQuery)
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSD1, .F., .T.)
#ELSE 
	SD1->(DbSetOrder(1))
	SD1->(MsSeek(xFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
#ENDIF

While (cAliasSD1)->(!Eof() .AND. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	If !Empty((cAliasSD1)->D1_PEDIDO)
		nPos := Ascan(aPedidos,{|x| x[01]+x[02] == (cAliasSD1)->(D1_PEDIDO+D1_ITEMPC)})
		If nPos == 0
			aadd(aPedidos,{(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC})
		Endif
	Endif
	(cAliasSD1)->(DbSkip())
EndDo

#IFDEF TOP
	(cAliasSD1)->(dbCloseArea())
#ENDIF

If Empty(aPedidos)
	MsgAlert("A Nota Fiscal não foi gerada a partir de um Contrato de fornecedor!","Atenção!")
	RestArea(aAreaSD1)
	RestArea(aAreaSC7)
	RestArea(aAreaCN9)
	Return
Endif

//Busca os contratos relacionados ao Pedido de Compras:
CN9->(DbSetOrder(1))
SC7->(DbSetOrder(1))
For nX:=1 to Len(aPedidos)
	If SC7->(DbSeek(xFilial("SC7")+aPedidos[nX,01]+aPedidos[nX,02])) .AND. !Empty(SC7->C7_CONTRA)
		nPos := Ascan(aContratos,{|x| x[02]+x[03] == SC7->(C7_CONTRA+C7_CONTREV)})
		If nPos == 0
			If FindFunction('CNTBuscFil')
				cFilCTR:= CNTBuscFil(xFilial('CND'),SC7->C7_MEDICAO)
			EndIf
			If CN9->(DbSeek(xFilial("CN9",cFilCTR)+SC7->(C7_CONTRA+C7_CONTREV)))
				aadd(aContratos,{oNo,SC7->C7_CONTRA,SC7->C7_CONTREV,CN9->CN9_DTINIC,CN9->CN9_DTFIM,cFilCTR})
			Endif
		Endif
	Endif
Next

If Empty(aContratos)
	MsgAlert("A Nota Fiscal não foi gerada a partir de um Contrato de fornecedor!","Atenção!")
	RestArea(aAreaSD1)
	RestArea(aAreaSC7)
	RestArea(aAreaCN9)
	Return
Endif

If Len(aContratos) > 1
	DEFINE MSDIALOG oDlgCtr FROM 50,40 TO 285,541 TITLE OemToAnsi("Selecione contrato para consulta:") Of oMainWnd PIXEL

		oLbxCtr := TWBrowse():New( 27,4,243,86,,aTitCampos,,oDlgCtr,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLbxCtr:SetArray(aContratos)
		oLbxCtr:bLDblClick := { || aContratos[oLbxCtr:nAt,1] := If(aContratos[oLbxCtr:nAt,1]:cName=="LBNO", oOk,oNo) }
		oLbxCtr:bLine := { || {aContratos[oLbxCtr:nAT][1],aContratos[oLbxCtr:nAT][2],aContratos[oLbxCtr:nAT][3],aContratos[oLbxCtr:nAT][4],aContratos[oLbxCtr:nAT][5]}}
		oLbxCtr:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlgCtr CENTERED ON INIT EnchoiceBar(oDlgCtr,{||If(VldSelCtr(oLbxCtr:aArray,aContratos),(nOpcCtr := 1,oDlgCtr:End()),oDlgCtr:End())},{||(nOpcCtr := 0,oDlgCtr:End())})
Endif

	If nOpcCtr == 1
	CNTC010( aContratos )
Endif

RestArea(aAreaSD1)
RestArea(aAreaSC7)
RestArea(aAreaCN9)
Return


Static Function VldSelCtr(aLbxCtr,aContratos)
LOCAL nSelOK := 0

aEval(aLbxCtr,{|x| If(x[1]:cName == "LBOK",++nSelOK,0)})

If nSelOK == 0
	MsgAlert("Nenhum contrato foi selecionado!","Atenção!")
	Return .f.
ElseIf nSelOK > 1
	MsgAlert("Foram selecionados mais de um contrato!","Atenção!")
	Return .f.
Endif
aContratos := aClone(aLbxCtr)

Return .t.
//-------------------------------------
/*	Modelo de Dados
@author  	Jefferson Tomaz
@version 	P10 R1.4
@build		7.00.101202A
@since 		06/04/2011
@return 		oModel Objeto do Modelo*/
//-------------------------------------

Static Function ModelDef()
Local oModel
Local oStruSF1  := FWFormStruct(1,"SF1")
Local oStruSD1  := FWFormStruct(1,"SD1")
Local oStruRSA2 := NIL
Local oStruCSA1 := NIL
Local aSM0		 := FWArrFilAtu()
Local lIntGFE   := SuperGetMv('MV_INTGFE',,.F.)
Local aAux      := {}
Local lEAI      := FWIsInCallStack( "FWFORMEAI" ) .Or. AllTrim(FunName()) == "RETURNMESSAGE"

Local aParRot   := {'aRotAuto1','aRotAuto2','nOpcx'}
Local aIDStruct := {}
Local bPost		 := Nil
Local aNewField := {}
Local aMsgRet   := {}

Private aPK_SF1   := {"F1_FILIAL", "F1_DOC", "F1_SERIE", "F1_FORNECE", "F1_LOJA" }
Private aSF1xSD1  := {{"D1_FILIAL",'xFilial("SF1")'},{"D1_DOC","F1_DOC"},{"D1_SERIE","F1_SERIE"},{"D1_FORNECE","F1_FORNECE"},{"D1_LOJA","F1_LOJA"}}
Private cIdxSD1   := "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA"

SM0->(MsGoto(aSM0[SM0_RECNO]))

If lIntGFE
	oStruSD1:aTriggers := {}

	oStruRSA2 := FWFormStruct(1,"SA2",{|cCampo| AllTrim(cCampo)+"|" $ "A2_COD|A2_LOJA|A2_NREDUZ|A2_CGC|A2_END|A2_BAIRRO|A2_MUN|A2_EST|A2_COD_MUN|A2_CEP|"})
	oStruDSA1 := FWFormStruct(1,"SA1",{|cCampo| AllTrim(cCampo)+"|" $ "A1_COD|A1_LOJA|A1_NREDUZ|A1_CGC|A1_END|A1_BAIRRO|A1_MUN|A1_EST|A1_COD_MUN|A1_CEP|A1_ENDENT|A1_BAIRROE|A1_CEPE|A1_MUNE|A1_ESTE|A1_CODMUNE"})
	
	oStruRSA1 := FWFormStruct(1,"SA1",{|cCampo| AllTrim(cCampo)+"|" $ "A1_COD|A1_LOJA|A1_NREDUZ|A1_CGC|A1_END|A1_BAIRRO|A1_MUN|A1_EST|A1_COD_MUN|A1_CEP|"})
	oStruCSA1 := FWFormStruct(1,"SA1",{|cCampo| AllTrim(cCampo)+"|" $ "A1_COD|A1_LOJA|A1_NREDUZ|A1_CGC|A1_END|A1_BAIRRO|A1_MUN|A1_EST|A1_COD_MUN|A1_CEP|A1_ENDENT|A1_BAIRROE|A1_CEPE|A1_MUNE|A1_ESTE|A1_CODMUNE"})

	If !lEAI
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"F1_CDTPDC"                      , ;      // [01]  C   Titulo do campo
		"Cod.Tp.Doc"                     , ;      // [02]  C   ToolTip do campo
		"F1_CDTPDC"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		5                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,"AllTrim(Tabela('MQ',AllTrim(SF1->F1_TIPO)+'E',.F.))" ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"F1_CDCLF"                       , ;      // [01]  C   Titulo do campo
		"Class.frete"                    , ;      // [02]  C   ToolTip do campo
		"F1_CDCLFR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		5                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		NIL                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"CGC Transp"                     , ;      // [01]  C   Titulo do campo
		"CGC Transp"                     , ;      // [02]  C   ToolTip do campo
		"F1_CGCTRP"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA4",1,xFilial("SA4")+SF1->F1_TRANSP,"A4_CGC")' ), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"F1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")' ), ; // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"D1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_CGC")' ), ; // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"Desc.Prod."                     , ;      // [01]  C   Titulo do campo
		"Desc.Prod."                     , ;      // [02]  C   ToolTip do campo
		"D1_DESCRI"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		TamSx3("B1_DESC")[1]             , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'SubStr(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"),1,50)' ), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		aAux := FwStruTrigger(;
		"D1_COD", ;                                                      // [01] Id do campo de origem
		"D1_DESCRI" , ;                                                   // [02] Id do campo de destino
		'SubStr(Posicione("SB1",1,xFilial("SB1")+FwFldGet("D1_COD"),"B1_DESC"),1,50)' )
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"Peso Bruto"                     , ;      // [01]  C   Titulo do campo
		"Peso Bruto"                     , ;      // [02]  C   ToolTip do campo
		"D1_PBRUTO"                      , ;      // [03]  C   Id do Field
		'N'                              , ;      // [04]  C   Tipo do campo
		11                               , ;      // [05]  N   Tamanho do campo
		4                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, 'If(FindFunction("OmRtPesoIt"),OmRtPesoIt(SD1->D1_COD,SD1->D1_QUANT, "E"),(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PESBRU")) * SD1->D1_QUANT )') ,;
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"D1_QUANT", ;                                                      // [01] Id do campo de origem
		"D1_PBRUTO" , ;                                                   // [02] Id do campo de destino
		'If(FindFunction("OmRtPesoIt"),OmRtPesoIt(FwFldGet("D1_COD"), SD1->D1_QUANT, "E"),Posicione("SB1",1,xFilial("SB1")+FwFldGet("D1_COD"),"B1_PESBRU") * M->D1_QUANT)')
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"M3"                             , ;      // [01]  C   Titulo do campo
		"M3"                             , ;      // [02]  C   ToolTip do campo
		"D1_METRO3"                      , ;      // [03]  C   Id do Field
		'N'                              , ;      // [04]  C   Tipo do campo
		11                               , ;      // [05]  N   Tamanho do campo
		4                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"D1_QUANT"  , ;                                                   // [01] Id do campo de origem
		"D1_METRO3" , ;                                                   // [02] Id do campo de destino
		"(SB5->(B5_ALTURA * B5_LARG * B5_COMPR)) * M->D1_QUANT",;
		.T.,;
		"SB5",;
		1,;
		"xFilial('SB5')+FwFldGet('D1_COD')",;
		"SB5->(FOUND())" )
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4])                                                        // [04] Bloco de codigo de execução do gatilho
		
		oStruRSA2:AddField( ;                    // Ord. Tipo Desc.
		"IBGE Compl"                     , ;      // [01]  C   Titulo do campo
		"Cod.IBGE Compl "                , ;      // [02]  C   ToolTip do campo
		"A2_CDIBGE"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		7                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'TMS120CdUf(SA2->A2_EST, "1") + SA2->A2_COD_MUN' ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		aAux := FwStruTrigger(;
		"A2_COD_MUN", ;                                                      // [01] Id do campo de origem
		"A2_CDIBGE" , ;                                                      // [02] Id do campo de destino
		'TMS120CdUf(M->A2_EST, "1") + M->A2_COD_MUN' )
		
		oStruRSA2:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		            
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"Atual.Ativo"                    , ;      // [01]  C   Titulo do campo
		"Atual.Ativo"                    , ;      // [02]  C   ToolTip do campo
		"D1_ATUATF"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		TamSx3("F4_ATUATF")[1]           , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_ATUATF")' ), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"D1_TES", ;                                                      // [01] Id do campo de origem
		"D1_ATUATF" , ;                                                   // [02] Id do campo de destino
		'Posicione("SF4",1,xFilial("SF4")+FwFldGet("D1_TES"),"F4_ATUATF")' )
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
		oStruDSA1:AddField( ;                    // Ord. Tipo Desc.
		"IBGE Compl"                     , ;      // [01]  C   Titulo do Gcampo
		"Cod.IBGE Compl "                , ;      // [02]  C   ToolTip do campo
		"A1_CDIBGE"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		7                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'TMS120CdUf(SA1->A1_EST, "1") + SA1->A1_COD_MUN' ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"A1_COD_MUN", ;                                                      // [01] Id do campo de origem
	"A1_CDIBGE" , ;                                                      // [02] Id do campo de destino
		'TMS120CdUf(M->A1_EST, "1") + M->A1_COD_MUN' )
		
		oStruDSA1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
	Else
   	 
		oStruSF1  := FWFormStruct(1,"SF1", {|cCampo| AllTrim(cCampo) $ "F1_DOC|F1_SERIE|F1_TIPO|F1_EMISSAO|F1_FORMUL|F1_ESPECIE|F1_COND|F1_FORNECE|F1_LOJA|F1_EST|F1_RECBMTO|F1_CHVNFE" } )
		oStruSD1  := FWFormStruct(1,"SD1", {|cCampo| AllTrim(cCampo) $ "D1_ITEM|D1_COD|D1_UM|D1_QUANT|D1_VUNIT|D1_TOTAL|D1_OPER|D1_EMISSAO|D1_DOC|D1_SERIE|D1_BASEICM|D1_PICM|D1_VALICM|D1_ICMSRET|D1_BASEISS|D1_ALIQISS|D1_VALISS|D1_BASECOF|D1_ALQCOF|D1_VALCOF|D1_BASEPIS|D1_ALQPIS|D1_VALPIS|D1_FORNECE|D1_LOJA|D1_NUMSEQ"})
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"F1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")' ), ; // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"Msg Retorno"                    , ;      // [01]  C   Titulo do campo
		"Msg Retorno"                    , ;      // [02]  C   ToolTip do campo
		"F1_MSGRET"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		250                              , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		{||'Processado'}                 , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual

		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"D1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAdd(aIDStruct, "MATA103_SF1")
		aAdd(aIDStruct, "MATA103_SD1")
		
	//	aAdd(aNewField, {"F1_CGCFOR","SA2",3,{{"F1_FORNECE","A2_COD"},{"F1_LOJA","A2_LOJA"},{"F1_EST","A2_EST"}}})
		aAdd(aNewField, {"F1_CGCFOR","SA2",3,{{"F1_EST","A2_EST"}}})
		aAdd(aNewField, {"F1_COND"  ,,,{{"F1_COND",{||SuperGetMv("MV_CPDGFE",,"")}}}})
		aAdd(aNewField, {"D1_CGCFOR","SA2",3,{{"D1_FORNECE","A2_COD"},{"D1_LOJA","A2_LOJA"}}})
		
		aAdd(aMsgRet, {"MATA103_SF1","F1_MSGRET","F1_SITFIS"})
		
		bPost   := {|oModel,b,c,d,e,f| MaRecEAI(oModel,"MATA103",aIDStruct,aParRot,aNewField,aMsgRet) }

	EndIf

	oStruSF1:SetProperty( '*' , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )   
	oStruSF1:SetProperty( '*' , MODEL_FIELD_WHEN,  NIL ) 
	oStruSF1:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)
		
	oStruSD1:SetProperty( '*' , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )   
	oStruSD1:SetProperty( '*' , MODEL_FIELD_WHEN,  NIL ) 
	oStruSD1:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)

	oStruRSA2:SetProperty( '*', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )
	oStruRSA2:SetProperty( '*', MODEL_FIELD_WHEN,  NIL )
	
	oStruDSA1:SetProperty( '*', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )
	oStruDSA1:SetProperty( '*', MODEL_FIELD_WHEN,  NIL )
	
	
Else
	oStruSD1:aTriggers := {}

	oStruRSA2 := FWFormStruct(1,"SA2",{|cCampo| AllTrim(cCampo)+"|" $ "A2_COD|A2_LOJA|A2_NREDUZ|A2_CGC|A2_END|A2_BAIRRO|A2_MUN|A2_EST|A2_COD_MUN|A2_CEP|"})
	oStruDSA1 := FWFormStruct(1,"SA1",{|cCampo| AllTrim(cCampo)+"|" $ "A1_COD|A1_LOJA|A1_NREDUZ|A1_CGC|A1_END|A1_BAIRRO|A1_MUN|A1_EST|A1_COD_MUN|A1_CEP|A1_ENDENT|A1_BAIRROE|A1_CEPE|A1_MUNE|A1_ESTE|A1_CODMUNE"})
	
	oStruRSA1 := FWFormStruct(1,"SA1",{|cCampo| AllTrim(cCampo)+"|" $ "A1_COD|A1_LOJA|A1_NREDUZ|A1_CGC|A1_END|A1_BAIRRO|A1_MUN|A1_EST|A1_COD_MUN|A1_CEP|"})
	oStruCSA1 := FWFormStruct(1,"SA1",{|cCampo| AllTrim(cCampo)+"|" $ "A1_COD|A1_LOJA|A1_NREDUZ|A1_CGC|A1_END|A1_BAIRRO|A1_MUN|A1_EST|A1_COD_MUN|A1_CEP|A1_ENDENT|A1_BAIRROE|A1_CEPE|A1_MUNE|A1_ESTE|A1_CODMUNE"})

	If !lEAI
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"F1_CDTPDC"                      , ;      // [01]  C   Titulo do campo
		"Cod.Tp.Doc"                     , ;      // [02]  C   ToolTip do campo
		"F1_CDTPDC"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		5                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,"AllTrim(Tabela('MQ',AllTrim(SF1->F1_TIPO)+'E',.F.))" ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"F1_CDCLF"                       , ;      // [01]  C   Titulo do campo
		"Class.frete"                    , ;      // [02]  C   ToolTip do campo
		"F1_CDCLFR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		5                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		NIL                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"CGC Transp"                     , ;      // [01]  C   Titulo do campo
		"CGC Transp"                     , ;      // [02]  C   ToolTip do campo
		"F1_CGCTRP"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA4",1,xFilial("SA4")+SF1->F1_TRANSP,"A4_CGC")' ), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"F1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")' ), ; // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"D1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_CGC")' ), ; // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"Desc.Prod."                     , ;      // [01]  C   Titulo do campo
		"Desc.Prod."                     , ;      // [02]  C   ToolTip do campo
		"D1_DESCRI"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		TamSx3("B1_DESC")[1]             , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'SubStr(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"),1,50)' ), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		aAux := FwStruTrigger(;
		"D1_COD", ;                                                      // [01] Id do campo de origem
		"D1_DESCRI" , ;                                                   // [02] Id do campo de destino
		'SubStr(Posicione("SB1",1,xFilial("SB1")+FwFldGet("D1_COD"),"B1_DESC"),1,50)' )
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"Peso Bruto"                     , ;      // [01]  C   Titulo do campo
		"Peso Bruto"                     , ;      // [02]  C   ToolTip do campo
		"D1_PBRUTO"                      , ;      // [03]  C   Id do Field
		'N'                              , ;      // [04]  C   Tipo do campo
		11                               , ;      // [05]  N   Tamanho do campo
		4                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, 'If(FindFunction("OmRtPesoIt"),OmRtPesoIt(SD1->D1_COD,SD1->D1_QUANT, "E"),(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PESBRU")) * SD1->D1_QUANT )') ,;
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"D1_QUANT", ;                                                      // [01] Id do campo de origem
		"D1_PBRUTO" , ;                                                   // [02] Id do campo de destino
		'If(FindFunction("OmRtPesoIt"),OmRtPesoIt(FwFldGet("D1_COD"), SD1->D1_QUANT, "E"),Posicione("SB1",1,xFilial("SB1")+FwFldGet("D1_COD"),"B1_PESBRU") * M->D1_QUANT)')
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"M3"                             , ;      // [01]  C   Titulo do campo
		"M3"                             , ;      // [02]  C   ToolTip do campo
		"D1_METRO3"                      , ;      // [03]  C   Id do Field
		'N'                              , ;      // [04]  C   Tipo do campo
		11                               , ;      // [05]  N   Tamanho do campo
		4                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"D1_QUANT"  , ;                                                   // [01] Id do campo de origem
		"D1_METRO3" , ;                                                   // [02] Id do campo de destino
		"(SB5->(B5_ALTURA * B5_LARG * B5_COMPR)) * M->D1_QUANT",;
		.T.,;
		"SB5",;
		1,;
		"xFilial('SB5')+FwFldGet('D1_COD')",;
		"SB5->(FOUND())" )
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4])                                                        // [04] Bloco de codigo de execução do gatilho
		
		oStruRSA2:AddField( ;                    // Ord. Tipo Desc.
		"IBGE Compl"                     , ;      // [01]  C   Titulo do campo
		"Cod.IBGE Compl "                , ;      // [02]  C   ToolTip do campo
		"A2_CDIBGE"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		7                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'TMS120CdUf(SA2->A2_EST, "1") + SA2->A2_COD_MUN' ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		
		aAux := FwStruTrigger(;
		"A2_COD_MUN", ;                                                      // [01] Id do campo de origem
		"A2_CDIBGE" , ;                                                      // [02] Id do campo de destino
		'TMS120CdUf(M->A2_EST, "1") + M->A2_COD_MUN' )
		
		oStruRSA2:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		            
		
		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"Atual.Ativo"                    , ;      // [01]  C   Titulo do campo
		"Atual.Ativo"                    , ;      // [02]  C   ToolTip do campo
		"D1_ATUATF"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		TamSx3("F4_ATUATF")[1]           , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_ATUATF")' ), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"D1_TES", ;                                                      // [01] Id do campo de origem
		"D1_ATUATF" , ;                                                   // [02] Id do campo de destino
		'Posicione("SF4",1,xFilial("SF4")+FwFldGet("D1_TES"),"F4_ATUATF")' )
		
		oStruSD1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
		oStruDSA1:AddField( ;                    // Ord. Tipo Desc.
		"IBGE Compl"                     , ;      // [01]  C   Titulo do Gcampo
		"Cod.IBGE Compl "                , ;      // [02]  C   ToolTip do campo
		"A1_CDIBGE"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		7                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'TMS120CdUf(SA1->A1_EST, "1") + SA1->A1_COD_MUN' ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAux := FwStruTrigger(;
		"A1_COD_MUN", ;                                                      // [01] Id do campo de origem
	"A1_CDIBGE" , ;                                                      // [02] Id do campo de destino
		'TMS120CdUf(M->A1_EST, "1") + M->A1_COD_MUN' )
		
		oStruDSA1:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
		
	Else
   	 
		oStruSF1  := FWFormStruct(1,"SF1", {|cCampo| AllTrim(cCampo) $ "F1_DOC|F1_SERIE|F1_TIPO|F1_EMISSAO|F1_FORMUL|F1_ESPECIE|F1_COND|F1_FORNECE|F1_LOJA|F1_EST|F1_RECBMTO|F1_CHVNFE" } )
		oStruSD1  := FWFormStruct(1,"SD1", {|cCampo| AllTrim(cCampo) $ "D1_ITEM|D1_COD|D1_UM|D1_QUANT|D1_VUNIT|D1_TOTAL|D1_OPER|D1_EMISSAO|D1_DOC|D1_SERIE|D1_BASEICM|D1_PICM|D1_VALICM|D1_ICMSRET|D1_BASEISS|D1_ALIQISS|D1_VALISS|D1_BASECOF|D1_ALQCOF|D1_VALCOF|D1_BASEPIS|D1_ALQPIS|D1_VALPIS|D1_FORNECE|D1_LOJA|D1_NUMSEQ"})
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"F1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")' ), ; // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		oStruSF1:AddField( ;                      // Ord. Tipo Desc.
		"Msg Retorno"                    , ;      // [01]  C   Titulo do campo
		"Msg Retorno"                    , ;      // [02]  C   ToolTip do campo
		"F1_MSGRET"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		250                              , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		{||'Processado'}                 , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual

		oStruSD1:AddField( ;                      // Ord. Tipo Desc.
		"CNPJ"                           , ;      // [01]  C   Titulo do campo
		"CNPJ "                          , ;      // [02]  C   ToolTip do campo
		"D1_CGCFOR"                      , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual
		
		aAdd(aIDStruct, "MATA103_SF1")
		aAdd(aIDStruct, "MATA103_SD1")
		
	//	aAdd(aNewField, {"F1_CGCFOR","SA2",3,{{"F1_FORNECE","A2_COD"},{"F1_LOJA","A2_LOJA"},{"F1_EST","A2_EST"}}})
		aAdd(aNewField, {"F1_CGCFOR","SA2",3,{{"F1_EST","A2_EST"}}})
		aAdd(aNewField, {"F1_COND"  ,,,{{"F1_COND",{||SuperGetMv("MV_CPDGFE",,"")}}}})
		aAdd(aNewField, {"D1_CGCFOR","SA2",3,{{"D1_FORNECE","A2_COD"},{"D1_LOJA","A2_LOJA"}}})
		
		aAdd(aMsgRet, {"MATA103_SF1","F1_MSGRET","F1_SITFIS"})
		
		bPost   := {|oModel,b,c,d,e,f| MaRecEAI(oModel,"MATA103",aIDStruct,aParRot,aNewField,aMsgRet) }

	EndIf

	oStruSF1:SetProperty( '*' , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )   
	oStruSF1:SetProperty( '*' , MODEL_FIELD_WHEN,  NIL ) 
	oStruSF1:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)
		
	oStruSD1:SetProperty( '*' , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )   
	oStruSD1:SetProperty( '*' , MODEL_FIELD_WHEN,  NIL ) 
	oStruSD1:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F.)

	oStruRSA2:SetProperty( '*', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )
	oStruRSA2:SetProperty( '*', MODEL_FIELD_WHEN,  NIL )
	
	oStruDSA1:SetProperty( '*', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )
	oStruDSA1:SetProperty( '*', MODEL_FIELD_WHEN,  NIL )
EndIf

oModel:= MPFormModel():New("MATA103",  /*bPre*/, bPost /*bPost*/, {|| Nil } /*bCommit*/, /*bCancel*/)
oModel:bPost := bPost
oModel:AddFields("MATA103_SF1", ,oStruSF1,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey(aPK_SF1)

oModel:AddGrid("MATA103_SD1","MATA103_SF1",oStruSD1,/*bLinePre*/, ,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MATA103_SD1",aSF1xSD1,cIdxSD1)

oModel:GetModel("MATA103_SD1"):SetDelAllLine(.T.)

If lIntGFE .And. !lEAI
	
	oModel:AddFields("REMETENTE_SA2","MATA103_SF1",oStruRSA2,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("REMETENTE_SA2",{{"A2_FILIAL",'xFilial("SA2")'},{"A2_COD","F1_FORNECE"},{"A2_LOJA","F1_LOJA"}},"A2_FILIAL+A2_COD+A2_LOJA")
	
	oModel:AddFields("REMETENTE_SA1","MATA103_SF1",oStruRSA1,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("REMETENTE_SA1",{{"A1_FILIAL",'xFilial("SA1")'},{"A1_COD","F1_FORNECE"},{"A1_LOJA","F1_LOJA"}},"A1_FILIAL+A1_COD+A1_LOJA")
	
	oModel:AddFields("REMETENTE_SM0","MATA103_SF1",oStruCSA1,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("REMETENTE_SM0",{{"A1_FILIAL",'xFilial("SA1")'},{"A1_CGC","SM0->M0_CGC"}},"A1_FILIAL+A1_CGC")

	oModel:AddFields("DESTINATARIO_SA1","MATA103_SF1",oStruDSA1,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("DESTINATARIO_SA1",{{"A1_FILIAL",'xFilial("SA1")'},{"A1_CGC","SM0->M0_CGC"}},"A1_FILIAL+A1_CGC")
	
EndIf
oModel:SetDescription( OemToAnsi(STR0009) )

Return oModel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103SetRateioBem³ Rev.  ³Fernando Radu Muscalu  ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Transforma o rateio do documento de entrada (SDE) em rateio da  	³±±
±±³          ³ficha de ativo (SNV). 										 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103SetRateioBem(aRatCC,cItem)	 						      	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aRatCC	- Array: Rateio de Compras - Doc. Entrada. 			  	³±±
±±³          ³	aRatCC[i,1] -> char: Item do Documento de Entrada		  		³±±
±±³          ³	aRatCC[i,2] -> array: acols do rateio							³±±
±±³          ³		aRatCC[i,2,j] -> array: linha do acols 						³±±
±±³          ³		aRatCC[i,2,j,1] -> char: item do rateio 					³±±
±±³          ³		aRatCC[i,2,j,2] -> Numeric: Percentual 						³±±
±±³          ³		aRatCC[i,2,j,3] -> char: Centro de Custo 					³±±
±±³          ³		aRatCC[i,2,j,4] -> char: Conta Contabil 					³±±
±±³          ³		aRatCC[i,2,j,5] -> char: Item da Conta Contabil				³±±
±±³          ³		aRatCC[i,2,j,6] -> char: Classe de valor					³±±
±±³          ³		aRatCC[i,2,j,7] -> boolean: 								³±±
±±³          ³cItem		- Char: Item do Documento de Entrada				  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRateio	- Array: Rateio de despesas de depreciacao (Grava SNV) 	³±±
±±³          ³	aRateio[i,1] - Char: Codigo do Rateio						  	³±±
±±³          ³	aRateio[i,2] - Char: Revisao do Rateio						  	³±±
±±³          ³	aRateio[i,3] - Char: Status do Rateio						  	³±±
±±³          ³		"2"	- Pendente de classificacao							  	³±±
±±³          ³	aRateio[i,4] - Numeric: Nro da Linha do Grid do Item da		  	³±±
±±³          ³	do Ativo (nAt da GetDados do SN3)							  	³±±
±±³          ³	aRateio[i,5] - Array: Similar ao aCols, com o Rateio		  	³±±
±±³          ³		aRateio[i,5,j] - Array: Linhas do aCols	  				  	³±±
±±³          ³			aRateio[i,5,j,k] - Any: Colunas do aCols			  	³±±
±±³          ³	aRateio[i,6] - Boolean: Demonstra se o item da ficha do Ativo 	³±±
±±³          ³	foi apagado na GetDados do SN3. Se .T. - item apagado 		  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAATF - Localizacao Argentina								  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A103SetRateioBem( aRatCC, cItem )

Local aRateio	:= {}
Local aAuxRat	:= {}
Local aHeadSNV	:= {}
Local aHeadSDE	:= BuscaSDE()[1]
Local aCloned	:= {}		
Local aAreaSN3	:= SN3->(GetArea())
Local nPItem	:= 0
Local nIni		:= 0
Local nFim		:= 0
Local nCont		:= 0
Local nI		:= 0 
Local nX		:= 0
Local nZ		:= 0
Local nPos		:= 0
Local nTamNvSeq := TamSx3("NV_SEQUEN")[1]

Local cBusca	:= ""

Default cItem	:= ""

If cPaisLoc != "ARG" .Or. !FindFunction("AF011HeadSNV") .Or. !(SN3->(FieldPos("N3_RATEIO")) > 0)
	Return(aRateio)
Endif

aHeadSNV := AF011HeadSNV()

If Empty(aRatCC)	//Nao e uma inclusao
	If !Empty(SD1->D1_CBASEAF)
		
		SN3->(DbSetOrder(1))
		
		If SN3->(DbSeek(xFilial("SN3") + SD1->D1_CBASEAF + "01"))
		    If SN3->N3_RATEIO == "1" .and. !Empty(SN3->N3_CODRAT)  
		    	AF010LoadR(aRateio,SN3->N3_CODRAT,1)
		    EndIf
	    Endif            
	    
	    RestArea(aAreaSN3)
    Endif
Else

	If !Empty(cItem)
		nPItem := aScan(aRatCC,{|x| alltrim(x[1]) == alltrim(cItem)})
	Endif
	
	If nPItem > 0
	    
		nCont++
	
		aCloned := aClone(aRatCC[nPItem,2])
		
		For nI := 1 to len(aCloned)
			
			aAdd(aAuxRat, Array( len(aHeadSNV)+ 1 ))
			
			For nX := 1 to len(aHeadSDE)
			
				Do Case
				Case alltrim(aHeadSDE[nX,2]) == "DE_ITEM"
					nPos := aScan(aHeadSNV,{|x| alltrim(x[2]) == "NV_SEQUEN" })				
				Case alltrim(aHeadSDE[nX,2]) == "DE_PERC"
					nPos := aScan(aHeadSNV,{|x| alltrim(x[2]) == "NV_PERCEN" })	
				Case alltrim(aHeadSDE[nX,2]) == "DE_CC"
					nPos := aScan(aHeadSNV,{|x| alltrim(x[2]) == "NV_CC" })
				Case alltrim(aHeadSDE[nX,2]) == "DE_CONTA"          
					nPos := aScan(aHeadSNV,{|x| alltrim(x[2]) == "NV_CONTA" })
				Case alltrim(aHeadSDE[nX,2]) == "DE_ITEMCTA"
					nPos := aScan(aHeadSNV,{|x| alltrim(x[2]) == "NV_ITEMCTA" })
				Case alltrim(aHeadSDE[nX,2]) == "DE_CLVL"
					nPos := aScan(aHeadSNV,{|x| alltrim(x[2]) == "NV_CLVL" })
				End Case
				
				If nPos > 0 
					
					If alltrim(aHeadSDE[nX,2]) == "DE_ITEM"
						aAuxRat[len(aAuxRat),nPos] := Strzero(Val(aCloned[nI,nX]),nTamNvSeq)
					Else
						aAuxRat[len(aAuxRat),nPos] := aCloned[nI,nX]	
					Endif
				Endif	
				
			Next nX
						 
			aAuxRat[len(aAuxRat),len(aHeadSNV)+1] := .f.
			
			For nX := 1 to len(aHeadSNV) 
				If aAuxRat[len(aAuxRat),nX] == nil
					aAuxRat[len(aAuxRat),nX] := CriaVar(aHeadSNV[nX,2])				
				Endif
			Next nX
			
		Next nI
	
		aAdd(aRateio,{"",Strzero(0,TamSx3("NV_REVISAO")[1]),"2",nCont,aAuxRat,.f.}) 
		aAuxRat := {}
		
	EndIf    
Endif

Return(aRateio)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M103LstPreºAutor  ³Vendas Cliente      º Data ³  02/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria um pedido de venda para uma nova entrega ou fechamento º±±
±±º          ³do pedido de venda										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA846													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function M103LstPre()

Local lRet		:= .T.													//Variavel de tratamento para o retorno
Local aArea		:= GetArea()											//Grava a area Atual
Local aAreaSF1	:= SF1->( GetArea() )									//Grava a area Atual
Local aAreaSD1	:= SD1->( GetArea()	)									//Grava a area Atual
Local aAreaSD2	:= SD2->( GetArea()	)									//Grava a area Atual
Local aCab		:= {}													//Array de cabecalho do EXECAUTO
Local aItens	:= {}													//Array dos itens do EXECAUTO
Local aItAux	:= {}													//Array auxiliar para os itens do EXECAUTO
Local cTES		:= ""													//TES usada no item da NF de Remessa
Local cTpOper	:= SuperGetMV("MV_LJLPTIV",,"")							//Tipo da Operacao para o Pedido de Venda (TES Inteligente)
Local cTESPad	:= SuperGetMV("MV_LJLPTSV",,"")							//TES padrao para o Pedido de Venda
Local cLista	:= ""													//Numero da Lista de Presente
Local cItLista	:= ""													//Item da Lista de Presentes
Local cNumPV	:= ""													//Numero do pedido de Venda original
Local cNumSC5	:= ""													//Numero do Novo Pedido de Venda 
Local cMay		:= ""													//Variavel que trata o novo numero do pedido de venda pelo semaforo
Local cSeqItem	:= Replicate("0",TamSX3("C6_ITEM")[1])					//Sequencia de Item no Pedido de Venda
Local cChaveSF1	:= xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA	//Chave de pesquisa para a tabela SD1
Local aRegCtaC	:= {}													//Array para criar o registro de Credito na tabela de conta corrente
Local aAreaSL1  := SL1->(GetArea())
Local aAreaSL2	:= SL2->(GetArea())
Local aAreaME1 := ME1->(GetArea())
Local nTamItem := TamSX3("L2_ITEM")[1]
Local nTamC5Num := TamSX3("C5_NUM")[1]
Local nTamC6It  := TamSX3("C6_ITEM")[1]
Local nTamC6Desc:= TamSX3("C6_DESCRI")[1]
Local nTamC6Prc := TamSX3("C6_PRCVEN")[2]
Local nTamC6Val := TamSX3("C6_VALOR")[2]

Private lMsErroAuto := .F.												//Variavel usada para o retorno da EXECAUTO


SL1->(DbSetOrder(2)) //Serie + Documento
If SL1->(DbSeek(xFilial("SL1") + SD1->D1_SERIORI + SD1->D1_NFORI))
	SL2->(DbSetOrder(1))
	SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM + PadR(AllTrim(SD1->D1_ITEMORI) , nTamItem))) 
	cLista := SL2->L2_CODLPRE
EndIf                                   



//Caso o parametro de Tipo de Operacao e TES estejam em branco e não seja item de presente, retorna como falso na funcao
If Empty(cTpOper) .And. Empty(cTESPad) .AND. !Empty(cLista) 
	lRet		:= .F.
ElseIf !Empty(cLista)	//Caso o codigo da lista de presentes esteja em branco, retorna para a funcionalidade normal
	DbSelectArea("SC5")
	DbSetOrder(1)	//C5_FILIAL + C5_NUM 
	
	ME1->(DbSetOrder(2)) //Filial Cod Lista
	ME1->(DbSeek(xFilial("ME1") + cLista))
	
	If ME1->ME1_TIPO <> "1"

		cNumSC5 := GetSxeNum("SC5","C5_NUM")
		cMay 	:= "SC5" + ALLTRIM( xFilial("SC5") ) + cNumSC5
		While !Eof() .AND. ( DbSeek(xFilial("SC5") + cNumSC5) .OR. !MayIUseCode(cMay) )
			cNumSC5 := Soma1(cNumSC5, nTamC5Num )
			cMay 	:= "SC5" + ALLTRIM( xFilial("SC5") ) + cNumSC5
		End
	
		DbSeek( xFilial("SC5") + cNumPV )
	
		Aadd(aCab,{ "C5_FILIAL"	,	xFilial("SC5")		,NIL })
		Aadd(aCab,{ "C5_NUM"	,	cNumSC5				,NIL })
		Aadd(aCab,{ "C5_TIPO"	,	"N"					,NIL })
		Aadd(aCab,{ "C5_CLIENTE",	SF1->F1_FORNECE		,NIL })
		Aadd(aCab,{ "C5_LOJACLI",	SF1->F1_LOJA		,NIL })
		Aadd(aCab,{ "C5_CLIENT"	,	SC5->C5_CLIENT		,NIL })
		Aadd(aCab,{ "C5_LOJAENT",	SC5->C5_LOJAENT		,NIL })
		Aadd(aCab,{ "C5_TRANSP"	,	SC5->C5_TRANSP		,NIL })
		Aadd(aCab,{ "C5_TIPOCLI",	SC5->C5_TIPOCLI		,NIL })
		Aadd(aCab,{ "C5_EMISSAO",	dDataBase			,NIL })
		Aadd(aCab,{ "C5_VEND1"	,	SC5->C5_VEND1		,NIL })
		Aadd(aCab,{ "C5_CONDPAG",	SC5->C5_CONDPAG		,NIL })
		Aadd(aCab,{ "C5_ORCRES"	,	SC5->C5_ORCRES		,NIL })
		Aadd(aCab,{ "C5_FRETE"	,	SC5->C5_FRETE		,NIL })
		Aadd(aCab,{ "C5_SEGURO"	,	SC5->C5_SEGURO		,NIL })
		Aadd(aCab,{ "C5_DESPESA",	SC5->C5_DESPESA		,NIL })
		Aadd(aCab,{ "C5_TPFRETE",	SC5->C5_TPFRETE		,NIL })
		Aadd(aCab,{ "C5_DESC1"	,	SC5->C5_DESC1		,NIL })
	EndIf
	
	DbSelectArea("SD2")
	DbSetOrder(3)	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	DbSelectArea("SD1")
	DbSetOrder(1)	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	DbSeek( cChaveSF1 )
	While !SD1->( Eof() ) .AND. cChaveSF1 == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
		aItAux := {} 
		If !Empty(cTpOper)
			cTES := MaTESInt(2,cTpOper,ME1->ME1_CODCLI,ME1->ME1_LOJCLI,"C",SD2->D2_COD)
		Else
			cTESPad := cTESPad
		EndIf

		cSeqItem := Soma1(cSeqItem,nTamC6It)
		
		//SD2->(DbSetOrder(3))
		//SD2->( DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI) )
		SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM + PadR(AllTrim(SD1->D1_ITEMORI) , nTamItem) )) 
		
		//MsSeek( xFilial("SD2") + PadR(AllTrim(SD1->D1_NFORI), nTamDoc) + PadR(AllTrim(SD1->D1_SERIORI), nTamSerie) + PadR(AllTrim(SD1->D1_FORNECE), nTamCli) + PadR(AllTrim(SD1->D1_LOJA),nTamLoja) + PadR(AllTrim(SD1->D1_COD), nTamCod) + PadR(AllTrim(SD1->D1_ITEMORI), nTamItem) )
		
		If ME1->ME1_TIPO <> "1"
			aAdd(aItAux,{ "C6_FILIAL"	,xFilial("SC6")	   																			,NIL })
			aAdd(aItAux,{ "C6_ITEM"		,cSeqItem																					,NIL })
			aAdd(aItAux,{ "C6_PRODUTO"	,SD1->D1_COD  																				,NIL })
			aAdd(aItAux,{ "C6_DESCRI"	,PadR(GetAdvFVal("SB1","B1_DESC",xFilial("SB1") + SD1->D1_COD,1,""),nTamC6Desc)				,NIL })
			aAdd(aItAux,{ "C6_UM"		,SD1->D1_UM																					,NIL })
			aAdd(aItAux,{ "C6_QTDVEN"	,SD1->D1_QUANT																				,NIL })
			aAdd(aItAux,{ "C6_PRCVEN"	,Round(SD1->D1_VUNIT,nTamC6Prc)																,NIL })
			aAdd(aItAux,{ "C6_VALOR"	,Round(SD1->D1_TOTAL,nTamC6Val)																,NIL })
			aAdd(aItAux,{ "C6_TES"		,cTESPad	 																				,NIL })
			aAdd(aItAux,{ "C6_LOCAL"	,SD1->D1_LOCAL																				,NIL })
			aAdd(aItAux,{ "C6_CLI"		,SD1->D1_FORNECE																			,NIL })
			aAdd(aItAux,{ "C6_LOJA"		,SD1->D1_LOJA																	 			,NIL })
			aAdd(aItAux,{ "C6_ENTREG"	,dDataBase																					,NIL })
			aAdd(aItAux,{ "C6_CODLPRE"	,SL2->L2_CODLPRE																			,NIL })
			aAdd(aItAux,{ "C6_ITLPRE"	,SL2->L2_ITLPRE																				,NIL })
			aAdd(aItAux,{ "C6_D1DOC"	,SD1->D1_DOC   																				,NIL })
			aAdd(aItAux,{ "C6_D1ITEM"	,SD1->D1_ITEM  																				,NIL })
			aAdd(aItAux,{ "C6_D1SERIE"	,SD1->D1_SERIE 																				,NIL })
			aAdd(aItens,aItAux)    
			
				//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM  
				
			//Alimenta o array com os itens que serao gravados na tabela de Conta Corrente da Lista de Presentes
			aRegCtaC	:= {}
			aAdd(aRegCtaC,SL2->L2_CODLPRE)		//01 - Codigo da Lista
			aAdd(aRegCtaC,SL2->L2_ITLPRE)		//02 - Item da Lista
			aAdd(aRegCtaC,SD1->D1_COD)			//03 - Codigo do Produto
			aAdd(aRegCtaC,SD1->D1_QUANT)		//04 - Quantidade
			aAdd(aRegCtaC,SD1->D1_TOTAL)		//05 - Valor
			aAdd(aRegCtaC,cEmpAnt)				//06 - Empresa Original
			aAdd(aRegCtaC,cFilAnt)				//07 - Filial Original
			aAdd(aRegCtaC,Nil)					//08 - Numero do Orcamento
			aAdd(aRegCtaC,Nil)					//09 - Item do Orcamento
			aAdd(aRegCtaC,cNumSC5)				//10 - Numero do Pedido de Venda
			aAdd(aRegCtaC,cSeqItem)				//11 - Item do Pedido de Venda
			aAdd(aRegCtaC,SD1->D1_DOC)			//12 - Numero do Documento
			aAdd(aRegCtaC,SD1->D1_SERIE)		//13 - Serie do Documento
			aAdd(aRegCtaC,dDataBase)			//14 - Emissao do documento/titulo
			aAdd(aRegCtaC,NIL)					//15 - Prefixo do Titulo
			aAdd(aRegCtaC,NIL)					//16 - Numero do Titulo
			aAdd(aRegCtaC,NIL)					//17 - Parcela do Titulo
			aAdd(aRegCtaC,NIL)					//18 - Tipo do Titulo
			aAdd(aRegCtaC,SD1->D1_FORNECE)		//19 - Codigo do Cliente
			aAdd(aRegCtaC,SD1->D1_LOJA)			//20 - Loja do Cliente
	    Else
	    
	    
		    //Alimenta o array com os itens que serao gravados na tabela de Conta Corrente da Lista de Presentes
			aRegCtaC	:= {}
			aAdd(aRegCtaC,SL2->L2_CODLPRE)		//01 - Codigo da Lista
			aAdd(aRegCtaC,SL2->L2_ITLPRE)		//02 - Item da Lista
			aAdd(aRegCtaC,SD1->D1_COD)			//03 - Codigo do Produto
			aAdd(aRegCtaC,SD1->D1_QUANT)		//04 - Quantidade
			aAdd(aRegCtaC,SD1->D1_TOTAL)		//05 - Valor
			aAdd(aRegCtaC,cEmpAnt)				//06 - Empresa Original
			aAdd(aRegCtaC,cFilAnt)				//07 - Filial Original 
			aAdd(aRegCtaC,SL1->L1_NUM)					//08 - Numero do Orcamento
			aAdd(aRegCtaC,SD1->D1_ITEMORI)					//09 - Item do Orcamento
			aAdd(aRegCtaC,Nil)				//10 - Numero do Pedido de Venda
			aAdd(aRegCtaC,Nil)				//11 - Item do Pedido de Venda
			aAdd(aRegCtaC,SD1->D1_DOC)			//12 - Numero do Documento
			aAdd(aRegCtaC,SD1->D1_SERIE)		//13 - Serie do Documento
			aAdd(aRegCtaC,dDataBase)			//14 - Emissao do documento/titulo
			aAdd(aRegCtaC,NIL)					//15 - Prefixo do Titulo
			aAdd(aRegCtaC,NIL)					//16 - Numero do Titulo
			aAdd(aRegCtaC,NIL)					//17 - Parcela do Titulo
			aAdd(aRegCtaC,NIL)					//18 - Tipo do Titulo
			aAdd(aRegCtaC,SD1->D1_FORNECE)		//19 - Codigo do Cliente
			aAdd(aRegCtaC,SD1->D1_LOJA)			//20 - Loja do Cliente
	    EndIf
	    
		//Chama a rotina que cria o registo de credito na tabela de conta corrente
		If !Lj8GeraCC(aRegCtaC,IIF(ME1->ME1_TIPO <> "1",5,6),NIL,.T.)
			lRet := .F.
			RollBackSX8()
			Exit
		EndIf

		SD1->( dbSkip() )
	End

	If lRet
		MSExecAuto({|x,y,z| Mata410(x,y,z)},aCab,aItens,3) //Inclusao

		If lMsErroAuto
			RollBackSX8()
			MostraErro()
			lRet := .F.
		Else
			ConfirmSX8()
		EndIf
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaSF1)
RestArea(aAreaSD1) 
RestArea(aAreaSD2)
RestArea(aAreaSL2)
RestArea(aAreaSL1)
RestArea(aAreaME1)
Return lRet   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ma103PerAutºAutor  ³Alvaro Camillo Neto º Data ³  07/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as variaveis com os parametros da execauto          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ma103PerAut()
Local nX 		:= 0
Local cVarParam := ""

If Type("aParamAuto")!="U"
	For nX := 1 to Len(aParamAuto)
		cVarParam := Alltrim(Upper(aParamAuto[nX][1]))
		If "MV_PAR" $ cVarParam
			&(cVarParam) := aParamAuto[nX][2]
		EndIf
	Next nX
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetTipoCteºAutor  ³Julio C.Guerato	 º Data ³  29/12/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o Tipo de CTE								          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Mata103                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetTipoCTE(cCTE)
Local aCombo1  :={}
Local aComboCte:={}
Local cTPCTE   := ""
Local nCT      := 0

If SF1->(FieldPos("F1_TPCTE"))>0
	aCombo1:=x3CboxToArray("F1_TPCTE")[1]
	aSize(aComboCte,Len(aCombo1)+1)
	For nCT:=1 to Len(aComboCte)
		aComboCte[nCT]:=IIf(nCT==1," ",aCombo1[nCT-1])
	Next nCT
	nCT:=Ascan(aComboCTE, {|x| Substr(x,1,1) == cCTE})
	If nCT>0
		cTPCTE:=aComboCte[nCT]
	EndIf
EndIf

Return cTPCTE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103CpXml ºAutor  ³Jefferson Lima      º Data ³  25/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Complementa o Xml recebido pelo EAI para preenchimento das º±±
±±º          ³ chaves primaria do protheus								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao OMS x GFE                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103CpXml(  )

Local cRet    		:= PARAMIXB[1]                
Local aArea			:= GetArea()
Local oXml	 		:= Nil
Local lRet        := .F.
Local cCGC			:= ""  
Local lIntGFE   	:= SuperGetMv('MV_INTGFE',,.F.)

If lIntGFE

	oXml := tXmlManager():New()
	
	lRet := oXml:Parse(cRet)
	
	If lRet
		lRet := oXml:XPathHasNode("//MATA103/MATA103_SF1/F1_CGCFOR/value")
		If lRet
			cCgc := AllTrim( oXml:XPathGetNodeValue("//MATA103/MATA103_SF1/F1_CGCFOR", "value") )
			SA2->(DbSetOrder(3))
			If SA2->(MsSeek(xFilial("SA2") + cCgc))
				While SA2->(!Eof()) .And. AllTrim( SA2->A2_CGC ) == cCgc
					If SA2->A2_MSBLQL <> '1'								
						If oXml:XPathAddNode("//MATA103/MATA103_SF1","F1_FORNECE", '')
							If oXml:XPathAddAtt("//MATA103/MATA103_SF1/F1_FORNECE","order","98")
								If oXml:XPathAddNode("//MATA103/MATA103_SF1","F1_LOJA"   , '')
									If oXml:XPathAddAtt("//MATA103/MATA103_SF1/F1_LOJA","order","99")
										If oXml:XPathAddNode("//MATA103/MATA103_SF1/F1_FORNECE","value", SA2->A2_COD)
											If oXml:XPathAddNode("//MATA103/MATA103_SF1/F1_LOJA"   ,"value", SA2->A2_LOJA)
												cRet := oXml:Save2String()
											EndIf
										EndIf
									EndIf
								EndIf		
							EndIf
						EndIf
						Exit
					EndIf
					SA2->(dbSkip())
				EndDo		
			EndIf	
		EndIf	
	EndIf
EndIf	

RestArea(aArea)

Return cRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103DigEnd³ Autor ³Everton M. Fernandes  ³ Data ³ 22/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz o endereçamento dos itens do DOC de entrada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103DigEnd()    	   	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103DigEnd(aDigEnd)
	
	Local nOpca			:= 0
	Local nx        	:= 0
	Local nOpc			:= 0
	Local nPos			:= 0
	
	Local aFields   	:= {} 
	Local aColsSDB		:= {}
	Local aColsSD1		:= {}
	Local aHeaderSDB	:= {}
	Local aHeaderSD1	:= {} 
	Local aAlterFields	:= {}  
	Local aDados		:= {}
	
	Local oSize			:= Nil
	Local oGetSD1       := Nil
	Local oGetSDB		:= Nil
	Local oDlgEnd		:= Nil
	
	Local cTitulo   := ""
	Local cIniCpos	:= ""
	
	Local cOldAlias:=Alias(),nOrd:=IndexOrd(),nRecno:=Recno()
    
	If MsgYesNo(OemToAnsi(STR0379), OemToAnsi(STR0380))//"Deseja realizar o endereçamento dos itens da nota?", "Endereçar itens"
		//--------------------------
		//	Calcula dimensões
		//--------------------------
		oSize := FwDefSize():New()             
		oSize:AddObject( "SD1" ,  100, 50, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "SDB" ,  100, 50, .T., .T. ) // Totalmente dimensionavel 
		oSize:lProp 	:= .T. // Proporcional             
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		oSize:Process() 	   // Dispara os calculos  
	
		//-----------------
		//Monta a Dialog   
		//-----------------
		cTitulo:=OemToAnsi(STR0381)  //"Cria‡„o de Lotes na Produ‡„o"
		nOpca := 0 
		DEFINE MSDIALOG oDlgEnd TITLE cTitulo FROM oSize:aWindSize[1],oSize:aWindSize[2];  
												TO oSize:aWindSize[3],oSize:aWindSize[4] of oMainWnd Pixel
		
		//--------------------------
		//	Monta o MsGetDados SD1 
		//--------------------------
		aFields := {"D1_ITEM","D1_COD","D1_LOCAL","D1_LOTECTL","D1_NUMLOTE","D1_DTVALID",;
					"D1_QUANT","D1_NUMSEQ","D1_DOC","D1_SERIE","D1_FORNECE","D1_LOJA"}
					
		DbSelectArea("SX3")
		SX3->(DbSetOrder(2))
		For nX := 1 to Len(aFields)    
			If SX3->(DbSeek(aFields[nX]))
				Aadd(aHeaderSD1, {AllTrim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
	            			    SX3->X3_USADO,;
	            			    SX3->X3_TIPO,;
	            			    SX3->X3_F3,;
	            			    SX3->X3_CONTEXT})
			Endif
		Next nX           
		oGetSD1 := MsNewGetDados():New(oSize:GetDimension("SD1","LININI"),oSize:GetDimension("SD1","COLINI"),;
	                                   oSize:GetDimension("SD1","LINEND"),oSize:GetDimension("SD1","COLEND"),;
	                                   2, "AllwaysTrue", "AllwaysTrue", cIniCpos, aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgEnd, aHeaderSD1, aDigEnd)
		
		//--------------------------
		//	Monta o MsGetDados SDB 
		//--------------------------
		aFields := {"DB_ITEM","DB_LOCAL","DB_LOCALIZ","DB_NUMSERI","DB_QUANT","DB_SERVIC","DB_ESTDES"}
		//Monta o aHeader
		For nX := 1 to Len(aFields)    
			If SX3->(DbSeek(aFields[nX]))
				Aadd(aHeaderSDB, {AllTrim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								If (aFields[nX]="DB_LOCALIZ","A103VLDCMP('DB_LOCALIZ')", If (aFields[nX]="DB_NUMSERI" ,"A103VLDCMP('DB_NUMSERI')",If (aFields[nX]="DB_QUANT" ,"A103VLDCMP('DB_QUANT')", SX3->X3_VALID))),;
	            			    SX3->X3_USADO,;
	            			    SX3->X3_TIPO,;
	            			    SX3->X3_F3,;
	            			    SX3->X3_CONTEXT})
			Endif
		Next nX
	   	aAlterFields := aClone(aFields)   	
	   	nPos := aScan(aAlterFields,"DB_LOCAL")
	   	if nPos > 0
	   		aDel(aAlterFields,nPos) 
	   		aSize(aAlterFields,len(aAlterFields)-1)
	   	endif
	
		cIniCpos := "DB_ITEM+DB_LOCAL"
		nOpc := GD_INSERT + GD_UPDATE + GD_DELETE
		oGetSDB := MsNewGetDados():New(oSize:GetDimension("SDB","LININI"),oSize:GetDimension("SDB","COLINI"),;
	                                   oSize:GetDimension("SDB","LINEND"),oSize:GetDimension("SDB","COLEND"),;
	                                   nOpc, "AllwaysTrue", "AllwaysTrue", cIniCpos, aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgEnd, aHeaderSDB, aColsSDB, {||A103CHANGE(oGetSD1,@oGetSDB,"SDB")})
	 
	    //-------------------------------------------------
	    //	Funções para atualizar os grids dinâmicamente
	    //-------------------------------------------------
	    oGetSD1:bChange  := {||A103CHANGE (oGetSD1 ,@oGetSDB ,"SD1"  , @aDados)}   
	    oGetSD1:bLinhaOK := {||DigEndLOk  (oGetSD1 , oGetSDB ,"SD1"  , @aDados)} 
		oGetSDB:bLinhaOK := {||DigEndLOk  (oGetSD1 , oGetSDB ,"SDB"  , @aDados)}
		oGetSDB:bTudoOK  := {||DigEndTdOK (oGetSD1 , oGetSDB ,@aDados)}
	    
		//Ativa a Dialog
		ACTIVATE MSDIALOG oDlgEnd ON INIT EnchoiceBar(oDlgEnd,{||nOpca:=1,if(oGetSDB:TudoOk(),oDlgEnd:End(),nOpca := 0)},{||oDlgEnd:End()})
		
	
		dbSelectArea(cOldAlias)
		dbSetOrder(nOrd)
		MsGoto(nRecno) 
	EndIf
	
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103CHANGE³ Autor ³Everton M. Fernandes  ³ Data ³ 22/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Grid SDB							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103CHANGE()    	   	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103DigEnd()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  A103CHANGE(oGetSD1, oGetSDB, cTab, aDados)

Local nLen, nLinha
Local nPos	:= 0
Local cItem 

LOCAL cOldAlias:=Alias(),nOrd:=IndexOrd(),nRecno:=Recno()
	
Do Case
Case cTab = "SD1"	
	//------------------  
	//	Carrega o aCols        
	//------------------
	oGetSDB:aCols := {}
	cItem := GDFieldGet("D1_ITEM",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)                     
	nPos := aScan(aDados, {|x| alltrim(x[1]) == cItem})
	
	If nPos <= 0
		DigEndLine(@oGetSDB, oGetSD1) //Inicia uma linha em branco
	Else
		If Len(aDados[nPos,3]) == 0
			DigEndLine(@oGetSDB, oGetSD1) 
		Else
			aColsSDB := aDados[nPos,3]		
			oGetSDB:aCols := aClone(aColsSDB)
			oGetSDB:lNewLine := .F.
		EndIf
		oGetSDB:Refresh()
	EndIf
Case cTab = "SDB"              
		//--------------------------------- 
		//Auto incremento do campo DB_ITEM
		//---------------------------------
		nLen := Len(oGetSDB:aCols)
		nLinha := oGetSDB:nAt
		cItem := GDFieldGet("DB_ITEM",nLinha,,oGetSDB:aHeader,oGetSDB:aCols)
		nPos := GDFieldPos("DB_ITEM",oGetSDB:aHeader)
		if nLinha = nLen  .and. CtoN(cItem,10) <> nLen
			oGetSDB:aCols[nLinha][nPos] := STRZERO(nLen,4)                          
		endif                             
		//Preenche o campo DB_LOCAL
		nPos := GDFieldPos("DB_LOCAL",oGetSDB:aHeader)
		oGetSDB:aCols[nLinha][nPos] := GDFieldGet("D1_LOCAL",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)
EndCase
oGetSDB:Refresh()
	
dbSelectArea(cOldAlias)
dbSetOrder(nOrd)
MsGoto(nRecno)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103VLDCMP³ Autor ³Everton M. Fernandes  ³ Data ³ 22/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz a validação dos campos do grid de endereçamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103VLDCMP(cCampo)  	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103DigEnd()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103VLDCMP(cCampo)
	Local lRet 			:= .T.    
	Local cOldAlias:=Alias(),nOrd:=IndexOrd(),nRecno:=Recno()
	    
	DO CASE
	CASE cCampo = "DB_LOCALIZ"
		lRet := ExistCpo("SBE",GDFieldGet("DB_LOCAL",,,aHeader,aCols)+M->DB_LOCALIZ)
	CASE cCampo = "DB_NUMSERI"
		If allTrim(M->DB_NUMSERI) <> "" .and. M->DB_NUMSERI <> nil
			If GDFieldGet("DB_QUANT") > 1
				lRet := .F.
				Help(" ",1,"A103NSERI")//"Para informar o nº de série a quantidade deve ser igual a 1."
			else
				aCols[N][GDFieldPos("DB_QUANT")]:=1
			endif
		EndIf
	CASE cCampo = "DB_QUANT"
		If M->DB_QUANT <> 1
			If allTrim(GDFieldGet("DB_NUMSERI")) <> ""
				lRet := .F.
				Help(" ",1,"A103QTSERI")//Para este item a quantidade deve ser igual a 1, pois foi informado um nº de série."
			endif
		EndIf
	ENDCASE
	
	dbSelectArea(cOldAlias)
	dbSetOrder(nOrd)
	MsGoto(nRecno)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DigEndLOk ³ Autor ³Everton M. Fernandes  ³ Data ³ 22/11/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz a validação da linha do grid de endereçamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103LtLinOK(cCampo) 	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103DigEnd()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DigEndLOk(oGetSD1, oGetSDB, cTab, aDados, lValida)

Local xCampo        := Nil

Local lRet			:= .T.
Local lAchou		:= .F.

Local nLen			:= 0 
Local nLenY			:= 0
Local nX			:= 0 
Local nY 			:= 0
Local nCont 		:= 0
Local nTotal 		:= GdFieldGet("D1_QUANT",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols) 

Local nPosNumSer	:= GdFieldPos("DB_NUMSERI"	,oGetSDB:aHeader)
Local nPosLocaliz	:= GdFieldPos("DB_LOCALIZ"	,oGetSDB:aHeader)   
Local nPosLocal		:= GdFieldPos("DB_LOCAL"	,oGetSDB:aHeader)   
Local nPosQtd		:= GdFieldPos("DB_QUANT"	,oGetSDB:aHeader) 

Local cItem 		:= GDFieldGet("D1_ITEM",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)  
Local cLocal   		:= GdFieldGet("DB_LOCAL"	,oGetSDB:nAt,,oGetSDB:aHeader,oGetSDB:aCols)
Local cProd			:= GdFieldGet("D1_COD"		,oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)
Local cSeek 		:= "" 
Local cEnd 			:= "" 

Local aColsEx 		:= {}

Local cOldAlias:=Alias(),nOrd:=IndexOrd(),nRecno:=Recno()    

Default lValida := .T.

Do Case
Case cTab = "SD1"                   
	lRet:=DigEndLOk(oGetSD1,oGetSDB,"SDB",@aDados, !oGetSDB:lNewLine ) //Valida o grid 2 antes de mudar de linha
	If lRet                                             
		//-----------------------
		//Salva os dados do aCols
		//-----------------------
		nPos := aScan(aDados, {|x| allTrim(x[1]) == allTrim(cItem)})
		
		If oGetSDB:lNewLine //Retira linha em branco do aCols
			nLen :=  Len(oGetSDB:aCols)
			aDel(oGetSDB:aCols, nLen)
			aSize(oGetSDB:aCols, nLen - 1)
		EndIf
			
		If nPos <= 0
			If Len(oGetSDB:aCols) > 0
				aAdd(aDados,{cItem, cProd, oGetSDB:aCols})
			EndIf
		Else
			aDados[nPos,1] := cItem                 
			aDados[nPos,2] := cProd 
			aDados[nPos,3] := aClone(oGetSDB:aCols)
		EndIf
	endif
Case cTab = "SDB" 
	If lValida .AND. !oGetSDB:aCols[oGetSDB:nAT,Len(oGetSDB:aCols[oGetSDB:nAT])] 
		nLen := len(oGetSDB:aCols)
		//---------------------------
		//	Valida o campo Endereço
		//---------------------------
	  	xCampo := AllTrim(oGetSDB:aCols[oGetSDB:nAt, nPosLocaliz])
		
		If lRet .and. ( xCampo = "" .or. xCampo = Nil) 
			Help(" ",1,"A103END")
			lRet := .F.		
		EndIf
		
		//Verifica se o endereço suporta a qtd a endereçar
		If lRet
			nCont := 0
			For nX:= 1 To nLen	    
				cEnd :=  allTrim(oGetSDB:aCols[nX, nPosLocaliz])
				If !oGetSDB:aCols[nX,Len(oGetSDB:aCols[nX])] .And. xCampo=cEnd	
					nCont += oGetSDB:aCols[nX, nPosQtd]
				EndIf       
	 		next nX
			For nX:= 1 to Len(aDados)
				If aDados[nX,1] != cItem
					aColsEx := aClone(aDados[nX,3])
					nLenY := Len(aColsEx)
					For nY:= 1 to nLenY	    
						cEnd :=  allTrim(aColsEx[nY, nPosLocaliz])
						If !aColsEx[nY,Len(aColsEx[nY])] .And. xCampo = cEnd	
							nCont += aColsEx[nY, nPosQtd]
						EndIf       
			 		Next nY
				EndIf
			Next nX
	 		lRet := Capacidade(cLocal,xCampo,nCont,cProd)
		 endif
		
		//----------------------------
		//	Valida o campo Quantidade
		//----------------------------
	  	xCampo := oGetSDB:aCols[oGetSDB:nAt, nPosQtd]

		If lRet .and. xCampo > 0 
			//Totaliza os itens do Grid 2
			nCont := 0
			For nX:= 1 to nLen
				If !oGetSDB:aCols[nX][len(oGetSDB:aCols[nX])] //se a linha não estiver deletada...
					xCampo := oGetSDB:aCols[nX, nPosQtd]
					nCont += xCampo                            
				EndIf
			Next nX  
			                         
			If nCont > nTotal 
				Help(" ",1,"A103QTD")//"A quantidade dos itens não pode ser maior que a quantidade do produto."
				lRet := .F.
			EndIf
		ElseIf lRet		
			Help(" ",1,"A103QTD0")	//"A quantidade do item deve ser maior que 0."
			lRet := .F. 
		EndIf
		
		//----------------------------
		//	Valida o campo Num. Serie
		//----------------------------
		xCampo := oGetSDB:aCols[oGetSDB:nAt, nPosNumSer]
		//----------------------------------------------------------------
		//	Verifica se ja nao existe um numero de serie p/ este produto
		//	neste almoxarifado.
		//----------------------------------------------------------------
		If lRet .And. !Empty(AllTrim(xCampo)) 
			dbSelectArea("SBF")
			dbSetOrder(4)
			cSeek 	:= xFilial("SBF")+cProd+xCampo  
			nX 		:= 1 
			While !lAchou .And. nX <= nLen
				lAchou := nX != oGetSDB:nAt .And. oGetSDB:aCols[nX,nPosNumSer] == xCampo .AND. oGetSDB:aCols[nX,nPosLocal] == cLocal .AND. !oGetSDB:aCols[nX][len(oGetSDB:aCols[nX])] 
				nX ++
			EndDo				
			nX 		:= 1
			While !lAchou .And. nX <= Len(aDados)
				If aDados[nX,1] != cItem .And. aDados[nX,2] == cProd
					aColsEx := aClone(aDados[nX,3])
					lAchou := ASCAN(aColsEx,{|x| x[nPosNumSer] == xCampo .And. x[nPosLocal] == cLocal}) > 0
				EndIf
			    nX++
			EndDo
			If lAchou .Or. (dbSeek(cSeek) .And. QtdComp(BF_QUANT) > QtdComp(0))
				Help(" ",1,"NUMSERIEEX")
				lRet:=.F.
			EndIf
		EndIf	
	endif
EndCase

   	
dbSelectArea(cOldAlias)
dbSetOrder(nOrd)
MsGoto(nRecno)
return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DigEndTdOK³Autor ³Everton M. Fernandes  ³ Data ³ 22/11/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz a validação do grid de endereçamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DigEndTdOK()     	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103DigEnd()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DigEndTdOK(oGetSD1, oGetSDB, aDados)
	Local lRet 
	
	Local nX, nY, nLenX, nLenY, nPos
	
	Local cItem 	:= ""
	Local cProd 	:= ""
	Local cNumSeq	:= ""
	Local cDoc 		:= ""
	Local cSerie 	:= ""
	Local cCliFor	:= ""
	Local cLoja 	:= ""
	Local cLocal 	:= ""
	Local cLote 	:= ""
	Local cSubLote	:= ""
	Local cNumSeri	:= ""
	Local cLocaliz	:= ""
	Local nQuant	:= 0

	lRet := DigEndLOk(oGetSD1, oGetSDB, "SD1", @aDados)
	Begin Transaction	
		If lRet
			nLenX := Len(oGetSD1:aCols)                    
			For nX:=1 to nLenX
				cItem 	:= GDFieldGet("D1_ITEM"		,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Item
				cProd 	:= GDFieldGet("D1_COD"		,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Produto  
				cNumSeq	:= GDFieldGet("D1_NUMSEQ"	,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Num Sequencial
				cDoc 	:= GDFieldGet("D1_DOC"		,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Num Documento
				cSerie 	:= GDFieldGet("D1_SERIE"	,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Serie da nota
				cCliFor	:= GDFieldGet("D1_FORNECE"	,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Fornecedor
				cLoja 	:= GDFieldGet("D1_LOJA"		,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Loja
				cLocal 	:= GDFieldGet("D1_LOCAL"	,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Armazem
				cLote 	:= GDFieldGet("D1_LOTECTL"	,nX,,oGetSD1:aHeader,oGetSD1:aCols) //Lote
				cSubLote:= GDFieldGet("D1_NUMLOTE"	,nX,,oGetSD1:aHeader,oGetSD1:aCols) //SubLote
				nPos 	:= Ascan(aDados,{|x| x[1]== cItem})
				nLenY	:= If(nPos > 0, Len(aDados[nPos,3]), 0)
				For nY:= 1 to nLenY
					If !aDados[nPos, 3, nY, Len(aDados[nPos, 3, nY])] //Se a linha não estiver deletada...
						cNumSeri 	:= GDFieldGet("DB_NUMSERI"		,nY,,oGetSDB:aHeader,aDados[nPos,3]) //Num Serie
						cLocaliz 	:= GDFieldGet("DB_LOCALIZ"		,nY,,oGetSDB:aHeader,aDados[nPos,3]) //Endereço
						nQuant		:= GDFieldGet("DB_QUANT"		,nY,,oGetSDB:aHeader,aDados[nPos,3]) //Quantidade
						lRet := A100Distri( cProd, cLocal, cNumSeq, cDoc, cSerie, cCliFor, cLoja, cLocaliz,	cNumSeri, nQuant,cLote,cSubLote)
					EndIf
				Next nY	
			next nX
		endif 
	End Transaction		
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MATA103_V ³ Autor ³ TOTVS S.A            ³ Data ³ 04/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ MATA103 aplicado no rpo do cliente, verificando assim a    ³±±
±±³			 ³ necessidade de uma atualizacao neste fonte.		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EST/PCP/FAT/COM	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA103_V
Local nRet := 20120104 // 04 de janeiro de 2012
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ A103FldOk   ³ Autor ³ Allyson Freitas       ³ Data ³ 12.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida permissao de Produto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103FldOk()
Local lRet := .T.
Local cMenVar   := &(ReadVar())
Local cFieldSD1 := ReadVar()
Local cFieldEdit:= SubStr(cFieldSD1,4,Len(cFieldSD1))
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])== "D1_COD"})
Local lVer116   := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11)
If Altera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario tem permissao de alteracao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cFieldEdit $ "D1_COD"
		If lVer116 .And. FindFunction("MaAvalPerm")
			If IsInCallStack("MATA103") //Documento de Entrada
				lRet := MaAvalPerm(1,{cCampo,"MTA103",5}) .And. MaAvalPerm(1,{aCols[n][nPProduto],"MTA103",3})
			ElseIf IsInCallStack("MATA102N") // Remito de Entrada
				lRet := MaAvalPerm(1,{cCampo,"MT102N",5}) .And. MaAvalPerm(1,{aCols[n][nPProduto],"MT102N",3})
			ElseIf IsInCallStack("MATA101N") // Factura de Entrada
				lRet := MaAvalPerm(1,{cCampo,"MT101N",5}) .And. MaAvalPerm(1,{aCols[n][nPProduto],"MT101N",3})
			EndIf
			If !lRet
				Help(,,1,'SEMPERM')
			EndIf
		EndIf
	Else
		If lVer116 .And. FindFunction("MaAvalPerm")
			If IsInCallStack("MATA103") //Documento de Entrada
				lRet := MaAvalPerm(1,{aCols[n][nPProduto],"MTA103",4})
			ElseIf IsInCallStack("MATA102N") // Remito de Entrada
				lRet := MaAvalPerm(1,{aCols[n][nPProduto],"MT102N",4})
			ElseIf IsInCallStack("MATA101N") // Factura de Entrada
				lRet := MaAvalPerm(1,{aCols[n][nPProduto],"MT101N",4})
			EndIf
			If !lRet
				Help(,,1,'SEMPERM')
			EndIf
		EndIF
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Marcelo C. Coutinho  º Data ³  29/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Única												º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem Única                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}

dbSelectArea('XX4')
aAreaXX4 := XX4->(GetArea())
XX4->(dbSetOrder(1))

// Ao cadastrar um dos três adapters a rotina CFGA020 precisará requisitar o
// WhoIs para saber quais as versões disponíveis. Como no cadastro nenhum
// dos três adapters estará na tabela XX4 as versões disponíveis terão que
// ser cadastradas aqui dentro. Ao criar uma nova versão dos adapters o array
// de versões terá que ser atualizado aqui também.
IF XX4->(dbSeek(Xfilial('XX4') + PADR('MATA103', Len(XX4_ROTINA))))
	If AllTrim(Upper(XX4_MODEL)) == "INPUTDOCUMENT"
		aRet := MATI103(cXML, nTypeTrans, cTypeMessage)
	ElseIf AllTrim(Upper(XX4_MODEL)) == "COVERAGEDOCUMENT"
		aRet := MATI103a(cXML, nTypeTrans, cTypeMessage)
	ElseIf AllTrim(Upper(XX4_MODEL)) == "INVOICE"
		aRet := MATI103b(cXML, nTypeTrans, cTypeMessage)
	EndIf
ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
	//WhoIs
	//MATI103  v1.000
	//MATI103a v1.000
	//MATI103b v3.001
	aRet := {.T., '1.000|3.001'}
EndIf

RestArea(aAreaXX4)

Return aRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DigEndLine³ Autor ³Everton M. Fernandes  ³ Data ³ 18/01/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia uma linha no de distribuição 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DigEndLine(oGetSDB, oGetSD1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103DigEnd()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DigEndLine(oGetSDB, oGetSD1)
	Local nPos := 0                 
	
	oGetSDB:AddLine()
	oGetSDB:aCols[oGetSDB:nAt][1] := STRZERO(Len(oGetSDB:aCols),4)   
	nPos := GDFieldPos("DB_LOCAL",oGetSDB:aHeader)
	oGetSDB:aCols[oGetSDB:nAt][nPos] := GDFieldGet("D1_LOCAL",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)
Return
                 
/*/
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-------------------------------------------------------------------------------+	¦¦
¦¦¦Programa  ¦ MA103DIV1 ¦ Autor SILVIA MONICA ¦  Data ¦ 05/05/11               	¦¦
¦¦+----------+---------------------------------------------------------------------	¦¦
¦¦¦Descriçào ¦ Selecao de Divergencias da Nota Fiscal Entrada	        	        ¦¦
¦¦+----------+---------------------------------------------------------------------	¦¦
¦¦¦Uso       ¦ Especifico para CNI                                                 	¦¦
¦¦+------------------------------------------------------------------------------+  ¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
/*/
            

Static Function  _MA103Div1()     

Local aArea		:= GetArea()
Local oDlg
Local cVar     := ""
Local cTitulo  := "Selecao da Natureza das Divergencias"
Local lMark    := .F.
Local oOk      := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo      := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk1
Local oChk2
Local cSaldo 

Private lChk1 := .F.
Private lChk2 := .F.

dbSelectArea("COF")
dbSetOrder(1)
dbSeek(xFilial("COF"))

//+-------------------------------------+
//| Carrega o vetor conforme a condicao |
//+-------------------------------------+
IF  (Len( _aDivPNF ) == 0)
	While !Eof() .And. COF_FILIAL == xFilial("COF")
	   aAdd(_aDivPNF, { if(Inclui,	lMark, CA040VER(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,COF->COF_CODIGO)) , ;
	   							COF_DESCRI,;
	   							COF_CODIGO})
	   dbSkip()
	End
ENDIF	                        

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar inclusao |
//+-----------------------------------------------+
If Len( _aDivPNF ) == 0
   Aviso( cTitulo, "Nao existe divergencia cadastrada", {"Ok"} )
   Return
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
   
@ 10,10 LISTBOX oLbx FIELDS HEADER " ", "Divergencias" ;
   SIZE 230,095 OF oDlg PIXEL ON dblClick(_aDivPNF[oLbx:nAt,1] := !_aDivPNF[oLbx:nAt,1])

oLbx:SetArray( _aDivPNF )                                       

oLbx:bLine := {|| { Iif(_aDivPNF[oLbx:nAt,1],oOk,oNo),  ;
						 _aDivPNF[oLbx:nAt,2]}}

//+----------------------------------------------------------------
//| ... utilizando a função aEval()
//+----------------------------------------------------------------
@ 110,10 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos" SIZE 70,7 PIXEL OF oDlg ;
         ON CLICK( aEval( _aDivPNF, {|x| x[1] := lChk1 } ),oLbx:Refresh() )

@ 110,95 CHECKBOX oChk2 VAR lChk2 PROMPT "Inverter a seleção" SIZE 70,7 PIXEL OF oDlg ;
         ON CLICK( aEval( _aDivPNF, {|x| x[1] := !x[1] } ), oLbx:Refresh() )

DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg      

ACTIVATE MSDIALOG oDlg CENTER


RestArea(aArea)

Return()         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A103CompAdR³ Autor ³ Carlos Capeli      ³ Data ³ 22/08/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada da função de compensacao do Titulo a Pagar quando  ³±±
±±³          ³ trata-se de pedido com Adiantamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com os Pedidos de Compra                       ³±±
±±³          ³ExpA2: Array com o Recno dos titulos gerados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A103CompAdR(aPedAdt,aRecGerSE2)

Local aAreaAnt := GetArea()
Local nCntAdt  := 0

If Len(aPedAdt) > 0 .and. Len(aRecGerSE2) > 0
	If A103NCompAd(aPedAdt,aRecGerSE2,.T.,cNFiscal,cSerie)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Elimina o saldo do relacionamento de pedidos finalizados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntAdt := 1 To Len(aPedAdt)
			cQuery  := ""
			cQuery  += "SELECT COUNT(*) NREG "
			cQuery  += "  FROM "+RetSqlName("SC7")+" "
			cQuery  += " WHERE C7_FILENT  = '"+xFilial("SC7")+"' "
			cQuery  += "   AND C7_NUM     = '"+aPedAdt[nCntAdt][1]+"' "
			cQuery  += "   AND C7_RESIDUO <> 'S' "
			cQuery  += "   AND C7_QUANT   > C7_QUJE "
			cQuery  += "   AND D_E_L_E_T_ = ' ' "
												
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"A103GRAVA",.F.,.T.)

			If NREG = 0
				FPedAdtRsd("P",{aPedAdt[nCntAdt][1]})
			Endif	
			A103GRAVA->(dbCloseArea())
		Next nCntAdt	
	Endif
Endif     
RestArea(aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MA103CkAIC³ Autor ³ TOTVS S.A            ³ Data ³ 18/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao: Os Documentos de entrada vinculados a pedidos de   ³±±
±±³			 ³ compra analisam a regra de tolerancia, caso as entradas    ³±±
±±³			 ³ ultrapassem os percentuais definidos pela regra o documento³±± 
±±³			 ³ de entrada sera bloqueado.		    					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EST/PCP/FAT/COM	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MA103CkAIC(cCodFor,cLoja,cProduto)
Local lRet := .F.

//-- Executar a funcao maavaltoler passando o 12o parametro como .T., permite saber se ha tolerancia cadastrada para o Fornecedor/Produto sem
//-- avaliar o bloqueio. O bloqueio sera analisado posteriormente. 
lRet := MaAvalToler(cCodFor,cLoja,cProduto,,,,,,,,,.T.)[1]

Return(lRet)
//-----------------------------------------------------
/*/	Integra o Documento de Entrada com o SIGAGFE
@author Felipe Machado de Oliveira
@version P11
@since 22/05/2013
/*/
//------------------------------------------------------
Function A103VlIGfe(lIsIncl,lIsClass, lCommit)
Local lRet := .T.
Local aDados := {}
Local aDadosIten := {}
Local nI := 0
	
//Integração Protheus com SIGAGFE
If SuperGetMV("MV_INTGFE",.F.,.F.) .And. SuperGetMV("MV_INTGFE2",.F.,"2") $ "1" .And. SuperGetMv("MV_GFEI10",.F.,"2") == "1" .And. (lIsIncl .Or. lIsClass)
	aAdd(aDados, AllTrim(cTipo)    + Space( (TamSX3("F1_TIPO")[1])   - (Len( AllTrim(cTipo) )) ) )     	//F1_TIPO
	aAdd(aDados, AllTrim(cFormul)  + Space( (TamSX3("F1_FORMUL")[1]) - (Len( AllTrim(cFormul) )) ) )   	//F1_FORMUL
	aAdd(aDados, AllTrim(cNFiscal) + Space( (TamSX3("F1_DOC")[1])    - (Len( AllTrim(cNFiscal) )) ) )  	//F1_DOC
	aAdd(aDados, AllTrim(cSerie)   + Space( (TamSX3("F1_SERIE")[1])  - (Len( AllTrim(cSerie) )) ) )    	//F1_SERIE
	aAdd(aDados, dDEmissao )                                                                           		//F1_EMISSAO
	aAdd(aDados, AllTrim(cA100For) ) 																		//F1_FORNECE
	aAdd(aDados, AllTrim(cLoja) )    																		//F1_LOJA
	aAdd(aDados, AllTrim(cEspecie) + Space( (TamSX3("F1_ESPECIE")[1]) - (Len( AllTrim(cEspecie) )) ) ) 	//F1_ESPECIE
	aAdd(aDados, "" )                                                                                  		//F1_NFORIG
	aAdd(aDados, aNFEDanfe[1] )                        														//F1_TRANSP
	aAdd(aDados, aNFEDanfe[5] )                        														//F1_VOLUME1
	aAdd(aDados, SubStr(aNFEDanfe[14],1,1) )         														//F1_TPFRETE
	aAdd(aDados, IIF(Empty(SF1->F1_VALICM),0,SF1->F1_VALICM) ) 											//F1_VALICM
	aAdd(aDados, xFilial("SF1") )
	aAdd(aDados, "" )                                  	 													//F1_SERORIG
	aAdd(aDados, aNFEDanfe[13] )                       	 													//F1_CHVNFE
			
	For nI := 1 to Len(aCols)
		aAdd(aDadosIten, { 	GDFieldGet("D1_ITEM",nI) ,;
						    GDFieldGet("D1_COD",nI)  ,;
						    GDFieldGet("D1_QUANT",nI),;
						    GDFieldGet("D1_TOTAL",nI),;
						    GDFieldGet("D1_TES",nI)  ,;
						    GDFieldGet("D1_PESO",nI)  ,;
						    GDFieldGet("D1_CF",nI) })
	Next nI
		
	lRet := OMSM011NFE("UNICO",aDados,aDadosIten,,,,lCommit)
	
EndIf
	
Return lRet
//-----------------------------------------------------
/*/	Exclui o registro integrado.
@author Felipe Machado de Oliveira
@version P11
@since 22/05/2013
/*/
//------------------------------------------------------
Static Function ExclDocGFE()
Local aAreaGW1 := GW1->( GetArea() )
Local lRet := .T.
Local oModelGFE := FWLoadModel("GFEA044")
Local cF1_CDTPDC := ""
Local cEmisDc
Local cSerie := SF1->F1_SERIE
Local cDoc := SF1->F1_DOC
Local lNumProp := SuperGetMv("MV_EMITMP",.F.,"0") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
Local cCod := ""
Local cLoja := ""
Local nForCli := 0
	
cF1_CDTPDC := Posicione("SX5",1,xFilial("SX5")+"MQ"+SF1->F1_TIPO+"E","X5_DESCRI")
		
If Empty(cF1_CDTPDC)
	cF1_CDTPDC := Posicione("SX5",1,xFilial("SX5")+"MQ"+SF1->F1_TIPO,"X5_DESCRI")
EndIf
	
If SF1->F1_TIPO $ "DB"
	SA1->( dbSetOrder(1) )
	SA1->( MsSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA ) )
	If !SA1->( EOF() ) .And. SA1->A1_FILIAL == xFilial("SA1");
						 .And. AllTrim(SA1->A1_COD) == AllTrim(SF1->F1_FORNECE);
						 .And. AllTrim(SA1->A1_LOJA) == AllTrim(SF1->F1_LOJA)
		
		If lNumProp
			cCod := SA1->A1_COD
			cLoja := SA1->A1_LOJA
			nForCli := 1
		Else
			If SA1->A1_TIPO == "X"
				cEmisDc := AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
			Else
				cEmisDc := SA1->A1_CGC
			EndIf
		EndIf

	EndIf
Else
	SA2->( dbSetOrder(1) )
	SA2->( MsSeek( xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA) )
	If !SA2->( EOF() ) .And. SA2->A2_FILIAL == xFilial("SA2");
						 .And. AllTrim(SA2->A2_COD) == AllTrim(SF1->F1_FORNECE);
						 .And. AllTrim(SA2->A2_LOJA) == AllTrim(SF1->F1_LOJA)
		
		If lNumProp
			cCod := SA2->A2_COD
			cLoja := SA2->A2_LOJA
			nForCli := 2
		Else
			If SA2->A2_TIPO == "X"
				cEmisDc := AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA)
			Else
				cEmisDc := SA2->A2_CGC
			EndIf
		EndIf
			
	EndIf
EndIf
	
cF1_CDTPDC := AllTrim(cF1_CDTPDC) + Space( (TamSX3("GW1_CDTPDC")[1]) - (Len( AllTrim(cF1_CDTPDC) )) )
cSerie := AllTrim(cSerie) + Space( (TamSX3("GW1_SERDC" )[1]) - (Len( AllTrim(cSerie) )) )
cDoc := AllTrim(cDoc) + Space( (TamSX3("GW1_NRDC" )[1]) - (Len( AllTrim(cDoc) )) )

If lNumProp
	cEmisDc := OMSM011COD(cCod,cLoja,nForCli,,)
EndIf
	
GW1->( dbSetOrder(1) )
GW1->( MsSeek(xFilial("GW1")+cF1_CDTPDC+cEmisDc+cSerie+cDoc) )
If !GW1->( Eof() ) .And. GW1->GW1_FILIAL == xFilial("GW1");
					.And. AllTrim(GW1->GW1_CDTPDC) == AllTrim(cF1_CDTPDC) ;
					.And. AllTrim(GW1->GW1_EMISDC) == AllTrim(cEmisDc) ;
					.And. AllTrim(GW1->GW1_SERDC) == AllTrim(cSerie) ;
					.And. AllTrim(GW1->GW1_NRDC) == AllTrim(cDoc)
		
	oModelGFE:SetOperation( MODEL_OPERATION_DELETE )
	oModelGFE:Activate()
		
	If oModelGFE:VldData()
		oModelGFE:CommitData()
	Else
		Help( ,, STR0119,,STR0404+CRLF+CRLF+oModelGFE:GetErrorMessage()[6], 1, 0,,,,,.T. ) //"Atenção"##"Inconsistência com o Frete Embarcador (SIGAGFE): "##
		lRet := .F.
	EndIf
		
EndIf
	
RestArea( aAreaGW1 )
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaHlpºAutor  ³Leonardo Quintania  º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ajuste dos helps do programa                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHlp()
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

aHelpPor := {"Não há notas fiscais de origem referente"," a este fornecedor e produto."}
aHelpEng := {"Ther are no invoices referring to this"," supplier"}
aHelpSpa := {"No hay facturas de origen referentes a ","este  producto y proveedor "}
PutHelp("PF4NAOFORI",aHelpPor,aHelpEng,aHelpSpa,.T.)

Return
