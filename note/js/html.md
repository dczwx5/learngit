# <font color=#6616a1> HTML </font>
http://www.w3school.com.cn/js/js_window_location.asp

## <font color=#CD4F39> api </font>
```js
查找 HTML 元素
document.getElementById(id)	通过元素 id 来查找元素
document.getElementsByTagName(name)	通过标签名来查找元素
document.getElementsByClassName(name)	通过类名来查找元素

改变 HTML 元素
element.innerHTML = new html content	改变元素的 inner HTML
element.attribute = new value	改变 HTML 元素的属性值
element.setAttribute(attribute, value)	改变 HTML 元素的属性值
element.style.property = new style	改变 HTML 元素的样式

添加和删除元素
document.createElement(element)	创建 HTML 元素
document.removeChild(element)	删除 HTML 元素
document.appendChild(element)	添加 HTML 元素
document.replaceChild(element)	替换 HTML 元素
document.write(text)	写入 HTML 输出流

添加事件处理程序
document.getElementById(id).onclick = function(){code}	向 onclick 事件添加事件处理程序

查找 HTML 对象
document.anchors	返回拥有 name 属性的所有 <a> 元素。	1
document.applets	返回所有 <applet> 元素（HTML5 不建议使用）	1
document.baseURI	返回文档的绝对基准 URI	3
document.body	返回 <body> 元素	1
document.cookie	返回文档的 cookie	1
document.doctype	返回文档的 doctype	3
document.documentElement	返回 <html> 元素	3
document.documentMode	返回浏览器使用的模式	3
document.documentURI	返回文档的 URI	3
document.domain	返回文档服务器的域名	1
document.domConfig	废弃。返回 DOM 配置	3
document.embeds	返回所有 <embed> 元素	3
document.forms	返回所有 <form> 元素	1
document.head	返回 <head> 元素	3
document.images	返回所有 <img> 元素	1
document.implementation	返回 DOM 实现	3
document.inputEncoding	返回文档的编码（字符集）	3
document.lastModified	返回文档更新的日期和时间	3
document.links	返回拥有 href 属性的所有 <area> 和 <a> 元素	1
document.readyState	返回文档的（加载）状态	3
document.referrer	返回引用的 URI（链接文档）	1
document.scripts	返回所有 <script> 元素	3
document.strictErrorChecking	返回是否强制执行错误检查	3
document.title	返回 <title> 元素	1
document.URL	返回文档的完整 URL	1
```


## <font color=#CD4F39> 输出 </font>
```html
<!DOCTYPE html> <html> <head> </head> <body>

<p id="demo"></p>

<script type="text/javascript">
	document.write("输出到页面");
	document.getElementById("demo").innerHTML = "修改标签内容";
	window.alert(5 + 6); // 弹出alert窗口
	console.log("输出到控制台");
</script>

</body> </html>
```

## <font color=#CD4F39> 元素事件 </font>
```html
<!DOCTYPE html> <html> <body>

<script>
function funcAdd(c) {
	var a = 100;
	var b = 20;
    document.getElementById("result").innerHTML = "a+b+c=" + (a+b+c);
}
</script>


<h2 id="title">JavaScript title</h2>

<!--方式一， 函数内容在onClick里-->
<button type="button" onclick='document.getElementById("title").innerHTML = "Hello JavaScript!"'>点击我改变title！</button>

<!--使用 scprit的函数-->
<button type="button" onclick="funcAdd(50)">加法</button>

</body> </html>

```
## <font color=#CD4F39>页面</font>
js代码可以在 head, body, 外部url, 或外部文件中

```html
<!DOCTYPE html> <html> <head> </head> <body>

<p id="title"></p> <!--页面元素 -->

<script type="text/javascript">
	ele = document.getElementById("title"); // 获得页面元素 
	ele.style.fontSize;
	ele.style.display = 'none' // 隐藏元素 
	ele.url
	ele.innerHtml
</script>

</body></html>
```
## <font color=#CD4F39> 变量 </font>
```html
<!DOCTYPE html> <html> <head> </head> <body>

<script type="text/javascript">
	var a = 1000;
</script>
<script type="text/javascript">
	// var a 是全局的
	document.write ("a = " + a);
	var b = 123e-111;
	document.write ("b = " + b);
</script>

</body></html>
```

## <font color=#CD4F39> 导入外部JS </font>
js 导入时后执行语句

```html
<!DOCTYPE html> <html> <head> </head> <body>

<!--外部JS-->
<script type="text/javascript" src="myScript.js"></script> 
<script type="text/javascript" src="js_change_property.js"></script>
<script type="text/javascript" src="function.js"></script>

<script>
	// 另一种导入方式。 但不知道怎么执行函数
	// 	var element = document.createElement("script");
	// 	element.src = "myScript.js";
	// 	document.body.appendChild(element); 
	//// element.doFunc(); 这个不对s

	// downScripts();
	doFunc(); // 这个函数在myScrpit定义
</script>

</body> </html>

```


#end