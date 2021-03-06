/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualiza��o 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! TCE		 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_TCE_IMPATUALIZADOE.PRW					 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para importacao de Atualiza��es dos Contratos	 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 27/05/2015												 !
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
! Programa 	! TCEATUDOE ! Autor !Gilson Lima 		 ! Data ! 17/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Atualiza��o DOE Contratos										 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function TCEATUDOE()


	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := 'C:\Temp\atualizadoe.txt'
	
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
	//| Verifica se foi poss�vel abrir o arquivo                            |
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
		
		cContrato := StrZero(Val(aDados[nA][1]),10)
		
		cRevisao  := aDados[nA][2]
		
		If AllTrim(cRevisao) != ''
			cRevisao := StrZero(Val(cRevisao),3)
		Else
			cRevisao := Space(3)
		EndIf
		
		cChave := xFilial("CN9") + cContrato + Space(5) + cRevisao
		
		dbSelectArea("CN9")
		CN9->(dbSetOrder(1))
		CN9->(dbGoTop())
		CN9->(dbSeek(cChave))
		
		If CN9->(Found())
		
			
			dDtPublic := StoD(aDados[nA][3])
			cNrEdicao := AllTrim(aDados[nA][4])

			RecLock("CN9",.F.)
			
				CN9->CN9_XPUBL	:= dDtPublic
				CN9->CN9_XEDOE	:= cNrEdicao
			
			MsUnLock()
		EndIF
		
		CN9->(dbCloseArea())		
	Next nA
	
	Alert('Conclu�do')
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RetGraf	! Autor !Gilson Lima 		 ! Data ! 15/10/2014     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Fun��o para retirar os Caracteres Especiais do texto			 !
!			!																 !
+----------------------------------------------------------------------------*/
Static Function RetGraf(_sOrig)

   local _sRet := _sOrig

   _sRet = StrTran (_sRet, "�", "a")
   _sRet = StrTran (_sRet, "�", "e")
   _sRet = StrTran (_sRet, "�", "i")
   _sRet = StrTran (_sRet, "�", "o")
   _sRet = StrTran (_sRet, "�", "u")
   _sRet = StrTran (_sRet, "�", "A")
   _sRet = StrTran (_sRet, "�", "E")
   _sRet = StrTran (_sRet, "�", "I")
   _sRet = StrTran (_sRet, "�", "O")
   _sRet = StrTran (_sRet, "�", "U")
   _sRet = StrTran (_sRet, "�", "a")
   _sRet = StrTran (_sRet, "�", "o")
   _sRet = StrTran (_sRet, "�", "A")
   _sRet = StrTran (_sRet, "�", "O")
   _sRet = StrTran (_sRet, "�", "a")
   _sRet = StrTran (_sRet, "�", "e")
   _sRet = StrTran (_sRet, "�", "i")
   _sRet = StrTran (_sRet, "�", "o")
   _sRet = StrTran (_sRet, "�", "u")
   _sRet = StrTran (_sRet, "�", "A")
   _sRet = StrTran (_sRet, "�", "E")
   _sRet = StrTran (_sRet, "�", "I")
   _sRet = StrTran (_sRet, "�", "O")
   _sRet = StrTran (_sRet, "�", "U")
   _sRet = StrTran (_sRet, "�", "c")
   _sRet = StrTran (_sRet, "�", "C")
   _sRet = StrTran (_sRet, "�", "a")
   _sRet = StrTran (_sRet, "�", "A")
   _sRet = StrTran (_sRet, "�", ".")
   _sRet = StrTran (_sRet, "�", ".")
   _sRet = StrTran (_sRet, chr (9), " ") // TAB
   
Return _sRet