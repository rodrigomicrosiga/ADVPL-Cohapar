//-----------------------------
//Impressão Ordem Transferência
//-----------------------------
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "protheus.ch"
#include "font.ch"
#include "topconn.ch"

User Function COHAX02()
	//Variáveis da rotina
	Local oDlg 		 := Nil
	Local aHelpP01   := {}
	Local aHelpP02   := {}
	Local aOrd		 := {}
	Local aPergs     := {}
	Local cDesc1     := ""
	Local cDesc2     := ""
	Local cDesc3     := ""
	Private nLastKey := 0
	Private cPerg    := "COHAX2   "
	Private nomeProg := "COHAX2"
	Private wnrel    := "COHAX2"
	Private cTitulo  := "Ordem de Transferência"
	Private tamanho  := "P"
	Private nLastKey := 0
	Private limite   := 132
	Private nTipo    := 15
	Private nLin     := 250
	Private oPrn     := Nil
	Private oFont8   := Nil
	Private oFont12  := Nil
	Private oFont12N := Nil
	Private oFont16N := Nil
	Private aReturn  := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	
	//Cria perguntas e help caso não existam
	Aadd( aHelpP01, "Número da ordem de transferência    " )
	
	SX1->(dbSeek(xFilial("SX1")+cPerg,.T.))
	If SX1->(!Found())
		Aadd(aPergs,{"Banco?","Banco?","Banco?","mv_ch1","C",TAMSX3("A6_COD")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
		Aadd(aPergs,{"Agência?","Agência?","Agência?","mv_ch2","C",TAMSX3("A6_AGENCIA")[1],0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"Conta?","Conta?","Conta?","mv_ch3","C",TAMSX3("A6_NUMCON")[1],0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"Núm Transf De?","Número Transf De?","Número Transf De?","mv_ch4","C",15,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"Núm Transf Ate?","Número Transf Ate?","Número Transf Ate?","mv_ch5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"Data De?","Data De?","Data De?","mv_ch6","D",8,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		Aadd(aPergs,{"Data Ate?","Data Ate?","Data Ate?","mv_ch7","D",8,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
		
		AjustaSx1("COHAX2",aPergs)
		
		PutSX1Help("P.COHAX2.",aHelpP01,,)
	Endif
	
	Pergunte(cPerg,.F.)
	
	//Tela de entrada dos dados
	DEFINE FONT oFont6 NAME "Courier New" BOLD
	
	DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
	@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL
	
	@ 015,017 SAY "Impressão da Ordem de Transferência" OF oDlg PIXEL SIZE 150,010 FONT oFont6 COLOR CLR_HBLUE
	@ 030,017 SAY "Específico COHAPAR                 " OF oDlg PIXEL SIZE 150,010 FONT oFont6 COLOR CLR_HBLUE
	
	@ 06,167 BUTTON "&Parâmetros" SIZE 036,012 ACTION Pergunte(cPerg,.T.) OF oDlg PIXEL
	@ 28,167 BUTTON "&Visualiza " SIZE 036,012 ACTION Imprime(.T.) OF oDlg PIXEL
	@ 49,167 BUTTON "&Imprime   " SIZE 036,012 ACTION Imprime(.F.) OF oDlg PIXEL
	@ 71,167 BUTTON "&Sair      " SIZE 036,012 ACTION oDlg:End()   OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function Imprime(lPreview)
	Local oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	Local oFont12  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	Local oFont12N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	Local oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	Local oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
	Local cBmp     := "LGMIDOLD.png"
	Local oPrn     := Nil
	Local nLinha := 0
	Local nTotaliz := 0
	Local nPrtRegs := 0
	Local aEstornos:= {}
	Local aProcTra := {}
	
	//Variáveis do relatório
	Private cDia     := StrZero(Day(dDataBase), 2)
	Private cMes     := StrZero(Month(dDataBase), 2)
	Private cAno     := StrZero(Year(dDataBase), 4)
	Private cMesExt  := MesExtenso(Month(dDataBase))
	Private cDataImp := cDia + " de " + cMesExt + " de " + cAno + "."
	
	//Inicio da impressão
	oPrn := TMSPrinter():New(cTitulo)
	
	oPrn:SetPortrait()
	
	//Verifica se o arquivo temporário está aberto
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	Endif
	
	If (Select("TMP") <> 0)
		dbSelectArea("TMP")
		dbCloseArea()
	Endif
	
	// Seleciona todos os registros de origem com os parâmetros informados
		
	cQuery2 := " SELECT E5_FILIAL, E5_DOCUMEN, E5_BANCO, E5_AGENCIA, A6_DVAGE, E5_CONTA, A6_DVCTA, E5_HISTOR, E5_VALOR "
	cQuery2 += ", E5_PROCTRA"
	cQuery2 += " FROM "+RetSqlName("SE5")
	// Data: 01/10/2012 -> Ligação entre a tabela de títulos e o cadastro de bancos, para selecionar os dígitos verificadores da conta e da agência
	cQuery2 += " SE5 LEFT JOIN "+RetSqlName("SA6")+ " SA6 ON ( "
	cQuery2 += " 	 SA6.A6_FILIAL	= '"+xFilial("SA6")+"'"
	cQuery2 += " AND SA6.A6_COD		= SE5.E5_BANCO "
	cQuery2 += " AND SA6.A6_AGENCIA	= SE5.E5_AGENCIA "
	cQuery2 += " AND SA6.A6_NUMCON	= SE5.E5_CONTA "
	cQuery2 += " AND SA6.D_E_L_E_T_ = ' ' "
	cQuery2 += " ) "
	cQuery2 += " WHERE SE5.D_E_L_E_T_ = ' ' "
	cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"' "
	//cQuery2 += " AND E5_RECPAG = 'R' "
	cQuery2 += " AND E5_RECPAG = 'P' "
	cQuery2 += " AND E5_NUMCHEQ >= '"+mv_par04+"' "
	cQuery2 += " AND E5_NUMCHEQ <= '"+mv_par05+"' "
	
	cQuery2 += " AND E5_DATA >= '"+DtoS(mv_par06)+"' "
	cQuery2 += " AND E5_DATA <= '"+DtoS(mv_par07)+"' "
	
	cQuery2 += " AND E5_BANCO = '"+mv_par01+"' "
	cQuery2 += " AND E5_AGENCIA = '"+mv_par02+"' "
	cQuery2 += " AND E5_CONTA = '"+mv_par03+"' "
	cQuery2 += " ORDER BY E5_NUMCHEQ "
	
	TcQuery cQuery2 New Alias "TRB"
	
	Do While (TRB->(!EOF()))

		aAdd(aProcTra,TRB->E5_PROCTRA)

		cBanco 		:= TRB->E5_BANCO
		cAgencia 	:= TRB->E5_AGENCIA
		cDVAgencia 	:= TRB->A6_DVAGE
		cConta 		:= TRB->E5_CONTA
		cDVConta 	:= TRB->A6_DVCTA
		
		TRB->(dbSkip())
	EndDo
	
	// Seleciona todos os registros de destino baseado nos registros de origem
	
	cQuery3 := " SELECT E5_FILIAL, E5_DOCUMEN, E5_BANCO, E5_AGENCIA, A6_DVAGE, E5_CONTA, A6_DVCTA, E5_HISTOR, E5_VALOR "
	cQuery3 += ", E5_PROCTRA, E5_NUMCHEQ"
	cQuery3 += " FROM "+RetSqlName("SE5")+" SE5 "

	cQuery3 += " LEFT JOIN "+RetSqlName("SA6")+ " SA6 ON ( "
	cQuery3 += " 	 SA6.A6_FILIAL	= '"+xFilial("SA6")+"'"
	cQuery3 += " AND SA6.A6_COD		= SE5.E5_BANCO "
	cQuery3 += " AND SA6.A6_AGENCIA	= SE5.E5_AGENCIA "
	cQuery3 += " AND SA6.A6_NUMCON	= SE5.E5_CONTA "
	cQuery3 += " AND SA6.D_E_L_E_T_ = ' ' "
	cQuery3 += " ) "
	
	cQuery3 += " WHERE SE5.D_E_L_E_T_ = ' ' "
	cQuery3 += " AND E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery3 += " AND E5_RECPAG = 'R' "
	
	// Adiciona condição para trazer somente os ítens do array aProcTra
	For nJ := 1 To Len(aProcTra)
		
		If nJ == 1
			cQuery3 += " AND ( "
		EndIf
		
		cQuery3 += " E5_PROCTRA = '" + aProcTra[nJ] + "' "
		
		If nJ != Len(aProcTra)
			cQuery3 += " OR "
		EndIf
		
		If nJ == Len(aProcTra)
			cQuery3 += ")"
		EndIf
	
	Next nJ

	cQuery3 += " ORDER BY E5_DOCUMEN "
	
	TcQuery cQuery3 New Alias "TMP"
	
	nContReg := 0
	
	// Valida Estorno e controla Nr de Registros
	Do While (TMP->(!EOF()))
		nContReg ++
		
		// Adiciona informação no array de ítens a serem ignorados em caso de estorno
		If 'ESTORNO' $ Upper(TMP->E5_HISTOR)
			nContReg--
			aAdd(aEstornos,TMP->E5_PROCTRA)
		EndIf
		
		TMP->(dbSkip())
	EndDo	
	
	// CAso não haja registros para o relatório
	If nContReg <= 0
		Alert("Sem informações para geração do relatório!")
		Return
	endIf
	
	TMP->(dbGoTop())
	
	Do While (TMP->(!EOF()))
		oPrn:StartPage()
		
		//INICIO COPIA
		
		// Box do título do relatório.
		oPrn:Box(0030,0080,0280,2300)
		
		oPrn:SayBitmap(0050,0100,cBmp,0550,0220)
		oPrn:Say(0125,850, "ORDEM DE TRANSFERÊNCIA", oFont16N)
		
		//oPrn:Say(0200,1900, "NÚMERO:", oFont12)
		//oPrn:Say(0200,2100, Alltrim(TRB->E5_NUMCHEQ), oFont12N)
		
		// Box do cabeçalho do relatório.
		oPrn:Box(0350,0080,0730,2300)
		
		oPrn:Say(0400,0100, "A COMPANHIA DE HABITAÇÃO DO PARANÁ - COHAPAR, AUTORIZA QUE SEJA(M) EFETUADA(S) A(S) TRANSFERÊNCIAS A " ,oFont12)
		oPrn:Say(0450,0100, "CRÉDITO DO(S) FAVORECIDO(S) ABAIXO DISCRIMINADO(S), DEBITANDO-A(S) EM NOSSA CONTA CORRENTE:                         " ,oFont12)
		
		oPrn:Say(0550,0100, "NÚMERO CONTA:", oFont12)
		oPrn:Say(0550,0500, Alltrim(cBanco) + " / " + Alltrim(cConta) + "-" + AllTrim(cDVConta), oFont12N)
		
		oPrn:Say(0600,0100, "ENTIDADE BANCÁRIA:", oFont12)
		oPrn:Say(0600,0500, Alltrim(Posicione("SA6", 1, xFilial("SA6")+cBanco+cAgencia+cConta, "A6_NOME")), oFont12N)
		
		oPrn:Say(0650,0100, "NÚMERO AGÊNCIA:", oFont12)
		oPrn:Say(0650,0500, Alltrim(cAgencia) + "-" + AllTrim(cDVAgencia), oFont12N)
		
		// Box dos valores e da assinatura.
		oPrn:Box(0800,0080,3150,2300)
		
		// Linha separando o cabeçalho dos itens (valores).
		oPrn:Line(0900,0080,0900,2300)
		
		oPrn:Say(0840,0100, "NÚMERO", oFont12)
		oPrn:Say(0840,0550, "FAVORECIDO", oFont12)
		oPrn:Say(0840,1220, "ENT.BANCÁRIA/AGÊNCIA", oFont12)
		oPrn:Say(0840,1770, "CONTA", oFont12)
		oPrn:Say(0840,2150, "VALOR", oFont12)
		
		// Linha antes do favorecido.
		oPrn:Line(0800,0300,2100,0300)
		// Linha antes da entidade bancária.
		oPrn:Line(0800,1220,2100,1220)
		// Linha antes da conta.
		oPrn:Line(0800,1670,2100,1670)
		// Linha antes do valor.
		oPrn:Line(0800,2000,2100,2000)
		
		nLinha := 900
		nTotaliz := 0
		nPrtRegs := 0
		
		Do While (TMP->(!EOF()))
			
			// Valida Estornos, não exibindo o registro de estorno e sua origem
			lEstorno := .F.

			For nG := 1 To Len(aEstornos)
				If TMP->E5_PROCTRA == aEstornos[nG]
					lEstorno := .T.
				EndIf
			Next nG
			
			If lEstorno
				TMP->(dbSkip())
				Loop
			EndIf
			// --------------
				
			oPrn:Say(nLinha,0100, Alltrim(TMP->E5_DOCUMEN), oFont12N)
			//oPrn:Say(nLinha,0100, Alltrim(TMP->E5_NUMCHEQ), oFont12N)
			oPrn:Say(nLinha,0320, Alltrim(Posicione("SA6", 1, xFilial("SA6")+TMP->E5_BANCO+TMP->E5_AGENCIA+TMP->E5_CONTA, "A6_NOME")), oFont12N)
			oPrn:Say(nLinha,1240, Alltrim(Posicione("SA6", 1, xFilial("SA6")+TMP->E5_BANCO+TMP->E5_AGENCIA+TMP->E5_CONTA, "A6_NREDUZ")), oFont12N)
			oPrn:Say(nLinha,1690, Alltrim(TMP->E5_CONTA) + "-" + AllTrim(TMP->A6_DVCTA), oFont12N)
			oPrn:Say(nLinha,2070, Transform(TMP->E5_VALOR, "@E 999,999,999.99"), oFont12N)
			oPrn:Say(nLinha+50,0320, Alltrim(TMP->E5_HISTOR), oFont12N)
			oPrn:Say(nLinha+50,1240, Alltrim(TMP->E5_BANCO) + " / " + Alltrim(TMP->E5_AGENCIA) + "-" + AllTrim(TMP->A6_DVAGE), oFont12N)
			
			nTotaliz += TMP->E5_VALOR
			nLinha += 100
			nPrtRegs++
			
			TMP->(dbSkip())
			
			If (nPrtRegs == 12)
				Exit
			EndIf
		EndDo
		
		// Linha antes do texto "IMPORTA...".
		oPrn:Line(2100,0080,2100,2300)
		
		oPrn:Say(2180,0100, "IMPORTA AS PRESENTES ORDENS DE TRANSFERÊNCIA A QUANTIA DE R$", oFont12)
		oPrn:Say(2180,1350, Transform(nTotaliz,"@E 999,999,999.99"), oFont14N)
		oPrn:Say(2280,0100, "(" + Extenso(nTotaliz,.F.,1) + ")", oFont12N)
		oPrn:Say(2430,1530, "CURITIBA-PR, " + Upper(cDataImp), oFont12N)
		
		// Linhas das assinaturas.
		// Primeira da esquerda.
		oPrn:Line(2630,0130,2630,0930)
		// Primeira da direita.
		oPrn:Line(2630,1450,2630,2250)
		// Segunda da esquerda.
		oPrn:Line(2830,0130,2830,0930)
		// Segunda da direita.
		oPrn:Line(2830,1450,2830,2250)
		// Última do meio.
		oPrn:Line(3030,0830,3030,1630)
		
		oPrn:Say(3250,0080, "COHAPAR - RUA MARECHAL DEODORO, 1133 - FONE: (41) 3312.5700 - FAX: (41) 3362.2048 - CURITIBA-PARANÁ", oFont08)
		
		oPrn:EndPage()
	EndDo
	
	//Fecha temporários
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("TMP")
	dbCloseArea()
	
	If lPreview
		oPrn:Preview()
	Else
		oPrn:Print()
	EndIf
Return Nil
