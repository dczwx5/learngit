namespace gameframework {
export namespace pool {
/**
 * ...
 * @author
 */
export class CPoolSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onDestroy() : void {
		super.onDestroy();

		Laya.CacheManger.stopCheck();
		this.forceReleaseExternsPool();
	}

	protected onStart() : boolean {
		let ret:boolean = super.onStart();

		// 检查并清除超出maxCount的元素
		Laya.CacheManger.beginCheck();

		return ret;
	}

	public addPool(sign:string, type:new()=>any, maxCount:number = 100) : CPoolBean {
		// 使用PoolCache.addPoolCacheManager 添加pool, 可将pool交给CacheManager管理
		let poolBean:CPoolBean = this.getPool(sign);
		if (!poolBean) {
			poolBean = new CPoolBean(sign, type);
			this.addBean(poolBean);
			poolBean.awake();
			poolBean.start();
		}
		Laya.PoolCache.addPoolCacheManager(sign, maxCount);
		
		return poolBean;
	}

	public getPool(sign:string) : CPoolBean {
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
	public createObject(flag:string, clazz:new()=>any) : any {
		let item:any = Laya.Pool.getItemByClass(flag, clazz);
		return item;
	}

	public recoverObject(flag:string, item) : void {
		Laya.Pool.recover(flag, item);
	}


	// 强制清除超出的pool, 但内部没处理, 只有清除超出maxCount的
	public forceReleaseExternsPool() : void {
		Laya.CacheManger.forceDispose();
	}
}
}
}