package game.procedure
{
	import a_core.framework.CAppSystem;
	import a_core.game.fsm.CFsmSystem;
	import a_core.procedure.CProcedureManager;
	import game.procedure.CProcedureEntry;
	import game.procedure.CProcedureLaunch;
	import game.procedure.CProcedureCheckVersion;
	import game.procedure.CProcedureLoadDataTable;
	import game.procedure.CProcedureStageStart;
	import game.procedure.CProcedureChangeScene;
	import game.procedure.CProcedureLoginMenu;
	import game.procedure.CProcedureGaming;
	import game.procedure.CProcedureResult;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureSystem extends CAppSystem {
		public function CProcedureSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
			
			var fsmSystem:CFsmSystem = stage.getSystem(CFsmSystem) as CFsmSystem;
			var procedureList:Array = [
				new CProcedureEntry(), new CProcedureLaunch(), new CProcedureCheckVersion(), new CProcedureLoadDataTable, 
				new CProcedureStageStart() , new CProcedureChangeScene(),
				new CProcedureLoginMenu(), new CProcedureGaming(), new CProcedureResult(),
				new CProcedureLoadResource()
			];
			m_procedureManager = fsmSystem.createProcedure("gameProcedure", procedureList);
			
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			m_procedureManager.startProcedure(CProcedureEntry);

			return ret;
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		private var m_procedureManager:CProcedureManager;
	}

}