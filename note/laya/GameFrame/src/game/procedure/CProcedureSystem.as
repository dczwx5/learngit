package game.procedure
{
	import core.framework.CAppSystem;
	import core.game.fsm.CFsmSystem;
	import core.procedure.CProcedureManager;
	import game.procedure.CProcedureEntry;
	import game.procedure.CProcedureLaunch;
	import game.procedure.CProcedureCheckVersion;
	import game.procedure.CProcedureLoadDataTable;
	import game.procedure.CProcedureStageStart;
	import game.procedure.CProcedureChangeScene;
	import game.procedure.CProcedureLoginMenu;
	import game.procedure.CProcedureGaming;

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
				new CProcedureLoginMenu(), new CProcedureGaming()
			];
			m_procedureManager = fsmSystem.createProcedure("gameProcedure", procedureList);
			
		}
		protected override function onStart() : void {
			super.onStart();

			
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		private var m_procedureManager:CProcedureManager;
	}

}