namespace VL {
    export namespace ObjectCache {
        /**
         * 能被对象池缓存的对象接口
         */
        export interface ICacheable {
            init(...args: any[]): ICacheable;
            clear();
            restore(maxCacheCount?: number);
        }
    }
}