namespace gameframework {
export namespace framework {
/**
 * ...
 * @author auto
 */

export class CLifeCycle extends Laya.EventDispatcher implements ILifeCycle {
	constructor(){
		super();
		this.m_state = CLifeCycle.STATE_UNREADY;
	}

	// =================================================

	public destroy() : void {
		this.onDestroy();
	}
	public awake() : void {
		if (this.isUnReady) {
			this.onAwake();
		}
	}
	public start() : boolean {
		return this.onStart();
	}

	// =================================================

	protected onAwake() : void {
		this.m_state = CLifeCycle.STATE_AWAKED;
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onAwake", typeName);
	}
	protected onStart() : boolean {
		this.m_state = CLifeCycle.STATE_STARTED;
		
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onStart", typeName);

		return true;
	}
	
	protected onDestroy() : void {
		this.m_state = CLifeCycle.STATE_DESTORYED;
		// let typeName:string = CCommon.getQualifiedClassName(this);
		// CLog.log("{0} onDestroy", typeName);
	}

	// =================================================

	public get isAwakeState() : boolean {
		return this.m_state == CLifeCycle.STATE_AWAKED;
	}
	public get isUnReady() : boolean {
		return this.m_state == CLifeCycle.STATE_UNREADY;
	}
	public get isAwaked() : boolean {
		return this.m_state >= CLifeCycle.STATE_AWAKED;
	}
	public get isStarted() : boolean {
		return this.m_state == CLifeCycle.STATE_STARTED;
	}
	public get isDestoryed() : boolean {
		return this.m_state == CLifeCycle.STATE_DESTORYED;
	}

	protected m_state:number;

	public static STATE_UNREADY:number = -1;
	public static STATE_AWAKED:number = 0;
	public static STATE_STARTED:number = 1;
	public static STATE_DESTORYED:number = 2;

	public get data() : Object {
		return this.m_dataObject;
	}
	public set data(v:Object) {
		this.m_dataObject = v;
	}
	protected m_dataObject:Object;
	
}
}
}