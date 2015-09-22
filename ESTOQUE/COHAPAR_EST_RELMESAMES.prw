#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Relatório 												 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Estoque	 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_EST_RELMESAMES.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Relatório de Consumo Mês a Mês com o consumo do último	 !
!		 		   ! ano, mais o consumo do Mês atual nos anos anteriores	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/07/2015												 !
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

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RelMesAMes! Autor !Gilson Lima 		 ! Data ! 18/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Chama Relatório												 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function RelMesAMes()
	                                                                                                                                                     
	Local cDesc1       := "Relatório Consumo mês a mês Produto"
	Local cDesc2       := ""
	Local cDesc3       := ""
	Local cPict        := ""
	Local nLin         := 80
	Local cCabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	
	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private CbTxt      := ""
	Private limite     := 232
	Private tamanho    := "G"
	Private nomeprog   := "RELMESAMES" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cPerg      := "RELMAM"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "RELMESAMES" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString	   := 'SD3'
	
	// AJUSTE NO SX1 - PARAMETROS                                   ³
	aRegistros:={}
	AADD(aRegistros,{cPerg,"01","Do Produto ?","","","mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Até o Produto ?","","","mv_ch2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Do Tipo ?","","","mv_ch3","C",02,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","02","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Até o Tipo ?","","","mv_ch4","C",02,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","02","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Do Grupo ?","","","mv_ch5","C",04,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Até o Grupo ?","","","mv_ch6","C",04,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Da Descrição do Produto ?","","","mv_ch7","C",30,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Até a Descrição do Produto ?","","","mv_ch8","C",30,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Tipo ?","","","mv_ch09","N",01,0,0,"C","","MV_PAR09","Analitico","","","","","Sintetico","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Média ?","","","mv_ch10","N",01,0,0,"C","","MV_PAR10","Geral","","","","","Parcial","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	dbSelectArea("SX1")
	dbSeek(cPerg)
	
	If !Found()
		dbSeek(cPerg)
		While SX1->X1_GRUPO==cPerg.and.!Eof()
			Reclock("SX1",.f.)
			dbDelete()
			MsUnlock("SX1")
			dbSkip()
		End
		For i:=1 to LEN(AREGISTROS)
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegistros[i,j])
			Next
			MsUnlock("SX1")
		Next	
		
	Endif
	
	pergunte(cPerg,.F.)
	
	// Monta a interface padrao com o usuario...
	
	Private cTitulo1 := "RELATÓRIO DE CONSUMO MÊS A MÊS POR PRODUTO"
	Private cCabec1	 := ''
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo1,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	// Processamento. RPTSTATUS monta janela com a regua de processamento.
	RptStatus({|| RunReport(cCabec1,cCabec2,cTitulo1,nLin) },cTitulo1)

Return


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RunReport ! Autor !Gilson Lima 		 ! Data ! 18/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Cria Relatório												 !
!			! 																 !
+----------------------------------------------------------------------------*/
Static Function RunReport(cCabec1,cCabec2,cTitulo1,nLin)

	Local aMeses := {'JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ'}
	Local aDados := {}
	
	Local nAnosA	:= 5
	Local aAnoMes 	:= {}
	Local aAnosA	:= {}
	Local cMesAt	:= StrZero(Month(dDataBase),2)
	
	Local nTotMes	:= 0
	Local nMesesVl	:= 0
	Local nTotAnos	:= 0
	Local nAnosVl	:= 0
	
	Local aTotMes	:= Array(12)
	Local aTotAnos	:= Array(nAnosA)
	
	Local nCol		:= 0
	Local nLin		:= 0
	Local nLinhas	:= IIF(MV_PAR09 == 1, 60, 60)

	For nC := 1 To nAnosA
		aAdd(aAnosA,cValToChar(Year(dDataBase) - nC))
	Next nC

	nAno := Year(dDataBase)
	
	If month(dDataBase) < 12
		nAno--
	EndIf

	nMes := Month(dDataBase)+1
	If nMes == 13
		nMes := 1
	EndIf
	
	//cMes := StrZero(nMes,2)
	
	cCabec1 := 'CODIGO    TP   GRUPO    DESCRICAO                        UM  '
	
	For nX := 1 To 12
		If aMeses[nMes] == 'JAN' .And. nX != 1 // Primeiro mês
			nAno++
		EndIf
		
		cCabec1 += PadL(aMeses[nMes]+'/'+cValToChar(nAno),12,' ')
		
		aAdd(aAnoMes,cValToChar(nAno)+StrZero(nMes,2))
		
		nMes++
		If nMes == 13
			nMes := 1
		EndIf
	Next nX
	
	cCabec1 += PadL('MEDIA',12,' ')
	
	cQuery := "SELECT SUBSTRING(SD3.D3_EMISSAO,1,6) ANOMES , SUM(SD3.D3_QUANT) QUANT"
	cQuery += " ,SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_TIPO, SB1.B1_GRUPO"
	cQuery += " FROM " + RetSqlName("SD3") + " SD3"
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery += "     ON SB1.B1_COD = SD3.D3_COD"
	cQuery += "    AND SB1.D_E_L_E_T_ != '*'"
	cQuery += "    AND SB1.B1_FILIAL = SD3.D3_FILIAL"
	cQuery += "    AND SB1.B1_TIPO >= '" + MV_PAR03 + "'"
	cQuery += "    AND SB1.B1_TIPO <= '" + MV_PAR04 + "'"
	cQuery += "    AND SB1.B1_GRUPO >= '" + MV_PAR05 + "'"
	cQuery += "    AND SB1.B1_GRUPO <= '" + MV_PAR06 + "'"
	cQuery += "    AND SB1.B1_DESC >= '" + MV_PAR07 + "'"
	cQuery += "    AND SB1.B1_DESC <= '" + MV_PAR08 + "'"
	cQuery += " WHERE SD3.D_E_L_E_T_ != '*'"
	cQuery += " AND SD3.D3_COD >= '" + MV_PAR01 + "'"
	cQuery += " AND SD3.D3_COD <= '" + MV_PAR02 + "'"
	cQuery += " AND SD3.D3_TM NOT IN('499','999')"
	cQuery += " AND SD3.D3_CF = 'RE0'" // Requisição
	cQuery += " AND SUBSTRING(SD3.D3_EMISSAO,1,6) IN ("
	// Monta range de datas baseado nos meses do ano atual
	For nN := 1 To Len(aAnoMes)
		cQuery += "'" + aAnoMes[nN] + "'"
		If nN != Len(aAnoMes)
			cQuery += ","
		EndIf
	Next nN
	//Monta range de datas baseado nos anos anteriores
	For nM := 1 To Len(aAnosA)
		cQuery += ",'" + aAnosA[nM]+cMesAt + "'"
	Next nM
	cQuery += " )"
	cQuery += " AND SD3.D3_FILIAL = '" + xFilial('SD3') + "'"
	cQuery += " GROUP BY SUBSTRING(SD3.D3_EMISSAO,1,6), SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_TIPO, SB1.B1_GRUPO"
	cQuery += " ORDER BY SB1.B1_COD, SUBSTRING(SD3.D3_EMISSAO,1,6) DESC"
	
	If Select("TRB") <> 0
	   DBSelectArea("TRB")
	   DBCloseArea()
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	SetRegua(Contar("TRB","!EOF()"))
	
	TRB->(dbGoTop())
	While !TRB->(EOF())
	
		IncRegua()
		
		lInclui := .T.
		
		// Procura produto no array
		For nZ := 1 To Len(aDados)
		
			If aDados[nZ][1] == TRB->B1_COD
				// Verifica nos meses do ano atual
				For nE := 1 To 12
					If TRB->ANOMES == aAnoMes[nE]
						aDados[nZ][6][nE] := TRB->QUANT
						Exit
					EndIF
				Next nE
				// Verifica nos anos anteriores
				For nF := 1 To nAnosA
					If TRB->ANOMES == aAnosA[nF]+cMesAt
						aDAdos[nZ][7][nF] := TRB->QUANT
						Exit
					EndIf
				Next nF
				
				lInclui := .F.
				Exit
			EndIf
		Next nZ
		
		// Caso não exista no array ainda, inclui uma nova posição
		If lInclui
		
			cDescrD := IIF (Len(AllTrim(TRB->B1_DESC)) > 30, Substr(AllTrim(TRB->B1_DESC),1,27)+'...', AllTrim(TRB->B1_DESC)) 
		
			aAdd(aDados,{;
				TRB->B1_COD,;	// [1]  - Código do Produto
				cDescrD,;		// [2]  - Descrição do Produto
				TRB->B1_UM,;	// [3]  - Unidade de Medida
				TRB->B1_TIPO,;	// [4]  - Tipo
				TRB->B1_GRUPO,;	// [5]  - Grupo
				Array(12),;		// [6]  - Array de Quantidades dos meses do ano atual
				Array(nAnosA),;	// [7]  - Array de Quantidades dos anos anteriores
				0,;				// [8]  - Média das quantidades dos meses do ano atual
				0,;				// [9]  - Total das quantidades dos meses do ano atual
				0,;				// [10] - Média das quantidades dos anos anteriores
				0;				// [11] - Total das quantidades dos anos anteriores
			})
			
			// Atribui valores Zero para não ocorrerem problemas na soma/média
			For nJ := 1 To 12
				aDados[Len(aDados)][6][nJ] := 0
			Next nJ
			For nK := 1 To nAnosA
				aDados[Len(aDados)][7][nK] := 0
			Next nK
			
			For nG := 1 To 12
				If TRB->ANOMES == aAnoMes[nG]
					aDados[Len(aDados)][6][nG] := TRB->QUANT
					Exit
				EndIF
			Next nG
			
			For nH := 1 To nAnosA
				If TRB->ANOMES == aAnosA[nH]+cMesAt
					aDados[Len(aDados)][7][nH] := TRB->QUANT
					Exit
				EndIf
			Next nH
		EndIf
		
		TRB->(dbSkip())    
	EndDo
	
	// Zera valores array de totais de meses e anos
	For nP := 1 To Len(aTotMes)
		aTotMes[nP] := 0
	Next nP
	
	For nQ := 1 To Len(aTotAnos)
		aTotAnos[nQ] := 0
	Next nQ
	
	// Trata médias e totais dos produtos
	For nL := 1 To Len(aDados)
		
		nTotMes		:= 0
		nMesesVl 	:= 0
		
		For nI := 1 To 12
			nTotMes += aDados[nL][6][nI]
			If aDados[nL][6][nI] != 0
				nMesesVl++
			EndIf
			aTotMes[nI] += aDados[nL][6][nI]
		Next nI
		
		If MV_PAR10 == 1 // Geral
			nMedMes := nTotMes / 12
		Else
			nMedMes := nTotMes / nMesesVl
		EndIf
		
		aDados[nL][8] := nMedMes
		aDados[nL][9] := nTotMes
		
		nTotAnos	:= 0
		nAnosVl		:= 0
		
		For nO := 1 To nAnosA
			nTotAnos += aDados[nL][7][nO]
			If aDados[nL][7][nO] != 0
				nAnosVl++
			EndIf
			aTotAnos[nO] += aDados[nL][7][nO]
		Next nO
		
		If MV_PAR10 == 1	// Média Geral
			nMedAnos := nTotAnos / nAnosA
		Else
			nMedAnos := nTotAnos / nAnosVl
		EndIf
		
		aDados[nL][10] := nMedAnos
		aDados[nL][11] := nTotAnos
	Next nL
	
	nQtdProd := IIF (MV_PAR09 == 1, 25, 50)
	nUltProd := nQtdProd
	nPriProd := 1
	nTotProd := Len(aDados)
	
	nVezes:= nTotProd / nQtdProd
	
	If nVezes != Int(nVezes)
		nVezes := Int(nVezes) + 1
	EndIf
	
	For nZ := 1 To nVezes

		Cabec(cTitulo1,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		If nZ == 1
			nPriProd := 1
			nUltProd := nQtdProd
		Else
			nPriProd := ((nZ-1) * nQtdProd)+1
			nUltProd := nPriProd + (nQtdProd - 1)
		EndIf
		
		If nUltProd > nTotProd
			nUltProd := nTotProd
		EndIf
		
		For nA := nPriProd To nUltProd
		
			If nLin > nLinhas // Salto da página. Valor definido baseado no tipo de relatório - Analítico e Sintético
				Cabec(cTitulo1,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			EndIf
			
			@nLin, 00 PSAY aDados[nA][1]
			@nLin, 11 PSAY aDados[nA][4]
			@nLin, 16 PSAY aDados[nA][5]
			@nLin, 25 PSAY aDados[nA][2]
			@nLin, 58 PSAY aDados[nA][3]
			
			For nB := 1 To Len(aDados[nA][6])
				If nB == 1
					nCol := 65
				Else
					nCol += 12
				EndIf
				@nLin, nCol PSAY aDados[nA][6][nB] Picture "9,999,999"
			Next nB
			
			nCol += 12
			@nLin, nCol PSAY aDados[nA][8] Picture "99,999.99"
			
			nLin++
		Next nA
		
		If nZ == nVezes
			
			nLin++
			@nLin, 30 PSAY Replicate('-',187)
			nLin++			
			@nLin, 30 PSAY 'TOTAL GERAL -->'
			
			nTotGr := 0
			
			For nL := 1 To Len(aTotMes)
				If nL == 1
					nCol := 64
				Else
					nCol += 12
				EndIf
				@nLin, nCol PSAY aTotMes[nL] Picture "9,999,999"
				
				nTotGr += aTotMes[nL]
			
			Next nL
			
			nCol += 12
			@nLin, nCol PSAY nTotGr/Len(aTotMes) Picture "99,999.99"

			nLin++
			@nLin, 30 PSAY Replicate('-',187)
			nLin++		
		EndIF

		If MV_PAR09 == 1 // Analítico
			
			nLin++
			nLin++
			
			cCabAnosA := PadR('CODIGO   DESCRICAO',49,' ')
			For nV := 1 To Len(aAnosA)
				cCabAnosA += PadL(aMeses[Val(cMesAt)]+'/'+cValToChar(aAnosA[nV]),15,' ')
			Next nV
			cCabAnosA += PadL('MEDIA',15,' ')
			
			@nLin, 30 PSAY cCabAnosA 
			nLin++
			
			@nLin, 30 PSAY Replicate('-',139)
			nLin++

			For nB := nPriProd To nUltProd
			
				@nLin, 30 PSAY aDados[nB][1]
				@nLin, 40 PSAY aDados[nB][2]
						
				For nC := 1 To Len(aDados[nB][7])
					If nC == 1
						nCol := 86
					Else
						nCol += 15
					EndIf
					@nLin, nCol PSAY aDados[nB][7][nC] Picture "9,999,999"
				Next nC
				
				nCol += 15
				@nLin, nCol PSAY aDados[nB][10] Picture "99,999.99"
				
				nLin++
			Next nB
		EndIf
	
	Next nZ

		
	TRB->(dbCloseArea())
	
	SET DEVICE TO SCREEN
	
	// Se impressao em disco, chama o gerenciador de impressao...
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return