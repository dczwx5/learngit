/**
 * Created by auto on 2016/7/15.
 */
package kof.game.scenario {

import QFLib.Interface.IUpdatable;

import kof.BIND_SYSTEM_ID;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;

import kof.game.common.system.CAppSystemImp;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.lobby.CLobbySystem;
import kof.game.scenario.event.CScenarioEvent;

public class CScenarioSystem extends CAppSystemImp implements IUpdatable, IScenarioSystem {
    public function CScenarioSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.SCENARIO);
    }
    public override function dispose() : void {
        super.dispose();
    }
    // ====================================================================
    override public function initialize():Boolean {
        BIND_SYSTEM_ID(KOFSysTags.SCENARIO, -5);
        var ret:Boolean = super.initialize();
        if (ret) {
            ret = ret && this.addBean(_scenarioManager = new CScenarioManager());
            ret = ret && this.addBean(new CScenarioViewHandler());
            ret = ret && this.addBean(new CSCenarioBubblesViewHandler());
            ret = ret && this.addBean(new CScenarioPlaySkillViewHandler());
            ret = ret && this.addBean(new CEscViewHandler());
            ret = ret && this.addBean(new CScenarioLoadingViewHandler2());

            this.registerEventType(CScenarioEvent.EVENT_SCENARIO_ENTER);
            this.registerEventType(CScenarioEvent.EVENT_SCENARIO_START);
            this.registerEventType(CScenarioEvent.EVENT_SCENARIO_END);
            this.registerEventType(CScenarioEvent.EVENT_SCENARIO_END_B);
            this.registerEventType(CScenarioEvent.EVENT_SCENARIO_END_C);


        }
        return ret;
    }

    public function update(delta:Number):void {
        if (_scenarioManager) _scenarioManager.update(delta);
    }

    public function dispatchScenarioUpdate(type:String, scenarioID:int = 0, controlType:int = 0, isFail:Boolean = false, returnLevel:Boolean = true) : void {
        this.dispatchEvent(new CScenarioEvent(type, scenarioID, controlType, isFail, returnLevel));
    }

    // ==============================interface======================================
    // 关卡的开场剧情ID
    public function playScenario(scenarioID:int, controlType:int,scenarioOverCallback:Function,isShowStartMask:Boolean = true,isShowEndMask:Boolean = true, levelStartScenarioID:int = -1) : void {
//        var pInstanceSys:IInstanceFacade = stage.getSystem(IInstanceFacade) as IInstanceFacade;
        _scenarioManager.enterScenario(scenarioID, controlType, scenarioOverCallback,isShowStartMask,isShowEndMask, levelStartScenarioID);

    }

    public function stopScenario() : void {
        if( _scenarioManager ){
            _scenarioManager.stopAllPart();
        }
    }

    [Inline]
    public function get isAllStop() : Boolean {
        return !isPlaying; // _scenarioManager.isAllStop;
    }
    [Inline]
    public function get isEndB() : Boolean {
        return _scenarioManager.isEndB;
    }
    [Inline]
    public function get isPlaying() : Boolean {
        return _scenarioManager.isStart;
    }
    private var _scenarioManager:CScenarioManager;

    public function setPlayEnable(v:Boolean) : void {
        if (_playEnableHandler != null) {
            _playEnableHandler(v);
        }
    }
    public function setAIEnable(v:Boolean) : void {
        if (_aiEnableHandler != null) {
            _aiEnableHandler(v);
        }
    }

    public function set playEnableHandler(v:Function) : void {
        _playEnableHandler = v;
    }
    public function set aiEnableHandler(v:Function) : void {
        _aiEnableHandler = v;
    }
    private var _playEnableHandler:Function;
    private var _aiEnableHandler:Function;
}
}