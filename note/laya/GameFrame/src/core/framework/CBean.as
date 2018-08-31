package core.framework
{
	/**
	 * ...
	 * @author
	 */
	public class CBean extends CContainerLifeCycle {
		public function CBean(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : void {
			super.onStart();
		}
		protected override function onDestroy() : void {
			m_system = null;
			super.onDestroy();
		}

		public function get system() : CAppSystem {
			return m_system;
		}
		public function set system(v:CAppSystem) : void {
			m_system = v;
		}

		private var m_system:CAppSystem;
	}

}