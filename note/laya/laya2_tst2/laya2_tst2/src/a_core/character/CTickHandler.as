package a_core.character
{
	import a_core.game.ecsLoop.CGameSystemHandler;
	import a_core.game.ecsLoop.CSubscribeBehaviour;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.game.ecsLoop.IGameComponent;
	import a_core.game.ecsLoop.CGameComponent;

	/**
	 * ...
	 * @author
	 */
	public class CTickHandler extends CGameSystemHandler {
 		public function CTickHandler(){
			super(CSubscribeBehaviour);
		}

		override protected function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			return ret;
		}

		override public function tickUpdate(delta:Number, obj:CGameObject) : void {
			const comps:Vectir.<IGameComponent> = obj.components;

			for each (var comp:CGameComponent in comps) {
				if (comp is CSubscribeBehaviour) {
					CSubscribeBehaviour(comp).update(delta);
				}
			}

			_tickObjAnimationFrozenTime(obj, delta);
		}

		private function _tickObjAnimationFrozenTime(obj:CGameObject, delta:Number) : void {
			if (null == obj) {
				return ;
			}

			// var bValidated:Boolean = true;
			// bValidated = bValidated && obj.isRunning;
			// if (bValidated) {
			// 	var ani:IAnimation = obj.getComponentByClass(IAnimation, true) as IAnimation;
			// 	ani.tickFrozenTime(delta);
			// }
		}
	}

}