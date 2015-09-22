/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Manutenção 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contabil												 !
+------------------+---------------------------------------------------------+
!Nome 			   ! PARAMFINFIS 											 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Modificação de Parâmetros Financeiro/Fiscal			 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima		 									 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/03/2015												 !
+------------------+---------------------------------------------------------+
! ATUALIZACOES 	   															 !
+-------------------------------------------+-----------+-----------+--------+
! Descricao detalhada da atualizacao 		!Nome do    ! Analista  !Data da !
! 											!Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											! 			! 			! 		 !
! 											! 			! 			! 		 !
+-------------------------------------------+-----------+-----------+--------*/

#Include "Protheus.ch"

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ALTPAR    ! Autor !Gilson Lima 		 ! Data ! 03/03/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Tela de chamada da rotina de Modificação dos Parâmetros		 !
! 			! MV_DATAFIN E MV_DATAFIS										 !
+----------------------------------------------------------------------------*/
User Function AltPar()

	Local	lDataOk		:= .F.

	Private cPerg	:= Padr("PRFINFIS",10)
	Private aPergs	:= {}
	
	//cria as peguntas se não existe
	CriaSX1(cPerg)
	Pergunte(cPerg,.T.)	

	If AllTrim(DtoS(MV_PAR01)) != '' .And. Dow(MV_PAR01) > 0
		lDataOk	:= .T.
	EndIf
	
	If AllTrim(DtoS(MV_PAR02)) != '' .And. Dow(MV_PAR02) > 0
		lDataOk := .T.
	EndIf
	
	If lDataOk
		//Chama função geração de títulos
		If MsgYesNo("Confirma Alteração de Parâmetros?","Atenção")
			Processa({||U_APFINFIS()}) 
		Endif 
	Else
		Alert("Nenhuma data válida!")
		Return
	EndIf

Return Nil

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! APFINFIS  ! Autor !Gilson Lima 		 ! Data ! 03/03/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Rotina de Modificação dos Parâmetros							 !
! 			! MV_DATAFIN E MV_DATAFIS										 !
+----------------------------------------------------------------------------*/
User Function APFINFIS()

	Local lAltera	:= .F.
	Local dDataFin	:= MV_PAR01
	Local dDataFis	:= MV_PAR02

	If AllTrim(DtoS(dDataFin)) != '' .And. Dow(dDataFin) > 0
		PutMV("MV_DATAFIN",dDataFin)
		lAltera := .T.	
	EndIf

	If AllTrim(DtoS(dDataFis)) != '' .And. Dow(dDataFis) > 0
		PutMV("MV_DATAFIS",dDataFis)	
		lAltera := .T.	
	EndIf
	
	If lAltera	
		MsgInfo("Alteração efetuada com sucesso!")
	Else
		MsgInfo("Nenhuma alteração efetuada!")
	EndIf

Return


/*
+------------------+---------------------------------------------------------+
!Nome              ! CriaSX1                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Funcao para cricao dos parametros                       !
+------------------+---------------------------------------------------------+
*/
static Function CriaSX1(cPerg)

//MV_DATAFIN
PutSx1(cPerg,"01","MV_DATAFIN","MV_DATAFIN","MV_DATAFIN","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"Data para Ajuste do Parâmetro MV_DATAFIN."," Bloqueio de Lançamentos Financeiros","",""},{"","","",""},{"","",""},"")
//MV_DATAFIN
PutSx1(cPerg,"02","MV_DATAFIS","MV_DATAFIS","MV_DATAFIS","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{"Data para Ajuste do Parâmetro MV_DATAFIS."," Bloqueio de Lançamentos Fiscais","",""},{"","","",""},{"","",""},"")

Return
