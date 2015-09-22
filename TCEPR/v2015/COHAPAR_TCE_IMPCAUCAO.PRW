/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! TCE		 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_TCE_IMPCAUCAO.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para importacao Informações de Caução Contratos!
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 21/05/2015												 !
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
! Programa 	! TCEIMPCAU ! Autor !Gilson Lima 		 ! Data ! 17/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Importação de informação caução								 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function TCEIMPCAU()


	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := 'C:\Temp\caucao_contrato.txt'
	
	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	nHdl := fOpen(cArqTxt)
	IF nHdl == -1
		IF FERROR() == 516
			ALERT("Feche a planilha que gerou o arquivo.")
		EndIF
	EndIf
	
	//+---------------------------------------------------------------------+
	//| Verifica se foi possível abrir o arquivo                            |
	//+---------------------------------------------------------------------+
	If nHdl == -1
		cMsg := "O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros."
		MsgAlert(cMsg,"Atencao!")
		Return
	Endif
	
	//+---------------------------------------------------------------------+
	//| Posiciona no Inicio do Arquivo                                      |
	//+---------------------------------------------------------------------+
	FSEEK(nHdl,0,0)
	
	//+---------------------------------------------------------------------+
	//| Traz o Tamanho do Arquivo TXT                                       |
	//+---------------------------------------------------------------------+
	nTamArq:=FSEEK(nHdl,0,2)
	
	//+---------------------------------------------------------------------+
	//| Posicona novamemte no Inicio                                        |
	//+---------------------------------------------------------------------+
	FSEEK(nHdl,0,0)
	
	//+---------------------------------------------------------------------+
	//| Fecha o Arquivo                                                     |
	//+---------------------------------------------------------------------+
	fClose(nHdl)
	FT_FUse(cArqTxt)  //abre o arquivo
	FT_FGOTOP()         //posiciona na primeira linha do arquivo
	nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
	FT_FGOTOP()
	
	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := FT_FLastRec() //nTamArq/nTamLinha
	
	ProcRegua(nLinhas)
	aErro := {}
	aDados := {}
	nCont := 0
	
	While !FT_FEOF()
		IF nCont > nLinhas
			exit
		endif
		nCont++   
		IncProc("Lendo arquivo texto..."+Alltrim(str(nCont)))
		cLinha := FT_FREADLN()
		cLinha := ALLTRIM(cLinha)
		//+---------------------------------------------------------------------+
		//| Armazena no array aDados todas as linhas do TXT                     |
		//+---------------------------------------------------------------------+
		if !empty(cLinha)
			AADD(aDados,Separa(cLinha,"|",.T.))
		endif
		FT_FSKIP()
	EndDo		
	FT_FUSE()
	fClose(nHdl) 		   
	
	For nA := 1 To Len(aDados)

		cNrContr := PadR(PadL(aDados[nA][1],10,'0'),15,' ')
		cRevisao := IIF(AllTrim(aDados[nA][2]) == '',Space(3),PadL(aDados[nA][2],3,'0'))
		
		cQuery := "SELECT CN9.CN9_DTINIC, CNC.CNC_CODIGO, CNC.CNC_LOJA"
		cQuery += " FROM " + RetSqlName("CN9") + " CN9"
		cQuery += " LEFT JOIN "+ RetSqlName("CNC") + " CNC"
		cQuery += "      ON CNC.D_E_L_E_T_ <> '*'"
		cQuery += "     AND CNC.CNC_NUMERO = CN9.CN9_NUMERO"
		cQuery += "     AND CNC.CNC_REVISA = CN9.CN9_REVISA"
		cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
		cQuery += " AND CN9.CN9_NUMERO = '" + cNrContr + "'"
		cQuery += " AND CN9.CN9_REVISA = '" + cRevisao + "'"
		
		If Select('TRB') <> 0
			dbSelectArea('TRB')
			TRB->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
		// Número de registros a Processar
		nReg := Contar("TRB","!EOF()")
		
		If nReg > 0
		
			dbSelectArea('TRB')
			TRB->(dbGoTop())
			
			While TRB->(!EOF())
				
				cFornec := TRB->CNC_CODIGO
				cLoja   := TRB->CNC_LOJA
				cDtEntr := TRB->CN9_DTINIC
				cDtIniv := TRB->CN9_DTINIC
			
				TRB->(dbSkip())
			EndDo
			
			TRB->(dbCloseArea())
			
		EndIf		
		
		cCodCN8 := GetSXEnum("CN8","CN8_CODIGO")
		
		Do Case
			Case AllTrim(aDados[nA][7]) == '3'
				cTpCaucao := '004'
			Case AllTrim(aDados[nA][7]) == '2'
				cTpCaucao := '003'
			Case AllTrim(aDados[nA][7]) == '1'
				cTpCaucao := '001'
		EndCase
		
		cNumDoc := AllTrim(aDados[nA][3])
		
		cDtFimV := AllTrim(aDados[nA][6])
		
		cVlEfet := AllTrim(aDados[nA][4])
		cVlEfet := StrTran(cVlEfet,',','.')
		nVlEfet := Val(cVlEfet)

		nMoeda  := 1
		cDesMoe := "REAL"
		
		cObs    := RetGraf(Upper(AllTrim(aDados[nA][5])))
		
		cCorr   := '2' 
		
		dbSelectArea("CN8")
		
			RecLock("CN8",.T.)
			
				CN8->CN8_FILIAL	:= xFilial("CN8")
				CN8->CN8_CODIGO	:= cCodCN8
				CN8->CN8_TPCAUC	:= cTpCaucao
				CN8->CN8_CONTRA	:= cNrContr
				CN8->CN8_REVISA	:= cRevisao
				CN8->CN8_FORNEC	:= cFornec
				CN8->CN8_LOJA	:= cLoja
				CN8->CN8_NUMDOC	:= cNumDoc
				CN8->CN8_DTENT	:= StoD(cDtEntr)
				CN8->CN8_DTINVI	:= StoD(cDtIniv)
				CN8->CN8_DTFIVI	:= StoD(cDtFimV)
				CN8->CN8_VLEFET	:= nVlEfet
				CN8->CN8_MOEDA	:= nMoeda
				CN8->CN8_DESCMO	:= cDesMoe
				CN8->CN8_OBSERV	:= cObs
				CN8->CN8_CORREC	:= cCorr
			MsUnLock()
			
			ConfirmSX8()
		
		CN8->(dbCloseArea())

	Next nA
	
	Alert('Concluído')
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RetGraf	! Autor !Gilson Lima 		 ! Data ! 15/10/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para retirar os Caracteres Especiais do texto			 !
!			!																 !
+----------------------------------------------------------------------------*/
Static Function RetGraf(_sOrig)

   local _sRet := _sOrig

   _sRet = StrTran (_sRet, "á", "a")
   _sRet = StrTran (_sRet, "é", "e")
   _sRet = StrTran (_sRet, "í", "i")
   _sRet = StrTran (_sRet, "ó", "o")
   _sRet = StrTran (_sRet, "ú", "u")
   _sRet = StrTran (_sRet, "Á", "A")
   _sRet = StrTran (_sRet, "É", "E")
   _sRet = StrTran (_sRet, "Í", "I")
   _sRet = StrTran (_sRet, "Ó", "O")
   _sRet = StrTran (_sRet, "Ú", "U")
   _sRet = StrTran (_sRet, "ã", "a")
   _sRet = StrTran (_sRet, "õ", "o")
   _sRet = StrTran (_sRet, "Ã", "A")
   _sRet = StrTran (_sRet, "Õ", "O")
   _sRet = StrTran (_sRet, "â", "a")
   _sRet = StrTran (_sRet, "ê", "e")
   _sRet = StrTran (_sRet, "î", "i")
   _sRet = StrTran (_sRet, "ô", "o")
   _sRet = StrTran (_sRet, "û", "u")
   _sRet = StrTran (_sRet, "Â", "A")
   _sRet = StrTran (_sRet, "Ê", "E")
   _sRet = StrTran (_sRet, "Î", "I")
   _sRet = StrTran (_sRet, "Ô", "O")
   _sRet = StrTran (_sRet, "Û", "U")
   _sRet = StrTran (_sRet, "ç", "c")
   _sRet = StrTran (_sRet, "Ç", "C")
   _sRet = StrTran (_sRet, "à", "a")
   _sRet = StrTran (_sRet, "À", "A")
   _sRet = StrTran (_sRet, "º", ".")
   _sRet = StrTran (_sRet, "ª", ".")
   _sRet = StrTran (_sRet, chr (9), " ") // TAB
   
Return _sRet