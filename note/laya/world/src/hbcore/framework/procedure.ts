import {fsm} from './fsm'
import { framework } from './frameWork';

export module procedure {

export interface IProcedureManager{
	initialize(name:string, fsmManager:fsm.CFsmManager, procedures:fsm.CFsmState[]) : void ;

	startProcedure(typeProcedure:new()=>any) : void ;

	hasProcedure(typeProcedure:new()=>any) : boolean ;

	getProcedure(typeProcedure:new()=>any) : CProcedureBase ;
}
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

	protected m_bFinished:boolean;
	
}

// ===================================================================

export class CProcedureManager implements IProcedureManager {
	constructor(){
	
	}

	get currentProcedure() : CProcedureBase {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}

		return this.m_procedureFsm.currentState as CProcedureBase;
	}

	get currentProcedureTime() : number {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}

		return this.m_procedureFsm.currentStateTime;
	}
	
	initialize(name:string, fsmManager:fsm.CFsmManager, procedures:fsm.CFsmState[]) : void {
		if (!fsmManager) {
			throw new Error("fsm manager is invalid");
		}
		this.m_name = name;
		this.m_pFsmManager = fsmManager;
		this.m_procedureFsm = this.m_pFsmManager.createFsm(name, this, procedures);
	}

	startProcedure(typeProcedure:new()=>any) : void {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}
		this.m_procedureFsm.start(typeProcedure);
	}

	hasProcedure(typeProcedure:new()=>any) : boolean {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}
		return this.m_procedureFsm.hasState(typeProcedure);
	}

	getProcedure(typeProcedure:new()=>any) : CProcedureBase {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}
		return this.m_procedureFsm.getState(typeProcedure) as CProcedureBase;
	}

	update(deltaTime:number) : void {
		// trace("CProcedureManager.update----------------");
	}
	shutDown() : void {
		if (this.m_pFsmManager != null) {
			if (this.m_procedureFsm != null) {
				this.m_pFsmManager.destroyFsm(this.m_procedureFsm.Name);
				this.m_procedureFsm = null;
			}
			this.m_pFsmManager = null;
		}
	}

	private m_pFsmManager:fsm.CFsmManager;
	private m_procedureFsm:fsm.CFsm;

	get name() : string {
		return this.m_name;
	}
	private m_name:string;
}
}
