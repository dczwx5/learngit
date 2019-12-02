namespace gameframework {
export namespace fsm {
import CAppSystem = framework.CAppSystem;

/**
 * ...
 * @author auto
 */
export class CFsm extends CFsmBase{
	constructor(name:string, owner:Object, stateList:CFsmState[]){
		super(name);

		this.m_owner = owner;
		this.m_states = new Array<CFsmState>(stateList.length);
		this.m_datas = new Object();

		let i:number = 0;
		for (; i <stateList.length; i++) {
			let fsmState:CFsmState = stateList[i];
			this.m_states[i] = fsmState;
		}

		this.m_currentStateTime = 0;
		this.m_currentState = null;
		this.m_isDestroyed = false;
	}

	public initialize() : void {
		let i:number = 0;
		for (; i < this.m_states.length; i++) {
			let fsmState:CFsmState = this.m_states[i];
			fsmState.initialize(this);
		}
		this.m_currentStateTime = 0;
		this.m_currentState = null;
		this.m_isDestroyed = false;
	}

	public start(stateType:new()=>any) : void {
		if (this.isRunning) {
			throw new Error("fsm is running, can nott start again");
		}

		let state:CFsmState = this.getState(stateType);
		if (state == null) {
			throw new Error("fsm not exist");
		}

		this.m_currentStateTime = 0;
		this.m_currentState = state;
		this.m_currentState.enter(this);
	}


	public get owner() : Object {
		return this.m_owner;
	}
	public get fsmStateCount() : number {
		return this.m_states.length;
	}
	public get isRunning() : boolean {
		return this.m_currentState != null;
	}
	public get isDestroyed() : boolean {
		return this.m_isDestroyed;
	}
	public get currentState() : CFsmState {
		return this.m_currentState;
	}
	public get currentStateTime() : number {
		return this.m_currentStateTime;
	}
	
	public hasState(stateType:new()=>any) : boolean {
		return this.getState(stateType) != null;
	}
	public getState(stateType:new()=>any) : CFsmState {
		let i:number = 0;
		for (; i < this.m_states.length; i++) {
			let state:CFsmState = this.m_states[i];
			if (state instanceof stateType) {
				return state;
			}
		}
		return null;
	}
	public getAllState() : Array<CFsmState> {
		return this.m_states;
	}
	public fireEevnt(sender:Object, eventID:number) : void {
		this.m_currentState.onEvent(this, sender, eventID, null);
	}

	public hasData(name:string) : boolean {
		return this.getData(name) != null;
	}
	public getData(name:string) : Object {
		if (name == null || name.length == 0) {
			throw new Error("name is invalid");
		}

		return this.m_datas[name];
	}
	public setData(name:string, data:Object) : void {
		if (name == null || name.length == 0) {
			throw new Error("name is invalid");
		}

		this.m_datas[name] = data;
	}
	public removeData(name:string) : void {
		if (name == null || name.length == 0) {
			throw new Error("name is invalid");
		}

		delete this.m_datas[name];
	}

	public update(deltaTime:number) : void {
		if (null == this.m_currentState) {
			return ;
		}

		this.m_currentStateTime += deltaTime;
		this.m_currentState.update(this, deltaTime);
	}
	public shutDown() : void {
		if (null != this.m_currentState) {
			this.m_currentState.leave(this, true);
			this.m_currentState = null;
			this.m_currentStateTime = 0;
		}

		for (let i:number = 0; i < this.m_states.length; i++) { 
			let state:CFsmState = this.m_states[i];
			state.destroy(this);
		}
		this.m_states.length = 0;
		for (let key in this.m_datas) {
			delete this.m_datas[key];
		}

		this.m_isDestroyed = true;

		this.m_pSystem = null;
	}

	public changeState(stateType:new()=>any) : void {
		if (null == this.m_currentState) {
			throw new Error("current state is invalid");
		}

		let state:CFsmState = this.getState(stateType);
		if (null == state) {
			throw new Error("fsm can not change state, state is not exist");
		}

		this.m_currentState.leave(this, false);
		this.m_currentStateTime = 0;
		this.m_currentState = state;
		this.m_currentState.enter(this);
	}

	public get system() : CAppSystem {
		return this.m_pSystem;
	}
	public set system(v:CAppSystem) {
		this.m_pSystem = v;
	}
	private m_pSystem:CAppSystem;

	private m_owner:Object;
	private m_states:Array<CFsmState>;
	private m_datas:Object;

	private m_currentState:CFsmState;
	private m_currentStateTime:number;
	private m_isDestroyed:boolean;
}
}
}