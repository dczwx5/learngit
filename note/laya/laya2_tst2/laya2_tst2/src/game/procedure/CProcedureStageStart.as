package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import game.procedure.CProcedureChangeScene;
	import game.procedure.EProcedureKey;
	import game.scene.ESceneID;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureStageStart extends CProcedureBase {
		public function CProcedureStageStart(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);

			fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.LOGIN_MENU);
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			changeProcedure(fsm, CProcedureChangeScene);

		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
	}

}