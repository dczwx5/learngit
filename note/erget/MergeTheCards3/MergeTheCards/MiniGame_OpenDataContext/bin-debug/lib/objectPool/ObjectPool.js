var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
/**
 * 对象池类
 */
var ObjectPool = (function () {
    function ObjectPool() {
        this._content = {};
        this._objs = [];
    }
    /**
     * 根据传入的类名取出一个该类的实例， 该类必须实现ICacheable接口
     * @param clazz 要取的对象的类，如果池中没有的话会根据反射创建一个
     * @param args
     * @returns {any}
     */
    ObjectPool.prototype.pop = function (clazz) {
        var args = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            args[_i - 1] = arguments[_i];
        }
        var className = getClassName(clazz);
        if (!className) {
            egret.warn(clazz['__proto__']['__class__'] + '需要加到window里面~~~~~~~~~~');
        }
        //类型检测
        if (clazz.prototype["__types__"].indexOf("ICacheable") < 0) {
            throw new Error(className + "未实现ICacheable接口，只有实现ICacheable接口的类才能使用对象池");
        }
        var list = this._content[className];
        var result;
        if (list && list.length) {
            result = list.pop();
        }
        else {
            result = new clazz();
        }
        result.init.apply(result, args);
        return result;
    };
    /**
     * 放入一个对象
     * @param obj
     *
     */
    ObjectPool.prototype.push = function (obj) {
        if (obj == null) {
            return false;
        }
        var className = getClassName(obj);
        this._content[className] = this._content[className] || [];
        this._content[className].push(obj);
        return true;
    };
    /**
     * 清除所有对象
     */
    ObjectPool.prototype.clear = function () {
        this._content = {};
        this._objs.length = 0;
    };
    /**
     * 清除某一类对象
     * @param classZ Class
     * @param clearFuncName 清除对象需要执行的函数
     */
    ObjectPool.prototype.clearClass = function (className, clearFuncName) {
        if (clearFuncName === void 0) { clearFuncName = null; }
        var list = this._content[className];
        while (list && list.length) {
            var obj = list.pop();
            if (clearFuncName) {
                obj[clearFuncName]();
            }
            obj = null;
        }
        this._content[className] = null;
        delete this._content[className];
    };
    /**
     * 缓存中对象统一执行一个函数
     * @param classZ Class
     * @param dealFuncName 要执行的函数名称
     */
    ObjectPool.prototype.dealFunc = function (className, dealFuncName) {
        var list = this._content[className];
        if (list == null) {
            return;
        }
        var i = 0;
        var len = list.length;
        for (i; i < len; i++) {
            list[i][dealFuncName]();
        }
    };
    return ObjectPool;
}());
__reflect(ObjectPool.prototype, "ObjectPool");
//# sourceMappingURL=ObjectPool.js.map