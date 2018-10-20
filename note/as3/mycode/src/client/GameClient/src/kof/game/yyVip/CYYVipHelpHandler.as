//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/8.
 */
package kof.game.yyVip {

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.yy.data.CYYData;
import kof.game.player.CPlayerSystem;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.game.yyVip.data.CYYVipRewardData;
import kof.game.yyVip.view.CYYVipViewHandler;
import kof.table.YYVipDayWelfare;
import kof.table.YYVipLevelReward;
import kof.table.YYVipWeekWelfare;

import morn.core.handlers.Handler;

public class CYYVipHelpHandler extends CAbstractHandler{
    private var m_newReward:Boolean;
    private var m_daysWeekReward:Boolean;
    private var m_oneNewReward:Boolean;
    private var m_twoNewReward:Boolean;
    private var m_threeNewReward:Boolean;
    private var m_daysReward:Boolean;
    private var m_weekReward:Boolean;
    public function CYYVipHelpHandler() {
        super();
    }

    public function hasRewardToTake():Boolean
    {
        return hasNewReward() || hasDaysWeekReward();
    }

    public function hasNewReward():Boolean
    {
        return m_newReward;
    }

    public function hasDaysWeekReward():Boolean
    {
        return m_daysWeekReward;
    }

    public function hasOneReward():Boolean
    {
        return m_oneNewReward;
    }
    public function hasTwoReward():Boolean
    {
        return m_twoNewReward;
    }
    public function hasThreeReward():Boolean
    {
        return m_threeNewReward;
    }

    public function hasDaysReward():Boolean
    {
        return m_daysReward;
    }
    public function hasWeekReward():Boolean
    {
        return m_weekReward;
    }

    public function updateAllReward(yyData:CYYVipRewardData):void
    {
        if(yyData.yyVipLevelRewardState == null || yyData.dayWelfareState == null ||
                yyData.weekWelfareState == null)
        {
            return;
        }
        m_oneNewReward = vipLevelDeal(yyData,1);
        m_twoNewReward = vipLevelDeal(yyData,2);
        m_threeNewReward = vipLevelDeal(yyData,3);
        m_newReward = m_oneNewReward || m_twoNewReward || m_threeNewReward;

        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统

        var dayslevelTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYVIPDAYWELFARE);
        var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        //日礼包-达到可领取的有几个
        var levelCount:int = 0;
        for(var l:int = 1;l<=dayslevelTable.tableMap.length;l++)
        {
            var levelRecord : YYVipDayWelfare = dayslevelTable.findByPrimaryKey( l ) as YYVipDayWelfare;
            if ((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade >= levelRecord.vipLevel )
            {
                levelCount++;
            }
        }
        //表里的等级数组长度 == 领取的等级数组长度？小红点是否消失
        //dayslevelTable.tableMap.length != yyData.dayWelfareState.length
        if(levelCount != yyData.dayWelfareState.length && levelCount > 0)
        {
            m_daysReward = true;
        }else{
            m_daysReward = false;
        }

        //周礼包-达到可领取的有几个
        var weekLevelTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYVIPWEEKWELFARE);
        //等级是否达到可领取等级
        levelCount = 0;
        for(var y:int = 1;y <= weekLevelTable.tableMap.length;y++)
        {
            var yyLevelRecord : YYVipWeekWelfare = weekLevelTable.findByPrimaryKey( y ) as YYVipWeekWelfare;
            if ((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade >= yyLevelRecord.vipLevel )
            {
                levelCount ++;
            }
        }
        //weekLevelTable.tableMap.length != yyData.weekWelfareState.length
        if(levelCount != yyData.weekWelfareState.length && levelCount > 0)
        {
            m_weekReward = true;
        }else{
            m_weekReward = false;
        }
        m_daysWeekReward = m_daysReward || m_weekReward;
    }
    public function vipLevelDeal(yyData:CYYVipRewardData,i:int):Boolean
    {
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYVIPLEVELREWARD);
        var pRecord : YYVipLevelReward = pTable.findByPrimaryKey( i ) as YYVipLevelReward;
        var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        //YY会员等级是否达到可领取等级 || 会员礼包是否已经领取
        if((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade < pRecord.vipLevel ||
                yyData.isVipLevelReward(pRecord.vipLevel))
        {
            return false;
        }else{
            return true;
        }
    }
}
}
