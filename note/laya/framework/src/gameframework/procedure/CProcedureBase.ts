namespace gameframework {
export namespace procedure {

/**
 * ...
 * @author
 */
export class CProcedureBase extends fsm.CFsmState {
	constructor(){
		super();
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		super.onEnter(fsm);
	}
	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}
	
	protected changeProcedure(fsm:fsm.CFsm, stateType:new()=>any) : void {
		this.changeState(fsm, stateType)
	}
}
}
}