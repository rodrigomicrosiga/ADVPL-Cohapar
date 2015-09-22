/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contrato	 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_PE_CONTRATOS.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Pontos de Entrada - Contratos							 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/07/2015												 !
+------------------+---------------------------------------------------------+
! ATUALIZACOES 	   															 !
+-------------------------------------------+-----------+-----------+--------+
! Descricao detalhada da atualizacao 		!Nome do    ! Analista  !Data da !
! 											!Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!  									 		! 		 	! 		 	!		 !
! 											! 		 	! 			! 		 !
+-------------------------------------------+-----------+-----------+--------+
*/
#include "Protheus.ch"

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CN100ALTDF! Autor !Gilson Lima 		 ! Data ! 23/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza data Final do Contrato								 !
!			! 										 						 !
+----------------------------------------------------------------------------*/
User Function CN100ALTDF()

	Local dDtRet	:= PARAMIXB[1] + 1

Return dDtRet

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CN100GRC  ! Autor !Gilson Lima 		 ! Data ! 06/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto Entrada gravação do contrato							 !
!			! Grava próxima numeração contrato na SX5						 !
+----------------------------------------------------------------------------*/
User Function CN100GRC()

	Local nOpc		:= PARAMIXB[1]
	Local aNrCtr	:= {}
	Local cTabSX5	:= 'ZF'
	Local cNovoNr	:= ''
	Local cPrefix	:= ''
	Local cAno		:= ''
	Local cCampoX5Nr:= ''
	Local cCampoX5An:= ''
	
	Local cCodForn	:= '' 
	Local cLojForn	:= ''
	Local cNomForn	:= ''
	
	
	If nOpc == 3 // Incluir
	
		aNrCtr := Separa(CN9->CN9_NUMERO,"/")
		
		cNovoNr := StrZero(Val(aNrCtr[1]) + 1,5)
		cPrefix := AllTrim(aNrCtr[2])
		cAno	:= AllTrim(aNrCtr[3])
		
		If cPrefix != 'GEN' .And. AllTrim(cPrefix) != ''
			
			cCampoX5Nr := cPrefix + 'NR'
			cCampoX5An := cPrefix + 'AN'			
			
			// Grava o novo número na tabela SX5
			aArea := GetArea()
	
			dbSelectArea('SX5')
			SX5->(dbSetOrder(1))

			// Grava Nr			
			If SX5->(dbSeek(xFilial('SX5')+cTabSX5+cCampoX5Nr))
				RecLock('SX5',.F.)
					SX5->X5_DESCRI := cNovoNr
				MsUnLock()
			EndIf
			
			SX5->(dbGoTop())

			// Grava Ano
			If SX5->(dbSeek(xFilial('SX5')+cTabSX5+cCampoX5An))
				RecLock('SX5',.F.)
					SX5->X5_DESCRI := cAno
				MsUnLock()
			EndIf
			
			SX5->(dbCloseArea())
			RestArea(aArea)
		EndIf	
	
	EndIf
	
	// Grava Nome do Fornecedor na CN9, baseado na planilha
	cCodForn	:= POSICIONE('CNA',1,xFilial('CNA')+CN9->CN9_NUMERO+CN9->CN9_REVISA,'CNA_FORNEC') 
	cLojForn	:= POSICIONE('CNA',1,xFilial('CNA')+CN9->CN9_NUMERO+CN9->CN9_REVISA,'CNA_LJFORN')
	cNomForn	:= POSICIONE('SA2',1,xFilial('SA2')+cCodForn+cLojForn,'A2_NOME')
	
	RecLock('CN9',.F.)
		CN9->CN9_XCODFN	:= cCodForn
		CN9->CN9_XLOJA	:= cLojForn
		CN9->CN9_XNMFOR	:= cNomForn
	CN9->(MsUnLock())	

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CTA100MNU ! Autor !Gilson Lima 		 ! Data ! 22/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto Entrada abertura do browse de contratos					 !
!			! inserir opções no menu de Ações Relacionadas					 !
+----------------------------------------------------------------------------*/
User Function CTA100MNU()

	Local aUserAlt  := StrToKarr(GetNewPar('MV_MANGEST',  'Administrador'),',')
	Local lUserAlt  := .F.

	// Verifica se usuário atual pode efetuar manutenção dos gestores
	For nX := 1 to Len(aUserAlt)
		If UPPER(AllTrim(aUserAlt[nX])) == UPPER(AllTrim(cUserName))
			lUserAlt := .T.
			Exit
			
		EndIf
	Next nX	

	If lUserAlt
		// Adiciona Ítem Ações Relacionadas para visualização de histórico de gestores
		//aAdd(aRotina,{'Manutenção de Gestor', "u_AGestCTR",0,9,0,NIL })
		aAdd(aRotina,{'Manutenção de Papéis', "u_APapCTR",0,11,0,NIL })
	EndIF

	// Adiciona Ítem Ações Relacionadas para alteração de gestor
	//aAdd(aRotina,{'Histórico de Gestores', "u_HGestCTR",0,10,0,NIL })
	

Return .T.

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CN140GREV ! Autor !Gilson Lima 		 ! Data ! 22/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto Entrada gravação da revisao								 !
!			! Solicitar	data de Assinatura e Início da Revisão				 !
+----------------------------------------------------------------------------*/
User Function CN140GREV()

	Local aArea	    := GetArea()
	Local nOpca	    := 0
	Local cNrContr  := PARAMIXB[1] // Nr. do Contrato
	Local cRevAnt   := PARAMIXB[2] // Revisão Origem
	Local cRevAtu   := PARAMIXB[3] // Revisão Gerada
	Local dDtInicio := POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XDTINI')
	Local dDtAssina := POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XDTASS')
	Local dDtIniExe := POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XINIEX')
	Local dDtFimExe := POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XFIMEX')
	Local cNrProc   := POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_NUMPR')
	Local cCompl    := POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XCOMPL')
	
	Local cNrDoe	:= POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XEDOE')
	Local dDtPubl	:= POSICIONE('CN9',1,xFilial('CN9')+cNrContr+cRevAnt,'CN9_XPUBL')
	
	Local cCdForn	:= POSICIONE('CNC',1,xFilial('CNC')+cNrContr+cRevAnt,'CNC_CODIGO')
	Local cLjForn	:= POSICIONE('CNC',1,xFilial('CNC')+cNrContr+cRevAnt,'CNC_LOJA')
	Local cNmForn	:= POSICIONE('SA2',1,xFilial('SA2')+cCdForn+cLjForn	,'A2_NOME')
	Local cCdUsr	:= POSICIONE('CNC',1,xFilial('CNC')+cNrContr+cRevAnt,'CNC_XCDASS')
	Local cTpUsr	:= POSICIONE('CNC',1,xFilial('CNC')+cNrContr+cRevAnt,'CNC_XTASS')
	
	Local cCPdrCdF	:= 'SA2' 	// Consulta Padrão: Fornecedores
	Local cCPdrCd	:= 'SZICOD' // Consulta Padrão: TCEPR PessoaSEICED
	Local cCPdrTp 	:= 'XU' 	// Tipo de Assinante de Contrato	
	
	Local cRevAtu	:= ''
	Local cNrRevAnt	:= ''
	Local nVlAnter	:= 0
	Local nVlAditivo:= 0
	
	Private oDlg
	
	// Janela de manutenção
	DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 TO 320,530 PIXEL
	
	@ 10,04 SAY OemToansi("Número do Contrato:") SIZE 73, 8 OF oDlg PIXEL
	@ 10,60 SAY OemToansi(cNrContr) SIZE 73, 8 OF oDlg PIXEL
	
	@ 25,04 SAY OemToAnsi('Nr. Revisão:') SIZE 73,8 OF oDlg PIXEL
	@ 25,60 SAY OemToAnsi(cRevAtu) SIZE 100,8 OF oDlg PIXEL
	
	@ 40,04 SAY OemToAnsi('Data de Início:') SIZE 73,8 OF oDlg PIXEL
	@ 39,60 MSGET oGet01 VAR dDtInicio  PICTURE PesqPict("CN9","CN9_XDTINI") SIZE 60,9 OF oDlg PIXEL
	
	@ 40,150 SAY OemToAnsi('Data de Assinatura:') SIZE 73,8 OF oDlg PIXEL
	@ 39,200 MSGET oGet02 VAR dDtAssina PICTURE PesqPict("CN9","CN9_XDTASS") SIZE 60,9 OF oDlg PIXEL
	
	@ 55,04 SAY OemToAnsi('Início de Execução:') SIZE 73,8 OF oDlg PIXEL
	@ 54,60 MSGET oGet03 VAR dDtIniExe  PICTURE PesqPict("CN9","CN9_XINIEX") SIZE 60,9 OF oDlg PIXEL
	
	@ 55,150 SAY OemToAnsi('Fim de Execução:') SIZE 73,8 OF oDlg PIXEL
	@ 54,200 MSGET oGet04 VAR dDtFimExe PICTURE PesqPict("CN9","CN9_XFIMEX") SIZE 60,9 OF oDlg PIXEL
	
	@ 70,04 SAY OemToAnsi('Complemento:') SIZE 73,8 OF oDlg PIXEL
	@ 69,60 MSGET oGet05 VAR cCompl  PICTURE PesqPict("CN9","CN9_XCOMPL") SIZE 60,9 OF oDlg PIXEL
	
	@ 70,150 SAY OemToAnsi('Número do Processo:') SIZE 73,8 OF oDlg PIXEL
	@ 69,200 MSGET oGet06 VAR cNrProc  PICTURE PesqPict("CN9","CN9_NUMPR") SIZE 60,9 OF oDlg PIXEL
	
	@ 85,04 SAY OemToAnsi('Data de Publ. DOE:') SIZE 73,8 OF oDlg PIXEL
	@ 84,60 MSGET oGet07 VAR dDtPubl PICTURE PesqPict("CN9","CN9_XPUBL") SIZE 60,9 OF oDlg PIXEL

	@ 85,150 SAY OemToAnsi('Nr. Edição DOE:') SIZE 73,8 OF oDlg PIXEL
	@ 84,200 MSGET oGet08 VAR cNrDoe  PICTURE PesqPict("CN9","CN9_XEDOE") SIZE 60,9 OF oDlg PIXEL
	
	@ 100,04 SAY OemToAnsi('Cód. Fornecedor:') SIZE 73,8 OF oDlg PIXEL
	@ 99,60 MSGET oGet09 VAR cCdForn F3 cCPdrCdF PICTURE PesqPict("CNC","CNC_CODIGO") SIZE 60,9 OF oDlg PIXEL
	
	@ 100,150 SAY OemToAnsi('Loja Fornecedor:') SIZE 73,8 OF oDlg PIXEL
	@ 99,200 MSGET oGet10 VAR cLjForn PICTURE PesqPict("CNC","CNC_LOJA") SIZE 60,9 OF oDlg PIXEL

	@ 115,04 SAY OemToAnsi('Nome do Fornecedor:') SIZE 73,8 OF oDlg PIXEL
	@ 114,60 MSGET oGet11 VAR cNmForn PICTURE PesqPict("SA2","A2_NOME") SIZE 200,9 OF oDlg PIXEL
	
	@ 130,04 SAY OemToAnsi('Cód. Assinante:') SIZE 73,8 OF oDlg PIXEL
	@ 129,60 MSGET oGet12 VAR cCdUsr F3 cCPdrCd PICTURE PesqPict("CNC","CNC_XCDASS") SIZE 60,9 OF oDlg PIXEL
	
	@ 130,150 SAY OemToAnsi('Tipo Assinante:') SIZE 73,8 OF oDlg PIXEL
	@ 129,200 MSGET oGet13 VAR cTpUsr F3 cCPdrTp PICTURE PesqPict("CNC","CNC_XTASS") SIZE 60,9 OF oDlg PIXEL

	DEFINE SBUTTON FROM 148, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
	DEFINE SBUTTON FROM 148, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:=2) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	
	
	// Ao clicar em OK
	If nOpca == 1

		cNrContr := CN9->CN9_NUMERO
		cRevAnt	 := CN9->CN9_REVISA
		
		cRevAtu  := StrZero(Val(cRevAnt)+1,3)
		
		// Valor do Aditivo
		nVlAnter 	:= CN9->CN9_VLATU
		nVlNovo     := POSICIONE("CN9",1,CN9->CN9_FILIAL+cNrContr+cRevAtu,"CN9_VLATU")
		nVlAditivo := nVlNovo - nVlAnter
	
		dbSelectArea('CN9')
		CN9->(dbSetOrder(1))
		If CN9->(dbSeek(xFilial('CN9')+cNrContr+cRevAtu))
			
			RecLock('CN9',.F.)
				CN9->CN9_XDTINI := dDtInicio
				CN9->CN9_XDTASS := dDtAssina
				CN9->CN9_XINIEX := dDtIniExe
				CN9->CN9_XFIMEX := dDtFimExe
				CN9->CN9_NUMPR	:= cNrProc
				CN9->CN9_XCOMPL := cCompl
				CN9->CN9_VLADIT := nVlAditivo
				CN9->CN9_XEDOE	:= cNrDoe
				CN9->CN9_XPUBL	:= dDtPubl
			CN9->(MsUnLock())
		EndIf

		CN9->(dbCloseArea())
		
		dbSelectArea('CNC')
		CNC->(dbSetOrder(1))
		If CNC->(dbSeek(xFilial('CNC')+cNrContr+cRevAtu))		

			RecLock('CNC',.F.)
				CNC->CNC_CODIGO	:= cCdForn
				CNC->CNC_LOJA	:= cLjForn
				CNC->CNC_XCDASS	:= cCdUsr
				CNC->CNC_XTASS	:= cTpUsr
			CNC->(MsUnLock())
				
		EndIf
	
	EndIf
	
	RestArea(aArea)

Return .T.

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CN100FIB  ! Autor !Gilson Lima 		 ! Data ! 24/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto Entrada Montagem do Browse de Contratos					 !
!			! Filtrar contratos conforme gestor				 				 !
+----------------------------------------------------------------------------*/
User Function CN100FIB()

	Local aArea		:= GetArea()
	Local cExpr     := ''
	Local aUserExc  := StrToKarr(GetNewPar('MV_CTRVISU',  'Administrador'),',')
	Local lUserExc  := .F.
	Local cIdProth  := RetCodUsr()
	Local cQuery	:= ''
	Local nCont		:= 0
	Local nRegistros:= 0
	
	// Verifica se usuário atual está na lista de exceções de visualização total
	For nX := 1 to Len(aUserExc)
		If UPPER(AllTrim(aUserExc[nX])) == UPPER(AllTrim(cUserName))
			lUserExc := .T.
			Exit
		EndIf
	Next nX	
	
	// Caso o usuário não esteja na lista de exceções, efetua o filtro
	If !lUserExc
	
		cQuery := "SELECT SZP.ZP_NRCONTR, SZI.ZI_CDPROTH"
		cQuery += " FROM " + RetSqlName('SZP') + " SZP"
		cQuery += " , " + RetSqlName('SZI') + " SZI"
		cQuery += " WHERE SZP.D_E_L_E_T_ <> '*'"
		cQuery += " AND SZP.ZP_ATIVO = 'S'"
		cQuery += " AND SZP.ZP_FLCONTR = '" + xFilial('SZP') + "'"
		cQuery += " AND SZI.D_E_L_E_T_ <> '*'"
		cQuery += " AND SZI.ZI_CODIGO = SZP.ZP_CDUSR"
		cQuery += " AND SZI.ZI_ATIVO = 'S'"
		cQuery += " AND SZI.ZI_CDPROTH = '" + cIdProth + "'"
		
		If Select('TRBSZP') <> 0
			dbSelectArea('TRBSZP')
			TRBSZP->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRBSZP',.F.,.F.)
		
		nRegistros := Contar("TRBSZP","!EOF()")
		
		dbSelectArea('TRBSZP')
		TRBSZP->(dbGoTop())
		
		While TRBSZP->(!EOF())
			nCont ++
			
			// Cria expressão de filtro
			If nCont <= nRegistros .And. nCont != 1
				cExpr += " OR "
			EndIf

			cExpr += "CN9_NUMERO = '" + TRBSZP->ZP_NRCONTR + "'"
			
			TRBSZP->(dbSkip())
		
		EndDo
		
		TRBSZP->(dbCloseArea())
		
	EndIf
	
	RestArea(aArea)
		
Return cExpr
