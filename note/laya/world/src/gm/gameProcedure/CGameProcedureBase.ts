import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import { log } from "../../hbcore/framework/log";
import CProcedureLoadDataTable from "./CProcedureLoadDataTable";

/**
 * ...
 * @author auto
 */
export default class CGameProcedureBase extends procedure.CProcedureBase {
	constructor(){
		super();
	}

	protected onEnter(fsm:fsm.CFsm) {
		super.onEnter(fsm);
		this.m_fsm = fsm;
	}

	forceChangeProcedure(stateType:new()=>any) {
		this.changeProcedure(this.m_fsm, stateType);
	}

	protected m_fsm:fsm.CFsm;
}
