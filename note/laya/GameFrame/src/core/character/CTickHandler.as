package core.character
{
	import core.game.ecsLoop.CGameSystemHandler;
	import core.game.ecsLoop.CSubscribeBehaviour;
	import core.game.ecsLoop.CGameObject;
	import core.game.ecsLoop.IGameComponent;
	import core.game.ecsLoop.CGameComponent;

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