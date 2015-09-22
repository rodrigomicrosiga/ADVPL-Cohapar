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
!Nome 			   ! COHAPAR_TCE_IMPSEICEDLICITACAO.PRW								 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para importacao de Classes de Produtos		 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/2015												 !
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
! Programa 	! TCEIMPSEI ! Autor !Gilson Lima 		 ! Data ! 17/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Importação de classes de produtos								 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function TCEIMPSEI()


	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := 'C:\Temp\seiced-licitacao.txt'
	
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

	dbSelectArea("SZI")
	
	For nA := 1 To Len(aDados)
	
		cNrDoc := AllTrim(aDados[nA][2])
		cNrDoc := StrTran(cNrDoc,'.','')
		cNrDoc := StrTran(cNrDoc,'-','')
		cNrDoc := StrTran(cNrDoc,'/','')
		
		If Len(cNrDoc) == 11
			cTpDoc := '2 ' 	// CPF
		Else
			cTpDoc := '1 ' 	// CNPJ
		EndIf
		
		cNrDoc := PadR(cNrDoc,14,' ')
		
		cChave := cTpDoc+cNrDoc
		
		SZI->(dbSetOrder(2))
		SZI->(dbSeek(cChave))
		
		If SZI->(!Found())
			
			cCodigo := GetSxEnum("SZI","ZI_CODIGO")
		
			RecLock("SZI",.T.)
			
				SZI->ZI_FILIAL	:= xFilial("SZI")
				SZI->ZI_CODIGO	:= cCodigo
				SZI->ZI_NOME	:= RetGraf(UPPER(AllTrim(aDados[nA][1])))
				SZI->ZI_NRDOC	:= cNrDoc
				SZI->ZI_TIPODOC	:= cTpDoc
				SZI->ZI_END		:= RetGraf(UPPER(AllTrim(aDados[nA][3])))
				SZI->ZI_COMPL	:= RetGraf(UPPER(AllTrim(aDados[nA][4])))
				SZI->ZI_BAIRRO	:= RetGraf(UPPER(AllTrim(aDados[nA][5])))
				SZI->ZI_UF		:= RetGraf(UPPER(AllTrim(aDados[nA][7])))
				SZI->ZI_CODMUN	:= PadL(AllTrim(aDados[nA][9]),5,'0')
				SZI->ZI_CEP		:= AllTrim(aDados[nA][8])
				SZI->ZI_DTALTER	:= Date()
				SZI->ZI_ATIVO	:= 'S'
			
			MsUnLock()
			
			ConfirmSX8()
		
		EndIf		
	Next nA
	
	dbCloseArea("SZI")
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