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
!Nome 			   ! COHAPAR_CONTRATOS_AJUSTAFORN.PRW						 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Contratos: Ajusta fornecedores no campo customizado	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 31/07/2015												 !
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
! Programa 	! AtForn2   ! Autor !Gilson Lima 		 ! Data ! 23/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza data Final do Contrato								 !
!			! 										 						 !
+----------------------------------------------------------------------------*/
User Function AtForn2()

	dbSelectArea('CNC')
	CNC->(dbSetOrder(1))
	
	While CNC->(!EOF())
	
		If AllTrim(CNC->CNC_REVISA) == ''
		
			dbSelectArea('CN9')
			CN9->(dbSetOrder(1))
			If CN9->(dbSeek(xFilial('CN9')+CNC->CNC_NUMERO+CNC->CNC_REVISA))
			
				While CN9->(!EOF()) .And. CN9->CN9_NUMERO == CNC->CNC_NUMERO
				
					RecLock('CN9',.F.)
						
						CN9->CN9_XCODFN := CNC->CNC_CODIGO
						CN9->CN9_XLOJA	:= CNC->CNC_LOJA
						CN9->CN9_XNMFOR	:= POSICIONE('SA2',1,xFilial('SA2')+CNC->CNC_CODIGO+CNC->CNC_LOJA,'A2_NOME')
					
					CN9->(MsUnLock())
				
					CN9->(dbSkip())
				EndDo
			
			EndIf
			
			CN9->(dbCloseArea())
		
		EndIF
		
		CNC->(dbSkip())
	EndDo
	
	CNC->(dbCloseArea())
	
	Alert('Concluido CNC')
	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	
	While CN9->(!EOF())
	
		cNmForn := ''
	
		If AllTrim(CN9->CN9_XNMFOR) == '' .Or. CN9->CN9_XCODFN == '999999' .Or. CN9->CN9_XCODFN == '888888'
		
			If AllTrim(CN9->CN9_XNFORN) != ''
			
				cNmForn := AllTrim(Separa(CN9->CN9_XNFORN,'|')[2])
				
				If AllTrim(cNmForn) != ''
				
					RecLock('CN9',.F.)
					
						CN9->CN9_XNMFOR	:= cNmForn
						
					CN9->(MsUnLock())
				EndIf
			
			EndIf
		
		EndIf
		
		CN9->(dbSkip())
	EndDo
	
	CN9->(dbCloseArea())
	
	Alert('Concluído CN9')

Return
