
User Function AtVlAdit()

	Local aArea := GetArea()
	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	
	While CN9->(!EOF())
	
		If AllTrim(CN9->CN9_REVISA) == ''
			CN9->(dbSkip())
			Loop
		EndIf
		
		// Nr. Revisão Anterior
		If CN9->CN9_REVISA == '001'
			cNrRevAnt := '   '
		Else
			cNrRevAnt := StrZero(Val(CN9->CN9_REVISA)-1,3)
		EndIf
		
		// Valor do Aditivo
		nVlAnter   := AtVlAd2(CN9->CN9_FILIAL,CN9->CN9_NUMERO,cNrRevAnt)
		nVlAditivo := CN9->CN9_VLATU - nVlAnter

		RecLock('CN9',.F.)
			CN9->CN9_VLADIT := nVlAditivo
		CN9->(MsUnLock())
	
		CN9->(dbSkip())
	End Do
	
	CN9->(dbCloseArea())
	
	Alert('Concluído')

	RestArea(aArea)

Return

Static Function AtVlAd2(cFilCtr, cNrCtr, cNrRevAnt)

	Local aArea	 := GetArea()
	Local nValor := 0
	
	nValor := POSICIONE("CN9",1,cFilCtr+cNrCtr+cNrRevAnt,"CN9_VLATU")
	
	RestArea(aArea)

Return nValor