// 创建对象：
console.log('============js_change_property==============');

var person = {
  firstName: "Bill",
  lastName : "Gates",
  language : "NO", 
};

// 更改属性：
Object.defineProperty(person, "language", {
  value: "EN",
  writable : true,
  enumerable : false, // 是否可枚举
  configurable : true
});

/*
// ES5 新的对象方法
// 添加或更改对象属性
Object.defineProperty(object, property, descriptor)

// 添加或更改多个对象属性
Object.defineProperties(object, descriptors)

// 访问属性
Object.getOwnPropertyDescriptor(object, property)

// 将所有属性作为数组返回
Object.getOwnPropertyNames(object)

// 将可枚举属性作为数组返回
Object.keys(object)

// 访问原型
Object.getPrototypeOf(object)

// 防止向对象添加属性
Object.preventExtensions(object)

// 如果可以将属性添加到对象，则返回 true
Object.isExtensible(object)

// 防止更改对象属性（而不是值）
Object.seal(object)

// 如果对象被密封，则返回 true
Object.isSealed(object)

// 防止对对象进行任何更改
Object.freeze(object)

// 如果对象被冻结，则返回 true
Object.isFrozen(object)

*/
var obj = {
	name:"abc",
	age:13
};

// 获得属性列表
var propertys = Object.getOwnPropertyNames(obj);
console.log(propertys.toString());


// 定义属性， 可改值，改属性的配置
Object.defineProperty(obj, 'name', {
  value: "EN",
  writable : true,
  enumerable : false, // 是否可枚举
  configurable : true
});
// 获得可枚举的列表
var propertys = Object.keys(obj);
console.log(propertys.toString());

// 获得属性的数据， 一个object
var propertys = Object.getOwnPropertyDescriptor(obj, 'name');
var subPropertys = Object.getOwnPropertyNames(propertys);
console.log(subPropertys.toString()); // value,writable,enumerable,configurable

// 方问原型
var prototype = Object.getPrototypeOf(obj);
console.log(prototype);


