package a_core.framework
{
	/**
	 * ...
	 * @author
	 */
	public class CBean extends CContainerLifeCycle {
		public function CBean(){
			
		}

		public override function addBean(o:CLifeCycle) : Boolean {
			var ret:Boolean = super.addBean(o);

			if (ret) {
				(o as CBean).system = system;
			}
			return ret;
		}
		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
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