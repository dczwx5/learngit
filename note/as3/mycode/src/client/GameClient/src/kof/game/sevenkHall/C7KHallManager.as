//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/18.
 */
package kof.game.sevenkHall {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.platform.sevenK.E7kVipType;
import kof.game.sevenkHall.data.C7K7KRewardInfoData;
import kof.message.PlatformReward.EverydayReward7k7kResponse;
import kof.message.PlatformReward.LevelUpReward7k7kResponse;
import kof.message.PlatformReward.NewPlayerReward7k7kResponse;
import kof.message.PlatformReward.PlatformRewardInfo7k7kResponse;

public class C7KHallManager extends CAbstractHandler {

    private var m_pRewardInfoData:C7K7KRewardInfoData;

    public function C7KHallManager()
    {
        super();
    }

    /**
     * 更新所有奖励状态
     * @param response
     */
    public function updateRewardsState(response:PlatformRewardInfo7k7kResponse):void
    {
        if(response)
        {
            var obj:Object = response.dataMap;
            if(m_pRewardInfoData == null)
            {
                m_pRewardInfoData = new C7K7KRewardInfoData();
                m_pRewardInfoData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            }

            m_pRewardInfoData.updateDataByData(obj);
        }
    }

    /**
     * 更新新手奖励领取状态
     * @param response
     */
    public function updateNewRewardState(response:NewPlayerReward7k7kResponse):void
    {
        if(response)
        {
            if(m_pRewardInfoData)
            {
                m_pRewardInfoData.newPlayerRewardState = response.receiveState;
            }
        }
    }

    /**
     * 更新每日奖励领取状态
     * @param response
     */
    public function updateDailyRewardState(response:EverydayReward7k7kResponse):void
    {
        if(response)
        {
            if(m_pRewardInfoData)
            {
                if(response.vipType == E7kVipType.COMMON)
                {
                    m_pRewardInfoData.everydayRewardState = response.receiveState;
                }
                else if(response.vipType == E7kVipType.YEAR)
                {
                    m_pRewardInfoData.yearVipEverydayRewardState = response.receiveState;
                }
            }
        }
    }

    /**
     * 更新等级奖励领取状态
     * @param response
     */
    public function updateLevelRewardState(response:LevelUpReward7k7kResponse):void
    {
        if(response)
        {
            if(m_pRewardInfoData)
            {
                m_pRewardInfoData.levelUpRewardState = response.rewardState;
            }
        }
    }

    public function get rewardInfoData():C7K7KRewardInfoData
    {
        return m_pRewardInfoData;
    }
}
}
