package metro.scene
{
	import metro.scene.CMetroSceneHandler;
	import a_core.scene.CSceneSystem;
	import a_core.CCommon;
	import laya.events.Event;
	import a_core.game.CGameSystem;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerNetHandler;
	import metro.player.CPlayerData;
	import a_core.CBaseDisplay;
	import game.CPathUtils;
	import laya.ui.Image;

	/**
	 * ...
	 * @author
	 */
	public class CMetroSceneSystem extends CSceneSystem {
		public function CMetroSceneSystem(){
			
		}
		protected override function onDestroy() : void {
			super.onDestroy();
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
			super.createScene(sceneID);

			m_sceneHandler.releaseScene();
			
			m_flatPanel = new CBaseDisplay();
			this.sceneRendering.addDisplayObject(m_flatPanel);

			m_effectLayer = new CBaseDisplay();
			this.sceneRendering.addDisplayObject(m_effectLayer);

			m_sceneHandler.createScene(m_flatPanel, m_effectLayer);
		}
		

		public override function get sceneWidth() : Number {
			return CCommon.screenWidth;
		}
		public override function get sceneHeight() : Number {
			return CCommon.screenHeight; //1334*0.55;
		}
		
		private var m_sceneHandler:CMetroSceneHandler;

		private var m_flatPanel:CBaseDisplay;
		private var m_effectLayer:CBaseDisplay;
		
	}

}