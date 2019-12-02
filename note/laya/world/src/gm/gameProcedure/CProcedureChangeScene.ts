import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import EProcedureKey from "./EProcedureKey";
import {ESceneID, ESceneType} from "./ESceneID";
import { log } from "../../hbcore/framework/log";
import CProcedureGaming from "./CProcedureGaming";
import CProcedureLogin from "./CProcedureLogin";
import CGameProcedureBase from "./CGameProcedureBase";
import CLoading from "../../game/loading/CLoading";

/**
 * ...
 * @author
 */
export default class CProcedureChangeScene extends CGameProcedureBase {
	constructor(){
		super();

		this.m_openSceneCompletedHandler = new Laya.Handler(this, this._onOpenSceneCompleted);	
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		log.log('切换场景')
		super.onEnter(fsm);

		this.m_bFinished = false;		

		let nextScene:string = fsm.getData(EProcedureKey.NEXT_SCENE_ID) as string;
		log.log('进入场景 : ', nextScene);
		CLoading.instance.show();
		Laya.Scene.open(nextScene, true, null, this.m_openSceneCompletedHandler);
	}

	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);

		if (this.m_bFinished) {
			let nextSceneType:number = fsm.getData(EProcedureKey.NEXT_SCENE_TYPE) as number;
			switch (nextSceneType) {
				case ESceneType.LOGIN :
					this.changeProcedure(fsm, CProcedureLogin);
					break;
				case ESceneType.GAMING :
					this.changeProcedure(fsm, CProcedureGaming);
					break;
			}
		}
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}

	private _onOpenSceneCompleted() {
		CLoading.instance.hide();
		this.m_bFinished = true;
	}

	private m_openSceneCompletedHandler:Laya.Handler;
}
