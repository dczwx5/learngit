package core.scene
{
	import core.character.CCharacter;
	import core.framework.CBean;
	import core.framework.IUpdate;
	import core.scene.CScene;

	/**
	 * ...
	 * @author
	 */
	public class CSceneRendering extends CBean implements IUpdate {
		public function CSceneRendering(){
			
		}

		public function get isReady() : Boolean {
			return true;
		}

		public function addDisplayObject(c:CCharacter) : void {
			m_pGraphicsScene.addObjectToLayer(c);
		}

		private var m_pGraphicsScene:CScene;
	}

}