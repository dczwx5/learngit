/**
 * 对象池类
 */
class ObjectPool {
    protected _content:any = {};
    protected _objs:ICacheable[] = [];

    /**
     * 根据传入的类名取出一个该类的实例， 该类必须实现ICacheable接口
     * @param clazz 要取的对象的类，如果池中没有的话会根据反射创建一个
     * @param args
     * @returns {any}
     */
    public pop<T>(clazz:new()=>T):T {
        let className = getClassName(clazz);
        if(!className){
            egret.warn(clazz['__proto__']['__class__']+'需要加到window里面~~~~~~~~~~')
        }
        //类型检测
        if(clazz.prototype["__types__"].indexOf("ICacheable") < 0){
            throw new Error(className + "未实现ICacheable接口，只有实现ICacheable接口的类才能使用对象池");
        }

        let list:T[] = this._content[className];
        let result:T;
        if (list && list.length) {
            result = list.pop();
        } else {
            result = new clazz();
        }
        // result.init(...args);
        return result;
    }

    /**
     * 放入一个对象
     * @param obj
     *
     */
    public push(obj:ICacheable):boolean {
        if (obj == null) {
            return false;
        }
        let className:string = getClassName(obj);

        this._content[className] = this._content[className] || [];
        this._content[className].push(obj);
        return true;
    }

    /**
     * 清除所有对象
     */
    public clear():void {
        this._content = {};
        this._objs.length = 0;
    }

    /**
     * 清除某一类对象
     * @param classZ Class
     * @param clearFuncName 清除对象需要执行的函数
     */
    public clearClass(className:string, clearFuncName:string = null):void {
        let list:Array<ICacheable> = this._content[className];
        while (list && list.length) {
            let obj:ICacheable = list.pop();
            if (clearFuncName) {
                obj[clearFuncName]();
            }
            obj = null;
        }
        this._content[className] = null;
        delete this._content[className];
    }

    /**
     * 缓存中对象统一执行一个函数
     * @param classZ Class
     * @param dealFuncName 要执行的函数名称
     */
    public dealFunc(className:string, dealFuncName:string):void {
        let list:ICacheable[] = this._content[className];
        if (list == null) {
            return;
        }

        let i:number = 0;
        let len:number = list.length;
        for (i; i < len; i++) {
            list[i][dealFuncName]();
        }
    }
}