//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity {

import QFLib.Foundation.CMap;
import QFLib.Foundation.CTime;
import QFLib.Interface.IUpdatable;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.limitActivity.data.CLimitScoreRankData;
import kof.game.limitActivity.enum.ELimitActivityState;
import kof.game.player.CPlayerSystem;
import kof.game.switching.CSwitchingSystem;
import kof.message.Activity.ActivityChangeResponse;
import kof.table.Activity;
import kof.table.Activity;
import kof.table.LimitTimeConsumeActivityConfig;
import kof.table.LimitTimeConsumeActivityConst;
import kof.table.LimitTimeConsumeActivityRankConfig;
import kof.table.LimitTimeConsumeActivityScoreConfig;

public class CLimitActivityManager extends CAbstractHandler implements IUpdatable {

    private var _rankRewardTable:IDataTable;
    private var _scoreRewardTable:IDataTable;
    private var _constTable:IDataTable;
    private var _consumeTable:IDataTable;
    private var _activityTable:IDataTable;

    private var _mySroce:int;
    private var _receiverList:Array = [];//已领取的奖励积分

    private var _myRank:int;
    private var _rankInfos:CLimitScoreRankData;

    private var m_pValidater : CLimitActivityValidater;
    private var m_pTrigger : CLimitActivityTrigger;

    public var curActivityId:int = 0;
    public var curActivityState:int = 0;
    public var startTime:Number = 0.0;
    public var endTime:Number = 0.0;

    private var m_dateHelper:Date = new Date();
    private var m_pActivityStateMap:CMap = new CMap();

    public function CLimitActivityManager() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _activityTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ACTIVITY);
        _rankRewardTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LIMITACTIVITY_RANKCONFIG);
        _scoreRewardTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LIMITACTIVITY_SCORECONFIG);
        _constTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LIMITACTIVITY_CONST);
        _consumeTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LIMITACTIVITY_CONSUME);

        var switchingSystem : CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        m_pValidater = new CLimitActivityValidater(system);
        switchingSystem.addValidator(m_pValidater);
        m_pTrigger = new CLimitActivityTrigger(system as CLimitActivitySystem);
        switchingSystem.addTrigger(m_pTrigger);

        if(_rankInfos == null){
            _rankInfos = new CLimitScoreRankData();
        }

        return ret;
    }

    public function update( delta : Number ) : void {

    }

    public function updateRankInfo(list:Array):void{
        var arr:Array = getScoreRankList();
        if(arr){
            _rankInfos.lenth = arr.length;
        }else{
            _rankInfos.lenth = 20;
        }
        _rankInfos.updateDataByData(list);
    }

    public function get rankInfos() : CLimitScoreRankData {
        return _rankInfos;
    }

    public function set rankInfos( value : CLimitScoreRankData ) : void {
        _rankInfos = value;
    }

    public function get myRank() : int {
        return _myRank;
    }

    public function set myRank( value : int ) : void {
        _myRank = value;
    }

    public function get mySroce() : int {
        return _mySroce;
    }

    public function set mySroce( value : int ) : void {
        _mySroce = value;
    }

    public function get receiverList() : Array {
        return _receiverList;
    }

    public function set receiverList( value : Array ) : void {
        _receiverList = value;
    }

    public function isGetReward(rewardId:int):Boolean{
        if(_receiverList && _receiverList.length > 0){
            var index:int = _receiverList.indexOf(rewardId);
            if(index != -1){
                return true;
            }
        }
        return false;
    }

    public function getScoreRewardList() : Array {
        return _scoreRewardTable.findByProperty("activityId",curActivityId);
    }

    public function getMaxScore():int {
        var scoreArr:Array = getScoreRewardList();
        var maxScore:int = 0;
        if(scoreArr)
        {
            for each(var scoreTb:LimitTimeConsumeActivityScoreConfig in scoreArr){
                if(scoreTb.score > maxScore){
                    maxScore = scoreTb.score;
                }
            }
        }

        return maxScore;
    }

    public function getScoreConfigByMyScore(score:int):LimitTimeConsumeActivityScoreConfig {
        var scoreArr:Array = getScoreRewardList();
        if(scoreArr)
        {
            scoreArr.sortOn("ID",Array.NUMERIC);
            for each(var scoreTb:LimitTimeConsumeActivityScoreConfig in scoreArr){
                if(score <= scoreTb.score){
                    return scoreTb;
                }else if(score >= getMaxScore()){
                    return scoreArr[scoreArr.length-1];
                }
            }
            return scoreArr[0];
        }

        return null;
    }

    public function getActivity() : Activity {
        if(curActivityId == 0)return null;
        return _activityTable.findByPrimaryKey(curActivityId) as Activity;
//        var activityArr:Array = _activityTable.findByProperty("type",EActivityType.ACTIVITY_TYPE_5);
//        if(activityArr && activityArr.length > 0){
//            var startTime:Number = 0.0;
//            var endTime:Number = 0.0;
//            var currTime:Number = 0.0;
//            var leftTime:Number = 0.0;
//            for each(var activity:Activity in activityArr){
//                startTime = getTimeByString(activity.startTime);
//                endTime = getTimeByString(activity.endTime);
//                currTime = CTime.getCurrServerTimestamp();
//                leftTime = endTime-currTime;
//                if(startTime <= currTime && currTime <= endTime){
//                    return activity;
//                }
//            }
//        }
//        return null;
    }

    public function getActivityType(activityId:int):int
    {
        var activityConfig:Activity = _activityTable.findByPrimaryKey(activityId);
        if(activityConfig)
        {
            return activityConfig.type;
        }
        else
        {
            return 0;
        }
    }

    public function getScoreRewardByID(id:int) : LimitTimeConsumeActivityScoreConfig {
        var arr:Array = getScoreRewardList();
        if(arr)
        {
            for each(var config:LimitTimeConsumeActivityScoreConfig in arr){
                if(config.ID == id){
                    return  config;
                }
            }
        }

        return null;
    }

    public function getScoreRewardByIndex(index:int) : LimitTimeConsumeActivityScoreConfig {
        var arr:Array = getScoreRewardList();
        if(arr)
        {
            for each(var config:LimitTimeConsumeActivityScoreConfig in arr){
                if(config.index == index){
                    return  config;
                }
            }
        }

        return null;
    }

    public function getScoreRankList() : Array {
        var arr:Array = _rankRewardTable.findByProperty("activityId",curActivityId);
        return arr;
    }

    public function getRankRewardTableByRank( rank:int) : LimitTimeConsumeActivityRankConfig {
        var arr:Array = _rankRewardTable.findByProperty("activityId",curActivityId);
        for each(var config:LimitTimeConsumeActivityRankConfig in arr){
            if(config.configId == rank){
                return config;
            }
        }
        return null;
    }

    public function getConstTableByID(id:int = 1) : LimitTimeConsumeActivityConst {
        return _constTable.findByPrimaryKey(id) as LimitTimeConsumeActivityConst;
    }

    public function getConsumeTable() : LimitTimeConsumeActivityConfig {
        return _consumeTable.findByPrimaryKey(curActivityId) as LimitTimeConsumeActivityConfig;
    }

    public function isHaveScoreReward():Boolean {
        var scoreArr:Array = getScoreRewardList();
        if(scoreArr)
        {
            scoreArr.sortOn("ID",Array.NUMERIC);
            for each(var scoreTb:LimitTimeConsumeActivityScoreConfig in scoreArr){
                var isGet:Boolean = isGetReward(scoreTb.ID);
                if(!isGet && _mySroce >= scoreTb.score){
                    //奖励可以领取
                    return true;
                }
            }
        }

        return false;
    }

    //字符串格式2017-07-18 00:00:00
    public function getTimeByString(timeStr:String):Number
    {
        var tempArray:Array = timeStr.split(" ");
        var dateArray:Array = tempArray[0].split("-");
        var timeArray:Array = tempArray[1 ].split(":");
        m_dateHelper.setFullYear(dateArray[0], dateArray[1]-1, dateArray[2]);
        m_dateHelper.setHours(timeArray[0], timeArray[1], timeArray[2]);
        return m_dateHelper.time;
    }

    public function isActivityClosed():Boolean{
        var acvitityConfig:Activity = getActivity();
        if(acvitityConfig == null)return false;
//        var startTime:Number = getTimeByString(acvitityConfig.startTime);
//        var endTime:Number = getTimeByString(acvitityConfig.endTime);
//        var currTime:Number = CTime.getCurrServerTimestamp();
//        var leftTime:Number = endTime-currTime;
//        if(startTime <= currTime && currTime <= endTime){
//            return true;
//        }
        return false;
    }

    public function updateRedPoint() : void
    {
        var isHave:Boolean = isHaveScoreReward();
        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.LIMIT_ACTIVITY ));
        if(isHave){
            if ( pSystemBundleContext && pSystemBundle) {
                pSystemBundleContext.setUserData(system as CLimitActivitySystem, CBundleSystem.NOTIFICATION, true);
            }
        }else{
            if ( pSystemBundleContext && pSystemBundle) {
                pSystemBundleContext.setUserData(system as CLimitActivitySystem, CBundleSystem.NOTIFICATION, false);
            }
        }
    }

    /**
     * 关闭系统入口
     * **/
    public function closeLimitActivity() : void
    {
//        var sys : ISystemBundleContext = ( system as CLimitActivitySystem ).ctx;
//        if( sys )
//        {
//            sys.unregisterSystemBundle( (system as CLimitActivitySystem) );
//        }

        limitSystem.onViewClosed();
        m_pValidater.valid = false;
        m_pTrigger.notifyUpdated();
        limitSystem.closeLimitActivity();
    }

    public function openLimitActivity() : void {
        m_pValidater.valid = true;
        m_pTrigger.notifyUpdated();
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
            if(response.state == ELimitActivityState.ACTIVITY_STATE_START)
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

    private function get limitSystem() : CLimitActivitySystem {
        return system as CLimitActivitySystem;
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _activity():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ACTIVITY);
    }
}
}
