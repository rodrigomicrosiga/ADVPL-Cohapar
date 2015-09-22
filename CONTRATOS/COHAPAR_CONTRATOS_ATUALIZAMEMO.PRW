/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contratos 												 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_CONTRATOS_ATUALIZAMEMO.PRW						 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para atualização do campo MEMO de contratos	 !
!				   ! importados												 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/04/2015												 !
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
! Programa 	! ATMEMOCT	! Autor !Gilson Lima 		 ! Data ! 18/09/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Programa para atualização do campo MEMO de contratos			 !
!			! importados													 !
+----------------------------------------------------------------------------*/
User Function ATMEMOCT()

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	CN9->(dbGoTop());
	
	nContLidos := 0
	nContAtual := 0
	
	While CN9->(!EOF())
		
		nContLidos++
		
		If AllTrim(CN9->CN9_XHIST) != ''
			
			nContAtual++
			
			cString := AllTrim(CN9->CN9_XHIST) + " " + AllTrim(CN9->CN9_XOBS)
			
			cMemo := MSMM(,,,cString,1,,,"CN9","CN9_CODOBJ")
		EndIf
	
		CN9->(dbSkip())
	End
	
	CN9->(dbCloseArea())
	
	Alert('Operação Executada: '+cValToChar(nContLidos) + ' Registros Lidos - '+cValToChar(nContAtual)+' Registros Atualizados')	
	
Return