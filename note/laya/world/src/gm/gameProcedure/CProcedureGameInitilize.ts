import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import EProcedureKey from "./EProcedureKey";
import { ESceneID, ESceneType } from "./ESceneID";
import CProcedureChangeScene from "./CProcedureChangeScene";
import { log } from "../../hbcore/framework/log";
import Lang from "../../hbcore/framework/Lang";
import { config } from "../../hbcore/framework/config";
import DashBoard from "../../hbcore/dashboard/DashBoard";
import CGameProcedureBase from "./CGameProcedureBase";
import CProcedureConnect from "./CProcedureConnect";

/**
 * ...
 * @author
 */
export default class CProcedureGameInitilize extends CGameProcedureBase {
	constructor() {
		super();
	}

	protected onInit(fsm: fsm.CFsm): void {
		super.onInit(fsm);
	}
	protected onEnter(fsm: fsm.CFsm): void {
		log.log("游戏初始化...");

		super.onEnter(fsm);

		config.DEBUG = true; // GM.instance.isLocal;
	}
	protected onUpdate(fsm: fsm.CFsm, deltaTime: number): void {
		super.onUpdate(fsm, deltaTime);

		log.log("游戏初始化成功...");
		this.changeProcedure(fsm, CProcedureConnect);
	}
	protected onLeave(fsm: fsm.CFsm, isShutDown: boolean): void {
		super.onLeave(fsm, isShutDown);
	}
	protected onDestroy(fsm: fsm.CFsm): void {
		super.onDestroy(fsm);
	}
}
