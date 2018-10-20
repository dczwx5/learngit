package game.login
{
	import core.framework.CViewBean;
	import metro.EViewType;
	import laya.ui.Box;
	import ui.GameStartUI;
	import laya.events.Event;
	import core.log.CLog;
	import game.CPathUtils;

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
				uiSystem.closeDialog(m_view);
			}
			
			super.onDestroy();			
		}

		protected override function _onShow() : void {
			m_view = new GameStartUI();
			uiSystem.addToDialog(m_view);

			m_view.btn_start.on(Event.MOUSE_UP, this, _onStart);
		}
		protected override function _onHide() : void {
			m_view.btn_start.off(Event.MOUSE_UP, this, _onStart);
			uiSystem.closeDialog(m_view);
		}

		private function _onStart() : void {
			event(EVENT_OK);
		}

		private var m_view:GameStartUI;
	}

}