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
!Nome 			   ! COHAPAR_CONTRATOS_ATUALIZANR.PRW						 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Funções Auxiliares para Atualização NR Contrato		 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 12/06/2015												 !
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
! Programa 	! AtuNmCtr	! Autor !Gilson Lima 		 ! Data ! 11/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Numeração de contratos baseado no Tipo de Contrato	 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function AtuNmCtr()

	Local cNrAnter 	:= ''
	Local cCtrAnter	:= ''
	Local cNrCTR	:= ''
	Local cTipo		:= ''
	Local cAno		:= ''
	
	ProcRegua(6000)

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	
	While CN9->(!EOF())
	
		IncProc() // Incrementa a régua
	
		// Caso não possua Cod. Instrumento, pula registro
		If Val(CN9->CN9_XCDINS) == 0
			cNrAnter := CN9->CN9_NUMERO
			CN9->(dbSkip())
			Loop
		EndIf
		
		// Caso já o Nr já esteja no novo formato, pula registro
		If Len(Separa(CN9->CN9_NUMERO,"/",.T.)) == 3
			cNrAnter := CN9->CN9_NUMERO
			CN9->(dbSkip())
			Loop
		EndIf
		
		// Se for um aditivo, estará com o mesmo número anterior, portanto é só replicar o nr
		If CN9->CN9_NUMERO == cNrAnter
			// Atribui o Nr do Contrato Atualizado
			cNrCTR := cCtrAnter
		Else
			If AllTrim(CN9->CN9_REVISA) == ''
				// Atribui o novo Nr. Anterior
				cNrAnter := CN9->CN9_NUMERO
				
				// Atribui o Nr baseado no Código do Instrumento
				cNumero := StrZero(Val(CN9->CN9_XCDINS),5)
				cPrefix := AllTrim(POSICIONE("CN1",1,xFilial('CN1')+CN9->CN9_TPCTO, "CN1_XTPDES"))
				cAno	:= Substr(DtoS(CN9->CN9_DTASSI),1,4)
				
				If AllTrim(cPrefix) == ''
					cPrefix := 'GEN'
				EndIf
				
				If AllTrim(cAno) == ''
					cAno	:= '9999'
				EndIf
				
				// Atribui os dados contratos
				cNrCTR 		:= cNumero + "/" + cPrefix + "/" + cAno
				cCtrAnter 	:= cNrCTR
				
			EndIf
		EndIF
		
		// Grava Novo Nr Contratos nas tabelas correspondentes
		
		// CN9 - Contratos
		//RecLock("CN9",.F.)
		//	CN9->CN9_NUMERO := cNrCTR
		//MsUnLock()
		
		If AllTrim(CN9->CN9_REVISA) == '' 
	
			// CN9 - Contratos
			GravaCTR('CN9',cNrAnter,cNrCTR)
	
			// CN8 - Calções
			GravaCTR('CN8',cNrAnter,cNrCTR)
	
			// CNC - Fornecedor x Contratos
			GravaCTR('CNC',cNrAnter,cNrCTR)
		
			// CNN - Usuários x Contratos
			GravaCTR('CNN',cNrAnter,cNrCTR)

		EndIf
	
		CN9->(dbSkip())
	EndDo
	
	CN9->(dbCloseArea())
	
	Alert("Concluído Alteração de Nr. Contratual")

Return 

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! GravaCTR	! Autor !Gilson Lima 		 ! Data ! 12/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Numeração de contratos baseado nas respectivas tabelas!
!			! 																 !
+----------------------------------------------------------------------------*/
Static Function GravaCTR(cTabela,cNrAnter,cNrCTR,cTpCto)

	Local aArea := GetArea()
	
	Do Case
		Case cTabela == 'CN9'
	
			While .T.
				CN9->(dbSelectArea('CN9'))
				CN9->(dbSetOrder(1))
				If CN9->(dbSeek(xFilial('CN9')+cNrAnter))
					While CN9->(!EOF()) .And. CN9->CN9_NUMERO == cNrAnter
						RecLock("CN9",.F.)
							CN9->CN9_NUMERO := cNrCTR
						MsUnLock()
						CN9->(dbSkip())
					EndDo
				Else
					CN9->(dbCloseArea())
					Exit
				EndIF
			EndDo	
			
		Case cTabela == 'CN8'
	
			dbSelectArea('CN8')
			CN8->(dbSetOrder(2))
			If CN8->(dbSeek(xFilial('CN8')+cNrAnter))
				While CN8->(!EOF()) .And. CN8->CN8_CONTRA == cNrAnter
					RecLock("CN8",.F.)
						CN8->CN8_CONTRA := cNrCTR
					MsUnLock()
					CN8->(dbSkip())
				EndDo
			EndIF
			CN8->(dbCloseArea())	
		
		Case cTabela == 'CNC'

			dbSelectArea('CNC')
			CNC->(dbSetOrder(1))
			If CNC->(dbSeek(xFilial('CNC')+cNrAnter))
				While CNC->(!EOF()) .And. CNC->CNC_NUMERO == cNrAnter
					RecLock("CNC",.F.)
						CNC->CNC_NUMERO := cNrCTR
					MsUnLock()
					CNC->(dbSkip())
				EndDo
			EndIF
			CNC->(dbCloseArea())	
		
		Case cTabela == 'CNN'

			dbSelectArea('CNN')
			CNN->(dbSetOrder(1))
			If CNN->(dbSeek(xFilial('CNN')+'000000'+cNrAnter))
				While CNN->(!EOF()) .And. CNN->CNN_CONTRA == cNrAnter
					RecLock("CNN",.F.)
						CNN->CNN_CONTRA := cNrCTR
					MsUnLock()
					CNN->(dbSkip())
				EndDo
			EndIF
			CNN->(dbCloseArea())	
	EndCase
	
	RestArea(aArea)
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! AtuRev	! Autor !Gilson Lima 		 ! Data ! 12/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Numeração de contratos baseado nas respectivas tabelas!
!			! 																 !
+----------------------------------------------------------------------------*/
User Function AtuRev()

	Local aDados := {}
	Local lAltera := .F.
	Local nAlter := 0
	
	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	
	While CN9->(!EOF())
		
		lAltera := .F.
		
		If Val(CN9->CN9_XCDINS) == 0
			CN9->(dbSkip())
			Loop
		EndIf
		
		For nA := 1 To Len(aDados)
		
			If aDados[nA][1] == CN9->CN9_XCDINS .And. aDados[nA][2] == CN9->CN9_REVISA .And. aDados[nA][3] == CN9->CN9_TPCTO
				lAltera := .T.
				Exit
			EndIf
		Next nA
		
		If lAltera
			
			nAlter++
		
			cQuery := "SELECT MAX(CN9.CN9_REVISA) AS NRATUAL "
			cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
			cQuery += " WHERE CN9.CN9_XCDINS = '" + CN9->CN9_XCDINS + "'"
			cQuery += " AND CN9.CN9_TPCTO= '" + CN9->CN9_TPCTO + "'"
			
			If Select('TRB') <> 0
				dbSelectArea('TRB')
				TRB->(dbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
			 
			cRevisa := StrZero(Val(TRB->NRATUAL) + 1,3)
			
			RecLock("CN9",.F.)
			
				CN9->CN9_REVISA := cRevisa
				
			MsUnLock()
		EndIf

		aAdd(aDados,{;
			CN9->CN9_XCDINS,;
			CN9->CN9_REVISA,;
			CN9->CN9_TPCTO;
		})
	
		CN9->(dbSkip())
	
	EndDo
	
	CN9->(dbCloseArea())
	
	Alert("Concluído! " + cValToChar(nAlter) + " registros alterados.")

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! AtuCNC	! Autor !Gilson Lima 		 ! Data ! 12/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Numeração de contratos baseado nas respectivas tabelas!
!			! 																 !
+----------------------------------------------------------------------------*/
User Function AtuCNC()

	Local nCont := 0
	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	CN9->(dbGoTop())
	
	While CN9->(!EOF())
	
		dbSelectArea('CNC')
		CNC->(dbSetOrder(1))
		CNC->(dbGoTop())
		
		While CNC->(!EOF())
		
			If CNC->CNC_NUMERO == CN9->CN9_XNRANT
				nCont++
				
				RecLock("CNC",.F.)
					CNC->CNC_NUMERO := CN9->CN9_NUMERO
				MsUnLock()			
			EndIf
			
			CNC->(dbSkip())
		
		EndDo
		
		CNC->(dbCloseArea())
		
		CN9->(dbSkip())
	EndDO
	
	
	CN9->(dbCloseArea())
	
	ALERT('ATUALIZACAO OK: ' + cValToChar(nCont) + ' Registros .')

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! AtuCN8	! Autor !Gilson Lima 		 ! Data ! 12/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Numeração de contratos baseado nas respectivas tabelas!
!			! 																 !
+----------------------------------------------------------------------------*/
User Function AtuCN8()

	Local nCont := 0
	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	CN9->(dbGoTop())
	
	While CN9->(!EOF())
	
		dbSelectArea('CN8')
		CN8->(dbSetOrder(2))
		CN8->(dbGoTop())
		
		While CN8->(!EOF())
		
			If CN8->CN8_CONTRA == CN9->CN9_XNRANT
				nCont++
				
				RecLock("CN8",.F.)
					CN8->CN8_CONTRA := CN9->CN9_NUMERO
				MsUnLock()			
			EndIf
			
			CN8->(dbSkip())
		
		EndDo
	
		CN8->(dbCloseArea())
		
		CN9->(dbSkip())
	EndDO
	
	
	CN9->(dbCloseArea())
	
	ALERT('ATUALIZACAO OK: ' + cValToChar(nCont) + ' Registros .')

Return