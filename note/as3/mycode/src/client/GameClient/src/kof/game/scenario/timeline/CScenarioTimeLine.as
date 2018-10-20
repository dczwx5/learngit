/**
 * Created by auto on 2016/8/4.
 */
package kof.game.scenario.timeline {

import kof.game.common.CDelayCall;
import kof.game.core.CGameObject;
import kof.game.levelCommon.CLevelLog;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.scenario.CScenarioManager;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioInfo;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scenario.info.CScenarioPartTriggerActionInfo;
import kof.game.scenario.scenarioInterface.IScenarioEnd;
import kof.game.scenario.scenarioInterface.IScenarioStart;
import kof.game.scenario.timeline.part.CScenarioPartBase;

public class CScenarioTimeLine implements IUpdatable, IDisposable, IScenarioStart, IScenarioEnd {
    public function CScenarioTimeLine(scenarioMgr:CScenarioManager) {
        _scenarioManager = scenarioMgr;
    }
    public function dispose() : void {
        _scenarioManager = null;
        clear();
    }

    public function clear() : void {
        _basePlayTime = 0;
        _playingPartList = null;
        _unPlayPartList = null;
        _finishPartList = null;
        _readyPartQueue = null;
        _delay = 0;
        _isStart = false;
        _isFinish = false;
        _isWarning = true;
        _delayCallIndex = -1;
        if (_delayCallList) {
            for each (var delayCall:CDelayCall in _delayCallList) {
                delayCall.dispose();
            }
        }
        _delayCallList = null;
    }

    public function start() : void {
        clear();
        _isStart = true;
        _playingPartList = {};
        _finishPartList = {};
        _readyPartQueue = {};
        _unPlayPartList = {};
        _delayCallList = {};
        var scenarioInfo:CScenarioInfo = _scenarioManager.scenarioInfo;
        for each (var partInfo:CScenarioPartInfo in scenarioInfo.parts) {
            if (partInfo.surrender <= 0) {
                _unPlayPartList[partInfo.id] = partInfo;
            }
        }
    }

    public function end() : void {
        clear();
    }
    public function isFinish() : Boolean {
        return _isFinish;
    }

    public function stopPart(partID:int) : void {
        for each (var part:CScenarioPartBase in _playingPartList) {
            if (part.info.id == partID) {
                part.stop();
                return ;
            }
        }

    }
    public function stopAllPart() : void {
        for each (var part:CScenarioPartBase in _playingPartList) {
            part.stop();
        }
        _unPlayPartList = {};
        for each (var delayCall:CDelayCall in _delayCallList) {
            delayCall.dispose();
        }
        _delayCallList = null;
    }

    public function removeDialogOption(info:CScenarioPartInfo):void {
        for each (var partInfo:CScenarioPartInfo in _unPlayPartList) {
            if(partInfo.actorType == info.actorType && partInfo.actorID == info.actorID){
                delete _unPlayPartList[partInfo.id];
            }
        }
    }

    public function update(delta:Number):void {
        if (!_isStart) return ;
        _basePlayTime += delta;

        // 修正时间
        _fixTime();

        // 检测可播放动作
        _checkCanPlayPart();

        // 检测队列里的动作能否开启
        _checkQueuePart();

        // 播放动作
        _updatePart(delta);

        // checkFinish
        if (_isUnPlayPartEmpty() && _isPlayingPartEmpty()) {
            // 完了
            _isFinish = true;
        }
    }

    private function _fixTime() : void {
        var curPlayTime:Number = getCurrentPlayTime();
        var partInfo:CScenarioPartInfo;
        // 修正时间
        var maxDelay:Number = 0;
        var tempSub:Number = 0;
        for each (partInfo in _unPlayPartList) {
            if (partInfo.isStartByTimeLine()) {
                tempSub = curPlayTime - partInfo.start;
                if (tempSub > 0) {
                    if (!(_playingPartList.hasOwnProperty(partInfo.id.toString()))) {
                        maxDelay = Math.max(tempSub, maxDelay);
                    }
                }
            }
        }
        this._delay += maxDelay;
    }
    private function _checkCanPlayPart() : void {
        var curPlayTime:Number = getCurrentPlayTime();
        var partInfo:CScenarioPartInfo;
        // 检测可播放动作
        for each (partInfo in _unPlayPartList) {
            if (partInfo.isStartByTimeLine() && curPlayTime >= partInfo.start) {
                if (!(_playingPartList.hasOwnProperty(partInfo.id.toString()))) {
                    // 不存在才添加
                    _addPartInQueue(partInfo, curPlayTime, 0);
                 }
            }

            if( partInfo.isEvent && curPlayTime > 120 && _isWarning){
                //放呆检测，如果剧情动作由事件触发，但是又没有配置前置的事件，导致剧情不会完成卡住
                CLevelLog.addDebugLog("[CScenarioTimeLine] 警告：该剧情动作是事件触发，但是没配置事件，请检查剧情文件" + partInfo.id);
                _isWarning = false;
            }
        }
    }
    private function _checkQueuePart() : void {
        for  (var key:String in this._readyPartQueue) {
            var datas:Array = _readyPartQueue[key];
            var part:CScenarioPartInfo = datas[0];
            if (part.actorType == EScenarioActorType.MONSTER) {
                var gameObject:CGameObject = _scenarioManager.actorManager.getActor(part.actorID) as CGameObject;
                if (gameObject && gameObject.isRunning) {
                    delete _readyPartQueue[key];
                    this._addPartToPlay(datas[0], datas[1], datas[2]);
                    break; // 每帧只处理一条
                }
            } else {
                delete _readyPartQueue[key];
                this._addPartToPlay(datas[0], datas[1], datas[2]);
                break; // 每帧只处理一条

            }
        }

    }
    private function _updatePart(delta:Number) : void {
        var curPlayTime:Number = getCurrentPlayTime();
        var partInfo:CScenarioPartInfo;
        for each (var playingPart:CScenarioPartBase in _playingPartList) {
            playingPart.update(delta);
            var isFinish:Boolean = false;
            if (playingPart.info.isDurationByTimeLine()) {
                if (curPlayTime >= playingPart.startTime + playingPart.info.duration) {
                    isFinish = true;
                }
            } else if (playingPart.isActionFinish()) {
                isFinish = true;
            }

            // 动作播放完了
            if (isFinish || playingPart.isStop()) {
                playingPart.end();
                _checkDialog(playingPart);//每次动作播放完成之后，检测对话动作是否全部播放完成

                if (playingPart.info.hasTriggerEvent()) {
                    for each (var action:Object in playingPart.info.triggerAction) {
                        // 假设有一个ID字段
                        partInfo = _unPlayPartList[action.id];
                        if (partInfo) {
                            _addPartInQueue(partInfo, curPlayTime, action.delay);
                        } else {
                            CLevelLog.addDebugLog("[CScenarioTimeLine] scenario : can not find part , PartId : " + action.id, true);
                        }
                    }
                }
                delete _playingPartList[playingPart.info.id];
                _finishPartList[playingPart.info.id] = playingPart.info;
            }
        }
    }

    private function _checkDialog( partInfo:CScenarioPartBase ) : Boolean
    {
        if( partInfo.info.actorType != EScenarioActorType.DIALOG ) return false;
        var partType:int = 0;
        if ( partInfo.info.hasTriggerEvent() ) {
            for each (var trigger:CScenarioPartTriggerActionInfo in partInfo.info.triggerAction) {
                partType = _scenarioManager.scenarioInfo.getPartTypeById( trigger.id );
                if(partType == EScenarioPartType.DIALOG_PLAY){
                    //如果还有对话
                    return true;
                }
            }
        }

        if(partInfo.info.type != EScenarioPartType.DIALOG_BUBBLES){
            partInfo.stop();
        }
        return false;
    }

    private function _addPartInQueue(partInfo:CScenarioPartInfo, startTime:Number, delay:Number) : void {
        this._readyPartQueue[partInfo.id] = [partInfo, startTime, delay];
        this._checkQueuePart();
    }
    private function _addPartToPlay(partInfo:CScenarioPartInfo, startTime:Number, delay:Number) : void {
        startTime = startTime+delay;
        if (delay > 0) {
            _delayCallIndex++;
            var levelDelayCall:CDelayCall = new CDelayCall(_addPartToPlayB, delay, [partInfo, startTime, delay, _delayCallIndex]);
            _delayCallList[_delayCallIndex] = levelDelayCall;
        } else {
            _addPartToPlayB(partInfo, startTime, delay);
        }

    }
    private function _addPartToPlayB(partInfo:CScenarioPartInfo, startTime:Number, delay:Number, delayCallIndex:int = -1) : void {
        if (_isFinish) return ;
        if (-1 != delayCallIndex) {
            delete _delayCallList[delayCallIndex];
        }

        CLevelLog.addDebugLog("scenario : start part, partType : " + partInfo.type + ", id : " + partInfo.id + "startTime : " + startTime);
        var part:CScenarioPartBase = CScenarioPartCreater.createPart(partInfo, _scenarioManager.system);
        _playingPartList[partInfo.id] = part;
        part.start();
        part.startTime = startTime;
        delete _unPlayPartList[partInfo.id];
    }
    private function getCurrentPlayTime() : Number {
        return _delay + _basePlayTime;
    }
    private function _isUnPlayPartEmpty() : Boolean {
        return _isListEmpty(_unPlayPartList);
    }
    private function _isPlayingPartEmpty() : Boolean {
        return _isListEmpty(_playingPartList);
    }
    private function _isEndPartEmpty() : Boolean {
        return _isListEmpty(_finishPartList);

    }
    private function _isListEmpty(list:Object) : Boolean {
        for (var key:String in list) {
            return false;
        }
        return true;
    }


    private var _scenarioManager:CScenarioManager;
    private var _basePlayTime:Number;
    private var _delay:Number;
    private var _unPlayPartList:Object;
    private var _playingPartList:Object;
    private var _finishPartList:Object;
    private var _readyPartQueue:Object; // 不能直接开启的part, 会在每次update检测能否开启

    private var _isStart:Boolean;
    private var _isFinish:Boolean;

    private var _delayCallList:Object; // 不能用数组. 一键退出时, delay会有问题. 因此在一键退出时, 应将当前delaycall全停掉
    private var _delayCallIndex:int;

    private var _isWarning:Boolean = true;

}
}
