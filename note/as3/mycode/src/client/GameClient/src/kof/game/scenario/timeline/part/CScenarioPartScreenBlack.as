//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/2/28.
 */
package kof.game.scenario.timeline.part {
import flash.utils.getTimer;

import kof.framework.CAppSystem;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.CScenarioViewHandler;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartScreenBlack extends CScenarioPartActorBase {
    public function CScenarioPartScreenBlack(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super(partInfo, system);
    }

    override public virtual function dispose() : void {
        _actionValue = false;
    }

    override public virtual function start() : void {
        if(_info.params == null){
            CLevelLog.addDebugLog("[CScenarioPartScreenBlack] info params is null");
            return;
        }
        if(_info.params.hasOwnProperty("showTime")){
            var duratiomTime:Number = _info.params["showTime"];
            (_system.getBean(CScenarioViewHandler) as CScenarioViewHandler).showMaskView(_endBlackFinish,null,null,duratiomTime,0x000000);
        }
    }

    private function _endBlackFinish() : void {
        _actionValue = true;
    }

    override public virtual function update(delta:Number):void {
        super.update(delta);
    }

    override public virtual function end() : void {
        _actionValue = false;
    }

    override public virtual function isActionFinish() : Boolean {
        return _actionValue;
    }
}
}
