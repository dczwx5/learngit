package core.scene
{
	import core.framework.CAppSystem;

	/**
	 * ...
	 * @author
	 */
	public class CSceneSystem extends CAppSystem {
		public function CSceneSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public virtual function createScene(sceneID:String) : void {

		}
	}

}