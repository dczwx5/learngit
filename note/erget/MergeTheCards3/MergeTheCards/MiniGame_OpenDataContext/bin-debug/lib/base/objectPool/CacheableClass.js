var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
/**
 * 有对象池机制的类，通过调静态方法create创建或取出一个该类对象，restore放回对象池
 */
var CacheableClass = (function () {
    function CacheableClass() {
    }
    /**
     * 从对象池取出
     * @param args
     * @returns {T}
     */
    CacheableClass.create = function (clazz) {
        return this._cachePool.pop(clazz);
    };
    /**
     * 放回对象池
     */
    CacheableClass.prototype.restore = function () {
        this.clear();
        var clzz = getClassByInstance(this);
        if (!clzz) {
            egret.warn('這個類要放到window~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            egret.warn(this['__proto__']['__class__']);
        }
        clzz._cachePool.push(this);
    };
    CacheableClass._cachePool = new ObjectPool();
    return CacheableClass;
}());
__reflect(CacheableClass.prototype, "CacheableClass", ["ICacheable"]);
window['CacheableClass'] = CacheableClass;
//# sourceMappingURL=CacheableClass.js.map