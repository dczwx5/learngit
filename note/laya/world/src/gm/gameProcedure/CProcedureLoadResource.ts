import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import { log } from "../../hbcore/framework/log";
import CProcedureGameInitilize from "./CProcedureGameInitilize";
import CGameProcedureBase from "./CGameProcedureBase";
import CGlobalConf from "../CGlobalConf";
/**
 * ...
 * @author
 */
export default class CProcedureLoadResource extends CGameProcedureBase {
	constructor(){
		super();
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		super.onEnter(fsm);

		this.m_bFinish = false;
		
		// 加载资源
		log.log('开始加载资源');
		let resList:string[] = ['comp'];
		for (let i:number = 0; i < resList.length; i++) {
			resList[i] = CGlobalConf.getAtlasPath(resList[i]);
		}

		// resList.push('common/paicai/img_num.png');
		Laya.loader.load(resList, Laya.Handler.create(this, this._onLoadResourceFinish));
	}

	private _onLoadResourceFinish() : void {
		this.m_bFinish = true;
	}
	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);
		 
		if (this.m_bFinish) {
			log.log('资源完毕');
			this.changeProcedure(fsm, CProcedureGameInitilize);
		}
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}

	private m_bFinish:Boolean;

	private WAIT_SUB_LOAD_RESOURCE_TIME:Number = 1;
}