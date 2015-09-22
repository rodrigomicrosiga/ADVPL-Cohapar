#include "rwmake.ch"
#include "TOPCONN.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Modulo            !~Gestao de Pessoal                                       !
+------------------+---------------------------------------------------------+
!Nome              ! RELFUNCP                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Relatório Geral De Funcionários Personalizado           !
+------------------+---------------------------------------------------------+
!Autor             ! Kelson Santos Martins                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/12/2012                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

************************
User Function RELFUNCP()
************************
************************

Local oRelFuncPer
Private cPerg := "RELFUNCP  " // 10 posiçoes para respeitar a montagem de parâmetros.
Private nVlrGeral := 0
//--Cria as perguntas		
CriaSx1()
Pergunte(cPerg, .F.)

oRelFuncPer := RELFUNCPR()
oRelFuncPer:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! RELFUNCP                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Monta a estrutura do relatório                          !
+------------------+---------------------------------------------------------+
!Autor             ! Kelson Martins                                          !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 17/12/2012                                              !
+------------------+--------------------------------------------------------*/
Static Function RELFUNCPR()

Local cProg   := "RELFUNCP"
Local cTitle  := OemToAnsi("Relatório de Funcionários Personalizado")
Local oRelFuncPer
Private oSessao
Private oBreak 
Private oBreak2
Private oBreak3
Private oBreak4
Private oBreak5


//Criacao do componente de impressao
oRelFuncPer := TReport():New(cProg,cTitle,cPerg,{|oRelFuncPer| RELFUNCPRS(oRelFuncPer)},cTitle)
oRelFuncPer:SetLandScape()

//--Definição das celulas
oSessao := TRSection():New(oRelFuncPer,"Funcionarios",{"SRA"})        
	TRCell():New(oSessao,"Superior1"  	,"CTT0","Nivel1","",6)
	TRCell():New(oSessao,"Superior"  	,"CTT0","Nivel2","",6)
	TRCell():New(oSessao,"Diretoria"  	,"CTT1","Nivel3","",6)          
	TRCell():New(oSessao,"Departamento" ,"CTT2","Nivel4","",6)
	TRCell():New(oSessao,"Setor"  	,"CTT3","Setor","",6)
	TRCell():New(oSessao,"NOME"   ,"SRA",,,35)
	TRCell():New(oSessao,"Matricula"  	,"SRA","Matricula","",6)
	TRCell():New(oSessao,"RA_ADMISSA" ,"SRA","Admissão","@D",10)	      
	TRCell():New(oSessao,"TempoServico"   ,"SRA","Anos","",10)
	TRCell():New(oSessao,"desc1"   ,"SRA","Cargo","",25)
	TRCell():New(oSessao,"desc2"   ,"SRA","Função","",25)
	TRCell():New(oSessao,"RA_SALARIO"   ,"SRA","Salario","@E 9,999,999.99")
	TRCell():New(oSessao,"AdTempoServico"   ,"SRA","ATS","@E 9,999,999.99",12)
	TRCell():New(oSessao,"FuncaoGratificada"   ,"SRA","FG","@E 9,999,999.99",12)
	TRCell():New(oSessao,"Total"   ,"SRA","Total","@E 9,999,999.99",12) 
	

Return(oRelFuncPer)

// Acha os dados 
Static Function RELFUNCPRS(oRelFuncPer)
***************************

Local oSessao := oRelFuncPer:Section(1)
Local cOrigem := ""
Local cAlias  := getNextAlias()
Local cQry := ""
Local _cSituac := ""
Local _cCateg := ""
Local cTotal := 0
Local aSitFunc := {}     
Local cAl := GetNextAlias()
dbSelectArea("SRA")

_cSituac := R001Param(mv_par09)
_cCateg := R001Param(mv_par10)
	
IF mv_par17 == 1     
	oBreak3 := TRBreak():New(oSessao,oSessao:Cell("Setor"),"Totalizador Setor",.F.)
	TRFunction():New(oSessao:Cell("TOTAL"),,"SUM",oBreak3,,,,.T.,.F.)
	TRFunction():New(oSessao:Cell("Setor"),,"COUNT",oBreak3,,,,.F.,.F.)			
ENDIF


IF mv_par16 == 1     
	oBreak2 := TRBreak():New(oSessao,oSessao:Cell("Departamento"),"Totalizador Nivel4",.F.)
	TRFunction():New(oSessao:Cell("TOTAL"),,"SUM",oBreak2,,,,.T.,.F.)
	TRFunction():New(oSessao:Cell("Departamento"),,"COUNT",oBreak2,,,,.F.,.F.)
ENDIF

IF mv_par15 == 1     
	oBreak := TRBreak():New(oSessao,oSessao:Cell("Diretoria"),"Totalizador Nivel3",.F.)
	TRFunction():New(oSessao:Cell("TOTAL"),,"SUM",oBreak,,,,.T.,.F.)
	TRFunction():New(oSessao:Cell("Diretoria"),,"COUNT",oBreak,,,,.F.,.F.)
ENDIF


IF mv_par14 == 1     
	oBreak4 := TRBreak():New(oSessao,oSessao:Cell("Superior"),"Totalizador Nivel2",.F.)
	TRFunction():New(oSessao:Cell("TOTAL"),,"SUM",oBreak4,,,,.T.,.F.)
	TRFunction():New(oSessao:Cell("Superior"),,"COUNT",oBreak4,,,,.F.,.F.)
ENDIF

IF mv_par13 == 1     
	oBreak5 := TRBreak():New(oSessao,oSessao:Cell("Superior1"),"Totalizador Nivel1",.F.)
	TRFunction():New(oSessao:Cell("TOTAL"),,"SUM",oBreak5,,,,.T.,.F.)
	TRFunction():New(oSessao:Cell("Superior1"),,"COUNT",oBreak5,,,,.F.,.F.)
ENDIF


//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oRelFuncPer:GetParam())

cQry := " SELECT * FROM "+RetSQLName("SRC") 	
cQry += " WHERE RC_DATA >= '" + DTOS(mv_par07) + "' "
cQry += " AND RC_DATA <=  '" + DTOS(mv_par08) + "' "
cQry := ChangeQuery(cQry)    
TcQuery cQry New Alias (cAlias)

nreg := Contar(cAlias,"!EOF()")

(cAlias)->(dbCloseArea())
//cAlias := getNextAlias()

if nreg > 0
oSessao:BeginQuery()
BeginSql Alias cAl
select 
ra_rescrai,
superior1, 
superior,
diretoria,
departamento,
setor,
ra_cc, 
RA_NOME as Nome,  
RA_ADMISSA,
RA_MAT as Matricula, 
TEMPO as TempoServico, 
desc1,
desc2,
CASE  WHEN SUM(RC_VALOR102) > 0 THEN SUM(RC_VALOR102) ELSE RA_SALARIO END as RA_SALARIO,
SUM(CASE  WHEN RC_PD = '103' THEN RC_VALOR103 ELSE 0 END) as AdTempoServico,
CASE WHEN ra_fgratif > 0 THEN ra_fgratif ELSE SUM(CASE  WHEN RC_PD = '300' THEN RC_VALOR300 ELSE 0 END) + SUM(CASE  WHEN RC_PD = '104' THEN RC_VALOR104 ELSE 0 END) + SUM(CASE  WHEN RC_PD = '117' THEN RC_VALOR117 ELSE 0 END)  + SUM(CASE  WHEN RC_PD = '308' THEN RC_VALOR308 ELSE 0 END) END as FuncaoGratificada, //,SUM(CASE  WHEN RC_PD = '300' THEN RC_VALOR300 ELSE 0 END) + SUM(CASE  WHEN RC_PD = '104' THEN RC_VALOR104 ELSE 0 END) + SUM(CASE  WHEN RC_PD = '117' THEN RC_VALOR117 ELSE 0 END)  + SUM(CASE  WHEN RC_PD = '308' THEN RC_VALOR308 ELSE 0 END) as FuncaoGratificada,
SUM(CASE  WHEN RC_PD = '104' THEN RC_VALOR104 ELSE 0 END)  + SUM(CASE  WHEN RC_PD = '300' THEN RC_VALOR300 ELSE 0 END) + SUM(CASE  WHEN RC_PD = '103' THEN RC_VALOR103 ELSE 0 END) + SUM(CASE  WHEN RC_PD = '117' THEN RC_VALOR117 ELSE 0 END)  + SUM(CASE  WHEN RC_PD = '308' THEN RC_VALOR308 ELSE 0 END) + CASE  WHEN SUM(RC_VALOR102) > 0 THEN SUM(RC_VALOR102) ELSE RA_SALARIO END as Total,
chefe
from
(
select   
superior1, 
superior,
diretoria,
departamento,
setor,  
ra_rescrai,
ra_nome,
ra_fgratif,
ra_mat,
CASE  WHEN RC_PD = '103' THEN RC_VALOR ELSE 0 END as RC_VALOR103,
CASE  WHEN RC_PD = '104' THEN RC_VALOR ELSE 0 END as RC_VALOR104,
CASE  WHEN RC_PD = '300' THEN RC_VALOR ELSE 0 END as RC_VALOR300,
CASE  WHEN RC_PD = '308' THEN RC_VALOR ELSE 0 END as RC_VALOR308,
CASE  WHEN RC_PD = '117' THEN RC_VALOR ELSE 0 END as RC_VALOR117,
CASE  WHEN RC_PD = '102' THEN RC_VALOR ELSE 0 END as RC_VALOR102,
rc_data,
ra_admissa,
tempo,
RA_CARGOC1,  
ra_cc,
ra_salario,
CASE  WHEN RC_PD = '308' THEN RC_PD WHEN RC_PD = '117' THEN RC_PD WHEN RC_PD = '103' THEN RC_PD WHEN RC_PD = '104' THEN RC_PD WHEN RC_PD = '300' THEN RC_PD WHEN RC_PD = '102' THEN RC_PD ELSE 0 END as RC_PD,
desc1,
desc2,
CHEFE
from
(
select
CASE WHEN CTT9.CTT_DESC01 = null then '  ' else substring(CTT9.CTT_DESC01,1,4) end AS SUPERIOR1,
CASE WHEN CTT0.CTT_DESC01 = null then '  ' else substring(CTT0.CTT_DESC01,1,4) end AS SUPERIOR,
CASE WHEN CTT1.CTT_DESC01 = null then '  ' else substring(CTT1.CTT_DESC01,1,4) end AS DIRETORIA,
CASE WHEN CTT2.CTT_DESC01 = null then '  ' else substring(CTT2.CTT_DESC01,1,4) end AS DEPARTAMENTO,
CASE WHEN CTT3.CTT_DESC01 = null then '  ' else substring(CTT3.CTT_DESC01,1,4) end AS SETOR,
RA_NOME, ra_fgratif, ra_rescrai,RA_CARGOC1, RA_MAT, RC_VALOR, RC_DATA, RA_ADMISSA, CASE WHEN DATEPART(dy,SRA.RA_ADMISSA) <= DATEPART(dy,GETDATE()) THEN DATEDIFF(yyyy,SRA.RA_ADMISSA,GETDATE()) ELSE DATEDIFF(yyyy,SRA.RA_ADMISSA,DATEADD(yy,-1,GETDATE())) END as TEMPO, RA_SALARIO, RC_PD, ra_cc, t1.rj_desc as desc1, t2.rj_desc as desc2,
CASE WHEN LEN(t2.RJ_LIDER) > 0 THEN 'TITULAR' END AS CHEFE
from %table:SRA% SRA, 
inner join %table:SRC% SRC on
rc_mat = RA_MAT
inner join %table:SRJ% as t1 on
t1.rj_funcao = ra_codfunc
left join %table:SRJ% as t2 on
t2.rj_funcao = ra_cargoc1  
LEFT OUTER JOIN %table:CTT% CTT9 ON
 CTT9.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,2)
AND CTT9.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT0 ON
 CTT0.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,3)
AND CTT0.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT1 ON
 CTT1.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,5)
AND CTT1.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT2 ON
 CTT2.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,7)
AND CTT2.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT3 ON
 CTT3.CTT_CUSTO = SRA.RA_CC
AND CTT3.D_E_L_E_T_ <> '*'
WHERE RA_FILIAL >= %Exp:MV_PAR01%
AND RA_FILIAL <= %Exp:MV_PAR02%
and RC_CC >= %Exp:MV_PAR03%
and RC_CC <= %Exp:MV_PAR04%
AND RA_MAT >= %Exp:MV_PAR05%
AND RA_MAT <= %Exp:MV_PAR06%
AND RA_SITFOLH IN %Exp:_cSituac%
AND RA_CATFUNC IN %Exp:_cCateg%
AND RA_NOME >= %Exp:MV_PAR11%
AND RA_NOME <= %Exp:MV_PAR12%
AND SRA.D_E_L_E_T_ = ' '
AND SRC.D_E_L_E_T_ = ' '
) b
) c
where desc1 <> 'PENSAO ALIMENTICIA' 
group by 
ra_rescrai,
superior1, 
superior,
setor,
departamento,
diretoria,
RA_NOME,
ra_fgratif,
RA_ADMISSA,
RA_MAT,
RA_CARGOC1,
TEMPO ,
desc1,
desc2,
ra_cc,
chefe,
RA_SALARIO
order by ra_cc,superior1,superior,diretoria, departamento, setor, chefe desc, ra_nome
//order by ra_cc,setor, departamento, diretoria, chefe desc, ra_nome
EndSql
oSessao:EndQuery() 

else              
oSessao:BeginQuery()
BeginSql Alias cAl
select
ra_rescrai,
superior1,
superior,
diretoria,
departamento,
setor,
ra_cc, 
RA_NOME as Nome,  
RA_ADMISSA,
RA_MAT as Matricula, 
TEMPO as TempoServico, 
desc1,
desc2, 
//SUM(CASE WHEN ISNULL(RA_CARGOC1,0) = 0 THEN RA_SALARIO ELSE RD_VALOR102 END) as RA_SALARIO, 
//SUM(CASE  WHEN RWhen Len(RA_CARGOC1) = 0 THEN RA_SALARIO ELSE RD_VALOR102 END) as RA_SALARIO, 
CASE  WHEN SUM(RD_VALOR102) > 0 THEN SUM(RD_VALOR102) ELSE RA_SALARIO END as RA_SALARIO,
//SUM(RD_VALOR102) as ADICIONAL,
//RA_SALARIO ,
SUM(CASE  WHEN RD_PD = '103' THEN RD_VALOR103 ELSE 0 END) as AdTempoServico,
SUM(CASE  WHEN RD_PD = '300' THEN RD_VALOR300 ELSE 0 END) + SUM(CASE  WHEN RD_PD = '104' THEN RD_VALOR104 ELSE 0 END) + SUM(CASE  WHEN RD_PD = '117' THEN RD_VALOR117 ELSE 0 END)  + SUM(CASE  WHEN RD_PD = '308' THEN RD_VALOR308 ELSE 0 END) as FuncaoGratificada,
SUM(CASE  WHEN RD_PD = '104' THEN RD_VALOR104 ELSE 0 END)  + SUM(CASE  WHEN RD_PD = '300' THEN RD_VALOR300 ELSE 0 END) + SUM(CASE  WHEN RD_PD = '103' THEN RD_VALOR103 ELSE 0 END) + SUM(CASE  WHEN RD_PD = '117' THEN RD_VALOR117 ELSE 0 END)  + SUM(CASE  WHEN RD_PD = '308' THEN RD_VALOR308 ELSE 0 END) + CASE  WHEN SUM(RD_VALOR102) > 0 THEN SUM(RD_VALOR102) ELSE RA_SALARIO END as Total,
chefe
from
(
select
ra_rescrai,
superior1, 
superior, 
diretoria,
departamento,
setor,
ra_nome,
ra_mat,
RA_CARGOC1,
CASE  WHEN RD_PD = '103' THEN RD_VALOR ELSE 0 END as RD_VALOR103,
CASE  WHEN RD_PD = '104' THEN RD_VALOR ELSE 0 END as RD_VALOR104,
CASE  WHEN RD_PD = '300' THEN RD_VALOR ELSE 0 END as RD_VALOR300,
CASE  WHEN RD_PD = '308' THEN RD_VALOR ELSE 0 END as RD_VALOR308,
CASE  WHEN RD_PD = '117' THEN RD_VALOR ELSE 0 END as RD_VALOR117,
CASE  WHEN RD_PD = '102' THEN RD_VALOR ELSE 0 END as RD_VALOR102,
rd_datpgt,
ra_admissa,
tempo,
ra_cc,
ra_salario,
CASE   WHEN RD_PD = '308' THEN RD_PD WHEN RD_PD = '117' THEN RD_PD WHEN RD_PD = '103' THEN RD_PD WHEN RD_PD = '104' THEN RD_PD WHEN RD_PD = '300' THEN RD_PD WHEN RD_PD = '102' THEN RD_PD ELSE 0 END as RD_PD, 
desc1,
desc2,
CHEFE
from
(
select 
CASE WHEN CTT9.CTT_DESC01 = null then '  ' else substring(CTT9.CTT_DESC01,1,4) end AS SUPERIOR1,
CASE WHEN CTT0.CTT_DESC01 = null then '  ' else substring(CTT0.CTT_DESC01,1,4) end AS SUPERIOR,
CASE WHEN CTT1.CTT_DESC01 = null then '  ' else substring(CTT1.CTT_DESC01,1,4) end AS DIRETORIA,
CASE WHEN CTT2.CTT_DESC01 = null then '  ' else substring(CTT2.CTT_DESC01,1,4) end AS DEPARTAMENTO,
CASE WHEN CTT3.CTT_DESC01 = null then '  ' else substring(CTT3.CTT_DESC01,1,4) end AS SETOR,
RA_NOME, ra_rescrai,RA_MAT, RD_VALOR, RD_DATPGT, RA_ADMISSA, CASE WHEN DATEPART(dy,SRA.RA_ADMISSA) <= DATEPART(dy,GETDATE()) THEN DATEDIFF(yyyy,SRA.RA_ADMISSA,GETDATE()) ELSE DATEDIFF(yyyy,SRA.RA_ADMISSA,DATEADD(yy,-1,GETDATE())) END as TEMPO, RA_SALARIO, RD_PD, ra_cc, t1.rj_desc as desc1, t2.rj_desc as desc2,RA_CARGOC1,
CASE WHEN LEN(t2.RJ_LIDER) > 0 THEN 'TITULAR' END AS CHEFE
from %table:SRA% SRA, 
inner join %table:SRD% SRD on
rd_mat = RA_MAT
inner join %table:SRJ% as t1 on
t1.rj_funcao = ra_codfunc
left join %table:SRJ% as t2 on
t2.rj_funcao = ra_cargoc1  
LEFT OUTER JOIN %table:CTT% CTT9 ON
 CTT9.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,2)
AND CTT9.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT0 ON
 CTT0.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,3)
AND CTT0.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT1 ON
 CTT1.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,2)
AND CTT1.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT2 ON
 CTT2.CTT_CUSTO = SUBSTRING(SRA.RA_CC,1,3)
AND CTT2.D_E_L_E_T_ <> '*'
LEFT OUTER JOIN %table:CTT% CTT3 ON
 CTT3.CTT_CUSTO = SRA.RA_CC
AND CTT3.D_E_L_E_T_ <> '*'
WHERE RA_FILIAL >= %Exp:MV_PAR01%
AND RA_FILIAL <= %Exp:MV_PAR02%
and RD_DATPGT >= %Exp:MV_PAR07%
and RD_DATPGT <= %Exp:MV_PAR08%
and RD_CC >= %Exp:MV_PAR03%
and RD_CC <= %Exp:MV_PAR04%
AND RA_MAT >= %Exp:MV_PAR05%
AND RA_MAT <= %Exp:MV_PAR06%
AND RA_SITFOLH IN %Exp:_cSituac%
AND RA_CATFUNC IN %Exp:_cCateg%
AND RA_NOME >= %Exp:MV_PAR11%
AND RA_NOME <= %Exp:MV_PAR12%
AND SRA.D_E_L_E_T_ = ' '
AND SRD.D_E_L_E_T_ = ' '
) b
) c
where desc1 <> 'PENSAO ALIMENTICIA' 
group by
ra_rescrai,
superior1,  
superior,  
setor,    
departamento,
diretoria,
RA_NOME,
RA_ADMISSA,
RA_MAT,
RA_CARGOC1,
TEMPO ,
desc1,
desc2,
ra_cc,
chefe,
RA_SALARIO                                                          
order by ra_cc,superior1,superior,diretoria, departamento, setor, chefe desc, ra_nome
//order by ra_cc,diretoria, departamento, setor, chefe desc, ra_nome
EndSql
oSessao:EndQuery() 
endif

oRelFuncPer:SetMeter( (cAl)->(RecCount()) )
oSessao:Init()
While !(cAl)->(Eof())

IF (cAl)->ra_rescrai $ '30/31'
	(cAl)->(dbSkip())	
ELSE
	oSessao:PrintLine()
	(cAl)->(dbSkip())	
ENDIF

	
End 
   
oSessao:Finish()
Return NIL

Static Function CriaSx1()
PutSx1(cPerg,"01","Filial De   	   ?","","","mv_ch1","C",2,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"02","Filial Até      ?","","","mv_ch2","C",2,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"03","Centro de Custo De   ?","","","mv_ch3","C",9,0,0,"G","","CTT","","","mv_par03","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"04","Centro de Custo Até  ?","","","mv_ch4","C",9,0,0,"G","","CTT","","","mv_par04","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"05","Matricula De    ?","","","mv_ch5","C",6,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"06","Matricula Até   ?","","","mv_ch6","C",6,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"07","Período De      ?","","","mv_ch7","D",8,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"08","Período Até     ?","","","mv_ch8","D",8,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","","","","")                           
PutSx1(cPerg,"09" ,"Situações ?","¿Situaciones ?","Status ?","MV_CH9","C",05,0,0,"G","fSituacao","","","","mv_par9"	,"","","","","","","","","",""		   		,""		,""		,""		,""		,""		," "	,""		,""		,""		,""		,""		,""		,""		,""		,""			,""			,""			,".RHSITUA.")
PutSx1(cPerg,"10" ,"Categorias ?","¿Categorias ?","Categories ?","MV_CH10","C",15,0,0,"G","fCategoria","","","","mv_par10","","","","","",""		,""		,""	   			,""				,""		   		,""		,""		,""		,""		,""		," "	,""		,""		,""		,""		,""		,""		,""		,""		,""			,""			,""			,".RHCATEG.") 
PutSx1(cPerg,"11","Nome De	       ?","","","mv_ch11","C",10,0,0,"G","","","","","mv_par11","","","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"12","Nome Até   	   ?","","","mv_ch12","C",10,0,0,"G","","","","","mv_par12","","","","","","","","","","","","","","","","","","","")                                                 
PutSx1(cPerg,"13","Totalizar Nivel 1   ?","","","mv_ch13","N",1 ,0,0,"C","","","","","mv_par13","Sim","Sim","Sim","Não","Não","Não","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
PutSx1(cPerg,"14","Totalizar Nivel 2   ?","","","mv_ch14","N",1 ,0,0,"C","","","","","mv_par14","Sim","Sim","Sim","Não","Não","Não","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
PutSx1(cPerg,"15","Totalizar Nivel 3   ?","","","mv_ch15","N",1 ,0,0,"C","","","","","mv_par15","Sim","Sim","Sim","Não","Não","Não","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
PutSx1(cPerg,"16","Totalizar Nivel 4   ?","","","mv_ch16","N",1 ,0,0,"C","","","","","mv_par16","Sim","Sim","Sim","Não","Não","Não","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
PutSx1(cPerg,"17","Totalizar Setor     ?","","","mv_ch17","N",1 ,0,0,"C","","","","","mv_par17","Sim","Sim","Sim","Não","Não","Não","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
Return

Static Function R001Param(_pParam)
	Local _cRet := ""
	
	For _nI := 1 To Len(_pParam)
		If !Empty(_cRet)
			_cRet += ","
		Endif
		_cRet += "'" + Substr(_pParam,_nI,1) + "'"
	Next _nI
	_cRet := "%(" + _cRet + ")%"
Return(_cRet)