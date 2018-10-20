package metro.lobby.view.bottom
{
	import ui.bottom.BuildingViewUI;
	import metro.lobby.view.CLobbyView;
	import metro.player.CPlayerSystem;
	import laya.utils.Handler;
	import laya.ui.Component;
	import ui.bottom.BuildingItemUI;
	import metro.building.data.CBuildingItemData;
	import laya.events.Event;
	import metro.player.CPlayerData;
	import metro.player.CPlayerPropertyCalc;

	/**
	 * ...
	 * @author
	 */
	public class CBottomBuildingView{
		public function CBottomBuildingView(lobbyView:CLobbyView){
			_lobbyView = lobbyView;
			_buildUI = lobbyView.view.bottom_ui.desc_ui.building_ui;
			_buildUI.list.vScrollBarSkin = "";
		}

		public function onDestroy() : void {
			_lobbyView = null;
			_buildUI = null;
		}

		public function onShow() : void {
			_buildUI.list.renderHandler = Handler.create(this, _onItemRender, null, false);

			var pPlayerSystem:CPlayerSystem = _lobbyView.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			var dataList:Array = pPlayerSystem.playerData.buildingListData.list;
			_buildUI.list.array = dataList;
		}
		
		public function onHide() : void {
			
		}

		public function updateData() : void {
			var pPlayerSystem:CPlayerSystem = _lobbyView.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			var dataList:Array = pPlayerSystem.playerData.buildingListData.list;
			_buildUI.list.array = dataList;
		}

		private function _onItemRender(comp:Component, idx:int) : void {
			var item:BuildingItemUI = comp as BuildingItemUI;
			var data:CBuildingItemData = item.dataSource as CBuildingItemData;
			item.lv_txt.text = data.lv.toString();

			item.name_txt.text = "name:" + data.ID; 

			
			item.dps_txt.text = CPlayerPropertyCalc.valueToString(data.dps);
			item.effect_txt.text = CPlayerPropertyCalc.valueToString(data.lvupDpsAdd);
			item.cost_txt.text = CPlayerPropertyCalc.valueToString(data.lvupCost); 

			item.lvup_btn.clickHandler = Handler.create(this, _onClickItem, [item], false);
		}
		private function _onClickItem(item:BuildingItemUI) : void {
			var data:CBuildingItemData = item.dataSource as CBuildingItemData;
			var pPlayerSystem:CPlayerSystem = _lobbyView.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			var pPlayerData:CPlayerData = pPlayerSystem.playerData;
			var lvupCost:Number = data.lvupCost;
			
			if (pPlayerData.currencyData.gold >= lvupCost) {
				if (pPlayerSystem.netHandler.cost(lvupCost)) {
					pPlayerSystem.netHandler.addBuildingLv(data.ID, 1);
				}
			}
		}
		

		private var _buildUI:BuildingViewUI;
		private var _lobbyView:CLobbyView;
	}

}