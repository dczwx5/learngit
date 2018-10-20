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
import kof.game.welfarehall.view.CWelfareHallViewHandler;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortHallUI;
import kof.ui.master.effortHall.EffortOverviewUI;
import kof.ui.master.welfareHall.RechargeWelfareUI;
import kof.ui.master.welfareHall.UpdateNoticeUI;

/**
 * 成就系统--战斗
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortFightHandler extends CEffortPanelBase {

    public function CEffortFightHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }



    protected override function _initView():void
    {
        super._initView();
    }

    protected override function get _categorizeType():int
    {
        return CEffortConst.FIGHT;
    }


}
}
