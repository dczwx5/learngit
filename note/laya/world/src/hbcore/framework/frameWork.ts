import { ILifeCycle } from "./interface/ILifeCycle";
import { IUpdate } from "./interface/IUpdate";
import { IFixUpdate } from "./interface/IFixUpdate";

export module framework {

	/**
	 * ...
	 * @author auto
	 */

	export class CLifeCycle extends Laya.EventDispatcher implements ILifeCycle {
		constructor() {
			super();
			this.m_state = CLifeCycle.STATE_UNREADY;
		}

		// =================================================

		destroy(): void {
			this.onDestroy();
		}
		awake(): void {
			if (this.isUnReady) {
				this.onAwake();
			}
		}
		start(): boolean {
			return this.onStart();
		}

		// =================================================

		protected onAwake(): void {
			this.m_state = CLifeCycle.STATE_AWAKED;

			// let typeName:string = CCommon.getQualifiedClassName(this);
			// CLog.log("{0} onAwake", typeName);
		}
		protected onStart(): boolean {
			this.m_state = CLifeCycle.STATE_STARTED;

			// let typeName:string = CCommon.getQualifiedClassName(this);
			// CLog.log("{0} onStart", typeName);

			return true;
		}

		protected onDestroy(): void {
			this.m_state = CLifeCycle.STATE_DESTORYED;
			// let typeName:string = CCommon.getQualifiedClassName(this);
			// CLog.log("{0} onDestroy", typeName);
		}

		// =================================================

		get isAwakeState(): boolean {
			return this.m_state == CLifeCycle.STATE_AWAKED;
		}
		get isUnReady(): boolean {
			return this.m_state == CLifeCycle.STATE_UNREADY;
		}
		get isAwaked(): boolean {
			return this.m_state >= CLifeCycle.STATE_AWAKED;
		}
		get isStarted(): boolean {
			return this.m_state == CLifeCycle.STATE_STARTED;
		}
		get isDestoryed(): boolean {
			return this.m_state == CLifeCycle.STATE_DESTORYED;
		}

		protected m_state: number;

		static STATE_UNREADY: number = -1;
		static STATE_AWAKED: number = 0;
		static STATE_STARTED: number = 1;
		static STATE_DESTORYED: number = 2;

		get data(): Object {
			return this.m_dataObject;
		}
		set data(v: Object) {
			this.m_dataObject = v;
		}
		protected m_dataObject: Object;

	}

	// =============================================================================================
	/**
	 * ...
	 * @author auto
	 */
	export class CContainerLifeCycle extends CLifeCycle {
		constructor() {
			super();

			this.m_beanList = new Array<CLifeCycle>();
			this.m_unReadyBeanList = new Array<CLifeCycle>();
			this.m_unStartBeanList = new Array<CLifeCycle>();
		}

		// =================================================

		destroy(): void {
			super.destroy();

			for (let i: number = this.m_beanList.length - 1; i >= 0; i--) {
				let o: CLifeCycle = this.m_beanList[i];
				o.destroy();
			}
		}

		awake(): void {
			super.awake();

			this._awakeUnReadyBean();
		}
		private _awakeUnReadyBean() {
			if (this.m_unReadyBeanList.length > 0) {
				for (let i: number = 0; i < this.m_unReadyBeanList.length; i++) {
					let o: CLifeCycle = this.m_unReadyBeanList[i];
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
		start(): boolean {
			let ret: boolean = super.start();
			if (!ret) {
				return ret;
			}

			if (this.m_unStartBeanList.length > 0) {
				for (let i: number = 0; i < this.m_unStartBeanList.length; i++) {
					let o: CLifeCycle = this.m_unStartBeanList[i];
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


		protected onAwake(): void {
			super.onAwake();
		}
		// onStart如果return false, 则会多次调用直到为true
		protected onStart(): boolean {
			return super.onStart();
		}
		protected onDestroy(): void {
			super.onDestroy();
		}


		// =================================================

		getBean(clz: new () => CLifeCycle): CLifeCycle {
			if (this.m_beanList) {
				for (let i: number = 0; i < this.m_beanList.length; i++) {
					let o: CLifeCycle = this.m_beanList[i];
					if (o instanceof clz) {
						return o;
					}
				}
			}
			return null;
		}
		getBeans(): Array<CLifeCycle> {
			return this.m_beanList;
		}

		removeBean(b: CLifeCycle): boolean {
			if (!b) {
				return false;
			}

			let index: number = this.m_beanList.indexOf(b);
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

		addBean(o: CLifeCycle): boolean {
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

		contains(o: CLifeCycle): boolean {
			for (let i: number = 0; i < this.m_beanList.length; i++) {

				let b: CLifeCycle = this.m_beanList[i];
				if (b == o) {
					return true;
				}
			}
			return false;
		}


		private m_beanList: Array<CLifeCycle>;
		private m_unReadyBeanList: Array<CLifeCycle>;
		private m_unStartBeanList: Array<CLifeCycle>;
	}

	// =============================================================================================
	/**
	 * ...
	 * @author
	 */
	export class CBean extends CContainerLifeCycle {
		constructor() {
			super();
		}

		addBean(o: CLifeCycle): boolean {
			let ret: boolean = super.addBean(o);

			if (ret) {
				(o as CBean).system = this.system;
			}
			return ret;
		}
		protected onAwake(): void {
			super.onAwake();
		}
		protected onStart(): boolean {
			return super.onStart();
		}
		protected onDestroy(): void {
			this.m_system = null;
			super.onDestroy();
		}

		get system(): CAppSystem {
			return this.m_system;
		}
		set system(v: CAppSystem) {
			this.m_system = v;
		}

		private m_system: CAppSystem;
	}

	// =============================================================================================

	/**
	 * ...
	 * @author auto
	 */
	export class CAppSystem extends CContainerLifeCycle implements IUpdate {
		constructor() {
			super();
		}
		protected onAwake(): void {
			super.onAwake();
		}
		protected onStart(): boolean {
			let ret: boolean = super.onStart();
			return ret;
		}

		protected onDestroy(): void {
			this.m_stage = null;

			super.onDestroy();

			// this.m_viewList = null;
		}

		// view
		// getAllViewBean() : Array<CViewBean> {
		// 	return m_viewList;
		// }
		update(delta: number): void {
			// if (m_viewList) {
			// 	for each (let view:CViewBean in m_viewList) {
			// 		if (view && view.isStarted) {
			// 			if (view.isDirty) {
			// 				view.updateData(delta);
			// 			}
			// 		}
			// 	}
			// }
		}

		addBean(o: CLifeCycle): boolean {
			let ret: boolean = super.addBean(o);
			if (ret) {
				(o as CBean).system = this;
			}

			// if (o is CViewBean) {
			// 	if (!m_viewList) {
			// 		m_viewList = new Array<CViewBean>();
			// 	}
			// 	m_viewList.push(o);
			// }

			return ret;
		}
		removeBean(b: CLifeCycle): boolean {
			let ret: boolean = super.removeBean(b);
			// if (b is CViewBean) {
			// 	let idx:int = m_viewList.indexOf(b as CViewBean);
			// 	m_viewList.splice(idx, 1);
			// }
			return ret;
		}

		get stage(): CAppStage {
			return this.m_stage;
		}
		set stage(v: CAppStage) {
			this.m_stage = v;
		}

		private m_stage: CAppStage;

		// private let m_viewList:Array<CViewBean>;

	}



	// =============================================================================================
	/**
	 ...
	1.update/fixUpdate : 继承IUpdate/IFixUpdate的system, 会自动调用update与fixUpdate, 并不会往下自动调用(避免调用太多无用的update)
	2.在OnAwake中addBean的节点, 会自动启动, 其他的需要自行调用awake与start:
	如 : (在awake之外添加)
		addBean(b);
		b.awake();
		b.start();
	* @author auto
	*/
	export class CAppStage extends CContainerLifeCycle implements IUpdate, IFixUpdate {
		constructor() {
			super();
		}

		update(deltaTime: number): void {
			let b: CLifeCycle;
			let beans: Array<CLifeCycle> = this.getBeans();
			let iCount: number = beans.length;
			for (let i: number = 0; i < iCount; i++) {
				b = beans[i];
				if (b.isStarted) {
					let iupdate: Function = b['update'];
					if (iupdate) {
						b['update'](deltaTime);
					}
				}
			}
		}
		fixUpdate(fixTime: number): void {
			let b: CLifeCycle;
			let beans: Array<CLifeCycle> = this.getBeans();
			let iCount: number = beans.length;
			for (let i: number = 0; i < iCount; i++) {
				b = beans[i];
				if (b.isStarted) {
					let iupdate: Function = b['fixUpdate'];
					if (iupdate) {
						b['fixUpdate'](fixTime);
					}
				}
			}
		}

		protected onAwake(): void {
			super.onAwake();
		}
		protected onStart(): boolean {
			return super.onStart();
		}

		protected onDestroy(): void {
			super.onDestroy();
		}

		getSystem(clazz: new () => CAppSystem): CAppSystem {
			return this.getBean(clazz) as CAppSystem;
		}
		addSystem(sys: CAppSystem): boolean {
			if (this.addBean(sys)) {
				sys.stage = this;
			}
			return false;
		}
		removeSystem(sys: CAppSystem): boolean {
			return this.removeBean(sys);
		}
		/** 先不支持
		getAllViewBean() : Array<CViewBean> {
			let ret:Array<CViewBean> = new Array<CViewBean>();
			let allBeans:Array<CLifeCycle>  = this.getBeans();
			for each (let b:CLifeCycle in allBeans) {
				if (b is CAppSystem) {
					let sys:CAppSystem = b as CAppSystem;
					let viewsInSys:Array<CViewBean> = sys.getAllViewBean();
					for each (let view:CViewBean in viewsInSys) {
						ret.push(view);
					}
				}
			}
		
			return ret;
		}
		*/
	}

	// =============================================================================================
}