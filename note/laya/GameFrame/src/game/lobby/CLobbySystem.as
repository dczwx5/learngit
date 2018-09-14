package game.lobby
{
	import core.framework.CAppSystem;
	import game.lobby.CLobbyView;

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
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}
	}

}