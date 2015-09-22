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
!Nome 			   ! COHAPAR_CONTRATOS_IMPORT2.PRW							 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Funções Importação de dados auxiliares para Contratos	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 23/06/2015												 !
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
! Programa 	! ImpCtr2	! Autor !Gilson Lima 		 ! Data ! 23/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Leitura do arquivo											 !
!			! 										 						 !
+----------------------------------------------------------------------------*/
User Function ImpCtr2()

	Local cArquivo 	:= "C:\Temp\PLANILHA_CONTRATOS.txt"
	Local nHdl		:= 0
	Local nTamFile	:= 0
	Local nRestaLer := 0
	Local nFimLinha := 0
	Local nIniLeit	:= 0
	Local cLeitura	:= ''
	Local cString	:= ''
	Local cEol		:= CHR(13)+CHR(10)
	Local lContinua	:= .T.
	
	Local aDados	:= {}
	Local aArquivo	:= {}
	
	Local aErros	:= {}
	Local nNrAdtvs	:= 0
	
	Local lContrato := lAditivo := lCaucao := .F.
	
	Local cCodAux	:= ''
	Local cRevAux	:= ''
	Local cQuery	:= ''
	Local cCtrFil	:= ''
	Local cCtrNr	:= ''
	Local cCtrRev	:= ''
	Local cChave	:= ''
	Local cObjeto	:= ''
	Local cCodObj	:= ''
	Local cCtrAnt	:= ''
	Local cFornec	:= ''
	Local cObs		:= ''
	Local cCompl	:= ''
	Local cAreaR	:= ''
	Local cJustifica:= ''
	Local cCodFor	:= ''
	Local cCtrDtA	:= ''
	Local cCodCN8	:= ''
	Local cTpCaucao	:= ''
	Local cNumDoc	:= ''
	Local cDtFimV	:= ''
	Local cVlEfet	:= ''
	Local nVlEfet	:= 0
	Local nMoeda	:= 0
	Local cDesMoe	:= ''
	Local cObsCa	:= ''
	Local cCorr		:= ''
	
	nHdl    := fOpen(cArquivo,68)
	
	If nHdl == -1
		MsgStop("O arquivo "+cArquivo+" não pode ser aberto... Verifique os parâmetros","Atencao")
	    Return(cArqDbf)
	Endif	
	
	nTamFile := nRestaLer := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)	
	
	While nRestaLer > 0
		
		aDados := {}
		
		cLeitura  := fReadStr(nHdl,65535)
	    nFimLinha := IIF(AT(cEol,cLeitura)==0, nRestaLer+1, AT(cEol,cLeitura)+1) 
		cString   := Substr(cLeitura,1,nFimLinha)
		If nFimLinha-1 <> nRestaLer
	    	cString   := Substr(cString,1,Len(cString)-2)
	    EndIf
		nRestaLer -= Len(cString)+2
		nIniLeit  += Len(cString)+2 
		
		fSeek(nHdl,nIniLeit)
			    
	    aDados := Separa(cString,'|',.T.)
	    
	    aAdd(aArquivo,aDados)
			
	EndDo
	
	fClose(nHdl)
	
				// Apaga justificativa atual - OK
				// Apaga objeto atual - OK
			
				// Apaga fornecedores Atuais
				// Atualiza Fornecedor [todos os contratos/aditivos]
				// inclui novos fornecedores
	
	For nA := 1 To Len(aArquivo)
		
		// Reinicia variáveis
		lContrato := lAditivo := lCaucao := .F.
		
		// Verifica se é contrato ou aditivo
		If AllTrim(aArquivo[nA][2]) == '1'
			lContrato 	:= .T.
			cCodAux 	:= PadL(AllTrim(aArquivo[nA][3]),10,'0')
			cRevAux 	:= '   '
		ElseIf AllTrim(aArquivo[nA][2]) == '2'
			lAditivo	:= .T.
			cCodAux 	:= PadL(AllTrim(aArquivo[nA][13]),10,'0')
			cRevAux 	:= PadL(AllTrim(aArquivo[nA][11]),3,'0')
		Else
			lCaucao 	:= .T.
		EndIF
			
		If lContrato
		
			// Localiza Contrato / Aditivo	e Obtém Nr contrato atual
			
			cQuery := "SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_DTASSI"
			cQuery += " FROM " + RetSqlName('CN9') + " CN9"
			cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
			cQuery += " AND CN9.CN9_XCDAUX = '" + cCodAux + "'"
			cQuery += " AND CN9.CN9_REVISA = '" + cRevAux + "'"
			
			If Select('TRB') <> 0
				dbSelectArea('TRB')
				TRB->(dbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
			
			dbSelectArea('TRB')
				cCtrFil	:= TRB->CN9_FILIAL
				cCtrNr  := TRB->CN9_NUMERO
				cCtrRev := TRB->CN9_REVISA
				cCtrDtA := TRB->CN9_DTASSI
			TRB->(dbCloseArea())
		Else
			// Ajusta Nr Revisão para os aditivos
			cCtrRev := cRevAux 			
		EndIf
		
		If lContrato .Or. lAditivo
			
			cChave := cCtrFil+cCtrNr+cCtrRev
			dbSelectArea('CN9')
			CN9->(dbSetOrder(1))
			
			If CN9->(dbSeek(cChave))		
	
				If lContrato
				
					// Atualiza Objeto
					cObjeto := AllTrim(aArquivo[nA][5])
					cCodObj := MSMM(,,,cObjeto,1,,,"CN9","CN9_CODOBJ")
					
					// Trata dados de Fornecedor, Observação, Complemento de Nr e Área REsponsável
					cCodFor := PadR(AllTrim(aArquivo[nA][9]),15,' ')
					cFornec := AllTrim(aArquivo[nA][9]) + " | " + Upper(AllTrim(aArquivo[nA][10]))	// Dados Fornecedor (CodParte | Nome Fornecedor)
					cObs	:= AllTrim(aArquivo[nA][6])	// Observacao
					cCompl	:= AllTrim(aArquivo[nA][7])	// Complemento Nr
					cAreaR	:= AllTrim(aArquivo[nA][8])	// Área Responsável
					nNrAdtvs := 0
					
					// Atualiza CN9
					RecLock("CN9",.F.)
					
						CN9->CN9_XNFORN	:= cFornec
						CN9->CN9_XOBS	:= cObs
						CN9->CN9_XCOMPL	:= cCompl
						CN9->CN9_XAREAR	:= cAreaR
						
					CN9->(MsUnLock())
				
				EndIf	
						
				If lAditivo	
				
					// Incrementa Nr. Aditivos
					nNrAdtvs++
					
					// Atualiza Justificativa
					cJustifica := aArquivo[nA][14]
					MSMM(,,,cJustifica,1,,,"CN9","CN9_CODJUS")
					
					//Atualiza CN9 com dados do Contrato
					RecLock("CN9",.F.)
						CN9->CN9_XNFORN	:= cFornec
						CN9->CN9_XOBS	:= cObs
						CN9->CN9_XCOMPL	:= cCompl
						CN9->CN9_XAREAR	:= cAreaR
						CN9->CN9_CODOBJ := cCodObj
					CN9->(MsUnlock())	
				EndIF
			
			EndIf	

		ElseIf lCaucao
			
			// Localiza Cód Fornecedor

			cQuery := "SELECT SA2.A2_COD, SA2.A2_LOJA"
			cQuery += " FROM " + RetSqlName("SA2") + " SA2"
			cQuery += " WHERE SA2.D_E_L_E_T_ <> '*'"
			cQuery += " AND SA2.A2_XCDPART = '" + cCodFor + "'"
			
			If Select('TRB') <> 0
				dbSelectArea('TRB')
				TRB->(dbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
			
			dbSelectArea('TRB')
				cFornCod	:= TRB->A2_COD
				cFornLoja  	:= TRB->A2_LOJA
			TRB->(dbCloseArea())			
			
			
			// Grava Caução

			Do Case
				Case AllTrim(aArquivo[nA][42]) == '3'
					cTpCaucao := '004'
				Case AllTrim(aArquivo[nA][42]) == '2'
					cTpCaucao := '003'
				Case AllTrim(aArquivo[nA][42]) == '1'
					cTpCaucao := '001'
			EndCase
			
			cNumDoc := AllTrim(aArquivo[nA][36])
			
			cDtFimV := AllTrim(aArquivo[nA][40])
			
			cVlEfet := AllTrim(aArquivo[nA][37])
			cVlEfet := StrTran(cVlEfet,',','.')
			nVlEfet := Val(cVlEfet)
	
			nMoeda  := 1
			cDesMoe := "REAL"
			
			cObsCa  := AllTrim(aArquivo[nA][39])
			
			cCorr   := '2' 
			
			// Grava cauções para todos os aditivos
			For nB := 0 To nNrAdtvs

				cCodCN8 := GetSXEnum("CN8","CN8_CODIGO")		
			
				If nB == 0
					cCtrRev := '   '
				Else
					cCtrRev := StrZero(nB,3)
				EndIf
			
				dbSelectArea("CN8")
				
					RecLock("CN8",.T.)
					
						CN8->CN8_FILIAL	:= xFilial("CN8")
						CN8->CN8_CODIGO	:= cCodCN8
						CN8->CN8_TPCAUC	:= cTpCaucao
						CN8->CN8_CONTRA	:= cCtrNr
						CN8->CN8_REVISA	:= cCtrRev
						CN8->CN8_FORNEC	:= cFornCod
						CN8->CN8_LOJA	:= cFornLoja
						CN8->CN8_NUMDOC	:= cNumDoc
						CN8->CN8_DTENT	:= StoD(cCtrDtA)
						CN8->CN8_DTINVI	:= StoD(cCtrDtA)
						CN8->CN8_DTFIVI	:= StoD(cDtFimV)
						CN8->CN8_VLEFET	:= nVlEfet
						CN8->CN8_MOEDA	:= nMoeda
						CN8->CN8_DESCMO	:= cDesMoe
						CN8->CN8_OBSERV	:= cObsCa
						CN8->CN8_CORREC	:= cCorr
					MsUnLock()
					
					ConfirmSX8()
				
				CN8->(dbCloseArea())			
			
			Next nB
		EndIf
	Next nA
	
	
	Alert('OK')

Return 

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ImpCtr2	! Autor !Gilson Lima 		 ! Data ! 23/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Leitura do arquivo											 !
!			! 										 						 !
+----------------------------------------------------------------------------*/
User Function ImpFornec()

	Local cArquivo 	:= "C:\Temp\PLANILHA_PARTES_CONTRATOS.txt"
	Local nHdl		:= 0
	Local nTamFile	:= 0
	Local nRestaLer := 0
	Local nFimLinha := 0
	Local nIniLeit	:= 0
	Local cLeitura	:= ''
	Local cString	:= ''
	Local cEol		:= CHR(13)+CHR(10)
	Local lContinua	:= .T.
	
	Local cCtrFil	:= ''
	Local cCtrNr  	:= ''
	Local cCtrRev 	:= ''
			
	Local aDados	:= {}
	Local aArquivo	:= {}
	
	Local aErros	:= {}
	
	Local cFornAnt 	:= cForLAnt := cCtrAnt := cRevAnt := ''		
	
	nHdl    := fOpen(cArquivo,68)
	
	If nHdl == -1
		MsgStop("O arquivo "+cArquivo+" não pode ser aberto... Verifique os parâmetros","Atencao")
	    Return(cArqDbf)
	Endif	
	
	nTamFile := nRestaLer := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)	
	
	While nRestaLer > 0
		
		aDados := {}
		
		cLeitura  := fReadStr(nHdl,65535)
	    nFimLinha := IIF(AT(cEol,cLeitura)==0, nRestaLer+1, AT(cEol,cLeitura)+1) 
		cString   := Substr(cLeitura,1,nFimLinha)
		If nFimLinha-1 <> nRestaLer
	    	cString   := Substr(cString,1,Len(cString)-2)
	    EndIf
		nRestaLer -= Len(cString)+2
		nIniLeit  += Len(cString)+2 
		
		fSeek(nHdl,nIniLeit)
			    
	    aDados := Separa(cString,'|',.T.)
	    
	    aAdd(aArquivo,aDados)
			
	EndDo
	
	fClose(nHdl)
	
	// Array com Contratos x Fornecedores
	
	For nA := 1 To Len(aArquivo)
	
		cCodAux 	:= PadL(AllTrim(aArquivo[nA][4]),10,'0')

		// Localiza Contrato / Aditivo	e Obtém Nr contrato atual
		cQuery := "SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA"
		cQuery += " FROM " + RetSqlName('CN9') + " CN9"
		cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
		cQuery += " AND CN9.CN9_XCDAUX = '" + cCodAux + "'"
		cQuery += " AND CN9.CN9_REVISA = '   '"
		
		If Select('TRB') <> 0
			dbSelectArea('TRB')
			TRB->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
		
		dbSelectArea('TRB')
			cCtrFil	:= TRB->CN9_FILIAL
			cCtrNr  := TRB->CN9_NUMERO
			cCtrRev := TRB->CN9_REVISA
		TRB->(dbCloseArea())
		

		// Localiza Dados Fornecedor
		
		cCodFor := PadR(AllTrim(aArquivo[nA][3]),15,' ')
		
		cQuery := "SELECT SA2.A2_COD, SA2.A2_LOJA"
		cQuery += " FROM " + RetSqlName("SA2") + " SA2"
		cQuery += " WHERE SA2.D_E_L_E_T_ <> '*'"
		cQuery += " AND SA2.A2_XCDPART = '" + cCodFor + "'"
		
		If Select('TRB') <> 0
			dbSelectArea('TRB')
			TRB->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
		
		dbSelectArea('TRB')
			cFornCod	:= TRB->A2_COD
			cFornLoja  	:= TRB->A2_LOJA
		TRB->(dbCloseArea())			

		
		// Verifica quantos Aditivos o Contrato Possui
				
		cQuery := "SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA"
		cQuery += " FROM " + RetSqlName('CN9') + " CN9"
		cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
		cQuery += " AND CN9.CN9_XCDAUX = '" + cCodAux + "'"
		
		If Select('TRB') <> 0
			dbSelectArea('TRB')
			TRB->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
		
		nAditivos := Contar("TRB","!EOF()")

		
		// Verifica se o Contrato já possui dados de fornecedor
		// se sim, pega o tipo e cod do assinante do último em seguida deleta os atuais para nova inclusão sem duplicidade

		cQuery := "SELECT CNC.CNC_XTASS, CNC.CNC_XCDASS, CNC.R_E_C_N_O_"
		cQuery += " FROM " + RetSqlName("CNC") + " CNC"
		cQuery += " WHERE CNC.D_E_L_E_T_ <> '*'"
		cQuery += " AND CNC.CNC_NUMERO = '" + cCtrNr + "'"
		cQuery += " AND CNC.CNC_CODIGO = '" + cFornCod + "'"
		cQuery += " AND CNC.CNC_LOJA = '" + cFornLoja + "'"
		cQuery += " ORDER BY CNC.CNC_REVISA DESC"
		
		If Select('TRB') <> 0
			dbSelectArea('TRB')
			TRB->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
		
		// Flag para validar cod assinante
		lAssina := .F.
		aDeleta := {}
		cTpAssinante := ''
		cCodAssinante := ''
		
		dbSelectArea('TRB')
			While TRB->(!EOF())
				
				If !lAssina
					
					lAssina := .T.
					
					cTpAssinante  := TRB->CNC_XTASS
					cCodAssinante := TRB->CNC_XCDASS
				EndIf
				
				aAdd(aDeleta,TRB->R_E_C_N_O_)

				TRB->(dbSkip())
			EndDo

		TRB->(dbCloseArea())			
		
		// Deleta os registros anteriores
		For nC := 1 To Len(aDeleta)
		
			dbSelectArea('CNC')
			CNC->(dbGoTo(aDeleta[nC]))
			
			RecLock('CNC',.F.)
				CNC->(dbDelete())
			CNC->(MsUnLock())
			
			CNC->(dbCloseArea())
		Next nC
		
		// Grava  novos dados
		
		// Caso não encontre o código do fornecedor
		If AllTrim(cFornCod) == ''
			cFornCod := '999999'
			cFornLoja := '01'
			cTpAssinante := ''
			cCodAssinante := ''
		EndIF
		
		For nD := 1 To nAditivos
		
			If nD == 1
				cRevisa := '   '
			Else
				cRevisa := StrZero(nD-1,3)
			EndIf

			cQuery := "SELECT CNC.R_E_C_N_O_"
			cQuery += " FROM " + RetSqlName("CNC") + " CNC"
			cQuery += " WHERE CNC.D_E_L_E_T_ <> '*'"
			cQuery += " AND CNC.CNC_NUMERO = '" + cCtrNr + "'"
			cQuery += " AND CNC.CNC_REVISA = '" + cRevisa + "'"
			cQuery += " AND CNC.CNC_CODIGO = '" + cFornCod + "'"
			cQuery += " AND CNC.CNC_LOJA = '" + cFornLoja + "'"
			
			If Select('TRB') <> 0
				dbSelectArea('TRB')
				TRB->(dbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
			
			cNrExist := Contar("TRB","!EOF()")
			
			If cNrExist == 0
			
				dbSelectArea('CNC')
				
				RecLock('CNC',.T.)
				
					CNC->CNC_FILIAL	:= xFilial('CNC')
					CNC->CNC_NUMERO	:= cCtrNr
					CNC->CNC_CODIGO	:= cFornCod
					CNC->CNC_LOJA	:= cFornLoja
					CNC->CNC_REVISA	:= cRevisa
					CNC->CNC_XTASS	:= cTpAssinante
					CNC->CNC_XCDASS	:= cCodAssinante
					
				CNC->(MsUnLock())
				
				CNC->(dbCloseArea())
			
			EndIf
			
			TRB->(dbCloseArea())
			
		Next nD
					
	Next nA

Return


/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CtrCC		! Autor !Gilson Lima 		 ! Data ! 02/07/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza Centros de Custo dos Contratos						 !
!			! 										 						 !
+----------------------------------------------------------------------------*/
User Function CtrCC()

	Local cQuery   := ''
	Local cDepto   := ''
	Local nCtr	   := 0
	Local nNrExist := 0
	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	
	nCtr := Contar("CN9","!EOF()")
	ProcRegua(nCtr)	// Número de registros a Processar
	
	CN9->(dbGoTop())		
	While CN9->(!EOF())
	
		IncProc('Atualizando CTR: ' + CN9->CN9_NUMERO + " / " + CN9->CN9_REVISA) // Incrementa a régua
	
		cDepto := AllTrim(CN9->CN9_XAREAR)
		
		If AllTrim(cDepto) != ''
		
			cQuery := "SELECT TOP 1 CTT.CTT_CUSTO"
			cQuery += " FROM " + RetSqlName("CTT") + " CTT"
			cQuery += " WHERE CTT.CTT_CLASSE = '2'"
			cQuery += " AND CTT.CTT_DESC01 LIKE '%" + cDepto + "%'"
			cQuery += " ORDER BY CTT.R_E_C_N_O_ DESC"
			
			If Select('TRB') <> 0
				dbSelectArea('TRB')
				TRB->(dbCloseArea())
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
			
			nNrExist := Contar("TRB","!EOF()")
			TRB->(dbGoTop())
			
			If nNrExist == 0
				cCCusto := '9999999999'
			Else
				cCCusto := AllTrim(TRB->CTT_CUSTO)
			EndIf
			
			TRB->(dbCloseArea())
		Else
			cCCusto := '8888888888'
		EndIf
		
		RecLock("CN9",.F.)
		
			CN9->CN9_XXCC := cCCusto
		
		CN9->(MsUnLock())
		
		CN9->(dbSkip())
		
	EndDo
	
	CN9->(dbCloseArea())
	
	Alert("Atualização Concluída!")

Return