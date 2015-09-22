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
!Nome 			   ! COHAPAR_CONTRATOS_IMPORTFORNEC.PRW							 !
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
/*/{Protheus.doc} ImpForn
Importação de Fornecedores baseado em arquivo TXT
@author Gilson Lima (contato@gilsonlima.com.br)
@since 25/06/2015
@version 1.0
@return NILL
@example
(examples)
@see (links_or_references)
/*/
User Function ImpForn()

	Local cArquivo 	:= "C:\Temp\PLANILHA_PARTES.txt"
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
	
	Local nImport	:= 0
	Local cDoc		:= ''

	Private aErros	:= {}
	Private aLogs	:= {}
	
	GrvLog("Fornecedores - Importação de Arquivo")
	GrvLog("Data e Hora Ínicio.: " + DtoC( Date() )  + " - " + Time() )
	GrvLog(Replicate('-',80))
	
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
	
	
	For nA := 1 To Len(aArquivo)
	
		If Len(AllTrim(aArquivo[nA][4])) < 12
			cDoc := PadL(AllTrim(aArquivo[nA][4]),11,'0')
		Else
			cDoc := PadL(AllTrim(aArquivo[nA][4]),14,'0')
		EndIF

		cDoc := PadR(cDoc,14,' ')

		// Trata erros de Doc.
		If !CGC(AllTrim(cDoc)) .Or. AllTrim(aArquivo[nA][4]) == ''
			aAdd(aErros,aArquivo[nA])
			Loop
		EndIF
		
		nImport++
		
		cChave := xFilial('SA2')+cDoc
		
		dbSelectArea('SA2')
		SA2->(dbSetOrder(3))
		If SA2->(dbSeek(cChave))
			RecLock("SA2",.F.)
			
			SA2->A2_XCDPART := AllTrim(aArquivo[nA][2])
			
			SA2->(MsUnLock())
		Else
		
			cCodigo := GetSxEnum('SA2','A2_COD')
						
			RecLock("SA2",.T.)
			SA2->A2_COD		:= cCodigo
			SA2->A2_NOME	:= AllTrim(aArquivo[nA][3])
			SA2->A2_CGC		:= cDoc
			SA2->A2_END		:= AllTrim(aArquivo[nA][5]) + ' - ' + AllTrim(aArquivo[nA][7]) 
			SA2->A2_BAIRRO	:= AllTrim(aArquivo[nA][6])
			SA2->A2_TEL		:= AllTrim(aArquivo[nA][8]) + ' ' + AllTrim(aArquivo[nA][9])
			SA2->A2_FAX		:= AllTrim(aArquivo[nA][10]) + ' ' + AllTrim(aArquivo[nA][11])
			SA2->A2_EMAIL	:= AllTrim(aArquivo[nA][12])
			SA2->A2_CEP		:= AllTrim(aArquivo[nA][13])
			SA2->A2_DDD		:= AllTrim(aArquivo[nA][8])
			SA2->A2_FORMUTU	:= 'F'	// Fornecedor
			SA2->A2_MSBLQL	:= '2'	// Não Bloqueado
			SA2->A2_CODPAIS	:= '01058'
			SA2->A2_TIPO	:= IIF(Len(AllTrim(aArquivo[nA][4])) == 14, 'J', 'F') // Jurídica / Física
			SA2->A2_XOBS	:= AllTrim(aArquivo[nA][14])
			SA2->A2_NR_END	:= AllTrim(aArquivo[nA][15])
			SA2->A2_HPAGE	:= AllTrim(aArquivo[nA][16])
			SA2->A2_XCDPART := AllTrim(aArquivo[nA][2])
			SA2->A2_LOJA	:= '01'
			
			SA2->(MsUnLock())
			
			ConfirmSX8()
		
		EndIf
	
		SA2->(dbCloseArea())
		
	Next nA

	GrvLog("Importação Fornecedores Concluída")
	GrvLog("Data / Hora Conclusão: " + DtoC( Date() )  + " / " + Time() )
	GrvLog("Registros Importados.: " + cValToChar(nImport))
	GrvLog(Replicate('-',80))
	
	GrvErros()
	ExibeLog()

Return 

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! GrvErros	! Autor !Gilson Lima 		 ! Data ! 17/03/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao auxiliar de adição da mensagem de log no array de Logs	 !
! 			! de sucesso e erros da rotina									 !
+----------------------------------------------------------------------------*/
Static Function GrvErros(cLog)

	// Gera o arquivo texto
	Local cArqTxt 	:= 'C:\TEMP\ERRO_FORNECEDOR.TXT'
	Local nHdl		:= fCreate(cArqTxt)
	
	Local cLin 	 	:= ""
	Local nLinhas	:= 0
	Local nRegistros:= 0
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" não pode ser executado! Verifique os parâmetros.","Atenção!")
		Return
	EndIf

	// Grava arquivos com erros
	For nB := 1 To Len(aErros)

		nLinhas++

		cLin := ''

		If nB == 1

			cLin += "Erros de Importação: " + CRLF
			cLin += Replicate('-',80) + CRLF
		
		EndIf
		
		cLin += cValToChar(nB) + '|' + AllTrim(aErros[nB][1]) + '|' + AllTrim(aErros[nB][2])+ '|' + AllTrim(aErros[nB][3])
		
		cLin += CRLF

		If nB == Len(aErros)
			cLin += Replicate('-',80)		
		EndIF
		
		// Gravação do arquivo. Testa por erros durante a gravação
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo. Continua?","Atenção!")
				Exit
			EndIf
		EndIf	
	
	Next nB
	
	// Fecha o arquivo texto
	fClose(nHdl)	

Return
/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! GrvLog	! Autor !Gilson Lima 		 ! Data ! 17/03/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao auxiliar de adição da mensagem de log no array de Logs	 !
! 			! de sucesso e erros da rotina									 !
+----------------------------------------------------------------------------*/
Static Function GrvLog(cLog)

	aAdd(aLogs,cLog)

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ExibeLog	! Autor !Gilson Lima 		 ! Data ! 17/03/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao chamada ao final do processamento para exibição do LOG	 !
! 			! de sucesso e erros da rotina									 !
+----------------------------------------------------------------------------*/
Static Function ExibeLog()

	Local cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
	Local cTexto	:= ''
	
	Local   cFile     := ""
	Local   cFileLog  := ""
	Local   oDlg      := NIL
	Local   oFont     := NIL
	Local   oMemo     := NIL	
	
	cTexto := LeLog()

	Define Font oFont Name "Courier New" Size 8, 18

	Define MsDialog oDlg Title "IMPORTACAO FORNECEDORES" From 3, 0 to 450, 673 Pixel

	@ 5, 5 Get oMemo Var cTexto Memo Size 330, 200 Of oDlg Pixel
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont

	Define SButton From 209, 309 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
	Define SButton From 209, 279 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
	MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

	Activate MsDialog oDlg Center

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! LeLog		! Autor !Gilson Lima 		 ! Data ! 17/03/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao que efetua a leitura do array de LOG do sistema e 	 	 !
! 			! retorna em variável para exibição em tela						 !
+----------------------------------------------------------------------------*/
Static Function LeLog()

	Local cRet := ''
	
	For nA := 1 To Len(aLogs)
		cRet += aLogs[nA] + CRLF
	Next nA
		
Return cRet
