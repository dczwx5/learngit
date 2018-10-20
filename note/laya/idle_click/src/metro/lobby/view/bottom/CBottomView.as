package metro.lobby.view.bottom
{
	import core.framework.CViewBean;
	import metro.EViewType;
	import ui.GamePlayUI;
	import game.CPathUtils;
	import metro.player.CPlayerData;
	import metro.player.CPlayerSystem;
	import metro.lobby.view.CLobbyView;
	import ui.bottom.BottomUI;
	import laya.events.Event;
	import metro.lobby.view.bottom.CBottomBuildingView;

	/**
	 * ...
	 * @author
	 */
	public class CBottomView  {
		public function CBottomView(lobbyView:CLobbyView){
			m_pLobbyView = lobbyView;
			bottomView.desc_ui.visible = false;

			m_buildingView = new CBottomBuildingView(lobbyView);
		}
		public function onDestroy() : void {
			m_pLobbyView = null;

			m_buildingView.onDestroy();
		}

		public function onShow() : void {
			bottomView.building_img.mouseEnabled = true;
			bottomView.building_img.on(Event.CLICK, this, _onToggleBuilding);

			m_buildingView.onShow();
		}
		private function _onToggleBuilding() : void {
			var lastVisible:Boolean = bottomView.desc_ui.visible;
			if (!lastVisible) {
				bottomView.desc_ui.visible = true;
			} else {
				bottomView.desc_ui.visible = false;
			}
		}
		public function onHide() : void {
			bottomView.building_img.off(Event.CLICK, this, _onToggleBuilding);

			m_buildingView.onHide();
		}

		public function updateData() : void {
			m_buildingView.updateData();
		}

		public function get bottomView() : BottomUI {
			return m_pLobbyView.view.bottom_ui;
		}


		private var m_bottomView:BottomUI;
		private var m_pLobbyView:CLobbyView;

		private var m_buildingView:CBottomBuildingView;
	}

}