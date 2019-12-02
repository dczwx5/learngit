namespace gameframework {
/**
 * ...
 * @author auto
 * 游戏流程系统
 */
export class CProcedureSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onAwake() : void {
		super.onAwake();
		
		let fsmSystem:fsm.CFsmSystem = this.stage.getSystem(fsm.CFsmSystem) as fsm.CFsmSystem;
		let procedureList:fsm.CFsmState[] = [
			
		];
		this.m_procedureManager = fsmSystem.createProcedure("gameProcedure", procedureList);
		
	}
	protected onStart() : boolean {
		let ret:boolean = super.onStart();

		// this.m_procedureManager.startProcedure(CProcedureEntry);

		return ret;
	}

	protected onDestroy() : void {
		super.onDestroy();
	}

	private m_procedureManager:procedure.CProcedureManager;
}

}