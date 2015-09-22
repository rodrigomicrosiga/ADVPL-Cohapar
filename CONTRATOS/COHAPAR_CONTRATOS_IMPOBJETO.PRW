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
!Nome 			   ! COHAPAR_CONTRATOS_IMPOBJETO.PRW							 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para importacao de Arquivos Texto				 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/05/2015												 !
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


User Function LimpObj()

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	While CN9->(!EOF())
	
		If AllTrim(CN9->CN9_CODOBJ) <> ''
		
			MSMM(CN9->CN9_CODOBJ,,,,2,,,,)
			
		EndIf
		CN9->(dbSkip())
	EndDo
	CN9->(dbCloseArea())
Return
/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! GCTIMPOBJ ! Autor !Gilson Lima 		 ! Data ! 05/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Importação objetos contratos									 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function GCTIMPOBJ()


	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := 'C:\Temp\impobj.txt'
	
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

	cObjeto := ''
	cJustifica := ''
	
	For nA := 1 To Len(aDados)
		If AllTrim(aDados[nA][4]) <> ''
		
			cChave := aDados[nA][1]+aDados[nA][2]+aDados[nA][3]
			
			dbSelectArea("CN9")
			CN9->(dbSetOrder(10))
			CN9->(dbGoTop())
			CN9->(dbSeek(cChave))
			
			If CN9->(Found()) .And. AllTrim(CN9->CN9_CODOBJ) == ''
				If AllTrim(aDados[nA][3]) == ''
					cObjeto := aDados[nA][4]
					
					cCodObj := MSMM(,,,cObjeto,1,,,"CN9","CN9_CODOBJ")
				Else
					cJustifica := aDados[nA][4]
					MSMM(,,,cJustifica,1,,,"CN9","CN9_CODJUS")
					
					RecLock("CN9",.F.)
						CN9->CN9_CODOBJ := cCodObj
					CN9->(MsUnlock())
					
				EndIf
			EndIF
			
			CN9->(dbCloseArea())
						 		
		EndIf
	Next nA
	
	Alert('Concluído')
Return