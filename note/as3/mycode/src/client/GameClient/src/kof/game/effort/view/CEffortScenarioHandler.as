//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import kof.framework.CViewHandler;
import kof.game.effort.data.CEffortConst;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortOverviewUI;
import kof.ui.master.welfareHall.RechargeWelfareUI;

/**
 * 成就系统--剧情
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortScenarioHandler extends CEffortPanelBase {

    public function CEffortScenarioHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }



    protected override function _initView():void
    {
        super._initView();
    }

    protected override function get _categorizeType():int
    {
        return CEffortConst.SCENARIO;
    }


}
}
