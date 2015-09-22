#INCLUDE "TBICONN.CH"
#INCLUDE "MATA140.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE VALMERC	01	// Valor total do mercadoria
#DEFINE VALDESC	02	// Valor total do desconto
#DEFINE TOTPED	    03	// Total do Pedido
#DEFINE FRETE     	04  // Valor total do Frete
#DEFINE VALDESP   	05	// Valor total da despesa
#DEFINE SEGURO	    07	// Valor total do seguro

Static aPedC := {}

// 24/09/2009 - Angola
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA140  � Autor � Edson Maricate        � Data � 24.01.2000 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Digitacao das Notas Fiscais de Entrada sem os dados Fiscais  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA        �Programa     MATA140.PRW  ���
���������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data                              ���
���������������������������������������������������������������������������Ĵ��
���      01  � Marcos V. Ferreira       � 11/04/2006 - Bops: 00000096840    ���
���      02  � Marcos V. Ferreira       � 19/12/2005					    ���
���      03  � Marcos V. Ferreira       � 11/04/2006 - Bops: 00000096840    ���
���      04  � Flavio Luiz Vicco        � 04/01/2006                        ���
���      05  � Nereu Humberto Junior    � 16/03/2006                        ���
���      06  � Nereu Humberto Junior    � 16/03/2006                        ���
���      07  � Flavio Luiz Vicco        � 04/01/2006                        ���
���      08  � Ricardo Berti            � 07/02/2006                        ���
���      09  � Ricardo Berti            � 07/02/2006                        ���
���      10  � Marcos V. Ferreira       � 19/12/2005					    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/	

Function MATA140(xAutoCab,xAutoItens,nOpcAuto,lSimulaca,nTelaAuto)

Local aRotADic  := {}
Local aCores    := {	{ 'Empty(F1_STATUS)','ENABLE' 		},;// NF Nao Classificada
						{ 'F1_STATUS=="B"'	,'BR_LARANJA'	},;// NF Bloqueada
						{ 'F1_STATUS=="C"'	,'BR_VIOLETA'   },;	// NF Bloqueada s/classf.
						{ 'F1_TIPO=="N"'	,'DISABLE'		},;// NF Normal
						{ 'F1_TIPO=="P"'	,'BR_AZUL'		},;// NF de Compl. IPI
						{ 'F1_TIPO=="I"'	,'BR_MARROM'	},;// NF de Compl. ICMS
						{ 'F1_TIPO=="C"'	,'BR_PINK'		},;// NF de Compl. Preco/Frete
						{ 'F1_TIPO=="B"'	,'BR_CINZA'		},;// NF de Beneficiamento
						{ 'F1_TIPO=="D"'	,'BR_AMARELO'	} }// NF de Devolucao
						
Local cFiltraSf1    := ""
Local nX,nAutoPC	:= 0
Local aCoresUsr     := {}    

Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()


PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro	:= OemToAnsi(STR0007) //"Pre-Documento de Entrada"
PRIVATE l140Auto	:= ( ValType(xAutoCab) == "A"  .And. ValType(xAutoItens) == "A" )
PRIVATE aAutoCab	:= xAutoCab
PRIVATE aAutoItens	:= xAutoItens
PRIVATE aHeadSD1    := {}
PRIVATE l103Auto	:= l140Auto
PRIVATE lOnUpdate	:= .T.
PRIVATE nMostraTela := 0 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
PRIVATE a140Total := {0,0,0}
PRIVATE a140Desp  := {0,0,0,0,0,0,0,0}

Private oLbx  
Private _aDivPNF := {}


DEFAULT nOpcAuto	:= 3
DEFAULT lSimulaca	:= .F.
DEFAULT nTelaAuto   := 0

//������������������������������������������Ŀ
//�Ajusta Help para criar novo help da rotina�
//��������������������������������������������
AjustaHelp()

If l140Auto   
	For nX:= 1 To Len(xAutoItens)
		If (nAutoPC := Ascan(xAutoItens[nx],{|x| x[1]== "D1_PEDIDO"})) > 0
		     If Empty(xAutoItens[nX][nAutoPC][3])
		     	xAutoItens[nX][nAutoPC][3]:= "vazio().or. A103PC()"
			 EndIf
		EndIf
	Next
EndIf      

If lPrjCni
	//------------------------------------------------
	// Abre arquivo de divergencias 
	//------------------------------------------------
	dbSelectArea("COF")
	dbSetOrder(1)
	dbSeek(xFilial("COF"))                           
EndIf


//�����������������������������������������������������������Ŀ
//�Se estiver usando conferencia fisica muda opcoes do mbrowse�
//�������������������������������������������������������������
If (SuperGetMV("MV_CONFFIS",.F.,"N") == "S")
	aCores    := {	{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. Empty(F1_STATUS)'	, 'ENABLE' 		},;	// NF Nao Classificada
					{ 'F1_TIPO=="N" .AND. !Empty(F1_STATUS)'									, 'DISABLE'		},; // NF Normal
					{ 'F1_STATUS=="B"'															, 'BR_LARANJA'	},;	// NF Bloqueada
				    { 'F1_STATUS=="C"'															, 'BR_VIOLETA'	},; // NF Bloqueada s/classf.
					{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="P"'	 	, 'BR_AZUL'		},;	// NF de Compl. IPI
					{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="I"'	 	, 'BR_MARROM'	},;	// NF de Compl. ICMS
					{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="C"'	 	, 'BR_PINK'		},;	// NF de Compl. Preco/Frete
					{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="B"'	 	, 'BR_CINZA'	},;	// NF de Beneficiamento
					{ '((F1_STATCON $ "1|4") .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="D"'    	, 'BR_AMARELO'	},;	// NF de Devolucao
					{ '!(F1_STATCON $ "1|4") .AND. !EMPTY(F1_STATCON) .AND. Empty(F1_STATUS)'	, 'BR_PRETO'	}} 	// NF Bloq. para Conferencia
EndIf


//��������������������������������������������������������������Ŀ
//| Adiciona rotinas ao aRotina                                  |
//����������������������������������������������������������������
If ExistBlock( "MT140FIL" )
    cFiltraSF1 := ExecBlock("MT140FIL",.F.,.F.)
	If ( ValType(cFiltraSF1) <> "C" )
		cFiltraSF1 := ""
	EndIf
EndIf

//�������������������������������������������������������������������������Ŀ
//�Ponto de entrada para Manipular o Array com as regras e cores da Mbrowse �
//���������������������������������������������������������������������������
If ( ExistBlock("MT140COR") )			
	aCoresUsr := ExecBlock("MT140COR",.F.,.F.,{aCores})
	If ( ValType(aCoresUsr) == "A" )
		aCores := aClone(aCoresUsr)
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica a permissao do programa em relacao aos modulos      �
//����������������������������������������������������������������
If AMIIn(2,4,11,12,14,17,39,41,42,97,17,44,67,69,72) 
	Pergunte("MTA140",.F.)
	//����������������������������������������������������������������Ŀ
	//� Ativa tecla F12 para ativar parametros de lancamentos contab.  �
	//������������������������������������������������������������������
	If l140Auto
		lOnUpdate  := !lSimulaca
		nMostraTela:= nTelaAuto
		aAutoCab   := xAutoCab
		aAutoItens := xAutoItens

		If nOpcAuto == 7
			aRotBack 	  := aClone(aRotina)
			aRotina[5][2] := aRotBack[7][2]
			nOpcAuto	  := 5
		EndIf
		MBrowseAuto( nOpcAuto, AClone( aAutoCab ), "SF1" )
                          
		If nOpcAuto == 5 .And. aRotina[5][2] == "A140EstCla" 
			aRotina:= aClone(aRotBack)
		EndIf

		xAutoCab   := aAutoCab
		xAutoItens := aAutoItens
	Else
		SetKey(VK_F12,{||Pergunte("MTA140",.T.)})
		
		#IFDEF TOP
    	    mBrowse(6,1,22,75,"SF1",,,,,,aCores,,,,,,,,cFiltraSF1) 
    	#Else
  			mBrowse(6,1,22,75,"SF1",,,,,,aCores)
	   	#ENDIF
	   	
		SetKey(VK_F12,Nil)
	EndIf
EndIf
Return
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �A140NFisca� Autor � Eduardo Riera         � Data �02.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Interface do pre-documento de entrada                        ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1: Alias do arquivo                                      ���
���          �ExpN2: Numero do Registro                                    ���
���          �ExpN3: Opcao selecionada no arotina                          ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo controlar a interface de um    ���
���          �pre-documento de entrada                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function A140NFiscal(cAlias,nReg,nOpcX)
Local nAcho     := 0
Local aRecSD1   := {}
Local aObjects  := {}
Local aInfo 	:= {}
Local aPosGet	:= {}
Local aPosObj	:= {}
Local aStruSD1  := {}
Local aListBox  := {}
Local aCamposPE := {}
Local aNoFields := {}
Local aRecOrdSD1:= {}
Local aTitles   := {OemToAnsi(STR0038), STR0008, STR0034} //"Fornecedor/Cliente" ### "Descontos/Frete/Despesas" //"Totais"
Local aFldCBAtu := Array(Len(aTitles))
Local aInfForn	:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"","","",""}
Local aSizeAut  := {}
Local aButtons	:= {}
Local aListCpo 	:= {	"D1_COD"	,;
						"D1_UM"		,;
						"D1_QUANT"	,;
						"D1_VUNIT"	,;
						"D1_TOTAL"	,;
						"D1_LOCAL"	,;
						"D1_PEDIDO"	,;
						"D1_ITEMPC"	,;
						"D1_SEGUM"	,;
						"D1_QTSEGUM",;
						"D1_CC"		,;
						"D1_CONTA"	,;
						"D1_ITEMCTA",;
						"D1_CLVL"	,;
						"D1_ITEM"	,;
						"D1_LOTECTL",;
						"D1_NUMLOTE",;
						"D1_DTVALID",;
						"D1_LOTEFOR",;
						"D1_DESC"	,;
						"D1_VALDESC",;
						"D1_OP"		,;
						"D1_CODGRP"	,;
						"D1_CODITE"	,;
						"D1_VALIPI"	,;
						"D1_VALICM"	,;
						"D1_CF"		,;
						"D1_IPI"	,;
						"D1_PICM"	,;
						"D1_PESO"	,;
						"D1_TP"		,;
						"D1_BASEICM",;
						"D1_BASEIPI",;
						"D1_TEC"	,;
						"D1_CONHEC"	,;
						"D1_TIPO_NF",;
						"D1_NFORI"	,;
						"D1_SERIORI",;
						"D1_ITEMORI",;
						"D1_VALIMP1",;
						"D1_VALIMP2",;
						"D1_VALIMP3",;
						"D1_VALIMP4",;
						"D1_VALIMP5",;
						"D1_VALIMP6",;
						"D1_BASIMP1",;
						"D1_BASIMP2",;
						"D1_BASIMP3",;
						"D1_BASIMP4",;
						"D1_BASIMP5",;
						"D1_BASIMP6",;
						"D1_ALQIMP1",;
						"D1_ALQIMP2",;
						"D1_ALQIMP3",;
						"D1_ALQIMP4",;
						"D1_ALQIMP5",;
						"D1_ALQIMP6",;
						"D1_VALFRE"	,;
						"D1_SEGURO"	,;
						"D1_DESPESA",;
						"D1_FORMUL"	,;
						"D1_CLASFIS",;
						"D1_II"		,;
						"D1_ICMSDIF",;		
						"D1_ITEMMED" } 
					
Local l140Inclui := .F.
Local l140Altera := .F.
Local l140Exclui := .F.
Local l140Visual := .F.
Local lContinua  := .T.
Local lQuery     := .F.
Local lItSD1Ord  := IIF(mv_par03==2,.T.,.F.)
Local lConsMedic := .F.
Local lExistMemo := .F. 
Local lIntACD	 := SuperGetMV("MV_INTACD",.F.,"0") == "1"

Local cAliasSD1  := "SD1"
Local nX         := 0
Local nY         := 0
Local nPosPC	 := 0
Local nPosGetLoja:= IIF(TamSX3("A2_COD")[1]< 10,(2.5*TamSX3("A2_COD")[1])+(110),(2.8*TamSX3("A2_COD")[1])+(100))
Local nOpcA		 := 0
Local nQtdConf   := 0
Local bWhileSD1  := {||.T.}
Local bCabOk     := {||.T.}
Local oDlg
Local oFolder
Local oEnable    := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable   := LoadBitmap( GetResources(), "DISABLE" )
Local oStatCon
Local oConf
Local oTimer
Local aPosDel    := {}
Local dDataFec   := If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
Local aCTBEnt		:= If(FindFunction("CTBEntArr"),CTBEntArr(),{})

Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local aButVisual	:= {}


Private oGetDados
Private bGDRefresh	:= {|| IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.) }		// Efetua o Refresh da GetDados
Private	bRefresh    := {|nX,nY,nTotal,nValDesc| Ma140Total(a140Total,a140Desp,nTotal,nValDesc),NfeFldChg(,,oFolder,aFldCBAtu),IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.)}
Private l103Visual  := .T. //-- Nao permite alterar os campos de despesas/frete.
Private lNfMedic    := .F. 

DEFAULT aPedC	:= {}    

l140Auto := !(Type("l140Auto")=="U" .Or. !l140Auto)

// Zera os totais para que a chamada de inclusao apos uma gravacao nao traga os valores preenchidos 
a140Total := {0,0,0}
a140Desp  := {0,0,0,0,0,0,0,0}

//��������������������������������������������������������������Ŀ
//� Inclui os campos referentes as entidades contabeis           �
//����������������������������������������������������������������
For nX := 1 To Len(aCTBEnt)
	If SD1->(FieldPos("D1_EC" +aCTBEnt[nX] +"CR")) > 0 
		aAdd(aListCpo,"D1_EC" +aCTBEnt[nX] +"CR")
		aAdd(aListCpo,"D1_EC" +aCTBEnt[nX] +"DB")
	EndIf
Next nX

//��������������������������������������������������������������Ŀ
//� Inclui os campos referentes ao WMS na Pre-Nota               �
//����������������������������������������������������������������
If IntDL()
	aAdd(aListCpo, 'D1_SERVIC')
	aAdd(aListCpo, 'D1_STSERV')
	aAdd(aListCpo, 'D1_TPESTR')
	aAdd(aListCpo, 'D1_DESEST')
	aAdd(aListCpo, 'D1_REGWMS')
	aAdd(aListCpo, 'D1_ENDER' )
EndIf

//��������������������������������������������������������������Ŀ
//� Inclui os campos referentes ao EIC na Pre-Nota               �
//����������������������������������������������������������������
If l140Auto .And. SuperGetMV("MV_EASY",,"N") == "S"
	aAdd(aListCpo, 'D1_DATORI' )
EndIf

//��������������������������������������������������������������Ŀ
//� Quando rotina autom�tica e o processo executado e uma transf.�
//� entre filiais, grava na TES o conte�do enviado - mv_par15	 �
//� MATA310 - array aParam310[15]								 �
//����������������������������������������������������������������
If l140Auto .and. IsInCallStack("MATA310")
	aAdd(aListCpo, 'D1_TESACLA' )
EndIf

//��������������������������������������������������������������Ŀ
//� Inclusao do campos D1_VALCMAJ para tratamento da Aliquota	 �
//� Majorada da COFINS Importacao.								 �
//����������������������������������������������������������������
If (SD1->(FieldPos("D1_VALCMAJ")) > 0)
	aAdd(aListCpo, 'D1_VALCMAJ')
EndIf

//��������������������������������������������������������������Ŀ
//� Chamada do ponto de entrada MT140CPO                         �
//����������������������������������������������������������������
If ExistTemplate("MT140CPO")
	aCamposPE := If(ValType(aCamposPE:=ExecTemplate('MT140CPO',.F.,.F.))=='A',aCamposPE,{})
	If Len(aCamposPE) > 0
		For nX := 1 to Len(aCamposPE)
			If (aScan(aListCpo, aCamposPE[nX])) == 0
				aadd(aListCpo, aCamposPE[nX])
			EndIf
		Next nX
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Chamada do ponto de entrada MT140CPO                         �
//����������������������������������������������������������������
If ExistBlock("MT140CPO")
	aCamposPE := If(ValType(aCamposPE:=ExecBlock('MT140CPO',.F.,.F.))=='A',aCamposPE,{})
	If Len(aCamposPE) > 0
		For nX := 1 to Len(aCamposPE)
			If (aScan(aListCpo, aCamposPE[nX])) == 0
				aadd(aListCpo, aCamposPE[nX])
			EndIf
		Next nX
	EndIf
EndIf                                                           

//�������������������������������������������������������������������������������������������������������������Ŀ
//� Chamada do ponto de entrada MT140DCP 					   �                                                |
//| Para n�o exibir os campos customizados no Acols, � necess�rio incluir o mesmo no aListBox e posteriormente  |
//| carregar o mesmo no array aNolFields para ser descconsiderado na FillGetDados 								|
//���������������������������������������������������������������������������������������������������������������
aNoFields:= {}
If ExistBlock("MT140DCP")
	aNoFields := If(ValType(aNoFields:=ExecBlock('MT140DCP',.F.,.F.))=='A',aNoFields,{})
	If Len(aNoFields) > 0
		For nX := 1 to Len(aNoFields)
			If (aScan(aListCpo, aNoFields[nX])) == 0
				aadd(aListCpo, aNoFields[nX])
			EndIf
		Next nX
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica a operacao a ser realizada                          �
//����������������������������������������������������������������
Do Case
	Case aRotina[nOpcX][4] == 2
		l140Visual := .T.
	Case aRotina[nOpcX][4] == 3
		l140Inclui	:= .T.
	Case aRotina[nOpcX][4] == 4
		l140Altera	:= .T.
	Case aRotina[nOpcX][4] == 5
		l140Exclui	:= .T.
		l140Visual	:= .T.
EndCase

//�������������������������������������������������������������������Ŀ
//� Analisa data de fechamento somente quando o parametro MV_DATAHOM  |
//| estiver configurado com o conteudo igual a "2"                    �
//���������������������������������������������������������������������
If l140Inclui .And. SuperGetMv("MV_DATAHOM",.F.,"1")=="2"
	If dDataFec >= dDataBase
		Help( " ", 1, "FECHTO" )
		lContinua := .F.
    EndIf
EndIf

// Evita reacumulo do saldo em aPedc (ao cancelar alt./realterar/F6) BOPS 90013 07/02/06
If !l140Visual
	aPedC	:= {}	
EndIf

//��������������������������������������������������������������Ŀ
//� Inicializa as variaveis da Modelo 2                          �
//����������������������������������������������������������������
Private bPMSDlgNF	:= {||PmsDlgNF(nOpcX,cNFiscal,cSerie,cA100For,cLoja,cTipo)} // Chamada da Dialog de Gerenc. Projetos
Private aRatAFN     := {}
Private	cTipo		:= If(l140Inclui,CriaVar("F1_TIPO")		,SF1->F1_TIPO)
Private cFormul		:= If(l140Inclui,CriaVar("F1_FORMUL")	,SF1->F1_FORMUL)
Private cNFiscal 	:= If(l140Inclui,CriaVar("F1_DOC")		,SF1->F1_DOC)
Private cSerie		:= If(l140Inclui,CriaVar("F1_SERIE")	,SF1->F1_SERIE)
Private dDEmissao	:= If(l140Inclui,CriaVar("F1_EMISSAO")	,SF1->F1_EMISSAO)
Private cA100For	:= If(l140Inclui,CriaVar("F1_FORNECE")	,SF1->F1_FORNECE)
Private cLoja		:= If(l140Inclui,CriaVar("F1_LOJA")		,SF1->F1_LOJA)
Private cEspecie	:= If(l140Inclui,CriaVar("F1_ESPECIE")	,SF1->F1_ESPECIE)
Private cUfOrigP	:= If(l140Inclui,CriaVar("F1_EST")		,SF1->F1_EST)
Private n           := 1
Private aCols		:= {}
Private aHeader 	:= {}
Private lReajuste   := IIF(mv_par01==1,.T.,.F.)
Private lConsLoja   := IIF(mv_par02==1,.T.,.F.)
Private cForAntNFE  := ""
Private lMudouNum   := .F.

//��������������������������������������������������������������Ŀ
//� Habilita as HotKeys e botoes da barra de ferramentas         �
//����������������������������������������������������������������
If (!l140Auto .Or. (nMostraTela <> 0)) .And. (l140Inclui .Or. l140Altera)
    If !l140Altera
		aButtons	:= {{'PEDIDO',{||A103ForF4(.F.,a140Desp, lNfMedic, lConsMedic),Eval(bRefresh)},STR0009,STR0010},; //"Pedidos de Compras"
						{'SDUPROP',{||A103ItemPC(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh)},STR0011,STR0031} } //"PEDIDO"###"Pedidos de Compras(por item)"
						
		SetKey( VK_F5, { || A103ForF4(.F.,a140Desp, lNfMedic, lConsMedic ),Eval(bRefresh) } )
		SetKey( VK_F6, { || A103ItemPC(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh) } )

    Else                    
	    AAdd(aButVisual,{ 'SDUPROP', {||A103ItemPC(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh)}, STR0011, STR0031 } ) //"PEDIDO"###"Pedidos de Compras(por item)"
		SetKey( VK_F6, { || A103ItemPC(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh) } )
    EndIf
EndIf

If (!l140Auto .Or. (nMostraTela <> 0)) .And. IntePms()
	If l140Altera .Or. l140Visual
		aadd(aButVisual, {'PROJETPMS',bPmsDlgNF,STR0012,STR0032}) //"Gerenciamento de Projetos"
	EndIf
	aadd(aButtons, {'PROJETPMS',bPmsDlgNF,STR0012,STR0032}) //"Gerenciamento de Projetos"
	SetKey( VK_F10, { || Eval(bPmsDlgNF)} )
EndIf

lConsMedic := A103GCDisp()

//��������������������������������������������������������������Ŀ
//� Habilita o folder de conferencia fisica se necessario        �
//����������������������������������������������������������������
If l140Visual .And. (((SA2->(FieldPos('A2_CONFFIS'))>0) .And. (((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "1") .Or. SA2->A2_CONFFIS == "1") ;
.And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S")) .Or. ;
(cTipo == "B" .And. (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. (SuperGetMV("MV_TPCONFF",.F.,"1") == "1")))
	aadd(aTitles,STR0013) //"Conferencia Fisica"
EndIf

//�������������������������������������������������Ŀ
//�Verifica se o usuario tem permissao de exclusao. �
//���������������������������������������������������
If nOpcX == 5
	If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
		aArea2 := GetArea()
		SD1->(dbSeek(xFilial("SD1")+cNFiscal+cSerie))
		While !SD1->(Eof()) .And. lContinua .And. SD1->D1_DOC == cNFiscal .And. SD1->D1_SERIE == cSerie
			lContinua := MaAvalPerm(1,{SD1->D1_COD,"MTA140",5})
			SD1->(dbSkip())
		End
		RestArea(aArea2)
		If !lContinua
			Help(,,1,'SEMPERM')
		EndIf
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se a NF possui NF de Conhec. e Desp. de Import.     �
//����������������������������������������������������������������
If l140Exclui .And. lContinua
	SF8->(dbSetOrder(2))
	If SF8->(MsSeek(xFilial("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		Help(" ", 1, "A103CAGREG")
		lContinua := .F.
	EndIf	
EndIf

//���������������������������������������������������������������������������������������������Ŀ
//�Notas Fiscais NAO Classificadas geradas pelo SIGAEIC NAO deverao ser visualizadas no MATA140 �
//�����������������������������������������������������������������������������������������������
If cPaisLoc == "BRA" .And. l140Visual .And. !Empty(SF1->F1_HAWB) .And. Empty(SF1->F1_STATUS) .And. (!IsInCallStack("DI154DELET") .And. !IsInCallStack("DI154CapNF"))  
	Aviso("A140NOVIEWEIC",STR0065,{"Ok"}) // "Este documento foi gerado pelo SIGAEIC e ainda N�O foi classificado, para visualizar utilizar a op��o classificar ou no Modulo SIGAEIC op��o Desembara�o/recebimento de importa��o/Totais. Apos a classifica��o o documento pode ser visualizado normalmente nesta op��o."
	lContinua := .F.
EndIf

//���������������������������������������������������������������Ŀ
//� Ponto de entrada para validar a alteracao de um pre-documento �
//�����������������������������������������������������������������
If l140Altera .And. ExistBlock("A140ALT") .And. lContinua
	lContinua := If(ValType(lContinua:=ExecBlock("A140ALT",.F.,.F.))=='L',lContinua,.T.)
EndIf	

//��������������������������������������������������������������Ŀ
//� Chamada do banco de conhecimento                             �
//����������������������������������������������������������������
If lContinua .And. (l140Visual .Or. l140Altera)
	AAdd(aButVisual,{ "clips", {|| A140Conhec() }, STR0066, STR0067 } ) // "Banco de Conhecimento", "Conhecim."
EndIf

If !l140Inclui .And. lContinua
	//-- Atualiza dados do folder de despesas
	a140Desp[VALDESP]:= SF1->F1_DESPESA
	a140Desp[FRETE]  := SF1->F1_FRETE
	a140Desp[SEGURO] := SF1->F1_SEGURO

	//��������������������������������������������������������������Ŀ
	//� Montagem do aCols                                            �
	//����������������������������������������������������������������
	If !l140Visual
		If !SoftLock("SF1")
			lContinua := .F.
		EndIf
	EndIf
	//��������������������������������������������������������������Ŀ
	//� Alteracao - Verifica Status da conferencia                   �
	//����������������������������������������������������������������
	If lContinua .And. !l140Visual   
		If (SA2->(FieldPos('A2_CONFFIS'))>0) .And. (((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "1") .Or. SA2->A2_CONFFIS == "1") ;
		.And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S").And. SF1->F1_STATCON == "1"
			If Aviso(OemToAnsi(STR0035),OemToAnsi(STR0054),{STR0026,STR0027})==1 //Atencao##"Documento j� conferido. Prosseguir e estornar a Confer�ncia?"
				A140AtuCon(,,,,,,,,.T.)
			Else
				lContinua := .F.
			EndIf
		EndIf
	EndIf
	If lContinua
		dbSelectArea("SD1")
		dbSetOrder(1)
		#IFDEF TOP

			//����������������������������������������������������������������������Ŀ
			//� Verifica a existencia de campo MEMO no SD1 para nao executar a Query.�
			//������������������������������������������������������������������������
			SX3->(dbSetOrder(1))
			SX3->(MsSeek("SD1"))
			While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SD1"
				If (IIf((!l140Auto .Or. (nMostraTela <> 0)),X3USO(SX3->X3_USADO),.T.) .And.;
				 Ascan(aListCpo,Trim(SX3->X3_CAMPO)) != 0 .And. cNivel >= SX3->X3_NIVEL) .Or.;
				(SX3->X3_PROPRI == "U" .And. cNivel >= SX3->X3_NIVEL)
					If SX3->X3_TIPO == "M"
                        lExistMemo := .T. 
						Exit
					EndIf
				EndIf
				SX3->(dbSkip())
			EndDo

			If !InTransact() .And. !lExistMemo
				aStruSD1 := SD1->(dbStruct())
				lQuery   := .T.

				cQuery := "SELECT SD1.R_E_C_N_O_ SD1RECNO,SD1.* "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
				cQuery += "SD1.D1_DOC = '"+SF1->F1_DOC+"' AND "
				cQuery += "SD1.D1_SERIE = '"+SF1->F1_SERIE+"' AND "
				cQuery += "SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND "
				cQuery += "SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND "
				cQuery += "SD1.D_E_L_E_T_=' ' "

				If lItSD1Ord .Or. ALTERA
					cQuery += "ORDER BY "+SqlOrder( "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD" )
				Else
					cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				EndIf

				cQuery := ChangeQuery(cQuery)

				SD1->(dbCloseArea())

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SD1")
				For nX := 1 To Len(aStruSD1)
					If aStruSD1[nX][2]<>"C"
						TcSetField("SD1",aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
					EndIf
				Next nX
			Else
		#ENDIF
			MsSeek(xFilial("SD1")+cNFiscal+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		#IFDEF TOP
			EndIf
		#ENDIF

		bWhileSD1 := { || ( !Eof().And. lContinua .And. ;
				(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
				(cAliasSD1)->D1_DOC == cNFiscal .And. ;
				(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
				(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
				(cAliasSD1)->D1_LOJA == SF1->F1_LOJA ) }

	EndIf
EndIf 

If lContinua
	//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
	//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
	SetKey( VK_F10, Nil ) //desativa tecla F10 ao exibir Alert
	FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,aListCpo,/*lOnlyYes*/,/*cQuery*/,{|| MaCols140 (cAliasSD1,bWhileSD1,aRecOrdSD1,@aRecSD1,@aPedC,lItSD1Ord,lQuery,l140Inclui,l140Visual,@lContinua,l140Exclui) },l140Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,.T.,IIF(!l140Auto .Or. nMostraTela <> 0,{},aListCpo))
	SetKey( VK_F10, { || Eval(bPmsDlgNF)} )
	If lQuery
		dbSelectArea("SD1")
		dbCloseArea()
		ChkFile("SD1")
	EndIf
            
	//��������������������������������������������������������������������������������������������������������������������������Ŀ
	//� Ponto de entrada que permite o preenchimento autom�tico dos dados do cabe�alho da pre-nota e define se continua a rotina |
	//����������������������������������������������������������������������������������������������������������������������������
	If l140Inclui
		If ExistBlock("MT140CAB")
			If !ExecBlock("MT140CAB",.F.,.F.)
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	If lContinua
		//��������������������������������������������������������������Ŀ
		//� Calculo do total do pre-documento de entrada                 �
		//����������������������������������������������������������������
		Ma140Total(a140Total,a140Desp)

		//��������������������������������������������������������������Ŀ
		//� Rotina automatica                                            �
		//����������������������������������������������������������������
		If l140Auto
			nOpcA := 1
			If !l140Exclui
				aValidGet := {}
				If l140Inclui
					PRIVATE aBlock := {	{|| NfeTipo(cTipo,@cA100For,@cLoja)},;
						{|| NfeFormul(cFormul,@cNFiscal,@cSerie)},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3("F1_DOC")},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3("F1_SERIE")},;
						{|| CheckSX3("F1_EMISSAO") .And. NfeEmissao(dDEmissao)},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3('F1_FORNECE',cA100For)},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3('F1_LOJA',cLoja)},;
						{|| CheckSX3("F1_ESPECIE",cEspecie)},;
						{|| CheckSX3("F1_EST",cUfOrigP) .And. CheckSX3("F1_EST",cUfOrigP)}}
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_TIPO"}))<>0
						aadd(aValidGet,{"cTipo",aAutoCab[(nX),2],"Eval(aBlock[1])",.T.})
					Else
						cTipo := "N"
					EndIf
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_FORMUL"}))<>0
						aadd(aValidGet,{"cFormul",aAutoCab[(nX),2],"Eval(aBlock[2])",.T.})
					Else
						cFormul := "N"
					EndIf
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_DOC"})
					aadd(aValidGet,{"cNFiscal" ,aAutoCab[(nX),2],"Eval(aBlock[3])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_SERIE"})
					aadd(aValidGet,{"cSerie",aAutoCab[(nX),2],"Eval(aBlock[4])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_EMISSAO"})
					aadd(aValidGet,{"dDEmissao",aAutoCab[(nX),2],"Eval(aBlock[5])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_FORNECE"})
					aadd(aValidGet,{"cA100For",aAutoCab[(nX),2],"Eval(aBlock[6])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_LOJA"})
					aadd(aValidGet,{"cLoja",aAutoCab[(nX),2],"Eval(aBlock[7])",.T.})
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_ESPECIE"}))<>0
						aadd(aValidGet,{"cEspecie",aAutoCab[(nX),2],"Eval(aBlock[8])",.T.})
					Else
						cEspecie := ""
					EndIf
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_EST"}))<>0
						aadd(aValidGet,{"cUfOrigP",aAutoCab[(nX),2],"Eval(aBlock[9])",.T.})
					Else
						cUfOrigP := ""
					EndIf
					If ! SF1->(MsVldGAuto(aValidGet))
						nOpcA := 0
					EndIf
				EndIf
				If GetMV("MV_INTPMS",,"N") == "S" .And. GetMV("MV_PMSIPC",,2) == 1 //Se utiliza amarracao automatica dos itens da NFE com o Projeto
					For nX := 1 To Len(aAutoItens)
						If nX == 1
							aAdd(aAutoItens[nX],{"D1_ITEM","000"+AllTrim(Str(nX)),NIL})
						Else
							aAdd(aAutoItens[nX],{"D1_ITEM",Soma1(aAutoItens[nX-1][Len(aAutoItens[nX-1])][2]),Nil})
						EndIf
						PMS140IPC(Val(aAutoItens[nX][aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})][2]))					
					Next nX
				EndIf
				If nOpcA <> 0 
					If nMostraTela <> 2
				  		If !SD1->(MsGetDAuto(aAutoItens,"Ma140LinOk",{|| Ma140TudOk()},aAutoCab,aRotina[nOpcX][4]))
				  			nOpcA := 0
				  		EndIf
	        		EndIf
				EndIf
				If nMostraTela <> 0 .And. nOpca <> 0
					l140Auto := .F.
					nOpca    := 0
					HelpInDark(.F.)
				EndIf
			EndIf
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Interface com o Usuario                                      �
		//����������������������������������������������������������������
		If !l140Auto
			aSizeAut := MsAdvSize(,.F.,400)
			aObjects := {}
			aadd( aObjects, { 0,    41, .T., .F. } )
			aadd( aObjects, { 100, 100, .T., .T. } )
			aadd( aObjects, { 0,    75, .T., .F. } )
			aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects )
			aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
				{{8,35,75,100,194,220,260,280},;
				If( l140Visual .Or. !lConsMedic,{8,35,75,100,nPosGetLoja,194,220,260,280},{8,35,75,108,145,160,190,220,244,265} ),;
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,75,103,148,164,230,253},;
				{6,34,200,218,280},;
				{11,50,150,190},;
				{273,130,190,293,205}})

			DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro Of oMainWnd PIXEL

			NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l140Visual .Or. l140Altera,.F.,@cUfOrigP,,.T.,nil,nil,nil,nil,@lNfMedic)

			oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"Ma140LinOk","Ma140TudOk","+D1_ITEM",!l140Visual,,,,9999,"A140FldOk",,,"Ma140DelIt")
			oGetDados:oBrowse:bGotFocus	:= bCabOk

			oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
			//��������������������������������������������������������������Ŀ
			//� Folder dos Totalizadores                                     �
			//����������������������������������������������������������������
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			NfeFldTot(oFolder:aDialogs[1],a140Total,aPosGet[3],@aFldCBAtu[1])
			//��������������������������������������������������������������Ŀ
			//� Folder dos Fornecedores                                      �
			//����������������������������������������������������������������
			oFolder:aDialogs[2]:oFont := oDlg:oFont
			oFolder:bSetOption := {|nDst| NfeFldChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}
			NfeFldFor(oFolder:aDialogs[2],aInfForn,{aPosGet[4],aPosGet[5],aPosGet[6]},@aFldCBAtu[2])
			//��������������������������������������������������������������Ŀ
			//� Folder das Despesas acessorias e descontos                   �
			//����������������������������������������������������������������
			oFolder:aDialogs[3]:oFont := oDlg:oFont
			NfeFldDsp(oFolder:aDialogs[3],a140Desp,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			//��������������������������������������������������������������Ŀ
			//� Folder de conferencia para os coletores                      �
			//����������������������������������������������������������������
			If l140Visual .And. (((SA2->(FieldPos('A2_CONFFIS'))>0) .And. (((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "1") .Or. SA2->A2_CONFFIS == "1") ;
			.And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S")) .Or. ;
			(cTipo == "B" .And. (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. (SuperGetMV("MV_TPCONFF",.F.,"1") == "1")))
				oFolder:aDialogs[4]:oFont := oDlg:oFont
				Do Case
				Case SF1->F1_STATCON $ "1 "
					cStatCon := STR0014 //"NF conferida"
				Case SF1->F1_STATCON == "0"
					cStatCon := STR0015 //"NF nao conferida"
				Case SF1->F1_STATCON == "2"
					cStatCon := STR0016 //"NF com divergencia"
				Case SF1->F1_STATCON == "3"
					cStatCon := STR0017 //"NF em conferencia"
				Case SF1->F1_STATCON == "4"
					cStatCon := "NF Clas. C/ Diver." 
				EndCase
				nQtdConf := SF1->F1_QTDCONF
				@ 06 ,aPosGet[6,1] SAY STR0018      OF oFolder:aDialogs[4] PIXEL SIZE 49,09 //"Status"
				@ 05 ,aPosGet[6,2] MSGET oStatCon VAR Upper(cStatCon) COLOR CLR_RED OF oFolder:aDialogs[4] PIXEL SIZE 70,9 When .F.
				@ 25 ,aPosGet[6,1] SAY STR0019 OF oFolder:aDialogs[4] PIXEL SIZE 49,09 //"Conferentes"
				@ 24 ,aPosGet[6,2] MSGET oConf Var nQtdConf OF oFolder:aDialogs[4] PIXEL SIZE 70,09 When .F.
				@ 05 ,aPosGet[5,3] LISTBOX oList Fields HEADER "  ",STR0020,STR0021 SIZE 170, 48 OF oFolder:aDialogs[4] PIXEL //"Codigo"###"Quantidade Conferida"
				oList:BLDblclick := {||A140DetCon(oList,aListBox)}

				DEFINE TIMER oTimer INTERVAL 3000 ACTION (A140AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,,oTimer)) OF oDlg
				oTimer:Activate()

				@ 30 ,aPosGet[5,3]+180 BUTTON STR0022 SIZE 40 ,11  FONT oDlg:oFont ACTION (A140AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,.T.,oTimer)) OF oFolder:aDialogs[4] PIXEL When SF1->F1_STATCON == '2' //"Recontagem"
				@ 42 ,aPosGet[5,3]+180 BUTTON STR0023 SIZE 40 ,11  FONT oDlg:oFont ACTION (A140DetCon(oList,aListBox)) OF oFolder:aDialogs[4] PIXEL //"Detalhes"

				A140AtuCon(oList,aListBox,oEnable,oDisable)
			EndIf

			ACTIVATE MSDIALOG oDlg ON INIT Ma140Bar(oDlg,{||If(oGetDados:TudoOk().And.NfeNextDoc(@cNFiscal,@cSerie,l140Inclui),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||oDlg:End()},IIF(l140Altera .Or. l140Visual,aButVisual,aButtons))
		EndIf 
		
		//���������������������������������������������������Ŀ
		//  FSW - 05/05/2011 - Rotina Exclui Divergencias
		//�����������������������������������������������������
		If lPrjCni		
            If l140Exclui
               IF  Empty(SF1->F1_STATUS)
                   CA040EXC()
               Endif         
            Endif
	    EndIf


		//���������������������������������������������������Ŀ
		//� Integracao com o ACD			  				  �
		//�����������������������������������������������������
		If l140Exclui .And. lIntACD .And. FindFunction("CBA140EXC") 
			nOpcA := IIF(CBA140EXC(),nOpcA,0)
		//�����������������������������������������������������Ŀ
		//�Template acionando Ponto de Entrada                  �
		//�������������������������������������������������������
		ElseIf l140Exclui .And. nOpcA == 1 .And. ExistTemplate("A140EXC")
			nOpcA := IIF(ExecTemplate("A140EXC",.F.,.F.),nOpcA,0)
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada para validar a exclusao de um pre-documento �
		//����������������������������������������������������������������
		If l140Exclui .And. nOpcA == 1 .And. ExistBlock("A140EXC")
			nOpcA := IIF(ExecBlock("A140EXC",.F.,.F.),nOpcA,0)
		EndIf     
		
		//FSW - Fazer ponto de entrada para validacao da inclusao da pre nota
		If lPrjCni
			If (l140Inclui .OR. l140Altera) .And. nOpcA == 1 
			   U_CM120GR (@nOpcA) 
			EndIf
		EndIf


		//��������������������������������������������������������������Ŀ
		//� Atualizacao do pre-documento de entrada                      �
		//����������������������������������������������������������������
		If nOpcA == 1 .AND. ( l140Inclui .OR. l140Altera .OR. l140Exclui ) .AND. ( Type( "lOnUpDate" ) == "U" .OR. lOnUpdate )
			Ma140Grava( l140Exclui, aRecSD1, a140Desp )
		ElseIf l140Auto
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FILIAL" } ) ) > 0
				aAutoCab[nPos][2] := xFilial( "SF1" )
			Else
				AAdd( aAutoCab, { "F1_FILIAL", xFilial( "SF1" ), NIL } )
			Endif

			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DOC" } ) ) > 0
				aAutoCab[nPos][2] := cNFiscal
			Else
				AAdd( aAutoCab, { "F1_DOC", cNFiscal, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_SERIE" } ) ) > 0
				aAutoCab[nPos][2] := cSerie
			Else
				AAdd( aAutoCab, { "F1_SERIE", cSerie, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FORNECE" } ) ) > 0
				aAutoCab[nPos][2] := cA100For
			Else
				AAdd( aAutoCab, { "F1_FORNECE", cA100For, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_LOJA" } ) ) > 0
				aAutoCab[nPos][2] := cLoja
			Else
				AAdd( aAutoCab, { "F1_LOJA", cLoja, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_EMISSAO" } ) ) > 0
				aAutoCab[nPos][2] := dDEmissao
			Else
				AAdd( aAutoCab, { "F1_EMISSAO", dDEmissao, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_EST" } ) ) > 0
				aAutoCab[nPos][2] := IIF( cTipo $ "DB", SA1->A1_EST, SA2->A2_EST )
			Else
				AAdd( aAutoCab, { "F1_EST", IIF( cTipo $ "DB", SA1->A1_EST, SA2->A2_EST ), NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_TIPO" } ) ) > 0
				aAutoCab[nPos][2] := cTipo
			Else
				AAdd( aAutoCab, { "F1_TIPO", cTipo, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DTDIGIT" } ) ) > 0
				aAutoCab[nPos][2] := dDataBase
			Else
				AAdd( aAutoCab, { "F1_DTDIGIT", dDataBase, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_RECBMTO" } ) ) > 0
				aAutoCab[nPos][2] := SF1->F1_DTDIGIT
			Else
				AAdd( aAutoCab, { "F1_RECBMTO", SF1->F1_DTDIGIT	, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FORMUL" } ) ) > 0
				aAutoCab[nPos][2] := IIF( cFormul == "S", "S", " " )
			Else
				AAdd( aAutoCab, { "F1_FORMUL", IIF( cFormul == "S", "S", " " ), NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_ESPECIE" } ) ) > 0
				aAutoCab[nPos][2] := cEspecie
			Else
				AAdd( aAutoCab, { "F1_ESPECIE", cEspecie, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DESPESA" } ) ) > 0
				aAutoCab[nPos][2] := a140Desp[VALDESP]
			Else
				AAdd( aAutoCab, { "F1_DESPESA", a140Desp[VALDESP], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FRETE" } ) ) > 0
				aAutoCab[nPos][2] := a140Desp[FRETE]
			Else
				AAdd( aAutoCab, { "F1_FRETE", a140Desp[FRETE], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_SEGURO" } ) ) > 0
				aAutoCab[nPos][2] := a140Desp[SEGURO]
			Else
				AAdd( aAutoCab, { "F1_SEGURO", a140Desp[SEGURO]	, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_VALMERC" } ) ) > 0
				aAutoCab[nPos][2] := a140Total[VALMERC]
			Else
				AAdd( aAutoCab, { "F1_VALMERC", a140Total[VALMERC], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DESCONT" } ) ) > 0
				aAutoCab[nPos][2] := a140Total[VALDESC]
			Else
				AAdd( aAutoCab, { "F1_DESCONT", a140Total[VALDESC], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_VALBRUT" } ) ) > 0
				aAutoCab[nPos][2] := a140Total[TOTPED]
			Else
				AAdd( aAutoCab, { "F1_VALBRUT", a140Total[TOTPED], NIL } )
			Endif
	
			aAutoItens := MsAuto2Gd( aHeader, aCols )
		EndIf
	EndIf
EndIf
//��������������������������������������������������������������Ŀ
//� Destrava os registros na alteracao e exclusao                �
//����������������������������������������������������������������
MsUnlockAll()
If !l140Auto .And. lContinua
	SetKey( VK_F5, Nil )
	SetKey( VK_F6, Nil )
	SetKey( VK_F10, Nil )
ElseIf !lContinua
	SetKey( VK_F10, Nil )
EndIf
If lPrjCni
	If  Type("_aDivPNF") != "U"
		_aDivPNF := {}
	Endif   
Endif

If ExistTemplate( "MT140SAI" ) .And. lContinua
	ExecTemplate( "MT140SAI", .F., .F., { aRotina[ nOpcx, 4 ], cNFiscal, cSerie, cA100For, cLoja, cTipo, nOpcA } )
EndIf


//�������������������������������������������������������������������������������������������������Ŀ
//� O ponto de entrada e disparado apos o RestArea pois pode ser utilizado para posicionar o Browse �
//���������������������������������������������������������������������������������������������������
If ExistBlock( "MT140SAI" ) .And. lContinua
	ExecBlock( "MT140SAI", .F., .F., { aRotina[ nOpcx, 4 ], cNFiscal, cSerie, cA100For, cLoja, cTipo, nOpcA } )
EndIf

Return lContinua
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma140LinOk� Autor � Eduardo Riera         � Data �02.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Validacao da Getdados - LinhaOk                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto da getdados                                    ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a linha digitada eh valida                  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo validar um item do pre-documen-���
���          �to de entrada                                                ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function Ma140LinOk()

Local aArea			:= GetArea()
Local lRetorno		:= .T.
Local nPosCod		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})
Local nPosLocal		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOCAL"})
Local nPosQuant		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_QUANT"})
Local nPosVUnit		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_VUNIT"})
Local nPosTotal		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_TOTAL"})
Local nPosPC		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_PEDIDO"})
Local nPosItemPC	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMPC"})
Local nPosLoteCtl	:= aScan(aHeader,{|x|AllTrim(x[2])=="D1_LOTECTL"})
Local nPosLote   	:= aScan(aHeader,{|x|AllTrim(x[2])=="D1_NUMLOTE"})
Local lPCNFE		:= GetNewPar( "MV_PCNFE", .F. ) //-- Nota Fiscal tem que ser amarrada a um Pedido de Compra ?
Local nPosServic	:= aScan(aHeader, {|x|Upper(Alltrim(x[2]))=='D1_SERVIC'})  
Local lMT140PC
Local nPosOp     	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_OP"})

Local dDTULMES := CTOD("") //Data do Ultimo Fechamento do Estoque

//����������������������������������Ŀ
//� Verifica a permissao do armazem. �
//������������������������������������
If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
	lRetorno := MaAvalPerm(3,{aCols[n][nPosLocal],aCols[n][nPosCod]})
EndIf 

//��������������������������������������������������������������������������������������������������������������������������Ŀ
//� Ponto de Entrada para o tratamento do par�metro MV_PCNFE (Nota Fiscal tem que ser amarrada a um Pedido de Compra ?)      �
//����������������������������������������������������������������������������������������������������������������������������
If lRetorno .And. (ExistBlock("MT140PC"))  
	lMT140PC  := ExecBlock("MT140PC",.F.,.F.,{lPCNFE})    
	If ( ValType(lMT140PC ) == 'L' )
		lPCNFE := lMT140PC 
	EndIf
EndIf     

//����������������������������������������������������������Ŀ
//� Verifica preenchimento dos campos da linha do acols      �
//������������������������������������������������������������
If lRetorno .And. CheckCols(n,aCols)
	If !aCols[n][Len(aCols[n])]
		//�������������������������������������������������������������Ŀ
		//� Quando Informado Armazem em branco considerar o B1_LOCPAD   �
		//���������������������������������������������������������������
		If Empty(aCols[n][nPosLocal])
			SB1->(dbSetOrder(1))
				If SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosCod]))
				aCols[n][nPosLocal] := SB1->B1_LOCPAD
				If Type("l140Auto") <> "U" .And. !l140Auto
					Aviso(OemToAnsi(STR0035),OemToAnsi(STR0053),{"Ok"}) //Atencao##O Armazem informado e Invalido, o campo sera ajustando com o armazem padr�o do cadastro de produtos
				EndIf	
			EndIf
		EndIf
		//�����������������������������������������������������Ŀ
		//� Verifica se o produto est� sendo inventariado.      �
		//�������������������������������������������������������
		Do Case
		Case Empty(aCols[n][nPosCod]) .Or. ;
				(Empty(aCols[n][nPosQuant]).And.cTipo$"NDB").Or. ;
				Empty(aCols[n][nPosVUnit]) .Or. ;
				Empty(aCols[n][nPosTotal])
			Help("  ",1,"A140VZ")
			lRetorno := .F.			
		Case nPosPC > 0 .And. !Empty(aCols[n][nPosPc]) .And. Empty(aCols[n][nPosItemPC])
			Help("  ",1,"A140PC")
			lRetorno := .F.			
		Case cPaisLoc <> "BRA".AND.cTipo <> "C" .And.;
				Round(aCols[n][nPosVUnit]*aCols[n][nPosQuant],SuperGetMV("MV_RNDLOC",.F.,2)) <> Round(aCols[n][nPosTotal],SuperGetMV("MV_RNDLOC",.F.,2))
			HELP(" ",1,"A100Valor")
			lRetorno := .F.			
		Case cTipo$'NDB' .And. (aCols[n][nPosTotal]>(aCols[n][nPosVUnit]*aCols[n][nPosQuant]+0.49);
		                   .Or. aCols[n][nPosTotal]<(aCols[n][nPosVUnit]*aCols[n][nPosQuant]-0.49))
			Help("  ",1,'TOTAL')
			lRetorno := .F.			
		Case !A103Alert(Acols[n][nPosCod],aCols[n][nPosLocal],l140Auto)
			lRetorno := .F.
		Case cTipo = 'N' .And. lPCNFE	 .And. Empty(aCols[n,nPosPC])
  		    If l140Auto .And. IsTransFil()   // Quando for Rotina Automatica e Transf.Filiais, ignora parametro pedido de compras 
  		       lRetorno := .T.
  		    else 
	   		   Aviso(OemToAnsi(STR0035),OemToAnsi(STR0036),{OemToAnsi(STR0037)}, 2 ) //-- "Atencao"###"Informe o No. do Pedido de Compras ou verifique o conteudo do parametro MV_PCNFE"###"Ok"
			   lRetorno := .F.
		    EndIf
		Case nPosCod>0 .And. nPosLoteCtl>0 .And. nPosLote>0 .And. (Rastro(aCols[n][nPosCod],"N")) .And. (!Empty(aCols[n][nPosLoteCtl]) .Or. !Empty(aCols[n][nPosLote]))
			Help(" ",1,"NAORASTRO")
			lRetorno := .F.		
		OtherWise
			lRetorno := .T.
		EndCase
		
		//�����������������������������������������������������������������Ŀ
		//� Valida o preenchimento dos campos referentes ao WMS             �
		//�������������������������������������������������������������������
		If	lRetorno .And. nPosServic > 0 .And. !Empty(aCols[n, nPosServic])
			lRetorno := A103WMSOk()
			//- Valida o Servico digitado na pre-nota, que deve ser de Conferencia.
			If	lRetorno
				//-- Valida o Servico digitado na pre-nota, que deve ser de Conferencia.
				If	!WmsVldSrv('5',aCols[n,nPosServic])
					Aviso(OemToAnsi(STR0035), STR0055, {'Ok'}) //'Somente Servicos WMS de Conferencia podem ser utilizados.'
					lRetorno := .F.
				EndIf
			EndIf
		EndIf

		//�����������������������������������������������������������������Ŀ
		//� Verifica se Produto x Fornecedor foi Bloquedo pela Qualidade.   �
		//�������������������������������������������������������������������
		If lRetorno
			lRetorno := QieSitFornec(cA100For,cLoja,aCols[n][nPosCod],.T.)
		EndIf

		//������������������������������������������������Ŀ
		//� Verifica se Ordem de Produ��o est� encerrada   �
		//��������������������������������������������������
		If lRetorno
			If !Empty(aCols[n][nPosOp]) .And. (!SC2->(dbSeek(xFilial("SC2")+aCols[n][nPosOp])) .Or. !Empty(SC2->C2_DATRF))
				lRetorno := .F.
			EndIf
			
			//�����������������������������������������������������Ŀ
			//� Integracao com SIGAMNT - NG Informatica             �
			//�������������������������������������������������������
			SC2->(dbSetOrder(1))
			If SC2->(dbSeek(xFilial("SC2")+aCols[n][nPosOp])) .And. !Empty(SC2->C2_DATRF)
				If SuperGetMV("MV_NGMNTES",.F.,"N") == "S" .And. SuperGetMV("MV_NGMNTPC",.F.,"N") == "S" .And. !Empty(aCols[n][nPosOp])
					lRetorno := .T.
					
					dDTULMES := SuperGetMV("MV_ULMES",.F.,CTOD(""))
					If !Empty(dDTULMES) .and. SC2->C2_DATRF <= dDTULMES
						lRetorno := .F.
					EndIf
				EndIf
			EndIf
			
			If !lRetorno
				Help(" ",1,"A100OPEND")
			EndIf
		EndIf

	Else
		lRetorno := .T.
	EndIf
Else
	lRetorno := .F.
EndIf

//����������������������������������������������������������Ŀ
//� Refresh do rodape do pre-documento de entrada            �
//������������������������������������������������������������
Eval(bRefresh)

//����������������������������������������������������������Ŀ
//� Executa os pontos de entrada da Linha Ok                 �
//������������������������������������������������������������
If lRetorno .And. ExistTemplate("MT140LOK")
	lRetorno := ExecTemplate("MT140LOK",.F.,.F.,{lRetorno,a140Total,a140Desp})
EndIf

If lRetorno .And. ExistBlock("MT140LOK")
	lRetorno := ExecBlock("MT140LOK",.F.,.F.,{lRetorno,a140Total,a140Desp})
EndIf

RestArea(aArea)
Return lRetorno
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma140TudOk� Autor � Eduardo Riera         � Data �02.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Validacao da Getdados - TudoOk                               ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto da getdados                                    ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se todos os itens sao validos                  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo validar todos os itens do pre- ���
���          �-documento de entrada                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MA140Tudok()

Local lRetorno     := .T.
Local lTudoDel     := .T.
Local nX           := 0   
Local nPosMed      := GDFieldPos( "D1_ITEMMED" ) 

Local lItensMed    := .F. 
Local lItensNaoMed := .F.                

Local aMT140GCT    := {}

//����������������������������������������������������������Ŀ
//� Verifica preenchimento dos campos do cabecalho           �
//������������������������������������������������������������
If Empty(ca100For) .Or. Empty(dDEmissao) .Or. Empty(cTipo) .Or. (Empty(cNFiscal).And.cFormul!="S")
	Help(" ",1,"A100FALTA")
	lRetorno := .F.
EndIf
//����������������������������������������������������������Ŀ
//� Verifica se existem itens a serem gravados               �
//������������������������������������������������������������
For nX :=1 to Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		lTudoDel := .F.     
		If !Empty( nPosMed ) 		
			//�������������������������������������������������������������������������������������Ŀ
			//� Verifica a existencia de itens de medicao junto com itens sem medicao               �
			//���������������������������������������������������������������������������������������
			lItensMed    := lItensMed .Or. aCols[ nX, nPosMed ] == "1" 
			lItensNaoMed := lItensNaoMed .Or. aCols[ nX, nPosMed ] $ " |2"

			//�������������������������������������������������������������������������������������Ŀ
			//� Ponto de entrada permite incluir itens n�o-pertinentes ao gct ou n�o.               �
			//���������������������������������������������������������������������������������������
			If (ExistBlock("MT140GCT"))
				aMT140GCT := ExecBlock("MT140GCT",.F.,.F.,{aCols,nX,nPosMed}) 
				
				If ValType(aMT140GCT) == "A" 
					If Len(aMT140GCT) >= 1 .And. ValType(aMT140GCT[1]) == "L"
						lItensMed    := aMT140GCT[1]
					EndIf
					If Len(aMT140GCT) >= 2 .And. ValType(aMT140GCT[2]) == "L" 
						lItensNaoMed := aMT140GCT[2]
					EndIf	 
				EndIf  
			EndIf	  
			
			If lItensMed .And. lItensNaoMed
				Help( " ", 1, "A103MEDIC" ) 
				lRetorno := .F. 		
				Exit
			EndIf 
		EndIf 	
	
	Endif
Next nX
If lTudoDel
	Help(" ",1,"A140TUDDEL")
	lRetorno := .F.
EndIf
//����������������������������������������������������������Ŀ
//� Chamada do Ponto de entrada para validacao da TudoOk     �
//������������������������������������������������������������
If lRetorno .And. ExistBlock("MT140TOK")
	lRetorno := ExecBlock("MT140TOK",.F.,.F.,{lRetorno})
EndIf
Return lRetorno
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma140Bar  � Prog. � Sergio Silveira       �Data  � 23/02/2001���
��������������������������������������������������������������������������Ĵ��
���          � Construcao da EnchoiceBar do pre-documento de entrada       ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto dialog                                       ���
���          � ExpB2 = Code block de confirma                              ���
���          � ExpB3 = Code block de cancela                               ���
���          � ExpA4 = Array com botoes ja incluidos.                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � Devolve o retorno da enchoicebar                            ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo criar a barra de botoes denomi-���
���          �nada EnchoiceBar                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function Ma140Bar(oDlg,bOk,bCancel,aButtonsAtu)

Local aUsButtons := {}
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

//�������������������������������������������������������Ŀ
//  FSW - 05/05/2011 - Implementa no menu da EnchoiceBar 
//���������������������������������������������������������
If lPrjCni
	If !Inclui
		aadd(aButtonsAtu,{"BUDGET",   {|| _A140Posic()},"Consulta Aprovacao","Consulta historico de aprovacao da NF" })
	EndIf
	
	aadd(aButtonsAtu,{"BUDGET",   {|| _MA140Div1()},"Cadastro de divergencias","Divergencias" })
EndIf


//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "MA140BUT" )
	If ValType( aUsButtons := ExecBlock( "MA140BUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| aadd( aButtonsAtu, x ) } )
	EndIf
EndIf

Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtonsAtu))

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma140Total� Prog. � Sergio Silveira       �Data  � 23/02/2001���
��������������������������������������������������������������������������Ĵ��
���          � Calculo do total do pre-documento de entrada                ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1: Array com os totais do pre-documento de entrada      ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo calcular os totais do pre-docum���
���          �ento de entrada                                              ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function Ma140Total(aTotal,aDespesa, nTotal, nValDesc)

Local nUsado   := Len(aHeader)
Local nMaxFor  := Len(aCols)
Local lDeleted := .F.
Local nPTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPValDesc:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Local nX       := 0

Default nTotal 		:= 0
Default nValDesc 	:= 0

If Len(aCols)> 0
	For nX := 1 To Len(aCols)
		If aCols[nX][Len(aCols[1])]
			lDeleted := .T.
			Exit
		EndIf
	Next nX
EndIf

aTotal := aFill(aTotal,0)
aDespesa[VALDESC] := 0
For nX := 1 To nMaxFor
	If !lDeleted .Or. !aCols[nX][nUsado+1]
		If (n==nX)
			aTotal[VALMERC] 	+= 	Iif (nTotal<>0, nTotal, aCols[nX][nPTotal])
			aTotal[VALDESC] 	+= 	Iif (nValDesc<>0, nValDesc, aCols[nX][nPValDesc])
			aTotal[TOTPED ] 	+= 	Iif (nTotal<>0, nTotal, aCols[nX][nPTotal]) - Iif (nValDesc<>0, nValDesc, aCols[nX][nPValDesc])
			aDespesa[VALDESC]	+=	Iif (nValDesc<>0, nValDesc, aCols[nX][nPValDesc])
						
		ElseIf ((nTotal==0) .Or. (n<>nX))
			aTotal[VALMERC] 	+= 	aCols[nX][nPTotal]			
			aTotal[VALDESC] 	+= 	aCols[nX][nPValDesc]
			aTotal[TOTPED ] 	+= 	aCols[nX][nPTotal] - aCols[nX][nPValDesc]
			aDespesa[VALDESC]	+=	aCols[nX][nPValDesc]
		EndIf
	EndIf
Next nX
aTotal[TOTPED ] += aDespesa[FRETE] + aDespesa[VALDESP] + aDespesa[SEGURO]
Return(.T.)
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma140Grava� Autor � Eduardo Riera         � Data �03.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de atualizacao do pre-documento de entrada            ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1: Indica se a operacao eh de exclusao                   ���
���          �ExpA1: Array com os recnos do SD1                            ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se houve atualizacao                           ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo atualizar um pre-documento de  ���
���          �entrada e seus anexos                                        ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function Ma140Grava(lExclui,aRecSD1,aDespesa)

Local aArea    := GetArea("SF1")
Local aPCMail  := {}
Local nX       := 0
Local nY       := 0
Local nMaxFor  := Len(aCols)
Local nUsado   := Len(aHeader)
Local nSaveSX8 := GetSX8Len()
Local lTravou  := .F.
Local lGrava   := .F.
Local cItem    := StrZero(0,Len(SD1->D1_ITEM))
Local cGrupo   := SuperGetMv("MV_NFAPROV")
Local lGeraBlq := .F.
Local nI       := 0
Local nJ       := 0
Local nPosServic := aScan(aHeader, {|x|Upper(Alltrim(x[2]))=='D1_SERVIC'})
Local nDecimalPC:= TamSX3("C7_PRECO")[2] 

Local _cSolicit := ""
Local _cGrupo   := GetNewPar("MV_XAPR_NF","PRENOT")
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local aComa080 := {}

//-- Variaveis utilizadas pela funcao wmsexedcf
Local nPosDCF	:= 0
Local cTipoNf   := SuperGetMv("MV_TPNRNFS")
Private aLibSDB	:= {}
Private aWmsAviso:= {}
//--

l140Auto := !(Type("l140Auto")=="U" .Or. !l140Auto)

//��������������������������������������������������������������Ŀ
//� Verifica o grupo de aprovacao do Comprador.                  �
//����������������������������������������������������������������
dbSelectArea("SAL")
dbSetOrder(3)
If MsSeek(xFilial("SAL")+RetCodUsr())
	cGrupo := If(!Empty(SY1->Y1_GRAPROV),SY1->Y1_GRAPROV,cGrupo)
EndIf
//��������������������������������������������������������������Ŀ
//� Ponto de entrada para alterar o Grupo de Aprovacao.          �
//����������������������������������������������������������������
If ExistBlock("MT140APV")
	cGrupo := ExecBlock("MT140APV",.F.,.F.,{cGrupo})
EndIf
//cGrupo:= If(Empty(SD1->D1_APROV),cGrupo,SD1->D1_APROV)

//��������������������������������������������������������������Ŀ
//� Verifica se a operacao e de exclusao                         �
//����������������������������������������������������������������
If lExclui
	aEval(aCols,{|x| x[nUsado+1] := .T.})
Else
	aEval(aCols,{|x| lGrava := !x[nUsado+1] .Or. lGrava })
EndIf
//��������������������������������������������������������������Ŀ
//� Posiciona o arquivo de Cliente/Fornecedor                    �
//����������������������������������������������������������������
If cTipo$"DB"
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1")+cA100For+cLoja)
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+cA100For+cLoja)
EndIf
//��������������������������������������������������������������Ŀ
//� Atualizacao do pre-documento de entrada                      �
//����������������������������������������������������������������
For nX := 1 To nMaxFor
	lTravou := .F.
	Begin Transaction
		//��������������������������������������������������������������Ŀ
		//� Atualizacao do cabecalho do pre-documento de entrada         �
		//����������������������������������������������������������������
		If nX == 1 .And. lGrava
			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja+cTipo)
				RecLock("SF1",.F.)
				MaAvalSF1(2)
			Else
				//�������������������������������������������Ŀ
				//� Obtem numero do documento quando utilizar �
				//� numeracao pelo SD9 (MV_TPNRNFS = 3)       �
				//���������������������������������������������	
				If cTipoNf == "3" .AND. cFormul == "S" .AND. cModulo <> "EIC"
					SX3->(DbSetOrder(1))
					If (SX3->(dbSeek("SD9")))
						// Se cNFiscal estiver vazio, busca numeracao no SD9, senao, respeita o novo numero
						// digitado pelo usuario.
						cNFiscal := MA461NumNf(.T.,cSerie,cNFiscal)
					EndIf			
				Endif 
				
				RecLock("SF1",.T.)
				//--Atualiza status da nota para em conferencia
				If ((SA2->(FieldPos('A2_CONFFIS'))>0) .And. ((((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "1") .Or. SA2->A2_CONFFIS == "1") ;
				.And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S")) .Or. ;
				(cTipo == "B" .And. (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. (SuperGetMV("MV_TPCONFF",.F.,"1") == "1")))
					SF1->F1_STATCON := "0"
				EndIf
			EndIf
			SF1->F1_FILIAL := xFilial("SF1")
			SF1->F1_DOC    := cNFiscal
			SF1->F1_SERIE  := cSerie
			SF1->F1_FORNECE:= cA100For
			SF1->F1_LOJA   := cLoja
			SF1->F1_EMISSAO:= dDEmissao
			SF1->F1_EST    := IIF(!Empty(cUfOrigP),cUfOrigP,IIf(cTipo$"DB",SA1->A1_EST,SA2->A2_EST))
			SF1->F1_TIPO   := cTipo
			SF1->F1_DTDIGIT:= IIf(GetMv("MV_DATAHOM",NIL,"1") == "1".Or.Empty(SF1->F1_RECBMTO),dDataBase,SF1->F1_RECBMTO)
			SF1->F1_RECBMTO:= SF1->F1_DTDIGIT
			SF1->F1_FORMUL := IIf(cFormul=="S","S"," ")
			SF1->F1_ESPECIE:= cEspecie
			SF1->F1_DESPESA:= aDespesa[VALDESP]
			SF1->F1_FRETE  := aDespesa[FRETE]
			SF1->F1_SEGURO := aDespesa[SEGURO]
			MaAvalSF1(1)
			If l140Auto
				For nI := 1 To Len(aAutoCab)
					SF1->(FieldPut(FieldPos(aAutoCab[nI][1]),aAutoCab[nI][2]))
				Next nI
			EndIf
			//��������������������������������������������������������������Ŀ
			//� Atualizacao da conferencia fisica                            �
			//����������������������������������������������������������������
			If ((SA2->(FieldPos('A2_CONFFIS'))>0) .And. (((SA2->A2_CONFFIS == "0" .And. SuperGetMV("MV_TPCONFF",.F.,"1") == "1") .Or. SA2->A2_CONFFIS == "1") ;
			.And. SuperGetMV("MV_CONFFIS",.F.,"N") == "S")) .Or. ;
			( cTipo == "D" .And. ;
			  (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .AND. (SuperGetMV("MV_TPCONFF",.F.,"1") == "1"))
				If ExistBlock("MT140ACD")
					ExecBlock("MT140ACD",.F.,.F.)
				EndIf
			EndIf

			//���������������������������������������������������������������������Ŀ
			//� Tratamento da gravacao do SF1 na Integridade Referencial            �
			//�����������������������������������������������������������������������
			SF1->(FkCommit())
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Atualizacao dos itens do pre-documento de entrada            �
		//����������������������������������������������������������������
		If nX <= Len(aRecSD1)
			dbSelectArea("SD1")
			MsGoto(aRecSD1[nX])
			RecLock("SD1")
			If cPaisLoc=="BRA"
				MaAvalSD1(2,"SD1")
			ElseIf cPaisLoc == "ARG"
				If SD1->D1_TIPO_NF == "5"	//Factura Fob
					MaAvalSD1(2,"SD1")
				EndIf
			ElseIf cPaisLoc == "CHI"
				If SD1->D1_TIPO_NF == "9"	//Factura Aduana
					MaAvalSD1(2,"SD1")
				EndIf
			Endif
			lTravou := .T.
		Else
			If !aCols[nX][nUsado+1]	
				RecLock("SD1",.T.)
				lTravou := .T.
			EndIf
		EndIf
		If lTravou
			//�������������������������������������������������������������-Ŀ
			//� Pontos de Entrada 											 �
			//������������������������������������������������������������-���
			If lExclui
				If (ExistTemplate("SD1140E"))
					ExecTemplate("SD1140E",.F.,.F.)
				EndIf
				If (ExistBlock("SD1140E"))
					ExecBlock("SD1140E",.F.,.F.)
				Endif
			EndIf
			//����������������������������������������������������������Ŀ
			//� Estorna o Servico do WMS (DCF)                           �
			//������������������������������������������������������������
			A103EstDCF(.T.)
			If aCols[nX][nUsado+1]
				If cPaisLoc=="BRA"
					MaAvalSD1(3,"SD1")
				ElseIf cPaisLoc == "ARG"
					If SD1->D1_TIPO_NF == "5"	//Factura Fob
						MaAvalSD1(3,"SD1")
					EndIf
				ElseIf cPaisLoc == "CHI"
					If SD1->D1_TIPO_NF == "9"	//Factura Aduana
						MaAvalSD1(3,"SD1")
					EndIf
				Endif
				//-- Incluido condi��o para que seja apagado a SDE correspondente.
				aAreaSDE := GetArea("SD1")
				dbSelectArea("SDE")  
				dbSetOrder(1)
				If (SDE->(MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)))
					While SDE->(!EOF()) .And. (SDE->DE_DOC+SDE->DE_SERIE+SDE->DE_FORNECE+SDE->DE_LOJA+SDE->DE_ITEMNF == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
						RecLock("SDE",.F.)
						SDE->(dbDelete())
						MsUnlock()
						SDE->(dbSkip())
					EndDo
				EndIf
				RestArea(aAreaSDE)				
				//Apaga a SD1
				SD1->(dbDelete())
				//�������������Ŀ
				//� Projeto CNI �
				//���������������
				If lPrjCni
					RSTSCLOG("LPN",2,/*cUser*/)
				EndIf
			Else
				cItem := Soma1(cItem,Len(cItem))
				//��������������������������������������������������������������Ŀ
				//� Atualiza os dados do acols                                   �
				//����������������������������������������������������������������
				For nY := 1 To nUsado
					If aHeader[nY][10] <> "V"
						SD1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				//��������������������������������������������������������������Ŀ
				//� Posiciona registros                                          �
				//����������������������������������������������������������������
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+SD1->D1_COD)

				SC7->(DbSetOrder(1))
				SC7->(MsSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				
				dbSelectArea("SD1")
				SD1->D1_FILIAL	:= xFilial("SD1")
				SD1->D1_FORNECE	:= cA100For
				SD1->D1_LOJA	:= cLoja
				SD1->D1_DOC		:= cNFiscal
				SD1->D1_SERIE	:= cSerie
				SD1->D1_EMISSAO	:= dDEmissao
				SD1->D1_DTDIGIT	:= dDataBase
				SD1->D1_GRUPO	:= SB1->B1_GRUPO
				SD1->D1_TIPO	:= cTipo
				SD1->D1_RATEIO	:= IIF(SC7->(FieldPos("C7_RATEIO"))>0,SC7->C7_RATEIO,"")
				If IntDL() .And. Empty(SD1->D1_NUMSEQ)
					SD1->D1_NUMSEQ := ProxNum()
				EndIf
				SD1->D1_TP		:= SB1->B1_TIPO
				SD1->D1_FORMUL	:= IIf(cFormul=="S","S"," ")
				If Empty(SD1->D1_ITEM)
					SD1->D1_ITEM    := cItem
				EndIf
				SD1->D1_TIPODOC := SF1->F1_TIPODOC
				// Caso o campo exista, significa que tem ACDSTD implantado, sendo necessario iniciar a CONFERENCIA
				If SD1->(FieldPos("D1_QTDCONF")) > 0
					SD1->D1_QTDCONF := 0
				EndIf

				If cPaisLoc != "BRA"
					SD1->D1_ESPECIE	:= cEspecie
					SD1->D1_FORMUL  := SF1->F1_FORMUL
					If l140Auto
						For nJ := 1 To Len(aAutoItens[nX])
							If Subs(aAutoItens[nX][nJ][1],4,6) $ "BASIMP|VALIMP|ALQIMP|TESDES"
								SD1->(FieldPut(FieldPos(aAutoItens[nX][nJ][1]),aAutoItens[nX][nJ][2]))
							EndIf
						Next nJ
					EndIf
					SD1->D1_TES	:= "   "
				EndIf      
				//Caio.Santos - 11/01/13 - Req.72
				If lPrjCni
					RSTSCLOG("LPN",1,/*cUser*/)
				EndIf				
				//-- Incluido condi��o para que seja gravado na SDE o rateio da SCH do pedido que est� vinculado a Pr�-Nota.
				If AliasInDic("SCH")
					aAreaSD1 := GetArea("SD1")
					dbSelectArea("SCH")  
					dbSetOrder(1) // CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM
					If(SCH->(MsSeek(xFilial("SCH")+SD1->D1_PEDIDO+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEMPC)))
						While SCH->(!EOF()) .And. ; 
						(SD1->D1_PEDIDO+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEMPC == SCH->CH_PEDIDO+SCH->CH_FORNECE+SCH->CH_LOJA+SCH->CH_ITEMPD)
							dbSelectArea("SDE")  
							SDE->(dbSetOrder(1)) // DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
							If !(SDE->(MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SCH->CH_FORNECE+SCH->CH_LOJA+SD1->D1_ITEM+SCH->CH_ITEM)))
								RecLock("SDE",.T.)
								SDE->DE_FILIAL 	:= xFilial("SDE")
								SDE->DE_DOC 	:= SD1->D1_DOC
								SDE->DE_SERIE 	:= SD1->D1_SERIE
								SDE->DE_FORNECE := SCH->CH_FORNECE
								SDE->DE_LOJA 	:= SCH->CH_LOJA
								SDE->DE_ITEMNF 	:= SD1->D1_ITEM
								SDE->DE_ITEM 	:= SCH->CH_ITEM
								SDE->DE_PERC 	:= SCH->CH_PERC
								SDE->DE_CC 		:= SCH->CH_CC
								SDE->DE_CONTA 	:= SCH->CH_CONTA
								SDE->DE_ITEMCTA := SCH->CH_ITEMCTA
								SDE->DE_CLVL 	:= SCH->CH_CLVL
								SDE->DE_CUSTO1 	:= SCH->CH_CUSTO1
								SDE->DE_CUSTO2 	:= SCH->CH_CUSTO2
								SDE->DE_CUSTO3 	:= SCH->CH_CUSTO3
								SDE->DE_CUSTO4 	:= SCH->CH_CUSTO4
								SDE->DE_CUSTO5 	:= SCH->CH_CUSTO5					
								SDE->(MsUnLock())
							Endif
							SCH->(dbSkip())
						EndDo
					EndIf
					RestArea(aAreaSD1)
				EndIf

				//so eh necessario q. um item tenha bloqueio, pois o bloqueio eh da NF inteira
				If Empty(SD1->D1_TEC) .And. !lGeraBlq .And. !Empty(SD1->D1_PEDIDO+SD1->D1_ITEMPC) .And. !Empty(cGrupo)
					SC7->(DbSetOrder(1))
					SC7->(MsSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
					lGeraBlq := MaAvalToler(SD1->D1_FORNECE, SD1->D1_LOJA,SD1->D1_COD,SD1->D1_QUANT+SC7->C7_QUJE+SC7->C7_QTDACLA,SC7->C7_QUANT,SD1->D1_VUNIT,xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,,M->dDEmissao,nDecimalPC,SC7->C7_TXMOEDA,))[1]
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
				//��������������������������������������������������������������Ŀ
				//� Ponto de Entrada na Inclusao.                                �
				//����������������������������������������������������������������
				If (ExistBlock("SD1140I"))
					ExecBlock("SD1140I",.F.,.F.,{nx})
				EndIf
				//��������������������������������������������������������������Ŀ
				//� Atualiza array com Pedidos utilizados                        �
				//����������������������������������������������������������������
				If !Empty(SD1->D1_PEDIDO)
					If aScan(aPCMail,SD1->D1_PEDIDO+" - "+SD1->D1_ITEMPC) == 0
						Aadd(aPCMail,SD1->D1_PEDIDO+" - "+SD1->D1_ITEMPC)
					EndIf
				EndIf
				
				//��������������������������������������������������������������Ŀ
				//� Gera os servicos de WMS na inclusao da Pre-Nota              �
				//����������������������������������������������������������������
				If nPosServic > 0 .And. !Empty(aCols[nX, nPosServic])
					CriaDCF('SD1',,,,,@nPosDCF)
					If	!Empty(nPosDCF) .And. WmsVldSrv('4',aCols[nX, nPosServic])
						DCF->(MsGoTo(nPosDCF))
						WmsExeDCF('1',.F.)
					EndIf
				EndIf
				
			EndIf
			//--Verifica se j� foi gerado bloqueio, pois basta o bloqueio de um item para o bloqueio de toda a nota
			If lGeraBlq .And. !SF1->F1_STATUS == "B"
				cGrupo:= If(Empty(SF1->F1_APROV),cGrupo,SF1->F1_APROV)
				If ALTERA .Or. lExclui // Estorna as liberacoes
					MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",SF1->F1_VALBRUT,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,3)
				EndIf
				If !lExclui
					MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",0,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,1)
				EndIf
				dbSelectArea("SF1")
				Reclock("SF1",.F.)
				SF1->F1_STATUS := "B"
				SF1->F1_APROV  := cGrupo
				MsUnlock()
			EndIf
		EndIf

		If nX == nMaxFor .And. !lGrava
			//���������������������������������������������������������������������Ŀ
			//� Tratamento da gravacao do SD1 na Integridade Referencial            �
			//�����������������������������������������������������������������������
			SD1->(FkCommit())

			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja+cTipo)   
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
				MsDocument("SF1", SF1->( RecNo()),2,,3) // Exclui o Banco de Conhecimentos vinculados a Pre-NF
				RecLock("SF1",.F.)
				MaAvalSF1(2)
				MaAvalSF1(3)
				MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",SF1->F1_VALBRUT,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,3)
				
				//A partir da vers�o 11.7
				//Ir� eliminar o documento/Serie/Fornecedor/Loja da confer�ncia embarque no WMS
				//dos documentos de origem de lan�amento que sejam originados MATA140 com F1_ORIGLAN == '  '
				If SF1->F1_ORIGLAN == '  ' .And. GetRpoRelease() >= 'R7' .And. IntDL()
					If FindFunction("WMSExcDoc")
						WmsExcDoc(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
					EndIf
				EndIf
				
				SF1->(dbDelete())
			EndIf
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Executa os gatilhos e a confirmacao do semaforo              �
		//����������������������������������������������������������������
		If nX == nMaxFor
			EvalTrigger()
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSx8()
			EndDo
		EndIf		
	End Transaction
Next nX

If !lExclui .And. lGrava
	//-- Integrado ao wms devera avaliar as regras para convocacao do servico e disponibilizar os 
	//-- registros do SDB para convocacao
	If	IntDL() .And. !Empty(aLibSDB)
		WmsExeDCF('2')
	EndIf
	//����������������������������������������������������������Ŀ
	//� Verifica a existencia de e-mails para o evento 005       �
	//������������������������������������������������������������
	MEnviaMail("005",{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,If(cTipo$"DB",SA1->A1_NOME,SA2->A2_NOME),aPCMail})
	//����������������������������������������������������������Ŀ
	//� Verifica a necessidade da impressao de etiquetas         �
	//������������������������������������������������������������
	If SA2->(FieldPos("A2_IMPIP")) <> 0 .And. SuperGetMV("MV_INTACD",.F.,"0") == "1"
		If (SA2->A2_IMPIP == "2") .Or. (SA2->A2_IMPIP $ "03 " .And. SuperGetMv("MV_IMPIP",.F.,"3") == "2" ) // MV_IMPIP: ACD
			If (!l140Auto .Or. GetAutoPar("AUTIMPIP",aAutoCab,0) == 1) .And. SF1->(FieldPos("F1_STATCON")) > 0 .And. SF1->F1_STATCON <> "1"
				If (FindFunction("ACDI010"))
					ACDI10NF(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,l140Auto)
				Else	
					T_ACDI10NF(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,l140Auto)
				EndIf
			EndIf
		EndIf
	EndIf  
	
	If lPrjCni
	    If ( Empty(SF1->F1_STATUS) .Or. SF1->F1_STATUS == "B" .Or. SF1->F1_STATUS == "C" ) .And. (Inclui .or. Altera)
			If  Len( _aDivPNF ) > 0
				CA040MAN(@_aDivPNF)
			EndIf
	    Endif
	EndIf


	//��������������������������������������������������������������Ŀ
	//� Template Function apos atualizacao de todos os dados inclusao�
	//����������������������������������������������������������������
	If (ExistTemplate("SF1140I"))
		ExecTemplate("SF1140I",.F.,.F.)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Ponto de Entrada apos atualizacao de todos os dados inclusao �
	//����������������������������������������������������������������
	If (ExistBlock("SF1140I"))
		ExecBlock("SF1140I",.F.,.F.)
	EndIf

EndIf    

dbSelectArea("SC7")  
dbSetOrder(1)

RestArea(aArea)
Return(lGrava)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A140AtuCon� Prog. � Fernando Alves        �Data  �15/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza folder de conferencia fisica                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A140ConfPr( ExpO1, ExpA1)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto do list box                                 ���
���          � ExpA2 = Array com o contudo da list box                    ���
���          � ExpO3 = Objeto para flag do list box                       ���
���          � ExpO4 = Objeto para flag do list box                       ���
���          � ExpO5 = Objeto com total de conferentes na nota            ���
���          � ExpN6 = Variavel de quantidade de conferentes              ���
���          � ExpN7 = Objeto com o status da nota                        ���
���          � ExpN8 = Variavel com a descricao do status da nota         ���
���          � ExpL9 = Habilita recontagem na conferencia (limpa o que foi���
���          �         gravado)                                           ���
���          � ExpO10= Objeto timer                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A140AtuCon(oList,aListBox,oEnable,oDisable,oConf,nQtdConf,oStatCon,cStatCon,lReconta,oTimer)

Local aArea     := {}
Local cAliasOld := Alias()

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf
lReconta := If (lReconta == nil,.F.,lReconta)
//���������������������
//�Habilita recontagem�
//���������������������
If lReconta .And. (Aviso(STR0024,STR0025,{STR0026,STR0027}) == 1) //"AVISO"###"Voce realmente quer fazer a recontagem?"###"Sim"###"Nao"
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

MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

While !EOF() .and. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	//��������������������������������������������������������Ŀ
	//�Se for a opcao RECONTAGEM, zera tudo o que foi conferido�
	//����������������������������������������������������������
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
//����������������Ŀ
//�Atualiza os Gets�
//������������������
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
		cStatCon := STR0014 //"NF conferida"
	Case SF1->F1_STATCON == '0'
		cStatCon := STR0015 //"NF nao conferida"
	Case SF1->F1_STATCON == '2'
		cStatCon := STR0016 //"NF com divergencia"
	Case SF1->F1_STATCON == '3'
		cStatCon := STR0017 //"NF em conferencia"
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A140DetCon� Prog. � Eduardo Motta         �Data  �19/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta listbox com dados da conferencia do produto          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A140DetCon(oList,aListBox)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto do list box                                 ���
���          � ExpA2 = Array com o contudo da list box                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A140DetCon(oList,aListBox)
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

DEFINE MSDIALOG oDlgDet TITLE OemToAnsi(STR0028+cCodPro+" "+SB1->B1_DESC) From 0, 0 To 25, 67 OF oMainWnd //"Detalhes de Conferencia do Produto "
oListDet := TWBrowse():New( 02, 2, (oDlgDet:nRight/2)-5, (oDlgDet:nBottom/2)-30,,aColunas,, oDlgDet,,,,,,,,,,,, .F.,, .T.,, .F.,,, )

A140AtuDet(cCodPro,oListDet,aListDet,,aCpoCBE)

@ (oDlgDet:nBottom/2)-25, 005 Say STR0029 PIXEL OF oDlgDet //"Ordem "
@ (oDlgDet:nBottom/2)-25, 025 MSCOMBOBOX oIndice    VAR cIndice    ITEMS aIndice    SIZE 180,09 PIXEL OF oDlgDet
oIndice:bChange := {||CBE->(DbSetOrder(aIndOrd[oIndice:nAt])),A140AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)}
@  (oDlgDet:nBottom/2)-25, (oDlgDet:nRight/2)-50 BUTTON STR0030 SIZE 40,10 ACTION ( oDlgDet:End() ) Of oDlgDet PIXEL // //"&Retorna"

DEFINE TIMER oTimer INTERVAL 1000 ACTION (A140AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)) OF oDlgDet
oTimer:Activate()

ACTIVATE MSDIALOG oDlgDet CENTERED

sRestArea(aArea)
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A140AtuDet� Prog. � Eduardo Motta         �Data  �19/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza array para listbox dos detalhes de conferencia    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A140AtuDet(cCodPro,oListDet,aListDet,oTimer)               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodPro  - Codigo do produto a procurar no CBE             ���
���          � oListDet - Objeto listbox a atualizar                      ���
���          � aListDet - Array do listbox                                ���
���          � oTimer   - Objeto timer a desativar para o processo        ���
���          � aCpoCBE  - Campos do LISTBOX                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A140AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)
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
			If aCpoCBE[nI,1] <> "CBE_NOMUSR"
				uConteudo := CriaVar(aCpoCBE[nI,1])
			Else
				If nI > 1
					uConteudo := RetOpName(aLine[nI - 1])
				Else
					uConteudo := ""
				Endif	
			Endif		
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RetDetLine� Prog. � Eduardo Motta         �Data  �20/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para retornar campos para o bLine do listbox        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RetDetLine(aListDet,nAt)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aListDet - Array com dados do listbox                      ���
���          � nAt      - Linha do listbox                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � A140AtuDet                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetDetLine( aListDet,nAt)
Local aRet := {}
Local nX:= 0
For nX:= 1 to len(aListDet[nAt])
	aadd(aRet,aListDet[nAt,nx])
Next nX
Return aRet

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MyMata140 � Autor � Eduardo Riera         � Data �04.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de teste da rotina automatica do programa MATA140     ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar testes na rotina de    ���
���          �documento de entrada                                         ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
User Function MyMata140()

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.
PRIVATE lMsErroAuto := .F.
//��������������������������������������������������������������Ŀ
//| Abertura do ambiente                                         |
//����������������������������������������������������������������
ConOut(Repl("-",80))
ConOut(PadC(OemToAnsi(STR0039),80)) //"Teste de Inclusao de 100 Pre-documentos com 30 itens cada"
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SF1","SD1","SA1","SA2","SB1","SB2"
//��������������������������������������������������������������Ŀ
//| Verificacao do ambiente para teste                           |
//����������������������������������������������������������������
dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
	lOk := .F.
	ConOut(OemToAnsi(STR0040)) //"Cadastrar produto: PA001"
EndIf
If !SB1->(MsSeek(xFilial("SB1")+"PA002"))
	lOk := .F.
	ConOut(OemToAnsi(STR0041)) //"Cadastrar produto: PA002"
EndIf
dbSelectArea("SA2")
dbSetOrder(1)
If !SA2->(MsSeek(xFilial("SA2")+"F0000101"))
	lOk := .F.
	ConOut(OemToAnsi(STR0042)) //"Cadastrar fornecedor: F0000101"
EndIf
If lOk
	ConOut(OemToAnsi(STR0043)+Time()) //"Inicio: "
	//��������������������������������������������������������������Ŀ
	//| Verifica o ultimo documento valido para um fornecedor        |
	//����������������������������������������������������������������
	dbSelectArea("SF1")
	dbSetOrder(2)
	MsSeek(xFilial("SF1")+"F0000101z",.T.)
	dbSkip(-1)
	cDoc := SF1->F1_DOC
	For nY := 1 To 100
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

		For nX := 1 To 30
			aLinha := {}
			aadd(aLinha,{"D1_COD"  ,"PA001",Nil})
			aadd(aLinha,{"D1_QUANT",1,Nil})
			aadd(aLinha,{"D1_VUNIT",100,Nil})
			aadd(aLinha,{"D1_TOTAL",100,Nil})
			aadd(aLinha,{"D1_CONHEC","CONHEC",Nil})
			aadd(aLinha,{"D1_TEC","TEC",Nil})
			aadd(aLinha,{"D1_VALIMP5",1,Nil})
			aadd(aLinha,{"D1_VALIMP6",2,Nil})
			aadd(aItens,aLinha)
		Next nX
		//��������������������������������������������������������������Ŀ
		//| Teste de Inclusao                                            |
		//����������������������������������������������������������������
		MATA140(aCabec,aItens)
		If !lMsErroAuto
			ConOut(OemToAnsi(STR0044)+cDoc) //"Incluido com sucesso! "
		Else
			ConOut(OemToAnsi(STR0045)) //"Erro na inclusao!"
		EndIf
	Next nY
	ConOut(OemToAnsi(STR0046)+Time()) //"Fim  : "
	//��������������������������������������������������������������Ŀ
	//| Teste de alteracao                                           |
	//����������������������������������������������������������������
	ConOut(PadC(OemToAnsi(STR0047),80)) //"Teste de alteracao"
	ConOut(OemToAnsi(STR0043)+Time()) //"Inicio: "
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

	For nX := 1 To 30
		aLinha := {}
		aadd(aLinha,{"D1_ITEM",StrZero(nX,Len(SD1->D1_ITEM)),Nil})
		aadd(aLinha,{"D1_COD","PA002",Nil})
		aadd(aLinha,{"D1_QUANT",2,Nil})
		aadd(aLinha,{"D1_VUNIT",100,Nil})
		aadd(aLinha,{"D1_TOTAL",200,Nil})
		//aadd(aLinha,{"D1_VALFRE",5,Nil})
		//aadd(aLinha,{"D1_DESPESA",10,Nil})
		//aadd(aLinha,{"D1_SEGURO",15,Nil})
		aadd(aItens,aLinha)
	Next nX
	//��������������������������������������������������������������Ŀ
	//| Teste de alteracao                                           |
	//����������������������������������������������������������������
	MATA140(aCabec,aItens,4)
	If !lMsErroAuto
		ConOut(OemToAnsi(STR0048)+cDoc) //"Alterado com sucesso! "
	Else
		ConOut(OemToAnsi(STR0049)) //"Erro na alteracao!"
	EndIf
	ConOut(OemToAnsi(STR0046)+Time()) //"Fim  : "
	//��������������������������������������������������������������Ŀ
	//| Teste de Exclusao                                            |
	//����������������������������������������������������������������
	ConOut(PadC(OemToAnsi(STR0050),80)) //"Teste de exclusao"
	ConOut(OemToAnsi(STR0043)+Time()) //"Inicio: "
	MATA140(aCabec,aItens,5)
	If !lMsErroAuto
		ConOut(OemToAnsi(STR0051)+cDoc) //"Exclusao com sucesso! "
	Else
		ConOut(OemToAnsi(STR0052)) //"Erro na exclusao!"
	EndIf
	ConOut(OemToAnsi(STR0046)+Time()) //"Fim  : "
	ConOut(Repl("-",80))
EndIf
RESET ENVIRONMENT
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A140Impri � Autor �Alexandre Inacio Lemes� Data �22/03/2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a chamada do relatorio padrao ou do usuario         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpX1 := A140Impri( ExpC1, ExpN1, ExpN2 )                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 -> Alias do arquivo                                  ���
���          � ExpN1 -> Recno do registro                                 ���
���          � ExpN2 -> Opcao do Menu                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpX1 -> Retorno do relatorio                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A140Impri( cAlias, nRecno, nOpc )

Local xRet := a103Impri( cAlias, nRecno, nOpc )

Pergunte("MTA140",.F.)

Return( xRet )
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A140EstCla � Autor �Patricia A. Salomao   � Data �01/08/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Estorno da Classificacao da Nota Fiscal.                    ���
���          �Executa a funcao de exclusao do MATA103;Porem, nao exclui o ���
���          �SD1/SF1;Apenas limpa o conteudo os campos D1_TES e F1_STATUS���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpX1 := A140ExcCla( ExpC1, ExpN1, ExpN2 )                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 -> Alias do arquivo                                  ���
���          � ExpN1 -> Recno do registro                                 ���
���          � ExpN2 -> Opcao Selecionada                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function A140EstCla( cAlias, nRecno, nOpc )

If SF1->F1_STATUS != "A"
    Help("",1,"A140ESTORN")
ElseIf SF1->F1_TIPO $ "NDB"
	A103NFiscal(cAlias,nRecno,5,,.T.)
Else
	Help("",1,"A140NCLASS")
EndIF

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a140Desc   � Autor �Gustavo G. Rueda      � Data �30/03/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para atualizar o valor do DESCONTO no rodapeh quando ���
���          � digitamos o campo D1_DESC ou D1_VALDESC.                   ���
���          �Para atualizar de acordo com o campo:                       ���
���          � - D1_DESC eh necessario criar o seguinte gatilho junto com ���
���          �   padroes do sistema.                                      ���
���          �   X7_CAMPO = D1_DESC                                       ���
���          �   X7_REGRA = M->D1_VALDESC := IIF(A140DESC(M->D1_VALDESC), ���
���          �              M->D1_VALDESC, M-D1_VALDESC)				  ���
���          �   X7_CDOMIN = D1_VALDESC                                   ���
���          � - D1_VALDESC eh necessario inserir a seguinte validacao no ���
���          �   SX3: A140DESC(M->D1_VALDESC)                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A140DESC(nValDesc)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nValDesc -> Valor do desconto do item                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function a140Desc (nValDesc)
	Eval (bRefresh,,,,nValDesc)
Return (.T.)
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ma140DelIt � Autor �Gustavo G. Rueda      � Data �30/03/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para atualizar o valor do DESCONTO e do TOTAL no     ���
���          � rodapeh quando marcamos como deletado determinado item.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ma140DelIt ()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Ma140DelIt ()
Local	aTotal		:=	{0,0,0}
Local	aDespesa	:=	{0,0,0,0,0,0,0,0}
Local 	nPProduto := aScan(aHeader,{|x| Trim(x[2])=="D1_COD"})
Local 	lRet := .T.

Static 	lPermHlp := .F.
	
	//�������������������������������������������������Ŀ
	//�Verifica se o usuario tem permissao de exclusao. �
	//���������������������������������������������������
	If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
		If IsInCallStack("MATA140")
			If !(lRet := MaAvalPerm(1,{aCols[n][nPProduto],"MTA140",5})) .And. !lPermHlp
				Help(,,1,'SEMPERM')
				lPermHlp := .T.
			Else
				lPermHlp := .F.
			EndIf
		EndIf
	EndIf
	If lRet	
		Ma140Total(aTotal,aDespesa)
		Eval (bRefresh)
	EndIf
Return lRet 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �01/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()     
Local aRotAdic := {}  
PRIVATE aRotina	:= {	{ STR0000	,"AxPesqui"		, 0 , 1, 0, .F.},; //"Pesquisar"
						{ STR0001	,"A140NFiscal"	, 0 , 2, 0, nil},; //"Visualizar"
						{ STR0002	,"A140NFiscal"	, 0 , 3, 0, nil},; //"Incluir"
						{ STR0003	,"A140NFiscal"	, 0 , 4, 0, nil},; //"Alterar"
						{ STR0004	,"A140NFiscal"	, 0 , 5, 0, nil},; //"Excluir"
						{ STR0005	,"A140Impri"  	, 0 , 4, 0, nil},; //"Imprimir"
						{ STR0033	,"A140EstCla" 	, 0 , 5, 0, nil},; //"Estorna Classificacao"
						{ STR0006	,"A103Legenda"	, 0 , 2, 0, .F.},; 	//"Legenda"
						{ STR0067 ,"MsDocument", 0 , 4, 0, nil}}	//"Conhecimento"
                              
If FindFunction("FWLSEnable") .And. FindFunction("A140XMLNFe") .And. (FWLSEnable(TOTVS_COLAB_ONDEMAND) .or. FwEmpTeste())
	aAdd(aRotina,{ STR0063	,"A140XMLNFe", 0 , 3, 0, nil}) //"Entrada NF-e"
EndIf

If FindFunction("A103Contr")
	AADD(aRotina,{ OemToAnsi(STR0064),"A103Contr" 	, 0 , 2, 0, nil})//"Rastr.Contrato" 
EndIf
//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("MTA140MNU")
	ExecBlock("MTA140MNU",.F.,.F.)
EndIf
//��������������������������������������������������������������Ŀ
//| Adiciona rotinas ao aRotina                                  |
//����������������������������������������������������������������
If ExistBlock( "MT140ROT" )
	aRotAdic := ExecBlock( "MT140ROT",.F.,.F.)
	If ValType( aRotAdic ) == "A"
		AEval( aRotAdic, { |x| aadd( aRotina, x ) } )
	EndIf
EndIf      
Return(aRotina) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MaCols140 � Autor � Liber De Esteban      � Data � 10/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem do aCols para GetDados.                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MaCols140()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros|-cAliasSD1 ->Alias do SD1.                                  ���
���          �-aRecSD1 -> Array com registros do SD1.                     ���
���          �-bWhileSD1 -> Bloco com condicao para While.                ���
���          �-nCounterSD1 -> Contador de registros do SD1, para o caso de���
���          �nao estar usando query.                                     ���
���          �-lQuery -> Flag de identificacao se esta usando query.      ���
���          �-l140Inclui -> Flag que identifica se operacao e inclusao.  ���
���          �-l140Visual -> Flag que identifica se operacao e inclusao.  ���
���          �-lContinua -> Flag que identifica se deve continuar proc.   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MaCols140(cAliasSD1,bWhileSD1,aRecOrdSD1,aRecSD1,aPedC,lItSD1Ord,lQuery,l140Inclui,l140Visual,lContinua,l140Exclui)
Local nPos		  := 0
Local nPosPc	  := 0
Local nX		  := 0
Local nY 		  := 0
Local nCountSD1 := 1
Local nContDoc  := 0

If !Empty(aHeadSD1)
	aHeader := aClone(aHeadSD1)
EndIf

If l140Inclui
	//��������������������������������������������������������������Ŀ
	//� Faz a montagem de uma linha em branco no aCols.              �
	//����������������������������������������������������������������
	aadd(aCols,Array(Len(aHeader)+1))
	For nY := 1 To Len(aHeader)
		If Trim(aHeader[nY][2]) == "D1_ITEM"
			aCols[1][nY] 	:= StrZero(1,Len((cAliasSD1)->D1_ITEM))
		Else
			If AllTrim(aHeader[nY,2]) == "D1_ALI_WT"
				aCOLS[Len(aCols)][nY] := "SD1"
			ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
				aCOLS[Len(aCols)][nY] := 0
			Else
				aCols[1][nY] := CriaVar(aHeader[nY][2])
			EndIf
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next nY
Else

	While Eval( bWhileSD1 )
	
		If !lQuery .And. (lItSD1Ord .Or. ALTERA)
		
			If nCountSD1 == 1
				//��������������������������������������������������������������Ŀ
				//� Este procedimento eh necessario para fazer a montagem        �
				//� do acols na ordem ITEM + COD quando classificacao em CDX     �
				//� e o parametro MV_PAR03 estiver para ITEM                     �
				//����������������������������������������������������������������
				aRecOrdSD1 := {}
				While ( !Eof().And. lContinua .And. ;
						(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
						(cAliasSD1)->D1_DOC == cNFiscal .And. ;
						(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
						(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
						(cAliasSD1)->D1_LOJA == SF1->F1_LOJA )
	
					AAdd( aRecOrdSD1, { ( cAliasSD1 )->D1_ITEM + ( cAliasSD1 )->D1_COD, ( cAliasSD1 )->( Recno() ) } )
	
					( cAliasSD1 )->( dbSkip() )
	
				EndDo
	
				ASort( aRecOrdSD1, , , { |x,y| y[1] > x[1] } )
	
				bWhileSD1 := { || nCountSD1 <= Len( aRecOrdSD1 ) .And. lContinua  }
			EndIf
			
			If !lQuery .And. (lItSD1Ord .Or. ALTERA)
				SD1->( dbGoto( aRecOrdSD1[ nCountSD1, 2 ] ) )
			EndIf

		EndIf

		If (cAliasSD1)->D1_TIPO == SF1->F1_TIPO
			If Empty((cAliasSD1)->D1_TES)
				//-- Impede a alteracao/exclusao da PreNota com Servico de WMS jah executado
				If	IntDL() .And. (l140Exclui .Or. !l140Visual) .And. FindFunction("WmsChkDCF")
					If	WmsChkDCF("SD1",,,SD1->D1_SERVIC,'3',,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,SD1->D1_COD,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_NUMSEQ,SD1->D1_ITEM)
						Aviso("SIGAWMS",STR0058,{'Ok'}) //"Documento nao pode ser alterado/excluido porque possui servicos de WMS pendentes. Antes estorne estes servicos."
						lContinua := .F.
						Loop
					EndIf
				EndIf
					If lQuery
					aadd(aRecSD1,(cAliasSD1)->SD1RECNO)
				Else
					aadd(aRecSD1,RecNo())
				EndIf

				If !l140Visual
					If !Empty((cAliasSD1)->D1_PEDIDO)
						nPosPC := aScan(aPedC,{|y| y[1] == (cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC})
						If nPosPc > 0
							aPedC[nPosPc,2] += (cAliasSD1)->D1_QUANT
						Else
							aadd(aPedC,{(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC,(cAliasSD1)->D1_QUANT})
						EndIf
					EndIf
				EndIf
				aadd(aCols,Array(Len(aHeader)+1))
				For nY := 1 to Len(aHeader)
					If ( aHeader[nY][10] != "V")
						aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
					Else
						If AllTrim(aHeader[nY,2]) == "D1_ALI_WT"
							aCOLS[Len(aCols)][nY] := "SD1"
						ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
							aCOLS[Len(aCols)][nY] := If(lQuery,(cAliasSD1)->SD1RECNO,(cAliasSD1)->(RecNo()))
						Else
							aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
						EndIf
					EndIf
					aCols[Len(aCols)][Len(aHeader)+1] := .F.
				Next nY
			Else
				SetKey( VK_F6, Nil ) //desativa tecla F6 ao exibir Alert
				Help(" ",1,"A140CLASSI")				
				lContinua := .F.
			EndIf
		EndIf

		//������������������������������������������������������������������Ŀ
		//� Efetua skip na area SD1 ( regra geral ) ou incrementa o contador �
		//� quando ordem por ITEM + CODIGO DE PRODUTO                        �
		//��������������������������������������������������������������������
		If !lQuery .And. (lItSD1Ord .Or. ALTERA)
			nCountSD1++
		Else
			dbSelectArea(cAliasSD1)
			dbSkip()
		EndIf
	EndDo  
	
	//���������������������������������������������������������������������Ŀ
	//� Verifica se h� embarque conferido (DCW)
	//�����������������������������������������������������������������������
	If lContinua .And. GetRpoRelease() >= 'R7' .And. IntDL()
		DCX->( dbSetOrder(2) )
		dbSelectArea('DCX')
		If DCX->( dbSeek(xFilial('DCX')+cNFiscal+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			
			dbSelectArea('DCW')
			DCW->( dbSetOrder(1))
			If DCW->( dbSeek(xFilial('DCW')+DCX->DCX_EMBARQ))
				If DCW->DCW_SITEMB == '3'
					lContinua := .F.
					Help("  ",1,"WMSDCWCONF") //Documento associado a um embarque no WMS j� conferido!
				EndIf
			Else
				// Verifica os documentos do embarque para verificar quantos documentos est�o associados
				dbSelectArea('DCX')
				DCX->( dbSetOrder(1))
				DCX->( dbSeek(xFilial('DCX')+DCW->DCW_EMBARQ))
				While !DCX->( Eof() ) .And.;
					DCX->DCX_FILIAL == xFilial('DCX') .And.; 
			       DCX->DCX_EMBARQ == DCW->DCW_EMBARQ
			       
		         	nContDoc++ 
			       DCX->( dbSkip() )			       
			 	EndDo
			 	//Verifica se documento � o unico do embarque no WMS
				If nContDoc < 2
					lContinua := .F.
					Help("  ",1,"WMSDCWDOC") //Documento � o unico associado a um embarque no WMS, n�o poder� ser excluido! //Efetue a exclus�o do embarque 
				EndIf				
			EndIf
		EndIf	
		DCW->(dbCloseArea())	
		DCX->(dbCloseArea())		
	EndIf	
EndIf

Return 

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �AjustaHelp    � Autor �Turibio Miranda       � Data �23.02.2010���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Ajusta os helps                                                ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   �AjustaHelp()                                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                         ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                         ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
*/
Static Function AjustaHelp()
Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

aHelpPor :=	{"N�o � poss�vel realizar o estorno de","classifica��o para esta nota."}
aHelpSpa :=	{"No es posible realizar la reversion de","clasificacion para esta factura."}
aHelpEng :=	{"Classification reversal is not","possible for this invoice."}
PutHelp("PA140ESTORN",aHelpPor,aHelpEng,aHelpSpa,.F.)    
 
aHelpPor :=	{"O estorno � poss�vel somente para","notas fiscais j� classificadas."}
aHelpSpa :=	{"Solo es posible la reversion para","facturas ya clasificadas."}
aHelpEng :=	{"Classification reversal is possible","only for already classified invoices."}
PutHelp("SA140ESTORN",aHelpPor,aHelpEng,aHelpSpa,.F.) 

Restarea(aArea)
Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A140FldOk � Autor � Allyson B. D. Freitas � Data �09/01/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida permissao de usuarios                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MsGetDados do MATA140                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A140FldOk()
Local cMenVar   := &(ReadVar())
Local cFieldSD1 := ReadVar()
Local cFieldEdit:= SubStr(cFieldSD1,4,Len(cFieldSD1))
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])== "D1_COD"})
Local lEdita    := .T.

If Altera
	//��������������������������������������������������Ŀ
	//�Verifica se o usuario tem permissao de alteracao. �
	//����������������������������������������������������
	If cFieldEdit $ "D1_COD"
		If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
			If !(lEdita := MaAvalPerm(1,{cCampo,"MTA140",5}) .And. MaAvalPerm(1,{aCols[n][nPProduto],"MTA140",3}))
				Help(,,1,'SEMPERM')
			EndIf
		EndIf
	Else
		If (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")
			If !(	lEdita := MaAvalPerm(1,{aCols[n][nPProduto],"MTA140",4}))
				Help(,,1,'SEMPERM')
			EndIf
		EndIf
	EndIf
EndIf
	
Return lEdita   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �_A140Posic� Prog. � TOTVS                 �Data  �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function _A140Posic()
Local aArea		:= GetArea()
Local aSavCols  := {}
Local aSavHead  := {}
Local cHelpApv  := OemToAnsi("Este documento nao possui controle de aprovacao.")
Local cAliasSCR := "TMP"
Local _cDoc     := ""
Local cSituaca  := ""
Local cNumDoc   := ""
Local cStatus   := ""
Local cTitle    := ""
Local cTitDoc   := ""
Local cAddHeader:= ""
Local lBloq     := .F.
Local lQuery    := .F.
Local nSavN		:= 0
Local nX   		:= 0
Local nY        := 0
Local oDlg
Local oGet
Local oBold

aSavCols  := aClone(aCols)
aSavHead  := aClone(aHeader)
nSavN     := N

If !Empty(SF1->F1_APROV)
	cTitle    := "Aprovacao da Nota Fiscal"
	cTitDoc   := "Nota Fiscal"
	cHelpApv  := "Esta nota fiscal nao possui controle de aprovacao."
	cNumDoc   := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	_cDoc     := SF1->(ALltrim(F1_SERIE)+"/"+F1_DOC)
	cStatus   := IIF(SF1->F1_STATUS<>"B",OemToAnsi("LIBERADO"),OemToAnsi("AGUARDANDO LIB."))
EndIf

aHeader:= {}
aCols  := {}

//��������������������������������������������������������������Ŀ
//� Faz a montagem do aHeader com os campos fixos.               �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SCR")
While !Eof() .And. (SX3->X3_ARQUIVO == "SCR")
	IF AllTrim(X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
		AADD(aHeader,{	TRIM(X3Titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT } )
		
		If AllTrim(x3_campo) == "CR_NIVEL"
			AADD(aHeader,{ OemToAnsi("Usuario"),"bCR_NOME",   "",15,0,"","","C","",""} )
			AADD(aHeader,{ OemToAnsi("Situacao"),"bCR_SITUACA","",20,0,"","","C","",""} )
			AADD(aHeader,{ OemToAnsi("Usuario Lib."),"bCR_NOMELIB","",15,0,"","","C","",""} )
		EndIf
		
	Endif
	
	dbSelectArea("SX3")
	dbSkip()
EndDo

ADHeadRec("SCR",aHeader)

aStruSCR := SCR->(dbStruct())
cAliasSCR := GetNextAlias()
cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
cQuery    += "SCR.CR_NUM = '"+Padr(SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),Len(SCR->CR_NUM))+"' AND "
cQuery    += "SCR.CR_TIPO = 'NF' AND "
cQuery    += "SCR.D_E_L_E_T_=' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

For nX := 1 To Len(aStruSCR)
	If aStruSCR[nX][2]<>"C"
		TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
	EndIf
Next nX

dbSelectArea(cAliasSCR)

While !Eof() .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,Len(SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) == xFilial("SCR") + "NF" + cNumDoc
	aadd(aCols,Array(Len(aHeader)+1))
	nY++
	For nX := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nX][2])
			aCols[nY][nX] := IIf(lQuery , (cAliasSCR)->SCRRECNO , SCR->(Recno())  )
		ElseIf IsHeadAlias(aHeader[nX][2])
			aCols[nY][nX] := "SCR"
		ElseIf aHeader[nX][02] == "bCR_NOME"
			aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USER)
		ElseIf aHeader[nX][02] == "bCR_SITUACA"
			Do Case
				Case (cAliasSCR)->CR_STATUS == "01"
					cSituaca := OemToAnsi("Aguardando")
				Case (cAliasSCR)->CR_STATUS == "02"
					cSituaca := OemToAnsi("Em Aprovacao")
				Case (cAliasSCR)->CR_STATUS == "03"
					cSituaca := "Nota Aprovada"
				Case (cAliasSCR)->CR_STATUS == "04"
					cSituaca := "Nota Bloqueada"
					lBloq := .T.
				Case (cAliasSCR)->CR_STATUS == "05"
					cSituaca := OemToAnsi("Nivel Liberado ")
			EndCase
			aCols[nY][nX] := cSituaca
		ElseIf aHeader[nX][02] == "bCR_NOMELIB"
			aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
		ElseIf ( aHeader[nX][10] != "V")
			aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
		EndIf
	Next nX
	aCols[nY][Len(aHeader)+1] := .F.
	dbSkip()
EndDo

If !Empty(aCols)
	If lBloq
		cStatus := "SOLICITA��O BLOQUEADA"
	EndIf
	n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localiza��es
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL
	@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
	@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009
	@ 014,041 MSGET SF1->F1_DOC PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
	@ 132,008 SAY "Situacao :" OF oDlg PIXEL SIZE 052,009 //'Situacao :'
	@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
	@ 132,205 BUTTON "Fechar" SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
	oGet:= MSGetDados():New(038,003,120,250,2,,,"")
	oGet:Refresh()
	@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Aviso("Atencao","Esta nota fiscal n�o possui controle de aprova��o",{"Voltar"})
EndIf

(cAliasSCR)->(dbCloseArea())

aHeader := aClone(aSavHead)
aCols   := aClone(aSavCols)
N		:= nSavN

dbSelectArea("SF1")
RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MA140DIV1 � Prog. � TOTVS                 �Data  �27/04/11  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Selecao de Divergencias da Nota Fiscal Entrada              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
                                                
Static Function _MA140Div1()     
       
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
//| ... utilizando a fun��o aEval()
//+----------------------------------------------------------------
@ 110,10 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos" SIZE 70,7 PIXEL OF oDlg ;
         ON CLICK( aEval( _aDivPNF, {|x| x[1] := lChk1 } ),oLbx:Refresh() )

@ 110,95 CHECKBOX oChk2 VAR lChk2 PROMPT "Inverter a sele��o" SIZE 70,7 PIXEL OF oDlg ;
         ON CLICK( aEval( _aDivPNF, {|x| x[1] := !x[1] } ), oLbx:Refresh() )

DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg      

ACTIVATE MSDIALOG oDlg CENTER


RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IsTransFil�Autor  � Andre Anjos		 � Data �  05/11/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Verifica se a pre-nota incluida e uma transferencia entre  ���
���          � filiais atrav�s do cadastro do fornecedor.                 ���
�������������������������������������������������������������������������͹��
���Uso       � MATA140                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IsTransFil()
Local lRet     := .F.
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSM0 := SM0->(GetArea())

If IsInCallStack("MATA310")	//-- Se chamada pela MATA310 - Transf. Filiais
	lRet := .T.
ElseIf IsInCallStack("COMXCOL") .or. IsInCallStack("MATA140I")	//-- Se chamada por TOTVS Colaboracao
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+cA100For+cLoja))

	//-- Verifica pelo campo A2_FILTRF, que deve ter o codigo da filial
	If UsaFilTrf()	
		lRet := !Empty(SA2->A2_FILTRF)
	//-- Verifica pelo CNPJ no SIGAMAT
	Else
		SM0->(dbGoTop())
		While !SM0->(EOF())
			If AllTrim(SM0->M0_CGC) == AllTrim(SA2->A2_CGC)
				lRet := .T.
				Exit
			EndIf
			SM0->(dbSkip())
		End
		SM0->(RestArea(aAreaSM0))
	EndIf
	
	SA2->(RestArea(aAreaSA2))
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A140Conhec� Autor �Alexandre Gimenez      � Data �29/05/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada da visualizacao do banco de conhecimento            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A140Conhec()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A140Conhec()

Local aRotBack := AClone( aRotina )
Local nBack    := N

Private aRotina := {}

Aadd(aRotina,{STR0066,"MsDocument", 0 , 2}) //"Conhecimento"

MsDocument( "SF1", SF1->( Recno() ), 1 )

aRotina := AClone( aRotBack )
N := nBack

Return( .t. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RetOpName� Autor �TOTVS                   � Data �14/03/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna o nome do Operador da Conferencia de Etiquetas      ���
��� na tabela CBE - Etiquetas Lidas                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �RetOpName()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCodOp - codigo do operador da conferencia de etiquetas     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �cNomeOper - nome do operador                                                        ���
�������������������������������������������������������������������������Ĵ��
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function RetOpName(cCodOp)
	
Local aArea := GetArea()
Local cNomeOper := ""
Local cAlias := "CB1"

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))

If (cAlias)->(DbSeek(xFilial("CB1")+cCodOp))
	cNomeOper := CB1->CB1_NOME
Endif
	
RestArea(aArea)
Return cNomeOper
