/**
 * 根据传入的对象实例或类，返回其类名字符串
 * @param classOrInstance
 * @returns {string}
 */
function getClassName(classOrInstance) {
    return egret.getQualifiedClassName(classOrInstance);
}
/**
 * 获取指定的类对象
 * @param className
 * @returns {any}
 */
function getClass(className) {
    return egret.getDefinitionByName(className);
}
/**
 * 根据传入的对象实例，返回对象的类
 * @param instance 传入的对象实例
 * @returns {any} 对象的类
 */
function getClassByInstance(instance) {
    return getClass(instance.__proto__.__class__);
}
/**
 * 判断某类是否是另一个类/接口的子类或实现类
 * @param childClass 子类
 * @param superClassName 父类类名/接口名
 * @returns {boolean}
 */
function isExtends(childClass, superClassName) {
    var childClassNmae = getClassName(childClass);
    return superClassName != childClassNmae && childClass.prototype.__types__.indexOf(superClassName) >= 0;
}
/**
 * 把一个对象的所有字段导出成一个Object键值对，
 * @param instance 导出数据的对象
 * @returns {{}}
 */
function toObject(instance) {
    var obj = {};
    for (var key in instance) {
        obj[key] = instance[key];
    }
    return obj;
}
/**
 * 从一个Object键值对把对应的字段设置到一个对象
 * @param vo 被赋值的对象
 * @param obj
 */
function fromObject(instance, obj) {
    for (var key in obj) {
        // if (obj.hasOwnProperty(key)) {
        //     instance[key] = obj[key];
        // }
        instance[key] = obj[key];
    }
    return;
}
/**
 * 复制到剪贴板
 * @param text
 */
function copyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.style.width = "0";
    textArea.style.height = "0";
    textArea.style.opacity = "0";
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    var result = false;
    try {
        result = document.execCommand('copy');
    }
    catch (err) {
        console.log('不能使用这种方法复制内容');
    }
    finally {
        document.body.removeChild(textArea);
        return result;
    }
}
//# sourceMappingURL=common.js.map