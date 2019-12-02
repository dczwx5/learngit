# <font color=#FF7F24><font color=#FF0024>I</font><font color=#8FaFF6>O</font><font color=#007F24>S</font> 开发 ， objectC </font>

## <font color=#CD4F39>技术</font>
* ios调cocos
  * https://www.cnblogs.com/billyrun/articles/8529503.html
* cocos xlite
  * https://github.com/cocos-creator/cocos2d-x-lite
* cocos js-bindings
  * https://github.com/cocos-creator/cocos2d-x-lite/tree/develop/cocos/scripting/js-bindings
* ios打包
  * https://docs.cocos.com/creator/manual/zh/publish/publish-native.html 
  * http://www.cocoachina.com/ios/20170623/19623.html
* 苹果证书的申请与制作
  * https://www.cnblogs.com/yyou/p/6964104.html 
* app开发帐号
  * https://developer.apple.com/account/#/overview/X2L242V82K
* 扫一扫
  * https://www.jianshu.com/p/097c2d53c596


## <font color=#CD4F39>学 : 学习 : study</font>
* views and controls
* view Controllers
* view layout
* appearance customization
* animation and haptics
* windows and screens

## <font color=#CD4F39> 数据转换 </font>
* dict转string
  NSDictionary* dict = @{@"id":@"1", @"name":@"abc"}; // {id:"1", name:"abc"} 和ts等区别, @{}, key和value前加@, key要引号
  
```objc
  NSData * jsonFromMap = [NSJSONSerialization dataWithJSONObject:dataMap options:NSJSONWritingPrettyPrinted error:nil];
  NSString * strFromMap = [[NSString alloc] initWithData:jsonFromMap encoding:NSUTF8StringEncoding];
  // strFromMap => {"code" : 0,"result" : [{"name" : "abc","walletAddr" : "bcbEHa4sVMYk2kFPgYGxMgexcgpu6V5idYXA"}, {"name" : "abc","walletAddr" : "bcbL79f3i1qnH6j9NdDMKwEz1cdZyDcxxnYF"},],"msg" : ""}
```
* string 转 dict

```objc
  NSData* jsonFromString = [strFromMap dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary* dictFromJson = [NSJSONSerialization JSONObjectWithData:jsonFromString options:NSJSONReadingMutableContainers error:nil];
```


## <font color=#CD4F39> 关键字 </font>
* #import 
  * 用于导入，保证头语言件只包含一次，#include 也可以

## <font color=#CD4F39> 数据结构 </font>

### <font color=#BF3EFF>结构体</font>
* 初始化 

```objc
struct point {
	float x;
	float y;
} start = {100.0, 200.0};
struct point end = {.y=500, .x = 200};
```

### <font color=#BF3EFF> 字符串 </font>
* 字符串前用@
* NSString *name = @"Chase";
* NSString *str = [NSString stringWithFormat:@'hahaha']
* NSString 是不可变的字符串，每次修改都重新创建一个新的对象
* NSMutableString 可变字符串
* 字符串替换 [str stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
* std::string转NSString
```objc
  std::string _string("hello");
  NSString *str= [NSString stringWithCString:_string.c_str() encoding:[NSString defaultCStringEncoding]];
```
* NSString转std::string
```objc
  NSString  * nsfaceName=@"HELLO";
  const char  *  lpfaceName = [nsfaceName UTF8String];
  std::string   strFaceName=  [nsfaceName UTF8String];
```
### <font color=#BF3EFF> instancetype / id </font>
  * id
    * 动态类型,弱类型
    * id 类似 as中的object, 可以动态访问不存在的变量, (但应该不能动态创建新成员)
    * id 在运行时，才检测
    * [id abc] = 100;
    * id 已经包含*, id是一个指针, 只能指向oc中的对象
    * id 不能使用.语法,
    * id 调用的方法，如果在所有类中都不存在，会报错 
  * instancetype
    * 与id类似, 但只能用做返回值
    * 类型由所在的类型文件决定
    
### <font color=#BF3EFF> 数据类型</font>

  * isKindOfClass 
    * [p isKindOfClass: [ClassP class]]; // 检测 p是否为 classP的子类 => true
    * [p isKindOfClass: [NSObject class]]; // => true
  * isMemberOfClass
    * [p isMemberOfClass: [ClassP class]]; // 检测 p是否为 classP的子类 => true
    * [p isMemberOfClass:[NSObject class]]; // => flase, 不能检测NSObject
   
### <font color=#ff0000>基本语法</font>
* self => this
* super
* 类 
  * 定义
  	* .h定义 ： @interfacce 开始， @end 结束
  	* .m定义 ： @implementation 开始， @end 结束
  	
  	```objc
  	// .h
  	@interface MyClass : NSObject // 所有类继承NSObject类
  	{
  		@private int var;
  		@public int color;
  	}

  	-(void) setColor:(int)color; // 成员函数
  	+(void) showMe; // 静态函数
  	@end
  	// .m
  	@implementation MyClass
  	-(void)setColor:(int)color{
  		//
  	}
  	+(void) showMe{
  		//
  	}
  	@end
  	```
  * 构造函数
    * 凡是以init开头的函数都是构造函数 
    * 无参构造函数
      * -(id) init;
    * 有参构造函数 以initWith开头
      * -(id) initWithXXX:(int)a andB:(int)b
  * 析构函数
    * 不能手动调用
    -(void)dealloc {
    	[super dealloc]; // 调用有时会报错，arc是5.0的功能
    }
  * api
    * release
      * arc提供的新api， 调用release可销毁对象

 * MyClass *mc = [[MyClass alloc] init]; // alloc

  * 访问修饰符
    * @public 
    * @protected
    * @private
    * 默认@protected 
    * ？ Object-C中的成员变量使用了@public、@protected、@private 作为访问修饰符，默认的@protected。Object-C中只用成员变量有访问修饰符，类变量、类方法、成员方法是没有访问修饰符的，所有的方法都是@public，所有的类变量都是@private。
  * 成员函数
  	* -(void) func: (int)param1
  * 静态函数，类方法
    * +(void) func:(int)param1
  * 方法调用
    * [self func:100] => this.func(100)
  * 无参函数定义
    -(int) getX;
  * 有参函数定义
  	+(void) setX:(int) x;
  * 多参函数定义
    -(void) setXY:(int) x andSetXY:(int) y; // 除第一个参数外，其他参数前都要写一个名字，并且调用时也是一样
    // 调用
    [mc setXY:9 andSetXY:22]; // -》 mc.setXY(9, 22);
  * @property
  	* atomic, assign, readwrite 为默认值
    * @property (atomic, assign, readwrite)int age;  同等于 @property int age;
    * assign 只能用于基础数据类型
      * @property NSObject *obj; // 会报警告
      * @property(retain) NSObject *obj; // 正确
    * 建议使用 strong/weak 代替 assgin/retain/copy
    * 释义
      * atomic / nonatomic
        * 默认为 atomic
	    * atomic : 线程安全
	    * nonatomic : 非线程安全 (性能高)
      * assign / retain / copy
      	* assgin : 
      	  * 直接赋值
      	  * 基础类型 (int, float, double, char, CGFloat, NSInteger)
      	* retain : 
      	  * 引用一个对象
      	  * 用于 NSObject 
      	* copy : 
      	  * 复制对象
      	  * 用于 NSString
      * strong / weak (新特性)
        * strong 
          * 自动会判断使用retain还是copy
          * 可以看成是强引用
        * weak 
          * 弱引用
          * 当引用对象的引用计数为0时，weak对象的值也会被清除
      * readwrite / readonly
  * property / synthesize
    * 在头文件中：
      * @property int count;  
      * 等效于在头文件中声明2个方法：
        - (int)count;   
        -(void)setCount:(int)newCount;
   * 实现文件(.m)中
     * @synthesize count;  
     * 等效于在实现文件(.m)中实现2个方法。
       - (int)count {
         return count;
       }
       -(void)setCount:(int)newCount {
         count = newCount;
       }
    * 关联成员
      * 头文件中 
        @interface MyClass 
        {
        @private int m_age;
        }
        property int age;
        @end
      * .m中
        @implementation MyClass
        @synthesize age = m_age;
        @end

## <font color=#CD4F39> 数组 </font>
* 初始化
  * int a[] = {[9]=x+1, [2]=3}; // 10个元素，只给 a[9] 和 a[2]赋了值
* 不可变数组

```objc
  NSArray *array = [NSArray arrayWithObjects:&'kksb', @'abab', @'cccc', myClass, nil];
  int count = [array count];
  for (int i = 0; i < count; ++i) {
  	NSLog(@'i = %d : , value : %@', i, [array objectAtIndex:i]);
  }
```


## <font color=#CD4F39> 控制结构 </font>
### <font color=#ff0000>for </font>
for i

```objc
  for (int i = 0; i < 5; ++i) {
  	NSLog(@'i = %d ', i);
  }
```

for in

```objc
for (int value in list) {
  	NSLog(@'value = %d', value);
  }
```

## <font color=#CD4F39> 类库 </font>
* NSLog
  * NSLog('name is aaa');

## <font color=#CD4F39>功能</font>
### <font color=#ff0000>切换横竖屏</font>

```objc
#pragma mark first
在配置设置时，只设置竖屏, 这样在打开应用时，不会因为手机方向导致旋转

#pragma mark AppController.mm
#pragma mark 替换项目设置的横竖屏设置
#pragma mark 解决键盘不旋转
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
```
```objc
#pragma mark RootViewController.mm
#pragma mark 禁止应用随手机旋转而切换横竖屏
#pragma mark 会导致键盘不旋转
// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
#ifdef __IPHONE_6_0
- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
#endif

- (BOOL) shouldAutorotate {
    return __isOpenAutoRotate; // 会导致键盘不旋转
}
```
```objc
#pragma mark FunctionFacade.mm
#pragma mark 切换横竖屏处理
+(void) enterLandscreen:(NSString *)funcName funcID:(NSString *)funcID {
	[CFunctionFacade setOrientation:(UIInterfaceOrientation)UIDeviceOrientationLandscapeLeft];
}
+(void) enterPortscreen:(NSString *)funcName funcID:(NSString *)funcID {
	[CFunctionFacade setOrientation:(UIInterfaceOrientation)UIInterfaceOrientationPortrait];
}
+(void) setOrientation:(UIInterfaceOrientation)orientation {
    __isOpenAutoRotate = true;
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];//前两个参数已被target和selector占用
    [invocation invoke];
    
    __isOpenAutoRotate = false;
}
```
```typescript
/*切横竖屏后，重新设置屏幕大小，布局*/
toLand() {
        console.log('toLand');
        osFunction.enterLandscreen();
        let size = cc.view.getCanvasSize();
        let w, h;
        if (size.width > size.height) {
            // 横屏
            w = size.width;
            h = size.height;
        } else {
            // 竖屏
            w = size.height;
            h = size.width;
        }

        cc.view['setCanvasSize'](w, h);
        this.refreshHallLayer(); // 自适应/布局
    }
```
### <font color=#ff0000>复制粘贴</font>
### <font color=#ff0000>退出应用</font>
```objc
+(void)exitApplication:funcName funcID:(NSString *)funcID{
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    abort();
    #pragma clang diagnostic pop
}
```
### <font color=#ff0000>webView</font>
```objc
// file : jsb_webview_auto.cpp
// func : js_webview_WebView_create
auto result = cocos2d::WebView::create();
__currentWebView = result;

// 设置webview's visible, 在cocos层设置无效
+(void) setWebViewVisible:(NSString *)funcName funcID:(NSString *)funcID isVisible:(bool)isVisible {
    if (__currentWebView){
        __currentWebView->setVisible(isVisible);
    }
}
```


### <font color=#ff0000>取得当前window</font>

```objc
+(UIWindow *)lastWindow {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isMemberOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    return [UIApplication sharedApplication].keyWindow;
}
```

### <font color=#ff0000>webView设置</font>
```objc
ui/webview/webViewImpl-ios.mm
- (void)setupWebView {
    if (!self.uiWebView) {
        self.uiWebView = [[[UIWebView alloc] init] autorelease];
        self.uiWebView.delegate = self;
        
        // add by auto 全面屏适配关闭(不关闭的话。上下左右会有空白)
        if (@available(ios 11.0,*)) {
            self.uiWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        // add by auto, 禁止web滚动
        self.uiWebView.scrollView.scrollEnabled = false;
    }
    ...
}

```


# END