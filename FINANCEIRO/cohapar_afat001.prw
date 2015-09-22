/*
+---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Nome              ! impTitu                                                 !
+------------------+---------------------------------------------------------+
!Módulo            ! Financeiro                                              !
+------------------+---------------------------------------------------------+
!Nome              !                                                         !
+------------------+---------------------------------------------------------+
!Descrição         ! Importacao de titulos a partir de um txt                !
+------------------+---------------------------------------------------------+
!Autor             ! Rodrigo Slisinski                                       !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 15/05/09                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!Corrigido fonte para importar arquivo TXT  !Marilda    !Rodrigo L  !13.12.11!
!Criado tela com log de erros/observações   !           !P Araujo   !        !
!Criado validações para inclusao de clientes!           !           !        !
!e titulos                                  !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!A pedido do Analista Totvs Giancarlos, foi !Giancarlos/!Rodrigo L  !02.01.12!
!incluido o codigo IBGE e o codigo do Pais  !Marilda    !P Araujo   !        !
+-------------------------------------------+-----------+-----------+--------+
!Correção do cadastro automático do cliente !Marilda    !Clederson  !28.02.12!
!quando este já estiver cadastrado;         !           !Dotti      !        !
!Documentação do layout de importação atual !           !           !        !  
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+*/
#include "Protheus.ch"
#Include "topconn.ch"
#INCLUDE "font.ch"
#INCLUDE "rwmake.ch"

//+---------------------------------------------------------------------+
//! Layout do arquivo a ser importado (Separador: "|"                   !
//!    1  | 2 |3|       4      |   5    |    6   |   7           8        |            9           |      10       |     11     |12|  13 |  14 |    15
//! 001291|010|1|00021493669915|20120102|20120102|20120102|           1.50|CARLOS ALBERTO RODRIGUES|RUA CAMELIA 268|PONTA GROSSA|PR|13451|19905|PONTA GROSSA
//! 001917|010|1|00039796574934|20120130|20120130|20120130|           1.50|OLINDA SIQUEIRA|RUA PIRAPITINGA 587|FOZ DO IGUACU|PR|13452|08304|FOZ DO IGUAÇU
//! 005793|010|1|00036297623953|20120119|20120119|20120119|           1.50|GERALDO APARECIDO DE SOUZA|AV. PINHO ARAUCARIA, 862|APUCARANA|PR|13453|01408|APUCARANA
//+---------------------------------------------------------------------+  
#DEFINE POSCODCLI 01
#DEFINE POSTIPO   02
#DEFINE POSPARCEL 03
#DEFINE POSCGC    04
#DEFINE POSDTEMIS 05
#DEFINE POSDTVCTO 06
#DEFINE POSDTVREA 07
#DEFINE POSVALOR  08
#DEFINE POSNOMCLI 09
#DEFINE POSENDCLI 10
#DEFINE POSMUNCLI 11
#DEFINE POSUFCLI  12
#DEFINE POSNUMERO 13
#DEFINE POSCODMUN 14
#DEFINE POSNOMMUN 15

User Function impTitu()
	Local lAbort := .T.
	Local cPeriodo:= LEFT(DTOS(DDATABASE),6)     
	Local cTexto :=""
	Private cCodigo:= ""
	Private aClientes:= {}
	Private oLeTxt
	Private cAuxArray 	:= ""
	Private aExplode	:= {}
	Private aTamCod		:= {}
	Private aExpPro		:= {}
	Private aTab		:= {}
	Private aTabCli		:= {}
	Private aTab2		:= {}
	Private nVerifica	:= 1
	Private lMsErroAuto := .F.
	Private aFiles :={}
	Private aScan := {}
	Private aTitulo :={}
	Private aLista := {}    
	Private oBrwLista     
	Private cLinha := ""
	Private cLinAux:= ""
	Private nCont  := 0  
	Private aDados     := {}
	Private aCampos := {}   
	Private aErro := {}    
	Private cPref 
	Private cNum  
	Private cParc 
	Private cTipo
	Private cCodCli   
	                                                   
	cPeriodo:= RIGHT(cPeriodo,2)+"/"+left(cPeriodo,4)
	Processa({||FnProd()} ,"Importando Titulos Abertos - Database: "+cPeriodo,"Aguarde...",lAbort)
Return

Static Function FnProd()
	Local cStatus:= ""
	Local cCidade:= ""
	nCont := 1

	//Pede pra escolher o arquivo txt a ser importado.
	cArqImpor := cGetFile("*.txt |*.TXT  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
	If !Empty(Alltrim(cArqImpor))
		AADD(aFiles, cArqImpor)
	EndIf

	If Len(aFiles) == 0
		cMsg := "Nao existem arquivos para importar. Processo ABORTADO"
		Alert(cMsg)
		Return(.F.)
	else
		//+---------------------------------------------------------------------+
		//| Define o nome do Arquivo Texto a ser usado                          |
		//+---------------------------------------------------------------------+
		cArqTxt := cArqImpor
		
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
		FT_FUse(cArqImpor)  //abre o arquivo
		FT_FGOTOP()         //posiciona na primeira linha do arquivo
		nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
		FT_FGOTOP()
		
		//+---------------------------------------------------------------------+
		//| Verifica quantas linhas tem o arquivo                               |
		//+---------------------------------------------------------------------+
		nLinhas := FT_FLastRec() //nTamArq/nTamLinha
		
		ProcRegua(nLinhas)
		aErro := {}
		While !FT_FEOF()
			IF nCont > nLinhas
				exit
			endif   
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
			nCont++
		EndDo		
		FT_FUSE()
		fClose(nHdl) 		   
		
		aCampos := {"E1_CLIENTE","E1_NATUREZ","E1_PARCELA","CNPJ",;
					"E1_EMISSAO","E1_VENCTO","E1_VENCREA","E1_VALOR",;
					"NOME","ENDERECO","CIDADE","ESTADO","E1_NUM",;
					"E1_PREFIXO","E1_TIPO","CODMUN","NOMECIDADE"}
				                      
	 	
		ProcRegua(Len(aDados))

		For i:=1 to Len(aDados)
			//+---------------------------------------------------------------------+
			//| Se a posição 4 da linha (aDados) começar com '000' utiliza somente  |
			//| os caracteres a partir da 4a posição, senão utiliza todos           |
			//+---------------------------------------------------------------------+
			if Substr(aDados[i, POSCGC], 1, 3) == '000'
				cCgc:= Substr(aDados[i, POSCGC], 4)
			Else
				cCgc:= aDados[i, POSCGC]
			EndIf                                                                
                      
			//+---------------------------------------------------------------------+
			//| Se a posição 4 da linha (aDados) começar com '000' utiliza somente  |
			//| os caracteres a partir da 4a posição, senão utiliza todos           |
			//| ou se o ano/mês for diferente
			//+---------------------------------------------------------------------+
			IF ( EMPTY(cCgc) .OR. cCGC == "00000000000" .OR. cCgc == "00000000000000" .OR. Left(aDados[i, POSDTVREA], 6) != Left(dtos(ddatabase),6) )
				IncProc("Validando >> CPF [" + cCgc + "] e/ou Pagamento [" + dtoc(stod(aDados[i, POSDTVREA])) + "]")			
				
				cTexto := "Verifique a linha " + Alltrim(strZero(i,6))+CHR(13)+CHR(10)
				
				IF EMPTY(cCgc)  .OR. cCGC=="00000000000" .OR. cCgc=="00000000000000"
					cTexto += "CPF vazio [" + cCgc + "]" + CHR(13) + CHR(10)
				endif         
					
				//+---------------------------------------------------------------------+
				//| Se a data do registro (posição 7) for diferente da data-base        |
				//+---------------------------------------------------------------------+
				IF DTOC(STOD(aDados[i, POSDTVREA])) <> dtoc(ddatabase)
					cTexto+= "Mes/Ano de PAGAMENTO diferente da database ["+DTOC(STOD(aDados[i, POSDTVREA]))+"]"+CHR(13)+CHR(10)
				endif
				
				cTexto+= "Database do sistema [" + dtoc(ddatabase) + "]"
				
				GravaErro(strzero(i,6),ALLTRIM(aDados[i, POSNOMCLI]),"IMPORTAÇÃO:"+chr(13)+chr(10)+"========================"+chr(13)+chr(10)+cTexto,"TXT")				
				
			//+---------------------------------------------------------------------+
			//| Se o CGC estiver correto                                            |
			//+---------------------------------------------------------------------+
			Else  						                                                
				aTitulo := {}
				
				IncProc("Validando/Importando Cliente "+alltrim(aDados[i, POSCODCLI]))
				cCidade:= "XXX" //Substr(Posicione("CC2",3,xFilial("CC2")+aDados[i, POSCODMUN],"CC2_MUN"),1,15)
				// Busca o cliente: Se já estiver cadastrado, traz o número da SA1, senão, traz o aDados[i, POSCODCLI]
				cCodCli := getCli(alltrim(aDados[i, POSCODCLI]),aDados[i, POSNOMCLI],aDados[i, POSENDCLI],;
								  aDados[i, POSUFCLI],cCgc,aDados[i, POSCODMUN],i,aDados[i, POSNOMMUN])

				cPref := "EFD"
				cNum  := PADL(ALLTRIM(aDados[i, POSNUMERO]),9,"0") 
				cParc := aDados[i, POSPARCEL]
				//cTipo := IIF(aDados[i, POSTIPO] == "010", "TX","BOL")    
				cTipo := "BOL"    
				
				// Tabela de contas a receber
				dbSelectArea("SE1")
				dbSetOrder(23) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_NATUREZ+E1_EMISSAO                                                                                            
				dbGoTop()
				// Se o título não for encontrado
				If SE1->(!dbSeek(xFilial("SE1") + cPref + cNum + cParc + cTipo + "900" + SUBSTR(aDados[i, POSTIPO], 2, 2) + dtoc(STOD(aDados[i, POSDTEMIS]))))
					IncProc("Importando C.Receber...Titulo: "+PADL(ALLTRIM(aDados[i, POSNUMERO]),9,"0")+" - "+Alltrim(STRZERO(i,6)))
					For j:=1 to Len(aCampos)							
						dbSelectArea("SX3")
						dbSetOrder(2)
						dbGoTop()
						If dbSeek(ALLTRIM(aCampos[j]))
							IF ALLTRIM(aCampos[j]) == "E1_CLIENTE"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), strzero(val(cCodCli), 6), NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_LOJA"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), "01", NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_NATUREZ"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), "900"+SUBSTR(aDados[i, POSTIPO],2,2)+"     ", NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_PARCELA"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), "1", NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_EMISSAO"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), STOD(aDados[i, POSDTEMIS]), NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_VENCTO"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), STOD(aDados[i, POSDTVCTO]), NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_VENCREA"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), STOD(aDados[i, POSDTVCTO]), NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_VALOR"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), VAL(aDados[i, POSVALOR]), NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_NUM"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), PADL(ALLTRIM(aDados[i, POSNUMERO]),9,"0"), NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_PREFIXO"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), cPref, NIL})
							ELSEIF ALLTRIM(aCampos[j]) == "E1_TIPO"
								AADD(aTitulo,{ALLTRIM(aCampos[j]), cTipo, NIL}) 
							ENDIF
						Else
							if !ALLTRIM(aCampos[j])$"CNPJ|NOME|ENDERECO|CIDADE|ESTADO|CODMUN|NOMECIDADE"
								GravaErro(strzero(i,6),ALLTRIM(aDados[i, POSNOMCLI]),;
								"CONTAS A RECEBER (SE1):"+chr(13)+chr(10)+;
								"======================="+chr(13)+chr(10)+;
								"Campo não existe: "+ALLTRIM(aCampos[j])+" na tabela SE1","SE1")
							endif
						EndIf						
					Next j
			
					Begin Transaction
						lMsErroAuto := .F.			
						MSExecAuto({|x,y| Fina040(x,y)},aTitulo,3)
						
						If lMsErroAuto
							//MostraErro("\SYSTEM\","AFAT001.LOG")  
							GravaErro(strzero(i,6),ALLTRIM(aDados[i, POSNOMCLI]),;
							"CONTAS A RECEBER (SE1):"+chr(13)+chr(10)+;
							"======================="+chr(13)+chr(10)+;
							"Não foi possivel gravar titulo"+CHR(13)+CHR(10)+;
							"Verifique a linha "+ALLTRIM(STRZERO(i,6))+CHR(13)+CHR(10)+;
							"Possivelmente: Título já cadastrado "+CHR(13)+CHR(10)+;
							"ou Cliente não existe "+CHR(13)+CHR(10)+;
							"ou Tipo de Taxa incorreto!","SE1")
							MostraErro()
							DisarmTransaction()  
						Else
							//dbSelectArea("SE1")
							//SE1->(dbSetOrder(23))
							SE1->(dbGoTop())
							// Busca o título pelo primeiro índice
							If SE1->(dbSeek(xFilial("SE1") + cPref + cNum + cParc + cTipo))
							 	RecLock("SE1",.F.)
							 	SE1->E1_BAIXA 	:= STOD(aDados[i, POSDTVCTO])
							 	SE1->E1_MOVIMEN := STOD(aDados[i, POSDTVCTO])
							 	SE1->E1_SALDO 	:= 0
							 	SE1->E1_VALLIQ  := VAL(aDados[i, POSVALOR])
							 	SE1->E1_OK      := "Tw"
							 	SE1->E1_STATUS  := "B"
							 	SE1->(MsUnlock())                      												
							endif
							dbCloseArea("SE1")
						EndIf			
						
					End Transaction
				Else
					/*
					GravaErro(strzero(i,6),aDados[i, POSNOMCLI],;
							"CONTAS A RECEBER (SE1):"+chr(13)+chr(10)+;
							"======================="+chr(13)+chr(10)+;
							"O registro já está cadastrado! "+CHR(13)+CHR(10)+;
							"Linha "+ALLTRIM(STRZERO(i,6)),"SE1")
					*/
				EndIf
			Endif
		Next i		
 

		If Len(aErro) > 0
			MostraLog()
		Else
			ApMsgInfo("Importação do contas a receber efetuada com sucesso!","[AFAT001] - SUCESSO")
		EndIf		
		
	EndIf

Return

User Function AFAT001L()
	Local bOk  	    := {|| oDlg:End() }
	Local bCancel   := {|| oDlg:End() }     
	Local aButtons  := {} 
	Local oDlg          
	Local _nCont    := 0                             

	If ( SELECT("ZZC") ) > 0
		dbSelectArea("ZZC")
		ZZC->(dbCloseArea())
	EndIf           	
	dbSelectarea("ZZC")
	ZZC->(dbSetOrder(2))
	ZZC->(dbGotop())
	aLista:={}                   
	While ZZC->(!EOF()) 
		AADD(aLista,{ZZC->ZZC_DATA,ZZC->ZZC_CODIGO,ZZC->ZZC_NOME,ZZC->ZZC_CGC,ZZC->ZZC_EMISSA,ZZC->ZZC_LINHA,ZZC->ZZC_STATUS})     
		_nCont++
		dbSelectArea("ZZC")
		ZZC->(dbSkip())
	EndDo	  
		
	if _nCont>0    		
		DEFINE MSDIALOG oDlg TITLE "[AFAT001] - Log de Erros" FROM 000, 000  TO 300, 700 Pixel //STYLE DS_MODALFRAME
			oBrwLista := TCBrowse():New(  014, 000, 150, 300,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oBrwLista:AddColumn(TCColumn():New("Data"   , {|| aLista[oBrwLista:nAt,01]},,,,, 10 ,.F.,.F.,,,,.F., ) )
			oBrwLista:AddColumn(TCColumn():New("Código" , {|| aLista[oBrwLista:nAt,02]},,,,, 10 ,.F.,.F.,,,,.F., ) )
			oBrwLista:AddColumn(TCColumn():New("Nome"   , {|| aLista[oBrwLista:nAt,03]},,,,, 30 ,.F.,.F.,,,,.F., ) )
			oBrwLista:AddColumn(TCColumn():New("CGC"    , {|| aLista[oBrwLista:nAt,04]},,,,, 20 ,.F.,.F.,,,,.F., ) )
			oBrwLista:AddColumn(TCColumn():New("Emissao", {|| aLista[oBrwLista:nAt,05]},,,,, 10 ,.F.,.F.,,,,.F., ) )
			oBrwLista:AddColumn(TCColumn():New("Linha"  , {|| aLista[oBrwLista:nAt,06]},,,,, 10 ,.F.,.F.,,,,.F., ) )
			oBrwLista:AddColumn(TCColumn():New("Status" , {|| aLista[oBrwLista:nAt,07]},,,,, 20 ,.F.,.F.,,,,.F., ) )
			oBrwLista:SetArray(aLista)
			                               
			Aadd(aButtons, {"PRODUTO",{|| fLimpar(),oDlg:End()},"Limpar Log"})  
			EnchoiceBar(oDlg, bOk, bCancel,,aButtons)                                                                                    
			
			oBrwLista:Align := CONTROL_ALIGN_ALLCLIENT
			
		 ACTIVATE MSDIALOG oDlg CENTERED	
	Else
		MsgInfo("Não há erros para mostrar!")
	endif
Return                                 

Static Function fLimpar()
	dbSelectarea("ZZC")
	ZZC->(dbSetOrder(1))
	ZZC->(dbGotop())
	While ZZC->(!EOF())
		RecLock("ZZC",.F.)
		ZZC->(dbDelete())
		MsUnLock("ZZC")	
		ZZC->(dbSkip())
	EndDo	
	MsgInfo("Tabela Limpa")	
Return

//*****************************************************************//
Static Function Explode(cBuffer)
Local aAux := {}
Local cAux2 := ""

aExplode := {}
For nX := 1 to Len(cBuffer)
	
	If Substr(cBuffer,nX,1) <> "|"
		cAux2 += Substr(cBuffer,nX,1)
	Else
		for nj:=1 to len(cAux2)
			If !(Substr(cAux2,nj,1) $ "|;()")
				cAuxArray += Substr(cAux2,nj,1)
			endif
		Next
		aadd(aExplode,CONVCAR(strtran (cAuxArray, chr (9), ""),.F.))
		cAuxArray := ""
		cAux2 := ""
	EndIf
	
	If nX == Len(cBuffer)
		for nj:=1 to len(cAux2)
			If !(Substr(cAux2,nj,1) $ "|;/.-()")
				cAuxArray += Substr(cAux2,nj,1)
			endif
		Next
		aadd(aExplode,CONVCAR(strtran (cAuxArray, chr (9), ""),.F.))
		//	alert(cAuxArray)
		cAuxArray := ""
		cAux2 := ""
	EndIf
Next

Return

/////////////////////////////////////////////////////////////////////////////////////////////////////
//Cadastrar clientes
Static Function getCli(cCod,cNome,cEnd,cEst,cCgc,cCodMun,nLinha,cNomMun)
	Local cCodCli := ""
	
	aTabCli:={}
	cMun := "XXX"	
	cqry :=" SELECT A1_COD,A1_LOJA"
	cQry +=" FROM "+retSqlName("SA1")+" "
	cQry +=" WHERE D_E_L_E_T_<>'*' "
	cQry +=" AND A1_FILIAL ='"+xFilial("SA1")+"'"
	cQry +=" AND ((A1_COD ='"+cCod+"'"
	cQry +=" AND A1_LOJA ='01' ) "
	// Adicionada a cláusula de busca por CGC, caso o cliente já exista na base
	cQry +=" OR (A1_CGC = '" + cCgc + "' ))"
	
	If (Select("TRA") <> 0)
		dbSelectArea("TRA")
		TRA->(dbCloseArea())
	Endif
	
	TcQuery cQry new alias "TRA"
	
	if TRA->(EOF())
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())
		if SA1->(!dbSeek(xFilial("SA1")+cCod+'01'))		
			IncProc("Importando Cliente: "+cNome)		
		
			aadd(aTabCli,{'A1_COD' 		,cCod 	,nil} )
			aadd(aTabCli,{'A1_LOJA'		,'01' 	,nil} )
			aadd(aTabCli,{'A1_NOME' 	,alltrim(cNome) 	,nil} )
			aadd(aTabCli,{'A1_NREDUZ'	,alltrim(cNome) 	,nil} )
			aadd(aTabCli,{'A1_END' 		,alltrim(cEnd) 		,nil} ) 
			
			cPessoa:=IIF(LEN(cCgc)==11,"F","J")
			
			aadd(aTabCli,{'A1_TIPO' 	,"F" 				,nil} )
			aadd(aTabCli,{'A1_PESSOA' 	,cPessoa			,nil} )
			aadd(aTabCli,{'A1_EST' 		,alltrim(cEst) 		,nil} )
			// Código do município será buscado depois
			aadd(atabCli,{'A1_COD_MUN'	,cCodMun			,nil} )
			aadd(aTabCli,{'A1_MUN'		,cNomMun			,nil} )
			aadd(aTabCli,{'A1_CGC' 		,alltrim(cCgc) 		,nil} )
			aadd(aTabCli,{'A1_CODPAIS'  ,"01058"			,nil} )
			
		 	MSExecAuto({|x,y| Mata030(x,y)},aTabCli,3)
		 			 	
			if lMsErroAuto                                                               
				GravaErro(strzero(nLinha,6),cNome,;
				"CADASTRO DE CLIENTE:"+chr(13)+chr(10)+;
				"=================================="+chr(13)+chr(10)+;
				"Verifique linha "+ALLTRIM(STRZERO(nLinha,6))+chr(13)+chr(10)+;			
				"=================================="+chr(13)+chr(10)+;
				"CODIGO: "		+cCod+iif(empty(cCod)				," >> Valor Inválido <<","") +chr(13)+chr(10)+;
				'LOJA: 01'		+chr(13)+chr(10)+;
				'NOME: ' 		+alltrim(cNome)+iif(empty(cNome)	," >> Valor Inválido <<","") +chr(13)+chr(10)+;
				'NREDUZ: '		+alltrim(cNome)+iif(empty(cNome)	," >> Valor Inválido <<","") +chr(13)+chr(10)+;
				'ENDERECO: '	+alltrim(cEnd)+iif(empty(cEnd)  	," >> Valor Inválido <<","") +chr(13)+chr(10)+;	
				'TIPO: F' 		+chr(13)+chr(10)+;
				'PESSOA: '		+cPessoa+iif(empty(cPessoa)     	," >> Valor Inválido! <<","")+chr(13)+chr(10)+;
				'COD.PAIS: '	+"01058"+chr(13)+chr(10)+;
				'ESTADO: ' 		+alltrim(cEst)+iif(empty(cEst)  	," >> Valor Inválido <<","") +chr(13)+chr(10)+;
				'COD.CIDADE: ' 	+alltrim(cCodMun)+iif(empty(cCodMun)," >> Valor Inválido <<","") +chr(13)+chr(10)+;
				'CPF: ' 		+alltrim(cCgc),"SA1" )
				//mostraerro()
			Else
			 	/*
			 	dbSelectArea("SA1")
			 	SA1->(dbSetOrder(1))
			 	SA1->(dbGoTop())
			 	If SA1->(dbSeek(xFilial("SA1")+cCod+"01")) 
				 	RecLock("SA1",.F.)
				 	// Busca o código do município considerando a UF. (Necessário devido à possível duplicidade do código de município)
				 	cMun 			:= Substr(Posicione("CC2",01,xFilial("CC2") + cEst + cCodMun,"CC2_MUN"), 1, 15)
				 	SA1->A1_COD_MUN := cCodMun
				 	SA1->A1_MUN 	:= cMun
				 	SA1->(MsUnlock())                      
			 	endif
			 	SA1->(dbCloseArea())
			 	*/				
			EndIf
									
			aTabCli:={}
		else  
			/*
			GravaErro(strzero(nLinha,6),cNome,;
			"CADASTRO DE CLIENTE:"+chr(13)+chr(10)+;
			"=================================="+chr(13)+chr(10)+;
			"Verifique linha "+ALLTRIM(STRZERO(nLinha,6))+chr(13)+chr(10)+;			
			"=================================="+chr(13)+chr(10)+;
			"Erro: Cliente já existe!","SA1")		
			*/
	    Endif
	// Se foi encontrado o código do cliente
	Else
		cCodCli := TRA->A1_COD
		
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())
		if SA1->(dbSeek(xFilial("SA1")+cCodCli))
		
			If AllTrim(SA1->A1_COD_MUN) == ''
				RecLock("SA1",.F.)
					SA1->A1_MUN 	:= cNomMun
					SA1->A1_COD_MUN := cCodMun
				SA1->(MsUnLock())
			EndIf
		EndIf		
		    
	EndIf
	TRA->(dbCloseArea())

// Retorna o código do cliente: SA1 ou cód. cliente informado por parâmetro
Return(IIF(Empty(cCodCli), cCod, cCodCli))


Static Function pegaNum()
	cNum:= ''
	cQry:= " SELECT TOP 1 E1_NUM FROM "+RetSqlName('SE1')+" "
	cQry+= " ORDER BY E1_NUM DESC "
	
	IF Select('TRX')<>0
		TRX->(dbCloseArea())
	EndIF
	TcQuery cQry new Alias "TRX"
	
	IF !TRX->(eof())
		cNum := STRZERO(val(TRX->E1_NUM) + 1,9)
	Else
		cNum := '000000001'
	EndIf
	
Return cNum

Static Function fGravaErro(cCodigo,cNatureza,cParcela,cCGC,cData,cNome,nLinha,cStatus)  
	Local cNrLin  := StrZero(nLinha,5)
	
	If ( SELECT("ZZC") ) > 0
		dbSelectArea("ZZC")
		ZZC->(dbCloseArea())
	EndIf           
	
	if Empty(cStatus)	
		if cCGC=="00000000000000" .OR. cCGC=="00000000000"
			cStatus+="CNPJ/CPF Zerado"
		elseif Empty(cCGC)
			cStatus+="Campo Vazio"
		Endif		
		if left(cData,6)!=left(dtos(ddatabase),6)
			cStatus+=", Data diferente da database do sistema!"
		endif            
	endif

	dbSelectarea("ZZC")
	ZZC->(dbSetOrder(2))
	ZZC->(dbGotop())
    ZZC->(!dbSeek(xFilial("ZZC")+cCodigo+cNatureza+cParcela+cCGC+cData))
	IF RecLock("ZZC",ZZC->(Eof()))	   
    	ZZC->ZZC_FILIAL := xFilial("ZZC")
    	ZZC->ZZC_CODIGO := cCodigo
    	ZZC->ZZC_NOME 	:= cNome
    	ZZC->ZZC_CGC 	:= cCGC
    	ZZC->ZZC_DATA 	:= dDatabase 
    	ZZC->ZZC_EMISSA	:= Stod(cData)
    	ZZC->ZZC_LINHA  := cNrLin
    	ZZC->ZZC_STATUS := cStatus
    	ZZC->ZZC_NATURE := cNatureza
    	ZZC->ZZC_PARCEL := cParcela
		ZZC->(MsUnLock())
	endif
Return

/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! Financeiro                                              !
+------------------+---------------------------------------------------------+
!Nome              ! GravaErro                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que grava os erros de importação em um array que !
!				   ! será lido posteriormente.                               !
+------------------+---------------------------------------------------------+
!Autor             ! Paulo Afonso Erzinger Junior                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/01/10                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

//Static Function GravaErro(cPref,cNum,cParc,cTipo,cNome,cMsg)
Static Function GravaErro(cLinha,cNome,cMsg,cAlias)

Local cFile := "\SYSTEM\AFAT001.LOG"
Local cLine := ""

DEFAULT cMsg  := NIL

If cMsg == NIL
	Begin Sequence
	IF !( lOk := File( cFile ) )
		Break
	EndIF
	
	FT_FUSE(cFile)
	FT_FGOTOP()
	
	While !FT_FEOF()
		
		cLine += FT_FREADLN() + CHR(13)+CHR(10)
		
		FT_FSKIP()
	End While
	
	FT_FUSE()
	End Sequence
	
	cMsg := cLine
EndIf

//AADD(aErro,{cPref,cNum,cParc,cTipo,cNome,cMsg})
AADD(aErro,{cLinha,cNome,cMsg,cAlias})

Return


/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! Financeiro                                              !
+------------------+---------------------------------------------------------+
!Nome              ! MostraLog                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que lê o array com os erros gravados anteriormen-!
!				   ! te e exibe na tela para que possa ser salvo ou impresso !
+------------------+---------------------------------------------------------+
!Autor             ! Paulo Afonso Erzinger Junior                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/01/10                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

Static Function MostraLog()

Local oDlg
Local oFont
Local cMemo := ""

DEFINE FONT oFont NAME "Courier New" SIZE 5,0

DEFINE MSDIALOG oDlg TITLE "[AFAT001] - Importação Contas a Receber" From 3,0 to 400,417 PIXEL

//aCabec := {"Prefixo","Número","Parcela","Tipo","Cliente"}
//cCabec := "{aErro[oBrw:nAT][1],aErro[oBrw:nAT][2],aErro[oBrw:nAT][3],aErro[oBrw:nAT][4],aErro[oBrw:nAT][5]}"
aCabec := {"Linha","Cliente","Alias"}
cCabec := "{aErro[oBrw:nAT][1],aErro[oBrw:nAT][2],aErro[oBrw:nAT][4]}"

bCabec := &( "{ || " + cCabec + " }" )

oBrw := TWBrowse():New( 005,005,200,090,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrw:SetArray(aErro)
oBrw:bChange    := { || cMemo := aErro[oBrw:nAT][3], oMemo:Refresh()}
oBrw:bLDblClick := { || cMemo := aErro[oBrw:nAT][3], oMemo:Refresh()}
oBrw:bLine := bCabec

@ 100,005 GET oMemo VAR cMemo MEMO SIZE 200,080 OF oDlg PIXEL

oMemo:bRClicked := {||AllwaysTrue()}
oMemo:lReadOnly := .T.
oMemo:oFont := oFont

oImprimir :=tButton():New(185,120,'Imprimir' ,oDlg,{|| fImprimeLog() },40,12,,,,.T.)
oSair     :=tButton():New(185,165,'Sair'     ,oDlg,{|| ::End() },40,12,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED

Return


/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! Financeiro                                              !
+------------------+---------------------------------------------------------+
!Nome              ! fImprimeLog                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que imprime os erros armazenados no array.       !
+------------------+---------------------------------------------------------+
!Autor             ! Paulo Afonso Erzinger Junior                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/01/10                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

Static Function fImprimeLog()

Local oReport

If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

Static Function ReportDef()

Local oReport
Local oSection

oReport := TReport():New("AFA001","Importação Contas a Receber",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
oReport:SetLandscape()

oSection := TRSection():New(oReport,,{})

TRCell():New(oSection,"LINHA"   ,,"Linha")
TRCell():New(oSection,"NOME"    ,,"Cliente")
TRCell():New(oSection,"ALIAS"   ,,"Alias")
TRCell():New(oSection,"DESCRI"  ,,"Descrição do Erro")

Return oReport

Static Function PrintReport(oReport)

Local oSection := oReport:Section(1)

oReport:SetMeter(Len(aErro))

oSection:Init()

For i:=1 to Len(aErro)
	
	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()
	
	oSection:Cell("LINHA"):SetValue(aErro[i,1])
	oSection:Cell("LINHA"):SetSize(10)
	oSection:Cell("NOME"):SetValue(aErro[i,2])
	oSection:Cell("NOME"):SetSize(70)
	oSection:Cell("ALIAS"):SetValue(aErro[i,4])
	oSection:Cell("ALIAS"):SetSize(10)
	oSection:Cell("DESCRI"):SetValue(aErro[i,3])
	oSection:Cell("DESCRI"):SetSize(200)
	
	nTamLin := 200
	nTab := 3
	lWrap := .T.
	
	lPrim := .T.
	
	cObsMemo := aErro[i,3]
	nLines   := MLCOUNT(cObsMemo, nTamLin, nTab, lWrap)
	
	For nCurrentLine := 1 to nLines
		If lPrim
			oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
			oSection:Cell("DESCRI"):SetSize(300)
			oSection:PrintLine()
			lPrim := .F.
		Else                 
			oSection:Cell("LINHA"):SetValue("")
			oSection:Cell("NOME"):SetValue("")
			oSection:Cell("ALIAS"):SetValue("")
			oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
			oSection:Cell("DESCRI"):SetSize(300)
			oSection:PrintLine()
		EndIf
	Next i
	
	oReport:SkipLine()
Next i

oSection:Finish()

Return

STATIC FUNCTION CONVCAR(cTexto,lAcento)
If lAcento // Imprime com acento
	cTexto:=Strtran(cTexto,"º","o")
	cTexto:=Strtran(cTexto,"ª","a")
	cTexto:=Strtran(cTexto,"ã","a"+Chr(8)+"~")
	cTexto:=Strtran(cTexto,"Ã","A"+Chr(8)+"~")
	cTexto:=Strtran(cTexto,"õ","o"+Chr(8)+"~")
	cTexto:=Strtran(cTexto,"Õ","O"+Chr(8)+"~")
	cTexto:=Strtran(cTexto,"ç","c"+Chr(8)+",")
	cTexto:=Strtran(cTexto,"Ç","C"+Chr(8)+",")
	cTexto:=Strtran(cTexto,"á","a"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"é","e"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"í","i"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"ó","o"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"ú","u"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"à","a"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"è","e"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"ì","i"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"ò","o"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"ù","u"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"â","a"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"ê","e"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"î","i"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"ô","o"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"û","u"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"ä","a"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"ë","e"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"ï","i"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"ö","o"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"ü","u"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"Á","A"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"É","E"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"Í","I"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"Ó","O"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"Ú","U"+Chr(8)+"'")
	cTexto:=Strtran(cTexto,"À","A"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"È","E"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"Ì","I"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"Ò","O"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"Ù","U"+Chr(8)+"`")
	cTexto:=Strtran(cTexto,"Â","A"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"Ê","E"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"Î","I"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"Ô","O"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"Û","U"+Chr(8)+"^")
	cTexto:=Strtran(cTexto,"Ä","A"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"Ë","E"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"Ï","I"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"Ö","O"+Chr(8)+'"')
	cTexto:=Strtran(cTexto,"Ü","U"+Chr(8)+'"')
Else
	cTexto:=Strtran(cTexto,"º","o")
	cTexto:=Strtran(cTexto,"ª","a")
	cTexto:=Strtran(cTexto,"ã","a")
	cTexto:=Strtran(cTexto,"Ã","A")
	cTexto:=Strtran(cTexto,"õ","o")
	cTexto:=Strtran(cTexto,"Õ","O")
	cTexto:=Strtran(cTexto,CHR(135),"c")
	cTexto:=Strtran(cTexto,"Ç","C")
	cTexto:=Strtran(cTexto,"á","a")
	cTexto:=Strtran(cTexto,chr(130),"e")
	cTexto:=Strtran(cTexto,"í","i")
	cTexto:=Strtran(cTexto,"ó","o")
	cTexto:=Strtran(cTexto,"ú","u")
	cTexto:=Strtran(cTexto,"à","a")
	cTexto:=Strtran(cTexto,"è","e")
	cTexto:=Strtran(cTexto,"ì","i")
	cTexto:=Strtran(cTexto,"ò","o")
	cTexto:=Strtran(cTexto,"ù","u")
	cTexto:=Strtran(cTexto,"â","a")
	cTexto:=Strtran(cTexto,chr(136),"e")
	cTexto:=Strtran(cTexto,"î","i")
	cTexto:=Strtran(cTexto,"ô","o")
	cTexto:=Strtran(cTexto,"û","u")
	cTexto:=Strtran(cTexto,"ä","a")
	cTexto:=Strtran(cTexto,"ë","e")
	cTexto:=Strtran(cTexto,"ï","i")
	cTexto:=Strtran(cTexto,"ö","o")
	cTexto:=Strtran(cTexto,"ü","u")
	cTexto:=Strtran(cTexto,"Á","A")
	cTexto:=Strtran(cTexto,"É","E")
	cTexto:=Strtran(cTexto,"Í","I")
	cTexto:=Strtran(cTexto,"Ó","O")
	cTexto:=Strtran(cTexto,"Ú","U")
	cTexto:=Strtran(cTexto,"À","A")
	cTexto:=Strtran(cTexto,"È","E")
	cTexto:=Strtran(cTexto,"Ì","I")
	cTexto:=Strtran(cTexto,"Ò","O")
	cTexto:=Strtran(cTexto,"Ù","U")
	cTexto:=Strtran(cTexto,"Â","A")
	cTexto:=Strtran(cTexto,"Ê","E")
	cTexto:=Strtran(cTexto,"Î","I")
	cTexto:=Strtran(cTexto,"Ô","O")
	cTexto:=Strtran(cTexto,"Û","U")
	cTexto:=Strtran(cTexto,"Ä","A")
	cTexto:=Strtran(cTexto,"Ë","E")
	cTexto:=Strtran(cTexto,"Ï","I")
	cTexto:=Strtran(cTexto,"Ö","O")
	cTexto:=Strtran(cTexto,"Ü","U")
Endif


Return(cTexto)