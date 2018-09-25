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
	import metro.EAnimation;
	import metro.role.CMonster;
	import core.character.CCharacterBase;

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

			m_root = new Sprite();
			Laya.stage.addChildAt(m_root, 0);

			m_sceneLayer = new Sprite();
			m_root.addChild(m_sceneLayer);

			return ret;
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public function get root() : Sprite {
			return m_root;
		}
		public function get sceneLayer() : Sprite {
			return m_sceneLayer;
		}

		public function createScene(sceneID:String) : void {
			while (m_sceneLayer.numChildren > 0) {
				m_sceneLayer.removeChildAt(0);
			}

			var bgUrl:String = CPathUtils.getScenePath("b");
			var bg:Image = new Image(bgUrl);
			m_sceneLayer.addChild(bg);

			m_role1 = new CMonster();
			m_role1.id = "1001";
			m_role1.displayObject.x = 200;
			m_role1.displayObject.y = 300;
			m_role1.on(CCharacterBase.EVENT_RUNNING, this, _onRole1Running);
			m_role1.create();

			m_role2 = new CMonster();
			m_role2.id = "1001";
			m_role2.displayObject.x = 400;
			m_role2.displayObject.y = 300;
			m_role2.on(CCharacterBase.EVENT_RUNNING, this, _onRole2Running);
			m_role2.create();

			m_role3 = new CMonster();
			m_role3.id = "1001";
			m_role3.displayObject.x = 400;
			m_role3.displayObject.y = 100;
			m_role3.on(CCharacterBase.EVENT_RUNNING, this, _onRole3Running);
			m_role3.create();
			
			m_sceneLayer.addChild(m_role1.displayObject);
			m_sceneLayer.addChild(m_role2.displayObject);
			m_sceneLayer.addChild(m_role3.displayObject);
        }

		private function _onRole1Running() : void {
			m_role1.playAnimation(EAnimation.DIE);
			m_role1.off(CCharacterBase.EVENT_RUNNING, this, _onRole1Running);
		}
		private function _onRole2Running() : void {
			m_role2.playAnimation(EAnimation.MOVE);
			m_role2.off(CCharacterBase.EVENT_RUNNING, this, _onRole2Running);
		}
		private function _onRole3Running() : void {
			m_role3.playAnimation(EAnimation.IDLE);
			m_role3.off(CCharacterBase.EVENT_RUNNING, this, _onRole3Running);
		}
		private var m_role1:CMonster;
		private var m_role2:CMonster;
		private var m_role3:CMonster;

		private var m_root:Sprite;
		private var m_sceneLayer:Sprite;
	}

}