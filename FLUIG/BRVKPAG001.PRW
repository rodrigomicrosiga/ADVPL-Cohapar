#INCLUDE "PROTHEUS.CH"   
#INCLUDE "RWMAKE.CH"

User Function BRVKPAG001(cCodLote)
Local cDesc1  := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2  := "de acordo com os parametros informados pelo usuario."
Local cDesc3  := "Relatório de Lotes de Aprovação"

Private lAbortPrint := .F.
Private nLin     := 80
Private limite   := 132
Private tamanho  := "M"
Private nomeprog := "BRVKPAG001" 
Private aOrd     := {"Analítico","Sintético"}
Private titulo   := "Relatório de Lotes de Aprovação"
Private nTipo    := 15
Private aReturn  := {"Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey := 0
Private cPerg   := "BRVKPAG001"
Private cString := "ZBR"
Private m_pag   := 01
Private wnrel   := "BRVKPAG001" // Coloque aqui o nome do arquivo usado para impressao em disco

If cCodLote != Nil
	RptStatus({|| RunReport(cCodLote) },Titulo)
	Return
EndIF

CriaSX1()
Pergunte(cPerg,.F.)    

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport() },Titulo)
Return



Static Function RunReport(cCodLote)
Local Cabec1 := "   Fil  Prefixo  Número  Parcela  Tipo  Natureza  C.Custo  Fornecedor                               Vencto.    Vl.Orig.  Situação"   
Local Cabec2 := "              Histórico: Data      Hora   Usuário          Situação   Observação"
Local nOrdem := aReturn[8]

If cCodLote != Nil
	
EndIf

DBSelectArea("ZBR")
DBSetOrder(1)
DBSeek(xFilial("ZBR"))
SetRegua(ZBR->(RecCount()))
//While ZBR->(!EOF()) .AND. ZBR->ZBR_FILIAL==xFilial("ZBR") .AND. ZBR->ZBR_CCUSTO>=MV_PAR03 .AND. ZBR->ZBR_CCUSTO<=MV_PAR04 .AND.;
//	DTOS(ZBR->ZBR_DATA)>=DTOS(MV_PAR01) .AND. DTOS(ZBR->ZBR_DATA)<=DTOS(MV_PAR02)
While ZBR->(!EOF()) .AND. ZBR->ZBR_FILIAL==xFilial("ZBR")
	
	If cCodLote != Nil
		If ZBR->ZBR_CODIGO != cCodLote
			DBSkip()
			Loop
		EndIf
	Else
		If !(ZBR->ZBR_CCUSTO>=MV_PAR03 .AND. ZBR->ZBR_CCUSTO<=MV_PAR04 .AND. DTOS(ZBR->ZBR_DATA)>=DTOS(MV_PAR01) .AND. DTOS(ZBR->ZBR_DATA)<=DTOS(MV_PAR02))
			DBSkip()
			Loop
		EndIf
		If (MV_PAR05==1 .AND. ZBR->ZBR_SITUAC<>'A') .OR. (MV_PAR05==2 .AND. ZBR->ZBR_SITUAC<>'E')
		    DBSkip()
			Loop
		Endif		
	EndIf

    If lAbortPrint
        @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
        Exit
    Endif

    If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
        Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
        nLin := 9
    Endif

    @nLin,000 PSAY "Lote: "+ZBR->ZBR_CODIGO+"   C.Custo: "+ZBR->ZBR_CCUSTO+"   Data Geração: "+DtoC(ZBR->ZBR_DATA)+"-"+ZBR->ZBR_HORA+;
    				"   Usuário: "+ZBR->ZBR_USUAR+"   Situação: "+Iif(ZBR->ZBR_SITUAC=="A","Aberto","Encerrado")+"   Proc.ECM: "+ZBR->ZBR_ECMPRO

    nLin := nLin + 1 
	DBSelectArea("ZBS")
    DBSetOrder(1)
	DBSeek(xFilial("ZBS")+ZBR->ZBR_CODIGO+ZBR->ZBR_CCUSTO)
	While ZBS->(!EOF()) .AND. ZBS->ZBS_LOTE==ZBR->ZBR_CODIGO .AND. ZBS->ZBS_CCUSTO==ZBR->ZBR_CCUSTO .AND. ZBS->ZBS_FILIAL==xFilial("ZBS")
	
	    If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
	        Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    	    nLin := 9
		    @nLin,000 PSAY "Lote: "+ZBR->ZBR_CODIGO+"   C.Custo: "+ZBR->ZBR_CCUSTO+"   Data Geração: "+DtoC(ZBR->ZBR_DATA)+"-"+ZBR->ZBR_HORA+;
	    					"   Usuário: "+ZBR->ZBR_USUAR+"   Situação: "+Iif(ZBR->ZBR_SITUAC=="A","Aberto","Encerrado")+"   Proc.ECM: "+ZBR->ZBR_ECMPRO
		    nLin := nLin + 1 
	    Endif

	    @nLin,003 PSAY ZBS->ZBS_FILTIT
	    @nLin,008 PSAY ZBS->ZBS_PREFIX
	    @nLin,017 PSAY ZBS->ZBS_NUM
	    @nLin,025 PSAY ZBS->ZBS_PARCEL
	    @nLin,034 PSAY ZBS->ZBS_TIPO
	    @nLin,040 PSAY ZBS->ZBS_NATURE
	    @nLin,050 PSAY ZBS_FORNEC+"-"+POSICIONE("SA2",1,xFilial("SA2")+ZBS->ZBS_FORNEC,"A2_NOME")
	    @nLin,100 PSAY ZBS->ZBS_VENCTO
	    @nLin,109 PSAY Transform(ZBS->ZBS_VALOR,"@E 999,999.99")
	    @nLin,121 PSAY IIf(ZBS->ZBS_SITUAC=="P","Pendente",IIf(ZBS->ZBS_SITUAC=="A","Aprovado",IIf(ZBS->ZBS_SITUAC=="R","Reprovado","Cancelado" )))    
    	nLin := nLin + 1 
			    	
		If nOrdem==1	
			DBSelectArea("ZBT")
		    DBSetOrder(1)
			If DBSeek(xFilial("ZBT")+ZBR->ZBR_CODIGO+ZBR->ZBR_CCUSTO+ZBS->ZBS_FILTIT+PADR(ZBS->ZBS_PREFIX,3)+ZBS->ZBS_NUM+ZBS->ZBS_PARCEL+PADR(ZBS->ZBS_TIPO,3)+ZBS->ZBS_FORNEC)
				While ZBT->(!EOF()) .AND. ZBT->ZBT_LOTE==ZBR->ZBR_CODIGO .AND. ZBT->ZBT_CCUSTO==ZBR->ZBR_CCUSTO .AND. ZBT->ZBT_FILIAL==xFilial("ZBT") .AND.;
					ZBT->ZBT_FILTIT==ZBS->ZBS_FILTIT .AND. AllTrim(ZBT->ZBT_PREFIX)==AllTrim(ZBS->ZBS_PREFIX) .AND. ZBT->ZBT_NUM==ZBS->ZBS_NUM .AND.;
					ZBT->ZBT_PARCEL==ZBS->ZBS_PARCEL .AND. AllTrim(ZBT->ZBT_TIPO)==AllTrim(ZBS->ZBS_TIPO) .AND. ZBT->ZBT_FORNEC==ZBS->ZBS_FORNEC
					
				    If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
				        Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			    	    nLin := 9
					    @nLin,000 PSAY "Lote: "+ZBR->ZBR_CODIGO+"   C.Custo: "+ZBR->ZBR_CCUSTO+"   Data Geração: "+DtoC(ZBR->ZBR_DATA)+"-"+ZBR->ZBR_HORA+;
				    					"   Usuário: "+ZBR->ZBR_USUAR+"   Situação: "+Iif(ZBR->ZBR_SITUAC=="A","Aberto","Encerrado")+"   Proc.ECM: "+ZBR->ZBR_ECMPRO
					    nLin := nLin + 1 
				    Endif
			
				    @nLin,025 PSAY ZBT->ZBT_DATA  
				    @nLin,035 PSAY ZBT->ZBT_HORA
				    @nLin,043 PSAY ZBT->ZBT_USUAR 
				    @nLin,059 PSAY IIf(ZBT->ZBT_SITUAC=="P","Pendente",IIf(ZBT->ZBT_SITUAC=="A","Aprovado",IIf(ZBT->ZBT_SITUAC=="R","Reprovado","Cancelado" )))    
				    @nLin,070 PSAY ZBT->ZBT_OBSERV 
	    			nLin := nLin + 1 
				    DBSkip()
		    	Enddo
	    		nLin := nLin + 1 
			Endif   
			DBCloseArea("ZBT")
		Endif
						
		DBSelectArea("ZBS")
	    DBSkip()
    Enddo
    
    nLin := nLin + 1 
	DBSelectArea("ZBR")
    DBSkip()
EndDo

SET DEVICE TO SCREEN
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

DBCloseArea("ZBS")
DBCloseArea("ZBR")
MS_FLUSH()
Return


Static Function CriaSX1()

DBSelectArea("SX1")
DBSetOrder(1)
If !DBSeek(cPerg+"01")
    Reclock("SX1",.T.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "01"
	SX1->X1_PERGUNT := "Data De"
	SX1->X1_VARIAVL := "MV_CH1"
	SX1->X1_TIPO    := "D"
	SX1->X1_TAMANHO := 8
	SX1->X1_PRESEL  := 0
	SX1->X1_GSC     := "G"
	SX1->X1_VAR01   := "MV_PAR01"
	SX1->X1_CNT01   := "01/01/2011"
    MsUnLock()
Endif

DBSelectArea("SX1")
DBSetOrder(1)
If !DBSeek(cPerg+"02")
    Reclock("SX1",.T.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "02"
	SX1->X1_PERGUNT := "Data Ate"
	SX1->X1_VARIAVL := "MV_CH2"
	SX1->X1_TIPO    := "D"
	SX1->X1_TAMANHO := 8
	SX1->X1_PRESEL  := 0
	SX1->X1_GSC     := "G"
	SX1->X1_VAR01   := "MV_PAR02"
	SX1->X1_CNT01   := "31/12/2011"
    MsUnLock()
Endif

DBSelectArea("SX1")
DBSetOrder(1)
If !DBSeek(cPerg+"03")
    Reclock("SX1",.T.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "03"
	SX1->X1_PERGUNT := "Centro Custo De"
	SX1->X1_VARIAVL := "MV_CH3"
	SX1->X1_TIPO    := "C"
	SX1->X1_TAMANHO := 9
	SX1->X1_PRESEL  := 0
	SX1->X1_GSC     := "G"
	SX1->X1_VAR01   := "MV_PAR03"
	SX1->X1_CNT01   := "         "
	SX1->X1_F3      := "CTT"
    MsUnLock()
Endif

DBSelectArea("SX1")
DBSetOrder(1)
If !DBSeek(cPerg+"04")
    Reclock("SX1",.T.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "04"
	SX1->X1_PERGUNT := "Centro Custo Ate"
	SX1->X1_VARIAVL := "MV_CH4"
	SX1->X1_TIPO    := "C"
	SX1->X1_TAMANHO := 9
	SX1->X1_PRESEL  := 0
	SX1->X1_GSC     := "G"
	SX1->X1_VALID   := "naovazio"
	SX1->X1_VAR01   := "MV_PAR04"
	SX1->X1_CNT01   := "ZZZZZZZZZ"
	SX1->X1_F3      := "CTT"
    MsUnLock()                                                    
Endif

DBSelectArea("SX1")
DBSetOrder(1)
If !DBSeek(cPerg+"05")
    Reclock("SX1",.T.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "05"
	SX1->X1_PERGUNT := "Situação Lote"
	SX1->X1_VARIAVL := "MV_CH5"
	SX1->X1_TIPO    := "N"
	SX1->X1_TAMANHO := 1
	SX1->X1_PRESEL  := 3
	SX1->X1_GSC     := "C"
	SX1->X1_VAR01   := "MV_PAR05"
	SX1->X1_DEF01   := "Abertos"
	SX1->X1_DEF02   := "Encerrados"
	SX1->X1_DEF03   := "Todos"
    MsUnLock()                                                    
Endif

Return