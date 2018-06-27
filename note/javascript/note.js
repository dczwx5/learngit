�������� : 
	.JavaScript�����������͸�������ͳһ�� Number ��ʾ�����¶��ǺϷ��� Number ���ͣ�
		123; // ����123
		0.456; // ������0.456
		1.2345e3; // ��ѧ��������ʾ1.2345x1000����ͬ��1234.5
		-99; // ����
		NaN; // NaN��ʾNot a Number�����޷�������ʱ��NaN��ʾ
		Infinity; // Infinity��ʾ���޴󣬵���ֵ������
	.�ַ������Ե�����'��˫����"�������������ı�
	.����JavaScript������ȱ�ݣ���Ҫʹ��==�Ƚϣ�ʼ�ռ��ʹ��===�Ƚϡ�
	.NaN
		��һ�������� NaN �������� Number ����������ֵ������ȣ��������Լ���
			NaN === NaN; // false
			Ψһ���ж�NaN�ķ�����ͨ��isNaN()������
			isNaN(NaN); // true
	.Number 
		�ⲻ��JavaScript�����ȱ�ݡ�����������������л��������Ϊ������޷���ȷ��ʾ����ѭ��С����Ҫ�Ƚ������������Ƿ���ȣ�ֻ�ܼ�������֮��ľ���ֵ�����Ƿ�С��ĳ����ֵ��
		Math.abs(1 / 3 - (1 - 2 / 3)) < 0.0000001; // true
	.null �� undefined
	.����
		������һ�鰴˳�����еļ��ϣ����ϵ�ÿ��ֵ��ΪԪ�ء�JavaScript��������԰��������������͡����磺
		[1, 2, 3.14, 'Hello', null, true];
		new Array(1, 2, 3); // ����������[1, 2, 3]
		Ȼ�������ڴ���Ŀɶ��Կ��ǣ�ǿ�ҽ���ֱ��ʹ��[]��
		�����Ԫ�ؿ���ͨ�����������ʡ���ע�⣬��������ʼֵΪ0��
			var arr = [1, 2, 3.14, 'Hello', null, true];
			arr[0]; // ��������Ϊ0��Ԫ�أ���1
			arr[5]; // ��������Ϊ5��Ԫ�أ���true
			arr[6]; // ���������˷�Χ������undefined
		// length
			arr.length = 10; // ��ı����鳤��. 
		��ע�⣬���ͨ��������ֵʱ�����������˷�Χ��ͬ��������Array��С�ı仯��
			var arr = [1, 2, 3];
			arr[5] = 'x';
			arr; // arr��Ϊ[1, 2, 3, undefined, undefined, 'x']


	
	.'use strict';
		ʹ��use strict ��ǿ�Ʊ���һ��Ҫ�ȶ���. 
		�������û��������ȫ�ֱ���
	.�ַ���
		toUpperCase
			toUpperCase()��һ���ַ���ȫ����Ϊ��д��
			var s = 'Hello';
			s.toUpperCase(); // ����'HELLO'
		toLowerCase
			toLowerCase()��һ���ַ���ȫ����ΪСд��
			var s = 'Hello';
			var lower = s.toLowerCase(); // ����'hello'����ֵ������lower
			lower; // 'hello'
		indexOf
			indexOf()������ָ���ַ������ֵ�λ�ã�
			var s = 'hello, world';
			s.indexOf('world'); // ����7
			s.indexOf('World'); // û���ҵ�ָ�����Ӵ�������-1

		substring
			substring()����ָ������������Ӵ���
			var s = 'hello, world'
			s.substring(0, 5); // ������0��ʼ��5��������5��������'hello'
			s.substring(7); // ������7��ʼ������������'world'

.����
	.indexOf
		��String���ƣ�ArrayҲ����ͨ��indexOf()������һ��ָ����Ԫ�ص�λ�ã�
			var arr = [10, 20, '30', 'xyz'];
			arr.indexOf(10); // Ԫ��10������Ϊ0
			arr.indexOf(20); // Ԫ��20������Ϊ1
			arr.indexOf(30); // Ԫ��30û���ҵ�������-1
			arr.indexOf('30'); // Ԫ��'30'������Ϊ2
		ע���ˣ�����30���ַ���'30'�ǲ�ͬ��Ԫ�ء�


	.slice
		slice()���Ƕ�ӦString��substring()�汾������ȡArray�Ĳ���Ԫ�أ�Ȼ�󷵻�һ���µ�Array��
			var arr = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
			arr.slice(0, 3); // ������0��ʼ��������3������������������3: ['A', 'B', 'C']
			arr.slice(3); // ������3��ʼ������: ['D', 'E', 'F', 'G']
		ע�⵽slice()����ֹ����������ʼ����������������������
		�������slice()�����κβ��������ͻ��ͷ��β��ȡ����Ԫ�ء�������һ�㣬���ǿ��Ժ����׵ظ���һ��Array��
			var arr = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
			var aCopy = arr.slice();
			aCopy; // ['A', 'B', 'C', 'D', 'E', 'F', 'G']
			aCopy === arr; // false


	.push��pop
		push()��Array��ĩβ�������Ԫ�أ�pop()���Array�����һ��Ԫ��ɾ������
			var arr = [1, 2];
			arr.push('A', 'B'); // ����Array�µĳ���: 4
			arr; // [1, 2, 'A', 'B']
			arr.pop(); // pop()����'B'
			arr; // [1, 2, 'A']
			arr.pop(); arr.pop(); arr.pop(); // ����pop 3��
			arr; // []
			arr.pop(); // ���������pop���ᱨ�����Ƿ���undefined
			arr; // []


	.unshift��shift
		���Ҫ��Array��ͷ���������Ԫ�أ�ʹ��unshift()������shift()�������Array�ĵ�һ��Ԫ��ɾ����
			var arr = [1, 2];
			arr.unshift('A', 'B'); // ����Array�µĳ���: 4
			arr; // ['A', 'B', 1, 2]
			arr.shift(); // 'A'
			arr; // ['B', 1, 2]
			arr.shift(); arr.shift(); arr.shift(); // ����shift 3��
			arr; // []
			arr.shift(); // ���������shift���ᱨ�����Ƿ���undefined
			arr; // []

	.sort
		sort()���ԶԵ�ǰArray������������ֱ���޸ĵ�ǰArray��Ԫ��λ�ã�ֱ�ӵ���ʱ������Ĭ��˳������

			var arr = ['B', 'C', 'A'];
			arr.sort();
			arr; // ['A', 'B', 'C']
		�ܷ��������Լ�ָ����˳�������أ���ȫ���ԣ����ǽ��ں���ĺ����н�����

	.reverse
		reverse()������Array��Ԫ�ظ���������Ҳ���Ƿ�ת��
			var arr = ['one', 'two', 'three'];
			arr.reverse(); 
			arr; // ['three', 'two', 'one']
	.splice
		splice()�������޸�Array�ġ����ܷ������������Դ�ָ����������ʼɾ������Ԫ�أ�Ȼ���ٴӸ�λ���������Ԫ�أ�
			var arr = ['Microsoft', 'Apple', 'Yahoo', 'AOL', 'Excite', 'Oracle'];
			// ������2��ʼɾ��3��Ԫ��,Ȼ�����������Ԫ��:
			arr.splice(2, 3, 'Google', 'Facebook'); // ����ɾ����Ԫ�� ['Yahoo', 'AOL', 'Excite']
			arr; // ['Microsoft', 'Apple', 'Google', 'Facebook', 'Oracle']
			// ֻɾ��,�����:
			arr.splice(2, 2); // ['Google', 'Facebook']
			arr; // ['Microsoft', 'Apple', 'Oracle']
			// ֻ���,��ɾ��:
			arr.splice(2, 0, 'Google', 'Facebook'); // ����[],��Ϊû��ɾ���κ�Ԫ��
			arr; // ['Microsoft', 'Apple', 'Google', 'Facebook', 'Oracle']

	.concat
		concat()�����ѵ�ǰ��Array����һ��Array����������������һ���µ�Array��
			var arr = ['A', 'B', 'C'];
			var added = arr.concat([1, 2, 3]);
			added; // ['A', 'B', 'C', 1, 2, 3]
			arr; // ['A', 'B', 'C']
		��ע�⣬concat()������û���޸ĵ�ǰArray�����Ƿ�����һ���µ�Array��
		ʵ���ϣ�concat()�������Խ��������Ԫ�غ�Array�������Զ���Array�𿪣�Ȼ��ȫ����ӵ��µ�Array�
			var arr = ['A', 'B', 'C'];
			arr.concat(1, 2, [3, 4]); // ['A', 'B', 'C', 1, 2, 3, 4]

	.join
		join()������һ���ǳ�ʵ�õķ��������ѵ�ǰArray��ÿ��Ԫ�ض���ָ�����ַ�������������Ȼ�󷵻����Ӻ���ַ�����
			var arr = ['A', 'B', 'C', 1, 2, 3];
			arr.join('-'); // 'A-B-C-1-2-3'
		���Array��Ԫ�ز����ַ��������Զ�ת��Ϊ�ַ����������ӡ�
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
	// ����Array���Բ����±�ѭ��������Map��Set���޷�ʹ���±ꡣΪ��ͳһ�������ͣ�ES6��׼�������µ�iterable���ͣ�Array��Map��Set������iterable���͡�
	// ����iterable���͵ļ��Ͽ���ͨ���µ�for ... ofѭ����������
	// for ... ofѭ����ES6������µ��﷨����������������Ƿ�֧�֣�
	'use strict';
	var a = [1, 2, 3];
	for (var x of a) {
	}
	console.log('��������֧��for ... of');

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
		
��ĩ�Զ���ӷֺ� : 
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
	
ȫ�������� : 
	// �����ⶨ��ı���, ��������ȫ�ֱ���, ����, ����window������
	var abc = 13;
	alert(abc); // �ȼ�
	alert(window.abc); // �ȼ�
	// ����Ҳһ��
	function foo() {
		alert('foo');
	}

	foo(); // ֱ�ӵ���foo()
	window.foo(); // ͨ��window.foo()����
let : 
	// ��as һ��. �������������Ǻ�����, ����for�ﶨ��ı���, Ҳ���ں����ڶ�����ʹ�õ�
	// Ϊ������for ���涨��ֲ�����, ʹ��let, �̶�����
	for (let i = 0; i < 100; i++) {
		// i ��������ֻ��for��
	}
const :
	// ����
	// �� let һ��, ������������
	
�⹹��ֵ : 
		// 
		var array = ['a', 'b', 'c'];
		var x = array[0];
		var y = array[1];
		// ==>
		var [x, y] = ['a', 'b'];
	
	
	
	
	