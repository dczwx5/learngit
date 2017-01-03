---
title: while代替for, 正反向遍历
grammar_cjkRuby: true
---


```actionscript
public function loopForward(list:Array, callback:Function) : void {
	if (callback == null || list == null || list.length == 0) return ;
	var i:int = 0;
	var len:int = list.length;
	for (i = 0; i < len; i++) {
		obj = list[i];
		callback(obj);
	}
}
public function loopBack(list:Array, callback:Function) : void {
	if (callback == null || list == null || list.length == 0) return ;
	var i:int = 0;
	var len:int = list.length;
	for (i = len-1; i >= 0; i--) {
		obj = list[i];
		callback(obj);
	}
}

public function loop(list:Array, callback:Function, isForward:Boolean) : void {
	if (callback == null || list == null || list.length == 0) return ;
	var len:int = list.length;
	var i:int = len - 1;
	if (isForward) i = 0;
	while((isForward&& i < len) || (!isForward && i >= 0)) {
		obj = list[i];
		callback(obj);
		
		if (isForward) ++i; 
		else --i;
	}
}
```
