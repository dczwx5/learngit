/**
 * Created by auto on 2016/9/12.
 */
package preview.game.levelServer.trigger {
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;


import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import kof.game.levelCommon.Interface.ITriggerIsEnd;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.base.CTrunkTriggerData;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import kof.game.levelCommon.CLevelLog;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleBase;

// override _onStartTrigger, _onActive, _onTrigger, _onCompleted
// server trigger
// active -> test -> isPass -> trigger -> isEnd -> completed -> dispose
// (trigger && active && completed) will trigger events -> (triggerEvents && activeEvents && completeEvents)
public class AbsLevelTriggerBase implements  IUpdatable, ITriggerIsEnd, IDisposable {
    public function AbsLevelTriggerBase(trunkInfo:CTrunkConfigInfo, trunkEntityInfo:CTrunkEntityBaseData, handleConditionRate:int) {
        _handlerList = new Object();

        _trunkEntityInfo = trunkEntityInfo;
        _trunkInfo = trunkInfo;
        _limit = trunkEntityInfo.limit;
        if (_limit == 0) _limit = -1;
        _state = _NONE;
        _startTime = -1;
        _startConditionTime = -1;
        _frameCount = 0;
        _isFirst = true;
        _limitStratTime = 0;

        _handleConditionRate = handleConditionRate;
        if (_handleConditionRate < 1) _handleConditionRate = 1;

        CLevelLog.Log(getQualifiedClassName(this) + " create.");
        _active();
    }

    // 目前只有随机触发器用到了
    public function reset() : void {
        _limit = _trunkEntityInfo.limit;
        if (_limit == 0) _limit = -1;
        _state = _NONE;
        _startConditionTime = -1;
        _startTime = -1;
        _frameCount = 0;
        _isFirst = true;
        _limitStratTime = 0;

        CLevelLog.Log(getQualifiedClassName(this) + " Reset.");
        _active();
    }

    public function dispose() : void {
        _trunkEntityInfo = null;
        _trunkInfo = null;
        _state = _NONE;
        _limit = 0;
        _startConditionTime = -1;
        _startTime = -1;
        _frameCount = 0;
        _isFirst = true;
        _limitStratTime = 0;

        for each (var handler:CTriggerCondHandleBase in _handlerList) {
            handler.dispose();
        }
        _handlerList = null;
    }

    // ================================================================================
    final public function isEnd() : Boolean {
        return (_state == _FINISH);
    }

    final public function update(delta:Number) : void {
        if (_state != _RUNNING) return ;

        _frameCount++;
        if (_handleConditionRate > 1){
            if (_handleConditionRate > _frameCount) {
                return;
            } else {
                _frameCount = 0;
            }
        }

        if (_hasTriggerCount()) {
            if (!_isFirst && (getTimer() - _limitStratTime) < triggerData.limitInterval*1000) {
                return;
            }
            test();
            if (_isPass() || (triggerData.executeImmediately && _isFirst)) {
                _trigger();
                _limitStratTime = getTimer();
                _isFirst = false;
                if (_hasTriggerCount()) {
                    _startTrigger(triggerData.limitInterval*1000);
                    _buildCondition();
                }
            }
        } else {
            _complete();
        }
    }

    private function test() : void {
        var passList:Array = new Array();
        for (var index:int = 0; index < _conditionMap.length; index++) {
            var condList:Array = this._conditionMap[index];
            for each (var cond:CTrunkConditionInfo in condList) {
                if (_checkCondition(cond)) {
                    passList.push({"group":index, "cond":cond});
                }
            }

        }
        _setPassCondition(passList);
    }

    private function _checkCondition(cond:CTrunkConditionInfo) : Boolean {
        if (cond.delay > 0) { // 条件delay判断
            if (getTimer() - _startTime < cond.delay * 1000) {
                return false;
            } else {
                _startConditionTime = getTimer();
            }
        }
        if (_handlerList.hasOwnProperty(cond.name) == false) {
            CLevelLog.addDebugLog(getQualifiedClassName(this) + " condition name : error " + cond.name, true);
            return false;
        }
        return (_handlerList[cond.name] as CTriggerCondHandleBase).handler(cond,triggerData.triggerFilter);
    }

    protected function addHandler(key:String, handlerClass:Class) : void {
        if (key == null || key.length == 0) { CLevelLog.addDebugLog(getQualifiedClassName(this) + ".addHandler : key is empty...", true); }
        if (handlerClass == null) { CLevelLog.addDebugLog(getQualifiedClassName(this) + ".addHandler : class is null...", true); }
        if (_handlerList.hasOwnProperty(key)) {
            CLevelLog.addDebugLog(getQualifiedClassName(this) + ".addHandler : key exist..." + key, true);
        }
        _handlerList[key] = new handlerClass(this);
    }
    // =================================================================================

    private function _active() : void {
        if (_state != _NONE) return ;
        _state = _RUNNING;
        _startTrigger(0);
        _buildCondition();
        _onActive();
    }
    // override to handler other event
    protected virtual function _onActive() : void {
    }
    private function _startTrigger(time:int) : void {
        _startTime = _startConditionTime = getTimer() + time;

        _frameCount = 0;
        _onStartTrigger();
    }
    protected virtual function _onStartTrigger() : void {
        // override , 每次触发器开始一次条件处理时调用
    }
    private function _trigger() : void {
        if (_state != _RUNNING) return ;
        if (_limit > 0) _limit--;
        _onTrigger();
    }
    // override to handler other event
    protected virtual function _onTrigger() : void {
    }

    private function _complete() : void {
        if (_state != _RUNNING) return ;
        _state = _FINISH;
        _onCompleted();
    }
    // override
    protected virtual function _onCompleted() : void {
    }

    // ==================================condition=====================================
    // 子类条件通过的, 需要调用该方法, 传入已完成的数组
    private function _setPassCondition(passList:Array) : void {
        if (passList == null || passList.length == 0) return ;
        for each (var data:Object in passList) {
            var cond:CTrunkConditionInfo = data["cond"];
            var group:int = data["group"];
            var condLilst:Array = (_conditionMap[group] as Array);
            var index:int = condLilst.indexOf(cond);
            if (index != -1) condLilst.splice(index, 1);
        }
    }
    private function _buildCondition() : void {
        _conditionMap = new Array();
        var conditionsList:Array = triggerData.conditions;
        for (var i:int = 0; i < conditionsList.length; i++) {
            var condList:Array = conditionsList[i];
            _conditionMap.push(new Array());
            for each (var condInfo:CTrunkConditionInfo in condList) {
                _conditionMap[i].push(condInfo);
            }
        }
    }
    private function _isPass() : Boolean {
        if (_conditionMap == null) return true;
        var hasData:Boolean = false;
        var condList:Array;
        for each (condList in _conditionMap) {
            hasData = true;
            break;
        }
        if (!hasData) return true; // 无数据, 则为无条件通过
        for each (condList in _conditionMap) {
            if (condList.length == 0) return true; // 某一个组的条件全达到了,则该组长度为0
        }
        return false;
    }

    // ======================================================================================

    private function _hasTriggerCount() : Boolean {
        // -1 is InFinty, zero is none count , other is leftCount;
        if (_limit == 0) return false;
        return true;
    }
    public function get triggerData() : CTrunkTriggerData {
        return this._trunkEntityInfo as CTrunkTriggerData;
    }
    final public function get trunkInfo() : CTrunkConfigInfo {
        return this._trunkInfo;
    }
    final public function get entityInfo() : CTrunkEntityBaseData {
        return _trunkEntityInfo;
    }
    final public function get startTime() : int {
        return this._startTime;
    }
    final public function get startConditionTime() : int {
        return this._startConditionTime;
    }
    final public function get limit() : int {
        return _limit;
    }

    // ======================================================================================

    protected var _trunkEntityInfo:CTrunkEntityBaseData; // 当前触发器的entity信息
    protected var _trunkInfo:CTrunkConfigInfo; // trunk数据

    private var _limit:int; // 剩余次数
    private var _state:int; // 触发器状态

    private const _NONE:int = 0;
    private const _RUNNING:int = 1;
    private const _FINISH:int = 2;

    // 条件map, 只要有一个组里所有的条件完成了，就算完成. 条件完成, 则会将元素删除, 即一个组里, 如果条件列表长度是0，则为完成
    private var _conditionMap:Array;

    private var _handlerList:Object;

    private var _startTime:int; // 每次trigger开始时的时间.用于类似定时器触发器
    private var _startConditionTime:int; //
    private var _handleConditionRate:int; // 执行条件的频率, N帧执行一次condition判断
    private var _frameCount:int; // 执行帧数

    private var _isFirst:Boolean = true;//是否第一次执行
    private var _limitStratTime:int;//间隔开始时间
}
}
