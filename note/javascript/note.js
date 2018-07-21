

.�������� : 
	.û��int ֻ�� Number
	.'use strict';
		ʹ��use strict ��ǿ�Ʊ���һ��Ҫ�ȶ���. 
		�������û��������ȫ�ֱ���
	.ʼ�ռ��ʹ��===�Ƚ�
	.undefined δ����
	.null ��
	.Infinity; // Infinity��ʾ���޴󣬵���ֵ������
	.NaN : 
		NaN������ֵ������ 
		isNaN(NaN); // true 
		NaN === NaN; // false
	.Number : �жϴ�Сֻ���� a - b > 0.0000001;
	.Object & Map & Set :
		. Object's key : �ַ��� : "3" �� 3��ͬһ��key
		. Map's key : "3" �� 3����ͬһ��key
		. Set's key : "3" �� 3����ͬһ��key
.�ַ��� :
	.'' or ""
	.toUpperCase : toLowerCase
	.indexOf : ����ָ���ַ������ֵ�λ��
		var s = 'hello, world';
		s.indexOf('world'); // ����7
		s.indexOf('World'); // û���ҵ�ָ�����Ӵ�������-1
	.substring : ����ָ������������Ӵ�
		var s = 'hello, world'
		s.substring(0, 5); // ������0��ʼ��5��������5��������'hello'
		s.substring(7); // ������7��ʼ������������'world'
.����
	// list = [1,2,3,4];
	.indexOf
		list.indexOf(2); // 1
	.slice : 
		var startIndex = 1;
		var endInstance = 3;
		list.slice(1,3); // [2,3,4]
		list.slice(); // [1,2,3,4]
	.push : ��ӵ�β��
	.pop : ��β��ɾ��
	.unshift : ��ӵ�ͷ��
	.shift : ��ͷ��ɾ��
	.sort
	.reverse : ��ת���� : �ı䱾����
	.splice
		var startIndex = 1;
		var deleteCount = 1;
		var add1 = "aa";
		var add2 = "bb";
		var ret = null;
		ret = list.splice(startIndex, deleteCount, add1, add2);
		// ret = [2];
		// list : [1, "aa", "bb", 3, 4]

	.concat : ��������
		arr = ['A', 'B', 'C'];
		var added = arr.concat([1, 2, 3]);

	.join ��
		var arr = ['A', 'B', 'C', 1, 2, 3];
		arr.join('-'); // 'A-B-C-1-2-3'
	// map : ͬ��һ������, ��������Ԫ��ת��һ������, �õ���һ������
		var foo = function (x) {return x*x};
		var arr = [1,2,3,4,5];
		// ʹ��map
		var result = arr.map(foo); // step 3
		// ͬ��
		for (var i:int = 0; i < arr.length; i++) {
			var value = foo(arr[i]);
			result.push(value);
		}
	// reduce : ��������������2��, ������ǰ2��Ԫ�ؿ�ʼ, ʹ�ú�������, �ó����, ���ý������һ��Ԫ������, һֱ�����
		// ����ʵ���˺����ۼ�
		var arr = [1,2,3,4];
		var foo = (x1, x2) => x1+x2;
		// ʹ��reduce
		var ret = arr.reduce(foo); // 1+2+3+4;
		// ͬ��
		var ret = foo(arr[0], arr[1]);
		ret = foo(ret, arr[2]);
		ret = foo(ret, arr[3]);
	// filter : һ������, ���˵�ΪfalseԪ��, ����������
		var arr[1,2,3,4];
		var foo = (x) => x < 3;
		var ret = arr.filter(foo); // ret = [1,2]
		// Ҳ������3������ (function (element, index, self) 
	// sort : Ĭ�ϰ��ַ����Ƚ�
		var arr = [1, 10, 2, 20];
		arr.sort(); // [1, 10, 2, 20];
		var fooSort = (v1, v2) => v1 - v2;
		arr.sort(fooSort); // 1, 2, 10, 20
.����
		// ͬas ��object , ��ֵΪstring
		delete obj.xx; // ɾ ���ֶ�
		���ʲ����ڵ����Բ��ᱨ��, ���� undefined
		in :
			var obj = {age:1};
			"age" in obj; // true
			"toString" in obj; // true
		hasOwnProperty : 
			var obj = {age:1};
			obj.hasOwnProperty("age"); // true
			obj.hasOwnProperty("toString"); // false;
Map :
	// ��Dictionaryһ��
	// ��ʼ����ʽ��һ��, ʹ��һ����ά�����ʼ��
	// key 2 �� key "2" �ǲ���ͬ��
		var m = new Map([['Michael', 95], ['Bob', 75], ['Tracy', 85]]);
		m.get('Michael'); // 95
		m.set('Adam', 67);
		m.delete('Adam'); 
Set :
	// ֻ��key, û��value
	var s1 = new Set(); // ��Set
	var s2 = new Set([1, 2, 3]); // ��1, 2, 3
	var s = new Set([1, 2, 3, 3, '3']); // Set {1, 2, 3, "3"} 3���ַ���'3'�ǲ�ͬ��Ԫ�ء��ظ���ӣ���������Ч����
	s.delete(3);
	s; // Set {1, 2, "3"}

iterable :
	// list = [10,20]; list.kk = "bb";
	.for of : ��������ֵ
		for (var value of list) {
			// 10, 20
		}
	.for in : ��������key // �� for (var key in ..);
		for (var key in list) {
			// 0,1,kk
		}
	.forEach : ͳһ ��������ֵ
		a.forEach(function (element, index, array) {
			// 10,20
		});

���� : 
	// ��������������������
	// ����, ��as3���������ڲ���д����ֵ����
		function (param1) { return 1; }
		var func = function (param1) { return 1; } // ��������
	// �������ٵĲ������������ǿ��е�
		func(1, 2, 3);
		func();
		// ���ǶԺ����ڲ�����Ӱ��, ��Ϊ��������Ҫ������
		function pow2(param1) {
			// �������param1���봫ֵ
			if (param1 === undefined) {
				throw 'param1 error';
			}
			return param1 * param1;
		}
	// arguments, ���в���������arguments��. ��as�еĲ��������� ...
		function varParamFunc() {
			arguments[0]; // 21
			return arguments.length;
		}
		varParamFunc(21,2,3); // 3
		
	// rest. ֻ��Ϊ��������������Դ��벻������
		function foo(a, b, ...rest) {
			console.log('a = ' + a);
			console.log('b = ' + b);
			console.log(rest);
		}
		foo(1,2,3,4,5); // rest = [3,4,5]
	// ��������
		function () {}
	// => ����
		() => 1; // ��򵥵��޲κ��� ͬ function () { return 1; }
		x => x+1; // 1������ ͬ function (x) { return x+1; }
		(x, y) => x + y; // 2������ ͬfunction (x, y) { return x + y; }
		// �ǵ���� 
		(x, y) => {
			if (x > y) return x;
			else return y;
		}
		// �������ֵ��obj // ͬ function () { return {name:"kk"};}
		() => {{name : "kk"}};  // ()=> {name:"kk"} ���Ǵ��
		// this �� ������this��һ��, thisָ�����ڵ�object
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
		// ����function *
		var f = foo(1); // ��ʱ������δִ��, ֻ��������generator����
		f.next(); // ִ�к��� ���� {value:1, done:true}
		f = foo(2);
		f.next(); // ����{value:2, done:false}
		f.next(); // ����{value:1, done:true};
		// ����nextʱ��ִ�к�����
		// ִ�е�yield��ʱ��, ����ֹͣ, ������
		// �ٴε���next, ���ϴ�yieldֹͣ�ĵط�����ִ��
		
		
.��ĩ�Զ���ӷֺ� : 
	// JavaScript��������ĩ�Զ���ӷֺŵĻ���
	return 
		1;
	// ʵ����
	return ;
		1 ;
	// ����ֵ����1
	// ��ȷд��
	return {
		1;
	}

.������ : 
	.ȫ�������� : // �����ⶨ��ı���, ��������ȫ�ֱ���, ����, ����window������
	.let : 
		// ��as һ��. �������������Ǻ�����, ����for�ﶨ��ı���, Ҳ���ں����ڶ�����ʹ�õ�
		// Ϊ������for ���涨��ֲ�����, ʹ��let, �̶�����
		for (let i = 0; i < 100; i++) {
			// i ��������ֻ��for��
		}
	.const :
		// ����
		// �� let һ��, ������������
	
.�⹹��ֵ : 
		// 
		var array = ['a', 'b', 'c'];
		var x = array[0];
		var y = array[1];
		// ==>
		var [x, y] = ['a', 'b'];
	
.�� 
	1.class : ES6��ʼ����
		// �ඨ��
		class Student {
			// ���캯��
			constructor(name) { 
				// thisָ���Լ� , name ��Ա����
				this.name = name;
			}
			// ��Ա����
			hello() {
				//
			}
		}
		// ��̳�
		class PrimaryStudent extends Student {
			// ���캯��
			constructor(name, grade) {
				super(name); // ���ø��๹�캯��
				this.grade = grade;
			}
			// ��Ա����
			myGrade() {
				console.log(this.grade);
			}
		}
		// ��������
		var s1 = new Student("s1");
		s1.hello();
		var s2 = new PrimaryStudent("s2", 1);
		s2.hello();
		s2.myGrade();
		
		
	2.��class
	
	