namespace gameframework {
export namespace usage {
/**
 * ...
 * @author
 */
export class CProcedureUsage{
	private procedureManager:procedure.CProcedureManager;
	private fsmManager:fsm.CFsmManager;
	public CProcedureUsage(){
		let owner:OwnerType = new OwnerType();
		let stateList:fsm.CFsmState[] = [new Login(), new Loading(), new Gaming(), new Exit()];
		this.fsmManager = new fsm.CFsmManager();
		this.procedureManager = new procedure.CProcedureManager();
		this.procedureManager.initialize("gameProcedure", this.fsmManager, stateList);
		this.procedureManager.startProcedure(Login);


	}

	public update(deltaTime:number) : void {
		this.fsmManager.update(deltaTime);
		if (this.procedureManager) {
			if (this.procedureManager.currentProcedure instanceof Exit) {
				this.procedureManager.shutDown();
				this.procedureManager = null;
			}
		}
		
	}
}

}
class OwnerType {

}
import CFsm = fsm.CFsm;
class Login extends procedure.CProcedureBase {
protected onInit(fsm:CFsm) : void {
	super.onInit(fsm);

	log.CLog.log("Login.onInit");
}

protected onEnter(fsm:CFsm) : void {
	super.onEnter(fsm);
	log.CLog.log("Login.onEnter");
}

protected onUpdate(fsm:CFsm, deltaTime:number) : void {
	super.onUpdate(fsm, deltaTime);
	log.CLog.log("Login.onUpdate");

	this.changeProcedure(fsm, Loading);
}

protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
	super.onLeave(fsm, isShutDown);
	log.CLog.log("Login.onLeave");
}

protected onDestroy(fsm:CFsm) : void {
	super.onDestroy(fsm);
	log.CLog.log("Login.onDestroy");
}
}
class Loading extends procedure.CProcedureBase {
protected onInit(fsm:CFsm) : void {
	super.onInit(fsm);
	log.CLog.log("Loading.onInit");
}

protected onEnter(fsm:CFsm) : void {
	super.onEnter(fsm);
	log.CLog.log("Loading.onEnter");
}

protected onUpdate(fsm:CFsm, deltaTime:number) : void {
	super.onUpdate(fsm, deltaTime);
	log.CLog.log("Loading.onUpdate");

	this.changeProcedure(fsm, Gaming);
}

protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
	super.onLeave(fsm, isShutDown);
	log.CLog.log("Loading.onLeave");
}

protected onDestroy(fsm:CFsm) : void {
	super.onDestroy(fsm);
	log.CLog.log("Loading.onDestroy");
}
}
class Gaming extends procedure.CProcedureBase {
protected onInit(fsm:CFsm) : void {
	super.onInit(fsm);
	log.CLog.log("Gaming.onInit");
}

protected onEnter(fsm:CFsm) : void {
	super.onEnter(fsm);
	log.CLog.log("Gaming.onEnter");
}

protected onUpdate(fsm:CFsm, deltaTime:number) : void {
	super.onUpdate(fsm, deltaTime);
	log.CLog.log("Gaming.onUpdate");

	this.changeProcedure(fsm, Exit);
}

protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
	super.onLeave(fsm, isShutDown);
	log.CLog.log("Gaming.onLeave");
}

protected onDestroy(fsm:CFsm) : void {
	super.onDestroy(fsm);
	log.CLog.log("Gaming.onDestroy");
}
}
class Exit extends procedure.CProcedureBase {
	protected onInit(fsm:CFsm) : void {
	super.onInit(fsm);
	log.CLog.log("Exit.onInit");
}

protected onEnter(fsm:CFsm) : void {
	super.onEnter(fsm);
	log.CLog.log("Exit.onEnter");
}

protected onUpdate(fsm:CFsm, deltaTime:number) : void {
	super.onUpdate(fsm, deltaTime);
	log.CLog.log("Exit.onUpdate");

	
}

protected onLeave(fsm:CFsm, isShutDown:boolean) : void {
	super.onLeave(fsm, isShutDown);
	log.CLog.log("Exit.onLeave");
}

protected onDestroy(fsm:CFsm) : void {
	super.onDestroy(fsm);
	log.CLog.log("Exit.onDestroy");
	
}
}
}