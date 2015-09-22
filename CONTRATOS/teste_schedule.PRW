#Include 'Protheus.ch'
#Include 'TbiConn.ch'

User Function TestSch(aParam)

	PREPARE ENVIRONMENT EMPRESA aParam[4] FILIAL aParam[5]
	
	Conout('Empresa Logada '+cEmpAnt)
	Conout('Filial Logada '+cFilAnt)
	VarInfo('Valores repassados para a rotina',aParam)
	
	RESET ENVIRONMENT
	
	aParam:=aSize(aParam,0)
	aParam:=Nil
	

Return
