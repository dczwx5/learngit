/**
 * 有对象池机制的类，通过调静态方法create创建或取出一个该类对象，restore放回对象池
 */
abstract class CacheableClass implements ICacheable{

    protected static _cachePool:ObjectPool = new ObjectPool();

    /**
     * 从对象池取出或创建出来的时候要做的事
     * @param args
     */
    public abstract init(...args:any[]):CacheableClass;

    /**
     * 从对象池取出
     * @param args
     * @returns {T}
     */
    public static create<T extends CacheableClass>(clazz:new()=>T):T{
        return this._cachePool.pop<T>(clazz);
    }

    protected abstract clear();

    /**
     * 放回对象池
     */
    public restore(){
        this.clear();
        let clzz = getClassByInstance(this);
        if(!clzz){
            egret.warn('這個類要放到window~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            egret.warn(this['__proto__']['__class__']);
        }
        clzz._cachePool.push(this);
    }
}
window['CacheableClass']=CacheableClass;