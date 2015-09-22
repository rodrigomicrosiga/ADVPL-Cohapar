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
!Nome 			   ! COHAPAR_PE_ATUALVALOR.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Atualiza valores Iniciais e Saldo de contratos/revisões !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 21/07/2015												 !
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
! Programa 	! ATVLCTR	! Autor !Gilson Lima 		 ! Data ! 21/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza valores de contratos e aditivos						 !
!			! 										 						 !
+----------------------------------------------------------------------------*/
User Function ATVLCTR()

	Local cCtrAnt := ''
	Local nVlInic := 0
	Local nVlAtual:= 0
	Local nVlAdt  := 0
	
	dbSelectArea('CN9')
	CN9->dbSetOrder(1)
	
	While CN9->(!EOF())
	
		If AllTrim(CN9->CN9_REVISA) == ''

			cCtrAnt := CN9->CN9_NUMERO
		
			If CN9->CN9_VLINI == 0
				CN9->(dbSkip())
				Loop
			EndIf
			
			nVlInic := CN9->CN9_VLINI
			
			RecLock('CN9',.F.)
				CN9->CN9_VLATU := CN9->CN9_VLINI
				CN9->CN9_SALDO := CN9->CN9_VLINI
			CN9->(MsUnLock())
			
			CN9->(dbSkip())
			Loop
			
		EndIf
		
		If CN9->CN9_NUMERO == cCtrAnt
		
			If CN9->CN9_VLINI > nVlInic
				
				
				
			EndIf
			
		
		EndIf
		
		
	EndDo
	
	CN9->(dbCloseArea())

Return