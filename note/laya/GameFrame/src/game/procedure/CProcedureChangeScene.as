package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
	import game.procedure.CProcedureLoginMenu;
	import game.procedure.EProcedureKey;
	import game.scene.ESceneID;
	import game.procedure.CProcedureGaming;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureChangeScene extends CProcedureBase {
		public function CProcedureChangeScene(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm);

			if (fsm.getData(EProcedureKey.NEXT_SCENE_ID) == ESceneID.LOGIN_MENU) {
				changeProcedure(fsm, CProcedureLoginMenu);
			} else {
				changeProcedure(fsm, CProcedureGaming);
			}

		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}