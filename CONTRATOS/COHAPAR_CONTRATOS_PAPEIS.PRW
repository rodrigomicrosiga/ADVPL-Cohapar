/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualiza��o 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contrato	 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_CONTRATOS_PAPEIS.PRW							 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Contratos - Papeis									 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 24/07/2015												 !
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
! Programa 	! APapCTR   ! Autor !Gilson Lima 		 ! Data ! 27/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Altera��o de Pap�is do Contrato								 !
!			!  																 !
+----------------------------------------------------------------------------*/
User Function APapCTR(cAlias,nReg,nOpc)

	Local aArea := GetArea()

	Local oDlg
	Local oGet
	Local nOpcA	:= 0
	Local nOpc := 4

	Local cNrContr  := CN9->CN9_NUMERO
	Local cFilContr := CN9->CN9_FILIAL

	Local cWhile 	:= "SZP->ZP_FILIAL+SZP->ZP_FLCONTR+SZP->ZP_NRCONTR"
	Local cChave 	:= xFilial("SZP")+cFilContr+cNrContr
	Local cQuery	:= ''	
	
	Local aCampos	:= {"ZP_CDUSR","ZP_NMUSR","ZP_TPUSR","ZP_DSTPUSR","ZP_ATIVO","ZP_DTATIVO","ZP_DTDESAT","ZP_JUSTIFI"}
	
	Private aHeader	:= {}
	Private aCols	:= {}
	
	Private aGets	:= {}
	Private aTela	:= {}
	Private aREG	:= {}
	
	// Monta aHeader e aCols para a Grid de Integrantes
	FillGetDados(nOpc,'SZP',1,cChave,{|| &cWhile },,,aCampos,.T.,,,.F.,@aHeader,@aCols,,,,'SZPTRB')

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 500,1000 OF oMainWnd PIXEL

		@ 10,04 SAY OemToansi("N�mero do Contrato:") SIZE 73, 8 OF oDlg PIXEL
		@ 10,60 SAY OemToansi(CN9->CN9_NUMERO) SIZE 73, 8 OF oDlg PIXEL
		
		oGet := MsGetDados():New(40,04,230,500, nOpc, "U_LinOk(n)", ".T.",, .T.,,,,,,,,"U_DelOk(n)")
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF(TudoOk(),(nOpca := 1, oDlg:End()), NIL)},{|| oDlg:End()}) CENTERED	
	
	If nOpcA == 1 .And. (nOpc == 4 .Or. nOpc == 5)
		Grava(nOpc, cNrContr, cFilContr)
	EndIf	
	
	RestArea(aArea)
	
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! Grava		! Autor !Gilson Lima 		 ! Data ! 27/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao para grava��o dos dados nas tabelas					 !
+----------------------------------------------------------------------------*/
Static Function Grava(nOpc, cNrContr, cFilContr)
	
	Local aArea := GetArea()
	
	// Usu�rio que est� efetuando a manuten��o
	Local cUsrManut	:= cValToChar(RetCodUsr()) + ' - ' + UsrFullName(RetCodUsr())
	
	// Data e Hora de Altera��o
	Local dDtAlter  := Date()
	Local cHrAlter  := Time()
	
	Local lAltera	:= .F.

	If nOpc == 4	// Altera��o

		// Grava �tens Se o aCols n�o estiver vazio
		If AllTrim(aCols[1][1]) != ''		
				
			For nX := 1 To Len(aCols)

				// Tabela SZP = Pap�is
				dbSelectArea("SZP")
				SZP->(dbSetOrder(1))

				//*******************************
				//* Se o Registro estiver exclu�do
				//*******************************
				If aCols[nX][Len(aCols[nX])] == .T. 
					
					// Se estiver exclu�do, mas ainda n�o houver sido gravado no BD, ignora
					If aCols[nX][(Len(aCols[nX]) - 1)] == 0
						SZP->(dbCloseArea())
						Loop
					EndIf
					
					// Vai para o registro correspondente
					SZP->(dbGoTo(aCols[nX][(Len(aCols[nX]) - 1)]))

					// Atualiza dados de desativa��o
					RecLock("SZP",.F.)
						SZP->ZP_ATIVO	:= aCols[nX,GdFieldPos("ZP_ATIVO")]
						SZP->ZP_DTDESAT	:= aCols[nX,GdFieldPos("ZP_DTDESAT")]					
					SZP->(MsUnLock())
						
				//*******************************
				//* Se for inclus�o
				//*******************************
				ElseIf aCols[nX][(Len(aCols[nX]) - 1)] == 0	
					
					// Inclui registro
					RecLock("SZP",.T.)
					
						SZP->ZP_FILIAL	:= xFilial("SZP")
						SZP->ZP_FLCONTR	:= cFilContr
						SZP->ZP_NRCONTR	:= cNrContr
						SZP->ZP_CDUSR	:= aCols[nX,GdFieldPos("ZP_CDUSR")]
						SZP->ZP_NMUSR	:= aCols[nX,GdFieldPos("ZP_NMUSR")]
						SZP->ZP_TPUSR	:= aCols[nX,GdFieldPos("ZP_TPUSR")]
						SZP->ZP_ATIVO	:= aCols[nX,GdFieldPos("ZP_ATIVO")]
						SZP->ZP_DTATIVO	:= aCols[nX,GdFieldPos("ZP_DTATIVO")]
						SZP->ZP_DTDESAT	:= aCols[nX,GdFieldPos("ZP_DTDESAT")]
						SZP->ZP_JUSTIFI	:= aCols[nX,GdFieldPos("ZP_JUSTIFI")]
						SZP->ZP_DTALTER	:= dDtAlter
						SZP->ZP_HRALTER	:= cHrAlter
						SZP->ZP_USRALTE	:= cUsrManut
					
					SZP->(MsUnlock())
					
				//*******************************
				//* Se for Altera��o
				//*******************************
				Else
					
					// Vai para o registro correspondente
					SZP->(dbGoTo(aCols[nX][(Len(aCols[nX]) - 1)]))
					
					//Verifica se houve alguma altera��o nos dados
					lAltera := .F.
					
					If SZP->ZP_CDUSR != aCols[nX,GdFieldPos("ZP_CDUSR")]
						lAltera := .T.
					EndIf
					If SZP->ZP_NMUSR != aCols[nX,GdFieldPos("ZP_NMUSR")]
						lAltera := .T.
					EndIf
					If SZP->ZP_TPUSR != aCols[nX,GdFieldPos("ZP_TPUSR")]
						lAltera := .T.
					EndIf
					If SZP->ZP_ATIVO != aCols[nX,GdFieldPos("ZP_ATIVO")]
						lAltera := .T.
					EndIf
					If SZP->ZP_DTATIVO != aCols[nX,GdFieldPos("ZP_DTATIVO")]
						lAltera := .T.
					EndIf
					If SZP->ZP_DTDESAT != aCols[nX,GdFieldPos("ZP_DTDESAT")]
						lAltera := .T.
					EndIf
					If SZP->ZP_JUSTIFI != aCols[nX,GdFieldPos("ZP_JUSTIFI")]
						lAltera := .T.
					EndIf
					
					// Caso haja alguma informa��o diferente, grava a altera��o
					If lAltera
					
						// Altera registro
						RecLock("SZP",.F.)
						
							SZP->ZP_FILIAL	:= xFilial("SZP")
							SZP->ZP_FLCONTR	:= cFilContr
							SZP->ZP_NRCONTR	:= cNrContr
							SZP->ZP_CDUSR	:= aCols[nX,GdFieldPos("ZP_CDUSR")]
							SZP->ZP_NMUSR	:= aCols[nX,GdFieldPos("ZP_NMUSR")]
							SZP->ZP_TPUSR	:= aCols[nX,GdFieldPos("ZP_TPUSR")]
							SZP->ZP_ATIVO	:= aCols[nX,GdFieldPos("ZP_ATIVO")]
							SZP->ZP_DTATIVO	:= aCols[nX,GdFieldPos("ZP_DTATIVO")]
							SZP->ZP_DTDESAT	:= aCols[nX,GdFieldPos("ZP_DTDESAT")]
							SZP->ZP_JUSTIFI	:= aCols[nX,GdFieldPos("ZP_JUSTIFI")]
							SZP->ZP_DTALTER	:= dDtAlter
							SZP->ZP_HRALTER	:= cHrAlter
							SZP->ZP_USRALTE	:= cUsrManut
						
						SZP->(MsUnlock())
						
					EndIf
					
				EndIf	
				
				SZP->(dbCloseArea())	
							
			Next nX
				
		EndIf
		
	EndIf
		
	RestArea(aArea)
	
Return


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! LinOk		! Autor !Gilson Lima 		 ! Data ! 27/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Valida��o das linhas do Grid									 !
+----------------------------------------------------------------------------*/
User Function LinOk(nPos)
	
	Local lRet		:= .T.
	
Return(lRet)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! TudoOk	! Autor !Gilson Lima 		 ! Data ! 27/11/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Valida��o Final da Tela de Cadastro							 !
+----------------------------------------------------------------------------*/
Static Function TudoOk()
	
	Local lRet		:= .T.
	
Return(lRet)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! DelOk		! Autor !Gilson Lima 		 ! Data ! 27/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Valida��o na exclus�o do dependente							 !
+----------------------------------------------------------------------------*/
User Function DelOk(n)
	
	Local lRet	:= .F.
	
	// Verifica se est� excluindo um registro rec�m inserido (ainda n�o gravado) 
	// e caso n�o seja, informa que n�o � poss�vel excluir
	If aCols[n][(Len(aCols[n]) - 1)] == 0
	
		lRet := .T.

	// Informa que n�o � poss�vel excluir o usu�rio e confirma se deve inativ�-lo
	ElseIf MsgYesNo("Para efeito de hist�rico, n�o � poss�vel excluir. Deseja inserir a data atual no campo de data de desativa��o e inativ�-lo?","Aten��o")
		If AllTrim(DtoS(aCols[n,GdFieldPos("ZP_DTDESAT")])) == ""
			aCols[n,GdFieldPos("ZP_DTDESAT")] 	:= dDataBase
			aCols[n,GdFieldPos("ZP_ATIVO")] 	:= 'N'
			lRet := .T.
		Else
			alert("Dependente j� possui data de t�rmino.")
		EndIf
	EndIf
	
Return(lRet)