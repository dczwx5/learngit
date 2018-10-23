package metro.player
{
	import a_core.framework.CBean;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerData;
	import metro.player.EPlayerEvent;
	import metro.scene.CMetroSceneHandler;
	import metro.scene.CMetroSceneSystem;

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

			var playerSystem:CPlayerSystem = _playerSystem;
			var playerData:CPlayerData = playerSystem.playerData;
			playerData.reset();
			playerSystem.event(EPlayerEvent.CUR_SCORE);
		}

		// for test
		public function changeData(data:Object) : void {
			var playerSystem:CPlayerSystem = _playerSystem;
			var playerData:CPlayerData = playerSystem.playerData;
			playerData.updateData(data);

			if (data.hasOwnProperty(CPlayerData._CURRENCY)) {
				playerSystem.event(EPlayerEvent.CURRENCY_DATA);
			}

		
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

		public function addScore(v:int) : Boolean {
			var playerSystem:CPlayerSystem = _playerSystem;
			var playerData:CPlayerData = playerSystem.playerData;
			if (playerData.curScore + v >= 0) {
				playerData.curScore += v;
				playerSystem.event(EPlayerEvent.CUR_SCORE);
				return true;
			}

			return true;
		}

		public function prevMerge() : void {
			var sceneHandler:CMetroSceneHandler = system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;
			var value:int = sceneHandler.getSelectValue();
			var count:int = sceneHandler.getSelectCount();
			var score:int = _playerSystem.playerData.calcScore(value, count);
			addScore(score);
			var playerData:CPlayerData = _playerSystem.playerData;
			playerData.lastValue = value;
		}

		
		

		private function get _playerSystem():CPlayerSystem {
			return system as CPlayerSystem;
		}
	}

}