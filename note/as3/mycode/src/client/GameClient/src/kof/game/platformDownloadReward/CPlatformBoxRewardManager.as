//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/13.
 */
package kof.game.platformDownloadReward {

import kof.framework.CAbstractHandler;

public class CPlatformBoxRewardManager extends CAbstractHandler {

    private var m_pRewardTakeState:int;// 奖励领取状态

    public function CPlatformBoxRewardManager()
    {
        super();
    }

    public function set rewardTakeState(value:int):void
    {
        m_pRewardTakeState = value;
    }

    public function get rewardTakeState():int
    {
        return m_pRewardTakeState;
    }
}
}
