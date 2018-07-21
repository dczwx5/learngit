

.数据类型 : 
	.没有int 只有 Number
	.'use strict';
		使用use strict 。强制变量一定要先定义. 
		如果变量没定义则是全局变量
	.始终坚持使用===比较
	.undefined 未定义
	.null 空
	.Infinity; // Infinity表示无限大，当数值超过了
	.NaN : 
		NaN与任意值都不等 
		isNaN(NaN); // true 
		NaN === NaN; // false
	.Number : 判断大小只能用 a - b > 0.0000001;
	.Object & Map & Set :
		. Object's key : 字符串 : "3" 和 3是同一个key
		. Map's key : "3" 和 3不是同一个key
		. Set's key : "3" 和 3不是同一个key
.字符串 :
	.'' or ""
	.toUpperCase : toLowerCase
	.indexOf : 搜索指定字符串出现的位置
		var s = 'hello, world';
		s.indexOf('world'); // 返回7
		s.indexOf('World'); // 没有找到指定的子串，返回-1
	.substring : 返回指定索引区间的子串
		var s = 'hello, world'
		s.substring(0, 5); // 从索引0开始到5（不包括5），返回'hello'
		s.substring(7); // 从索引7开始到结束，返回'world'
.数组
	// list = [1,2,3,4];
	.indexOf
		list.indexOf(2); // 1
	.slice : 
		var startIndex = 1;
		var endInstance = 3;
		list.slice(1,3); // [2,3,4]
		list.slice(); // [1,2,3,4]
	.push : 添加到尾部
	.pop : 从尾部删掉
	.unshift : 添加到头部
	.shift : 从头部删除
	.sort
	.reverse : 反转数组 : 改变本数组
	.splice
		var startIndex = 1;
		var deleteCount = 1;
		var add1 = "aa";
		var add2 = "bb";
		var ret = null;
		ret = list.splice(startIndex, deleteCount, add1, add2);
		// ret = [2];
		// list : [1, "aa", "bb", 3, 4]

	.concat : 连接数组
		arr = ['A', 'B', 'C'];
		var added = arr.concat([1, 2, 3]);

	.join ：
		var arr = ['A', 'B', 'C', 1, 2, 3];
		arr.join('-'); // 'A-B-C-1-2-3'
	// map : 同于一个参数, 所有数组元素转过一个运算, 得到另一个数组
		var foo = function (x) {return x*x};
		var arr = [1,2,3,4,5];
		// 使用map
		var result = arr.map(foo); // step 3
		// 同于
		for (var i:int = 0; i < arr.length; i++) {
			var value = foo(arr[i]);
			result.push(value);
		}
	// reduce : 函数参数必须是2个, 从数组前2个元素开始, 使用函数运算, 得出结果, 再用结果和下一个元素运算, 一直到最后
		// 以下实现了函数累加
		var arr = [1,2,3,4];
		var foo = (x1, x2) => x1+x2;
		// 使用reduce
		var ret = arr.reduce(foo); // 1+2+3+4;
		// 同于
		var ret = foo(arr[0], arr[1]);
		ret = foo(ret, arr[2]);
		ret = foo(ret, arr[3]);
	// filter : 一个参数, 过滤掉为false元素, 生成新数组
		var arr[1,2,3,4];
		var foo = (x) => x < 3;
		var ret = arr.filter(foo); // ret = [1,2]
		// 也可以是3个参数 (function (element, index, self) 
	// sort : 默认按字符串比较
		var arr = [1, 10, 2, 20];
		arr.sort(); // [1, 10, 2, 20];
		var fooSort = (v1, v2) => v1 - v2;
		arr.sort(fooSort); // 1, 2, 10, 20
.对象
		// 同as 的object , 键值为string
		delete obj.xx; // 删 除字段
		访问不存在的属性不会报错, 返回 undefined
		in :
			var obj = {age:1};
			"age" in obj; // true
			"toString" in obj; // true
		hasOwnProperty : 
			var obj = {age:1};
			obj.hasOwnProperty("age"); // true
			obj.hasOwnProperty("toString"); // false;
Map :
	// 和Dictionary一样
	// 初始化方式不一样, 使用一个二维数组初始化
	// key 2 和 key "2" 是不相同的
		var m = new Map([['Michael', 95], ['Bob', 75], ['Tracy', 85]]);
		m.get('Michael'); // 95
		m.set('Adam', 67);
		m.delete('Adam'); 
Set :
	// 只有key, 没有value
	var s1 = new Set(); // 空Set
	var s2 = new Set([1, 2, 3]); // 含1, 2, 3
	var s = new Set([1, 2, 3, 3, '3']); // Set {1, 2, 3, "3"} 3和字符串'3'是不同的元素。重复添加，但不会有效果：
	s.delete(3);
	s; // Set {1, 2, "3"}

iterable :
	// list = [10,20]; list.kk = "bb";
	.for of : 遍历集合值
		for (var value of list) {
			// 10, 20
		}
	.for in : 遍历所有key // 类 for (var key in ..);
		for (var key in list) {
			// 0,1,kk
		}
	.forEach : 统一 遍历集合值
		a.forEach(function (element, index, array) {
			// 10,20
		});

函数 : 
	// 函数允许接收任意个参数
	// 定义, 和as3的区别在于不用写返回值类型
		function (param1) { return 1; }
		var func = function (param1) { return 1; } // 匿名函数
	// 传入多或少的参数给函数都是可行的
		func(1, 2, 3);
		func();
		// 但是对函数内部会有影响, 因为函数体内要做处理
		function pow2(param1) {
			// 如果期望param1必须传值
			if (param1 === undefined) {
				throw 'param1 error';
			}
			return param1 * param1;
		}
	// arguments, 所有参数都存于arguments中. 如as中的不定长参数 ...
		function varParamFunc() {
			arguments[0]; // 21
			return arguments.length;
		}
		varParamFunc(21,2,3); // 3
		
	// rest. 只是为了声明。这里可以传入不定参数
		function foo(a, b, ...rest) {
			console.log('a = ' + a);
			console.log('b = ' + b);
			console.log(rest);
		}
		foo(1,2,3,4,5); // rest = [3,4,5]
	// 匿名函数
		function () {}
	// => 函数
		() => 1; // 最简单的无参函数 同 function () { return 1; }
		x => x+1; // 1个参数 同 function (x) { return x+1; }
		(x, y) => x + y; // 2个参数 同function (x, y) { return x + y; }
		// 非单语句 
		(x, y) => {
			if (x > y) return x;
			else return y;
		}
		// 如果返回值是obj // 同 function () { return {name:"kk"};}
		() => {{name : "kk"}};  // ()=> {name:"kk"} 这是错的
		// this 和 其他的this不一样, this指向所在的object
	// generator
		var foo = function* (x) {
			while(x > 0) {
				if (x == 1) 
					return 1;
				else 
					yield x;
				x--;
			}
		} 
		// 定义function *
		var f = foo(1); // 此时函数体未执行, 只是生成了generator对象
		f.next(); // 执行函数 返回 {value:1, done:true}
		f = foo(2);
		f.next(); // 返回{value:2, done:false}
		f.next(); // 返回{value:1, done:true};
		// 调用next时才执行函数体
		// 执行到yield的时候, 函数停止, 并返回
		// 再次调用next, 从上次yield停止的地方继续执行
		
		
.行末自动添加分号 : 
	// JavaScript引擎在行末自动添加分号的机制
	return 
		1;
	// 实际是
	return ;
		1 ;
	// 返回值不是1
	// 正确写法
	return {
		1;
	}

.作用域 : 
	.全局作用域 : // 函数外定义的变量, 函数都是全局变量, 函数, 存于window变量里
	.let : 
		// 和as 一样. 变量的作用域是函数内, 所以for里定义的变量, 也是在函数内都可以使用的
		// 为在类似for 里面定义局部变量, 使用let, 固定区域
		for (let i = 0; i < 100; i++) {
			// i 的作用域只在for里
		}
	.const :
		// 常量
		// 和 let 一样, 有区块作用域
	
.解构赋值 : 
		// 
		var array = ['a', 'b', 'c'];
		var x = array[0];
		var y = array[1];
		// ==>
		var [x, y] = ['a', 'b'];
	
.类 
	1.class : ES6开始才有
		// 类定义
		class Student {
			// 构造函数
			constructor(name) { 
				// this指向自己 , name 成员变量
				this.name = name;
			}
			// 成员函数
			hello() {
				//
			}
		}
		// 类继承
		class PrimaryStudent extends Student {
			// 构造函数
			constructor(name, grade) {
				super(name); // 调用父类构造函数
				this.grade = grade;
			}
			// 成员函数
			myGrade() {
				console.log(this.grade);
			}
		}
		// 创建对象
		var s1 = new Student("s1");
		s1.hello();
		var s2 = new PrimaryStudent("s2", 1);
		s2.hello();
		s2.myGrade();
		
		
	2.非class
	
	