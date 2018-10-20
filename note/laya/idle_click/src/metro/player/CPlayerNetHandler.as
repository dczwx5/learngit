package metro.player
{
	import core.framework.CBean;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerData;
	import metro.player.EPlayerEvent;
	import metro.building.data.CBuildingItemData;

	/**
	 * ...
	 * @author
	 */
	public class CPlayerNetHandler extends CBean {
		public function CPlayerNetHandler(){
			
		}

		public function onData() : void {
			var data:Object = {
				"ID":1001, 
				"name":"auto",
				"currency":{
					"gold":10
				}, 
				"buildings":[
					{"ID":1, "lv":1}, 
					{"ID":2, "lv":2}, 
					{"ID":3, "lv":3}, 
					{"ID":4, "lv":4}, 
					{"ID":5, "lv":5}, 
					{"ID":6, "lv":6}, 
					{"ID":7, "lv":7}, 
					{"ID":8, "lv":8}, 
				]
			}
			changeData(data);
		}

		// for test
		public function changeData(data:Object) : void {
			var playerSystem:CPlayerSystem = _playerSystem;
			var playerData:CPlayerData = playerSystem.playerData;
			playerData.updateData(data);

			if (data.hasOwnProperty(CPlayerData._CURRENCY)) {
				playerSystem.event(EPlayerEvent.CURRENCY_DATA);
			}

			if (data.hasOwnProperty(CPlayerData._BUILDINGS)) {
				playerSystem.event(EPlayerEvent.BUILDINGS_DATA);
			}
		}

		public function addBuildingLv(ID:int, addCount:int) : void {
			var playerSystem:CPlayerSystem = _playerSystem;
			var playerData:CPlayerData = playerSystem.playerData;
			var buildingData:CBuildingItemData = playerData.buildingListData.getByID(ID);

			var data:Object = {
				"ID":1001, 
				"buildings":[
					{"ID":ID, "lv":buildingData.lv + addCount}
				]
			};

			changeData(data);
		}
		public function cost(costCount:Number) : Boolean {
			var playerSystem:CPlayerSystem = _playerSystem;
			var playerData:CPlayerData = playerSystem.playerData;
			if (costCount > playerData.currencyData.gold) {
				return false;
			}

			var data:Object = {
				"ID":1001, 
				"currency":{
					"gold":playerData.currencyData.gold-costCount
				}
			};

			changeData(data);
			return true;
		}

		private function get _playerSystem():CPlayerSystem {
			return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
		}
	}

}