package game.login
{
	import core.framework.CAppSystem;
	import game.login.CLoginMenuView;

	/**
	 * ...
	 * @author
	 */
	public class CLoginSystem extends CAppSystem {
		public function CLoginSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			addBean(new CLoginMenuView());
		}
		protected override function onStart() : void {
			super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public function showLoginMenu() : void {
			(getBean(CLoginMenuView) as CLoginMenuView).show();
		}
		public function closeLoginMenu() : void {
			(getBean(CLoginMenuView) as CLoginMenuView).hide();
		}
	}

}