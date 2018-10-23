var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ObjectCache;
    (function (ObjectCache) {
        /**
         * 有对象池机制的类，通过调静态方法create创建或取出一个该类对象，restore放回对象池
         */
        var CacheableClass = (function () {
            function CacheableClass() {
            }
            /**
             * 从对象池取出
             * @param clzz
             * @returns {T}
             */
            CacheableClass.create = function (clzz) {
                var className = getClassName(clzz);
                var pool = this._objPoolDic[className];
                if (pool && pool.length > 0) {
                    return pool.take();
                }
                else {
                    return new clzz();
                }
            };
            /**
             * 放回对象池
             * @param {number} maxCacheCount 对象池最多存多少个对象
             */
            CacheableClass.prototype.restore = function (maxCacheCount) {
                if (maxCacheCount === void 0) { maxCacheCount = Number.MAX_VALUE; }
                restore(this, maxCacheCount);
            };
            CacheableClass.restore = function (entity, maxCacheCount) {
                if (maxCacheCount === void 0) { maxCacheCount = Number.MAX_VALUE; }
                entity.clear();
                var className = getClassName(entity);
                var pool = CacheableClass._objPoolDic[className];
                if (!pool) {
                    pool = CacheableClass._objPoolDic[className] = new ObjectCache.ObjectPool(getClassByEntity(entity));
                }
                pool.maxLength = maxCacheCount;
                pool.restore(entity);
            };
            // private static _cachePool: ObjectPool = new ObjectPool();
            CacheableClass._objPoolDic = {};
            return CacheableClass;
        }());
        ObjectCache.CacheableClass = CacheableClass;
        __reflect(CacheableClass.prototype, "VL.ObjectCache.CacheableClass", ["VL.ObjectCache.ICacheable"]);
    })(ObjectCache = VL.ObjectCache || (VL.ObjectCache = {}));
})(VL || (VL = {}));
// let create = VL.ObjectCache.CacheableClass.create;
var restore = VL.ObjectCache.CacheableClass.restore;
function create(clzz) {
    return VL.ObjectCache.CacheableClass.create(clzz);
}
//# sourceMappingURL=CacheableClass.js.map