package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import game.procedure.CProcedureLoginMenu;
	import game.procedure.EProcedureKey;
	import game.scene.ESceneID;
	import game.procedure.CProcedureGaming;
	import game.procedure.CProcedureResult;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureChangeScene extends CProcedureBase {
		public function CProcedureChangeScene(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

			var nextScene:int = fsm.getData(EProcedureKey.NEXT_SCENE_ID) as int;
			if (nextScene == ESceneID.LOGIN_MENU) {
				changeProcedure(fsm, CProcedureLoginMenu);
			} else if (nextScene == ESceneID.RESULT) {
				changeProcedure(fsm, CProcedureResult);
			} else {
				changeProcedure(fsm, CProcedureGaming);
			}

		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
	}

}