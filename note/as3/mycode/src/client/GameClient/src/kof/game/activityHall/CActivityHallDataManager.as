//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/31.
 */
package kof.game.activityHall {

import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.SYSTEM_TAG;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.activityHall.activeTask.CActiveTaskData;
import kof.game.activityHall.chargeActivity.CTotalChargeData;
import kof.game.activityHall.consumeActivity.CTotalConsumeData;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.data.CActivityState;
import kof.game.activityHall.event.CActivityHallTrigger;
import kof.game.activityHall.event.CActivityHallValidater;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.message.Activity.ActivityStateDataResponse;
import kof.table.Activity;
import kof.table.ActivityPreviewData;
import kof.table.ConsumeActivity;
import kof.table.Item;
import kof.table.TotalRechargeConfig;

public class CActivityHallDataManager extends CAbstractHandler implements IUpdatable {

    //活动表
    private var m_activityTable : IDataTable;

    //累计消费表
    private var m_consumeActivityTable : IDataTable;
    public var consumeDiamond : int;
    public var consumeDiamondType : int;
    public var consumeReceivedList : Array = [];

    //累计充值表
    private var m_chargeActivityTable : IDataTable;
    public var chargeDiamond : int;
    public var chargeReceivedList : Array = [];

    //特惠商店
    private var m_discountShopTable : IDataTable;
    public var m_personalMap : Array = [];//个人购买信息
    public var m_serverMap : Array = [];//全服购买信息

    //活跃任务配置表
    private var m_activeTaskTable : IDataTable;
    public var m_activeTaskDataArr : Array = [];

    //活动预览配置
    private var m_previewTable : IDataTable;

    private var m_pValidater : CActivityHallValidater;
    private var m_pTrigger : CActivityHallTrigger;

    private var m_openActivityDic : CMap = new CMap();
    private var m_openActivityList : Vector.<CActivityHallActivityInfo> = new Vector.<CActivityHallActivityInfo>();
    private var m_dateHelper : Date = new Date();

    public function CActivityHallDataManager() {
    }

    override public function dispose() : void {
        super.dispose();

        m_pTrigger.dispose();
        m_pValidater.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_activityTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY );
        m_consumeActivityTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.TOTALCONSUME_ACTIVITY );
        m_chargeActivityTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.TOTALCHARGE_ACTIVITY );
        m_discountShopTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.DISCOUNT_SHOP );
        m_activeTaskTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVE_TASK );
        m_previewTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY_PREVIEW );

        var switchingSystem : CSwitchingSystem = system.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem;
        m_pValidater = new CActivityHallValidater( system );
        switchingSystem.addValidator( m_pValidater );
        m_pTrigger = new CActivityHallTrigger();
        switchingSystem.addTrigger( m_pTrigger );

        stopSystemBundle();//活动开放才开启

        return ret;
    }

    public function updateActivityState( activityId : int, state : int, paramObj : Object = null ) : void {
        var info : CActivityHallActivityInfo;
        if ( state == CActivityState.ACTIVITY_START ) {
            info = new CActivityHallActivityInfo();
            info.table = m_activityTable.findByPrimaryKey( activityId );
            if(!info.table) return;
            info.startTime = paramObj.startTick;
            info.endTime = paramObj.endTick;
            info.state = state;

            if ( info.table.type == CActivityHallActivityType.CONSUME ) {
                (system.getBean( CActivityHallHandler ) as CActivityHallHandler).onConsumeActivityRequest( info.table.ID );
                m_openActivityDic.add( activityId, info, true );
            } else if ( info.table.type == CActivityHallActivityType.CHARGE ) {
                (system.getBean( CActivityHallHandler ) as CActivityHallHandler).onChargeActivityRequest();
                m_openActivityDic.add( activityId, info, true );
            } else if ( info.table.type == CActivityHallActivityType.DISCOUNT ) {
                (system.getBean( CActivityHallHandler ) as CActivityHallHandler).onDiscounterRequest();
                m_openActivityDic.add( activityId, info, true );
            } else if ( info.table.type == CActivityHallActivityType.ACTIVE_TASK ) {
                (system.getBean( CActivityHallHandler ) as CActivityHallHandler).onLivingTaskActivityDataRequest();
                m_openActivityDic.add( activityId, info, true );
            }
        }
        else if ( state >= CActivityState.ACTIVITY_END )//结束或关闭
        {
            m_openActivityDic.remove( activityId );
        }
        checkHavePreviewData();
    }

    /**
     * 当数据发生变化时，校验活动入口是否开启
     */
    public function checkHavePreviewData() : void
    {
        var bool : Boolean = previewDataArray && previewDataArray.length > 0;//有预览活动
        if(bool || m_openActivityDic.length > 0)
            startSystemBundle();
        else
            stopSystemBundle();
    }
    public function startSystemBundle() : void {
        if((system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.ACTIVITY_HALL))
        {
            return;
        }

        m_pValidater.valid = true;
//        m_pTrigger.notifyUpdated();
        var switchingSystem:CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        var pValidators : CSwitchingValidatorSeq = switchingSystem.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
        if ( pValidators )
        {
            if ( pValidators.evaluate() )// 验证所有开启条件是否已达成
            {
                var vResult : Vector.<String> = pValidators.listResultAsTags();
                if ( vResult && vResult.length )
                {
                    if(vResult.indexOf(KOFSysTags.ACTIVITY_HALL) != -1)
                    {
                        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
                        if ( pSystemBundleContext ) {
                            pSystemBundleContext.startBundle( system as ISystemBundle );
                        }
                    }
                }
            }
        }
    }

    public function stopSystemBundle() : void {
        m_pValidater.valid = false;
        m_pTrigger.notifyUpdated();
        (system as CActivityHallSystem).onViewClosed();
        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext ) {
            pSystemBundleContext.stopBundle( system as ISystemBundle );
        }
    }
    public function getActivityType( activityId : int ) : int {
        var activityConfig : Activity = m_activityTable.findByPrimaryKey( activityId );
        if ( activityConfig ) {
            return activityConfig.type;
        }
        else {
            return 0;
        }
    }

    //获取可开启的活动id列表
    public function getOpenedActivityList() : Vector.<CActivityHallActivityInfo> {
        m_openActivityList.length = 0;
        for each( var info : CActivityHallActivityInfo in m_openActivityDic )
        {
            m_openActivityList.push( info );
        }
        return m_openActivityList;
    }

    //获取特惠商店excele信息
    public function getDiscountShopConfigs( activityId : int ) : Array {
        return m_discountShopTable.findByProperty( "activityID", activityId );
    }

    //获取已购买次数，不要传类型为NO_LIMIT
    public function getCanBuyTimesInShop( type : int, id : int ) : int {
        if ( type == CActivityHallActivityType.NO_LIMIT ) return 0;

        var tempArray : Array = type == CActivityHallActivityType.PERSON_LIMIT ? m_personalMap : m_serverMap;
        var len : int = tempArray.length;
        for ( var i : int = 0; i < len; i++ ) {
            if ( tempArray[ i ].goodsID == id ) {
                return tempArray[ i ].count;
            }
        }
        return 0;
    }

    public function getTotalConsumeConfigs( activityId : int, needSort : Boolean = true ) : Array {
        var configArray : Array = m_consumeActivityTable.findByProperty( "activityId", activityId );
        if ( configArray && configArray.length > 0 ) {
            var dataArray : Array = [];
            var config : ConsumeActivity;
            var consumeData : CTotalConsumeData;
            var len : int = configArray.length;
            for ( var i : int = 0; i < len; i++ ) {
                config = configArray[ i ];
                var hasRecivedTimes : int = getConsumeRecivedTimes( config.consume );
                var totalTimes : int = consumeDiamond / config.consume;
                totalTimes = totalTimes > config.limit ? config.limit : totalTimes;
                var leftTimes : int = totalTimes - hasRecivedTimes;
                leftTimes = leftTimes < 0 ? 0 : leftTimes;

                consumeData = new CTotalConsumeData();
                consumeData.config = config;
                consumeData.leftTimes = leftTimes;
                dataArray.push( consumeData );
            }

            if ( needSort ) dataArray.sort( sortConsumeDataFunc );
            return dataArray;
        }
        return null;
    }

    //获取累计消费已领取次数
    public function getConsumeRecivedTimes( diamond : int ) : int {
        var len : int = consumeReceivedList.length;
        for ( var i : int = 0; i < len; i++ ) {
            if ( consumeReceivedList[ i ].diamond == diamond ) {
                return consumeReceivedList[ i ].count;
            }
        }
        return 0;
    }

    private function sortConsumeDataFunc( data1 : CTotalConsumeData, data2 : CTotalConsumeData ) : int {
        if ( data1.leftTimes > 0 && data2.leftTimes == 0 ) {
            //可领取排前面
            return -1;
        }
        else if ( data1.leftTimes == 0 && data2.leftTimes > 0 ) {
            //可领取排前面
            return 1;
        }
        else if ( data1.leftTimes > 0 && data2.leftTimes > 0 ) {
            //可领取中，金额高的排前面
            return data1.config.consume > data2.config.consume ? -1 : 1;
        }
        else if ( data1.leftTimes == 0 && data2.leftTimes == 0 ) {
            //都不可领取,未达成的排前面
            if ( consumeDiamond >= data1.config.consume && consumeDiamond < data2.config.consume ) {
                return 1;
            }
            else if ( consumeDiamond >= data2.config.consume && consumeDiamond < data1.config.consume ) {
                return -1;
            }
            //已完成的排最后
            return data1.config.consume > data2.config.consume ? 1 : -1;
        }
        return 0;
    }

    //获取累计充值数据
    public function getTotalChargeConfigs( activityId : int, needSort : Boolean = true ) : Array {
        var configArray : Array = m_chargeActivityTable.findByProperty( "activityId", activityId );
        if ( configArray && configArray.length > 0 ) {
            var dataArray : Array = [];
            var config : TotalRechargeConfig;
            var chargeData : CTotalChargeData;
            var len : int = configArray.length;
            for ( var i : int = 0; i < len; i++ ) {
                config = configArray[ i ];
                var hasRecivedTimes : int = getChargeRecivedTimes( config.rechargeValue );
                var totalTimes : int = chargeDiamond / config.rechargeValue;
                totalTimes = totalTimes > config.limit ? config.limit : totalTimes;
                var leftTimes : int = totalTimes - hasRecivedTimes;
                leftTimes = leftTimes < 0 ? 0 : leftTimes;

                chargeData = new CTotalChargeData();
                chargeData.config = config;
                chargeData.leftTimes = leftTimes;
                dataArray.push( chargeData );
            }

            if ( needSort ) dataArray.sort( sortChargeDataFunc );
            return dataArray;
        }
        return null;
    }

    //获取当前档已领取次数
    public function getChargeRecivedTimes( diamond : int ) : int {
        var len : int = chargeReceivedList.length;
        for ( var i : int = 0; i < len; i++ ) {
            if ( chargeReceivedList[ i ].rechargeValue == diamond ) {
                return chargeReceivedList[ i ].count;
            }
        }
        return 0;
    }

    private function sortChargeDataFunc( data1 : CTotalChargeData, data2 : CTotalChargeData ) : int {
        if ( data1.leftTimes > 0 && data2.leftTimes == 0 ) {
            //可领取排前面
            return -1;
        }
        else if ( data1.leftTimes == 0 && data2.leftTimes > 0 ) {
            //可领取排前面
            return 1;
        }
        else if ( data1.leftTimes > 0 && data2.leftTimes > 0 ) {
            //可领取中，金额高的排前面
            return data1.config.rechargeValue > data2.config.rechargeValue ? -1 : 1;
        }
        else if ( data1.leftTimes == 0 && data2.leftTimes == 0 ) {
            //都不可领取,未达成的排前面
            if ( chargeDiamond >= data1.config.rechargeValue && chargeDiamond < data2.config.rechargeValue ) {
                return 1;
            }
            else if ( chargeDiamond >= data2.config.rechargeValue && chargeDiamond < data1.config.rechargeValue ) {
                return -1;
            }
            //已完成的排最后
            return data1.config.rechargeValue > data2.config.rechargeValue ? 1 : -1;
        }
        return 0;
    }

    //获取活跃任务配置数据
    public function getActiveTaskConfigs( activityId : int ) : Array {
        return m_activeTaskTable.findByProperty( "activityId", activityId );
    }

    //获取活跃任务信息
    public function getActiveTaskInfos() : Array {
        return this.m_activeTaskDataArr;
    }

    public function sortActiveTaskData() : void {
        this.m_activeTaskDataArr.sort( sortActiveTaskDataFunc );
    }

    private function sortActiveTaskDataFunc( data1 : CActiveTaskData, data2 : CActiveTaskData ) : int {
        var t1 : int;
        var t2 : int;
        //第一轮，依据领取状态判定，可领取最前，未完成其次，已领取最末
        if ( data1.state == 0 ) {
            t1 = 1;
        }
        else if ( data1.state == 1 ) {
            t1 = 0;
        }
        else if ( data1.state == 2 ) {
            t1 = 2;
        }
        if ( data2.state == 0 ) {
            t2 = 1;
        }
        else if ( data2.state == 1 ) {
            t2 = 0;
        }
        else if ( data2.state == 2 ) {
            t2 = 2;
        }

        //第一轮排序平序状态下，做第二轮，依据id大小判定
        if ( t1 == t2 ) {
            t1 = data1.config.ID;
            t2 = data2.config.ID;
        }

        return t1 - t2;
    }

    public function getYearMonthDateByTime( time : Number ) : String {
        m_dateHelper.setTime( time );
        return "#1年#2月#3日".replace( "#1", m_dateHelper.fullYear ).replace( "#2", m_dateHelper.month + 1 ).replace( "#3", m_dateHelper.date );
    }

    public function getItemTableByID( id : int ) : Item {
        var itemTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ITEM );
        return itemTable.findByPrimaryKey( id );
    }

    //判断是否有消费奖励可领取
    public function hasConsumeReward() : Boolean {
        var list : Vector.<CActivityHallActivityInfo> = getOpenedActivityList();
        for ( var i : int = 0; i < list.length; i++ ) {
            if ( list[ i ].table.type == CActivityHallActivityType.CONSUME ) {
                var tempList : Array = getTotalConsumeConfigs( list[ i ].table.ID, false );
                if ( tempList ) {
                    var data : CTotalConsumeData;
                    for ( i = 0; i < tempList.length; i++ ) {
                        data = tempList[ i ];
                        if ( data.leftTimes > 0 ) return true;
                    }
                }
            }
        }
        return false;
    }

    //判断是否有充值奖励可以领取
    public function hasTotalChargeReward() : Boolean {
        var list : Vector.<CActivityHallActivityInfo> = getOpenedActivityList();
        for ( var i : int = 0; i < list.length; i++ ) {
            if ( list[ i ].table.type == CActivityHallActivityType.CHARGE ) {
                var tempList : Array = getTotalChargeConfigs( list[ i ].table.ID, false );
                if ( tempList ) {
                    var data : CTotalChargeData;
                    for ( i = 0; i < tempList.length; i++ ) {
                        data = tempList[ i ];
                        if ( data.leftTimes > 0 ) return true;
                    }
                }
            }
        }
        return false;
    }

    //判断是否有活跃任务奖励可以领取
    public function hasActiveTaskReward() : Boolean {
        var list : Vector.<CActivityHallActivityInfo> = getOpenedActivityList();
        for ( var i : int = 0; i < list.length; i++ ) {
            if ( list[ i ].table.type == CActivityHallActivityType.ACTIVE_TASK ) {
                for ( var j : int = 0; j < m_activeTaskDataArr.length; j++ ) {
                    var activeTaskData : CActiveTaskData = m_activeTaskDataArr[ j ];
                    if ( activeTaskData.state == 1 ) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * 活动投放的格斗家
     * @param activityIds<int> 已经开启过的所有的活动列表
     * @return
     */
    public function updateActivityOpenHeros( activityIds : Array ) : void {
        var resultArr : Array = [];
        if(activityIds && activityIds.length)
        {
            for each( var id : int in activityIds ) {
                var activityTable : Activity = _activity.findByPrimaryKey( id ) as Activity;
                if ( activityTable && activityTable.heroIds ) {
                    var arr : Array = activityTable.heroIds.split( "#" );
                    if ( arr && arr.length ) {
                        for each( var heroId : String in arr ) {
                            if ( resultArr.indexOf( heroId ) == -1 ) {
                                resultArr.push( heroId );
                            }
                        }
                    }
                }
            }
        }

        (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.activityHeroIds = resultArr;
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.updateActivityAddHero();
    }

    /**
     * 根据活动ID和系统ID获取活动预览配置
     */
    public function getPreviewDataByType(type : int = -1,sysID : int = 0) : ActivityPreviewData
    {
        for each (var item : ActivityPreviewData in m_previewTable.tableMap)
        {
            if(item.type == type || item.sysID == sysID)
            {
                return item;
            }
        }
        return null;
    }
    private var _isFirstOpenPreview : Boolean;//首次登录显示红点
    public function set isFirstOpenPreview(value : Boolean) : void
    {
        _isFirstOpenPreview = value;
    }
    public function get isFirstOpenPreview() : Boolean
    {
        return _isFirstOpenPreview;
    }
    private var _previewDic : Dictionary;//活动预览数据
    public function updatePreviewDic(obj : Object) : void
    {
        var item : ActivityPreviewData = getPreviewDataByType(-1,obj.sysID);
        if(!item) return;//过滤未配置的活动
        obj.ID = item.ID;//用于排序
        //此处过滤已关闭活动，系统活动state==1为开启，配置活动state==2为开启
        if((item.type == 0 && obj.state == 1 ) || (item.type > 0 && obj.state == 2 ))
        {
            _previewDic ||= new Dictionary();
            _previewDic[obj.sysID] = obj;
            isFirstOpenPreview = true;
        }
    }
    public function get previewDataArray() : Array
    {
        var item : ActivityPreviewData;
        var isOpen : Boolean;
        var result : Array = [];
        for each(var obj:Object in _previewDic)
        {
            item = getPreviewDataByType(-1,obj.sysID);
            isOpen = (system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(SYSTEM_TAG(item.sysID));
            if(isOpen)//系统未开启，过滤该活动
                result.push(obj);
        }
        result.sortOn("ID",Array.NUMERIC);
        return result;
    }
    public function update( delta : Number ) : void {
    }

//==========================================table==================================================
    private function get _dataBase() : IDatabase {
        return system.stage.getSystem( IDatabase ) as IDatabase;
    }

    private function get _activity() : IDataTable {
        return _dataBase.getTable( KOFTableConstants.ACTIVITY );
    }
}
}
