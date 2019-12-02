namespace gameframework {
export namespace fsm {
/**
 * ...
 * @author
 */
export abstract class CFsmBase {
	constructor(name:string){
		this.m_name = name;
	}


	public get Name() : string {
		return this.m_name;
	}

	public abstract get isDestroyed() : boolean ;

	public abstract get fsmStateCount() : number ;
	public abstract get isRunning() : boolean ;
	// public abstract get currentStateName() : string ;
	public abstract get currentStateTime() : number ;
	
	public abstract initialize() : void ;

	// abstract interface
	public abstract shutDown() : void ;

	public abstract update(deltaTime:number) : void ;

	private m_name:string;
	
}
}
}