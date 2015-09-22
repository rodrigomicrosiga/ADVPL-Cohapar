#INCLUDE "PROTHEUS.CH"        
#INCLUDE "TOPCONN.CH"

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! GeraLote	! Autor !Gilson Lima 		 ! Data ! 02/04/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função Auxiliar para processamento de Lotes em aberto para o   !
! 			! Centro de custo do Usuário	    							 !
+----------------------------------------------------------------------------*/
USER FUNCTION GeraLote(cCCusto)
	
	Local cQuery := ""
	Local cCodCusto  := ""
	
	// Tipos de Documentos que são processados pelo FLUIG
	Local cTipos := StrTran(GETNEWPAR("MC_TPFLUIG",'AF'),";","/") 	
		
	// Centro Custo Usuário
	Local cFilMatr := ''
	Local cCC      := ''
	
	Local nTotalNF := 0
	
	//Private cCodLote := StrZero(Randomize(1,32000),8) 
	Private cCodLote := GetSxEnum("ZBR","ZBR_CODIGO")
	Private _cCodUsr := ''
	Private _cNome	 := ''
	Private _cSenha	 := ''
	Private _NomeUser := ''
	
	// Se não houver cCCusto
	If cCCusto == Nil
		// Busca CCusto Usuário
		cFilMatr := Substr(PswRet()[1][22],3)
		cCC      := POSICIONE("SRA",1,cFilMatr,"RA_CC")	
	Else
		cCC		 := cCCusto
	EndIf
	
	// Obtém dados usuário logado
	_cCodUsr := RetCodUsr()
	_cNome   := UsrRetName(_cCodUsr)
	
	// Senha
	PswOrder(1)
	If PswSeek(_cCodUsr,.T.)
	   _aRetUser := PswRet(1,.F.)
	   _cSenha   := Upper(AllTrim(_aRetUser[1,3]))         
	EndIf
	
	cQuery += "SELECT SF1.F1_FILIAL, SF1.F1_SERIE, SF1.F1_DOC, SF1.F1_ESPECIE, SF1.F1_TIPO, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_VALBRUT"
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"
	cQuery += " WHERE SF1.D_E_L_E_T_ <> '*'"
	cQuery += " AND SF1.F1_XLOTE = '" + Space(TamSX3("F1_XLOTE")[1]) + "'"
	cQuery += " AND SF1.F1_XCCLAN = '" + cCC + "'"
	cQuery += " AND SF1.F1_ESPECIE IN ('" + cTipos+ "')"
	
	If Select( "SF1TMP" ) <> 0
		dbSelectArea("SF1TMP")
		SF1TMP->(dbCloseArea())
	EndIf            
	
	cQuery := ChangeQuery(cQuery)    
	TcQuery cQuery Alias "SF1TMP" New	

	// Verifica se existem NFs, se sim, grava lote
	nQtd := Contar("SF1TMP","!EOF()")	
	If nQtd == 0
		RollBackSx8()
		Return .F.
	EndIf	
	
	// Confirma Número Lote
	ConfirmSX8()	
	
	GravarLote(cCC)
	
	// Grava itens do Lote
	dBSelectArea("SF1TMP")
	SF1TMP->(dbGoTop())
	While SF1TMP->(!EOF())
	
		nTotalNF := 0
	
		cQuery2 := " SELECT SUM(D1_TOTAL) AS D1_TOTAL FROM "+RetSQLName("SD1")+" "
		cQuery2 += " WHERE D_E_L_E_T_<>'*' AND D1_FILIAL='"+SF1TMP->F1_FILIAL+"' AND D1_DOC='"+SF1TMP->F1_DOC+"' "
		cQuery2 += " AND D1_SERIE='"+SF1TMP->F1_SERIE+"' AND D1_FORNECE='"+SF1TMP->F1_FORNECE+"' "
		cQuery2 := ChangeQuery(cQuery2)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"TRBXYZ",.T.,.T.)
		dbSelectArea("TRBXYZ")

			nTotalNF := TRBXYZ->D1_TOTAL
		
		dbCloseArea("TRBXYZ")
	    	
		DBSelectArea("ZBS")
		RecLock("ZBS", .T.) 
		ZBS->ZBS_FILIAL := ""
		ZBS->ZBS_LOTE   := cCodLote
		ZBS->ZBS_CCUSTO := cCC
		ZBS->ZBS_FILTIT := SF1TMP->F1_FILIAL
		ZBS->ZBS_PREFIX := SF1TMP->F1_SERIE
		ZBS->ZBS_NUM    := SF1TMP->F1_DOC
		ZBS->ZBS_PARCEL := ''
		ZBS->ZBS_TIPO   := SF1TMP->F1_ESPECIE
		ZBS->ZBS_NATURE := ''
		ZBS->ZBS_FORNEC := SF1TMP->F1_FORNECE
		ZBS->ZBS_DTEMIS := StoD(SF1TMP->F1_EMISSAO)
		ZBS->ZBS_VENCTO := StoD('')
		ZBS->ZBS_VALOR  := nTotalNF
		//ZBS->ZBS_VALOR  := SF1TMP->F1_VALBRUT
		ZBS->ZBS_SITUAC := "P"
		ZBS->ZBS_RATEIO := 100
		//ZBS->ZBS_VALRAT := SF1TMP->F1_VALBRUT
		ZBS->ZBS_VALRAT := nTotalNF
		MsUnLock()
		
		cChave := SF1TMP->F1_FILIAL+SF1TMP->F1_DOC+SF1TMP->F1_SERIE+SF1TMP->F1_FORNECE+SF1TMP->F1_LOJA+SF1TMP->F1_TIPO
		
		// Grava Lote na SF1
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		SF1->(dbSeek(cChave))
		
		RecLock("SF1",.F.)
			SF1->F1_XLOTE := cCodLote
		MsUnLock()
		
		SF1->(dbCloseArea())
	
		SF1TMP->(dbSkip())
	End
	
	dbCloseArea("SF1TMP")

Return .T.

Static Function GravarLote(cCCusto)
	
	Local cCodUser		:= POSICIONE("CTT",1,xFilial("CTT")+cCCusto,"CTT_USER") 
	Local cNmCCusto		:= AllTrim(POSICIONE("CTT",1,xFilial("CTT")+cCCusto,"CTT_DESC01"))
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
	Local cUsrAprova		:= cCodUser // Cod Aprovador CCusto
	
	local cUsrProtheus 	:= 'operador.protheus'
	local cPwdProtheus 	:= '#fluig#'
	local cCodCompany 	:= '0101'
	local cMatUsrProtheus := _cCodUsr 
	Local cProcessId 	:= 'Pagamento'
	    	
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
				_cBody += '    <userId>'+cUserOrig+'</userId>'
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
				_cBody += '      	   <item>nomeCentro</item>'
				_cBody += '      	   <item>' + cNmCCusto + '</item>'
				_cBody += '        </item>'
				_cBody += '        <item>'
				_cBody += '      	   <item>dtLote</item>'
				_cBody += '            <item>' + dToS(dDataBase)+" "+Substr(Time(),1,2)+":"+Substr(Time(),4,2) + '</item>'
				_cBody += '        </item>'
				_cBody += '        <item>'
				_cBody += '      	   <item>aprovador</item>'
				_cBody += '      	   <item>' + cUsrAprova + '</item>'
				_cBody += '        </item>'							
				_cBody += '        <item>'
				_cBody += '      	   <item>codUser</item>'
				_cBody += '      	   <item>' + cUserOrig + '</item>'
				_cBody += '        </item>'							
				_cBody += '     </cardData>'
				_cBody += '     <appointment/>'
				_cBody += '     <managerMode>false</managerMode>'
				_cBody += '</ws:startProcess>'
				_cBody += '</soap:Body>'
				
				oXML := U_SoapSend(_cBody, "startProcess", "ECMWorkflowEngineService")
				
				oXMLDetail := xGetInfo(oXML,'_SOAP_ENVELOPE:_SOAP_BODY:_NS1_STARTPROCESSRESPONSE:_RESULT' )
				
				lProcOk := .F.
				
				if oXMLDetail == Nil
					// Adiciona no array de "log" Posicoes: {numero PC, tipo de log ("E","S"), mensagem )}
					//aAdd(aLog, {SD1->D1_PEDIDO, "E",;
					 
					 ALERT("Ocorreu um erro na atualização do processo Fluig!")
					 Return .F.
				else
					oXMLDetail := xGetInfo(oXML,'_SOAP_ENVELOPE:_SOAP_BODY:_NS1_STARTPROCESSRESPONSE:_RESULT' )
					if ValType(oXMLDetail:_ITEM[1]) == "O" 
						If "ERRO" $ oXMLDetail:_ITEM[1]:TEXT
							lProcOk := .F.
							ALERT("Ocorreu um erro na atualização do processo Fluig!")
						Else
							cIDProc := oXMLDetail:_ITEM[4]:_ITEM[2]:TEXT
							lProcOk := .T.
						EndIf
					EndIf
					
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
						ZBR->ZBR_ECMPRO := cIDProc
						
						MsUnLock()

						DBCloseArea("ZBR")	
					
						// Geração OK
						If MsgYesNo("Lote Nr. "+cCodLote+" gerado com sucesso. Deseja imprimir o relatório?","Atenção")
							// Imprime Relatório
							U_BRVKPAG001(cCodLote)
						EndIf
					endif
				endif
			Endif
		Endif
	Endif

Return .T.
