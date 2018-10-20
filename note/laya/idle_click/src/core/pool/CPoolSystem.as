package core.pool
{
	import laya.utils.Pool;
	import laya.utils.PoolCache;
	import laya.utils.CacheManager;
	import core.pool.CPoolBean;
	import core.framework.CAppSystem;
	import core.framework.CLifeCycle;

	/**
	 * ...
	 * @author
	 */
	public class CPoolSystem extends CAppSystem {
		public function CPoolSystem(){
			
		}

		protected override function onDestroy() : void {
			super.onDestroy();

			CacheManager.stopCheck();
			forceReleaseExternsPool();
		}

		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			// 检查并清除超出maxCount的元素
			CacheManager.beginCheck();

			return ret;
		}

		public function addPool(sign:String, type:Class, maxCount:int = 100) : CPoolBean {
			// 使用PoolCache.addPoolCacheManager 添加pool, 可将pool交给CacheManager管理
			var poolBean:CPoolBean = getPool(sign);
			if (!poolBean) {
				poolBean = new CPoolBean(sign, type);
				this.addBean(poolBean);
				poolBean.awake();
				poolBean.start();
			}
			PoolCache.addPoolCacheManager(sign, maxCount);
			
			return poolBean;
		}

		public function getPool(sign:String) : CPoolBean {
			var beans:Vector.<CLifeCycle> = this.getBeans();
			for each (var bean:CLifeCycle in beans) {
				if (bean is CPoolBean) {
					var poolBean:CPoolBean = bean as CPoolBean;
					if (poolBean.sign == sign) {
						return poolBean;
					}
				}
			}

			return null;
		}

		// 创建对象和回收对象, 与使用CPoolBean是一样的, 只不过CPoolBean保存了pool的类型
		public function createObject(flag:String, clazz:Class) : * {
			var item:* = Pool.getItemByClass(flag, clazz);
			return item;
		}

		public function recoverObject(flag:String, item) : void {
			Pool.recover(flag, item);
		}


		// 强制清除超出的pool, 但内部没处理, 只有清除超出maxCount的
		public function forceReleaseExternsPool() : void {
			CacheManager.forceDispose();
		}

	}

}