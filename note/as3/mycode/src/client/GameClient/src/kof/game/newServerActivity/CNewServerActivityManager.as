//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/8/10.
 */
package kof.game.newServerActivity {

import QFLib.Foundation.CTime;
import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.bundle.ISystemBundleContext;
import kof.game.newServerActivity.data.CActivityRewardConfig;
import kof.game.newServerActivity.data.CNewServerActivityData;
import kof.game.newServerActivity.event.CNewServerActivityEvent;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.message.Activity.ServerActivityPrizeResponse;
import kof.table.ServerActivity;

public class CNewServerActivityManager extends CAbstractHandler implements IUpdatable {

    private var m_pNewServerActivityTable : IDataTable;//新服活动数据表
    private var m_iOpenServerDays : int;//开服天数
    private var m_iCurActivityID : int;//当前活动id
    private var m_pCurActivity : ServerActivity;
    private var m_activityReward : Array;
    private var m_iFirstReward : int;
    private var m_pCurActivityData : CNewServerActivityData;
    private var m_curActivityStartTime : Date;
    private var m_curActivityEndTime : Date;
    private var m_curActivityRankArr : Array;//活动排行榜数据
    private var m_activityList : Array = new Array();//所有活动的列表
    public var m_curDay : int ;
    public var m_allFinishFlg : Boolean;
    public static var last_day : int = 7;

    public var actiivityTypeArray : Array = [ "等级" ,"竞技场排名" ,"斗魂" ,"神器总等级" ,"格斗家总星级", "装备总星级","战斗力" ];

    public function CNewServerActivityManager() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        var pPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        if (pPlayerSystem) {
            pPlayerSystem.removeEventListener(CPlayerEvent.PLAYER_SYSTEM,_onPlayerDataUpdate);
        }
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_pNewServerActivityTable = ( system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem ).getTable( KOFTableConstants.NEW_SERVER_ACTIVITY );//获取数据表
        var pPlayerSystem : CPlayerSystem = ( system.stage.getSystem( CPlayerSystem ) as CPlayerSystem );
        pPlayerSystem.addEventListener(CPlayerEvent.PLAYER_SYSTEM,_onPlayerDataUpdate);
        playerDataUpdate();

        return ret;
    }

    /**
     * 开服天数更新
     * **/
    private function _onPlayerDataUpdate( e : CPlayerEvent ) : void {
        //要判断是不是openserverday更新
        if( m_iOpenServerDays != pCPlayerData.systemData.openSeverDays )
        {
            playerDataUpdate();
            system.dispatchEvent( new CNewServerActivityEvent( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DAY_UPDATE ) );
        }
    }

    /**
     * 开服天数更新
     * */
    public function playerDataUpdate() : void {
        m_iOpenServerDays = pCPlayerData.systemData.openSeverDays;

        //如果活动结束，关闭系统入口
        if ( isActivityClosed() ) {
            closeNewServerActivity();
        }
    }

    private function get pCPlayerData() : CPlayerData {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }

    public function get openSeverDays() : int //开服时间获取
    {
        return m_iOpenServerDays;
    }

    /**
     * 通过id获取活动配置
     * **/
    public function getActivityInfoById( id : int ) : ServerActivity {
        return m_pNewServerActivityTable.findByPrimaryKey( id );
    }

    /**
     * 更新数据
     * **/
    public function updateActivityData( activityID : int ) : void {
        var activityData : ServerActivity = getActivityInfoById( activityID );
        m_pCurActivity = activityData;
        m_activityReward = new Array();
        //把排名奖励加入到array中
        var rankRewardStr : String = m_pCurActivity.rankPrize.slice( 1, m_pCurActivity.rankPrize.length - 1 );
        var rankArr : Array = rankRewardStr.split( ";" );
        for each( var str : String in rankArr ) {
            var arr1 : Array = str.split( ":" );
            var activityReward : CActivityRewardConfig = new CActivityRewardConfig();
            if ( m_activityReward.length > 0 ) {
                if ( m_activityReward[ m_activityReward.length - 1 ].rewardType == 1 ) {
                    activityReward.pre_goal = m_activityReward[ m_activityReward.length - 1 ].goal + 1;
                }
            }
            activityReward.goal = int( arr1[ 0 ] );
            activityReward.rewardID = int( arr1[ 1 ] );
            activityReward.rewardType = 1;
            if ( activityID < openSeverDays ) //可以显示邮件发放奖励了
            {
                activityReward.canGet = true;
            }
            //获取第一名的奖励
            if ( activityReward.goal == 1 ) {
                activityReward.pre_goal = 1;
                m_iFirstReward = activityReward.rewardID;
            }
            else {
                m_activityReward.push( activityReward );
            }
        }
        //删除阶段奖励
        //把阶段奖励存到数组中
        /*var m_stageRewards : Array = new Array();//存储不能领取的的阶段奖励
        var m_stageGetedRewards : Array = new Array();//已经领取的奖励
        if ( m_pCurActivity ) {
            //先把可以领取的阶段奖励加入到array中
            var stageRewardStr : String = m_pCurActivity.stagePrize.slice( 1, m_pCurActivity.stagePrize.length - 1 );
            var strArr : Array = stageRewardStr.split( ";" );
            for ( var index : int = 0; index < strArr.length; index++ ) {
                var arr : Array = strArr[ index ].split( ":" );
                activityReward = new CActivityRewardConfig();
                activityReward.goal = int( arr[ 0 ] );
                activityReward.rewardID = int( arr[ 1 ] );
                activityReward.rewardType = 0;
                if ( _checkGiftActived( activityReward.goal ) ) //激活
                {
                    activityReward.canGet = true;
                    if ( !m_pCurActivityData.stageRewardState[ activityReward.goal ] )//没有领取
                    {
                        activityReward.hasGet = false;
                        m_activityReward.push( activityReward );
                    }
                    else {
                        activityReward.hasGet = true;
                        //m_stageRewards.push( activityReward );
                        m_stageGetedRewards.push(activityReward);
                    }
                }
                else {
                    activityReward.canGet = false;
                    activityReward.hasGet = false;
                    m_stageRewards.push( activityReward );
                }
            }
            //把不能领取的阶段奖励加入进array
            for each( var stageReward : CActivityRewardConfig in m_stageRewards ) {
                m_activityReward.push( stageReward );
            }
            //把已经领取过的奖励加入到array
            for each( var stageGetedReward : CActivityRewardConfig in m_stageGetedRewards )
            {
                m_activityReward.push(stageGetedReward);
            }
        }*/
    }


    private function _checkGiftActived( stage : int ) : Boolean {
        var result : Boolean = false;
        if ( m_pCurActivityData.stageRewardState != null ) {
            for ( var key : int in m_pCurActivityData.stageRewardState ) {
                if ( key == stage )//激活
                {
                    result = true;
                    break;
                }
            }
        }
        return result;
    }


    /**
     * 获取活动开始时间
     * **/
    public function curActivityStartTime( activityID : int ) : Date {
        var activityData : ServerActivity = getActivityInfoById( activityID );
        var startDay : int = activityData.activityTime.split( '-' )[ 0 ];//开服第几天活动开始
        var curTime : Number = CTime.getCurrServerTimestamp();
        var startServerTime : Number = curTime - (openSeverDays - startDay)*24*3600*1000;
        m_curActivityStartTime = new Date();
        m_curActivityStartTime.setTime( startServerTime );
        m_curActivityStartTime.setHours( 0,0,0,0);
        return m_curActivityStartTime;
    }

    /**
     * 当前活动的结束时间
     * **/
    public function curActivityEndTime( activityID : int ) : Date {
        var activityData : ServerActivity = getActivityInfoById( activityID );
        var endDay : int = activityData.activityTime.split( '-' )[ 1 ];//开服第几天活动结束
        var curTime : Number = CTime.getCurrServerTimestamp();
        var endTime : Number = curTime + ( endDay - openSeverDays )*24*3600*1000;
        m_curActivityEndTime = new Date();
        m_curActivityEndTime.setTime( endTime );
        m_curActivityEndTime.setHours( 21, 59, 59, 999);
        return m_curActivityEndTime;
    }

    /**
     * 服务器当前时间
     * **/
    public function curServerDate() : Date
    {
        var serverTime : Number = CTime.getCurrServerTimestamp();
        var serverDate : Date = new Date();
        serverDate.setTime( serverTime );
        return serverDate;
    }

    /**
     * 排名第一的奖励
     * **/
    public function get firstReward() : int
    {
        return m_iFirstReward;
    }
    /**
     * 排名奖励和目标奖励的数据
     * **/
    public function get activityRewards() : Array
    {
        return m_activityReward;
    }

    /***
     * 当前活动id
     * */
    public function set curActivityID( value : int ) : void
    {
        m_iCurActivityID = value;
    }
    public function get curActivityID() : int
    {
        return m_iCurActivityID;
    }
    /**
     * 活动配置数据
     * **/
    public function get activityInfo() : ServerActivity
    {
        return m_pCurActivity;
    }

    /**
     * 当前排行榜数据
     * **/
    public function get curActivityRankData() : Array
    {
        return m_curActivityRankArr;
    }
    /**
     * 更新排行榜数据
     * **/
    public function updateActivityRank( data : Object ) : void
    {
        if( !data ) return;
        m_curActivityRankArr = new Array();
        for( var i : int = 0; i < data["rankList" ].length ; i++ )
        {
            var obj : Object = new Object();
            obj.rank = data["rankList" ][ i ].rank;
            obj.name = data["rankList" ][ i ].name;
            obj.value = data["rankList"][ i ].value;
            obj._id = data["rankList"][ i ]._id;
            m_curActivityRankArr.push( obj );
        }
    }

    /***
     * 更新新服活动小红点数据
     * **/
    public function updateRedPointData( activityList : Array ) : void
    {
        m_activityList = activityList;
        system.dispatchEvent( new CNewServerActivityEvent( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_TIPS_UPDATE ) );
    }

    public function canGetReward() : Boolean
    {
        //修改为活动进行中就会显示小红点
        var result : Boolean = pCPlayerData.systemData.openSeverDays < 9 ? true : false;
        /*for( var i : int = 0 ; i < m_activityList.length ; i++ )
        {
            result = m_activityList[i]["prize"];
            if( result )
            {
                return result;
            }
        }*/
        return result;
    }

    public function isTimeOut():Boolean{
        var result : Boolean;
        var m_iCountDownTime : Number = curActivityEndTime( 7 ).getTime() - CTime.getCurrServerTimestamp();
        var remainDay : int = (int)( ( m_iCountDownTime - m_iCountDownTime % 86400000 ) / 86400000 );
        var remainTime : Number = m_iCountDownTime % 86400000;
        if ( m_iCountDownTime <= 0 ) {
            result = true;
        }
        return result;

    }

    public function get activityList() : Array
    {
        return m_activityList;
    }

    /**
     * 活动服务器数据
     * **/
    public function get activityData() : CNewServerActivityData
    {
        if( !m_pCurActivityData )
        {
            m_pCurActivityData = new CNewServerActivityData();
        }
        return m_pCurActivityData;
    }

    /**
     * 领取奖励返回数据
     * **/
    public function updataStageReward( response : ServerActivityPrizeResponse ) : void
    {
        var stageGoal : int = response.stage;
        var param : int = response.gamePromptID;
        if( param ==0 )//领取成功
        {
            _setStageRewardState(stageGoal);
        }
    }
    /**
     * 设置阶段奖励的领取状态
     * **/
    private function _setStageRewardState( stage : int ) : void
    {
        if( m_activityReward )
        {
            var activityReward : CActivityRewardConfig;
            for( var index : int = 0; index < m_activityReward.length; index++ )
            {
                activityReward = m_activityReward[index];
                if( activityReward.goal == stage && activityReward.rewardType == 0 )
                {
                    m_activityReward.splice(index,1);
                    break;
                }
            }
            var changeActivityReward : CActivityRewardConfig = activityReward;
            changeActivityReward.hasGet = true;
            m_activityReward.push( changeActivityReward );
            /*for( var i : int = m_activityReward.length - 1 ; i >= 1 ; i-- )
            {
                if( m_activityReward[ i ].rewardType == 0 && m_activityReward[ i-1 ].rewardType == 0 )
                {
                    if( m_activityReward[ i ].goal <  m_activityReward[ i-1 ].goal && m_activityReward[ i-1 ].canGet && !m_activityReward[ i-1 ].hasGet)
                    {
                        var temp : CActivityRewardConfig = m_activityReward[ i ];
                        m_activityReward[ i ] = m_activityReward[ i-1 ];
                        m_activityReward[ i -1 ] = temp;
                    }
                }
            }*/
        }
        //派发数据更新的事件
        system.dispatchEvent( new CNewServerActivityEvent( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DATE_UPDATE ) );
    }

    /**
     * 入榜单tips
     * **/
    public function getRankTips() : String
    {
        var tipStr : String = m_pCurActivity.describe;
        return tipStr;
    }

    /**
     * 活动是否结束
     * **/
    public function isActivityClosed() : Boolean
    {
        var isClosed : Boolean = false;
        if( m_iOpenServerDays >= last_day+1) //活动已结束
            isClosed = true;
        return isClosed;
    }
    /**
     * 关闭系统入口
     * **/
    public function closeNewServerActivity() : void
    {
        _system.changeActivityState(false);
        /*var pSystem : CNewServerActivitySystem = system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem;
        var sys : ISystemBundleContext = ( system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem).ctx;
        if( sys )
        {
            if ( sys.getSystemBundle( pSystem.bundleID ) )
                sys.unregisterSystemBundle( system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem );
        }*/
    }

    public function update ( delta : Number ) :void
    {

    }

    private function get _system() : CNewServerActivitySystem
    {
        return system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem;
    }
}
}
