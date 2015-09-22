#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 04/07/02

User Function Valnat()        // incluido pelo assistente de conversao do AP5 IDE em 04/07/02

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// ALTERADO PARA SOMENTE MOSTRAR A TELA NA INCLUSAO - ROSSANA (12/11/2007)
                 
	SetPrvt("_CNAT,FLAG,Inclui")
         
        IF AllTrim(FunName())=="MATA235"
          Inclui:= .f.
        ENDIF

	DBSELECTAREA("SED")
	SED->(dbSetOrder(1))


	_cNat:=SPACE(10)                        
                     
	// Não chamar no Gera Solicitação na unificação das bases e no relatório de pedido de compras
	                                      
	If AllTrim(FunName())=="GERASOLICIT" .or. AllTrim(FunName())=="MATR110" .or. AllTrim(FunName())=="MATR120"
		Return
	EndIf


	                              
If Inclui 
	flag :=.t.
	Do While flag==.t.
    	  @ 96,042 TO 323,555 DIALOG oDlg5 TITLE "Validacao"
	      @ 08,010 TO 84,252
    	  @ 27,014 SAY "      Obrigatorio entrar com  a natureza.    "
	      @ 35,014 SAY "      Deve ser do grupo 2 (Despesas/saidas). "
    	  @ 43,014 SAY "Entre com a natureza .......................:"
	      @ 43,125 GET _cNat PICTURE "@!" F3 "SED" VALID !(EMPTY(_cNat))
    	  @ 91,168 BMPBUTTON TYPE 1 ACTION OkProc()// Substituido pelo assistente de conversao do AP5 IDE em 04/07/02 ==>       @ 91,168 BMPBUTTON TYPE 1 ACTION Execute(OkProc)
	      ACTIVATE DIALOG oDlg5
	Enddo
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 04/07/02 ==> __Return(_cNat)

	Return(_cNat)        // incluido pelo assistente de conversao do AP5 IDE em 04/07/02 */
Return
// Substituido pelo assistente de conversao do AP5 IDE em 04/07/02 ==> Function OkProc

Static Function OkProc()
/*
      SED->(DBSEEK(xFilial("SED")+_cNat))
      If SED->(!FOUND()) .OR. SED->ED_TIPO=="S" .OR. EMPTY(SED->ED_CONTA)
         Msgbox("Natureza Invalida (Nao aceita Branco, ou sem conta contabil, ou natureza de saidas!!")
         flag:=.t.
      Else
         Close(oDlg5)
         flag:=.f.
      Endif
  */    
Return
