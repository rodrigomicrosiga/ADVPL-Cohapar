#INCLUDE "PROTHEUS.CH"        


USER FUNCTION MGETMOED()
	//Local dDtIni := Date()+GetMv("MV_BKDDINI")
	Local dDtIni := StoD('20150310')
	Local dDtFim := dDtIni+GetMv("MV_BKDDFIM")
	Local cQuery := ""
	Local cCodCusto  := ""
	//Private cCodLote := DtoS(dDataBase) 
	Private cCodLote := StrZero(Randomize(1,32000),8) 
	Private _cCodUsr := ''
	Private _cNome	 := ''
	Private _cSenha	 := ''
	Private _NomeUser := ''
	
	// Obtém dados usuário logado
	_cCodUsr := RetCodUsr()
	_cNome   := UsrRetName(_cCodUsr)
	
	// Senha
	PswOrder(1)
	If PswSeek(_cCodUsr,.T.)
	   _aRetUser := PswRet(1,.F.)
	   _cSenha   := Upper(AllTrim(_aRetUser[1,3]))         
	EndIf

	#IFDEF TOP
		cQuery := " SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_FORNECE,E2_VENCREA,E2_VALOR,E2_EMISSAO,E2_CCD,E2_FILORIG "
		cQuery += " FROM "+RetSQLName("SE2")+" A, "+RetSQLName("SED")+" B WHERE A.D_E_L_E_T_<>'*' AND B.D_E_L_E_T_<>'*' AND E2_VENCREA "
		cQuery += " BETWEEN "+DtoS(dDtIni)+" AND "+DtoS(dDtFim)+" AND ED_CODIGO=E2_NATUREZ AND ED_GERLOTE='S' AND E2_SALDO>0 "
		cQuery += " AND E2_LOTEAPR IN (' ','1') ORDER BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSE2",.T.,.T.)
		DBSelectArea("TRBSE2")
		DBGoTop()
		While TRBSE2->(!Eof())

			cQuery := " SELECT F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE FROM "+RetSQLName("SF1")+" WHERE D_E_L_E_T_<>'*' "
			cQuery += " AND F1_FILIAL='"+TRBSE2->E2_FILIAL+"' AND F1_DUPL='"+TRBSE2->E2_NUM+"' AND F1_FORNECE='"+TRBSE2->E2_FORNECE+"' "
  			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSF1",.T.,.T.)
			DBSelectArea("TRBSF1")
			If TRBSF1->(!Eof())
				
				DBSelectArea("SDE")
				DBSetOrder(1)
				If DBSeek(TRBSF1->F1_FILIAL+TRBSF1->F1_DOC+PADR(TRBSF1->F1_SERIE,3)+TRBSF1->F1_FORNECE)
					While SDE->(!Eof()) .AND. SDE->DE_FILIAL==TRBSF1->F1_FILIAL .AND. SDE->DE_DOC==TRBSF1->F1_DOC .AND.;
						AllTrim(SDE->DE_SERIE)==AllTrim(TRBSF1->F1_SERIE) .AND. SDE->DE_FORNECE==TRBSF1->F1_FORNECE
							    	
						GravarLote(SDE->DE_CC)
						DBSelectArea("ZBS")
						RecLock("ZBS", .T.) 
						ZBS->ZBS_FILIAL := ""
						ZBS->ZBS_LOTE   := cCodLote
						ZBS->ZBS_CCUSTO := SDE->DE_CC
						ZBS->ZBS_FILTIT := TRBSE2->E2_FILORIG
						ZBS->ZBS_PREFIX := TRBSE2->E2_PREFIXO
						ZBS->ZBS_NUM    := TRBSE2->E2_NUM
						ZBS->ZBS_PARCEL := TRBSE2->E2_PARCELA
						ZBS->ZBS_TIPO   := TRBSE2->E2_TIPO
						ZBS->ZBS_NATURE := TRBSE2->E2_NATUREZ
						ZBS->ZBS_FORNEC := TRBSE2->E2_FORNECE
						ZBS->ZBS_DTEMIS := StoD(TRBSE2->E2_EMISSAO)
						ZBS->ZBS_VENCTO := StoD(TRBSE2->E2_VENCREA)
						ZBS->ZBS_VALOR  := TRBSE2->E2_VALOR
						ZBS->ZBS_SITUAC := "P"
						ZBS->ZBS_RATEIO := SDE->DE_PERC
						ZBS->ZBS_VALRAT := SDE->DE_CUSTO1
						MsUnLock()

						DBSelectArea("SDE")
						DBSkip()
					Enddo	
				Else
					cQuery := " SELECT D1_CC FROM "+RetSQLName("SF1")+" A, "+RetSQLName("SD1")+" B WHERE A.D_E_L_E_T_<>'*' AND B.D_E_L_E_T_<>'*' "
					cQuery += " AND D1_FILIAL='"+TRBSE2->E2_FILIAL+"' AND F1_DUPL='"+TRBSE2->E2_NUM+"' AND F1_FILIAL=D1_FILIAL "
					cQuery += " AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE GROUP BY D1_CC"
		  			cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBSD1",.T.,.T.)
					DBSelectArea("TRBSD1")
					DBGoTop()
					If TRBSD1->(!Eof())
						While TRBSD1->(!Eof())
		    	
							GravarLote(TRBSD1->D1_CC)
							DBSelectArea("ZBS")
							RecLock("ZBS", .T.) 
							ZBS->ZBS_FILIAL := ""
							ZBS->ZBS_LOTE   := cCodLote
							ZBS->ZBS_CCUSTO := TRBSD1->D1_CC
							ZBS->ZBS_FILTIT := TRBSE2->E2_FILORIG
							ZBS->ZBS_PREFIX := TRBSE2->E2_PREFIXO
							ZBS->ZBS_NUM    := TRBSE2->E2_NUM
							ZBS->ZBS_PARCEL := TRBSE2->E2_PARCELA
							ZBS->ZBS_TIPO   := TRBSE2->E2_TIPO
							ZBS->ZBS_NATURE := TRBSE2->E2_NATUREZ
							ZBS->ZBS_FORNEC := TRBSE2->E2_FORNECE
							ZBS->ZBS_DTEMIS := StoD(TRBSE2->E2_EMISSAO)
							ZBS->ZBS_VENCTO := StoD(TRBSE2->E2_VENCREA)
							ZBS->ZBS_VALOR  := TRBSE2->E2_VALOR
							ZBS->ZBS_SITUAC := "P"
							ZBS->ZBS_RATEIO := 100
							ZBS->ZBS_VALRAT := TRBSE2->E2_VALOR
							MsUnLock()
		
							DBSelectArea("TRBSD1")
							DBSkip()
						Enddo
		    		Endif
		    
					DBSelectArea("TRBSD1")
					DBCloseArea("TRBSD1")	
		    	Endif
	    	Else
			
				If !Empty(TRBSE2->E2_CCD)
				    GravarLote(TRBSE2->E2_CCD)
					DBSelectArea("ZBS")
					RecLock("ZBS", .T.) 
					ZBS->ZBS_FILIAL := ""
					ZBS->ZBS_LOTE   := cCodLote
					ZBS->ZBS_CCUSTO := TRBSE2->E2_CCD
					ZBS->ZBS_FILTIT := TRBSE2->E2_FILORIG
					ZBS->ZBS_PREFIX := TRBSE2->E2_PREFIXO
					ZBS->ZBS_NUM    := TRBSE2->E2_NUM
					ZBS->ZBS_PARCEL := TRBSE2->E2_PARCELA
					ZBS->ZBS_TIPO   := TRBSE2->E2_TIPO
					ZBS->ZBS_NATURE := TRBSE2->E2_NATUREZ
					ZBS->ZBS_FORNEC := TRBSE2->E2_FORNECE
					ZBS->ZBS_DTEMIS := StoD(TRBSE2->E2_EMISSAO)
					ZBS->ZBS_VENCTO := StoD(TRBSE2->E2_VENCREA)
					ZBS->ZBS_VALOR  := TRBSE2->E2_VALOR
					ZBS->ZBS_SITUAC := "P"
					ZBS->ZBS_RATEIO := 100
					ZBS->ZBS_VALRAT := TRBSE2->E2_VALOR
					MsUnLock()
				Endif
			Endif
									
			DBSelectArea("SE2")
			DBSetOrder(1)
		    If DBSeek(TRBSE2->E2_FILIAL+PADR(TRBSE2->E2_PREFIXO,3)+TRBSE2->E2_NUM+TRBSE2->E2_PARCELA+PADR(TRBSE2->E2_TIPO,3)+TRBSE2->E2_FORNECE)
				RecLock("SE2",.F.) 
				SE2->E2_LOTEAPR := '2'
				MsUnLock()
			Endif			
			
		
			DBSelectArea("TRBSF1")
			DBCloseArea("TRBSF1")	

			DBSelectArea("TRBSE2")
			DBSkip()
		EndDo
		DBCloseArea("TRBSE2")	

	#ELSE

		DBSelectArea("SE2")
		DBSetOrder(3)
		DBGoTop()
		While SE2->(!Eof()) .AND. SE2->E2_VENCREA>=dDtIni .AND. SE2->E2_VENCREA<=dDtFim

			If SE2->E2_SALDO>0 .AND. POSICIONE("SED",1,xFilial("SED")+SE2->E2_NATUREZ,"ED_GERLOTE")=='S' .AND.;
				(SE2->E2_LOTEAPR=="1" .OR. Empty(SE2->E2_LOTEAPR)) 


				DBSelectArea("SF1")
				DBSetOrder(2)
				If DBSeek(SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_NUM)
                
					DBSelectArea("SDE")
					DBSetOrder(1)
					If DBSeek(SF1->F1_FILIAL+SF1->F1_DOC+PADR(SF1->F1_SERIE,3)+SF1->F1_FORNECE)

						While SDE->(!Eof()) .AND. SDE->DE_FILIAL==SF1->F1_FILIAL .AND. SDE->DE_DOC==SF1->F1_DOC .AND.;
							AllTrim(SDE->DE_SERIE)==AllTrim(SF1->F1_SERIE) .AND. SDE->DE_FORNECE==SF1->F1_FORNECE

							GravarLote(SDE->DE_CC)
							DBSelectArea("ZBS")
							RecLock("ZBS", .T.) 
							ZBS->ZBS_FILIAL := ""
							ZBS->ZBS_LOTE   := cCodLote
							ZBS->ZBS_CCUSTO := SDE->DE_CC
							ZBS->ZBS_FILTIT := SE2->E2_FILORIG
							ZBS->ZBS_PREFIX := SE2->E2_PREFIXO
							ZBS->ZBS_NUM    := SE2->E2_NUM
							ZBS->ZBS_PARCEL := SE2->E2_PARCELA
							ZBS->ZBS_TIPO   := SE2->E2_TIPO
							ZBS->ZBS_NATURE := SE2->E2_NATUREZ
							ZBS->ZBS_FORNEC := SE2->E2_FORNECE
							ZBS->ZBS_DTEMIS := SE2->E2_EMISSAO
							ZBS->ZBS_VENCTO := SE2->E2_VENCREA
							ZBS->ZBS_VALOR  := SE2->E2_VALOR
							ZBS->ZBS_SITUAC := "P"
							ZBS->ZBS_RATEIO := SDE->DE_PERC
							ZBS->ZBS_VALRAT := SDE->DE_CUSTO1
							MsUnLock()
	
							DBSelectArea("SDE")
							DBSkip()
        				Enddo
					
					Else
						
						DBSelectArea("SD1")
						DBSetOrder(1)
						If DBSeek(SF1->F1_FILIAL+SF1->F1_DOC+PADR(SF1->F1_SERIE,3)+SF1->F1_FORNECE)
						
							While SD1->(!Eof()) .AND. SD1->D1_FILIAL==SF1->F1_FILIAL .AND. SD1->D1_DOC==SF1->F1_DOC .AND.;
								AllTrim(SD1->D1_SERIE)==AllTrim(SF1->F1_SERIE) .AND. SD1->D1_FORNECE==SF1->F1_FORNECE
				
								If AllTrim(SD1->D1_CC)<>cCodCusto	
									GravarLote(SD1->D1_CC)
									DBSelectArea("ZBS")
									RecLock("ZBS", .T.) 
									ZBS->ZBS_FILIAL := ""
									ZBS->ZBS_LOTE   := cCodLote
									ZBS->ZBS_CCUSTO := SD1->D1_CC
									ZBS->ZBS_FILTIT := SE2->E2_FILORIG
									ZBS->ZBS_PREFIX := SE2->E2_PREFIXO
									ZBS->ZBS_NUM    := SE2->E2_NUM
									ZBS->ZBS_PARCEL := SE2->E2_PARCELA
									ZBS->ZBS_TIPO   := SE2->E2_TIPO
									ZBS->ZBS_NATURE := SE2->E2_NATUREZ
									ZBS->ZBS_FORNEC := SE2->E2_FORNECE
									ZBS->ZBS_DTEMIS := SE2->E2_EMISSAO
									ZBS->ZBS_VENCTO := SE2->E2_VENCREA
									ZBS->ZBS_VALOR  := SE2->E2_VALOR
									ZBS->ZBS_SITUAC := "P"
									ZBS->ZBS_RATEIO := 100
									ZBS->ZBS_VALRAT := SE2->E2_VALOR
									MsUnLock()
								Endif
				
								DBSelectArea("SD1")
								cCodCusto := SD1->D1_CC
								DBSkip()
							Enddo
						Endif
					Endif
				Else	
					If !Empty(SE2->E2_CCD)
					    GravarLote(SE2->E2_CCD)
						DBSelectArea("ZBS")
						RecLock("ZBS", .T.) 
						ZBS->ZBS_FILIAL := ""
						ZBS->ZBS_LOTE   := cCodLote
						ZBS->ZBS_CCUSTO := SE2->E2_CCD
						ZBS->ZBS_FILTIT := SE2->E2_FILORIG
						ZBS->ZBS_PREFIX := SE2->E2_PREFIXO
						ZBS->ZBS_NUM    := SE2->E2_NUM
						ZBS->ZBS_PARCEL := SE2->E2_PARCELA
						ZBS->ZBS_TIPO   := SE2->E2_TIPO
						ZBS->ZBS_NATURE := SE2->E2_NATUREZ
						ZBS->ZBS_FORNEC := SE2->E2_FORNECE
						ZBS->ZBS_DTEMIS := SE2->E2_EMISSAO
						ZBS->ZBS_VENCTO := SE2->E2_VENCREA
						ZBS->ZBS_VALOR  := SE2->E2_VALOR
						ZBS->ZBS_SITUAC := "P"
						ZBS->ZBS_RATEIO := 100
						ZBS->ZBS_VALRAT := SE2->E2_VALOR
						MsUnLock()
    				Endif
                Endif
                
                
                DBSelectArea("SE2")
				RecLock("SE2",.F.) 
				SE2->E2_LOTEAPR := '2'
				MsUnLock()                                                             
			Endif

			DBSelectArea("SE2")
			DBSkip()
		Enddo
		
	#ENDIF
Return .T.


Static Function GravarLote(cCCusto)
	
	Local cCodUser		:= POSICIONE("CTT",1,xFilial("CTT")+cCCusto,"CTT_USER") 
	Local lKitPag		:= GetMv("MV_BRVKPAG")    
	Local aInfo			:= {}
	Local oSvc			:= NIL
	
	local aRet			:= {}
	local nPos			:= 0
	local cXML			:= ""
	local cChave		:= ""
	local cComments 	:= "Solicitacao Gerada atraves do Protheus"
	Local _cBody 		:= ''
	
	// Integracao Protheus
	
	Local cUserOrig			:= _cCodUsr
	//Local cUsrProtheus		:= _cNome
	//Local cPwdProtheus		:= _cSenha
	Local cUsrAprova		:= cCodUser // Cod Aprovador CCusto
	
	local cUsrProtheus 	:= 'operador.protheus'
	local cPwdProtheus 	:= '#fluig#'
	local cCodCompany 	:= '0101'
	local cMatUsrProtheus := '000468' 
	Local cProcessId 	:= 'Pagamento'
	//Local cUsrRecebe	:= '000433' // De Paula	
	    	
	DBSelectArea("ZBR")
	DBSetOrder(1)
    If !DBSeek(xFilial("ZBR")+cCodLote+cCCusto)
		PswOrder(1)

 		If PswSeek(cCodUser,.T.)
			aInfo := PswRet(1)

			If lKitPag  

				_cBody += '<soap:Body>'
				_cBody += '<ws:startProcess>'
				_cBody += '    <username>'+cUsrProtheus+'</username>'
				_cBody += '    <password>'+cPwdProtheus+'</password>'
				_cBody += '    <companyId>'+cCodCompany+'</companyId>'
				_cBody += '    <processId>'+cProcessId+'</processId>'
				_cBody += '    <choosedState>0</choosedState>'
				_cBody += '    <colleagueIds >'
				_cBody += '        <item>'+ cUserOrig +'</item>'
				_cBody += '    </colleagueIds>'
				_cBody += '    <comments>' +cComments+ '</comments>'
				_cBody += '    <userId>'+cMatUsrProtheus+'</userId>'
				_cBody += '    <completeTask>true</completeTask>'
				_cBody += '    <attachments />'
				_cBody += '    <cardData>'
				_cBody += '        <item>'
				_cBody += '            <item>lote</item>'
				_cBody += '      	   <item>' + cCodLote + '</item>'
				_cBody += '        </item>'
				_cBody += '        <item>'
				_cBody += '      	   <item>centroCusto</item>'
				_cBody += '      	   <item>' + cCCusto + '</item>'
				_cBody += '        </item>'
				_cBody += '        <item>'
				_cBody += '      	   <item>dtLote</item>'
				_cBody += '            <item>' + dToS(dDataBase)+" "+Substr(Time(),1,2)+":"+Substr(Time(),4,2) + '</item>'
				_cBody += '        </item>'
				_cBody += '        <item>'
				_cBody += '      	   <item>aprovador</item>'
				_cBody += '      	   <item>' + cUsrAprova + '</item>'
				_cBody += '        </item>'				
				_cBody += '     </cardData>'
				_cBody += '     <appointment/>'
				_cBody += '     <managerMode>false</managerMode>'
				_cBody += '</ws:startProcess>'
				_cBody += '</soap:Body>'
				
				oXML := U_SoapSend(_cBody, "startProcess", "ECMWorkflowEngineService")
				
				oXMLDetail := xGetInfo(oXML,'_SOAP_ENVELOPE:_SOAP_BODY:_SOAP_FAULT' )
				
				lProcOk := .F.
				
				if oXMLDetail != Nil
					// Adiciona no array de "log" Posicoes: {numero PC, tipo de log ("E","S"), mensagem )}
					//aAdd(aLog, {SD1->D1_PEDIDO, "E",;
					 
					 ALERT("Ocorreu um erro na atualização do processo Fluig:" + CRLF + oXMLDetail:_FAULTSTRING:TEXT)
				else
					oXMLDetail := xGetInfo(oXML,'_SOAP_ENVELOPE:_SOAP_BODY:_NS1_STARTPROCESSRESPONSE:_RESULT' )
					//if ValType(oXMLDetail:_ITEM[1]) == "O" 
						//If "ERRO" $ oXMLDetail:_ITEM[1]:TEXT
							// Adiciona no array de "log" Posicoes: {numero PC, tipo de log ("E","S"), mensagem )}
							//aAdd(aLog, {SD1->D1_PEDIDO, "E",;
							
							//ALERT("Ocorreu um erro na atualização do processo Fluig:" + CRLF + oXMLDetail:_Item:OXMLDETAIL:_ITEM[2]:TEXT)
						//Else
							//lProcOk := .T.
						//EndIf
						 	
					//else
						lProcOk := .T.
					//EndIf
					
					If lProcOk
						// Adiciona no array de "log" Posicoes: {numero PC, tipo de log ("E","S"), mensagem )}
						//aAdd(aLog, {SD1->D1_PEDIDO, "S",;
					 	//"O processo foi encerrado com sucesso no Fluig sob o número " + cNumFluig + "."})
					 		
						RecLock("ZBR", .T.) 
						ZBR->ZBR_FILIAL := ""
						ZBR->ZBR_CODIGO := cCodLote
						ZBR->ZBR_CCUSTO := cCCusto
						ZBR->ZBR_DATA   := dDataBase
						ZBR->ZBR_HORA   := Substr(Time(),1,2)+":"+Substr(Time(),4,2)
						ZBR->ZBR_CODUSR := cCodUser
						ZBR->ZBR_USUAR  := AllTrim(aInfo[1,2])
						ZBR->ZBR_SITUAC := "A"
						
						MsUnLock()

						DBCloseArea("ZBR")	
						
					 	Alert("Processo OK!")						
					endif
				endif
			Endif
		Endif
	Endif

Return .T.
