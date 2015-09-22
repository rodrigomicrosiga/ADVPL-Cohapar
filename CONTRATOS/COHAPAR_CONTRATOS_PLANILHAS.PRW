/*
+----------------------------------------------------------------------------+
!                        FICHA TECNICA DO PROGRAMA                           !
+----------------------------------------------------------------------------+
! DADOS DO PROGRAMA 														 !
+------------------+---------------------------------------------------------+
!Tipo 			   ! Atualização 											 !
+------------------+---------------------------------------------------------+
!Modulo 		   ! Contrato	 											 !
+------------------+---------------------------------------------------------+
!Nome 			   ! COHAPAR_CONTRATOS_PLANILHAS.PRW						 !
+------------------+---------------------------------------------------------+
!Descricao 		   ! Programa para Replicação de Planilhas nas revisões		 !
+------------------+---------------------------------------------------------+
!Autor 			   ! Gilson Lima											 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/05/2015												 !
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

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ReplPlan 	! Autor !Gilson Lima 		 ! Data ! 07/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Replica Planilhas							 !
!			! 																 !
+----------------------------------------------------------------------------*/
User Function ReplPlan()

	aDadosCNA := {}
	aDadosCNB := {}
	
	dbSelectArea("CNA")
	CNA->(dbSetOrder(1))
	CNA->(dbGoTop())
	
	While CNA->(!EOF())
	
		aAdd(aDadosCNA,{;
			CNA->CNA_FILIAL,;
			CNA->CNA_CONTRA,;
			CNA->CNA_NUMERO,;
			CNA->CNA_REVISA,;
			CNA->CNA_FORNEC,;
			CNA->CNA_LJFORN,;
			CNA->CNA_DTINI,;
			CNA->CNA_VLTOT,;
			CNA->CNA_SALDO,;
			CNA->CNA_TIPPLA,;
			CNA->CNA_DTFIM,;
			CNA->CNA_CRONOG,;
			CNA->CNA_ESPEL,;
			CNA->CNA_FLREAJ,;
			CNA->CNA_DTMXMD,;
			CNA->CNA_CLIENT,;
			CNA->CNA_LOJACL,;
			CNA->CNA_CRONCT,;
			CNA->CNA_VLCOMS;
		})
		
		CNA->(dbSkip())
	End

	CNA->(dbCloseArea())

	ReplCNA(aDadosCNA)
	ReplCNB(aDadosCNA)	

	Alert('Concluído')
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ReplCNA 	! Autor !Gilson Lima 		 ! Data ! 07/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Replica Planilhas CNA											 !
!			! 																 !
+----------------------------------------------------------------------------*/
Static Function ReplCNA(aDadosCNA)

	For nA := 1 To Len(aDadosCNA)

		If Val(aDadosCNA[nA][4]) > 0
			nNrPlan := Val(aDadosCNA[nA][4])
		Else
			nNrPlan := 0
		EndIf
		
		If nNrPlan > 0
			dbSelectArea("CNA")
			For nCont := 0 To nNrPlan - 1
			
				If nCont == 0
					cCNARev := Space(3)
				Else
					cCNARev := StrZero(nCont,3)
				EndIf
					
				RecLock("CNA",.T.)
					
					CNA->CNA_FILIAL := aDadosCNA[nA][1]
					CNA->CNA_CONTRA := aDadosCNA[nA][2]
					CNA->CNA_NUMERO := aDadosCNA[nA][3]
					CNA->CNA_REVISA := cCNARev
					CNA->CNA_FORNEC := aDadosCNA[nA][5]
					CNA->CNA_LJFORN := aDadosCNA[nA][6]
					CNA->CNA_DTINI 	:= aDadosCNA[nA][7]
					CNA->CNA_VLTOT 	:= aDadosCNA[nA][8]
					CNA->CNA_SALDO 	:= aDadosCNA[nA][9]
					CNA->CNA_TIPPLA := aDadosCNA[nA][10]
					CNA->CNA_DTFIM 	:= aDadosCNA[nA][11]
					CNA->CNA_CRONOG := aDadosCNA[nA][12]
					CNA->CNA_ESPEL 	:= aDadosCNA[nA][13]
					CNA->CNA_FLREAJ := aDadosCNA[nA][14]
					CNA->CNA_DTMXMD := aDadosCNA[nA][15]
					CNA->CNA_CLIENT := aDadosCNA[nA][16]
					CNA->CNA_LOJACL := aDadosCNA[nA][17]
					CNA->CNA_CRONCT := aDadosCNA[nA][18]
					CNA->CNA_VLCOMS := aDadosCNA[nA][19]	
									
				MsUnLock()
			Next nCont
			CNA->(dbCloseArea())
		EndIf
	
	Next nA

	Alert('Concluído CNA')
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ReplCNB 	! Autor !Gilson Lima 		 ! Data ! 07/05/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Replica Planilhas CNB											 !
!			! 																 !
+----------------------------------------------------------------------------*/
Static Function ReplCNB(aDadosCNA)

	aDadosCNB := {}
	
	For nA := 1 To Len(aDadosCNA)

		If Val(aDadosCNA[nA][4]) > 0
			nNrPlan := Val(aDadosCNA[nA][4])
		Else
			nNrPlan := 0
		EndIf
		
		If nNrPlan > 0

			For nCont := 0 To nNrPlan - 1
			
				If nCont == 0
					cCNARev := Space(3)
				Else
					cCNARev := StrZero(nCont,3)
				EndIf

				cChave := aDadosCNA[nA][1]+aDadosCNA[nA][2]+aDadosCNA[nA][4]+aDadosCNA[nA][3]
				
				dbSelectArea("CNB")
				CNB->(dbSetOrder(1))
				CNB->(dbSeek(cChave))
				
				While CNB->(!EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == cChave
				
					aAdd(aDadosCNB,{;
						CNB->CNB_FILIAL,;
						CNB->CNB_NUMERO,;
						cCNARev,;
						CNB->CNB_ITEM,;
						CNB->CNB_PRODUT,;
						CNB->CNB_DESCRI,;
						CNB->CNB_UM,;
						CNB->CNB_QUANT,;
						CNB->CNB_VLUNIT,;
						CNB->CNB_VLTOT,;
						CNB->CNB_DESC,;
						CNB->CNB_VLDESC,;
						CNB->CNB_CODMEN,;
						CNB->CNB_DTANIV,;
						CNB->CNB_CONORC,;
						CNB->CNB_CONTRA,;
						CNB->CNB_DTCAD,;
						CNB->CNB_DTPREV,;
						CNB->CNB_QTDMED,;
						CNB->CNB_CONTA,;
						CNB->CNB_PERC,;
						CNB->CNB_RATEIO,;
						CNB->CNB_TIPO,;
						CNB->CNB_ITSOMA,;
						CNB->CNB_PRCORI,;
						CNB->CNB_QTDORI,;
						CNB->CNB_QTRDAC,;
						CNB->CNB_QTRDRZ,;
						CNB->CNB_QTREAD,;
						CNB->CNB_VLREAD,;
						CNB->CNB_VLRDGL,;
						CNB->CNB_PERCAL,;
						CNB->CNB_FILHO,;
						CNB->CNB_SLDMED,;
						CNB->CNB_NUMSC,;
						CNB->CNB_ITEMSC,;
						CNB->CNB_QTDSOL,;
						CNB->CNB_SLDREC,;
						CNB->CNB_REALI,;
						CNB->CNB_DTREAL,;
						CNB->CNB_VLTOTR,;
						CNB->CNB_FLGCMS,;
						CNB->CNB_TE,;
						CNB->CNB_TS,;
						CNB->CNB_COPMED,;
						CNB->CNB_ULTAVA,;
						CNB->CNB_PROXAV,;
						CNB->CNB_ITMDST,;
						CNB->CNB_ITEMCT,;
						CNB->CNB_GERBIN,;
						CNB->CNB_BASINS,;
						CNB->CNB_FILORI,;
						CNB->CNB_XPOST0,;
						CNB->CNB_XREL;
					})
				
					CNB->(dbSkip())
				End				
				
				CNB->(dbCloseArea())
				
			Next nCont

		EndIf
	
	Next nA
	
	dbSelectArea("CNB")
	
	For nB := 1 To Len(aDadosCNB) 
		
		RecLock("CNB",.T.)
		
			CNB->CNB_FILIAL := aDadosCNB[nB][1]
			CNB->CNB_NUMERO := aDadosCNB[nB][2]
			CNB->CNB_REVISA := aDadosCNB[nB][3]
			CNB->CNB_ITEM 	:= aDadosCNB[nB][4]
			CNB->CNB_PRODUT := aDadosCNB[nB][5]
			CNB->CNB_DESCRI := aDadosCNB[nB][6]
			CNB->CNB_UM 	:= aDadosCNB[nB][7]
			CNB->CNB_QUANT 	:= aDadosCNB[nB][8]
			CNB->CNB_VLUNIT := aDadosCNB[nB][8]
			CNB->CNB_VLTOT 	:= aDadosCNB[nB][10]
			CNB->CNB_DESC 	:= aDadosCNB[nB][11]
			CNB->CNB_VLDESC := aDadosCNB[nB][12]
			CNB->CNB_CODMEN := aDadosCNB[nB][13]
			CNB->CNB_DTANIV := aDadosCNB[nB][14]
			CNB->CNB_CONORC := aDadosCNB[nB][15]
			CNB->CNB_CONTRA := aDadosCNB[nB][16]
			CNB->CNB_DTCAD 	:= aDadosCNB[nB][17]
			CNB->CNB_DTPREV := aDadosCNB[nB][18]
			CNB->CNB_QTDMED := aDadosCNB[nB][19]
			CNB->CNB_CONTA 	:= aDadosCNB[nB][20]
			CNB->CNB_PERC 	:= aDadosCNB[nB][21]
			CNB->CNB_RATEIO := aDadosCNB[nB][22]
			CNB->CNB_TIPO 	:= aDadosCNB[nB][23]
			CNB->CNB_ITSOMA := aDadosCNB[nB][24]
			CNB->CNB_PRCORI := aDadosCNB[nB][25]
			CNB->CNB_QTDORI := aDadosCNB[nB][26]
			CNB->CNB_QTRDAC := aDadosCNB[nB][27]
			CNB->CNB_QTRDRZ := aDadosCNB[nB][28]
			CNB->CNB_QTREAD := aDadosCNB[nB][29]
			CNB->CNB_VLREAD := aDadosCNB[nB][30]
			CNB->CNB_VLRDGL := aDadosCNB[nB][31]
			CNB->CNB_PERCAL := aDadosCNB[nB][32]
			CNB->CNB_FILHO 	:= aDadosCNB[nB][33]
			CNB->CNB_SLDMED := aDadosCNB[nB][34]
			CNB->CNB_NUMSC 	:= aDadosCNB[nB][35]
			CNB->CNB_ITEMSC := aDadosCNB[nB][36]
			CNB->CNB_QTDSOL := aDadosCNB[nB][37]
			CNB->CNB_SLDREC := aDadosCNB[nB][38]
			CNB->CNB_REALI 	:= aDadosCNB[nB][39]
			CNB->CNB_DTREAL := aDadosCNB[nB][40]
			CNB->CNB_VLTOTR := aDadosCNB[nB][41]
			CNB->CNB_FLGCMS := aDadosCNB[nB][42]
			CNB->CNB_TE 	:= aDadosCNB[nB][43]
			CNB->CNB_TS 	:= aDadosCNB[nB][44]
			CNB->CNB_COPMED := aDadosCNB[nB][45]
			CNB->CNB_ULTAVA := aDadosCNB[nB][46]
			CNB->CNB_PROXAV := aDadosCNB[nB][47]
			CNB->CNB_ITMDST := aDadosCNB[nB][48]
			CNB->CNB_ITEMCT := aDadosCNB[nB][49]
			CNB->CNB_GERBIN := aDadosCNB[nB][50]
			CNB->CNB_BASINS := aDadosCNB[nB][51]
			CNB->CNB_FILORI := aDadosCNB[nB][52]
			CNB->CNB_XPOST0 := aDadosCNB[nB][53]
			CNB->CNB_XREL	:= aDadosCNB[nB][54]		
		
		MsUnLock()
	Next nB
	
	CNB->(dbCloseArea())

	Alert('Concluído CNB')
Return