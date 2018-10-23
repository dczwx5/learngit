package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import game.login.CLoginSystem;
	import a_core.framework.CViewBean;
	import game.procedure.CProcedureChangeScene;
	import a_core.log.CLog;
	import game.login.CLoginMenuView;
	import game.procedure.EProcedureKey;
	import game.scene.ESceneID;
	import metro.lobby.CLobbySystem;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureLoginMenu extends CProcedureBase {
		public function CProcedureLoginMenu(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);

			var loginSystem:CLoginSystem = fsm.system.stage.getSystem(CLoginSystem) as CLoginSystem;
			var loginMenuView:CLoginMenuView = loginSystem.getBean(CLoginMenuView) as CLoginMenuView;
			loginMenuView.on(CViewBean.EVENT_OK, this, _onStartClick, [fsm]);
			loginMenuView.on('rank', this, _onRankClick, [fsm]);
			loginSystem.showLoginMenu();
		}
		private function _onStartClick(fsm:CFsm) : void {
			var loginSystem:CLoginSystem = fsm.system.stage.getSystem(CLoginSystem) as CLoginSystem;
			var loginMenuView:CLoginMenuView = loginSystem.getBean(CLoginMenuView) as CLoginMenuView;
			loginMenuView.off(CViewBean.EVENT_OK, this, _onStartClick);
			loginMenuView.off('rank', this, _onRankClick);
			loginSystem.closeLoginMenu();

			fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.GAMING);
			changeProcedure(fsm, CProcedureChangeScene);

		}
		private function _onRankClick(fsm:CFsm) : void {
			var lobbySystem:CLobbySystem = fsm.system.stage.getSystem(CLobbySystem) as CLobbySystem;
			lobbySystem.showRank();
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
	}

}