package metro
{
	import core.game.CGameSystem;
	import core.CCommon;
	import laya.events.Event;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerData;

	/**
	 * ...
	 * @author
	 */
	public class CMetroGameSystem extends CGameSystem {
		public function CMetroGameSystem(){
			
		}
		protected override function onDestroy() : void {
			CCommon.stage.off(Event.CLICK, this, _onStageClickHandler);

			super.onDestroy();
		}

		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
		
			CCommon.stage.on(Event.CLICK, this, _onStageClickHandler);

			m_pPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;

			return ret;
		}

		private var m_currentProduceValueAdded:Number = 0;
		private var m_perSecond:Number = 0;
		public override function update(deltaTime:Number) : void {
			var buildingDps:Number = m_pPlayerSystem.playerData.getBuildingDps();
			addGold(deltaTime * buildingDps);


			m_perSecond += deltaTime;
			if (m_perSecond > 1.0) {
				m_pPlayerSystem.playerData.dps = m_currentProduceValueAdded/(m_perSecond); // 算出1秒dps
				m_perSecond = 0;

				m_currentProduceValueAdded = 0;
			}
		}

		private var _ID:int = 2; // for test
		private function _onStageClickHandler() : void {
			var gameSystem:CGameSystem = stage.getSystem(CGameSystem) as CGameSystem;
			gameSystem.spawnCharacter({ID:_ID, type:0, skin:"1001", defAni:"idle", x:Math.random()*600, y:Math.random()*300});
			_ID++;

			addGold(1);
		}
		public function addGold(gold:Number) : void {
			var playerData:CPlayerData = m_pPlayerSystem.playerData;
			var playerObjectData:Object = {};
			playerObjectData[CPlayerData._CURRENCY] = {"gold":playerData.currencyData.gold + gold};
			m_pPlayerSystem.netHandler.changeData(playerObjectData);
			m_currentProduceValueAdded += gold;
		}

		private var m_pPlayerSystem:CPlayerSystem;
	}

}