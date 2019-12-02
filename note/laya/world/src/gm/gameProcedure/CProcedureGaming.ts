import { fsm } from "../../hbcore/framework/Fsm";
import { procedure } from "../../hbcore/framework/procedure";
import EProcedureKey from "./EProcedureKey";
import {ESceneID, ESceneType} from "./ESceneID";
import CProcedureChangeScene from "./CProcedureChangeScene";
import { log } from "../../hbcore/framework/log";
import CGameProcedureBase from "./CGameProcedureBase";
import { CGameStage } from "../CGameStage";
import { CGameSystem } from "../CGameSystem";

/**
 * ...
 * @author
 */
export default class CProcedureGaming extends CGameProcedureBase {
	constructor(){
		super();
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		log.log('进入游戏场景');
		super.onEnter(fsm);

		this.m_bFinished = false;

		let pGameSystem = fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
		let eventDispatcher = pGameSystem.eventDispatcher;
		eventDispatcher.listenEvent(eventDispatcher.GameEvent.EVENT_TO_LOGIN, this, this._onReturnGameHall);
	}
	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);

		if (this.m_bFinished) {
			fsm.setData(EProcedureKey.NEXT_SCENE_TYPE, ESceneType.LOGIN);
			fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.LOGIN);
			this.changeProcedure(fsm, CProcedureChangeScene);
		}
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);

		let pGameSystem = fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
		let eventDispatcher = pGameSystem.eventDispatcher;
		eventDispatcher.unlistenEvent(eventDispatcher.GameEvent.EVENT_TO_LOGIN, this, this._onReturnGameHall);
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}

	private _onReturnGameHall() {
		this.m_bFinished = true;
	}
}
