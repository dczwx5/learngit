package game.lobby
{
	import core.framework.CViewBean;
	import game.view.EViewType;

	/**
	 * ...
	 * @author
	 */
	public class CLobbyView extends CViewBean {
		public function CLobbyView(){
			
		}

		public override function get viewID() : int {
			return EViewType.LOBBY;
		}
		protected override function _viewRes() : Array {
			return null;
		}   
		protected override function _soundRes() : Array {
			return null;
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : void {
			super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		protected override function _onShow() : void {

		}
		protected override function _onHide() : void {
			
		}
	}

}