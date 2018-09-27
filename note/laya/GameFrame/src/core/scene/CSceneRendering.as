package core.scene
{
	import core.character.CCharacter;
	import core.framework.CBean;
	import core.framework.IUpdate;
	import core.scene.CSceneLayer;
	import core.CCommon;
	import game.CPathUtils;
	import laya.ui.Image;
	import metro.role.CMonster;
	import core.character.CCharacterBase;
	import metro.EAnimation;

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
			CCommon.stage.addChildAt(m_root, 0);

			m_sceneLayer = new CSceneLayer();
			m_root.addChild(m_sceneLayer);

			return ret;
		}

		public function get isReady() : Boolean {
			return true;
		}

		public function addDisplayObject(c:CCharacter) : void {
			m_sceneLayer.addChild(c);
		}

		public function update(delta:Number) : void {

		}

		public function createScene(sceneID:String) : void {
			while (m_sceneLayer.numChildren > 0) {
				m_sceneLayer.removeChildAt(0);
			}

			var bgUrl:String = CPathUtils.getScenePath("b");
			var bg:Image = new Image(bgUrl);
			m_sceneLayer.addChild(bg);
		}

		private var m_root:CSceneLayer;
		private var m_sceneLayer:CSceneLayer;
	}

}