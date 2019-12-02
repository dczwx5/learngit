# <font color=#6616a1> JS </font>
## <font color=#CD4F39> 《数组》 </font>
```js
判断变量是否为数组
var arr = [];
arr instanceof Array; // true;
typeof arr; // object
```

## <font color=#CD4F39> 《隐藏类》 </font>
```js
每个JS对象都有一个隐藏类与之关联。
隐藏类存储有对象结构信息(属性数和对对象原型的引用)，以及从属性名称到属性的索引映射。
隐藏类是动态创建的，并随着对象的变化而动态更新。
```
## <font color=#CD4F39> 《回收机制》 </font>
在Javascript中，如果一个对象不再被引用，那么这个对象就会被GC回收。如果两个对象互相引用，而不再被第3者所引用，那么这两个互相引用的对象也会被回收
## <font color=#CD4F39> 《基本》 </font>
```js
在网页中，全局变量属于 window 对象。
全局变量能够被页面中（以及窗口中）的所有脚本使用和修改。
未定义直接赋值的变量，为全局变量
```
## <font color=#CD4F39> 《不确定》 </font>
```js
不通过关键词 v ar 创建的变量总是全局的，即使它们在函数中创建。
```

## <font color=#CD4F39> 《严格模式》 </font>
```js
在 JavaScript 严格模式下，如果 apply() 方法的第一个参数不是对象，则它将成为被调用函数的所有者（对象）。在“非严格”模式下，它成为全局对象。

```
## <font color=#CD4F39> 《this》 </font>
```js
在 JavaScript 中，被称为 this 的事物，指的是“拥有”当前代码的对象。
this 的值，在函数中使用时，是“拥有”该函数的对象。
如果函数没有拥有对象，this为全局对象

在函数嵌套中，拥有对象不会传递
var obj = {
	getName:function() {
		this.name; // 这里的this是obj
		return function() {
			return this.name; // 这里的this是 window
		}
	}
}
```

## <font color=#CD4F39> 《function》 </font>
### <font color=#BF3EFF> 基本 </font>
```js
函数是对象
var func = function() {};
typeof func; // func = 'function'

arguments
function myFunc(a,b) {
	return arguments.length; // 即 arguments[0] == a;
}
```
### <font color=#BF3EFF>定义 </font>
```js
声明
function functionName(parameters) {
   要执行的代码
}

表达式
var x = function (a, b) {return a * b};

Function构造器
var myFunction = new Function("a", "b", "return a * b");

函数声明可以被提升，表达式不可以
```
### <font color=#BF3EFF> 动态函数 </font>
```js
// 可以从配置文件，或远程文件，读入function的内容,达到动态修改函数内容
var func = new Function('a', 'b', 'return a+b;');
var value = func(100, 123);
console.log(value);
```
### <font color=#BF3EFF> 自调用函数 </font>
```js
函数声明无法进行自调用
(function(){
	console.log('自调用函数');
})();
```
### <font color=#BF3EFF> call/apply </font>
```js
function func(a,b) { 
}

func.call(this, 1,2);
func.apply(this, [1,2]);
```
### <font color=#BF3EFF> 闭包</font>
* 函数嵌套，子函数可访问父函数的作用域。
* 闭包指的是有权访问父作用域的函数，即使在父函数关闭之后。
* 闭包是将函数内部和函数外部连接起来的桥梁
* 没有将闭包返回使用，那不叫闭包
* 闭包的作用是将父函数的作用域，变量，保存下来，不被gc
* 函数的作用域及其所有变量都会在函数执行结束后被销毁。但是，在创建了一个闭包以后，这个函数的作用域就会一直保存到闭包不存在为止


```js
闭包的关键词
父函数
子函数
局部变量
作用域
对象
```
```js
内部函数
function add(a, b) {
	let c = 0;
	let func = () => {
		c = a+b;
	}
	return c;
}
```
```js
闭包
function counter() {
	let a = 0;
	return ()=>{
		return a++;
	}
}
let f = counter(); // 执行函数counter，产生闭包
f(); // 由于 返回的闭包引用存在，counter不会被gc
f(); // a = 2 // counter中的局部变量持续存在
f = null; // 闭包释放
```
```js
function arrFunc() {
	var arr = [];
	for (var i = 0; i < 10; i++) {
		arr[i] = fucntion() {
			return i;
		};
	}
	return arr;
}
返回 一个闭包数组，所有闭包的i都是10;因为他们存在于同一个作用域，引用的都是同一个变量i
```
```js
匿名函数的this是 window， 它没有拥有对象
var obj = {
	getName:function() {
		this.name; // 这里的this是obj
		return function() {
			return this.name; // 这里的this是 window
		}
	}
}
```
```js
匿名函数的this是 window， 它没有拥有对象
var obj = {
	getName:function() {
		return this.name; // 这里的this是obj
}
(obj.getName = obj.getName)(); // 这些执行函数时,this是 window
// (obj.getName = obj.getName) 赋值语句返回的是右值，相当于 f();。此时没有调用对象，因此，this是window
```

## <font color=#CD4F39> 《类》 </font>
### <font color=#BF3EFF> 继承 </font>
https://www.cnblogs.com/Grace-zyy/p/8206002.html

### <font color=#BF3EFF> 原型 </font>
* __proto__ 对象隐性原型 是一个对象
* prototype 函数显性原型 是一个对象

```js
prototype定义的属性和方法是公共的(静态)
prototype的所有属性和方法， 都会被构造函数的实例继承
我们可以把不变的属性和方法，定义在prototype对象属性上
```
```js
原型链
a = new A();
a.kk
当a没有kk这个对象时, 去a.__proto__找,(也就是A.prototype), 
如果 a.__proto__也没有时, 去a.__proto__.__proto__找 (任务对象都是继承于Object)
```
```js
var a = new A();
a.__proto__ == A.prototype
A == A.prototype.constructor
```
```js
当试图得到一个对象的某个属性时，如果这个对象本身没有这个属性，
那么会去它的_proto_(即它的构造函数的 prototype（显式原型）)中寻找

if (f.hasOwnProperty(item)) 中遍历 f 时，判断遍历中的 item,
是否可以通过 hasOwnProperty 验证，
通过则表明它是 f 自身的属性，
未通过则表明 是 f 通过原型获得的属性

f.hasOwnProperty 只有f自身属性才为true!!!
```
```js
所有的引用类型都具有对象特性，即可自由扩展属性(除'null')
var obj = {}; obj.a = 100;
var arr = []; arr.a = 100;
function fn() { } fn.a = 100;

所有的引用类型（数组、对象、函数）都有一个 _proto_ 属性(隐式原型属性），属性值是一个普通的对象
obj.__proto__
arr.__proto__
fn.__proto__

所有的函数，都有一个prototype(显式原型)属性，属性值也是一个普通对象
fn.prototype

所有的引用类型， __proto__属性指向它的构造函数的prototype
obj.__proto__ === Object.prototype
```
```js
function Animal {
	this.eat = function () {
		...
	}
}

function Dog() {
	this.bark = function() {
		...
	}
}
Dog.propotype = new Animal();
```
### <font color=#BF3EFF> prototype __proto__ ClassName </font>
```js
function Person(name, age, job) {
  this.name = name;
  this.job = job;
  this.age = age;
  this.sayName = function() {
    console.log(this.name);
  }
}

let p1 = new Person('aa', 12, 'stu');
let p2 = new Person('bb', 12, 'stu');
// p1.__proto__ === p2.__proto === Person.prototype 
// Person == Person.prototype.constructor;
console.log('p1.__proto__', p1.__proto__);
console.log('Person.prototype', Person.prototype);
console.log('Person.prototype.constructor', Person.prototype.constructor);
console.log('Person', Person);

console.log(Person.prototype === p1.__proto__); // true 
console.log(Person === Person.prototype.constructor); // true
```
### <font color=#BF3EFF> property </font>
```js
var person = {
  firstName: "Bill",
  lastName : "Gates",
  language : "NO", 
};
```


```js
// 添加或更改对象属性
Object.defineProperty(object, property, descriptor)

// 更改属性：
Object.defineProperty(person, "language", {
  value: "EN", // 值
  writable : true, // 是否可写
  enumerable : false, // 是否可枚举
  configurable : true // 是否可配置？
});

// 更改属性：添加 get/set
Object.defineProperty(person, "language", {
	get : function() { return language },
	set : function(value) { language = value.toUpperCase()}
});
```

```js
// 添加或更改多个对象属性
Object.defineProperties(object, descriptors)
```
```js
// 将所有属性作为数组返回
Object.getOwnPropertyNames(object)

var propertyNames = Object.getOwnPropertyNames(obj);
/**
propertyNames : [value, writable, enumerable, configurable]
*/
```
```js
// 访问属性
Object.getOwnPropertyDescriptor(object, property)

var propertyObj = Object.getOwnPropertyDescriptor(obj, 'name');
/**
propertyObj
{
  value: "EN", // 值
  writable : true, // 是否可写
  enumerable : false, // 是否可枚举
  configurable : true // 是否可配置？
}*/
```
```js
// 将可枚举属性作为数组返回
Object.keys(object)

// 获得可枚举的列表
var propertys = Object.keys(obj);
console.log(propertys.toString());
/**
propertys : [value, writable, enumerable, configurable]
*/
```
```js
// 方问原型
var prototype = Object.getPrototypeOf(obj);
console.log(prototype);

/**
{constructor: ƒ, __defineGetter__: ƒ, __defineSetter__: ƒ, hasOwnProperty: ƒ, __lookupGetter__: ƒ, …}
constructor: ƒ Object()
hasOwnProperty: ƒ hasOwnProperty()
isPrototypeOf: ƒ isPrototypeOf()
propertyIsEnumerable: ƒ propertyIsEnumerable()
toLocaleString: ƒ toLocaleString()
toString: ƒ toString()
valueOf: ƒ valueOf()
__defineGetter__: ƒ __defineGetter__()
__defineSetter__: ƒ __defineSetter__()
__lookupGetter__: ƒ __lookupGetter__()
__lookupSetter__: ƒ __lookupSetter__()
get __proto__: ƒ __proto__()
set __proto__: ƒ __proto__()
*/
```
```js
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
```





#end