package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
	import game.login.CLoginSystem;
	import core.framework.CViewBean;
	import game.procedure.CProcedureChangeScene;
	import core.log.CLog;
	import game.login.CLoginMenuView;
	import game.procedure.EProcedureKey;
	import game.scene.ESceneID;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureLoginMenu extends CProcedureBase {
		public function CProcedureLoginMenu(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);

			var loginSystem:CLoginSystem = fsm.system.stage.getSystem(CLoginSystem) as CLoginSystem;
			var loginMenuView:CLoginMenuView = loginSystem.getBean(CLoginMenuView) as CLoginMenuView;
			loginMenuView.on(CViewBean.EVENT_OK, this, _onStartClick, [fsm]);
			loginSystem.showLoginMenu();
		}
		private function _onStartClick(fsm:IFsm) : void {
			var loginSystem:CLoginSystem = fsm.system.stage.getSystem(CLoginSystem) as CLoginSystem;
			var loginMenuView:CLoginMenuView = loginSystem.getBean(CLoginMenuView) as CLoginMenuView;
			loginMenuView.off(CViewBean.EVENT_OK, this, _onStartClick);
			loginSystem.closeLoginMenu();

			fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.GAMING);
			changeProcedure(fsm, CProcedureChangeScene);

		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}