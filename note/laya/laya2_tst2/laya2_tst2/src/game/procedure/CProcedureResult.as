package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import a_core.scene.CSceneSystem;
	import a_core.game.CGameSystem;
	import metro.lobby.CLobbySystem;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerNetHandler;
	import metro.result.CResultView;
	import game.scene.ESceneID;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureResult extends CProcedureBase {
		public function CProcedureResult(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);

			var pLobbySystem:CLobbySystem = fsm.system.stage.getSystem(CLobbySystem) as CLobbySystem;
			pLobbySystem.showResult();

			m_resultView = pLobbySystem.getBean(CResultView) as CResultView;
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

			if (m_resultView.isClickRestart) {
				fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.GAMING);
				changeProcedure(fsm, CProcedureChangeScene);
			}
			// fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.GAMING);
			// 	changeProcedure(fsm, CProcedureChangeScene);
		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			var pLobbySystem:CLobbySystem = fsm.system.stage.getSystem(CLobbySystem) as CLobbySystem;
			pLobbySystem.hideResult();
			m_resultView = null;
			
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}

		private var m_resultView:CResultView;
	}

}