namespace VL.Reflector {
    /**
     * 反射器接口
     */
    export interface IReflector {
        /**
         * 获取类名字符串
         * @param classOrEntity 类或实例
         */
        getClassName(classOrEntity: any): string ;

        /**
         * 获取指定的类对象
         * @param className
         * @returns {any}
         */
        getClass<T extends new(...args) => T>(className: string): T;

        /**
         * 根据传入的对象实例，返回对象的类
         * @param entity 传入的对象实例
         * @returns new(...args) => T 对象的类
         */
        getClassByEntity<T>(entity: T):{new(...args) : T} | {new() : T}

        /**
         * 判断某类是否是另一个类/接口的子类或实现类
         * @param extClass 子类
         * @param baseClassName 父类类名/接口名
         * @returns {boolean}
         */
        isExtends(extClass: any, baseClassName: string): boolean;
    }
}
