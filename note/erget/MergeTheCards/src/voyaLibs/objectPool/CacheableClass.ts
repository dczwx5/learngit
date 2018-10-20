namespace VL {
    export namespace ObjectCache {
        /**
         * 有对象池机制的类，通过调静态方法create创建或取出一个该类对象，restore放回对象池
         */
        export abstract class CacheableClass implements ICacheable {

            // private static _cachePool: ObjectPool = new ObjectPool();

            private static _objPoolDic: { [className: string]: ObjectPool } = {};

            /**
             * 从对象池取出
             * @param clzz
             * @returns {T}
             */
            public static create<T extends ICacheable>(clzz: new() => T): T {
                let className = getClassName(clzz);
                let pool = this._objPoolDic[className];
                if (pool && pool.length > 0) {
                    return pool.take() as T;
                } else {
                    return new clzz();
                }
            }

            /**
             * 从对象池取出或创建出来的时候要做的事
             * @param args
             */
            public abstract init(...args: any[]): CacheableClass;

            public abstract clear();

            /**
             * 放回对象池
             * @param {number} maxCacheCount 对象池最多存多少个对象
             */
            public restore(maxCacheCount: number = Number.MAX_VALUE) {
                restore(this, maxCacheCount);
            }

            public static restore(entity:ICacheable, maxCacheCount: number = Number.MAX_VALUE){
                entity.clear();
                let className = getClassName(entity);
                let pool = CacheableClass._objPoolDic[className];
                if (!pool) {
                    pool = CacheableClass._objPoolDic[className] = <ObjectPool>new ObjectPool(getClassByEntity(entity));
                }
                pool.maxLength = maxCacheCount;
                pool.restore(entity);
            }

        }
    }
}
// let create = VL.ObjectCache.CacheableClass.create;
let restore = VL.ObjectCache.CacheableClass.restore;
function create<T extends VL.ObjectCache.ICacheable>(clzz: new() => T ): T{
    return VL.ObjectCache.CacheableClass.create(clzz);
}