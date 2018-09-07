package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
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

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);

			fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.LOGIN_MENU);
		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm);
			changeProcedure(fsm, CProcedureChangeScene);

		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}