package metro.player
{
	import a_core.framework.CAppSystem;
	import metro.player.CPlayerData;
	import metro.player.CPlayerNetHandler;

	/**
	 * ...
	 * @author
	 */
	public class CPlayerSystem extends CAppSystem {
		public function CPlayerSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			_playerData = new CPlayerData();
			this.addBean(m_netHandler = new CPlayerNetHandler());

		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			return ret;
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public function get playerData() : CPlayerData {
			return _playerData;
		}

		public function get netHandler() : CPlayerNetHandler {
			return m_netHandler;
		}

		private var _playerData:CPlayerData;
		private var m_netHandler:CPlayerNetHandler;
	}

}