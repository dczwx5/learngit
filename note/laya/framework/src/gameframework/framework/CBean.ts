namespace gameframework {
export namespace framework {

/**
 * ...
 * @author
 */
export class CBean extends CContainerLifeCycle {
	constructor(){
		super();
	}

	public addBean(o:CLifeCycle) : boolean {
		let ret:boolean = super.addBean(o);

		if (ret) {
			(o as CBean).system = this.system;
		}
		return ret;
	}
	protected onAwake() : void {
		super.onAwake();
	}
	protected onStart() : boolean {
		return super.onStart();
	}
	protected onDestroy() : void {
		this.m_system = null;
		super.onDestroy();
	}

	public get system() : CAppSystem {
		return this.m_system;
	}
	public set system(v:CAppSystem) {
		this.m_system = v;
	}

	private m_system:CAppSystem;
}
}
}