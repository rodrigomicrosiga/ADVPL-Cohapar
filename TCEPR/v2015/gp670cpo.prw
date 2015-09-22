#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GP670CPO  � Autor � Equipe RH          � Data �  12/06/03   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada da integracao Folha x Financeiro          ���
���          � para gravacao do CENTRO DE CUSTO                           ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function GP670CPO ()
                     
        If RC1->RC1_NATURE == "23006" .OR. RC1->RC1_NATURE == "23002" .OR. RC1->RC1_NATURE == "23102"
       		 RecLock("SE2",.F.)
		     SE2->E2_CC := "01010001"
        	 MsUnLock("SE2")
        EndIf	    
        
        if SE2->E2_TIPO == '3PA'        
       		 RecLock("SE2",.F.)
		     SE2->E2_HIST := "GPE - Pensao Alimenticia"
        	 MsUnLock("SE2")        
        
        EndIf
	
	// GML - TRATAMENTO PARA TCE/PR
	// 02/07/2017
    Do Case
    	Case AllTrim(SE2->E2_TIPO) == '2FG'
    		cCdTipo := '09'
    	Case AllTrim(SE2->E2_TIPO) == '2FP'
    		cCdTipo := '09'
    	Case AllTrim(SE2->E2_TIPO) == '2IN'
    		cCdTipo := '28'
    	Case AllTrim(SE2->E2_TIPO) == '3CO'
    		cCdTipo := '28'
    	Case AllTrim(SE2->E2_TIPO) == '3CS'
    		cCdTipo := '28'
    	Case AllTrim(SE2->E2_TIPO) == '3IR'
    		cCdTipo := '09'
    	Otherwise
    		cCdTipo := '09'
    EndCase	

	RecLock('SE2', .F.)

		SE2->E2_XCODTP := cCdTipo

	SE2->(MsUnlock())			
        
Return
