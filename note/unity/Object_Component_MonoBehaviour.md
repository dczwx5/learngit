---
title: Object, Component, MonoBehaviour
grammar_cjkRuby: true
grammar_flow: true
---

## UnityEngine.Object
* c#脚本最基本的类
* Unity3D中所有对象的基类
* 派生自UnityEngine.Object类的public变量会被显示在监视器(inspector)视窗
* 类成员
	* hideFlags : 标识对象是否被隐藏
	* name : 对象名
	* GetInstanceID : 实例ID
	* ToString : 返回对象名称
	* Destroy : 销毁一个游戏对象, 组件或资源
	* DestroyImmediate : 立即销毁一个游戏对象(不推荐)
	* DontDestroyOnLoad : 在切换场景时目标对象不会被销毁
	* FindObjectOfType : 查找第一个目标类型对象
	* FindObjectsOfType : 类FindObjectOfType, 返回一个列表
	* Instantiate : 复制原始对象
```csharp
GameObject testItem;
GameObject obj = UnityEngine.Object.Instantiate(testItem) as GameObject;
UnityEngine.Object.Destroy(obj);
```

## UnityEngine.Component
* 继承 UnityEngine.Object
* 组件基类
* 需要添加到GameObject中
* 成员
	* gameObject : 组件所在的游戏对象
	* tag : 游戏对象的标签
	* transform : 添加对gameObject上的Transform组件
	* BroadcastMessage : 调用组件所在的gameObject以及其子对象所有MonoBehaviour中定义叫作methodName的方法(methodName是传以的参数)
	* CompareTag : gameObject是否被标签标记
	* GetComponent : 获取gameObject的组件对象
	* GetComponentInChildren : 获取gameObject以及子对象上的组件
	* GetComponentInParent : 获取gameObject以及父对象上的组件
	* GetComponents
	* GetComponentsInChildren 
	* GetComponentsInParent 
	* SendMessage : 调用gameObject所有MonoBehaviour以及其基类中名为methodName的方法(与BroadcastMessage对比, SendMessage只调用gameObject上的MonoBehaviour的方法, 而BroadcaseMessage会调用子对象的)
```csharp
// GetComponent
public HingeJoint[] joints;
joints = GetComponents<HingeJoint>(); // 性能up
joints = GetComponents(typeof(HingeJoint));
// BroadcaseMessage
public class KK : MonoBehaviour {
	void TestFunction(int value) {
		print(value);
	}
	void example() {
		BroadcaseMessage("TestFunction", 100);
	}
	// result : print 100;
}
```

## UnityEngine.MonoBehaviour
* 所有脚本都继承自UnityEngine.MonoBehaviour
* 继承 UnityEngine.Behaiour
* MonoBehaviour是一个可以启用或禁用的组件
* MonoBehaviour类型对象无法使用new实例化
```csharp
public class A: MonoBehaviour { }
public class Test : MonoBehaviour {
	void Start(){
		A a = gameObject.AddComponent<A>();
	}
}
```
* 成员
	*属性
		* enabled : 启用状态下, 会执行每帧更新
		* isActiveAndEnabled : Behaviour是否启用
	* 方法	
		* CancelInvoke : 取消所有当前MonoBehaviour所调用的方法
		* Invoke : 在指定时间内调用指定方法
		* InvokeRepeaing : 在指定时间内调用指定方法, 之后间隔指定时间重复调用
		* IsInVoking : 指定方法是否正等待被调用
		* StartCoroutine : 开启一个协程
		* StopAllCoroutines : 停止所有协程
		* StopCoroutine : 停止一个协程
	* 消息
		* Awake : 脚本被加载时, 触发Awake
		* Start : Awake之后, 第一次Update之前调用
		* Update : 当脚本处于enabled状态, 每帧调用一次
		* LateUpdate : 当脚本处于enabled状态, 在所有Update调用后调用
		* FixedUpate : 当脚本处于enabled状态, 间隔指定的帧率调用
		* OnBecameInvisible : 指定渲染器无法被任务的camera视为可见状态时, 调用
		* OnBecameVisble : 与OnBecameInvisible相反
		* OnCollisionEnter : 当刚体开始碰到另一个刚体时, 调用
		* OnCollisionExit : ...结束触碰时调用
		* OnCollisionStay : ...正在触碰时, 每帧都会调用
		* OnDestroy : MonoBehaviour即针被销毁时调用
		* OnDisable : 当MonoBehaviour状态变为disabled or inactive时, 调用
		* OnEnable : 与OnDisable相反
		* OnGUI : 处理渲染和GUI事件
		* OnLevelWasLoaded : 新关卡被载入时, 调用
		* 鼠标
			* OnMouseDown
			* OnMouseDrag
			* OnMouseEnter
			* OnMouseExit
			* OnMouseOver
			* OnMouseUp
			* OnMouseUpAsButton
		* trigger
			* OnTriggerEnter
			* OnTriggerExit
			* OnTriggerStay
	
		*Reset : 重置为默认值
* 流程
	* Reset : 当脚本第一次添加到游戏对象或当执行Reset命令时调用, 用于初始化脚本的各个属性	
	* Awaek : Start前调用, 实例化后就调用(在Start和Upate前调用)
	* OnEnable : 对象激化状态下, 场景加载or脚本实例化后调用(由disable变为enable应该也会调用)(在Start和Upate前调用)
	* Start : Awake之后, Update之前调用
	* OnApplicationPause : 检测到暂停状态时, 会在帧结束之后调用(并非一定触发)
	* FixedUpdate : 按固定时间调用, 调次频率不一定比Update高也不一定比Update低
	* Update : 每帧调用
	* LateUpdate : Update之后调用
```flow
st=>start: 脚本添加到游戏对象
reset=>operation: Reset
behaviourInstance=>operation: 脚本第一次加载, prefab实例化后
awake=>operation: Awake
onEnable=>operation: OnEnable 
start=>operation: Start  
frameBegin=>operation: 帧开始
frameUpdate=>operation: Update
frameLateUpdate=>operation: LateUpdate
frameFixedUpdate=>operation: FixedUpdate
frameEnd=>operation: 帧结束
onApplicaitionPause=>operation: OnApplicationPause 
condRemove=>condition: 游戏对象删除或脚本删除或停止?
e=>end: 结束
st->reset->behaviourInstance->awake->onEnable->start->frameBegin->frameUpdate->frameLateUpdate->frameFixedUpdate->frameEnd->onApplicaitionPause->condRemove
condRemove(yes)->e
condRemove(no)->frameBegin
```




