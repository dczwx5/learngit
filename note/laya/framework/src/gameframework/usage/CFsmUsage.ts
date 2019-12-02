namespace gameframework {
export namespace usage {
import CFsm = fsm.CFsm;
import CFsmManager = fsm.CFsmManager;
/**
 * ...
 * @author
 */
export class CFsmUsage{
	private fsmManager:CFsmManager;
	constructor(){
	}

	public start() : void {
		let owner:OwnerType = new OwnerType();
		let stateList:fsm.CFsmState[] = [new StateIdle(), new StateRun(), new StateJump(), new StateDie()];
		this.fsmManager = new CFsmManager();
		let fsm:fsm.CFsm = this.fsmManager.createFsm("TEST_FSM", owner, stateList);
		fsm.start(StateIdle);
	}
	public update(deltaTime:number) : void {
		this.fsmManager.update(deltaTime);
		let fsm:CFsm = this.fsmManager.getFsm("TEST_FSM");
		if (fsm && fsm.currentState instanceof StateDie) {
			this.fsmManager.destroyFsm("TEST_FSM");
			// fsmManager.shutDown();
		}
	}
	public stop() : void {

	}
}



}

class OwnerType {

}
import CFsm = fsm.CFsm;
import CFsmState = fsm.CFsmState;

class StateIdle extends fsm.CFsmState {
	protected onInit(fsm:CFsm) : void {
		super.onInit(fsm);
		log.CLog.log("StateIdle.onInit");
	}

	protected onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		log.CLog.log("StateIdle.onEnter");
	}

	protected onUpdate(fsm:CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);
		log.CLog.log("StateIdle.onUpdate");

		this.changeState(fsm, StateRun);
	}

	protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
		log.CLog.log("StateIdle.onLeave");
	}

	protected onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);
		log.CLog.log("StateIdle.onDestroy");
	}
}
class StateRun extends CFsmState {
	protected onInit(fsm:CFsm) : void {
		super.onInit(fsm);
		log.CLog.log("StateRun.onInit");
	}

	protected onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		log.CLog.log("StateRun.onEnter");
	}

	protected onUpdate(fsm:CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);
		log.CLog.log("StateRun.onUpdate");

		this.changeState(fsm, StateJump);
	}

	protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
		log.CLog.log("StateRun.onLeave");
	}

	protected onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);
		log.CLog.log("StateRun.onDestroy");
	}
}
class StateJump extends CFsmState {
	protected onInit(fsm:CFsm) : void {
		super.onInit(fsm);
		log.CLog.log("StateJump.onInit");
	}

	protected onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		log.CLog.log("StateJump.onEnter");

		this.changeState(fsm, StateDie);
	}

	protected onUpdate(fsm:CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);
		log.CLog.log("StateJump.onUpdate");
	}

	protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
		log.CLog.log("StateJump.onLeave");
	}

	protected onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);
		log.CLog.log("StateJump.onDestroy");
	}
}

class StateDie extends fsm.CFsmState {
	protected onInit(fsm:CFsm) : void {
		super.onInit(fsm);
		log.CLog.log("StateDie.onInit");
	}

	protected onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		log.CLog.log("StateDie.onEnter");
	}

	protected onUpdate(fsm:CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);
		log.CLog.log("StateDie.onUpdate");
	}

	protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
		log.CLog.log("StateDie.onLeave");
	}

	protected onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);
		log.CLog.log("StateDie.onDestroy");

	}
}
}