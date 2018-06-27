数据类型 : 
	.JavaScript不区分整数和浮点数，统一用 Number 表示，以下都是合法的 Number 类型：
		123; // 整数123
		0.456; // 浮点数0.456
		1.2345e3; // 科学计数法表示1.2345x1000，等同于1234.5
		-99; // 负数
		NaN; // NaN表示Not a Number，当无法计算结果时用NaN表示
		Infinity; // Infinity表示无限大，当数值超过了
	.字符串是以单引号'或双引号"括起来的任意文本
	.由于JavaScript这个设计缺陷，不要使用==比较，始终坚持使用===比较。
	.NaN
		另一个例外是 NaN 这个特殊的 Number 与所有其他值都不相等，包括它自己：
			NaN === NaN; // false
			唯一能判断NaN的方法是通过isNaN()函数：
			isNaN(NaN); // true
	.Number 
		这不是JavaScript的设计缺陷。浮点数在运算过程中会产生误差，因为计算机无法精确表示无限循环小数。要比较两个浮点数是否相等，只能计算它们之差的绝对值，看是否小于某个阈值：
		Math.abs(1 / 3 - (1 - 2 / 3)) < 0.0000001; // true
	.null 和 undefined
	.数组
		数组是一组按顺序排列的集合，集合的每个值称为元素。JavaScript的数组可以包括任意数据类型。例如：
		[1, 2, 3.14, 'Hello', null, true];
		new Array(1, 2, 3); // 创建了数组[1, 2, 3]
		然而，出于代码的可读性考虑，强烈建议直接使用[]。
		数组的元素可以通过索引来访问。请注意，索引的起始值为0：
			var arr = [1, 2, 3.14, 'Hello', null, true];
			arr[0]; // 返回索引为0的元素，即1
			arr[5]; // 返回索引为5的元素，即true
			arr[6]; // 索引超出了范围，返回undefined
		// length
			arr.length = 10; // 会改变数组长度. 
		请注意，如果通过索引赋值时，索引超过了范围，同样会引起Array大小的变化：
			var arr = [1, 2, 3];
			arr[5] = 'x';
			arr; // arr变为[1, 2, 3, undefined, undefined, 'x']


	
	.'use strict';
		使用use strict 。强制变量一定要先定义. 
		如果变量没定义则是全局变量
	.字符串
		toUpperCase
			toUpperCase()把一个字符串全部变为大写：
			var s = 'Hello';
			s.toUpperCase(); // 返回'HELLO'
		toLowerCase
			toLowerCase()把一个字符串全部变为小写：
			var s = 'Hello';
			var lower = s.toLowerCase(); // 返回'hello'并赋值给变量lower
			lower; // 'hello'
		indexOf
			indexOf()会搜索指定字符串出现的位置：
			var s = 'hello, world';
			s.indexOf('world'); // 返回7
			s.indexOf('World'); // 没有找到指定的子串，返回-1

		substring
			substring()返回指定索引区间的子串：
			var s = 'hello, world'
			s.substring(0, 5); // 从索引0开始到5（不包括5），返回'hello'
			s.substring(7); // 从索引7开始到结束，返回'world'

.数组
	.indexOf
		与String类似，Array也可以通过indexOf()来搜索一个指定的元素的位置：
			var arr = [10, 20, '30', 'xyz'];
			arr.indexOf(10); // 元素10的索引为0
			arr.indexOf(20); // 元素20的索引为1
			arr.indexOf(30); // 元素30没有找到，返回-1
			arr.indexOf('30'); // 元素'30'的索引为2
		注意了，数字30和字符串'30'是不同的元素。


	.slice
		slice()就是对应String的substring()版本，它截取Array的部分元素，然后返回一个新的Array：
			var arr = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
			arr.slice(0, 3); // 从索引0开始，到索引3结束，但不包括索引3: ['A', 'B', 'C']
			arr.slice(3); // 从索引3开始到结束: ['D', 'E', 'F', 'G']
		注意到slice()的起止参数包括开始索引，不包括结束索引。
		如果不给slice()传递任何参数，它就会从头到尾截取所有元素。利用这一点，我们可以很容易地复制一个Array：
			var arr = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
			var aCopy = arr.slice();
			aCopy; // ['A', 'B', 'C', 'D', 'E', 'F', 'G']
			aCopy === arr; // false


	.push和pop
		push()向Array的末尾添加若干元素，pop()则把Array的最后一个元素删除掉：
			var arr = [1, 2];
			arr.push('A', 'B'); // 返回Array新的长度: 4
			arr; // [1, 2, 'A', 'B']
			arr.pop(); // pop()返回'B'
			arr; // [1, 2, 'A']
			arr.pop(); arr.pop(); arr.pop(); // 连续pop 3次
			arr; // []
			arr.pop(); // 空数组继续pop不会报错，而是返回undefined
			arr; // []


	.unshift和shift
		如果要往Array的头部添加若干元素，使用unshift()方法，shift()方法则把Array的第一个元素删掉：
			var arr = [1, 2];
			arr.unshift('A', 'B'); // 返回Array新的长度: 4
			arr; // ['A', 'B', 1, 2]
			arr.shift(); // 'A'
			arr; // ['B', 1, 2]
			arr.shift(); arr.shift(); arr.shift(); // 连续shift 3次
			arr; // []
			arr.shift(); // 空数组继续shift不会报错，而是返回undefined
			arr; // []

	.sort
		sort()可以对当前Array进行排序，它会直接修改当前Array的元素位置，直接调用时，按照默认顺序排序：

			var arr = ['B', 'C', 'A'];
			arr.sort();
			arr; // ['A', 'B', 'C']
		能否按照我们自己指定的顺序排序呢？完全可以，我们将在后面的函数中讲到。

	.reverse
		reverse()把整个Array的元素给掉个个，也就是反转：
			var arr = ['one', 'two', 'three'];
			arr.reverse(); 
			arr; // ['three', 'two', 'one']
	.splice
		splice()方法是修改Array的“万能方法”，它可以从指定的索引开始删除若干元素，然后再从该位置添加若干元素：
			var arr = ['Microsoft', 'Apple', 'Yahoo', 'AOL', 'Excite', 'Oracle'];
			// 从索引2开始删除3个元素,然后再添加两个元素:
			arr.splice(2, 3, 'Google', 'Facebook'); // 返回删除的元素 ['Yahoo', 'AOL', 'Excite']
			arr; // ['Microsoft', 'Apple', 'Google', 'Facebook', 'Oracle']
			// 只删除,不添加:
			arr.splice(2, 2); // ['Google', 'Facebook']
			arr; // ['Microsoft', 'Apple', 'Oracle']
			// 只添加,不删除:
			arr.splice(2, 0, 'Google', 'Facebook'); // 返回[],因为没有删除任何元素
			arr; // ['Microsoft', 'Apple', 'Google', 'Facebook', 'Oracle']

	.concat
		concat()方法把当前的Array和另一个Array连接起来，并返回一个新的Array：
			var arr = ['A', 'B', 'C'];
			var added = arr.concat([1, 2, 3]);
			added; // ['A', 'B', 'C', 1, 2, 3]
			arr; // ['A', 'B', 'C']
		请注意，concat()方法并没有修改当前Array，而是返回了一个新的Array。
		实际上，concat()方法可以接收任意个元素和Array，并且自动把Array拆开，然后全部添加到新的Array里：
			var arr = ['A', 'B', 'C'];
			arr.concat(1, 2, [3, 4]); // ['A', 'B', 'C', 1, 2, 3, 4]

	.join
		join()方法是一个非常实用的方法，它把当前Array的每个元素都用指定的字符串连接起来，然后返回连接后的字符串：
			var arr = ['A', 'B', 'C', 1, 2, 3];
			arr.join('-'); // 'A-B-C-1-2-3'
		如果Array的元素不是字符串，将自动转换为字符串后再连接。
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
	// 遍历Array可以采用下标循环，遍历Map和Set就无法使用下标。为了统一集合类型，ES6标准引入了新的iterable类型，Array、Map和Set都属于iterable类型。
	// 具有iterable类型的集合可以通过新的for ... of循环来遍历。
	// for ... of循环是ES6引入的新的语法，请测试你的浏览器是否支持：
	'use strict';
	var a = [1, 2, 3];
	for (var x of a) {
	}
	console.log('你的浏览器支持for ... of');

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
		
行末自动添加分号 : 
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
	
全局作用域 : 
	// 函数外定义的变量, 函数都是全局变量, 函数, 存于window变量里
	var abc = 13;
	alert(abc); // 等价
	alert(window.abc); // 等价
	// 函数也一样
	function foo() {
		alert('foo');
	}

	foo(); // 直接调用foo()
	window.foo(); // 通过window.foo()调用
let : 
	// 和as 一样. 变量的作用域是函数内, 所以for里定义的变量, 也是在函数内都可以使用的
	// 为在类似for 里面定义局部变量, 使用let, 固定区域
	for (let i = 0; i < 100; i++) {
		// i 的作用域只在for里
	}
const :
	// 常量
	// 和 let 一样, 有区块作用域
	
解构赋值 : 
		// 
		var array = ['a', 'b', 'c'];
		var x = array[0];
		var y = array[1];
		// ==>
		var [x, y] = ['a', 'b'];
	
	
	
	
	