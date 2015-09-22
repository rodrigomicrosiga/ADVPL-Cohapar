#include "rwmake.ch"        
#Include 'Protheus.ch'
#include "TOPCONN.ch"

User Function gpeprevM()    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

LOCAL cTeste := ""
SetPrvt("_NORDSRX,_NFAIXAF,_NVALSAL,_CFAIXA,_NNRMESES,_NNRM")
SetPrvt("_NANOS,ANOMES,_NVALCONTR,_REFAN,_REFFG,_NPERC")
SetPrvt("_NDESC,_NA,_NB,_NVALOR,_NJOIA,_NCAD")

/*
+---------------------------------------------------------------------------+
| FUNCAO GPEPREVM   Autor: Rita Pimentel         Data  02/05/2001 			|
|---------------------------------------------------------------------------+
|  Descrição--CALCULO PREVIDENCIA PRIVADA - COHAPAR- LIC. MATERNIDADE       |
+---------------------------------------------------------------------------+
| Uso chamada da Função : Roteiro de Calculo -> FOL2957                     |
+---------------------------------------------------------------------------+
|Alterado por: Reginaldo Torres												|
|Alterado fonte do programa para chamar apenas os funcionários AFASTADOS POR| 
|LICENÇA MATERNIDADE pela rotina de FUNCIONÁRIOS AFASTADOS.                 |
|DATA: 25/03/2015															|
|Solicitado por Sr. Andre Marques do RH                                     |
+---------------------------------------------------------------------------+

*/                                                                           

DbSelectArea("SRX") // Parametro
_nOrdSRX := srx->(dbSetOrder())
DbSetOrder(1)
SRX->(DbGoTop())    
Store 0.00 to _nValor,_nPerc,_nDesc,_nValContr,_nValSal
_nFaixaf  := 0
_nValSal  := 0
_cFaixa   := " "
_nNrMeses := 0
_nNrM     := 0
_nanos    := 0
_nVlrGrt  := 0

nValAux := 0 
cQry := ""

If SRA->RA_DTINPP > dDataBase
   return
EndIf

//==========================================================================
//    CALCULA VALOR PREVIDENCIA PRIVADA POR FAIXA                          |
//==========================================================================

   _nFaixaf := val(sra->ra_idpp)
   If _nFaixaf <26
      _nFaixaf := 25
   ElseIf _nfaixaf <31
      _nFaixaf := 30
   ElseIf _nfaixaf <36
      _nFaixaf := 35
   ElseIf _nfaixaf <41
      _nFaixaf := 40
   ElseIf _nfaixaf <46
      _nFaixaf := 45
   ElseIf _nfaixaf <51
      _nFaixaf := 50
   Else
      _nFaixaf := 99
   EndIf
   _cFaixa   := LTRIM(str(_nFaixaf))
   AnoMes    := str(Year(dDataBase)) + strzero(Month(dDataBase),2)
   SRX->(DbSeek(xFilial("SRX") + "FE" + _cFaixa))// Checa na Tabela SRX --> FE o Fator de Contribuicao Cadastrado pelo USER.
   If srx->(!Eof())
      _nValContr:=  Val(Substr(SRX->RX_TXT,1,6))
   EndIf

   // Alterado em 19/06/01 por Rita para atender a reducao do ATS
   // O sistema pega o salario e recalcula o ATS de acordo com a referencia da verba no SRC
   // ja com a reducao de ATS.

//==========================================================================
//    BUSCA REF. DAS VERBAS NO MOMVIMENTO DA FOLHA                         |
//==========================================================================
   _refAN := 0
   If fBuscaPD("103") != 0
      _refAN := fBuscaPD("103","H")
   EndIf
   
   If fBuscaPD("101") != 0
      //_refAN := fBuscaPD("103","H")
   EndIf
   _nValSal := SRA->RA_SALARIO + ((SRA->RA_SALARIO * _refAN)/ 100)
  //  msginfo(_nValSal)   
   nValAux := SRA->RA_SALARIO + ((SRA->RA_SALARIO * _refAN)/ 100)
   
        /*
        +==================================================================================================================+	
		|					 CONSULTA PARA VERIFICAR AFASTAMENTO DE LICENÇA MATERNIDADE CONF. DT BASE SISTEMA              |
		|																												   |
		+==================================================================================================================+		
		
		*/
		cQry += "SELECT SR8.R8_MAT as REGISTROS FROM "+RetSQLName("SR8") + " SR8 "                                                                     
		cQry += "WHERE "
		cQry += "SR8.R8_MAT = '" + SRA->RA_MAT + "' "
		cQry += "AND '"+DTOS(DDATABASE)+"' BETWEEN  R8_DATAINI AND R8_DATAFIM "		
		cQry += "AND (SR8.R8_TIPO = 'Q' "
		cQry += "OR SR8.R8_TIPO = 'M')		
		cQry += "AND SR8.D_E_L_E_T_ <> '*' "
		
		If Select( "SR8TMP" ) <> 0
			dbSelectArea("SR8TMP")
			SR8TMP->(dbCloseArea())
		EndIf            
		
		cQry := ChangeQuery(cQry)    
		TcQuery cQry New Alias "SR8TMP"		
		nQtd := Contar("SR8TMP","!EOF()")
        //msginfo(nQtd)
          
// Verifica se estiver afastada e motivos por LICENÇA MATERNIDADE
	If SRA->RA_SITFOLH = "A" .AND. nQtd > 0 //NAO CALCULA PARA FUNCIONARIOS COM SITUACAO DE AFASTADO NO CADASTRO
    	If nQtd > 0
			_nValSal := SRA->RA_SALINCO    
		EndIf
	Endif 
	
IF  nQtd > 0 //SÓ CALCULA SE FOR AFASTADO POR LIC. MATERNIDADE ((((((( SOLICITADO POR Sr. ANDRE DO RH)))))))) 
 		
// =====================================CONSIDERA A BASE DE CALCULO MENOS O ATS============================================  
 		_nVlrGrt := SRA->RA_FGRATIF
 		 				
 		If SRA->RA_FGRATIF != 0  //fBuscaPD("104")!= 0
	      _refFG := fBuscaPD("154","D")
	      _nValSal := _nValSal - ((_nVlrGrt / _refFG) * 30)  
	    EndIf
//=========================================================================================================================    

	
   	SRX->(DbGoTop())
   	SRX->(DbSeek(xFilial("SRX")+"FC" + AnoMes,.T.)) // Verifica na Tabela a Faixa Salarial
   	Do While SRX->RX_TIP=="FC" .AND. SRX->(!Eof())

      If ALLTRIM(SUBSTR(SRX->RX_COD,1,6))==ALLTRIM(AnoMes)

         If substr(SRX->RX_COD,7,1) == "3"
   
            If _nValSal >  Val(subs(SRX->RX_TXT,1,12))
                //msginfo(_nValSal)
               _nValSal := Val(subs(SRX->RX_TXT,1,12))
            EndIf
            _nPerc := Val(Substr(SRX->RX_TXT,13,6)) 
            _nDesc := Val(Substr(SRX->RX_TXT,19,9))
         Else
            If _nValSal <= Val(subs(SRX->RX_TXT,1,12)) 
               _nPerc := Val(Substr(SRX->RX_TXT,13,6))
               _nDesc := Val(Substr(SRX->RX_TXT,19,9))
            ElseIf _nValSal <= Val(subs(SRX->RX_TXT,28,12))
               _nPerc := Val(Substr(SRX->RX_TXT,40,6)) 
               _nDesc := Val(Substr(SRX->RX_TXT,46,9))
            EndIf
         EndIf
      EndIf
      IF _nPerc == 0
         SRX->(DbSkip())
         loop
      ENDIF
      Exit
   EndDo
   _nA := ((_nValSal * _nPerc) / 100) - _nDesc
   _nB := _nA * _nValContr
   _nValor := _nA + _nB
   
   	 If _nValor > 0
      	fGeraVerba("530",_nValor,,,,,,,,,.T.) // gera verba de desconto PREVIDENCIA PRIVADA
      	fGeraVerba("800",_nValSal,,,,,,,,,.T.) // gera verba de desconto PREVIDENCIA PRIVADA
     EndIf
Endif// FINAL DA GERAÇÃO DO DESC PREV PRIVADA E RELAÇÃO AOS AFASTADO JÁ CONSIDERANDO OS ATIVOS



//=================================JOIA ??? ========================================================
   _nJoia := 0
   _nNrMeses := val(SRA->RA_NPJOIA)
      If Year(dDataBase) == Year(SRA->RA_DTINPP)
         _nNrM := Month(dDataBase) - Month(SRA->RA_DTINPP) // Checa Nr.Meses de utilizacao da Previdencia Privada
      ElseIf Year(dDataBase) < Year(SRA->RA_DTINPP)
         _nNrM := _nNrMeses
      Else
         _nanos := Year(dDataBase) - Year(SRA->RA_DTINPP)
         _nNrM  := Month(dDataBase) - (Month(SRA->RA_DTINPP)-(12 * _nanos))
      EndIf
//    _nNrM :=int((Month(dDataBase)-Month(SRA->RA_DTINPP)/30)+1,2) // Checa Nr.Meses de utilizacao da Previdencia Privada
   If (_nNrMeses - _nNrM) > 0
      _nJoia := _nValor * sra->ra_joia / 100
      fGeraVerba("531",_nJoia,,,,,,,,,.T.) // gera verba de Joia
      fGeraVerba("801",_nValor,,,,,,,,,.T.) // gera verba de desconto PREVIDENCIA PRIVADA
   EndIf
   If SRA->RA_CAPP != 0
      _nCad := _nValSal * SRA->RA_CAPP / 100
      fGeraVerba("532",_nCad,,,,,,,,,.T.) // gera verba de Contribuicao Adicional
      fGeraVerba("802",_nValSal,,,,,,,,,.T.) // gera verba de desconto PREVIDENCIA PRIVADA
   EndIf
srx->(dbSetOrder(_nOrdSRX))
//EndIf
Return      
