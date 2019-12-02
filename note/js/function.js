console.log('================function.js==============');
var func = new Function('a', 'b', 'return a+b;');
var value = func(100, 123);
console.log(value);

