#INCLUDE "PROTHEUS.CH"
#INCLUDE "Ap5mail.ch"
#INCLUDE "GCPA002.ch"
#INCLUDE "FWMVCDEF.CH"
// Define dos modos das rotinas
#DEFINE VISUALIZAR							2
#DEFINE INCLUIR	  		   		 	  		3
#DEFINE ALTERAR	   		   		 			4
#DEFINE GERAR	   		   		  			5
#DEFINE OK		   		   		  			1
#DEFINE CANCELA		  		   				2
#DEFINE ENTER 						  		Chr(13)+Chr(10)
#DEFINE REMANESCENTE						13
Static aModXTipo := {	{"DL","AA*DE*DR*DV"},;
						{"PG","PE*PP*MP"},;  
						{"IN","DI"},;
						{"TP","RP*MT*TP*MP*  "},;
						{"CV","MP*MT*TP*  "},;
						{"CC","MT*TP*  "},;
						{"LL","  "},;
						{"CS","  "}	}

//utilizado para o sistema S
Static aModXTipo2 := {	{"DL","AA*DE*DR*DV"},;
							{"PG","MP"},;
							{"IN","DI"},;
							{"CV","MP*TP"},;
							{"CC","MP*TP"},;
							{"LL","  "},;
							{"CS","  "}   }    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCPA002 	บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para controle de Edital                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GCPA002()     
Local   lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Private aRotina := MenuDef()
Private cCadastro	:= STR0001+"..." //"Edital"
Private aTrocaF3 := {} 
Private lRemanescente 	:= .F.

if lPrjCni
	if Existblock( 'GCP2BROW')                                                    
		Execblock( "GCP2BROW", .F., .F. )
	EndIf
EndIf

If !GCPValTab()
	Return
EndIf    

AjustaSX1()
AjustaSX3()
AjustaSX5()
AjustaHelp()

dbSelectArea("CO1")
dbSetOrder(1)
dbGoTop()
mBrowse(,,,,"CO1",,,,,,GCPA02Status())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPA02Man   บAutor  ณTOTVS SA          บ Data ณ  06/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manuten็ใo do cadastro do Edital                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPA02Man(cAlias,nRecNo,nOpc)
Local   lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
       
if lPrjCni       
	if Existblock( 'GCP2MANU')    
		Execblock( "GCP2MANU", .F., .F. , {nOpc} )
	EndIf
EndIf
GCPA02Edital(cAlias,nRecNo,nOpc)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPA02EditalบAutor  ณTOTVS SA            บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Edital                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GCPA02Edital( cAlias, nRecNo, nOpc, aSLComp, cPrfEdital, cNumProc, cTpModal, cTipo, cRegra)

Local aHeader 		:= {}
Local aCols   		:= {}
Local cAliasITem	:= "CO2"
Local aSolic		:= {}
Local aRet			:= {}
Local lRet			:= .T.
Local lGcp02Cmp		:= ExistBlock("GCP02CMP")
Local lGCP2EDIM     := .F.
Local lPrjCni       := FindFunction("ValidaCNI") .And. ValidaCNI()
Private oEnch		:= Nil
Private oDlg		:= Nil

Default aSLComp := {}
Default cPrfEdital	:= ""
                                              

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis internas para a MsMGet()ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aTELA[0][0]
Private aGETS[0]
Private lRTudoOk		:= .F.
Private aREdital		:= {}
Private aRHeader		:= {}
Private aRCols			:= {}
Private aRPartic		:= {}
Private aRComiss		:= {}
Private aRSolic			:= {}
Private cLote			:= Space(TamSx3("CO2_LOTE")[1])

if lPrjCni
	lGCP2EDIM     := Existblock( 'GCP2EDIM')
EndIf

If nOpc == ALTERAR
	If CO1->CO1_ETAPA $ "PE,PR,PC,FV,CO,CE" .And. lRet //inclusao do status edital cancelado
		Help("",1,"GCP02NOETP") //"Somente edital em aberto poderแ ter manuten็ใo ou estorno "
		Return
	Endif
	If	lPrjCni
		//-- Verifica se informou ganhador
		If	GCPChkCO3("3",CO1->CO1_CODEDT,CO1->CO1_NUMPRO)
			Help("",1,"GCP02GANHA",,STR0098,4,1)		//"Edital com ganhador informado nใo poderแ ser alterado"
			Return
		EndIf
	EndIf
EndIf

aHeader	:= CriaHeader(nil,"CO2_FILIAL/CO2_CODEDT/CO2_NUMPRO",Nil,cAliasITem) //CO2_FILIAL/CO2_CODEDT/CO2_NUMPRO

If nOpc != GERAR 

	if lPrjCni
		if  lGCP2EDIM
			Execblock( "GCP2EDIM", .F., .F. , {xFilial(cAliasITem),(cAlias)->(CO1_CODEDT), (cAlias)->(CO1_NUMPRO)} )
		EndIf
	EndIf
	
	aCols	:= CriaAcols(aHeader,cAliasITem,2,xFilial(cAliasITem)+(cAlias)->(CO1_CODEDT+CO1_NUMPRO),nOpc,nil,"CO2_ITEM","CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO")
Else
	aRet 	:= GCP02DadosEdt( aHeader, aSLComp, cPrfEdital )
	If !Empty(aRet)
		aCols 	:= aClone(aRet[1])
		aSolic 	:= aClone(aRet[2])
	Else
		Help("",1,"GCP02NOSOL") //"Solicita็๕es de compras invalidas "
		Return
	EndIf
EndIf

MontaTela( aHeader, aCols, nRecNo, nOpc, aSolic, cPrfEdital, cTpModal, cTipo, cRegra)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada para execu็ใo de rotinas complementares ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGcp02Cmp .And. ( nOpc == INCLUIR .Or. nOpc == ALTERAR .Or. nOpc == GERAR ) .And. lRTudoOk
	ExecBlock("GCP02CMP",.F.,.F.,{aREdital,aRHeader,aRCols,nOpc,aRPartic,aRComiss,aRSolic})
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02DadosEdtบAutor  ณTOTVS SA         บ Data ณ  04/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera os dados do edital a partir da solicitacao de compra  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GCP02DadosEdt( aHeader, aSLComp, cEdital )
Local aHeadC1 		:= CriaHeader(Nil,Nil,Nil,"SC1")
Local nPosProdSC	:= aScan(aHeadC1,{|x| AllTrim(x[2])=="C1_PRODUTO"})+1
Local nPosQtSC 		:= aScan(aHeadC1,{|x| AllTrim(x[2])=="C1_QUANT"})+1
Local nPosNumSC		:= aScan(aHeadC1,{|x| AllTrim(x[2])=="C1_NUM"})+1
Local nPosItemSC	:= aScan(aHeadC1,{|x| AllTrim(x[2])=="C1_ITEM"})+1
Local nPosProdEdt	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO2_CODPRO"})
Local nPosQtEdt		:= aScan(aHeader,{|x| AllTrim(x[2])=="CO2_QUANT"})
Local nPosPaCOls	:= 0
Local nPosSolic		:= 0
Local cItem			:= Replicate("0",TamSx3("CO2_ITEM")[1])
Local aRet	   		:= {}
Local aCols	   		:= {}
Local aSolic		:= {}
Local nX	   		:= 0
Local nY			:= 0
Local nCols			:= 0

For nX := 1 to Len(aSLComp)
	If aSLComp[nX][1]
		nPosPaCOls := aScan(aCols,{|x| AllTrim(x[nPosProdEdt]) == ALLTRIM(aSLComp[nX][nPosProdSC])})
		nPosSolic := aScan(aSolic ,{|x| Alltrim(x[1]) == Alltrim(aSLComp[nX][nPosProdSC]) })
		If Empty(nPosPaCOls) .Or. Empty(nPosSolic)
			cItem := Soma1(cItem)
			aAdd(aCols,Array(Len(aHeader)+1))
			nCols++
			For nY := 1 To Len(aHeader)
				If Alltrim(aHeader[nY][2]) == "CO2_CODPRO"
					aCols[nCols][nY] := aSLComp[nX][nPosProdSC]
				ElseIf Alltrim(aHeader[nY][2]) == "CO2_QUANT"
					aCols[nCols][nY] := aSLComp[nX][nPosQtSC]
				ElseIf Alltrim(aHeader[nY][2]) == "CO2_NUMSC"
					aCols[nCols][nY] := aSLComp[nX][nPosNumSC]
				ElseIf Alltrim(aHeader[nY][2]) == "CO2_ITEMSC"
					aCols[nCols][nY] := aSLComp[nX][nPosItemSC]
				ElseIf Alltrim(aHeader[nY][2]) == "CO2_UM"
					aCols[nCols][nY] := POSICIONE( "SB1", 1, XFILIAL( "SB1" ) + aSLComp[nX][nPosProdSC] , "B1_UM" )
				ElseIf Alltrim(aHeader[nY][2]) == "CO2_DESCR"
					aCols[nCols][nY] := POSICIONE( "SB1", 1, XFILIAL( "SB1" ) + aSLComp[nX][nPosProdSC] , "B1_DESC" )
				ElseIf Alltrim(aHeader[nY][2]) == "CO2_ITEM"
					aCols[nCols][nY] := cItem
				ElseIf CO2->( FieldPos(aHeader[nY][2]) ) > 0
					aCols[nCols][nY] := CriaVar(aHeader[nY][2])
				EndIF
			Next nX
			aCols[nCols][Len(aHeader)+1] := .F.
			//Relaciona a solicita็ใo ao item
			AAdd(aSolic,{ aSLComp[nX][nPosProdSC] , {aClone(aSLComp[nX])} })
		Else
			aCols[nPosPaCOls][nPosQtEdt] += aSLComp[nX][nPosQtSC]
			AAdd(aSolic[nPosSolic][2],aClone(aSLComp[nX]))
		EndIf
	EndIf
Next nX

If !Empty(aCols) .And. !Empty(aSolic)
	aRet := {aCols,aSolic}
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaTela บAutor  ณTOTVS SA            บ Data ณ  06/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFunc็ใo responsแvel por montar a tela                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaTela( aHeader, aCols, nReg, nOpc, aSolic, cPrfEdital, cTpModal, cTipo, cRegra)
Local oDlg := Nil
Local lGCP02But		:= Existblock( 'GCP02But' )
Local aButAux		:= {}
Local lPrjCni       := FindFunction("ValidaCNI") .And. ValidaCNI()                          	
Local lGCP2MTEL     := iif (lPrjCni, Existblock( 'GCP2MTEL'), .F.)
Local lMTELOk    
Local lGCP2OPCX     := iif (lPrjCni, Existblock( 'GCP2OPCX'), .F.)
Local aGCP2OPCX     := {}
Local lGcp02Edt		:= ExistBlock("GCP02EDT")
Local nX			:= 0
Local aGcp02Edt		:= {}
Local aDadosCO1		:= {}
Local aDadosCO2		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nOpcX			:= 0                                       	// Op็ใo da MsNewGetDados
Local cLinhaOk     	:= "GCP02LEdt"  							// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= ""								  		// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= "+CO2_ITEM"               			  	// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              						// Campos estaticos na GetDados.
Local nMax         	:= 999              						// Numero maximo de linhas permitidas.
Local aAlter    	:= {}                                      	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"						  	// Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"          			  		// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue"    					 	// Funcao executada para validar a exclusao de uma linha do aCols
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsMGet()             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oEnch		 := Nil
Local aCpoEnch   := {}	               	// Campos da Enchoice
Local aAlterEnch := {}		 			// Campos que podem ser editados na Enchoice
Local aPos       := {000,000,080,400} 	// Dimensao da MsMget em relacao ao Dialog  (LinhaI,ColunaI,LinhaF,ColunaF)
Local nModelo    := 3   		 		// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros
Local lF3        := .F.			 		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria
Local lMemoria   := .T.	   		 		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao
Local lColumn    := .F.			 		// Indica se a apresentacao dos campos sera em forma de coluna
Local caTela     := "" 			 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela
Local lNoFolder  := .F.			 		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
Local lProperty  := .F.			 		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
Local nOpcA      := 0					// Botใo Ok ou Cancela
Local nCont      := 0
Local aArea      := GetArea()
Local aAreaSX5	 := SX5->(GetArea())

Local cAliasCab 	:= "CO1"
Local cAliasITem	:= "CO2"
Local aButtons		:= {}
Local aPartic		:= {}
Local aComiss		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis para a MsAdvSize e MsObjSizeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lEnchBar   		:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
Local lPadrao    		:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
Local nMinY	    		:= 400 // Altura mํnima da janela
Local aSize	   			:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 			:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects			:= {}
Local aPosObj	   		:= {}
Local cSeq 				:= ""

Private oGetEdt			:= Nil 
Private oGetPart		:= Nil
Private aColsSav        := {}

Default aSolic			:= {}
Default cPrfEdital	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใo das posi็๕es dos objetos na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine os campos da Enchoiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAliasCab))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAliasCab
	If (X3USO(SX3->X3_USADO)) .AND. (cNivel >= SX3->X3_NIVEL)
		aAdd(aCpoEnch,SX3->X3_CAMPO)

		If (nOpc == 5 .And. ALLTRIM(SX3->X3_CAMPO) $ "CO1_MODALI/CO1_TIPO") .Or.;  //Na geracao nao sera permitido alterar modali / tipo
			nOpc == ALTERAR  .And. ALLTRIM(SX3->X3_CAMPO) $ "CO1_CODEDT/CO1_NUMPRO"
			SX3->(dbSkip())
			Loop
		EndIf

		aAdd(aAlterEnch,SX3->X3_CAMPO)

	Endif
	SX3->(dbSkip())
End
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefini็ใod dos Objetosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == INCLUIR
	nOpcX	:= GD_INSERT+GD_UPDATE+GD_DELETE
ElseIf nOpc == GERAR
	nOpcX	:= GD_DELETE+GD_INSERT+GD_UPDATE
ElseIf nOpc == ALTERAR
	If CO1->(FieldPos("CO1_REMAN")) > 0 .And. CO1->(FieldGet(FieldPos("CO1_REMAN")))
		nOpcX	:= 0
	ELSE   
		nOpcX	:= GD_INSERT+GD_UPDATE+GD_DELETE  //edu 181012
	ENDIF
Else
	nOpcX	:= 0
EndIf
            
if lPrjCni
	if lGCP2MTEL
		lGCP2MTEL := Execblock( "GCP2MTEL", .F., .F.)
		lMTELOk   := lGCP2MTEL
	Else
		lMTELOk   := .F.
	EndIf
EndIf               

oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)

RegToMemory(cAliasCab,IIF(nOpc == INCLUIR .Or. nOpc == GERAR ,.T.,.F.))

if lPrjCni 
	If nOpc == GERAR
		If ExistBlock("GCP02SEQ")
			cSeq := Execblock( "GCP02SEQ", .F., .F.,{cPrfEdital} )
		Else
			cSeq := ""
		EndIF
	
		If ValType( cSeq ) == "C"
			M->CO1_CODEDT := PadR( AllTrim(cPrfEdital)+AllTrim(cSeq), TamSX3( 'CO1_CODEDT' )[1] )
		Else
			M->CO1_CODEDT := PadR( cPrfEdital, TamSX3( 'CO1_CODEDT' )[1] )
		EndIf         
		  
		//--------------------------------------------//
		//Autor: Eric do Nascimento Data:29/02/12     //
		//GAP: 104 Desc.: Retorna modalidade de       //
		// acordo com alguma regra especifica      	  // 
		//--------------------------------------------//
		//+---------------------------------------------+
		//|Alterado a variavel cPrfEdital por cTpModal  |
		//|Devido a altera็๕es realizadas pelo Padrใo   |
		//+---------------------------------------------+
		If ExistBlock("GCP02MOD")
			cTpModal := Execblock( "GCP02MOD", .F., .F.,{cTpModal} )
		Endif
		
		M->CO1_MODALI := cTpModal
		// Posicionar na consulta padrao para obter o nome da modalidade
		M->CO1_DESMOD := Posicione("SX5",1,xFilial("SX5")+'LF'+cTpModal,"X5_DESCRI")
		M->CO1_TIPO	:= cTipo
		M->CO1_REGRA	:= cRegra 
		M->CO1_DESTIP := Posicione("SX5",1,xFilial("SX5")+'LG'+cTipo,"X5_DESCRI")
		aAlter := {"CO2_FRACAS","CO2_OBS"}
	Elseif (lMTELOk )
       
    	if lGCP2OPCX           
			aGCP2OPCX :=  Execblock( "GCP2OPCX", .F., .F. , {M->CO1_CODEDT, M->CO1_NUMPRO} ) 
	                    
	   		//Se edital jแ passou por processo de estorno
			if ValType(aGCP2OPCX[1]) == "N" .And. ValType(aGCP2OPCX[2]) == "A"
				nOpcX  := aGCP2OPCX[1]
				aAlter := aGCP2OPCX[2]                                  
		   	EndIf
		Else
			aAlter := {"CO2_CODPRO","CO2_QUANT","CO2_UM","CO2_VLESTI","CO2_LOTE","CO2_FRACAS","CO2_OBS"}	
	    EndIf
    
	Else
		aAlter := {"CO2_CODPRO","CO2_QUANT","CO2_UM","CO2_VLESTI","CO2_LOTE","CO2_FRACAS","CO2_OBS"}
	EndIf
Else
	If nOpc == GERAR
		If ExistBlock("GCP02SEQ")
			cSeq := Execblock( "GCP02SEQ", .F., .F.,{cPrfEdital} )
		Else
			cSeq := ""
		EndIF
		If ValType( cSeq ) == "C"
			M->CO1_CODEDT := PadR( AllTrim(cPrfEdital)+AllTrim(cSeq), TamSX3( 'CO1_CODEDT' )[1] )
		Else
			M->CO1_CODEDT := PadR( cPrfEdital, TamSX3( 'CO1_CODEDT' )[1] )
		EndIf         
		
		M->CO1_MODALI := cTpModal
		// Posicionar na consulta padrao para obter o nome da modalidade
		M->CO1_DESMOD := Posicione("SX5",1,xFilial("SX5")+'LF'+cTpModal,"X5_DESCRI")
		M->CO1_TIPO	:= cTipo
		M->CO1_REGRA	:= cRegra 
		M->CO1_DESTIP := Posicione("SX5",1,xFilial("SX5")+'LG'+cTipo,"X5_DESCRI")
		aAlter := {"CO2_VLESTI","CO2_LOTE"}

		// Ponto de entrada para gatilhar os dados do Edital
		If lGcp02Edt
			aGcp02Edt := ExecBlock("GCP02EDT",.F.,.F.,{aHeader,aCols,aSolic})
			If ValType( aGcp02Edt ) == "A" .And. Len(aGcp02Edt) > 0
				If ValType( aGcp02Edt[1] ) == "A"
					aDadosCO2 := aClone(aGcp02Edt[1])
					aCols := aClone(aDadosCO2)
				EndIf
				If ValType( aGcp02Edt[2] ) == "A"
					aDadosCO1 := aClone(aGcp02Edt[2])
					For nX := 1 To Len(aDadosCO1)
						&("M->"+AllTrim(aDadosCO1[nX][1])) := aDadosCO1[nX][2]
					Next nX
				EndIf
			EndIf
		EndIf
	Elseif nOpc = REMANESCENTE
		M->CO1_MODALI := cTpModal
		M->CO1_DESMOD := Posicione("SX5",1,xFilial("SX5")+'LF'+cTpModal,"X5_DESCRI")
		M->CO1_TIPO	:= cTipo
		M->CO1_REGRA	:= cRegra
		M->CO1_DESTIP := Posicione("SX5",1,xFilial("SX5")+'LG'+cTipo,"X5_DESCRI") 
		M->CO1_REMAN := .T.
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณpor Eduardo Dias em 27 de Marco de 2012                              ณ
		//ณCampos que permitem preenchimentos sempre que for inclusao de edital ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nOpc == INCLUIR .Or. nOpc == ALTERAR
			aAlter := {"CO2_CODPRO","CO2_QUANT","CO2_UM","CO2_VLESTI","CO2_LOTE","CO2_FRACAS","CO2_OBS"}
		EndIf
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inclusใo de campos de usuแrio para edi็ใo ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SX3->(dbSetOrder(1))
		SX3->(dbSeek(cAliasITem))
		While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAliasITem
			If SX3->X3_PROPRI$"U" .AND. (X3USO(SX3->X3_USADO)) .AND. (cNivel >= SX3->X3_NIVEL)
				aAdd(aAlter,SX3->X3_CAMPO)
			Endif
			SX3->(dbSkip())
		End
	EndIf
EndIf

RestArea(aAreaSX5)

//ฺฤฤฤฤฤฤฤฤฟ
//ณEnchoiceณ
//ภฤฤฤฤฤฤฤฤู
oEnch  := 	MsMGet():New(cAliasCab,nReg,nOpc,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,;
{aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]},; // aPosObj[1]
aAlterEnch,nModelo,/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oDlg,lF3,;
lMemoria,lColumn,caTela,lNoFolder,lProperty)
oEnch:oBox:Align:= CONTROL_ALIGN_TOP

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMsNewGetDadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetEdt	:= 	MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpcX,;
cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDLG,aHeader,aCols)
oGetEdt:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oGetEdt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
//ฺฤฤฤฤฤฤฟ
//ณBotoesณ
//ภฤฤฤฤฤฤู
aAdd(aButtons,{"PRECO",{|| oGetEdt:oBrowse:lDisablePaint:=.T.,GCP02Part(@aPartic,oGetEdt:nAt,nOpc),oGetEdt:oBrowse:lDisablePaint:=.F. },STR0002,STR0003})//"Participante(s) "##"Particip."
                                                                        
//CONSULTA PRECO
aAdd(aButtons,{"CONSULTA",{|| oGetEdt:oBrowse:lDisablePaint:=.T.,GCP02Val(oGetEdt:nAt,nOpc),oGetEdt:oBrowse:lDisablePaint:=.F. },"Consulta Pre็o","Cons. Pre็o"})//"Participante(s) "##"Particip."

if lPrjCni 
	aAdd(aButtons,{"ESTOMOVI",{|| oGetEdt:oBrowse:lDisablePaint:=.T., Eval({|| oGetEdt:oBrowse:lDisablePaint:=.T.,GCP02Solic(@aSolic,nOpc, .T.),oGetEdt:oBrowse:lDisablePaint:=.F.}),oGetEdt:oBrowse:lDisablePaint:=.F. },STR0004,STR0005})//"Solicita็ใo de Compras..."##"Solicita็ใo"
Else
	aAdd(aButtons,{"ESTOMOVI",{|| oGetEdt:oBrowse:lDisablePaint:=.T., Eval({|| oGetEdt:oBrowse:lDisablePaint:=.T.,GCP02Solic(@aSolic,nOpc),oGetEdt:oBrowse:lDisablePaint:=.F.}),oGetEdt:oBrowse:lDisablePaint:=.F. },STR0004,STR0005})//"Solicita็ใo de Compras..."##"Solicita็ใo"
EndIf

aAdd(aButtons,{"POSCLI",{|| oGetEdt:oBrowse:lDisablePaint:=.T.,GCP02Com(@aComiss,nOpc),oGetEdt:oBrowse:lDisablePaint:=.F. },STR0006,STR0006})//"Comissใo "
aAdd(aButtons,{"S4WB011N",{|| GdSeek(@oGetEdt,STR0007) },STR0007,STR0008})//"Buscar produto"##"Buscar produto" ##"Busca"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณpor Icaro Queiroz em 16 de Agosto de 2010            ณ
//ณPE que permite a inclusao de novos botoes na Enchoiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGCP02But         

	if lPrjCni             
		aButAux := Execblock( "GCP02But", .F., .F., {nOpc,M->CO1_CODEDT, M->CO1_NUMPRO,oGetEdt:aCols[oGetEdt:nAt, 1 ], ;
					    	{|| oGetEdt:oBrowse:lDisablePaint:=.T.,   ;
					    	Eval({|| oGetEdt:oBrowse:lDisablePaint:=.T.,GCP02Solic(@aSolic,GERAR, .F.),oGetEdt:oBrowse:lDisablePaint:=.F.}),;
					    	oGetEdt:oBrowse:lDisablePaint:=.F. }       	 } ) //ALTERADO 25/01 - Caio.Santos - FSW - Adicionado parโmetro {nOpc} para validar a opera็ใo no PE
    Else   
		aButAux := Execblock( "GCP02But", .F., .F. )
	EndIf
	
	If ValType( aButAux ) == "A"
		aEval( aButAux, {|x| aAdd( aButtons, x ) } )
	EndIf
EndIf
GCP02TF31() // funcao para preencher atrocaf3
                      
if lPrjCni
	oDlg:bInit 		:= EnchoiceBar(oDlg,{||IIF(GCP02TEdt() .And. Obrigatorio(aGets,aTela), (nOpcA:=OK,   ;
    	                  iif(VlGRVCP02(nOpc, nOpcA, aPartic,aComiss,aSolic,oDlg),oDlg:End(),)   ), ) }, ;
        	           {||RollBackSX8(),oDlg:End()},,aButtons)

	oDlg:lCentered	:= .T.
	oDlg:Activate()

	RestArea(aArea)
Else                   
	oDlg:bInit 		:= EnchoiceBar(oDlg,{||IIF(GCP02TEdt() .And. VldModTip() .And.Obrigatorio(aGets,aTela),(nOpcA:=OK,oDlg:End()), )},{||RollBackSX8(),oDlg:End()},,aButtons)
	oDlg:lCentered	:= .T.
	oDlg:Activate()

	If nOpcA == OK .AND. nOpc != VISUALIZAR
		Begin Transaction
		GCPA02Grv(nOpc,oGetEdt:aCols,aPartic,aComiss,aSolic,aCols)
		End Transaction
		//Envia o email para comissใo
		If nOpc== INCLUIR .Or. nOpc == ALTERAR .Or. nOpc == GERAR
			GCP02ComEmail(M->CO1_CODEDT , M->CO1_NUMPRO )
		EndIf
	Endif

	RestArea(aArea)
EndIf

Return(nOpcA)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPA02Grv บAutor  ณMicrosiga           บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo de grava็ใo dos dados                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GCPA02Grv(nOpc,aItEdt,aPartic,aComiss,aSolic,aCols)
Local aArea := GetArea()
Local aHeadEdt 	:= CriaHeader(nil,"CO2_FILIAL/CO2_CODEDT/CO2_NUMPRO",Nil,"CO2")
Local aHeadPart := CriaHeader(nil,"CO3_FILIAL/CO3_CODEDT/CO3_NUMPRO/CO3_CODPRO",Nil,"CO3")
Local aHeadCons := CriaHeader(nil,"COC_FILIAL/COC_CODEDT/COC_NUMPRO/COC_CODPRO",Nil,"COC")

Local aHeadComis:= CriaHeader(nil,"CO9_NUMPRO/CO9_CODEDT",Nil,"CO9")
Local aHeadSolic:= CriaHeader(Nil,Nil,Nil,"SC1")
Local nX		:= 0
Local nY		:= 0
Local nI		:= 0 
Local nZ		:= 0  
Local nK		:= 0
Local bCampo 	:= {|nField| FieldName(nField)}                   
Local nPosItemEdt:=aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_ITEM"})
Local nPosProdEdt:=aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_CODPRO"})
Local nPosRevoga:=aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_FRACAS"})
Local nPosLtCO2:=aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_LOTE"})
Local nPRvObsCO2:=aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_OBS"})
Local nPosReman :=aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_REMAN"})

Local nPosLoteEdt := 0
Local nPosTipPar:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_TIPO"})
Local nPosCodPar:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_CODIGO"})
Local nPosLojPar:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_LOJA"})
Local nPosItCO3:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_ITEM"})
Local nPosLtCO3:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_LOTE"})
Local nPosRvPar:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_REVOGA"})
Local nPosRvObs:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_OBS"})

Local nP_Lot	:= 0
Local nPosCodCon:= aScan(aHeadCons,{|x| AllTrim(x[2])=="COC_CODIGO"})
Local nPosLojCon:= aScan(aHeadCons,{|x| AllTrim(x[2])=="COC_LOJA"})
Local nPosItComis:= aScan(aHeadComis,{|x| AllTrim(x[2])=="CO9_ITEM"})
Local nPosNumSc	:= aScan(aHeadSolic,{|x| AllTrim(x[2])=="C1_NUM"}) + 1  // a primeira posi็ใo ้ a marca do listbox
Local nPosItSc	:= aScan(aHeadSolic,{|x| AllTrim(x[2])=="C1_ITEM"}) + 1 // a primeira posi็ใo ้ a marca do listbox
Local cItemCO2	:= Replicate("0",TamSX3("CO2_ITEM")[1])     
Local nAuxProd	:= 0
Local nAuxItem	:= 0
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local cRetff := ""
Local lGCP2FCCO2 := iif ( lPrjCni , ExistBlock("GCP2FCCO2"), .F.), lRetCmps           
Local cGCP02GRV	:= Existblock("GCP02GRV")
Local n1Cnt		:= 0
Local n2Cnt		:= 0
Local cCampo	:= ""
Local aGrvCO1	:= {}
Local aGrvCO7	:= {}
Local lVoltaEtp := .F.
Local lContinua	:= .T.             
Local cGrvLote	:= ""
Local aRevoga	:= {}
Local nSeek		:= 0
Local cObsRev	:= ""
                   
If	nOpc == ALTERAR
	//-- Verifica se a etapa de referencia "neste caso PB - publicacao" foi executada
	If	GCPChkCO7("1",M->CO1_CODEDT,M->CO1_NUMPRO,PadR("PB",Len(CO7->CO7_MOVATU)),M->CO1_ETAPA,aGrvCO1,aGrvCO7)

		//-- Verifica se houve alteracoes na tabela CO1
		For n1Cnt := 1 To CO1->(FCount())
		
			cCampo := CO1->(Eval( bCampo, n1Cnt ))
		
			If	M->&( cCampo ) != CO1->(FieldGet(FieldPos(cCampo))) 
				lVoltaEtp := .T.
				Exit
			EndIf
	
		Next
		//-- Verifica se houve alteracoes na tabela CO2
		If	! lVoltaEtp
			CO2->(DbSetOrder(1))
			For n1Cnt := 1 To Len(aItEdt)
				If	!GdDeleted(n1Cnt,aHeadEdt,aItEdt) .And. CO2->(DbSeek(xFilial("CO2")+M->CO1_CODEDT+M->CO1_NUMPRO+aItEdt[n1Cnt,nPosProdEdt]))
			
					For n2Cnt := 1 To Len(aHeadEdt)
						If	aHeadEdt[n2Cnt,10]!="V" .And. aItEdt[n1Cnt,n2Cnt] != CO2->(FieldGet(FieldPos(AllTrim(aHeadEdt[n2Cnt,2])))) 
							lVoltaEtp := .T.
							Exit
						EndIf
					Next
					If	lVoltaEtp
						Exit
					EndIf
					
				Else
					//-- Inclusao ou delecao de linhas no Grid
					lVoltaEtp := .T.
					Exit
				EndIf
			Next		
		EndIf
		
		//-- Verifica se houve alteracoes na tabela CO3
		//-- Quando CO1_REGRA=="002" volta a etapa somente para editais com modalidade diferente de "PG"
		If	! lVoltaEtp .And. aScan(aItEdt,{|x| x[Len(aItEdt[1])] == .F.}) > 0 .And. Iif(M->CO1_REGRA == "002",CO1->CO1_MODALI != "PG",.T.)
			CO3->(DbSetOrder(1))
			For nY := 1 to Len(aPartic)
				aItPart := aPartic[nY,2]
				For n1Cnt := 1 To Len(aItPart)
					If	! GdDeleted(n1Cnt,aHeadPart,aItPart) .And. CO3->(DbSeek(xFilial("CO3")+M->CO1_CODEDT+M->CO1_NUMPRO+aPartic[nY,1]+aItPart[n1Cnt,nPosTipPar] + aItPart[n1Cnt,nPosCodPar] + aItPart[n1Cnt,nPosLojPar]))
						For n2Cnt := 1 To Len(aHeadPart)
							If	aHeadPart[n2Cnt,10]!="V" .And. aItPart[n1Cnt,n2Cnt] != CO3->(FieldGet(FieldPos(AllTrim(aHeadPart[n2Cnt,2]))))
								lVoltaEtp := .T.
								Exit
							EndIf
						Next
						If	lVoltaEtp
							Exit
						EndIf
					Else
						//-- Inclusao ou delecao de linhas no Grid
						lVoltaEtp := .T.
						Exit
					EndIf	
				Next	
				If	lVoltaEtp
					Exit
				EndIf
			Next
			aItPart := {}
		EndIf
			
		//-- Se houve alguma alteracao no Edital apos publicacao
		If	lVoltaEtp
			If lPrjCni
				lContinua := MsgYesNo(STR0100,STR0057)//"Qualquer modifica็ใo no edital exige divulga็ใo, o Edital voltarแ para etapa de Publica็ใo, Confirma a Altera็ใo ?"###"Aten็ใo"

				If	lContinua
					If	! MsgYesNo("A altera็ใo afetarแ a formula็ใo das propostas?",STR0057)
						aGrvCO1:={}
					EndIf
				EndIf				

			Else	
				lContinua := MsgYesNo(STR0099+CRLF+STR0100,STR0057)	//"Lei 8.666/1993 - Art.21 ง 4o"###"Qualquer modifica็ใo no edital exige divulga็ใo, o Edital voltarแ para etapa de Publica็ใo, Confirma a Altera็ใo ?"###"Aten็ใo"
				
				If	lContinua
					If	! MsgYesNo("A altera็ใo afetarแ a formula็ใo das propostas?",STR0057)
						aGrvCO1:={}
					EndIf
				EndIf				

			EndIf
		EndIf
	EndIf
EndIf


If	lContinua
//--
	If	CO2->(FieldPos("CO2_LOTE"))>0 .And. CO3->(FieldPos("CO3_LOTE"))>0
		nPosLoteEdt := aScan(aHeadEdt,{|x| AllTrim(x[2])=="CO2_LOTE"})
		nP_Lot		:= aScan(aHeadPart,{|x| AllTrim(x[2])=="CO3_LOTE"})
	EndIf

	For n1Cnt := 1 To Len(aItEdt)
		If	!GdDeleted(n1Cnt,aHeadEdt,aItEdt)
			//-- Efetuar a replica da digitacao dos participantes caso avaliacao por lote
			If	nPosLoteEdt > 0 .And. nP_Lot > 0
				cGrvLote := aItEdt[n1Cnt,nPosLoteEdt]
			EndIf

			If	!Empty(cGrvLote)
				aItPart := {}
				//-- Procura em apartic a digitacao dos participantes para este lote
				For nX := 1 To Len(aPartic)
					nY := AScan(aPartic[nX,2],{|x| AllTrim(x[nP_Lot])==AllTrim(cGrvLote)})
					If	nY>0
						aItPart := AClone(aPartic[nX,2])
						Exit
					EndIf
				Next
				If	!Empty(aItPart)
					For nX := 1 To Len(aItEdt)
						If	aItEdt[nX,nPosLoteEdt]==cGrvLote .And. !GdDeleted(nX,aHeadEdt,aItEdt)
							nY := AScan(aPartic,{|x| x[1]==aItEdt[nX,nPosProdEdt] } )
							If	nY==0
								AAdd(aPartic,{aItEdt[nX,nPosProdEdt],{}})
								nY := Len(aPartic)
							EndIf
	
							If	Empty(aPartic[nY,2])
								aPartic[nY,2]:=AClone(aItPart)
							EndIf
						EndIf
					Next
				EndIf	
			EndIf
		EndIf
	Next
	aItPart := {}

	if lPrjCni
		If ExistBlock("GCP02PA8") //<---ponto de entrada do Cristiano // Alterado pelo Eric (Passando o nOpc)
			Execblock( "GCP02PA8", .F., .F.,{M->CO1_NUMPRO,nOpc} )
		EndIf
	EndIf
	
	// Se tiver algum item marcado
	If aScan(aItEdt,{|x| x[Len(aItEdt[1])] == .F.}) > 0
		//Grava os Participantes
		CO3->(dbSetOrder(3)) //CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO+CO3_ITEM+CO3_LOTE
		For nY := 1 to Len(aPartic)
			aItPart := aPartic[nY][2]
			For nX := 1 To Len(aItPart)
				lGrava := ( CO3->(dbSeek(xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)+ aPartic[nY][1] + aItPart[nX][nPosItCO3] + aItPart[nX][nPosLtCO3] ) ) )
				// Se linha deletada
				If  aItPart[nX,Len(aHeadPart)+1] .Or. (lVoltaEtp .And. aItPart[nX,nPosRvPar]=="1") 
					If lGrava

						If	lVoltaEtp .And. aItPart[nX,nPosRvPar]=="1"
							nSeek := AScan(aRevoga,{|x| x[1]==aItPart[nX,nPosLtCO3]})
							If	nSeek == 0
								AAdd(aRevoga,{aItPart[nX,nPosLtCO3],"","",""})
								nSeek := Len(aRevoga)
							EndIf
							
							If	!(AllTrim( CO3->CO3_CODIGO )$aRevoga[nSeek,3])
								aRevoga[nSeek,3]:=aRevoga[nSeek,3]+AllTrim( CO3->CO3_CODIGO )+" "+AllTrim( CO3->CO3_LOJA )+"  "
								aRevoga[nSeek,4]:=aRevoga[nSeek,4]+AllTrim( aItPart[nX,nPosRvObs] )+". "
							EndIf
							
						EndIf

						RecLock("CO3",.F.)
						CO3->(dbDelete())
						MsUnlock()
					EndIf
				EndIf
				
				// Apenas grava participante com produto Ativo
				nAuxProd := aScan(aItEdt,{ |aLinha| Alltrim(aLinha[nPosProdEdt]) == Alltrim(aPartic[nY][1]) })           
	            If nAuxProd > 0 .And. !aItEdt[nAuxProd,Len(aHeadEdt)+1]  
					If !aItPart[nX,Len(aHeadPart)+1] 
						RecLock("CO3",!lGrava)
						For nI:= 1 to Len(aHeadPart)-2
							If FieldPos(Trim(aHeadPart[nI,2])) > 0
								CO3->(FieldPut(FieldPos(Trim(aHeadPart[nI,2])),aItPart[nX,nI]))
							EndIf
						Next nI
						CO3->CO3_FILIAL := xFilial("CO3")
						CO3->CO3_CODEDT := M->CO1_CODEDT
						CO3->CO3_NUMPRO := M->CO1_NUMPRO
						CO3->CO3_CODPRO := aPartic[nY][1]
						CO3->CO3_LANCE	:= CO3->CO3_VLUNIT
						MsUnLock()
					EndIf
				EndIf
			Next nX
		Next nY
    EndIf
     
	// Se tiver algum item marcado                                              
	If aScan(aItEdt,{|x| x[Len(aItEdt[1])] == .F.}) > 0
		//Grava os Participantes
		If AliasInDic("COC")
			COC->(dbSetOrder(1)) //CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO+CO3_TIPO+CO3_CODIGO+CO3_LOJA
			For nY := 1 to Len(aAcols/*aPartic*/)
				aAColsFor/*aItPart*/ := aAcols[nY][2]
				For nX := 1 To Len(aAColsFor)
					lGrava := !(COC->(dbSeek(xFilial("COC")+M->(CO1_CODEDT+CO1_NUMPRO)+ aAcols[nY][1] + aAColsFor[nX][nPosTipPar] + aAColsFor[nX][nPosCodPar] ) ) )
					// Se linha deletada
					If aAColsFor[nX,Len(aAcolsFor[nX])]
						RecLock("COC",.F.)
						COC->(dbDelete())
						MsUnlock()
					EndIf				
					//Apenas grava participante com produto Ativo
					nAuxItem := aScan(aItEdt,{ |aLinha| aLinha[nPosItemEdt] == aAcols[nY][1] })
		            If nAuxItem > 0 .And. !aItEdt[nAuxItem,Len(aHeadEdt)+1]  
						If !aAColsFor/*!aItPart*/[nX,Len(aHeadCons/*aHeadPart*/)-1] 
							RecLock("COC",lGrava)							
							For nI:= 1 to Len(aHeadCons/*aHeadPart*/)-2
								If FieldPos(Trim(aHeadCons/*aHeadPart*/[nI,2])) > 0
									COC->(FieldPut(FieldPos(Trim(aHeadCons/*aHeadPart*/[nI,2])),aAColsFor/*aItPart*/[nX,nI]))
								EndIf
							Next nI
							COC->COC_FILIAL := xFilial("COC")
							COC->COC_CODEDT := M->CO1_CODEDT
							COC->COC_NUMPRO := M->CO1_NUMPRO     
							COC->COC_ITEMED	:= aACols[nY][1]
							COC->COC_CODPRO := aACols/*aPartic*/[nY][5]           
							COC->COC_CODIGO := aAColsFor[nX][1]
							COC->COC_LOJA	:= aAColsFor[nX][2]
							COC->COC_PRECO	:= aAColsFor[nX][4]       
							COC->COC_VLRCON := aAcols[nY][3]
							MsUnLock()
						EndIf
					EndIf
				Next nX
			Next nY
		EndIf

		//Manipula a solicita็ใo de compras
		SC1->(dbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM
		SC8->(dbSetOrder(4)) //C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
		For nX := 1 to Len(aSolic)
			aSolAux := aSolic[nX][2]
			For nY:= 1 to Len(aSolAux)
				If aSolAux[nY][1]			
					If SC1->( MsSeek(xFilial("SC1") + aSolAux[nY][nPosNumSc] + aSolAux[nY][nPosItSc]) )
						RecLock("SC1",.F.)
						SC1->C1_CODED:= M->CO1_CODEDT
						SC1->C1_NUMPR:= M->CO1_NUMPRO
						SC1->C1_MODAL:= M->CO1_MODALI
						SC1->C1_TPMOD:= M->CO1_TIPO
						SC1->C1_COTACAO := "EDITAL"
						MsUnLock() 
						//Caio.Santos - 11/01/13 - Req.72
						If lPrjCni
							RSTSCLOG("EDT",1,/*cUser*/)
						EndIf
						If SC8->( MsSeek(xFilial("SC8")+SC1->(C1_COTACAO+C1_IDENT+C1_PRODUTO)))
							RecLock("SC8",.F.) 
							SC8->C8_CODED:= M->CO1_CODEDT
							SC8->C8_NUMPR:= M->CO1_NUMPRO					
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Next nY
		Next nX
		
		//Grava os itens do Edital
		CO2->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
		For nX := 1 To Len(aItEdt)
			If	lVoltaEtp .And. aItEdt[nX,nPosRevoga]=="S"
				lRevPar:=.F.
				nSeek := AScan(aRevoga,{|x| x[1]==aItEdt[nX,nPosLtCO2] })
			
				If	nSeek == 0
					AAdd(aRevoga,{aItEdt[nX,nPosLtCO2],"","",AllTrim( aItEdt[nX,nPRvObsCO2] )+". "})
					nSeek := Len(aRevoga)
					lRevPar:=.T.
				EndIf
			
			
				aRevoga[nSeek,2]:=aRevoga[nSeek,2]+AllTrim( aItEdt[nX,nPosProdEdt] ) + " "
			EndIf
			lGrava := (CO2->(dbSeek(xFilial("CO2")+M->(CO1_CODEDT+CO1_NUMPRO)+aItEdt[nX][nPosProdEdt]) ) )
			// Apaga os CO3 atrelados ao item caso o item do edital esteja deletado
			If (aItEdt[nX,Len(aHeadEdt)+1] .Or. (lVoltaEtp .And. aItEdt[nX,nPosRevoga]=="S")) .And. CO3->(MsSeek(xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)+ aItEdt[nX][nPosProdEdt]))
				While CO3->(!EOF()) .And. CO3->( CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO ) == xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)+ aItEdt[nX][nPosProdEdt]
					If	lVoltaEtp .And. aItEdt[nX,nPosRevoga]=="S" .And. lRevPar
						aRevoga[nSeek,3] := aRevoga[nSeek,3] + AllTrim( CO3->CO3_CODIGO )+" "+AllTrim( CO3->CO3_LOJA )+"  "
					EndIf
					RecLock("CO3",.F.)
					CO3->(dbDelete())
					MsUnlock()
					CO3->(dbSkip())
				EndDo
			ENdIf
			//Retira os relacionamentos da solicita็ใo
			If (aItEdt[nX,Len(aHeadEdt)+1] .Or. (lVoltaEtp .And. aItEdt[nX,nPosRevoga]=="S")) .And. SC1->(MsSeek(xFilial("SC1")+M->(CO1_CODEDT+CO1_NUMPRO)+aItEdt[nX,nPosProdEdt]))
				While SC1->(!EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == xFilial("SC1")+M->(CO1_CODEDT+CO1_NUMPRO)+aItEdt[nX,nPosProdEdt]
					RecLock("SC1",.F.)
					SC1->C1_CODED:= ''
					SC1->C1_NUMPR:= ''
					SC1->C1_MODAL:= ''
					SC1->C1_TPMOD:= ''
					SC1->C1_COTACAO	:= ''
					SC1->(MsUnLock())
				End
			ENdIf
			If (aItEdt[nX,Len(aHeadEdt)+1] .And. lGrava)
				SC1->(DbSetOrder(1)) 
				If SC1->(DbSeek(xFilial('SC1')+CO2->CO2_NUMSC+CO2->CO2_ITEMSC))
					RecLock("SC1",!lGrava)
					SC1->C1_CODED:= ''
					SC1->C1_NUMPR:= ''
					SC1->C1_MODAL:= ''
					SC1->C1_TPMOD:= ''
					SC1->C1_COTACAO	:= ''
					SC1->(MsUnlock())
				EndIf
				RecLock("CO2",!lGrava)  
				
				if lPrjCni                                                                  
					if Existblock( 'GCP2EXC1') 
						Execblock( "GCP2EXC1", .F., .F. , {CO2->CO2_CODPRO} ) 	
					EndIf     
				EndIf
				
				CO2->(dbDelete())
				MsUnlock()
				
				
			ElseIf !aItEdt[nX,Len(aHeadEdt)+1]
				cItemCO2 := Soma1(cItemCO2)
				RecLock("CO2",!lGrava)
				For nI:= 1 to Len(aHeadEdt)-2  
				
					if lPrjCni 
						if lGCP2FCCO2			
							lRetCmps	:= Execblock( "GCP2FCCO2", .F., .F., {Trim(aHeadEdt[nI,2])} )
							
							if ValType(lRetCmps) == "L"
					           
								if lRetCmps == .T.
									CO2->(FieldPut(FieldPos( Trim(aHeadEdt[nI,2] ) ) , aItEdt[nX,nI] ) )
								EndIf
									
					        Else
					        	CO2->(FieldPut(FieldPos( Trim(aHeadEdt[nI,2] ) ) , aItEdt[nX,nI] ) )
					        EndIf
						Else                                                                      
							CO2->(FieldPut(FieldPos( Trim(aHeadEdt[nI,2] ) ) , aItEdt[nX,nI] ) )
						EndIf
					Else
						If	FieldPos(Trim(aHeadEdt[nI,2]))>0
							CO2->(FieldPut(FieldPos( Trim(aHeadEdt[nI,2] ) ) , aItEdt[nX,nI] ) )
						EndIf
					EndIf
					
				Next nI   
				
				if lPrjCni                                        
					if Existblock( 'GCP2INSE')  //Marca Itens que foram excluidos do Edital(CO2)
						Execblock( "GCP2INSE", .F., .F. , {nOpc,CO2->CO2_QUANT,CO2->CO2_CODPRO} ) 	
					EndIf
				EndIf
				
				CO2->CO2_FILIAL  := xFilial("CO2")
				CO2->CO2_CODEDT  := M->CO1_CODEDT
				CO2->CO2_NUMPRO  := M->CO1_NUMPRO
				CO2->CO2_ORIGEM  := "CO1"
				CO2->CO2_ITEM  	 := cItemCO2

				MsUnLock()

				//-- Voltara para a etapa de homologacao entao ajusta o CO3
				If	lVoltaEtp .And. !Empty(aGrvCO1) .And. CO3->(DbSeek(xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)+ aItEdt[nX][nPosProdEdt]))
					While CO3->(!EOF()) .And. CO3->( CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO ) == xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)+ aItEdt[nX][nPosProdEdt]
						RecLock("CO3",.F.)
						CO3->CO3_VLUNIT := CO3->CO3_LANCE
						CO3->CO3_RANK   := Space(Len(CO3->CO3_RANK))
						CO3->CO3_CLASS  := "X"
						CO3->CO3_CLAANT := Space(Len(CO3->CO3_CLAANT))
						CO3->CO3_REVOGA := "2"						
						MsUnlock()
						CO3->(DbSkip())
					EndDo
				EndIf

			EndIf
		Next nX
		
		//Grava a comissใo
		CO9->(dbSetOrder(1)) //CO9_FILIAL+CO9_CODEDT+CO9_NUMPRO+CO9_ITEM
		For nX := 1 To Len(aComiss)
			lGrava := (CO9->(dbSeek(xFilial("CO9")+M->(CO1_CODEDT+CO1_NUMPRO)+aComiss[nX][nPosItComis]) ) )
			If aComiss[nX,Len(aHeadComis)+1] .And. lGrava
				RecLock("CO9",!lGrava)
				CO9->(dbDelete())
				MsUnlock()
			ElseIf !aComiss[nX,Len(aHeadComis)+1]
				RecLock("CO9",!lGrava)
				For nI:= 1 to Len(aHeadComis)-2
					If FieldPos(Trim(aHeadComis[nI,2]))>0
						CO9->(FieldPut(FieldPos(Trim(aHeadComis[nI,2])),aComiss[nX,nI]))
					EndIf
				Next nI
				CO9->CO9_FILIAL := xFilial("CO9")
				CO9->CO9_CODEDT := M->CO1_CODEDT
				CO9->CO9_NUMPRO := M->CO1_NUMPRO
				CO9->CO9_ITEM 	:= aComiss[nX][nPosItComis]
				MsUnLock()
			EndIf
		Next nX
		
		//Grava o Cabe็alho da Tabela
		CO1->(dbSetOrder(1)) //CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO
		lGrava :=!(CO1->(dbSeek(xFilial("CO1")+M->(CO1_CODEDT+CO1_NUMPRO))))
		RecLock("CO1",lGrava)
		For nX := 1 to CO1->(FCount())
			If "FILIAL" $ CO1->(FieldName(nX))
				CO1->(FieldPut(nX,xFilial("CO1")))
			Else
				CO1->(FieldPut(nX,M->&(Eval(bCampo,nX) )))
			EndIf
			//Inicia o andamento por passo especifico.
			If M->CO1_ETAPA == "ED" .AND. (M->CO1_MODALI == "DL" .Or.  M->CO1_MODALI == "IN") .AND. AllTRim(M->CO1_TIPO) $ "DV/DE"
					CO1->CO1_PASSO := "29"
			ElseIf M->CO1_ETAPA == "ED" .AND. (M->CO1_MODALI == "DL" .Or.  M->CO1_MODALI == "IN") .AND. AllTRim(M->CO1_TIPO) $ "DI/AA"
					CO1->CO1_PASSO := "31"
			Elseif M->CO1_ETAPA == "ED" .AND. M->CO1_MODALI == "DL" .AND. AllTRim(M->CO1_TIPO) $ "DV"
					CO1->CO1_PASSO := "62"	
			EndIf
		Next nX
		MsUnlock()          

		//-- Lei 8.666/1993 - Art.21 ง 4o - Voltar a etapa e passo para Publicacao
		If	lVoltaEtp .And. !Empty(aGrvCO7)

			If	!Empty(aRevoga)
				cRevoga:=""
				nSeek := 0
				For nSeek := 1 To Len(aRevoga)
					cRevoga+=aRevoga[nSeek,1]+CRLF+aRevoga[nSeek,2]+CRLF+aRevoga[nSeek,3]+CRLF
					cRevoga+="- - -"+CRLF
					
					cObsRev+=aRevoga[nSeek,4]
				Next
				//-- Grava historico revogado
				GCPA006({{"CO7_CODEDT", M->CO1_CODEDT},;
					{"CO7_NUMPRO", M->CO1_NUMPRO},;
					{"CO7_VERSAO", M->CO1_VERSAO},;
					{"CO7_DTMOV" , dDataBase},;
					{"CO7_HRMOV" , Time()},;
					{"CO7_CODUSU", Upper(Alltrim(Substr(cUsuario,7,15)))},;
					{"CO7_MOVATU", "PR"},;
					{"CO7_DESATU", Posicione("SX5",1,xFilial("SX5")+'LE'+"PR","X5_DESCRI")},;										//Revogado
					{"CO7_ACAO"  , "" },;
					{"CO7_OBS001", cRevoga },;								//Revogado
					{"CO7_OBS002", cObsRev },;
					{"CO7_PASATU", M->CO1_PASSO}})
			EndIf

			GCPA006(aGrvCO7, aGrvCO1)
			aGrvCO1 := {}
			aGrvCO7 := {}
		EndIf
		
		//Envia o email para comissใo
		If nOpc== INCLUIR .Or. nOpc == ALTERAR .Or. nOpc == GERAR
			GCP02ComEmail(M->CO1_CODEDT , M->CO1_NUMPRO )
		EndIf
		
		if lPrjCni                              
			If ExistBlock("GCP2GRVA")
				Execblock( "GCP2GRVA", .F., .F.,{M->CO1_CODEDT, M->CO1_NUMPRO, M->CO1_MODALI, M->CO1_TIPO,oGetEdt:aCols,oGetEdt:aHeader} )
			EndIf     
		EndIf
	Else
		//Deleta Itens do Edital
		CO2->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
		CO2->(dbSeek(xFilial("CO2")+M->(CO1_CODEDT+CO1_NUMPRO) ) )
		While CO2->(!EOF()) .And. CO2->( CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO ) == xFilial("CO2")+M->(CO1_CODEDT+CO1_NUMPRO)
			RecLock("CO2",.F.)   
			
			if lPrjCni
				if Existblock( 'GCP2DELE')  //Marca Itens que foram excluidos do Edital(CO2)
					Execblock( "GCP2DELE", .F., .F. , {CO2->CO2_CODPRO} ) 	
				EndIf     
			EndIf
			
			CO2->(dbDelete())
			MsUnlock()
			CO2->(dbSkip())
		EndDo
		
		//Deleta Participantes do Edital
		CO3->(dbSetOrder(1)) //CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO+CO3_TIPO+CO3_CODIGO
		CO3->(dbSeek(xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO) ) )
		While CO3->(!EOF()) .And. CO3->( CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO ) == xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)
			RecLock("CO3",.F.)
			CO3->(dbDelete())
			MsUnlock()
			CO3->(dbSkip())
		EndDo
		
		//Deleta Comissao do Edital
		CO9->(dbSetOrder(1)) //CO9_FILIAL+CO9_CODEDT+CO9_NUMPRO+CO9_ITEM
		CO9->(dbSeek(xFilial("CO9")+M->(CO1_CODEDT+CO1_NUMPRO) ) )
		While CO9->(!EOF()) .And. CO9->( CO9_FILIAL+CO9_CODEDT+CO9_NUMPRO ) == xFilial("CO9")+M->(CO1_CODEDT+CO1_NUMPRO)
			RecLock("CO9",.F.)
			CO9->(dbDelete())
			MsUnlock()
			CO9->(dbSkip())
		EndDo
		
		//Retira o relacionamento com a solicita็ใo de compra
		SC1->(dbOrderNickName("GCP01")) //C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO+C1_NUM+C1_ITEM
		SC1->(MsSeek(xFilial("SC1")+M->(CO1_CODEDT+CO1_NUMPRO)))
		While SC1->(!EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR) == xFilial("SC1")+M->(CO1_CODEDT+CO1_NUMPRO)
			RecLock("SC1",.F.)
			SC1->C1_CODED:= ''
			SC1->C1_NUMPR:= ''
			SC1->C1_MODAL:= ''
			SC1->C1_TPMOD:= ''
			SC1->C1_COTACAO	:= ''
			SC1->(MsUnLock())
		End
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDeleta o Cabe็calhoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CO1->(dbSetOrder(1)) //CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO
		If CO1->(dbSeek(xFilial("CO1")+M->(CO1_CODEDT+CO1_NUMPRO)))
			RecLock("CO1",.F.)
			CO1->(dbDelete())
			MsUnlock()
		EndIf
	EndIf
	
	//ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Copia os parโmetros para o ponto de entrada CP02CMP ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Aadd(aREdital,{xFilial("CO1"),M->CO1_CODEDT,M->CO1_NUMPRO})
	aRHeader := aClone(oGetEdt:aHeader)
	aRCols   := aClone(oGetEdt:aCols)
	aRPartic := aClone(aPartic)
	aRComiss := aClone(aComiss)
	aRSolic  := aClone(aSolic)
	                                         
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ P.E. para complementar a grava็ใo dos dados, ou envio de email  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cGCP02GRV
		Execblock("GCP02GRV",.F.,.F.)
	EndIf
EndIf
	
RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02VldPro  บAutor  ณ Totvs          บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao para nao permitir o produto duas vezes para, o   บฑฑ
ฑฑบ          ณ mesmo Edital. Esta sendo executado pelo X3_VLDUSER do      บฑฑ
ฑฑบ          ณ campo CO2_CODPRO                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GCP02VldPro()

Local lRet := .T.
Local i := 0
Local nT_aCOLS := Len(oGetEdt:aCOLS)
Local nItem := oGetEdt:nAt
Local nP_Pro := aScan(oGetEdt:aHeader,{|x| Trim(x[2])=="CO2_CODPRO"})
Local cProd := M->CO2_CODPRO

For i:=1 To nT_aCOLS
	If i <> nItem
		If oGetEdt:aCOLS[i,nP_Pro] == cProd .And. !(oGetEdt:aCOLS[i,Len(oGetEdt:aHeader)+1])  
			Help("",1,"GCP02NOPROD") //"Jแ existe este c๓digo de produto para este Edital."
			lRet := .F.
		Endif
	Endif
Next i

Return(lRet)          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ  GCP02Hr() ณ Autor ณ    Eduardo Dias     ณ Data ณ 19/04/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Validacao dos Campos H9_HRINI e H9_HRFIM                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ GCPA002                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02Hr()       
Local cHora := &(ReadVar())
 
If ValType(cHora) == "C"
	If "-" $ cHora .Or. "  " $ cHora
		Help(" ",1,"HORAINVALI")
		Return(.F.)
	Endif

	If ! Empty(cHora)
		If Val(Left(ALLTRIM(cHora), 2)) > 23 .Or. Val(Right(ALLTRIM(cHora), 2)) > 59
			Help(" ",1,"HORAINVALI")
			Return(.F.)
		Endif
	Endif
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02TEdt บAutor  ณMicrosiga           บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTudoOK da tela de Edital                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02TEdt()
Local lRet 		:= .T.
Local aValTipo	:= Iif(M->CO1_REGRA == "002",aModXTipo2,aModXTipo)
Local nX 			:= 0
Local lRetPE		:= .F. 
Local nCont		:= 0
Local nSomaTot	:= SomaCO2()
Local cTextoV		:= ""
Local lPrjCni 	:= FindFunction("ValidaCNI") .And. ValidaCNI()
Local nPosRevo	:= aScan(oGetEdt:aHeader,{|x| AllTrim(x[2])=="CO2_FRACAS"})
For nX :=  1 to Len(oGetEdt:aCols)
	//-- Valida itens nao deletados e nao revogados
	If !oGetEdt:aCols[nX][Len(oGetEdt:aHeader)+1] .And. oGetEdt:aCols[nX,nPosRevo]!="S" 
		If !GCP02LEdt(nX)
			lRet := .F.
			Exit
		EndIf
		nCont++ 
	EndIf
Next nX

If lRet .And. Empty(nCont) 
	Help("",1,"GCP02NOITEM") //"ษ necessแrio pelo menos um produto no edital"
	lRet := .F.
EndIf                                       

If lRet
	lRet := ValDiaSRP()
EndIf

If	lRet   
	lRet := GCPA017Lim(M->CO1_REGRA,M->CO1_ESPECI,M->CO1_MODALI,nSomaTot)
	
	If	M->CO1_REGRA=="001" .And. M->CO1_ESPECI=="3"
		Aviso(STR0057,STR0101+" "+M->CO1_REGRA,{"OK"})		//"Especie nใo permitida para Regra"
		lRet := .F.
	EndIf
EndIf

If lRet .And. M->CO1_REGRA = "002" .And. M->CO1_MODALI == "TP"
	Aviso(STR0057,STR0134,{"OK"},1)
	lRet :=.F.
EndIf

If lRet
	nCont := aScan(aValTipo,{|x| x[1] == M->CO1_MODALI})
	If !Empty(aValTipo[nCont,2]) .And. Empty(M->CO1_TIPO) .And. !(M->CO1_TIPO $ aValTipo[nCont,2])
		Aviso(STR0057,STR0058,{"OK"}) //-- ษ necessแrio informar o tipo da modalidade para este edital.
		lRet := .F.
	ElseIf Empty(aValTipo[nCont,2]) .And. !Empty(M->CO1_TIPO)
		M->CO1_TIPO := CriaVar("CO1_TIPO",.F.)
	ElseIf !(M->CO1_TIPO $ aValTipo[nCont,2])
		cTextoH := STR0059 +M->CO1_MODALI +" - " +AllTrim(M->CO1_DESMOD) //-- O tipo de modalidade selecionado nใo ้ valido para a modalidade ###
		cTextoH += STR0060 //-- . Esta modalidade adimite os seguintes tipos de modalidade:
		For nX := 1 To Len(aValTipo[nCont,2])
			If !Empty(Substr(aValTipo[nCont,2],nX,2))
				cTextoH += CRLF +Substr(aValTipo[nCont,2],nX,2) +" - " +AllTrim(Tabela("LG",Substr(aValTipo[nCont,2],nX,2),.F.))
			EndIf
			nX += 2
		Next nX
		Aviso(STR0057,cTextoH,{"OK"},2)
		lRet := .F.         
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para permitir valida็ใo de usuแrio na TudoOk da tela de editalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .And. ExistBlock("GCPA2EOK")
	lRetPE:= ExecBlock("GCPA2EOK",.F.,.F.)
	If Valtype( lRetPE ) == "L"
		lRet := lRetPE
	EndIf
EndIf

lRTudoOk := lRet

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02LEdt   บAutor  ณMicrosiga        บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da linha da grid de Edital                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GCP02LEdt(nLinha)
Local lRet := .T.
Local aCols:= oGetEdt:aCols
Local aHeader:= oGetEdt:aHeader
Local nPosQuant:= aScan(aHeader,{|x| AllTrim(x[2])=="CO2_QUANT"})
Local nPosCod:= aScan(aHeader,{|x| AllTrim(x[2])=="CO2_CODPRO"}) 
Local nPosPreco:= aScan(aHeader,{|x| AllTrim(x[2])=="CO2_VLESTI"})
Local nPosLote:=aScan(aHeader,{|x| AllTrim(x[2])=="CO2_LOTE"})
Local nPosRevo:=aScan(aHeader,{|x| AllTrim(x[2])=="CO2_FRACAS"})
Local nPosObs :=aScan(aHeader,{|x| AllTrim(x[2])=="CO2_OBS"})
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local  lGCP2VALL   := iif (lPrjCni, Existblock( 'GCP2VALL'), .F.)
Local  lRetTst := .F., lRetOk := .F.
Local n1Cnt := 0
Local n2Cnt := 0

Default nLinha := oGetEdt:nAt

If Valtype(nLinha) != "N"
	nLinha := oGetEdt:nAt
EndIf

If aCols[nLinha,Len(aHeader)+1]
	Return(.T.)
Endif
              

if lPrjCni                            
	if lGCP2VALL
		lRetTst :=	Execblock( "GCP2VALL", .F., .F., {aCols[nLinha,nPosCod], aCols[nLinha,nPosQuant]} )
		if ValType(lRetTst) == "L"
			lRet := lRetTst
		EndIf
	Else
		If Empty(aCols[nLinha,nPosCod]) .Or. aCols[nLinha,nPosQuant] == 0  
			Help("",1,"GCP02NOLIN") //"Preenchimento de todos os campos do produto obrigat๓rio"
			lRet := .F.
		Endif
	EndIf
Else
	If Empty(aCols[nLinha,nPosCod]) .Or. aCols[nLinha,nPosQuant] == 0 .Or. (aCols[nLinha,nPosPreco]==0 .And.;
			 (Empty(aACols) .Or. (aCols[nLinha,9] == 0 .And. aACols[1,3] == 0) )) //aCols[nLinha,9] == 0)) //aCols[nLinha,nPosPreco] == 0 //(aCols[nLinha,nPosPreco]==0 .Or. (Empty(aACols) .Or. aACols[nLinha,3] == 0)) //aACols[nLinha,3] == 0) //aCols[nLinha,nPosPreco] == 0 
		Help("",1,"GCP02NOLIN") //"Preenchimento de todos os campos do produto obrigat๓rio"
		lRet := .F.
	Endif
	If	M->CO1_AVAL=="2" .And. !aCols[nLinha,Len(aHeader)+1]
		If	Empty(aCols[nLinha,nPosLote])
			Help(" ",1,"OBRIGAT2",,RetTitle("CO2_LOTE"),4,1)
			lRet := .F.
		EndIf
	EndIf

	If	lRet
		If	M->CO1_AVAL$"23"
			If	aCols[nLinha,nPosRevo]=="S"
				If	M->CO1_AVAL=="2"
					GCP02Rpl(nLinha,aCols[nLinha,nPosLote],aCols[nLinha,nPosObs],nPosLote,nPosObs)
				EndIf
				lRet := .F.
				//-- esse for tem que passar por todas as linhas do acols, para obter a quantidade de linhas revogadas
				For n1Cnt := 1 To Len(aCols)
					//-- Verifica se todos os itens foram revogados
					If	aCols[n1Cnt,nPosRevo]=="S" .Or. aCols[n1Cnt,Len(aHeader)+1]
						n2Cnt++
					EndIf
					If	aCols[n1Cnt,nPosLote]==aCols[nLinha,nPosLote] .And. !Empty(aCols[n1Cnt,nPosObs])
						lRet := .T.
					EndIf
				Next
				If	!lRet
					Help(" ",1,"OBRIGAT2",,RetTitle("CO2_OBS"),4,1)
				EndIf
			EndIf
		Else
			If	aCols[nLinha,nPosRevo]=="S" .And. Empty(aCols[nLinha,nPosObs]) 
				Help(" ",1,"OBRIGAT2",,RetTitle("CO2_OBS"),4,1)
				lRet := .F.
			EndIf
			If	lRet .And. aCols[nLinha,nPosRevo]=="S"
				//-- esse for tem que passar por todas as linhas do acols, para obter a quantidade de linhas revogadas
				For n1Cnt := 1 To Len(aCols)
					//-- Verifica se todos os itens foram revogados
					If	aCols[n1Cnt,nPosRevo]=="S" .Or. aCols[n1Cnt,Len(aHeader)+1]
						n2Cnt++
					EndIf
				Next
			EndIf
		EndIf
		If	lRet .And. n2Cnt==Len(aCols)
			Help("",1,"GCP02NOITEM") //"ษ necessแrio pelo menos um produto no edital"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02Part    บAutor  ณ Totvs          บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tela de manuten็ใo de dados do participante relacionado comบฑฑ
ฑฑบ          ณ o item do produto                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GCP02Part(aPartic,nLinha,nOpc)
Local nOpcao 	:= 0  
Local lRetPE, lRetOff  
Local cProd := ""
Local i 	:= 0
Local nP_Item := 0
Local nP_Prod := 0
Local nX := 0
Local nP_ForCli := 0
Local nP_Loj 	:= 0
Local nP_Nom	:= 0
Local nP_Lote	:= 0
Local nP_VlUn	:= 0
Local nPosTipo 	:= 0
Local nOpcX		:= 0
Local nCOLS		:= 0
Local nPos 		:= 1
Local cTitulo := STR0009 // "Consultar Participante"
Local nPosProd := aScan(oGetEdt:aHeader,{|x| ALLTrim(x[2])=="CO2_CODPRO"})
Local nPosLote := aScan(oGetEdt:aHeader,{|x| AllTrim(x[2])=="CO2_LOTE"})
Local aArea := GetArea()
Local aCols	:= {}   
Local aButAux := {}
Local aButtons:= {}
Local oDlg2
Local lGCP02Par	:= Existblock("GCP02PAR")
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local lLtNew:= .F.
Local n1Cnt := 0
Local n2Cnt := 0
Local nPosQuant	:= GDFieldPos("CO2_QUANT",oGetEdt:aHeader)
Local nPosPreco	:= GDFieldPos("CO2_VLESTI",oGetEdt:aHeader)
Local nPosFrac	:= GDFieldPos("CO2_FRACAS",oGetEdt:aHeader)
Local cChkCpo	:= ""
Local aAlter    := {}

Default aPartic := {}
Default nLinha := oGetEdt:nAt
Default nOpc := INCLUIR
             
if lPrjCni             
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤF
	//ณCriado por Eric do Nascimentoณ
	//ณTeste de PE                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤF
	If ExistBlock("GCPA02PBut")
		aButAux := Execblock( "GCPA02PBut", .F., .F. )
		If ValType( aButAux ) == "A"
			aEval( aButAux, {|x| aAdd( aButtons, x ) } )
		EndIf
	EndIf
EndIf

cProd := oGetEdt:acols[nLinha,nPosProd]
If !lPrjCni
	cLote := oGetEdt:aCols[nLinha,nPosLote]
Else
	cLote := Space(TamSx3("CO2_LOTE")[1])
EndIf

If Empty(cProd)
	Help("",1,"GCP02PRODIN") //"Produto Invแlido"
	Return
Endif
   
If oGetEdt:aCols[nLinha][Len(oGetEdt:aHeader)+1] // Se o item estiver deletado
	Aviso(STR0037,STR0047,{"Ok"}) 
	Return
EndIf

If	nOpc == ALTERAR
	//-- Verifica se houve alteracoes na tabela CO2
	CO2->(DbSetOrder(1))
	For n1Cnt := 1 To Len(oGetEdt:aCols)
		If	!GdDeleted(n1Cnt,oGetEdt:aHeader,oGetEdt:aCols) .And. CO2->(DbSeek(xFilial("CO2")+M->CO1_CODEDT+M->CO1_NUMPRO+oGetEdt:aCols[n1Cnt,nPosProd]))
		
			For n2Cnt := 1 To Len(oGetEdt:aHeader)
				If	oGetEdt:aHeader[n2Cnt,10]!="V" .And. oGetEdt:aCols[n1Cnt,n2Cnt] != CO2->(FieldGet(FieldPos(AllTrim(oGetEdt:aHeader[n2Cnt,2]))))
					cChkCpo:=RetTitle(oGetEdt:aHeader[n2Cnt,2])
					Exit
				EndIf
			Next
			If	!Empty(cChkCpo)
				Exit
			EndIf
					
		Else
			//-- Inclusao ou delecao de linhas no Grid
			cChkCpo:=STR0094		//"Inclusใo ou estorno do Produto"
			Exit
		EndIf
	Next		

	If	!Empty(cChkCpo)
		If	!MsgYesNo(STR0095+cChkCpo+STR0096,STR0057)		//"Houve Altera็๕es no Edital ("###") que podem influenciar no calculo do lance dos licitantes, Continua?"###"Aten็ใo"
			Return
		EndIf
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ P.E. Utilizado ao clicar no botao "Participantes"            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGCP02Par
	Execblock("GCP02PAR",.F.,.F.,{nOpc})
EndIf

cTitulo := cTitulo + STR0010+cProd+Iif(!Empty(cLote),STR0090+cLote,"")			//" para o produto: "###"Lote "
aHeader	:= CriaHeader(nil,"CO3_FILIAL/CO3_CODEDT/CO3_NUMPRO/CO3_CODPRO",Nil,"CO3")
nPosTipo 	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_TIPO"})
nP_ForCli	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_CODIGO"})
nP_Loj  	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_LOJA"})
nP_Nom 		:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_NOME"})
nP_Lot		:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_LOTE"})


If M->CO1_MODALI == "LL"
	aHeader[nPosTipo,11] := STR0011 //"1=Pre-Cliente;2=Cliente"
Endif

If	!Empty(cLote)
	For n1Cnt := 1 To Len(aPartic)
	
		nPosPart := aScan(aPartic[n1Cnt,2],{|x| Alltrim(x[nP_Lot]) == Alltrim(cLote) })
	
		If nPosPart > 0
			aCols := aPartic[n1Cnt][2]
			Exit
		EndIf
	
	Next
Else
	nPosPart := aScan(aPartic,{|x| Alltrim(x[1]) == Alltrim(cProd) })
	If nPosPart > 0
		aCols := aPartic[nPosPart][2]
	EndIf
EndIf

If Len(aCols) == 0
	If nOpc == INCLUIR .Or. nOpc == GERAR
		aCols := CriaAcols(aHeader,"CO3",1,xFilial("CO3")+M->(CO1_CODEDT+CO1_NUMPRO)+cProd,nOpc,nil,"CO3_ITEM","CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO")
	Else 
		GCPViewCO3("1",M->CO1_AVAL,M->CO1_CODEDT,M->CO1_NUMPRO,cProd,cLote,aHeader,aCols)
	EndIf
EndIf

// Salva aCols antes da alteracao
aColsSav := aClone(aCols)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณpor Icaro Queiroz em 10 de Agosto de 2010                                             ณ
//ณDefinicao do objeto                                                                   ณ
//ณ - A MSNewGetDados nao podera ter suas linhas habilitadas para delecao (tecla <<DEL>>)ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nOpc == INCLUIR .Or. nOpc == ALTERAR .Or. nOpc == GERAR
	
	if lPrjCni
		nOpcX	:= GD_INSERT+GD_UPDATE
	
		If ExistBlock("GCP2PART")
			lRetPE := Execblock( "GCP2PART", .F., .F.,{M->CO1_CODEDT, M->CO1_NUMPRO,oGetEdt:aCols[oGetEdt:nAt, 1 ]} )
		
			if ValType(lRetPE) == "L" .And. lRetPE
				nOpcX	:= 0			
			EndIf
		EndIf
	Else
		//-- Se o item do Edital estiver revogado, abre o grid de participantes apenas como visualizacao
		If	oGetEdt:aCols[oGetEdt:nAt,nPosFrac]=="S"
			cTitulo += " - "+STR0097		//"Revogado"
			nOpcX := 0
		Else
			nOpcX := GD_INSERT+GD_UPDATE+GD_DELETE // So sera permitido exclusao, caso nao tenha iniciado o andamento
		EndIf
	EndIf		
	aAlter := {"CO3_TIPO","CO3_CODIGO","CO3_LOJA","CO3_VLUNIT","CO3_PRZENT","CO3_REVOGA","CO3_OBS"}
Else
	nOpcX	:= 0
EndIf            

If nOpc == ALTERAR .And. CO1->CO1_REMAN 
	nOpcX := 0
Endif  
         
if lPrjCni
	DEFINE MSDIALOG oDlg2 TITLE cTitulo From 100,10 TO 400,700 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oGetPart := MsNewGetDados():New(13,1,150,345,nOpcX,"GCP02LPart","","+CO3_ITEM/CO3_CODEDT/CO3_NUMPRO/CO3_CODPRO",,,999,,,,oDlg2,aHeader,aCols)  
	oGetPart:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT    
	ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{|| nOpcao:=IIF(GCP02TPart(),1,2),IIF(nOpcao==1,oDlg2:End(),NIL) },{|| oDlg2:End() },,aButtons)
Else
	DEFINE MSDIALOG oDlg2 TITLE cTitulo From 100,10 TO 400,700 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oGetPart := MsNewGetDados():New(13,1,150,345,nOpcX,"GCP02LPart","","+CO3_ITEM/CO3_CODEDT/CO3_NUMPRO/CO3_CODPRO",aAlter,,999,,,,oDlg2,aHeader,aCols)  
	oGetPart:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,{|| nOpcao:=IIF(GCP02TPart(),1,2),IIF(nOpcao==1,oDlg2:End(),NIL) },{|| oDlg2:End() })
EndIf

If nOpc != VISUALIZAR .And. nOpcao == 1
	If	!Empty(cLote)
		If	Len(aPartic) > 0

			lLtNew := .T.
			For n1Cnt := 1 To Len(aPartic)
			
				nPosPart := aScan(aPartic[n1Cnt,2],{|x| Alltrim(x[nP_Lot]) == Alltrim(cLote) })
			
				If	nPosPart > 0
					lLtNew := .F.
					//-- Alteracao de participantes de um lote ja existente no apartic
					aPartic[n1Cnt][2] := aClone(oGetPart:aCols)

				EndIf

			Next

			If	lLtNew
				//-- Inclusao de participantes quando o apartic estiver vazio
				AAdd(aPartic,{ cProd, aClone(oGetPart:aCols) })
			EndIf

		Else
			//-- Inclusao de participantes quando o apartic estiver vazio
			AAdd(aPartic,{ cProd, aClone(oGetPart:aCols) })
			
			//-- Distribui digitacao do participante para todos os produtos com mesmo lote
			For n1Cnt := 1 To Len(oGetEdt:aCols)
				If	! ( oGetEdt:aCols[n1Cnt,nPosProd]==cProd ) .And. oGetEdt:aCols[n1Cnt,nPosLote]==cLote 
					AAdd(aPartic,{ oGetEdt:aCols[n1Cnt,nPosProd], aClone(oGetPart:aCols) })
				EndIf
			Next

		EndIf
	Else

		If	M->CO1_AVAL=="1"

			nPosPart := aScan(aPartic,{|x| Alltrim(x[1])  == Alltrim(cProd) })
			If nPosPart > 0
				aPartic[nPosPart][2] := aClone(oGetPart:aCols)
			Else
				AAdd(aPartic,{ cProd, aClone(oGetPart:aCols) })
			EndIf
			
		ElseIf M->CO1_AVAL=="3"

			//-- Distribui digitacao do participante para todos os produtos do Edital
			aPartic := {}
			For n1Cnt := 1 To Len(oGetEdt:aCols)
				AAdd(aPartic,{ oGetEdt:aCols[n1Cnt,nPosProd], aClone(oGetPart:aCols) })
			Next

		EndIf
	
	EndIf
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada executado apos a confirmacao da manipulacao do participante  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู      
If ExistBlock("GCPA02ALT") .And. nOpcao == 1
	ExecBlock("GCPA02ALT",.F.,.F.,{M->CO1_NUMPRO})   
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02TPartบAutor  ณMicrosiga           บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTudoOK da tela de participantes                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02TPart()
Local lRet := .T.
Local nX := 0
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local lRetAux := .F.
Local lGCP02TOK := iif ( lPrjCni, Existblock( 'GCP02TOK' ), .F.)

For nX :=  1 to Len(oGetPart:aCols)
	If !GCP02LPart(nX)
		lRet := .F.
		Exit
	EndIf
Next nX
          
if lPrjCni
	/////
	// Criado no projeto CNI para poder validar o participante selecionado.
	// Wanderley Monteiro 13/01/2012 - 09:36:08
	// GCP02TOK
	If lRet .and. lGCP02TOK
		lRetAux := Execblock( "GCP02TOK", .F.,.F., oGetPart:aCols )
		If ValType( lRetAux ) == "L"
	      lRet:= lRetAux
		EndIf
	EndIf
EndIf

Return lRet
                                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02LPart   บAutor  ณMicrosiga        บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da linha da grid de participante                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GCP02LPart(nLinha)
Local lRet := .T.
Local aCols:= oGetPart:aCols
Local aHeader:= oGetPart:aHeader          

Local nPosLote	:= aScan(oGetEdt:aHeader,{|x| AllTrim(x[2])=="CO2_LOTE"})
Local nPosPreco	:= aScan(oGetEdt:aHeader,{|x| AllTrim(x[2])=="CO2_VLESTI"})
Local nPosQuant := aScan(oGetEdt:aHeader,{|x| AllTrim(x[2])=="CO2_QUANT"})

Local nPosTip:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_TIPO"})
Local nPosVlU:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_VLUNIT"})
Local nPosCod:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_CODIGO"}) 
Local nPosLoj:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_LOJA"})
Local nP_Lote:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_LOTE"})
Local nP_Revo:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_REVOGA"})
Local nP_Obs := aScan(aHeader,{|x| AllTrim(x[2])=="CO3_OBS"})
Local lPrjCni:= FindFunction("ValidaCNI") .And. ValidaCNI()
Local n1Cnt  := 0
Local nVlEsti:= 0
Default nLinha := oGetPart:nAt

If Valtype(nLinha) != "N"
	nLinha := oGetPart:nAt
EndIf

If aCols[nLinha,len(aCols[nLinha])] <> .T. 					
	If lRet .And. aCols[nLinha,nPosVlU] == 0 .Or. Empty(aCols[nLinha,nPosCod]) .Or. Iif( aCols[nLinha,nPosTip] == "2" .And. Empty(aCols[nLinha,nPosLoj]) ,.T. ,.F.)
		Help("",1,"GCP02NOVL") //"Pre็o unitแrio licitado e dados do participante sใo de preenchimento obrigat๓rio" 
		lRet := .F. 
	Endif

	If	lRet .And. aCols[nLinha,nP_Revo]=="1" .And. Empty(aCols[nLinha,nP_Obs])
		Help(" ",1,"OBRIGAT2",,RetTitle("CO3_OBS"),4,1)
		lRet := .F.
	EndIf

	If	lRet .And. !lPrjCni
		If	(M->CO1_AVAL=="2" .Or. M->CO1_AVAL=="3") 
			If	M->CO1_AVAL=="2" .And. !Empty(cLote)
				For n1Cnt := 1 To Len(oGetEdt:aCols)
					If	oGetEdt:aCols[n1Cnt,nPosLote]==cLote
						nVlEsti += ( oGetEdt:aCols[n1Cnt,nPosPreco]*oGetEdt:aCols[n1Cnt,nPosQuant] )
					EndIf
				Next
			ElseIf	M->CO1_AVAL=="3"
				For n1Cnt := 1 To Len(oGetEdt:aCols)
					nVlEsti += ( oGetEdt:aCols[n1Cnt,nPosPreco]*oGetEdt:aCols[n1Cnt,nPosQuant] )
				Next
			EndIf
	
			If	M->CO1_MODALI=="LL"
				If	aCols[nLinha,nPosVlU] < nVlEsti
					Help("",1,"GCP02ESTI",,STR0102+Transform(nVlEsti,PesqPict("CO3","CO3_VLUNIT")),4,1)		//"Valor do Lance menor que o valor estimado "
					lRet := .F.
				EndIf
			Else		
				If	aCols[nLinha,nPosVlU] > nVlEsti
					Help("",1,"GCP02ESTI",,STR0103+Transform(nVlEsti,PesqPict("CO3","CO3_VLUNIT")),4,1)		//"Valor do Lance maior que o valor estimado "
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

If	lRet .And. !lPrjCni
	oGetPart:aCols[nLinha,nP_Lote]:=cLote
EndIf           

Return lRet                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02Com  บAutor  ณTOTVS SA            บ Data ณ  07/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณComissa do edital                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function  GCP02Com(aComiss,nOpc)
Local oDlg3
Local nOpcao := 0
Local i := 0
Local nX := 0
Local cTitulo := STR0012 //"Adicionar Membro da Comissao"
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local aArea := GetArea()
Local aCols	:= {}
Local nOpcX	:= 0
Local lRetOff, lRetPE
Private oGetComiss

Default aComiss := {}
Default nOpc 	:= INCLUIR

If nOpc == INCLUIR .Or. nOpc == GERAR .Or. nOpc == ALTERAR  
	nOpcX := GD_INSERT+GD_DELETE+GD_UPDATE
EndIf

if lPrjCni            
	if ExistBlock("GCP2COMI")
		lRetPE := Execblock( "GCP2COMI", .F., .F.,{M->CO1_CODEDT, M->CO1_NUMPRO,oGetEdt:aCols[oGetEdt:nAt, 1 ]} )
	
		if ValType(lRetPE) == "L" .And. lRetPE
			nOpcX	:= 0			
		EndIf
	
	EndIf
EndIf

aHeadCom	:= CriaHeader(nil,"CO9_NUMPRO/CO9_CODEDT",Nil,"CO9")
If Len(aComiss) == 0
	aCOLSCom	:= CriaAcols(aHeadCom,"CO9",1,xFilial("CO9")+M->(CO1_CODEDT+CO1_NUMPRO),nOpc,nil,"CO9_ITEM","CO9_FILIAL+CO9_CODEDT+CO9_NUMPRO")
Else
	aCOLSCom := aClone(aComiss)
EndIf

DEFINE MSDIALOG oDlg3 TITLE cTitulo From 100,10 TO 400,700 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

oGetComiss := MsNewGetDados():New(13,1,150,345,nOpcX,"GCP02LCom()","","+CO9_ITEM",,,999,,,,oDlg3,aHeadCom,aCOLSCom)
oGetComiss:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3,{|| nOpcao:=IIF(GCP02TCom(),1,2),IIF(nOpcao==1,oDlg3:End(),NIL) },{|| oDlg3:End() })

If nOpcao==1
	aComiss:= {}
	aComiss:= aClone(oGetComiss:aCOLS)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02TCom   บAutor  ณMicrosiga           บ Data ณ  04/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTudoOK da tela de comissao                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02TCom()
Local lRet := .T.
Local nX := 0

For nX :=  1 to Len(oGetComiss:aCols)
	If !GCP02LCom(nX)
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GCP02OKGe บAutor  ณEduardo Dias        บ Data ณ  21/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTudoOK da tela de Geracao de Edital                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02OKGe()
Local lRet := .T.
Local nX := 0

For nX :=  1 to Len(oGetComiss:aCols)
	If !GCP02LCom(nX)
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02LCom บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a linha esta OK para a tela de cadastro dos       บฑฑ
ฑฑบ          ณ membros da comissao.                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02LCom(nLinha)
Local lRet := .T.
Local aCols := oGetComiss:aCols
Local aHeader := oGetComiss:aHeader
Local nPosNome := aScan(aHeader,{|x| AllTrim(x[2])=="CO9_NOME"})
Local nPosEmail := aScan(aHeader,{|x| AllTrim(x[2])=="CO9_EMAIL"})
Default nLinha   := oGetComiss:nAt

If Valtype(nLinha) != "N"
	nLinha := oGetComiss:nAt
EndIf

// Se a linha nao estiver deletada.
If !aCols[nLinha][Len(aHeader)+1]
	If Empty(aCols[nLinha,nPosNome])
		Help("",1,"GCP02NONOME") //"Nao sera permitido linha sem nome."
		lRet := .F.
	Endif
	
	If Empty(aCols[nLinha,nPosEmail])
		Help("",1,"GCP02NOMAIL") //"Nao sera permitido linha sem email."
		lRet := .F.
	ElseIf At("@",TRIM(aCols[nLinha,nPosEmail])) == 0
		Help("",1,"GCP02MAIL") //"O Email do designado nใo parece ter um formato vแlido"
		lRet := .F.
	Endif
Endif

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCPA02Can บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cancela processo do edital a qualquer momento              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GCPA02Can()
Local lRetPE     
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local aGrvCO1  := {}
Local aGrvCO7  := {}
Local cCO7Acao := ""
Local cMotivo  := Space(200)
Local aRet     := {}
Local aParam   := {}
Local lOk      := .T.
LOCAL aArea	   := GetArea()
//-- nao permite cancelamento de edital ja encerrado ou pedido de compras gerado
//SC7->(dbOrderNickName("GCP01")) //C7_FILIAL+C7_CODED+C7_NUMPR 
If SC7->(IndexKey(20)) == "C7_FILIAL+C7_CODED+C7_NUMPR"
	SC7->(dbSetOrder(20))  
ElseIf SC7->(IndexKey(21)) == "C7_FILIAL+C7_CODED+C7_NUMPR"
	SC7->(dbSetOrder(21))  
EndIf

If CO1->CO1_ETAPA $ "PE,PC,FV,CO,PM,PR,CE" .Or. SC7->(dbSeek(xFilial("SC7")+CO1->(CO1_CODEDT+CO1_NUMPRO)))
	Help("",1,"GCP02NOCAN") //"Somente edital em aberto poderแ ser cancelado"
	lOk  := .F.
Endif

if lOk .And. lPrjCni            
	If	ExistBlock("GCP2CANC")
		lRetPE := Execblock( "GCP2CANC", .F., .F.,{CO1->CO1_CODEDT, CO1->CO1_NUMPRO} )
		
		if ValType(lRetPE) == "L" .And. lRetPE
			lOk := !lRetPE
		EndIf
	EndIf
EndIf

If lOk .And. (lOk := MsgYesNo(STR0013,cCadastro))
		
	//-- array com o retorno do parambox
	AAdd(aRet,cMotivo)   // qual e' o motivo do cancelamento
	
	//-- array com a configuracao do parambox
	AAdd(aParam,{1,STR0015,aRet[1],"@!","","","",125,.T.})//"Motivo do Cancelamento"
		
		//-- chamada da funcao parambox()
	lOk := ParamBox(aParam,STR0014,@aRet,,,.T.,80,3)//"Motivo"
		
	If lOk .And. !Empty(aRet[1])
			
		Begin Transaction
			
		cMotivo := aRet[1]
			
		cCO7Acao := STR0016 + CO1->CO1_PASSO + chr(13)+chr(10)//"Passo: "
		cCO7Acao += STR0017 + chr(13)+chr(10)//"Cancelamento do Edital"
		cCO7Acao += STR0018 + chr(13)+chr(10) + cMotivo + chr(13)+chr(10)//"Motivo: "
			
		aGrvCO1 := {	{"CO1_ETAPA" , "PE"      }}  // processo encerrado
			
		aGrvCO7 := {	{"CO7_CODEDT", CO1->CO1_CODEDT},;
		{"CO7_NUMPRO", CO1->CO1_NUMPRO},;
		{"CO7_DTMOV" , dDataBase},;
		{"CO7_HRMOV" , Time()},;
		{"CO7_CODUSU", Upper(Alltrim(Substr(cUsuario,7,15)))},;
		{"CO7_MOVATU", CO1->CO1_ETAPA},;
		{"CO7_DESATU", Posicione("SX5",1,xFilial("SX5")+'LE'+CO1->CO1_ETAPA,"X5_DESCRI")},;
		{"CO7_ACAO"  , cCO7Acao },;
		{"CO7_PASATU", CO1->CO1_PASSO}}
		GCPA006(aGrvCO7, aGrvCO1)
		
		//-- Retira o relacionamento com as solicitacoes de compra     
//		SC1->(dbOrderNickName("GCP01")) //C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO+C1_NUM+C1_ITEM    
		If SC1->(IndexKey(7)) == "C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO+C1_NUM+C1_ITEM"
			SC1->(dbSetOrder(7))  
		ElseIf SC1->(IndexKey(8)) == "C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO+C1_NUM+C1_ITEM"
			SC1->(dbSetOrder(8))  
		EndIf              
		While SC1->(dbSeek(xFilial("SC1")+CO1->(CO1_CODEDT+CO1_NUMPRO)))
			RecLock("SC1",.F.)
			SC1->C1_CODED:= ''
			SC1->C1_NUMPR:= ''
			SC1->C1_MODAL:= ''
			SC1->C1_TPMOD:= ''
			SC1->C1_COTACAO	:= ''
			SC1->(MsUnLock())      
				
			If lPrjCni
				//Caio.Santos - 11/01/13 - Req.72
				RSTSCLOG("EDT",2,/*cUser*/)
			EndIf 
		EndDo
		
		//-- Retira o relacionamento com a cotacao
//		SC8->(dbOrderNickName("GCP01")) //C8_FILIAL+C8_CODED+C8_NUMPR	
		If SC8->(IndexKey(6)) == "C8_FILIAL+C8_CODED+C8_NUMPR"
			SC8->(dbSetOrder(6))  
		ElseIf SC8->(IndexKey(7)) == "C8_FILIAL+C8_CODED+C8_NUMPR"
			SC8->(dbSetOrder(7))  
		EndIf
		While SC8->(DbSeek(xFilial("SC8")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO))
			RecLock("SC8",.F.) 
			SC8->C8_CODED := ''
			SC8->C8_NUMPR := ''
			SC8->(MsUnLock())
		EndDo
		End Transaction
		
	Else
		Help("",1,"GCP02CAN") //"Edital nao cancelado"
	Endif	
Else
	Help("",1,"GCP02CAN") //"Edital nao cancelado"
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCPA02Scm    บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao de montagem da tela de selecao das solicitacoes de       บฑฑ
ฑฑบ          ณ compra para geracao do edital                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function GCPA02Scm(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
Local lPrjCni		:= FindFunction("ValidaCNI") .And. ValidaCNI()
Local aDados		:= {}
Local cPerg		:= "GCPA02"
Local cCodEdt		:= ""
Local cNumPro		:= ""
Local cModali		:= ""
Local cTipo		:= ""
Local cRegra		:= ""
Local cModalAtu 	:= Upper(CO1->CO1_MODALI)
Local lRet		:= .T.

lRemanescente := (nOpc == REMANESCENTE)

If lPrjCni
	If ExistBlock("GCP2SOLI")
		Execblock( "GCP2SOLI", .F., .F.)
	EndIf
EndIf

AjustaSX1(.T.,cPerg)

If Pergunte(cPerg,.T.)
	cCodEdt:= CriaVar("CO1_CODEDT",.T.)
	cNumPro:= CriaVar("CO1_NUMPRO",.T.)
	cModali:= Iif(Empty(mv_par01) .And. mv_par01 == "LL" ,CriaVar("CO1_MODALI",.T.),mv_par01)
	cTipo	:= Iif(Empty(mv_par02),CriaVar("CO1_TIPO",.T.)  ,mv_par02)
  	cRegra	:= Iif(Empty(mv_par03),CriaVar("CO1_REGRA",.T.) ,mv_par03)
	
	If	lRemanescente	
		// Efetua a validacao do participante se o mesmo utilizar cliente ou fornecedor
		// Verificar se a mudanca da modalidade anterior ou atual eh igual a LL ( Leilao )
		// rotina de exclusao dos participantes do edital
		If	!(cModali == cModalAtu)
			If	(cModali == "LL" .Or. cModalAtu == "LL")
				Help("",1,"GCP02MODAL")	//"Nใo ้ possํvel alterar para essa modalidade"
				lRet := .F.
			EndIf
		EndIf
		If	lRet
			GCPA02Edital(cAlias,nReg,nOpc,aDados,cCodEdt,cNumPro,cModali,cTipo,cRegra)
		EndIf
	Else
		If  cModali == "LL"
			Help("",1,"GCPA02MDLL") //Para a Modalidade 'Leilใo' nใo ้ possํvel carregar solicita็ใo de compra
			lRet := .F.
		Else
			If ExistChav("CO1",cCodEdt+cNumPro)
				aDados := GCP02SelSC(nOpc)
				If Len(aDados) > 0
					GCPA02Edital(cAlias,nReg,nOpc,aDados,cCodEdt,cNumPro,cModali,cTipo,cRegra)
				EndIf
			EndIf
		EndIf
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)
Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02Solic  บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao de montagem da tela de selecao das solicitacao de        บฑฑ
ฑฑบ          ณ compra 					                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function GCP02Solic(aSolic,nOpc,lConsSolic)
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local nPosProd  := aScan(oGetEdt:aHeader,{|x| Trim(x[2])=="CO2_CODPRO"})
Local nPosQEdt  := aScan(oGetEdt:aHeader,{|x| Trim(x[2])=="CO2_QUANT"} )   
Local nPosOrig  := iif (lPrjCni,  aScan(oGetEdt:aHeader,{|x| Trim(x[2])=="CO2_ORIG"}  ), 0)

Local nPosSolic := 0
Local nLinha	:= oGetEdt:nAT
Local cProduto  := oGetEDt:aCols[nLinha,nPosProd]
Local cEdital	:= M->CO1_CODEDT
Local cProcesso	:= M->CO1_NUMPRO
Local nX		:= 0
Local aDados    := {}
Local aHeadC1 	:= CriaHeader(Nil,Nil,Nil,"SC1")
Local nPosQSc 	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_QUANT"})
Local aSolAux 	:= {}
Local nQtde		:= 0, nQtTst, nQtPE
Local lClick	:= nOpc == GERAR
Local lGCP2QTSC := iif (lPrjCni, Existblock( 'GCP2QTSC'), .F.)

nPosSolic := aScan(aSolic ,{|x| Alltrim(x[1]) == Alltrim(cProduto) })

If nPosSolic > 0
	aSolAux := aSolic[nPosSolic][2]
EndIf

if lPrjCni
	aDados := GCP02SelSC(nOpc,cProduto,cEdital,cProcesso,aSolAux,lClick,!lConsSolic)
	
	If Existblock( 'GCP2GRDS')
		Execblock( "GCP2GRDS", .F., .F. , {aDados})
	EndIf
Else	
	aDados := GCP02SelSC(nOpc,cProduto,cEdital,cProcesso,aSolAux,lClick)
EndIf

If !Empty(aDados)
	For nX:= 1 To Len(aDados)
		If nOpc == GERAR
			If aDados[nX,1]
				nQtde += aDados[nX,nPosQSc + 1]
			Endif
		Else
			If !aDados[nX,1]
				nQtde += aDados[nX,nPosQSc + 1]
			Endif
		EndIf
	Next nX
	
	if lPrjCni             
		if lGCP2QTSC                                       
	
			aRetPE := Execblock( "GCP2QTSC", .F., .F. , {  lConsSolic, nQtde, M->CO1_CODEDT,	M->CO1_NUMPRO, M->CO1_MODALI, M->CO1_TIPO,  ;
			oGetEdt:aCols[nLinha, 1 ], oGetEDt:aCols[nLinha,nPosProd],   oGetEdt:aCols[nLinha, nPosQEdt ]}) //,  ;
    
    		If ValType(aRetPE) == "A" .And. ValType(aRetPE[1]) == "N" .and. ValType(aRetPE[2]) == "N"
	    		oGetEdt:aCols[nLinha, nPosQEdt ] := aRetPE[1]
	    		oGetEdt:aCols[nLinha, nPosOrig ] := aRetPE[2]
		    EndIf
	
		EndIf     
	Else
		oGetEdt:aCols[nLinha, nPosQEdt ]:= nQtde
	EndIf
	
	If oGetEdt:aCols[nLinha, nPosQEdt ] > 0
		oGetEdt:aCols[nLinha, Len(oGetEdt:aHeader)+1 ] := .F.
	Else
		oGetEdt:aCols[nLinha, Len(oGetEdt:aHeader)+1 ] := .T.
	EndIf
	
	oGetEdt:ForceRefresh()
	
	If nPosSolic > 0
		aSolic[nPosSolic][2] := aClone(aDados)
	Else
		AAdd(aSolic,{ cProduto, aClone(aDados) })
	EndIf
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02SelSCบAutor  ณTOTVS SA            บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de sele็ใo de solicita็ใo de titulos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤมฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบ PROGRAMADOR ณ DATA   ณ FNC  ณ  MOTIVO DA ALTERACAO                    บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบIcaro Queirozณ13/08/10ณD.Prevณ-Incluido o ponto de entrada GCP02Fil queบฑฑ
ฑฑบ             ณ        ณ      ณ permite add filtro na selecao do SC1;   บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบIcaro Queirozณ28/09/10ณD.Prevณ-Inversao da marcacao pelo clique no     บฑฑ
ฑฑบ             ณ        ณ      ณ canto superior do cabecalho;            บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบIcaro Queirozณ29/09/10ณD.Prevณ-Add opcao de filtro recursivo via botao บฑฑ
ฑฑบ             ณ        ณ      ณ na janela de selecao do SC1 - de|ate;   บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GCP02SelSC(nOpc,cProduto,cEdital,cProcesso,aSolC,lClick, lWndManutEdit)
Local oDlg         
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local cTitulo  := STR0019 //"Solicita็๕es de compra"
Local aHeadC1 	:= CriaHeader(Nil,Nil,Nil,"SC1")
Local nX
Local aVetor		:= {}
Local aTam			:= {}
Local aCmbItens		:= {}
Local aCmbOrdem		:= {}
Local nOpcX			:= 0
Local nCmbOp		:= 1
Local cPesq			:= Space(100)
Local cCombo		:= ""
Local aDados		:= {}
Local nNumSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_NUM"})
Local nItemSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_ITEM"})
Local nProdSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_PRODUTO"})
Local nDescrSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_DESCRI"})
Local aRet 		:= {}
Local cQuery 	:= ""
Local cAliasTmp := GetNextAlias()
Local nY		:= 0
Local lRet		:= .T.
Local aArea		:= GetArea()   
Local cQrTst, cQrOk
Local lGCP02Fil		:=  Existblock( 'GCP02Fil' ) // por Icaro Queiroz em 13 de Agosto de 2010. Disponibiliza Filtro na Query
Local aFilter		:= {}
Local aRetFil		:= {} 
Local cTpCto        := IIf (lPrjCni, GETMV("MV_TPSCCT"), .F.)  // FSW - TIPO DE SC ADITIVO CONTRATO
Local aVetTst       := {}
Local aButtons		:= {}

Private oOk      	:= LoadBitmap( GetResources(), "LBOK" )
Private oNo      	:= LoadBitmap( GetResources(), "LBNO" )
Private oLbx
Private aTitulo := {}
Default lWndManutEdit := .F.
Default nOpc := GERAR
Default cProduto := ""
Default cEdital := ""
Default cProcesso := ""
Default aSolC := {}
Default lClick := .T.
   
if lPrjCni            
	if lWndManutEdit
		aSolC := {} //Houve problema ao usar vแrias vezes em seguida a SOlicita็ใo e a Edi็ใo para uma linha de registro
	EndIf
EndIf    

If nOpc == GERAR      

	if lPrjCni 
		cQuery := " SELECT SC1.* "
		cQuery += " FROM " + RetSqlTab("SC1")           
		cQuery += " WHERE SC1.C1_CODED = '' "
		cQuery += " AND SC1.C1_NUMPR = '' "
		cQuery += " AND SC1.C1_QUJE = 0 "
		cQuery += " AND SC1.C1_TPSC = '2'"
		cQuery += " AND SC1.C1_QUANT > 0"
		cQuery += " AND SC1.C1_RESIDUO <> 'S'"
		cQuery += " AND SC1.C1_APROV NOT IN ('R','B')"   
		cQuery += " AND SC1.C1_XTIPOSC <> '"+cTpCto+"' "  // FSW - TIPO DE SC ADITIVO CONTRATO

		If lWndManutEdit .And. ExistBlock("GCP2SQLS")
			cQrTst := Execblock( "GCP2SQLS", .F., .F.,{cEdital, cProcesso, cProduto, cTpCto, cQuery} )

			if ValType(cQrTst) == "C"
       	    	cQuery := cQrTst
			EndIf
		EndIf
		
    	Else
		cQuery := " SELECT * "
		cQuery += " FROM " + RetSqlTab("SC1")
		cQuery += " WHERE C1_CODED = '' "
		cQuery += " AND C1_NUMPR = '' "
		cQuery += " AND C1_QUJE = 0 "
		cQuery += " AND C1_TPSC = '2'"
		cQuery += " AND C1_QUANT > 0"
		cQuery += " AND C1_RESIDUO <> 'S'"
		cQuery += " AND C1_APROV NOT IN ('R','B')"
    	EndIf
    	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPE que permite o usuario incrementar o filtro na query;ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lGCP02Fil
		cQuery += Execblock( "GCP02Fil", .F., .F. )
	EndIf

	cQuery += " AND " + RetSQLCond("SC1")
Else               
	if lPrjCni	
		cQuery := " SELECT SC1.* "
		cQuery += " FROM " + RetSqlTab("SC1") 
		cQuery += " WHERE SC1.C1_CODED = '" +cEdital + "' "
		cQuery += " AND SC1.C1_NUMPR = '" + cProcesso + "' "
		cQuery += " AND SC1.C1_PRODUTO = '" + cProduto + "' "
		cQuery += " AND SC1.C1_XTIPOSC <> '"+cTpCto+"' " // FSW - TIPO DE SC ADITIVO CONTRATO
	Else
		cQuery := " SELECT * "
		cQuery += " FROM " + RetSqlTab("SC1")
		cQuery += " WHERE C1_CODED = '" +cEdital + "' "
		cQuery += " AND C1_NUMPR = '" + cProcesso + "' "
		cQuery += " AND C1_PRODUTO = '" + cProduto + "' "
        EndIf
        
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPE que permite o usuario incrementar o filtro na query;ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lGCP02Fil
		cQuery += Execblock( "GCP02Fil", .F., .F. )
	EndIf

	cQuery += " AND " + RetSQLCond("SC1")
EndIf

cQuery := ChangeQuery(cQuery)
IncProc(STR0020)//"Selecionando as Solicita็๕es de Compra..."
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.F.)

If (cAliasTmp)->(!Eof())
	TcFieldAll(cAliasTmp)
	While (cAliasTmp)->(!Eof())
		aVetor:= {}
		
		if lPrjCni		
			if lWndManutEdit            
				if ExistBlock("GCP2HEAD")
			   		aVetTst = Execblock( "GCP2HEAD", .F., .F. , {(cAliasTmp)->(C1_NUMPR), aVetor} )// cEdital, cProcesso, cProduto, cTpCto})
			   		
			   		if ValType(aVetTst) == "A"
			 			aVetor := aVetTst
			   		EndIf                
				EndIf
			else
				aAdd( aVetor, .F. )
			EndIf  
		Else
			aAdd( aVetor, .F. )
		EndIf
		
		For nY:= 1 To Len(aHeadC1)-2
			If	!Empty((cAliasTmp)->( FieldGet(FieldPos(aHeadC1[nY,2] ) ) ))
				aAdd( aVetor, (cAliasTmp)->( FieldGet(FieldPos(aHeadC1[nY,2] ) ) ) )
			Else
				AAdd( aVetor, CriaVar(aHeadC1[nY,2]))
			EndIf
		Next nY
		aAdd( aDados , aVetor )
		(cAliasTmp)->(dbSkip())
	End
ElseIf !Empty(xFilial("SC1")) .And. FindFunction("MaComCent") .And. SC1->(FieldPos("C1_COMPRAC")) > 0
	If (lRet := MsgYesNo(STR0084)) //Nใo existem solicita็๕es de licita็ใo nesta filial. Deseja buscar solicita็๕es de outras filiais?
		GCP02ComCe(oLbx,cQuery,lWndManutEdit,@aDados)
        If Len(aDados) == 0
			(cAliasTmp)->(DbCloseArea())
			lRet := .F.
		EndIf
	EndIf
Else
	Help("",1,"GCP02SOLIC") //"Nใo hแ dados de solicita็ใo de compras"
	(cAliasTmp)->(DbCloseArea())
	lRet := .F.
EndIf

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefine o titulo das colunas do browseณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd( aTitulo, "" )
	aAdd( aTam, 10 )
	For nX:= 1 To Len(aHeadC1)
		If !("_WT" $ aHeadC1[nX,2])
			aAdd( aTitulo, aHeadC1[nX,1] )
			aAdd( aTam, GetTextWidth( 0, Replicate( ";", 5+Max( TamSX3( aHeadC1[nX,2] )[1], Len( aHeadC1[nX,1] ) ) ) ) )
		EndIf
	Next
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDefinicao da Dialog ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 300,700 PIXEL
	
	//Definicao dos paineis (superior e inferiror)
	oTPane1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
	oTPane1:Align := CONTROL_ALIGN_TOP
	
	//Definicao dos objetos de busca
	aAdd(aCmbItens, aHeadC1[nNumSc ,  1] + " + " + aHeadC1[nItemSc ,1])
	aAdd(aCmbItens, aHeadC1[nProdSc , 1])
	aAdd(aCmbItens, aHeadC1[nDescrSc, 1])
	
	aAdd( aFilter, { 1, STR0043, Space(6), '@!', '', 'SC1', '', 40, .F. } )	// 'Numero da SC de  ?'
	aAdd( aFilter, { 1, STR0044, Space(6), '@!', '', 'SC1', '', 40, .F. } )	// 'Numero da SC ate ?'
	@ 03,03 COMBOBOX oCombo VAR cCombo ITEMS aCmbItens SIZE 100,20 ON CHANGE (nCmbOp:=oCombo:nAt) PIXEL OF oTPane1
	@ 03,105 MSGET cPesq SIZE 100,09 PIXEL OF oTPane1
	@ 03,207 BUTTON STR0041 SIZE 35,11 PIXEL OF oTPane1 ACTION ( oLbx:nAt := BuscaScm(aDados,cPesq,oLbx:nAt,nCmbOp,aHeadC1),oLbx:Refresh()) // '&Buscar'
	@ 03,244 BUTTON STR0042 SIZE 35,11 PIXEL OF oTPane1 ACTION ( If( ParamBox( aFilter, STR0039, @aRetFil ), GCAFilter( @aDados, aHeadC1, aRetFil, cAliasTmp ), Nil ) ) // '&Filtro'		// 'Filtro recursivo'
	
	//Definacao do MarkBrowse
	oLbx := TwBrowse():New(0,0,0,0,,aTitulo,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:Align := CONTROL_ALIGN_ALLCLIENT
	oLbx:aColSizes := aTam
	oLbx:SetArray( aDados )
	If lClick
		oLbx:bLDblClick := {|| aDados[oLbx:nAt,1] := !aDados[oLbx:nAt,1],oLbx:Refresh()}
	EndIf
	
	oLbx:bLine := GCAbLine( aDados )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณpor Icaro Queiroz em 28 de Setembro de 2010                          ณ
	//ณFaz a inversao da marcacao pelo clique no canto superior do cabecalhoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	olbx:bheaderclick := { |x,y| If( Len( aDados )== 0, Alert( STR0040 ), If( y == 1, GCAMarkAll( @aDados ), Nil ) ) }	// 'Nใo existe dados para sele็ใo'
	
	If FindFunction("MaComCent") .And. SC1->(FieldPos("C1_COMPRAC")) > 0
		aAdd(aButtons,{'PROJETPMS',{|| GCP02ComCe(oLbx,cQuery,lWndManutEdit,@aDados)},STR0085}) //-- Compra Centralizada
	EndIf
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| (oDlg:End(),nOpcX:= 1)},{||oDlg:End()},,aButtons)
	
	If nOpcX == 1
		aRet := aClone(aDados)
	EndIf
	
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

RestArea(aArea)
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BuscaScm     บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao de busca da usada pela tela de inclusao do Edital        บฑฑ
ฑฑบ          ณ via solicitacao de compra.                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function BuscaScm(aDados,cPesq,nPosAtu,nIndex,aHeadC1)
Local nPos

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao do criterio de pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nIndex == 1
	nPos:= aScan(aDados,{|x| RTrim(cPesq) $ RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_NUM"}) + 1]) + RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_ITEM"}) + 1])},nPosAtu + 1)
ElseIf nIndex == 2
	nPos:= aScan(aDados,{|x| RTrim(cPesq) $ RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_PRODUTO"}) + 1])},nPosAtu + 1)
ElseIf nIndex == 3
	nPos:= aScan(aDados,{|x| RTrim(cPesq) $ RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_DESCRI"}) + 1])},nPosAtu + 1)
EndIf

If nPos == 0
	Help("",1,"GCP02BUS") //"Informa็ใo nใo localizada"
	nPos:= 1
Endif

Return nPos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02TF31     บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para fazer a troca do F3 dos aprovadores de usuario บฑฑ
ฑฑบ          ณ para aprovadores externos. Esta sendo executado pelo       บฑฑ
ฑฑบ          ณ X3_VLDUSER dos campos CO2_TPAPR1 e CO2_TPAPR2              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GCP02TF31()

//-- Estabelece a Troca de Aprovador Externo

aTrocaF3 := {}

If ( M->CO1_TPAPR1 == "2" )
	AAdd(aTrocaF3,{"CO1_APROV1","CO5"})
EndIf
If ( M->CO1_TPAPR2 == "2" )
	AAdd(aTrocaF3,{"CO1_APROV2","CO5"})
EndIf

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02ComEmailบAutorณMicrosiga           บ Data ณ  04/13/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que envia email para comissใo                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02ComEmail(cEdital , cNumPro )
Local aArea := GetArea()
Local oHTML := Nil
Local cArqDot := "EMAILCOMIS.HTM"     // Nome do Arquivo MODELO do Email
Local cPathDot:= AllTrim(GETMV("MV_GCPDOT",,"\samples\documents\gcp\dot\")) // PATH DO ARQUIVO MODELO WORD
Local cFile   := cPathDot + cArqDot
Local lEnvRet := .T.
Local cFileHTML := CriaTrab( NIL , .F. ) + ".htm"
Local cAssunto := STR0021 //"Convoca็ใo de Comissใo"
Local cMsg	   := ""

cNumPro := Alltrim(cNumPro)

CO9->(dbSetOrder(1))//CO9_FILIAL+CO9_CODEDT+CO9_NUMPRO+CO9_ITEM
If CO9->(dbSeek(xFilial("CO9") + cEdital + cNumPro ))
	If Aviso(cCadastro,STR0022,{STR0023,STR0024},2,STR0025) == 1 //"Deseja enviar e-mail de aviso para os participantes da comissใo?"##"Sim"##"Nใo"##"Comissใo"
		If File(cFile)
			While CO9->(!EOF()) .And. Alltrim(CO9->(CO9_FILIAL+CO9_CODEDT+CO9_NUMPRO)) == Alltrim(xFilial("CO9") + cEdital + cNumPro)
				oHTML := TWFHTML():New( cFile )
				oHTML:ValByName( "cCodEdt", cEdital     )
				oHTML:ValByName( "cNumPro", cNumPro     )
				oHTML:ValByName( "cNome" , CO9->CO9_NOME)
				oHTML:SaveFile( cFileHTML )
				cMsg := WFLoadFile(cFileHTML)
				cMsg := StrTran(cMsg,chr(13),"")
				cMsg := StrTran(cMsg,chr(10),"")
				lEnvRet := SetMail(CO9->CO9_EMAIL,cAssunto,cMsg)
//				lEnvRet := GCP02Email(CO9->CO9_EMAIL, Nil, cAssunto, cMsg)
				Erase(cFileHTML)
				If !lEnvRet
					Help("",1,"GCP02EMAIL") //"Erro no envio do email, verifique as configura็๕es no configurador. Mais detalhes no log do servidor"
					Exit
				EndIf  
				CO9->(DBSKIP())
			EndDo
			If lEnvRet 
				Help("",1,"GCP02OKMAIL") //"E-Mail(s) enviado(s) com sucesso."
			EndIf
		Else
			Help("",1,"GCP02ARQMAIL") //"Arquivo EMAILCOMIS.HTM nใo estแ no diretorio configurado no parametro MV_GCPDOT "
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02VldFor  บAutor  ณ Totvs          บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao para nao permitir o participante duas vezes para บฑฑ
ฑฑบ          ณ o mesmo produto do Edital. Esta sendo executado pelo       บฑฑ
ฑฑบ          ณ X3_VLDUSER do campo CO3_CODIGO                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GCP02VldFor()

Local lRet     := .T.
Local i        := 0
Local nT_aCOLS := Len(oGetPart:aCOLS)
Local nItem    := oGetPart:oBrowse:nAt
Local nP_Tip   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="CO3_TIPO"})
Local nP_For   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="CO3_CODIGO"})
Local nP_Loj   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="CO3_LOJA"})
Local nP_Nom   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="CO3_NOME"})
Local nP_Lote  := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="CO3_LOTE"})
Local cTipo    := ''
Local cForn    := ''
Local cLoj	   := ''
Local cForCli  := "F"
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

cTipo    := oGetPart:aCOLS[n,nP_Tip]
cForn    := oGetPart:aCOLS[n,nP_For]
cLoj     := oGetPart:aCOLS[n,nP_Loj]

If 'CO3_LOJA' $ ReadVar()
	cLoj:= &(ReadVar())
Else
	If	cTipo == "1"
		cForn := M->CO3_CODIGO
	ElseIf 'CO3_CODIGO' $ ReadVar()	
		cForn:= &(ReadVar())
	EndIf
EndIf

If M->CO1_MODALI == "LL"
	cForCli  := "C"
Endif



//-- simula gatilho para preencher loja do participante e descricao
If cTipo == "2"       // participante
	If !Empty(cLoj)
		If cForCli == "F"
			oGetPart:aCOLS[n,nP_Loj] := Posicione("SA2",1,xFilial("SA2")+cForn+cLoj,"A2_LOJA")
			oGetPart:aCOLS[n,nP_Nom] := Posicione("SA2",1,xFilial("SA2")+cForn+cLoj,"A2_NOME")
			If SA2->(Eof())
				Help("",1,"GCP02FORC") //"Fornecedor nใo cadastrado"
				lRet := .F.
			Endif
			If SA2->A2_MSBLQL == '1' // Bloqueado SIM
				Help("",1,"GCP02FORB") //"Fornecedor bloqueado"
				lRet := .F.
			EndIf
		Else
			oGetPart:aCOLS[n,nP_Loj] := Posicione("SA1",1,xFilial("SA1")+cForn+cLoj,"A1_LOJA") 
			oGetPart:aCOLS[n,nP_Nom] := Posicione("SA1",1,xFilial("SA1")+cForn+cLoj,"A1_NOME")
			If SA1->(Eof())
				Help("",1,"GCP02CLIC") //"Cliente nใo cadastrado"
				lRet := .F.
			Endif
			If SA1->A1_MSBLQL == '1' // Bloqueado SIM
				Help("",1,"GCP02CLIB") //"Cliente bloqueado"
				lRet := .F.
			EndIf
		Endif
	Else
		If cForCli == "F"
			Posicione("SA2",1,xFilial("SA2")+cForn,"A2_COD")
			If SA2->(Eof())                                                            
				Help("",1,"GCP02FORC") //"Fornecedor nใo cadastrado"
				lRet := .F.
			Endif
		Else
			Posicione("SA1",1,xFilial("SA1")+cForn,"A1_COD") 
			If SA1->(Eof())
					Help("",1,"GCP02CLIC") //"Cliente nใo cadastrado"
				lRet := .F.
			Endif
		Endif
	EndIf
ElseIf cTipo == "1"   // pre-participante
	oGetPart:aCOLS[n,nP_Loj] := Posicione("CO6",1,xFilial("CO6")+cForn+cLoj,"CO6_LOJFOR")
	oGetPart:aCOLS[n,nP_Nom] := Posicione("CO6",1,xFilial("CO6")+cForn+cLoj,"CO6_NOME")
	oGetPart:aCOLS[n,nP_For] := Posicione("CO6",1,xFilial("CO6")+cForn+cLoj,"CO6_CODIGO")
	If CO6->(Eof())
		Help("",1,"GCP02PART") //"Participante nใo cadastrado"
		lRet := .F.
	ElseIf SA2->(dbSeek(xFilial("SA2")+CO6->(CO6_FORNEC+CO6_LOJFOR)))   
//		Help("",1,"PGCP02SA2")
		MsgAlert (STR0104)		//"Fornecedor jแ cadastrado na tabela de Fornecedores"
		lRet := .F.
	EndIf
Endif

For i:=1 To nT_aCOLS
	If i <> nItem
		If oGetPart:aCOLS[i,nP_Tip] == cTipo .And.  oGetPart:aCOLS[i,nP_For] == cForn .And. oGetPart:aCOLS[i,nP_Loj] == cLoj .And. !oGetPart:aCOLS[i,len(aCols[i])]
			Help("",1,"GCP02FDUP") //"Jแ existe este c๓digo de fornecedor/cliente para o produto"
			lRet := .F.
		Endif
	Endif
Next i        

If	lRet .And. !lPrjCni
	oGetPart:aCOLS[n,nP_Lote]:=cLote
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaHeaderบAutor  ณAlvaro Camillo Neto บ Data ณ  21/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Aheader da getdados                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader,cAlias)
Local   lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local 	aArea		:= GetArea()   
Local   lGCP2FHEA   := iif ( lPrjCni, Existblock( 'GCP2FHEA'), .F.)
Local   lRetTst := .F., lRetProibe := .F.
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que nใo conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .Or. ( AllTrim(SX3->X3_CAMPO) $ Alltrim(cCampos) )) .AND. (cNivel >= SX3->X3_NIVEL) .AND. !(AllTrim(SX3->X3_CAMPO) $ Alltrim(cExcessao)) 
	   
		if lPrjCni   
			if lGCP2FHEA
				lRetTst :=	Execblock( "GCP2FHEA", .F., .F., {cAlias, AllTrim(SX3->X3_CAMPO)} )
				if ValType(lRetTst) == "L"
					lRetProibe := lRetTst
				EndIf
		    EndIf
		    
			if !lRetProibe
				aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
				SX3->X3_CAMPO	, ;			// 02 - Campo
				SX3->X3_Picture	, ;			// 03 - Picture
				SX3->X3_TAMANHO	, ;			// 04 - Tamanho
				SX3->X3_DECIMAL	, ;			// 05 - Decimal
				SX3->X3_Valid  	, ;			// 06 - Valid
				SX3->X3_USADO  	, ;			// 07 - Usado
				SX3->X3_TIPO   	, ;			// 08 - Tipo
				SX3->X3_F3		   , ;		// 09 - F3
				SX3->X3_CONTEXT   , ;       // 10 - Contexto
				SX3->X3_CBOX	  , ; 		// 11 - ComboBox
				SX3->X3_RELACAO    } )   // 12 - Relacao
			EndIf
		Else
			aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
			SX3->X3_CAMPO	, ;			// 02 - Campo
			SX3->X3_Picture	, ;			// 03 - Picture
			SX3->X3_TAMANHO	, ;			// 04 - Tamanho
			SX3->X3_DECIMAL	, ;			// 05 - Decimal
			SX3->X3_Valid  	, ;			// 06 - Valid
			SX3->X3_USADO  	, ;			// 07 - Usado
			SX3->X3_TIPO   	, ;			// 08 - Tipo
			SX3->X3_F3		   , ;		// 09 - F3
			SX3->X3_CONTEXT   , ;       // 10 - Contexto
			SX3->X3_CBOX	  , ; 		// 11 - ComboBox
			SX3->X3_RELACAO    } )   // 12 - Relacao
		EndIf		
	Endif
	SX3->(dbSkip())
End

If cAlias # "COC"
	ADHeadRec(cAlias,aHeader)
EndIf

RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณCriaAcols บAutor  ณAlvaro Camillo Neto บ Data ณ  21/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณFunc๕a que cria Acols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณcAlias  : Alias da tabela                                   บฑฑ
ฑฑบ          ณnIndice : Indice da tabela que sera usado para              บฑฑ
ฑฑบ          ณcComp   : Informacao dos Campos para ser comparado no While บฑฑ
ฑฑบ          ณnOpc    : Op็ใo do Cadastro                                 บฑฑ
ฑฑบ          ณaCols   : Opcional caso queira iniciar com algum elemento   บฑฑ
ฑฑบ          ณcCPO_ITEM: Opcional Campo de item a ser inicializado com '001'บฑฑ
ฑฑบ          ณcINDICE : Chave de compara็ใo da tabela de item             บฑฑ
ฑฑบ          ณcCPOMemo: Opcional Nome do campo de c๓digo do MEMO          บฑฑ
ฑฑบ          ณcMemo   : Nome do campo memo virtual                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols,cCPO_ITEM,cINDICE, lRecno)
Local nX		   		:= 0
Local nCols		     	 := 0
Local aArea				:= GetArea()

DEFAULT aCols			:= {}
DEFAULT cCPO_ITEM		:= ""
DEFAULT lRecno			:= .T.

If !lRecno
	aSize(aHeader, Len(aHeader))
EndIf
	
IF nOpc == 3 // INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		If IsHeadRec(aHeader[nX,2])
			aCols[Len(aCols),nX] := 0
		ElseIf IsHeadAlias(aHeader[nX,2])
			aCols[Len(aCols),nX] := cAlias
		ElseIf Alltrim(aHeader[nX][2]) == cCPO_ITEM
			aCols[1][nX] := STRZERO(1,TamSX3(cCPO_ITEM)[1])
		Else
			aCols[1][nX] := CriaVar(AllTrim(aHeader[nX][2]))
		EndIF
	Next nX 
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(&(cINDICE))) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If IsHeadRec(aHeader[nX,2])
				aCols[Len(aCols),nX] := (cAlias)->(Recno())	
			ElseIf IsHeadAlias(aHeader[nX,2])
				aCols[Len(aCols),nX] := cAlias
			ElseIf ( aHeader[nX][10] != "V")   
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			Else
				If AllTrim(aHeader[nX,2])=="CO2_DESCR"
					aCols[nCols,nX] := CO2->(GcpValDesc(CO2->CO2_CODPRO))
	    	    Else
					aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)	    	    	
	    	    EndIf
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTcFieldAllบAutor  ณAlvaro Camillo Neto บ Data ณ  06/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAplica o comando TcSetField em todos os campos de uma query บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TcFieldAll(qQuery)
Local aStruQry 	:= {}
Local nI		:= 0
Local aArea		:= GetArea()
Local AAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2)) //X3_CAMPO
aStruQry   := (qQuery)->(dbStruct())
For nI := 1 To Len(aStruQry)
	If SX3->(dbSeek(aStruQry[nI][1]))
		aStruQry[nI][2] := SX3->X3_TIPO
		If aStruQry[nI][2] <> "C"
			TcSetField(qQuery ,aStruQry[nI][1],aStruQry[nI][2],aStruQry[nI][3],aStruQry[nI][4])
		EndIf
	EndIf
Next nI
RestArea(AAreaSX3)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ TOTVS SA              ณ Data ณ 06/04/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {}
Local aRotAux	:= {}
Local lGCP02Rot	:= Existblock( 'GCP02Rot' )

aAdd(aRotina,{STR0026 		,"AxPesqui"  ,0,1})//"Pesquisar"
aAdd(aRotina,{STR0027    	,"GCPA02Man" ,0,2})//"Consultar"
aAdd(aRotina,{STR0028     	,"GCPA02Man" ,0,3})//"Incluir" 
aAdd(aRotina,{STR0029    	,"GCPA02Man" ,0,4})//"Manutencao" 
aAdd(aRotina,{STR0031  		,"GCPA02Scm" ,3,3})//"Gerar Edital"
aAdd(aRotina,{STR0032	  	,"GCPA005" 	 ,0,5})//"Andamento"
aAdd(aRotina,{STR0033     	,"GCPA02Can" ,0,4})//"Cancelar"
aAdd(aRotina,{STR0034    	,"GCPA007" 	 ,0,4})//"Historico"
aAdd(aRotina,{STR0035    	,"MsDocument",0,4})//"Documentos" 
aAdd(aRotina,{STR0036      	,"GCPA02Leg" ,0,1})//"Legenda"
aAdd(aRotina,{STR0064      	,"GCPA02LegV",0,8})//"Consulta Modalidade x Valor"
aAdd(aRotina,{STR0065     	,"GCPA05SRP" ,0,6})//"Prorroga Edital SRP"
aAdd(aRotina,{STR0048     	,"GCPA005"	 ,0,6})//"Remanescente"
aAdd(aRotina,{STR0049     	,"GCPA02Enc" ,0,7})//"Encerrar"
aAdd(aRotina,{STR0138     	,"GCPA02Rev" ,0,4})//"Revogar"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณpor Icaro Queiroz em 16 de Agosto de 2010  ณ
//ณPermite inclusao de botao adicional no menuณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGCP02Rot
	aRotAux := Execblock( "GCP02Rot", .F., .F. )
	If ValType( aRotAux ) == "A"
		aEval( aRotAux, {|x| aAdd( aRotina, x ) } )
	EndIf
EndIf

Return( aRotina )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPA02Leg   บAutor  ณAlvaro Camillo Netoบ Data ณ  06/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda da rotina                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPA02Leg()

Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local aLeg	  := {}

aAdd(aLeg,{"BR_VERDE"     ,STR0105 })   // publicacao
aAdd(aLeg,{"BR_VERMELHO"  ,STR0106 })   // processo encerrado
aAdd(aLeg,{"BR_AMARELO"   ,STR0107 })   // edital
aAdd(aLeg,{"BR_AZUL"      ,STR0108 })   // pedido de compra
aAdd(aLeg,{"BR_BRANCO"    ,STR0109 })   // homologacao
aAdd(aLeg,{"BR_CINZA"     ,STR0110 })   // tecnica
aAdd(aLeg,{"BR_PINK"      ,STR0111 })   // abertura de documentacao
aAdd(aLeg,{"BR_LARANJA"   ,STR0112 })   // abertura comercial
aAdd(aLeg,{"BR_MARRON"    ,STR0113 })   // faturamento / vendas
aAdd(aLeg,{"BR_PRETO"     ,STR0114 })   // pregao externo
aAdd(aLeg,{"LIGHTBLU"     ,STR0115 })   // contrato
aAdd(aLeg,{'BRANCO'       ,STR0116 })   // assinatura do contrato
aAdd(aLeg,{'AVGOIC1'      ,STR0117 })   // juridico
aAdd(aLeg,{'BR_MARROM'    ,STR0118 })   // gerar pedido / contrato
aAdd(aLeg,{'PMSEDT2'      ,STR0119 })   // Edital revogado       
aAdd(aLeg,{'BR_VIOLETA'   ,STR0120 })   // Sistema de Registro de Preco bloqueio   

If !lPrjCni
	aAdd(aLeg,{'PMSEDT4'   ,STR0121 })   // Sistema de Registro de Pre็o continua etapa
EndIf

BrwLegenda(cCadastro,"Status",aLeg)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPA02Status   บAutor  ณAlvaro Camillo Netoบ Data ณ  06/04/10บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda da rotina                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPA02Status()

Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local aStatus := {}   


		aAdd(aStatus,{"CO1_ETAPA == 'PB'" ,'BR_VERDE'     })   // publicacao
		aAdd(aStatus,{"CO1_ETAPA == 'PE'" ,'BR_VERMELHO'  })   // processo encerrado
		aAdd(aStatus,{"CO1_ETAPA == 'ED'" ,'BR_AMARELO'   })   // edital
		aAdd(aStatus,{"CO1_ETAPA == 'PC'" ,'BR_AZUL'      })   // pedido de compra
		aAdd(aStatus,{"CO1_ETAPA == 'PM'" ,'BR_AZUL'      })   // pedido de compra manual
		aAdd(aStatus,{"CO1_ETAPA == 'HO'" ,'BR_BRANCO'    })   // homologacao
		aAdd(aStatus,{"CO1_ETAPA == 'TP'" ,'BR_CINZA'     })   // tecnica
		aAdd(aStatus,{"CO1_ETAPA == 'AD'" ,'BR_PINK'      })   // abertura de documentacao
		aAdd(aStatus,{"CO1_ETAPA == 'AC'" ,'BR_LARANJA'   })   // abertura comercial
		aAdd(aStatus,{"CO1_ETAPA == 'FV'" ,'BR_MARRON'    })   // faturamento / vendas
		aAdd(aStatus,{"CO1_ETAPA == 'PX'" ,'BR_PRETO'     })   // pregao externo
		aAdd(aStatus,{"CO1_ETAPA == 'CO'" ,'LIGHTBLU'     })   // contrato
		aAdd(aStatus,{"CO1_ETAPA == 'AS'" ,'BRANCO'  	  	})   // assinatura do contrato
		aAdd(aStatus,{"CO1_ETAPA == 'JR'" ,'AVGOIC1'			})   // juridico
		aAdd(aStatus,{"CO1_ETAPA $ 'GP/EC/EO'" ,'BR_MARROM'    })   // gerar pedido / contrato
		aAdd(aStatus,{"CO1_ETAPA == 'PR'" ,'PMSEDT2'    })   // Edital revogado       
 		aAdd(aStatus,{"CO1_ETAPA == 'SR'" ,'PMSEDT4'    })   // Edital revogado continua etapa      

CO1->(dbSetOrder(1)) //CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO
While CO1->(!EOF())                        
	If !lPrjCni .And. (CO1->CO1_SRP == "S" .Or. CO1->CO1_SRP == "1") .And. !Empty(CO1->CO1_DTSRP)
		nQtdSRP:= IIf ( !Empty(CO1_DTSRPA) , CO1_DTSRPA, CO1->CO1_DTSRP) + CO1_QTDSRP   //edu 1403
		//nMesSRP := Year(CO1->CO1_DTSRP)+1  
//		If dDataBase > STOD(cvaltoChar(nMesSRP) + Right(DTOS(CO1->CO1_DTSRP),4)) 
		If dDataBase > nQtdSRP
			RecLock("CO1",.F.)   
				CO1->CO1_BKPASS	:= CO1->CO1_PASSO
				CO1->CO1_BKETAP	:= CO1->CO1_ETAPA
		   		CO1->CO1_ETAPA	:= "AP"		
				aAdd(aStatus,{"DTOS(CO1_DTSRP) <= DTOS(DDATABASE)",'BR_VIOLETA'  })  // Sistema de Registro de Preco bloqueia  
			MsUnlock()
		ElseIf !(CO1->CO1_ETAPA $ ('PC*CO'))
			RecLock("CO1",.F.)
			CO1->CO1_ETAPA := CO1->CO1_BKETAP		
	    EndIf
	EndIf
CO1->(dbSkip())
EndDo

Return aStatus

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02VMod บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existem participantes associados, usado na       บฑฑ
ฑฑบ          ณ verificacao da mudanca de modalidade                 	    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02VldMod()
Local lRet   		:= .T. 
Local aValTipo	:= Iif(M->CO1_REGRA == "002",aModXTipo2,aModXTipo)        	
Local nPos	 	:= 0

If M->CO1_REGRA = "002" .And. M->CO1_MODALI == "TP"
	Aviso(STR0057,STR0134,{"OK"},1)
	lRet :=.F.
EndIf

If lRet .And. !Empty(M->CO1_MODALI) .And. (lRet := ExistCpo("SX5","LF"+M->CO1_MODALI))
	If (nPos := aScan(aValTipo,{|x| x[1] == M->CO1_MODALI})) > 0 .And. !(M->CO1_TIPO $ aValTipo[nPos,2])
		M->CO1_TIPO   := CriaVar("CO1_TIPO",.F.)
		M->CO1_DESTIP := CriaVar("CO1_DESTIP",.F.)
	EndIf
EndIf

Return lRet        


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAjustaSX3 ณ Autor ณ      Eduardo Dias     ณ Data ณ15/10/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Ajusta o X3_VALID do CO1_MODALI		    				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GCPA002                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function AjustaSX3()
                     
dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("CO1_MODALI") .And. Upper(AllTrim(SX3->X3_VALID)) # 'GCP02VLDMOD()'
	Reclock("SX3",.F.)                      
	X3_VALID := 'GCP02VldMod()'
	MsUnlock()
Endif                

If dbSeek("CO1_TIPO")
	If AllTrim(SX3->X3_F3) # "LG"
		Reclock("SX3",.F.)                      
		X3_F3 := "LG"
		MsUnlock()
	EndIf
	If AllTrim(Upper(SX3->X3_VALID)) # 'GCP02VLDTP()' 
		Reclock("SX3",.F.)
		X3_VALID := "GCP02VldTp()"
		MsUnlock()
	EndIf
Endif                                                 

If dbSeek("CO8_TIPO") .And. AllTrim(SX3->X3_F3) # "LG"
	Reclock("SX3",.F.)
	X3_F3 := "LG"
	MsUnlock()
Endif                

If dbSeek("CO1_DIRET") .And. AllTrim(X3_F3) # 'LJ'
	Reclock("SX3",.F.)                      
	X3_F3 := 'LJ'
	MsUnlock()
Endif              

If dbSeek ("CO2_DESCR") .And. SX3->X3_ORDEM <> '08'
	Reclock("SX3",.F.)                      
	X3_ORDEM := '08'
	MsUnlock()	
EndIf
               
If dbSeek("CO3_LOJA") .And. SX3->X3_VISUAL != 'A'
	Reclock("SX3",.F.)                      
	X3_VISUAL := 'A'
	MsUnlock()
Endif              

If dbSeek("CO3_LOJA") .And. !Empty(SX3->X3_TRIGGER)
	Reclock("SX3",.F.)                      
	X3_TRIGGER := ""
	MsUnlock()
Endif
               
If dbSeek("CO3_NOME") .And. !Empty(SX3->X3_RELACAO)
	Reclock("SX3",.F.)                      
	X3_RELACAO := " " 
	MsUnlock()
Endif 

If dbSeek("CO1_DSCRGR").And. Empty(SX3->X3_RELACAO)
	Reclock("SX3",.F.)
	X3_RELACAO := 'IIF(INCLUI, POSICIONE("CO0",1,XFILIAL("CO0")+"001","CO0_DSCRGR"),POSICIONE("CO0",1,XFILIAL("CO0")+CO1->CO1_REGRA,"CO0_DSCRGR"))' 
	MsUnlock()
Endif

aHelpPor :=	{"Arquivo EMAILCOMIS.HTM nใo estแ"," no diretorio configurado  no parametro MV_GCPDOT"}
aHelpEsp := {"El archivo EMAILCOMIS.HTM no esta"," en el directorio configurado  en el parametro MV_GCPDOT"}
aHelpEng := {"EMAILCOMIS.HTM file is not in the"," directory configured in the parameter MV_GCPDOT"}
PutHelp("PGCP02ARQMAIL",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor :=	{	"Nao sera permitido linha sem email."}
aHelpEng := {   "Line without e-mail is not allowed."}
aHelpEsp := {   "No se permitira linea sin email."}
PutHelp("PGCP02NOMAIL",aHelpPor,aHelpEng,aHelpEsp,.T.)

aHelpPor :=	{	"ษ necessแrio pelo menos ","um produto no edital"}
aHelpEng := {   "ษ necessแrio pelo menos ","um produto no edital"}
aHelpEsp := {   "ษ necessแrio pelo menos ","um produto no edital"}
PutHelp("PGCP02NOITEM",aHelpPor,aHelpEng,aHelpEsp,.T.)   

aHelpPor :=	{	"Pedido nใo pode ser ","excluido, pois foi gerado por Edital"}
aHelpEng := { 	"Pedido nใo pode ser ","excluido, pois foi gerado por Edital"}
aHelpEsp := {   "Pedido nใo pode ser ","excluido, pois foi gerado por Edital"}
PutHelp("PA120EDITAL",aHelpPor,aHelpEng,aHelpEsp,.T.)   

aHelpPor :=	{	"Pedido nใo pode ser ","excluido, pois foi gerado por Edital"}
aHelpEng := { 	"Pedido nใo pode ser ","excluido, pois foi gerado por Edital"}
aHelpEsp := {   "Pedido nใo pode ser ","excluido, pois foi gerado por Edital"}
PutHelp("PMA410EDITAL",aHelpPor,aHelpEng,aHelpEsp,.T.)   


aHelpPor :=	{	"Todos os campos sใo obrigatorios "," para gera็ใo do Contrato"}
aHelpEng := { 	"Todos os campos sใo obrigatorios "," para gera็ใo do Contrato"}
aHelpEsp := {   "Todos os campos sใo obrigatorios "," para gera็ใo do Contrato"}
PutHelp("PGCPOBRCNT",aHelpPor,aHelpEng,aHelpEsp,.T.)           

aHelpPor :=	{	"O tipo de contrato deve ser de venda"}
aHelpEng := {   "O tipo de contrato deve ser de venda"}
aHelpEsp := {   "O tipo de contrato deve ser de venda"}
PutHelp("PGCPCNTVEN",aHelpPor,aHelpEng,aHelpEsp,.T.) 

aHelpPor :=	{	"O tipo de contrato deve ser de compra"}
aHelpEng := { 	"O tipo de contrato deve ser de compra"}
aHelpEsp := {   "O tipo de contrato deve ser de compra"}
PutHelp("PGCPCNTCOM",aHelpPor,aHelpEng,aHelpEsp,.T.) 

aHelpPor :=	{ "Contrato nใo pode ser excluido"," pois foi gerado por edital"}
aHelpEng := { "Contrato nใo pode ser excluido"," pois foi gerado por edital"}
aHelpEsp := { "Contrato nใo pode ser excluido"," pois foi gerado por edital"}
PutHelp("PCNT100EDITAL",aHelpPor,aHelpEng,aHelpEsp,.T.)


If	AliasIndic("CO0")
	CO0->(DbGoTop())
	If	CO0->(Eof())
		GCP017Carga()
	EndIf
EndIf

Return           
               
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAjustaSX1 ณ Autor ณ      Eduardo Dias     ณ Data ณ19/11/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Ajusta o SX1                 		    				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GCPA002                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function AjustaSX1( lX1, cPerg )          

Local aArea		:= GetArea()
Local aHelpP	:= {}
Local aHelpE	:= {}
Local aHelpS	:= {}
Local cModal    := CriaVar("CO1_MODALI",.F.)
Local cTipo     := CriaVar("CO1_TIPO",.F.)

Default lX1		:= .T.

IF lRemanescente
	cModal    := ALLTRIM(CO1->CO1_MODALI)
	cTipo     := ALLTRIM(CO1->CO1_TIPO)
ENDIF

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(Padr("GCA002",10)+"02") .And. "NAOVAZIO() .AND. " $ Upper(SX1->X1_VALID)
	Reclock("SX1",.F.)                      
	X1_VALID := "ExistChav('CO1',mv_par01+mv_par02)"
	MsUnlock()
Endif  

If lX1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPrimeira tela de escolha na geracao do editalณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If !MsSeek(Padr("GCPA02",len(sx1->x1_grupo))+"01")
		PutSX1( cPerg, '01', 'Modalidade ?', 'Modalidade ?', 'Modalidade ?', 'mv_ch1', 'C', 2, 0, 0, 'G', 'EXISTCPO("SX5","LF"+mv_par01)', 'LF', '', 'S', 'mv_par01', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelpP, aHelpE, aHelpS )
	    If MsSeek(Padr("GCPA02",len(sx1->x1_grupo))+"01")
	    	RecLock("SX1",.F.)
				X1_PICTURE	:= "@!"
			MsUnLock()
		Endif
	Else
		RecLock("SX1", .F.)
		    X1_PERGUNT	:= 'Modalidade ?'
		    X1_PERSPA	:= 'Modalidade ?'
		    X1_PERENG	:= 'Modalidade ?'
		    X1_VALID	:= 'EXISTCPO("SX5","LF"+mv_par01)'
		    X1_VAR01	:= 'mv_par01'                               
			X1_CNT01 	:= ""
			X1_PICTURE	:= "@!"
		MsUnLock()
	EndIf
		
	If !MsSeek(Padr("GCPA02",len(sx1->x1_grupo))+"02") 
		PutSX1( cPerg, '02', 'Tipo de modalidade ?', 'Tipo de modalidade ?', 'Tipo de modalidade ?', 'mv_ch2', 'C', 2, 0, 0, 'G', 'GCP02VldTp', 'LG', '', 'S', 'mv_par02', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', aHelpP, aHelpE, aHelpS )
        If MsSeek(Padr("GCPA02",len(sx1->x1_grupo))+"02")
        	RecLock("SX1",.F.)                      
				X1_PICTURE := "@!"
			MsUnLock()
		EndIf
	Else
		RecLock("SX1", .F.)
			X1_CNT01 := ""
		MsUnlock()	
	EndIf
	
	If !MsSeek(Padr("GCPA02",len(SX1->X1_GRUPO))+"03")
		PutSX1(cPerg,'03', 'Regra', 'Regla', 'Rule', 'mv_ch3', 'C', 3, 0, 0, 'G', 'ExistCpo("CO0", mv_par03)', 'CO0', '', 'S', 'mv_par03', '', '', '', '001', '', '', '', '', '', '', '', '', '', '', '', '', aHelpP, aHelpE, aHelpS)  
	Else
		RecLock("SX1", .F.)
			X1_VALID 	:= 'ExistCpo("CO0", mv_par03)'
			X1_VARIAVL	:= 'mv_ch3'
		MsUnlock()
	EndIf
	
Else
	SX3->( dbSetOrder(2) )
	If SX3->( dbSeek( 'CO1_DTABER' ) )
		If Alltrim( X3Titulo() ) <> 'Dt. Recebim.'
			RecLock( 'SX3', .F. )
				Replace X3_TITULO	With 'Dt. Recebim.'
				Replace X3_TITSPA	With 'Dt. Recebim.'
				Replace X3_TITENG	With 'Dt. Recebim.'
				Replace X3_DESCRIC	With 'Data do Recebimento'
				Replace X3_DESCSPA	With 'Data do Recebimento'
				Replace X3_DESCENG	With 'Data do Recebimento'
			SX3->( MsUnLock() )
		EndIf
	EndIf
                     
	If SX3->( dbSeek( 'CO1_HRABER' ) )
		If Alltrim( X3Titulo() ) <> 'Hr. Recebim.'
			RecLock( 'SX3', .F. )
				Replace X3_TITULO	With 'Hr. Recebim.'
				Replace X3_TITSPA	With 'Hr. Recebim.'
				Replace X3_TITENG	With 'Hr. Recebim.'
				Replace X3_DESCRIC	With 'Hora do Recebimento'
				Replace X3_DESCSPA	With 'Hora do Recebimento'
				Replace X3_DESCENG	With 'Hora do Recebimento'
			SX3->( MsUnLock() )
		EndIf
	EndIf

	If SX3->( dbSeek( 'CO1_MODALI' ) )
		If Alltrim( SX3->X3_WHEN ) <> '.F.'
			RecLock( 'SX3', .F. )
				Replace X3_WHEN	With '.F.'
			SX3->( MsUnLock() )
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณGCAMarkAllณ Autor ณ      Icaro Queiroz    ณ Data ณ28/09/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Marca ou desmarca todos os itens;	    				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GCAMarkAll                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GCAMarkAll( aData )

aEval( aData, { |x| If( Empty( aData ), Nil, x[1] := !x[1] ) }, oLbx:Refresh() )

oLbx:bLine := GCAbLine( aData )
oLbx:Refresh()

Return( .T. )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณGCAFilter ณ Autor ณ      Icaro Queiroz    ณ Data ณ29/09/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ	Filtro recursivo - SC de|ate     						  ณฑฑ
ฑฑณ			 ณ	param  aData	Itens disponiveis para selecao			  ณฑฑ
ฑฑณ			 ณ	param  aHeadC1	Itens disponiveis para selecao            ณฑฑ
ฑฑณ			 ณ	param  aRetFil	Retorna da selecao dos parametros		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GCAFilter                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function GCAFilter( aData, aHeadC1, aRetFil, cAliasTmp )
Local nX		:= 0
Local nY		:= 0
Local aAuxData	:= {}
Local aVetor := {}

aData := {}
dbSelectArea(cAliasTmp)
dbGoTop()
If (cAliasTmp)->(!Eof())
	TcFieldAll(cAliasTmp)
	While (cAliasTmp)->(!Eof())
		aVetor:= {}
		aAdd( aVetor, .F. )
		For nY:= 1 To Len(aHeadC1)-2
			If !Empty((cAliasTmp)->(FieldGet(FieldPos(aHeadC1[nY,2]))))
				aAdd(aVetor,(cAliasTmp)->(FieldGet(FieldPos(aHeadC1[nY,2]))))
			Else
				aAdd(aVetor,CriaVar(aHeadC1[nY,2]))
			EndIf
		Next nY
		aAdd( aData , aVetor )
		(cAliasTmp)->(dbSkip())
	End
EndIf

aEval( aData, { |y| nX++, If( aRetFil[1] <= aData[nX][ aScan( aHeadC1, { |z| Trim( z[2] ) == 'C1_NUM' } ) + 1] .And. aRetFil[2] >= aData[nX][ aScan( aHeadC1, { |z| Trim( z[2] ) == 'C1_NUM' } ) + 1], aAdd( aAuxData, y ), Nil ) }, oLbx:Refresh() )

aData := aClone( aAuxData )

oLbx:SetArray( aData )
oLbx:bLine := GCAbLine( aData )
oLbx:Refresh()

Return( .T. )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ GCAbLine ณ Autor ณ      Icaro Queiroz    ณ Data ณ29/09/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ	Indica o bloco de codigo da lista de campos				  ณฑฑ
ฑฑณ			 ณ	@param  aData	Itens disponiveis para selecao			  ณฑฑ
ฑฑณ			 ณ	@Return bMyLine	blogo de codigo da lista de campos        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GCAFilter                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function GCAbLine( aData )
Local bMyLine
Local cLine		:= ''

cLine := '{ Iif( aData[oLbx:nAt,1], oOk, oNo )'
aEval( aTitulo, { |x,y| cLine += ',aData[oLbx:nAt,' + LTrim( Str(y) ) + ']' }, 2 ); cLine += '}'

bMyLine := & ( '{|| ' + cLine + '}' )

Return( bMyLine )  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCPA02EncบAutor  ณ Totvs              บ Data ณ  17/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Encerra o processo do edital a qualquer momento            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function GCPA02Enc()

Local aGrvCO1  := {}
Local aGrvCO7  := {}
Local cCO7Acao := ""

dbSelectArea("CO1")

//-- nao permite cancelamento de edital ja encerrado ou pedido de compras gerado
If CO1->CO1_ETAPA $ "PE,CE"
	Help("",1,"GCP02NOENC") //"O Edital nใo pode ser encerrado"
	Return
Endif

If MsgYesNo(STR0046,cCadastro)
	
	cCO7Acao := STR0016 + CO1->CO1_PASSO + chr(13)+chr(10)//"Passo: "
	cCO7Acao += STR0045 + chr(13)+chr(10)//"Encerramento do Edital"
	
	aGrvCO1 := {	{"CO1_ETAPA" , "PE"      }}  // processo encerrado
	
	aGrvCO7 := {	{"CO7_CODEDT", CO1->CO1_CODEDT},;
	{"CO7_NUMPRO", CO1->CO1_NUMPRO},;
	{"CO7_DTMOV" , dDataBase},;
	{"CO7_HRMOV" , Time()},;
	{"CO7_CODUSU", Upper(Alltrim(Substr(cUsuario,7,15)))},;
	{"CO7_MOVATU", CO1->CO1_ETAPA},;
	{"CO7_DESATU", Posicione("SX5",1,xFilial("SX5")+'LE'+CO1->CO1_ETAPA,"X5_DESCRI")},;
	{"CO7_ACAO"  , cCO7Acao },;
	{"CO7_PASATU", CO1->CO1_PASSO}}
	GCPA006(aGrvCO7, aGrvCO1)

Else
	MsgInfo(STR0055) //"Edital nao encerrado"
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ LimpRes  ณ Autor ณ      TOTVS            ณ Data ณ28/06/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ	A rotina tem como objetivo eliminar residuos de pedidos deณฑฑ
ฑฑณ			 ณ	de compras e pedido de venda                			  ณฑฑ
ฑฑณ			 ณ	Para contratos o cancelamento                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ	LimpRes( cTipo, aDados )                                  ณฑฑ
ฑฑณ			 ณ	cTipo : PC ( Pedido de Compra )                           ณฑฑ
ฑฑณ			 ณ	        PV ( Pedido de Venda )                            ณฑฑ
ฑฑณ			 ณ	        CO ( Contrato )                                   ณฑฑ
ฑฑณ			 ณ	aDados : C6_NUM / C7_NUM / CN9_NUMERO, CN9_REVISA         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ DATAPREV                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function LimpRes(cTipo,aDados)
Local aArea   := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local aRet     := {}
Local aAux     := {}
Local lRet     := .T.
Local cNumPro  := CO1->CO1_NUMPRO
Local cQuery   := ""
Local cFilSC1  := ""
Local cSitAnt  := " "
Local cFilBkp  := cFilAnt
Local lCancelCN9:= .F.
Local lCancelSC7:= .F.

If Empty(Alltrim(cTipo)) .Or. !(Alltrim(UPPER(cTipo)) $ 'PC_FV_CO')
	Help( "", 1, STR0054) //"Tipo de opera็ใo invแlido ! - LIMPRES()"
	aAdd(aRet,{.F.,''})
	lRet := .F.
EndIf

If lRet
	Do Case
	
	Case cTipo == 'P' //-- Pedido de Compra
	
		cQuery := "SELECT R_E_C_N_O_ SC7RECNO "
		cQuery += "FROM " +RetSqlName('SC7') +" WHERE "
		cQuery += "	D_E_L_E_T_ <> '*' AND "
		If SC7->(FieldPos("C7_FISCORI")) == 0
			cQuery += "	C7_FILIAL = '" +xFilial('SC7') +"' AND "
		Else
			cQuery += "	CASE C7_FISCORI WHEN '" +Space(FWSizeFilial()) +"' THEN C7_FILIAL "
			cQuery += " ELSE C7_FISCORI END = '" +xFilial('SC7') +"' AND "
		EndIf
		cQuery += "	C7_CODED = '" +CO1->CO1_CODEDT +"' AND "
		cQuery += "	C7_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "	C7_QUANT - C7_QUJE > 0 AND "
		cQuery += "	C7_RESREM <> 'S'"
		cQuery := ChangeQuery(cQuery)		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC7TMP")

		Begin Transaction

		While lRet .And. SC7TMP->(!EOF())			
			dbSelectArea('SC7')
			dbGoTo(SC7TMP->SC7RECNO)
							
			lCancelSC7:=.F.
			If	!Empty(aDados) .And. Ascan(aDados,{|x| x[6] + x[7] + x[3] == SC7->C7_CODED + SC7->C7_NUMPR + SC7->C7_PRODUTO }) > 0
				lCancelSC7:=.T.
			EndIf

			If	lCancelSC7
				If AllTrim(SC7->C7_RESIDUO) <> "S"
					lRet := MA235ElRes()
					SC7->(dbGoTo(SC7TMP->SC7RECNO))
				EndIf
				
				If !lRet
					Help("",1,"LIMPRES",,STR0050 +SC7->C7_NUM +"/" +SC7->C7_ITEM,1,1) //"Erro ao eliminar o resํduo do pedido de compra : "
					aAdd(aRet,{.F.,''})
					DisarmTransaction()
					lRet := .F.
				Else	
					RecLock("SC7",.F.)
					SC7->C7_RESREM := "S"
					SC7->(MsUnLock())
					aAdd(aRet,{lRet,SC7->C7_PRODUTO,SC7->(C7_QUANT - C7_QUJE),SC7->(C7_NUMSC-C7_ITEMSC)})
				EndIf
			EndIf
	
			SC7TMP->(dbSkip())				
		End
		
		End Transaction
		
		SC7TMP->(dbCloseArea())		
		
	Case cTipo == 'F' //-- Pedido de venda
	
		cQuery := "SELECT SC6.R_E_C_N_O_ SC6RECNO "
		cQuery += "FROM " +RetSqlName("SC6") +" SC6 "
		cQuery += "JOIN " +RetSqlName("SC5") +" SC5 ON SC5.D_E_L_E_T_ <> '*' AND "
		cQuery += "	SC5.C5_FILIAL = '" + xFilial('SC5') + "' AND "
		cQuery += "	SC5.C5_NUM = SC6.C6_NUM AND "
		cQuery += "	SC5.C5_CODED = '" +CO1->CO1_CODEDT +"' AND "
		cQuery += "	SC5.C5_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "	SC5.C5_RESREM <> 'S' "
		cQuery += "WHERE SC6.D_E_L_E_T_ <> '*' AND SC6.C6_FILIAL = '" + xFilial('SC6') + "' AND"
		cQuery += "	SC6.C6_QTDVEN - SC6.C6_QTDENT > 0
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC6TMP")
		
		Begin Transaction
		
		While lRet .And. SC6TMP->(!EOF())			
			dbSelectArea("SC6")
			dbGoTo(SC6TMP->SC6RECNO)
			
			If AllTrim(SC6->C6_BLQ) <> "R"
				lRet := MAResDoFat()
				SC6->(dbGoTo(SC6TMP->SC6RECNO))
			EndIf
			
			If !lRet
				Help("",1,"LIMPRES",,STR0052 +SC6->C6_NUM +"/" +SC6->C6_ITEM,1,1) //"Erro ao eliminar o resํduo do pedido de venda : "
				aAdd(aRet,{.F.,''})
				DisarmTransaction()
				lRet := .F.
			Else
				aAdd(aRet,{lRet,SC6->C6_PRODUTO,SC6->(C6_QTDVEN - C6_QTDENT)})

				SC5->(dbSetOrder(1))
				SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM))
				RecLock("SC5",.F.)
				SC5->C5_RESREM := "S"
				SC5->(MsUnLock())
			EndIf
			
			SC6TMP->(dbSkip())
		End
		
		End Transaction
		
		SC6TMP->(DbCloseArea())
		
	Case cTipo == 'C' //-- Contrato
	
		cQuery := "SELECT CN9.R_E_C_N_O_ CN9RECNO, CNB.R_E_C_N_O_ CNBRECNO"
		cQuery += "FROM " +RetSqlName("CN9") +" CN9 "
		cQuery += "JOIN " +RetSqlName("CNB") +" CNB ON CNB.D_E_L_E_T_ <> '*' AND "
		If CNB->(FieldPos("CNB_FILORI")) == 0
			cQuery += "	CNB.CNB_FILIAL = '" +xFilial('CNB') +"' AND "
		Else
			cQuery += "	CNB.CNB_FILORI = '" +xFilial('CNB') +"' AND "
		EndIf
		cQuery += "	CNB.CNB_CONTRA = CN9.CN9_NUMERO AND "
		cQuery += "	CNB.CNB_REVISA = CN9.CN9_REVATU AND "
		cQuery += "	CNB.CNB_SLDREC > 0 "
		cQuery += "WHERE CN9.D_E_L_E_T_ <> '*' AND "
		If CN9->(FieldPos("CN9_FILORI")) == 0
			cQuery += "	CN9.CN9_FILIAL = '" +xFilial('CN9') +"' AND "
		Else
			cQuery += "	CN9.CN9_FILORI = '" +xFilial('CN9') +"' AND "
		EndIf
		cQuery += "	CN9.CN9_NUMERO = CNB.CNB_CONTRA AND "
		cQuery += " CN9.CN9_REVATU = CNB.CNB_REVISA AND "
		cQuery += "	CN9.CN9_CODED = '" +CO1->CO1_CODEDT +"' AND "
		cQuery += "	CN9.CN9_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "	CN9_RESREM <> 'S'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CN9TMP")

		Begin Transaction
								
		While lRet .And. !CN9TMP->(EOF())

			CNB->(dbGoTo(CN9TMP->CNBRECNO))

			dbSelectArea("CN9")
			dbGoTo(CN9TMP->CN9RECNO)
			cSitAnt := CN9->CN9_SITUAC

			//-- o vetor adados contem os dados do ganhador durante o processo remanescente (edital, processo, produto e fornecedor)
			//-- somente o contrato com o fornecedor substituido no processo remanescente sera cancelado. 
			lCancelCN9 := .F.
			If	!Empty(aDados) .And. CNB->CNB_CONTRA+CNB->CNB_REVISA == CN9->CN9_NUMERO+CN9->CN9_REVATU .And.;
				Ascan(aDados,{|x| x[6] + x[7] + x[3] == CN9->CN9_CODED + CN9->CN9_NUMPR + CNB->CNB_PRODUT }) > 0
				lCancelCN9 := .T.  //-- Cancela somente o contrato com o fornecedor substituido no processo remanescente
			EndIf
			//-- Verifica se e originado de compra centralizada,
			//-- Se sim troca filial para execucao das eliminacoes
			If CN9->CN9_FILIAL # xFilial("CN9")
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+AllTrim(CN9->CN9_FILIAL)))
				cFilAnt := FWCodFil()
			EndIf			
			If CN9->CN9_SITUAC == "09"
				Help("",1,"LIMPRES",,STR0062+CN9->CN9_NUMERO +STR0093,1,1)	//"O contrato "###" estแ em processo de revisใo. Exclua ou aprove a revisใo para que o remanescente possa ser processado."
				aAdd(aRet,{.F.,''})
				lRet := .F.
			ElseIf CN9->CN9_SITUAC <> '01' .And. lCancelCN9 .And. !(lRet := CN100Cance(,,aRet))
				Help("",1,"LIMPRES",,STR0051 +AllTrim(CN9->CN9_NUMERO) +'/' +CN9->CN9_REVISA,1,1) //"Erro ao cancelar o contrato/revisใo : "
				aAdd(aRet,{.F.,''})
				lRet := .F.
			EndIf
			
			//-- se houver Pedido de Compra aret eh preenchido na funcao CN100Cance, caso contrario devera ser preenchido no if abaixo
			If	lRet .And. lCancelCN9 .And. Empty(aScan(aAux,{|x| x == CN9TMP->CNBRECNO}))
	
				CNB->(dbGoTo(CN9TMP->CNBRECNO))
				aAdd(aRet,{lRet,CNB->CNB_PRODUT,CNB->CNB_SLDREC,CNB->(CNB_NUMSC+CNB_ITEMSC),CN9TMP->CNBRECNO,cSitAnt,CN9TMP->CN9RECNO})
				aAdd(aAux,CN9TMP->CNBRECNO)
			EndIf

            SM0->(RestArea(aAreaSM0))
			cFilAnt := cFilBkp
			CN9TMP->(dbSkip())
		End
		
		If !lRet
			DisarmTransaction()
		EndIf
		
		End Transaction
							
		CN9TMP->(dbCloseArea())
		
	EndCase
Endif	

RestArea(aArea)
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGC02LjPartบAutor  ณMicrosiga           บ Data ณ  05/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ(Valida็ใo do campo when CO3_LOJA)                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GC02LjPart()
Local nPosTipo := 0
Local lRet := .T.

If Type("oGetPart") == "O"
	nPosTipo   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="CO3_TIPO"})
	
	If nPosTipo > 0
		lRet := oGetPart:aCols[oGetPart:nAt,nPosTipo] == '2' // Fornecedor ou cliente 
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVlGRVCP02 บAutor  ณMicrosiga           บ Data ณ  23/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsistencias qtdes no evento de manutencao do Edital       บฑฑ
ฑฑบ          ณExecutado apenas para o ponto de entrada          		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/           

Static Function VlGRVCP02(nOpc, nOpcA, aPartic,aComiss,aSolic,oDlg)
Local lGCP2VALD     := Existblock( 'GCP2VALD')                      
Local lGCP2TRAN     := Existblock( 'GCP2TRAN')
Local lRet := .T.
Local lOk    := .F.     
Local lOkTmp := .F.

      
If lGCP2VALD                     
    lOkTmp := Execblock( "GCP2VALD", .F., .F.,{nOpcA, nOpc})
    If ValType(lOkTmp) == "L"
    	lOk := lOkTmp
    EndIf            
                                                       
	Begin Transaction 

		GCPA02Grv(nOpc,oGetEdt:aCols,aPartic,aComiss,aSolic)         
	                                                               
		If lOk .And. lGCP2TRAN .And. nOpcA == OK .AND. nOpc != VISUALIZAR                            
			lOkTmp := Execblock( "GCP2TRAN", .F., .F.,	{ M->CO1_CODEDT, M->CO1_NUMPRO, oGetEdt:aCols, oGetEdt:aHeader  })
		    If ValType(lOkTmp) == "L"
		    	lOk := lOkTmp
		    EndIf 
			if !lOk
				DisarmTransaction()
				lRet := lOk
			EndIf
		EndIf

	End Transaction	
Else
	If nOpcA == OK .AND. nOpc != VISUALIZAR                            
		Begin Transaction 
			GCPA02Grv(nOpc,oGetEdt:aCols,aPartic,aComiss,aSolic) 
	 	End Transaction	
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02VldTpบAutor  ณ    Eduardo Dias    บ Data ณ  07/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que efetua a validacao do relacionamento            บฑฑ
ฑฑบ          ณ Modalidade x Tipo de Modalidade ( CO8 )                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DATAPREV                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02VldTp()
Local aArea   	:= GetArea()
Local aValTipo	:= Iif(IsInCallStack("GCPA02Scm"),Iif(mv_par03 == "002",aModXTipo2,aModXTipo),Iif(M->CO1_REGRA == "002",aModXTipo2,aModXTipo)) 
Local lRet    	:= .T.
local lSistemaS 	:= .F.
Local cModal  	:= If(IsInCallStack("GCPA02Scm"), mv_par01, M->CO1_MODALI)
Local cTpMod  	:= If(IsInCallStack("GCPA02Scm"), mv_par02, M->CO1_TIPO)   
Local cDescMo 	:= If(IsInCallStack("GCPA02Scm"), ' ', AllTrim(M->CO1_DESMOD))
Local cTextoH 	:= ""
Local nPosMod 	:= 0
Local nX 	  		:= 0

lRet := Empty(cTpMod) .Or. ExistCpo("SX5","LG"+cTpMod)
nPosMod := aScan(aValTipo,{|x| x[1] == cModal})

If lRet .And. nPosMod > 0 .And. Empty(aValTipo[nPosMod,2]) .And. !Empty(cTpMod)
	MsgInfo(STR0061) //-- A modalidade escolhida nใo adimite tipo de modalidade.
	M->CO1_TIPO := CriaVar("CO1_TIPO")
ElseIf lRet .And. nPosMod > 0 .And. !(cTpMod $ aValTipo[nPosMod,2])
	cTextoH := STR0059 +cModal +" - " + cDescMo //AllTrim(M->CO1_DESMOD) //-- O tipo de modalidade selecionado nใo ้ valido para a modalidade ###
	cTextoH += STR0060 //-- . Esta modalidade adimite os seguintes tipos de modalidade:
	For nX := 1 To Len(aValTipo[nPosMod,2])
		If !Empty(Substr(aValTipo[nPosMod,2],nX,2))
			cTextoH += CRLF +Substr(aValTipo[nPosMod,2],nX,2) +" - " +AllTrim(Tabela("LG",Substr(aValTipo[nPosMod,2],nX,2),.F.))
		EndIf
		nX += 2
	Next nX
	Aviso(STR0057,cTextoH,{"OK"},3)
	lRet := .F.         
EndIf 

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALMOD    บAutor  ณ    Eduardo Dias    บ Data ณ  07/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que efetua a validacao do relacionamento            บฑฑ
ฑฑบ          ณ Modalidade x Tipo de Modalidade ( CO8 )                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DATAPREV                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION VALMOD()
Local lRet    := .T.
Local cModal  := If(IsInCallStack("GCPA02Scm"), mv_par01, M->CO1_MODALI)
Local cTpMod  := If(IsInCallStack("GCPA02Scm"), mv_par02, M->CO1_TIPO)
Local nPosMod := 0
Local aModal  := {}     
Local aArea   := GetArea()  

aAdd(aModal,{"DL","AA*DE*DR*DV"})
aAdd(aModal,{"PG","PE*PP*MP"})  
aAdd(aModal,{"IN","DI"})     
aAdd(aModal,{"CV"," "})     
aAdd(aModal,{"CC"," "})     
aAdd(aModal,{"CS"," "})   
 
nPosMod := aScan(aModal,{|x| x[1] == cModal})

If nPosMod > 0 .And. aModal[nPosMod,1] $ "DL|PG|IN" .And. !(cTpMod $ aModal[nPosMod,2])// .Or. mv_par02 != Nil .And. mv_par02 != M->CO1_MODALI //edu 1204
	MsgInfo(STR0056) //"Nใo existe registro relacionado a este tipo de modalidade"
	lRet := .F.         
	Return(.F.)
ElseIf nPosMod > 0 .And. aModal[nPosMod,1] $ "CV|CC|CS" .And. !Vazio(cTpMod)
	MsgInfo(STR0056) //"Nใo existe registro relacionado a este tipo de modalidade"
	lRet := .F.         
	Return(.F.)
EndIf 

RestArea(aArea)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVLDMODTIP บAutor  ณEduardo Dias        บ Data ณ  01/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que efetua a validacao da Modalidadde X Tipo de     บฑฑ
ฑฑบ          ณ Modalidade ( CO1 )                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DATAPREV                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function VldModTip()
Local lRet  := .T.          

DbSelectArea('CO1')
 DbSetOrder(1) //CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO       
DBSEEK(xFilial("CO1")+M->(CO1_CODEDT+CO1_NUMPRO))
If M->CO1_MODALI == 'DL' .And. Empty(M->CO1_TIPO)
	lRet := .F.
	Help("",1,"GCP02TIPMOD") //"Solicita็๕es de compras invalidas "
EndIf  
	                
Return lRet             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  SomaCO2 บAutor  ณEduardo Dias        บ Data ณ  05/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que efetua a soma dos valores de todos os itens     บฑฑ
ฑฑบ          ณ edital, para obter o valor total do edital                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SomaCO2(cAcao,cCodEdt,cNumPr,cCodPro)          
Local aAreaAnt	:= GetArea()
Local nTotalCO2 := 0   
Local nX   		:= 0         
Default cAcao 	:= "1"

If	cAcao == "1"
	For nX := 1 to Len(oGetEdt:aCols)
		nTotalCO2 += GDFieldGet("CO2_VLESTI",nX,,oGetEdt:aHeader,oGetEdt:aCols) *;
					 GDFieldGet("CO2_QUANT",nX,,oGetEdt:aHeader,oGetEdt:aCols)
	Next nX
//-- Obtem a quantidade total do produto do edital (usado por GCPSldItem)
ElseIf cAcao=="2"

	BeginSQL Alias "SOMACO2"
			
	SELECT SUM(CO2.CO2_QUANT) nQuant
			
	FROM %table:CO2% CO2
			
	WHERE CO2.CO2_FILIAL = %xfilial:CO2%
		AND CO2.CO2_CODEDT = %exp:cCodEdt%
		AND CO2.CO2_NUMPRO = %exp:cNumPr%
		AND CO2.CO2_CODPRO = %exp:cCodPro%
		AND CO2.%NotDel%
			
	EndSql

	nTotalCO2 := SOMACO2->nQuant
	
	SOMACO2->(DbCloseArea())

EndIf	
RestArea(aAreaAnt)
Return nTotalCO2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCPA02LegV บAutor  ณ   Eduardo Dias    บ Data ณ  05/10/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda da rotina dos valores entre Modalidade x Valor     บฑฑ
ฑฑบ          ณ Total do Edital                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPA02LegV()
                           
CO0->(DbSetOrder(1))
If	CO0->(DbSeek(xFilial("CO0")+CO1->CO1_REGRA))
	FwExecView(STR0027,"GCPA017",MODEL_OPERATION_VIEW)
EndIf

Return                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValDiaSRP บAutor  ณEduardo Dias        บ Data ณ  05/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para validar quatidade de dia a ser considerado no  บฑฑ
ฑฑบ          ณ Sistema de Registro de Pre็o.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ValDiaSRP()          

Local lRet := .T.
              
If (M->CO1_MODALI == "PG") .Or.(M->CO1_MODALI == "CC" .And. M->CO1_TIPO $ "MP|TP")
	If (M->CO1_SRP == "S" .Or. M->CO1_SRP == "1") .And. M->CO1_QTDSRP == 0
		MsgAlert(STR0086) //-- ษ obrigatorio informar a quantidade de dias SRP quando um edital ้ do tipo SRP.
		lRet := .F.
	ElseIf (M->CO1_SRP == "S" .Or. M->CO1_SRP == "1") .And. M->CO1_QTDSRP > 365
		MsgAlert(STR0087) //-- O perํodo de um Sistema Registro de Pre็o nใo pode ser maior do que um ano.
		lRet := .F.                 
	ElseIf (M->CO1_SRP == "N" .Or. M->CO1_SRP == "2") .And. !Empty(M->CO1_QTDSRP)
		MsgAlert(STR0088) //-- O perํodo de um Sistema Registro de Pre็o nใo pode ser maior do que um ano.
		lRet := .F.
	EndIf
ElseIf	(M->CO1_SRP == "S" .Or. M->CO1_SRP == "1")
	MsgAlert(STR0091) //-- "A licita็ใo para registro de pre็os s๓ pode ser realizada na modalidade de concorr๊ncia ou pregใo, conforme termos das leis 8.666, de 21 de julho de 1993, e 10.520, de 17 de julho de 2002; excepcionalmente na modalidade de concorr๊ncia com tipo T้cnica e Pre็o (TP) a crit้rio do ๓rgใo gerenciador e mediante despacho devidamente fundamentado da autoridade mแxima do ๓rgใo ou entidade."
	lRet := .F.
EndIf

Return(lRet)     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02ComCeบAutor  ณ Rodrigo Toledo     บ Data ณ  12/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a interface de tela para compra centralizada.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GCP02ComCe(oLbx,cQuery,lWndManutEdit,aDados)
Local aArea	  := GetArea()
Local aHeadC1 := CriaHeader(Nil,Nil,Nil,"SC1")
Local aVetTst := {}
Local aVetor  := {}
Local nY	  := 0

If MaComCent()
	aDados := {}
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ARQTRB")
	
	TcFieldAll("ARQTRB")
	While ARQTRB->(!Eof())
		aVetor := {}		
		If FindFunction("ValidaCNI") .And. ValidaCNI()
			If lWndManutEdit
				If ExistBlock("GCP2HEAD")
			   		aVetTst := Execblock("GCP2HEAD",.F.,.F. ,{ARQTRB->C1_NUMPR,aVetor})
			   		If ValType(aVetTst) == "A"
			 			aVetor := aVetTst
			   		EndIf
				EndIf
			Else
				aAdd(aVetor,.F.)
			EndIf
		Else
			aAdd(aVetor,.F.)
		EndIf
		
		For nY := 1 To Len(aHeadC1)-2
			If !Empty(ARQTRB->(FieldGet(FieldPos(aHeadC1[nY,2]))))
				aAdd(aVetor,ARQTRB->(FieldGet(FieldPos(aHeadC1[nY,2]))))
			Else
				aAdd(aVetor,CriaVar(aHeadC1[nY,2]))
			EndIf
		Next nY
		aAdd(aDados,aVetor)
		ARQTRB->(dbSkip())
	End
	ARQTRB->(dbCloseArea())
	
	If ValType(oLbx) == "O"
		oLbx:SetArray(aDados)
		oLbx:bLine := GCAbLine(aDados)
		oLbx:Refresh()
	EndIf
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCP02Val บAutor  ณ   Eduardo Dias     บ Data ณ  11/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina Consulta Preco                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02Val(nLinha,nOpc)
Local cProd 	:= ""
Local i 		:= 0
Local nP_Item 	:= 0
Local nP_Prod 	:= 0
Local nX 		:= 0
Local nP_ForCli := 0
Local nP_Loj 	:= 0
Local nP_Nom	:= 0
Local nOpcX		:= 0
Local nCOLS		:= 0
Local nPos 		:= 1
Local cTitulo 	:= "Consultar de Pre็o"
Local nPosProd 	:= aScan(oGetEdt:aHeader,{|x| ALLTrim(x[2])=="CO2_CODPRO"}) 
Local nPosItem 	:= aScan(oGetEdt:aHeader,{|x| ALLTrim(x[2])=="CO2_ITEM"})
Local nVLESTI	:= GDFieldPos("CO2_VLESTI",oGetEdt:aHeader)
Local aArea 	:= GetArea()
Local aCols		:= {}   
Local aColsAux	:= {}   
Local aRadio	:= {}

Private nRadio	:= Nil
Private nPreco  := CriaVar("COC_VLRCON",.F.)

Static aAcols := {} // Guarda os dados do participantes adicionados

Default nLinha := oGetEdt:nAt
Default nOpc := INCLUIR
             
cProd := oGetEdt:acols[nLinha,nPosProd]  
cItem := oGetEdt:acols[nLinha,nPosItem]      

aCloneFor := aClone(aAcols)

If ( nPos := ASCAN(aAcols, {|x| x[1] == cItem} ) ) > 0
	Acols	:= aAcols[nPos,2]
	nPreco	:= aAcols[nPos,3] 
	nRadio	:= aAcols[nPos,4]    
EndIf	

If Empty(cProd)
	Help("",1,"GCP02PRODIN") //"Produto Invแlido"
	Return
Endif
   
cTitulo := cTitulo + "Item/Produto: " + cItem + " - " + cProd  //

aHeader	:= CriaHeader(nil,"COC_FILIAL/COC_CODEDT/COC_NUMPRO/COC_CODPRO/COC_ITEMED/COC_VLRCON",Nil,"COC")

nP_ForCli	:= aScan(aHeader,{|x| Trim(x[2])=="COC_CODIGO"})
nP_Loj  	:= aScan(aHeader,{|x| Trim(x[2])=="COC_LOJA"})
nP_Nom 		:= aScan(aHeader,{|x| Trim(x[2])=="COC_NOME"})

If Empty(aCols) .And. (nOpc == INCLUIR .Or. nOpc == GERAR .Or. nOpc == ALTERAR)
	dbSelectArea("COC")
	dbSetOrder(1)
	dbSeek(xFilial("COC")+M->(CO1_CODEDT+CO1_NUMPRO)+cItem)
	
	While COC->(!Eof()) .And. COC->(COC_FILIAL+COC_CODEDT+COC_NUMPRO+COC_ITEMED) == xFilial("COC")+M->(CO1_CODEDT+CO1_NUMPRO)+cItem
		aCols := CriaAcols(aHeader,"COC",1,xFilial("COC")+M->(CO1_CODEDT+CO1_NUMPRO)+cItem,nOpc,nil,Nil,"COC_FILIAL+COC_CODEDT+COC_NUMPRO+COC_ITEMED",.F.)
		COC->(dbSkip())
	EndDo	
	
ElseIf Empty(aCols)
	aHeader := aSize(aHeader, Len(aHeader))
	dbSelectArea("COC")
	dbSetOrder(1)
	dbSeek(xFilial("COC")+M->(CO1_CODEDT+CO1_NUMPRO)+cItem)
	
	While COC->(!Eof()) .And. COC->(COC_FILIAL+COC_CODEDT+COC_NUMPRO+COC_ITEMED) == xFilial("COC")+M->(CO1_CODEDT+CO1_NUMPRO)+cItem
		aAdd(aCols,Array(Len(aHeader)))
		nCOLS++
		For nX := 1 To Len(aHeader)
		
			If (aHeader[nX,10] <> "V") .And. FieldPos(aHeader[nX,2]) > 0
				aCols[nCOLS,nX] := COC->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aCols[nCOLS,nX] := CriaVar(aHeader[nX,2],.T.)
			Endif
		Next nX      
		
		aADD(aCols[nCOLS], .F.) 
		
		COC->(dbSkip())
	EndDo

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicao do objeto                                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nOpc == INCLUIR .Or. nOpc == GERAR .Or. nOpc == ALTERAR 
	nOpcX	:= GD_INSERT+GD_UPDATE+GD_DELETE // So sera permitido exclusao, caso nao tenha iniciado o andamento
Else
	nOpcX	:= 0
EndIf         

// Salva aCols antes da alteracao
aColsSav := aClone(aCols)           

DEFINE DIALOG oDlg TITLE "Consulta de pre็o" SIZE 750,500 

	//- Recupera coordenadas da area Inferior da linha e coluna a direita do container
	oSize := FWDefSize():New(.T.)
	oSize:AddObject("CABE",100,10,.T.,.T.)    
	oSize:AddObject("GETD",100,65,.T.,.T.)
	oSize:AddObject("RODA",100,25,.T.,.T.)
	oSize:SetWindowSize({0,0,oDlg:NHEIGHT,oDlg:NWIDTH})
	oSize:lProp 	:= .T.      
	oSize:aMargins := {6,6,6,6}
	oSize:Process()
	
	oPnCab := TPanel():Create(oDlg,oSize:GetDimension("CABE","LININI"),oSize:GetDimension("CABE","COLINI"),"",,,,,,oSize:GetDimension("CABE","XSIZE"),oSize:GetDimension("CABE","YSIZE"))
	oPnGet := TPanel():Create(oDlg,oSize:GetDimension("GETD","LININI"),oSize:GetDimension("GETD","COLINI"),"",,,,,,oSize:GetDimension("GETD","XSIZE"),oSize:GetDimension("GETD","YSIZE"))
	oPnRod := TPanel():Create(oDlg,oSize:GetDimension("RODA","LININI"),oSize:GetDimension("RODA","COLINI"),"M้todo de cแlculo:",,,,,,oSize:GetDimension("RODA","XSIZE"),oSize:GetDimension("RODA","YSIZE"))
           
	//- Recupera coordenadas da area Inferior da linha e coluna a direita do container
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject("GRID",100,100,.T.,.T.)    
	oSize1:SetWindowSize({0,0,oPnCab:NHEIGHT,oPnCab:NWIDTH})
	oSize1:lProp 	:= .T.      
	oSize1:aMargins := {4,4,4,4}
	oSize1:Process()      

	@ 05, 0 TO 22,362 OF oPnCab PIXEL
	@ 10,05 Say "Item/Produto: " + cItem + " - " + cProd of oPnCab PIXEL SIZE Len(cProd)*10, 29                                                           
	
	//- Recupera coordenadas da area Inferior da linha e coluna a direita do container
	oSize2 := FWDefSize():New(.T.)
	oSize2:AddObject("GRID",100,100,.T.,.T.)    
	oSize2:SetWindowSize({0,0,oPnGet:NHEIGHT,oPnGet:NWIDTH})
	oSize2:lProp 	:= .T.      
	oSize2:aMargins := {3,3,3,3}
	oSize2:Process()      
	
	oGetPart := MsNewGetDados():New(oSize2:AposObj[1,1],oSize2:AposObj[1,2]-3,oSize2:AposObj[1,3],oSize2:AposObj[1,4],nOpcX,"GCP02LCons","GCP02LCons","COC_CODEDT/COC_NUMPR/COC_PRODUT",,,999,,,,oPnGet,aHeader,aCols)

	aAdd( aRadio, "M้dia Geral" )             
	aAdd( aRadio, "M้dia Maior/Menor" ) 
	aAdd( aRadio, "Menor Pre็o" )    
	aAdd( aRadio, "Maior Pre็o" )
	aAdd( aRadio, "Pre็o Intermediแrio" )	

	@ 00, 60 RADIO oRadio VAR nRadio ITEMS aRadio[1],aRadio[2],aRadio[3],aRadio[4],aRadio[5] SIZE 100,20 ; 	
	PIXEL OF oPnRod ON CHANGE (MetodoPreco(oGetPart:Acols),oPreco:Refresh())
	
	@ 22,200 SAY "Pre็o estimado: " Of oPnRod PIXEL                                                          	                                                
	@ 20,260 MSGET oPreco Var nPreco PICTURE PesqPict("CO2","CO2_VLESTI") SIZE 80,10 OF oPnRod PIXEL	

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(GCP02LCons(nLinha,.T.),oDlg:End(),)},{||oDlg:End()},,)

// Retira os registros deletados do acols	
For nX := 1 To Len(oGetPart:Acols)
	If !aTail(oGetPart:Acols[nx])
		aAdd(aColsAux, oGetPart:Acols[nX])
     EndIf
Next
aCols := aColsAux

//Monta o aAcols
If nOpc != VISUALIZAR 
	If (nPos := ASCAN(aAcols, {|x| x[1] == cItem})) == 0
		aAdd(aAcols, {cItem, aClone(oGetPart:aCols), nPreco, nRadio, cProd})
	Else	
		aAcols[nPos] := {cItem, aClone(oGetPart:aCols), nPreco, nRadio, cProd}	
	EndIf
	
	oGetEdt:aCols[oGetEdt:oBrowse:nAt,nVLESTI] := nPreco
Endif

RestArea(aArea)
Return 
                                                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMetodoPrecoบAutor  ณ   Eduardo Dias     บ Data ณ  04/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle das opcoes para calculo do Consulta Preco          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MetodoPreco(aCols)
Local aColsBkp 	:= aClone(aCols)
Local AcolsAux	:= {}
Local nX		:= 0
Local nY		:= 0 
Local nQuant	:= 0	
Local nSoma		:= 0
Local nPos	    := 0     
Local nMenor	:= 0
Local nMaior	:= 0
Local nInterm	:= 0

For nX := 1 To Len(aCols)
	If !aTail(Acols[nX]) 
		AADD(AcolsAux, aCols[nX])	
	EndIf
Next

If Len(AcolsAux) > 0       
	Do Case
	Case nRadio==1 //Media Geral 
		For nY :=1 To Len (AcolsAux)     
			nSoma := nSoma+AcolsAux[nY,4]
		Next  
		nQuant	:= Len(AcolsAux)
		nPreco	:= nSoma/nQuant
	Case nRadio==2 //Media Menor/Maior
		AcolsAux	:= ASort(AcolsAux,,,{|x,y|  x[4] < y[4] })
		nMenor		:= AcolsAux[1,4]
		nPos		:= Len(AcolsAux)
		nMaior		:= AcolsAux[nPos,4]
		nPreco		:= (nMenor+nMaior)/2		
	Case nRadio==3 //Menor
		AcolsAux	:= ASort(AcolsAux,,,{|x,y|  x[4] < y[4] })
		nPreco		:= AcolsAux[1,4]			 
	Case nRadio==4 //Maior
		AcolsAux	:= ASort(AcolsAux,,,{|x,y|  x[4] < y[4] })
		nPos		:= Len(AcolsAux)
		nPreco		:= AcolsAux[nPos,4]	
	Case nRadio==5 //Intermediแrio
		AcolsAux	:= ASort(AcolsAux,,,{|x,y|  x[4] < y[4] })
		nPos		:= Len(AcolsAux)     
		nInterm		:= round(nPos/2,0)
		nPreco		:= AcolsAux[nInterm,4]		
	EndCase
EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  GCPFor2 บAutor  ณ   Eduardo Dias     บ Data ณ  09/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do fornecedor								      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPFor2()
  
Local lRet     := .T.
Local i        := 0
Local nT_aCOLS := Len(oGetPart:aCOLS)
Local nItem    := oGetPart:oBrowse:nAt
Local nP_For   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="COC_CODIGO"})
Local nP_Loj   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="COC_LOJA"})
Local nP_Nom   := aScan(oGetPart:aHeader,{|x| Trim(x[2])=="COC_NOME"})
Local cForn    := ''
Local cLoj	   := ''

cForn	:= SA2->A2_COD
cLoj	:= SA2->A2_LOJA

If 'COC_LOJA' $ ReadVar()
	cLoj:= &(ReadVar())
Else                     
	If 'COC_CODIGO' $ ReadVar()	
		cForn:= &(ReadVar())
	EndIf
EndIf

//-- simula gatilho para preencher loja do participante e descricao
If !Empty(cLoj)
	oGetPart:aCOLS[n,nP_Loj] := Posicione("SA2",1,xFilial("SA2")+cForn+cLoj,"A2_LOJA")
	oGetPart:aCOLS[n,nP_Nom] := Posicione("SA2",1,xFilial("SA2")+cForn+cLoj,"A2_NOME")
	If SA2->(Eof())
		Help("",1,"GCP02FORC") //"Fornecedor nใo cadastrado"
		lRet := .F.
	Endif
	If SA2->A2_MSBLQL == '1' // Bloqueado SIM
		Help("",1,"GCP02FORB") //"Fornecedor bloqueado"
		lRet := .F.
	EndIf
Else
	Posicione("SA2",1,xFilial("SA2")+cForn,"A2_COD")
	If SA2->(Eof())                                                            
		Help("",1,"GCP02FORC") //"Fornecedor nใo cadastrado"
		lRet := .F.
	Endif
EndIf

For i:=1 To nT_aCOLS
	If i <> nItem
		If oGetPart:aCOLS[i,nP_For] == cForn .And. oGetPart:aCOLS[i,nP_Loj] == cLoj .And. !oGetPart:aCOLS[i,len(aCols[i])]
			Help("",1,"GCP02FDUP") //"Jแ existe este c๓digo de fornecedor/cliente para o produto"
			lRet := .F.
		Endif
	Endif
Next i      


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGCP02LConsบAutor  ณ   Eduardo Dias     บ Data ณ  04/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da linha da grid. Obrigatorio informar o valor    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA002                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCP02LCons(nLinha,lTudoOK)
Local lRet 		:= .T.
Local aCols		:= oGetPart:aCols
Local aHeader	:= oGetPart:aHeader
Local nPosVlU	:= aScan(aHeader,{|x| AllTrim(x[2]) == "COC_PRECO"})
Local nPosProd 	:= aScan(oGetEdt:aHeader,{|x| ALLTrim(x[2]) == "CO2_CODPRO"}) 

Default nLinha 	:= oGetPart:nAt 
Default lTudoOK := .F.

Static aAcols := {} // Guarda os dados do participantes adicionados

//If Valtype(nLinha) != "N"
	nLinha := oGetPart:nAt
//EndIf

If aCols[nLinha,len(aCols[nLinha])] <> .T. 
	If lRet .And. aCols[nLinha,nPosVlU] == 0 .Or. Empty(aCols[nLinha,nPosProd]) .Or. Iif(lTudoOK,nPreco <= 0,.F.)
		Help("",1,"GCP02NOVL") //"Pre็o unitแrio licitado e dados do participante sใo de preenchimento obrigat๓rio" 
		lRet := .F. 
	Endif
EndIf

If lRet
	MetodoPreco(@aCols)
	oPreco:Refresh()
EndIf

Return lRet                  

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณGCPViewCO3ณ Autor ณ Alex Egydio           ณ Data ณ20.02.2013ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Monta acols/aheader de participantes                       ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/
Function GCPViewCO3(cAcao,cAval,cCodEdt,cNumPro,cCodPro,cLte,aHeader,aCols)
Local aAreaAnt	:= GetArea()
Local aSldItem	:= {}
Local cAliasCO3 := GetNextAlias()
Local cNome		:= ""
Local nSeek		:= 0
Local nSeek1	:= 0
Local nP_ForCli	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_CODIGO"})
Local nP_Loj  	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_LOJA"})
Local nP_Nom	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_NOME"})
Local nP_VlUn	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_VLUNIT"})
Local nP_Revo	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_REVOGA"})
Local nP_Rank	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_RANK"})
Local nP_Lance	:= aScan(aHeader,{|x| AllTrim(x[2])=="CO3_LANCE"})
Local nQuant	:= 0


If	cAval == "1"										//-- por item

	BeginSQL Alias cAliasCO3
						
	SELECT CO3.R_E_C_N_O_ RecCO3
							
	FROM %table:CO3% CO3
							
	WHERE CO3.CO3_FILIAL = %xfilial:CO3%
		AND CO3.CO3_CODEDT = %exp:cCodEdt%
		AND CO3.CO3_NUMPRO = %exp:cNumPro%
		AND CO3.CO3_CODPRO = %exp:cCodPro%
		AND CO3.%NotDel%
	ORDER BY %Order:CO3%
								
	EndSql
	
ElseIf cAval == "2"										//-- por lote

	BeginSQL Alias cAliasCO3
						
	SELECT CO3.R_E_C_N_O_ RecCO3
							
	FROM %table:CO3% CO3
							
	WHERE CO3.CO3_FILIAL = %xfilial:CO3%
		AND CO3.CO3_CODEDT = %exp:cCodEdt%
		AND CO3.CO3_NUMPRO = %exp:cNumPro%
		AND CO3.CO3_LOTE = %exp:cLte%
		AND CO3.%NotDel%
	ORDER BY %Order:CO3%
								
	EndSql
	
ElseIf	cAval == "3"									//-- por edital

	BeginSQL Alias cAliasCO3
						
	SELECT CO3.R_E_C_N_O_ RecCO3
							
	FROM %table:CO3% CO3
							
	WHERE CO3.CO3_FILIAL = %xfilial:CO3%
		AND CO3.CO3_CODEDT = %exp:cCodEdt%
		AND CO3.CO3_NUMPRO = %exp:cNumPro%
		AND CO3.%NotDel%
	ORDER BY %Order:CO3%
								
	EndSql

EndIf

While (cAliasCO3)->(!Eof())
	CO3->(DbGoTo((cAliasCO3)->RecCO3))

	If	(nSeek:=AScan(aCols,{|x| x[nP_ForCli]+x[nP_Loj]==CO3->CO3_CODIGO+CO3->CO3_LOJA}))==0

		If	CO3->CO3_TIPO=="1"
			cNome := Posicione("CO6",1,xFilial("CO6")+CO3->CO3_CODIGO+CO3->CO3_LOJA,"CO6_NOME")
			//cTipo := cTxtPFor
		Else
			If	CO1->CO1_MODALI == "LL"
				cNome := Posicione("SA1",1,xFilial("SA1")+CO3->CO3_CODIGO+CO3->CO3_LOJA,"A1_NOME")				
			Else
				cNome := Posicione("SA2",1,xFilial("SA2")+CO3->CO3_CODIGO+CO3->CO3_LOJA,"A2_NOME")
			EndIf
			//cTipo := cTxtFor
		EndIf
		aAdd(aCols,Array(Len(aHeader)+1))
		nSeek := Len(aCols)

		For nSeek1 := 1 To Len(aHeader)-2
			If	aHeader[nSeek1,10]<>"V" .And. CO3->(FieldPos(aHeader[nSeek1,2]))>0
				aCols[nSeek,nSeek1]:=CO3->(FieldGet(FieldPos(aHeader[nSeek1,2])))
			Else
				aCols[nSeek,nSeek1]:=CriaVar(aHeader[nSeek1,2],.T.)
			EndIf
		Next
		aCols[nSeek,nP_Nom]:=cNome
		If	(cAval=="2" .Or. cAval=="3") .And. CO3->CO3_REVOGA<>"1" .And. (CO3->CO3_CLASS=="1" .Or. CO3->CO3_CLAANT=="1")
			CO2->(DbSetOrder(1))
			CO2->(DbSeek(xFilial("CO2")+M->CO1_CODEDT+M->CO1_NUMPRO+CO3->CO3_CODPRO))

			nQuant:=CO2->CO2_QUANT
			aSldItem := {M->CO1_CODEDT,M->CO1_NUMPRO,CO3->CO3_CODPRO}
			GCPSldItem("3",aSldItem)
			//-- Se nao efetuou a entrega total, abate a quantidade ja entregue (CO2_QUANT - C7_QUJE)
			//-- Se efetuou a entrega total devera permanecer com a quantidade original CO2_QUANT
			If	aSldItem[1]<nQuant
				nQuant -= aSldItem[1]
			EndIf		
			aCols[nSeek,nP_VlUn]:=nQuant*CO3->CO3_VLUNIT

		Else
			aCols[nSeek,nP_VlUn]:=CO3->CO3_VLUNIT
		EndIf
		If	CO3->CO3_REVOGA=="1"
			aCols[nSeek,nP_Revo]:=CO3->CO3_REVOGA
		EndIf
		aCols[nSeek,Len(aHeader)+1] := .F.

	Else
		If	(cAval=="2" .Or. cAval=="3") .And. CO3->CO3_REVOGA<>"1" .And. (CO3->CO3_CLASS=="1" .Or. CO3->CO3_CLAANT=="1")
			CO2->(DbSetOrder(1))
			CO2->(DbSeek(xFilial("CO2")+M->CO1_CODEDT+M->CO1_NUMPRO+CO3->CO3_CODPRO))

			nQuant:=CO2->CO2_QUANT
			aSldItem := {M->CO1_CODEDT,M->CO1_NUMPRO,CO3->CO3_CODPRO}
			GCPSldItem("3",aSldItem)
			//-- Se nao efetuou a entrega total, abate a quantidade ja entregue (CO2_QUANT - C7_QUJE)
			//-- Se efetuou a entrega total devera permanecer com a quantidade original CO2_QUANT
			If	aSldItem[1]<nQuant
				nQuant -= aSldItem[1]
			EndIf		
			aCols[nSeek,nP_VlUn]+=nQuant*CO3->CO3_VLUNIT
		EndIf
		If	CO3->CO3_REVOGA=="1"
			aCols[nSeek,nP_Revo]:=CO3->CO3_REVOGA
		EndIf
	EndIf

	(cAliasCO3)->(DbSkip())
EndDo
(cAliasCO3)->(DbCloseArea())

If	!Empty(aCols)
	ASort(aCols,,,{|x,y|x[nP_Rank] < y[nP_Rank]})
EndIf
RestArea(aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AjustaSX5ณ Autor ณ Jose Delmondes  		ณ Data ณ26/06/2013ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Altera descricao da legenda             					    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ GCPA002               	                         			ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/

Static Function AjustaSX5()

Local aArea:= GetArea()

dbSelectArea("SX5")

If dbSeek(xFilial()+"LE"+"PR")   
	RecLock("SX5",.F.)
		X5_DESCRI  := "Processo Revogado"
		X5_DESCSPA := "Proceso Revocado"
		X5_DESCENG := "Process Denied"
	MsUnlock()
EndIf
	
If dbSeek(xFilial()+"LE"+"PE")   
	RecLock("SX5",.F.)
		X5_DESCRI  := "Processo Encerrado"
		X5_DESCSPA := "Proceso Finalizado"
		X5_DESCENG := "Process Closed"
	MsUnlock()
EndIf	
	
If !dbSeek(xFilial()+"LE"+"AP")
	RecLock("SX5",.T.)
		X5_TABELA  := "LE"
		X5_CHAVE   := "AP"
		X5_DESCRI  := "Ata de Sistema Registro de Pre็o"
		X5_DESCSPA := "Acta de Sistema Registro de Precio"
		X5_DESCENG := "Register of Price Record"
	MsUnlock()	
EndIf

If !dbSeek(xFilial()+"LG"+"MP")
	RecLock("SX5",.T.)
		X5_FILIAL	:= xFilial() 
		X5_TABELA  := "LG"
		X5_CHAVE   := "MP"
		X5_DESCRI  := "Menor Pre็o"
		X5_DESCSPA := "Precio mแs Bajo"
		X5_DESCENG := "Lowest Price"
	MsUnlock()	
EndIf

If !dbSeek(xFilial()+"LG"+"TP")
	RecLock("SX5",.T.)
		X5_FILIAL	:= xFilial() 
		X5_TABELA  := "LG"
		X5_CHAVE   := "TP"
		X5_DESCRI  := "T้cnica e Pre็o"
		X5_DESCSPA := "Tecnica y Precio"
		X5_DESCENG := "Technique and Price"
	MsUnlock()	
EndIf			
		
		
If dbSeek(xFilial()+"LG"+"PR")
	RecLock("SX5",.F.)
		X5_CHAVE   := "PP"
		X5_DESCRI  := "Pregao Presencial"
	MsUnlock()	
EndIf	
RestArea(aArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} GCP02VldRev
Validacoes na revogacao do item do edital

@author Alex Egydio
@since 05/07/2013
@version P11.80
*/
//-------------------------------------------------------------------
Function GCP02VldRev()
Local cLote:= ""
Local lRet := .T.
Local nSeek:= 0
Local nPRev:= IIF(Type("oGetEdt") <> "U",GDFieldPos("CO2_FRACAS",oGetEdt:aHeader),0) 
Local nPLot:= IIF(Type("oGetEdt") <> "U",GDFieldPos("CO2_LOTE",oGetEdt:aHeader),0)

lRet := Pertence("SN")

If	lRet .And. (nPRev <> 0 .And. nPLot <> 0)

	If	M->CO1_AVAL$"23"

		cLote := GDFieldGet("CO2_LOTE",oGetEdt:nAt,,oGetEdt:aHeader,oGetEdt:aCols)

		For nSeek := 1 To Len(oGetEdt:aCols)
			If	oGetEdt:aCols[nSeek,nPLot]==cLote
				oGetEdt:aCols[nSeek,nPRev] := M->CO2_FRACAS
			EndIf
		Next

		oGetEdt:Refresh()

	EndIf

EndIf

Return(lRet)
//-------------------------------------------------------------------
/*{Protheus.doc} GCP02Rpl
Validacoes na revogacao do item do edital

@author Alex Egydio
@since 05/07/2013
@version P11.80
*/
//-------------------------------------------------------------------
Function GCP02Rpl(nLinha,cLte,cObsRev,nPosLote,nPosObs)
Local n1Cnt := 0
//-- necessario para replicar a justificativa para todos as linhas com o mesmo lote
For n1Cnt := 1 To Len(oGetEdt:aCols)
	If	cLte == oGetEdt:aCols[n1Cnt,nPosLote]
		oGetEdt:aCols[n1Cnt,nPosObs] := cObsRev
	EndIf
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAjustaHelp    ณ Autor ณAntenor Silva         ณ Data ณ02.04.2014ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณAjusta os helps                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณAjustaHelp()                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Static Function AjustaHelp()
Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}   

//
aHelpPor :=	{"O edital nใo pode ser encerrado."}
aHelpSpa :=	{"Lo edicto no se puede terminar."}
aHelpEng :=	{"The licitation issuance can not be terminated."}
PutHelp("PGCP02NOENC",aHelpPor,aHelpEng,aHelpSpa,.F.)  

aHelpPor :=	{"Encerre um edital em aberto."}
aHelpSpa :=	{"Apague un edicto abierto."}
aHelpEng :=	{"Finish an edict open."}
PutHelp("SGCP02NOENC",aHelpPor,aHelpEng,aHelpSpa,.F.) 

//
aHelpPor :=	{"Para a modalidade 'Leilใo (LL)' nใo ้ ", "possํvel carregar solicita็ใo de compras."}
aHelpSpa :=	{"Para la modalidad 'subasta (LL)' ", "imposible cargar solicitud de compras."}
aHelpEng :=	{"For the modality 'Auction (LL)' ", "can not load purchases request."}
PutHelp("PGCPA02MDLL",aHelpPor,aHelpEng,aHelpSpa,.F.)  

aHelpPor :=	{"Para incluir edital utilizando a ", "modalidade Leilใo (LL) fa็a pelo ","procedimento padrใo clicando em Incluir."}
aHelpSpa :=	{"Para incluir un aviso p๚blico ", "mediante el modo Subasta (LL) que el", "procedimiento estแndar haciendo clic en Agregar."}
aHelpEng :=	{"To include public notice using the ", "Auction mode (LL) make the standard procedure ","by clicking Add."}
PutHelp("SGCPA02MDLL",aHelpPor,aHelpEng,aHelpSpa,.F.) 

aHelpPor :=	{"Somente edital em aberto poderแ ser", "revogado."}
aHelpSpa :=	{"Solo podra revocarse edicto abierto"}
aHelpEng :=	{"You can only revoke an open public", "notice."}
PutHelp("PGCP02NOREV",aHelpPor,aHelpEng,aHelpSpa,.F.) 

aHelpPor :=	{"Edital nใo revogado."}
aHelpSpa :=	{"Edicto no derogado."}
aHelpEng :=	{"Public notice not revoked."}
PutHelp("PGCP02REV",aHelpPor,aHelpEng,aHelpSpa,.F.)

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA02Rev
Revoga Edital

@author Jose Delmondes
@since 26/06/2014
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCPA02Rev()
Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()
Local lOk     := .T.
Local cCO7Acao:= ""
Local cMotivo := Space(200)
Local cFilSC1 := xFilial("SC1")
Local aGrvCO1 := {}
Local aGrvCO7 := {}
Local aRet    := {}
Local aParam  := {}
LocaL aArea	:= GetArea()

//-- Nao permite a revogacao de edital ja encerrado ou em fase de elaboracao.
If CO1->CO1_ETAPA $ "PE,PC,FV,CO,PM,PR,CE"
	Help("",1,"GCP02NOREV") //"Somente edital em aberto poderแ ser revogado."
	lOk  := .F.
Endif


If lOk .And. (lOk := MsgYesNo(STR0135+	Alltrim(CO1->CO1_CODEDT)+"?",cCadastro))
		
	//-- array com o retorno do parambox
	AAdd(aRet,cMotivo)   // motivo da revoga็ใo
	
	//-- array com a configuracao do parambox
	AAdd(aParam,{1,STR0136,aRet[1],"@!","","","",125,.T.}) //"Motivo da revogacao"
		
	//-- chamada da funcao parambox()
	lOk := ParamBox(aParam,STR0014,@aRet,,,.T.,80,3) //"Motivo"
		
	If lOk .And. !Empty(aRet[1])
			
		Begin Transaction
			
		cMotivo := aRet[1]
			
		cCO7Acao := STR0016 + CO1->CO1_PASSO + chr(13)+chr(10)				//"Passo: "
		cCO7Acao += STR0137 + chr(13)+chr(10)									//"Revogacao do Edital"
		cCO7Acao += STR0018 + chr(13)+chr(10) + cMotivo + chr(13)+chr(10)	//"Motivo: "
			
		aGrvCO1 := {	{"CO1_ETAPA" , "PR"      }}  // processo revogado
			
		aGrvCO7 :=	{	{"CO7_CODEDT", CO1->CO1_CODEDT},;
						{"CO7_NUMPRO", CO1->CO1_NUMPRO},;
						{"CO7_VERSAO", CO1->CO1_VERSAO},;
						{"CO7_DTMOV" , dDataBase},;
						{"CO7_HRMOV" , Time()},;
						{"CO7_CODUSU", Upper(Alltrim(Substr(cUsuario,7,15)))},;
						{"CO7_MOVATU", "PR"},;
						{"CO7_DESATU", STR0119},;
						{"CO7_ACAO"  , cCO7Acao },;
						{"CO7_PASATU", CO1->CO1_PASSO}}
		
		GCPA006(aGrvCO7, aGrvCO1)
		
		//limpa relacionameno com SCs
		dbSelectArea("SC1")
		dbSetOrder(8)
		While dbSeek(cFilSC1+CO1->CO1_CODEDT+CO1->CO1_NUMPRO)
			RecLock("SC1",.F.)
			SC1->C1_CODED		:= ''
			SC1->C1_NUMPR		:= ''
			SC1->C1_MODAL		:= ''
			SC1->C1_TPMOD		:= ''
			SC1->C1_COTACAO	:= ''
			SC1->(MsUnLock())      
				
			If lPrjCni
				RSTSCLOG("EDT",2,/*cUser*/)
			EndIf 
		EndDo
		
		End Transaction
		
	Else
		Help("",1,"GCP02REV") //"Edital nao revogado"
	Endif	
EndIf

RestArea(aArea)

Return
