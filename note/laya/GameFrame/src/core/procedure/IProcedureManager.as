package core.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsmManager;

	/**
	 * ...
	 * @author
	 */
	public interface IProcedureManager{
		function get currentProcedure() : CProcedureBase;

		function get currentProcedureTime() : Number;
		
		function initialize(name:String, fsmManager:IFsmManager, procedures:Array) : void ;

		function startProcedure(typeProcedure:Class) : void ;

		function hasProcedure(typeProcedure:Class) : Boolean ;

		function getProcedure(typeProcedure:Class) : CProcedureBase ;
	}

}