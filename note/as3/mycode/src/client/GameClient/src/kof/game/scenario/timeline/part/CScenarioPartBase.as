/**
 * Created by auto on 2016/8/4.
 */
package kof.game.scenario.timeline.part {
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.framework.CAppSystem;
import kof.game.common.CTest;
import kof.game.core.CECSLoop;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.CScenarioManager;
import kof.game.scenario.CScenarioSystem;

import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scenario.scenarioInterface.IScenarioEnd;
import kof.game.scenario.scenarioInterface.IScenarioIsFinish;
import kof.game.scenario.scenarioInterface.IScenarioStart;
import kof.game.scenario.scenarioInterface.IScenarioStop;
import kof.game.scene.CSceneSystem;

public class CScenarioPartBase implements IScenarioStart, IScenarioEnd, IScenarioIsFinish, IUpdatable, IDisposable, IScenarioStop {
    public function CScenarioPartBase(partInfo:CScenarioPartInfo, system:CAppSystem) {
        _info = partInfo;
        _system = system;
    }

    public virtual function dispose() : void {
        throw new Error("need override CScenarioPartBase.dispose");
    }
    public virtual function update(delta:Number) : void {
        _curTime += delta;
        if(_curTime > TIME_OUT){
            _actionValue = true;
            CTest.log("[CScenarioPartBase] 该动作播放超过20秒" + _info.id + "  type:" +_info.type +
                    "  actorID:"+_info.actorID + "  actorType:" +_info.actorType);
        }
    }

    public virtual function start() : void {
        throw new Error("need override CScenarioPartBase.start");
    }
    public virtual function end() : void {
        throw new Error("need override CScenarioPartBase.end");
    }
    public virtual function isActionFinish() : Boolean {
        throw new Error("need override CScenarioPartBase.isFinish");
        return false;
    }
    public function get info() : CScenarioPartInfo {
        return _info;
    }
    public function get startTime() : Number {
        return _startTime;
    }
    public function set startTime(v:Number) : void {
        _startTime = v;
        _curTime = 0.0;
    }

    public function get partType() : int {
        return _info.type;
    }

    public function getActor() : Object {
        var ret:Object = _scenarioManager.actorManager.getActor(_info.actorID);
//        if (ret == null) {
//            _scenarioManager.actorManager.createActor(_info);
//        }
//        ret = _scenarioManager.actorManager.getActor(_info.actorID);
        return ret;
    }
    protected function get _gameSystem() : CECSLoop {
        return _system.stage.getSystem(CECSLoop) as CECSLoop;
    }
    protected function get _sceneSystem() : CSceneSystem {
        return _system.stage.getSystem(CSceneSystem) as CSceneSystem;
    }
    protected function get _scenarioSystem() : CScenarioSystem {
        return _system.stage.getSystem(CScenarioSystem) as CScenarioSystem;
    }
    protected function get _scenarioManager() : CScenarioManager {
        return _scenarioSystem.getBean(CScenarioManager) as CScenarioManager;
    }
    public function stop() : void {
        _forceStop = true;
    }
    public function isStop() : Boolean {
        return _forceStop;
    }

    protected var _info:CScenarioPartInfo;
    protected var _system:CAppSystem;
    private var _startTime:Number; // 开始播放动作时间,

    protected var _actionValue:Boolean; // 供上层使用的一个变量, 想用来干嘛都行

    private var _forceStop:Boolean; // 强制停止

    protected var _curTime:Number;
    public static const TIME_OUT:Number = 20.0;

}
}
