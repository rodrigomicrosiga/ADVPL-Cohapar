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
!Nome 			   ! COHAPAR_CONTRATOS_ATPLANILHA.PRW						 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para Atualização de Planilhas nos contratos	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/07/2015												 !
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
! Programa 	! AtuPlan 	! Autor !Gilson Lima 		 ! Data ! 17/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Planilhas											 !
!			! 																 !
+----------------------------------------------------------------------------*/

User Function AtuPlan()

	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	
	While CN9->(!EOF())
	
		If CN9->CN9_DTINIC >= StoD('20150701') // CN9->CN9_SITUAC != '02' .Or. 
			CN9->(dbSkip())
			Loop
		EndIf
		
		// Grava Cabeçalho Planilha
		RecLock('CNA',.T.)
		
			CNA->CNA_FILIAL	:= CN9->CN9_FILIAL
			CNA->CNA_CONTRA	:= CN9->CN9_NUMERO
			CNA->CNA_NUMERO	:= '000001'
			CNA->CNA_REVISA	:= CN9->CN9_REVISA
			CNA->CNA_FORNEC := POSICIONE('CNC',1,CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA,'CNC_CODIGO')
			CNA->CNA_LJFORN := POSICIONE('CNC',1,CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA,'CNC_LOJA')
			CNA->CNA_DTINI	:= CN9->CN9_DTINIC
			CNA->CNA_VLTOT	:= CN9->CN9_VLATU
			CNA->CNA_SALDO	:= CN9->CN9_VLATU
			CNA->CNA_TIPPLA	:= '006'
			CNA->CNA_DTFIM	:= CN9->CN9_DTFIM
			CNA->CNA_FLREAJ	:= CN9->CN9_FLGREJ
		
		CNA->(MsUnLock())
		
		// Grava Ítem de Planilha
		RecLock('CNB',.T.)
		
			CNB->CNB_FILIAL	:= CN9->CN9_FILIAL
			CNB->CNB_NUMERO	:= '000001'
			CNB->CNB_REVISA	:= CN9->CN9_REVISA
			CNB->CNB_ITEM	:= '001'
			CNB->CNB_PRODUT	:= '00824'
			CNB->CNB_DESCRI	:= POSICIONE('SB1',1,CN9->CN9_FILIAL+'00824','B1_DESC')
			CNB->CNB_UM		:= POSICIONE('SB1',1,CN9->CN9_FILIAL+'00824','B1_UM')
			CNB->CNB_QUANT	:= 1
			CNB->CNB_VLUNIT := CN9->CN9_VLATU
			CNB->CNB_VLTOT	:= CN9->CN9_VLATU
			CNB->CNB_CONTRA	:= CN9->CN9_NUMERO
			CNB->CNB_DTCAD	:= CN9->CN9_DTINIC
			CNB->CNB_SLDMED	:= 1
			CNB->CNB_SLDREC	:= 1
			CNB->CNB_GERBIN	:= '2'
			CNB->CNB_BASINS	:= '2'
			CNB->CNB_FILORI	:= '01'
			
		CNB->(MsUnLock())
	
		CN9->(dbSkip())
	EndDo
	
	CN9->(dbCloseArea())
	
	Alert('Concluído Atualização de Planilhas')

Return