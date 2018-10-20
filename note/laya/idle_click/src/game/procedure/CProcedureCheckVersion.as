package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
	import game.procedure.CProcedureLoadDataTable;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureCheckVersion extends CProcedureBase {
		public function CProcedureCheckVersion(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			changeProcedure(fsm, CProcedureLoadDataTable);

		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}