#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 16/01/03

User Function gpegpp()        // incluido pelo assistente de conversao do AP5 IDE em 16/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_NCONTLIN,_NVAL530,_NVAL531,_NVAL532,_NVAL533,_NVAL534")
SetPrvt("_NVAL535,_NVAL536,_NVAL538,_NVAL800,_NVAL801,_NVAL802")
SetPrvt("_NVAL803,_NVAL804,_NVALBAS,_CREGISTRO,_NNUMREG,_CMES")
SetPrvt("_CMESANO,_CARQUIVO,NOUTFILE,_NFUNC,FLAGT,_NV530")
SetPrvt("_NV531,_NV532,_NV533,_NV534,_NV535,_NV536")
SetPrvt("_NV538,_NV800,_NV801,_NV802,_NV803,_NV804")
SetPrvt("_NVBAS,_CPAGTO,_CDESCR530,_CDESCR531,_CDESCR532,_CDESCR533")
SetPrvt("_CDESCR534,_CDESCR535,_CDESCR536,_CDESCR538,FLAGF,CALIAS")
SetPrvt("AREGISTROS,CNOMEPERG,CULTPERG,NLIN,NCOL,")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEGPP   ³ Autor ³ Rita Pimentel         ³ Data ³ 25/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de Arquivo de Remessa dos Valores Descontado da    ³±±
±±³          ³ Previdencia Privada                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo COHAPAR                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Consultor    ³ DATA   ³         MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//³ mv_par01 = Filial De                                         ³
//³ mv_par02 = Filial Ate                                        ³
//³ mv_par03 = Centro de Custo De                                ³
//³ mv_par04 = Centro de Custo Ate                               ³
//³ mv_par05 = Situacoes a Imprimir                              ³
//³ mv_par06 = Mes/Ano de Referencia                             ³
//³ mv_par07 = Nome do Arquivo a Gerar                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nContLin   := 0
_nVal530 := 0
_nVal531 := 0
_nVal532 := 0
_nVal533 := 0
_nVal534 := 0
_nVal535 := 0
_nVal536 := 0
_nVal538 := 0
_nVal800 := 0
_nVal801 := 0
_nVal802 := 0
_nVal803 := 0
_nVal804 := 0
_nValBAS := 0
cPerg := 'GPEGPP'
AjustaSX1(cPerg)
If !Pergunte(cPerg,.T.)
   Return Nil
Endif

Processa({|| fGPE()})  //-- Chamada do Relatorio.// Substituido pelo assistente de conversao do AP5 IDE em 16/01/03 ==> Processa({|| Execute(fGPE)})  //-- Chamada do Relatorio.


//=======================================
// Substituido pelo assistente de conversao do AP5 IDE em 16/01/03 ==> Function fGPE
Static Function fGPE()

//----------------------------- variaveis gerais
_cRegistro := {}
_nNumReg   := 0

//----------------------------- mensagens
_cMes   := Subs(mv_par06,1,2)

//--------------------------------- data referencia

Do Case
   Case Subs(mv_par06,1,2) == "01"
        _cMesAno := "  JANEIRO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "02"                
        _cMesAno := "FEVEREIRO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "03"
        _cMesAno := "    MARCO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "04"
        _cMesAno := "    ABRIL/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "05"
        _cMesAno := "     MAIO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "06"
        _cMesAno := "    JUNHO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "07"
        _cMesAno := "    JULHO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "08"
        _cMesAno := "   AGOSTO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "09"
        _cMesAno := " SETEMBRO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "10"
        _cMesAno := "  OUTUBRO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "11"
        _cMesAno := " NOVEMBRO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "12"
        _cMesAno := " DEZEMBRO/" + SubStr(mv_par06,4,4)
   Case Subs(mv_par06,1,2) == "13"
        _cMes    := "13"
        _cMesAno := " DEZEMBRO/" + SubStr(mv_par06,4,4)
EndCase


//-------------------------------------- abre o arquivo 
_cArquivo := Alltrim(mv_par07)
nOutfile := FCreate(_cArquivo,0)  // cria o arquivo
If Ferror() #0
   MsgStop("Ocorreu o erro ( " + AllTrim(str(Ferror())) + " ) do DOS na criacao do arquivo " + _cArquivo)
   Return
EndIf

//-------------------------------------- parametros iniciais

_cRegistro := "10DESCONTO COHAPREV" + _cMesAno  + space(55) + "*"
FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
_nContLin := _nContLin + 1
_nNumReg := _nNumReg + 1
If Ferror() #0
    MsgStop("Ocorreu um erro na gravacao do arquivo")
    Return
EndIf

//-------------------------------------- arquivos e indices
DbSelectArea("SRV")    // verbas 
DbSetOrder(1)          // filial + cod
DbSelectArea("SRC")    // movimentacao mes
DbSetOrder(1)          // filial + mat + pd
DbSelectArea("SRA")    // funcionarios
DbSetOrder(1)          // filial + mat 
IF _cMes == "13"
   DbSelectArea("SRI")    // movimentacao 13. SALARIO
   DbSetOrder(1)          // filial + mat + pd
ENDIF

IF _cMes <> "13"

   //--- Leitura do SRC - Movimento Mensal
   // Procura o 1§ funcionario com movimento
   SRA->(DbGoTop()) 
   While SRA->(!Eof())
      DbSelectArea("SRC")
      SRC->(DbSetOrder(1))
      SRC->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT,.T.))
      If SRC->(Found())
        Exit
      EndIf
      SRA->(DbSkip())
   End
   ProcRegua(RecCount()) //-- Total de elementos da regua.
   
   //-------------------------------------- inicio do loop
   _nFunc := 0
   While SRA->(!Eof())
      IncProc()
      //-------------------------------------- testa situacao
      If SRA->RA_SITFOLH $ mv_par05 .and. SRA->RA_FILIAL >= mv_par01 .and. SRA->RA_FILIAL <= mv_par02;   
                                    .and. SRA->RA_CC >= mv_par03 .and. SRA->RA_CC <= mv_par04          
         SRC->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT,.T.))
         If SRC->(!Found())
            SRA->(DbSkip())
            Loop
         EndIf
         flagt := .f.
         _nV530 := 0
         _nV531 := 0
         _nV532 := 0
         _nV533 := 0
         _nV534 := 0
         _nV535 := 0
         _nV536 := 0
         _nV538 := 0
         _nV800 := 0
         _nV801 := 0
         _nV802 := 0
         _nV803 := 0
         _nV804 := 0
         _nVBAS := 0 

         Do While SRC->(!Eof()) .And. src->rc_filial == sra->ra_filial .And. src->rc_mat == sra->ra_mat
            If (src->rc_pd >= "530" .AND. src->rc_pd <= "538") .OR. (src->rc_pd >= "800" .AND. src->rc_pd <= "804")
               flagt := .t.
               SRV->(dbSeek(xFilial("SRV") + src->rc_pd))
               _cPagto := StrZero(Year(src->rc_data),4) + Subs(DtoC(src->rc_data),4,2) + Subs(DtoC(src->rc_data),1,2)
               If src->rc_pd == "530"
                  _nVal530    := _nVal530 + src->rc_valor
                  _nV530      := src->rc_valor
                  _cDescr530  := srv->rv_desc
               EndIf
               If src->rc_pd == "531"
                  _nVal531    := _nVal531 + src->rc_valor
                  _nV531      := src->rc_valor
                  _cDescr531  := srv->rv_desc
               EndIf
               If src->rc_pd == "532"
                  _nVal532    := _nVal532 + src->rc_valor
                  _nV532      := src->rc_valor
                  _cDescr532  := srv->rv_desc
               EndIf
               If src->rc_pd == "533"
                  _nVal533    := _nVal533 + src->rc_valor
                  _nV533      := src->rc_valor
                  _cDescr533  := srv->rv_desc
               EndIf
               If src->rc_pd == "534"
                  _nVal534    := _nVal534 + src->rc_valor
                  _nV534      := src->rc_valor
                  _cDescr534  := srv->rv_desc
               EndIf
               If src->rc_pd == "535"
                  _nVal535    := _nVal535 + src->rc_valor
                  _nV535      := src->rc_valor
                  _cDescr535  := srv->rv_desc
               EndIf
               If src->rc_pd == "536"
                  _nVal536    := _nVal536 + src->rc_valor
                  _nV536      := src->rc_valor
                  _cDescr536  := srv->rv_desc
               EndIf
               If src->rc_pd == "538"
                  _nVal538    := _nVal538 + src->rc_valor
                  _nV538      := src->rc_valor
                  _cDescr538  := srv->rv_desc
               EndIf
               If src->rc_pd == "800"
                  _nVal800 := _nVal800 + src->rc_valor
                  _nV800   := src->rc_valor
               EndIf
               If src->rc_pd == "801"
                  _nVal801 := _nVal801 + src->rc_valor
                  _nV801   := src->rc_valor
               EndIf
               If src->rc_pd == "802"
                  _nVal802 := _nVal802 + src->rc_valor
                  _nV802   := src->rc_valor
               EndIf
               If src->rc_pd == "803"
                  _nVal803 := _nVal803 + src->rc_valor
                  _nV803   := src->rc_valor
               EndIf
               If src->rc_pd == "804"
                  _nVal804 := _nVal804 + src->rc_valor
                  _nV804   := src->rc_valor
               EndIf
            EndIf
            SRC->(dbSkip())
         EndDo
         if flagt
            flagf := .f.
            If _nV530 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "530" + _cDescr530 + _cPagto + Transform(_nV530,"@R 999999999.99") + Transform(_nV800,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV531 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "531" + _cDescr531 + _cPagto + Transform(_nV531,"@R 999999999.99") + Transform(_nV801,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV532 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "532" + _cDescr532 + _cPagto + Transform(_nV532,"@R 999999999.99") + Transform(_nV802,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV533 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "533" + _cDescr533 + _cPagto + Transform(_nV533,"@R 999999999.99") + Transform(_nVBAS,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV534 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "534" + _cDescr534 + _cPagto + Transform(_nV534,"@R 999999999.99") + Transform(_nVBAS,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV535 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "535" + _cDescr535 + _cPagto + Transform(_nV535,"@R 999999999.99") + Transform(_nVBAS,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV536 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "536" + _cDescr536 + _cPagto + Transform(_nV536,"@R 999999999.99") + Transform(_nV803,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV538 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "538" + _cDescr538 + _cPagto + Transform(_nV538,"@R 999999999.99") + Transform(_nV804,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If flagf := .t.
               _nFunc := _nFunc + 1
            EndIf
         EndIf
      Endif
      SRA->(dbSkip())
   End //While

ELSE

   //--- Leitura do SRI - Movimento 13. SALARIO
   // Procura o 1§ funcionario com movimento
   SRA->(DbGoTop()) 
   While SRA->(!Eof())
      DbSelectArea("SRI")
      SRI->(DbSetOrder(1))
      SRI->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT,.T.))
      If SRI->(Found())
        Exit
      EndIf
      SRA->(DbSkip())
   End
   ProcRegua(RecCount()) //-- Total de elementos da regua.
   
   //-------------------------------------- inicio do loop
   _nFunc := 0
   While SRA->(!Eof())
      IncProc()
      //-------------------------------------- testa situacao
      If SRA->RA_SITFOLH $ mv_par05 .and. SRA->RA_FILIAL >= mv_par01 .and. SRA->RA_FILIAL <= mv_par02;   
                                    .and. SRA->RA_CC >= mv_par03 .and. SRA->RA_CC <= mv_par04          
         SRI->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT,.T.))
         If SRI->(!Found())
            SRA->(DbSkip())
            Loop
         EndIf
         flagt := .f.
         _nV530 := 0
         _nV531 := 0
         _nV532 := 0
         _nV533 := 0
         _nV534 := 0
         _nV535 := 0
         _nV536 := 0
         _nV538 := 0
         _nV800 := 0
         _nV801 := 0
         _nV802 := 0
         _nV803 := 0
         _nV804 := 0
         _nVBAS := 0 

         Do While SRI->(!Eof()) .And. srI->rI_filial == sra->ra_filial .And. srI->rI_mat == sra->ra_mat
            If (srI->rI_pd >= "530" .AND. srI->rI_pd <= "538") .OR. (srI->rI_pd >= "800" .AND. srI->rI_pd <= "804")
               flagt := .t.
               SRV->(dbSeek(xFilial("SRV") + sri->ri_pd))
               _cPagto := StrZero(Year(sri->ri_data),4) + Subs(DtoC(sri->ri_data),4,2) + Subs(DtoC(sri->ri_data),1,2)
               If sri->ri_pd == "536"
                  _nVal536    := _nVal536 + sri->ri_valor
                  _nV536      := sri->ri_valor
                  _cDescr536  := srv->rv_desc
               EndIf
               If sri->ri_pd == "538"
                  _nVal538    := _nVal538 + sri->ri_valor
                  _nV538      := sri->ri_valor
                  _cDescr538  := srv->rv_desc
               EndIf
               If sri->ri_pd == "803"
                  _nVal803 := _nVal803 + sri->ri_valor
                  _nV803   := sri->ri_valor
               EndIf
               If sri->ri_pd == "804"
                  _nVal804 := _nVal804 + sri->ri_valor
                  _nV804   := sri->ri_valor
               EndIf
            EndIf
            SRI->(dbSkip())
         EndDo
         if flagt
            flagf := .f.
            If _nV536 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "536" + _cDescr536 + _cPagto + Transform(_nV536,"@R 999999999.99") + Transform(_nV803,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If _nV538 != 0
               flagf := .t.
               _cRegistro :=  "20" + sra->ra_mat + "538" + _cDescr538 + _cPagto + Transform(_nV538,"@R 999999999.99") + Transform(_nV804,"@R 999999999.99") + space(25) + "*"
               FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
               _nNumReg := _nNumReg + 1
               _nContLin := _nContLin + 1
               If Ferror() #0
                  MsgStop("Ocorreu um erro na gravacao do arquivo")
                  Return
               EndIf
            EndIf
            If flagf := .t.
               _nFunc := _nFunc + 1
            EndIf
         EndIf
      Endif
      SRA->(dbSkip())
   End //While
ENDIF






   _cRegistro := "30" + StrZero(_nFunc,4) + "530" + Transform(_nVal530,"@R 999999999.99") + Transform(_nVal800,"@R 999999999.99")
   _cRegistro := _cRegistro + "531" + Transform(_nVal531,"@R 999999999.99") + Transform(_nVal801,"@R 999999999.99")
   _cRegistro := _cRegistro + "532" + Transform(_nVal532,"@R 999999999.99") + Transform(_nVal802,"@R 999999999.99") 
   _cRegistro := _cRegistro + "533" + Transform(_nVal533,"@R 999999999.99") + Transform(_nValBAS,"@R 999999999.99") 
   _cRegistro := _cRegistro + "534" + Transform(_nVal534,"@R 999999999.99") + Transform(_nValBAS,"@R 999999999.99") 
   _cRegistro := _cRegistro + "535" + Transform(_nVal535,"@R 999999999.99") + Transform(_nValBAS,"@R 999999999.99") 
   _cRegistro := _cRegistro + "536" + Transform(_nVal536,"@R 999999999.99") + Transform(_nVal803,"@R 999999999.99")
   _cRegistro := _cRegistro + "538" + Transform(_nVal538,"@R 999999999.99") + Transform(_nVal804,"@R 999999999.99") + " *"
   FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
   _nNumReg := _nNumReg + 1
   _nContLin := _nContLin + 1
   _cRegistro := "90" + Transform((_nVal530+_nVal531+_nVal532+_nVal533+_nVal534+_nVal535+_nVal536+_nVal538),"@R 999999999.99") + Transform((_nVal800+_nVal801+_nVal802+_nVal803+_nVal804),"@R 999999999.99") + space(62) + "*"
   FWrite(nOutFile,_cRegistro + Chr(10),Len(_cRegistro) + 1)
   _nNumReg := _nNumReg + 1
   _nContLin := _nContLin + 1
  
   If Ferror() #0
      MsgStop("Ocorreu um erro na gravacao do arquivo")
      Return
   EndIf
   
   //  fim da gravacao do arquivo
   //

   FClose(nOutFile)                // fecha o arquivo
   If Ferror() #0
      Tone(4000,10)
      MsgStop("Ocorreu um erro no fechamento do arquivo")
   Else
      Tone(4000,1)
      MsgAlert(Str(_nNumReg , 5, 0) + " registros exportados")
   EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³RdMake    ³AjustaSX1 ³ Autor ³ Rita Pimentel         ³ Data ³ 25.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria perguta no SX1 caso NAO Exista                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ AjustaSX1                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 16/01/03 ==> Function AjustaSX1
Static Function AjustaSX1(cPerg)
	PutSX1(cPerg,"01","Filial De           " ,"","","mv_ch1" , "C",2,0,0 ,"G","NaoVazio" ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","","")
	PutSX1(cPerg,"02","Filial Ate          " ,"","","mv_ch2" , "C",2,0,0 ,"G","NaoVazio" ,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","","")
	PutSX1(cPerg,"03","Centro de Custo De  " ,"","","mv_ch3" , "C",9,0,0 ,"G","NaoVazio" ,"mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","","","")
	PutSX1(cPerg,"04","Centro de Custo Ate " ,"","","mv_ch4" , "C",9,0,0 ,"G","NaoVazio" ,"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","","","","")
	PutSX1(cPerg,"05","Situacao a Imprimir " ,"","","mv_ch5" , "C",5,0,0 ,"G","fSituacao","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"06","Mes/Ano Referencia  " ,"","","mv_ch6" , "C",7,0,0 ,"G","NaoVazio" ,"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"07","Arquivo de Destino  " ,"","","mv_ch7" , "C",30,0,0,"G","NaoVazio" ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","")
Return
