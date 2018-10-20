//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/20.
 */
package kof.game.welfarehall {

import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.welfarehall.data.CAdvertisementData;
import kof.game.welfarehall.data.CAnnouncementData;
import kof.game.welfarehall.data.CRechargeWelfareData;
import kof.message.Notice.AdvertisementListResponse;
import kof.message.Notice.AnnouncementListResponse;
import kof.message.Notice.GetUpdateRewardResponse;
import kof.table.Currency;
import kof.table.RetrieveReward;
import kof.table.RetrieveSystemConfig;

public class CWelfareHallManager extends CAbstractHandler implements IUpdatable {

    private var m_pAnnouncementListData:Vector.<CAnnouncementData>;// 公告列表
    private var m_pAdvertisementListData:Vector.<CAdvertisementData>;// 广告列表

    public var cardMonthRewardType : int;

    public var data:CRechargeWelfareData;

    private var _recoveryConfig : IDataTable;
    private var _recoveryReward : IDataTable;
    private var _stateChangeArr : Array = [];//记录领奖后状态发生变化的活动
    public function CWelfareHallManager() {
        super();

        data = new CRechargeWelfareData();
    }
    public function update(delta:Number) : void {

    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _recoveryConfig = _dataSystem.getTable( KOFTableConstants.RETRIEVESYSTEMCONFIG );
        _recoveryReward = _dataSystem.getTable( KOFTableConstants.RETRIEVEREWARD );
        return ret;
    }
    /**
     * 更新公告列表
     * @param response
     */
    public function updateAnnouncementList(response:AnnouncementListResponse):void
    {
        if(m_pAnnouncementListData == null)
        {
            m_pAnnouncementListData = new Vector.<CAnnouncementData>();
        }

        if(response)
        {
            m_pAnnouncementListData.length = 0;

            for each(var data:Object in response.announcementList)
            {
                var announceData:CAnnouncementData = new CAnnouncementData();
                announceData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

                var obj:Object = CAnnouncementData.createObjectData(data.id,data.title,data.content,data.items,data.imgs,
                    data.rewards,data.data,data.version,data.rewardState,data.isPopUpEveryLogin,data.isPopUpFirstLogin);
                announceData.updateDataByData(obj);

                m_pAnnouncementListData.push(announceData);
            }

            system.dispatchEvent(new CWelfareHallEvent(CWelfareHallEvent.ANNOUNCEMENT_UPDATE,null));
        }
    }

    /**
     * 更新广告列表
     * @param response
     */
    public function updateAdvertisementList(response:AdvertisementListResponse):void
    {
        if(m_pAdvertisementListData == null)
        {
            m_pAdvertisementListData = new Vector.<CAdvertisementData>();
        }

        if(response)
        {
            m_pAdvertisementListData.length = 0;
            for each(var data:Object in response.advertisementList)
            {
                var advertisementData:CAdvertisementData = new CAdvertisementData();
                advertisementData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

                var obj:Object = CAdvertisementData.createObjectData(data.id,data.contents,data.imgs,data.validity,data.version);
                advertisementData.updateDataByData(obj);

                m_pAdvertisementListData.push(advertisementData);
            }

            system.dispatchEvent(new CWelfareHallEvent(CWelfareHallEvent.ADVERTISING_UPDATE,null));
        }
    }

    public function updateRewardInfo(response:GetUpdateRewardResponse):void
    {
        if(response)
        {
            for each (var info:CAnnouncementData in m_pAnnouncementListData)
            {
                if(info.id == response.id)
                {
                    var obj:Object = {};
                    obj["rewardState"] = response.rewardState;
                    info.updateDataByData(obj);
                    break;
                }
            }
        }
    }

    public function get announcementListData():Vector.<CAnnouncementData>
    {
        if(m_pAnnouncementListData)
        {
            m_pAnnouncementListData.sort(_sortByTime);
        }

        return m_pAnnouncementListData;
    }

    private function _sortByTime(a1:CAnnouncementData, a2:CAnnouncementData):int
    {
        if(a1.startTime > a2.startTime)
        {
            return -1;
        }
        else if(a1.startTime < a2.startTime)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }

    /**
     * 可找回奖励的活动列表
     */
    private var _recoverableList : Array;
    public function set recoverableList(value : Array) : void
    {
        _recoverableList = value;
        _recoverableList.sortOn(["state","systemId"],[Array.NUMERIC,Array.NUMERIC]);
        var bool : Boolean;
        for (var key : String in _recoverableList)
        {
            recondRewardState(_recoverableList[key ]);
            if(_recoverableList[key ].state == 0)
            {
                bool = true;
            }
        }
        hasRecoveryReward = bool;
    }
    public function get recoverableList() : Array
    {
        return _recoverableList;
    }
    /**
     * 根据活动ID获取该活动的奖励次数
     */
    public function getActivityCountByID(systemId : int) : int
    {
        for each(var item : Object in recoverableList)
        {
            if(item.systemId == systemId && item.count)
            {
                return item.count;
            }
        }
        return 1;
    }
    public function getRecoveryConfigByID( id : int ) : RetrieveSystemConfig
    {
        for each(var item : RetrieveSystemConfig in _recoveryConfig.tableMap)
        {
            if(item.systemId == id)
            {
                return item;
            }
        }
        return null;
    }
    public function getRecoveryRewardByID( systemId : int) : RetrieveReward
    {
        var lvl : int = _playData.teamData.level;
        var rewardArr : Array = getRecoveryRewardArray(systemId);
        var length : int = rewardArr.length;
        var bool:Boolean;
        for (var i : int = 0; i < rewardArr.length; i++)
        {
            if(i == length - 1)
            {
                bool = checkBlock(rewardArr[i].level,rewardArr[i].level,lvl);
            }
            else
            {
                bool = checkBlock(rewardArr[i].level,rewardArr[i+1].level,lvl);
            }
            if(bool)  return rewardArr[ i ];
        }
        return null;
    }

    /**
     * 判断该等级是否属于区间
     * @param min
     * @param max
     * @param lvl
     * @return
     */
    private function checkBlock(min:int,max:int,lvl:int):Boolean
    {
        if(min == max && lvl >= min) return true;
        if(lvl >= min && lvl < max) return true;
        return false;
    }
    private function getRecoveryRewardArray(sysId:int) : Array
    {
        var result : Array = [];
        for each (var item : RetrieveReward in _recoveryReward.tableMap)
        {
            if(item.systemId == sysId)
                result.push(item);
        }
        result.sortOn("ID",Array.NUMERIC);
        return result;
    }

    /**
     * 计算总价
     */
    public function getRecoveryTotalConsume() : Object
    {
        var gold : int = 0;
        var diamond : int = 0;
        var result : Object = new Object();
        var item : RetrieveSystemConfig;
        for(var i : int = 0; i < recoverableList.length; i++)
        {
            for each(item in _recoveryConfig.tableMap)
            {
                if(item.systemId == recoverableList[i ].systemId && recoverableList[i ].state == 0)
                {
                    gold = gold + item.commonConsumes * recoverableList[i ].count;
                    diamond = diamond + item.payConsumes * recoverableList[i ].count;
                }
            }
        }

        result.type1 = item.commonCurrencyType;
        result.type2 = item.payCurrencyType;
        result.cur1 = gold;
        result.cur2 = diamond;
        return result;

    }

    /**
     * 获取货币类型
     */
    public function getCurrencyType(id : int):String
    {
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.CURRENCY);
        var item : Currency = itemTable.findByPrimaryKey(id);
        return item.source;
    }
    private var _hasRecoveryReward : Boolean;
    public function set hasRecoveryReward(value : Boolean) : void
    {
        _hasRecoveryReward = value;
        system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.UPDATE_RED_POINT ));
    }
    public function get hasRecoveryReward() : Boolean
    {
        return _hasRecoveryReward;
    }
    private var _rewardStateDic : Dictionary = new Dictionary();
    /**
     * 记录领奖状态
     */
    private function recondRewardState(obj : Object) : void
    {
        var systemId : int = obj.systemId;
        var state : int = obj.state;
        if(!_rewardStateDic.hasOwnProperty(systemId + ""))
        {
            _rewardStateDic[systemId] = state;
            return;
        }
        if(_rewardStateDic[systemId] == 0 && state == 1)
        {
            _rewardStateDic[systemId] = state;
            if(_stateChangeArr.indexOf(systemId) == -1)
            {
                _stateChangeArr.push(systemId);
            }
        }
    }
    public function set stateChangeArr(value : Array) : void
    {
        _stateChangeArr = value;
    }
    public function get stateChangeArr() : Array
    {
        if(!_stateChangeArr)
            _stateChangeArr = [];
        return _stateChangeArr;
    }

    public function get advertisementListData():Vector.<CAdvertisementData>
    {
        return m_pAdvertisementListData;
    }

    private function get _dataSystem() : CDatabaseSystem
    {
        return system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
    }
    private function get _playData() : CPlayerData
    {
        return (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
    }
}
}
