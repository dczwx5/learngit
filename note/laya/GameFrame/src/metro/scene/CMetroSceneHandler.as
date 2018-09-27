package metro.scene
{
	import core.framework.CBean;
	import laya.ui.Box;
	import laya.display.Node;
	import laya.display.Sprite;
	import game.CPathUtils;
	import laya.ui.Image;
	import laya.d3.animation.AnimationClip;
	import laya.display.Animation;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author auto
	 */
	public class CMetroSceneHandler extends CBean {
		public function CMetroSceneHandler(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			return ret;
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}
	}

}