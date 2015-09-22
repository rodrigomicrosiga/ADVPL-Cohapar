#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'  
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH' 
#INCLUDE 'RWMAKE.CH'


//| Estrutura do WSDL |
WSSTRUCT tCabecLotes
	WSDATA LOTE    AS STRING 
	WSDATA CCUSTO  AS STRING 
	WSDATA DATAGER AS DATE   
	WSDATA HORA    AS STRING 
ENDWSSTRUCT

WSSTRUCT tItensLote
	WSDATA FILIAL  AS STRING 
	WSDATA PREFIXO AS STRING 
	WSDATA NUMERO  AS STRING 
	WSDATA PARCELA AS STRING 
	WSDATA TIPO    AS STRING 
	WSDATA NATUREZ AS STRING 
	WSDATA FORNECE AS STRING 
	WSDATA EMISSAO AS DATE
	WSDATA VENCTO  AS DATE
	WSDATA VALOR   AS FLOAT
	WSDATA RATEIO  AS FLOAT
	WSDATA VALORRT AS FLOAT
	WSDATA SITUAC  AS STRING 
	WSDATA OBSERV  AS STRING 
ENDWSSTRUCT

WSSTRUCT tCabecNota
	WSDATA NUMERO   AS STRING 
	WSDATA SERIE    AS STRING
	WSDATA ESPECIE  AS STRING 
	WSDATA UF       AS STRING 
	WSDATA EMISSAO  AS DATE 
	WSDATA FORNECE  AS STRING 
	WSDATA NOMEFOR  AS STRING 
	WSDATA CONDPAG  AS STRING 
	WSDATA VALORTOT AS FLOAT
ENDWSSTRUCT

WSSTRUCT tItensNota
	WSDATA ITEM     AS STRING 
	WSDATA PRODUTO  AS STRING 
	WSDATA DESCPROD AS STRING 
	WSDATA UNIDADE  AS STRING 
	WSDATA QUANTDE  AS FLOAT
	WSDATA VALUNIT  AS FLOAT
	WSDATA VALTOTAL AS FLOAT
	WSDATA VALICMS  AS FLOAT
	WSDATA VALIPI   AS FLOAT
ENDWSSTRUCT

WSSTRUCT tPedCompra
	WSDATA NUMERO   AS STRING 
	WSDATA EMISSAO  AS DATE
	WSDATA ITEM     AS STRING 
	WSDATA PRODUTO  AS STRING 
	WSDATA DESCRI   AS STRING 
	WSDATA UNIDADE  AS STRING 
	WSDATA QUANTDE  AS FLOAT
	WSDATA VALUNIT  AS FLOAT
	WSDATA VALTOTAL AS FLOAT
	WSDATA CCUSTO   AS STRING 
	WSDATA OBSERV   AS STRING 
ENDWSSTRUCT

WSSTRUCT tHistAprov
	WSDATA CCUSTO   AS STRING 
	WSDATA RESPONS  AS STRING 
	WSDATA RATEIO   AS FLOAT
	WSDATA VALOR    AS FLOAT
	WSDATA DATAAPR  AS STRING 
	WSDATA SITUAC   AS STRING 
	WSDATA OBSERV   AS STRING 
ENDWSSTRUCT



//Definição dos parâmetros e métodos do Web Service     	       
WSSERVICE BRVKitPagamentos DESCRIPTION "Serviços relacionados ao Brava Kit Pagamentos" NAMESPACE "http://kitpagamentos.bravaecm.com.br"
    WSDATA tGetLotes     AS ARRAY OF tCabecLotes
    WSDATA tGetItensLote AS ARRAY OF tItensLote
    WSDATA tGetCabecNota AS ARRAY OF tCabecNota
    WSDATA tGetItensNota AS ARRAY OF tItensNota
    WSDATA tGetPedidos   AS ARRAY OF tPedCompra
    WSDATA tGetHistApr   AS ARRAY OF tHistAprov
    WSDATA cUser     AS STRING
    WSDATA cLote     AS STRING
    WSDATA cCCusto   AS STRING
    WSDATA cFilTit   AS STRING
    WSDATA cFilNota  AS STRING
    WSDATA cNota     AS STRING
    WSDATA cSerie    AS STRING
    WSDATA cFornec   AS STRING
    WSDATA cPrefixo  AS STRING
    WSDATA cTitulo   AS STRING
    WSDATA cParcela  AS STRING
    WSDATA cTipo     AS STRING
    WSDATA cReturn   AS STRING
    WSDATA cItemLote AS STRING
    WSDATA cMovimenta AS STRING
    
    WSMETHOD GetLotes      DESCRIPTION "Método de consulta aos lotes de títulos gerados"
    WSMETHOD GetItensLote  DESCRIPTION "Método de consulta aos itens dos lotes de títulos gerados"
    WSMETHOD GetCabecNota  DESCRIPTION "Método de consulta às notas fiscais de origem dos títulos"
    WSMETHOD GetItensNota  DESCRIPTION "Método de consulta aos itens das notas fiscais de origem dos títulos"
    WSMETHOD GetPedidos    DESCRIPTION "Método de consulta aos pedidos de compra referentes à nota fiscal de origem dos títulos"
    WSMETHOD GetPathNota   DESCRIPTION "Método de consulta ao caminho onde estão as imagens das notas fiscais de origem"
    WSMETHOD GetHistApr    DESCRIPTION "Método de consulta aos históricos de aprovação realizados para o título"
    WSMETHOD GravarLote    DESCRIPTION "Método de gravação da aprovação dos lotes"
    WSMETHOD FecharLote    DESCRIPTION "Método de fechamento do lote de aprovação"
ENDWSSERVICE	     


WSMETHOD GetLotes WSRECEIVE cUser WSSEND tGetLotes WSSERVICE BRVKitPagamentos
Local oTemp
Local cQuery

	::tGetLotes := {}
	RpcSetType(3)
		
	#IFDEF TOP
		cQuery := " SELECT * FROM "+RetSQLName("ZBR")+" WHERE D_E_L_E_T_<>'*' AND ZBR_CODUSR='"+cUser+"' AND ZBR_SITUAC='A' ORDER BY ZBR_CODIGO"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBXY",.T.,.T.)
		dbSelectArea("TRBXY")
		dbGoTop()
		While TRBXY->(!Eof())

			oTemp         := WsClassNew("tCabecLotes")
   			oTemp:LOTE    := TRBXY->ZBR_CODIGO
   			oTemp:CCUSTO  := TRBXY->ZBR_CCUSTO
			oTemp:DATAGER := StoD(TRBXY->ZBR_DATA)
			oTemp:HORA    := TRBXY->ZBR_HORA
   			aAdd(::tGetLotes, oTemp)

			DBSkip()
		Enddo
		dbCloseArea("TRBXY")
	#ELSE
		DBSelectArea("ZBR")
		DBSetOrder(2)
		DBSeek(xFilial("ZBR")+cUser)
		While ZBR->(!Eof()) .AND. ZBR->ZBR_CODUSR==cUser .AND. ZBR->ZBR_FILIAL==xFilial("ZBR")

			oTemp         := WsClassNew("tCabecLotes")
   			oTemp:LOTE    := ZBR->ZBR_CODIGO
   			oTemp:CCUSTO  := ZBR->ZBR_CCUSTO
			oTemp:DATAGER := ZBR->ZBR_DATA
			oTemp:HORA    := ZBR->ZBR_HORA
   			aAdd(::tGetLotes, oTemp)

			DBSkip()
		Enddo
		dbCloseArea("ZBR")
	#ENDIF

Return .T.  



WSMETHOD GetItensLote WSRECEIVE cLote,cCCusto WSSEND tGetItensLote WSSERVICE BRVKitPagamentos
Local oTemp
Local cQuery

	::tGetItensLote := {}
	RpcSetType(3)
		
	#IFDEF TOP
		cQuery := " SELECT * FROM "+RetSQLName("ZBS")+" WHERE D_E_L_E_T_<>'*' AND ZBS_LOTE='"+cLote+"' AND ZBS_CCUSTO='"+cCCusto+"' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBXY",.T.,.T.)
		dbSelectArea("TRBXY")
		dbGoTop()
		While TRBXY->(!Eof())

			oTemp         := WsClassNew("tItensLote")
   			oTemp:FILIAL  := TRBXY->ZBS_FILTIT
   			oTemp:PREFIXO := TRBXY->ZBS_PREFIX
   			oTemp:NUMERO  := TRBXY->ZBS_NUM
   			oTemp:PARCELA := TRBXY->ZBS_PARCEL
   			oTemp:TIPO    := TRBXY->ZBS_TIPO
   			oTemp:NATUREZ := TRBXY->ZBS_NATURE
   			oTemp:FORNECE := TRBXY->ZBS_FORNEC
   			oTemp:EMISSAO := StoD(TRBXY->ZBS_DTEMIS)
   			oTemp:VENCTO  := StoD(TRBXY->ZBS_VENCTO)
   			oTemp:VALOR   := TRBXY->ZBS_VALOR
   			oTemp:RATEIO  := TRBXY->ZBS_RATEIO
   			oTemp:VALORRT := TRBXY->ZBS_VALRAT
   			oTemp:SITUAC  := TRBXY->ZBS_SITUAC
   			oTemp:OBSERV  := AllTrim(TRBXY->ZBS_OBSERV)
   			aAdd(::tGetItensLote, oTemp)
			
			DBSkip()
		Enddo
		dbCloseArea("TRBXY")
	#ELSE

		DBSelectArea("ZBS")
		DBSetOrder(1)
		DBSeek(xFilial("ZBS")+cLote+cCCusto)
		While ZBS->(!Eof()) .AND. ZBS->ZBS_FILIAL==xFilial("ZBS") .AND. ZBS->ZBS_LOTE==cLote .AND. AllTrim(ZBS->ZBS_CCUSTO)==AllTrim(cCCusto) 

			oTemp         := WsClassNew("tItensLote")
   			oTemp:FILIAL  := ZBS->ZBS_FILTIT
   			oTemp:PREFIXO := ZBS->ZBS_PREFIX
   			oTemp:NUMERO  := ZBS->ZBS_NUM
   			oTemp:PARCELA := ZBS->ZBS_PARCEL
   			oTemp:TIPO    := ZBS->ZBS_TIPO
   			oTemp:NATUREZ := ZBS->ZBS_NATURE
   			oTemp:FORNECE := ZBS->ZBS_FORNEC
   			oTemp:EMISSAO := ZBS->ZBS_DTEMIS
   			oTemp:VENCTO  := ZBS->ZBS_VENCTO
   			oTemp:VALOR   := ZBS->ZBS_VALOR
   			oTemp:RATEIO  := ZBS->ZBS_RATEIO
   			oTemp:VALORRT := ZBS->ZBS_VALRAT
   			oTemp:SITUAC  := ZBS->ZBS_SITUAC
   			oTemp:OBSERV  := AllTrim(ZBS->ZBS_OBSERV)
   			aAdd(::tGetItensLote, oTemp)
			
			DBSkip()
		Enddo
		dbCloseArea("ZBS")

	#ENDIF

Return .T.  



WSMETHOD GetCabecNota WSRECEIVE cFilNota,cPrefixo,cTitulo,cFornec WSSEND tGetCabecNota WSSERVICE BRVKitPagamentos
Local oTemp
Local cQuery
Local nTotalNF := 0
Local cDescEsp := ''

	::tGetCabecNota := {}
	RpcSetType(3)
		
	#IFDEF TOP
		cQuery := " SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_EST,F1_EMISSAO,F1_ESPECIE,F1_VALBRUT,F1_COND FROM "+RetSQLName("SF1")+" "
		cQuery += " WHERE D_E_L_E_T_<>'*' AND F1_FILIAL='"+cFilNota+"' AND F1_SERIE='"+cPrefixo+"' AND F1_DOC='"+cTitulo+"' AND F1_FORNECE='"+cFornec+"' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBXY",.T.,.T.)
		dbSelectArea("TRBXY")
		dbGoTop()
		While TRBXY->(!Eof())
		
			nTotalNF := 0
		
			cQuery2 := " SELECT SUM(D1_TOTAL) AS D1_TOTAL FROM "+RetSQLName("SD1")+" "
			cQuery2 += " WHERE D_E_L_E_T_<>'*' AND D1_FILIAL='"+cFilNota+"' AND D1_DOC='"+cTitulo+"' "
			cQuery2 += " AND D1_SERIE='"+cPrefixo+"' AND D1_FORNECE='"+TRBXY->F1_FORNECE+"' "
			cQuery2 := ChangeQuery(cQuery2)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"TRBXYZ",.T.,.T.)
			dbSelectArea("TRBXYZ")

				nTotalNF := TRBXYZ->D1_TOTAL
			
			dbCloseArea("TRBXYZ")

			oTemp          := WsClassNew("tCabecNota")
   			oTemp:NUMERO   := TRBXY->F1_DOC
   			oTemp:SERIE    := TRBXY->F1_SERIE
   			oTemp:ESPECIE  := AllTrim(TRBXY->F1_ESPECIE)+"-"+AllTrim(POSICIONE("SX5",1,xFilial("SX5")+'42'+TRBXY->F1_ESPECIE,"X5_DESCRI"))
   			oTemp:UF       := TRBXY->F1_EST
   			oTemp:EMISSAO  := StoD(TRBXY->F1_EMISSAO)
   			oTemp:FORNECE  := TRBXY->F1_FORNECE
   			oTemp:NOMEFOR  := AllTrim(POSICIONE("SA2",1,xFilial("SA2")+TRBXY->F1_FORNECE,"A2_NOME"))
   			oTemp:CONDPAG  := TRBXY->F1_COND+"-"+AllTrim(POSICIONE("SE4",1,xFilial("SE4")+TRBXY->F1_COND,"E4_DESCRI"))
   			//oTemp:VALORTOT := TRBXY->F1_VALBRUT
   			oTemp:VALORTOT := nTotalNF
   			aAdd(::tGetCabecNota, oTemp)
			
			TRBXY->(DBSkip())
		Enddo
		TRBXY->(dbCloseArea())
	#ELSE
		DBSelectArea("SF1")
		DBSetOrder(1)
		DBSeek(cFilNota+cTitulo)
		While SF1->(!Eof()) .AND. SF1->F1_DOC==cTitulo .AND. SF1->F1_FILIAL==cFilNota
                 
			If AllTrim(SF1->F1_PREFIXO)==AllTrim(cPrefixo)
				oTemp          := WsClassNew("tCabecNota")
	   			oTemp:NUMERO   := SF1->F1_DOC
	   			oTemp:SERIE    := SF1->F1_SERIE
	   			oTemp:ESPECIE  := SF1->F1_ESPECIE
	   			oTemp:UF       := SF1->F1_EST
	   			oTemp:EMISSAO  := SF1->F1_EMISSAO
	   			oTemp:FORNECE  := SF1->F1_FORNECE
	   			oTemp:NOMEFOR  := AllTrim(POSICIONE("SA2",1,xFilial("SA2")+SF1->F1_FORNECE,"A2_NOME"))
	   			oTemp:CONDPAG  := SF1->F1_COND+"-"+AllTrim(POSICIONE("SE4",1,xFilial("SE4")+SF1->F1_COND,"E4_DESCRI"))
	   			oTemp:VALORTOT := SF1->F1_VALBRUT
	   			aAdd(::tGetCabecNota, oTemp)
			Endif
			DBSkip()
		Enddo
		dbCloseArea("SF1")

	#ENDIF

Return .T.  


WSMETHOD GetItensNota WSRECEIVE cFilNota,cNota,cSerie,cFornec WSSEND tGetItensNota WSSERVICE BRVKitPagamentos
Local oTemp
Local cQuery

	::tGetItensNota := {}
	RpcSetType(3)
		
	#IFDEF TOP
		cQuery := " SELECT D1_ITEM,D1_COD,D1_IPI,D1_UM,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALIPI,D1_VALICM FROM "+RetSQLName("SD1")+" "
		cQuery += " WHERE D_E_L_E_T_<>'*' AND D1_FILIAL='"+cFilNota+"' AND D1_DOC='"+cNota+"' "
		cQuery += " AND D1_SERIE='"+cSerie+"' AND D1_FORNECE='"+cFornec+"' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBXY",.T.,.T.)
		dbSelectArea("TRBXY")
		dbGoTop()
		While TRBXY->(!Eof())

			oTemp          := WsClassNew("tItensNota")
   			oTemp:ITEM     := TRBXY->D1_ITEM
   			oTemp:PRODUTO  := TRBXY->D1_COD
   			oTemp:DESCPROD := AllTrim(POSICIONE("SB1",1,xFilial("SB1")+TRBXY->D1_COD,"B1_DESC"))
   			oTemp:UNIDADE  := TRBXY->D1_UM
   			oTemp:QUANTDE  := TRBXY->D1_QUANT
   			oTemp:VALUNIT  := TRBXY->D1_VUNIT
   			oTemp:VALTOTAL := TRBXY->D1_TOTAL
   			oTemp:VALICMS  := TRBXY->D1_VALICM
   			oTemp:VALIPI   := TRBXY->D1_VALIPI
   			aAdd(::tGetItensNota, oTemp)
			
			DBSkip()
		Enddo
		dbCloseArea("TRBXY")
	#ELSE

		DBSelectArea("SD1")
		DBSetOrder(1)
		DBSeek(cFilNota+cNota+padr(cSerie,3)+cFornec)
		While SD1->(!Eof()) .AND. SD1->D1_FILIAL==cFilNota .AND. SD1->D1_DOC==cNota .AND. AllTrim(SD1->D1_SERIE)==AllTrim(cSerie) .AND.;
			SD1->D1_FORNECE==cFornec

			oTemp          := WsClassNew("tItensNota")
   			oTemp:ITEM     := SD1->D1_ITEM
   			oTemp:PRODUTO  := SD1->D1_COD
   			oTemp:DESCPROD := AllTrim(POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"))
   			oTemp:UNIDADE  := SD1->D1_UM
   			oTemp:QUANTDE  := SD1->D1_QUANT
   			oTemp:VALUNIT  := SD1->D1_VUNIT
   			oTemp:VALTOTAL := SD1->D1_TOTAL
   			oTemp:VALICMS  := SD1->D1_VALICM
   			oTemp:VALIPI   := SD1->D1_VALIPI
   			aAdd(::tGetItensNota, oTemp)

			DBSkip()
		Enddo
		dbCloseArea("SD1")

	#ENDIF

Return .T.  


WSMETHOD GetPedidos WSRECEIVE cFilNota,cNota,cSerie,cFornec WSSEND tGetPedidos WSSERVICE BRVKitPagamentos
Local aPedido := {}
Local lAchou := .F.
Local oTemp
Local cQuery

	::tGetPedidos := {}
	RpcSetType(3)
		
	#IFDEF TOP
		cQuery := " SELECT D1_PEDIDO FROM "+RetSQLName("SD1")+" WHERE D_E_L_E_T_<>'*' AND D1_FILIAL='"+cFilNota+"' "
		cQuery += " AND D1_DOC='"+cNota+"' AND D1_SERIE='"+cSerie+"' AND D1_FORNECE='"+cFornec+"' GROUP BY D1_PEDIDO"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSD1",.T.,.T.)
		dbSelectArea("TRBSD1")
		dbGoTop()
		While TRBSD1->(!Eof())

			cQuery := " SELECT C7_NUM,C7_EMISSAO,C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_PRECO,C7_TOTAL,C7_CC,C7_OBS "
			cQuery += " FROM "+RetSQLName("SC7")+" WHERE D_E_L_E_T_<>'*' AND C7_FILIAL='"+cFilNota+"' AND C7_NUM='"+TRBSD1->D1_PEDIDO+"' "
			cQuery += " AND C7_FORNECE='"+cFornec+"' ORDER BY C7_NUM,C7_ITEM "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSC7",.T.,.T.)
			dbSelectArea("TRBSC7")
			dbGoTop()
			While TRBSC7->(!Eof())

				oTemp          := WsClassNew("tPedCompra")
	   			oTemp:NUMERO   := TRBSC7->C7_NUM
	   			oTemp:EMISSAO  := STOD(TRBSC7->C7_EMISSAO)
	   			oTemp:ITEM     := TRBSC7->C7_ITEM
	   			oTemp:PRODUTO  := TRBSC7->C7_PRODUTO
	   			oTemp:DESCRI   := AllTrim(TRBSC7->C7_DESCRI)
	   			oTemp:UNIDADE  := TRBSC7->C7_UM
	   			oTemp:QUANTDE  := TRBSC7->C7_QUANT
	   			oTemp:VALUNIT  := TRBSC7->C7_PRECO
	   			oTemp:VALTOTAL := TRBSC7->C7_TOTAL
	   			oTemp:CCUSTO   := TRBSC7->C7_CC
	   			oTemp:OBSERV   := AllTrim(TRBSC7->C7_OBS)
	   			aAdd(::tGetPedidos, oTemp)

				DBSkip()
			Enddo
				
			dbCloseArea("TRBSC7")
			dbSelectArea("TRBSD1")
			DBSkip()
		Enddo
		dbCloseArea("TRBSD1")
	#ELSE

		DBSelectArea("SD1")
		DBSetOrder(1)
		DBSeek(cFilNota+cNota+padr(cSerie,3)+cFornec)
		While SD1->(!Eof()) .AND. SD1->D1_FILIAL==cFilNota .AND. SD1->D1_DOC==cNota .AND. AllTrim(SD1->D1_SERIE)==AllTrim(cSerie) .AND.;
			SD1->D1_FORNECE==cFornec

			lAchou := .F.
			For i:=1 to Len(aPedido)
				If aPedido[i,1]==SD1->D1_PEDIDO
					lAchou := .T.
	
				Endif 
			Next

			If !lAchou	 

				DBSelectArea("SC7")
				DBSetOrder(3)
				DBSeek(cFilNota+cFornec+SD1->D1_LOJA+SD1->D1_PEDIDO)
				While SC7->(!Eof()) .AND. SC7->C7_FILIAL==cFilNota .AND. SC7->C7_FORNECE==cFornec .AND. SC7->C7_LOJA==SD1->D1_LOJA .AND.;
					SC7->C7_NUM==SD1->D1_PEDIDO
	
					oTemp          := WsClassNew("tPedCompra")
		   			oTemp:NUMERO   := SC7->C7_NUM
		   			oTemp:EMISSAO  := SC7->C7_EMISSAO
		   			oTemp:ITEM     := SC7->C7_ITEM
		   			oTemp:PRODUTO  := SC7->C7_PRODUTO
		   			oTemp:DESCRI   := AllTrim(SC7->C7_DESCRI)
		   			oTemp:UNIDADE  := SC7->C7_UM
		   			oTemp:QUANTDE  := SC7->C7_QUANT
		   			oTemp:VALUNIT  := SC7->C7_PRECO
		   			oTemp:VALTOTAL := SC7->C7_TOTAL
		   			oTemp:CCUSTO   := SC7->C7_CC
		   			oTemp:OBSERV   := AllTrim(SC7->C7_OBS)
		   			aAdd(::tGetPedidos, oTemp)
					DBSkip()
				Enddo

				dbCloseArea("SC7")
			Endif
			
			dbSelectArea("SD1")
			AADD(aPedido,{SD1->D1_PEDIDO})
			cPedido := SD1->D1_PEDIDO
			DBSkip()
		Enddo
		dbCloseArea("SD1")

	#ENDIF

Return .T.  


WSMETHOD GetPathNota WSRECEIVE NULLPARAM WSSEND cReturn WSSERVICE BRVKitPagamentos

	RpcSetType(3)
   ::cReturn := GetMv("MV_NFEPATH")

Return .T.  


WSMETHOD GetHistApr WSRECEIVE cFilTit,cPrefixo,cTitulo,cParcela,cTipo,cFornec WSSEND tGetHistApr WSSERVICE BRVKitPagamentos
Local oTemp
Local cQuery

	::tGetHistApr := {}
	RpcSetType(3)                     

	#IFDEF TOP
		cQuery := " SELECT * FROM "+RetSQLName("ZBT")+" WHERE D_E_L_E_T_<>'*' AND ZBT_FILTIT='"+cFilTit+"' AND ZBT_PREFIX='"+cPrefixo+"' "
		cQuery += " AND ZBT_NUM='"+cTitulo+"' AND ZBT_PARCEL='"+cParcela+"' AND ZBT_TIPO='"+cTipo+"' "
		cQuery += " AND ZBT_FORNEC='"+cFornec+"' ORDER BY ZBT_DATA,ZBT_HORA"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBZBT",.T.,.T.)
		dbSelectArea("TRBZBT")
		dbGoTop()
		While TRBZBT->(!Eof())

			oTemp         := WsClassNew("tHistAprov")
   			oTemp:CCUSTO  := TRBZBT->ZBT_CCUSTO
   			oTemp:RESPONS := TRBZBT->ZBT_USUAR
   			oTemp:DATAAPR := TRBZBT->ZBT_DATA+" "+TRBZBT->ZBT_HORA
   			oTemp:SITUAC  := TRBZBT->ZBT_SITUAC
   			oTemp:OBSERV  := AllTrim(TRBZBT->ZBT_OBSERV)

   			oTemp:RATEIO  := 100
   			oTemp:VALOR   := 0
   			aAdd(::tGetHistApr, oTemp)
			DBSkip()
		Enddo
		dbCloseArea("TRBZBT")
	#ELSE

		DBSelectArea("ZBT")
		DBSetOrder(2)
		If DBSeek(xFilial("ZBT")+cFilTit+PADR(cPrefixo,3)+cTitulo+cParcela+PADR(cTipo,3)+cFornec)
			While ZBT->(!Eof()) .AND. ZBT->ZBT_FILIAL==xFilial("ZBT") .AND. ZBT->ZBT_FILTIT==cFilTit .AND. AllTrim(ZBT->ZBT_PREFIX)==AllTrim(cPrefixo);
				.AND. ZBT->ZBT_NUM==cTitulo .AND. ZBT->ZBT_PARCEL==cParcela .AND. AllTrim(ZBT->ZBT_TIPO)==AllTrim(cTipo) .AND. ZBT->ZBT_FORNEC==cFornec 
	
				oTemp         := WsClassNew("tHistAprov")
	   			oTemp:CCUSTO  := ZBT->ZBT_CCUSTO
	   			oTemp:RESPONS := ZBT->ZBT_USUAR
	   			oTemp:DATAAPR := DTOS(ZBT->ZBT_DATA)+" "+ZBT->ZBT_HORA
	   			oTemp:RATEIO  := 100
	   			oTemp:VALOR   := 0
	   			oTemp:SITUAC  := ZBT->ZBT_SITUAC
	   			oTemp:OBSERV  := AllTrim(ZBT->ZBT_OBSERV)
	   			aAdd(::tGetHistApr, oTemp)
				DBSkip()
			Enddo
		Endif

	#ENDIF

Return .T.  


WSMETHOD GravarLote WSRECEIVE cItemLote WSSEND cReturn WSSERVICE BRVKitPagamentos
Local nRegistro := 0
Local aItemLote := {}
Local aRegistro := {}
Local i,x

// Sequencia dos onze itens do array de entrada: nomeuser,lote,ccusto,filial,prefixo,título,parcela,tipo,fornecedor,situação,observação

	RpcSetType(3)
	cItemLote := StrTran(cItemLote,"||","| |")                     
	aItemLote := StrToArray(cItemLote,"|")
	nRegistro := Len(aItemLote)/11

	    
	x:=1
    For i:=1 to nRegistro
		Aadd(aRegistro,{aItemLote[x],aItemLote[x+1],aItemLote[x+2],aItemLote[x+3],aItemLote[x+4],aItemLote[x+5],aItemLote[x+6],aItemLote[x+7],;
						aItemLote[x+8],aItemLote[x+9],aItemLote[x+10]})
		x:=x+11
	Next


    For i:=1 to nRegistro
		
		DBSelectArea("ZBR")
		DBSetOrder(1)	   
		If DBSeek(xFilial("ZBR")+aRegistro[i,2]+aRegistro[i,3])
	
			If ZBR->ZBR_SITUAC<>'E'
				
				cChave := xFilial("ZBS")+aRegistro[i,2]+PADR(aRegistro[i,3],12)+aRegistro[i,4]+PADR(aRegistro[i,5],3)+PADR(aRegistro[i,6],9)+;
						  PADR(aRegistro[i,7],1)+PADR(aRegistro[i,8],5)+aRegistro[i,9]
										 
				conout(cChave)

				DBSelectArea("ZBS")
				DBSetOrder(1)	   
				If DBSeek(cChave)

					RecLock("ZBS", .F.) 
					ZBS->ZBS_SITUAC := aRegistro[i,10]
					ZBS->ZBS_OBSERV := aRegistro[i,11]
					MsUnLock()                          
					
		
					DBSelectArea("ZBT")
					RecLock("ZBT", .T.) 
					ZBT->ZBT_FILIAL := ""
					ZBT->ZBT_LOTE   := aRegistro[i,2]
					ZBT->ZBT_CCUSTO := aRegistro[i,3]
					ZBT->ZBT_FILTIT := aRegistro[i,4]
					ZBT->ZBT_PREFIX := aRegistro[i,5]
					ZBT->ZBT_NUM    := aRegistro[i,6]
					ZBT->ZBT_PARCEL := aRegistro[i,7]
					ZBT->ZBT_TIPO   := aRegistro[i,8]
					ZBT->ZBT_FORNEC := aRegistro[i,9]
					ZBT->ZBT_DATA   := dDataBase
					ZBT->ZBT_HORA   := Substr(Time(),1,2)+":"+Substr(Time(),4,2)
					ZBT->ZBT_USUAR  := aRegistro[i,1]
					ZBT->ZBT_SITUAC := aRegistro[i,10]
					ZBT->ZBT_OBSERV := aRegistro[i,11]
					MsUnLock()                          
		
					::cReturn := 'OK'
				Else				
					::cReturn := 'NOK-Título do lote não encontrado!'
					Return .T.  
				Endif
			Else
				::cReturn := 'NOK-Lote já encerrado!'
				Return .T.  
			Endif
			
		Else
			::cReturn := 'NOK-Lote não encontrado!'
			Return .T.  
		Endif
	Next

Return .T.  


WSMETHOD FecharLote WSRECEIVE cLote,cCCusto,cMovimenta WSSEND cReturn WSSERVICE BRVKitPagamentos
Local lReprov := .F.
Local oSvc    := NIL

	RpcSetType(3)                     
	DBSelectArea("ZBR")
	DBSetOrder(1)	   
	If DBSeek(xFilial("ZBR")+cLote+PADR(cCCusto,12))

		If ZBR->ZBR_SITUAC<>'E'

			DBSelectArea("ZBS")
			DBSetOrder(1)	       
			DBSeek(xFilial("ZBS")+cLote+PADR(cCCusto,12))
			While ZBS->(!Eof()) .AND. ZBS->ZBS_FILIAL==xFilial("ZBS") .AND. ZBS->ZBS_LOTE==cLote .AND. AllTrim(ZBS->ZBS_CCUSTO)==AllTrim(cCCusto) 

				If ZBS->ZBS_SITUAC='R' 
					lReprov := .T.
				Endif   	

				If ZBS->ZBS_SITUAC='P' 
					::cReturn := 'NOK-Existem títulos pendentes de aprovação!'
					Return .T.				
				Endif

				dbSkip()
			EndDo

			RecLock("ZBR", .F.) 
			ZBR->ZBR_SITUAC := 'E'
			MsUnLock()                          
			::cReturn := 'OK'

    		If !Empty(ZBR->ZBR_ECMPRO) .AND. cMovimenta=='S' 
				oSvc := WSPagamentosService():New()
				oSvc:nsolicitacao := Val(AllTrim(ZBR->ZBR_ECMPRO))
				oSvc:natividade   := Iif(lReprov,5,6)
				oSvc:cusuario     := ZBR->ZBR_CODUSR
				oSvc:fecharLote()        
        	Endif
		Else
			::cReturn := 'NOK-Lote já encerrado!'
		Endif
	Else				
		::cReturn := 'NOK-Lote não encontrado!'
	Endif
	dbCloseArea("ZBS")
	dbCloseArea("ZBR")

Return .T.  