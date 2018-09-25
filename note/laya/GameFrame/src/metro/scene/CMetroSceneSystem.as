package metro.scene
{
	import game.scene.CSceneSystem;
	import metro.scene.CMetroSceneHandler;

	/**
	 * ...
	 * @author
	 */
	public class CMetroSceneSystem extends CSceneSystem {
		public function CMetroSceneSystem(){
			
		}
		protected override function onAwake() : void {
			super.onAwake();

			this.addBean(m_sceneHandler = new CMetroSceneHandler());

		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
		

			return ret;
		}

		public override function createScene(sceneID:String) : void {
			m_sceneHandler.createScene(sceneID);
		}
		
		private var m_sceneHandler:CMetroSceneHandler;
	}

}