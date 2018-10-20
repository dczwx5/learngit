//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower {

import kof.data.CPreloadData;
import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.EPreloadType;
import kof.game.endlessTower.data.CEndlessTowerBaseData;
import kof.game.endlessTower.data.CEndlessTowerHeroData;
import kof.game.endlessTower.data.CEndlessTowerResultData;
import kof.game.endlessTower.event.CEndlessTowerEvent;
import kof.game.instance.IInstanceFacade;
import kof.message.EndlessTower.EndlessTowerDataResponse;
import kof.message.EndlessTower.EndlessTowerEverydayRewardObtainResponse;
import kof.message.EndlessTower.EndlessTowerPassBoxObtainResponse;
import kof.message.EndlessTower.EndlessTowerRankResponse;

public class CEndlessTowerManager extends CAbstractHandler {

    private var m_pTowerBaseData:CEndlessTowerBaseData;
    private var m_listRankData:Array;

    public function CEndlessTowerManager()
    {
        super();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean =  super.onSetup();
        m_pTowerBaseData = new CEndlessTowerBaseData();
        m_pTowerBaseData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

        return ret;
    }

    public function updateBaseData(response:EndlessTowerDataResponse):void
    {
        if(response)
        {
//            m_pTowerBaseData.boxHasTakeArr = response.maxPassedLayerBoxRewardObtainedArr;
            m_pTowerBaseData.boxTakeInfoListData.updateDataByData(response.layerInfoArr);
            m_pTowerBaseData.dayRewardTakeLayer = response.everydayRewardObtainedLayer;
            m_pTowerBaseData.maxPassedLayer = response.maxPassedLayer;

            system.dispatchEvent(new CEndlessTowerEvent(CEndlessTowerEvent.BaseInfo_Update, null));
        }
    }

    /**
     * 更新排行版数据
     * @param response
     */
    public function updateRankData(response:EndlessTowerRankResponse):void
    {
        if(response)
        {
            m_listRankData = response.rankData;

            system.dispatchEvent(new CEndlessTowerEvent(CEndlessTowerEvent.RankInfo_Update, null));
        }
    }

    /**
     * 每日奖励领取信息
     */
    public function updateDayRewardTakeInfo(response:EndlessTowerEverydayRewardObtainResponse):void
    {
        if(response && m_pTowerBaseData)
        {
            m_pTowerBaseData.dayRewardTakeLayer = response.everydayRewardObtainedLayer;

            system.dispatchEvent(new CEndlessTowerEvent(CEndlessTowerEvent.DayRewardInfo_Update, null));
        }
    }

    /**
     * 通关宝箱领取信息
     */
    public function updateBoxRewardTakeInfo(response:EndlessTowerPassBoxObtainResponse):void
    {
        if(response && m_pTowerBaseData)
        {
            m_pTowerBaseData.boxTakeInfoListData.updateDataByData([response.layerInfo]);

            system.dispatchEvent(new CEndlessTowerEvent(CEndlessTowerEvent.BoxRewardInfo_Update, null));
        }
    }

    /**
     * 结算数据
     * @param dataObj
     */
    public function updateResultData(dataObj:Object) : void {
        m_pTowerBaseData.updateResultData(dataObj);
    }

    public function startPreload(layer:int):void
    {
        var heroArr:Array = (system.getHandler(CEndlessTowerHelpHandler) as CEndlessTowerHelpHandler).getHeroDatasById(layer);

        var enemyIdList:Array = [];
        if(heroArr && heroArr.length)
        {
            for each(var endlessHeroData:CEndlessTowerHeroData in heroArr)
            {
                enemyIdList.push(endlessHeroData.heroId);
            }
        }

        var preloadDataList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
        CPreload.AddPreloadListByIDList(preloadDataList,enemyIdList,EPreloadType.RES_TYPE_HERO);
        var instanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
        instanceSystem.addPreloadData(preloadDataList);
    }

    public function get baseData():CEndlessTowerBaseData
    {
        return m_pTowerBaseData;
    }

    public function get rankDataArr():Array
    {
        return m_listRankData;
    }

    public function get resultData():CEndlessTowerResultData
    {
        return m_pTowerBaseData.resultData;
    }
}
}
