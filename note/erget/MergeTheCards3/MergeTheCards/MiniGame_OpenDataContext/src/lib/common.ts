/**
 * 根据传入的对象实例或类，返回其类名字符串
 * @param classOrInstance
 * @returns {string}
 */
function getClassName(classOrInstance: any): string {
    return egret.getQualifiedClassName(classOrInstance);
}

/**
 * 获取指定的类对象
 * @param className
 * @returns {any}
 */
function getClass(className: string): any {
    return egret.getDefinitionByName(className);
}

/**
 * 根据传入的对象实例，返回对象的类
 * @param instance 传入的对象实例
 * @returns {any} 对象的类
 */
function getClassByInstance(instance: any): any {
    // return getClass(instance.__proto__.__class__);
    if (!instance) {
        return null;
    }
    if (instance.prototype) {
        // return getClass(instance.prototype.__class__);
        return instance;
    }
    // return getClass(instance.__proto__.__class__);
    return instance.__proto__.constructor;
}
/**
 * 判断某类是否是另一个类/接口的子类或实现类
 * @param childClass 子类
 * @param superClassName 父类类名/接口名
 * @returns {boolean}
 */
function isExtends(childClass:any, superClassName:string):boolean{
    let childClassNmae = getClassName(childClass);
    return superClassName != childClassNmae && childClass.prototype.__types__.indexOf(superClassName) >= 0
}

/**
 * 把一个对象的所有字段导出成一个Object键值对，
 * @param instance 导出数据的对象
 * @returns {{}}
 */
function toObject(instance: any): any {
    let obj = {};
    for (let key in instance) {
        obj[key] = instance[key];
    }
    return obj;
}

/**
 * 从一个Object键值对把对应的字段设置到一个对象
 * @param vo 被赋值的对象
 * @param obj
 */
function fromObject(instance: any, obj: any) {
    for (let key in obj) {
        // if (obj.hasOwnProperty(key)) {
        //     instance[key] = obj[key];
        // }
        instance[key] = obj[key];
    }
    return;
}
