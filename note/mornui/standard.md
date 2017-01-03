---
title: 2016-12-17 规范
grammar_cjkRuby: true
---


## xx
* mornUI资源不要随便加载
* 资源不存在
	* 有可能是之前先new了。但是没有加载swf, 后面再加载swf，图片也不会出来(有可能是底层被改了), 
	* 也有可能是一个界面包含了多个swf, 某些swf没有加载
* 事件顺序 : 
	* 父级先触发事件
	* 子层后触发, 超上层超后触发
	* resize先于reposition触发, resize会触发reposition
* image加载完图片之后, 父层会发出resize事件
* repeatX/Y修改之后, 不一定会重要布局坐标. 因此在对于动态 调整坐标的。最好设置一下list.centerX = list.centerX, 强制布局
