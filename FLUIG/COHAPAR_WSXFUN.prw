#include "totvs.ch"
#include "protheus.ch"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualizacao                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! Funcoes                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! COHAPAR_WSXFUN                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Funções utilizadas na integração Protheus X Fluig		 !
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Bahl e Dotti									 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 30/10/2014                                              !
+------------------+---------------------------------------------------------+
*/

/*
+-------------------------------------------------------------------------+
! Função    ! MontaXML  ! Autor ! Alexandre Effting  ! Data !  25/04/2012 !
+-----------+-----------+-------+--------------------+------+-------------+
! Parâmetros! _cBody = SoapBody                                           !
+-----------+-------------------------------------------------------------+
! Retorno   ! _cSoapSend = Retorna Requisição XML para ser enviada        !
+-----------+-------------------------------------------------------------+
! Descricao ! Monta XML para envio                                        !
+-----------+---------------------------------------+-------+-------------+
| Atualização                                       | Data  | Responsável |
+---------------------------------------------------+-------+-------------+
|								                        |       |             |
|								                        |       |             |
+---------------------------------------------------+-------+-------------+
*/
User Function MontaXML(_cBody)
   Local _cSoapSend := ""          
   Local _cEncode   := ""
   
   _cSoapSend += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
   _cSoapSend += '<soap:Header/>'
   _cSoapSend += _cBody
   _cSoapSend += '</soap:Envelope>'
Return _cSoapSend

/*
+-------------------------------------------------------------------------+
! Função    ! SoapSend  ! Autor ! Alexandre Effting  ! Data !  25/04/2012 !
+-----------+-----------+-------+--------------------+------+-------------+
! Parâmetros! _cBody = SoapBody                                           !
+-----------+-------------------------------------------------------------+
! Retorno   ! oXmlRet = Retorna Objeto do XML de retorno Parseado         !
+-----------+-------------------------------------------------------------+
! Descricao ! Efetua o envio da requisição ao WS CRM Oracle               !
+-----------+-------------------------------------------------------------+
*/
User Function SoapSend(_cBody, _cMethod, _cService)
	//Local _cUrl := AllTrim(SuperGetMv("MV_INTURL",.F.,"https://secure-vmsomxmma.crmondemand.com/Services/Integration")) 
	//Local _cUrl := 'http://192.168.1.49:8180/webdesk/' + _cService
	Local _cUrl := 'http://200.189.114.17:8080/webdesk/' + _cService
	Local _cSSend := ''
	Local _nTimeOut := 120
	Local _aHeadOut := {}
	Local _cHeadRet := ''
	Local cError := ""
	Local cWarning := ""
	Local _aHeadOut := {}

	Local _dDtIni
	Local _cHrIni
 
	_cSSend := u_MontaXML(_cBody)
	//AADD(_aHeadOut,u_RetAction(_cEntidade,_cOp))
	AADD(_aHeadOut,'SOAPAction: '+ _cMethod)
	AADD(_aHeadOut,"Content-Type: text/xml; charset=utf-8")
	AADD(_aHeadOut,"User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.111010P-20120120; FSW TOTVS CTBA - ADVPL WSDL)")
	//AADD(_aHeadOut,"Host: secure-vmsomxmma.crmondemand.com")
	
	conout("XML SEND =================")
	conout(_cSSend)
	MemoWrite("C:\temp\TCP_WSXFUN_SOAPSEND.txt", _cSSend)
	
	// Busca Data e Hora de Início Integração
	_dDtIni := dDatabase
	_cHrIni := TIME()
	
	_cPostRet := Httppost(_cUrl,"",_cSSend,_nTimeOut,_aHeadOut,@_cHeadRet)
	//_cPostRet := HttpSPost(_cUrl,"","","","",_cSSend,_nTimeOut,_aHeadOut,@_cHeadRet) 
 
	if _cPostRet == NIL
		conout("Erro de Comunicação com: "+_cUrl)
		return Nil
	EndIf
	 
	conout("XML RETORNO ==============")
	conout(_cPostRet)
	
	//Aviso( "XML RETORNO", _cPostRet, {"Ok"} )
	
	oXmlRet := XmlParser(_cPostRet,'_',@cError,@cWarning)
	
	// VERIFICA SE E UM ERRO
	If xGetInfo( oXmlRet ,"_SOAP_ENVELOPE:_SOAP_BODY:_SOAP_FAULT:_DETAIL" ) != NIL .OR.;
		xGetInfo( oXmlRet ,"_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_SOAP_ENV_FAULT:_DETAIL" ) != NIL
		//_cStatus := "E"
		// ERRO
	else
		// SUCESSO 		
	EndIF                
	
Return oXmlRet

// Funcao para padronizar string para envio no WS
User Function fStdString(cString)
    local cNewString
    
    cNewString := AllTrim(NoAcento(OemToAnsi(cString)))
    cNewString := StrTran(cNewString, "&", "e")
    cNewString := StrTran(cNewString, "'", " ")
    cNewString := StrTran(cNewString, '"', ' ')
	cNewString := EncodeUTF8(AllTrim(cNewString))
	
Return cNewString

user function DocIDFlg(cNumProcess)
	// Integracao Protheus
	local cUsrProtheus := 'michaelandrade'
	local cPwdProtheus := '123456'
	local cCodCompany := '0101'
	local cMatUsrProtheus := '000467'
	
	local cDocID := ''
	local _cSOAPBody := ''
	local _cMethod := '"getAttachments"'
	local _cService := 'ECMWorkflowEngineService'
	
	// busca attachments -> pega o documentId -> atualiza o cardData com o docId
	_cSOAPBody += '<soap:Body>'
	_cSOAPBody += '    <ws:getAttachments>'
	_cSOAPBody += '        <username>'+cUsrProtheus+'</username>'
	_cSOAPBody += '        <password>'+cPwdProtheus+'</password>'
	_cSOAPBody += '        <companyId>'+cCodCompany+'</companyId>'
	_cSOAPBody += '        <userId>'+cMatUsrProtheus+'</userId>'
	_cSOAPBody += '        <processInstanceId>'+AllTrim(cNumProcess)+'</processInstanceId>'
	_cSOAPBody += '    </ws:getAttachments>'
	_cSOAPBody += '</soap:Body>'
	
	oXMLRet := U_SoapSend(_cSOAPBody, _cMethod, _cService)
	oXMLErro := xGetInfo(oXMLRet,'_SOAP_ENVELOPE:_SOAP_BODY:_SOAP_FAULT' )
	if oXMLErro != Nil
		//alert("Ocorreu um erro de comunicacao com o Fluig:" + CRLF + oXMLErro:_FAULTSTRING:TEXT)
	else
		// Busca a mensagem de retorno do processo
		oMsgErr := xGetInfo(oXMLRet,'oXMLRet:_SOAP_ENVELOPE:_SOAP_BODY:_ns1_getAttachmentsResponse:_result:text' )
		// se o retorno foi um erro
		if Valtype(oMsgErr) == "C" .and. "erro" $ lower(oMsgErr)
			//Alert("Houve um erro ao solicitar dados do processo no Fluig: " + CRLF + cMsgFluig)
			//lRet := .f.
		else
			// Pega o docId para alterar os dados do formulario
			aItem := oXMLRet:_SOAP_ENVELOPE:_SOAP_BODY:_ns1_getAttachmentsResponse:_attachments:_ITEM
			cDocID := aItem[Len(aItem)]:_DOCUMENTID:TEXT
		endif
	endif
	
return cDocID