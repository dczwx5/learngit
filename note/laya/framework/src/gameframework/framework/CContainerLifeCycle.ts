namespace gameframework {
export namespace framework {
/**
 * ...
 * @author auto
 */
export class CContainerLifeCycle extends  CLifeCycle {
	constructor(){
		super();
		
		this.m_beanList = new Array<CLifeCycle>();
		this.m_unReadyBeanList = new Array<CLifeCycle>();
		this.m_unStartBeanList = new Array<CLifeCycle>();
	}

	// =================================================

	public destroy() : void {
		super.destroy();

		for (let i:number = this.m_beanList.length - 1; i >= 0; i--) {
			let o:CLifeCycle = this.m_beanList[i];
			o.destroy();
		}
	}

	public awake() : void {
		super.awake();
		
		if (this.m_unReadyBeanList.length > 0) {
			for (let i:number = 0; i < this.m_unReadyBeanList.length; i++) {
				let o:CLifeCycle = this.m_unReadyBeanList[i];
				o.awake();

				if (o.isAwaked) {
					this.m_unReadyBeanList.splice(i, 1);
					i--;
					this.m_unStartBeanList.push(o);
				}
			}
		}
	}

	// 
	public start() : boolean {
		let ret:boolean = super.start();
		if (!ret) {
			return ret;
		}

		if (this.m_unStartBeanList.length > 0) {
			for (let i:number = 0; i < this.m_unStartBeanList.length; i++) {
				let o:CLifeCycle = this.m_unStartBeanList[i];
				ret = o.start();
				if (!ret) {
					return ret;
				}

				if (o.isStarted) {
					this.m_unStartBeanList.splice(i, 1);
					i--;
				}
			}
		}
		return true;
	}

	// =================================================


	protected onAwake() : void {
		super.onAwake();
	}
	// onStart如果return false, 则会多次调用直到为true
	protected onStart() : boolean {
		return super.onStart();
	}
	protected onDestroy() : void {
		super.onDestroy();
	}


	// =================================================

	public getBean(clz:new() => CLifeCycle) : CLifeCycle {
		if (this.m_beanList) {
			for (let i:number = 0; i <this.m_beanList.length; i++) {
				let o:CLifeCycle = this.m_beanList[i];
				if (o instanceof clz) {
					return o;
				}
			}
		}
		return null;
	}
	public getBeans() : Array<CLifeCycle> {
		return this.m_beanList;
	}

	public removeBean(b:CLifeCycle) : boolean {
		if (!b) {
			return false;
		}

		let index:number = this.m_beanList.indexOf(b);
		if (-1 == index) {
			return false;
		}

		this.m_beanList.splice(index, 1);

		index = this.m_unReadyBeanList.indexOf(b);
		if (-1 != index) {
			this.m_unReadyBeanList.splice(index, 1);
		}

		index = this.m_unStartBeanList.indexOf(b);
		if (-1 != index) {
			this.m_unStartBeanList.splice(index, 1);
		}
		return true;
	}

	public addBean(o:CLifeCycle) : boolean {
		if (!o) {
			return false;
		}

		if (this.contains(o)) {
			return false;
		}

		this.m_beanList.push(o);
		this.m_unReadyBeanList.push(o);

		return true;
	}

	public contains(o:CLifeCycle) : boolean {
		for (let i:number = 0; i <this.m_beanList.length; i++) {
		
			let b:CLifeCycle = this.m_beanList[i];
			if (b == o) {
				return true;
			}
		}
		return false;
	}

	
	private m_beanList:Array<CLifeCycle>;
	private m_unReadyBeanList:Array<CLifeCycle>;
	private m_unStartBeanList:Array<CLifeCycle>;
}
}
}