import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import { log } from "../../hbcore/framework/log";
import CProcedureLoadDataTable from "./CProcedureLoadDataTable";
import CGameProcedureBase from "./CGameProcedureBase";
/**
 * ...
 * @author auto
 */
export default class CProcedureEntry extends CGameProcedureBase {
	constructor() {
		super();
	}

	protected onInit(fsm: fsm.CFsm): void {
		super.onInit(fsm);

	}
	protected onEnter(fsm: fsm.CFsm): void {
		super.onEnter(fsm);
		log.log('进入游戏');
	}

	protected onUpdate(fsm: fsm.CFsm, deltaTime: number): void {
		super.onUpdate(fsm, deltaTime);

		this.changeProcedure(fsm, CProcedureLoadDataTable);
	}
	protected onLeave(fsm: fsm.CFsm, isShutDown: boolean): void {
		super.onLeave(fsm, isShutDown);
	}
	protected onDestroy(fsm: fsm.CFsm): void {
		super.onDestroy(fsm);
	}
}
