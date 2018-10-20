//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/17.
 */
package kof.game.yyHall {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.platform.yy.data.CYYData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.yyHall.data.CYYRewardData;
import kof.table.YYGameLevelReward;
import kof.table.YYLevelReward;
import kof.table.YYLoginReward;

public class CYYHallHelpHandler extends CAbstractHandler
{
    private var m_newReward:Boolean;
    private var m_loginReward:Boolean;
    private var m_levelReward:Boolean;
    private var m_guizuReward:Boolean;
    public function CYYHallHelpHandler()
    {
        super();
    }

    public function hasRewardToTake():Boolean
    {
        return hasNewReward() || hasLoginReward() || hasLevelReward() || hasGuizuReward();
    }

    public function hasNewReward():Boolean
    {
        return m_newReward;
    }

    public function hasLoginReward():Boolean
    {
        return m_loginReward;
    }

    public function hasLevelReward():Boolean
    {
        return m_levelReward;
    }

    public function hasGuizuReward():Boolean
    {
        return m_guizuReward;
    }
    public function updateNewReward(newReward:Boolean):void
    {
        m_newReward = newReward
    }
    public function updateLoginReward(loginReward:Boolean):void
    {
        m_loginReward = loginReward
    }
    public function updateLevelReward(levelReward:Boolean):void
    {
        m_levelReward = levelReward
    }
    public function updateGuizuReward(guizuReward:Boolean):void
    {
        m_guizuReward = guizuReward
    }
    public function updateAllReward(yyData:CYYRewardData):void
    {
        if(yyData.loginRewardState == null || yyData.gameLevelRewardState == null ||
                yyData.yyLevelRewardState == null)
        {
            return;
        }
        if(yyData.newPlayerRewardState == 1)
        {
            m_newReward = false;
        }else{
            m_newReward = true;
        }
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统

        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLOGINREWARD);
        //天数是否达到可领取天数
//        var daysResult:Boolean;
        var daysCount:int = 0;
        for(var i:int = 1;i<=pTable.tableMap.length;i++)
        {
            var pRecord : YYLoginReward = pTable.findByPrimaryKey( i ) as YYLoginReward;
            if ( yyData.loginDays >= pRecord.days )
            {
                daysCount ++;
//                daysResult = true;
//                break;
            }
//            daysResult = false;
         }
        //表里的登录数组长度 == 领取的登录天数数组长度？小红点是否消失
        //pTable.tableMap.length != yyData.loginRewardState.length
        if(daysCount != yyData.loginRewardState.length && daysCount > 0)
        {
            m_loginReward = true;
        }else{
            m_loginReward = false;
        }

        var levelTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYGAMELEVELREWARD);
        var levelPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        //等级是否达到可领取等级
//        var levelResult:Boolean;
        var levelCount:int = 0;
        for(var l:int = 1;l<=levelTable.tableMap.length;l++)
        {
            var levelRecord : YYGameLevelReward = levelTable.findByPrimaryKey( l ) as YYGameLevelReward;
            if ( levelPlayerData.teamData.level >= levelRecord.gameLevel )
            {
                levelCount ++;
//                levelResult = true;
//                break;
            }
//            levelResult = false;
        }
        //表里的等级数组长度 == 领取的等级数组长度？小红点是否消失
        //levelTable.tableMap.length != yyData.gameLevelRewardState.length
        if(levelCount != yyData.gameLevelRewardState.length && levelCount  > 0)
        {
            m_levelReward = true;
        }else{
            m_levelReward = false;
        }

        //表里的贵族等级数组长度 == 领取的贵族等级数组长度？判断小红点是否消失
        var yyLevelTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLEVELREWARD);
        var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        //等级是否达到可领取等级
//        var yyLevelResult:Boolean;
        var yyLevelCount:int = 0;
        for(var y:int = 1;y<=yyLevelTable.tableMap.length;y++)
        {
            var yyLevelRecord : YYLevelReward = yyLevelTable.findByPrimaryKey( y ) as YYLevelReward;
            if ((yyLevelPlayerSystem.platform.data as CYYData).yyLevel >= yyLevelRecord.ID )
            {
                yyLevelCount ++;
//                yyLevelResult = true;
//                break;
            }
//            yyLevelResult = false;
        }
        var a:Boolean = (yyLevelTable.tableMap.length != yyData.yyLevelRewardState.length);
        //yyLevelTable.tableMap.length != yyData.yyLevelRewardState.length
        if(yyLevelCount != yyData.yyLevelRewardState.length && yyLevelCount > 0)
        {
            m_guizuReward = true;
        }else{
            m_guizuReward = false;
        }
    }
}
}
