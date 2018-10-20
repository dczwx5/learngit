//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-05-28.
 */
package kof.game.HeroTreasure {

import QFLib.Foundation.CMap;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.HeroTreasure.enum.EHeroTreasureActivityState;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.switching.CSwitchingSystem;
import kof.message.Activity.ActivityChangeResponse;
import kof.table.Activity;
import kof.table.TreasureDisplayItem;

/**
 *@author Demi.Liu
 *@data 2018-05-28
 */
public class CHeroTreasureManager extends CAbstractHandler {

    //格斗家宝藏活动时间，-1为活动已过期
    private var _activityTime:Number;

    //10连抽的奖励
    private var _rewardListData:CRewardListData;

    //当个奖励的下标
    private var _reward:int;

    //抽奖卡池
    private var _poolId:int;

    //抽奖卡池
    //   1：消耗道具
    //   2：单抽
    //   3：十连抽
    public static var POOTYPE_ONE:int = 1;
    public static var POOTYPE_TWO:int = 2;
    public static var POOTYPE_THREE:int = 3;

    //活动基础信息里的ID值
    public static var HREOTREASUREACTIVITYINFO_ID:int = 24;

    public var curActivityId:int = 0;
    public var curActivityState:int = 0;
    public var startTime:Number = 0.0;
    public var endTime:Number = 0.0;

    private var m_pActivityStateMap:CMap = new CMap();

    private var m_pValidater : CHeroTreasureValidater;
    private var m_pTrigger : CHeroTreasureTrigger;

    private var _activityTable:IDataTable;

    public function CHeroTreasureManager() {
        super();
    }

    public function setActivityTime(activityTime:Number):void{
        this._activityTime = activityTime;
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _activityTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ACTIVITY);

        var switchingSystem : CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        m_pValidater = new CHeroTreasureValidater(system);
        switchingSystem.addValidator(m_pValidater);
        m_pTrigger = new CHeroTreasureTrigger(system as CHeroTreasureSystem);
        switchingSystem.addTrigger(m_pTrigger);

        return ret;
    }

    public function getActivityTime():Number{
        return _activityTime
    }

    public function setRewardListData( list:Array):void{
        var _rewardList:Array = [];
        for(var i:int = 0; i<list.length; i++){
            var obj:Object = {ID:list[i].itemId,num:list[i].count};
            _rewardList.push(obj);
        }
        _rewardListData = CRewardUtil.createByList2(system.stage,_rewardList);
    }

    public function getRewardListData():CRewardListData{
        return _rewardListData;
    }

    public function setRewardIndex( reward:Array):void{
        var rewardItem:Object = reward[0];//{itemId:10200204,count:1}

        for ( var j : int = 1; j <= 16; j++ ) {
            var treasureDisplayItem : TreasureDisplayItem = _getTreasureItemTableData(j);
            if(rewardItem.itemId == treasureDisplayItem.propsId && rewardItem.count == treasureDisplayItem.propsNum)
            {
                this._reward = j;
            }
        }
    }

    public function getOntRewardIndex():int{
        return this._reward
    }

    public function set poolId(poolId:int):void {
        this._poolId = poolId;
    }

    public function get poolId():int {
        return this._poolId;
    }

    /**抽奖奖励配置表*/
    private function _getTreasureItemTableData( index : int ) : TreasureDisplayItem {
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.TREASUREDISPLAYITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( index );
    }

    public function openHeroTreasureActivity() : void {
        m_pValidater.valid = true;
        m_pTrigger.notifyUpdated();
    }

    /**
     * 关闭系统入口
     * **/
    public function closeHeroTreasureActivity() : void
    {
        heroTreasureSystem.onViewClosed();
        m_pValidater.valid = false;
        m_pTrigger.notifyUpdated();
        heroTreasureSystem.closeHeroTreasureActivity();
    }

    private function get heroTreasureSystem() : CHeroTreasureSystem {
        return system as CHeroTreasureSystem;
    }

    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _activity():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ACTIVITY);
    }

    /**
     * 更新活动状态
     */
    public function updateActivityState(response:ActivityChangeResponse):void
    {
        if(response)
        {
            m_pActivityStateMap.add(response.activityID, response.state, true);

            var heroIds:Array = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.activityHeroIds;
            if(response.state == EHeroTreasureActivityState.ACTIVITY_STATE_START)
            {
                var activityTable:Activity = _activity.findByPrimaryKey(response.activityID) as Activity;
                if(activityTable && activityTable.heroIds)
                {
                    var arr:Array = activityTable.heroIds.split("#");
                    if(arr && arr.length)
                    {
                        for each(var heroId:String in arr)
                        {
                            if(heroIds.indexOf(heroId) == -1)
                            {
                                heroIds.push(heroId);
                            }
                        }
                    }
                }
            }

        }
    }

    public function getActivityType(activityId:int):int
    {
        var activityConfig:Activity = _activityTable.findByPrimaryKey(activityId) as Activity;
        if(activityConfig)
        {
            return activityConfig.type;
        }
        else
        {
            return 0;
        }
    }

}
}
