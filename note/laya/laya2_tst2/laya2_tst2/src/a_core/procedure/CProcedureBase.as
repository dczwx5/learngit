package a_core.procedure
{
	import a_core.fsm.CFsmState;
	import a_core.fsm.CFsm;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureBase extends CFsmState {
		public function CProcedureBase(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);
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
		
		protected function changeProcedure(fsm:CFsm, stateType:Class) : void {
			changeState(fsm, stateType)
		}
	}

}