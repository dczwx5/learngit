namespace gameframework {
export namespace procedure {

/**
 * ...
 * @author
 */
export class CProcedureManager implements IProcedureManager {
	public CProcedureManager(){
		

	}

	public get currentProcedure() : CProcedureBase {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}

		return this.m_procedureFsm.currentState as CProcedureBase;
	}

	public get currentProcedureTime() : number {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}

		return this.m_procedureFsm.currentStateTime;
	}
	
	public initialize(name:string, fsmManager:fsm.CFsmManager, procedures:fsm.CFsmState[]) : void {
		if (!fsmManager) {
			throw new Error("fsm manager is invalid");
		}
		this.m_name = name;
		this.m_pFsmManager = fsmManager;
		this.m_procedureFsm = this.m_pFsmManager.createFsm(name, this, procedures);
	}

	public startProcedure(typeProcedure:new()=>any) : void {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}
		this.m_procedureFsm.start(typeProcedure);
	}

	public hasProcedure(typeProcedure:new()=>any) : boolean {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}
		return this.m_procedureFsm.hasState(typeProcedure);
	}

	public getProcedure(typeProcedure:new()=>any) : CProcedureBase {
		if (this.m_procedureFsm == null) {
			throw new Error("you must iniialize procedure first");
		}
		return this.m_procedureFsm.getState(typeProcedure) as CProcedureBase;
	}

	public update(deltaTime:number) : void {
		// trace("CProcedureManager.update----------------");
	}
	public shutDown() : void {
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

	public get name() : string {
		return this.m_name;
	}
	private m_name:string;
}
}
}