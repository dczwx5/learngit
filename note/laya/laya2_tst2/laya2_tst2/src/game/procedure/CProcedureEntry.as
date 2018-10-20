package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import game.procedure.CProcedureLaunch;
	import a_core.procedure.CProcedureManager;
	import game.procedure.CProcedureSystem;
	import a_core.framework.CAppStage;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureEntry extends CProcedureBase {
		public function CProcedureEntry(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);

			
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

			changeProcedure(fsm, CProcedureLaunch);
		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
	}

}