/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Gestão Pessoal 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_PE_GPEM670.PRW							 	     !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Pontos de entrada da rotina de geração de titulos a     !
!                  ! pagar via GPE - GPEM670								 !
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
! Programa 	! GP670CPO  ! Autor !Gilson Lima 		 ! Data ! 26/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Executa ao final da inclusão do título a definição do Tipo Doc !
!			! TCE															 !
+----------------------------------------------------------------------------*/

User Function GP670CPO()

    Do Case
    	Case AllTrim(SE2->E2_TIPO) == '2FG'
    		cCdTipo := '09'
    	Case AllTrim(SE2->E2_TIPO) == '2FP'
    		cCdTipo := '09'
    	Case AllTrim(SE2->E2_TIPO) == '2IN'
    		cCdTipo := '28'
    	Case AllTrim(SE2->E2_TIPO) == '3CO'
    		cCdTipo := '28'
    	Case AllTrim(SE2->E2_TIPO) == '3CS'
    		cCdTipo := '28'
    	Case AllTrim(SE2->E2_TIPO) == '3IR'
    		cCdTipo := '09'
    	Otherwise
    		cCdTipo := '09'
    EndCase	

	RecLock('SE2', .F.)

		SE2->E2_XCODTP := cCdTipo

	SE2->(MsUnlock())	

Return