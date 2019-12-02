import { framework } from "./FrameWork";
import { log } from "./log";

// import framework from '../framework/FrameWork';

export module pool {
/**
 * ...
 * @author auto
 */
export class CPoolBean extends framework.CBean {
	constructor(sign:string, type:new()=>any){
		super();
		this.m_type = type;
		this.m_sign = sign;
	}

	get sign() : string {
		return this.m_sign;
	}
	get type() : new()=>any {
		return this.m_type;
	}

	createObject() : any {
		let item:any = Laya.Pool.getItemByClass(this.sign, this.type);
		let reset:Function = item["reset"];
		if (reset) {
			item.reset();
		}
		return item;
	}

	recoverObject(item:any) : void {
		let dispose:Function = item["dispose"];
		if (dispose) {
			item.dispose();
		}
		Laya.Pool.recover(this.sign, item);
	}

	private m_sign:string;
	private m_type:new()=>any;
}
// ==================================================================================
export class CPoolSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onDestroy() : void {
		super.onDestroy();

		Laya.CacheManger.stopCheck();
		this.forceReleaseExternsPool();
	}

	protected onAwake() : void {
		log.log('CPoolSystem.onAwake');
		
		super.onAwake();
	}

	protected onStart() : boolean {
		let ret:boolean = super.onStart();

		// 检查并清除超出maxCount的元素
		Laya.CacheManger.beginCheck();
		log.log('CPoolSystem.onStart')

		return ret;
	}

	// 清除所有内存池资源, 只清理CPoolBean管理的
	removeAllPoolMemory() : void {
		let beanList:Array<framework.CLifeCycle> = this.getBeans();
		let sign:string;
		for (let bean of beanList) {
			sign = (bean as pool.CPoolBean).sign;
			Laya.Pool.clearBySign(sign);
		}
	}
	removePoolMemory(sign:string) : void {
		// 因为边界检测没法清除. 如果移除poolBean, 则会导致下次addPool时, 会再增加一个边界检测, 
		// let poolBean:CPoolBean = this.getPool(sign);
		// if (poolBean) {
		// 	this.removeBean(poolBean);
		// 	// 边界检测没法清除
		// }

		// 清除内存池资源
		Laya.Pool.clearBySign(sign);
	}

	addPool(sign:string, type:new()=>any, maxCount:number = 100) : CPoolBean {
		// 使用PoolCache.addPoolCacheManager 添加pool, 可将pool交给CacheManager管理
		let poolBean:CPoolBean = this.getPool(sign);
		if (!poolBean) {
			poolBean = new CPoolBean(sign, type);
			this.addBean(poolBean);
			poolBean.awake();
			poolBean.start();
			Laya.PoolCache.addPoolCacheManager(sign, maxCount);		
		}
		
		return poolBean;
	}

	getPool(sign:string) : CPoolBean {
		let beans:Array<framework.CLifeCycle> = this.getBeans();
		for (let bean of beans) {
			if (bean instanceof CPoolBean) {
				let poolBean:CPoolBean = bean as CPoolBean;
				if (poolBean.sign == sign) {
					return poolBean;
				}
			}
		}

		return null;
	}

	// 创建对象和回收对象, 与使用CPoolBean是一样的, 只不过CPoolBean保存了pool的类型
	// 使用以下方法, 不会定时清理超过边界的内存
	createObject(flag:string, clazz:new()=>any) : any {
		let item:any = Laya.Pool.getItemByClass(flag, clazz);
		return item;
	}

	recoverObject(flag:string, item) : void {
		Laya.Pool.recover(flag, item);
	}

	// 强制清除超出的pool, 但内部没处理, 只有清除超出maxCount的
	forceReleaseExternsPool() : void {
		Laya.CacheManger.forceDispose();
	}
}
}