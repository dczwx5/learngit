import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import CProcedureChangeScene from "./CProcedureChangeScene";
import EProcedureKey from "./EProcedureKey";
import { ESceneID, ESceneType } from "./ESceneID";
import { log } from "../../hbcore/framework/log";
import CGameProcedureBase from "./CGameProcedureBase";
import { CGameStage } from "../CGameStage";
import { CGameSystem } from "../CGameSystem";

/**
 * ...
 * @author auto
 */
export default class CProcedureLogin extends CGameProcedureBase {
	constructor(){
		super();
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		log.log('进入登陆界面');
		
		super.onEnter(fsm);

		this.m_bFinished = false;

		let pGameSystem = fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
		let eventDispatcher = pGameSystem.eventDispatcher;
		eventDispatcher.listenEvent(eventDispatcher.GameEvent.EVENT_TO_GAMING, this, this._onEnterHall);
	}
	
	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);

		if (this.m_bFinished) {
			log.log('login成功');
	
			this.m_fsm.setData(EProcedureKey.NEXT_SCENE_TYPE, ESceneType.GAMING);
			this.m_fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.GAMING);
			this.changeProcedure(this.m_fsm, CProcedureChangeScene);		
		}
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);

		let pGameSystem = fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
		let eventDispatcher = pGameSystem.eventDispatcher;
		eventDispatcher.unlistenEvent(eventDispatcher.GameEvent.EVENT_TO_GAMING, this, this._onEnterHall);
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}

	private _onEnterHall() {
		this.m_bFinished = true;
	}
	
}
