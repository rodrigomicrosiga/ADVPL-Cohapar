/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Workflow 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contrato	 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_CONTRATOS_WORKFLOW.PRW							 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Contratos - Envio de Email para gestores e fiscais		 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/08/2015												 !
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
#include "tbiconn.ch"
#include "topconn.ch"

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! WFCTRVCTO ! Autor !Gilson Lima 		 ! Data ! 03/08/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Envio de Workflow para gestores, DELI e fiscais informando	 !
!			! vencto de contrato											 !
+----------------------------------------------------------------------------*/

User Function WFCTRVCTO(aParam)

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'
	
	cQuery		:= ''

	cNrDias		:= ''			
	cNum		:= ''
	cRevisa		:= ''
	cEmail		:= ''	
	cTipo		:= ''
	aCtEmail	:= {}
	
	aEmails		:= Separa(AllTrim(GETNEWPAR("MV_CTRGREM", 'gilson.lima@totvs.com.br')),',') // Parametro que receberá os e-mails do grupo do DELI
	lEmailGrp	:= .F.

	aPrazosVc	:= Separa(AllTrim(GETNEWPAR("MV_CTRPRZVC",'120,90,60,50,30,0')),',')
	aPrazosEx	:= Separa(AllTrim(GETNEWPAR("MV_CTRPRZEX",'90,60,30,0')),',')
	
	// FIM VIGENCIA
	
	cQuery := "SELECT * "
	cQuery += " FROM " + RetSqlName('CN9') + " CN9"
	cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_SITUAC = '05'"	// Ativos
	
	// Acrescenta as datas no While
	For nA:= 1 To Len(aPrazosVc)
		If nA == 1
			cQuery += " AND ("
		Else
			cQuery += " OR"
		EndIf
		cQuery += " CN9.CN9_DTFIM = '" + DtoS(Date() + Val(aPrazosVc[nA])) + "'"
		If nA == Len(aPrazosVc)
			cQuery += ")"
		EndIf
	Next nA
	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		aAdd(aCtEmail,{;
			TRB->CN9_NUMERO,;
			TRB->CN9_REVISA,;
			TRB->CN9_DTFIM,;
			'V'; // Vigência
		})
		
		TRB->(dbSkip())
	EndDo
	
	TRB->(dbCloseArea())

	// FIM EXECUCAO
	
	cQuery := "SELECT * "
	cQuery += " FROM " + RetSqlName('CN9') + " CN9"
	cQuery += " WHERE CN9.D_E_L_E_T_ <> '*'"
	cQuery += " AND CN9.CN9_SITUAC = '05'"	// Ativos
	cQuery += " AND CN9.CN9_XCONTR = '2'" //OBRAS
	
	// Acrescenta as datas no While
	For nA:= 1 To Len(aPrazosEx)
		If nA == 1
			cQuery += " AND ("
		Else
			cQuery += " OR"
		EndIf
		cQuery += " CN9.CN9_XFIMEX = '" + DtoS(Date() + Val(aPrazosEx[nA])) + "'"
		If nA == Len(aPrazosEx)
			cQuery += ")"
		EndIf
	Next nA
	
	cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())

	While TRB->(!EOF())
	
		aAdd(aCtEmail,{;
			TRB->CN9_NUMERO,;
			TRB->CN9_REVISA,;
			TRB->CN9_XFIMEX,;
			'E';	// Execução
		})
		
		TRB->(dbSkip())
	EndDo
	
	TRB->(dbCloseArea())
	
	
	For nB := 1 To Len(aCtEmail)
		
		// Controle e envio de e-mails para Grupo do DELI
		lEmailGrp := .F.
		
		cNrDias  := cValToChar(StoD(aCtEmail[nB][3]) - Date())			
		cNum	 := aCtEmail[nB][1]
		cRevisa	 := aCtEmail[nB][2]
		cTipo	 := aCtEmail[nB][4]
		
		cQuery2 := "SELECT SZP.ZP_NMUSR, SRA.RA_EMAIL"
		cQuery2 += " FROM " + RetSqlName('SZP') + " SZP"
		cQuery2 += " LEFT JOIN " + RetSqlName('SZI') + " SZI"
		cQuery2 += "     ON SZP.ZP_CDUSR = SZI.ZI_CODIGO"
		cQuery2 += "    AND SZI.D_E_L_E_T_ <> '*'"
		cQuery2 += " LEFT JOIN " + RetSqlName('SRA') + " SRA"
		cQuery2 += "     ON SRA.RA_CIC = SZI.ZI_NRDOC"
		cQuery2 += "    AND SRA.D_E_L_E_T_ <> '*'"
		cQuery2 += " WHERE SZP.D_E_L_E_T_ <> '*'"
		cQuery2 += " AND SZP.ZP_NRCONTR = '" + aCtEmail[nB][1] + "'"
		cQuery2 += " AND SZP.ZP_ATIVO = 'S'"
		
		If Select('TRB2') <> 0
			dbSelectArea('TRB2')
			TRB2->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),'TRB2',.F.,.F.)
		
		dbSelectArea('TRB2')
		
		While TRB2->(!EOF())
		
			If AllTrim(TRB2->RA_EMAIL) == ''
				TRB2->(dbSkip())
				Loop
			EndIf
			
			cEmail	 := AllTrim(TRB2->RA_EMAIL)
			
			// Envia E-mail
			WFCTV01(cNum, cRevisa, cEmail, cNrDias, cTipo)
			
			TRB2->(dbSkip())
		EndDo
		
		TRB2->(dbCloseArea())
		
		// Caso não tenha sido enviado ainda, envia e-mails para o Grupo do DELI
		If !lEmailGrp
			For nZ := 1 To Len(aEmails)
				// Envia E-mail
				WFCTV01(cNum, cRevisa, aEmails[nZ], cNrDias, cTipo)
			Next nZ
			lEmailGrp := .T.			
		EndIf			
					
	Next nB
	
	RESET ENVIRONMENT
	
	aParam := aSize(aParam,0)
	aParam := NIL

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! WFCTV01   ! Autor !Gilson Lima 		 ! Data ! 03/08/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Envio de Workflow para gestores, DELI e fiscais informando	 !
!			! vencto de contrato											 !
+----------------------------------------------------------------------------*/
Static Function WFCTV01(cNum, cRevisa, cEmail, cNrDias, cTipo)

	Local aArea		:= GetArea()
	Local oProcess
	Local cDirWF	:= ""
	Local aPrazos	:= {}
	Local cNrAviso := ''
	
	cMvAtt	:= GetMv("MV_WFHTML")
	
	//+----------------------------------------------------------------------------+
	//! Altera o parametro para o HTML ir no corpo no e-mail...                    !
	//+----------------------------------------------------------------------------+
	PutMv("MV_WFHTML","T")	
	
	If Empty(cDirWF)
		cDirWf := "\WORKFLOW\"
	Else
		If Right(cDirWF,1) <> "\"
			cDirWF += "\"
		Endif
	Endif
	
	dbSelectArea('CN9')
	CN9->(dbSetOrder(1))
	If CN9->(dbSeek(xFilial('CN9')+cNum+cRevisa))
	
		cFornec	:= AllTrim(CN9->CN9_XNMFOR)
		Do Case
			Case CN9->CN9_XCONTR =='1'
				cTpCtr := 'Prestação de Serviços'
			Case CN9->CN9_XCONTR =='2'
				cTpCtr := 'Obras e Serv. Engenharia'
			Case CN9->CN9_XCONTR =='3'
				cTpCtr := 'Compras'
			Otherwise
				cTpCtr := ''
		EndCase
		
		cOrigem	:= AllTrim(CN9->CN9_XAREAR)
		cCdObj	:= CN9->CN9_CODOBJ
		cDsObj	:= AllTrim(MSMM(CN9->CN9_CODOBJ))
		cDtAss	:= DtoC(CN9->CN9_DTASSI)
		cDtIniV	:= DtoC(CN9->CN9_DTINIC)
		cDtFimV	:= DtoC(CN9->CN9_DTFIM)
		cDtIniE	:= DtoC(CN9->CN9_XINIEX)
		cDtFimE	:= DtoC(CN9->CN9_XFIMEX)
		cVlGlob	:= TransForm(CN9->CN9_VLATU ,"@E 999,999,999.99")
		
		cFiscais  := RetPapel(1,cNum)
		cGestores := RetPapel(2,cNum)
		
		cDiasExt := AllTrim(Extenso(Val(cNrDias),.T.))
		
		aPrazos := IIf (cTipo == 'V', aPrazosVc, aPrazosEx)
		
		bSeek := {|x| x == cNrDias}
		nNrAviso := aScan(aPrazos,bSeek) // Posição em que encontra-se o Nr de dias.
		
		cNrAviso := "[Aviso: " + cValToChar(nNrAviso) + "/" + cValToChar(Len(aPrazos)) + "]"	
		
		cAssunto:= cNrAviso + " - CONTRATO NR. " + AllTrim(cNum) + " - " + cFornec 
	
	EndIf
	CN9->(dbCloseArea())

	// Crio o objeto oProcess, que recebe a inicialização da classe TWFProcess.
	// Repare que o primeiro Parâmetro é o código do processo cadastrado no configurador
	oProcess := TWFProcess():New("CT001",cAssunto)
	//oProcess := TWFProcess():New("CT999",cAssunto)
	
	//Informo o título do email.
	oProcess:cSubject := cAssunto
	
	// Crio uma task. Um Processo pode ter várias Tasks(tarefas). Para cada Task
	// informo um nome para ela e o HTML envolvido. Repare que o path do HTML é sempre abaixo do RootPath.
	// aqui usarei uma task para cada Email Enviado
	oProcess:NewTask("ENVIACT",cDirWF+"COHAPAR_WF_VENCTOCTR.HTML" )
	//oProcess:NewTask("ENVIAEM",cDirWF+"COHAPAR_WF_VENCTOCTR.HTML" )
		
	oProcess:cTo := cEmail
	//oProcess:cBCC := 'gilson.lima@totvs.com.br'                               
	
	//Impresssão dos dados 	de cabeçalho
	oProcess:oHtml:ValByName('cNrAviso' ,cNrAviso)                    
	oProcess:oHtml:ValByName('cNrCtr'	,cNum)
	oProcess:oHtml:ValByName('cFornec'	,cFornec)
	oProcess:oHtml:ValByName('cTpCtr'	,cTpCtr)	
	oProcess:oHtml:ValByName('cOrigem'	,cOrigem)
	oProcess:oHtml:ValByName('cDsObj'	,cDsObj)
	oProcess:oHtml:ValByName('cDtAss'	,cDtAss)
	oProcess:oHtml:ValByName('cDtIniV'	,cDtIniV)
	oProcess:oHtml:ValByName('cDtFimV'	,cDtFimV)	
	oProcess:oHtml:ValByName('cDtIniE'	,cDtIniE)
	oProcess:oHtml:ValByName('cDtFimE'	,cDtFimE)	
	oProcess:oHtml:ValByName('cVlGlob'	,cVlGlob)
	oProcess:oHtml:ValByName('cDias'	,cNrDias)
	oProcess:oHtml:ValByName('cDiasExt'	,cDiasExt)
	oProcess:oHtml:ValByName('cGestores',cGestores)
	oProcess:oHtml:ValByName('cFiscais'	,cFiscais)
	      	
	oProcess:Start()	
	
	oProcess:Free()
	oProcess:= Nil

	WFSendMail({"01","01"})	
	
	RestArea(aArea)

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! RetPapel  ! Autor !Gilson Lima 		 ! Data ! 17/08/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Retorna Nomes dos Gestores e Fiscais do Contrato				 !
!			! nTipo := 1  Fiscal / 2  Gestor								 !
+----------------------------------------------------------------------------*/
Static Function RetPapel(nTipo,cNum)

	Local aArea	 := GetArea()
	Local cNomes := ''
	Local nNomes := 0
	Local cTipo	 := StrZero(nTipo,2)
	
	cQuery := "SELECT SZP.ZP_NMUSR"
	cQuery += " FROM " + RetSqlName('SZP') + " SZP"
	cQuery += " WHERE SZP.D_E_L_E_T_ <> '*'"
	cQuery += " AND SZP.ZP_NRCONTR = '" + cNum + "'"
	cQuery += " AND SZP.ZP_ATIVO = 'S'"
	cQuery += " AND SZP.ZP_TPUSR = '" + cTipo + "'"
	cQuery += " ORDER BY SZP.ZP_NMUSR"
	
	If Select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRB',.F.,.F.)
	
	nReg := Contar("TRB","!EOF()")
		
	dbSelectArea('TRB')
	TRB->(dbGoTop())
	
	While TRB->(!EOF())
		nNomes++
		
		cNomes += AllTrim(TRB->ZP_NMUSR)
		
		If nNomes < nReg
			cNomes += "<BR />"
		EndIf	
		
		TRB->(dbSkip())
	EndDo
	
	TRB->(dbCloseArea())

	RestArea(aArea)

Return cNomes