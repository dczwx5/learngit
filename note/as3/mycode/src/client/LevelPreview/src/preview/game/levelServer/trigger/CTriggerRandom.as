/**
 * Created by auto on 2016/5/24.
 * 用于服务器 刷怪区域
 */
package preview.game.levelServer.trigger {

import QFLib.Math.CMath;

import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkEntityTriggerRandom;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import preview.game.levelServer.CLevelServer;

public class CTriggerRandom extends AbsLevelServerTrigger {
    public function CTriggerRandom(server:CLevelServer, trunkInfo:CTrunkConfigInfo, trunkEntity:CTrunkEntityBaseData) {
        super(server, trunkInfo, trunkEntity, 1);
        _lastEventIndex = -1;
    }
    public override function dispose() : void {
        super.dispose();
        _lastEventIndex = -1;
        _unuseEventList = null;
        this._canuseEventList = null;

    }
    protected override function _onTrigger() : void {
        var triggerEvents:Array = _entity.triggerEvents;
        if (triggerEvents != null && triggerEvents.length > 0) {
            var randomFun:Function = null;
            if (_entity.randomType == EAutoTriggerRandomType.TYPE_NORMAL) {
                // 普通随机
                randomFun = _randomNormal;
            } else if (_entity.randomType == EAutoTriggerRandomType.TYPE_WEIGHT){
                // 权重随机
                randomFun = _randomWeight;
            }
            // 完全随机
            switch (_entity.randomAttribute) {
                case EAutoTriggerRandomAtrribute.RANDOM_NORMAL:
                    var index:int = randomFun(triggerEvents);
                    _server.serverEnventManager.pushEventInQueue(_trunkInfo.ID, triggerEvents[index]);
                    break;
                case EAutoTriggerRandomAtrribute.RANDOM_NO_REPEAT:
                    if (_unuseEventList == null || _unuseEventList.length == 0) {
                        _resetUnuseEventList();
                    }
                    var indexTemp:int = randomFun(_unuseEventList);
                    index = _unuseEventList[indexTemp];
                    _unuseEventList.removeAt(indexTemp);
                    _server.serverEnventManager.pushEventInQueue(_trunkInfo.ID, triggerEvents[index]);
                    break;
                case EAutoTriggerRandomAtrribute.RANDOM_DIFF_LAST:
                    this._resetCanuseEventList();
                    _lastEventIndex = randomFun(_canuseEventList);
                    _server.serverEnventManager.pushEventInQueue(_trunkInfo.ID, triggerEvents[_lastEventIndex]);
                    break;
            }
        }
    }

    // 随机方式
    private function _randomNormal(list:Array) : int {
        return CMath.rand() * list.length;
    }
    // 随机方式
    private function _randomWeight(list:Array) : int {
        var total:int = 0;
        for each (var event:CSceneEventInfo in list) {
            total += event.weight;
        }

        var randValue:int = CMath.rand() * (total) + 1;
        var sceneEvent:CSceneEventInfo;
        var curValue:int = 0;
        for (var i:int = 0; i < list.length; i++) {
            sceneEvent = list[i];
            curValue += sceneEvent.weight;
            if (curValue >= randValue) {
                return i;
            }
        }
        return list.length-1;
    }

    private function _resetUnuseEventList() : void {
        _unuseEventList = new Array(_entity.triggerEvents.length);
        for (var i:int = 0; i < _entity.triggerEvents.length; i++) {
            _unuseEventList[i] = i;
        }
    }
    private function _resetCanuseEventList() : void {
        _canuseEventList = new Array();
        for (var i:int = 0; i < _entity.triggerEvents.length; i++) {
            if (_lastEventIndex != i) {
                _canuseEventList.push(i);
            }
        }
    }

    private function get _entity() : CTrunkEntityTriggerRandom {
        return _trunkEntityInfo as CTrunkEntityTriggerRandom;
    }

    private var _unuseEventList:Array; // 未被随机的索引列表, 为了实现每次随机不重复
    private var _lastEventIndex:int; // 上一次随机到的索引
    private var _canuseEventList:Array; // 可以使用的随机索引列表, 为了实现上一次不重复
}
}

class EAutoTriggerRandomType {
    public static const TYPE_NORMAL:int = 0; // 完全随机
    public static const TYPE_WEIGHT:int = 1; // 权重随机
}
class EAutoTriggerRandomAtrribute {
    public static const RANDOM_NORMAL:int = 0; // 无
    public static const RANDOM_NO_REPEAT:int = 1; // 每次随机不重复
    public static const RANDOM_DIFF_LAST:int = 2; // 不重复上一次

}
