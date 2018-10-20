//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena {

import flash.utils.setTimeout;

import kof.data.CPreloadData;

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.arena.CArenaHelpHandler;
import kof.game.arena.data.CArenaBaseData;
import kof.game.arena.data.CArenaBestRankRewardData;
import kof.game.arena.data.CArenaFightReportData;
import kof.game.arena.data.CArenaResultData;
import kof.game.arena.data.CArenaRoleData;
import kof.game.arena.event.CArenaEvent;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.EPreloadType;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.loading.CPVPLoadingData;
import kof.game.loading.CPVPLoadingData;
import kof.game.loading.CPVPLoadingHeadData;
import kof.message.Arena.ArenaBaseResponse;
import kof.message.Arena.ArenaBattleResultResponse;
import kof.message.Arena.ArenaBuyChallengeResponse;
import kof.message.Arena.ArenaChallengeResponse;
import kof.message.Arena.ArenaChangeResponse;
import kof.message.Arena.ArenaFightReportResponse;
import kof.message.Arena.ArenaHighestAwardListResponse;

public class CArenaManager extends CAbstractHandler {

    private var m_listRoleData:Array = [];// 挑战者列表数据
    private var m_pArenaBaseData:CArenaBaseData;// 竞技场基本数据
    private var m_pRewardData:CArenaBestRankRewardData;// 最高奖励数据
    private var m_listReport:Array = [];// 战报数据
    private var m_pArenaResultData:CArenaResultData;// 竞技场结算数据
    private var m_pChallengerData:CArenaRoleData;// 当前挑战者数据

    public function CArenaManager()
    {
        super();
    }

    override protected virtual function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        return ret;
    }

    /**
     * 更新竞技场挑战者数据
     */
    public function updateChallengerInfo(response:ArenaChangeResponse):void
    {
        if(response && response.dataMap)
        {
            m_listRoleData.length = 0;
            for(var i:int = 0; i < response.dataMap.length; i++)
            {
                var info:Object = response.dataMap[i];
                var roleData:CArenaRoleData = new CArenaRoleData();
                roleData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                roleData.updateDataByData(info);

                if(i < 3)
                {
                    roleData.displayPos = 1;
                }
                else
                {
                    roleData.displayPos = 2;
                }

                m_listRoleData.push(roleData);
            }

            system.dispatchEvent(new CArenaEvent(CArenaEvent.AllChallenger_Update,null));
        }
    }

    /**
     * 更新单个挑战者数据
     */
    public function updateSingleChallengerInfo(response:ArenaChallengeResponse):void
    {
        if(m_pChallengerData == null)
        {
            m_pChallengerData = new CArenaRoleData();
            m_pChallengerData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        if(response && response.dataMap)
        {
            m_pChallengerData.updateDataByData(response.dataMap);

            // 预加载
            var selfIdList:Array = [];
            var selfData:CArenaRoleData = _getSelfData();
            if(selfData)
            {
                var len:int = selfData.heroList.length;
                for(var i:int = 0; i < len; i++)
                {
                    var heroInfo:Object = selfData.heroList[i];
                    var heroId:int = heroInfo["heroId"];
                    selfIdList[i] = heroId;
                }
            }

            var enemyIdList:Array = [];
            len = m_pChallengerData.heroList.length;
            for(i = 0; i < len; i++)
            {
                heroInfo = m_pChallengerData.heroList[i];
                heroId = heroInfo["heroId"];
                enemyIdList[i] = heroId;
            }

            var preloadDataList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
            var heroIdList:Array = selfIdList.concat(enemyIdList);
            CPreload.AddPreloadListByIDList(preloadDataList,heroIdList,EPreloadType.RES_TYPE_HERO);
            var instanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
            instanceSystem.addPreloadData(preloadDataList);

            system.dispatchEvent(new CArenaEvent(CArenaEvent.SingleChallenger_Update,null));
        }
    }

    private function _getSelfData():CArenaRoleData
    {
        if(m_listRoleData && m_listRoleData.length)
        {
            var arenaHelp : CArenaHelpHandler = system.getHandler( CArenaHelpHandler ) as CArenaHelpHandler;
            for each( var roleData : CArenaRoleData in m_listRoleData )
            {
                if ( arenaHelp.isSelf( roleData.roleId ) )
                {
                    return roleData;
                }
            }
        }

        return null;
    }

    /**
     * 更新竞技场主界面基本数据
     * @param response
     */
    public function updateArenaBaseData(response:ArenaBaseResponse):void
    {
        if(m_pArenaBaseData == null)
        {
            m_pArenaBaseData = new CArenaBaseData();
            m_pArenaBaseData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        if(response)
        {
            var obj:Object = CArenaBaseData.createObjectData(response.challengeNumber,response.buyNumber,response.changeNumber);
            m_pArenaBaseData.updateDataByData(obj);

            system.dispatchEvent(new CArenaEvent(CArenaEvent.BaseInfo_Update,null));
        }
    }

    /**
     * 更新历史最高排名奖励数据
     * @param response
     */
    public function updateRewardData(response:ArenaHighestAwardListResponse):void
    {
        if(m_pRewardData == null)
        {
            m_pRewardData = new CArenaBestRankRewardData();
            m_pRewardData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        if(response)
        {
            var obj:Object = CArenaBestRankRewardData.createObjectData(response.rank,response.canGet,response.haveGot);
            m_pRewardData.updateDataByData(obj);

            system.dispatchEvent(new CArenaEvent(CArenaEvent.RewardInfo_Update,null));
        }
    }

    /**
     * 更新战报数据
     */
    public function updateFightReportData(response:ArenaFightReportResponse):void
    {
        if(response && response.fightReportDataList)
        {
            m_listReport.length = 0;
            for each(var info:Object in response.fightReportDataList)
            {
                var fightReportData:CArenaFightReportData = new CArenaFightReportData();
                fightReportData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                fightReportData.updateDataByData(info);
                m_listReport.push(fightReportData);
            }

            system.dispatchEvent(new CArenaEvent(CArenaEvent.FightReport_Update,null));
        }
    }

    /**
     * 购买挑战次数后更新基本信息中的次数信息
     * @param response
     */
    public function updateChallengeBaseInfo(response:ArenaBuyChallengeResponse):void
    {
        if(response)
        {
            if(m_pArenaBaseData)
            {
                var obj:Object = CArenaBaseData.createObjectData(response.challengeNumber,response.buyNumber,m_pArenaBaseData.changeNum);
                m_pArenaBaseData.updateDataByData(obj);

                system.dispatchEvent(new CArenaEvent(CArenaEvent.BaseInfo_Update,null));
            }
        }
    }

    /**
     * 竞技场结算数据
     */
    public function updateArenaResultData(response:ArenaBattleResultResponse):void
    {
        if(m_pArenaResultData == null)
        {
            m_pArenaResultData = new CArenaResultData();
            m_pArenaResultData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        if(response)
        {
            m_pArenaResultData.convertData(response.keyValues);

            ((system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getHandler(CMultiplePVPResultViewHandler )
            as CMultiplePVPResultViewHandler).data = m_pArenaResultData;
        }
    }

    /**
     * 自己的当前排名
     */
    public function getMyRank():int
    {
        if(m_listRoleData && m_listRoleData.length)
        {
            var arenaHelp:CArenaHelpHandler = system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
            for each(var info:CArenaRoleData in m_listRoleData)
            {
                if(arenaHelp.isSelf(info.roleId))
                {
                    return info.rank;
                }
            }
        }

        return 0;
    }

    /**
     * 历史最高排名
     * @return
     */
    public function getHisBestRank():int
    {
        if(m_pRewardData)
        {
            return m_pRewardData.hisBestRank;
        }

        return 0;
    }

    /**
     * 竞技场双方信息
     * @return
     */
    public function getArenaLoadingData():CPVPLoadingData
    {
        var loadingData:CPVPLoadingData;
        var selfLoadingHeadData:CPVPLoadingHeadData;
        var enemyLoadingHeadData:CPVPLoadingHeadData;
        var selfHeroIdList:Array;
        var enemyHeroIdList:Array;
        var enemyQualList:Array;

        if(m_listRoleData && m_listRoleData.length)
        {
            var arenaHelp:CArenaHelpHandler = system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
            for each(var roleData:CArenaRoleData in m_listRoleData)
            {
                //己方数据====================================================
                if(arenaHelp.isSelf(roleData.roleId))
                {
                    // 头像部分数据
                    selfLoadingHeadData = new CPVPLoadingHeadData();
                    selfLoadingHeadData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

                    var star:int = _getStar(roleData.displayId,roleData.heroList);
                    var quality:int = _getQuality(roleData.displayId,roleData.heroList);
                    var data:Object = CPVPLoadingHeadData.createObjectData(roleData.displayId,star,quality,roleData.roleName,
                            "排名",roleData.rank.toString(), "战斗力",roleData.combat.toString());
                    selfLoadingHeadData.updateDataByData(data);

                    // 格斗家列表数据
                    selfHeroIdList = [];
                    for each(var info:Object in roleData.heroList)
                    {
                        selfHeroIdList.push(info["heroId"]);
                    }
                }

                //敌方数据====================================================
                if(arenaHelp.isEnemy(roleData.rank))
                {
//                    roleData = m_pChallengerData;
//
//                    // 头像部分数据
//                    enemyLoadingHeadData = new CPVPLoadingHeadData();
//                    enemyLoadingHeadData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
//
//                    star = _getStar(roleData.displayId,roleData.heroList);
//                    quality = _getQuality(roleData.displayId,roleData.heroList);
//                    data = CPVPLoadingHeadData.createObjectData(roleData.displayId,star,quality,roleData.roleName,"排名",roleData.rank.toString(),
//                            "战斗力",roleData.combat.toString());
//                    enemyLoadingHeadData.updateDataByData(data);
//
//                    // 格斗家列表数据
//                    enemyHeroIdList = [];
//                    for each(info in roleData.heroList)
//                    {
//                        enemyHeroIdList.push(info["heroId"]);
//                    }
                }
            }

            if(m_pChallengerData)
            {
                roleData = m_pChallengerData;

                // 头像部分数据
                enemyLoadingHeadData = new CPVPLoadingHeadData();
                enemyLoadingHeadData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

                star = _getStar(roleData.displayId,roleData.heroList);
                quality = _getQuality(roleData.displayId,roleData.heroList);
                data = CPVPLoadingHeadData.createObjectData(roleData.displayId,star,quality,roleData.roleName,"排名",roleData.rank.toString(),
                        "战斗力",roleData.combat.toString());
                enemyLoadingHeadData.updateDataByData(data);

                // 格斗家列表数据
                enemyHeroIdList = [];
                enemyQualList = [];
                for each(info in roleData.heroList)
                {
                    enemyHeroIdList.push(info["heroId"]);
                    enemyQualList.push(info["quality"]);
                }
            }

            if(selfLoadingHeadData && enemyLoadingHeadData && selfHeroIdList && enemyHeroIdList)
            {
                loadingData = new CPVPLoadingData();
                loadingData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                data = CPVPLoadingData.createObjectData(selfLoadingHeadData,enemyLoadingHeadData,selfHeroIdList,enemyHeroIdList,enemyQualList);
                loadingData.updateDataByData(data);
            }
        }

        return loadingData;
    }

    private function _getStar(heroId:int,heroList:Array):int
    {
        if(heroList && heroList.length)
        {
            for each(var info:Object in heroList)
            {
                if(info.hasOwnProperty("heroId") && info["heroId"] == heroId)
                {
                    if(info.hasOwnProperty("star"))
                    {
                        return info["star"];
                    }
                }
            }
        }

        return 0;
    }

    private function _getQuality(heroId:int,heroList:Array):int
    {
        if(heroList && heroList.length)
        {
            for each(var info:Object in heroList)
            {
                if(info.hasOwnProperty("heroId") && info["heroId"] == heroId)
                {
                    if(info.hasOwnProperty("quality"))
                    {
                        return info["quality"];
                    }
                }
            }
        }

        return 0;
    }

    public function clearResultData():void
    {
        m_pArenaResultData = null;
    }

    public function get arenaBaseData():CArenaBaseData
    {
        return m_pArenaBaseData;
    }

    public function get roleListData():Array
    {
        return m_listRoleData;
    }

    public function get rewardData():CArenaBestRankRewardData
    {
        return m_pRewardData;
    }

    public function get reportListData():Array
    {
        return m_listReport;
    }

    public function get resultData():CArenaResultData
    {
        return m_pArenaResultData;
    }
}
}
