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
!Nome 			   ! COHAPAR_CONTRATOS_XFUN.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Fun��es Auxiliares para Contratos						 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 11/06/2015												 !
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
! Programa 	! GeraNmCtr	! Autor !Gilson Lima 		 ! Data ! 11/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Gera Numera��o de contratos baseado no Tipo de Contrato		 !
!			! Vari�vel Global: cCodigo										 !
+----------------------------------------------------------------------------*/

User Function GeraNmCtr()

	Local aArea
	Local cNrRet 	 := ''
	Local cPrefx 	 := ''
	Local cTabSX5	 := 'ZF'
	Local cAnoAtual  := SubStr(DtoS(dDataBase),1,4)
	Local cTpCtr 	 := cCodigo	
	Local cCampoX5Nr := ''
	Local cCampoX5Re := ''
	Local cCampoX5An := ''
	Local cNr 		 := ''
	Local cNovoNr	 := ''
	Local cReinicia  := ''
	Local cAno 		 := ''

	// Verifica o Tipo de Contrato
	If CN1->(dbSeek(xFilial('CN1')+cTpCtr))
		
		cPrefx := AllTrim(CN1->CN1_XTPDES)
		cCampoX5Nr := cPrefx + 'NR'
		cCampoX5Re := cPrefx + 'RE'
		cCampoX5An := cPrefx + 'AN'
		
		cNr 		:= AllTrim(POSICIONE('SX5',1,xFilial('SX5')+cTabSX5+cCampoX5Nr,'X5_DESCRI'))
		cReinicia 	:= AllTrim(POSICIONE('SX5',1,xFilial('SX5')+cTabSX5+cCampoX5Re,'X5_DESCRI'))
		cAno 		:= AllTrim(POSICIONE('SX5',1,xFilial('SX5')+cTabSX5+cCampoX5An,'X5_DESCRI'))
		
		If cNr != ''
			
			// Numera��o Reinicia Anualmente
			If cReinicia == 'S' 
				// Se o Ano for menor que ano atual
				// atribui o 000001
				If cAnoAtual > cAno
					cNr	    := '00001'
				EndIf
			EndIf

		// Caso n�o encontre na SX5, utiliza informa��es Gen�ricas	
		Else
			cPrefx  := 'GEN'
			cNr 	:= StrZero(Val(GETSXENUM('CN9','CN9_NUMERO')),5)
		EndIf
	EndIf
	
	cNrRet := cNr + "/" + cPrefx + "/" + cAnoAtual
	
Return cNrRet