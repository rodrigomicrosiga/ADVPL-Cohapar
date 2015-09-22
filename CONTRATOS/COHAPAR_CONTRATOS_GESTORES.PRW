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
!Nome 			   ! COHAPAR_CONTRATOS_GESTORES.PRW							 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Contratos - Gestores									 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 22/07/2015												 !
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
! Programa 	! AGestCTR  ! Autor !Gilson Lima 		 ! Data ! 22/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Alteração de Gestores do Contrato								 !
!			!  																 !
+----------------------------------------------------------------------------*/
User Function AGestCTR()
	
	Local aArea		:= GetArea()
		
	Local cNrContra	:= AllTrim(CN9->CN9_NUMERO)
	Local cCdGestAn := AllTrim(CN9->CN9_XCDRES)
	Local cNmGestAn := AllTrim(POSICIONE('SZI',1,xFilial('SZI')+CN9->CN9_XCDRES,"ZI_NOME"))
	Local cTpGestAn := AllTrim(CN9->CN9_XXTR)
	
	Local cCPdrCd	:= 'SZICOD' // Consulta Padrão: TCEPR PessoaSEICED
	Local cCPdrTp 	:= 'XY' 	// Tipo de Gestor de Contrato
	
	Local cCdGestNv	:= Space(6)
	Local cNmGestNv := ''
	Local cTpGestNv := Space(2)
	Local cJustific := Space(250)
	
	Local nOpca		:= 0
	
	Local cUsrManut	:= cValToChar(RetCodUsr()) + ' - ' + UsrFullName(RetCodUsr())
	Local dDtAlter
	Local cHrAlter
	
	Local cGestorAt := AllTrim(CN9->CN9_XCDRES) + ' - ' + AllTrim(POSICIONE('SZI',1,xFilial('SZI')+CN9->CN9_XCDRES,"ZI_NOME"))

	Private oDlg

	// Em caso de contrato finalizado, não permite a mudança de gestores
	If CN9->CN9_SITUAC == '08'
		MsgInfo('Contrato Finalizado. Não permite alteração de Gestores','Alerta')
		Return .F.
	EndIf
	
	// Janela de manutenção
	DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 TO 175,530 PIXEL
	
	@ 10,04 SAY OemToansi("Número do Contrato:") SIZE 73, 8 OF oDlg PIXEL
	@ 10,60 SAY OemToansi(CN9->CN9_NUMERO) SIZE 73, 8 OF oDlg PIXEL
	
	@ 25,04 SAY OemToAnsi('Gestor Atual:') SIZE 73,8 OF oDlg PIXEL
	@ 25,60 SAY OemToAnsi(cGestorAt) SIZE 100,8 OF oDlg PIXEL
	
	@ 40,04 SAY OemToAnsi('Novo Gestor:') SIZE 73,8 OF oDlg PIXEL
	@ 39,60 MSGET oGet01 VAR cCdGestNv  F3 cCPdrCd SIZE 60,9 OF oDlg PIXEL
	
	@ 40,150 SAY OemToAnsi('Tipo de Gestor:') SIZE 73,8 OF oDlg PIXEL
	@ 39,200 MSGET oGet02 VAR cTpGestNv  F3 cCPdrTp SIZE 60,9 OF oDlg PIXEL
	
	@ 55,04 SAY OemToAnsi('Justificativa:') SIZE 73,8 OF oDlg PIXEL
	@ 54,60 MSGET oGet03 VAR cJustific PICTURE PesqPict("SZO","ZO_JUSTIFIC") SIZE 200,9 OF oDlg PIXEL
	
	//@ 10,104  SAY OemToansi(RetTitle("CNF_COMPET")) SIZE 73, 8 OF oDlg PIXEL
	//@ 09,137 ComboBox oCbx Var cCompet ON CHANGE CN120Compet() SIZE 50,9 OF oDlg PIXEL
	//@ 09,37   MSGET oGet01 VAR cContra PICTURE PesqPict("CN9","CN9_NUMERO") F3 "SZNCLA" SIZE 60,9 VALID CN120VlCon(nTipo) OF oDlg PIXEL
	//@ 10,04   SAY OemToansi(RetTitle("CN9_NUMERO")) SIZE 73, 8 OF oDlg PIXEL

	DEFINE SBUTTON FROM 70, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
	DEFINE SBUTTON FROM 70, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:=2) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	
	
	// Ao clicar em OK
	If nOpca == 1
		
		// Valida Preenchimento de Campos:
		If AllTrim(cCdGestNv) == ''
			MsgInfo('Preenchimento do Novo Gestor é obrigatório. Alteração não efetuada.','Alerta')
			Return .F.
		EndIf
		If AllTrim(cTpGestNv) == ''
			MsgInfo('Preenchimento do Tipo do Novo Gestor é obrigatório. Alteração não efetuada.','Alerta')
			Return .F.
		EndIf
		If AllTrim(cJustific) == ''
			MsgInfo('Preenchimento da Justificativa é obrigatório. Alteração não efetuada.','Alerta')
			Return .F.
		EndIf
		
		If AllTrim(cCdGestNv) == AllTrim(cCdGestAn) .And. AllTrim(cTpGestNv) == AllTrim(cTpGestAn)
			MsgInfo('Os Dados selecionados são os mesmos já existentes. Alteração não efetuada', 'Alerta')
			Return .F.
		EndIf
		
		// Nome do Novo Gestor
		cNmGestNv := AllTrim(POSICIONE('SZI',1,xFilial('SZI')+cCdGestNv,"ZI_NOME"))
		
		// Data e Hora de Alteração
		dDtAlter  := Date()
		cHrAlter  := Time()
		
		// Grava Tabela de Histórico
		RecLock('SZO',.T.)
		
			SZO->ZO_FILIAL	:= xFilial('SZO')
			SZO->ZO_FLCONTR := CN9->CN9_FILIAL
			SZO->ZO_NRCONTR := CN9->CN9_NUMERO
			SZO->ZO_CDGESAN	:= cCdGestAn
			SZO->ZO_NMGESAN	:= cNmGestAn
			SZO->ZO_TPGESAN := cTpGestAn
			SZO->ZO_CDGESNV	:= cCdGestNv
			SZO->ZO_NMGESNV	:= cNmGestNv
			SZO->ZO_TPGESNV := cTpGestNv
			SZO->ZO_JUSTIFI	:= cJustific
			SZO->ZO_DTALTER	:= dDtAlter
			SZO->ZO_HRALTER	:= cHrAlter
			SZO->ZO_USRALTE := cUsrManut
			
		SZO->(MsUnLock())
		
		// Grava Alteração nos Contratos
		
		dbSelectArea('CN9')
		CN9->(dbSetOrder(1))
		CN9->(dbSeek(xFilial('CN9')+cNrContra))
		
		While CN9->(!EOF()) .And. AllTrim(CN9->CN9_NUMERO) == cNrContra 
			RecLock('CN9',.F.)
			
				CN9->CN9_XCDRES := cCdGestNv
				CN9->CN9_XXTR	:= cTpGestNv
				
			CN9->(MsUnLock())
		
			CN9->(dbSkip())
		EndDo
		
		RestArea(aArea)
		
		MsgInfo('Alteração efetuada com sucesso.','Alerta')
		
	// Clicar em Fechar
	ElseIf nOpca == 2
		Alert('Você clicou em fechar. Nenhuma alteração foi efetuada.')
		Return .F.
	EndIf
	
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! HGestCTR  ! Autor !Gilson Lima 		 ! Data ! 22/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Histórico de Gestores do Contrato								 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function HGestCTR(cAlias,nReg,nOpc)

	Local cNrContr  := CN9->CN9_NUMERO
	Local cFilContr := CN9->CN9_FILIAL
	Local cGestorAt := AllTrim(CN9->CN9_XCDRES) + ' - ' + AllTrim(POSICIONE('SZI',1,xFilial('SZI')+CN9->CN9_XCDRES,"ZI_NOME"))

	//Local nOpc 		:= 2
	
	Local cWhile 	:= "SZO->ZO_FILIAL+SZO->ZO_FLCONTR+SZO->ZO_NRCONTR"
	Local cChave 	:= xFilial("SZO")+cFilContr+cNrContr
	
	Local aCampos	:= {"ZO_DTALTER", "ZO_HRALTER", "ZO_NMGESAN", "ZO_USRALTE"}
		
	Private aHeader	:= {}
	Private aCols	:= {}

	// Monta aHeader e aCols para a Grid de Integrantes
	//FillGetDados(nOpc,'SZO',1,cChave,{|| &cWhile },,,aCampos,.T.,cQuery,,.F.,@aHeader,@aCols,,,,'SZOTRB')
	FillGetDados(nOpc,'SZO',1,cChave,{|| &cWhile },,,aCampos,.T.,,,.F.,@aHeader,@aCols,,,,'SZOTRB')
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 300,900 OF oMainWnd PIXEL

		@ 10,04 SAY OemToansi("Número do Contrato:") SIZE 73, 8 OF oDlg PIXEL
		@ 10,60 SAY OemToansi(CN9->CN9_NUMERO) SIZE 73, 8 OF oDlg PIXEL
		
		@ 25,04 SAY OemToAnsi('Gestor Atual:') SIZE 73,8 OF oDlg PIXEL
		@ 25,60 SAY OemToAnsi(cGestorAt) SIZE 100,8 OF oDlg PIXEL
		
		oGet := MsGetDados():New(40,04,130,450, nOpc, ".T.", ".T.",, .T.)
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) CENTERED	
	
Return
