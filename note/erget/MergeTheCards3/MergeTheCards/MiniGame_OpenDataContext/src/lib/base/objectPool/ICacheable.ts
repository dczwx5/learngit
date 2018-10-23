/**
 * 能被对象池缓存的对象接口
 */
interface ICacheable{
    init(...args:any[]):ICacheable;
    restore(cachePool:ObjectPool);
}