//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/10/19.
 */
package kof.game.openServerActivity {

import QFLib.Interface.IUpdatable;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.openServerActivity.data.COpenServerTargetData;
import kof.game.switching.CSwitchingSystem;
import kof.table.Activity;
import kof.table.CarnivalActivityConfig;
import kof.table.CarnivalEntryConfig;
import kof.table.CarnivalRewardConfig;
import kof.table.CarnivalTargetConfig;

public class COpenServerActivityManager extends CAbstractHandler implements IUpdatable {

    private var _activityTable : IDataTable;
    private var _activityConfigTable : IDataTable;
    private var _activityEntryTable : IDataTable;
    private var _activityTargetTable : IDataTable;
    private var _activityRewardTable : IDataTable;

    private var m_pValidater : COpenServerActivityValidater;
    private var m_pTrigger : COpenServerActivityTrigger;

    public var curActivityId : int = 0;
    public var curActivityState : int = 0;
    public var startTime : Number = 0.0;
    public var endTime : Number = 0.0;

    private var _openActivityIds : Array = [];
    private var _targetInfoList : Array = [];
    private var _isGetRewardList : Array = [];

    private var m_dateHelper : Date = new Date();

    public function COpenServerActivityManager() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _activityTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ACTIVITY );
        _activityConfigTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.CARNIVALACTIVITY_CONFIG );
        _activityEntryTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.CARNIVALACTIVITY_ENTRY_CONFIG );
        _activityTargetTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.CARNIVALACTIVITY_TARGET_CONFIG );
        _activityRewardTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.CARNIVALACTIVITY_REWARD_CONFIG );

        var switchingSystem : CSwitchingSystem = system.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem;
        m_pValidater = new COpenServerActivityValidater( system );
        switchingSystem.addValidator( m_pValidater );
        m_pTrigger = new COpenServerActivityTrigger( system as COpenServerActivitySystem );
        switchingSystem.addTrigger( m_pTrigger );

        return ret;
    }

    public function update( delta : Number ) : void {

    }

    public function updateTargetInfoList( arr : Array ) : void {
        for each( var info : Object in arr ) {
            var targetData : COpenServerTargetData = new COpenServerTargetData();
            targetData.updateDataByData( info );
            targetInfoList.push( targetData );
        }
    }

    public function getActivity() : Activity {
        if ( curActivityId == 0 )return null;
        return _activityTable.findByPrimaryKey( curActivityId ) as Activity;
    }

    public function getActivityConfigById( id : int ) : CarnivalActivityConfig {
        return _activityConfigTable.findByPrimaryKey( id ) as CarnivalActivityConfig;
    }

    public function getActivityLabelById( id : int ) : CarnivalEntryConfig {
        return _activityEntryTable.findByPrimaryKey( id ) as CarnivalEntryConfig;
    }

    public function getActivityLabelByName( name : String ) : CarnivalEntryConfig {
        var arr : Array = _activityEntryTable.findByProperty( "name", name );
        if ( arr && arr.length > 0 ) {
            return (arr[ 0 ] as CarnivalEntryConfig);
        }
        return null;
    }

    public function getActivityLabels( id : int ) : Array {
        var activityConfig : CarnivalActivityConfig = getActivityConfigById( id );
        var labelConfig : CarnivalEntryConfig = null;
        var labelArr : Array = [];
        if ( activityConfig && activityConfig.entryIds && activityConfig.entryIds.length > 0 ) {
            for each( var labelId : int in activityConfig.entryIds ) {
                labelConfig = getActivityLabelById( labelId );
                if ( labelConfig ) {
                    labelArr.push( labelConfig.name );
                }
            }
        }
        return labelArr;
    }

    public function getActivityTargetsConfig( entryIds : Array ) : Array {
        var entryConfig : CarnivalTargetConfig = null;
        var entryArr : Array = [];
        for each( var id : int in entryIds ) {
            entryConfig = _activityTargetTable.findByPrimaryKey( id ) as CarnivalTargetConfig;
            if ( entryConfig ) {
                entryArr.push( entryConfig );
            }
        }
        return entryArr;
    }

    public function sortActivityTargetsConfig( targetArr : Array ) : void {
        targetArr.sort( _sortFun );
    }

    private function _sortFun( data1 : CarnivalTargetConfig, data2 : CarnivalTargetConfig ) : int {
        var openServerManager : COpenServerActivityManager = system.getBean( COpenServerActivityManager ) as COpenServerActivityManager;
        var t1 : int;
        var t2 : int;
        var isGet1 : Boolean = openServerManager.isGetTargetReward( data1.ID );
        if ( isGet1 ) {
            t1 = 2;
        } else {
            var isCan1 : Boolean = openServerManager.isCanTargetReward( data1.ID );
            if ( isCan1 ) {
                t1 = 0;
            } else {
                t1 = 1;
            }
        }

        var isGet2 : Boolean = openServerManager.isGetTargetReward( data2.ID );
        if ( isGet2 ) {
            t2 = 2;
        } else {
            var isCan2 : Boolean = openServerManager.isCanTargetReward( data2.ID );
            if ( isCan2 ) {
                t2 = 0;
            } else {
                t2 = 1;
            }
        }

        //第一轮排序平序状态下，做第二轮，依据id大小判定
        if ( t1 == t2 ) {
            t1 = data1.ID;
            t2 = data2.ID;
        }

        return t1 - t2;
    }


    public function getActivityLabelConfig( id : int ) : Array {
        var activityConfig : CarnivalActivityConfig = getActivityConfigById( id );
        var labelConfig : CarnivalEntryConfig = null;
        var labelArr : Array = [];
        if ( activityConfig && activityConfig.entryIds && activityConfig.entryIds.length > 0 ) {
            for each( var labelId : int in activityConfig.entryIds ) {
                labelConfig = getActivityLabelById( labelId );
                if ( labelConfig ) {
                    labelArr.push( labelConfig );
                }
            }
        }
        return labelArr;
    }

    public function getActivityType( activityId : int ) : int {
        var activityConfig : Activity = _activityTable.findByPrimaryKey( activityId );
        if ( activityConfig ) {
            return activityConfig.type;
        }
        else {
            return 0;
        }
    }

    //字符串格式2017-07-18 00:00:00
    public function getTimeByString( timeStr : String ) : Number {
        var tempArray : Array = timeStr.split( " " );
        var dateArray : Array = tempArray[ 0 ].split( "-" );
        var timeArray : Array = tempArray[ 1 ].split( ":" );
        m_dateHelper.setFullYear( dateArray[ 0 ], dateArray[ 1 ] - 1, dateArray[ 2 ] );
        m_dateHelper.setHours( timeArray[ 0 ], timeArray[ 1 ], timeArray[ 2 ] );
        return m_dateHelper.time;
    }

    public function isActivityClosed() : Boolean {
        var acvitityConfig : Activity = getActivity();
        if ( acvitityConfig == null )return false;
        return false;
    }

    private function get openServerSystem() : COpenServerActivitySystem {
        return system as COpenServerActivitySystem;
    }

    public function get openActivityIds() : Array {
        return _openActivityIds;
    }

    public function set openActivityIds( value : Array ) : void {
        _openActivityIds = value;
    }

    public function get targetInfoList() : Array {
        return _targetInfoList;
    }

    public function set targetInfoList( value : Array ) : void {
        _targetInfoList = value;
    }

    public function get isGetRewardList() : Array {
        return _isGetRewardList;
    }

    public function set isGetRewardList( value : Array ) : void {
        _isGetRewardList = value;
    }


    public function addActivityId( id : int ) : void {
        if ( _openActivityIds ) {
            _openActivityIds.push( id );
        }
    }

    public function addTargetInfoToList( targetInfos : Array ) : void {
        for each( var info : Object in targetInfos ) {
            var targetData : COpenServerTargetData = new COpenServerTargetData();
            targetData.updateDataByData( info );
            targetInfoList.push( targetData );
        }
    }

    public function updateTargetInfo( targetInfo : Object ) : void {
        for each( var target : COpenServerTargetData in targetInfoList ) {
            if ( target.targetId == targetInfo.targetId ) {
                target.updateDataByData( targetInfo );
            }
        }
    }

    public function updateTargetById( targetId : int ) : void {
        for each( var target : COpenServerTargetData in targetInfoList ) {
            if ( target.targetId == targetId ) {
                target.isObtained = true;
//                if(target.leftNum > 0 ){
//                    target.leftNum = target.leftNum - 1;
//                }
                target.obtainedNum++;
            }
        }
    }

    public function isGetReward( id : int ) : Boolean {
        var index : int = _isGetRewardList.indexOf( id );
        if ( index != -1 ) {
            return true;
        }
        return false;
    }

    public function getRewardList() : Array {
        return _activityRewardTable.toArray();
    }

    public function getTargetInfoById( targetId : int ) : COpenServerTargetData {
        for each( var info : COpenServerTargetData in _targetInfoList ) {
            if ( info.targetId == targetId ) {
                return info;
            }
        }
        return null;
    }

    /**
     * 目标奖励是否已经领取
     * @param targetId
     * @return
     */
    public function isGetTargetReward( targetId : int ) : Boolean {
        for each( var info : COpenServerTargetData in _targetInfoList ) {
            if ( info.targetId == targetId ) {
                return info.isObtained;
            }
        }
        return false;
    }

    /**
     * 目标奖励是否能够领取
     * @return
     */
    public function isCanTargetReward( targetId : int ) : Boolean {
        for each( var info : COpenServerTargetData in _targetInfoList ) {
            if ( info.targetId == targetId ) {
                return info.isComplete;
            }
        }
        return false;
    }

    /**
     * 活动是否开启
     * @param day 第几天
     * @return
     */
    public function isStartActivityByDay( day : int = 1 ) : Boolean {
        var index : int = _openActivityIds.indexOf( day );
        if ( index != -1 ) {
            return true;
        }
        return false;
    }

    /**
     * 获取目标完成的数量
     * @return
     */
    public function getTargetComlpeteNum() : int {
        var completeNum : int = 0;
        for each( var info : COpenServerTargetData in _targetInfoList ) {
            if ( info.isComplete ) {
                completeNum++;
            }
        }
        return completeNum;
    }

    public function getCompleteRewardConfigByMyScore( num : int ) : CarnivalRewardConfig {
        var rewardArr : Array = _activityRewardTable.toArray();
        rewardArr.sortOn( "ID", Array.NUMERIC );
        var maxNum : int = getComplteNumMax();
        if ( num >= maxNum ) {
            num = maxNum;
        }
        for each( var rewardTb : CarnivalRewardConfig in rewardArr ) {
            if ( num <= rewardTb.completeNum ) {
                return rewardTb;
            }
        }
        return rewardArr[ 0 ];
    }

    public function getComplteNumMax() : int {
        var rewardArr : Array = _activityRewardTable.toArray();
        rewardArr.sortOn( "ID", Array.NUMERIC );
        var maxNum : int = 0;
        for each( var rewardTb : CarnivalRewardConfig in rewardArr ) {
            if ( maxNum <= rewardTb.completeNum ) {
                maxNum = rewardTb.completeNum;
            }
        }
        return maxNum;
    }


    public function getRewardConfigById( id : int ) : CarnivalRewardConfig {
        return _activityRewardTable.findByPrimaryKey( id ) as CarnivalRewardConfig;
    }

    public function isShowRedByDay( day : int ) : Boolean {
        if( isStartActivityByDay( day ) == false ){
            return false;
        }
        var activityConfig : CarnivalActivityConfig = getActivityConfigById( day );
        var entryConfig : CarnivalEntryConfig = null;
        var targetConfig : CarnivalTargetConfig = null;
        if ( activityConfig && activityConfig.entryIds && activityConfig.entryIds.length > 0 ) {
            for each( var labelId : int in activityConfig.entryIds ) {
                entryConfig = getActivityLabelById( labelId );
                for each( var id : int in entryConfig.targetIds ) {
                    targetConfig = _activityTargetTable.findByPrimaryKey( id ) as CarnivalTargetConfig;
                    if ( targetConfig ) {
                        for each( var info : COpenServerTargetData in _targetInfoList ) {
                            if ( info.targetId == targetConfig.ID ) {
//                                if(info.isComplete && !info.isObtained && info.leftNum > 0){
                                if ( info.isComplete && !info.isObtained && info.obtainedNum < targetConfig.maxNum ) {
                                    //能够领取奖励，但是未领的，并且剩余数量大于0
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    public function isShowRedByLabel( label : String ) : Boolean {
        var entryConfig : CarnivalEntryConfig = getActivityLabelByName( label );
        var targetConfig : CarnivalTargetConfig = null;
        if ( entryConfig ) {
            for each( var id : int in entryConfig.targetIds ) {
                targetConfig = _activityTargetTable.findByPrimaryKey( id ) as CarnivalTargetConfig;
                if ( targetConfig ) {
                    for each( var info : COpenServerTargetData in _targetInfoList ) {
                        if ( info.targetId == targetConfig.ID ) {
//                            if(info.isComplete && !info.isObtained && info.leftNum > 0){
                            if ( info.isComplete && !info.isObtained && info.obtainedNum < targetConfig.maxNum ) {
                                //能够领取奖励，但是未领的，并且剩余数量大于0
                                return true;
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    public function updateRedPoint() : void {

        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.CARNIVAL_ACTIVITY ) );
        var iStateValue : int = pSystemBundleContext.getSystemBundleState( pSystemBundle );
        var bundle : ISystemBundle;
        if ( iStateValue == CSystemBundleContext.STATE_STOPPED ) {
            return;
        }
        var isShow : Boolean = false;
        for ( var i : int = 1; i < 8; i++ ) {
            var flag : Boolean = isShowRedByDay( i );
            if ( flag ) {
                isShow = flag;
                break;
            }
        }


        if ( isShow ) {
            if ( pSystemBundleContext && pSystemBundle ) {
                pSystemBundleContext.setUserData( system as COpenServerActivitySystem, CBundleSystem.NOTIFICATION, true );
            }
        } else {
            if ( pSystemBundleContext && pSystemBundle ) {
                pSystemBundleContext.setUserData( system as COpenServerActivitySystem, CBundleSystem.NOTIFICATION, false );
            }
        }
    }

    /**
     * 关闭系统入口
     * **/
    public function closeOpenActivity() : void {
        openServerSystem.onViewClosed();
        m_pValidater.valid = false;
        m_pTrigger.notifyUpdated();
        openServerSystem.closeOpenActivity();
    }

    public function openActivity() : void {
        m_pValidater.valid = true;
        m_pTrigger.notifyUpdated();
    }

}
}
