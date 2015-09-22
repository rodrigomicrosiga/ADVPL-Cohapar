/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Financeiro 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_CNABCEF_XFUN.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Rotina para retorno de informações de conta CNB CEF	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 06/07/2015												 !
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
! Programa 	! RetCC		! Autor !Gilson Lima 		 ! Data ! 06/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Retorna informação Nr e Dig conta baseado na Opção escolhida	 !
!			! nOpc 1 = Conta, nOpc 2 = Digito								 !
+----------------------------------------------------------------------------*/
User Function RetCC(nOpc)
	
	Local cNrConta	:= ''
	Local cDvCta	:= ''
	Local cRet		:= ''
	
	If AT("-",SEA->EA_NUMCON) != 0
		cNrConta := STRZERO(VAL(STRTRAN(SUBS(SEA->EA_NUMCON,1,AT("-",SEA->EA_NUMCON)-1),".","0000")),12)
		cDvCta   := SUBS(SEA->EA_NUMCON,AT("-",SEA->EA_NUMCON)+1,1)
	Else
		cNrConta := STRZERO(VAL(SEA->EA_NUMCON),12)
		cDvCta   := POSICIONE("SEE",1,xFilial('SEE')+'3167 '+SEA->EA+NUMCON+'001',"EE_DVCTA")
	EndIF

	cRet := IIf(nOpc == 1; cNrConta; cDvCta)

Return cRet