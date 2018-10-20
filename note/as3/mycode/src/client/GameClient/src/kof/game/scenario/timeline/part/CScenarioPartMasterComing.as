//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/24.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.level.ILevelFacade;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartMasterComing extends CScenarioPartBase {
    public function CScenarioPartMasterComing(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super(partInfo, system);
    }

    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        //显示强敌来袭动画效果
        (_system.stage.getSystem(ILevelFacade) as ILevelFacade).showMasterComingCommon(close);
    }

    private function close():void{
        _actionValue = true;
    }

    public override function end() : void {
        _actionValue = false;
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }
}
}
