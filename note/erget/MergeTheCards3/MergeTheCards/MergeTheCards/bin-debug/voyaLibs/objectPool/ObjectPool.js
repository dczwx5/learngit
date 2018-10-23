var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ObjectCache;
    (function (ObjectCache) {
        /**
         * 对象池类
         */
        var ObjectPool = (function () {
            /**
             *
             * @param {{new(): T}} objClass 对象的类(构造函数)
             * @param {number} maxCacheCount 对象池中最多存多少个对象, 默认不做限制
             */
            function ObjectPool(objClass, maxCacheCount) {
                if (maxCacheCount === void 0) { maxCacheCount = Number.MAX_VALUE; }
                // this._objs = {};
                this._objClass = objClass;
                this._objs = [];
                this.maxLength = maxCacheCount;
            }
            /**
             * 根据传入的类名取出一个该类的实例， 该类必须实现ICacheable接口
             * @param clazz 要取的对象的类，如果池中没有的话会根据反射创建一个
             * @returns {T}
             */
            ObjectPool.prototype.take = function () {
                // let className = Reflector.getClassName(clazz);
                // if (!className) {
                //     egret.warn(clazz['__proto__']['__class__'] + '需要加到window里面~~~~~~~~~~')
                // }
                // //类型检测
                // if (clazz.prototype["__types__"].indexOf("ICacheable") < 0) {
                //     throw new Error(className + "未实现ICacheable接口，只有实现ICacheable接口的类才能使用对象池");
                // }
                var list = this._objs;
                var result;
                if (list && list.length > 0) {
                    result = list.pop();
                }
                else {
                    result = new this._objClass();
                }
                return result;
            };
            /**
             * 存入一个对象
             * @param obj
             * @returns {boolean} 如果存入成功返回true，如果超出缓存数量返回false
             */
            ObjectPool.prototype.restore = function (obj) {
                if (obj == null) {
                    return false;
                }
                // let className: string = Reflector.getClassName(obj);
                //
                // if (!this._objs[className]) {
                //     this._objs[className] = [];
                // }
                // let arrCache = this._objs[className];
                if (this._objs.length < this._maxLength) {
                    this._objs.push(obj);
                    return true;
                }
                else {
                    return false;
                }
            };
            /**
             * 清除所有对象
             */
            ObjectPool.prototype.clear = function () {
                // this._objs = {};
                this._objs.length = 0;
            };
            Object.defineProperty(ObjectPool.prototype, "length", {
                get: function () {
                    return this._objs.length;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(ObjectPool.prototype, "maxLength", {
                get: function () {
                    return this._maxLength;
                },
                set: function (value) {
                    if (value == this._maxLength) {
                        return;
                    }
                    this._maxLength = value;
                    if (this._objs.length > value) {
                        this._objs.length = value;
                    }
                },
                enumerable: true,
                configurable: true
            });
            return ObjectPool;
        }());
        ObjectCache.ObjectPool = ObjectPool;
        __reflect(ObjectPool.prototype, "VL.ObjectCache.ObjectPool");
    })(ObjectCache = VL.ObjectCache || (VL.ObjectCache = {}));
})(VL || (VL = {}));
//# sourceMappingURL=ObjectPool.js.map