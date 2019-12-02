namespace gameframework {
export namespace fsm {

/**
 * ...
 * @author
 */
export class CFsmSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onAwake() : void {
		super.onAwake();
		this.m_proceudres = new Object();
		this.m_fsmManager = new CFsmManager();
		this.addBean(this.m_fsmManager);
		
	}
	protected onStart() : boolean {
		return super.onStart();
	}

	protected onDestroy() : void {
		super.onDestroy();

		for (let key in this.m_proceudres) {
			delete this.m_proceudres[key];
		}
		this.m_proceudres = null;
		
		this.m_fsmManager = null;
	}

	public createFsm(name:string, owner:Object, stateList:CFsmState[]) : CFsm {
		let fsm:CFsm = this.m_fsmManager.createFsm(name, owner, stateList);
		return fsm;
	}
	public getFsm(name:string) : CFsm {
		return this.m_fsmManager.getFsm(name);
	}
	public destroyFsm(name:string) : boolean {
		return this.m_fsmManager.destroyFsm(name);
	}

	public hasFsm(name:string) : boolean {
		return this.m_fsmManager.hasFsm(name);
	}
	public update(deltaTime:number) : void {
		super.update(deltaTime);

		this.m_fsmManager.update(deltaTime);
	}

	// 流程
	public createProcedure(name:string, procedures:CFsmState[]) : procedure.CProcedureManager {
		let procedureManager:procedure.CProcedureManager = new procedure.CProcedureManager();
	
		procedureManager.initialize(name, this.m_fsmManager, procedures);
		this.m_proceudres[name] = procedureManager;
		return procedureManager;
	}
	public getProcedure(name:string) : procedure.CProcedureManager {
		return this.m_proceudres[name];
	}
	public removeProcedure(name:string) : void {
		
		let manager:procedure.CProcedureManager = this.getProcedure(name);
		if (manager) {
			manager.shutDown();
			delete this.m_proceudres[name];
		}

	}


	private m_fsmManager:CFsmManager;

	private m_proceudres:Object;
}
}
}