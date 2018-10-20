package usage
{
	import a_core.sequentiaProcedure.CSequentialProcedureManager;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class CSequentialProcedureUsage{
		
		public function CSequentialProcedureUsage(){
			m_index = 0;
			trace("CSequentialProcedureUsage ----------------------");
			var procedureManager:CSequentialProcedureManager = new CSequentialProcedureManager();
			procedureManager.addSequential(Handler.create(this, _login), null);
			procedureManager.addSequential(null, Handler.create(this, _isLoginFinish, null, false));
			procedureManager.addSequential(Handler.create(this, _loading), Handler.create(this, _isLoadingFinish, null, false));
			procedureManager.addSequential(null, Handler.create(this, _isDead));

		}

		private function _login() : void {
			trace("CSequentialProcedureUsage _login")
		}
		private function _isLoginFinish() : Boolean {
			m_index++;
			if (m_index > 500) {
				return true;
			}
			return false;
		}

		private function _loading() : void {
			trace("CSequentialProcedureUsage _loading")
		}
		private function _isLoadingFinish() : Boolean {
			m_index++;
			if (m_index > 1000) {
				return true;
			}
			return false;
		}
		private function _isDead() : Boolean {
			trace("CSequentialProcedureUsage -------------------------finish");
			return true;
		}
		private var m_index:int;
	}

}