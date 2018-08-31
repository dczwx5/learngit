package core.game.sequentiaProcedure
{
	import core.framework.CAppSystem;
	import core.sequentiaProcedure.CSequentialProcedureManager;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class CSequentiaProcedureSystem extends CAppSystem {
		public function CSequentiaProcedureSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			m_procedureManager = new CSequentialProcedureManager();
		}
		protected override function onStart() : void {
			super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();

			m_procedureManager.destroy();

			
			m_procedureManager = null;
		}

		public function addSequential(handler:Handler, checkFinishHandler:Handler) : void {
			m_procedureManager.addSequential(handler, checkFinishHandler);
		}

		private var m_procedureManager:CSequentialProcedureManager;
	}

}