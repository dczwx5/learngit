namespace gameframework {
export namespace fsm {


/**
 * ...
 * @author
 */
export class CFsmState{
	public CFsmState(){
		
	}

	public initialize(fsm:CFsm) : void {
		this.onInit(fsm);
	}
	protected onInit(fsm:CFsm) : void {
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onInit", typeName)
	}


	public enter(fsm:CFsm) : void {
		this.onEnter(fsm);
	}
	protected onEnter(fsm:CFsm) : void {
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onEnter", typeName)
	}

	public update(fsm:CFsm, deltaTime:number) : void {
		this.onUpdate(fsm, deltaTime);
	}
	protected onUpdate(fsm:CFsm, deltaTime:number) : void {

	}

	public leave(fsm:CFsm, isShutDown:boolean) : void {
		this.onLeave(fsm, isShutDown);
		
	}
	protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onLeave", typeName)
	}

	public destroy(fsm:CFsm) : void {
		this.onDestroy(fsm);
	}
	protected onDestroy(fsm:CFsm) : void {
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onDestroy", typeName)
	}

	protected changeState(fsm:CFsm, stateType:new()=>any) : void {
		let fsmImp:CFsm = fsm as CFsm;
		if (null == fsmImp) {
			throw new Error("fsm is invalid");
		}

		if (stateType == null) {
			throw new Error("state type is invalid");
		} 

		fsmImp.changeState(stateType);
	}

	public onEvent(fsm:CFsm, sender:Object, eventID:number, userData:Object) : void {

	}
}
}
}