//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import kof.framework.CAppSystem;
import kof.game.effort.data.CEffortConst;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortOverviewUI;
import kof.ui.master.welfareHall.RechargeWelfareUI;

/**
 * 成就系统--豪气
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortConsumeHandler extends CEffortPanelBase {

    public function CEffortConsumeHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }


    protected override function _initView():void
    {
        super._initView();

    }

    protected override function get _categorizeType():int
    {
        return CEffortConst.CONSUME;
    }
}
}
