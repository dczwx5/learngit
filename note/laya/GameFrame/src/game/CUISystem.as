package game
{
	import core.framework.CAppSystem;
	import laya.ui.Box;

	/**
	 * ...
	 * @author
	 */
	public class CUISystem extends CAppSystem {
		public function CUISystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : void {
			super.onStart();
		}
		
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		private var m_uiRoot:Box;
		private var m_dialogLayer:Box;
		private var m_tipsLayer:Box;
		private var m_effectLayer:Box;
		private var m_tutorLayer:Box;
		
	}

}