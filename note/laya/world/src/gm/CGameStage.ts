import { framework } from "../hbcore/framework/FrameWork";
import { pool } from "../hbcore/framework/pool";
import { fsm } from "../hbcore/framework/Fsm";
import { sound } from "../hbcore/framework/sound";
import { procedure } from "../hbcore/framework/procedure";
import { sequential } from "../hbcore/framework/sequential";
import { config } from "../hbcore/framework/config";
import CGameProcedureSystem from "./gameProcedure/CGameProcedureSystem";
import { gameframework } from "../hbcore/gameframework";
import { CGameSystem } from "./CGameSystem";

/**
 * ...
 * @author auto
 */
export class CGameStage extends framework.CAppStage {
	private static s_instance:CGameStage;
    static get instance() : CGameStage {
        return this.s_instance;
    } 

	constructor(pStartedHandler:Laya.Handler, pUpdateHandler?:Laya.Handler) {
		super();

		CGameStage.s_instance = this;

		this.m_pStartedHandler = pStartedHandler;
		this.m_pUpdateHandler = pUpdateHandler;

		let stageStart = new CGameStageStart(this);
		stageStart.on(Laya.Event.COMPLETE, this, this._onStageStarted, [stageStart]);
		
	}
	private _onStageStarted(stageStart:CGameStageStart) : void {
		stageStart.off(Laya.Event.COMPLETE, this, this._onStageStarted);
	   
        if (this.m_pStartedHandler) {
            this.m_pStartedHandler.run();
            this.m_pStartedHandler = null;
		}
		
		// 循环开始
        this.m_gameStageUpdate = new CGameStageUpdateProxy(this);
        this.startLoop();
        
	}
	
	startLoop() :void {
		// 循环在scene.update之后, 也就是所有其他的update执行完后, 才会执行这里的update
        Laya.timer.frameLoop(1, this, this._onLoop);
	}
	stopLoop() : void {
		Laya.timer.clearAll(this);
	}
	private _onLoop() : void {
		this.m_gameStageUpdate.update();
		if (this.m_pUpdateHandler) {
			this.m_pUpdateHandler.run();
		}
	}
	
	protected onAwake() : void {
		super.onAwake();

		this.addSystem(this.m_pool = new pool.CPoolSystem());
		this.addSystem(this.m_fsm = new fsm.CFsmSystem());
		this.addSystem(this.m_sequential = new sequential.CSequentiaProcedureSystem());
		this.addSystem(this.m_sound = new sound.CSoundSystem());
		this.addSystem(new CGameProcedureSystem());
		this.addSystem(this.m_gameSystem = new CGameSystem());
	}
	
	protected onDestroy() : void {
		super.onDestroy();
	}

	get poolSystem() : pool.CPoolSystem {
		return this.m_pool;
	}
	get fsmSystem() : fsm.CFsmSystem {
		return this.m_fsm;
	}
	get sequentialSystem() : sequential.CSequentiaProcedureSystem {
		return this.m_sequential;
	}
	get soundSystem() : sound.CSoundSystem {
		return this.m_sound;
	}
	get gameSystem() : CGameSystem {
		return this.m_gameSystem;
	}
	static get GameSystem() {
		return CGameStage.instance.gameSystem;
	}
	private m_pool:pool.CPoolSystem;
	private m_fsm:fsm.CFsmSystem;
	private m_sequential:sequential.CSequentiaProcedureSystem;
	private m_sound:sound.CSoundSystem;
	private m_gameSystem:CGameSystem;

	private m_pUpdateHandler:Laya.Handler;
    private m_pStartedHandler:Laya.Handler;
    private m_gameStageUpdate:CGameStageUpdateProxy;
	
}

// ===============================================================

export class CGameStageStart extends Laya.EventDispatcher {
	constructor(pGameStage:CGameStage){
		super();

		this.m_gameStage = pGameStage;
		this.m_gameStage.awake();
		
		Laya.timer.frameLoop(1, this, this._waitStart);
	}
	private _waitStart() : void {
		let isStarted:boolean = this.m_gameStage.start();
		if (isStarted) {
			Laya.timer.clear(this, this._waitStart);
			// Laya.timer.frameLoop(1, this, _onEnterFrame);
			this.m_isReady = true;
			this.event(Laya.Event.COMPLETE);
		}
	}
	
	get stage() : CGameStage {
		return this.m_gameStage;
	}

	private m_gameStage:CGameStage;

	get isReady() : boolean {
		return this.m_isReady;
	}
	private m_isReady:boolean;
}

// ===============================================================

export class CGameStageUpdateProxy extends Laya.EventDispatcher {
	constructor(pGameStage:CGameStage){
		super();

		this.m_gameStage = pGameStage;
		this.m_duringTime = 0;
	}
	
	update() : void {
		let deltaTime:number = Laya.timer.delta*0.001;
		this.m_gameStage.update(deltaTime);

		this.m_duringTime += deltaTime;
		while(this.m_duringTime >= this.FIX_TIME) {
			this.m_duringTime -= this.FIX_TIME;
			this.m_gameStage.fixUpdate(this.FIX_TIME);
		}
	}

	get stage() : CGameStage {
		return this.m_gameStage;
	}

	private m_gameStage:CGameStage;
	private m_duringTime:number;
	private FIX_TIME:number = 1/60;

	get isReady() : boolean {
		return this.m_isReady;
	}
	private m_isReady:boolean;
}