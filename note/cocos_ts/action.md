# action
动作列表 : http://docs.cocos.com/creator/manual/zh/scripting/action-list.html

let moveInAct = cc.moveTo(0.5, 500, 500);
let stayAct = cc.delayTime(1);
let moveOutAct = cc.moveTo(0.5, 1000, 500);

let fadeInAct = cc.fadeIn(0.5);
let fadeOutAct = cc.fadeOut(0.5);

let removeAct = cc.removeSelf();

let inSpawn = cc.spawn(moveInAct, fadeInAct);
let outSpawn = cc.spawn(moveOutAct,  fadeOutAct);
let seq = cc.sequence(inSpawn, stayAct, outSpawn, removeAct);
node.runAction(seq);
## 基础动作
```js
形变，位移
// 移动节点
var action = cc.moveTo(2, 100, 100);
// 旋转节点
cc.rotateBy;
// 缩放节点
cc.scaleTo
```
```js
时间间隔动作 - 在一定时间内完成的渐变动作
继承于 cc.ActionInterval
```
```js
即时动作 - 立即发生的动作 - isDone一开始就是true
继承于cc.ActionInstant
```
## 容器动作
容器动作可以将动作组织起来

```js
let act1 = cc.moveBy(0.5, 200, 0);
let act2 = cc.moveBy(0.5, -200, 0);
```
```js
顺序动作 - 顺序动作可以让一系列的子动作按顺序一个个执行
var seq = cc.sequence(act1, act2);
node.runAction(seq);
```
```js
同步动作 - 同步执行一系列子动作，子动作的执行结果会叠加起来
动作同时进行
var spawn = cc.spawn(act1, act2);
node.runAction(spawn);
```
```js
重复动作 - 多次重复一个动作
var seq = cc.sequence(act1, act2);
var repeat = cc.repeat(seq, 5);
node.runAction(seq);
```
```js
永远重复动作 - 一直重复，直到手动停止
var seq = cc.sequence(act1, act2);
var repeat = cc.repeatForever(seq);
node.runAction(seq);
```
```js
速度动作 - 加速或减速动作
// 假如act1执行完成是 5秒， 下面使用执行完成时间变成 2.5秒
let spawn = cc.spawn(act1, act2);
let speed = cc.speed(spawn, 2); // 2倍速度执行动作
node.runAction(speed);
```
## 即时动作
```js
函数执行完，动作完成
注意: 在 cc.callFunc 中不应该停止自身动作，由于动作是不能被立即删除，如果在动作回调中暂停自身动作会引发一系列遍历问题，导致更严重的 bug。

export function callFunc(selector: Function, selectorTarget?: any, data?: any): ActionInstant;	
let func = (caller:any, params)=>{
	
};
let funcAction = cc.callFunc(func, this, 'aaa');
node.runAction(funcAction);
```
## 缓动动作
缓动动作不可以单独存在，它永远是为了修饰基础动作而存在的，它可以用来修改基础动作的时间曲线，让动作有快入、缓入、快出或其它更复杂的特效。需要注意的是，只有时间间隔动作才支持缓动：

```js
var act = cc.scaleTo(0.5, 2, 2);
action.easing(cc.easeIn(3));
```
## run/stop
```js
node.runActioin(action);
node.stopAction(action);
node.stopAllActions();
```
## 链式调用
```js 
动作对象可通过 repeat/repeatForver/speed 三个API实现链式调用
let seq = cc.sequence(act1, act2);
let repeat = seq.repeat(3);
let speed = repeat.speed(2);

// 同下面
let seq = cc.sequence(act1, act2);
let repeat = cc.repeat(seq, 3);
let speed = cc.speed(repeat, 2);
```
## tag
```js
node.setTag(1);
node.getActionByTag(1);
node.stopActionByTag(1);
```

# ActionManager
```js
cc.ActionManager 是可以管理动作的单例类。
通常你并不需要直接使用这个类，99%的情况您将使用 CCNode 的接口。
但也有一些情况下，您可能需要使用这个类。 
例如：
当你想要运行一个动作，但目标不是 CCNode 类型时。 
当你想要暂停/恢复动作时。 

```

```js
addAction 增加一个动作，同时还需要提供动作的目标对象，目标对象是否暂停作为参数。
removeAllActions 移除所有对象的所有动作。
removeAllActionsFromTarget 移除指定对象上的所有动作。
removeAction 移除指定的动作。
removeActionByTag 删除指定对象下特定标签的一个动作，将删除首个匹配到的动作。
getActionByTag 通过目标对象和标签获取一个动作。
getNumberOfRunningActionsInTarget 返回指定对象下所有正在运行的动作数量。
pauseTarget 暂停指定对象：所有正在运行的动作和新添加的动作都将会暂停。
resumeTarget 让指定目标恢复运行。
pauseAllRunningActions 暂停所有正在运行的动作，返回一个包含了那些动作被暂停了的目标对象的列表。
resumeTargets 让一组指定对象恢复运行（用来逆转 pauseAllRunningActions 效果的便捷函数）。
pauseTargets 暂停一组指定对象。
purgeSharedManager 清除共用的动作管理器。
update ActionManager 主循环。
```