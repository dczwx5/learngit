package usage
{
	import core.fsm.CFsmManager;
	import core.fsm.IFsm;
	import core.fsm.CFsmState;

	/**
	 * ...
	 * @author
	 */
	public class CFsmUsage{
		private var fsmManager:CFsmManager;
		public function CFsmUsage(){
			
		}

		public function start() : void {
			var owner:OwnerType = new OwnerType();
			var stateList:Array = [new StateIdle(), new StateRun(), new StateJump(), new StateDie()];
			fsmManager = new CFsmManager();
			var fsm:IFsm = fsmManager.createFsm("TEST_FSM", owner, stateList);
			fsm.start(StateIdle);
		}
		public function update(deltaTime:Number) : void {
			fsmManager.update(deltaTime);
			var fsm:IFsm = fsmManager.getFsm("TEST_FSM");
			if (fsm && fsm.currentState is StateDie) {
				fsmManager.destroyFsm("TEST_FSM");
				// fsmManager.shutDown();
			}
		}
		public function stop() : void {

		}
	}

	

}
import core.fsm.CFsmState;
import core.fsm.IFsm;

class OwnerType {

}

class StateIdle extends CFsmState {
		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
			trace("StateIdle.onInit");
		}

		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
			trace("StateIdle.onEnter");
		}

		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			trace("StateIdle.onUpdate");

			changeState(fsm, StateRun);
		}
 
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
			trace("StateIdle.onLeave");
		}
 
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
			trace("StateIdle.onDestroy");
		}
}
class StateRun extends CFsmState {
		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
			trace("StateRun.onInit");
		}

		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
			trace("StateRun.onEnter");
		}

		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			trace("StateRun.onUpdate");

			changeState(fsm, StateJump);
		}
 
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
			trace("StateRun.onLeave");
		}
 
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
			trace("StateRun.onDestroy");
		}
}
class StateJump extends CFsmState {
		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
			trace("StateJump.onInit");
		}

		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
			trace("StateJump.onEnter");

			changeState(fsm, StateDie);
		}

		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			trace("StateJump.onUpdate");
		}
 
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
			trace("StateJump.onLeave");
		}
 
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
			trace("StateJump.onDestroy");
		}
}
class StateDie extends CFsmState {
		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
			trace("StateDie.onInit");
		}

		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
			trace("StateDie.onEnter");
		}

		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			trace("StateDie.onUpdate");
		}
 
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
			trace("StateDie.onLeave");
		}
 
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
			trace("StateDie.onDestroy");

		}
}