//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/17.
 */
package kof.game.guildWar {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.guildWar.data.CGuildWarData;

public class CGuildWarManager extends CAbstractHandler {

    private var m_pData:CGuildWarData;

    public function CGuildWarManager() {
        super();
    }

    public function get data() : CGuildWarData
    {
        return m_pData;
    }

    /**
     * 初始化公会战基本信息
     */
    public function initGuildWarInfoData(data:Object):void
    {
        if(m_pData == null)
        {
            var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            m_pData = new CGuildWarData(dataBase);
        }

        m_pData.baseData.updateDataByData(data);
    }

    /**
     * 更新公会战基本信息
     */
    public function updateGuildWarInfoData(data:Object):void
    {
        initGuildWarInfoData(data);
    }

    /**
     * 更新各空间站俱乐部信息
     */
    public function updateStationInfo(data:Array):void
    {
        if(m_pData && m_pData.stationListData)
        {
            m_pData.stationListData.clearAll();
            m_pData.stationListData.updateDataByData(data);
        }
    }

    /**
     * 更新匹配数据
     */
    public function updateMatchData(data:Object):void
    {
        if(m_pData && m_pData.matchData)
        {
            m_pData.matchData.updateDataByData(data);
        }
    }

    /**
     * 更新进度信息
     * @param enemyProgress
     */
    public function updateProgress(enemyProgress:int):void
    {
        if(m_pData)
        {
            m_pData.enemyProgress = enemyProgress;
        }
    }

    /**
     * 结算数据
     * @param data
     */
    public function updateResultData(data:Object):void
    {
        if(m_pData && m_pData.resultData)
        {
            m_pData.resultData.updateDataByData(data);
        }
    }

    /**
     * 公会战某个空间站俱乐部排行数据
     * @param data
     */
    public function updateStationClubRankData(data:Object):void
    {
        if(m_pData && m_pData.stationClubRankData)
        {
            m_pData.stationClubRankData.updateDataByData(data);
        }
    }

    /**
     * 公会战某个空间站个人排行数据
     * @param data
     */
    public function updateStationRoleRankData(data:Object):void
    {
        if(m_pData && m_pData.stationRoleRankData)
        {
            m_pData.stationRoleRankData.updateDataByData(data);
        }
    }

    /**
     * 公会战总能源排行数据更新
     */
    public function updateTotalScoreRankData(data:Object):void
    {
        if(m_pData && m_pData.totalScoreRankListData)
        {
            m_pData.totalScoreRankListData.clearAll();
            m_pData.totalScoreRankListData.updateDataByData(data);
        }
    }

    /**
     * 公会战空间站能源排行数据更新
     */
    public function updateStationTotalScoreRankData(data:Object):void
    {
        if(m_pData && m_pData.stationTotalScoreRankListData)
        {
            m_pData.stationTotalScoreRankListData.clearAll();
            m_pData.stationTotalScoreRankListData.updateDataByData(data);
        }
    }

    /**
     * 已占领的空间站ID
     * @param ids
     */
    public function updateObtainSpaceIds(ids:Array):void
    {
        if(m_pData)
        {
            m_pData.obtainSpaceIds = ids;
        }
    }

    /**
     * 更新战报信息
     * @param data
     */
    public function updateFightReportInfo(data:Object):void
    {
        if(m_pData && m_pData.fightReportData)
        {
            m_pData.fightReportData.updateDataByData(data);
        }
    }

    /**
     * 更新战斗激活数据
     */
    public function updateBuffInfo(data:Object):void
    {
        if(m_pData && m_pData.buffData)
        {
            m_pData.buffData.updateDataByData(data);
        }
    }

    /**
     * 更新鼓舞反馈数据
     * @param data
     */
    public function updateBuffResponseInfo(data:Object):void
    {
        if(m_pData && m_pData.buffResponseData)
        {
            m_pData.buffResponseData.updateDataByData(data);
        }
    }

    /**
     * 更新礼包分配数据
     * @param data
     */
    public function updateGiftBagInfo(data:Object):void
    {
        if(m_pData && m_pData.giftBagData)
        {
            m_pData.giftBagData.updateDataByData(data);
        }
    }

    /**
     * 更新礼包分配记录数据
     * @param data
     */
    public function updateGiftBagRecordInfo(data:Object):void
    {
        if(m_pData && m_pData.giftBagRecordData)
        {
            m_pData.giftBagRecordData.clearAll();
            m_pData.giftBagRecordData.updateDataByData(data);
        }
    }
}
}
