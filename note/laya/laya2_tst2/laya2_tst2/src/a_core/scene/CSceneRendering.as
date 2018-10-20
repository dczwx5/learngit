package a_core.scene
{
	import a_core.framework.CBean;
	import a_core.framework.IUpdate;
	import a_core.scene.CSceneLayer;
	import a_core.CCommon;
	import game.CPathUtils;
	import laya.ui.Image;
	import a_core.character.display.CCharacterDisplay;
	import a_core.CBaseDisplay;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class CSceneRendering extends CBean implements IUpdate {
		public function CSceneRendering(){
			
		}

		override protected function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			m_root = new CSceneLayer();
			m_sceneLayer = new CSceneLayer();
			m_root.addChild(m_sceneLayer);

			return ret;
		}

		public function get isReady() : Boolean {
			return true;
		}

		public function addDisplayObject(c:CBaseDisplay) : void {
			m_sceneLayer.addChild(c);
		}

		public function update(delta:Number) : void {

		}

		public function createScene(sceneID:String) : void {
			while (m_sceneLayer.numChildren > 0) {
				m_sceneLayer.removeChildAt(0);
			}
		}

		public function get displayerObject():Sprite {
			return m_root;
		}

		private var m_root:CSceneLayer;
		private var m_sceneLayer:CSceneLayer;
	}

}