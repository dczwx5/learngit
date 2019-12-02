## cocos库目录
* Macintosh HD⁩ ▸ ⁨Applications⁩ ▸ ⁨CocosCreator⁩ ▸ ⁨Contents⁩ ▸ ⁨Resources⁩ ▸ ⁨cocos2d-x⁩ / cocos
* Macintosh HD⁩ ▸ ⁨Applications⁩ ▸ ⁨CocosCreator⁩ ▸ ⁨Contents⁩ ▸ ⁨Resources⁩ ▸ ⁨cocos2d-x⁩ ▸ ⁨cocos⁩ ▸ ⁨scripting⁩ ▸ ⁨js-bindings⁩

## cocos - vscode 项目环境配置
https://docs.cocos.com/creator/manual/zh/getting-started/coding-setup.html##-vs-code--1
### 设置vs扩展（vscode extension）, 和代码提示（vs code api source） (冒似每个项目都需要点一下)
  * 标题栏->开发者(developer)->vs 工作流（vs code workflow) -> 
    * 分别点下
      1.instance vs code extension
      2.update vs code api source
        * 会在项目目录下。生成creator.d.ts文件
        * creator.d.ts文件需要和assets同目录
### 安装chrom debugger
* 在左侧扩展中搜索 Debugger for Chrome, 并安装, 启用 (每个项目都需要启用)
* 在调试页，点debug右边那个，点 add configurations
* 打开launch.json文件, 并替换内容

```js
{
  "version": "1.4.0",
  "configurations": [
      {
          "name": "Creator Debug: Launch Chrome",
          "type": "chrome",
          "request": "launch",
          "url": "http://localhost:7456",
          "sourceMaps": true,
          "userDataDir": "${workspaceRoot}/.vscode/chrome",
          "diagnosticLogging": false,
          "pathMapping": {
              "/preview-scripts/assets": "${workspaceRoot}/temp/quick-scripts/assets",
              "/": "${workspaceRoot}"
          }    
      }
  ]
}
```
### 文件显示和搜索过滤
meta文件在vscode不需要显示, 以及不显示library,temp等文件夹
* 设置
  * 在 VS Code 的主菜单中选择 文件（Windows）／Code（Mac）-> 首选项 -> 设置
  * 搜索 files.exclude
    * 添加需要过滤掉的目录和文件
      * '**/*.meta' 过滤掉meta文件  （引号不需要，这里是格式表示有问题）
      * library/ 过滤掉文件夹
      * temp/
      * local/ 
      * .vscode/

### 编译
* vscode 中修改了内容, 不会自动编译
* 两种编译方式
  1. command+p -> 输入 task compile
    * 可将操作设置为快捷键
		 
	 ```js
	  {
	    "key": "shift+p", //请配置自己习惯的快捷键
	    "command": "workbench.action.tasks.runTask",
	    "args": "compile"
	  }
	 ```
    * 快捷键参考 快捷键笔记 
  2. 切回cocos creator 点刷新，再切回vscode 

### 快捷键设置
* 路径 Code -> 首选项 -> 键盘快捷方式
* 在上面打开的路径。可以看到可以修改各个快捷键
* 新建快捷键
  1.keybindings.json (ctrl+p(win)）(command+p(mac))快捷键打开文件)， 以下是编译的快捷键
  
``` js
    [
        {
            "key": "shift+p", //请配置自己习惯的快捷键
            "command": "workbench.action.tasks.runTask",
            "args": "compile"
        }
    ]
```
  2.在keyboard shortcuts最右边一个{}， 点击打开 keybindings.json
* 常用快捷键
  1.jump to line -> ctrl + g
  2.jump to erorr -> f8
  3.上一位置 shift+- 改成alt-
  4.下一位置 shift+ctrl+- 改成 alt+

## Scene
* 场景默认不释放
* 资源结构
  * Prefab -> Node -> Sprite -> SpriteFrame -> Texture
* 加载场景时，会先自动加载场景关联到的资源，这些资源如果再关联其它资源，其它也会被先被加载，等加载全部完成后，场景加载才会结束。

## 内存释放
* 场景自动释放
  * cc.loader.release 精确释放不使用的资源
  * 默认情况下，场景切换不自动释放资源，可以设置
  * 已知问题：粒子系统的 plist 所引用的贴图不会被自动释放。如果要自动释放粒子贴图，请从 plist 中移除贴图信息，改用粒子组件的 Texture 属性来指定贴图。
  * setAutoRelease 
  * 单个资源上改变这个默认行为，强制在切换场景时保留或者释放指定资源
  * 如果场景设置了自动释放资源，可以通过这个属性，设置单个资源不被释放
* 动态加载资源
  * cc.loader.loadRes
    * 资源必须放在resource目录下
    * 只加载单个资源
    * 资源不传文件后缀
    * resource目录必须在assets根目录下
    * 例
    
		```js
		// 加载 Prefab
		cc.loader.loadRes("test assets/prefab", function (err, prefab) {
		  var newNode = cc.instantiate(prefab);
		  cc.director.getScene().addChild(newNode);
		});
		
		// 加载 AnimationClip
		var self = this;
		cc.loader.loadRes("test assets/anim", function (err, clip) {
		  self.node.getComponent(cc.Animation).addClip(clip, "anim");
		});
		```
  * cc.loader.loadResDir
    // 加载 test assets 目录下所有资源
    cc.loader.loadResDir("test assets", function (err, assets) {
      // ...
    });

    // 加载 test assets 目录下所有 SpriteFrame，并且获取它们的路径
    cc.loader.loadResDir("test assets", cc.SpriteFrame, function (err, assets, urls) {
      // ...
    });
* 释放机制
  * 资源不会由垃圾回收自动释放
  * 加载一个资源之后，资源对象会缓存到Loader
  * 如加载一个Prefab之后，Loader中同时会有Prefab, spirteFrame, Texture的缓存
  * 而释放一个Prefab时， spirteFrame和Texture不会被释放，因为他们可能还被其他对象使用
  * 释放例
    // 释放texture
    cc.loader.release(texture);
    // 释放一个prefab以及所有依赖
    Var deps = cc.loader.getDependsRecursively('prefabs/sample');
    cc.loader.release(deps);
    // 释放一个prefab以及所有依赖，同时一些资源不释放
    var deps = cc.loader.getDependsRecursively('prefabs/sample');
    Var index = deps.indexOf(texture2d._uuid);
    If (-1 !== index) deps.splice(index, 1); // 将资源依赖从deps中移除
    cc.loader.release(deps);

cc.loader.loadRes 或 cc.loader.loadResDir 动态加载的资源，则不受场景设置的影响，默认不自动释放。

## Pipeline
* 用于url加载
* 所有加载完成，流程结束

## Loader
* AssertLoader
* DownLoader
* Loader

## CCLoader

## 生命周期
* onLoad
* enable
* start 只调一次
* disable
* destroy 

## Director
* cc.director 一个管理你的游戏的逻辑流程的单例对象。
* getActionManager 获取和 director 相关联的 cc.ActionManager（动作管理器）。
* setActionManager 设置和 director 相关联的 cc.ActionManager（动作管理器）。
* getCollisionManager 获取和 director 相关联的 cc.CollisionManager （碰撞管理器）。
* getPhysicsManager 返回与 director 相关联的 cc.PhysicsManager （物理管理器）
* getWinSize 获取视图的大小，以点为单位。
* getWinSizeInPixels 获取视图大小，以像素为单位（这里的像素指的是资源分辨率
* getVisibleSize 获取运行场景的可见大小。
* pause 暂停正在运行的场景，该暂停只会停止游戏逻辑执行，但是不会停止渲染和 UI 响应
* isPaused 是否处于暂停状态
* resume 恢复暂停场景的游戏逻辑，如果当前场景没有暂停将没任何事情发生
* getScheduler 获取和 director 相关联的 cc.Scheduler
* setScheduler 设置和 director 相关联的 cc.Scheduler
* runSceneImmediate 立刻切换指定场景
* runScene 运行指定场景
* loadScene 通过场景名称进行加载场景
* preloadScene 预加载场景，你可以在任何时候调用这个方法

## animation
* cc.sequence 
  * 顺序执行动作，创建的动作将按顺序依次运行。
  *sequence(actionOrActionArray: FiniteTimeAction | FiniteTimeAction[], ...tempArray: FiniteTimeAction[]): ActionInterval;
* FiniteTimeAction
  * 有限时间动作，这种动作拥有时长 duration 属性。
* ActionInterval
  * 时间间隔动作，这种动作在已定时间内完成，继承 FiniteTimeAction。
  * action.easing(cc.easeIn(3.0)); 返回 ActionInterval
* ActionInstant
  * 即时动作，这种动作立即就会执行，继承自 FiniteTimeAction。

## Scheduler 类型
Scheduler 是负责触发回调函数的类。
通常情况下，建议使用 cc.director.getScheduler() 来获取系统定时器。
有两种不同类型的定时器：
- update 定时器：每一帧都会触发。您可以自定义优先级。<br/>
- 自定义定时器：自定义定时器可以每一帧或者自定义的时间间隔触发。<br/>
如果希望每帧都触发，应该使用 update 定时器，使用 update 定时器更快，而且消耗更少的内存。


## pool
* let pool = new cc.NodePool('MenuItem'); // 创建对象池 menuItem -> 自定义类
* pool.get(); // 取出对象池
* pool.push(node); // 放回对象池
* get -> reuse, put -> unuse // 对应的回调
* get('aa') -> reuse('aa'); // get传入的参数会传入reuse
* size // 空闲数量

## 模板
* on<T extends Function>(type: string, callback: T, target?: any, useCapture?: boolean): T;   
* func<T>(arg:T):T; // 模板T，
* func<T>(args:Array<T>):Array<T>; // 
* let pFunc<T>(arg:T) => T = func; // 声明
* 静态不能用模拟板
* 接口模板  // 类似委托
  interface IFunc{
    (a:T, b:T):T;
  }
  add<T>(a:T, b:T):T {
    return a+b;
  }
  let pFunc:IFunc = add;
* 泛型创建工厂函数
  create<T>(clazz:{new():T;}):T {
    return new clazz();
  }
  
## delegate
* 在需要回调时，指定回调格式很有用
* 实现类似C#的delegate
* 例

  ```js
  // 模仿delegate, 相比较ts方式，delegate格式要美观
  interface IDelegate {
    (a:number, b:number):number;
  }
  func(caller:any, callback:IDelegate, a:number, b:number) {
    callback.call(caller, a, b);
  }

  add(a:number, b:number) : number { return a+b; }
  func(this, add, 10, 20);
  ```

  ```js
  //ts的方式
  func(caller:any, callback:(a:number, b:number)=>number), a:number, b:number) {
    callback.call(caller, a, b);
  }
  add(a:number, b:number) : number { return a+b; }
  func(this, add, 10, 20);
  ```

  ```js
  // 横板delegate
  interface ITDelegate {
    (a:T, b:T) : T;
  }
  func<T>(caller:any, callback:ITDelegate, a:T, b:T) {
    callback.call(caller, a, b);
  }
  add(a:number, b:number) : number { return a+b; }
  func(this, add, 10, 20); // ts会自动推断类型
  func<number>(this, add, 10, 20);
  ```


# GL,UI线程
* cocos中的渲染和JS在GL线程中执行
* ui在UI线程中执行
* app.runOnUiThread 
  * 在原生中不要直接调用ui显示。用runOnUiThread处理
  * 并在cocos层通过 jsb.reflection.callStaticMethod调用

# cocos IOS 互调
## cocos调IOS
* 调ios
  * jsb.reflection.callStaticMethod("iosClassName", "iosFuncName", param1, param2, ...);
  * iosFuncName 需要和ios函数结构一致 
  * ios里的函数, 需要是静态的
  
``` typescript
// ios回调接口
export function orginCallback(funcID:string, result:any) {
    // result.code;
    // result.msg
    // result.result
    if (osAdapter.s_callbackMap) {
        if (osAdapter.s_callbackMap.hasOwnProperty(funcID)) {
            let callbackObject:Object = osAdapter.s_callbackMap[funcID];
            if (callbackObject) {
                let caller:any = callbackObject['caller'];
                let callback:Function = callbackObject['callback'];
                if (callback) {
                    callback.call(caller, result);
                }
            }
            delete osAdapter.s_callbackMap[funcID];
        }
    }

    console.log("call by orgin => orginCallback : ", funcID);
}
window['orginCallback'] = orginCallback;

// ios接口调用
static callOrginApi(packageType:number, funcName:string, funcParams:Array<any>, callback:Function, caller:any) {
    let funcID:number = 0;
    if (callback) {
        osAdapter.s_funcID++;
        funcID = osAdapter.s_funcID;
        if (!osAdapter.s_callbackMap) {
            osAdapter.s_callbackMap = {};
        }
        osAdapter.s_callbackMap[funcID] = {caller:caller, callback:callback};
    }
    

    // 传入原生的参数， 第一个为回调函数， 第二个回调函数的全局id
    let methodParams = null; //funcParams;
    if (callback) {
        methodParams = ['orginCallback', funcID.toString()];
    } else {
        methodParams = ['', funcID.toString()];
    }
    methodParams = methodParams.concat(funcParams);

    let packageName:string = IosAdapter.getPageType(packageType);
    let callArgs:Array<any> = [packageName,
        funcName].concat(methodParams);

    let method:Function = jsb.reflection.callStaticMethod; 
    FuncUtils.callFunc(null, method, callArgs);
}
```

* ios调cocos
  * cocos中的函数, 需要是全局的 window['orginCallback'] = orginCallback;
  * cocos中的函数参数, 统一为一个，且为字符串, 在cocos端去解析
  
``` objc
#include "cocos/scripting/js-bindings/jswrapper/SeApi.h"
#import "cocos2d.h"
#import "Utils.h"

using namespace cocos2d;

@implementation Utils

+(NSString*) toNSString:(std::string) str {
    NSString *ret= [NSString stringWithCString:str.c_str() encoding:[NSString defaultCStringEncoding]];
    return ret;
}
+(std::string) toStdString:(NSString*) nsString {
    std::string ret = [nsString UTF8String];
    return ret;
}
+(void) cocosCallback:(NSString *)funcName funcID:(NSString *)funcID strParam:(std::string)strParam {
    std::string strFuncID = [Utils toStdString:funcID];
    std::string strFuncName = [Utils toStdString:funcName];
    std::string jsCallStr = cocos2d::StringUtils::format("%s(\"%s\",\"%s\");", strFuncName.c_str(), strFuncID.c_str(), strParam.c_str());
    se::ScriptEngine::getInstance()->evalString(jsCallStr.c_str() , -1 , NULL, NULL);
}
@end
```



# framework
* input
* loader
* gameStage
* memery
* new version check
* tween
* 自适应
