package metro
{
	import a_core.game.CGameSystem;
	import a_core.CCommon;
	import laya.events.Event;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerData;
	import metro.scene.CMetroSceneHandler;
	import metro.scene.CMetroSceneSystem;

	/**
	 * ...
	 * @author
	 */
	public class CMetroGameSystem extends CGameSystem {
		public function CMetroGameSystem(){
			
		}
		protected override function onDestroy() : void {
			CCommon.stage.off(Event.CLICK, this, _onStageClickHandler);

			super.onDestroy();
		}

		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
		
			CCommon.stage.on(Event.CLICK, this, _onStageClickHandler);

			m_pPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
			m_sceneHandler = stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;

			return ret;
		}


		public override function update(deltaTime:Number) : void {
			
		}

		private function _onStageClickHandler() : void {
			//m_sceneHandler.onClick();
		}

		public function get isDead() : Boolean {
			return m_sceneHandler.isDead;
		}
		

		public function stop() : void {
			m_sceneHandler.stop();
		}
		
		private var m_sceneHandler:CMetroSceneHandler;

		private var m_pPlayerSystem:CPlayerSystem;
	}

}