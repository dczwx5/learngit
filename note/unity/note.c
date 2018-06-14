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