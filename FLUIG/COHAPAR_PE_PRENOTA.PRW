/*+--------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualiza��o 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Faturamento 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! PE_PRENOTA 											 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Pontos de Entrada Pr�-Nota								 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima 											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 02/04/2015 											 !
+------------------+---------------------------------------------------------+
! ATUALIZACOES 	   															 !
+-------------------------------------------+-----------+-----------+--------+
! Descricao detalhada da atualizacao 		!Nome do    ! Analista  !Data da !
! 											!Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 									 		! 		 	! 		 	!		 !
! 											! 		 	! 			! 		 !
+-------------------------------------------+-----------+-----------+--------+
! 											! 			! 			! 		 !
! 											! 			! 			! 		 !
+-------------------------------------------+-----------+-----------+--------+
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! SF1140I	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada na Grava��o da Pre-Nota... 					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
User Function SF1140I()

	// MV_TPFLUIG = Par�metro para Especificar os tipos de Doc que ser�o processados pelo Fluig
	Local aTipos := StrToKarr(GETNEWPAR("MC_TPFLUIG",'AF'),';') 
	
	Local cFilMatr := Substr(PswRet()[1][22],3)
	Local cCCusto  := POSICIONE("SRA",1,cFilMatr,"RA_CC")
	
	
	For nA := 1 To Len(aTipos)

		If SF1->F1_ESPECIE == PadR(aTipos[nA],TamSX3("F1_ESPECIE")[1],' ')
		
			// Altera��es da Pr�-Nota
			RecLock("SF1",.F.)
				SF1->F1_STATUS := 'B'		// Grava Status Pr�-Nota com B = Bloqueada
				SF1->F1_XCCLAN := cCCusto	// Grava o CCusto do Usu�rio Lan�ador da Pr�-Nota
			MsUnLock()
		
		EndIf
	Next nA
	
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! MT140FIL	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada Filtro mBrowse Pre-Nota... 					 !
! 			! 																 !
+----------------------------------------------------------------------------*/
User Function MT140FIL()

	Local cFiltro  := ''
	Local lFiltro  := .F.
	
	// Grupos de Usu�rios de Lan�adores do Fluig
	Local aGrpFluig := StrToKarr(GETNEWPAR("MC_GRFLUIG",'000014'),';')
	Local aGrpUser  := PswRet()[1][10]
	
	// Busca CCusto Usu�rio
	Local cFilMatr := Substr(PswRet()[1][22],3)
	Local cCCusto  := POSICIONE("SRA",1,cFilMatr,"RA_CC")
	
	Local lGeraLote := .F.
	
	// Grupo Lancador Fluig
	For nA := 1 To Len(aGrpFluig)
		// Grupos Usu�rio
		For nB := 1 To Len(aGrpUser)

			If aGrpFluig[nA] == aGrpUser[nB] .And. !lFiltro		
				// Filtra mBrowse trazendo apenas Docs do CCusto do Usu�rio
				cFiltro := "F1_XCCLAN = '"+cCCusto+"'"
				
				// Atribui Verdadeiro para n�o filtrar novamente
				lFiltro := .T.
			EndIf		
		Next nB
	Next nA
	
	// Verifica se existem Documentos ainda n�o enviados para aprova��o
	lGeraLote := VGerLote(cCCusto) 
	
	// Caso existam Documentos, pergunta se deseja processar o lote
	If lGeraLote
		If MsgYesNo("Existem NFs deste Centro de Custo a serem enviadas para aprova��o, Deseja enviar agora?","Aten��o")
			// Gera Lote
			U_GeraLote(cCCusto)
		EndIf
	Endif 


Return cFiltro

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! VGerLote	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Fun��o Auxiliar que verifica se existem Lotes a serem gerados  !
! 			! para o Centro de custo do Usu�rio								 !
+----------------------------------------------------------------------------*/
Static Function VGerLote(cCCusto)

	Local lRet 	 := .F.
	Local aArea  := GetArea()
	Local cTipos := StrTran(GETNEWPAR("MC_TPFLUIG",'AF'),";","/") 
	Local cQuery := ''
	Local nQtd	 := 0
	
	cQuery += "SELECT SF1.F1_DOC"
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"
	cQuery += " WHERE SF1.D_E_L_E_T_ <> '*'"
	cQuery += " AND SF1.F1_XLOTE = '" + Space(TamSX3("F1_XLOTE")[1]) + "'"
	cQuery += " AND SF1.F1_XCCLAN = '" + cCCusto + "'"
	cQuery += " AND SF1.F1_ESPECIE IN ('" + cTipos+ "')"
	
	If Select( "SF1TMP" ) <> 0
		dbSelectArea("SF1TMP")
		SF1TMP->(dbCloseArea())
	EndIf            
	
	cQuery := ChangeQuery(cQuery)    
	TcQuery cQuery Alias "SF1TMP" New	
	nQtd := Contar("SF1TMP","!EOF()")	
	
	If nQtd > 0
		lRet := .T.
	EndIf
	
	RestArea(aArea)
	
Return lRet


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! MT140ROT	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada para adicionar fun��es em A��es Relacionadas  !
! 			! tela Pr�-Nota													 !
+----------------------------------------------------------------------------*/
User Function MT140ROT()

	// Grupos de Usu�rios de Lan�adores do Fluig
	Local aGrpFluig := StrToKarr(GETNEWPAR("MC_GRFLUIG",'000014'),';')
	Local aGrpUser  := PswRet()[1][10]	
	
	Local lAcRel := .F.
	
	// Grupo Lancador Fluig
	For nA := 1 To Len(aGrpFluig)
		// Grupos Usu�rio
		For nB := 1 To Len(aGrpUser)
			// Adiciona �tens em A��es Relacionadas
			If aGrpFluig[nA] == aGrpUser[nB] .And. !lAcRel
			
				aAdd(aRotina,{"Gerar Lote de Aprova��o", "U_GeraLote()", 6, 0})
				aAdd(aRotina,{"Relat�rio de Lote de Aprova��o", "U_BRVKPAG001()", 7, 0})
				
				lAcRel := .T.
				
			EndIf
		Next nB
	Next nA

Return(aRotina)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! MT103PN	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada executado na rotina de classifica��o			 !
! 			! Impedir a classifica��o da NF caso esteja em processo de 		 !
! 			! libera��o no Fluig											 !
+----------------------------------------------------------------------------*/
User Function MT103PN()

	Local lRet := .T.

	If SF1->F1_STATUS == 'B'
	
		MsgAlert("Documento em processo de libera��o pelo FLUIG e n�o pode ser Classificado","Aten��o")
		lRet := .F.
	EndIf

Return(lRet)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! A140ALT	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada executado na Altera��o da Pr� Nota			 !
! 			! Modificar Pr�-nota das tabelas Fluig					 		 !
! 			! 																 !
+----------------------------------------------------------------------------*/
User Function A140ALT()
	
	Local aAreaSD1  := GetArea("SD1")
	Local aAreaSF1  := GetArea("SF1")
	Local cChave	:= SF1->F1_FILIAL+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_ESPECIE+SF1->F1_FORNECE 
	Local cChaveSF1 := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

	DBSelectArea("ZBS")
	DBSetOrder(3)
	If(DbSeek(xFilial("ZBS")+cChave))
	 	If ApMsgYesNo("A exclus�o da Pr�-nota resultar� na exclus�o da mesma em seus respectivos lotes de aprova��o."+chr(13)+;
				"Deseja continuar?")
				
			While ZBS->(!Eof()) .AND. ZBS->(ZBS_FILIAL+ZBS_FILTIT+ZBS_PREFIX+ZBS_NUM+ZBS_TIPO+ZBS_FORNEC) == xFilial("ZBS")+cChave                                                                                                    
							    
				RecLock("ZBS", .F.) 
				ZBS->ZBS_SITUAC := "C"   
				ZBS->ZBS_OBSERV := "Cancelamento devido � alteara��o do t�tulo."
				MsUnLock()
	
				DBSelectArea("ZBT")
				RecLock("ZBT", .T.) 
				ZBT->ZBT_FILIAL := ""
				ZBT->ZBT_LOTE   := ZBS->ZBS_LOTE
				ZBT->ZBT_CCUSTO := ZBS->ZBS_CCUSTO
				ZBT->ZBT_FILTIT := ZBS->ZBS_FILTIT
				ZBT->ZBT_PREFIX := ZBS->ZBS_PREFIX
				ZBT->ZBT_NUM    := ZBS->ZBS_NUM
				ZBT->ZBT_PARCEL := ZBS->ZBS_PARCEL
				ZBT->ZBT_TIPO   := ZBS->ZBS_TIPO
				ZBT->ZBT_FORNEC := ZBS->ZBS_FORNEC
				ZBT->ZBT_DATA   := dDataBase
				ZBT->ZBT_HORA   := Substr(Time(),1,2)+":"+Substr(Time(),4,2)
				ZBT->ZBT_USUAR  := Alltrim(Substr(cUsuario,7,15))
				ZBT->ZBT_SITUAC := "C"
				ZBT->ZBT_OBSERV := "Cancelamento devido � alteara��o do t�tulo."
				MsUnLock()                          
				     
				DBSelectArea("ZBS")
				DBSkip()
				
				// Exclui Lote na SF1
				ExcluiSF1(cChaveSF1)
			Enddo    
		
			Return .T.
		Else
			Return .F.		  					
		Endif 
				
	EndIf
	
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)

Return()

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! A140EXC	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada executado na exclus�o da Pr� Nota			 !
! 			! remover Pr�-nota das tabelas Fluig					 		 !
! 			! 																 !
+----------------------------------------------------------------------------*/
User Function A140EXC()
	
	//Executa Fun��o Auxiliar de Exclus�o no Fluig
	DelDoc()

Return()

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! A100DEL	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Ponto de Entrada executado na exclus�o da Nota Fiscal			 !
! 			! remover Nota Fiscal das tabelas Fluig					 		 !
! 			! 																 !
+----------------------------------------------------------------------------*/
User Function A100DEL()
	
	//Executa Fun��o Auxiliar de Exclus�o no Fluig
	DelDoc()

Return()


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! DelDoc	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao Auxiliar para Excluir do Lote no momento da exclus�o	 !
! 			! da pr�-nota													 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function DelDoc()

	Local aAreaSD1  := GetArea("SD1")
	Local aAreaSF1  := GetArea("SF1")
	Local cChave	:= SF1->F1_FILIAL+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_ESPECIE+SF1->F1_FORNECE 
	Local cChaveSF1 := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)

	DBSelectArea("ZBS")
	ZBS->(DBSetOrder(3))
	If(ZBS->(DbSeek(xFilial("ZBS")+cChave)))
	 	If ApMsgYesNo("A exclus�o da Pr�-nota resultar� na exclus�o da mesma em seus respectivos lotes de aprova��o."+chr(13)+;
				"Deseja continuar?")
				
			While ZBS->(!Eof()) .AND. ZBS->(ZBS_FILIAL+ZBS_FILTIT+ZBS_PREFIX+ZBS_NUM+ZBS_TIPO+ZBS_FORNEC) == xFilial("ZBS")+cChave                                                                                                    
							    
				RecLock("ZBS", .F.) 
				ZBS->ZBS_SITUAC := "C"   
				ZBS->ZBS_OBSERV := "Cancelamento devido � exclus�o da nota."
				MsUnLock()
	
				DBSelectArea("ZBT")
				RecLock("ZBT", .T.) 
				ZBT->ZBT_FILIAL := ""
				ZBT->ZBT_LOTE   := ZBS->ZBS_LOTE
				ZBT->ZBT_CCUSTO := ZBS->ZBS_CCUSTO
				ZBT->ZBT_FILTIT := ZBS->ZBS_FILTIT
				ZBT->ZBT_PREFIX := ZBS->ZBS_PREFIX
				ZBT->ZBT_NUM    := ZBS->ZBS_NUM
				ZBT->ZBT_PARCEL := ZBS->ZBS_PARCEL
				ZBT->ZBT_TIPO   := ZBS->ZBS_TIPO
				ZBT->ZBT_FORNEC := ZBS->ZBS_FORNEC
				ZBT->ZBT_DATA   := dDataBase
				ZBT->ZBT_HORA   := Substr(Time(),1,2)+":"+Substr(Time(),4,2)
				ZBT->ZBT_USUAR  := Alltrim(Substr(cUsuario,7,15))
				ZBT->ZBT_SITUAC := "C"
				ZBT->ZBT_OBSERV := "Cancelamento devido � exclus�o da nota."
				MsUnLock()                          
				     
				DBSelectArea("ZBS")
				DBSkip()
				
				// Exclui Lote na SF1
				ExcluiSF1(cChaveSF1)
				
			Enddo    
		
			Return .T.
		Else
			Return .F.		  					
		Endif 
				
	EndIf
	
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)	
		
Return .T.


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! EXCLUISF1	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao Auxiliar para Excluir NR. Lote SF1						 !
! 			! 																 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function ExcluiSF1(cChave)

	Local aArea := GetArea()

	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	SF1->(dbSeek(cChave))
	
	If SF1->(FOUND()) 
		RecLock("SF1",.F.)
			SF1->F1_XLOTE := ''
		MsUnlock()
	EndIf
	
	RestArea(aArea)
Return
