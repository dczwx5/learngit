import { framework } from "./FrameWork";
import { log } from "./log";

export module sequential {

/**
 * ...
 * @author auto
 串行流程
	*/
export class CSequentialProcedureManager{
	constructor(){
		this.m_procedureInfoList = new Array<_CProcedureInfo>();
		this.reset();
	}

	reset() : void {
		this.m_isRunning = false;
		this.m_procedureInfoList.length = 0;
		this.m_currentProcedureInfo = null;
		this.m_finishCallback = null;
		Laya.timer.clear(this, this._onUpdate);
	}

	destroy() : void {
		this.m_isRunning = false;
		this.m_currentProcedureInfo = null;
		this.m_procedureInfoList = null;
		Laya.timer.clear(this, this._onUpdate);
	}
	// handler == checkFinishHandler == null : 则直接通过 -> 没意义
	// handler == null, checkFinishHandler != null, 则checkFinishHandler返回true, 通过 -> 用于等待某个条件完成
	// handler != null, checkFinishHandler == null, 执行一次handler, 然后通过 -> 用于调用一次handler, 和普通函数调用一置
	// handler != null, checkFinishHandler != null, 执行一次handler, 并等待checkFinishHandler返回true, 通过
	// 注意checkFinishHandler的once要设成false
	addSequential(handler:Laya.Handler, checkFinishHandler:Laya.Handler) : void {
		this.m_procedureInfoList[this.m_procedureInfoList.length] = new _CProcedureInfo(handler, checkFinishHandler);
		if (!this.m_isRunning) {
			this.m_isRunning = true;
			Laya.timer.frameLoop(1, this, this._onUpdate);
		}
	}

	private _onUpdate() : void {
		if (!this.m_currentProcedureInfo && this.m_procedureInfoList.length > 0) {
			this.m_currentProcedureInfo = this.m_procedureInfoList.shift();
			if (this.m_currentProcedureInfo.handler) {
				this.m_currentProcedureInfo.handler.run();
			}
		}
		if (this.m_currentProcedureInfo) {
			if (this.m_currentProcedureInfo.checkFinishHandler) {
				if (this.m_currentProcedureInfo.checkFinishHandler.run()) {
					// finish返回true, 完成
					this.m_currentProcedureInfo = null;
				}
			} else {
				// 没有finish直接完成
				this.m_currentProcedureInfo = null;
			}
		}

		if (!this.m_currentProcedureInfo && this.m_procedureInfoList.length == 0) {
			// stop
			this.m_isRunning = false;
			Laya.timer.clear(this, this._onUpdate);
			if (null != this.m_finishCallback) {
				this.m_finishCallback.run();
			}
			return ;
		}
	}

	set finishCallback(v:Laya.Handler) {
		this.m_finishCallback = v;
	}

	private m_procedureInfoList:Array<_CProcedureInfo>;
	private m_isRunning:boolean;
	private m_currentProcedureInfo:_CProcedureInfo;

	private m_finishCallback:Laya.Handler;

	private m_finish;
}

class _CProcedureInfo {
	constructor(handler:Laya.Handler, checkFinishHandler:Laya.Handler) {
		this.handler = handler;
		this.checkFinishHandler = checkFinishHandler;
	}
	handler:Laya.Handler;
	checkFinishHandler:Laya.Handler;a

}

// ============================================================================

export class CSequentiaProcedureSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onAwake() : void {
		log.log('CSequentiaProcedureSystem.onAwake');
		
		super.onAwake();

		this.m_list = new ProcedureInfoList();
	}
	protected onStart() : boolean {
		log.log('CSequentiaProcedureSystem.onStart');
		
		return super.onStart();
	}

	protected onDestroy() : void {
		super.onDestroy();

		this.m_list.destroy();
		this.m_list = null;
	}

	// handler == checkFinishHandler == null : 则直接通过 -> 没意义
	// handler == null, checkFinishHandler != null, 则checkFinishHandler返回true, 通过 -> 用于等待某个条件完成
	// handler != null, checkFinishHandler == null, 执行一次handler, 然后通过 -> 用于调用一次handler, 和普通函数调用一置
	// handler != null, checkFinishHandler != null, 执行一次handler, 并等待checkFinishHandler返回true, 通过
	// 注意checkFinishHandler的once要设成false	
	// 调用addSequential(xx, handler, checkhandker);
	//		1.先执行handle
	//		2.执行checkHandler, 直到checkHandler为true, 完成
	// 每个caller，会创建一个流程, 为一组
	addSequential(caller:any, handler:Laya.Handler, checkFinishHandler:Laya.Handler) : void {
		let info:ProcedureInfo = this.m_list.find(caller);
		if (!info) {
			info = this.m_list.create();
			info.isIdle = false;
			info.caller = caller;
			info.procedureManager.finishCallback = Laya.Handler.create(this, this._onSequnentialFinish, [caller]);
		}
		info.procedureManager.addSequential(handler, checkFinishHandler);
	}

	private _onSequnentialFinish(caller:any) : void {
		this.m_list.recycle(caller);
	}

	private m_list:ProcedureInfoList;
}

class ProcedureInfoList {
	constructor() {
		this.m_list = new Array<ProcedureInfo>();
	}

	destroy() : void {
		let i:number = 0;
		let len:number = this.m_list.length;
		let info:ProcedureInfo;
		for (; i < len; i++) {
			info = this.m_list[i];
			info.procedureManager.destroy();
			info.reset();
			info.procedureManager = null;
		}
		this.m_list.length = 0;
		this.m_list = null;
	}

	remove(caller:any) : void {
		let i:number = 0;
		let len:number = this.m_list.length;
		let info:ProcedureInfo;
		for (; i < len; i++) {
			info = this.m_list[i];
			if (info.caller == caller) {
				this.m_list.splice(i, 1);
				break;
			}
		}
	}
	find(caller:any) : ProcedureInfo {
		let i:number = 0;
		let len:number = this.m_list.length;
		let info:ProcedureInfo;
		for (; i < len; i++) {
			info = this.m_list[i];
			if (info.caller == caller) {
				return info;
			}
		}
		return null;
	}
	getIdle() : ProcedureInfo {
		let i:number = 0;
		let len:number = this.m_list.length;
		let info:ProcedureInfo;
		for (; i < len; i++) {
			info = this.m_list[i];
			if (info.isIdle) {
				return info;
			}
		}
		return null;
	}
	 create() : ProcedureInfo {
		let info:ProcedureInfo = this.getIdle();
		if (!info) {
			info = new ProcedureInfo();
			let procedureManager:CSequentialProcedureManager = new CSequentialProcedureManager();
			info.procedureManager = procedureManager;
			this.m_list[this.m_list.length] = info;
		}
		
		return info;
	}

	recycle(caller:any) : void {
		if (this.m_list.length > 10) {
			this.remove(caller);
		} else {
			let info:ProcedureInfo = this.find(caller);
			info.reset();
		}
	}

	private m_list:Array<ProcedureInfo>;

}

class ProcedureInfo {
	caller:any;
	handler:Laya.Handler;
	checkFinishHandler:Laya.Handler;
	procedureManager:CSequentialProcedureManager;

	reset() : void {
		this.caller = null;
		this.handler = null;
		this.checkFinishHandler = null;
		this.isIdle = true;
	}

	isIdle:boolean = true;
}

}