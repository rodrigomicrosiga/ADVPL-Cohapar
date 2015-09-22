/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualiza��o 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Financeiro 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_PE_MATA100.PRW							 	     !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Inclus�o do Tipo Doc Fiscal na SE2 no cadastro da NF	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 26/05/2015												 !
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
! Programa 	! MT103FIM  ! Autor !Gilson Lima 		 ! Data ! 26/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Executa ao final da inclus�o da NF a defini��o do Tipo Doc TCE !
!			! 																 !
+----------------------------------------------------------------------------*/

User Function MT103FIM()  

	Local aArea		:= GetArea()  
	Local cTitulo	:= xFilial('SE2') + SF1->F1_SERIE + SF1->F1_DOC
	
	Local nOpcao	:= PARAMIXB[1]   
	Local nConfirma	:= PARAMIXB[2] // Op��o Escolhida pelo usuario no aRotina
	
	// 3 inclusao
	// 1 confirma  
 
	If nConfirma = 1
		While xFilial('SE2') + SE2->E2_PREFIXO + SE2->E2_NUM = cTitulo    	
		    
		    Do Case
		    	Case AllTrim(SE2->E2_TIPO) == 'NF'
		    		cCdTipo := '42'
		    	Case AllTrim(SE2->E2_TIPO) == 'SP'
		    		cCdTipo := '43'
		    	Otherwise
		    		cCdTipo := '43'
		    EndCase
		    
			RecLock('SE2', .F.)
	
				SE2->E2_XCODTP := cCdTipo
	
			SE2->(MsUnlock())
		                        
			SE2->(DbSkip())
		
		EndDo
	EndIf  

	RestArea(aArea)

Return