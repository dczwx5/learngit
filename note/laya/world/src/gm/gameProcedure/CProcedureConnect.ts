import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import EProcedureKey from "./EProcedureKey";
import { ESceneID, ESceneType } from "./ESceneID";
import CProcedureChangeScene from "./CProcedureChangeScene";
import { log } from "../../hbcore/framework/log";
import Lang from "../../hbcore/framework/Lang";
import CGameProcedureBase from "./CGameProcedureBase";
import { CGameStage } from "../CGameStage";
import { CGameSystem } from "../CGameSystem";

/**
 * ...
 * @author
 */
export default class CProcedureConnect extends CGameProcedureBase {
	constructor(){
		super();
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		log.log("连接服务器...");
		
		super.onEnter(fsm);

		this.m_bFinished = false;

		// GM.instance.eventDispater.on(this, GMEvent.EVENT_HALL_CONNECT_SUCCESS, this._onLoginSuccess);
		let pGameSystem = fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
		pGameSystem.network.initNetConect();


		this._onLoginSuccess(); // 
	}
	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);

		if (this.m_bFinished) {
			log.log("连接大厅服务器成功...");		
			fsm.setData(EProcedureKey.NEXT_SCENE_TYPE, ESceneType.LOGIN);
			fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.LOGIN);
			this.changeProcedure(fsm, CProcedureChangeScene);
		}	
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
		// GM.instance.eventDispater.off(this, GMEvent.EVENT_HALL_CONNECT_SUCCESS);
		
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}

	private _onLoginSuccess() {
		this.m_bFinished = true;
	}
}
