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
!Nome 			   ! COHAPAR_CONTRATOS_CODUSER.PRW							 !
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

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! CtrCdUs 	! Autor !Gilson Lima 		 ! Data ! 07/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Importação Usuários de Contratos								 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function CtrCdUs()

	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := 'C:\Temp\usuariocontrato.txt'
	
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
	
	dbSelectArea("CNN")
	
	For nA := 1 To Len(aDados)
	
		RecLock("CNN",.T.)
		
			CNN->CNN_FILIAL := aDados[nA][1]
			CNN->CNN_CONTRA := aDados[nA][2]
			CNN->CNN_USRCOD := aDados[nA][3]
			CNN->CNN_TRACOD := aDAdos[nA][4]
		
		MsUnlock()	
	Next nA
	
	CNN->(dbCloseArea())
	
	Alert('Concluído')
Return