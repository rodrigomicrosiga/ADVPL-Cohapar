/*
+------------------+------------------------------------------------------------------------------+
!                                        ATUALIZACOES                  				              !
+-------------------------------------------+---------------------+--------------------+----------+
!   Descricao detalhada da atualizacao      !Nome do              ! Analista           !Data da   !
!                                           !Solicitante          ! Respons.           !Atualiz.  !
+-------------------------------------------+---------------------+--------------------+----------+
!1 Inserção de quebra de linha, de tal forma!  Manolo             !  Kelson Martins    ! 19/02/14 !
! quando o funcionário registre mais que 3  !                     !                    !          !
! pares de marcações em um mesmo dia as     !                     !                    !          !
! mesma apareçam no relatório na linha      !                     !                    !          !
! seguinte									!                     !                    !          !
!2 - Inserção de numeração de páginas		!                     !                    !          !
!3 - Inserção de quebra de página			!                     !                    !          !
+-------------------------------------------+---------------------+--------------------+----------+
*/

#Include "rwmake.ch"
#Include "TOPCONN.CH"
#Include "PROTHEUS.CH"
////////////////////////////////////////////////
// PONESP    : Espelho do Ponto
// Exclusivo : COHAPAR
// Criacao   : CD - 05.11.08
///////////////////////////////////////////////
User Function PONESP2()

Private Titulo  := "Relatório de Frequencia"
Private cCabec  := Titulo
Private nLine   := 61
Private cDesc1  := "Este programa tem como objetivo imprimir o Espelho do Ponto"
Private cDesc2  := ""
Private cDesc3  := ""
Private cPict   := ""
Private nLin    := 80
Private imprime := .T.
Private Cabec1  := ""
Private Cabec1  := ""
Private Cabec2  := ""
Private cString := 'SRA' 	//-- Alias do arquivo principal (Base)
//
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private ntamanho     := "M"
Private nTipo        := 18
Private aReturn      := { "Normal", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private nomeprog     := "PONESP0"
Private wnrel        := "PONESP0"
private nQtMarc      := 0
Private lFerias := .F.
//
// montas as perguntas
//
AjustaSX1()
Private oDlg
Private cFile := SPACE(100)
Private cPerg := "PONESP"
Pergunte(cPerg,.F.)

//
// Monta a interface padrao
//


//wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,nTamanho)


If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif
//nTipo := If(aReturn[4]==1,15,18)
//
// Processamento (RPTSTATUS) monta janela com a regua de processamento
//
//RptStatus({|| RunCHpon(Cabec1,Cabec2,Titulo) },Titulo)
Processa({|| RunCHpon(Cabec1,Cabec2,Titulo)},"Processamento",Titulo)
Return


/////////////////////////////////////////////////////////////////////////
// função - Executa o Relatorio                                        //
/////////////////////////////////////////////////////////////////////////
Static Function RunCHPon(Cabec1,Cabec2,Titulo)
LOCAL lFechou := .F.
LOCAL lHrComps := .F.
nLine := 61
//
aDriver := ReadDriver()
dbSelectArea("SRA") // funcionario
dbSetOrder(1) 		// f + mat
dbSelectArea("SR6") // turno
dbSetOrder(1) 		// f + turno
dbSelectArea("SRJ") // funcao
dbSetOrder(1) 		// f + cod.funcao
dbSelectArea("CTT") // ccusto
dbSetOrder(1) 		// f + cod.cc
dbSelectArea("SPI") // banco de horas
//dbSetOrder(1) 		// f + mat + pd + dtos(data)
dbSetOrder(2) 		// f + mat + dtos(data) + pd
dbSelectArea("SP8") // Marcacoes
dbSetOrder(2) 		// f + mat + dtos(data) + str(hora,5,2)
dbSelectArea("SPC") // Apontamentos
dbSetOrder(1)       // f + mat + pd + dtos(data)
dbSelectArea("SP9") // Eventos
dbSetOrder(2) 		// f + idpon
dbSetOrder(1) 		// f + codigo (3)

DBSelectArea("SP3")
dbSetOrder(1)
DBSelectArea("SRW")
SRW->(DBSetOrder(4))//RW_FILIAL+RW_PROCESS+RW_ALIAS+RW_IDUSER
//
// Monta query
//
_sDtIni := DTOS(mv_par07)
_sDtFim := DTOS(mv_par08)

_cQuery := " SELECT DISTINCT P8_FILIAL,P8_MAT, P8_DATA, P8_HORA, P8_TPMARCA, P8_ORDEM, P8_PAPONTA "
_cQuery += " FROM SP8010 SP8 "
//_cQuery += "   LEFT JOIN SPC010 SPC "
//_cQuery += "         ON  PC_FILIAL BETWEEN '" + mv_par01  + "' AND '" + mv_par02   + "'"
//_cQuery += "         AND PC_MAT    BETWEEN '" + mv_par03  + "' AND '" + mv_par04   + "'"
//_cQuery += "         AND PC_CC     BETWEEN '" + mv_par05  + "' AND '" + mv_par06   + "'"
//_cQuery += "         AND PC_DATA   BETWEEN '" + _sDtIni   + "' AND '" + _sDtFim    + "'"
_cQuery += " INNER JOIN "+RetSQLName("SRA")+" SRA ON "
_cQuery += "         RA_FILIAL BETWEEN '" + mv_par01  + "' AND '" + mv_par02   + "'"
_cQuery += "         AND RA_MAT    BETWEEN '" + mv_par03  + "' AND '" + mv_par04   + "'"
_cQuery += "         AND RA_CC     BETWEEN '" + mv_par05  + "' AND '" + mv_par06   + "'"
_cQuery += "         AND SRA.D_E_L_E_T_ <> '*' "
_cQuery += " WHERE "
//" P8_MAT  = PC_MAT "
//_cQuery += "   AND P8_DATA = PC_DATA "
_cQuery += "         P8_FILIAL = SRA.RA_FILIAL "
_cQuery += "         AND P8_MAT = SRA.RA_MAT  "
_cQuery += "         AND P8_DATA   BETWEEN '" + _sDtIni   + "' AND '" + _sDtFim    + "'"
//_cQuery += "         AND P8_CC = SRA.RA_CC  "
_cQuery += "   AND P8_ORDEM <> '  ' "
_cQuery += "   AND SUBSTRING(P8_MOTIVRG,1,19) <> 'REJEICAO AUTOMATICA'  "
_cQuery += "   AND SUBSTRING(P8_MOTIVRG,1,46) <> 'DESCONSIDERAR MARCACAO REGISTRO EM DUPLICIDADE'  "
_cQuery += "   AND SP8.D_E_L_E_T_ <> '*' "
//_cQuery += "   AND SPC.D_E_L_E_T_ <> '*' "
_cQuery += "   ORDER BY P8_FILIAL,P8_MAT,P8_DATA,P8_HORA,P8_ORDEM,P8_TPMARCA "
TCQUERY _cQuery NEW ALIAS "QRY"
QRY->(DbGoTop())
	
//Quando nao localiza registros tenta imprimir como Ausente...
If QRY->(Eof())
	xCabec()
EndIf
__nCount := 0
QRY->(DBEVal({||__nCount++}))
ProcRegua(__nCount)

QRY->(DbGoTop())

Do While !QRY->(Eof())
	m_pag := 01
	SRA->(DBGoTop())
	SR6->(DBGoTop())
	SRJ->(DBGoTop())
	CTT->(DBGoTop())
	SRA->(dbSeek(QRY->(P8_FILIAL+P8_MAT)))
	SR6->(dbSeek(SRA->(RA_FILIAL+RA_TNOTRAB)))
	SRJ->(dbSeek(xFilial("SRJ") + SRA->RA_CODFUNC))
	CTT->(dbSeek(xFilial("CTT") + SRA->RA_CC))
	
	//Verifica as regras de relatorios...
	lSkip := .T.
	If SRW->(MSSeek(xFilial("SRW")+Padr("PONESP",TamSX3("RW_PROCESS")[01])+"SRA"+__CUSERID))
		lSkip:= !Empty(SRW->RW_FILREL).And.(&(SRW->RW_FILREL))
	EndIf
	
	If !lSkip
		QRY->(DBSkip())
		Loop
	EndIf
	
	_cMat       := QRY->P8_MAT
	_nTMinCC    := 0
	_nBHCredito := 0
	_nBHDebito  := 0
	_nHTotal    := 0
	_nTTHmes    := 0
	_nTTHH50    := 0
	_nTTHH100   := 0
	_nTTHJust   := 0
	
	SetPrc(0,0)
	@ 000,000 PSAY &(aDriver[1]) //,If(nTamanho=="G",aDriver[5],(If(aReturn[4]=1,aDriver[3],aDriver[4])))))
	
	
	//   @ PRow()  ,000 PSay Chr(15)
	@ PRow()+1,000 PSay "Companhia de Habitação do Paraná"
	@ PRow()  ,070 PSay "Página:" + ALLTRIM(STR(m_pag))
	@ PRow()+1,000 PSay "Rua Marechal Deodoro, 1133"
	@ PRow()+1,000 PSay "80.060-010 - Curitiba - PR"
	@ PRow()+1,000 PSay "C.G.C. 76.592.807/0001-22"
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay "RELATÓRIO DE FREQUÊNCIA"
	@ PRow()  ,050 PSay "PERÍODO " + DTOC(mv_par07) + " a " + DTOC(mv_par08)
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay "Empregado   : " + SRA->RA_NOME
	@ PRow()  ,055 PSay "Matricula : " + SRA->RA_MAT
	@ PRow()+1,000 PSay "Cargo       : " + SRJ->RJ_DESC
	@ PRow()  ,055 PSay "CTPS      : " + SRA->RA_NUMCP + "/" + SRA->RA_SERCP
	@ PRow()+1,000 PSay "Localização : " + AllTrim(CTT->CTT_DESC01)
	@ PRow()  ,055 PSay "Categoria : Mensalista"
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay PadC("Horários: " + SR6->R6_TURNO + " / " + AllTrim(SR6->R6_DESC),83)
	@ PRow()+1,000 PSay ".-----.-.------------------------------------.-----------------.-----.------------."
	@ PRow()+1,000 PSay "|     |S|                                    |    Horas/Dia    |Ausên| Bco.Horas  |"
	@ PRow()+1,000 PSay "| DIA |E|              MARCAÇÕES             |-----------------|     |------------|"
	@ PRow()+1,000 PSay "|     |M|                                    |H.Cal| 50% | 100%|Just.|Créd.|Débi. |"
	@ PRow()+1,000 PSay "|-----+-+------------------------------------+-----+-----+-----+-----+-----+------|"
	//                      |xx/xx| xxx | xx:xx xx:xx xx:xx xx:xx xx:xx xx:xx |xx:xx|xx:xx|xx:xx|xx:xx|xx:xx|xx:xx|
	//                       1      8     14    20    26    32    38    44     51    57    63    69    75    81        91      99
	//                      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	
	
	
	// Imprimi as marcaçoes do dia
	nCon:= 1

	Do While !QRY->(Eof()) .And. _cMat == QRY->P8_MAT
		
		
		IncProc("Imprimindo..."+QRY->(P8_FILIAL+P8_MAT) )
		_nPosIni   := 009//014
		_cDataMarc := QRY->P8_DATA
		_dDataMarc := STOD(QRY->P8_DATA)
		_cMat      := QRY->P8_MAT
		_cOrdem    := QRY->P8_ORDEM
		_cFilial   := QRY->P8_FILIAL
		_lFecha    := .F. // flag para fechar o quadro do ponto
		lHrComps := .F.
		
		//Tratamento para imprimir as marcacoes quando for sabado/domingo/feriados, para quando inicio da marcacao dia primeiro
		If nCon == 1 .And. Substr(_sDtIni,1,6) == Substr(_sDtFim,1,6)
			_dDataMarc := mv_par07
			Do While STOD(QRY->P8_DATA) > (_dDataMarc)
				fImprExc()
				_dDataMarc++
				
			EndDo
			
			//
			If _lFecha
				@ PRow()+1,000 PSay "'-----'-'-------------------------------------'-----'-----'-----'-----'-----'------'"
				lFechou	:= .T.
			EndIf
			//
		EndIf
		
		nCon++			//Alimenta variavel de controle de impressao
		//////////////////////////////////////////////////////////
		
		IF PRow() > 58
			@ PRow()+1,000 PSay "'-----'-'-------------------------------------'-----'-----'-----'-----'-----'-----'"		
			@ 000,000 PSay "" // pula pagina
			m_pag++
			impCab()			
			impCabMa()			
		ENDIF
		
		@ PRow()+1,000 PSay "|"  + Substr(QRY->P8_DATA,7,2) + "/" + Substr(QRY->P8_DATA,5,2)
		@ PRow()  ,005 PSay "|" + Subs(_fDiaSem(STOD(QRY->P8_DATA)),1,1) + "|"
		
		_nPosIni   := 009//014
		_cDataMarc := QRY->P8_DATA
		_dDataMarc := STOD(QRY->P8_DATA)
		_cMat      := QRY->P8_MAT
		_cOrdem    := QRY->P8_ORDEM
		_cFilial   := QRY->P8_FILIAL              
		_lFecha    := .F. // flag para fechar o quadro do ponto
		_cConQt := 1
		nQtMarc:= 0
		cMsg:= ""
		nLimMarc:= 3
		Do While !QRY->(Eof()) .And. _cMat == QRY->P8_MAT .And. _cOrdem == QRY->P8_ORDEM
			
			lFerias := .F.
			cMsg	:= _fPictHora(QRY->P8_HORA,2)
			//Quando eh férias e existe apontamento, insere FERIAS antes da marcacao.
			if nQtMarc==0 .And. yPonFer(_dDataMarc,1)
				cMsg	:= "FERIAS "				
				@ PRow()    ,_nPosIni PSay cMsg
				fechPipe() // Fecha os Pipes
				cMsg	:= _fPictHora(QRY->P8_HORA,2)
				@ PRow() + 1,000 PSay "|"  + Substr(QRY->P8_DATA,7,2) + "/" + Substr(QRY->P8_DATA,5,2)
				@ PRow()    ,005 PSay "|" + Subs(_fDiaSem(STOD(QRY->P8_DATA)),1,1) + "|"												
				lFerias := .T.
			EndIf 
			//Delimita quantidade de marcacoes a sere impressas.
			//If _cConQt <=nLimMarc
			
			IF _cConQt == 7
				fechPipe() // Fecha os Pipes
				_nPosIni   := 009							 
				@ PRow() + 1,000 PSay "|"  + Substr(QRY->P8_DATA,7,2) + "/" + Substr(QRY->P8_DATA,5,2)
				@ PRow()    ,005 PSay "|" + Subs(_fDiaSem(STOD(QRY->P8_DATA)),1,1) + "|"								
				@ PRow()    ,_nPosIni PSay cMsg // Picture("99:99")
				
				_cConQt := 1				
			ELSE
				@ PRow(),_nPosIni PSay cMsg // Picture("99:99")
			ENDIF	
				_cUltimaHora := QRY->P8_HORA
				_nPosIni     += 6
				//if nQtMarc==0 .And. yPonFer(_dDataMarc,1)
				//	_nPosIni+= 7
				//EndIf
				nQtMarc++
			//EndIf
			_cConQt++
			QRY->(DbSkip())
			_lFecha := ( _cMat != QRY->P8_MAT )
			_lFecha := iif(QRY->(Eof()),.T.,_lFecha)
		EndDo
		//nQtMarc:= 2
		// soma os apontamentos com resultado do total de horas trabalhadas no dia

		if Select("Z0A") > 0
		Endif
		// Tabela customizada de Eventos x Porcentagem
		dbSelectArea("Z0A")
		Z0A->(dbSetOrder(1))
				
		_nHCalc := 0
		_nHDebi := 0
		_nHrsDia:= 0
		SPC->(dbSetOrder(2))       // f + mat + dtos(data)
		SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + _cDataMarc))
		
		dbSelectArea("SPI")
		SPI->(dbSetOrder(1))
		
		Do While !SPC->(Eof()) .And. SRA->RA_MAT == _cMat .And. SPC->PC_DATA == _dDataMarc
			_cCodPD := IIf(!Empty(SPC->PC_PDI),SPC->PC_PDI   ,SPC->PC_PD)
			_nHorPD := IIf(!Empty(SPC->PC_PDI),SPC->PC_QUANTI,SPC->PC_QUANTC)
			SP9->(dbSeek(xFilial("SP9") + _cCodPD))
			If !SP9->P9_IDPON $ "030A 031A" // intervalo nao conta
				If SP9->P9_TIPOCOD == "1" .Or. !EMPTY(SPC->PC_ABONO) // credito
					If EMPTY(SPC->PC_ABONO)//alterado
						_nHrsDia    += _fHorMin(_nHorPD)
						_nHcalc     += _fHorMin(_nHorPD)
					Else // Se houver abono
						// Se houver diferença entre o faltante e o abonado, desconta do BH
						nHrDesc := _fHorMin(_nHorPD) - _fHorMin(SPC->PC_QTABONO)
						_nHDebi += nHrDesc
						_nBHDebito += IIf(SP9->P9_BHORAS = "S",nHrDesc,0)
					EndIf
					If (_cCodPD $ "901/902")//Somente é credito de BH quando o Codigo for 901/902
						//_nBHCredito += IIf(SP9->P9_BHORAS = "S",_fHorMin(_nHorPD),0)
						/*
						// Alteracao para utilizar horas valorizadas
						If ( SPI->(dbSeek(xFilial("SPI") + _cMat + _cCodPD + DTOS(_dDataMarc) )) )
							_nBHCredito += IIf(SP9->P9_BHORAS = "S",_fHorMin(SPI->PI_QUANTV),0)
						EndIf
						*/
						// Alteracao para utilizar horas valorizadas
						if Z0A->(dbSeek(xFilial("Z0A") + _cCodPD))
							_nBHCredito += _fHorMin(_nHorPD) * (1 + Z0A->Z0A_PERCENT/100)
						else
							_nBHCredito += IIf(SP9->P9_BHORAS = "S",_fHorMin(_nHorPD),0) 
						endif				
					EndIf
				Else
//					_nHcalc    -= _fHorMin(_nHorPD)
					//					If nQtMarc == 1 .Or. nQtMarc == 3 .Or. nQtMarc == 5
					//					Else
					_nBHDebito += IIf(SP9->P9_BHORAS = "S",_fHorMin(_nHorPD),0)
					//					EndIf
					
					If (_cCodPD == "850")
						lHrComps := .T.
					EndIf
					
					_nHDebi    += _fHorMin(_nHorPD)
					if(_cCodPD == "992")//quando horario de almoco diminui das horas
						_nHrsDia -= _fHorMin(_nHorPD)
					EndIf
				Endif
			Endif
			SPC->(DbSkip())
		EndDo
		//		If nQtMarc == 1 .Or. nQtMarc == 3 .Or. nQtMarc == 5
		//		eLSE
		_nTTHMes += _nHCalc
		//		EndIf
		//_nHrsDia:= _nHcalc
		@ PRow(),044 PSay "|"
		If _nHrsDia > 0
			//Solicitado pelo cliente nao mostrar o valor de horas quando houver marcacoes incorretas...
			//		    If nQtMarc == 1 .Or. nQtMarc == 3 .Or. nQtMarc == 5
			//				@ PRow(),045 PSay ""
			//		    Else
			
			@ PRow(),045 PSay _fPictHora(_fMinHor(_nHrsDia),2) //  Picture("@E 99.99")
			//			EndIf
		EndIf
		
		// procura HH 50% autorizada = 801
		@ PRow(),050 PSay "|"
		SPC->(dbSetOrder(1))       // f + mat + pd + dtos(data)
		SPC->(DBGoTop())
		If SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "001" + _cDataMarc)) .OR.;
			SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "019" + _cDataMarc)) .OR.; 
			SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "021" + _cDataMarc)) .OR.;
			SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "022" + _cDataMarc)) //Hora extra nao autorizada
			If SPC->PC_PDI == "801" // se foi autorizada
				/*
				// Alteracao para utilizar horas valorizadas
				If ( SPI->(dbSeek(xFilial("SPI") + SRA->RA_MAT + "801" + DTOS(_dDataMarc) )) )
					@ PRow(),051 PSay _fPictHora(SPI->PI_QUANTV,2) //  Picture("@E 99.99")
					_nTTHH50 += _fHorMin(SPI->PI_QUANTV)
				EndIf
				*/
				@ PRow(),051 PSay _fPictHora(SPC->PC_QUANTI,2) //  Picture("@E 99.99")
				_nTTHH50 += _fHorMin(SPC->PC_QUANTI)
			EndIf

		ElseIf SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "801" + _cDataMarc))//Hora extra Autorizada
			/*
				// Alteracao para utilizar horas valorizadas
				If ( SPI->(dbSeek(xFilial("SPI") + SRA->RA_MAT + "801" + DTOS(_dDataMarc) )) )
					@ PRow(),051 PSay _fPictHora(SPI->PI_QUANTV,2) //  Picture("@E 99.99")
					_nTTHH50 += _fHorMin(SPI->PI_QUANTV)
				EndIf
			*/
			@ PRow(),051 PSay _fPictHora(SPC->PC_QUANTC,2) //  Picture("@E 99.99")
			_nTTHH50 += _fHorMin(SPC->PC_QUANTC)
		EndIf
		
		
		// procura HH 100% autorizada = 902
		
		@ PRow(),056 PSay "|"
		SPC->(DBGoTop())
		If SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "002" + _cDataMarc)) .or.;
			SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "020" + _cDataMarc)) .or.;
			SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "023" + _cDataMarc)) .or.; 
			SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "024" + _cDataMarc)) //HORA EXTRA NAO AUTORIZADA BUSCA POR AUTORIZACAO
			If SPC->PC_PDI == "801" // se foi autorizada
				// Alteracao para utilizar horas valorizadas
				/*
				If ( SPI->(dbSeek(xFilial("SPI") + SRA->RA_MAT + "902" + DTOS(_dDataMarc) )) )
					@ PRow(),057 PSay _fPictHora(SPI->PI_QUANTV,2) //  Picture("@E 99.99")
					_nTTHH100 += _fHorMin(SPI->PI_QUANTV)
				EndIf
				*/
				@ PRow(),057 PSay _fPictHora(SPC->PC_QUANTI,2) //  Picture("@E 99.99")
				_nTTHH100 += _fHorMin(SPC->PC_QUANTI)
			EndIf
		ElseIf SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "902" + _cDataMarc)) // HORA EXTRA AUTORIZADA
			// Alteracao para utilizar horas valorizadas
			/*
			If ( SPI->(dbSeek(xFilial("SPI") + SRA->RA_MAT + "902" + DTOS(_dDataMarc) )) )
				@ PRow(),057 PSay _fPictHora(SPI->PI_QUANTV,2) //  Picture("@E 99.99")
				_nTTHH100 += _fHorMin(SPI->PI_QUANTV)
			EndIf
			*/
			@ PRow(),057 PSay _fPictHora(SPC->PC_QUANTC,2) //  Picture("@E 99.99")
			_nTTHH100 += _fHorMin(SPC->PC_QUANTC)
			//		Else
			//			@ PRow(),057 PSay _fPictHora(SPC->PC_QUANTC,2) // Picture("@E 99.99")
			//			_nTTHH100 += _fHorMin(SPC->PC_QUANTC)
		Endif
		
		// soma as faltas e atrasos justificados
		
		@ PRow(),062 PSay "|"
		_nHCalc := 0
		SPC->(dbSetOrder(2))       // f + mat + dtos(data)
		SPC->(DBGoTop())
		SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + _cDataMarc))
		Do While !SPC->(Eof()) .And. SRA->RA_MAT == _cMat .And. SPC->PC_DATA == _dDataMarc
			If !EMPTY(SPC->PC_ABONO)
				_nHCalc += _fHorMin(SPC->PC_QTABONO)
			Endif
			SPC->(DbSkip())
		EndDo
		_nTTHJust += _nHCalc
		If _nHCalc > 0
			@ PRow(),063 PSay _fPictHora(_fMinHor(_nHCalc),2) // Picture("@E 99.99")
		Endif
		
		// imprime créditos de banco
		@ PRow(),068 PSay "|"
		SPC->(dbSetOrder(1))       // f + mat + pd + dtos(data)
		/*
		SPC->(DBGoTop())
		lSCred:= .F.
		// Lista de codigos de HE nao autorizadas
		cListHENA := "001/002/019/020/021/023/024/801/802/901/902" 
		SPC->(dbSetOrder(2))
		SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + _cDataMarc))
		while !SPC->(eof()) .and. SPC->PC_DATA == _dDataMarc
			if SPC->PC_PD $ cListHENA
				lSCred := .t.
				exit
			endif
			SPC->(dbSkip())
		enddo
		*/
		//Alterado pois entrou tambem o codigo 019,020,021 alem do 001 para HE.
		If !(lSCred := SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "001" + _cDataMarc)))
			If !(lSCred := SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "002" + _cDataMarc)))
				If!(lSCred := SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "019" + _cDataMarc)))
					If !(lSCred := SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "020" + _cDataMarc)))
						lSCred := SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "021" + _cDataMarc))
					EndIf
				EndIf
			EndIf
		EndIf
		
		If lSCred//SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "001" + _cDataMarc))
			If SPC->PC_PDI $ "901/902" // se foi autorizada para o banco
				// Alteracao para utilizar horas valorizadas (calcula as horas de forma customizada
				nValHora := SPC->PC_QUANTI
				if Z0A->(dbSeek(xFilial("Z0A") + SPC->PC_PDI))
					nValHora := _fMinHor( _fHorMin(SPC->PC_QUANTI) * (1 + Z0A->Z0A_PERCENT/100) ) 
				endif
				@ PRow(),069 PSay _fPictHora(nValHora,2) // Picture("99.99")
			Else
				If SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "901" + _cDataMarc)) .OR. SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "902" + _cDataMarc))
					// Alteracao para utilizar horas valorizadas
					nValHora := SPC->PC_QUANTI
					if Z0A->(dbSeek(xFilial("Z0A") + SPC->PC_PDI))
						nValHora := _fMinHor( _fHorMin(SPC->PC_QUANTI) * (1 + Z0A->Z0A_PERCENT/100) ) 
					endif
					@ PRow(),069 PSay _fPictHora(nValHora,2) // Picture("99.99")			
				EndIf
			EndIf
		EndIf
		
		// imprime DEBITOS do B.H.
		@ PRow(),074 PSay "|"
		If _nHDebi > 0
			
			//		    If nQtMarc == 1 .Or. nQtMarc == 3 .Or. nQtMarc == 5
			//				@ PRow(),075 PSay ""
			//		    Else
			@ PRow(),075 PSay _fPictHora(_fMinHor(_nHDebi),2) + IIF(lHrComps, "*", " ") // Picture("99.99")
			//			EndIf
		EndIf
		@ PRow(),081 PSay "|"
		
		If _lFecha .And. (_dDataMarc + 1) > mv_par08
			@ PRow()+1,000 PSay "'-----'-'------------------------------------'-----'-----'-----'-----'-----'------'"
		Else
			
			//---------------------------------------------------------------------------------------------------------
			// verifica S.B.F. ou se chegou no final do mes SEM marcaçoes
			//---------------------------------------------------------------------------------------------------------
			_cFiltro1 := "STOD(QRY->P8_DATA) > (_dDataMarc + 1)"
			_cFiltro2 := "STOD(QRY->P8_DATA) >=(_dDataMarc + 2)"
			
			If _lFecha .And. (_dDataMarc + 1) < mv_par08
				_cFiltro1 := "(_dDataMarc + 1) < mv_par08"
				_cFiltro2 := "_dDataMarc       < mv_par08"
			EndIf
			//
			If &_cFiltro1
				Do While &_cFiltro2 // STOD(QRY->P8_DATA) >= _dDataMarc + 2
					_dDataMarc++
					fImprExc()
					
				EndDo
				//
				If _lFecha
					@ PRow()+1,000 PSay "'-----'-'------------------------------------'-----'-----'-----'-----'-----'------'"
					lFechou	:= .T.
				EndIf
				//
			EndIf
			
			
			/*
			
			
			// verifica S.B.F.
			If STOD(QRY->P8_DATA) > (_dDataMarc + 1)
			Do While STOD(QRY->P8_DATA) >= _dDataMarc + 2
			_dDataMarc++
			SP3->(dbSeek(xFilial("SP3") + _cDataMarc ))
			@ PRow()+1,000 PSay "|"  + Substr(DTOS(_dDataMarc),7,2) + "/" + Substr(DTOS(_dDataMarc),5,2)
			@ PRow()  ,005 PSay "|" + subs(_fDiaSem(_dDataMarc),1,1) + "| " + SP3->P3_DESC
			@ PRow()  ,045 PSay "|     |     |     |     |     |     |"
			//               @ PRow()+1,000 PSay "|-----+-----+-------------------------------------+-----+-----+-----+-----+-----+-----|"
			EndDo
			EndIf
			
			
			// QRY->(DbSkip()) - nao preciso pois ja farre no inicio do loop
			*/
		EndIf
	EndDO
	lFechou	:= .T.
	//Tratamento para imprimir as marcacoes quando for sabado/domingo/feriados, para quando ultimo dia do mes eh final de semana...
	If  Substr(_sDtIni,1,6) == Substr(_sDtFim,1,6)
		Do While mv_par08 > (_dDataMarc)
			lFechou	:= .F.
			_dDataMarc++
			fImprExc()
		EndDo
		//
		If _lFecha .And. !lFechou
			@ PRow()+1,000 PSay "'-----'-'------------------------------------'-----'-----'-----'-----'-----'------'"
			lFechou	:= .T.
		EndIf
		//				@ PRow()+1,000 PSay "|-----+-----+-------------------------------------+-----+-----+-----+-----+-----+-----|"
	EndIf
	lFechou	:= .F.
	
	
	// saldo anterior do BH --- rever codigo para SQL !!!
	
	_nBHSalAnt := 0
	SPI->(dbSetOrder(2)) 		// f + mat + dtos(data) + pd
	SPI->(DBGoTop())
	SPI->(dbSeek(SRA->(RA_FILIAL+RA_MAT) )) //  + DTOS(mv_par07) ) )
	SP9->(DBsetOrder(01))
	SP9->(DBGoTop())
	Do While !SPI->(Eof()) .AND. SPI->PI_FILIAL == SRA->RA_FILIAL .And. SPI->PI_MAT == SRA->RA_MAT .And. SPI->PI_DATA < mv_par07
		SP9->(dbSeek(xFilial("SP9") + SPI->PI_PD))
		If SPI->PI_STATUS <> 'B'
		If SP9->P9_TIPOCOD = "1" // credito
			_nBHSalAnt += _fHorMin(SPI->PI_QUANTV)
		Else
			_nBHSalAnt -= _fHorMin(SPI->PI_QUANTV)
		Endif                   
		ENDIF
		SPI->(DbSkip())
	EndDo

	If Prow() > 53
		@ 000,000 PSay "" // pula pagina
		m_pag++
		impCab()
	Endif         
	
	@ PRow()+1,000 		PSay "Resumo das Ocorrencias"
	@ PRow()  ,053 		PSay "Banco de Horas"
	@ PRow()+1,000      	PSay "Horas Calculadas  : "
	@ PRow()  ,PCol()+1 	PSay _fPictHora(_fMinHor(_nTTHMes),4)								 //Picture("99.99")
	@ PRow()  ,053 		PSay "Saldo Anterior  : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHSalAnt),4)                            //Picture("99.99")
	@ PRow()+1,000 		PSay "Horas Extras  50% : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nTTHH50),4)								 //Picture("99.99")
	@ PRow()  ,053 		PSay "Crédito         : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHCredito),4) 						 	 //Picture("99.99")
	@ PRow()+1,000 		PSay "Horas Extras 100% : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nTTHH100),4) 							 //Picture("99.99")
	@ PRow()  ,053 		PSay "Débito          : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHDebito),4) 							 //Picture("99.99")
	@ PRow()+1,000 		PSay "Horas Justificada : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nTTHJust),4) 							 //Picture("99.99")
	@ PRow()  ,053       PSay "Saldo Atual     : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHSalAnt + _nBHCredito - _nBHDebito),4) //Picture("99.99")
	
	@ PRow()+1,000 PSay ".---------------------------------------------------------------------------------."
	@ PRow()+1,000 PSay "|Obs:                                                                             |"
	@ PRow()+1,000 PSay "|Legenda: * = Compensação de Banco de Horas.                                      |"
	@ PRow()+1,000 PSay "'---------------------------------------------------------------------------------'"
	
	@ PRow()+1,000 PSay "Confirmo as informações acima."
	
	@ PRow()+2,000 PSay Replicate("_",30) + Space(21) + Replicate("_",30)
	@ PRow()+1,000 PSay "Assinatura do Empregado"
	@ PRow()  ,051 PSay "Assinatura da Gerência"
	@ PRow()+2,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay ProcName(6) + " -  " + DTOC(dDataBase) + " - " + Time()
	@ PRow()+1,000 PSay Replicate("-",83)
	
	@ 000,000 PSay "" // pula pagina
	m_pag++
	// procura outra MAT
EndDo
//
// Fecha os temporarios
//
DbSelectArea("QRY")
QRY->(DbCloseArea())
//
// Se em disco, chama o spoll
//
SET DEVICE TO SCREEN
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return()



/////////////////////////////////////////////////////////////////////////
// função - Pergunta no SX1                                            //
/////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1()
dbSelectArea("SX1")
dbSetOrder(1)
_aReg   := {}
AADD(_aReg,{"PONESP    ","01","Filial De        ","Filial De        ","Filial De        ","mv_ch1","C",2,0,0,"G","NaoVazio","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(_aReg,{"PONESP    ","02","Filial Ate       ","Filial Ate       ","Filial Ate       ","mv_ch2","C",2,0,0,"G","NaoVazio","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(_aReg,{"PONESP    ","03","Matricula De     ","Matricula De     ","Matricula De     ","mv_ch3","C",6,0,0,"G","NaoVazio","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA","","","","",""})
AADD(_aReg,{"PONESP    ","04","Matricula Ate    ","Matricula Ate    ","Matricula Ate    ","mv_ch4","C",6,0,0,"G","NaoVazio","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA","","","","",""})
AADD(_aReg,{"PONESP    ","05","Centro Custo De  ","Centro Custo De  ","Centro Custo De  ","mv_ch5","C",12,0,0,"G","NaoVazio","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SI3","","","","",""})
AADD(_aReg,{"PONESP    ","06","Centro Custo Ate ","Centro Custo Ate ","Centro Custo Ate ","mv_ch6","C",12,0,0,"G","NaoVazio","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SI3","","","","",""})
AADD(_aReg,{"PONESP    ","07","Data De          ","Data De          ","Data De          ","mv_ch7","D",8,0,0,"G","NaoVazio","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(_aReg,{"PONESP    ","08","Data Ate         ","Data Ate         ","Data Ate         ","mv_ch8","D",8,0,0,"G","NaoVazio","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
For _nLin := 1 to Len(_aReg)
	If !dbSeek(_aReg[_nLin,1] + _aReg[_nLin,2])
		RecLock("SX1",.T.)
		For _nCol := 1 to FCount()
			FieldPut(_nCol,_aReg[_nLin,_nCol])
		Next
		MsUnlock()
		_lFlagAj := .T.   // flag de ajuste
	Endif
Next
Return


////////////////////////////////////////////////////////////////////////////
// funcão - Dia da Semana
// retorna o dia da semana
////////////////////////////////////////////////////////////////////////////
Static Function _fDiaSem(_dData)
Do Case
	Case DOW(_dData) == 1
		Return "DOM"
	Case DOW(_dData) == 2
		Return "SEG"
	Case DOW(_dData) == 3
		Return "TER"
	Case DOW(_dData) == 4
		Return "QUA"
	Case DOW(_dData) == 5
		Return "QUI"
	Case DOW(_dData) == 6
		Return "SEX"
	Case DOW(_dData) == 7
		Return "SAB"
EndCase
Return "***"


////////////////////////////////////////////////////////////////////////////
// funcão - Horas em Minutos
// retorna a quantidade de minutos em um determinado numero
////////////////////////////////////////////////////////////////////////////
Static Function _fHorMin(_nValor)
Return (Int(_nValor) * 60) + ( (_nValor - Int(_nValor)) * 100)


////////////////////////////////////////////////////////////////////////////
// funcão - Minutos para Horas
// retorna a quantidade de horas a partir de um numero de minutos
////////////////////////////////////////////////////////////////////////////
Static Function _fMinHor(_nValor)
Return ( Int(_nValor / 60) + ( ((_nValor / 60) - Int(_nValor / 60)) * .60 ) )


////////////////////////////////////////////////////////////////////////////
// funcão - Picture para Hora
// retorna a hora formatada
////////////////////////////////////////////////////////////////////////////
Static Function _fPictHora(_nValor,_nCasas)
_cRet := StrZero(_nValor,_nCasas+3,2)
_cRet := SubStr(_cRet,1,_nCasas) + ":" + SubStr(_cRet,_nCasas+2,2)
Return _cRet

//Verifica se a data eh ferias...
Static Function yPonFer(dDtFer,NTp)

LOCAL cQuery := ""
LOCAL lRet   := .F.
DEFAULT NTp  := 1
//NTp  := 0

if NTp == 1
	cQuery := " SELECT COUNT(1) AS QTDE FROM "+RetSQLName("SR8")
	cQuery += " WHERE "
	cQuery += " R8_FILIAL = '"+SRA->RA_FILIAL+"' AND "
	cQuery += " R8_MAT = '"+SRA->RA_MAT+"' AND "
	cQuery += " R8_TIPO = 'F' AND "
	cQuery += " '"+DToS(dDtFer)+"' >= R8_DATAINI AND '"+DToS(dDtFer)+"' <= R8_DATAFIM AND "
	cQuery += " D_E_L_E_T_ <> '*' "
	If Select("TRBSR8") <> 0
		DBSelectArea("TRBSR8")
		TRBSR8->(DBCloseArea())
	EndIf
	TCQuery cQuery New Alias "TRBSR8"
	
	TRBSR8->(DBGoTop())
	If !TRBSR8->(Eof())
		lRet:= TRBSR8->QTDE > 0
	EndIf
EndIf
/*
//Valida se existe Excessao cadastrada referente a ferias...
If !lRet
	
	cQuery := " SELECT COUNT(1) AS QTDE FROM "+RetSQLName("SP2")
	cQuery += " WHERE "
	cQuery += " P2_FILIAL = '"+SRA->RA_FILIAL+"' AND "
	cQuery += " P2_MAT = '"+SRA->RA_MAT+"' AND "
	cQuery += " P2_YFER = '1' AND " //Campo criado para informar se eh sim/nao
	cQuery += " '"+DToS(dDtFer)+"' >= P2_DATA AND '"+DToS(dDtFer)+"' <= P2_DATAATE AND "
	cQuery += " D_E_L_E_T_ <> '*' "
	If Select("TRBSR8") <> 0
		DBSelectArea("TRBSR8")
		TRBSR8->(DBCloseArea())
	EndIf
	TCQuery cQuery New Alias "TRBSR8"
	lRet := .F.
	TRBSR8->(DBGoTop())
	If !TRBSR8->(Eof())
		lRet:= TRBSR8->QTDE > 0
	EndIf
	
	If Select("TRBSR8") <> 0
		DBSelectArea("TRBSR8")
		TRBSR8->(DBCloseArea())
	EndIf
	
EndIf
*/
Return lRet

//Localiza Afastamentos ou Excessoes
Static Function yfAfast(dDtExces)

LOCAL cQuery := ""
LOCAL cRet   := ""

DBselectArea("SX5")
SX5->(DBSetOrder(01))
SX5->(DBGoTop())

//Localiza por afastamentos
cQuery := " SELECT R8_TIPO FROM "+RetSQLName("SR8")
cQuery += " WHERE "
cQuery += " R8_FILIAL = '"+SRA->RA_FILIAL+"' AND "
cQuery += " R8_MAT = '"+SRA->RA_MAT+"' AND "
cQuery += " R8_TIPO <> 'F' AND "
cQuery += " '"+DToS(dDtExces)+"' >= R8_DATAINI AND ('"+DToS(dDtExces)+"' <= R8_DATAFIM OR RTRIM(LTRIM(R8_DATAFIM))= '' ) AND "
cQuery += " D_E_L_E_T_ <> '*' "
If Select("TRBSR8") <> 0
	DBSelectArea("TRBSR8")
	TRBSR8->(DBCloseArea())
EndIf
TCQuery cQuery New Alias "TRBSR8"

TRBSR8->(DBGoTop())
If !TRBSR8->(Eof())
	If SX5->(MSSeek(xFilial("SX5")+"30"+TRBSR8->R8_TIPO))
		cRet := AllTrim(Subs(SX5->X5_DESCRI,1,35))
	EndIf
EndIf

//Localiza por Excessoes ocorridas no periodo...
If Empty(cRet)
	
	cQuery := " SELECT P2_MOTIVO FROM "+RetSQLName("SP2")
	cQuery += " WHERE "
	cQuery += " P2_FILIAL = '"+SRA->RA_FILIAL+"' AND "
	cQuery += "("
	cQuery += " P2_MAT = '"+SRA->RA_MAT+"' OR (P2_CC = '"+SRA->RA_CC+"' AND P2_MAT = '"+Space(TamSX3("RA_MAT")[01])+"' ) "
	cQuery += ") AND "
	cQuery += " '"+DToS(dDtExces)+"' >= P2_DATA AND '"+DToS(dDtExces)+"' <= P2_DATAATE AND "
	cQuery += " D_E_L_E_T_ <> '*' "
	If Select("TRBSR8") <> 0
		DBSelectArea("TRBSR8")
		TRBSR8->(DBCloseArea())
	EndIf
	TCQuery cQuery New Alias "TRBSR8"
	
	TRBSR8->(DBGoTop())
	If !TRBSR8->(Eof())
		cRet := AllTrim(TRBSR8->P2_MOTIVO)
	EndIf
EndIf

If Select("TRBSR8") <> 0
	DBSelectArea("TRBSR8")
	TRBSR8->(DBCloseArea())
EndIf

Return cRet

//Imprime o cabecalho para o relatorio...
Static Function xCabec()
LOCAL cMtAfas := ""
Local lHrComps := .F.
DBSelectArea("SRA")
DBGoTop()
SET FILTER TO (RA_FILIAL >= MV_PAR01 .AND. RA_FILIAL <= MV_PAR02 .AND. RA_MAT >= MV_PAR03 .AND. RA_MAT <= MV_PAR04 .AND. RA_CC >= mv_par05  .AND. RA_CC <=  mv_par06)
DBGoTop()

Do While !SRA->(EOF())
	
	SR6->(DBGoTop())
	SRJ->(DBGoTop())
	CTT->(DBGoTop())
	SR6->(dbSeek(SRA->(RA_FILIAL+RA_TNOTRAB)))
	SRJ->(dbSeek(xFilial("SRJ") + SRA->RA_CODFUNC))
	CTT->(dbSeek(xFilial("CTT") + SRA->RA_CC))
	
	//Verifica as regras de relatorios...
	lSkip := .T.
	If SRW->(MSSeek(xFilial("SRW")+Padr("PONESP",TamSX3("RW_PROCESS")[01])+"SRA"+__CUSERID))
		lSkip:= !Empty(SRW->RW_FILREL).And.(&(SRW->RW_FILREL))
	EndIf
	
	If !lSkip
		SRA->(DBSkip())
		loop
	EndIf
	
	_cMat       := SRA->RA_MAT
	_nTMinCC    := 0
	_nBHCredito := 0
	_nBHDebito  := 0
	_nHTotal    := 0
	_nTTHmes    := 0
	_nTTHH50    := 0
	_nTTHH100   := 0
	_nTTHJust   := 0
	lHrComps := .F.
	
	SetPrc(0,0)
	@ 000,000 PSAY &(aDriver[1]) //,If(nTamanho=="G",aDriver[5],(If(aReturn[4]=1,aDriver[3],aDriver[4])))))
	
	
	//   @ PRow()  ,000 PSay Chr(15)
	@ PRow()+1,000 PSay "Companhia de Habitação do Paraná"
	@ PRow()+1,000 PSay "Rua Marechal Deodoro, 1133"
	@ PRow()+1,000 PSay "80.060-010 - Curitiba - PR"
	@ PRow()+1,000 PSay "C.G.C. 76.592.807/0001-22"
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay "RELATÓRIO DE FREQUÊNCIA"
	@ PRow()  ,050 PSay "PERÍODO " + DTOC(mv_par07) + " a " + DTOC(mv_par08)
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay "Empregado   : " + SRA->RA_NOME
	@ PRow()  ,055 PSay "Matricula : " + SRA->RA_MAT
	@ PRow()+1,000 PSay "Cargo       : " + SRJ->RJ_DESC
	@ PRow()  ,055 PSay "CTPS      : " + SRA->RA_NUMCP + "/" + SRA->RA_SERCP
	@ PRow()+1,000 PSay "Localização : " + AllTrim(CTT->CTT_DESC01)
	@ PRow()  ,055 PSay "Categoria : Mensalista"
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay PadC("Horários: " + SR6->R6_TURNO + " / " + AllTrim(SR6->R6_DESC),83)
	@ PRow()+1,000 PSay ".-----.-.------------------------------------.-----------------.-----.------------."
	@ PRow()+1,000 PSay "|     |S|                                    |    Horas/Dia    |Ausên| Bco.Horas  |"
	@ PRow()+1,000 PSay "| DIA |E|              MARCAÇÕES             |-----------------|     |------------|"
	@ PRow()+1,000 PSay "|     |M|                                    |H.Cal| 50% | 100%|Just.|Créd.|Débi. |"
	@ PRow()+1,000 PSay "|-----+-+------------------------------------+-----+-----+-----+-----+-----+------|"
	//                      |xx/xx| xxx | xx:xx xx:xx xx:xx xx:xx xx:xx xx:xx |xx:xx|xx:xx|xx:xx|xx:xx|xx:xx|xx:xx|
	//                       1      8     14    20    26    32    38    44     51    57    63    69    75    81        91      99
	//                      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	
	
	
	//Tratamento para imprimir as marcacoes quando for sabado/domingo/feriados, para quando inicio da marcacao dia primeiro
	If Substr(_sDtIni,1,6) == Substr(_sDtFim,1,6)
		_dDataMarc := mv_par07
		Do While mv_par08 >= (_dDataMarc)
			
			@ PRow()+1,000 PSay "|"  + Substr(DTOS(_dDataMarc),7,2) + "/" + Substr(DTOS(_dDataMarc),5,2)
			@ PRow()  ,005 PSay "|" + SubStr(_fDiaSem(_dDataMarc),1,1) + "| " // + AllTrim(SP3->P3_DESC)
			//---------------------------------------------------------------------------------------------------------
			// feriados
			//---------------------------------------------------------------------------------------------------------
			lFeriado := .F.
			lHrComps := .F.
			SP3->(DBSetOrder(01))
			If !(lFeriado:= SP3->(dbSeek(xFilial("SP3") + DTOS(_dDataMarc))))
				SP3->(DBSetOrder(02))
				lFeriado:= SP3->(dbSeek(xFilial("SP3") + Subs(DTOS(_dDataMarc),5,4)))
			EndIf
			cMtAfas:= ""
			If yPonFer(_dDataMarc)
				@ PRow(),009 PSay "FERIAS"
				@ PRow(),044 PSay "|     |     |     |     |     |      |"
				// feriado
			ElseIf lFeriado
				@ PRow(),009 PSay AllTrim(SP3->P3_DESC)
				@ PRow(),044 PSay "|     |     |     |     |     |      |"
			ElseIf !Empty((cMtAfas:=yfAfast(_dDataMarc))) //Localiza por afastamentos
				@ PRow(),009 PSay cMtAfas
				@ PRow(),044 PSay "|     |     |     |     |     |      |"
			Else
				//---------------------------------------------------------------------------------------------------------
				// faltas
				//---------------------------------------------------------------------------------------------------------
				SPC->(dbSetOrder(1))       // f + mat + pd + dtos(data) //+ PC->PC_PDI ==" "
				If SPC->(dbSeek(SRA->(RA_FILIAL+RA_MAT) + "905" + DTOS(_dDataMarc)) )// .And.SPC->PC_PDI <>"850"
					cMtAbono:= "Ausente"
					If !EMPTY(SPC->PC_ABONO)
						cMtAbono:= alltrim(POSICIONE("SP6",01,xFilial("SP6")+SPC->PC_ABONO,"P6_DESC"))
					EndIf
					//@ PRow(),009 PSay cMtAbono
					//---------------------------------------------------------------
					//Alterado por Reginaldo 07/10/2014 para tratar a informação quando a FALTA está sendo compensanda no banco de horas 
					If SPC->PC_PDI == "850"         //quando o campo não está vazio
						cMtAbono := "Compensação Banco de Horas" //Alltrim(POSICIONE("SP6",01,xFilial("SP6")+SPC->PC_ABONO,"P6_DESC")) 
						lHrComps := .T.
					EndIf
					@ PRow(),009 PSay cMtAbono
					//---------------------------------------------------------------------------------------------------------------
					_nHCalc := 0
					nRecAux:= SPC->(Recno())
					Do While SPC->(!Eof()) .And. SPC->PC_MAT == SRA->RA_MAT .And. SPC->PC_PD == "905" .And. SPC->PC_DATA == _dDataMarc
						_nHCalc    += _fHorMin(SPC->PC_QUANTC) - _fHorMin(SPC->PC_QTABONO)
						_nBHDebito += _nHCalc
						SPC->(dbSkip())
					Enddo     
					SPC->(DBGoTo(nRecAux))
					//
					If _nHCalc > 0
						If SPC->PC_QTABONO > 0
							@ PRow(),044 PSay "|     |     |     |"
							@ PRow(),063 PSay _fPictHora(SPC->PC_QTABONO,2) // Picture("99.99")
							@ PRow(),068 PSay "|     |"
							_nTTHJust += _fHorMin(SPC->PC_QTABONO)
						Else
							@ PRow(),044 PSay "|     |     |     |     |     |"
						EndIf
						@ PRow(),075 PSay _fPictHora(_fMinHor(_nHCalc),2) + IIF(lHrComps, "*", " ") // Picture("99.99")
						@ PRow(),080 PSay "|"
					ElseIf SPC->PC_QTABONO > 0
						@ PRow(),044 PSay "|     |     |     |"
						@ PRow(),063 PSay _fPictHora(SPC->PC_QTABONO,2)  // Picture("99.99")
						@ PRow(),068 PSay "|     |     |"
						_nTTHJust += _fHorMin(SPC->PC_QTABONO)
					Else
						@ PRow(),044 PSay "|     |     |     |     |     |      |"
					Endif
				Else
					cMtAbono:= ""
					If DOW(_dDataMarc) == 1//Domingo
						cMtAbono:= "D.S.R"
					ElseIf DOW(_dDataMarc) == 7//Sabado
						cMtAbono := "Sábado Compensado"
					EndIf
					If Empty(cMtAbono)
						cMtAbono:= "Ausente"
					EndIF
					@ PRow(),009 PSay cMtAbono
					@ PRow(),044 PSay "|     |     |     |     |     |      |"
				Endif
			Endif
			_dDataMarc++
		EndDo
		//
		@ PRow()+1,000 PSay "'-----'-'------------------------------------'-----'-----'-----'-----'-----'------'"
		//
	EndIf
	
	
	_nBHSalAnt := 0
	SPI->(dbSeek(SRA->(RA_FILIAL+RA_MAT) )) //  + DTOS(mv_par07) ) )
	Do While !SPI->(Eof()) .AND. SPI->PI_FILIAL == SRA->RA_FILIAL .And. SPI->PI_MAT == SRA->RA_MAT .And. SPI->PI_DATA <= mv_par07
		SP9->(dbSeek(xFilial("SP9") + SPI->PI_PD))
		If SPI->PI_STATUS <> 'B'
		If SP9->P9_TIPOCOD = "1" // credito
			_nBHSalAnt += _fHorMin(SPI->PI_QUANTV)
		Else
			_nBHSalAnt -= _fHorMin(SPI->PI_QUANTV)
		Endif
		ENDIF
		SPI->(DbSkip())
	EndDo
	
	@ PRow()+1,000 		PSay "Resumo das Ocorrencias"
	@ PRow()  ,053 		PSay "Banco de Horas"
	@ PRow()+1,000      	PSay "Horas Calculadas  : "
	@ PRow()  ,PCol()+1 	PSay _fPictHora(_fMinHor(_nTTHMes),4)								 //Picture("99.99")
	@ PRow()  ,053 		PSay "Saldo Anterior  : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHSalAnt),4)                            //Picture("99.99")
	@ PRow()+1,000 		PSay "Horas Extras  50% : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nTTHH50),4)								 //Picture("99.99")
	@ PRow()  ,053 		PSay "Crédito         : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHCredito),4) 						 	 //Picture("99.99")
	@ PRow()+1,000 		PSay "Horas Extras 100% : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nTTHH100),4) 							 //Picture("99.99")
	@ PRow()  ,053 		PSay "Débito          : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHDebito),4) 							 //Picture("99.99")
	@ PRow()+1,000 		PSay "Horas Justificada : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nTTHJust),4) 							 //Picture("99.99")
	@ PRow()  ,053       PSay "Saldo Atual     : "
	@ PRow()  ,PCol()+1  Psay _fPictHora(_fMinHor(_nBHSalAnt + _nBHCredito - _nBHDebito),4) //Picture("99.99")
	
	@ PRow()+1,000 PSay ".---------------------------------------------------------------------------------."
	@ PRow()+1,000 PSay "|Obs:                                                                             |"
	@ PRow()+1,000 PSay "|Legenda: * = Compensação de Banco de Horas.                                      |"
	@ PRow()+1,000 PSay "'---------------------------------------------------------------------------------'"
	
	@ PRow()+1,000 PSay "Confirmo as informações acima."
	
	@ PRow()+2,000 PSay Replicate("_",30) + Space(21) + Replicate("_",30)
	@ PRow()+1,000 PSay "Assinatura do Empregado"
	@ PRow()  ,051 PSay "Assinatura da Gerência"
	
	@ PRow()+2,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay ProcName(6) + " -  " + DTOC(dDataBase) + " - " + Time()
	@ PRow()+1,000 PSay Replicate("-",83)
	
	@ 000,000 PSay "" // pula pagina	
	
	SRA->(DBSkip())
EndDo
DBSelectArea("SRA")
SET FILTER TO

Return

//Excessoes
Static Function fImprExc()
Local cMtAfas := ""
Local lHrComps := .F.

@ PRow()+1,000 PSay "|"  + Substr(DTOS(_dDataMarc),7,2) + "/" + Substr(DTOS(_dDataMarc),5,2)
@ PRow()  ,005 PSay "|" + SubStr(_fDiaSem(_dDataMarc),1,1) + "| " // + AllTrim(SP3->P3_DESC)
//---------------------------------------------------------------------------------------------------------
// feriados
//---------------------------------------------------------------------------------------------------------
lFeriado := .F.
SP3->(DBSetOrder(01))
If !(lFeriado:= SP3->(dbSeek(xFilial("SP3") + DTOS(_dDataMarc))))
	SP3->(DBSetOrder(02))
	lFeriado:= SP3->(dbSeek(xFilial("SP3") + Subs(DTOS(_dDataMarc),5,4)))
EndIf
cMtAfas:= ""
If yPonFer(_dDataMarc)
	@ PRow(),009 PSay "FERIAS"
	@ PRow(),044 PSay "|     |     |     |     |     |      |"
	// feriado
ElseIf lFeriado
	@ PRow(),009 PSay AllTrim(SP3->P3_DESC)
	@ PRow(),044 PSay "|     |     |     |     |     |      |"
ElseIf !Empty((cMtAfas:=yfAfast(_dDataMarc))) //Localiza por afastamentos
	@ PRow(),009 PSay cMtAfas
	@ PRow(),044 PSay "|     |     |     |     |     |      |"
Else
	//---------------------------------------------------------------------------------------------------------
	// faltas
	//---------------------------------------------------------------------------------------------------------
	SPC->(dbSetOrder(1))       // f + mat + pd + dtos(data)
	SPC->(dbSeek(_cFilial + SRA->RA_MAT + "905" + DTOS(_dDataMarc)) )//.And. SPC->PC_PDI =="850"
	If SPC->(!Eof())
		cMtAbono:= "Ausente"
		
		If !EMPTY(SPC->PC_ABONO)
			cMtAbono:= Alltrim(POSICIONE("SP6",01,xFilial("SP6")+SPC->PC_ABONO,"P6_DESC")) 
		EndIf
		//@ PRow(),009 PSay cMtAbono
		//---------------------------------------------------------------
		//Alterado por Reginaldo 07/10/2014 para tratar a informação quando a FALTA está sendo compensanda no banco de horas 
		If SPC->PC_PDI=="850"         //quando o campo não está vazio
			cMtAbono := "Compensação Banco de Horas" //Alltrim(POSICIONE("SP6",01,xFilial("SP6")+SPC->PC_ABONO,"P6_DESC"))
			lHrComps := .T.
		EndIf
		@ PRow(),009 PSay cMtAbono
		//---------------------------------------------------------------------------------------------------------------
		_nHCalc := 0
		nRecAux:= SPC->(Recno())
		Do While SPC->(!Eof()) .And. SPC->PC_MAT == SRA->RA_MAT .And. SPC->PC_PD == "905" .And. SPC->PC_DATA == _dDataMarc
			_nHCalc    += _fHorMin(SPC->PC_QUANTC) - _fHorMin(SPC->PC_QTABONO)
			_nBHDebito += _nHCalc
			SPC->(dbSkip())
		Enddo
		SPC->(DBGoTo(nRecAux))
		//
		If _nHCalc > 0
			If SPC->PC_QTABONO > 0
				@ PRow(),044 PSay "|     |     |     |"
				@ PRow(),063 PSay _fPictHora(SPC->PC_QTABONO,2) // Picture("99.99")
				@ PRow(),068 PSay "|      |"
				_nTTHJust += _fHorMin(SPC->PC_QTABONO)
			Else
				@ PRow(),044 PSay "|     |     |     |     |     |"
			EndIf
			@ PRow(),075 PSay _fPictHora(_fMinHor(_nHCalc),2) + IIF(lHrComps, "*", " ") // Picture("99.99")
			@ PRow(),080 PSay "|"
		ElseIf SPC->PC_QTABONO > 0
			@ PRow(),044 PSay "|     |     |     |"
			@ PRow(),063 PSay _fPictHora(SPC->PC_QTABONO,2) // Picture("99.99")
			@ PRow(),068 PSay "|     |      |"
			_nTTHJust += _fHorMin(SPC->PC_QTABONO)
		Else
			@ PRow(),044 PSay "|     |     |     |     |     |      |"
		Endif
	Else
		cMtAbono:= ""
		If DOW(_dDataMarc) == 1//Domingo
			cMtAbono:= "D.S.R"
		ElseIf DOW(_dDataMarc) == 7//Sabado
			cMtAbono:= "Sábado Compensado"
		EndIf
		If Empty(cMtAbono)
			cMtAbono:= "Ausente"
		EndIF
		@ PRow(),009 PSay cMtAbono
		@ PRow(),044 PSay "|     |     |     |     |     |      |"
	Endif
Endif
Return

Static Function impCab()
	@ PRow()+1,000 PSay "Companhia de Habitação do Paraná"
	@ PRow()  ,070 PSay "Página:" + ALLTRIM(STR(m_pag))	
	@ PRow()+1,000 PSay "Rua Marechal Deodoro, 1133"
	@ PRow()+1,000 PSay "80.060-010 - Curitiba - PR"
	@ PRow()+1,000 PSay "C.G.C. 76.592.807/0001-22"
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay "RELATÓRIO DE FREQUÊNCIA"
	@ PRow()  ,050 PSay "PERÍODO " + DTOC(mv_par07) + " a " + DTOC(mv_par08)
	@ PRow()+1,000 PSay Replicate("-",83)
	@ PRow()+1,000 PSay "Empregado   : " + SRA->RA_NOME
	@ PRow()  ,055 PSay "Matricula : " + SRA->RA_MAT
	@ PRow()+1,000 PSay "Cargo       : " + SRJ->RJ_DESC
	@ PRow()  ,055 PSay "CTPS      : " + SRA->RA_NUMCP + "/" + SRA->RA_SERCP
	@ PRow()+1,000 PSay "Localização : " + AllTrim(CTT->CTT_DESC01)
	@ PRow()  ,055 PSay "Categoria : Mensalista"
	@ PRow()+1,000 PSay Replicate("-",83)	
Return

static function impcabMa()
	@ PRow()+1,000 PSay ".-----.-.------------------------------------.-----------------.-----.-----------."
	@ PRow()+1,000 PSay "|     |S|                                    |    Horas/Dia    |Ausên| Bco.Horas |"
	@ PRow()+1,000 PSay "| DIA |E|              MARCAÇÕES             |-----------------|     |-----------|"
	@ PRow()+1,000 PSay "|     |M|                                    |H.Cal| 50% | 100%|Just.|Créd.|Débi.|"
	@ PRow()+1,000 PSay "|-----+-+------------------------------------+-----+-----+-----+-----+-----+-----|"
return

static function fechPipe()

	@ PRow(),044 PSay "|"
	@ PRow(),050 PSay "|"
	@ PRow(),056 PSay "|"
	@ PRow(),062 PSay "|"
	@ PRow(),068 PSay "|"
	@ PRow(),074 PSay "|"
	@ PRow(),080 PSay "|"
				
Return
