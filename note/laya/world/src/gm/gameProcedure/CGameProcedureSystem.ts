import { procedure } from "../../hbcore/framework/procedure";
import { framework } from "../../hbcore/framework/frameWork";
import { fsm } from "../../hbcore/framework/Fsm";
import CProcedureEntry from "./CProcedureEntry";
import CProcedureLoadResource from "./CProcedureLoadResource";
import CProcedureLoadDataTable from "./CProcedureLoadDataTable";
import CProcedureChangeScene from "./CProcedureChangeScene";
import CProcedureGaming from "./CProcedureGaming";
import { log } from "../../hbcore/framework/log";
import CProcedureLogin from "./CProcedureLogin";
import CProcedureGameInitilize from "./CProcedureGameInitilize";
import CGameProcedureBase from "./CGameProcedureBase";
import CProcedureConnect from "./CProcedureConnect";

/**
 * ...
 * @author auto
 * 游戏流程控制
 */
export default class CGameProcedureSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onAwake() : void {
		super.onAwake();
		
		log.log('CGameProcedureSystem.onAwake');
		
		let procedureList:fsm.CFsmState[] = [
			new CProcedureEntry(), new CProcedureLoadResource(), new CProcedureLoadDataTable(), 
			new CProcedureGameInitilize(),
			new CProcedureConnect(),
			
			new CProcedureChangeScene(), 
			new CProcedureLogin(),
			new CProcedureGaming()
		];
		let fsmSystem:fsm.CFsmSystem = this.stage.getSystem(fsm.CFsmSystem) as fsm.CFsmSystem;
		this.m_procedureManager = fsmSystem.createProcedure("gameProcedure", procedureList);
	}
	protected onStart() : boolean {
		log.log('CGameProcedureSystem.onStart');
		
		let ret:boolean = super.onStart();
		this.m_procedureManager.startProcedure(CProcedureEntry);
		return ret;
	}

	protected onDestroy() : void {
		super.onDestroy();
	}

	returnToLogin() {
		if (this.m_procedureManager && this.m_procedureManager.currentProcedure) {
			(this.m_procedureManager.currentProcedure as CGameProcedureBase).forceChangeProcedure(CProcedureLogin);
		}
	}

	private m_procedureManager:procedure.CProcedureManager;
}