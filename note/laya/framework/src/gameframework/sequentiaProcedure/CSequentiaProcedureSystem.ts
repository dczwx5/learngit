namespace gameframework {
export namespace sequentialProcedure {


/**
 * ...
 * @author
 */
export class CSequentiaProcedureSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onAwake() : void {
		super.onAwake();

		this.m_list = new ProcedureInfoList();
	}
	protected onStart() : boolean {
		return super.onStart();
	}

	protected onDestroy() : void {
		super.onDestroy();

		this.m_list.destroy();
		this.m_list = null;
	}

	// checkFinishHandler 的once要为false
	public addSequential(caller:any, handler:Laya.Handler, checkFinishHandler:Laya.Handler) : void {
		let info:ProcedureInfo = this.m_list.find(caller);
		if (!info) {
			info = this.m_list.create();
			info.isIdle = false;
			info.procedureManager.finishCallback = Laya.Handler.create(this, this._onSequnentialFinish, [caller]);
		}
		info.procedureManager.addSequential(handler, checkFinishHandler);
	}

	private _onSequnentialFinish(caller:any) : void {
		this.m_list.recycle(caller);
	} 

	private m_list:ProcedureInfoList;
}

}

class ProcedureInfoList {
public ProcedureInfoList() {
	this.m_list = new Array<ProcedureInfo>();
}

public destroy() : void {
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

public remove(caller:any) : void {
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
public find(caller:any) : ProcedureInfo {
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
public getIdle() : ProcedureInfo {
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
public  create() : ProcedureInfo {
	let info:ProcedureInfo = this.getIdle();
	if (!info) {
		info = new ProcedureInfo();
		let procedureManager:sequentialProcedure.CSequentialProcedureManager = new sequentialProcedure.CSequentialProcedureManager();
		info.procedureManager = procedureManager;
		this.m_list[this.m_list.length] = info;
	}
	
	return info;
}

public recycle(caller:any) : void {
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
public caller:any;
public handler:Laya.Handler;
public checkFinishHandler:Laya.Handler;
public procedureManager:sequentialProcedure.CSequentialProcedureManager;

public reset() : void {
	this.caller = null;
	this.handler = null;
	this.checkFinishHandler = null;
	this.isIdle = true;
}

public isIdle:boolean = true;
}
}