//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/7.
 */
package kof.game.welfarehall {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.platform.yy.data.CYYData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.welfarehall.data.CRechargeWelfareData;
import kof.game.yyHall.data.CYYRewardData;
import kof.table.ForeverRechargeReward;
import kof.table.YYGameLevelReward;
import kof.table.YYLevelReward;
import kof.table.YYLoginReward;

public class CWelfareHelpHandler extends CAbstractHandler{
    private var m_rechargeReward:Boolean = true;
    public function CWelfareHelpHandler() {
    }

    public function hasRechargeReward():Boolean
    {
        return m_rechargeReward;
    }

    public function updateRechargeReward(rechargeReward:Boolean):void
    {
        m_rechargeReward = rechargeReward;
    }

    public function updateAllReward(rechargeData:CRechargeWelfareData):void {
        if ( rechargeData.receiveRechargeRecord == null) {
            return;
        }
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统

        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.FOREVER_RECHARGE_REWARD);
        //是否达到可领取条件
        var daysCount:int = 0;
        for(var i:int = 1;i<=pTable.tableMap.length;i++)
        {
            var pRecord : ForeverRechargeReward = pTable.findByPrimaryKey( i ) as ForeverRechargeReward;
            if ( rechargeData.totalRechargeDiamond >= pRecord.rechargeValue )
            {
                daysCount ++;
            }
        }
        //表里的福利数组长度 == 领取的福利数组长度？小红点是否消失
        if(daysCount != rechargeData.receiveRechargeRecord.length && daysCount > 0)
        {
            m_rechargeReward = true;
        }else{
            m_rechargeReward = false;
        }

    }
}
}
