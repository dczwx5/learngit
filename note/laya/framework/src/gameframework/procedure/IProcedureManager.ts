namespace gameframework {
export namespace procedure {

/**
 * ...
 * @author
 */
export interface IProcedureManager{
	//get currentProcedure() : CProcedureBase;

	//get currentProcedureTime() : number;
	
	initialize(name:string, fsmManager:fsm.CFsmManager, procedures:fsm.CFsmState[]) : void ;

	startProcedure(typeProcedure:new()=>any) : void ;

	hasProcedure(typeProcedure:new()=>any) : boolean ;

	getProcedure(typeProcedure:new()=>any) : CProcedureBase ;
}
}
}