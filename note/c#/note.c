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
    * Nullable
       * Nullable<bool> b
       * 变量b可存true false null三个值
* 类 
        * 访问修饰符
            * internal 可以被应该程序的任何类或方法访问
            * protect internal 只能被应用程序内的子类访问
       
* 函数 
        * 值传
            * 数值会被复制新的结构传入函数
        * ref 
            * 按引用传参
            * void func(ref int param)
            * func(v)
            * 期望不复制结构
            * 传入函数的是变量地址的引用
        * out 
            * 用于多个返回值
            * int func(out int param)
            * func(out int)
            * 效果和ref类似，期望从函数中带出返回值
    
* 数组
        * 