* Build Setting : 发布设置
	1.player Setting :
		1.Resolution and presentation : 
			1.default is full screen : 
			2.default is navive resolution : 用当前设备的分辨率
* Edit 菜单
	1.Selection : 保持对多物体的选择。没什么用
	2.Project Setting : 
		1.Input : 输入控制
		2.Time : 游戏fps控制
	3.Render Setting : 全局渲染控制
		1.fog : 如果不打开fog, 物体不管多远，都会显示在窗口, 如果打开了，则会用fog代替远处的物体
		2.Ambient light : 全局环境光（非自己创建的光源）
			1.如果做场景烘培, 则要关闭环境光，不然结果会有出入
			2.将光的颜色设为0
	4.Snap Setting : 
		1.操作场景物体时各操作的步长(moveX,Y,Z, scalc...)
* Assets : (操作针对Project)
	1.Import Package / Export Package : 导入导出资源包
	2.Select Dependencies : 
		1.选择与选中物体组成的资源
		2.然后通过显示出的物体(们)全选, 右键可以导出资源包(导出单物体的所有资源)
* gameobject : (操作针对Scene/hierarchy)
* Component : 
	1.添加默认的脚本组件
	2.Navigation : 导航风格
	3.Scripte : 自己的script
* Rendering path : 渲染模式
	1.vectex Lit : 顶点渲染
		1.性能最高
		2.不支持阴影
	2.forward : 正向渲染
		1.正向渲染
		2.可以使用32层(layer)
		3.只支持一个方向光产生阴影
	3.deferred lighting :  延迟渲染
		1.性能最低
		2.不支持移动端
		3.不支持抗锯齿
		4.只能使用4层(layer)
* 生命周期
    * 加载新关卡时，所有对象都会被销毁，如果不想被销毁，使用DontDestroyOnLoad
    
* gameobject
    * acticveSelf
        * parent的值，覆盖child的值（和as的mouseEnanle，visible等一样）
        * 不能简单使用activeSelf简单的判断对象是否激活，使用activeInHierarchy

* prefab
        * 添加删除组件或对象，链接破坏
        
* 数据类型
    * object
        * 类型转换为对象 装箱 obj = 1
        * 对象转换为值类型 拆箱 int v = obj
    * dynamic 
        * dynamic dv = 100;
        * 运行时检查类型，可以存任何类型
    * 左值右值 
        * 左值可以在赋值语句左和右
        * 右值只能在右边
* 类 
* 