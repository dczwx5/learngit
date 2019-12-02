import { procedure } from "../../hbcore/framework/procedure";
import { fsm } from "../../hbcore/framework/Fsm";
import EProcedureKey from "./EProcedureKey";
import { ESceneID, ESceneType } from "./ESceneID";
import CProcedureChangeScene from "./CProcedureChangeScene";
import { log } from "../../hbcore/framework/log";
import Lang from "../../hbcore/framework/Lang";
import { config } from "../../hbcore/framework/config";
import CProcedureLoadResource from "./CProcedureLoadResource";
import CGameProcedureBase from "./CGameProcedureBase";
import CGlobalConf from "../CGlobalConf";
import { CGameStage } from "../CGameStage";
import { CGameSystem } from "../CGameSystem";

/**
 * ...
 * @author
 */
export default class CProcedureLoadDataTable extends CGameProcedureBase {
	constructor(){
		super();
	}

	protected onInit(fsm:fsm.CFsm) : void {
		super.onInit(fsm);
	}
	protected onEnter(fsm:fsm.CFsm) : void {
		log.log("配置加载...");
		
		super.onEnter(fsm);

		this.m_bFinished = false;
		this._loadConfigs(this, function () : void {
			this.m_bFinished = true;
		});
	}
	protected onUpdate(fsm:fsm.CFsm, deltaTime:number) : void {
		super.onUpdate(fsm, deltaTime);

		if (this.m_bFinished) {
			log.log("配置加载完毕...");		
			this.changeProcedure(fsm, CProcedureLoadResource);
		}	
	}
	protected onLeave(fsm:fsm.CFsm, isShutDown:boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected onDestroy(fsm:fsm.CFsm) : void {
		super.onDestroy(fsm);
	}

	_loadConfigs(caller: any, callback: Function): void {
        let loadLangFunc = (url: string) => {
            let langData = Laya.loader.getRes(url);
            Lang.initialize(langData);
            callback.apply(caller);
        };
        let loadConfigFunc = (configData) => {
			let pGameSystem = this.m_fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
			pGameSystem.config.initConf(configData);
			
            let langType: string = configData.lang;
            if (!langType || langType.length == 0) {
                langType = 'zh_cn';
            }
            let langURL: string = "conf/" + langType + ".xml";
            // 加载xml
            let loadLangHandler = Laya.Handler.create(null, loadLangFunc, [langURL]);
            Laya.loader.load(langURL, loadLangHandler, null, Laya.Loader.XML);
        };
        let loadConfigHandler = Laya.Handler.create(null, loadConfigFunc);
        Laya.loader.load(CGlobalConf.CONFIG_URL, loadConfigHandler, null, Laya.Loader.JSON);
	}
}
