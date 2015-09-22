#INCLUDE "PROTHEUS.CH"   

USER FUNCTION FA050ALT()        
Local lKitPag  := GetMv("MV_BRVKPAG")    
Local cQuery := ""
        
  	If ApMsgYesNo("A manutenção do título resultará no cancelamento do mesmo em seus respectivos lotes de aprovação."+chr(13)+;
  					"Deseja continuar?")
		DBSelectArea("ZBS")
		DBSetOrder(2)
		DbSeek(xFilial("ZBS")+SE2->E2_FILIAL+PADR(SE2->E2_PREFIXO,3)+SE2->E2_NUM+SE2->E2_PARCELA+PADR(SE2->E2_TIPO,3)+SE2->E2_FORNECE)
		While ZBS->(!Eof()) .AND. ZBS->ZBS_FILIAL==xFilial("ZBS") .AND. ZBS->ZBS_FILTIT==SE2->E2_FILIAL .AND.;
			AllTrim(ZBS->ZBS_PREFIX)==AllTrim(SE2->E2_PREFIXO) .AND. ZBS->ZBS_NUM==SE2->E2_NUM .AND. ZBS->ZBS_PARCEL==SE2->E2_PARCELA .AND.;
			AllTrim(ZBS->ZBS_TIPO)==AllTrim(SE2->E2_TIPO) .AND. ZBS->ZBS_FORNEC==SE2->E2_FORNECE
						    
			RecLock("ZBS", .F.) 
			ZBS->ZBS_SITUAC := "C"   
			ZBS->ZBS_OBSERV := "Cancelamento devido à alteração realizada no título."
			MsUnLock()
		     

			DBSelectArea("ZBT")
			RecLock("ZBT", .T.) 
			ZBT->ZBT_FILIAL := ""
			ZBT->ZBT_LOTE   := ZBS->ZBS_LOTE
			ZBT->ZBT_CCUSTO := ZBS->ZBS_CCUSTO
			ZBT->ZBT_FILTIT := ZBS->ZBS_FILTIT
			ZBT->ZBT_PREFIX := ZBS->ZBS_PREFIX
			ZBT->ZBT_NUM    := ZBS->ZBS_NUM
			ZBT->ZBT_PARCEL := ZBS->ZBS_PARCEL
			ZBT->ZBT_TIPO   := ZBS->ZBS_TIPO
			ZBT->ZBT_FORNEC := ZBS->ZBS_FORNEC
			ZBT->ZBT_DATA   := dDataBase
			ZBT->ZBT_HORA   := Substr(Time(),1,2)+":"+Substr(Time(),4,2)
			ZBT->ZBT_USUAR  := Alltrim(Substr(cUsuario,7,15))
			ZBT->ZBT_SITUAC := "C"
			ZBT->ZBT_OBSERV := "Cancelamento devido à alteração realizada no título."
			MsUnLock()                          

			DBSelectArea("ZBS")
			DBSkip()
		Enddo    
	
		Return .T.
	Else
		Return .F.		  					
	Endif 

Return .T.