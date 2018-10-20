package metro.lobby
{
	import a_core.framework.CAppSystem;
	import metro.player.CPlayerSystem;
	import metro.player.EPlayerEvent;
	import metro.result.CResultView;

	/**
	 * ...
	 * @author
	 */
	public class CLobbySystem extends CAppSystem {
		public function CLobbySystem(){
		}

		protected override function onAwake() : void {
			super.onAwake();
			this.addBean(new CResultView());
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			pPlayerSystem.on(EPlayerEvent.CURRENCY_DATA, this, _onPlayerData);
			

			return ret;
		}
		private function _onPlayerData() : void {
			var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			pPlayerSystem.playerData;

		}

		protected override function onDestroy() : void {
			super.onDestroy();

			var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			if (pPlayerSystem) {
				pPlayerSystem.off(EPlayerEvent.CURRENCY_DATA, this, _onPlayerData);
			}
		}

		public function showResult() : void {
			(getBean(CResultView) as CResultView).show();
		}
		
		public function hideResult() : void {
			(getBean(CResultView) as CResultView).hide();
		}

	}

}