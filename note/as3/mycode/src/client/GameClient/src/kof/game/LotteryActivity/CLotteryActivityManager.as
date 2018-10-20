//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/28.
 */
package kof.game.LotteryActivity {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.player.CPlayerSystem;
import kof.game.switching.CSwitchingSystem;
import kof.table.Activity;
import kof.table.LotteryConfig;
import kof.table.LotteryConsume;
import kof.table.LotteryShow;

public class CLotteryActivityManager extends CAbstractHandler{

    private var m_pTrigger:CLotteryTrigger;
    private var m_pValidater:CLotteryValidater;
    private var m_activityTable : IDataTable;
    private var m_consumeTable : IDataTable;
    private var m_showTable : IDataTable;
    private var m_configTable : IDataTable;
    private var _rewardStates : Array = [];//抽取状态
    private var _count : int;//已经抽过的次数
    private var _newPosition : int = 1; //抽奖返回的位置
    private var _lastPosition : int = 1;//上一次的位置，默认为1
    private var _backCounts : int;//返回的钥匙数量
    public var curActivityId:int = 0;
    public var curActivityState:int = 0;
    public var startTime:Number = 0.0;
    public var endTime:Number = 0.0;
    public var firstOpen:Boolean;
    public static var maxCount : int = 10;//总次数为10次
    public function CLotteryActivityManager() {
        super();
    }
    override public function dispose() : void {
        super.dispose();

        m_pTrigger.dispose();
        m_pValidater.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_activityTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY );
        m_configTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.LOTTERYCONFIG );
        m_consumeTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.LOTTERYCONSUME );
        m_showTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.LOTTERYSHOW );

        var switchingSystem : CSwitchingSystem = system.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem;
        m_pValidater = new CLotteryValidater( _system );
        switchingSystem.addValidator( m_pValidater );
        m_pTrigger = new CLotteryTrigger();
        switchingSystem.addTrigger( m_pTrigger );

        closeActivity();//活动开放才开启
        return ret;
    }

    public function openActivity() : void {
        if(count >= maxCount) return;//如果次数用完，就不开启系统
        m_pValidater.valid = true ;
        m_pTrigger.notifyUpdated();
    }
    public function closeActivity() : void {
        m_pValidater.valid = false;
        m_pTrigger.notifyUpdated();
        firstOpen = false;
    }
    public function getActivityType(activityId:int):int
    {
        var activityConfig:Activity = m_activityTable.findByPrimaryKey(activityId);
        if(activityConfig)  return activityConfig.type;
        else  return 0;
    }
    public function get itemID() : int
    {
        for each(var item : LotteryConfig in m_configTable.tableMap)
        {
            if(item.activityId == curActivityId)
            {
                return item.itemID;
            }
        }
        return 0;
    }
    public function set rewardStates(value : Array) : void
    {
        _rewardStates = value;
    }
    public function get rewardStates() : Array
    {
        return _rewardStates;
    }
    public function set count(value : int) : void
    {
        _count = value;
    }
    public function get count() : int
    {
        return _count;
    }
    public function set newPosition(value : int) : void
    {
        _lastPosition = _newPosition;
        _newPosition = value;
    }
    public function get newPosition() : int
    {
        return _newPosition;
    }
    public function get lastPosition() : int
    {
        return _lastPosition;
    }
    public function get hasKeyNum() : int
    {
        var pBagData : CBagData;
        for each(var item : LotteryConfig in m_configTable.tableMap)
        {
            if(item.activityId == curActivityId)
            {
                pBagData = (_bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(item.itemID);
                if(!pBagData)return 0;
                return pBagData.num;
            }
        }
        return 0
    }
    public function get needKeyNum() : int
    {
        for each(var item : LotteryConsume in m_consumeTable.tableMap)
        {
            if(item.activityID == curActivityId && item.counts == (count+1))
            {
                return item.consumeValue;
            }
        }
        return 0;
    }
    public function getItemDataByPosition(pos : int) : LotteryShow
    {
        for each(var item : LotteryShow in m_showTable.tableMap)
        {
            if(item.activityID == curActivityId && item.position == pos)
            {
                return item;
            }
        }
        return null;
    }
    public function set backCounts(value : int) : void
    {
        _backCounts = value;
    }
    public function get backCounts() : int
    {
        return _backCounts;
    }
    private function get _bagSystem() : CBagSystem
    {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
    private function get _system() : CLotteryActivitySystem
    {
        return system as CLotteryActivitySystem;
    }
}
}
