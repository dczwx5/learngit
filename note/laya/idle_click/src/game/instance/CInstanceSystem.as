package game.instance
{
	import core.framework.CAppSystem;

	/**
	 * ...
	 * @author auto
	 */
	public class CInstanceSystem extends CAppSystem {
		public function CInstanceSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			// this.addBean(new CLobbyView());
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public function enterInstance(instanceID:int) : void {
			// create scene

			
		}
	}

}