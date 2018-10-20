package metro.lobby
{
	import core.framework.CAppSystem;
	import metro.player.CPlayerSystem;
	import metro.player.EPlayerEvent;
	import metro.lobby.view.CLobbyView;

	/**
	 * ...
	 * @author
	 */
	public class CLobbySystem extends CAppSystem {
		public function CLobbySystem(){
		}

		protected override function onAwake() : void {
			super.onAwake();
			this.addBean(new CLobbyView());
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			pPlayerSystem.on(EPlayerEvent.CURRENCY_DATA, this, _onPlayerData);
			pPlayerSystem.on(EPlayerEvent.BUILDINGS_DATA, this, _onPlayerData);
			

			return ret;
		}
		private function _onPlayerData() : void {
			var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			pPlayerSystem.playerData;

			var lobbyView:CLobbyView = (getBean(CLobbyView) as CLobbyView);
			if (lobbyView.isShowingState) {
				lobbyView.invalidate();
			}

		}

		protected override function onDestroy() : void {
			super.onDestroy();

			var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			if (pPlayerSystem) {
				pPlayerSystem.off(EPlayerEvent.CURRENCY_DATA, this, _onPlayerData);
				pPlayerSystem.off(EPlayerEvent.BUILDINGS_DATA, this, _onPlayerData);
			}
		}

		public function showLobby() : void {
			(getBean(CLobbyView) as CLobbyView).show();
		}
		public function hideLobby() : void {
			(getBean(CLobbyView) as CLobbyView).hide();
		}
	}

}