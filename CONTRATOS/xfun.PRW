#INCLUDE "PROTHEUS.CH"

User Function XGETNUMERO()

Local lRet := 0
Local _TPCTO := cCodigo
Local _nProx := 0

if CN1->(dbSeek( xFilial('CN1') + _TPCTO ))
	_nProx := CN1->CN1_XPROX
	if _nProx > 0
	
		
		lRet := VAL(SubStr(DTOS(dDataBase),1,4) + STRZERO(_nProx, 5))
		
		Reclock("CN1",.F.)
		CN1->CN1_XPROX := _nProx+1
		MsUnlock()
	Endif
Endif
Return lRet
	

User Function XGETCONTRA()

Local lRet := ""
Local _TPCTO := cCodigo
Local _nProx := 0

if CN1->(dbSeek( xFilial('CN1') + _TPCTO ))
	_nProx := CN1->CN1_XPRO2
	if _nProx > 0
	
		
		lRet := STRZERO(_nProx, 5) +"/"+ CN1->CN1_XTPDES +"/"+ SubStr(DTOS(dDataBase),1,4)
		
		Reclock("CNA",.F.)
		CNA_XPROX := _nProx+1
		MsUnlock()
	Endif
Endif
Return lRet
