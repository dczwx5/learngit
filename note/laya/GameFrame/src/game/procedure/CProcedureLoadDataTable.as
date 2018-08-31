package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
	import game.procedure.CProcedureStageStart;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureLoadDataTable extends CProcedureBase {
		public function CProcedureLoadDataTable(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm);
			changeProcedure(fsm, CProcedureStageStart);

		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}