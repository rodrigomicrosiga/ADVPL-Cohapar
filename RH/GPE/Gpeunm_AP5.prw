/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!                            DADOS DO PROGRAMA                               !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! GPE - GESTÃO DE PESSOAL                                 !
+------------------+---------------------------------------------------------+
!Nome              ! Gpeunm                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina utilizada tanto para calculo da folha quanto para!
!                  ! rescisão.                                               !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Atualização       ! RODRIGO LACERDA P ARAUJO                                !
+------------------+---------------------------------------------------------+
!Data Atualização  ! 06/10/2011                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Efetuado alteração para buscar os valores corresponden- !
!                  ! tes ao plano de saude conforme faixa etária, da nova    !
!                  ! tabela S009, criada pela Totvs SP.                      !
!                  !                                                         !
!                  ! E separação dos descontos e reembolso, conforme a verba !
!                  ! informada no cadastro do dependente (RB_VBREEAM)        !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Data Atualização  ! 26/10/2011                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Criado um novo campo para informar o valor do percentual!
!                  ! que os funcionarios que tiverem Unimed mas que nao tem  !
!                  ! salario, recebam o valor correto de desconto e reembol- !
!                  ! so da Unimed, nas verbas 215 e 438                      !
!                  !                                                         !
!                  ! Alterado fonte para receber este novo campo e efetuar os!
!                  ! calculos necessarios.                                   !
+------------------+---------------------------------------------------------+
!Atualização       ! Clederson Bahl e Dotti                                  !
+------------------+---------------------------------------------------------+
!Data Atualização  ! 15/03/2012                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Alteradas as tabelas onde buscar informações de planos  !
!                  ! de saúde - As informações deixaram de ser buscadas na   !
!                  ! SRA (funcionários) e SRB (dependentes) e passaram a ser !
!                  ! retiradas da RHK (plano de saúde titular) e RHL (plano  !
!                  ! de saúde dependente.                                    !
!                  ! Alterada a forma de cálculo de desconto dos depententes:!
!                  ! A SOMA dos valores de desconto dos deps. é lançada em   !
!                  ! única verba.                                            !
+------------------+---------------------------------------------------------+
*/

#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 04/07/02
#include "topconn.ch"

User Function GPEUNM()        // incluido pelo assistente de conversao do AP5 IDE em 04/07/02
	// Código do plano de saúde usado para o cálculo | 001 == Unimed
	Local cCodPlan := "001"
	Local aArea    := GetArea()   
	Local aAreaSRV := SRV->(GetArea())
	Local aAreaRCC := RCC->(GetArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SetPrvt("_NORDSRX,_NFAIXAE,_NFAIXAEF,_NFAIXARE,_CCODUNI,_CCODUNIF")
	SetPrvt("_CFAIXA,_NVALOR,_NPERC,_NVALORDEP,_NPERFUN,_NSALARIO,_NVLRTOTD,_nVLRTOTR")
	SetPrvt("_NVALORRF,CALC,_NVALORRD,cQuery,_nPercent")
	
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³GPEUNM    ³ Autor ³ Rita Pimentel         ³ Data ³ 04.12.00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³C lculo Assistˆncia M‚dica UNIMED - COHAPAR                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³Roteiro de Calculo -> FOL252                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Observa‡„o³- Executar o roteiro apos o original (Ass.Med.) MICROSIGA   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Manuten‡„o³                                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	DbSelectArea("SRX") // Parametros
	_nOrdSRX := SRX->(dbSetOrder())
	DbSetOrder(1)
	SRX->(DbGoTop())    
	
	DbSelectArea("RCC") // Parametros
	_nOrdRCC := RCC->(dbSetOrder())
	DbSetOrder(1)
	RCC->(DbGoTop())
	
	Store 0.00 to _nValor,_nValordep,_nPerFun,_nValorrf,_nVlrTotD,_nVlrTotR
	_nFaixae  := 0
	_nFaixaef := 0
	_nFaixare := 0
	_cCoduni  := "   "
	_cCodunif := "   "
	_cFaixa   := " "
	
	// Neste momento a tabela SRA está posicionada no funcionário em questão
	dbSelectArea("RHK")
	RHK->(dbSetOrder(01))
	RHK->(dbGoTop())

	// Se for encontrada a matrícula na tabela de planos ativos, faz o cálculo
	// Filial + Matrícula + Tipo do fornecedor (Sempre "1" para planos de saúde) + Código do fornecedor (tabela RCC - S016)
	If RHK->(dbSeek(xFilial("RHK") + SRA->RA_MAT + "1" + cCodPlan)) .And. RHK->RHK_TPPLAN == "2"
	//If (SRA->RA_TIPAMED=='2') //se tiver assistencia médica faz o calculo		
	
		//********************************************************************************************************************************
		// DESCONTO VALOR FUNCIONARIO - Plano
		//********************************************************************************************************************************
		//_nFaixaef := Int(Round(Int((dDataBase-SRA->RA_NASC)/365.2500),2)) // Checa Faixa Etaria do Funcionario
		_nFaixaef := ClIdade(SRA->RA_NASC,dDataBase)
	   	//_cCodunif := SRA->RA_ASMEDIC
	   	_cCodunif := RHK->RHK_PLANO
		_cFaixa   := Faixa(_nFaixaef)

		cQuery := "SELECT RCC_CONTEU "
		cQuery += "FROM " + RETSQLNAME("RCC") + " "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
		cQuery += "AND RCC_CODIGO = 'S009' "
		cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '" + Alltrim(_cCodunif) + "' "
		cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(str(_cFaixa)) + "' "
		cQuery += "ORDER BY RCC_CONTEU "
				
		If ( SELECT("TRB") ) > 0
			dbSelectArea("TRB")
			TRB->(dbCloseArea())
		EndIf
        
		TCQUERY cQuery NEW ALIAS "TRB"
		
		dbSelectArea("TRB")
		TRB->(dbGoTop())
		If TRB->(!Eof())
	      	_nValor:=  Val(SUBSTR(TRB->RCC_CONTEU,32,6))
	      	_nPerc := (Val(SUBSTR(TRB->RCC_CONTEU,62,7)) / 100)
	      	_nValor:= _nValor * _nPerc
	      	_cVeDes:= Posicione("SRV",2,xFilial("SRV")+"049","RV_COD")  //Verba correspondente ao ID 049				//Incluido por RLPA
	      	//fGeraVerba(_cVeDes,_nValor,,,,,,,,,.T.) 					// gera verba de desconto UNIMED para o titular	//Incluido por RLPA

		   	
		   	//********************************************************************************************************************************
		    // DESCONTO VALOR DEPENDENTE - Plano
		   	//********************************************************************************************************************************
		   	// Posiciona a tabela de dependentes
		   	dbSelectArea("RHL")
		   	RHL->(dbSetOrder(01))
		   	RHL->(dbGoTop())
		   	RHL->(dbSeek(RHK->RHK_FILIAL + RHK->RHK_MAT + "1" + cCodPlan))
		   	
		   	SRB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT,.T.))
		   	
		   	Do While RHK->RHK_FILIAL == RHL->RHL_FILIAL .and. RHK->RHK_MAT == RHL->RHL_MAT
		   	//Do While SRA->RA_FILIAL==SRB->RB_FILIAL .and. SRA->RA_MAT==SRB->RB_MAT		
		    	//_nFaixae :=Int(Round(int((dDataBase-SRB->RB_DTNASC)/365.2500),2)) // Verifica Faixa Etaria dos Dependentes
		    	_nFaixae := ClIdade(SRB->RB_DTNASC,dDataBase) // Verifica Faixa Etaria dos Dependentes
		      	//_cCoduni := Alltrim(SRB->RB_CODAMED)
		      	_cCoduni := Alltrim(RHL->RHL_PLANO)
		      	_cFaixae := Faixa(_nFaixae)
		      	
				cQuery := "SELECT RCC_CONTEU "
				cQuery += "FROM " + RETSQLNAME("RCC") + " "
				cQuery += "WHERE D_E_L_E_T_ <> '*' "
				cQuery += "AND RCC_CODIGO = 'S009' "
				cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '" + Alltrim(_cCoduni) + "' "
				cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(str(_cFaixae)) + "' "			
				cQuery += "ORDER BY RCC_CONTEU "
				
				If ( SELECT("TRB2") ) > 0
					dbSelectArea("TRB2")
					TRB2->(dbCloseArea())
				EndIf

				TCQUERY cQuery NEW ALIAS "TRB2"
				
				dbSelectArea("TRB2")
				TRB2->(dbGoTop())
				If TRB2->(!Eof())
		        	_nValordep := Val(SUBSTR(TRB2->RCC_CONTEU,44,6))
		         	_nPerc     := (Val(SUBSTR(TRB2->RCC_CONTEU,69,7)) / 100) 
		           	_nValordep := _nValordep * _nPerc		
				EndIf
				// Alteração: O cálculo da verba dos dependentes agora é SOMADA 
				_nVlrTotD += _nValordep
				
				TRB2->(dbCloseArea())					      	

		      	RHL->(DbSkip())
		      	SRB->(DbSkip())
		    EndDo
		    

		  	//PESQUISAR QUAL A VERBA DE DESCONTO PERTENCE AO DEPENDENTE ATUAL E INFORMAR NO FGERAVERBA()
	      	//fGeraVerba(SRB->RB_VBDESAM,_nValordep,,,,,,,,,.T.) // gera verba de desconto UNIMED correspondente ao dependente
	      	
	      	// O total da SOMA dos descontos dos dependentes é lançado como UMA verba
	      	//fGeraVerba(RHK->RHK_PDDAGR,_nVlrTotD,,,,,,,,,.T.) // gera verba de desconto UNIMED correspondente ao dependente
		
		   
		   // REEMBOLSO FUNCIONARIO		   
		   //********************************************************************************************************************************
		   // Verifica faixa salarial e atribui valor do percentual de reembolso
		   //********************************************************************************************************************************
		                                                         		
		   	_nPerFun  := 0
		   	_nSalario := 0.00 
		   	_nPercent := 0
		
		   	If val(SRA->RA_MAT) > 19000 //diretores e comissionados
		      _nSalario := 0
		      _nPercent := SRA->RA_PERCUNM //campo onde estará informado o percentual para calculo na unimed
		   	Else
		      _nSalario := SRA->RA_SALARIO
		      _nPerFun  := 0
		   	EndIf  
		    
			
		   	SRX->(DbGoTop())		
		   	SRX->(DbSeek(xFilial("SRX") + "RE"))
		   	Do While SRX->RX_TIP == "RE" .AND. SRX->(!Eof())
		      	If _nSalario > Val(subs(SRX->RX_TXT,1,12)) .AND. _nSalario <= Val(Subs(SRX->RX_TXT,13,12))
		         	_nPerFun := (Val(Subs(SRX->RX_TXT,25,5)) / 100)
		      	elseif _nSalario == 0                    //condição para quem não tem salario
		      		_nPerFun :=  _nPercent / 100        //Criado o parametro para os funcionarios que nao tem salario
		      	                                        //neste parametro será informado o percentual correspondente para efetuar o calculo.
		      	EndIf
		      	SRX->(DbSkip())
		   	EndDo
		
			If SRA->RA_SEXO == "M"
				cQuery := "SELECT RCC_CONTEU "     	
				cQuery += "FROM " + RETSQLNAME("RCC") + " "
				cQuery += "WHERE D_E_L_E_T_ <> '*' "
				cQuery += "AND RCC_CODIGO = 'S009' "
				cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '09' "
				cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(str(_cFaixa)) + "' "			
				cQuery += "ORDER BY RCC_CONTEU "
				
				If ( SELECT("TRB3") ) > 0
					dbSelectArea("TRB3")
					TRB3->(dbCloseArea())
				EndIf
		
				TCQUERY cQuery NEW ALIAS "TRB3"
				
				dbSelectArea("TRB3")
				TRB3->(dbGoTop())
				If TRB3->(!Eof())			      	
		       		_nValorrf:= Val(SUBSTR(TRB3->RCC_CONTEU,32,6))
	         		_nPerc   := (Val(SUBSTR(TRB3->RCC_CONTEU,62,7)) / 100)
	         		_nValorrf:= _nValorrf * _nPerc
	         		_nValorrf:= _nValorrf * _nPerFun
				EndIf
		      	TRB3->(dbCloseArea())
		   	Else
				//If Alltrim(SRA->RA_ASMEDIC) == "08" .or. Alltrim(SRA->RA_ASMEDIC) == "10"
				If Alltrim(RHK->RHK_PLANO) == "08" .or. Alltrim(RHK->RHK_PLANO) == "10"
					cQuery := "SELECT RCC_CONTEU "
					cQuery += "FROM " + RETSQLNAME("RCC") + " "
					cQuery += "WHERE D_E_L_E_T_ <> '*' "
					cQuery += "AND RCC_CODIGO = 'S009' "
					cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '08' "
					cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(Str(_cFaixa)) + "' "			
					cQuery += "ORDER BY RCC_CONTEU "
					
					If ( SELECT("TRB4") ) > 0
						dbSelectArea("TRB4")
						TRB4->(dbCloseArea())
					EndIf
			
					TCQUERY cQuery NEW ALIAS "TRB4"
					
					dbSelectArea("TRB4")
					TRB4->(dbGoTop())
					
					If TRB4->(!Eof())			      	
			            _nValorrf:= Val(SUBSTR(TRB4->RCC_CONTEU,32,6))
			            _nPerc   := Val(SUBSTR(TRB4->RCC_CONTEU,62,7))/100
			            _nValorrf:= _nValorrf * _nPerc
	    		        _nValorrf:= _nValorrf * _nPerFun
					EndIf
				 	TRB4->(dbCloseArea())
			    Else
					cQuery := "SELECT RCC_CONTEU "
					cQuery += "FROM " + RETSQLNAME("RCC") + " "
					cQuery += "WHERE D_E_L_E_T_ <> '*' "
					cQuery += "AND RCC_CODIGO = 'S009' "
					cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '09' "
					cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(Str(_cFaixa)) + "' "			
					cQuery += "ORDER BY RCC_CONTEU "
					
					If ( SELECT("TRB5") ) > 0
						dbSelectArea("TRB5")
						TRB5->(dbCloseArea())
					EndIf
			
					TCQUERY cQuery NEW ALIAS "TRB5"
					
					dbSelectArea("TRB5")
					TRB5->(dbGoTop())
					If TRB5->(!Eof())			      	
			            _nValorrf:= Val(SUBSTR(TRB5->RCC_CONTEU,32,6))
			            _nPerc   := Val(SUBSTR(TRB5->RCC_CONTEU,62,7))/100
			            _nValorrf:= _nValorrf * _nPerc
	    		        _nValorrf:= _nValorrf * _nPerFun	         		
					EndIf		
					TRB5->(dbCloseArea())
		    	EndIf
		   	EndIf
		    
		    //GRAVAR A VERBA DE REEMBOLSO DO TITULAR
		    fGeraVerba("215",_nValorrf,,,,,,,,,.T.) 
		
			
		   	// REEMBOLSO DOS DEPENDENTES
		   	
		   	SRB->(dbSetOrder(01))
		   	SRB->(dbGoTop())
		   	SRB->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT,.T.))
		   	
		   	RHL->(dbSetOrder(01))
		   	RHL->(dbGoTop())
		   	RHL->(dbSeek(RHK->RHK_FILIAL + RHK->RHK_MAT + "1" + cCodPlan))
		   	
			Do While RHK->RHK_FILIAL == RHL->RHL_FILIAL .And. RHK->RHK_MAT == RHL->RHL_MAT
			
				//IF SRB->RB_REEMB != "4"
				// RHL->RHL_REEMB -> Campo customizado 
		   		IF RHL->RHL_REEMB != "4"
		        	//_nFaixae  := int(Round(int((dDataBase-SRB->RB_DTNASC)/365.2500),2))
		        	_nFaixae := ClIdade(SRB->RB_DTNASC,dDataBase) // Verifica Faixa Etaria dos Dependentes
		         	_nFaixare := _nFaixae       
		         	_nFaixae  := Faixa(_nFaixae)	         	
		         	_cCoduni := Alltrim(RHL->RHL_PLANO)
		         	
		         	calc := .F.         
		         	IF RHL->RHL_REEMB == "2" .and. _nFaixare <=21 // ate 21 anos
		            	calc := .T.
		         	ElseIf RHL->RHL_REEMB == "3" .and. _nFaixare <=24 // ate 24 anos
		            	calc := .T.
		         	ElseIf RHL->RHL_REEMB == "1"
		            	calc := .T.
		         	EndIf
		         	
		         	If calc
		            	_cFaixa   := Alltrim(str(_nFaixae))
		         		If RHL->RHL_REEMB == "1" .and. (_cCoduni == "08" .or. _cCoduni == "10")
							cQuery := "SELECT RCC_CONTEU "
							cQuery += "FROM " + RETSQLNAME("RCC") + " "
							cQuery += "WHERE D_E_L_E_T_ <> '*' "
							cQuery += "AND RCC_CODIGO = 'S009' "
							cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '08' "
							cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(_cFaixa) + "' "			
							cQuery += "ORDER BY RCC_CONTEU "
							
							If ( SELECT("TRB6") ) > 0
								dbSelectArea("TRB6")
								TRB6->(dbCloseArea())
							EndIf
					
							TCQUERY cQuery NEW ALIAS "TRB6"
							
							dbSelectArea("TRB6")
							TRB6->(dbGoTop())
							If TRB6->(!Eof())			      	             
					            _nValorrd:= Val(SUBSTR(TRB6->RCC_CONTEU,44,6))
					            _nPerc   := Val(SUBSTR(TRB6->RCC_CONTEU,69,7))/100
					            _nValorrd:= _nValorrd * _nPerc
			    		        _nValorrd:= _nValorrd * _nPerFun 
							EndIf
							TRB6->(dbCloseArea())			        
		            	Else                        
							cQuery := "SELECT RCC_CONTEU "
							cQuery += "FROM " + RETSQLNAME("RCC") + " "
							cQuery += "WHERE D_E_L_E_T_ <> '*' "
							cQuery += "AND RCC_CODIGO = 'S009' "
							cQuery += "AND SUBSTRING(RCC_CONTEU,1,2) = '09' "
							cQuery += "AND SUBSTRING(RCC_CONTEU,24,2)= '" + Alltrim(_cFaixa) + "' "			
							cQuery += "ORDER BY RCC_CONTEU "
							
							If ( SELECT("TRB6") ) > 0
								dbSelectArea("TRB6")
								TRB6->(dbCloseArea())
							EndIf
					
							TCQUERY cQuery NEW ALIAS "TRB6"
							
							dbSelectArea("TRB6")
							TRB6->(dbGoTop())
							If TRB6->(!Eof())			      	
					            _nValorrd:= Val(SUBSTR(TRB6->RCC_CONTEU,44,6))
					            _nPerc   := Val(SUBSTR(TRB6->RCC_CONTEU,69,7))/100
					            _nValorrd := _nValorrd * _nPerc
		                  		_nValorrd := _nValorrd * _nPerFun
							EndIf
							
							TRB6->(dbCloseArea())			        		            	
		            	EndIf             
		     
				    	//GRAVAR A VERBA DE REEMBOLSO PARA CADA DEPENDENTE, LOCALIZAR NO CADASTRO A VERBA CORRESPONDENTE
				    	//fGeraVerba(SRB->RB_VBREEAM,_nValorrd,,,,,,,,,.T.) // gera verba de reembolso UNIMED
				    	
				    	// Geração do reembolso por dependente 
				    	// RHL->RHL_VBREAM -> Campo customizado
	       	  			//fGeraVerba(RHL->RHL_VBREAM,_nVlrTotR,,,,,,,,,.T.) // gera verba de reembolso UNIMED
					_nVlrTotR += _nValorrd
		         	Endif
		      	EndIf
		      	
		      // Geração da SOMA do reembolso dos dependentes	
		      // RHL->RHL_VBREAM -> Campo customizado
	       	  fGeraVerba(RHL->RHL_VBREAM,_nVlrTotR,,,,,,,,,.T.) // gera verba de reembolso UNIMED
	       	  
		      RHL->(DbSkip())
		      SRB->(DbSkip())
		   	Enddo
		    
		EndIf   
		TRB->(dbCloseArea())
		
	Endif  
 
	srx->(dbSetOrder(_nOrdSRX))
	RetIndex("SRB")
	dbCloseArea("RCC")
	dbCloseArea("SRV")
	
	RestArea(aAreaRCC)
	RestArea(aAreaSRV)
	RestArea(aArea)
Return      

//identificar a faixa correspondente titular/dependente
Static Function Faixa(_nFaixa)
	Local _nFaixae:= 0
   	If _nFaixa < 19
      	_nFaixae := 18
   	ElseIf _nFaixa < 24
       	_nFaixae := 23
   	ElseIf _nFaixa < 29
       	_nFaixae := 28
   	ElseIf _nFaixa < 34
       	_nFaixae := 33
   	ElseIf _nFaixa < 39
       	_nFaixae := 38
   	ElseIf _nFaixa < 44
       	_nFaixae := 43
   	ElseIf _nFaixa < 49
       	_nFaixae := 48
   	ElseIf _nFaixa < 54
       	_nFaixae := 53
   	ElseIf _nFaixa < 59
       	_nFaixae := 58     
   	Else
      	_nFaixae := 99
   	EndIf
Return(_nFaixae)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! ClIdade	! Autor !Gilson Lima 		 ! Data ! 19/06/2015     !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao cálculo da idade baseada na Dt. de Nascimento			 !
+----------------------------------------------------------------------------*/
User Function ClIdade(dDtNasc, dDtCalc)
	
	Local cMesDiaNasc	:= ''
	Local cMesDiaBase	:= ''
	Local cIdade		:= ''
	Local nIdade		:= 0
	
	cMesDiaNasc	:= StrZero(Month(dDtNasc),2) + StrZero(Day(dDtNasc),2)
	cMesDiaBase	:= StrZero(Month(dDtCalc),2) + StrZero(Day(dDtCalc),2)
	nIdade		:= Year(dDtCalc) - Year(dDtNasc)
	
	If (cMesDiaNasc > cMesDiaBase)
		nIdade --
	EndIf
	
Return(nIdade)