package core.procedure
{
	import core.fsm.CFsmState;
	import core.fsm.IFsm;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureBase extends CFsmState {
		public function CProcedureBase(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm);
		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
		
		protected function changeProcedure(fsm:IFsm, stateType:Class) : void {
			changeState(fsm, stateType)
		}
	}

}