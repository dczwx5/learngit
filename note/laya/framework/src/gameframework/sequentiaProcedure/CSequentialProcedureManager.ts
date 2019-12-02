namespace gameframework {
export namespace sequentialProcedure {

/**
 * ...
 * @author auto
 串行流程
	*/
export class CSequentialProcedureManager{
	constructor(){
		this.reset();
	}

	public reset() : void {
		this.m_isRunning = false;
		this.m_procedureInfoList.length = 0;
		this.m_currentProcedureInfo = null;
		this.m_finishCallback = null;
		Laya.timer.clear(this, this._onUpdate);
	}

	public destroy() : void {
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
	public addSequential(handler:Laya.Handler, checkFinishHandler:Laya.Handler) : void {
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

	public set finishCallback(v:Laya.Handler) {
		this.m_finishCallback = v;
	}

	private m_procedureInfoList:Array<_CProcedureInfo>;
	private m_isRunning:boolean;
	private m_currentProcedureInfo:_CProcedureInfo;

	private m_finishCallback:Laya.Handler;
}
}

class _CProcedureInfo {
constructor(handler:Laya.Handler, checkFinishHandler:Laya.Handler) {
	this.handler = handler;
	this.checkFinishHandler = checkFinishHandler;
}
public handler:Laya.Handler;
public checkFinishHandler:Laya.Handler;

}
}