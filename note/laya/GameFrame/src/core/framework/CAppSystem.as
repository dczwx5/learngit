package core.framework
{
	/**
	 * ...
	 * @author auto
	 */
	public class CAppSystem extends CContainerLifeCycle {
		public function CAppSystem() {
			
		}
		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : void {
			super.onStart();
		}
		
		protected override function onDestroy() : void {
			m_stage = null;

			super.onDestroy();
		}

		public override function addBean(o:CLifeCycle) : Boolean {
			var ret:Boolean = super.addBean(o);
			if (ret) {
				(o as CBean).system = this;
			}
			
			return ret;
		}
		
		public function get stage() : CAppStage {
			return m_stage;
		}
		public function set stage(v:CAppStage) : void {
			m_stage = v;
		}

		private var m_stage:CAppStage;

	}

}