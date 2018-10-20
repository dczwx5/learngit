package game.login
{
	import a_core.framework.CViewBean;
	import metro.EViewType;
	import laya.ui.Box;
	import laya.events.Event;
	import a_core.log.CLog;
	import game.CPathUtils;
	import ui.LoginMenuUI;

	/**
	 * ...
	 * @author
	 */
	public class CLoginMenuView extends CViewBean {
		public function CLoginMenuView(){
			
		}

		public override function get viewID() : int {
			return EViewType.LOGIN_MENU;
		}
		protected override function _viewRes() : Array {
			
			return [CPathUtils.getUIPath("gameUI")];
		}   
		protected override function _soundRes() : Array {
			return null;
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
	
		protected override function onDestroy() : void {
			if (m_view) {
				uiSystem.removeView(m_view);
			}
			
			super.onDestroy();			
		}

		protected override function _onShow() : void {
			m_view = new LoginMenuUI();
			uiSystem.addToView(m_view);

			m_view.start_btn.on(Event.MOUSE_UP, this, _onStart);
		}
		protected override function _onHide() : void {
			m_view.start_btn.off(Event.MOUSE_UP, this, _onStart);
			uiSystem.removeView(m_view);
		}

		private function _onStart() : void {
			event(EVENT_OK);
		}

		private var m_view:LoginMenuUI;
	}

}