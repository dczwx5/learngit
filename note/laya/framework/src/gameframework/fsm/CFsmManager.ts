namespace gameframework {
export namespace fsm {
/**
 * ...
 * @author
 */
export class CFsmManager extends framework.CBean {
	constructor(){
		super();
		this.m_fsms = new Object();
	}

	protected onAwake() : void {
		super.onAwake();
	}
	protected onStart() : boolean {
		return super.onStart();
	}
	protected onDestroy() : void {
		super.onDestroy();

		for (let key in this.m_fsms) {
			let fsm:CFsmBase = this.m_fsms[key];
			delete this.m_fsms[key]; 

			if (fsm.isDestroyed) {
				continue;
			}
			fsm.shutDown();
		}
		this.m_fsms = null;
	}

	public update(deltaTime:number) : void {
		for (let key in this.m_fsms) {
			let fsm:CFsmBase = this.m_fsms[key];
			if (fsm.isDestroyed) {
				continue;
			}
			fsm.update(deltaTime);
		}
	}

	public getAllFsms() : Object {
		return this.m_fsms;
	}

	public getFsm(name:string) : CFsm {
		return this.m_fsms[name];
	}
	public getFsmByOwnerType(clazz:new()=>any) : CFsm {
		let fsm:CFsm;
		for (let key in this.m_fsms) {
			fsm = this.m_fsms[key];
			if (fsm.owner instanceof clazz) {
				return fsm;
			}
		}
		return null;
	}
	public getFsmsByOwnerType(clazz:new()=>any) : Array<CFsm> {
		let ret:Array<any> = new Array();
		let fsm:CFsm;
		for (let key in this.m_fsms) {
			fsm = this.m_fsms[key];
			if (fsm.owner instanceof clazz) {
				ret.push(fsm);
			}
		}
		return ret;
	}

	public createFsm(name:string, owner:Object, stateList:CFsmState[]) : CFsm {
		if (this.hasFsm(name)) {
			throw new Error("already exist FSM " + name);
		}
	
		let fsm:CFsm = new CFsm(name, owner, stateList);
		fsm.system = this.system;
		fsm.initialize();
		this.m_fsms[name] =fsm;
		// m_fsms.set(name, fsm);
		return fsm;
	}

	public destroyFsm(name:string) : boolean {
		let fsm:CFsmBase = this.m_fsms[name];
		if (fsm) {
			fsm.shutDown();
			delete this.m_fsms[name];
			return true;
		}
		return false;
	}

	public hasFsm(name:string) : boolean {
		return this.m_fsms.hasOwnProperty(name);
	}

	private m_fsms:Object; // key:string, value fsm
}
}
}