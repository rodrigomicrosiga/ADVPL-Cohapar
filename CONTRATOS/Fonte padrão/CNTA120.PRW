#INCLUDE "CNTA120.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ApWizard.ch"

//Situacoes de contrato
#DEFINE DEF_SCANC "01" //Cancelado
#DEFINE DEF_SELAB "02" //Em Elaboracao
#DEFINE DEF_SEMIT "03" //Emitido
#DEFINE DEF_SAPRO "04" //Em Aprovacao
#DEFINE DEF_SVIGE "05" //Vigente
#DEFINE DEF_SPARA "06" //Paralisado
#DEFINE DEF_SSPAR "07" //Sol Fina.
#DEFINE DEF_SFINA "08" //Finalizado
#DEFINE DEF_SREVS "09" //Revisao
#DEFINE DEF_SREVD "10" //Revisado

//Transacoes
#DEFINE DEF_TRAINC "021"//Inclusao de Medicoes
#DEFINE DEF_TRAEDT "022"//Edicao de Medicoes
#DEFINE DEF_TRAEXC "023"//Exclusao de Medicoes
#DEFINE DEF_TRAENC "024"//Encerramento de Medicoes
#DEFINE DEF_TRAEST "025"//Estorno de Medicoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNTA120  ³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao de Medicoes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA120()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CNTA120(xAutoCab,xAutoItens,nOpcAuto,cRotina,xOrigem,xShow,xExcede)

Local aCores 	:=  {}
Local aIndexCND	:= {}
Local aCoresUsr := {}   
   				    
Local cRoda     := ""
Local cFiltro	:= ""
Local cCn120Fil := ""   

Local nx		:= 0
Local nLinPos	:= 0
Local nScan     := 0

Local xRet      := NIL
Local lFixo     := .T.

Default xOrigem	:= FUNNAME()
Default xShow   := .F.

Private bFiltraBrw	:= {|| Nil }
Private lAuto 		:= (valType(xAutoCab) == "A" .And. valType(xAutoItens) == "A")
Private aAutoCab	:= xAutoCab
Private aAutoItens	:= xAutoItens
Private aAutoExced  := xExcede
Private cCadastro 	:= STR0001//"Manutenção das Medições"

Private aRotina 	:= MenuDef()
Private cOrigem		:= Alltrim(xOrigem)      
Private lShow		:= xShow     
Private cFilCTR   := cFilAnt
//Desabilita na tela da medicao do contrato a tecla F4
SetKey( VK_F4, Nil )    
	 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta Dicionario SX1		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foi aplicado o update GCTUPD23³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")
dbSetOrder(1)
If (dbSeek(PadR("CND", Len(SX2->X2_CHAVE))) .And. SX2->X2_UNICO # "CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED") .Or.;
   (dbSeek(PadR("CNE", Len(SX2->X2_CHAVE))) .And. SX2->X2_UNICO # "CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMMED+CNE_ITEM"  )
	Final(OemtoAnsi(STR0072))  //"Aplicar o update GCTUPD23 !!!"
Endif       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro com CND_SERVIC vazio ³
//³se verdadeiro aplicar o update GCTUPD36			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
cn120Upd36()

If CND->(FieldPos("CND_ALCAPR")) == 0
	If (CND->(FieldPos("CND_AUTFRN")) == 0 .Or. CND->(FieldPos("CND_PEDIDO")) == 0) 
		If (CND->(FieldPos("CND_SERVIC")) > 0 )
			aCores :=  {	{ "Empty(CND->CND_DTFIM)", "BR_VERMELHO"	},;//"Medicao em aberto"	
	   		  		    { "!Empty(CND->CND_DTFIM)", "BR_VERDE"	   },;  //"Medicao Encerrada"
	   				    { "Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_AMARELO"  },;//"Med. Servic. Aberta"
	   				    {"!Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_VIOLETA"   } }//"Med. Servic. Encerrada"	  
		Else
			aCores :=  {	{ "Empty(CND->CND_DTFIM)", "BR_VERMELHO"	},;//"Medicao em aberto"	
	   		  		    { "!Empty(CND->CND_DTFIM)", "BR_VERDE"	   }}  //"Medicao Encerrada"

		EndIf
	 Else   
		If CND->(FieldPos("CND_SERVIC")) == 0 
			aCores :=  {	{ "Empty(CND->CND_DTFIM) .And. CND->CND_AUTFRN == '1'" , "BR_VERMELHO"	},;//"Medicao em aberto"	
	   					    { "!Empty(CND->CND_DTFIM) .And. CND->CND_AUTFRN == '1'", "BR_VERDE"	    },;  //"Medicao Encerrada"	 
	   					    { "Empty(CND->CND_DTFIM) .AND. Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'" , "BR_LARANJA"   },;//"Aut. Fornec. Sem Pedido"
	   					    { "Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'", "BR_AZUL"      },;//"Aut. Fornec. Aberta"
	   					    {"!Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'", "BR_CINZA"     } }//"Aut. Fornec. Encerrada"
		 Else 
 			aCores :=  {	{ "Empty(CND->CND_DTFIM)  .And. CND->CND_AUTFRN == '1' .And. CND->CND_SERVIC == '1'" , "BR_VERMELHO"  },;//"Medicao em aberto"	
	   					    { "!Empty(CND->CND_DTFIM) .And. CND->CND_AUTFRN == '1' .And. CND->CND_SERVIC == '1'" , "BR_VERDE"	  },;  //"Medicao Encerrada"	    					    
   						    { "Empty(CND->CND_DTFIM) .AND. Empty(CND->CND_PEDIDO)  .And. CND->CND_AUTFRN == '2'" , "BR_LARANJA"   },;//"Aut. Fornec. Sem Pedido"
	   					    { "Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'" , "BR_AZUL"      },;//"Aut. Fornec. Aberta"
	   					    {"!Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'" , "BR_CINZA"     },;//"Aut. Fornec. Encerrada"	       					    
	   					    { "Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_AMARELO"  },;//"Med. Servic. Aberta"
	   					    {"!Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_VIOLETA"   } }//"Med. Servic. Encerrada"      
		 EndIf
	 EndIF
Else
	If CND->(FieldPos("CND_AUTFRN")) == 0 .Or. CND->(FieldPos("CND_PEDIDO")) == 0
		If (CND->(FieldPos("CND_SERVIC")) > 0) 
			aCores :=  {	{ "Empty(CND->CND_DTFIM)", "BR_VERMELHO"	},;//"Medicao em aberto"	
	   		  		    { "!Empty(CND->CND_DTFIM)", "BR_VERDE"	   },;  //"Medicao Encerrada"
	   				    { "Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_AMARELO"  },;//"Med. Servic. Aberta"
	   				    {"!Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_VIOLETA"   } }//"Med. Servic. Encerrada"	  
		Else
			aCores :=  {	{ "Empty(CND->CND_DTFIM)", "BR_VERMELHO"	},;//"Medicao em aberto"	
	   		  		    { "!Empty(CND->CND_DTFIM)", "BR_VERDE"    }}  //"Medicao Encerrada"

		EndIf
	Else                                 
		If CND->(FieldPos("CND_SERVIC")) == 0 
			aCores :=  {	{ "Empty(CND->CND_DTFIM) .AND. CND->CND_ALCAPR = 'L' .And. CND->CND_AUTFRN == '1'", "BR_VERMELHO"	},;//"Medicao em aberto"
	  					    { "Empty(CND->CND_DTFIM) .AND. CND->CND_ALCAPR = 'B' .And. CND->CND_AUTFRN == '1'", "BR_PRETO"	    },;	//"Medicao Bloqueada"
	   					    { "!Empty(CND->CND_DTFIM) .And. CND->CND_AUTFRN == '1'", "BR_VERDE"	   },;	                            //"Medicao Encerrada"	
	   					    { "Empty(CND->CND_DTFIM) .AND. Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'" , "BR_LARANJA"   },;//"Aut. Fornec. Sem Pedido"
	   					    { "Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'", "BR_AZUL"      },;//"Aut. Fornec. Aberta"
	   				    	{"!Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'", "BR_CINZA"     }} //"Aut. Fornec. Encerrada"
	 	Else
			aCores :=  {	{ "Empty(CND->CND_DTFIM) .AND. CND->CND_ALCAPR = 'L'  .And. CND->CND_AUTFRN == '1'.And. CND->CND_SERVIC == '1'", "BR_VERMELHO"},; //"Medicao em aberto"
	  					    { "Empty(CND->CND_DTFIM) .AND. CND->CND_ALCAPR = 'B'  .And. CND->CND_AUTFRN == '1'" , "BR_PRETO"     },;//"Medicao Bloqueada"
	   					    { "!Empty(CND->CND_DTFIM).And. CND->CND_AUTFRN == '1' .And. CND->CND_SERVIC == '1'" , "BR_VERDE"	 },;//"Medicao Encerrada"	
	   					    { "Empty(CND->CND_DTFIM) .AND. Empty(CND->CND_PEDIDO) .And. CND->CND_AUTFRN == '2'" , "BR_LARANJA"   },;//"Aut. Fornec. Sem Pedido"
	   					    { "Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO).And. CND->CND_AUTFRN == '2'" , "BR_AZUL"      },;//"Aut. Fornec. Aberta"
	   				    	{"!Empty(CND->CND_DTFIM) .AND. !Empty(CND->CND_PEDIDO).And. CND->CND_AUTFRN == '2'" , "BR_CINZA"     },; //"Aut. Fornec. Encerrada"	 	
	   					    { "Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_AMARELO"   },;//"Med. Servic. Aberta"
	   					    {"!Empty(CND->CND_DTFIM) .AND. CND->CND_SERVIC == '2'" , "BR_VIOLETA"   } }//"Med. Servic. Encerrada"	 
	 	EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta Dicionarios  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN120AjSX6()
CN120AjSX7()
CN120AjSXB()
CN120AjSX3()
CN120AjHelp()

If !lAuto
	
	If ValType( cRotina ) == "C"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz tratamento para chamada por outra rotina             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( nScan := AScan( aRotina, { |x| Upper( x[2] ) == Upper( cRotina ) .And. x[4] == nOpcAuto } ) )
			cRoda := cRotina + "( 'CND', CND->( Recno() ), " + Str(nScan,2) + ")"
			xRet  := Eval( { || &( cRoda ) } )
		EndIf
	Else
		If ExistBlock("CN120FIL")
			cCn120Fil := ExecBlock("CN120FIL",.F.,.F.)
			If ( ValType(cCn120Fil) == "C" ) .And. !Empty(cCn120Fil)
				cFiltro := cCn120Fil
			EndIf
		EndIf
		If !Empty(cFiltro)
			bFiltraBrw := {|| FilBrowse("CND",@aIndexCND,@cFiltro) }
			Eval(bFiltraBrw)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para personalizar as cores X situacoes da legenda   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( ExistBlock("CN120COR") )			
			aCoresUsr := ExecBlock("CN120COR",.F.,.F.,{aCores})
			If ( ValType(aCoresUsr) == "A" )
				aCores := aClone(aCoresUsr)
			EndIf
		EndIf        

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ mv_par01 - Mostra Lancamentos   S/N                          ³
		//³ mv_par02 - Aglut Lancamentos    S/N                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetKey(VK_F12,{|| Pergunte("CNT120",.T.)})
		
		mBrowse(6,1,22,75,"CND",,,,,,aCores)    
		
		FWSetShowKeys(.T.)
		SetKey( VK_F12 , Nil )

		If ( Len(aIndexCND)>0 )
			EndFilBrw("CND",aIndexCND)
		EndIf
	EndIf
Else                                     
	CN1->(dbSetOrder(1))
	CN1->(dbSeek(xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO))
	lFixo  := (Empty(CN1->CN1_CTRFIX) .OR. (CN1->CN1_CTRFIX == "1"))
	If lFixo
		For nx:=1 to len(aAutoItens)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica campo LINPOS dos itens da rotina automatica ³
			//³pois a inclusao de medicao implica em alterar o acols³
			//³gerado com base na estrutura da planilha             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nLinPos:=aScan(aAutoItens[nx],{|x| AllTrim(x[1])=="LINPOS"}))>0
				aAutoItens[nx,nLinPos,3] := aAutoItens[nx,aScan(aAutoItens[nx],{|x| AllTrim(x[1])=="CNE_ITEM"}),2]
			Else
				aadd(aAutoItens[nx],{"LINPOS","CNE_ITEM",aAutoItens[nx,aScan(aAutoItens[nx],{|x| AllTrim(x[1])=="CNE_ITEM"}),2]})
			EndIf
		Next
	EndIf
	DEFAULT nOpcAuto := 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa rotina automatica               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CND")
EndIf

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Manut³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica situacao da medicao antes de alterar/excluir      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120Manut(cExp01,nExp02,nExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120Manut(cAlias,nReg,nOpc)
Local lContinua	:= .T.
Local aValidGet	:= {}
Local nPosNum		:= 0
Local nPosPln		:= 0
Local cChave		:= ""
Local lVer116		:= (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")

If CND->(FieldPos("CND_FILCTR")) > 0
	cFilCtr := CND->CND_FILCTR
Else
	cFilCtr := cFilAnt
EndIf

If lAuto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o numero da medicao foi fornecido      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPosNum:=aScan(aAutoCab,{|x| x[1]=="CND_NUMMED"})) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida numero da medicao                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aValidGet,{"cNumMed" ,aAutoCab[nPosNum,2],"CN120NumAuto(cNumMed,.F.)",.T.})
		
		If (lContinua := MsVldGAuto(aValidGet))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na medicao                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			dbSelectArea("CND")						
			If (nPosPln := aScan(aAutoCab,{|x| x[1]=="CND_NUMERO"})) > 0 
				CND->(dbSetOrder(1))
				CND->(dbSeek(xFilial("CND")+;
						aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_CONTRA"}),2]+;
						aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_REVISA"}),2]+;
						aAutoCab[nPosPln,2]+;
						aAutoCab[nPosNum,2]))
			Else 				
				CND->(dbSetOrder(4))
				CND->(dbSeek(xFilial("CND")+aAutoCab[nPosNum,2]))
			EndIf
			nReg := CND->(Recno())
		EndIf
	else
		lContinua:=.F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario tem permissao de delecao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5
	If lVer116
		aArea2 := GetArea()
		CNE->(dbSeek(xFilial("CNE")+CND->(CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED)))
		While !CNE->(Eof()) .And. lContinua .And. ;
			xFilial("CNE")+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED)==CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED) 
			lContinua := MaAvalPerm(1,{CNE->CNE_PRODUT,"CNT120",5})
			CNE->(dbSkip())
		End
		RestArea(aArea2)
		If !lContinua
			Help(,,1,'SEMPERM')
		EndIf
	EndIf
EndIf

dbSelectArea("CND")
dbSetOrder(1)
MsGoTo(nReg)

If lContinua
	lContinua := CN240VldUsr(CND->CND_CONTRA,If(aRotina[nOpc,4]==4,DEF_TRAEDT,DEF_TRAEXC),.T.,,cFilCtr)
EndIf

cChave := CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED
If LockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Adiciona valor previsao a estrutura da planilha    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(CND->CND_DTFIM)
			CN130Manut(cAlias,nReg,nOpc,,CND->CND_CONTRA,CND->CND_REVISA)
		Else
			Help( " ", 1, "CNTA120_03" )//"Medição ja encerrada"
		EndIf
	EndIf
Else      
	// Nao permite processamento concorrente
	Aviso(STR0068,OemtoAnsi(STR0069),{"Ok"},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
EndIf
UnLockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Leg    ³ Autor ³ Fabio Alves Silva     ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de legenda da Medicao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120Legenda(nExp01,nExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA120                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120Leg()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com as cores que representam a situacao de cada Medicao na mBrowse.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aLegenda := 		{	{"BR_VERMELHO", OemtoAnsi(STR0040)	},; // "Medicao em aberto"
							{"BR_PRETO"   , OemtoAnsi(STR0048)	},; // "Medicao bloqueada por Alçada"
							{"BR_VERDE"   , OemtoAnsi(STR0041)	}} // "Medicao encerrada"
Local aLegeUsr := {}

//Autorizacao de Fornecimento
If !Empty(CND->(FieldPos("CND_AUTFRN"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO")))
		aAdd(aLegenda,{"BR_AZUL"    , OemtoAnsi(STR0052)})  // "Autorização de Fornecimento Aberta"
		aAdd(aLegenda,{"BR_CINZA"   , OemtoAnsi(STR0053)})  // "Autorização de Fornecimento Encerrada"
		aAdd(aLegenda,{"BR_LARANJA"    , OemtoAnsi(STR0055)})  // "Autorização de Fornecimento Sem Pedido"
EndIf         

If !Empty(CND->(FieldPos("CND_SERVIC")))
		aAdd(aLegenda,{"BR_AMARELO"   , OemtoAnsi("Medição de Serviço Aberta")})  // "Medição de Serviço Aberta"
		aAdd(aLegenda,{"BR_VIOLETA"   , OemtoAnsi("Medição de Serviço  Encerrada")})  // "Medição de Serviço  Encerrada"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para personalizar as cores da legenda      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("CN120LEG") )
	aLegeUsr := ExecBlock("CN120LEG",.F.,.F.,{aLegenda})
	If ( ValType(aLegeUsr) == "A" )
		aLegenda := aClone(aLegeUsr)
	EndIf
EndIf

BrwLegenda(cCadastro, OemtoAnsi(STR0042), aLegenda)//"Legendas"

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Inc  ³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inclui Medicao - Exibe tela para selecao de contrato,      ³±±
±±³          ³ competencia e planilha                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CNTA120Inc(cExp01,nExp02,nExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120Inc(cAlias,nReg,nOpc,aVar,nTipo,nServico)

Local aValidGet   := {}
Local aRet        := {}
Local aTitle      := {}
Local aCampos	  := {}
Local aCn120ctaut := {} 

Local cArqCNA     := ""
Local cLine       := ""
Local cCn120Sxb   := ""
Local cConsSxb    := "CN9003"

Local oDlg	      := NIL
Local oGet01	  := NIL
Local oOk         := LoadBitmap( GetResources(), "LBTIK" )
Local oNo  		  := LoadBitmap( GetResources(), "LBNO" )

Local nOpca       := 0
Local nPos	      := 0  
Local nSaveSX8    := GetSX8Len()

Local lRet		  := .T.
Local lFisico     := .F.
Local lCn120ctaut := ExistBlock("CN120CTAUT")
Local lCn120Sxb   := ExistBlock("CN120SXB")
Local lCn120BOk   := ExistBlock("CN120BOK")

DEFAULT nTipo     := 1
DEFAULT nServico  := 1    

Private cNumMed   := ""
Private cPlan     := ""
Private cParcel   := ""
Private cContra   := Space(TamSX3("CN9_NUMERO")[1])
Private cRevisa   := Space(TamSX3("CN9_REVISA")[1])
Private cCompet   := Space(TamSX3("CNF_COMPET")[1])

Private oBrowse
Private oCbx

Private lMedeve := .F.//medicao Eventual
Private lFixo   := .T.//Contrato Fixo

cFilCtr := cFilAnt

If !lAuto
	//-- Monta variaveis da montagem do browse de planilhas
	CN120Plans(@cArqCNA,@aTitle,@aCampos,@cLine)

	If lCn120ctaut
		aCn120ctaut := ExecBlock("CN120CTAUT",.F.,.F.)
  		If ValType(aCn120ctaut) == "A"
  			cContra := aCn120ctaut[1]
	  		If !Empty(aCn120ctaut[2])
	  			cRevisa := aCn120ctaut[2]
	  		EndIf
	  		If !Empty(aCn120ctaut[3])
				cCompet := aCn120ctaut[3]
			EndIf
		EndIf
	EndIf	

	If lCn120Sxb
		cConsSxb := If(Valtype(cCn120Sxb:=ExecBlock("CN120SXB",.F.,.F.))=="C",cCn120Sxb,"CN9003")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Dialog para selecao de planilha               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCadastro := If(nTipo==1.And.nServico==1,STR0001,iIf(nTipo==2,STR0056,"Manutenção Das Medições/entregas da Medição de Serviços"))//"Manutenção Das Medições/entregas"#"Autorização de Fornecimento"
	
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From 74,7 TO 400,606 PIXEL
	
	@ 10,04   SAY OemToansi(RetTitle("CN9_NUMERO")) SIZE 73, 8 OF oDlg PIXEL
	@ 09,37   MSGET oGet01 VAR cContra PICTURE PesqPict("CN9","CN9_NUMERO") F3 cConsSxb SIZE 60,9 VALID CN120VlCon(nTipo) OF oDlg PIXEL
	
	@ 10,104  SAY OemToansi(RetTitle("CNF_COMPET")) SIZE 73, 8 OF oDlg PIXEL
	@ 09,137 ComboBox oCbx Var cCompet ON CHANGE CN120Compet() SIZE 50,9 OF oDlg PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Configura browse    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))
		oBrowse := TWBrowse():New( 30, 4,__DlgWidth(oDlg)-8,__DlgHeight(oDlg)-58, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBCNA", .T. )
		oBrowse:bLine := &( "{ || " + cLine + " }" )
		oBrowse:bLDblClick := {|| If(!Empty(TRBCNA->CNA_NUMERO),((cPlan:= TRBCNA->CNA_NUMERO,cParcel:=TRBCNA->CNF_PARCEL), oBrowse:Refresh()),) }
	Else		
		oBrowse := TWBrowse():New( 30, 4,__DlgWidth(oDlg)-8,__DlgHeight(oDlg)-58, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBCNA", .T. )	
		oBrowse:bLine := &( "{ || " + cLine + " }" )
		oBrowse:bLDblClick := {|| If(!Empty(TRBCNA->CNA_NUMERO),(cPlan := TRBCNA->CNA_NUMERO, oBrowse:Refresh()),) }
	EndIf
	
	DEFINE SBUTTON FROM 150, 240 When .T. TYPE 1 ACTION (If(CNTVldPlan(cContra,cRevisa,cPlan),(oDlg:End(),nOpca:=1),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 150, 270 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:=2) ENABLE OF oDlg
	
	If lCn120ctaut .and. ValType(aCn120ctaut) == "A"
		dbSelectArea("CN9")
		dbSetOrder(1)
		dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa)	
		CN120VlCon(nTipo)
		oBrowse:SetFocus()
	EndIf

	ACTIVATE MSDIALOG oDlg CENTERED
	
	// Ponto de Entrada após a confirmação da tela de seleção de Contrato e Planilha
	If lCn120BOk
		ExecBlock("CN120BOK",.F.,.F.,{cContra,cRevisa,cPlan,cParcel})
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo temporario                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBCNA->(dbCloseArea())
	FErase(cArqCNA + ".DBF")
	FErase(cArqCNA + OrdBagExt() )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cabecalho contem os campos CND_CONTRA,³
	//³CND_REVISA,CND_COMPET,CND_NUMERO essenciais para a  ³
	//³criacao da medicao                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos := aScan(aAutoCab,{|x| x[1]=="CND_CONTRA"})) > 0
		cContra := aAutoCab[nPos,2]
	Else
		lRet := .F.
	EndIf
	If lRet .And. ((nPos := aScan(aAutoCab,{|x| x[1]=="CND_REVISA"})) > 0)
		cRevisa := aAutoCab[nPos,2]
	Else
		lRet := .F.
	EndIf
	If lRet .And. ((nPos := aScan(aAutoCab,{|x| x[1]=="CND_COMPET"})) > 0)
		cCompet := aAutoCab[nPos,2]
	Else
		lRet := .F.
	EndIf
	If lRet .And. ((nPos := aScan(aAutoCab,{|x| x[1]=="CND_NUMERO"})) > 0)
		cPlan   := aAutoCab[nPos,2]
	Else
		lRet := .F.
	EndIf 
	
	If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))
		If lRet .And. ((nPos := aScan(aAutoCab,{|x| x[1]=="CND_PARCEL"})) > 0)
			cParcel := aAutoCab[nPos,2]
		Else
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida os campos do cabecalho da medicao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aValidGet,{"cContra" ,aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_CONTRA"}),2],"CheckSX3('CND_CONTRA',cContra)",.T.})
		AADD(aValidGet,{"cRevisa" ,aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_REVISA"}),2],"CheckSX3('CND_REVISA',cRevisa) .And. CN120CtrAuto(cContra,cRevisa)",.T.})
		AADD(aValidGet,{"cPlan"   ,aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_NUMERO"}),2],"CheckSX3('CND_NUMERO',cPlan)",.T.})
		If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))
		  	AADD(aValidGet,{"cParcel" ,aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_PARCEL"}),2],"CheckSX3('CND_PARCEL',cParcel)",.T.})
		EndIf
		AADD(aValidGet,{"cCompet" ,aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_COMPET"}),2],"CheckSX3('CND_COMPET',cCompet) .And. CN120VldCpt()",.T.})
		
		If (nPosNum := aScan(aAutoCab,{|x| x[1]=="CND_NUMMED"})) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida campo CND_NUMMED quando fornecido atraves    ³
			//³da rotina automatica                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumMed := aAutoCab[nPosNum,2]
			AADD(aValidGet,{"cNumMed" ,aAutoCab[nPosNum,2],"CN120NumAuto(cNumMed,.T.)",.T.})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³PE para permitir alterar a validacao da rotina automatica ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CN120AutVl")
			aRet := ExecBlock("CN120AutVl",.F.,.F.,{aValidGet})
			
			If valtype(aRet) == "A"
				aValidGet := aRet
			EndIf
		EndIf
		
		lRet := MsVldGAuto(aValidGet)
	EndIf
EndIf

dbSelectArea("CN9")
dbSetOrder(1)
dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o contrato possui cronograma fisico     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFisico := ((CN1->(FieldPos("CN1_CROFIS")) > 0) .And. Posicione("CN1",1,xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO,"CN1_CROFIS") == "1")
	
If nServico == 2 .And. (lFisico .Or. !lFixo .Or. lMedEve)
    Aviso("CNTA120",STR0089,{"ok"},2)
    nOpca:= 2
EndIf  
	
If nOpca == 1 .OR. (lAuto .And. lRet)
	
	//Rotina de manutencao de medicoes
	If CN130Manut(cAlias,nReg,nOpc,,cContra,cRevisa,cCompet,cPlan,lMedeve,lFisico,cParcel,nTipo,,nServico,@nSaveSX8)
		While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
		EvalTrigger()
		msUnlockAll()
	EndIf
Else
	While ( GetSX8Len() > nSaveSX8 )
		RollBackSX8()
	EndDo
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120NumAuto³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida numero da medicao na execucao da rotina automatica    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120NumAuto(cExp01,lExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Numero da Medicao                                   ³±±
±±³          ³ lExp02 - Indica se e inclusao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120NumAuto(cNumMed,lInc)
Local lRet
Local aArea := GetArea()

dbSelectArea("CND")
dbSetOrder(4)
dbSeek(xFilial("CND")+cNumMed)

lRet := If(lInc,!(Found()),Found())

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120CtrAuto³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida contrato+revisao durante a execucao da rotina         ³±±
±±³          ³ automatica                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120CtrAuto(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do Contrato                                  ³±±
±±³          ³ cExp02 - Codigo da revisao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120CtrAuto(cContra,cRevisa,lExcede)
Local lRet      := .T. 
Local lCN120CTU := .T.

Default lExcede := .F.

dbSelectArea("CN9")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no contrato                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa)

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a situacao do contrato                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := (CN9->CN9_SITUAC == DEF_SVIGE)
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o acesso do usuario                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := CN240VldUsr(cContra,DEF_TRAINC,.T.,,cFilCtr) 
		
		If lRet .And. lExcede 
			If CN9->(FieldPos("CN9_ESPCTR")) > 0 .And. CN9->CN9_ESPCTR == "1"
				Aviso("CNTA120",STR0090,{"OK"}) //-- Funcionalidade indisponível para contratos de compra.
				lRet := .F.
			ElseIf Empty(CN9->CN9_CLIENT) 
				Aviso("CNTA120",STR0090,{"OK"}) //-- Funcionalidade indisponível para contratos de compra.
				lRet := .F.
			EndIf
			
		EndIf
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa ponto de entrada após validação do acesso ao usuário  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CN120CTU")
		   lCN120CTU := ExecBlock("CN120CTU",.F.,.F.,{lRet})  
		  	If ValType(lCN120CTU) == "L"
				lRet := lCN120CTU
			EndIf
  		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120VlCon³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida contrato e preenche competencias                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120VlCon()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120VlCon(nTipo,lExcede)

Local cFilCod	  := ""
Local cCompetbck  := ""
Local cQuery      := ""
Local cCompExce   := ""

Local nMes		  := 0
Local nAno		  := 0
Local nMesF		  := 0
Local nAnoF		  := 0

Local aCompets    := {}
Local aCompExce   := {}                                                     

Local lRet        := .T.
Local lCn120ctaut := ExistBlock("CN120CTAUT")
Local lVldVige    := GetNewPar("MV_CNFVIGE","N") == "N"     
Local lCN120DTCON := .T.

Local bValAno 	  := {|| Val(Subs(CNF->CNF_COMPET,4,4)) <= Year(dDataBase)}
Local bValMes 	  := {|| Val(Subs(CNF->CNF_COMPET,1,2)) <= Month(dDataBase)}

Static lMVCNFCOMP  := SuperGetMv("MV_CNFCOMP",.F.,.F.) //-- Filtra competencias a exibir de acordo com a database

DEFAULT nTipo     := 1 
DEFAULT lExcede   := .F.

dbSelectArea("CN9")
dbSetOrder(1)
 
lRet := If(AliasInDic("CPD"),CNTVldCTR(cContra),ExistCpo("CN9",cContra)) .And. CN240VldUsr(cContra,DEF_TRAINC,.T.,,cFilCTR)
    
If !dbSeek(xFilial("CN9",cFilCTR)+cContra)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona na revisao atual do contrato       ³k
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CN9->(dbSeek(xFilial("CN9",cFilCTR)+CN9->CN9_NUMERO+"ZZZ",.T.))
CN9->(dbSkip(-1))

cRevisa := if((!Empty(CN9->CN9_REVATU) .And. CN9->CN9_SITUAC != DEF_SVIGE),CN9->CN9_REVATU,CN9->CN9_REVISA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica Medicao eventual                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CN1")
dbSetOrder(1)
If dbSeek(xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica Medicao eventual                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lMedeve := (CN1->CN1_MEDEVE == "1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica Contrato Fixo            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If (CN1->(FieldPos("CN1_CTRFIX")) > 0)
		lFixo := Empty(CN1->CN1_CTRFIX) .Or. CN1->CN1_CTRFIX = "1"
	EndIf	
EndIf

If nTipo == 2 .And. CN1->CN1_ESPCTR == "2"
	Aviso("CNTA120",OemToAnsi(STR0054),{"OK"})//"Autorizacao de Fornecimento é valida somente para contratos de compra"
	lRet := .F.
EndIf

If lRet .And. lExcede .And. CN1->CN1_ESPCTR == "1"
	Aviso("CNTA120",STR0090,{"OK"}) //-- Funcionalidade indisponível para contratos de compra.
	lRet := .F.
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se o contrato esta em vigencia              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(CN9->CN9_SITUAC) != DEF_SVIGE
		lRet := .F.
		Help( " ", 1, "CNTA120_02" )//"Apenas contratos em vigência podem ser medidos"
	ElseIf lVldVige .and. (CN9->CN9_DTINIC > dDataBase .Or. CN9->CN9_DTFIM < dDataBase)
		lRet := .F.
		Help( " ", 1, "CNTA120_07" )//Contrato fora do periodo de vigencia
	ElseIf !lExcede
		cPlan := ""
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa arquivo temporario                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("TRBCNA")
		If RecCount() > 0
			Zap
			oBrowse:Refresh()
		Endif
				
		nMes := Month(CN9->CN9_DTINIC)
		nAno := Year(CN9->CN9_DTINIC)
		nMesF:= Month(CN9->CN9_DTFIM)
		nAnoF:= Year(CN9->CN9_DTFIM)
		
		If !lMedeve .And. lFixo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando o contrato nao tiver medicao eventual       ³
			//³seleciona competencias de acordo com os cronogramas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CNF")
			cFilCod := xFilial("CNF",cFilCTR)
			dbSetOrder(2)
			dbSeek(cFilCod+cContra+cRevisa)
			while CNF->CNF_FILIAL = cFilCod .And. CNF->CNF_CONTRA = cContra .And. CNF->CNF_REVISA = cRevisa
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Exclui parcelas pagas e verifica competencia       ³
				//³contra database                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CNF->CNF_SALDO > 0 .And. (!lVldVige .Or. (lVldVige .And. (nAno < Val(Subs(CNF->CNF_COMPET,4,4)) .OR. (nAno = Val(Subs(CNF->CNF_COMPET,4,4)) .And. nMes <= Val(Subs(CNF->CNF_COMPET,1,2)))) .And. aScan(aCompets,CNF->CNF_COMPET) == 0))
					If lMVCNFCOMP
						If CNF->CNF_PERIOD == "1" .And.; 	//-- Periodicidade mensal
								Eval(bValAno) .And.; 		//-- Valida ano
								Eval(bValMes) 				//-- Valida mes
							aAdd(aCompets,CNF->CNF_COMPET)
						ElseIf CNF->CNF_PERIOD == "2" .And.; 	//-- Periodicidade quinzenal
								Eval(bValAno) .And.; 			//-- Valida ano
								Eval(bValMes) .And.; 			//-- Valida mes
								Iif((Day(dDataBase)-15) > 0,Day(CNF->CNF_PRUMED) > 15,Day(CNF->CNF_PRUMED) <= 15) //-- Valida quinzena
							aAdd(aCompets,CNF->CNF_COMPET)					
						ElseIf CNF->CNF_PERIOD == "3" .And.;	//-- Periodicidade diaria
								Eval(bValAno) .And.; 			//-- Valida ano
								Eval(bValMes) .And.;			//-- Valida mes
							 	CNF->CNF_PRUMED <= dDataBase  	//-- Valida dia
							aAdd(aCompets,CNF->CNF_COMPET)					
						EndIf   
					Else
						aAdd(aCompets,CNF->CNF_COMPET)
					EndIf
				EndIf
				dbSkip()
			EndDo
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando o contrato tiver medicao eventual seleciona ³
			//³competencias de acordo com a vigencia do mesmo     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While nMes <= nMesF .Or. nAno < nAnoF
				If nMes > 12
					nMes := 1
					nAno++
				EndIf
				If !lMVCNFCOMP .Or. StrZero(nMes,2) +"/" +Str(nAno,4) < StrZero(Month(dDataBase),2) +"/" +Str(Year(dDataBase),4)
					aAdd(aCompets,StrZero(nMes,2) +"/" +Str(nAno,4))
				Else
					Exit
				EndIf
				nMes++
			EndDo
		EndIf
		//Ordena por data
		If lCn120ctaut .and. cCompet<>Space(TamSX3("CNF_COMPET")[1])
			cCompetbck := cCompet
			oCbx:aItems := ASort(aCompets,,,{|x,y|  CTOD("01/"+x) < CTOD("01/"+y)  })
			cCompet := cCompetbck
			oCbx:nAT := aScan(oCbx:aItems,cCompet)		
			oCbx:Refresh()
		Else
			oCbx:aItems := ASort(aCompets,,,{|x,y|  CTOD("01/"+x) < CTOD("01/"+y)  })
		EndIf
	EndIf
EndIf

If lRet
	If lExcede
		cEspCtr := '2'
		cCompExce := Substr(DToS(CN9->CN9_DTINIC),1,6)
	
		cQuery := "SELECT DISTINCT(CNF.CNF_COMPET) AS CNF_COMPET FROM " +RetSQLName("CNF") +" CNF WHERE "
		cQuery += "CNF.D_E_L_E_T_ <> '*' AND CNF.CNF_FILIAL = '" +xFilial("CNF",cFilCTR) +"' AND "
		cQuery += "CNF.CNF_CONTRA = '" +cContra +"' AND CNF.CNF_REVISA = '" +cRevisa +"' "

		cQuery += "UNION "
		
		cQuery += "SELECT DISTINCT(CND.CND_COMPET) FROM " +RetSQLName("CND") +" CND WHERE CND.D_E_L_E_T_ = ' ' AND "
		If CND->(FieldPos("CND_FILCTR")) == 0
			cQuery += "CND.CND_FILIAL = '" + xFilial("CND") +"' AND "
		Else
			cQuery += "CND.CND_FILCTR = '" + cFilCTR +"' AND "
		EndIf
		cQuery += "CND.CND_CONTRA = '" +cContra +"' AND "
		cQuery += "CND.CND_REVISA = '" +cRevisa +"' AND CND.CND_COMPET NOT IN ("
		
		cQuery += "SELECT DISTINCT(CNFTMP.CNF_COMPET) FROM " +RetSQLName("CNF") +" CNFTMP WHERE CNFTMP.D_E_L_E_T_ = ' ' AND "
		cQuery += "CNFTMP.CNF_FILIAL = '" +xFilial("CNF",cFilCTR) +"' AND CNFTMP.CNF_CONTRA = '" +cContra +"' AND "
		cQuery += "CNFTMP.CNF_REVISA = '" +cRevisa +"'"
		
		cQuery += ")"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"QRYTRB",.F.,.T.)
		
		QRYTRB->(dbEval({|| aAdd(aCompets, Substr(QRYTRB->CNF_COMPET,4,4) + Substr(QRYTRB->CNF_COMPET,1,2))}))
		QRYTRB->(dbCloseArea())
		
		//-- Monta competencias nao previstas no cronograma.
		While cCompExce <= Substr(DToS(CN9->CN9_DTFIM),1,6)
			If aScan(aCompets, {|x| x == cCompExce}) == 0
				aAdd(aCompExce,Substr(cCompExce,5,2) +"/" +Substr(cCompExce,1,4))
			EndIf
		
			//-- Incrementa cCompExce
			If Substr(cCompExce,5,2) == '12'
				cCompExce := StrZero(Val(Substr(cCompExce,1,4)) + 1,4) + "01"
			Else
				cCompExce := Substr(cCompExce,1,4) + StrZero(Val(Substr(cCompExce,5,2)) + 1,2)
			EndIf
		End
		If !Empty(aCompExce)
			oCbx:aItems := aClone(aCompExce)
			cCompet := oCbx:aItems[1]
		Else
			Aviso(STR0114,STR0115,{"OK"}) //-- Não há competências não previstas para este contrato.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		CN120Compet(lExcede)
	EndIf
EndIf      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada após validação  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120DTCON")
	lCN120DTCON:= ExecBlock("CN120DTCON",.F.,.F.,{lRet})   
	If ValType(lCN120DTCON) == "L"
	   lRet := lCN120DTCON
	EndIf
EndIf     

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Compet³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Competencia e carrega planilhas de acordo com a      ³±±
±±³          ³ competencia selecionada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120Compet()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120Compet(lExcede)

Local cQuery     	:= ""
Local lRet       	:= .T.
Local lCN120GTR  	:= ExistBlock("CN120GTR") 
Local lCN120QRY  	:= ExistBlock("CN120QRY")
Local lCn120ctaut	:= ExistBlock("CN120CTAUT")
Local aCn120Cpo  	:= {}
Local lCn120Cpo  	:= Iif(ExistBlock("CN120CPO"),.T.,.F.)
Local nCpo		   	:= 0         
Local dData			:= dDatabase

Static lCompetenci	:= SuperGetMv("MV_CNFCOMP",.F.,.F.) // Filtra cronograma

Default lExcede	:= .F.

cPlan := ""

CursorWait()

If lCn120Cpo
	aCn120Cpo := ExecBlock("CN120CPO",.F.,.F.)
	If ValType(aCn120cpo) <> "A"
		aCn120Cpo := {}
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra contrato                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CN9")
dbSetOrder(1)
dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa)

dbSelectArea("CNF")
dbSetOrder(2)
dbSeek(xFilial("CNF",cFilCTR)+cContra+cRevisa)
If lFixo
	If lExcede
		cQuery := "SELECT CNA.R_E_C_N_O_ AS PLANREC, CNA.CNA_NUMERO, CNA.CNA_DTINI, CNA.CNA_VLTOT, CNA.CNA_DTFIM, "
		cQuery += " CNA.CNA_FORNEC, CNA.CNA_LJFORN,CNA.CNA_CLIENT,CNA.CNA_LOJACL, CNA.CNA_CRONOG, 0 AS CNF_VLPREV, '' AS CNF_PARCEL "
		If Len(aCn120Cpo) > 0 .And. lCn120Cpo
			For nCpo:=1 To Len(aCn120Cpo)
				cQuery += ","+aCn120Cpo[nCpo]
			Next nCpo
		Endif
		If AliasIndic("CPD")
			cQuery += " FROM " +RetSQLName("CNA") +" CNA, " +RetSQLName("CN9") + " CN9 ," + RetSQLName("CPD") + " CPD WHERE "
		Else
			cQuery += " FROM " +RetSQLName("CNA") +" CNA, " +RetSQLName("CN9") +" CN9 WHERE "
		EndIf
		cQuery += " CNA.CNA_FILIAL = '" +xFilial("CNA",cFilCTR) +"'"
		cQuery += " AND CN9.CN9_FILIAL = '" +xFilial("CN9",cFilCTR) +"'"
		cQuery += " AND CNA.CNA_CONTRA = CN9.CN9_NUMERO  "
		cQuery += " AND CNA.CNA_REVISA = CN9.CN9_REVISA "
		
		If AliasIndic("CPD")
			cQuery += " AND CPD.CPD_CONTRA = CN9.CN9_NUMERO "
			cQuery += " AND CPD.CPD_NUMPLA = CNA.CNA_NUMERO "
			cQuery += " AND CPD.CPD_FILAUT = '" + cFilAnt +"'"
		EndIf
		
		cQuery += " AND CNA.CNA_CONTRA = '" +cContra +"'"
		cQuery += " AND CNA.CNA_REVISA = '" +cRevisa +"'"
		cQuery += " AND SUBSTRING(CNA.CNA_DTFIM,1,6) >= '" +Substr(cCompet,4,4) +Substr(cCompet,1,2) +"'"
		If AliasIndic("CPD")
			cQuery += " AND CPD.D_E_L_E_T_ = '' "
		EndIf
		cQuery += " AND CNA.D_E_L_E_T_ <> '*' AND CN9.D_E_L_E_T_ <> '*'"
	Else
		If !lMedeve
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Filtra planilhas de acordo com os cronogramas      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT CNA.R_E_C_N_O_ as PLANREC, CNA.CNA_NUMERO, CNA.CNA_DTINI,  CNA.CNA_VLTOT, CNA.CNA_DTFIM, "
			cQuery += " CNA.CNA_FORNEC, CNA.CNA_LJFORN, CNA.CNA_CLIENT, CNA.CNA_LOJACL, CNA.CNA_CRONOG, (CNF.CNF_SALDO) as CNF_VLPREV, CNF.CNF_PARCEL "
			
			If Len(aCn120Cpo) > 0 .And. lCn120Cpo
				For nCpo:=1 To Len(aCn120Cpo)
					cQuery += ","+aCn120Cpo[nCpo]
				Next nCpo
			Endif
			
			If AliasIndic("CPD")
				cQuery += "  FROM " + RetSQLName("CNA") + " CNA ," + RetSQLName("CNF") + " CNF ," + RetSQLName("CN9") + " CN9 ," + RetSQLName("CPD") + " CPD "
			Else
				cQuery += "  FROM " + RetSQLName("CNA") + " CNA ," + RetSQLName("CNF") + " CNF ," + RetSQLName("CN9") + " CN9 "
			EndIf
			
			cQuery += " WHERE CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCTR) +"'" 
			cQuery += " 	AND CNF.CNF_FILIAL = '"+ xFilial("CNF",cFilCTR) +"'"
			cQuery += " 	AND CN9.CN9_FILIAL = '"+ xFilial("CN9",cFilCTR) +"'"
			cQuery += "	AND CNA.CNA_CONTRA = CNF.CNF_CONTRA "
			cQuery += " 	AND CNA.CNA_REVISA = CNF.CNF_REVISA "
			cQuery += " 	AND CNF.CNF_NUMERO = CNA.CNA_CRONOG "
			cQuery += " 	AND CNF.CNF_COMPET = '"+cCompet+"'"
			
			If lCompetenci .And. CNF->CNF_PERIOD <> "1" .And. Substr(DToS(dDataBase),1,6) <= Substr(cCompet,4,4)+Substr(cCompet,1,2)
				cQuery += "   AND CNF.CNF_PRUMED <= '"+Dtos(dDataBase)+"'"
			EndIf
			
			If AliasIndic("CPD")
				cQuery += "   AND CPD.CPD_CONTRA = CN9.CN9_NUMERO "
				cQuery += "   AND CPD.CPD_NUMPLA = CNA.CNA_NUMERO "
				cQuery += "   AND CPD.CPD_FILAUT = '" + cFilAnt + "'"
			EndIf
			
			cQuery += "   AND CNA.CNA_CONTRA = CN9.CN9_NUMERO "
			cQuery += "   AND CNA.CNA_REVISA = CN9.CN9_REVISA "
			cQuery += "   AND CNA.CNA_CONTRA = '" +cContra+ "'"
			cQuery += "   AND CNA.CNA_REVISA = '" +cRevisa+ "'"
			cQuery += "   AND CNF.CNF_SALDO > 0 AND " //Filtra parcelas nao medidas
			cQuery += "   (SELECT COUNT(R_E_C_N_O_) "
			cQuery += "      FROM "+ RetSQLName("CND") + " CND WHERE "
			If !Empty(CND->(FieldPos("CND_FILCTR")))
				cQuery += " CND.CND_FILCTR = '"+ cFilCTR +"' AND "
			Else
				cQuery += " CND.CND_FILIAL = '"+ xFilial("CND") +"' AND "
			EndIf
			cQuery += "CND.CND_CONTRA =  '"+ cContra +"' AND "
			If !Empty(CND->(FieldPos("CND_AUTFRN"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO"))) //Filtra planilhas sem medicoes em aberto
				cQuery += " CND.CND_REVISA   = '"+ cRevisa +"'"
				cQuery += " AND CND.CND_NUMERO   = CNA.CNA_NUMERO "
				cQuery += " AND ((CND.CND_AUTFRN='1' AND  CND.CND_DTFIM = '') " 
				cQuery += " OR (CND.CND_AUTFRN='2' AND CND.CND_PEDIDO = ''))  "
				cQuery += " AND CND.D_E_L_E_T_ = '') = 0  AND "
			Else
				cQuery += "CND.CND_REVISA = '"+ cRevisa +"' AND CND.CND_NUMERO = CNA.CNA_NUMERO and CND.CND_DTFIM = '' and CND.D_E_L_E_T_ = '') = 0 AND " //Filtra planilhas sem medicoes em aberto
			EndIf
			If AliasIndic("CPD")
				cQuery += " CPD.D_E_L_E_T_ = '' AND "
			EndIf
			cQuery += " CNA.D_E_L_E_T_ = '' AND CNF.D_E_L_E_T_ = '' AND CN9.D_E_L_E_T_ = ''"
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Filtra planilhas                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT CNA.R_E_C_N_O_ as PLANREC, CNA.CNA_NUMERO, CNA.CNA_DTINI, CNA.CNA_VLTOT, CNA.CNA_DTFIM, "
			cQuery += "       CNA.CNA_FORNEC, CNA.CNA_LJFORN, CNA.CNA_CRONOG, '"+Replicate('-',TamSX3("CNF_PARCEL")[1])+"' AS CNF_PARCEL "
			If Len(aCn120Cpo) > 0 .And. lCn120Cpo
				For nCpo:=1 To Len(aCn120Cpo)
					cQuery += ","+aCn120Cpo[nCpo]
				Next nCpo
			Endif
			cQuery += "  FROM " + RetSQLName("CNA") + " CNA ," + RetSQLName("CN9") + " CN9 "
			cQuery += "  WHERE CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCTR) +"' AND CN9.CN9_FILIAL = '"+ xFilial("CNB",cFilCTR) +"'"
			cQuery += "  AND CNA.CNA_CONTRA = CN9.CN9_NUMERO "
			cQuery += "  AND CNA.CNA_REVISA = CN9.CN9_REVISA "
			cQuery += "  AND CNA.CNA_CONTRA = '" + cContra + "'"
			cQuery += "  AND CNA.CNA_REVISA = '" + cRevisa + "'"
			cQuery += "  AND CNA.CNA_SALDO  > 0 AND "//Filtra planilhas com saldo
			cQuery += " (SELECT COUNT(R_E_C_N_O_) FROM " + RetSQLName("CND") + " CND WHERE "
			If !Empty(CND->(FieldPos("CND_FILCTR")))
				cQuery += "CND.CND_FILCTR = '"+ cFilCTR +"' AND "
			Else
				cQuery += "CND.CND_FILIAL = '"+ xFilial("CND") +"' AND "	
			EndIf
			cQuery += "CND.CND_CONTRA =  '"+ cContra +"' AND "
			cQuery += "CND.CND_REVISA = '"+ cRevisa +"' AND CND.CND_NUMERO = CNA.CNA_NUMERO AND "			
			If !Empty(CND->(FieldPos("CND_AUTFRN"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO")))
				cQuery += "((CND.CND_AUTFRN='1' AND  CND.CND_DTFIM = '') OR (CND.CND_AUTFRN='2' AND CND.CND_PEDIDO = ''))  AND CND.D_E_L_E_T_ = '') = 0 AND " //Filtra planilhas sem medicoes em aberto
			Else
				cQuery += "CND.CND_DTFIM = '' AND CND.D_E_L_E_T_ = '') = 0 AND " //Filtra planilhas sem medicoes em aberto
			EndIf
			cQuery += " CNA.D_E_L_E_T_ = '' AND CN9.D_E_L_E_T_ = ''"
		EndIf
	EndIf
	
	If lCN120QRY					
		cCN120QRY := ExecBlock("CN120QRY",.F.,.F.,{cQuery})
		If ValType(cCN120QRY) == "C"
			cQuery := cCN120QRY
		EndIf
	EndIf
	
 	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TRB", .F., .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Configura estrutura                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TCSetField("TRB","CNA_DTINI","D")
	TCSetField("TRB","CNA_DTFIM","D")
	TCSetField("TRB","CNA_VLTOT","N",TamSX3("CNA_VLTOT")[1],TamSX3("CNA_VLTOT")[2])
	TCSetField("TRB","CNF_VLPREV","N",TamSX3("CNF_VLPREV")[1],TamSX3("CNF_VLPREV")[2])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpa arquivo temporario           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRBCNA")
If RecCount() > 0
	Zap
Endif

If lFixo .And. TRB->(Eof()) .And. !lCn120ctaut
	Aviso("CNTA120",OemToAnsi(STR0034),{"OK"})//"Não existe planilha disponível no contrato e competência selecionados. Verifique o saldo e a existência de medições em aberto para o contrato"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Copia planilhas filtradas para arquivo temporario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFixo
	While TRB->(!Eof())
		RecLock("TRBCNA",.T.)
			TRBCNA->CNA_NUMERO := TRB->CNA_NUMERO
			TRBCNA->CNA_DTINI  := TRB->CNA_DTINI
			TRBCNA->CNA_VLTOT  := TRB->CNA_VLTOT
			TRBCNA->CNA_DTFIM  := TRB->CNA_DTFIM
			TRBCNA->CNA_FORNEC := TRB->CNA_FORNEC
			TRBCNA->CNA_LJFORN := TRB->CNA_LJFORN
			TRBCNA->CNA_CRONOG := TRB->CNA_CRONOG
			If !lMedeve
				TRBCNA->CNF_VLPREV := TRB->CNF_VLPREV
			else
				TRBCNA->CNF_VLPREV := 0
			EndIf
			TRBCNA->CNF_PARCEL := TRB->CNF_PARCEL
			If Len(aCn120Cpo) > 0 .And. lCn120Cpo
				For nCpo:=1 To Len(aCn120Cpo)
					TRBCNA->&(aCn120Cpo[nCpo]) := TRB->&(aCn120Cpo[nCpo])
				Next nCpo
			Endif
			If lCN120GTR 
				ExecBlock("CN120GTR",.F.,.F.,{lFixo,TRB->PLANREC})
			EndIf
		MsUnlock()
		TRB->(dbSkip())
	EndDo

	TRB->(dbCloseArea())
Else
	RecLock("TRBCNA",.T.)	
		TRBCNA->CNA_NUMERO := "------"
		TRBCNA->CNA_DTINI  := dDataBase
		TRBCNA->CNA_VLTOT  := 0
		TRBCNA->CNA_DTFIM  := dDataBase
		TRBCNA->CNA_FORNEC := ""
		TRBCNA->CNA_LJFORN := ""
		TRBCNA->CNA_CRONOG := ""
		TRBCNA->CNF_VLPREV := 0
		TRBCNA->CNF_PARCEL := ""
		If Len(aCn120Cpo) > 0 .And. lCn120Cpo
			For nCpo:=1 To Len(aCn120Cpo)
				TRBCNA->&(aCn120Cpo[nCpo]) := TRB->&(aCn120Cpo[nCpo])
			Next nCpo
		Endif
		If lCN120GTR 
			ExecBlock("CN120GTR",.F.,.F.,{lFixo,TRB->PLANREC})
		EndIf
	MsUnlock()
EndIf

TRBCNA->(dbGoTop())

CursorArrow()

oBrowse:Refresh()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120VldCpt ³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida competencia durante a execucao da rotina automatica   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120VldCpt(cExp01,cExp02)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120VldCpt(lExcede)

Local cQuery    := ""    
Local lRet      := .T.
Local lCN120CPT := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra contrato                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExcede
	//-- Verifica se formato da competencia e valido
	lRet := Val(Substr(cCompet,1,2)) > 0 .And. Val(Substr(cCompet,1,2)) <= 12 .And. Substr(cCompet,3,1) == "/"
	
	//-- Valida competencia com data de inicio e fim da planilha
	If lRet
		CNA->(dbSetOrder(1))
		CNA->(dbSeek(xFilial("CNA",cFilCTR)+cContra+cRevisa+cPlan))
		
		lRet := Substr(cCompet,4,4)+Substr(cCompet,1,2) >= Substr(DToS(CNA->CNA_DTINI),1,6) .And.;
				Substr(cCompet,4,4)+Substr(cCompet,1,2) <= Substr(DToS(CNA->CNA_DTFIM),1,6)
	EndIf
	
	//-- Verifica se competencia e prevista
	If lRet
		cQuery := "SELECT DISTINCT(CNF.CNF_COMPET) AS CNF_COMPET FROM " +RetSQLName("CNF") +" CNF WHERE "
		cQuery += "CNF.D_E_L_E_T_ <> '*' AND CNF.CNF_FILIAL = '" +xFilial("CNF",cFilCTR) +"' AND "
		cQuery += "CNF.CNF_CONTRA = '" +cContra +"' AND CNF.CNF_REVISA = '" +cRevisa +"' AND "
		cQuery += "CNF.CNF_COMPET = '" +cCompet +"' "
	
		cQuery += "UNION "
		
		//-- Verifica se ja foi gerada medicao
		cQuery += "SELECT DISTINCT(CND.CND_COMPET) FROM " +RetSQLName("CND") +" CND WHERE CND.D_E_L_E_T_ = ' ' AND "
		If CND->(FieldPos("CND_FILCTR")) == 0
			cQuery += "CND.CND_FILIAL = '" +xFilial("CND") +"' AND "
		Else
			cQuery += "CND.CND_FILCTR = '" +cFilCTR +"' AND "
		EndIf
		cQuery += "CND.CND_CONTRA = '" +cContra +"' AND "
		cQuery += "CND.CND_REVISA = '" +cRevisa +"' AND CND.CND_COMPET = '" +cCompet +"'"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TRB",.F.,.T.)
		
		//-- So valida se nao existir nenhum dos dois casos
		lRet := Empty(TRB->CNF_COMPET)

		TRB->(dbCloseArea())
	EndIf
ElseIf !lFixo
	dbSelectArea("CN9")
	dbSetOrder(1)
	dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa)
	
	lMedeve := (Posicione("CN1",1,xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO,"CN1_MEDEVE") == "1")
	
	If !lMedeve
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtra planilhas de acordo com os cronogramas      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT(R_E_C_N_O_) QTD "
		cQuery += "  FROM "+RetSQLName("CNA") + " CNA ," + RetSQLName("CNF") + " CNF "
		cQuery += " WHERE CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCTR) +"' AND CNF.CNF_FILIAL = '"+ xFilial("CNF",cFilCTR) +"'"
		cQuery += "   AND CNA.CNA_CONTRA = CNF.CNF_CONTRA "
		cQuery += "   AND CNA.CNA_REVISA = CNF.CNF_REVISA "
		cQuery += "   AND CNF.CNF_NUMERO = CNA.CNA_CRONOG "
		cQuery += "   AND CNF.CNF_COMPET = '"+ cCompet +"'"
		cQuery += "   AND CNA.CNA_CONTRA = '" + cContra + "'"
		cQuery += "   AND CNA.CNA_REVISA = '" + cRevisa + "'"
		cQuery += "   AND CNA.CNA_NUMERO = '" + cPlan   + "'"
		cQuery += "   AND CNF.CNF_SALDO  > 0  " //Filtra parcelas nao medidas
		cQuery += "   AND (SELECT COUNT(R_E_C_N_O_) FROM " + RetSQLName("CND")+" CND WHERE "
		If CND->(FieldPos("CND_FILCTR")) == 0
			cQuery += "         CND.CND_FILIAL = '"+ xFilial("CND") +"'"
		Else
			cQuery += "         CND.CND_FILCTR = '"+ cFilCTR +"'"
		EndIf		
		cQuery += "           AND CND.CND_CONTRA = '"+ cContra +"'"
		cQuery += "           AND CND.CND_REVISA = '"+ cRevisa +"'"
		cQuery += "           AND CND.CND_NUMERO = CNA.CNA_NUMERO "
		cQuery += "           AND CND.CND_DTFIM  = '' "
		cQuery += "           AND CND.D_E_L_E_T_ = '') = 0 "//Filtra planilhas sem medicoes em aberto
		cQuery += "   AND CNA.D_E_L_E_T_ = '' "
		cQuery += "   AND CNF.D_E_L_E_T_ = '' "
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtra planilhas                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT(R_E_C_N_O_) QTD "
		cQuery += "  FROM " + RetSQLName("CNA") + " CNA "
		cQuery += " WHERE CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCTR) +"'"
		cQuery += "   AND CNA.CNA_CONTRA = '" + cContra + "'"
		cQuery += "   AND CNA.CNA_REVISA = '" + cRevisa + "'"
		cQuery += "   AND CNA.CNA_NUMERO = '" + cPlan   + "'"
		cQuery += "   AND CNA.D_E_L_E_T_ = ''"
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TRB", .F., .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o acesso do usuario                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := (TRB->QTD > 0)

	TRB->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa ponto de entrada após validação da competência  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120CPT")
	lCN120CPT := ExecBlock("CN120CPT",.F.,.F.,{lRet})  
  	If ValType(lCN120CPT) == "L"
		lRet := lCN120CPT
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120RetTip³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna descricao do tipo de planilha                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120RetTip()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120RetTip()
Local cTipPlan
Local cRet := ""

If !INCLUI
	cTipPlan := Posicione( "CNA", 1, xFilial("CNA",cFilCTR) + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMERO,"CNA_TIPPLA")
	cRet     := Posicione( "CNL", 1, xFilial("CNL",cFilCTR) + cTipPlan, "CNL_DESCRI" )
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120MedEnc³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Encerra medicao, valida cronograma, medicoes zeradas        ³±±
±±³          ³ e saldo do contrato e planilhas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CN120MedEnc(nExp01)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  nExp01 - Registro atual                                    ³±±
±±³          ³  lExp01 - Aviso de confirmacao de encerramento              ³±±
±±³          ³  lExp02 - Autorizacao de Fornecimento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120MedEnc(nReg,lAviso,lAutoFor,lMedServ)

Local aAreaSX3    := ""

Local lRet	   := .T.
Local lMedeve
Local lFscLmt  := .F.
Local lContab  := .F.     
Local lFixo    := .T.
Local lValor   := .T.
Local lPeSld   := ExistBlock("CN120ENSLD")
Local lPeGrP   := ExistBlock("CN120GRPED")
Local lGrped   := .T.
Local lPeVlPar := ExistBlock("CN120VLPAR")
Local lRetVlPar:=.T.
Local lFisico  := .F.
Local lVldVige := GetNewPar("MV_CNFVIGE","N") == "N"
Local lBloqSE2 := .F.  
Local lAtuSld  := .T.
Local lCN120VMP:= .T.  
Local lPeVdSld := ExistBlock("CN120VDSD")      
Local lSldFlex := .T.      
Local lGCTBloq := (SE2->(FieldPos("E2_MSBLQL")) > 0)

Local cFilCod
Local cCronog
Local cParcel
Local cAliasQry:= ""
Local cAliasSD1:= ""
Local cAliasSE2:= ""
Local cFilCND  := xFilial("CND")
Local cFilSC7  := xFilial("SC7")
Local cNumPed  := ""
Local cNumTit  := ""
Local cTexto	 := ""
Local cFilCNS
Local cAlias   := ""
Local cEspCtr  := ""
Local cAliasCNE:= "" 
Local cChave   := ""
Local cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cChave1  := ""
Local cChave2  := ""
Local cTes     := ""

Local nMedLmt   := 0 //Limite de medicao do contrato
Local nTaxa
Local nTipo     := 1 //1 - Medicao;2 - Autorizacao de Fornecimento
Local nAcao     := 1 //1 - Encerra;2 - Gera Pedido;3 - Somente Encerra
Local nServico  := 1 //1 - Medicao;2 - Medicao de Servico;
Local nTpDoc	:= CN120VerDoc(CND->CND_NUMMED) //Verifica quais documentos foram gerados Pedidos/Titulos      

Local uRet         

//Variaveis para contabilizacao
Local nHead			:= 0 						//Retorno da funcao HeadProva
Local nDet  			:= 0     					//Retorno da funcao DetProva
Local cArqGCT 			:= ""                       //Arquivo contabilizacao
Local cLancCont		:= ""						// Numero da LP
Local lDigita 			:= .F.    	 				//Mostra lancamento?
Local lAglutina		:= .F.    	 				//Aglutina
Local cLoteGCT  		:= LoteCont("COM")  		//Numero do Lote

Local nI				:= 0
Local cBusca			:= ""
Local cSeqPCOLan		:= ""	//Sequencia de Lancamento do PCO - 000355t
Local lMedComPlan 	:= .F.   

Local aLPGCT		:= {	{"697",VerPadrao("697")},; //LP Gestão de Contratos - Encerramento da Medição
							{"698",VerPadrao("698")},; //LP Gestão de Contratos - Encerramento da Medição/Automatico
							{"699",VerPadrao("699")},; //LP Gestão de Contratos - Encer. Medicao: Itens do Contrato			
							{"69A",VerPadrao("69A")},; //LP Gestão de Contratos - Est. Medicao: Itens do Contrato
							{"69B",VerPadrao("69B")},; //LP Gestão de Contratos - Incl. Rateio Itens Contrato s/ Planilha
							{"69C",VerPadrao("69C")},; //LP Gestão de Contratos - Excl. Rateio Itens Contrato s/ Planilha
							{"69D",VerPadrao("69D")},; //LP Gestão de Contratos - Incl. Rateio Itens Contrato c/ Planilha							
							{"69E",VerPadrao("69E")},;
							{"69F",VerPadrao("69F")} ; //LP Gestão de Contratos - Excl. Rateio Itens Contrato c/ Planilha
						} 
Static nParcelas := SuperGetMv("MV_NUMPARC")						
Static cNatureza := SuperGetMv("MV_CNNATMD",.F.,"") //Informa natureza financeira usada pelos títulos gerados pela medição de itens faturados através de título.

DEFAULT lAviso   := .T.
DEFAULT lAutoFor := .F.
DEFAULT lMedServ := .F.


//Estabelece passos
ProcRegua(5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona na medicao                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CND")
MsGoTo(nReg)

If !lAutoFor .Or. !lMedServ
	lRet := CN240VldUsr(CND->CND_CONTRA,DEF_TRAENC,.T.,,cFilCtr)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validar o encerramento da   ³
//³medicao                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120VENC")
	uRet := ExecBlock("CN120VENC", .F., .F., {lRet})
	If ValType(uRet) == "L"
		lRet := uRet
	EndIf
EndIf
          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para indicar se atualiza ou nao  ³
//³saldo da medicao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120ATSLD")
	lAtuSld := ExecBlock("CN120ATSLD",.F.,.F.)
	If ValType(lAtuSld) <> "L"
		lAtuSld:=.T.
	EndIf
EndIf

cChave := CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED
  
If LockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
	Pergunte("CNT120",.F.)	//carrega as variaveis
	
	If Type("cOrigem") == "C"
		cLancCont:= IiF(ALLTRIM(cOrigem) == "CNTA120",cLancCont:= "697",cLancCont:= "698")
		If cOrigem == "CNTA260" .and. GetRemoteType() != -1 .And. lShow
	   		Pergunte("CNT120",.T.)
	   	ElseIf cOrigem == "CNTA260" .and. GetRemoteType() == -1
	   		MV_PAR01 := 1
	   		MV_PAR02 := 2
	   		MV_PAR03 := 2		
		EndIf  
	Else
		cLancCont:= "697"
	EndIf	

	If (lCtbOnLine := (MV_PAR01 == 1)) //SE CONTABILIZA, atraves da escolha do usuario 
		//Percorre os lancamentos contabeis do GCT, se algum deles existir, a contabilizacao podera ter continuidade
		For nI := 1 to len(aLPGCT) 
			If aLPGCT[nI,2]
				lCtbOnline := .t.
				Exit
			Else
				lCtbOnline := .f.	
			Endif
		Next nI 
		
		If lCtbOnLine
		
			lDigita	 	:= IIF(VAlTYPE(MV_PAR02)=="N" ,MV_PAR02 == 1,.F.)
			lAglutina	:= IIF(VAlTYPE(MV_PAR03)=="N" ,MV_PAR03 == 1,.F.) 
			
			nHead	:= HeadProva(cLoteGCT,cOrigem,Subs(cUsuario,7,6),@cArqGCT)
			If nHead <= 0
				If GetRemoteType() != -1 
					HELP(" ",1,STR0081) //"SEM_LANC"
				Else
					ConOut(STR0081) //"SEM_LANC"
				EndIf
				lCtbOnLine := .F.
			EndIf
		EndIf
	Endif

	If lRet
		If !Empty(CND->(FieldPos("CND_AUTFRN"))) 
			nTipo := If(CND->CND_AUTFRN=="2",2,1)
			
			If !Empty(CND->(FieldPos("CND_PEDIDO"))) 
				If nTipo == 2
					If Empty(CND->CND_PEDIDO)
						nAcao := 2
					Else
						nAcao := 3
					EndIf
				EndIf
			EndIf
		EndIf     
		                                   
		If !Empty(CND->(FieldPos("CND_SERVIC"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO"))) 
			nServico := If(CND->CND_SERVIC=="1",1,2)   
	    EndIf
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a medicao ja se encontra encerrada    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(CND->CND_DTFIM)
			lRet := .F.
			Help( " ", 1, "CNTA120_03" )//"Medição já encerrada"
		ElseIf (GetNewPar("MV_CNMDALC","N") == "S" ) .AND. CND->CND_ALCAPR == "B"
			lRet := .F.
			Help( " ", 1, "CNTA120_09" )//"Medição bloqueada por alçada"	
		ElseIf nTpDoc # 1 .And. (Empty(cNatureza) .Or. !SED->(dbSeek(xFilial("SED")+cNatureza)))
		 	Help( " ", 1, "NOCNNATMD" )//"A natureza informada no parâmetro MV_CNNATMD não está cadastrada.
		 	lRet := .F.
		EndIf
		dbSelectArea("CN9")
		dbSetOrder(1)
		If lRet .And. dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA)
			If (CN9->CN9_SITUAC==DEF_SFINA .OR. CN9->CN9_SITUAC==DEF_SCANC) //Contrato finalizado ou cancelado
				lRet := .F.
				Help( " ", 1, "CNTA120_02" )//"Apenas contratos em vigência podem ser medidos"
			EndIf
		EndIf                                                 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se os campos CND_DATA e CND_PARC estão criados conforme parametro MV_NUMPARC   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		dbSelectArea("SE4")
		dbSetOrder(1)   
		MsSeek(xFilial("SE4")+CND->CND_CONDPG)
		If SE4->E4_TIPO=='9' 
			If nParcelas > 4
				cChave1  := "CND_DATA"+Subs(cParcela,nParcelas,1)
				cChave2  := "CND_PARC"+Subs(cParcela,nParcelas,1)
				aAreaSX3 := SX3->(GetArea())
					
				DbSelectArea("SX3")
				DbSetOrder(2)
				If lRet
					If !DbSeek(cChave1) .or. !DbSeek(cChave2)
						Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
						lRet:= .F.      
					EndIf  
				EndIf
					
				Restarea(aAreaSX3)		
			EndIf     
		EndIf 
		
		If lRet
			If !Empty(CND->CND_CLIENT)
				lRet := ExistCpo("SA1",CND->CND_CLIENT+CND->CND_LOJACL)   //Verifica se cliente e loja existe
			Else 
			    lRet :=	ExistCpo("SA2",CND->CND_FORNEC+CND->CND_LJFORN) 	
			EndIf  
		EndIf
		
		If nAcao != 3
			If lRet
				dbSelectArea("CN9")
				dbSetOrder(1)
				If dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Identifica especie do contrato  ³
					//³1 - Compra                      ³
					//³2 - Venda                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If CN9->(FieldPos("CN9_ESPCTR")) > 0
						cEspCtr 	:= CN9->CN9_ESPCTR
					Else
						cEspCtr	:=If(Empty(CN9->CN9_CLIENT),"1","2")
					EndIf	
					
					CN1->(dbSetOrder(1))
					CN1->(dbSeek(xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO))
					lMedeve := (CN1->CN1_MEDEVE == "1")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o contrato possui   ³
					//³ou nao cronograma contabil      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lContab := (CN1->CN1_CROCTB == "1")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se campo CN1_LMTMED ja existir valida a medicao   ³
					//³de acordo com o valor informado, caso contrario   ³
					//³valida apenas contra o saldo do cronograma        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If CN1->(FieldPos("CN1_LMTMED")) > 0
						nMedLmt := CN1->CN1_LMTMED
					EndIf
					
					If CN1->(FieldPos("CN1_TPLMT")) > 0
						lFscLmt := (CN1->CN1_TPLMT == "2")
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o contrato é fixo  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If CN1->(FieldPos("CN1_CTRFIX")) > 0 .And. CN1->(FieldPos("CN1_VLRPRV")) > 0
						lFixo  := (Empty(CN1->CN1_CTRFIX) .OR. (CN1->CN1_CTRFIX == "1"))
						lValor := (Empty(CN1->CN1_VLRPRV) .OR. (CN1->CN1_VLRPRV == "1"))
					EndIf
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se o contrato possui cronograma fisico   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lFisico := (!lMedeve .And. (CN1->(FieldPos("CN1_CROFIS")) > 0) .And. (CN1->CN1_CROFIS == "1"))
				EndIf
				
				If lFixo
					cCronog := Posicione("CNA",1,xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO,"CNA_CRONOG")
					If !lMedeve
						IncProc( STR0013 )//"Validando Cronograma X Planilhas"
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Quando nao for medicao eventual valida           ³
						//³valor previsto do cronograma com valor realizado ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNF")
						If !Empty(CND->( FieldPos( "CND_PARCEL" ) )) .And. !Empty(CND->CND_PARCEL)
							dbSetOrder(3)
							dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_PARCEL)
						Else
							dbSetOrder(2)
							dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_COMPET)
						EndIf
						
						If Found()
							cParcel := CNF->CNF_PARCEL
							
							If lPeVlPar
								lRetVlPar := If(Valtype(lRetVlPar:=ExecBlock("CN120VLPAR",.F.,.F.))=="L",lRetVlPar,.T.)
							EndIf
							
							If lRetVlPar					
								If !lFscLmt
								
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Soma o limite de medicao ao saldo da parcela      ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									nTaxa := CNF->CNF_TXMOED
									If lRet .And. ((CNF->CNF_SALDO+((CNF->CNF_VLPREV*nMedLmt)/100)) < xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa))
										Aviso("CNTA120",STR0011+CRLF+STR0012,{"OK"})//"Valor total de medição não previsto no cronograma."+CRLF+"O mesmo deve ser reestruturado."
										lRet := .F.
									EndIf
								Else
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Valida a quantidade medida contra a quantidade    ³
									//³prevista no cronograma                            ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cQuery := "SELECT CNE.CNE_ITEM,CNE.CNE_QUANT,CNS.CNS_PRVQTD "
									cQuery += "  FROM "+RetSQLName("CNE")+" CNE, "+RetSQLName("CNS")+" CNS, "+RetSQLName("CNF")+" CNF "
									cQuery += " WHERE CNE.CNE_FILIAL = '"+xFilial("CNE")+"'"
									cQuery += "   AND CNS.CNS_FILIAL = '"+xFilial("CNS",cFilCTR)+"'"
									cQuery += "   AND CNF.CNF_FILIAL = '"+xFilial("CNF",cFilCTR)+"'"
									cQuery += "   AND CNE.CNE_NUMMED = '"+CND->CND_NUMMED+"' AND "
									If !Empty(CND->( FieldPos( "CND_PARCEL" ) )) .And. !Empty(CND->CND_PARCEL)
										cQuery += "CNF.CNF_PARCEL = '"+CND->CND_PARCEL+"' AND "
									Else
										cQuery += "CNF.CNF_COMPET = '"+CND->CND_COMPET+"' AND "
									EndIf
									cQuery += "     CNS.CNS_CONTRA = CNE.CNE_CONTRA "
									cQuery += " AND CNS.CNS_REVISA = CNE.CNE_REVISA "
									cQuery += " AND CNS.CNS_PLANI  = CNE.CNE_NUMERO "
									cQuery += " AND CNS.CNS_ITEM   = CNE.CNE_ITEM   " 
									cQuery += " AND CNS.CNS_CONTRA = CNF.CNF_CONTRA "
									cQuery += " AND CNS.CNS_REVISA = CNF.CNF_REVISA "
									cQuery += " AND CNS.CNS_CRONOG = CNF.CNF_NUMERO "
									cQuery += " AND CNS.CNS_PARCEL = CNF.CNF_PARCEL "
									cQuery += " AND CNS.D_E_L_E_T_ = ' ' "
									cQuery += " AND CNE.D_E_L_E_T_ = ' ' "
									cQuery += " AND CNF.D_E_L_E_T_ = ' ' "
								
									cAlias := GetNextAlias()
									cQuery := ChangeQuery( cQuery )
									dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAlias, .F., .T. )
									
									nMedLmt += 100
									
									While !(cAlias)->(Eof())
										If ((cAlias)->CNS_PRVQTD = 0 .And. (cAlias)->CNE_QUANT > 0) .OR. ((((cAlias)->CNE_QUANT*100)/(cAlias)->CNS_PRVQTD) > nMedLmt)
											Aviso("CNTA120",OemToAnsi(STR0035)+(cAlias)->CNE_ITEM+OemToAnsi(STR0036),{"OK"})//"Não é possível encerrar a medição.O item "##" ultrapassou o limite de medição do cronograma físico"
											lRet := .F.
											Exit
										EndIf
										(cAlias)->(dbSkip())
									EndDo
								
									(cAlias)->(dbCloseArea())
								EndIf
							EndIf
						EndIf
					EndIf
		   		Else          
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Ponto de entrada permite ou não validar o saldo do contrato do tipo flexível ³
					//³com o valor da medição a ser encerrada                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If lPeVdSld
						lSldFlex := ExecBlock("CN120VDSD",.F.,.F.)
					EndIf
				
					If lSldFlex			 
						If lValor .And. CN9->CN9_SALDO < xMoeda(CND-> CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2])
							If nTipo==1 .And. nServico ==1
								Aviso("CNTA120",STR0049,{"OK"})//"Não foi possível encerrar a medição. O saldo do contrato nao equivale ao valor da medicao."
							Else
								Aviso("CNTA120",STR0057,{"OK"})//"Não foi possível gerar o pedido. O saldo do contrato nao equivale ao valor da medicao."
							EndIf  
							
							lRet := .F.
						EndIf      
					EndIf   
				EndIf    		
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa ponto de entrada após validação do valor previsto com realizado   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("CN120VMP")
				   lCN120VMP := ExecBlock("CN120VMP",.F.,.F.,{lRet})  
				  	If ValType(lCN120VMP) == "L"
						lRet := lCN120VMP
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se houveram itens medidos quando a      ³
				//³medicao nao for zerada                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If(CND->CND_ZERO == "2" .And. CND->CND_VLTOT == 0)
					Help( " ", 1, "CNTA120_04")// "Não existem itens medidos no registro atual"
					lRet := .F.
				EndIf
			EndIf
			
			If lRet
				IncProc( STR0015 )//"Atualizando Medicao e Itens"
				PcoIniLan("000355") 
				Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Chama ponto de entrada para verificar se gera pedido. ³
				//³Podera ser utilizado para aglutinar varias medicoes e |
				//³somente apos realizar a geracao do pedido.            |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPeGrP
					lGrped := ExecBlock("CN120GRPED",.f.,.f.)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera pedido de compra                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        If lGrPed
					If CND->CND_ZERO == "2"
						IncProc( OemToAnsi( If(cEspCtr=="1",STR0017,STR0039) ) )//"Gerando Pedido de Compras"##"Gerando Pedido de Vendas"
						lRet := CN120GrvPed(CND->CND_NUMMED,CND->CND_REVISA,@cNumPed,nTaxa,CND->CND_CONTRA,@cTes,.F.,@cNumTit)
					EndIf
				Else
					lRet := .T. //Retorna .T. para continuar o processo normal
				EndIf
				
				If lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza data fim da medicao                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nAcao == 1
						RecLock("CND",.F.)
							CND->CND_DTFIM := dDataBase
						MsUnlock()
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   	//³Ponto lancamento contabil e orcamentario para encerramento da medicao            ³
				   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000355","03","CNTA120")
					If lCtbOnLine							
				    	nDet += DetProva(nHead,cLancCont,cOrigem,cLoteGCT,,,,,,,,,{"CND",CND->(RECNO())})
					EndIf
					
					DbSelectArea("CNE")
					dbSetOrder(1)
					cFilCod := xFilial()
					dbSeek(cFilCod+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED)
					
					If lFixo
						If lFisico
							cFilCNS := xFilial("CNS",cFilCTR)
						EndIf
								
						If lAtuSld .And. !lPeSld
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza itens da planilha                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							While CNE->CNE_FILIAL = cFilCod .And. CNE->CNE_CONTRA = CND->CND_CONTRA .And. CNE->CNE_REVISA = CND->CND_REVISA .And.;
								CNE->CNE_NUMERO = CND->CND_NUMERO .And. CNE->CNE_NUMMED = CND->CND_NUMMED
								
								lMedComPlan := .f.
																
								//-- Itens excedentes nao atualizam saldos
								If Empty(CNE->(FieldPos("CNE_EXCEDE"))) .Or. CNE->CNE_EXCEDE == '2'
									dbSelectArea("CNB")
									dbSetOrder(1)
									If dbSeek(xFilial("CNB",cFilCTR)+CNE->CNE_CONTRA+CNE->CNE_REVISA+CNE->CNE_NUMERO+CNE->CNE_ITEM)
										RecLock("CNB",.F.)  
											If nServico == 1
												CNB->CNB_QTDMED += CNE->CNE_QUANT
												CNB->CNB_SLDMED -= CNE->CNE_QUANT
											Else 
												CNB->CNB_QTDMED += CNE->CNE_QTDORI
												CNB->CNB_SLDMED -= CNE->CNE_QTDORI										
											EndIf
										MsUnlock()
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ CAPTURO A VARIAVEL FLAG DE ITENS COM PLANILHA ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										lMedComPlan := .T.
									EndIf
									
									If lFisico
										dbSelectArea("CNS")
										dbSetOrder(1)
										If dbSeek(cFilCNS+CND->CND_CONTRA+CND->CND_REVISA+cCronog+cParcel+CNB->CNB_ITEM)
											RecLock("CNS",.F.)
												CNS->CNS_RLZQTD += CNE->CNE_QUANT
												CNS->CNS_SLDQTD -= CNE->CNE_QUANT
											MsUnlock()
										EndIf
									EndIf
								EndIf
								
								PcoDetLan("000355","04","CNTA120")
								
								If lCtbOnLine
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ CONTABILIZA ENCERRAMENTO DA MEDICAO - ITENS DO CONTRATO ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									nDet += DetProva(nHead,"69A","CNTA120",cLoteGCT,,,,,,,,,{"CNE",CNE->(Recno())})
								Endif	
                                
								If lMedComPlan
									cLancCont 	:= "69E"
									cSeqPCOLanc	:= "06"
								Else
									cLancCont := "69C"
									cSeqPCOLanc	:= "05"
								Endif
	                            
	                            If AliasInDic("CNZ")
	                            
	                            	cBusca :=	xFilial("CNZ",cFilCTR) +;
												Padr(CNE->CNE_CONTRA	,tamSx3("CNZ_CONTRA")[1])	+;
												Padr(CNE->CNE_REVISA	,TamSx3("CNZ_REVISA")[1])	+;
												Padr(CNE->CNE_NUMMED	,TamSX3("CNZ_NUMMED")[1])	+; 
												Padr(CNE->CNE_ITEM		,TamSx3("CNZ_ITCONT")[1])
		                            
		                            CNZ->(dbSetOrder(2)) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT+CNZ_ITEM
		                            
		                            If CNZ->(dbSeek( cBusca ))
		                            	While CNZ->(!Eof()) .and. cBusca == 	xFilial("CNZ",cFilCTR) +;
		                            											Padr(CNE->CNE_CONTRA	,tamSx3("CNZ_CONTRA")[1])	+;
																				Padr(CNE->CNE_REVISA	,TamSx3("CNZ_REVISA")[1])	+;
																				Padr(CNE->CNE_NUMMED	,TamSX3("CNZ_NUMMED")[1])	+; 
																				Padr(CNE->CNE_ITEM		,TamSx3("CNZ_ITCONT")[1])	
									        
							  		     	PcoDetLan("000355",cSeqPCOLan,"CNTA120")
	
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Contabiliza os rateios do item do contrato com planilha. 												  ³
											//³ Se ha planilha, entao nao podera contabilizar o rateio sem planilha, abaixo (controlar com variavel flag) ³
											//³ efetua a contabilizacao dos rateios do item do contrato sem planilha, 									  ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											If lCtbOnLine							                     
										    	nDet += DetProva(nHead,cLancCont,"CNTA120",cLoteGCT,,,,,,,,,{"CNZ",CNZ->(Recno())})
	  										EndIf
											CNZ->(DbSkip())									
		                            	EndDo
		                            Endif
								Endif
								dbSelectArea("CNE")
								dbSkip()
							EndDo
						EndIf
							
						IncProc( STR0016 )//"Atualizando Saldos"
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza saldo da planilha                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNA")
						If dbSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO)
							If lAtuSld .And. !lPeSld//Nao atualiza saldo quando o ponto de entrada CN120SLDCTR estiver ativo
								RecLock("CNA",.F.)
									CNA->CNA_SALDO -= xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa)
								MsUnlock()
							EndIf
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza saldo do contrato                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CN9")
					dbSetorder(1)
					If dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA)
						If lAtuSld .And. !lPeSld//Nao atualiza saldo quando o ponto de entrada CN120SLDCTR estiver ativo
							RecLock("CN9",.F.)
								If lFixo .Or. lValor
									CN9->CN9_SALDO -= xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa)
								Else
									CN9->CN9_VLATU += xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa)//Atualiza valor do contrato
									If Empty(CN9->CN9_REVISA)//Se contrato original atualiza valor inicial
										CN9->CN9_VLINI += xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa)
									EndIf
								EndIf     							 
								
							MsUnlock()
						EndIf
					EndIf
					
					If !lMedeve .And. lFixo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza saldo do cronograma quando nao houver  ³
						//³ medicao eventual                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNF")
						If !Empty(CND->( FieldPos( "CND_PARCEL" ) )) .And. !Empty(CND->CND_PARCEL)
							dbSetorder(3)
							dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_PARCEL)
						Else
							dbSetorder(2)
							dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_COMPET)				
						EndIf
						
						If Found()
							If lAtuSld .And. !lPeSld//Nao atualiza saldo quando o ponto de entrada CN120SLDCTR estiver ativo
								RecLock("CNF")
									CNF->CNF_VLREAL += xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa)
									CNF->CNF_SALDO  -= xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDataBase,TamSX3("CND_VLTOT")[2],,nTaxa)
									CNF->CNF_DTREAL := dDataBase
								MsUnlock()
								
								If (GetNewPar( "MV_CNPROVI" ,  "S" ) == "S")
									IncProc( STR0021 )//"Processando títulos provisórios"
									
									CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,cFilCtr)
									If CNF->CNF_SALDO > 0
										CN100CTit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,CNF->CNF_SALDO)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
					If lContab
						dbSelectArea("CNV")
						dbSetOrder(2)
						
						If dbSeek(xFilial("CNV",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO)
							nVlOr := xMoeda(CND->CND_VLTOT - CN120VlExc(),CN9->CN9_MOEDA,1,dDataBase,TamSX3("CNV_VRCAMB")[2],CNV->CNV_TXMOED)
							nVlAtu:= xMoeda(CND->CND_VLTOT - CN120VlExc(),CN9->CN9_MOEDA,1,dDataBase,TamSX3("CNV_VRCAMB")[2])
							RecLock("CNV",.F.)
								CNV->CNV_VRCAMB += nVlAtu-nVlOr
							MsUnlock()
						EndIf
					EndIf
					
					If lPeSld//Chama ponto de entrada para atualizacao do saldo
						ExecBlock("CN120ENSLD",.f.,.f.,{lMedeve,lFisico,cCronog,lFixo,lValor})
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa ponto de entrada para encerramento da medicao ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("CN120ENCMD")
						ExecBlock("CN120ENCMD",.F.,.F.)
					EndIf
				EndIf
				
				End Transaction
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa ponto de entrada para encerramento da medicao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("CN120ENMED") // Fora da transação
					ExecBlock("CN120ENMED",.F.,.F.)
				EndIf
				
				PcoFinLan("000355")

				If !lAuto
					If lAviso
						If lRet
							If Empty(cNumPed) .And. Empty(cNumTit)
								If nTipo == 1 .And. nServico == 1
									Aviso("CNTA120",OemToAnsi(STR0050),{"OK"})//"Medição/entrega encerrada com sucesso"
								ElseIf nTipo == 2
									Aviso("CNTA120",OemToAnsi(STR0065),{"OK"})//"Autorização de fornecimento encerrada com sucesso"  
								Else
									Aviso("CNTA120",OemToAnsi(STR0084),{"OK"})//"Medição de Serviços encerrada com sucesso" 
								EndIf      
															
							Else
								If !Empty(cNumTit)
									cTexto := OemToAnsi(If(cEspCtr=="1",STR0118,STR0119))+cNumTit //Gerado titulo à pagar/receber número "
									cTexto += CRLF
								EndIf								
								If !Empty(cNumPed)
									cTexto += OemToAnsi(If(cEspCtr=="1",STR0026,STR0044))+cNumPed//"Gerado pedido de compra/venda número "	
								EndIf
								Aviso("CNTA120",cTexto,{"OK"})//"Gerado pedido de compra número "	
							EndIf
						Else               
							If Empty(cTes).And.cEspCtr=="2"
								Aviso("CNTA120",STR0080,{"OK"})//Produto não possui TES vinculada. Vincule o Produto a TES através do Cadastro de Produtos antes de Encerrar a Medição.
							Else
								Aviso("CNTA120",OemToAnsi(If(cEspCtr=="1",STR0027,STR0045))+" "+OemToAnsi(STR0028),{"OK"})//"O pedido de compra não pode ser gerado."##"Para mais informações consulte o log gerado no diretório \SYSTEM do sistema"
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			Begin Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza data fim da medicao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("CND",.F.)
				CND->CND_DTFIM := dDataBase
			MsUnlock()
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Desbloqueia titulos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			lBloqSE2 := .F.
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona a nota        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT DISTINCT SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_TIPO, SF1.F1_DUPL, SF1.F1_PREFIXO, F1_FORNECE, F1_LOJA "
			cQuery += "  FROM " + RetSQLName("SF1") + " SF1, " + RetSQLName("SD1") + " SD1 "
			cQuery += " WHERE SF1.F1_FILIAL  = '" + xFilial("SF1") + "'"
			cQuery += "   AND SD1.D1_FILIAL  = '" + xFilial("SD1") + "'"
			cQuery += "   AND SF1.F1_DOC     = SD1.D1_DOC     "
			cQuery += "   AND SF1.F1_SERIE   = SD1.D1_SERIE   "
			cQuery += "   AND SF1.F1_TIPO    = SD1.D1_TIPO    " 
			cQuery += "   AND SF1.F1_FORNECE = SD1.D1_FORNECE "
			cQuery += "   AND SF1.F1_LOJA    = SD1.D1_LOJA    "
			cQuery += "   AND SD1.D1_PEDIDO  = '" + CND->CND_PEDIDO + "'"
			cQuery += "   AND SF1.D_E_L_E_T_ = ' ' "
			cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
	
			cQuery    := ChangeQuery( cQuery )
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )
			
			If !(cAliasQry)->(Eof())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona os pedidos relacionados na mesma nota   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := "SELECT DISTINCT SD1.D1_PEDIDO "
				cQuery += "  FROM " + RetSQLName("SD1") + " SD1 "
				cQuery += " WHERE SD1.D1_FILIAL   = '" + xFilial("SD1") + "'" 
				cQuery += "   AND SD1.D1_DOC      = '" + (cAliasQry)->F1_DOC + "'"
				cQuery += "   AND SD1.D1_SERIE    = '" + (cAliasQry)->F1_SERIE + "'"
				cQuery += "   AND SD1.D1_TIPO     = '" + (cAliasQry)->F1_TIPO + "'"
				cQuery += "   AND SD1.D1_PEDIDO  <> '" + CND->CND_PEDIDO + "'"
				cQuery += "   AND SD1.D_E_L_E_T_  = ' '"
				
				cQuery    := ChangeQuery( cQuery )
				cAliasSD1 := GetNextAlias()			
				dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSD1, .F., .T. )
				
				While !(cAliasSD1)->(Eof())
					dbSelectArea("SC7")
					dbSetOrder(1)
					
					If dbSeek(cFilSC7+(cAliasSD1)->D1_PEDIDO)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o pedido foi originado por uma medicao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(SC7->C7_CONTRA)
	
							dbSelectArea("CND")
							dbSetOrder(1)
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona na Medicao ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If CND->( dbSeek( cFilCND+SC7->C7_CONTRA+SC7->C7_CONTREV+SC7->C7_PLANILH+SC7->C7_MEDICAO ) )
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Quando houver alguma medicao NAO encerrada impede o desbloqueio dos titulos ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Empty(CND->CND_DTFIM)
									lBloqSE2 := .T.
									Exit
								EndIf
							EndIf
							
						EndIf
					EndIf
	
					(cAliasSD1)->(dbSkip())
				EndDo
				
				(cAliasSD1)->(dbCloseArea())
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Desbloqueia os titulos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				If !lBloqSE2 .And. lGCTBloq
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona os titulos ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := "SELECT SE2.R_E_C_N_O_ AS RECNO "
					cQuery += "  FROM " + RetSQLName("SE2") + " SE2 "
					cQuery += " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "'"
					cQuery += "   AND SE2.E2_NUM     = '" + (cAliasQry)->F1_DUPL + "'"
					cQuery += "   AND SE2.E2_PREFIXO = '" + IIf(Empty((cAliasQry)->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),(cAliasQry)->F1_PREFIXO) + "'"
					cQuery += "   AND SE2.E2_FORNECE = '" + (cAliasQry)->F1_FORNECE + "'"
					cQuery += "   AND SE2.E2_LOJA    = '" + (cAliasQry)->F1_LOJA + "'"
					cQuery += "   AND SE2.E2_TIPO    = 'NF '"
					cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "
	
					cQuery    := ChangeQuery( cQuery )
					cAliasSE2 := GetNextAlias()			
					dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Desbloqueia os titulos ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					While !(cAliasSE2)->(Eof())
						SE2->( MsGoTo( (cAliasSE2)->RECNO ) )
					
						RecLock("SE2",.F.)
							SE2->E2_MSBLQL := "2"
						MsUnlock()
						
						(cAliasSE2)->(dbSkip())
					EndDo
					
					(cAliasSE2)->(dbCloseArea())
				EndIf
			EndIf
			
			(cAliasQry)->(dbCloseArea())
			
			End Transaction
			If nTipo == 2
				Aviso("CNTA120",OemToAnsi(STR0065),{"OK"})//"Autorização de Fornecimento encerrada com sucesso"
			Else
				Aviso("CNTA120",OemToAnsi(STR0084),{"OK"})//"Autorização de Fornecimento encerrada com sucesso"
			EndIf
			
		EndIf
	EndIf
Else      
	// Nao permite processamento concorrente
	Aviso(STR0068,OemtoAnsi(STR0069),{"Ok"},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
EndIf

If lCtbOnLine
	RodaProva(nHead,nDet)
	If nDet > 0
		cA100Incl(cArqGCT,nHead,1,cLoteGCT,lDigita,lAglutina)
	Endif
EndIf	

UnLockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Ence ³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Encerra medicao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120Ence(cExp01,nExp02,nExp03)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120Ence(cAlias,nReg,nOpc)
Local aValidGet := {}
Local nPosNum        
Local lCanEnce  := ExistBlock("CN120ENVL")
Local lContinua := .T.

If CND->(FieldPos("CND_FILCTR")) > 0
	cFilCtr := CND->CND_FILCTR
Else
	cFilCtr := cFilAnt
EndIf

If !lAuto
	If (!Empty(CND->(FieldPos("CND_AUTFRN"))) .AND. !Empty(CND->(FieldPos("CND_PEDIDO")))) .And. CND->CND_AUTFRN == "2"
		lContinua := (Aviso("CNTA120",OemtoAnsi(STR0062),{STR0022,STR0023}) == 1)//"Confirma encerramento da autorização de fornecimento?"
	ElseIf (!Empty(CND->(FieldPos("CND_SERVIC")))) .And. CND->CND_SERVIC == "2"
		lContinua := (Aviso("CNTA120",OemtoAnsi(STR0085),{STR0022,STR0023}) == 1)//"Confirma encerramento da Medicao de Servico?"
	Else
		lContinua := (Aviso("CNTA120",OemtoAnsi(STR0024),{STR0022,STR0023}) == 1)//"Confirma encerramento da medição?"##"Sim"##"Não"
	EndIf
Else                                                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o numero da medicao foi fornecido      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPosNum:=aScan(aAutoCab,{|x| x[1]=="CND_NUMMED"})) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida numero da medicao                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aValidGet,{"cNumMed" ,aAutoCab[nPosNum,2],"CN120NumAuto(cNumMed,.F.)",.T.})
		
		If (lContinua := MsVldGAuto(aValidGet))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na medicao                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CND")
			dbSetOrder(4)
			dbSeek(xFilial("CND")+aAutoCab[nPosNum,2])
			nReg:=CND->(RECNO())
		EndIf
	else
		lContinua:=.F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada permite encerrar a medição ou não.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lCanEnce
	lContinua:=ExecBlock("CN120ENVL",.F.,.F.)
	If ValType(lContinua) <> "L"
		lContinua:=.T.
	EndIf
EndIf

If lContinua
	//Chama rotina de encerramento por meio de processo
	Processa( {|| CN120MedEnc(nReg) } )
	
	If CNL->(FieldPos("CNL_LMTAVS")) > 0
		dbSelectArea("CNA")
		dbSetOrder(1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica alerta de saldo das planilhas            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dbSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula percentual do saldo da planilha           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPrcSld := (CNA->CNA_SALDO*100)/CNA->CNA_VLTOT
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona tipo de planilha                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CNL")
			dbSetOrder(1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a planilha alcancou o limite percentual³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dbSeek(xFilial("CNL",cFilCTR)+CNA->CNA_TIPPLA) .And. cPrcSld <= CNL->CNL_LMTAVS
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Emite alerta de saldo do contrato ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MEnviaMail("040",{CND->CND_NUMERO,CND->CND_CONTRA,CND->CND_REVISA,CNA->CNA_VLTOT,CNA->CNA_SALDO,CND->CND_FILIAL})
			EndIf
		EndIf
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Estor³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estorna medicao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120Estor(cExp01,nExp02,nExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120Estor(cAlias,nReg,nOpc)
Local aValidGet := {}
Local nPosNum     
Local cChave    := ""  
Local lCanEstor :=ExistBlock("CN120VLEST")
Local lContinua := .T.

If CND->(FieldPos("CND_FILCTR")) > 0
	cFilCtr := CND->CND_FILCTR
Else
	cFilCtr := cFilAnt
EndIf

If !lAuto
	If (!Empty(CND->(FieldPos("CND_AUTFRN"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO")))) .And. CND->CND_AUTFRN == "2"
		lContinua := (Aviso("CNTA120",OemtoAnsi(STR0063),{STR0022,STR0023}) == 1)//"Confirma encerramento da autorização de fornecimento?"
	Else
		lContinua := (Aviso("CNTA120",OemtoAnsi(STR0025),{STR0022,STR0023}) == 1)//"Confirma estorno da medição?"##"Sim"##"Não"
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o numero da medicao foi fornecido      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPosNum:=aScan(aAutoCab,{|x| x[1]=="CND_NUMMED"})) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida numero da medicao                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aValidGet,{"cNumMed" ,aAutoCab[nPosNum,2],"CN120NumAuto(cNumMed,.F.)",.T.})
		
		If (lContinua := MsVldGAuto(aValidGet))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na medicao                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CND")						
			If (nPosPln:=aScan(aAutoCab,{|x| x[1]=="CND_NUMERO"})) > 0 
				CND->(dbSetOrder(1))
				
				CND->(dbSeek( xFilial("CND")							+ ;
				aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_CONTRA"}),2]	+ ;
				aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_REVISA"}),2]	+ ;
				aAutoCab[nPosPln,2]										+ ;				
				aAutoCab[nPosNum,2]))				
				
			Else 				
				CND->(dbSetOrder(4))
				CND->(dbSeek(xFilial("CND")+aAutoCab[nPosNum,2]))				
			Endif 
			nReg := CND->(Recno())
		EndIf
	else
		lContinua:=.F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada permite estornar a medição ou não.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. lCanEstor
	lContinua:=ExecBlock("CN120VLEST",.F.,.F.)
	If ValType(lContinua) <> "L"
		lContinua:=.T.
	EndIf
EndIf

cChave := CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED
  
If LockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
	If lContinua
		//Chama rotina de estorno por meio de processo
		Processa( {|| CN120MedEst(nReg) } )
	EndIf   
Else      
	// Nao permite processamento concorrente
	Aviso(STR0068,OemtoAnsi(STR0069),{"Ok"},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
EndIf
UnLockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120GrvPed³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera pedido de compra por rotina automatica                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120GrvPed(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Numero da medicao                                  ³±±
±±³          ³ cExp02 - Codigo da nova revisao,usado na aprovacao CNTA150  ³±±
±±³          ³          pois o CND traz o codigo da revisao original       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120GrvPeD(cNumMed,cNRevisa,cNumPed,nTaxa,cContra,cTes,lExcede,cNumTit)

Local aRet			:= {}
Local aCab			:= {}
Local aItem		:= {}
Local aArea		:= GetArea()
Local aVend		:= {}//Array de vendedores
Local aStrCNE		:= CNE->(dbStruct())
Local aCN120ITM	:= {}
Local aCTBEnt	  	:= If(FindFunction("CTBEntArr"),CTBEntArr(),{})
Local aRatGCT		:= {}
Local aRatPedGCT	:= {}

Local cFilCod		:= xFilial("CNE")
Local cFilCNB		:= xFilial("CNB",cFilCTR)
Local cQuery		:= ""
Local cAliasQry	:= ""
Local cAliasCNR	:= ""
Local cAliasCNQ	:= ""
Local cAliasCND	:= ""
Local cEspCtr		:= "" //Tipo do contrato
Local cNumSC5		:= ""
Local cNumSC7		:= ""
Local cFilSC5		:= ""
Local cTpRat		:= GetNewPar("MV_CNRATE", "1")
Local cItemSC6	:= ""
Local cVend		:= "1"     
Local cParcela	:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cC7Item		:= ""	   
Local cAlc			:= "N"

Local nVlrTitulo	:= 0
Local nAcres		:= 0
Local nDecres		:= 0
Local nTpDoc		:= CN120VerDoc(CND->CND_NUMMED) //Verifica quais documentos foram gerados Pedidos/Titulos
Local nDesc		:= 0
Local nDecrUn		:= 0    
Local nDecrUnBon	:= 0
Local nDecrUnMul	:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nRateio		:= 0
Local nRatBoni	:= 0  
Local nRatMult	:= 0
Local nPosCpo		:= 0
Local nPosTotCpo	:= 0
Local nPosUniCpo	:= 0
Local nPosVenCpo	:= 0
Local nTotMedic	:= 0
Local nQuantArred	:= 0
Local nPrecoCalc	:= 0
Local nPrecoArred	:= 0
Local nValorOri	:= 0
Local nValorArred	:= 0
Local nValTot		:= 0             
Local nValUni		:= 0
Local nValQuant	:= 0
Local nDifValor	:= 0
Local nMult		:= 0
Local nBoni		:= 0
Local nCauc		:= 0
Local nAdia		:= 0
Local nDescMed	:= 0  
Local nPosItemed	:= 0    
Local nVlItDesc	:= 0
Local nRecNumber	:= 0      
Local nSaveSX8	:= If(Type('nSaveSx8')=='U', GetSX8Len(), nSaveSX8) 
Local lDesc
Local lRet			:= .T.
Local lGCTRet1	:= (GetNewPar( "MV_CNRETNF", "N" ) == "S") .And. ( SE1->( FieldPos("E1_RETCNTR") ) > 0 )
Local lGCTRet2	:= (GetNewPar( "MV_CNRETNF", "N" ) == "S") .And. ( SE2->( FieldPos("E2_RETCNTR") ) > 0 )
Local lGCTAdia	:= GetNewPar("MV_CNADIA","N") == "S"
Local lCN120PDM	:= .T.  
Local lCtMulBoni	:= !Empty( CNR->( FieldPos( "CNR_CONTRA" ) ) ) 
Local lCN120ITM	:= ExistBlock("CN120ITM") 
Local lGCTDPcAl	:= (GetNewPar("MV_CNDPCAL","N") == "S")
Local lGCTMdAlc	:= (GetNewPar("MV_CNMDALC","N") == "S")
Local cExpQry		:= ""
Local lPrjCni		:= FindFunction("ValidaCNI") .And. ValidaCNI()
Local cCodEdt		:= ""
Local cNumPro		:= ""       
Local lExistCpo	:= SC7->(FieldPos("C7_CODED"))>0 .And. SC7->(FieldPos("C7_NUMPR"))>0 .And. CN9->(FieldPos("CN9_CODED"))>0 .And. CN9->(FieldPos("CN9_NUMPR"))>0
Local lExistVld 	:= CN4->(FieldPos("CN4_VLDALT")) > 0
Local lExistDcme	:= CND->(FieldPos("CND_DESCME")) > 0 .And. AliasInDic("CNQ")
Local lExistOri	:= SC7->(FieldPos("C7_FISCORI")) > 0 .And. CNB->(FieldPos("CNB_FILORI")) > 0
Local lExistCC	:= CNE->(FieldPos("CNE_CC")) > 0
Local lExistTE	:= CNE->(FieldPos("CNE_TE")) > 0
Local lExistTS	:= CNE->(FieldPos("CNE_TS")) > 0
Local lExistPed	:= CND->(FieldPos("CND_PEDIDO")) > 0 .And. CND->(FieldPos("CND_AUTFRN")) > 0
Local lExistCNG	:= CNG->(FieldPos("CNG_NUMMED")) > 0
Local lExistCau	:= CND->(FieldPos("CND_RETCAC")) > 0

Default cNRevisa	:= ""
Default cContra	:= ""      
Default cNumMed	:= ""           
Default cTes		:= ""
Default cNumTit	:= ""	
Default cNumPed	:= ""
Default lExcede	:= .F.

Static nParcelas	:= SuperGetMv("MV_NUMPARC")   

Private cXFil 	:= "" // Para ser utilizado no ponto de entrada antes de apos o processamento da exclusão do pedido de compra - FSW

If Type("lAuto") == "L" 
	If lAuto .And. (nPosCpo := aScan(aAutoCab,{|x| AllTrim(x[1]) == "NUMPED"})) > 0
		cNumPed := aAutoCab[nPosCpo,2]
	EndIf                 
EndIf                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra da medicao do contrato      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT CND.R_E_C_N_O_ as CNDRECNO "
cQuery += "  FROM "+ RetSQLName("CND") +" CND "
cQuery += " WHERE CND.CND_FILIAL = '"+ xFilial("CND") +"'"
cQuery += "   AND CND.CND_CONTRA = '" + cContra + "'"
cQuery += "   AND CND.CND_REVISA = '" + cNRevisa+ "'"
cQuery += "   AND CND.CND_NUMMED = '" + cNumMed + "'"
cQuery += "   AND CND.D_E_L_E_T_ <> '*'"
	
cQuery    := ChangeQuery(cQuery)
cAliasCND := GetNextAlias()
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCND,.F.,.F.)

While !(cAliasCND)->(Eof())
	nVlrTitulo := 0 //-- Inicializa variavel de soma de titulos a serem gerados
	
	CND->(MsGoto((cAliasCND)->CNDRECNO))    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se medicao tem alcada                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If !lGCTDPcAl
		cAlc := IIf( lGCTMdAlc .And. !Empty(CND->CND_APROV),"S","N") 
	Else	
		cAlc :=  "S" //desativa o uso do alcada padrao do modulo de compras, indentifica no PC que e originado do SIGAGCT
    EndIf
    
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA))
	If lExistCpo
		cCodEdt:=CN9->CN9_CODED
		cNumPro:=CN9->CN9_NUMPR
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica especie do contrato             ³
	//³ 1 - Compra                               ³
	//³ 2 - Venda                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If CN9->(FieldPos("CN9_ESPCTR")) > 0
		cEspCtr 	:= CN9->CN9_ESPCTR
	Else
		cEspCtr	:=If(Empty(CN9->CN9_CLIENT),"1","2")
	EndIf
		
	// Apura o valor total da medicao sem considerar descontos
	cAliasQry := GetNextAlias()
	
	cQuery := "SELECT SUM(CNE_VLTOT) VLTOT, SUM(CNE_VLDESC) VLDESC "
	cQuery += "  FROM " + RetSqlName( "CNE" )
	cQuery += " WHERE CNE_FILIAL = '" + xFilial( "CNE" ) + "'"
	cQuery += "   AND CNE_CONTRA = '" + cContra + "'"
	cQuery += "   AND CNE_REVISA = '" + cNRevisa+ "'"
	cQuery += "   AND CNE_NUMMED = '" + cNumMed + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	If lExcede
		cQuery += "   AND CNE_EXCEDE = '1' AND CNE_PEDIDO = ' '"
	EndIf
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )
	
	nTotMedic   := ( cAliasQry )->VLTOT
	( cAliasQry )->( dbCloseArea() )
	
	dbSelectArea( "CNE" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o recurso de multa / bonificacao esta disponivel para a medicao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lExcede .And. lExistVld
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem o valor de multa e/ou bonificacao da medicao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CNR")
		cAliasCNR := GetNextAlias()
		
		cQuery := "SELECT CNR.CNR_VALOR  AS VALOR, CNR.CNR_TIPO "   
		If lCtMulBoni
			cQuery += "  ,CNR.CNR_CONTRA "  
		EndIf
		cQuery += "  FROM " + RetSqlName("CNR" ) + " CNR "
		cQuery += " WHERE CNR.CNR_FILIAL = '"+xFilial("CNR")+"'"
		cQuery += "   AND CNR.CNR_NUMMED = '" + cNumMed + "'"
		cQuery += "   AND CNR.CNR_FLGPED = '1'"
		cQuery += "   AND CNR.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasCNR, .F., .T. )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acerta o campo numerico                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TcSetField( cAliasCNR, "VALOR", "N", 18, 2 )
		
		While !( cAliasCNR )->( Eof() )
			If lCtMulBoni
				If !Empty(( cAliasCNR )->CNR_CONTRA) .And. (( cAliasCNR )->CNR_CONTRA) <> CND->CND_CONTRA 
					( cAliasCNR )->( dbSkip() )
					Loop  
				EndIf
			EndIf

			If ( cAliasCNR )->CNR_TIPO == "1"
				nMult += ( cAliasCNR )->VALOR
			ElseIf ( cAliasCNR )->CNR_TIPO == "2"
				nBoni += ( cAliasCNR )->VALOR
			EndIf
			( cAliasCNR )->( dbSkip() )
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		( cAliasCNR )->( dbCloseArea() )
		dbSelectArea( "CNR" )
		
	EndIf
	
	If !lExcede .And. lExistDcme .And. CND->CND_DESCME > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem o valor dos descontos de contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CNQ")
		
		cAliasCNQ := GetNextAlias()
		
		cQuery := "SELECT SUM( CNQ.CNQ_VALOR ) AS VALOR "
		cQuery += "  FROM " + RetSqlName("CNQ" ) + " CNQ, "+ RetSQLName("CNP") +" CNP "
		cQuery += " WHERE CNQ.CNQ_FILIAL = '"+ xFilial("CNQ") +"'"
		cQuery += "   AND CNP.CNP_FILIAL = '"+ xFilial("CNP",cFilCTR) +"'"
		cQuery += "   AND CNQ.CNQ_TPDESC = CNP.CNP_CODIGO "
		cQuery += "   AND CNQ.CNQ_NUMMED = '" + cNumMed + "'"
		cQuery += "   AND CNP.CNP_FLGPED = '1'"
		cQuery += "   AND CNQ.D_E_L_E_T_ = ' '"
		cQuery += "   AND CNP.D_E_L_E_T_ = ' '" 
		cQuery += "   AND CNP.CNP_FLGPED = '1'"
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasCNQ, .F., .T. )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acerta o campo numerico                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TcSetField( cAliasCNQ, "VALOR", "N", 18, 2 )
		
		nDescMed := If((!( cAliasCNQ )->(Eof())),( cAliasCNQ )->VALOR,0)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha a area de trabalho                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		( cAliasCNQ )->( dbCloseArea() )
		dbSelectArea( "CNQ" )
	EndIf
	
	dbSelectArea("CN9")
	dbSetOrder(1)
	dbSeek(xFilial("CN9",cFilCTR)+cContra+cNRevisa)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra itens da medicao e da planilha           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cQuery := "SELECT DISTINCT  CNE.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+ RetSQLName("CNE") +" CNE "
	cQuery += " WHERE CNE.CNE_FILIAL = '"+ xFilial("CNE") +"'"
	cQuery += "   AND CNE_CONTRA     = '" + cContra + "'"
	cQuery += "   AND CNE_REVISA     = '" + cNRevisa+ "'"
	cQuery += "   AND CNE.CNE_NUMMED = '"+ CND->CND_NUMMED +"'"
	cQuery += "   AND CNE.D_E_L_E_T_ <> '*'"
	If lExcede
		cQuery += "   AND CNE.CNE_EXCEDE = '1' AND CNE.CNE_PEDIDO = ' '"
	EndIf
	
	cQuery    := ChangeQuery(cQuery)
	cAliasCNE := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNE,.F.,.F.)
	
	For nx:=1 to len(aStrCNE)
		if (cAliasCNE)->(FieldPos(aStrCNE[nx,1])) > 0 .And. aStrCNE[nx,2] <> "C"
			TCSetField( cAliasCNE, aStrCNE[nx,1], aStrCNE[nx,2], aStrCNE[nx,3], aStrCNE[nx,4] )
		endif
	Next
	// Gera PC/PV somente quando cNumPed e cNumTit vazio,  
	// pois caso esteja preenchido significa que 
	// o mesmo ja foi gerado.					  
	If Empty(cNumPed) .And. Empty(cNumTit)
		If !lExcede
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o valor de retencao de caucao     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCauc := If(lExistCau .And. !(If((cEspCtr=="1"),lGCTRet2,lGCTRet1)),CND->CND_RETCAC,0)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem o valor dos adiantamentos         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAdia := If(lGCTAdia,CND->CND_TOTADT,0)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma descontos, multas, bonificacoes, caucoes retidas e adiantamentos        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDesc := nDescMed + nCauc + nAdia
			nRateio := ( nDesc *100 ) / nTotMedic
			nRatMult:= (nMult * 100 ) / nTotMedic
			nRatBoni:= (nBoni * 100 ) / nTotMedic
			lDesc   := !Empty( nDesc )
		EndIf
		//Contrato de compra
		If cEspCtr=="1"	
			If nTpDoc # 2  //-- Se gera pedido monta cabeçalho
				If lPrjCni
					If ExistBlock("CTA120FN")
						 ExecBlock("CTA120FN",.F.,.F.)
					EndIf
				EndIf
				cNumSC7  := Criavar("C7_NUM",.T.)//Gera numero do pedido de compra
				While ( GetSX8Len() > nSaveSX8 )
					ConFirmSX8()  
				EndDo
				If lPrjCni
					If ExistBlock("CTA120FV")
						 ExecBlock("CTA120FV",.F.,.F.)
					EndIf     
				EndIf
				//Efetua montagem do aCab usado para geração de pedido de compra
				aCab:={	{"C7_NUM"		,	cNumSC7				  		,NIL},; // Numero do Pedido
							{"C7_EMISSAO"	,	dDataBase						,NIL},; // Data de Emissao
							{"C7_FORNECE"	,	CND->CND_FORNEC				,NIL},; // Fornecedor
							{"C7_LOJA"		,	CND->CND_LJFORN				,NIL},; // Loja do Fornecedor
							{"C7_CONTATO"	,	CriaVar("C7_CONTATO"	,.F.)	,NIL},; // Contato
							{"C7_COND"		,	CND->CND_CONDPG				,NIL},; // Condicao de Pagamento
							{"C7_FILENT"	,	CriaVar("C7_FILENT",.F.)		,NIL},; // Filial de Entrega
							{"C7_FRETE"	,	CriaVar("C7_FRETE",.F.)		,NIL},; // Frete
							{"C7_DESPESA"	,	CriaVar("C7_DESPESA",.F.)	,NIL},; // Despesa
							{"C7_SEGURO"	,	CriaVar("C7_SEGURO",.F.)		,NIL},; // Seguro
							{"C7_MSG"		,	CriaVar("C7_MSG",.F.)		,NIL},; // Mensagem
							{"C7_REAJUST"	,	CriaVar("C7_REAJUST",.F.)	,NIL},; // Reajuste
							{"ALCADA"		,	cAlc							,NIL},; // Alcada
							{"MED_GCT"		,	"GCT"							,NIL},; // Reajuste
							{"C7_MOEDA"	,	CND->CND_MOEDA				,NIL}}  // Moeda
				If CN9->CN9_MOEDA == 1
					aAdd(aCab,{"C7_TXMOEDA",If(CND->CND_MOEDA!=1,xMoeda(1,CND->CND_MOEDA,1,dDataBase,TamSx3("C7_TXMOEDA")[2],,nTaxa),1),NIL}) // Taxa de Conversao
				Else
					aAdd(aCab,{"C7_TXMOEDA",If(CND->CND_MOEDA!=1,xMoeda(1,CND->CND_MOEDA,1,dDataBase,TamSx3("C7_TXMOEDA")[2],nTaxa),1),NIL}) // Taxa de Conversao		
				EndIf
			EndIf
			If nTpDoc # 1 //-- Se gera titulo, prepara array pra ExecAuto
				aTitulo :={	{"E2_FORNECE"	,	CND->CND_FORNEC  				,NIL},; // Fornecedor
								{"E2_LOJA"		,	CND->CND_LJFORN				,NIL},; // Loja do Fornecedor
								{"E2_ORIGEM"	,	"CNTA120"						,NIL},; // Origem
								{"E2_EMISSAO"	,	dDataBase						,NIL},; // Emissão
								{"E2_VENCTO" 	,	dDataBase						,NIL},; // Vencimento
								{"E2_VENCREA"	,	DataValida( dDataBase )		,NIL},; // Vencimento Real
								{"E2_VENCORI"	,	DataValida( Ddatabase,.T.)	,NIL},; // Vencimento Origem
								{"E2_MOEDA"  	,	CND->CND_MOEDA				,NIL},; // Moeda
								{"E2_MDCONTR"	,	CND->CND_CONTRA				,NIL},; // Numero do Contrato
								{"E2_MDREVIS"	,	CND->CND_REVISA				,NIL},; // Revisão do Contrato
								{"E2_MEDNUME"	,	CND->CND_NUMMED				,NIL},; // Numero da Medição
								{"E2_MDPLANI"	,	CND->CND_NUMERO				,NIL}}  // Numero da planilha
			EndIf
		Else
			If nTpDoc # 2 //-- Se gera pedido monta cabeçalho
				aVend := CtaVend(CND->CND_CONTRA) //Carrega vendedores do contrato
				If Empty(cNumPed) //Gera numero do pedido de venda
					cNumSC5 := GetSXENum("SC5","C5_NUM")
				EndIf
				RollBAckSx8()
				//Efetua montagem do aCab usado para geração de pedido de venda
				aCab:={	{"C5_NUM"		,	cNumSC5			,Nil},; 	// Numero do pedido
							{"C5_TIPO"   	,	"N"					,Nil},; 	// Tipo de pedido
							{"C5_CLIENTE"	,	CND->CND_CLIENT	,Nil},; 	// Codigo do cliente
							{"C5_LOJAENT"	,	CND->CND_LOJACL	,Nil},; 	// Loja para entrada
							{"C5_LOJACLI"	,	CND->CND_LOJACL	,Nil},; 	// Loja do cliente
							{"C5_EMISSAO"	,	dDatabase			,Nil},; 	// Data de emissao
							{"C5_CONDPAG"	,	CND->CND_CONDPG	,Nil},; 	// Codigo da condicao de pagamanto*
							{"C5_MOEDA"  	,	CND->CND_MOEDA	,Nil},; 	// Moeda
							{"C5_MDCONTR"	,	CND->CND_CONTRA	,Nil},;	// Cod. do Contrato
							{"C5_MDNUMED"	,	CND->CND_NUMMED	,Nil},;	// Codigo da Medicao
							{"C5_MDPLANI"	,	CND->CND_NUMERO	,Nil}} 	// Numero da Planilha
			
				If CN9->CN9_MOEDA == 1
					aAdd(aCab,{"C5_TXMOEDA",If(CND->CND_MOEDA!=1,xMoeda(1,CND->CND_MOEDA,1,dDataBase,TamSx3("C5_TXMOEDA")[2],,nTaxa),1),NIL}) // Taxa de Conversao
				Else
					aAdd(aCab,{"C5_TXMOEDA",If(CND->CND_MOEDA!=1,xMoeda(1,CND->CND_MOEDA,1,dDataBase,TamSx3("C5_TXMOEDA")[2],nTaxa),1),NIL}) // Taxa de Conversao		
				EndIf
				cVend := "1"
				For nx:=1 to Len(aVend) //Preenche os vendedores de acordo com o contrato 
					aAdd(aCab,{"C5_VEND"+cVend,aVend[nx,1],NIL})
					aAdd(aCab,{"C5_COMIS"+cVend,aVend[nx,2],NIL})
					cVend:=Soma1(cVend)
				Next             
				dbSelectArea("SE4")
				dbSetOrder(1)
				MsSeek(xFilial("SE4")+CND->CND_CONDPG) 
				If SE4->E4_TIPO=='9' //Preenche as Parcelas e Vencimentos  se condição de pagamento for do tipo 9
					For nX:=1 to nParcelas    
						If !Empty(CND->(FieldPos("CND_PARC"+Substr(cParcela,nx,1)))) .And. !Empty(CND->(FieldPos("CND_DATA"+Substr(cParcela,nx,1))))
							aAdd(aCab,{"C5_PARC"+Substr(cParcela,nx,1),&("CND->CND_PARC"+Substr(cParcela,nx,1)),NIL})
							aAdd(aCab,{"C5_DATA"+Substr(cParcela,nx,1),&("CND->CND_DATA"+Substr(cParcela,nx,1)),NIL}) 
						EndIf
					Next nX   
				EndIf
			EndIf
			If nTpDoc # 1 //-- Se gera titulo prepara array para ExecAuto
				aTitulo :={	{"E1_CLIENTE"	,	CND->CND_CLIENT  				,NIL},; // Cliente
								{"E1_LOJA"		,	CND->CND_LOJACL				,NIL},; // Loja do Cliente
								{"E1_ORIGEM"	,	"CNTA120"						,NIL},; // Origem
								{"E1_EMISSAO"	,	dDataBase						,NIL},; // Emissão
								{"E1_VENCTO" 	,	dDataBase						,NIL},; // Vencimento
								{"E1_VENCREA"	,	DataValida( dDataBase )		,NIL},; // Vencimento Real
								{"E1_VENCORI"	,	DataValida( Ddatabase,.T.)	,NIL},; // Vencimento Origem
								{"E1_MOEDA"  	,	CND->CND_MOEDA				,NIL},; // Moeda
								{"E1_MDCONTR"	,	CND->CND_CONTRA				,NIL},; // Numero do Contrato
								{"E1_MDREVIS"	,	CND->CND_REVISA				,NIL},; // Revisão do Contrato
								{"E1_MEDNUME"	,	CND->CND_NUMMED				,NIL},; // Numero da Medição
								{"E1_MDPLANI"	,	CND->CND_NUMERO				,NIL}}  // Numero da planilha
			EndIf
		EndIf
		nDifPreco := 0
		nDifValor := 0
		
		CN9->(dbSetOrder(1))
		CN9->(dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA))
		
		While !(cAliasCNE)->(Eof()) //Itens da Medição    
			CNE->(MsGoTo((cAliasCNE)->RECNO))			
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			//Regras de aplicação de multa, desconto e bonificação
			//Contratos de Compra:
			//Multas		(Desconto) 
			//Bonificação	(Acréscimo) 
			//Desconto		(Desconto) 
			//Adiantamento(Desconto)
			//Contratos de Venda:
			//Multas		(Acréscimo) 
			//Bonificação	(Desconto)
			//Desconto		(Desconto)  
			//Adiantamento(Desconto)
			If SB1->(MSSeek(xFilial("SB1")+CNE->CNE_PRODUT))
				If CNE->CNE_VLTOT > 0
					nDecrUn     := (CNE->CNE_VLUNIT * nRateio)/100  
					nDecrUnBon  := ((CNE->CNE_VLUNIT * nRatBoni)/100) 
					nDecrUnMul  := ((CNE->CNE_VLUNIT * nRatMult)/100)
					If cTpRat == "1" 
						//Tipo de rateio dos descontos da medicao. 
						//1=Subtrai do valor unitario.
						//2=Soma no valor de descontos do item.
						nQuantArred := A410Arred( CNE->CNE_QUANT, If(cEspCtr=="1","C7_QUANT","C6_QTDVEN") )
						If(cEspCtr=="1")
							nPrecoCalc  := CNE->CNE_VLUNIT - nDecrUn + nDecrUnBon - nDecrUnMul    
						Else					
							nPrecoCalc  := CNE->CNE_VLUNIT - nDecrUn - nDecrUnBon + nDecrUnMul
						EndIf
						nPrecoArred := A410Arred( nPrecoCalc, If(cEspCtr=="1","C7_TOTAL","C6_VALOR") )
						nValorOri   := nPrecoCalc * CNE->CNE_QUANT
						nValorArred := A410Arred( nPrecoArred * nQuantArred,  If(cEspCtr=="1","C7_TOTAL","C6_VALOR") )
						nDifValor   += ( nValorArred - nValorOri )
					Else
						nQuantArred := A410Arred( CNE->CNE_QUANT, If(cEspCtr=="1","C7_QUANT","C6_QTDVEN") )
						If(cEspCtr=="1") 
							nPrecoCalc  := CNE->CNE_VLUNIT + nDecrUnBon - nDecrUnMul    
						Else					
							nPrecoCalc  := CNE->CNE_VLUNIT - nDecrUnBon + nDecrUnMul
						EndIf
						If lExcede
							nPrecoArred := A410Arred(CNE->CNE_VLUNIT, If(cEspCtr=="1","C7_PRECO","C6_PRCVEN") )
							nValorOri   := CNE->CNE_VLUNIT * CNE->CNE_QUANT
						Else
							nPrecoArred := A410Arred( nPrecoCalc, If(cEspCtr=="1","C7_PRECO","C6_PRCVEN") )
							nValorOri   := nPrecoCalc * CNE->CNE_QUANT
						EndIf
						nValorArred := A410Arred( nPrecoArred * nQuantArred,  If(cEspCtr=="1","C7_TOTAL","C6_VALOR") )
						nDifValor   += (nValorArred - nValorOri)
						nVlItDesc   := A410Arred(CNE->CNE_VLDESC+(nDecrUn*CNE->CNE_QUANT),  If(cEspCtr=="1","C7_TOTAL","C6_VALOR"))
					EndIf
					
					CNB->(dbSetOrder(1)) //Posiciona CNB para leitura de campos
					CNB->(dbSeek(cFilCNB+CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM)))
					
					If nVlItDesc < nValorArred
						If cEspCtr=="1"
							If CNE->(FieldPos("CNE_PEDTIT")) == 0 .Or. CNE->CNE_PEDTIT == "1" //Se o item está marcado para gerar pedido
								aAdd(aItem,{}) //Gera item do pedido de compra
								
								cC7Item := StrZero(Val(CNE->CNE_ITEM),TamSX3("C7_ITEM")[1])
								
								aAdd(aTail(aItem)	,{"C7_ITEM"		,StrZero(Val(CNE->CNE_ITEM),TamSX3("C7_ITEM")[1]),NIL})	//Item
								aAdd(aTail(aItem)	,{"C7_PRODUTO"	,CNE->CNE_PRODUT										,NIL}) //Produto
								
								If lExistOri .And. !Empty(CNB->CNB_FILORI)
									aAdd(aTail(aItem),{"C7_FISCORI",CNB->CNB_FILORI,NIL}) 			//Filial de origem da SC
								EndIf    
								
								If !Empty(CNB->CNB_NUMSC)
									aAdd(aTail(aItem)	,{"C7_NUMSC"		,CNB->CNB_NUMSC										,NIL}) //Solicitacao
									aAdd(aTail(aItem)	,{"C7_ITEMSC"		,CNB->CNB_ITEMSC										,NIL})	//Item solicitacao
								EndIf
								If !Empty(CNB->CNB_DESCRI)
									aAdd(aTail(aItem)	,{"C7_DESCRI"		,CNB->CNB_DESCRI										,NIL}) //Descricao
								EndIf
								aAdd(aTail(aItem)	,{"C7_QUANT"		,nQuantArred											,NIL}) //Quantidade
								aAdd(aTail(aItem)	,{"C7_QTDSOL"		,nQuantArred											,NIL})	//Quantidade solicitada
								aAdd(aTail(aItem)	,{"C7_UM"			,SB1->B1_UM											,NIL}) //Unidade de Medida
								aAdd(aTail(aItem)	,{"C7_QTSEGUM"	,ConvUm(SB1->B1_COD,nQuantArred,0,2)				,NIL})	//Segunda unidade de medida
								aAdd(aTail(aItem)	,{"C7_PRECO"		,nPrecoArred											,NIL}) //Preco unitario
								aAdd(aTail(aItem)	,{"C7_TOTAL"		,nValorArred											,NIL}) //Valor total
								aAdd(aTail(aItem)	,{"C7_IPI"			,SB1->B1_IPI											,NIL}) //IPI
								aAdd(aTail(aItem)	,{"C7_REAJUST"	,CriaVar("C7_REAJUST",.F.)							,NIL})	//Reajuste
								aAdd(aTail(aItem)	,{"C7_FRETE"		,CriaVar("C7_FRETE",.F.)								,NIL}) //Frete
								aAdd(aTail(aItem)	,{"C7_DATPRF"		,CNE->CNE_DTENT										,NIL}) //Data de entrega
								aAdd(aTail(aItem)	,{"C7_LOCAL"		,SB1->B1_LOCPAD										,NIL}) //Local
								aAdd(aTail(aItem)	,{"C7_MSG"			,CriaVar("C7_MSG",.F.)								,NIL}) //Mensagem
								aAdd(aTail(aItem)	,{"C7_TPFRETE"	,CriaVar("C7_TPFRETE",.F.)							,NIL}) //Tipo de frete
								aAdd(aTail(aItem)	,{"C7_OBS"			,CriaVar("C7_OBS",.F.)								,NIL}) //Observacao
								aAdd(aTail(aItem)	,{"C7_DESCRI"		,SB1->B1_DESC											,NIL}) //Descricao
								aAdd(aTail(aItem)	,{"C7_SEQMRP"		,CriaVar("C7_SEQMRP",.F.)							,Nil}) //Sequencia MRP						
								aAdd(aTail(aItem)	,{"C7_TES"			,IIF(lExistTE,CNE->CNE_TE,SB1->B1_TE),Nil}) // TES
								aAdd(aTail(aItem)	,{"C7_ITEMED"		,CNE->CNE_ITEM										,Nil}) //Item da Medicao
								aAdd(aTail(aItem)	,{"C7_VLDESC"		,nVlItDesc												,NIL}) //Desconto Item
	
								If lExistCC
									aAdd(aTail(aItem)	,{"C7_CC"			,CNE->CNE_CC											,NIL}) //Centro de custo
									aAdd(aTail(aItem)	,{"C7_CONTA"		,CNE->CNE_CONTA										,NIL}) //Conta
									aAdd(aTail(aItem)	,{"C7_ITEMCTA"	,CNE->CNE_ITEMCTA										,NIL}) //Item de conta
									aAdd(aTail(aItem)	,{"C7_CLVL"		,CNE->CNE_CLVL										,NIL})	//Classe de valor
								Else
									aAdd(aTail(aItem)	,{"C7_CC"			,SB1->B1_CC											,NIL}) //Centro de custo
									aAdd(aTail(aItem)	,{"C7_CONTA"		,SB1->B1_CONTA										,NIL}) //Conta
									aAdd(aTail(aItem)	,{"C7_ITEMCTA"	,SB1->B1_ITEMCC										,NIL}) //Item de Conta
									aAdd(aTail(aItem)	,{"C7_CLVL"		,SB1->B1_CLVL											,NIL})	//Classe de valor
								EndIf
								
								For nX := 1 To Len(aCTBEnt) //Entidades Contabeis
									If SC7->(FieldPos("C7_EC"+aCTBEnt[nX]+"CR")) > 0
										If CNE->(FieldPos("CNE_EC"+aCTBEnt[nX]+"CR")) > 0
											aAdd(aTail(aItem)	,{"C7_EC"+aCTBEnt[nX]+"CR"	,CNE->&("CNE_EC"+aCTBEnt[nX]+"CR")					,NIL}) //Entidades Contabeis Credito
											aAdd(aTail(aItem)	,{"C7_EC"+aCTBEnt[nX]+"DB"	,CNE->&("CNE_EC"+aCTBEnt[nX]+"DB")					,NIL}) //Entidades Contabeis Debito
										Else
											aAdd(aTail(aItem),{"C7_EC"+aCTBEnt[nX]+"CR"	,SB1->&("B1_EC"+aCTBEnt[nX]+"CR")					,NIL}) //Entidades Contabeis Credito
											aAdd(aTail(aItem),{"C7_EC"+aCTBEnt[nX]+"DB"	,SB1->&("B1_EC"+aCTBEnt[nX]+"DB")					,NIL}) //Entidades Contabeis Debito
										EndIf
									EndIf
								Next nX
								
								//-- Rateio do PC														
								If AliasInDic("CNZ") .And. AliasInDic("AGG")
									Aadd(aRatGCT,CN120GetRa(CNE->CNE_CONTRA,CNE->CNE_NUMMED,CNE->CNE_REVISA,CNE->CNE_ITEM,{"fornecedor",CND->CND_FORNEC,CND->CND_LJFORN},cC7Item))
								Endif
							Else
								nAcres += nDecrUnBon * CNE->CNE_QUANT //-- Computa acrescimo no titulo 
								nDecres += ((nDecrUn + nDecrUnMul) * CNE->CNE_QUANT) + CNE->CNE_VLDESC //-- Computa decrescimo no valor do titulo  
								nVlrTitulo += CNE->CNE_VLTOT //-- Soma valores dos itens da medição
							EndIf
						Else
							If CNE->( FieldPos( "CNE_PEDTIT" ) ) == 0 .Or. CNE->CNE_PEDTIT == "1"
								cItemSC6 := If(Empty(cItemSC6),strZero(1,TamSX3("C6_ITEM")[1]),Soma1(cItemSC6))//Atualiza sequencia do item
								
								If lExistTS .And. !Empty(CNE->CNE_TS) //Atualiza o campo TS dos itens da medição  
									cTes := CNE->CNE_TS
								Else
								   	cTes := SB1->B1_TS
							   	EndIf
							   	
								If Empty(cTes)
								   lRet := .F.
								   Exit
								ElseIf !SF4->(dbSeek(xFilial('SF4') + cTes))
									Help( " ", 1, 'NOTESFILIAL' )
									lRet:= .F.
									Exit								
								EndIf
								
								aAdd(aItem,{}) //Gera item do pedido de venda
								aAdd(aTail(aItem)	,{"C6_NUM"			,cNumSC5												,Nil}) // Numero do Pedido
								aAdd(aTail(aItem)	,{"C6_ITEM"		,cItemSC6												,Nil}) // Numero do Item no Pedido
								aAdd(aTail(aItem)	,{"C6_PRODUTO"	,CNE->CNE_PRODUT										,Nil}) // Codigo do Produto
								If !Empty(CNB->CNB_DESCRI)
									aAdd(aTail(aItem)	,{"C6_DESCRI"		,CNB->CNB_DESCRI										,NIL})	// Descricao
								EndIf
								aAdd(aTail(aItem)	,{"C6_QTDVEN"		,nQuantArred											,Nil}) // Quantidade Vendida
								aAdd(aTail(aItem)	,{"C6_PRUNIT"		,nPrecoArred											,Nil}) // PRECO DE LISTA
								aAdd(aTail(aItem)	,{"C6_PRCVEN"		,nPrecoArred											,Nil}) // Preco Unitario Liquido
								aAdd(aTail(aItem)	,{"C6_VALOR"		,nValorArred											,Nil}) // Valor Total do Item
								aAdd(aTail(aItem)	,{"C6_ENTREG"		,CNE->CNE_DTENT										,Nil}) // Data da Entrega
								aAdd(aTail(aItem)	,{"C6_UM"			,SB1->B1_UM											,Nil}) // Unidade de Medida Primar.
								aAdd(aTail(aItem)	,{"C6_CLI"			,CND->CND_CLIENT										,Nil}) // Cliente
								aAdd(aTail(aItem)	,{"C6_LOJA"		,CND->CND_LOJACL										,Nil}) // Loja do Cliente
							 	aAdd(aTail(aItem)	,{"C6_TES"			,cTes													,Nil}) // TES
								aAdd(aTail(aItem)	,{"C6_LOCAL"		,SB1->B1_LOCPAD										,Nil}) // Local
								aAdd(aTail(aItem)	,{"C6_DESCRI"		,SB1->B1_DESC											,Nil}) // Descricao
								aAdd(aTail(aItem)	,{"C6_ITEMED"		,CNE->CNE_ITEM										,Nil}) // Item da Medicao
								aAdd(aTail(aItem)	,{"C6_VALDESC"	,nVlItDesc												,Nil}) // Desconto Item	
								If AliasInDic("CNZ") .And. AliasInDic("AGG") //Rateio do Pedido de Venda
									aADD(aRatGCT	,Array(2))                       
									aRatGCT[len(aRatGCT)][1] := cItemSC6
									aRatGCT[len(aRatGCT)][2] := {}
									aRatGCT[len(aRatGCT)][2] := CN120GetRa(CNE->CNE_CONTRA,CNE->CNE_NUMMED,CNE->CNE_REVISA,CNE->CNE_ITEM,{STR0082,CNA->CNA_CLIENT,CNA->CNA_LOJACL},cItemSC6) //"cliente"						
									If Empty(aRatGCT[len(aRatGCT)][2]) //Limpa o array se o centro de custo estiver vazio 
										aRatGCT := {}
									EndIf	
								Endif
								If CNE->CNE_FLGCMS == "1" //Verifica se o item e comissionado 
									cVend:="1"
									For nx:=1 to len(aVend) //Complementa as comissoes de acordo com os contratos
										aAdd(aItem[len(aItem)],{"C6_COMIS"+cVend,aVend[nx,2],NIL})
										cVend:=Soma1(cVend)
									Next
								EndIf
								If lPrjCni
									If ExistBlock("CN120IT7") //PE para adicionar campos no item da SC7
								 		aItem := ExecBlock("CN120IT7",.F.,.F.,{aItem})
									EndIf	 
								EndIf
							Else
								nAcres += nDecrUnMul * CNE->CNE_QUANT //-- Computa acrescimo no titulo 
								nDecres += ((nDecrUn + nDecrUnBon) * CNE->CNE_QUANT) + CNE->CNE_VLDESC //-- Computa desconto no titulo 
								nVlrTitulo += CNE->CNE_VLTOT //-- Soma valores dos itens da medição
							EndIf
						EndIf    										
					EndIf		
				EndIf
	   			//Chama ponto de entrada para tratamento de campos
				//especificos por item na geracao do pedido de compra
				//ou vendas
				If lCN120ITM
					aCN120ITM := ExecBlock("CN120ITM",.f.,.f.,{aCab,aItem,cAliasCNE})
					If Valtype(aCN120ITM) == "A"
						aCab := aCN120ITM[1]
						aItem:= aCN120ITM[2]
					EndIf
				EndIf
				(cAliasCNE)->(dbskip())
			Else
				(cAliasCNE)->(dbskip())			
			EndIf      
			//Transfere a diferenca dos arredondamentos quando houver
			If (cAliasCNE)->(Eof()) .And. !Empty( nDifValor )
				If (ValType(aItem)=="A" .And. Len(aItem)>0)
					//Ajusta o valor total e valor unitario do ultimo item
					nPosTotCpo := aScan(aItem[len(aItem)],{|x| x[1] == If((cEspCtr=="1"),"C7_TOTAL","C6_VALOR")})
					nPosUniCpo := aScan(aItem[len(aItem)],{|x| x[1] == If((cEspCtr=="1"),"C7_PRECO","C6_PRUNIT")})
					nPosVenCpo := aScan(aItem[len(aItem)],{|x| x[1] == "C6_PRCVEN"})
					nValQuant  := aItem[ Len( aItem ), aScan(aItem[len(aItem)],{|x| x[1] == If((cEspCtr=="1"),"C7_QUANT","C6_QTDVEN")} ), 2 ]
					If nPosTotCpo > 0 .And. nPosUniCpo > 0						
						nValTot := A410Arred(aItem[len(aItem),nPosTotCpo,2]-nDifValor,If(cEspCtr=="1","C7_TOTAL","C6_VALOR"))
						nValUni := A410Arred(nValTot / nValQuant,If(cEspCtr=="1","C7_PRECO","C6_PRUNIT"))
						aItem[len(aItem),nPosUniCpo,2] := nValUni                                             
						aItem[len(aItem),nPosTotCpo,2] := A410Arred(nValUni * nValQuant,If(cEspCtr=="1","C7_TOTAL","C6_VALOR")) 
						If cEspCtr=="2"					
							If nPosVenCpo > 0
								aItem[len(aItem),nPosVenCpo,2] := nValUni
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndDo
		If !lRet
			Exit
		EndIf
		//Chama ponto de entrada para tratamento de campos
		//especificos na geracao do pedido de compra
		If ExistBlock("CN120PED")
			aRet := ExecBlock("CN120PED",.f.,.f.,{aCab,aItem,cAliasCNE})
			If Valtype(aRet) == "A"
				aCab := aRet[1]
				aItem:= aRet[2]
			EndIf
		EndIf
		//Executa rotina automatica para geracao dos documentos
		If (ValType(aCab)=="A" .And. Len(aCab)>0) .And. (ValType(aItem)=="A" .And. Len(aItem)>0)
			lMsErroAuto := Iif(Type("lMsErroAuto")=='L',lMsErroAuto,.F.)	
			If cEspCtr=="1" //Gera pedido de compra		
				//Ajusta array do rateio por Centro de Custo 
				//para rotina automática do Pedido de Compras
				For nX:= 1 to Len(aRatGCT)				
					For nY := 1 to Len(aRatGCT[nX])  
						nZ++ 
						aAdd(aRatPedGCT,{})
						aRatPedGCT[nZ] := aRatGCT[nX,nY]
					Next nY
				Next nX                              
				nX:= 0
				nY:= 0
				If lPrjCni
					If ExistBlock("CN120AEP")//// Ponto de Entrada para alterar filial antes de processar o pedido de compra
						 ExecBlock("CN120AEP",.F.,.F.)
					EndIf
				EndIf
				cNumPed := cNumSC7
				MSExecAuto({|v,x,y,z,w,a| MATA120(v,x,y,z,w,a)},1,aCab,aItem,3,.F.,aRatPedGCT)          
			Else //Gera pedido de venda
				MSExecAuto({|x,y,z,w| Mata410(x,y,z,,,,,w)},aCab,aItem,3,aRatGCT)
				cNumPed := SC5->C5_NUM
			EndIf
			Pergunte("CNT120",.F.)
			lRet := !lMsErroAuto      
			If lMsErroAuto
				MostraErro()
			Endif
		EndIf
		
		If nTpDoc # 1 //-- Se gera titulo
			If cEspCtr=="1" //-- Gera titulo a pagar (SE2)
				aAdd(aTitulo,{"E2_VALOR",nVlrTitulo,Nil})
				If (nAcres - nDecres) > 0
					aAdd(aTitulo,{"E2_ACRESC",nAcres - nDecres,Nil})
				ElseIf (nDecres - nAcres) > 0
					aAdd(aTitulo,{"E2_DECRESC",nDecres - nAcres,Nil})
				EndIf
				lRet := C120TitSE2(aTitulo,@cNumTit)
			Else //-- Gera titulo a receber (SE1)
				aAdd(aTitulo,{"E1_VALOR",nVlrTitulo,Nil})
				If (nAcres - nDecres) > 0
					aAdd(aTitulo,{"E1_ACRESC",nAcres - nDecres	,Nil})
				ElseIf (nDecres - nAcres) > 0
					aAdd(aTitulo,{"E1_DECRESC",nDecres - nAcres,Nil})
				EndIf
				lRet := C120TitSE1(aTitulo,@cNumTit)
			EndIf
		EndIf
		If ExistBlock("CN120PDM") //Executa ponto de entrada após execução do MSExecAuto 
		   lCN120PDM := ExecBlock("CN120PDM",.F.,.F.,{lRet})  
		  	If ValType(lCN120PDM) == "L"
				lRet := lCN120PDM
			EndIf
		EndIf
	EndIf 

	If lRet              
		If ValType(aItem)=="A" .And. Len(aItem)>0
			If cEspCtr == "1" //Seleciona pedido de compra criado
				nPosItemed := aScan(aItem[len(aItem)],{|x| x[1] == "C7_ITEMED"})
				cQuery := "SELECT SC7.R_E_C_N_O_ as RECNO,SC7.C7_ITEM "
				cQuery += "  FROM "+ RetSQLName("SC7") +" SC7 "
				cQuery += " WHERE SC7.C7_FILIAL  = '"+ xFilial("SC7") +"'"
				cQuery += "   AND SC7.C7_NUM     = '"+ cNumSC7 +"'"
				cQuery += "   AND SC7.D_E_L_E_T_ = ''"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSC7",.F.,.F.)				
				dbSelectArea("SC7")
				While !TRBSC7->(Eof()) //Preenche campos especificos do SIGAGCT    
					nY++
					MsGoTo(TRBSC7->RECNO)
					RecLock("SC7",.F.)
						SC7->C7_CONTRA  := CND->CND_CONTRA
						SC7->C7_CONTREV := cNRevisa
						SC7->C7_PLANILH := CND->CND_NUMERO
						SC7->C7_MEDICAO := CND->CND_NUMMED
						SC7->C7_ITEMED  := aItem[nY,nPosItemed,2]
						If	!Empty(cCodEdt) .And. !Empty(cNumPro)
							SC7->C7_CODED := cCodEdt
							SC7->C7_NUMPR := cNumPro
						EndIf
					MsUnlock()
					If lPrjCni //Na Inclusão do Pedido o Log ja e gravado
						RSTSCLOG("PED",5,/*cUser */,SC7->(C7_NUM+C7_ITEM))
					EndIf
					TRBSC7->(dbSkip())
				EndDo

				If lPrjCni
					If ExistBlock("CN120GSC") //PE para gravar informações na SC7
						ExecBlock("CN120GSC",.F.,.F.)
					EndIf
				EndIf
				TRBSC7->(dbCloseArea())
				If lPrjCni
					//Correcao no vinculo PC x SC
					If SC7->(dbSeek(xFilial("SC7")+cNumPed))    
					                          
						If !Empty(CN9->CN9_XSCORI) .AND. AllTrim(CN9->CN9_XSC) == "1" //Se foi gerado por SC
							cExpQry := " AND C1_NUM = '" + CN9->CN9_XSCORI + "' "
						ElseIf !Empty(CN9->CN9_CODED) //Se foi gerado por Edital
	     					cExpQry := " AND C1_CODED = '" + CN9->CN9_CODED + "' AND C1_NUMPR = '" + CN9->CN9_NUMPR + "' "
						ElseIf !Empty(CN9->CN9_XCOT) //Se foi gerado por Cotacao
	                       	cExpQry := " AND C1_COTACAO = '" + CN9->CN9_XCOT + "' "
						ElseIf CN9->CN9_XREGP == "1" .AND. OnStack("U_CNI109AL") //Se for contrato de registro de preco e a medicao estiver ocorrendo na liberacao da SC
							cExpQry := " AND C1_NUM = '" + SC1->C1_NUM + "' AND C1_ITEM = '" + SC1->C1_ITEM + "' "
						Else
							cExpQry := ""
						EndIf
						
						If !Empty(cExpQry)
							cExpQry := "%"+cExpQry+"%"
		                            
							BeginSQL Alias "SC1TMP"
								SELECT C1_NUM, C1_ITEM, C1_PRODUTO
								FROM %Table:SC1% SC1
								WHERE C1_FILIAL = %xFilial:SC1% %Exp:cExpQry% AND SC1.%NotDel%
							EndSQL
										
							While (SC7->(C7_FILIAL+C7_NUM) == (xFilial("SC7")+cNumPed))  
								SC1TMP->(dbGoTop())								
								While !SC1TMP->(EOF())
									If SC7->C7_PRODUTO == SC1TMP->C1_PRODUTO									   
										If !OnStack("U_CNI109AL")// Não gravar o número da SC e Item se vier da liberação da SC, pois já gravou quando estava posicionado		
											RecLock("SC7",.F.)
												SC7->C7_NUMSC := SC1TMP->C1_NUM
												SC7->C7_ITEMSC := SC1TMP->C1_ITEM
											MsUnlock()
										EndIf
										
										DbSelectArea("SC1")
										SC1->(DbSetOrder(1))  // Bruna - O indice estava posicionado no segundo indice, reposiciona no primeiro para encontrar a SC1
										SC1->(DbGoTop())
										If (SC1->(dbSeek(xFilial("SC1")+SC1TMP->C1_NUM+SC1TMP->C1_ITEM)))
											RecLock("SC1",.F.)
												SC1->C1_PEDIDO := cNumPed
											MsUnlock()
										EndIf										
									EndIf
									
									DbSelectArea("SC1TMP")		
									SC1TMP->(dbSkip())	
								EndDo
								SC7->(dbSkip())	
							EndDo
							SC1TMP->(dbCloseArea())
						EndIf
					EndIf				
				EndIf
			EndIf   
		EndIf

		If lPrjCni
			// FSW - PE para alterar filial depois de processar o pedido de compra
			If ExistBlock("CN120ADP")
				ExecBlock("CN120ADP",.F.,.F.)
			EndIf		
		EndIf
		// Atualiza codigo do pedido e titulo que foram gerados
		If !lExcede .And. lExistPed
			RecLock("CND",.F.)
				CND->CND_PEDIDO := cNumPed
				If !Empty(CND->(FieldPos("CND_NUMTIT"))) 
					CND->CND_NUMTIT := cNumTit
				EndIf
			MsUnlock()
		EndIf
		//Atualiza o campo CNE_PEDIDO dos itens da medicao
		//com o codigo do pedido gerado		
		(cAliasCNE)->(dbGoTop())
		While !(cAliasCNE)->(Eof())
			CNE->(MsGoTo( ( cAliasCNE)->RECNO ) )
			If !lExcede .Or. (CNE->CNE_EXCEDE == '1' .And. Empty(CNE->CNE_PEDIDO))
				If !Empty(CNE->(FieldPos("CNE_PEDTIT"))) .And. CNE->CNE_PEDTIT == '2' //Baixa o saldo a receber da planilha 
					CtaAvalGCT(1,{},CNE->CNE_CONTRA,CNE->CNE_NUMERO,CNE->CNE_ITEM,CNE->CNE_QUANT,,CNE->CNE_NUMMED,CNE->CNE_VLTOT)
				Else
					RecLock("CNE",.F.)
					CNE->CNE_PEDIDO := cNumPED
					MsUnlock()
				EndIf
			EndIf
			(cAliasCNE)->(dbSkip())
		EndDo

		If lPrjCni
			// FSW - Criação de Ponto de Entrada para gravar o número do pedido na medição 
			// Somente para pedidos de compra 
			If ExistBlock("CN120GPM") .And. cEspCtr=="1" .And. lRet
				ExecBlock("CN120GPM",.F.,.F.,{cNumSC7,cNumPed})
			EndIf		
		EndIf
		//Verifica se o recurso de multa / bonificacao esta disponivel para a medicao
		If !lExcede .And. !Empty( CN4->( FieldPos( "CN4_VLDALT" ) ) )
			//Obtem o valor de multa e/ou bonificacao da medicao
			cAliasCNR := GetNextAlias()
			cQuery := "SELECT CNR_VALOR, CNR_DESCRI, CNR_TIPO "
			If lCtMulBoni
				cQuery += "  ,CNR_CONTRA "
			EndIf
			cQuery += "  FROM " + RetSqlName("CNR")
			cQuery += " WHERE CNR_NUMMED='" + cNumMed + "'"
			cQuery += "   AND D_E_L_E_T_=' '"
			
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasCNR, .F., .T. )
			TcSetField( cAliasCNR, "CNR_VALOR", "N", 18, 2 ) //Acerta o campo numerico 
			
			aMultas := {}
			While !( cAliasCNR )->( Eof() )
				If lCtMulBoni
					If !Empty(( cAliasCNR )->CNR_CONTRA) .And. (( cAliasCNR )->CNR_CONTRA) <> CND->CND_CONTRA 
						( cAliasCNR )->( dbSkip() )
						Loop  
					EndIf
				EndIf     

				AAdd( aMultas, { ( cAliasCNR )->CNR_VALOR,( cAliasCNR )->CNR_DESCRI,( cAliasCNR )->CNR_TIPO } )
				( cAliasCNR )->( dbSkip() )
			EndDo
			( cAliasCNR )->( dbCloseArea() )
			dbSelectArea( "CNR" )
			
			If lExistCNG// Verifica o campo CNG_NUMMED para armaz. historico
				CN120HistMul( 1, aMultas, CND->CND_CONTRA, CND->CND_NUMMED )
			EndIf
			
		EndIf

		If !lExcede .And. lExistCau .And. !Empty(CND->CND_RETCAC) //Grava retencao da caucao
			CN120CaucRet(CND->CND_CONTRA,CND->CND_NUMMED,1,CND->CND_RETCAC)
		EndIf
	EndIf
	(cAliasCNE)->(dbCloseArea())
	(cAliasCND)->(dbSkip())
EndDo
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120CaucRet³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava o valor retido da caucao com base no valor da medicao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CN120CaucRet(cExp01,cExp02,nExp03,nExp04)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cExp01 - Codigo do contrato                                ³±±
±±³          ³  cExp02 - Codigo do medicao                                 ³±±
±±³          ³  nExp03 - (1-Incluir,2-Excluir)                             ³±±
±±³          ³  nExp04 - Valor retido                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120CaucRet(cContra,cMedicao,nOpc,nVlRet)
Local cQuery      := ""
Local cAliasCNT   := ""
Local cLctoRet    := "695"
Local lCn120IncCa := ExistBlock("CN120INCCA")
Local lGrvCau     := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para indicar se grava ou não a   ³
//³retencao de caucao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120GRVCA")
	lGrvCau := ExecBlock("CN120GRVCA",.F.,.F.)
	If ValType(lGrvCau) <> "L"
		lGrvCau:=.T.
	EndIf
EndIf

If lGrvCau
	If nOpc==1//Inclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava retencao da caucao                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CNT")
		RecLock("CNT",.T.)
			CNT->CNT_FILIAL := xFilial("CNT",cFilCTR)
			CNT->CNT_CONTRA := cContra
			CNT->CNT_NUMMED := cMedicao
			CNT->CNT_VLRET  := Round(nVlRet,TamSX3("CNT_VLRET")[2])
			CNT->CNT_DTMED  := dDataBase
			CNT->CNT_FORNEC := CND->CND_FORNEC
			CNT->CNT_LJFORN := CND->CND_LJFORN
			CNT->CNT_CLIENT := CND->CND_CLIENT
			CNT->CNT_LOJACL := CND->CND_LOJACL
			If lCn120IncCa
				ExecBlock("CN120INCCA",.F.,.F.)
			Endif
		MsUnlock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa contabilizacao da retencao do contrato ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CN120Contab(cLctoRet)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona retencao da medicao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT CNT.R_E_C_N_O_ AS RECNO "
		cQuery += "  FROM "+RetSQLName("CNT")+" CNT "
		cQuery += " WHERE CNT.CNT_FILIAL = '"+xFilial("CNT",cFilCTR)+"'"
		cQuery += "   AND CNT.CNT_CONTRA = '"+cContra+"'"
		cQuery += "   AND CNT.CNT_NUMMED = '"+cMedicao+"'"
		cQuery += "   AND CNT.D_E_L_E_T_ = ' '"
		
		cAliasCNT := GetNextAlias()
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNT,.F.,.T.)
		
		dbSelectArea("CNT")
		While !(cAliasCNT)->(Eof())
			CNT->( MsGoTo( (cAliasCNT)->RECNO ) )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui retencao        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("CNT",.F.)
				CNT->( dbDelete() )
			CNT->( MsUnlock() )
			(cAliasCNT)->(dbSkip())
		EndDo
		
		(cAliasCNT)->(dbCloseArea())
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120MedEst³ Autor ³ Marcelo Custodio      ³ Data ³09.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estorna medicao, valida pedido de compra, medicoes zeradas  ³±±
±±³          ³ e saldo do contrato, planilhas e cronogramas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CN120MedEst(nExp01)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  nExp01 - Registro atual                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CN120MedEst(nReg,nAcao,lAviso,lAutoFor,lMedServ)
Local cQuery		:= ""
Local cNumSC7		:= ""
Local cNumSC5		:= ""
Local cNumTit		:= ""
Local cCronog		:= ""
Local cFilCod		:= ""
Local cEspCtr		:= ""
Local cAliasPed	:= ""
Local cParcel		:= ""
Local cAliasCNT	:= ""
Local cAliasQry	:= ""
Local cAliasSD1	:= ""
Local cAliasSE2	:= ""
Local cFilCND  	:= xFilial("CND")
Local cFilSC7  	:= xFilial("SC7")

Local lMedeve  := .F.
Local lContinua:= .T. 
Local lEstSld  := .T.
Local lEstPed  := .F.
Local lEstExce := .T.
Local lFisico  := .F.
Local lFixo    := .T.
Local lValor   := .T.
Local lPeSld   := ExistBlock("CN120ESSLD")
Local lVldVige := GetNewPar("MV_CNFVIGE","N") == "N"
Local lBloqSE2 := .F.
Local lRet     := .F.  
Local lGCTBloq := (SE2->(FieldPos("E2_MSBLQL")) > 0)

Local nTipo    := 1 //1 - Medicao;2 - Autorizacao de Fornecimento
Local nTaxa
Local nServico := 1 //1 - Medicao;2 - Medicao de Servico
Local nTpDoc	 := CN120VerDoc(CND->CND_NUMMED) //Verifica quais documentos foram gerados Pedidos/Titulos

Local uRet
Local dDtFim
Local aPVExce  := {}

Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

//Variaveis da contabilizacao
Local nHead			:= 0
Local nDet  		:= 0     							//Retorno da funcao DetProva
Local nI			:= 0

Local cArqGCT 		:= ""
Local cLoteGCT  	:= LoteCont("COM")  				//Numero do Lote
Local cLancCont		:= ""
Local cBusca		:= ""

Local lDigita 		:= .F.    	 						//Mostra lancamento?
Local lAglutina		:= .F.    	 						//Aglutina
Local lMedComPlan 	:= .F.

Local aLPGCT		:= {	{"697",VerPadrao("697")},; //LP Gestão de Contratos - Encerramento da Medição
							{"698",VerPadrao("698")},; //LP Gestão de Contratos - Encerramento da Medição/Automatico
							{"699",VerPadrao("699")},; //LP Gestão de Contratos - Encer. Medicao: Itens do Contrato			
							{"69A",VerPadrao("69A")},; //LP Gestão de Contratos - Est. Medicao: Itens do Contrato
							{"69B",VerPadrao("69B")},; //LP Gestão de Contratos - Incl. Rateio Itens Contrato s/ Planilha
							{"69C",VerPadrao("69C")},; //LP Gestão de Contratos - Excl. Rateio Itens Contrato s/ Planilha
							{"69D",VerPadrao("69D")},; //LP Gestão de Contratos - Incl. Rateio Itens Contrato c/ Planilha							
							{"69E",VerPadrao("69E")},;
							{"69F",VerPadrao("69F")} ; //LP Gestão de Contratos - Excl. Rateio Itens Contrato c/ Planilha
						}

Private cXFil := "" // Para ser utilizado no ponto de entrada antes de após o processamento da exclusão do pedido de compra - FSW

DEFAULT nAcao  := 1//1 - Estorna;2 - Exclui Pedido;3 - Somente Estorna
DEFAULT lAviso := .T.
DEFAULT lAutoFor:= .F.
DEFAULT lMedServ:= .F.

Static cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),Len(SE2->E2_PREFIXO))
Static cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),Len(SE2->E2_TIPO))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para indicar se atualiza ou nao  ³
//³saldo da medicao no estorno                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120ATESL")
	lEstSld := ExecBlock("CN120ATESL",.F.,.F.)
	If ValType(lEstSld) <> "L"
		lEstSld:=.T.
	EndIf
EndIf


dbSelectArea("CND")
MsGoTo(nReg)

//Estabelece passos
ProcRegua(6)

If !lAutoFor .Or. !lMedServ
	lContinua := CN240VldUsr(CND->CND_CONTRA,DEF_TRAEST,.T.,,cFilCtr)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validar o estorno da   ³
//³medicao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CN120VEST")
	uRet := ExecBlock("CN120VEST", .F., .F., {lContinua})
	If ValType(uRet) == "L"
		lContinua := uRet
	EndIf	
EndIf

Pergunte("CNT120",.F.)	//carrega as variaveis

If (lCtbOnLine := (MV_PAR01 == 1)) //SE CONTABILIZA, atraves da escolha do usuario    
	//Percorre os lancamentos contabeis do GCT, se algum deles existir, a contabilizacao podera ter continuidade
	For nI := 1 to len(aLPGCT) 
		If aLPGCT[nI,2]
			lCtbOnline := .T.
			Exit
		Else
			lCtbOnline := .F.	
		Endif
	Next nI 
	
	If lCtbOnLine
		lDigita	  := If(ValType(MV_PAR02)=="N",MV_PAR02 == 1,.F.)
		lAglutina := If(ValType(MV_PAR03)=="N",MV_PAR03 == 1,.F.) 
		nHead	  := HeadProva(cLoteGCT,"CNTA120",Subs(cUsuario,7,6),@cArqGCT)
		If nHead <= 0
			Help(" ",1,"SEM_LANC")
			lCtbOnLine := .F.
		EndIf
	EndIf
Endif

If lContinua
	If !Empty(CND->CND_DTFIM) .Or. nAcao != 1
		If !Empty(CND->(FieldPos("CND_AUTFRN")))
			nTipo := If(CND->CND_AUTFRN=="2",2,1)

			If !Empty(CND->(FieldPos("CND_PEDIDO")))
				If nTipo == 2 .And. nAcao == 1
					nAcao := 3
				EndIf
			EndIf
		EndIf               
		
		If !Empty(CND->(FieldPos("CND_SERVIC"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO")))     
			nServico := If(CND->CND_SERVIC=="1",1,2)
		EndIf
				
		If nAcao != 3
			dbSelectArea("CN9")
			dbSetOrder(1)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona na revisao atual do contrato       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CN9->(dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+"ZZZ",.T.))
			CN9->(dbSkip(-1))   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Identifica especie do contrato ³
			//³ 1 - Compra                     ³
			//³ 2 - Venda                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If CN9->(FieldPos("CN9_ESPCTR")) > 0
				cEspCtr := CN9->CN9_ESPCTR
			Else
				cEspCtr :=If(Empty(CN9->CN9_CLIENT),"1","2")
			EndIf	
			//So permite o estorno se o contrato estiver fora das seguintes situacoes
			If lVldVige .And.((CN9->CN9_SITUAC==DEF_SFINA) .Or. (CN9->CN9_DTINIC > dDataBase .Or. CN9->CN9_DTFIM < dDataBase))  //Contrato finalizado ou fora do período da vigência 
				lContinua := .F.
				Help( " ", 1, "CNTA120_07" )//Contrato fora do periodo de vigencia
			EndIf
			          
			If lContinua .And. CN9->CN9_SITUAC==DEF_SFINA
			  lContinua := .F.
			  Aviso("CNTA120",STR0117,{"OK"})//Ação não disponível para contrato Finalizado 
		 	EndIF        
		 	
			If lContinua .And. CN9->CN9_SITUAC==DEF_SCANC
				lContinua := .F.
				Help( " ", 1, "CNTA120_10" )//Ação não disponível para contrato Cancelado
			EndIf    
			
			If lContinua .And. CN9->CN9_SITUAC==DEF_SREVS 
				lContinua := .F.
				Help( " ", 1, "CNTA120_11" )//Ação não disponível para contrato com Revisão em Aberto
			EndIf 

			If lContinua .And. (CN9->CN9_REVISA <> CND->CND_REVISA) //Verifica se a revisao da medição é a revisão atual
				lContinua := .F.
				Help( " ", 1, "CNTA120_12" )//Estorno não permitido para revisões anteriores.
			EndIf			
			
			dbSelectArea("CNA")
			dbSetOrder(1)
			If MsSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO)
				cCronog := CNA_CRONOG
				dbSelectArea("CNF")
				If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))
					dbSetOrder(3)
					If MsSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_PARCEL)
						nTaxa := CNF_TXMOED
					EndIf
				Else
					dbSetOrder(2)
					If MsSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_COMPET)
						nTaxa := CNF_TXMOED
					EndIf	
				EndIf
			EndIf
	
			If lContinua .And. CND->( FieldPos("CND_RETCAC") ) > 0 .And. !Empty(CND->CND_RETCAC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe retencao para a medicao e se ³
				//³ a mesma se encontra baixada                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := "SELECT COUNT(R_E_C_N_O_) AS RETQTD "
				cQuery += "  FROM "+RetSQLName("CNT")+" CNT"
				cQuery += " WHERE CNT.CNT_FILIAL = '"+xFilial("CNT",cFilCTR)+"'"
				cQuery += "   AND CNT.CNT_CONTRA = '"+CND->CND_CONTRA+"'"
				cQuery += "   AND CNT.CNT_NUMMED = '"+CND->CND_NUMMED+"'"
				cQuery += "   AND CNT.CNT_VLBX   > 0"
				cQuery += "   AND D_E_L_E_T_ = ' '"
				
				cAliasCNT := GetNextAlias()
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNT,.F.,.T.)
				
				lContinua := ((cAliasCNT)->RETQTD == 0)
				
				(cAliasCNT)->(dbCloseArea())
				
				If !lContinua
					Help( " ", 1, "CNTA120_05")//"A medição não pode ser estornada, pois o valor de retenção da caução já foi baixado"
				EndIf
			EndIf
			
			If lContinua
				dbSelectArea("CNE")
				dbSetOrder(1)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Seleciona pedido gerado      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If dbSeek(xFilial("CNE")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED)
					If cEspCtr == "1"
						cNumSC7 := CNE->CNE_PEDIDO
						If Empty(cNumSC7) .And. (!Empty(CND->(FieldPos("CND_PEDIDO"))) .And. !Empty(CND->(FieldPos("CND_AUTFRN")))) //Carrega o pedido do cabecalho
							cNumSC7 := CND->CND_PEDIDO
						EndIf
					Else
						cNumSC5 := CNE->CNE_PEDIDO
					EndIf
					If !Empty(CND->(FieldPos("CND_NUMTIT"))) //Recupera numero do titulo seja à pagar ou receber
						cNumTit := CND->CND_NUMTIT
					EndIf
				EndIf
				
				PcoIniLan("000355")

				lMsErroAuto := Iif(Type("lMsErroAuto")=='L',lMsErroAuto,.F.)
				
				Begin Transaction
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui pedidos de venda de excedentes           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IncProc(If(cEspCtr == '2',STR0043,""))
				If cEspCtr == '2' .And. CNE->(FieldPos("CNE_EXCEDE")) > 0
					cQuery := "SELECT DISTINCT(CNE.CNE_PEDIDO) AS PVNUM "
					cQuery += "FROM " +RetSQLName("CNE") +" CNE WHERE "
					cQuery += "CNE.D_E_L_E_T_ <> '*' AND CNE.CNE_FILIAL = '" +xFilial("CNE") +"' AND "
					cQuery += "CNE.CNE_CONTRA = '" +CND->CND_CONTRA +"' AND CNE.CNE_NUMMED = '" +CND->CND_NUMMED +"' AND "
					cQuery += "CNE.CNE_EXCEDE = '1' AND CNE.CNE_PEDIDO <> '" +CND->CND_PEDIDO +"'"
					
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"PVEXCE",.F.,.T.)				
					
					While !PVEXCE->(EOF())					
						MSExecAuto({|x,y,z| Mata410(x,y,z)},{{"C5_NUM",PVEXCE->PVNUM,NIL}},{},5)

						If lMsErroAuto
							lEstExce := .F.
							MOSTRAERRO()
							Exit
						Endif						

						PVEXCE->(dbSkip())
					End
					PVEXCE->(dbCloseArea())
				EndIf
				If CND->CND_ZERO == "2" .And. lEstExce //Verifica se a medicao e zerada 
					If cEspCtr == "1"
						If !Empty(cNumSC7)
							IncProc( STR0020 )//"Verificando pedido de compras"
							If lPrjCni
								// PE para alterar filial antes de processar a exclusão do pedido de compra
								If ExistBlock("CN120EPM")
									ExecBlock("CN120EPM",.F.,.F.)
								EndIf  							
							EndIf
							MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},1,{{"C7_NUM",cNumSC7,NIL}},{},5,.F.) //Exclui pedido de compras
							If lPrjCni
								// PE para alterar filial depois de processar a exclusão do pedido de compra
								If ExistBlock("CN120EPE")
									ExecBlock("CN120EPE",.F.,.F.)
								EndIf							
							EndIf
							lEstPed := !lMsErroAuto 
							If lMsErroAuto
								MostraErro()
							Endif
						EndIf
						If !Empty(cNumTit)
							IncProc(STR0120)//"Verificando título a pagar"
							aTitulo := {}
							aAdd(aTitulo,{"E2_FILIAL"	, xFilial("SE2")	,NIL})    
							aAdd(aTitulo,{"E2_PREFIXO"	, cRetPrf			,NIL})    
							aAdd(aTitulo,{"E2_NUM"		, cNumTit	  		,NIL})    
							aAdd(aTitulo,{"E2_TIPO"		, cTpTit			,NIL}) 
							aAdd(aTitulo,{"E2_ORIGEM"	, "CNTA120"		,NIL})
							MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)//Exclui títulos à pagar
							If lMsErroAuto
								MOSTRAERRO()
							Else
								lEstPed := .T.
								CN120EstSld(CND->CND_NUMMED)
							Endif	
						EndIf
					Else
						If !Empty(cNumSC5)
							IncProc( STR0043 )//"Verificando pedido de venda"
							MSExecAuto({|x,y,z| Mata410(x,y,z)},{{"C5_NUM",cNumSC5,NIL}},{},5) //Exclui pedido de venda
						EndIf
						lEstPed := !lMsErroAuto
						If lMsErroAuto
							MostraErro()	
						Endif			
						If !Empty(cNumTit)
							IncProc(STR0121)//"Verificando título a receber"
							aTitulo := {}
							aAdd(aTitulo,{"E1_FILIAL"	, xFilial("SE1")	,NIL})    
							aAdd(aTitulo,{"E1_PREFIXO"	, cRetPrf			,NIL})    
							aAdd(aTitulo,{"E1_NUM"		, cNumTit	  		,NIL})    
							aAdd(aTitulo,{"E1_TIPO"		, cTpTit			,NIL})
							aAdd(aTitulo,{"E1_ORIGEM"	, "CNTA120"		,NIL}) 
							MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5)
							If lMsErroAuto
								MOSTRAERRO()
							Else
								lEstPed := .T.
								CN120EstSld(CND->CND_NUMMED)
							Endif	
						EndIf
					EndIf				
				Else
					lEstPed := .T.
				EndIf
				
				lEstPed := lEstPed .And. lEstExce
				
				If lEstPed
					CN9->(DbSetOrder(1))
					If CN9->(DbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA))
					
						CN1->(dbSetOrder(1))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se o contrato é fixo  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
						If CN1->(FieldPos("CN1_CTRFIX")) > 0 .And. CN1->(FieldPos("CN1_VLRPRV")) > 0 .And. CN1->(DbSeek(xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO))
							lFixo  := (Empty(CN1->CN1_CTRFIX) .OR. (CN1->CN1_CTRFIX == "1"))
							lValor := (Empty(CN1->CN1_VLRPRV) .OR. (CN1->CN1_VLRPRV == "1"))
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza data fim da medicao                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dDtFim := CND->CND_DTFIM				
					If nAcao == 1
						RecLock("CND",.F.)
							CND->CND_DTFIM := CTOD("")
						MsUnlock()
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				   	//³Ponto de lancamento contabil e orcamentario para estorno da medicao                ³
				   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000355","03","CNTA120",.T.)				
					
					If lCtbOnLine							
				    	nDet += DetProva(nHead,"699","CNTA120",cLoteGCT,,,,,,,,,{"CND",CND->(RECNO())})
					EndIf									
					dbSelectArea("CNE")
					dbSetOrder(1)
					cFilCod := xFilial("CNE")
					dbSeek(cFilCod+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED)
					
					IncProc( STR0015 )//"Atualizando Medição e Itens"
					
					If lFixo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza saldo da planilha                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNA")
						dbSetOrder(1)
						If dbSeek(xFilial("CNA",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO)
							If lEstSld .And. !lPeSld//Nao atualiza saldo quando o ponto de entrada CN120SLDCTR estiver ativo	
								RecLock("CNA",.F.)
									CNA->CNA_SALDO += xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDtFim,TamSX3("CND_VLTOT")[2],,nTaxa)
								MsUnlock()
							EndIf
							If !Empty(CNA->CNA_CRONOG)
								cCronog := CNA->CNA_CRONOG
							EndIf
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza saldo do contrato                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CN9")
					dbSetorder(1)
					If dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA)
						If lEstSld .And. !lPeSld//Nao atualiza saldo quando o ponto de entrada CN120SLDCTR estiver ativo
							RecLock("CN9",.F.)
								If lFixo .Or. lValor
									CN9->CN9_SALDO += xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDtFim,TamSX3("CND_VLTOT")[2],,nTaxa)
								Else
									CN9->CN9_VLATU -= xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDtFim,TamSX3("CND_VLTOT")[2],,nTaxa)//Atualiza valor do contrato
									If Empty(CN9->CN9_REVISA)//Se contrato original atualiza valor inicial
										CN9->CN9_VLINI -= xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDtFim,TamSX3("CND_VLTOT")[2],,nTaxa)
									EndIf
								EndIf
							MsUnlock()
						EndIf
						lMedeve := (Posicione("CN1",1,xFilial("CN1",cFilCTR)+CN9->CN9_TPCTO,"CN1_MEDEVE") == "1")
						lFisico := (!lMedeve .And. (CN1->(FieldPos("CN1_CROFIS")) > 0) .And. (CN1->CN1_CROFIS == "1"))
					EndIf
					
					If lFisico
						cFilCNS := xFilial("CNS",cFilCTR)
					EndIf
					
					If !lMedeve
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza saldo do cronograma quando nao houver  ³
						//³ medicao eventual                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNF")
						If !Empty(CND->( FieldPos( "CND_PARCEL" ) )) .And. !Empty(CND->CND_PARCEL)
							dbSetorder(3)
							dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_PARCEL)
						Else
							dbSetorder(2)
							dbSeek(xFilial("CNF",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA+cCronog+CND->CND_COMPET)						
						EndIf
						
						If Found()
							cParcel := CNF->CNF_PARCEL
							
							If lEstSld .And. !lPeSld//Nao atualiza saldo quando o ponto de entrada CN120SLDCTR estiver ativo
								RecLock("CNF")
									CNF->CNF_VLREAL -= xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDtFim,TamSX3("CND_VLTOT")[2],,nTaxa)
									CNF->CNF_SALDO  += xMoeda(CND->CND_VLTOT - CN120VlExc(),CND->CND_MOEDA,CN9->CN9_MOEDA,dDtFim,TamSX3("CND_VLTOT")[2],,nTaxa)
									If CNF->CNF_VLREAL == 0
										CNF->CNF_DTREAL := CTOD("")
									Else
										// Atualiza a data de realizacao do Cronograma quando estornar medição parcial
										aAreaCND := CND->(GetArea())
										CNF->CNF_DTREAL := CTOD("")
										CND->(dbSkip(-1))
										While !CND->(Bof()) 
											If CND->CND_CONTRA+CND->CND_REVISA = CNF->CNF_CONTRA+CNF->CNF_REVISA .And. Empty(CNF->CNF_DTREAL)
												If 	!Empty(CND->CND_DTFIM) .And. CND->CND_PARCEL = CNF->CNF_PARCEL .And. ;
												(Empty(CNF->CNF_DTREAL) .Or. CND->CND_DTFIM > CNF->CNF_DTREAL)
													CNF->CNF_DTREAL := CND->CND_DTFIM
												Endif                                
											EndIf
											CND->(dbSkip(-1))								
										EndDo
										RestArea(aAreaCND)
									EndIf
								MsUnlock()
								
								If (GetNewPar( "MV_CNPROVI" ,  "S" ) == "S")
									IncProc( STR0021 )//"Processando títulos provisórios"
									
									CN100ETit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,cFilCtr)
									If CNF->CNF_SALDO > 0
										CN100CTit(CND->CND_CONTRA,CND->CND_REVISA,cCronog,CNF->CNF_PARCEL,CNF->CNF_SALDO,cFilCtr)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
					If lEstSld .And. !lPeSld // Atualiza itens da planilha 
						RecLock("CND",.F.) //Limpa codigo do titulo e pedido
						CND->CND_PEDIDO := CriaVar("CND_PEDIDO",.F.)
						If !Empty(CND->(FieldPos("CND_NUMTIT")))
							CND->CND_NUMTIT := CriaVar("CND_NUMTIT",.F.)
						EndIf
						MsUnlock()
						While !CNE->(Eof()) .And. CNE->CNE_FILIAL == cFilCod .And. CNE->CNE_CONTRA == CND->CND_CONTRA .And. CNE->CNE_REVISA == CND->CND_REVISA .And.;
							CNE->CNE_NUMERO == CND->CND_NUMERO .And. CNE->CNE_NUMMED == CND->CND_NUMMED
							lMedComPlan := .F.
							RecLock("CNE") //Limpa o pedido do item de medicao 
								CNE->CNE_PEDIDO := ""
							MsUnlock()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza saldo dos itens da planilha            ³
							//³ Itens excedentes nao atualizam saldos			³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(CNE->(FieldPos("CNE_EXCEDE"))) .Or. CNE->CNE_EXCEDE == '2'
								dbSelectArea("CNB")
								dbSetOrder(1)
								If dbSeek(xFilial("CNB",cFilCTR)+CNE->CNE_CONTRA+CNE->CNE_REVISA+CNE->CNE_NUMERO+CNE->CNE_ITEM)
									RecLock("CNB",.F.)
								 	If nServico == 1
										CNB->CNB_QTDMED -= CNE->CNE_QUANT
										CNB->CNB_SLDMED += CNE->CNE_QUANT
									Else     
										CNB->CNB_QTDMED -= CNE->CNE_QTDORI
										CNB->CNB_SLDMED += CNE->CNE_QTDORI
									EndIf
									
									MsUnlock()
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ CAPTURO A VARIAVEL FLAG DE ITENS COM PLANILHA ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									lMedComPlan := .T.
								EndIf
														
								If lFisico
									dbSelectArea("CNS")
									dbSetOrder(1)
									If dbSeek(cFilCNS+CND->CND_CONTRA+CND->CND_REVISA+cCronog+cParcel+CNE->CNE_ITEM)
										RecLock("CNS",.F.)
											CNS->CNS_RLZQTD -= CNE->CNE_QUANT
											CNS->CNS_SLDQTD += CNE->CNE_QUANT
										MsUnlock()
									EndIf
								EndIf
							EndIf
							
							PcoDetLan("000355","04","CNTA120",.T.)
							
							If lCtbOnLine							                     
								//CONTABILIZA ESTORNO DA MEDICAO - ITENS DO CONTRATO
								nDet += DetProva(nHead,"69B","CNTA120",cLoteGCT,,,,,,,,,{"CNE",CNE->(Recno())})
							Endif	

							If lMedComPlan
								cLancCont := "69D"
								cSeqPCOLan:= "06"
							Else
								cLancCont := "69F"
								cSeqPCOLan:= "05"
							Endif
                           
                           	If AliasInDic("CNZ") 
                            	cBusca :=	xFilial("CNZ",cFilCTR) +;
										Padr(CNE->CNE_CONTRA	,tamSx3("CNZ_CONTRA")[1])	+;
										Padr(CNE->CNE_REVISA	,TamSx3("CNZ_REVISA")[1])	+;
										Padr(CNE->CNE_NUMMED	,TamSX3("CNZ_NUMMED")[1])	+; 
										Padr(CNE->CNE_ITEM		,TamSx3("CNZ_ITCONT")[1])
                            
	                            CNZ->(dbSetOrder(2)) //CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+CNZ_ITCONT+CNZ_ITEM
	                            
	                            If CNZ->(dbSeek( cBusca ))
	                            	While CNZ->(!Eof()) .and. cBusca == 	xFilial("CNZ",cFilCTR) +;
	                            											Padr(CNE->CNE_CONTRA	,tamSx3("CNZ_CONTRA")[1])	+;
																			Padr(CNE->CNE_REVISA	,TamSx3("CNZ_REVISA")[1])	+;
																			Padr(CNE->CNE_NUMMED	,TamSX3("CNZ_NUMMED")[1])	+; 
																			Padr(CNE->CNE_ITEM		,TamSx3("CNZ_ITCONT")[1])
	
										PcoDetLan("000355",cSeqPCOLan,"CNTA120",.T.)
										
										If lCtbOnLine							                    
											//CONTABILIZA OS RATEIOS DO ITEM DO CONTRATO COM PLANILHA. 
											//SE HA PLANILHA, ENTAO NAO PODERA CONTABILIZAR O RATEIO SEM PLANILHA, ABAIXO (CONTROLAR COM VARIAVEL FLAG)
											//EFETUA A CONTABILIZACAO DOS RATEIOS DO ITEM DO CONTRATO SEM PLANILHA, 
									    	nDet	+= DetProva(nHead,cLancCont,"CNTA120",cLoteGCT,,,,,,,,,{"CNZ",CNZ->(RECNO())})
	                                        Endif
										CNZ->(DbSkip())									
	                            	EndDo
	                            Endif
		                    Endif
		                    
							dbSelectArea("CNE")
							dbSkip()
						EndDo
					EndIf
					
					IncProc( STR0016 )//"Atualizando Saldos"
					
					If lPeSld//Chama ponto de entrada para atualizacao do saldo
						ExecBlock("CN120ESSLD",.f.,.f.,{lMedeve,lFisico,cCronog,lFixo,lValor})
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna o historico de multas / bonificacoes do contrato ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( CNG->( FieldPos ( "CNG_NUMMED" ) ) )// Verifica o campo CNG_NUMMED para estor. historico
						CN120HistMul( 2, NIL, CND->CND_CONTRA, CND->CND_NUMMED )
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa ponto de entrada para estorno da medicao ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ExistBlock("CN120ESTMD")
						If cEspCtr == "1"
							ExecBlock("CN120ESTMD",.F.,.F.,{cNumSC7})
						Else
							ExecBlock("CN120ESTMD",.F.,.F.,{cNumSC5})					
						EndIf
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Estorna o valor retido da caucao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CND->( FieldPos("CND_RETCAC")) > 0 .And. !Empty(CND->CND_RETCAC)
					CN120CaucRet(CND->CND_CONTRA,CND->CND_NUMMED,2,CND->CND_RETCAC)
				EndIf
				End Transaction
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa ponto de entrada para estorno da medicao ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("CN120ESMED")
					If cEspCtr == "1"
						ExecBlock("CN120ESMED",.F.,.F.,{cNumSC7})
					Else
						ExecBlock("CN120ESMED",.F.,.F.,{cNumSC5})					
					EndIf
				EndIf
				
				PcoFinLan("000355")
				
				If !lAuto
					If lAviso
						If !lEstPed
							Aviso("CNTA120",OemToAnsi(STR0031)+cNumSC7+OemToAnsi(STR0032),{"OK"})//"O pedido "##" não pode ser estornado"
						Else
							If nTipo == 1  .And. nServico == 1
								Aviso("CNTA120",OemToAnsi(STR0033),{"OK"})//"Medição/entrega estornada com sucesso"
							ElseIf nTipo == 2
								Aviso("CNTA120",OemToAnsi(STR0064),{"OK"})//"Autorização de fornecimento estornada com sucesso"
							Else  
								Aviso("CNTA120",OemToAnsi(STR0086),{"OK"})//"Autorização de fornecimento estornada com sucesso"
							EndIf 
						EndIf
					EndIf
				EndIf
				
				lRet := lEstPed
			EndIf
		Else            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona a nota        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT DISTINCT SF1.F1_DOC,  SF1.F1_SERIE,   SF1.F1_TIPO, "
			cQuery += "                SF1.F1_DUPL, SF1.F1_PREFIXO, F1_FORNECE, F1_LOJA "
			cQuery += "  FROM " + RetSQLName("SF1") + " SF1, " + RetSQLName("SD1") + " SD1 "
			cQuery += " WHERE SF1.F1_FILIAL  = '" + xFilial("SF1") + "'"
			cQuery += "   AND SD1.D1_FILIAL  = '" + xFilial("SD1") + "'"
			cQuery += "   AND SF1.F1_DOC     = SD1.D1_DOC     "
			cQuery += "   AND SF1.F1_SERIE   = SD1.D1_SERIE   "
			cQuery += "   AND SF1.F1_TIPO    = SD1.D1_TIPO    " 
			cQuery += "   AND SF1.F1_FORNECE = SD1.D1_FORNECE "
			cQuery += "   AND SF1.F1_LOJA    = SD1.D1_LOJA    " 
			cQuery += "   AND SD1.D1_PEDIDO  = '" + CND->CND_PEDIDO + "'" 
			cQuery += "   AND SF1.D_E_L_E_T_ = ' ' "
			cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
	
			cQuery    := ChangeQuery( cQuery )
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )
			
			If !(cAliasQry)->(Eof())			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica os valores dos titulos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := "SELECT SUM(E2_VALOR) AS E2_VALOR,SUM(E2_SALDO) AS E2_SALDO " 
				cQuery += "  FROM " + RetSQLName("SE2") + " SE2 "
				cQuery += " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "'"
				cQuery += "   AND SE2.E2_NUM     = '" + (cAliasQry)->F1_DUPL + "'"
				cQuery += "   AND SE2.E2_PREFIXO = '" + IIf(Empty((cAliasQry)->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),(cAliasQry)->F1_PREFIXO) + "'"
				cQuery += "   AND SE2.E2_FORNECE = '" + (cAliasQry)->F1_FORNECE + "'"
				cQuery += "   AND SE2.E2_LOJA    = '" + (cAliasQry)->F1_LOJA + "'"
				cQuery += "   AND SE2.E2_TIPO    = 'NF '"
				cQuery += "   AND SE2.D_E_L_E_T_ = ' '"
                                                                           
				cQuery    := ChangeQuery( cQuery )
				cAliasSE2 := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )
				
				TCSetField( cAliasSE2, "E2_VALOR", "N", TamSX3("E2_VALOR")[1], TamSX3("E2_VALOR")[2] )
				TCSetField( cAliasSE2, "E2_SALDO", "N", TamSX3("E2_SALDO")[1], TamSX3("E2_SALDO")[2] )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se houve movimentacoes nos titulos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cAliasSE2)->E2_VALOR > (cAliasSE2)->E2_SALDO
					Aviso("CNTA120",OemToAnsi(STR0058)+(cAliasQry)->F1_DOC+"/"+(cAliasQry)->F1_SERIE+OemToAnsi(STR0059),{"OK"})//STR0058"Não foi possível estornar a autorização de fornecimento, pois a NFE: "##" possui movimentações financeiras."
					lBloqSE2 := .T.
				EndIf

				(cAliasSE2)->(dbCloseArea())
				
				If !lBloqSE2 .And. lGCTBloq
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Seleciona os titulos ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := "SELECT SE2.R_E_C_N_O_ AS RECNO "
					cQuery += "  FROM " + RetSQLName("SE2") + " SE2 "
					cQuery += " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "'"
					cQuery += "   AND SE2.E2_NUM     = '" + (cAliasQry)->F1_DUPL + "'"
					cQuery += "   AND SE2.E2_PREFIXO = '" + IIf(Empty((cAliasQry)->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),(cAliasQry)->F1_PREFIXO) + "'"
					cQuery += "   AND SE2.E2_FORNECE = '" + (cAliasQry)->F1_FORNECE + "'"
					cQuery += "   AND SE2.E2_LOJA    = '" + (cAliasQry)->F1_LOJA + "'"
					cQuery += "   AND SE2.E2_TIPO    = 'NF '"
					cQuery += "   AND SE2.D_E_L_E_T_ = ' '"
					
					cQuery    := ChangeQuery( cQuery )
					cAliasSE2 := GetNextAlias()
					dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSE2, .F., .T. )
					                            
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Bloqueia os titulos ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While !(cAliasSE2)->(Eof())
						SE2->(MsGoTo((cAliasSE2)->RECNO))
						
						RecLock("SE2",.F.)
							SE2->E2_MSBLQL := "1"
						MsUnlock()
						
						(cAliasSE2)->(dbSkip())
					EndDo
					
					(cAliasSE2)->(dbCloseArea())
				EndIf
			EndIf
			
			(cAliasQry)->(dbCloseArea())
		
			If !lBloqSE2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza data fim da medicao                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("CND",.F.)
					CND->CND_DTFIM := CTOD("")
				MsUnlock()
				
				lRet := .T.
			EndIf
		EndIf
	Else
		Help( " ", 1, "CNTA120_06")//Nao encerrada
	EndIf
EndIf

If lCtbOnLine
	RodaProva(nHead,nDet)
	If nDet > 0
		cA100Incl(cArqGCT,nHead,1,cLoteGCT,lDigita,lAglutina)
	Endif
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120AjSX7 ³ Autor ³ Marcelo Custodio      ³ Data ³06.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Corrige ordem dos gatilhos dos itens de medicao (CNE)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CN120AjSX7()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120AjSX7()
Local nRegD//Registro da ordem 002
Local nRegT//Registro da ordem 003

SX7->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa ordem 002 e valida conteudo atual      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SX7->(dbSeek("CNE_PERC  002")) .And. AllTrim(SX7->X7_CDOMIN) == "CNE_VLDESC"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Armazena registro da ordem 002              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRegD := SX7->(RecNo())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa ordem 003 e armazena registro      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX7->(dbSeek("CNE_PERC  003"))
	nRegT := SX7->(RecNo())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a troca da ordem de execucao        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX7->(MsGoTo(nRegD))
	RecLock("SX7",.F.)
		SX7->X7_SEQUENC := "003"
	MsUnlock()
	
	SX7->(MsGoTo(nRegT))
	RecLock("SX7",.F.)
		SX7->X7_SEQUENC := "002"
	MsUnlock()
EndIf

//Inclui gatilho para descricao da condicao de pagamento
If !SX7->(dbSeek("CND_CONDPG001"))
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CND_CONDPG"
		SX7->X7_SEQUENC	 := "001"
		SX7->X7_REGRA    := "SE4->E4_DESCRI"
		SX7->X7_CDOMIN   := "CND_DESCCP"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "S	
		SX7->X7_ALIAS    := "SE4"
		SX7->X7_ORDEM    := 1	
		SX7->X7_CHAVE    := "xFilial('SE4')+M->CND_CONDPG"
		SX7->X7_PROPRI   := "U"
	MsUnlock()
EndIf

//Inclui gatilho 001 do valor total para atualizar quantidade
If !SX7->(dbSeek("CNE_VLTOT 001"))
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CNE_VLTOT"
		SX7->X7_SEQUENC	 := "001"
		SX7->X7_REGRA    := 'Round(M->CNE_VLTOT/M->CNE_VLUNIT,TamSX3("CNE_QUANT")[2])'
		SX7->X7_CDOMIN   := "CNE_QUANT"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

//Inclui gatilho 002 do valor total para atualizar desconto
If !SX7->(dbSeek("CNE_VLTOT 002"))
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CNE_VLTOT"
		SX7->X7_SEQUENC	 := "002"
		SX7->X7_REGRA    := 'Round(M->CNE_VLTOT*M->CNE_PDESC/100,TamSx3("CNE_VLDESC")[2])'
		SX7->X7_CDOMIN   := "CNE_VLDESC"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

//Inclui gatilho 003 do valor total para atualizar percentual da quantidade em contratos fixos
If !SX7->(dbSeek("CNE_VLTOT 003"))
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CNE_VLTOT"
		SX7->X7_SEQUENC	 := "003"
		SX7->X7_REGRA    := 'Round((M->CNE_QUANT*100)/M->CNE_QTDSOL,TamSX3("CNE_PERC")[2])'
		SX7->X7_CDOMIN   := "CNE_PERC"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_CONDIC   := "lFixo"
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

//Inclui gatilho 002 do CNE_PERC para atualizar o valor total
If !SX7->(dbSeek("CNE_PERC  002"))
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CNE_PERC"
		SX7->X7_SEQUENC	 := "002"
		SX7->X7_REGRA    := 'M->CNE_VLUNIT*M->CNE_QUANT'
		SX7->X7_CDOMIN   := "CNE_VLTOT "
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_CONDIC   := "!LSERVICO "
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

//Inclui gatilho 006 da Quantidade para atualizar o valor unitario
//para medicao de servicos 
If !SX7->(dbSeek("CNE_PERC  006"))
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CNE_PERC"
		SX7->X7_SEQUENC	 := "006"
		SX7->X7_REGRA    := 'M->CNE_VLTOT
		SX7->X7_CDOMIN   := "CNE_VLUNIT "
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_CONDIC   := "lFixo .And. lServico "
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf



// Alterar os gatilhos dos campos CNE_QUANT //
If SX7->(dbSeek("CNE_QUANT 001")) .And. 'Round((M->CNE_QUANT*100)/M->CNE_QTDSOL,TamSX3("CNE_PERC")[2])' $ SX7->X7_REGRA
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "(M->CNE_QUANT*100)/M->CNE_QTDSOL"
	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_QUANT 002")) .And. 'Round(M->CNE_VLUNIT*M->CNE_QUANT,TamSX3("CNE_VLTOT")[2])' $ SX7->X7_REGRA
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "M->CNE_VLUNIT*M->CNE_QUANT"
	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_QUANT 003")) .And. !("NoRound(M->CNE_VLTOT*(M->CNE_PDESC/100),TamSx3('CNE_VLDESC')[2])" $ SX7->X7_REGRA)
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "NoRound(M->CNE_VLTOT*(M->CNE_PDESC/100),TamSx3('CNE_VLDESC')[2])"
	MsUnlock()
EndIf


// Alterar os gatilhos dos campos CNE_VLTOT //
If SX7->(dbSeek("CNE_VLTOT 001")) .And. 'Round(M->CNE_VLTOT/M->CNE_VLUNIT,TamSX3("CNE_QUANT")[2])' $ SX7->X7_REGRA
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "M->CNE_VLTOT/M->CNE_VLUNIT"

	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_VLTOT 002")) .And. !('NoRound(M->CNE_VLTOT*(M->CNE_PDESC/100),TamSx3("CNE_VLDESC")[2])' $ SX7->X7_REGRA)
	RecLock("SX7", .F.)
		SX7->X7_REGRA := 'NoRound(M->CNE_VLTOT*(M->CNE_PDESC/100),TamSx3("CNE_VLDESC")[2])'
	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_VLTOT 003")) .And. 'Round((M->CNE_QUANT*100)/M->CNE_QTDSOL,TamSX3("CNE_PERC")[2])' $ SX7->X7_REGRA
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "(M->CNE_QUANT*100)/M->CNE_QTDSOL"
	MsUnlock()
EndIf   

//Inclui gatilho 002 da Quantidade para atualizar o valor total 
If !SX7->(dbSeek("CNE_QUANT 002"))  
	RecLock("SX7",.T.)
		SX7->X7_CAMPO	 := "CNE_QUANT"
		SX7->X7_SEQUENC	 := "002"
		SX7->X7_REGRA    := 'M->CNE_VLUNIT*M->CNE_QUANT'
		SX7->X7_CDOMIN   := "CNE_VLTOT"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_CONDIC   := ""
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf 
      

//Se existir o gatilho 002 com a regra diferente, alterar para Quantidade atualizar o valor total 
If (SX7->(dbSeek("CNE_QUANT 002")) .And. !(SX7->X7_REGRA=='M->CNE_VLUNIT*M->CNE_QUANT'))
	RecLock("SX7",.F.)
		SX7->X7_CAMPO	 := "CNE_QUANT"
		SX7->X7_SEQUENC	 := "002"
		SX7->X7_REGRA    := 'M->CNE_VLUNIT*M->CNE_QUANT'
		SX7->X7_CDOMIN   := "CNE_VLTOT"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_CONDIC   := ""
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf              
     
//Tratamento especifico para o contrato de vendas
If SX7->(dbSeek("CNE_VLTOT 002")) .And. !("Empty(M->CND_CLIENT)"$ SX7->X7_CONDIC)
	RecLock("SX7", .F.)
		SX7->X7_CONDIC := "Empty(M->CND_CLIENT)"
	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_PDESC 001")) .And. !("Empty(M->CND_CLIENT)"$ SX7->X7_CONDIC)
	RecLock("SX7", .F.)
		SX7->X7_CONDIC := "Empty(M->CND_CLIENT)"
	MsUnlock()
EndIf


If SX7->(dbSeek("CNE_QUANT 003")) .And. !("Empty(M->CND_CLIENT)"$ SX7->X7_CONDIC)
	RecLock("SX7", .F.)
		SX7->X7_CONDIC := "Empty(M->CND_CLIENT)"
	MsUnlock()
EndIf  


// Alterar os gatilhos dos campos CNE_PERC //
If SX7->(dbSeek("CNE_PERC  001")) .And. SX7->X7_REGRA != '(M->CNE_QTDSOL*M->CNE_PERC)/100'
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "(M->CNE_QTDSOL*M->CNE_PERC)/100" 
		SX7->X7_CDOMIN   := "CNE_QUANT "
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0
		SX7->X7_CHAVE    := ""
		SX7->X7_CONDIC   := "!LSERVICO "
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_PERC  002")) .And. SX7->X7_REGRA != 'M->CNE_VLUNIT*M->CNE_QUANT'
	RecLock("SX7", .F.)
		SX7->X7_REGRA := "M->CNE_VLUNIT*M->CNE_QUANT"
		SX7->X7_CDOMIN   := "CNE_VLTOT "
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0
		SX7->X7_CHAVE    := ""
		SX7->X7_CONDIC   := "!LSERVICO "
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

If SX7->(dbSeek("CNE_PERC  003")) .And. (SX7->X7_REGRA != 'NoRound(M->CNE_VLTOT*(M->CNE_PDESC/100),TamSx3("CNE_VLDESC")[2])';
   .Or. !("Empty(M->CND_CLIENT)"$ SX7->X7_CONDIC))
	RecLock("SX7", .F.)
		SX7->X7_REGRA := 'NoRound(M->CNE_VLTOT*(M->CNE_PDESC/100),TamSx3("CNE_VLDESC")[2])'
		SX7->X7_CDOMIN   := "CNE_VLDESC"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0
		SX7->X7_CHAVE    := ""
		SX7->X7_CONDIC   := "Empty(M->CND_CLIENT)"
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf  

If SX7->(dbSeek("CNE_PERC  004")) .And. (SX7->X7_REGRA != '(M->CNE_QTDSOL*M->CNE_PERC)/100';
   .Or. !("lFixo .And. lServico"$ SX7->X7_CONDIC))
	RecLock("SX7", .F.)
		SX7->X7_REGRA := '(M->CNE_QTDSOL*M->CNE_PERC)/100'
		SX7->X7_CDOMIN   := "CNE_QTDORI"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0
		SX7->X7_CHAVE    := ""
		SX7->X7_CONDIC   := "lFixo .And. lServico"
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf  


If SX7->(dbSeek("CNE_PERC  005")) .And. (SX7->X7_REGRA != 'M->CNE_VUNORI*M->CNE_QTDORI';
   .Or. !("lFixo .And. lServico"$ SX7->X7_CONDIC))
	RecLock("SX7", .F.)
		SX7->X7_REGRA := 'M->CNE_VUNORI*M->CNE_QTDORI'
		SX7->X7_CDOMIN   := "CNE_VLTOT"
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_ORDEM    := 0
		SX7->X7_CHAVE    := ""
		SX7->X7_CONDIC   := "lFixo .And. lServico"
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf         

If SX7->(dbSeek("CNE_PERC  006")) .And. SX7->X7_REGRA != "M->CNE_VLTOT"
	RecLock("SX7",.F.)
		SX7->X7_CAMPO	 := "CNE_PERC"
		SX7->X7_SEQUENC	 := "006"
		SX7->X7_REGRA    := "M->CNE_VLTOT"
		SX7->X7_CDOMIN   := "CNE_VLUNIT "
		SX7->X7_TIPO     := "P"
		SX7->X7_SEEK     := "N"	
		SX7->X7_ALIAS    := ""
		SX7->X7_CONDIC   := "lFixo .And. lServico "
		SX7->X7_ORDEM    := 0	
		SX7->X7_CHAVE    := ""
		SX7->X7_PROPRI   := "S"
	MsUnlock()
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CN120HistMul³ Autor ³ Sergio Silveira     ³ Data ³04/08/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a manutencao do historico das multas nas medicoes    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103HistMul( ExpN1,ExpA2,ExpC3,ExpC4,ExpC5,ExpC6)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Tipo : 1 - Inclusao / 2 - Exclusao                 ³±±
±±³          ³ ExpA2 -> Array de multas                                    ³±±
±±³          ³ ExpC3 -> Documento                                          ³±±
±±³          ³ ExpC4 -> Serie                                              ³±±
±±³          ³ ExpC5 -> Fornecedor                                         ³±±
±±³          ³ ExpC6 -> Loja                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CN120HistMul( nTipo, aMultas, cContra, cNumMed )

Local cHora     := ""
Local cAliasQry := ""
Local cQuery    := ""

Local nLoop     := 0

If nTipo == 1
	cHora := Time()
	
	For nLoop := 1 to Len( aMultas )
		RecLock( "CNG", .T. )
			CNG->CNG_FILIAL  := xFilial( "CNG" )
			CNG->CNG_CONTRA  := cContra
			CNG->CNG_DATA    := dDataBase
			CNG->CNG_HORA    := cHora
			CNG->CNG_VALOR   := aMultas[ nLoop, 1 ]
			CNG->CNG_DESCRI  := aMultas[ nLoop, 2 ]
			CNG->CNG_TIPO    := aMultas[ nLoop, 3 ]
			CNG->CNG_NUMMED  := cNumMed
		CNG->( MsUnlock() )
	Next nLoop
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o historico desta NF no contrato                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cAliasQry := GetNextAlias()
	
	cQuery := "SELECT R_E_C_N_O_ CNGRECNO "
	cQuery += "  FROM " + RetSqlName( "CNG" )
	cQuery += " WHERE CNG_NUMMED = '"  + cNumMed + "'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .F., .T. )
	
	While !( cAliasQry )->( Eof() )
		
		CNG->( MsGoTo( ( cAliasQry )->CNGRECNO ) )
		
		RecLock( "CNG", .F. )
			CNG->( dbDelete())
		CNG->( MsUnlock())
		
		( cAliasQry )->( dbSkip() )
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a area de trabalho da query                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	( cAliasQry )->( dbCloseArea() )
	
EndIf

Return( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120Impr ºAutor  ³Fabio Alves         º Data ³  28/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a impressao da medicao dentro da rotina             º±±
±±º          ³ Medicoes/Entregas.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CNTA120                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120Impr(cAlias,nReg)  
Private cTitRel := OemToAnsi(STR0037) //Medicoes
Private lEnd	:= .F.

dbSelectArea("CND")
dbSetOrder(1)
MsGoTo(nReg)   

RptStatus({|lEnd| CNR030Imp(@lEnd,CND->CND_NUMMED)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³24/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()     
Local aExcede := {	{STR0091, "CN120ExceM" , 0, 13, 0, NIL},; //-- "p / medição encerrada"
					{STR0092, "CN120ExceC" , 0, 14, 0, NIL}	} //-- "p / competência não prevista"

PRIVATE aRotina	:= { 	{ STR0002, "AxPesqui"  	, 0, 1, 0,.F.},;//"Pesquisar"
								{ STR0003, "CN130Manut"	, 0, 2, 0, nil},;//"Visualizar"
								{ STR0004, "CN120Inc"   , 0, 3, 0, nil},;//"Incluir"
								{ STR0005, "CN120Manut" , 0, 4, 0, nil},;//"Alterar"
								{ STR0006, "CN120Manut"	, 0, 5, 0, nil},;//"Excluir"
								{ STR0007, "CN120Ence"	, 0, 6, 0, nil},;//"Encerrar"
								{ STR0018, "CN120Estor"	, 0, 7, 0, nil},; //"Estornar"
								{ STR0042, "CN120Leg"	, 0, 8, 0, .F.},; //"Legendas"
								{ STR0051, "CN120Aut"	, 0, 3, 0, .F.},; //"Aut. Fornec."
								{ STR0038, "CN120Impr"	, 0, 9, 0, nil},;//"Imprimir"
		    					{ STR0067, "MsDocument" , 0, 4, 0, nil},; //"Conhecimento"
		    					{ STR0087, "CN120Serv" , 0, 3, 0, .F.}}  //"Med. Serviços."

If SuperGetMV("MV_CNBTEXC",.F.,"N") == "S" .And. CNE->(FieldPos("CNE_EXCEDE")) > 0
	If Type("lAuto") == "L" .And. lAuto
		aEval(aExcede,{|x| aAdd(aRotina, x)})
	Else
		aAdd(aRotina,{ STR0093, aExcede	, 0, 13, 0, nil}) //Excedente
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTA120MNU")
	ExecBlock("CTA120MNU",.F.,.F.)
EndIf
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN120AjSXB³ Autor ³ Marcelo Custodio   ³ Data ³29/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Corrige filtro da consulta padra CN9001                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN120AjSXB()

dbSelectArea("SXB")
dbSetOrder(1)

If dbSeek("CN9001601") .And. AllTrim(SXB->XB_CONTEM) = "CN100FilCont()"
	RecLock("SXB",.F.)
		SXB->XB_CONTEM := "CN9->CN9_SITUAC = '05'"
	MsUnlock()
EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN120AjSX6³ Autor ³ Marcelo Custodio   ³ Data ³20/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui parametro MV_CNMDALC                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN120AjSX6() 
Local i
Local j
Local aSXB    := {}     
Local aEstrut := {}
Local aArea   := GetArea()
Local aAreaSXB:= SXB->(GetArea()) 
Local aAreaSX6 := SX6->(GetArea()) 

dbSelectArea("SX6")
dbSetOrder(1)

If !dbSeek(xFilial("SX6")+"MV_CNMDALC")
	RecLock("SX6",.T.)
		X6_FIL     :=  xFilial("SX6")
		X6_VAR     := "MV_CNMDALC"
		X6_TIPO    := "C"
		X6_CONTEUD := "N"
		X6_CONTSPA := "N"
		X6_CONTENG := "N"
		X6_PROPRI  := "S"
		X6_PYME    := "N"
		X6_DESCRIC := "Informa se o controle de alcada e ativo para as "
		X6_DSCSPA  := "Cita si el controle de pertinencias esta activo en las "
		X6_DSCENG  := "Informs whether the competence control is active on the "
		X6_DESC1   := "medicoes de contrato."
		X6_DSCSPA1 := "mediciones de contracto"
		X6_DSCENG1 := "contract´s measurements"
		X6_DESC2   := ""
		X6_DSCSPA2 := ""
		X6_DSCENG2 := ""
	MsUnlock()
EndIf 


If !dbSeek(xFilial("SX6")+"MV_CNDPCAL")
	RecLock("SX6",.T.)
		X6_FIL     :=  xFilial("SX6")
		X6_VAR     := "MV_CNDPCAL"
		X6_TIPO    := "C"
		X6_CONTEUD := "N"
		X6_CONTSPA := "N"
		X6_CONTENG := "N"
		X6_PROPRI  := "S"
		X6_PYME    := "N"
		X6_DESCRIC := "Desativa o controle de alcada para o Pedido de Compras"
		X6_DSCSPA  := "Desactiva el Controle Alcada para Ordenes de compra "
		X6_DSCENG  := "Disables the authoritie control to the Purschase Order "
		X6_DESC1   := "geradas pela medicoes de contrato."
		X6_DSCSPA1 := "generadas por mediciones de contracto"
		X6_DSCENG1 := "generated by contract´s measurements"
		X6_DESC2   := ""
		X6_DSCSPA2 := ""
		X6_DSCENG2 := ""
	MsUnlock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencha a matriz aSXB com os campos a serem criados. Utilize a mesma ordem indicada na       ³
//³ matriz aEstrut                                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
Aadd(aSXB,{"CN9003","1","01","RE","Contratos"        ,"Contratos"         ,"Contracts" ,"SX5"})
Aadd(aSXB,{"CN9003","2","01","01"," "                ," "                 ," "         ,"CNDMedEsp()"})
Aadd(aSXB,{"CN9003","5","01","  "," "                ," "                 ," "         ,"CN9->CN9_NUMERO"})
Aadd(aSXB,{"CN9003","5","02","  "," "                ," "                 ," "         ,"CN9->CN9_REVISA"})

dbSelectArea("SXB")
dbSetOrder(1) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA

For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(aSXB[i,1]+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])	
			RecLock("SXB",.T.)   
				For j:=1 To Len(aSXB[i])		
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
					EndIf
				Next j
				dbCommit()        
			MsUnLock()
		EndIf
	EndIf
Next i            
                                   
RestArea(aAreaSX6)   
RestArea(aAreaSXB)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN120AjSX3³ Autor ³ Marcelo Custodio   ³ Data ³07/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Configura os campos de fornecedor como obrigatorios     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN120AjSX3()
                             
Local aArea   := GetArea()
Local aAreaSX3:= SX3->(GetArea()) 

Local cRelObj := 'If(Inclui, "", MSMM(CN9->CN9_CODOBJ))'
Local cRelCla := 'If(Inclui, "", MSMM(CN9->CN9_CODCLA))'
Local cRelJus := 'If(Inclui, "", MSMM(CN9->CN9_CODJUS))'
Local cMoeda  := 'M->CND_MOEDA > 0 .AND. M->CND_MOEDA <= MOEDFIN() .AND. CN130MOEDA()'
Local cRelNumOri := 'GetSX8Num("CND","CND_NUMMED")'
Local cRelNumNew := 'CN130NumMd()'       
Local cPrdValid := iif(FindFunction("cn130MultT"),'ExistCPO("SB1") .And. cn130MultT() .And. CN120VldProd(M->CNE_PRODUT)' ,'ExistCPO("SB1") .And. CN120VldProd(M->CNE_PRODUT) ' )
Local cQtdValid := iif(FindFunction("cn130MultT"),'Positivo() .And. CN130VldQtd().And.cn130MultT()' ,'Positivo() .And. CN130VldQtd()')
Local cVUnValid := iif(FindFunction("cn130MultT"),'cn130VlUnt().And.cn130MultT()' ,'cn130VlUnt()')    
Local cPrcValid := iif(FindFunction("cn130MultT"),'Positivo() .And. CN130VldPerc().And.cn130MultT()' ,'Positivo() .And. CN130VldPerc()')
Local cTotValid := iif(FindFunction("cn130MultT"),'Positivo() .And. CN130VlTot().And.cn130MultT()' ,'Positivo() .And. CN130VlTot()')
Local cUsado    := ""
Local cReser    := ""

dbSelectArea("SX3")
dbSetOrder(2)    

If dbSeek("CND_CONDPG")
	RecLock("SX3",.F.)
		SX3->X3_TRIGGER := "S"
	MsUnlock()
EndIf
If dbSeek("CND_FORNEC") 
	If SX3->X3_RESERV != "‡€"
		RecLock("SX3",.F.)
			SX3->X3_RESERV := "‡€"
		MsUnlock()
	Endif
	If Alltrim(SX3->X3_VALID) == 'ExistCpo("SA2")'
		RecLock("SX3",.F.)
			SX3->X3_VALID := 'ExistCpo("SA2",M->CND_FORNEC+M->CND_LJFORN)'
		SX3->(MsUnlock())
	Endif
EndIf

If dbSeek("CND_LJFORN") .And. SX3->X3_RESERV != "‡€"
	RecLock("SX3",.F.)
		SX3->X3_RESERV := "‡€"
	MsUnlock()
EndIf

If dbSeek("CN9_OBJCTO") .And. SX3->X3_RELACAO != cRelObj
	RecLock("SX3",.F.)
		SX3->X3_RELACAO := cRelObj
	MsUnlock()
EndIf

If dbSeek("CN9_ALTCLA") .And. SX3->X3_RELACAO != cRelCla
	RecLock("SX3",.F.)
		SX3->X3_RELACAO := cRelCla
	MsUnlock()
EndIf

If dbSeek("CN9_JUSTIF") .And. SX3->X3_RELACAO != cRelJus
	RecLock("SX3",.F.)
		SX3->X3_RELACAO := cRelJus
	MsUnlock()
EndIf

If dbSeek("CND_MOEDA") .And. SX3->X3_VALID != cMoeda
	RecLock("SX3",.F.)
		SX3->X3_VALID := cMoeda
	MsUnlock()
EndIf

If dbSeek("CND_NUMMED") .And. (AllTrim(SX3->X3_RELACAO)) == cRelNumOri
	RecLock("SX3",.F.)
		SX3->X3_RELACAO := cRelNumNew
	MsUnlock()
EndIf

If dbSeek("CNE_VLTOT") .And. !(AllTrim(SX3->X3_VALID) == cTotValid)
	RecLock("SX3",.F.)
		SX3->X3_VALID := cTotValid
	MsUnlock()
EndIf 

If dbSeek("CNE_PERC") .And. !(AllTrim(SX3->X3_VALID) ==  cPrcValid)
	RecLock("SX3",.F.)
		SX3->X3_VALID := cPrcValid
	MsUnlock()
EndIf

If dbSeek("CNE_QUANT") .And. !(AllTrim(SX3->X3_VALID) == cQtdValid)
	RecLock("SX3",.F.)
		SX3->X3_VALID := cQtdValid
	MsUnlock()           
EndIf           

If dbSeek("CNE_TE") .And. SX3->X3_VALID != "Vazio().Or.ExistCPO('SF4')"
	RecLock("SX3",.F.)
		SX3->X3_VALID := "Vazio().Or.ExistCPO('SF4')"
	MsUnlock()
EndIf            

If FindFunction("cn130VldTE") 
	If dbSeek("CNE_TE") .And. SX3->X3_VALID != "cn130VldTE()"
		RecLock("SX3",.F.)
			SX3->X3_VALID := "(Vazio().Or.ExistCPO('SF4')) .And. CN130VldTE()"
		MsUnlock()
	EndIf                    
Else
	If dbSeek("CNE_TE") .And. SX3->X3_VALID != "Vazio().Or.ExistCPO('SF4')"
		RecLock("SX3",.F.)
			SX3->X3_VALID := "Vazio().Or.ExistCPO('SF4')"
		MsUnlock()
	EndIf     
EndIf


If FindFunction("cn130VldTS") 
	If dbSeek("CNE_TS") .And. SX3->X3_VALID != "cn130VldTS()"
		RecLock("SX3",.F.)
			SX3->X3_VALID := "cn130VldTS()"
		MsUnlock()
	EndIf                    
Else
	If dbSeek("CNE_TS") .And. SX3->X3_VALID != "Vazio().Or.ExistCPO('SF4')"
		RecLock("SX3",.F.)
			SX3->X3_VALID := "Vazio().Or.ExistCPO('SF4')"
		MsUnlock()
	EndIf     
EndIf       

If dbSeek("CND_SERVIC")
	If  !("1=Nao;2=Sim" $ SX3->X3_CBOX)
		RecLock("SX3", .F.)	
		SX3->X3_CBOX    := "1=Nao;2=Sim"
		SX3->X3_CBOXSPA := "1=No;2=Si"
		SX3->X3_CBOXENG := "1=No;2=Yes"
		MsUnlock()		
	EndIf
EndIf                                        
     
If dbSeek("CNE_VLUNIT") .And. !(AllTrim(SX3->X3_VALID) == cVUnValid)
	RecLock("SX3",.F.)
		SX3->X3_VALID := cVUnValid
	MsUnlock()
EndIf                            
                             
                          
If dbSeek("CNE_PRODUT") .And. !(AllTrim(SX3->X3_VALID) == cPrdValid)
	RecLock("SX3",.F.)
	SX3->X3_VALID := cPrdValid
	MsUnlock()
EndIf  

//Campo de Eliminacao do Residuo no cabecalho 
If dbSeek("CND_RESID")
	If  !("V" $ SX3->X3_VISUAL)
		RecLock("SX3", .F.)	
		SX3->X3_VISUAL := "V"
		MsUnlock()		
	EndIf
EndIf   

//Campo de Eliminacao do Residuo no Grid
If dbSeek("CNE_RESID")
	If  !("V" $ SX3->X3_VISUAL)
		RecLock("SX3", .F.)	
		SX3->X3_VISUAL := "V"
		MsUnlock()		
	EndIf
EndIf    

SX3->(dbSeek("CNE_QUANT"))
cUsado := SX3->X3_USADO
cReser := SX3->X3_RESERV

If dbSeek("CNE_TE")
	If  !(cUsado $ SX3->X3_USADO)
		RecLock("SX3", .F.)	
		SX3->X3_USADO  := cUsado
		SX3->X3_RESERV := cReser
		MsUnlock()		
	EndIf
EndIf    

If dbSeek("CNE_TS")
	If  !(cUsado $ SX3->X3_USADO)
		RecLock("SX3", .F.)	
		SX3->X3_USADO  := cUsado
		SX3->X3_RESERV := cReser
		MsUnlock()		
	EndIf
EndIf 

RestArea(aAreaSX3)
RestArea(aArea)    

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN120Aut  ³ Autor ³ Marcelo Custodio   ³ Data ³06/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao da Autorizacao de fornecimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN120Aut(cAlias,nReg,nOpc)

If !Empty(CND->(FieldPos("CND_AUTFRN"))) .And. !Empty(CND->(FieldPos("CND_PEDIDO")))
	CN120Inc(cAlias,nReg,nOpc,,2)
Else
	Aviso( "CNTA120", STR0066, { "OK" }, 2 )//"Opção não disponível. Execute o compatibilizador GCTUPD18"
EndIf

Return       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN120Serv ³ Autor ³ Aline Sebrian      ³ Data ³30/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao da Medicao de Servicos                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN120Serv(cAlias,nReg,nOpc)
If !Empty(CND->(FieldPos("CND_SERVIC")))  .And. !Empty(CNE->(FieldPos("CNE_QTDORI"))) .And. !Empty(CNE->(FieldPos("CNE_VUNORI")))
	CN120Inc(cAlias,nReg,nOpc,,,2)
Else
	Aviso( "CNTA120", STR0088, { "OK" }, 2 )//"Opção não disponível. Execute o compatibilizador GCTUPD36"
EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AjHelp     ³ Autor ³ Aline Sebrian        ³ Data ³09.09.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para incluir novos helps                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN120AjHelp()

Local aHlpP	:=	{}
Local aHlpE	:=	{}
Local aHlpS	:=	{}

aAdd (aHlpP, "Ação não disponível para contrato")
aAdd (aHlpP, " Cancelado.")
aAdd (aHlpE, " ")
aAdd (aHlpE, " ")
aAdd (aHlpE, " ")
aAdd (aHlpS, " ")
aAdd (aHlpS, " ")
aAdd (aHlpS, " ")
PutHelp ("PCNTA120_10", aHlpP, aHlpE, aHlpS, .T.)    
//

aHlpP	:=	{}
aHlpE	:=	{}
aHlpS	:=	{}

aAdd (aHlpP, "Ação não disponível para contrato")
aAdd (aHlpP, " com Revisão em Aberto.")
aAdd (aHlpE, " ")
aAdd (aHlpE, " ")
aAdd (aHlpE, " ")
aAdd (aHlpS, " ")
aAdd (aHlpS, " ")
aAdd (aHlpS, " ")
PutHelp ("PCNTA120_11", aHlpP, aHlpE, aHlpS, .T.)         

aHlpP	:=	{}
aHlpE	:=	{}
aHlpS	:=	{}

aAdd (aHlpP, "Estorno não permitido para revisões")
aAdd (aHlpP, " anteriores.")
aAdd (aHlpE, "Reversal not allowed for previous")
aAdd (aHlpE, "revisions.")
aAdd (aHlpS, "La inversión no se permite para  ")
aAdd (aHlpS, "las revisiones anteriores. ")
PutHelp ("PCNTA120_12", aHlpP, aHlpE, aHlpS, .T.)      

aHlpP	:=	{}
aHlpE	:=	{}
aHlpS	:=	{}

aAdd (aHlpP, "Selecionar a medição com a revisão atual.")     
aAdd (aHlpE, "Select the measurement with the current ")
aAdd (aHlpE, "revision.")
aAdd (aHlpS, "Seleccione la medición con la revisión ")
aAdd (aHlpS, "curso.")
PutHelp ("SCNTA120_12", aHlpP, aHlpE, aHlpS, .T.)
Return Nil		

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CNDMedEsp ³ Autor ³ Aline Sebrian         ³ Data ³07/10/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera consulta especifica do contrato à Medição              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNTA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CNDMedEsp()
Local aArea     := GetArea()    
Local aGrp   	:= {}     
Local aTamCab	:= {}
Local aButtons	:= {}
Local aCN120CMP := {}

Local cGrps     := ""
Local cQuery    := ""   
Local cQuery1   := ""
Local cQuery2   := ""
Local cQuery3   := ""
Local cQuery4   := ""
Local cQuery5   := ""
Local cCod      := RetCodUsr() 
Local cQueryPE  := ""

Local lVldVige  := GetNewPar("MV_CNFVIGE","N") == "N"   
Local lRet      := .F.

Local nSavQual  := 0
Local nX        := 0                                                              
Local nOpca		:= 0
Local nNovaOrd	:= 0
Local oQual
Local oPanel  
Local oDlg  

Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

PRIVATE aCab	   := {}
PRIVATE aCampos	   := {}
PRIVATE aArrayF4   := {}

dbSelectArea("CNN")
dbSetOrder(1)
				
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Grupos do usuario                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aGrp := UsrRetGrp(UsrRetName(cCod))
				
For nX:=1 to len(aGrp)
	cGrps += "'"+aGrp[nX]+"',"
Next
cGrps := SubStr(cGrps,1,len(cGrps)-1)

cQuery1 := " SELECT CN9_NUMERO, MAX(CN9_REVISA) AS CN9_REVISA"
If CN9->(FieldPos("CN9_FILCTR")) > 0
	cQuery1 += ", CN9_FILCTR "
EndIf
cQuery1 += " FROM " + RetSqlName("CN9") + " CN9 , "+ RetSqlName("CNN") + " CNN "
If AliasInDic("CPD")
	cQuery1 += ", "+ RetSqlName("CPD") + " CPD "
EndIf 

cQuery1 += " WHERE CN9_SITUAC   = '05' AND "

If AliasInDic("CPD")
	cQuery1 += " CPD.CPD_FILAUT = '"+cFilAnt+"' AND "
	cQuery1 += " CPD.CPD_CONTRA = CN9.CN9_NUMERO AND "
EndIf

If lVldVige
	cQuery1 += " ('"+DToS(dDataBase)+"' BETWEEN CN9_DTINIC AND CN9_DTFIM )  AND "
EndIf
cQuery1+= " CNN.CNN_FILIAL = CN9_FILIAL AND "
cQuery1+= " CNN.CNN_CONTRA = CN9_NUMERO AND "        

If CN9->(FieldPos("CN9_VLDCTR"))> 0
	cQuery2 := " CN9_VLDCTR ='2' "
	cQuery3 := " CN9_VLDCTR IN(' ','1') AND (CNN.CNN_USRCOD   = '"+ cCod +"'" 
	If len(aGrp) > 0
		cQuery3 += " OR CNN.CNN_GRPCOD IN ("+ cGrps +"))"
	Else
	    cQuery3 += ")"
	EndIf
Else
	cQuery3:= " (CNN.CNN_USRCOD   = '"+ cCod +"'"
	If len(aGrp) > 0
		cQuery3+= " OR CNN.CNN_GRPCOD IN ("+ cGrps +"))"
	Else
		cQuery3+=")"
	EndIf
EndIf

cQuery4 := " AND CNN.D_E_L_E_T_	= '' "
cQuery4 += " AND CN9.D_E_L_E_T_	= '' "
If AliasInDic("CPD") 
	cQuery4 += " AND CPD.D_E_L_E_T_	= '' "
EndIf
cQuery4 += " GROUP BY CN9_NUMERO"
If CN9->(FieldPos("CN9_FILCTR")) > 0
	cQuery4 += ", CN9_FILCTR "
EndIf
cQuery5 := " ORDER BY CN9_NUMERO,CN9_REVISA"
If CN9->(FieldPos("CN9_FILCTR")) > 0
	cQuery5 += ", CN9_FILCTR "
EndIf

If CN9->(FieldPos("CN9_VLDCTR"))> 0
	cQuery := cQuery1
    cQuery += cQuery2+" "+cQuery4
    cQuery += " UNION "
    cQuery += cQuery1            
    cQuery += cQuery3+" "+cQuery4+" "+cQuery5
Else                 
	cQuery := cQuery1
    cQuery += cQuery3+" "+cQuery4+" "+cQuery5
EndIf
                                     
If lPrjCni
	// FSW - Ponto de entrada para refazer a query retirando os contratos compartilhados
	If Existblock('CN120QCC')
		cQueryPE := Execblock('CN120QCC', .F., .F., {cQuery1, cQuery2, cQuery3, cQuery4, cQuery5})
		cQuery   := If(ValType(cQueryPE)=='C', cQueryPE, cQuery)
	Endif
EndIf

If Existblock('CN120ESY')
	cQueryPE := Execblock('CN120ESY', .F., .F., {cQuery})
	cQuery   := If(ValType(cQueryPE)=='C', cQueryPE, cQuery)
Endif
	
cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCN9",.F.,.T.)
	             
If !TRBCN9->(Eof())   
	DbSelectArea("SX3")
	DbSetOrder(2)     
	
	MsSeek("CN9_NUMERO")
	
	AAdd(aCab,x3Titulo())
	Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
	
	MsSeek("CN9_REVISA")
	
	AAdd(aCab,x3Titulo())
	Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE}) 
	
	If CN9->(FieldPos("CN9_FILCTR")) > 0
		MsSeek("CN9_FILCTR")
	
		AAdd(aCab,x3Titulo())
		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
	EndIf

	If Existblock('CN120CMP')
		aCN120CMP :=	Execblock('CN120CMP', .F., .F., {aCab,aCampos})  
			
		If Valtype(aCN120CMP) == "A"
			If Len(aCN120CMP)>=1 .And. Valtype(aCN120CMP[1]) == "A"
				aCab   := aClone(aCN120CMP[1])
			EndIf      
			
			If Len(aCN120CMP)>=2 .And. Valtype(aCN120CMP[2]) == "A"
				aCampos:= aClone(aCN120CMP[2])
			EndIf	 
		Endif
	EndIf		
EndIf	

While !TRBCN9->(Eof())   
	Aadd(aArrayF4,Array(Len(aCampos)))							  
	
	For nX := 1 to Len(aCampos)
		aArrayF4[Len(aArrayF4)][nX] := TRBCN9->(FieldGet(FieldPos(aCampos[nX][1])))								
	Next
	dbSelectArea("TRBCN9")
	dbSkip()
EndDo

TRBCN9->(dbCloseArea())

If !Empty(aArrayF4)
	aButtons		:= {{'pesquisa',{||C120PesqP(aCab,aCampos,aArrayF4,oQual)},OemToAnsi(STR0079),OemToAnsi(STR0002)} } //"Pesquisar"
	
	SetKey( VK_F4, { ||C120PesqP(aCab,aCampos,aArrayF4,oQual) } )	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta dinamicamente o bline do CodeBlock                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi(STR0073) Of oMainWnd PIXEL
	@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"

	oPanel:Align := CONTROL_ALIGN_TOP
	oQual := TWBrowse():New( 29,4,243,85,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oQual:SetArray(aArrayF4)
	oQual:bLine      := { || aArrayF4[oQual:nAT] }
	oQual:Align      := CONTROL_ALIGN_ALLCLIENT
	oQual:blDblClick := {|| nSavQual:=oQual:nAT,nOpcA := 1,oDlg:End()}

	@ 6  ,4   SAY OemToAnsi(STR0074) Of oPanel PIXEL SIZE 120 ,9 //"Selecione o Contrato"
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
					
	If nOpcA == 1
		dbSelectArea("CN9")
		dbSetOrder(1)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no registro da CN9 selecionado        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilCTR := If(Len(aArrayF4[nSavQual]) >= 3,aArrayF4[nSavQual,3],cFilAnt)
		dbSeek(xFilial("CN9",cFilCTR)+aArrayF4[ nSavQual, 1 ]+aArrayF4[ nSavQual,2 ])  
		lRet := .T.

	EndIF
	//Desabilita na tela da medicao do contrato a tecla F4  
	SetKey( VK_F4, Nil )
EndIf
	
RestArea(aArea)          
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³cn120VTip9 ³  Autor³ Aline Sebrian         ³ Data ³ 17.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se os vencimentos digitados na medicao  sao menores ³±±
±±³          ³que a data de emissao da medicao.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cnta120                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function cn120VTip9()
Local cVar := &(ReadVar())
Local cAlias := Alias()
Local lRet   := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente obriga a digita‡ao da data do vencimento      ³
//³quando a condi‡„o de pagamento for tipo 9.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE4")
dbSetOrder(1)
If dbSeek(xFilial()+M->CND_CONDPG)
	If SE4->E4_TIPO == "9"
		If DtoS(cVar) < DtoS(M->CND_DTINIC) .And. !Empty(cVar)  
			Aviso("CNTA120",OemToAnsi(STR0071),{"OK"}) //"Data de Vencimento da parcela deve ser maior ou igual a data de emissão da Medição."
			lRet := .F.
		Endif		
	Endif
Endif
dbSelectArea(cAlias)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³c120PesqP ³ Autor ³ Aline Sebrian         ³ Data ³07.05.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Seek no browse de itens de pedidos de compra                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array das descricoes dos cabecalhos                  ³±±
±±³          ³ExpA2 : Array com os campos                                  ³±±
±±³          ³ExpA3 : Array com os conteudos                               ³±±
±±³          ³ExpO4 : Objeto do listbox                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo abrir uma janela de pesquisa   ³±±
±±³          ³em browses de getdados poisicionando na llinha caso encontre ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function c120PesqP(aCab,aCampos,aArrayF4,oQual)

Local aCpoBusca	:= {}
Local aCpoPict	:= {}
Local aComboBox	:= { AllTrim( STR0075) , AllTrim( STR0076 ) , AllTrim( STR0077 ) } //"Exata"###"Parcial"###"Contem"

Local bAscan	:= { || .F. }

Local cPesq		:= Space(30)
Local cBusca	:= ""
Local cTitulo	:= OemtoAnsi(STR0002)  //"Pesquisar"
Local cOpcAsc	:= aComboBox[1]	//"Exata"
Local cAscan	:= ""

Local nOpca		:= 0
Local nPos		:= 0
Local nx		:= 0
Local nTipo		:= 1
Local nBusca	:= Iif(oQual:nAt == Len(aArrayF4) .Or. oQual:nAt == 1, oQual:nAt, oQual:nAt+1 )

Local oDlg
Local oBusca
Local oPesq1
Local oPesq2
Local oPesq3
Local oPesq4
Local oComboBox

For nX := 1 to Len(aCampos)
	AAdd(aCpoBusca,aCab[nX])
	AAdd(aCpoPict,aCampos[nX][4])
Next	

If Len(aCampos) > 0 .And. Len(aArrayF4) > 0

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(cTitulo)  FROM 00,0 TO 100,490 OF oMainWnd PIXEL

	@ 05,05 MSCOMBOBOX oBusca VAR cBusca ITEMS aCpoBusca SIZE 206, 36 OF oDlg PIXEL ON CHANGE (nTipo := oBusca:nAt,C120ChgPic(nTipo,aCampos,@cPesq,@oPesq1,@oPesq2,@oPesq3,@oPesq4))

	@ 022,005 MSGET oPesq1 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL

	@ 022,005 MSGET oPesq2 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL

	@ 022,005 MSGET oPesq3 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL

	@ 022,005 MSGET oPesq4 VAR cPesq Picture "@!" SIZE 206, 10 Of oDlg PIXEL

	oPesq1:Hide()
	oPesq2:Hide()
	oPesq3:Hide()	
	oPesq4:Hide()		

	Do Case
	Case aCampos[1][2] == "C"

		DbSelectArea("SX3")
		DbSetOrder(2)
		If MsSeek(aCampos[1][1])
			If !Empty(SX3->X3_F3)
				oPesq2:cF3 := SX3->X3_F3
				oPesq1:Hide()				
				oPesq2:Show()				
				oPesq3:Hide()
				oPesq4:Hide()
			Else	
				oPesq1:Show()			
				oPesq2:Hide()
				oPesq3:Hide()				
				oPesq4:Hide()				
			Endif
		Endif		

	Case aCampos[1][2] == "D"
		oPesq1:Hide()
		oPesq2:Hide()				
		oPesq3:Show()
		oPesq4:Hide()						
	Case aCampos[1][2] == "N"
		oPesq1:Hide()
		oPesq2:Hide()				
		oPesq3:Hide()
		oPesq4:Show()						
	EndCase

	cPesq := CriaVar(aCampos[1][1],.F.)
	cPict := aCampos[1][4]

	DEFINE SBUTTON oBut1 FROM 05, 215 TYPE 1 ACTION ( nOpca := 1, oDlg:End() ) ENABLE of oDlg		 	
	DEFINE SBUTTON oBut1 FROM 20, 215 TYPE 2 ACTION ( nOpca := 0, oDlg:End() )  ENABLE of oDlg		

	@ 037,005 SAY OemtoAnsi(STR0078) SIZE 050,10 OF oDlg PIXEL //Tipo
	@ 037,030 MSCOMBOBOX oComboBox VAR cOpcAsc ITEMS aComboBox SIZE 050,10 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1

		Do Case

		Case aCampos[nTipo][2] == "C"
			IF ( cOpcAsc == aComboBox[1] )	//Exata
				cAscan := Padr( Upper( cPesq ) , TamSx3(aCampos[nTipo][1])[1] )
				bAscan := { |x| cAscan == Upper( x[ nTipo ] ) }
			ElseIF ( cOpcAsc == aComboBox[2] )	//Parcial
				cAscan := Upper( AllTrim( cPesq ) )
				bAscan := { |x| cAscan == Upper( SubStr( Alltrim( x[nTipo] ) , 1 , Len( cAscan ) ) ) }
			ElseIF ( cOpcAsc == aComboBox[3] )	//Contem
				cAscan := Upper( AllTrim( cPesq ) )
				bAscan := { |x| cAscan $ Upper( Alltrim( x[nTipo] ) ) }
			EndIF

			nPos := Ascan( aArrayF4 , bAscan )
		Case aCampos[nTipo][2] == "N"		
			nPos := Ascan(aArrayF4,{|x| Transform(cPesq,PesqPict("SC7",aCampos[nTipo][1])) == x[nTipo]},nBusca)	
		Case aCampos[nTipo][2] == "D"
			nPos := Ascan(aArrayF4,{|x| Dtos(cPesq) == Dtos(x[nTipo])},nBusca)
		EndCase

		If nPos > 0
			If Existblock("CN120PSQ")
				aCn120Psq := Execblock("CN120PSQ",.F.,.F.,{aArrayF4,cPesq,cOpcAsc,cAscan,bAscan,nPos,aCampos,nTipo,nBusca})
				If Valtype(aCn120Psq) == 'A'
					aArrayF4	:= aClone(aCn120Psq[1])
					nPos		:= aCn120Psq[2]
				Endif
			Endif
			oQual:bLine := { || aArrayF4[oQual:nAT] }
			oQual:nFreeze := 1
			oQual:nAt := nPos                		
			oQual:Refresh()
			oQual:SetFocus()
		Else
			Help(" ",1,"REGNOIS")	
		Endif	

	EndIf
Endif
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³C120ChgPic³ Autor ³ Aline Sebrian         ³ Data ³07.05.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Atualiza picture na funcao C120PespP                         ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Posicao do campo no Array                            ³±±
±±³          ³ExpA2 : Array com os dados dos campos                        ³±±
±±³          ³ExpX3 : Pesquisa                                             ³±±
±±³          ³ExpO4 : Objeto de pesquisa                                   ³±±
±±³          ³ExpO5 : Objeto de pesquisa                                   ³±±
±±³          ³ExpO6 : Objeto de pesquisa                                   ³±±
±±³          ³ExpO7 : Objeto de pesquisa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo tratar a picture do campo sele ³±±
±±³          ³cionado na funcao GdSeek                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C120ChgPic(nTipo,aCampos,cPesq,oPesq1,oPesq2,oPesq3,oPesq4)

Local cPict   := ""
Local aArea   := GetArea()
Local aAreaSX3:= SX3->(GetArea())
Local bRefresh


DbSelectArea("SX3")
DbSetOrder(2)
If MsSeek(aCampos[nTipo][1])

	Do case

	Case aCampos[nTipo][2] == "C"
		If !Empty(SX3->X3_F3)
			oPesq2:cF3 := SX3->X3_F3
			oPesq1:Hide()
			oPesq2:Show()			
			oPesq3:Hide()
			oPesq4:Hide()			
			bRefresh := { || oPesq2:oGet:Picture := cPict,oPesq2:Refresh() }
		Else	
			oPesq1:Show()
			oPesq2:Hide()
			oPesq3:Hide()			
			oPesq4:Hide()			                                     			
			bRefresh := { || oPesq1:oGet:Picture := cPict,oPesq1:Refresh() }		
		Endif

	Case aCampos[nTipo][2] == "D"
		oPesq1:Hide()
		oPesq2:Hide()
		oPesq3:Show()			
		oPesq4:Hide()			                                                    		
		bRefresh := { || oPesq3:oGet:Picture := cPict,oPesq3:Refresh() }				
	Case aCampos[nTipo][2] == "N"
		oPesq1:Hide()
		oPesq2:Hide()
		oPesq3:Hide()
		oPesq4:Show()
		bRefresh := { || oPesq4:oGet:Picture := cPict,oPesq4:Refresh() }				
	EndCase

Endif		

If nTipo > 0
	cPesq := CriaVar(aCampos[nTipo][1],.F.)
	cPict := aCampos[nTipo][4]
EndIf							

Eval(bRefresh)

RestArea(aAreaSX3)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN120VldProd³ Autor ³ Allyson Freitas       ³ Data ³ 11.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida permissao de Produto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProd: Produto                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA120                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120VldProd(cProd)
Local lRet	 := .T.
Local lVer116 := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() >= "R6" .Or. VAL(GetVersao(.F.))  > 11) .And. FindFunction("MaAvalPerm")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario tem permissao de inclusao. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui
	If lVer116
		If !(lRet := MaAvalPerm(1,{cProd,"CNT120",3}))
			Help(,,1,'SEMPERM')
		EndIf
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AjustaSX1  ³ Autor ³ Aline Sebrian         ³ Data ³14/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Configura as perguntas da rotina de contrato                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustaSX1()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX1()
Local aAreaAnt := GetArea()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local cPerg	   := "CNT120" 	

//---------------------------------------MV_PAR01--------------------------------------------------
aHelpPor := {"Contabiliza o contrato? "}
aHelpEng := {"¨Contabiliza el contrato?"}
aHelpSpa := {"Account for contract?    "}

PutSX1(cPerg,"01","Contabiliza ?","¨Contabiliza ?","Account for ?","mv_ch1","N",1,0,1,"C","","","","N","mv_par01","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR02--------------------------------------------------
aHelpPor := {"Exibe contabilização do contrato?"}
aHelpEng := {"¨Mostra Asiento Contab ?"}
aHelpSpa := {"Show Accounting Entries ?"}

PutSX1(cPerg,"02","Mostra Lanc Contab ?","¨Mostra Asiento Contab ?","Show Accounting Entries ?","mv_ch2","N",1,0,1,"C","","","","N","mv_par02","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR03--------------------------------------------------
aHelpPor := {"Aglutina os lançamentos contábeis?"}

PutSX1(cPerg,"03","Aglutina Lanc. Contab ?","Aglutina Lanc. Contab ?","Aglutina Lanc. Contab ?","mv_ch3","N",1,0,1,"C","","","","N","mv_par03","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

RestArea(aAreaAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120GetRaºAutor  ³Microsiga           º Data ³  01/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que obtem o rateio de pedidos de compra ou venda.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN120GetRa(cContrato,cNumMed,cRevisao,cItemPlan,aDadoEnt,cPedItem)
Local aRet		:= {}
Local aAux		:= {}
Local nSetOrder	:= If(Upper(aDadoEnt[1]) == "FORNECEDOR",3,4)
Local cCodEnt	:= If(Upper(aDadoEnt[1]) == "FORNECEDOR","CNZ_FORNEC","CNZ_CLIENT")
Local cLjEnt	:= If(Upper(aDadoEnt[1]) == "FORNECEDOR","CNZ_LJFORN","CNZ_LOJACL")
Local cBusca	:= xFilial("CNZ",cFilCTR)+cContrato+cRevisao+cNumMed+aDadoEnt[2]+aDadoEnt[3]+cItemPlan
                      
Default cPedItem := ''

CNZ->(dbSetOrder(nSetOrder))
If CNZ->(dbSeek(cBusca)) 			
	While CNZ->(!Eof()) .And. cBusca == xFilial("CNZ",cFilCTR)+CNZ->(CNZ_CONTRA+CNZ_REVISA+CNZ_NUMMED+&(cCodEnt)+&(cLjEnt)+CNZ_ITCONT)
		If CNZ->CNZ_PERC == 0
			aRet := {}
			Exit
		EndIf
		   
		If Upper(aDadoEnt[1]) == "FORNECEDOR"      		                                                                             
			aAux := {}
			aAdd(aAux,{"CH_ITEMPD"		, cPedItem           , nil}) //Nro do Item do Pedido de Compras
			aAdd(aAux,{"CH_ITEM"		, CNZ->CNZ_ITEM		, nil})
			aAdd(aAux,{"CH_PERC"		, CNZ->CNZ_PERC		, nil})
			aAdd(aAux,{"CH_CC"			, CNZ->CNZ_CC		, nil})
			aAdd(aAux,{"CH_CONTA"		, CNZ->CNZ_CONTA	, nil})
			aAdd(aAux,{"CH_ITEMCTA"		, CNZ->CNZ_ITEMCT	, nil})
			aAdd(aAux,{"CH_CLVL"		, CNZ->CNZ_CLVL		, nil})    
			aadd(aRet,aAux)  
		Else
			aAdd(aAux,{"AGG_ITEMPD"		, cItemPlan			, nil})
			aAdd(aAux,{"AGG_ITEM"		, CNZ->CNZ_ITEM		, nil})
			aAdd(aAux,{"AGG_PERC"		, CNZ->CNZ_PERC		, nil})
			aAdd(aAux,{"AGG_CC"			, CNZ->CNZ_CC		, nil})
			aAdd(aAux,{"AGG_CONTA"		, CNZ->CNZ_CONTA	, nil})
			aAdd(aAux,{"AGG_ITEMCTA"	, CNZ->CNZ_ITEMCT	, nil})
			aAdd(aAux,{"AGG_CLVL"		, CNZ->CNZ_CLVL		, nil})   
			aadd(aRet,aAux)  
			aAux := {}
		Endif													
				
		CNZ->(DbSkip())
	EndDo
Endif
Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OnStack   ºAutor  ³FSW	             º Data ³  15/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a funcao esta na pilha de chamadas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OnStack(cFunc)
Local lRet := .F.
Local cProc := ""
Local nX := 0

While !Empty(cProc := ProcName( nX++ )) .And. !lRet
	lRet := (Alltrim(Upper(cProc)) == cFunc)
End

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120VlExcºAutor  ³Microsiga           º Data ³  08/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que retorna o valor total correspondente aos        º±±
±±º          ³ excedentes de uma medicao.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cContra: numero do contrato								  º±±
±±º			 ³ cRevisa: numero da revisao								  º±±
±±º          ³ cNumMed: numero da medicao								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ nRet: valor total dos excedentes da medicao				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN120VlExc(cContra,cRevisa,cNumMed)
Local aArea  := GetArea()
Local nRet   := 0
Local cQuery := ""

Default cContra := CND->CND_CONTRA
Default cRevisa := CND->CND_REVISA
Default cNumMed := CND->CND_NUMMED

If CNE->(FieldPos("CNE_EXCEDE")) > 0
	cQuery := "SELECT SUM(CNE.CNE_VLTOT) - SUM(CNE.CNE_VLDESC) AS TOTAL "
	cQuery += "FROM " +RetSQLName("CNE") +" CNE WHERE CNE.D_E_L_E_T_ <> '*' AND "
	cQuery += "CNE.CNE_FILIAL = '" +xFilial("CNE") +"' AND CNE.CNE_CONTRA = '" +cContra +"' AND "
	cQuery += "CNE.CNE_REVISA = '" +cRevisa +"' AND CNE.CNE_NUMMED = '" +cNumMed +"' AND "
	cQuery += "CNE.CNE_EXCEDE = '1'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
	nRet := TRB->TOTAL
	TRB->(dbCloseArea())
EndIf

RestArea(aArea)
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120ExceM³ Autor ³Joao Goncalves de Oliveira   ³Data ³08/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inclui excedente na medicao apos encerramento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120ExceM(cExp01,nExp02,nExp03)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Arquivo                                        ³±±
±±³          ³ ExpN2 - Numero do Registro                                      ³±±
±±³          ³ ExpN3 - Opcao de Atualizacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Nenhum                       						   		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN120ExceM(cAlias,nReg,nOpc)
Local lContinua := CN240VldUsr(CND->CND_CONTRA,DEF_TRAEDT,.T.,,cFilCtr)
Local aValidGet := {}
Local aCN130CEX := {}
Local aEditCamp := {"CNE_QUANT","CNE_DTENT","CNE_FLGCMS","CNE_PEDTIT"}
Local cChave    := ""
Local cNumPed   := ""
Local cTes      := ""
Local cQuery    := ""
Local cTabPrc   := ""
Local cItem		:= ""
Local nX		:= 0
Local nY		:= 0
Local nPNUMMED  := 0
Local nPPRODUT  := 0
Local nPQUANT   := 0
Local nPITEM	:= 0
Local nSumMed   := 0

//-- Valida o tipo do contrato
CN9->(dbSetOrder(1))
If lContinua .And. CN9->(dbSeek(xFilial("CN9",cFilCTR)+CND->CND_CONTRA+CND->CND_REVISA))
	If CN9->(FieldPos("CN9_ESPCTR")) > 0 .And. CN9->CN9_ESPCTR == "1"
		Aviso(STR0094,STR0090,{"OK"}) //-- Funcionalidade indisponível para contratos de compra.
		lContinua := .F.
	ElseIf Empty(CN9->CN9_CLIENT)
		Aviso(STR0094,STR0090,{"OK"}) //-- Funcionalidade indisponível para contratos de compra.
		lContinua := .F.
	EndIf	
	
EndIf

//-- Valida se e medicao encerrada
If Empty(CND->CND_DTFIM)
	Help(" ",1,"CNTA120_13")
	lContinua := .F.
EndIf

//-- Ponto de entrada para permitir alterar mais campos
If ExistBlock("CN130CEX")
	aCN130CEX := ExecBlock("CN130CEX",.F.,.F.,{aEditCamp})
	If ValType(aCN130CEX) == "A"
		aEditCamp := aClone(aCN130CEX)
	EndIf
EndIf

If lContinua .And. lAuto .And. !Empty(aAutoItens) .And. (nPNUMMED := aScan(aAutoCab,{|x| AllTrim(x[1]) == "CND_NUMMED"})) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida numero da medicao                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aValidGet,{"cNumMed",aAutoCab[nPNUMMED,2],"CN120NumAuto(cNumMed,.F.)",.T.})
	If (lContinua := MsVldGAuto(aValidGet))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto excedente esta gravado na medicao      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aAutoItens)              
			If (nPITEM	 := aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_ITEM"})) > 0 .And.;
			   (nPQUANT	 := aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_QUANT"})) > 0
			 	
				cQuery := "SELECT CNE.CNE_PRODUT, CNE.CNE_DTENT, CNE.CNE_FLGCMS, CNE.CNE_TS "
				If CNE->(FielPos("CNE_PEDTIT")) > 0 
					cQuery += ", CNE.CNE_PEDTIT "
				EndIf
				cQuery += "FROM " +RetSQLName("CNE") +" CNE "
				cQuery += "JOIN " +RetSQLName("CNB") +" CNB "
				cQuery += "ON CNB.D_E_L_E_T_ <> '*' AND "
				cQuery += "CNB.CNB_FILIAL = '" +xFilial("CNB",cFilCTR) +"' AND "
				cQuery += "CNB.CNB_ITEM = CNE.CNE_ITEM AND "
				cQuery += "CNB.CNB_PRODUT = CNE.CNE_PRODUT AND "
				cQuery += "CNB.CNB_NUMERO = '" +CND->CND_NUMERO +"' AND "
				cQuery += "CNB.CNB_TABPRC <> ' ' "
				cQuery += "WHERE CNE.D_E_L_E_T_ <> '*' AND "
				cQuery += "CNE.CNE_FILIAL = '" +xFilial("CNE") + "' AND "
				cQuery += "CNE.CNE_NUMMED = '" +CND->CND_NUMMED + "' AND "
				cQuery += "CNE.CNE_ITEM = '" +aAutoItens[nX,nPITEM,2] +"' AND "
				cQuery += "CNE.CNE_EXCEDE <> '1'"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCNE",.F.,.T.)
				If TRBCNE->(EOF())
					Aviso(STR0114,STR0095 +aCols[nAux,nPITEM] +STR0096) //-- O item ### não possui preço para a quantidade excedente.
					lContinua := .F.
				Else
					If Empty(aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_PRODUT"}))
						aAdd(aAutoItens[nX],{"CNE_PRODUT",TRBCNE->CNE_PRODUT,NIL})
						nPPRODUT := Len(aAutoItens[nX])
					EndIf
					If Empty(aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_DTENT"}))
						aAdd(aAutoItens[nX],{"CNE_DTENT",TRBCNE->CNE_DTENT,NIL})
					EndIf
					If Empty(aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_FLGCMS"}))
						aAdd(aAutoItens[nX],{"CNE_FLGCMS",TRBCNE->CNE_FLGCMS,NIL})
					EndIf
					If Empty(aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_TS"}))
						aAdd(aAutoItens[nX],{"CNE_TS",TRBCNE->CNE_TS,NIL})
					EndIf
					If CNE->(FielPos("CNE_PEDTIT")) > 0 .And. Empty(aScan(aAutoItens[nX],{|x| AllTrim(x[1]) == "CNE_PEDTIT"}))
						aAdd(aAutoItens[nX],{"CNE_PEDTIT",TRBCNE->CNE_PEDTIT,NIL})
					EndIf
				EndIf
				TRBCNE->(dbCloseArea())
			Else
				Aviso(STR0094,STR0095,{"OK"}) //-- Campo item ou quantidade ausente para geração do excedente.
				lContinua := .F.
			EndIf	
		Next nX
	EndIf
EndIf

cChave := CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED
If lContinua .And. LockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)
	If lAuto
		//-- Pega maior item da medicao
		cQuery := "SELECT MAX(CNE_ITEM) AS CNE_ITEM FROM " +RetSQLName("CNE") +" WHERE "
		cQuery += "D_E_L_E_T_ <> '*' AND CNE_FILIAL = '" + xFilial("CNE") + "' AND "
		cQuery += "CNE_NUMMED = '" +CND->CND_NUMMED + "'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCNE",.F.,.T.)
		cItem := TRBCNE->CNE_ITEM
		TRBCNE->(dbCloseArea())
			
		Begin Transaction

		For nX := 1 To Len(aAutoItens)
			cItem   := Soma1(cItem)
			cTabPrc := Posicione("CNB",1,xFilial("CNB",cFilCTR)+CND->(CND_CONTRA+CND_REVISA+CND_NUMERO)+aAutoItens[nX,nPITEM,2],"CNB_TABPRC")
			
			If Empty(nPrcUnit := MaTabPrVen(cTabPrc,aAutoItens[nX,nPPRODUT,2],aAutoItens[nX,nPQUANT,2],CND->CND_CLIENT,CND->CND_LOJACL,1,dDataBase))
				Aviso(STR0094,STR0096 +aCols[nAux,nPITEM] +STR0097,{"OK"}) //-- O item ### " não possui preço para a quantidade excedente.
				DisarmTransaction()
				lContinua := .F.
				Exit
			EndIf
							
			Reclock("CNE",.T.)
			For nY := 1 to Len(aAutoItens[nX])
				If aScan(aEditCamp,{|x| AllTrim(x) == AllTrim(aAutoItens[nX,nY,1])}) > 0
					CNE->(FieldPut(FieldPos(aAutoItens[nX,nY,1]),aAutoItens[nX,nY,2]))
				ElseIf aAutoItens[nX,nY,1] # "LINPOS"
					CNE->(FieldPut(FieldPos(aAutoItens[nX,nY,1]),CriaVar(aAutoItens[nX,nY,1])))
				EndIf
			Next nY
			
			//-- Campos de controle do sistema
			CNE->CNE_FILIAL := xFilial("CNE")
			CNE->CNE_NUMERO := CND->CND_NUMERO
			CNE->CNE_NUMMED := CND->CND_NUMMED
			CNE->CNE_REVISA := CND->CND_REVISA
			CNE->CNE_CONTRA := CND->CND_CONTRA
			CNE->CNE_ITEM   := cItem
			CNE->CNE_PRODUT := aAutoItens[nX,nPPRODUT,2]
			CNE->CNE_TS     := Posicione("CNB",1,xFilial("CNB",cFilCTR)+CND->(CND_CONTRA+CND_REVISA+CND_NUMERO)+aAutoItens[nX,nPITEM,2],"CNB_TS")
			If CNE->(FieldPos("CNE_PEDTIT")) > 0
				CNE->CNE_PEDTIT := Posicione("CNB",1,xFilial("CNB",cFilCTR)+CND->(CND_CONTRA+CND_REVISA+CND_NUMERO)+aAutoItens[nX,nPITEM,2],"CNE_PEDTIT")
			EndIf
			CNE->CNE_EXCEDE := '1'
			CNE->CNE_VLUNIT := nPrcUnit
			CNE->CNE_VLTOT  := Round(nPrcUnit * aAutoItens[nX,nPQUANT,2],TamSX3('CNE_VLTOT')[2])
			CNE->(MsUnlock())
			
			nSumMed += CNE->CNE_VLTOT
		Next nX
						
		End Transaction
		
		//-- Processa geracao do pedido excedente
		If lContinua
			RecLock("CND",.F.)
			CND->CND_VLTOT += nSumMed
			CND->(MsUnLock())

			Processa({|| CN120GrvPeD(CND->CND_NUMMED,CND->CND_REVISA,@cNumPed,NIL,CND->CND_CONTRA,@cTes,.T.)},,STR0039) //"Gerando Pedido de Vendas"
		EndIf			
	Else
		CN130Manut(cAlias,nReg,nOpc,"EXCEDE",CND->CND_CONTRA,CND->CND_REVISA)
	EndIf
ElseIf lContinua //Nao permite processamento concorrente	
	Aviso(STR0068,OemtoAnsi(STR0069),{"OK"},2) // ##"Concorrência"##"Esta Medição está em uso por outra estação."
EndIf
UnLockByName("CN120"+xFilial("CND")+cChave,.T.,!Empty(xFilial("CND")),.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120PlansºAutor  ³ Andre Anjos	     º Data ³  24/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta variaveis utilizadas na montagem do browse da selecaoº±±
±±º          ³ das planilhas a medir e o arquivo temporario.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN120Plans(cArqCNA,aTitle,aCampos,cLine)
Local aStruCNA  := CNA->(dbStruct())
Local aCn120cpo := {}
Local aNewFld   := {}
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona parcela e valor previsao a estrutura da planilha    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aStruCNA,{"CNF_PARCEL","C",TamSX3("CNF_PARCEL")[1],TamSX3("CNF_PARCEL")[2]})
aAdd(aStruCNA,{"CNF_VLPREV","N",TamSX3("CNF_VLPREV")[1],TamSX3("CNF_VLPREV")[2]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria arquivo temporario                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqCNA := CriaTrab(aStruCNA)
dbUseArea(.T.,,cArqCNA,"TRBCNA",.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura campos exibidos na inclusao de medicoes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))
	aTitle := { "",RetTitle("CNA_NUMERO"),RetTitle("CNF_PARCEL"),RetTitle("CNA_DTINI"),RetTitle("CNA_DTFIM"),RetTitle("CNA_VLTOT"),RetTitle("CNF_VLPREV"),RetTitle("CNA_FORNEC"),RetTitle("CNA_LJFORN"),RetTitle("CNA_CRONOG")}
	aCampos := {"",TRBCNA->CNA_NUMERO,TRBCNA->CNF_PARCEL,TRBCNA->CNA_DTINI,TRBCNA->CNA_DTFIM,TRBCNA->CNA_VLTOT,TRBCNA->CNF_VLPREV,TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG}
	cLine := "{If((cPlan+cParcel==(TRBCNA->CNA_NUMERO+TRBCNA->CNF_PARCEL)),oOk,oNo),TRBCNA->CNA_NUMERO,TRBCNA->CNF_PARCEL,TRBCNA->CNA_DTINI,TRBCNA->CNA_DTFIM,Transform(TRBCNA->CNA_VLTOT,PesqPict('CNA','CNA_VLTOT')),Transform(TRBCNA->CNF_VLPREV,PesqPict('CNF','CNF_VLPREV')),TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG,"

Else
	aTitle := { "",RetTitle("CNA_NUMERO"),RetTitle("CNA_DTINI"),RetTitle("CNA_DTFIM"),RetTitle("CNA_VLTOT"),RetTitle("CNF_VLPREV"),RetTitle("CNA_FORNEC"),RetTitle("CNA_LJFORN"),RetTitle("CNA_CRONOG")}
	aCampos := {"",TRBCNA->CNA_NUMERO,TRBCNA->CNA_DTINI,TRBCNA->CNA_DTFIM,TRBCNA->CNA_VLTOT,TRBCNA->CNF_VLPREV,TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG}
 	cLine := "{If((cPlan==TRBCNA->CNA_NUMERO),oOk,oNo),TRBCNA->CNA_NUMERO,TRBCNA->CNA_DTINI,TRBCNA->CNA_DTFIM,Transform(TRBCNA->CNA_VLTOT,PesqPict('CNA','CNA_VLTOT')),Transform(TRBCNA->CNF_VLPREV,PesqPict('CNF','CNF_VLPREV')),TRBCNA->CNA_FORNEC,TRBCNA->CNA_LJFORN,TRBCNA->CNA_CRONOG,"	
EndIf

If ExistBlock("CN120CPO")
	aCn120cpo := ExecBlock("CN120CPO",.F.,.F.)
	If ValType(aCn120cpo) == "A"
		aNewFld := aCn120cpo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Varre os campos especificos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aNewFld)
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(aNewFld[nx])) //Pesquisa estrutura do campo
		If SX3->X3_TIPO == "N"//Monta cLine para campos numericos
			cLine += "Transform(TRBCNA->"+aNewFld[nx]+",PesqPict('CNA','"+aNewFld[nx]+"')),"
		Else
			cLine += "TRBCNA->"+aNewFld[nx]+","
		EndIf		
		aAdd(aTitle,RetTitle(aNewFld[nx]))
		aAdd(aCampos,TRBCNA->(&(aNewFld[nx])))
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza construcao do cLine ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLine := substr(cLine,1,len(cLine)-1)+"}"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120ExceCºAutor  ³ Andre Anjos 		 º Data ³  21/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza a inclusao de medicao excedente para uma compet.   º±±
±±º          ³ inexistente na CNF.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120ExceC(cAlias,nReg,nOpc)
Local oWizard   := NIL
Local oOk       := LoadBitmap(GetResources(),"LBTIK")
Local oNo  	    := LoadBitmap(GetResources(),"LBNO")
Local aStruCNA  := CNA->(dbStruct())
Local aTitle    := {}
Local aCampos   := {}
Local aAlter    := {"UCNE_QUANT","CNE_DTENT","CNE_FLGCMS","CNE_PEDTIT"}
Local aValidGet := {}
Local aRetPE	:= {}
Local cLine    	:= ""
Local cArqCNA  	:= ""
Local cConsSxb 	:= "CN9003"
Local nX	   	:= 0
Local nPQUANT   := 0

Private cContra   := CriaVar("CND_CONTRA",.F.)
Private cRevisa   := CriaVar("CND_REVISA",.F.)
Private cCompet   := CriaVar("CNF_COMPET",.F.)
Private cPlan     := CriaVar("CND_NUMERO",.F.)
Private cParcel   := ""
Private cNumMed   := ""
Private lFixo	  := .T.
Private lMedeve   := .F.
Private lEncerra  := .F.
Private aListBox  := {}
Private nTotMed   := 0
Private nCaucVlr  := 0
Private oBrowse   := NIL
Private oCbx      := NIL
Private oGetDados := NIL
Private oGetTot   := NIL
Private cEspCtr   := '1'

Private aHeader := {}
Private aCols   := {}

cTexto := STR0097 //-- Assistente responsável pela inclusão de medição de excedentes contratuais para uma competência
cTexto += STR0098 //-- não prevista no contrato. Nesta medição, apenas itens excedentes poderão ser lançados.
cTexto += CRLF + CRLF
cTexto += STR0099 //-- Clique em avançar e inicie o processo

If ExistBlock("CN120SXB")
	cConsSxb := If(Valtype(cCn120Sxb:=ExecBlock("CN120SXB",.F.,.F.))=="C",cCn120Sxb,"CN9003")
EndIf

SX3->(dbSetOrder(2))
SX3->(dbSeek("CNE_ITEM"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_PRODUT"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_DESCRI"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_QUANT"))
//-- Troca nome do campo para nao executar gatilhos
aAdd(aHeader,{AllTrim(X3Titulo()),"UCNE_QUANT",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"CN120VlQEx()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_VLUNIT"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_VLTOT"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_DTENT"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_FLGCMS"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_TS"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_TABPRC"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
SX3->(dbSeek("CNE_EXCEDE"))
aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
If SX3->(dbSeek("CNE_PEDTIT"))
	aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT})
EndIf
If lAuto
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida os campos do cabecalho da medicao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aValidGet,{"cContra",aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_CONTRA"}),2],"CheckSX3('CND_CONTRA',cContra)",.T.})
	aAdd(aValidGet,{"cRevisa",aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_REVISA"}),2],"CheckSX3('CND_REVISA',cRevisa) .And. CN120CtrAuto(cContra,cRevisa,.T.)",.T.})
	aAdd(aValidGet,{"cPlan",aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_NUMERO"}),2],"CheckSX3('CND_NUMERO',cPlan)",.T.})
	If !Empty(CND->(FieldPos("CND_PARCEL"))) .And. aScan(aAutoCab,{|x| x[1]=="CND_PARCEL"}) > 0
	  	aAdd(aValidGet,{"cParcel",aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_PARCEL"}),2],"CheckSX3('CND_PARCEL',cParcel)",.T.})
	EndIf
	aAdd(aValidGet,{"cCompet",aAutoCab[aScan(aAutoCab,{|x| x[1]=="CND_COMPET"}),2],"CheckSX3('CND_COMPET',cCompet) .And. CN120VldCpt(.T.)",.T.})	
	
	If (nPosNum := aScan(aAutoCab,{|x| x[1] == "CND_NUMMED"})) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida campo CND_NUMMED quando fornecido atraves    ³
		//³da rotina automatica                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumMed := aAutoCab[nPosNum,2]
		aAdd(aValidGet,{"cNumMed",aAutoCab[nPosNum,2],"CN120NumAuto(cNumMed,.T.)",.T.})
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PE para permitir alterar a validacao da rotina automatica ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("CN120AutVl")
		aRetPE := ExecBlock("CN120AutVl",.F.,.F.,{aValidGet})
		
		If ValType(aRetPE) == "A"
			aValidGet := aClone(aRetPE)
		EndIf
	EndIf
	
	If MsVldGAuto(aValidGet)
		//-- Prepara memoria para gravacao
		RegToMemory("CND",.T.,.F.,.T.)
	
		//-- Joga do array para memoria
		For nX := 1 To Len(aAutoCab)
			If Substr(aAutoCab[nX,1],1,4) == "CND_"
				&("M->" +aAutoCab[nX,1]) := aAutoCab[nX,2]
			EndIf
		Next nX
		
		//-- Verifica chave de encerramento da medicao
		lEncerra := aScan(aAutoCab,{|x| AllTrim(x[1]) == "ENCERRA" .And. x[2] == "S"}) > 0
		
		//-- Se validou, carrega aCols
		CN120VldPn(1,@aHeader,@aCols)
		
		//-- Ajusta o nome do campo de quantidade e coloca valid
		If Len(aAutoItens) > 0 .And. (nPQUANT := aScan(aAutoItens[1],{|x| AllTrim(x[1]) = "CNE_QUANT"})) > 0
			For nX := 1 To Len(aAutoItens)
				aAutoItens[nX,nPQUANT,1] := "UCNE_QUANT"
				If ValType(aAutoItens[nX,nPQUANT,3]) == "C" .And. !Empty(aAutoItens[nX,nPQUANT,3])
					aAutoItens[nX,nPQUANT,3] += ".And.CN120VlQEx()"
				Else
					aAutoItens[nX,nPQUANT,3] := "CN120VlQEx()"
				EndIf
			Next nX
		EndIf
		
		//-- Se tudo valido, chama gravacao
		If Len(aAutoItens) > 0 .And. MsGetDAuto(aAutoItens,{|| CN120LiOKE()},{|| CN120TdOKE()},aAutoCab,aRotina[nOpc][4])
		 	CN120VldPn(3,aHeader,aCols)
		EndIf
	EndIf
Else
	//-- Monta variaveis para montagem do browse de planilhas
	CN120Plans(@cArqCNA,@aTitle,@aCampos,@cLine)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel de apresentacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE WIZARD oWizard;
	TITLE STR0100; //-- Assitente - Excedente 
	HEADER STR0101; //-- Excedente para competência não prevista
	TEXT cTexto;
	PANEL NEXT {|| .T. };
	FINISH {|| .T. }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecao do contrato e competencia                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard;
	HEADER STR0101; //-- Excedente para competência não prevista
	MESSAGE STR0102; //-- Selecione o contrato, competência e planilha
	PANEL NEXT {|| CN120VldPn(1,@oGetDados:aHeader,@oGetDados:aCols)};
	FINISH {|| .T. }
	
	TSay():New(07,10,{|| STR0103},oWizard:oMPanel[2],,,,,,.T.,,,60,10) //-- Contrato
	@05,040 MSGET cContra PICTURE PesqPict("CN9","CN9_NUMERO") F3 cConsSxb SIZE 60,9 VALID CN120VlCon(1,.T.) OF oWizard:oMPanel[2] PIXEL
	
	TSay():New(07,130,{|| STR0104},oWizard:oMPanel[2],,,,,,.T.,,,100,10) //-- Competência
	oCbx := TComboBox():New(05,170,{|u| If(PCount()>0,cCompet:=u,cCompet)},,50,10,oWizard:oMPanel[2],,{|| CN120Compet(.T.)},,,,.T.,,,,,,,,,cCompet)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta browse de planilhas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrowse := TWBrowse():New(23,4,__DlgWidth(oWizard:oMPanel[2])-5,__DlgHeight(oWizard:oMPanel[2])-35,{|| {aCampos}},aTitle,{030,090},oWizard:oMPanel[2],,,,,,,,,,,,,"TRBCNA",.T.)
	oBrowse:bLine := &("{ || " +cLine +" }")
	If !Empty(CND->(FieldPos("CND_PARCEL")))
		oBrowse:bLDblClick := {|| If(!Empty(TRBCNA->CNA_NUMERO),((cPlan:= TRBCNA->CNA_NUMERO,cParcel:=TRBCNA->CNF_PARCEL),oBrowse:Refresh()),)}
	Else
		oBrowse:bLDblClick := {|| If(!Empty(TRBCNA->CNA_NUMERO),(cPlan := TRBCNA->CNA_NUMERO,oBrowse:Refresh()),)}
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecao do contrato e competencia                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard;
	HEADER STR0101; //-- Excedente para competência não prevista
	MESSAGE STR0105; //-- Preencha os itens com as quantidades excedentes
	PANEL NEXT {|| CN120VldPn(2,@oGetDados:aHeader,@oGetDados:aCols)};
	FINISH {|| .T. }
	
	oGetDados := MsNewGetDados():New(05,10,__DlgHeight(oWizard:oMPanel[3])-30,__DlgWidth(oWizard:oMPanel[3])-5,GD_UPDATE,"CN120LiOKE","CN120TdOKE",,aAlter,,,,,,oWizard:oMPanel[3],aHeader,aCols)
	TSay():New(__DlgHeight(oWizard:oMPanel[3])-23,10,{|| STR0106},oWizard:oMPanel[3],,,,,,.T.,,,60,10) //-- Total da medição
	@__DlgHeight(oWizard:oMPanel[3])-25,60 MSGET oGetTot VAR nTotMed PICTURE PesqPict("CND","CND_VLTOT") PIXEL WHEN .F. SIZE 50,5 OF oWizard:oMPanel[3]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finalizacao da inclusão.           			        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard;
	HEADER STR0101; //-- Excedente para competência não prevista
	MESSAGE STR0107; //-- Confirme a gravação da medição excedente
	FINISH {|| CN120VldPn(3,@oGetDados:aHeader,@oGetDados:aCols)}
	
	TCheckBox():New(30,10,STR0108,{|u| If(PCount()>0,lEncerra:=u,lEncerra)},oWizard:oMPanel[4],150,10,,,,,,,,.T.) //-- Processar encerramento da medição após gravação
	
	ACTIVATE WIZARD oWizard CENTERED
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apaga arquivo temporario                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBCNA->(dbCloseArea())
	FErase(cArqCNA + ".DBF")
	FErase(cArqCNA + OrdBagExt())
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120VldPnºAutor  ³ Andre Anjos		 º Data ³  24/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida preenchimento dos paineis da medicao excedente para º±±
±±º          ³ competencia nao prevista.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN120VldPn(nPainel,aHeader,aCols)
Local lRet     := .T.
Local cItem    := StrZero(1,TamSX3("CNE_ITEM")[1])
Local nSaveSX8 := GetSX8Len()

Do Case
	Case nPainel == 1
		//-- Verifica se escolheu a planilha
		If Empty(cPlan)
			Help(" ",1,"CNTA120_01")
			lRet := .F.
		EndIf	
		
		//-- Preenche aHeader e aCols para proxima tela
		If lRet
			aCols := {}
						
			CNB->(dbSetOrder(1))
			CNB->(dbSeek(xFilial("CNB",cFilCTR)+cContra+cRevisa+cPlan))
			While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == xFilial("CNB",cFilCTR)+cContra+cRevisa+cPlan
				aAdd(aCols,Array(Len(aHeader)+1))
				aTail(aCols)[GDFieldPos("CNE_ITEM",aHeader)] := cItem
				aTail(aCols)[GDFieldPos("CNE_PRODUT",aHeader)] := CNB->CNB_PRODUT
				aTail(aCols)[GDFieldPos("CNE_DESCRI",aHeader)] := Posicione("SB1",1,xFilial("SB1")+CNB->CNB_PRODUT,"B1_DESC")
				aTail(aCols)[GDFieldPos("UCNE_QUANT",aHeader)] := 0
				aTail(aCols)[GDFieldPos("CNE_VLUNIT",aHeader)] := 0
				aTail(aCols)[GDFieldPos("CNE_VLTOT",aHeader)] := 0
				aTail(aCols)[GDFieldPos("CNE_DTENT",aHeader)] := dDataBase
				aTail(aCols)[GDFieldPos("CNE_FLGCMS",aHeader)] := CriaVar("CNE_FLGCMS",.T.)
				aTail(aCols)[GDFieldPos("CNE_TS",aHeader)] := CNB->CNB_TS
				aTail(aCols)[GDFieldPos("CNE_TABPRC",aHeader)] := CNB->CNB_TABPRC
				aTail(aCols)[GDFieldPos("CNE_EXCEDE",aHeader)] := '1'
				If CNE->(FieldPos("CNE_PEDTIT")) > 0
					aTail(aCols)[GDFieldPos("CNE_PEDTIT",aHeader)] := CNB->CNB_PEDTIT
				EndIf
				aTail(aCols)[Len(aHeader)+1] := .F.
				cItem := Soma1(cItem)
				CNB->(dbSkip())
			End
			
			nTotMed := 0
		EndIf
	Case nPainel == 2
		If !lAuto
			lRet := oGetDados:LinhaOk() .And. oGetDados:TudoOk()
		EndIf
	Case nPainel == 3
		If lAuto .Or. (lRet := MsgYesNo(STR0109 +cCompet +STR0110)) //-- Confirma a geração de medição excedente para a competência ###, não prevista no cronograma deste contrato?
			CN9->(dbSetOrder(1))
			CN9->(dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa))
			
			//-- Prepara valores de memoria para gravacao
			If !lAuto
				RegToMemory("CND",.T.,.F.,.T.)
			EndIf
			M->CND_CONTRA := CN9->CN9_NUMERO
			M->CND_REVISA := CN9->CN9_REVISA
			M->CND_CLIENT := CN9->CN9_CLIENT
			M->CND_LOJACL := CN9->CN9_LOJACL
			M->CND_CONDPG := CN9->CN9_CONDPG
			M->CND_VLCONT := CN9->CN9_VLATU
			M->CND_VLADIT := CN9->CN9_VLADIT
			M->CND_VLREAJ := CN9->CN9_VLREAJ
			M->CND_NUMERO := cPlan
			M->CND_COMPET := cCompet
			M->CND_PARCEL := cParcel
			M->CND_VLTOT  := nTotMed
			M->CND_MOEDA  := 1
			M->CND_DTVENC := dDataBase
			M->CND_SERVIC := '1'
						
			cNumMed := M->CND_NUMMED
			
			//-- Ajusta nome do campo de quantidade			
			aHeader[GDFieldPos("UCNE_QUANT",aHeader),2] := "CNE_QUANT"
					
			//-- Grava medicao
			MsAguarde({|| CN130Grv(3,.F.,cCompet,nSaveSX8,{},{},{},aHeader,aCols,1)},STR0111) //-- Gravando medição
			
			If lEncerra
				Processa({|| CN120MedEnc(CND->(Recno()))})
			ElseIf !lAuto
				Aviso("CNTA120",STR0112 +cNumMed +".",{"OK"}) //-- Gerada medição número ###
			EndIf
		EndIf
EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120VlQExºAutor  ³ Andre Anjos		 º Data ³  24/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida a quantidade digitada como excedente em competencia º±±
±±º          ³ nao prevista e gatilha o preco conforme tabela.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120VlQEx()
Local lRet     := .T.
Local nPrcUnit := 0

lRet := Positivo()

//-- Gatilha preco unitario e valor total
If lRet
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9",cFilCTR)+cContra+cRevisa))

	//-- Obtem preco unitario pela tabela de preco
	nPrcUnit := MaTabPrVen(aCols[n,GDFieldPos("CNE_TABPRC")],aCols[n,GDFieldPos("CNE_PRODUT")],M->UCNE_QUANT,CN9->CN9_CLIENT,CN9->CN9_LOJACL,1,dDataBase)
	
	aCols[n,GDFieldPos("CNE_VLUNIT")] := nPrcUnit
	nTotMed += (M->UCNE_QUANT * nPrcUnit) - aCols[n,GDFieldPos("CNE_VLTOT")]
	aCols[n,GDFieldPos("CNE_VLTOT")] := M->UCNE_QUANT * aCols[n,GDFieldPos("CNE_VLUNIT")]
	
	If !lAuto
		oGetTot:Refresh()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120LiOKEºAutor  ³ Andre Anjos        º Data ³  29/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida linha da medicao excedente para competencia nao     º±±
±±º          ³ prevista.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120LiOKE()
Local lRet := .T.

//-- Verifica se ha item com quantidade sem preco
If aCols[n,GDFieldPos("UCNE_QUANT")] > 0 .And. aCols[n,GDFieldPos("CNE_VLUNIT")] == 0
	Help(1," ","OBRIGAT2",,RetTitle("CNE_VLUNIT"),3,0)
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN120TdOkEºAutor  ³ Andre Anjos		 º Data ³  29/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida GetDados da medicao excedente para competencia nao  º±±
±±º          ³ prevista.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN120TdOkE()
Local lRet := .T.

If Empty(nTotMed)
	Aviso(STR0114,STR0113,{"OK"}) //-- Não há quantidade para geração de medição.
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³cn120Upd36ºAutor  ³ Aline S Damasceno	 º Data ³  28/02/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se existe registro com CND_SERVIC vazio  		  º±±
±±º          ³ se verdadeiro aplicar o update GCTUPD36                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA120													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function cn120Upd36()  
Local cQuery    := ""
Local cAliasCND := ""

If CND->(FieldPos("CND_SERVIC")) > 0               
	cQuery := " SELECT  CND.R_E_C_N_O_ AS RECNO FROM " + RetSqlName("CND") + " CND "
	cQuery += "   WHERE CND.CND_SERVIC = ' ' "
	cQuery += "     AND CND.D_E_L_E_T_ = ' ' "

	cQuery    := ChangeQuery( cQuery )
	cAliasCND := GetNextAlias()			                                           
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasCND, .F., .T. )

				
	If !Empty((cAliasCND)->RECNO)
		Final(OemtoAnsi(STR0116))  //"Aplicar o update GCTUPD36 !!!"					   
	EndIf
EndIf    

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN120Contab³ Autor ³ Aline Sebrian         ³ Data ³24/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Contabiliza a Retencao do Contrato                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN120Contab()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN120Contab(cPadrao)

LOCAL aArea     := GetArea()

LOCAL cLoteCtb  := ""

LOCAL lDigita   := If(MV_PAR02==1,.T.,.F.)                           
LOCAL lPadrao   := .F.

LOCAL nHdlPrv   := 0
LOCAL nTotal    := 0

Private cArquivo := " "

dbSelectArea("CND")
dbSetOrder(1)

lPadrao := VerPadrao(cPadrao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento Contabil³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lPadrao .and. MV_PAR01 == 1 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero do lote contabil                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	dbSetOrder(1)
	If MsSeek(xFilial()+"09GCT")
		cLoteCtb := AllTrim(X5Descri())
	Else
		cLoteCtb := "GCT "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o execblock                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At(UPPER("EXEC"),X5Descri()) > 0
		cLoteCtb := &(X5Descri())
	EndIf
	
	nHdlPrv := HeadProva(cLoteCtb,"CNTA120",Substr(cUsuario,7,6),@cArquivo)
	nTotal  += DetProva(nHdlPrv,cPadrao,"CNTA120",cLoteCtb)
	RodaProva(nHdlPrv,nTotal)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para Lancamento Contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cA100Incl(cArquivo,nHdlPrv,3,cLoteCtb,lDigita,.F.)
EndIf

RestArea(aArea)
Return(.T.)

//-------------------------------------------------------------------
/*{Protheus.doc} CNTVldCTR
Realiza a validação de contratos com base na tabela CPD

@author leonardo.quintania
@since 09/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function CNTVldCTR(cContrato)
Local cCod		:= RetCodUsr()
Local aGrp 	:= UsrRetGrp(UsrRetName(cCod)) //Carrega Grupos do usuario
Local lVldVige:= GetNewPar("MV_CNFVIGE","N") == "N"
Local lRet		:= .F.
Local nX		:= 0
Local cGrps	:= ''
Local cQuery1	:= ''
Local cQuery2	:= ''
Local cQuery3	:= ''
Local cQuery4	:= ''
Local cQuery5	:= ''
Local cQuery	:= ''
Local aArea 	:= GetArea()

For nX:=1 to len(aGrp)
	cGrps += "'"+aGrp[nX]+"',"
Next

cGrps := SubStr(cGrps,1,len(cGrps)-1)

cQuery1 := " SELECT CN9_NUMERO, MAX(CN9_REVISA) AS CN9_REVISA "
cQuery1 += " FROM " + RetSqlName("CN9") + " CN9 , "+ RetSqlName("CNN") + " CNN, "+ RetSqlName("CPD") + " CPD " 
cQuery1 += " WHERE CN9_SITUAC   = '05' AND "
cQuery1 += " CPD.CPD_FILAUT = '"+cFilAnt+"' AND "
cQuery1 += " CPD.CPD_CONTRA = CN9.CN9_NUMERO AND "

If lVldVige
	cQuery1 += " ('"+DToS(dDataBase)+"' BETWEEN CN9_DTINIC AND CN9_DTFIM )  AND "
EndIf
cQuery1+= " CNN.CNN_FILIAL = CN9_FILIAL AND "
cQuery1+= " CNN.CNN_CONTRA = CN9_NUMERO AND "        

If CN9->(FieldPos("CN9_VLDCTR"))> 0
	cQuery2 := " CN9_VLDCTR ='2' "
	cQuery3 := " CN9_VLDCTR IN(' ','1') AND (CNN.CNN_USRCOD   = '"+ cCod +"'" 
	If len(aGrp) > 0
		cQuery3 += " OR CNN.CNN_GRPCOD IN ("+ cGrps +"))"
	Else
	    cQuery3 += ")"
	EndIf
Else
	cQuery3:= " (CNN.CNN_USRCOD   = '"+ cCod +"'"
	If len(aGrp) > 0
		cQuery3+= " OR CNN.CNN_GRPCOD IN ("+ cGrps +"))"
	Else
		cQuery3+=")"
	EndIf
EndIf

cQuery4 := " AND CNN.D_E_L_E_T_	= '' "
cQuery4 += " AND CN9.D_E_L_E_T_	= '' " 
cQuery4 += " AND CPD.D_E_L_E_T_	= '' "
cQuery4 += " GROUP BY CN9_NUMERO "
cQuery5 := " ORDER BY CN9_NUMERO,CN9_REVISA "

If CN9->(FieldPos("CN9_VLDCTR"))> 0
	cQuery := cQuery1
    cQuery += cQuery2+" "+cQuery4
    cQuery += " UNION "
    cQuery += cQuery1            
    cQuery += cQuery3+" "+cQuery4+" "+cQuery5
Else                 
	cQuery := cQuery1
    cQuery += cQuery3+" "+cQuery4+" "+cQuery5
EndIf

cQuery := ChangeQuery(cQuery)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCN9",.F.,.T.)

While !TRBCN9->(Eof())
	If AllTrim(TRBCN9->CN9_NUMERO)== AllTrim(cContrato)
		lRet:= .T.
		Exit
	EndIf
	TRBCN9->(dbSkip())
EndDo 

If !lRet
	Help(" ",1,"REGNOIS")
EndIf

TRBCN9->(dbCloseArea())

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CNTVldPlan
Valida condições necessarias para realizar medições em outra filial

@author leonardo.quintania
@since 09/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function CNTVldPlan(cContra,cRevisa,cPlan)
Local lRet		:= .T.
Local aArea := GetArea()

If Empty(cPlan)
	Help( " ", 1, 'CNTA120_01' )
	lRet:= .F.
Else
	If CNB->(dbSeek(xFilial('CNB',cFilCTR) +  cContra + cRevisa + cPlan  )) //Cadastro de produtos
		While !CNB->(Eof()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == xFilial('CNB',cFilCTR)+cContra+cRevisa+cPlan
			If !SB1->(dbSeek(xFilial('SB1') + CNB->CNB_PRODUT))
				Help( " ", 1, 'NOPRODFILIAL' )
				lRet:= .F.
				Exit
			EndIf
			
			If lRet .And. !Empty(CNB->CNB_TE)
				If !SF4->(dbSeek(xFilial('SF4') + CNB->CNB_TE))
					Help( " ", 1, 'NOTESFILIAL' )
					lRet:= .F.
					Exit
				EndIf
			EndIf
			
			If lRet .And. !Empty(CNB->CNB_TS)
				If !SF4->(dbSeek(xFilial('SF4') + CNB->CNB_TS))
					Help( " ", 1, 'NOTESFILIAL' )
					lRet:= .F.
					Exit
				EndIf
			EndIf

			CNB->(dbSkip())
		EndDo
	EndIf
	
	If lRet .And. !SE4->(dbSeek(xFilial('SE4')+CN9->CN9_CONDPG)) //Condição de Pagamento
		Help( " ", 1, 'NOCONDFILIAL' )
		lRet:= .F.
	EndIf
	
	
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CN120VerDoc
Verifica quais documentos devem ser gerados no Gestão de Contratos e Serviços
1 - Pedido
2 - Titulo
3 - Pedido/Titulo
@author leonardo.quintania
@since 22/11/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function CN120VerDoc(cMedicao)
Local nRet		:= 1
Local aArea	:= GetArea()

If CNE->(FieldPos("CNE_PEDTIT")) > 0
	BeginSql Alias "CNETMP"
	
	SELECT * FROM
		(SELECT COUNT(R_E_C_N_O_) PEDTIT1
		FROM %Table:CNE% CNE
		WHERE CNE.CNE_FILIAL = %xFilial:CNE%
			AND CNE.CNE_NUMMED = %Exp:cMedicao%
			AND CNE.CNE_PEDTIT = '1' 
			AND CNE.%NotDel% ) PEDTIT1,		
		(SELECT COUNT(R_E_C_N_O_) PEDTIT2
		FROM %Table:CNE% CNE
		WHERE CNE.CNE_FILIAL = %xFilial:CNE%
			AND CNE.CNE_NUMMED = %Exp:cMedicao%
			AND CNE.CNE_PEDTIT = '2' 
			AND CNE.%NotDel% ) PEDTIT2		
			
	EndSql
	
	If CNETMP->PEDTIT1 > 0 .And. CNETMP->PEDTIT2 > 0
		nRet := 3	//-- Medicao com pedido e titulo
	ElseIf CNETMP->PEDTIT1 > 0
		nRet:= 1	//-- Medicao com pedido, somente
	Else
		nRet:= 2	//-- Medicao com titulo, somente
	EndIf
	
	CNETMP->(dbCloseArea())
EndIf

RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} CN120TitSE1
Executa ExecAuto do FINA040 contas a receber
@author leonardo.quintania
@since 22/11/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function C120TitSE1(aRotAuto,cNumTit)
Local lRet		:= .T.
Local cParcela:= StrZero(1,Len(SE1->E1_PARCELA))
Local aCond	:= {{aRotAuto[ProcH(aRotAuto,"E1_VENCTO"),2],aRotAuto[ProcH(aRotAuto,"E1_VALOR"),2]}}
Local aArea	:= GetArea()
Local nX		:= 0

Private lMsErroAuto := .F.

Static lGeraCP	:= SuperGetMV("MV_CNPROCP",.F.,"N") == "S"
Static cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),Len(SE1->E1_PREFIXO))          
Static cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),Len(SE1->E1_TIPO))
Static cRetNat	:= PadR(SuperGetMv("MV_CNNATMD",.F.,""),Len(SE1->E1_NATUREZ))

BeginSql Alias "SE1TMP"
	SELECT MAX(SE1.E1_NUM) AS E1_NUM 
	FROM %Table:SE1% SE1
	WHERE SE1.E1_FILIAL  = %xFilial:SE1%
		AND SE1.E1_PREFIXO =%Exp:cRetPrf%
		AND SE1.%NotDel%
EndSql 

cNumTit := Soma1(SE1TMP->E1_NUM)
SE1TMP->(dbCloseArea())

//-- Verifica se o codigo está disponivel
SE1->(dbSetOrder(1))
While SE1->(dbSeek(xFilial("SE1")+cRetPrf+cNumTit))
	cNumTit += Soma1(cNumTit)
End

If lGeraCP
	aCond := Condicao(aCond[1,2],CN9->CN9_CONDPG,,aCond[1,1])
EndIf

For nX := 1 To Len(aCond)

	//-- Preenchimento de array para execauto FINA040
	aAdd(aRotAuto,{"E1_NUM",cNumTit,NIL})
	aAdd(aRotAuto,{"E1_PREFIXO",cRetPrf,NIL})
	aAdd(aRotAuto,{"E1_NATUREZ",cRetNat,NIL})
	aAdd(aRotAuto,{"E1_PARCELA",cParcela,NIL})
	aAdd(aRotAuto,{"E1_TIPO",cTpTit,NIL})
	
	aRotAuto[ProcH(aRotAuto,"E1_VENCTO"),2] := aCond[nX,1]
	aRotAuto[ProcH(aRotAuto,"E1_VALOR"),2] := aCond[nX,2]
	
	MSExecAuto({|x,y| FINA040(x,y)},aRotAuto,3)
	
	If lMsErroAuto 
		MostraErro()
		Exit
	EndIf
	
	cParcela := Soma1(cParcela)	
Next nX

RestArea(aArea)
Return !lMsErroAuto

//-------------------------------------------------------------------
/*{Protheus.doc} C120TitSE2
Executa ExecAuto do FINA050 Contas a Pagar
@author leonardo.quintania
@since 22/11/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function C120TitSE2(aRotAuto,cNumTit)
Local lRet		:= .T.
Local cParcela:= StrZero(1,Len(SE2->E2_PARCELA))
Local aCond	:= {{aRotAuto[ProcH(aRotAuto,"E2_VENCTO"),2],aRotAuto[ProcH(aRotAuto,"E2_VALOR"),2]}}
Local aArea	:= GetArea()
Local nX		:= 0

Private lMsErroAuto := .F.

Static lGeraCP	:= SuperGetMV("MV_CNPROCP",.F.,"N") == "S"
Static cRetPrf	:= PadR(SuperGetMV("MV_CNPREMD",.F.,"MED"),Len(SE2->E2_PREFIXO))          
Static cTpTit	:= PadR(SuperGetMV("MV_CNTPTMD",.F.,"BOL"),Len(SE2->E2_TIPO))
Static cRetNat	:= PadR(SuperGetMv("MV_CNNATMD",.F.,""),Len(SE2->E2_NATUREZ))

BeginSql Alias "SE2TMP"
	SELECT MAX(SE2.E2_NUM) AS E2_NUM 
	FROM %Table:SE2% SE2
	WHERE SE2.E2_FILIAL  = %xFilial:SE2%
		AND SE2.E2_PREFIXO =%Exp:cRetPrf%
		AND SE2.%NotDel%
EndSql 

cNumTit := Soma1(SE2TMP->E2_NUM)
SE2TMP->(dbCloseArea())

//-- Verifica se o codigo está disponivel
SE2->(dbSetOrder(1))
While SE2->(dbSeek(xFilial("SE2")+cRetPrf+cNumTit))
	cNumTit += Soma1(cNumTit)
End

If lGeraCP
	aCond := Condicao(aCond[1,2],CN9->CN9_CONDPG,,aCond[1,1])
EndIf

For nX := 1 To Len(aCond)
	//-- Preenchimento de array para execauto FINA040
	aAdd(aRotAuto,{"E2_NUM",cNumTit,NIL})
	aAdd(aRotAuto,{"E2_PREFIXO",cRetPrf,NIL})
	aAdd(aRotAuto,{"E2_NATUREZ",cRetNat,NIL})
	aAdd(aRotAuto,{"E2_PARCELA",cParcela,NIL})
	aAdd(aRotAuto,{"E2_TIPO",cTpTit,NIL})
	
	aRotAuto[ProcH(aRotAuto,"E2_VENCTO"),2] := aCond[nX,1]
	aRotAuto[ProcH(aRotAuto,"E2_VALOR"),2] := aCond[nX,2]
	
	MSExecAuto({|x,y| FINA050(x, y)},aRotAuto,3)
	
	If lMsErroAuto 
		MostraErro()
		Exit
	EndIf
	
	cParcela := Soma1(cParcela)
Next nX

RestArea(aArea)
Return !lMsErroAuto

//-------------------------------------------------------------------
/*{Protheus.doc} CN120EstSld
Estorna Saldo do titulo na planilha
1 - Pedido
2 - Titulo
3 - Pedido/Titulo
@author leonardo.quintania
@since 22/11/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function CN120EstSld(cMedicao)
Local aArea := GetArea()

BeginSql Alias "CNETMP"
	SELECT CNE_CONTRA,CNE_NUMERO,CNE_ITEM,CNE_QUANT,CNE_NUMMED,CNE_VLTOT,CNE_PEDTIT
	FROM	%Table:CNE% CNE
	WHERE CNE.CNE_FILIAL = %xFilial:CNE%
		AND CNE.CNE_NUMMED = %Exp:cMedicao%
		AND CNE.CNE_PEDTIT = '2'
		AND CNE.%NotDel%
EndSql

While !CNETMP->(EOF())
	CtaAvalGCT(2,{},CNETMP->CNE_CONTRA,CNETMP->CNE_NUMERO,CNETMP->CNE_ITEM,CNETMP->CNE_QUANT,,CNETMP->CNE_NUMMED,CNETMP->CNE_VLTOT)	
	CNETMP->(dbSkip())
End
CNETMP->(dbCloseArea())

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} ProcH
Pesquisa em array de execauto
*/
//-------------------------------------------------------------------
Static Function ProcH(aArray,cValor)
Return aScan(aArray,{|x| Trim(x[1]) == cValor })
