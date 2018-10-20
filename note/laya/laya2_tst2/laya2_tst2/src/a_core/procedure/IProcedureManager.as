package a_core.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsmManager;

	/**
	 * ...
	 * @author
	 */
	public interface IProcedureManager{
		function get currentProcedure() : CProcedureBase;

		function get currentProcedureTime() : Number;
		
		function initialize(name:String, fsmManager:CFsmManager, procedures:Array) : void ;

		function startProcedure(typeProcedure:Class) : void ;

		function hasProcedure(typeProcedure:Class) : Boolean ;

		function getProcedure(typeProcedure:Class) : CProcedureBase ;
	}

}