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
!Nome 			   ! COHAPAR_CONTRATOS_ATUALIGESTOR.PRW						 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Contratos - Atualização de Gestores					 !
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
! Programa 	! AtGestor  ! Autor !Gilson Lima 		 ! Data ! 29/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualização de Gestores										 !
!			!  																 !
+----------------------------------------------------------------------------*/
User Function AtGestor()

	Local aCtr 		:= {}
	Local lExiste 	:= .F.

	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	
	While CN9->(!EOF())
	
		If AllTrim(CN9->CN9_XCDRES) != ''
			
			lExiste := .F.
			
			For nA := 1 To Len(aCtr)
			
				If aCtr[nA] == CN9->CN9_NUMERO
					lExiste := .T.
					Exit
				EndIf
			Next nA
			
			If !lExiste
				RecLock('SZP',.T.)
				
					SZP->ZP_FILIAL	:= xFilial('SZP')
					SZP->ZP_FLCONTR	:= CN9->CN9_FILIAL
					SZP->ZP_NRCONTR	:= CN9->CN9_NUMERO
					SZP->ZP_CDUSR	:= CN9->CN9_XCDRES
					SZP->ZP_NMUSR	:= POSICIONE('SZI',1,xFilial('SZI')+CN9->CN9_XCDRES,'ZI_NOME')
					SZP->ZP_TPUSR	:= CN9->CN9_XXTR
					SZP->ZP_ATIVO	:= 'S'
					SZP->ZP_DTATIVO := CN9->CN9_DTINIC
					SZP->ZP_DTALTER	:= DATE()
					SZP->ZP_HRALTER := TIME()
					SZP->ZP_USRALTE := '000000 - Administrador'
				
				SZP->(MsUnLock())
				
				aAdd(aCtr,CN9->CN9_NUMERO)
				
			EndIf		
		EndIf
		CN9->(dbSkip())
	EndDo
	
	Alert('Atualização concluída!')

Return