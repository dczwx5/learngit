namespace gameframework {

/**
 * ...
 * @author auto
 */
export class CGameStage extends framework.CAppStage {
	private static m_stage:CGameStage;
	
	public static getInstance() : CGameStage {
		if (CGameStage.m_stage == null) {
			CGameStage.m_stage = new CGameStage();
		}

		return CGameStage.m_stage;
	}

	constructor() {
		super();

		if (CGameStage.m_stage) {
			throw new Error("gamestage is exist");
		}
	}

	protected onAwake() : void {
		super.onAwake();

		this.addSystem(new pool.CPoolSystem());
		this.addSystem(new fsm.CFsmSystem());
		this.addSystem(new sequentialProcedure.CSequentiaProcedureSystem());
		this.addSystem(new sound.CSoundSystem());
		this.addSystem(new CProcedureSystem());
	}
	protected onStart() : boolean {
		return super.onStart();
	}
	protected onDestroy() : void {
		super.onDestroy();
	}
}

}