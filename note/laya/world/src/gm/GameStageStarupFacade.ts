import { log } from "../hbcore/framework/log";
import { CGameStage } from "./CGameStage";

export default class GameStageStarupFacade {

    start() : void {
        this.m_startTime = Laya.timer.currTimer;
        log.log('GM.initilize');
        
        let onInitilizeHandler:Laya.Handler = Laya.Handler.create(this, this._onInitilize);
        let onUpdateHandler:Laya.Handler = Laya.Handler.create(this, this._onUpdate, null, false);
        this.m_gameStage = new CGameStage(onInitilizeHandler, onUpdateHandler);
    }

    private _onInitilize() : void {
        let curTime:number = Laya.timer.currTimer;
        let costTime:number = curTime - this.m_startTime;
        log.log('GM.onInitilized. cost time : ', costTime.toString(), ' ms');
        log.log('_________________________________________________________________________');
        
    }
    
    // 主循环回调, 也可以当作是主循环, 但是会在其他update之后调用
    private _onUpdate():void {
		// 循环在scene.update之后, 也就是所有其他的update执行完后, 才会执行这里的update
        // let now:number = Laya.timer.currTimer;
        // this._curTime = now;
        // let deltaTime:number = Laya.timer.delta*0.001;  
    }

    get gameStage() : CGameStage { return this.m_gameStage; }

    private m_startTime:number;
    private m_gameStage:CGameStage;
    
}