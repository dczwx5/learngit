//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/10.
 */

package kof.game.recruitRank {
/*数据管理器*/

import QFLib.Foundation.CMap;
import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.recruitRank.data.CRecruitRankData;
import kof.game.recruitRank.data.CRecruitRankItemData;
import kof.game.switching.CSwitchingSystem;
import kof.table.Activity;
import kof.table.RecruitRankActivityConst;
import kof.table.RecruitRankActivityRankConfig;
import kof.table.RecruitRankActivityTimesConfig;

public class CRecruitRankManager extends CAbstractHandler{

    private var _rankRewardTable:IDataTable;
    private var _constTable:IDataTable;
    private var _timesConfig:IDataTable;
    private var _activityTable:IDataTable;

    private var _myRank:int = 0;
    private var _myTimes:int = 0;
    private var _totalTimes:int = 0;
    private var _rankData:CRecruitRankData;//排名列表
    private var _received:Array = []; //已领取奖励id数组

    public var curActivityId:int = 0;
    public var curActivityState:int = 0;
    public var startTime:Number = 0.0;
    public var endTime:Number = 0.0;
    public var firstOpen:Boolean;
    private var m_pValidater : CRecruitRankValidater;
    private var m_pTrigger : CRecruitRankTrigger;
    public function CRecruitRankManager()
    {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();
    }

    protected override function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        _activityTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ACTIVITY);
        _rankRewardTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RECRUIT_ACTIVITY_RANK_CONFIG);
        _constTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RECRUIT_ACTIVITY_CONST);
        _timesConfig = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RECRUIT_ACTIVITY_TIMES_CONFIG);
        if(_rankData == null)
        {
            _rankData = new CRecruitRankData();
        }
        var switchingSystem : CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        m_pValidater = new CRecruitRankValidater(recruitRankSystem);
        switchingSystem.addValidator(m_pValidater);
        m_pTrigger = new CRecruitRankTrigger();
        switchingSystem.addTrigger(m_pTrigger);
        return ret;
    }
    public function openActivity() : void {
        _rankData.LimitTimes = getRewardList();
        m_pValidater.valid = true;
        m_pTrigger.notifyUpdated();
    }
    public function closeActivity() : void {
        m_pValidater.valid = false;
        //recruitRankSystem.closeLimitActivity();
        m_pTrigger.notifyUpdated();
        firstOpen = false;
    }
    /**
     * 解析全服次数
     */
    public function setTotaltimes(totalTimes:int,selfTimes:int,received:Array) : void
    {
        _totalTimes = totalTimes;
        _myTimes = selfTimes;
        this.received = received;
    }
    /**
     * 解析排名数据
     *
     */
    public function setRankInfo(selfTimes:int,rankInfos:Array) : void
    {
        _myTimes = selfTimes;
        for(var i:int = 0; i < rankInfos.length; i++)
        {
            if(String(rankInfos[ i ].id) == String(playerData.ID))
            {
                _myRank = rankInfos[ i ].rank;
                break;
            }
        }
        _rankData.updateDataByData(rankInfos);
    }

    /**
     * 获取第n-m名数据
     */
    public function getAppointRankInfo(n:int,m:int):Array
    {
        if(!_rankData || !_rankData.rankInfos) return null;
        var list:Array = _rankData.rankInfos;
        var resultArr:Array = [];
        for(var i:int = 0; i <list.length; i++)
        {
            if((list[i] as CRecruitRankItemData).roleRank >= n)
            {
               resultArr.push(list[i ]);
            }
            if((list[i] as CRecruitRankItemData).roleRank == m)
            {
                break;
            }
        }
        return resultArr;
    }

    /**
     *  领奖返回
     */
    public function set received(value:Array):void
    {
        _received = value;
    }
    public function get received():Array
    {
        return _received;
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
    public function getActivity() : Activity {
        if ( curActivityId == 0 )return null;
        return _activityTable.findByPrimaryKey( curActivityId ) as Activity;
    }


    /**
     * 读取奖励列表
     * @return
     */

    public function getRewardList() : Array {
        return _rankRewardTable.findByProperty("activityId",curActivityId);
    }

    /**
     * 获取第n名的奖励
     * @return
     */
    public function getSingleReward(n:int):Array {
        var rewardArr:Array = getRewardList();
        var rewardTb:RecruitRankActivityRankConfig;
        var rewardData:CRewardListData;

        for each(rewardTb in rewardArr)
        {
            if(rewardTb.configId == n)
            {
                rewardData = CRewardUtil.createByDropPackageID(recruitRankSystem.stage, rewardTb.reward);
                if(rewardData){
                    return rewardData.list;
                }
            }
        }
        return null;
    }

    /**
     * 显示所有奖励，同类型合并
     */
    public function getTotalRewardList() : Array
    {
        var rewardArr:Array = getRewardList();
        var resultArr:Array = [];
        if(!rewardArr) return resultArr;
        var rank:Array;//名次数组
        var itemObj:Object;
        for(var i:int = 0; i < rewardArr.length; i++)
        {
            itemObj = new Object();
            rank = [];
            rank.push(rewardArr[ i ].configId);
            itemObj.rank = rank;
            itemObj.reward = rewardArr[ i ].reward;
            itemObj.needTimes = rewardArr[ i ].needTimes;
            if(resultArr.length == 0)
            {
                resultArr.push(itemObj);
            }
            else
            {
                resultArr = _checkIsExis(itemObj,resultArr);
            }

        }
        return resultArr;
    }
    private function _checkIsExis(obj:Object,res:Array):Array {
        var rank : Array = [];
        var ret : Boolean = true;
        for each( var meb : Object in res )
        {
            if ( meb.reward == obj.reward )
            {
                rank = meb.rank;
                rank.push( obj.rank[0] );
                rank.sort();
                meb.rank = rank;
                ret = false;
                break;
            }
        }
        if ( ret ) {
            res.push( obj );
            res.sortOn("needTimes", Array.NUMERIC|Array.DESCENDING);
        }
        return res;
    }

    /**
     * 读取全服累计奖励
     * @return
     */
    public function getTotalReward():Array
    {
        return _timesConfig.findByProperty("activityId",curActivityId);
    }

    /**
     * 读取提示配置
     */
    public function getHelpTips():String
    {
        var config:CMap = _constTable.tableMap as CMap;
        if(!config) return "";
        var descConf:RecruitRankActivityConst = config.find(1) as RecruitRankActivityConst;
        if(!descConf) return "";
        var result:String = descConf.describe1;
        return result;
    }

    /**
     * 通过id取奖励配置
     */
    public function getRewardByID(id:int):RecruitRankActivityTimesConfig
    {
        return _timesConfig.findByPrimaryKey(id);
    }

    /**
     * 判断奖励是否已领取
     */
    public function isGetReward(id:int):Boolean {
        var index:int = this.received.indexOf(id);
        if(index != -1){
            return true;
        }
        return false;
    }

    /**
     * 更新红点
     */
    public function updateRedPoint() : void
    {
        var isHave:Boolean = isHaveScoreReward();
        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.RECRUIT_RANK));
        if(isHave){
            if ( pSystemBundleContext && pSystemBundle) {
                pSystemBundleContext.setUserData(recruitRankSystem, CBundleSystem.NOTIFICATION, true);
            }
        }else{
            if ( pSystemBundleContext && pSystemBundle) {
                pSystemBundleContext.setUserData(recruitRankSystem, CBundleSystem.NOTIFICATION, false);
            }
        }
    }
    public function isHaveScoreReward():Boolean {
        if(firstOpen) return true;
        var rewardArr:Array = getTotalReward();
        if(!rewardArr) return false;
        rewardArr.sortOn("ID",Array.NUMERIC);
        for each(var scoreTb:RecruitRankActivityTimesConfig in rewardArr){
            var isGet:Boolean = isGetReward(scoreTb.ID);
            if(!isGet && _totalTimes >= scoreTb.times){
                //奖励可以领取
                return true;
            }
        }
        return false;
    }

    public function get myRank():int
    {
        return _myRank;
    }
    public function get myTimes():int
    {
        return _myTimes;
    }
    public function get totalTimes():int
    {
        return _totalTimes;
    }
    //获取全服累计招募次数进度条,按奖励阶段处理进度条
    public function get timesPercent():Number
    {
        var percent:Number;
        var timesArr:Array = [];
        var configArr:Array = getTotalReward();
        for each(var member:RecruitRankActivityTimesConfig in configArr )
        {
            timesArr.push(member.times);
        }
        timesArr.sort(Array.NUMERIC);
        var len:int = timesArr.length;
        for(var i:int=0; i<len-1; i++)
        {
            if(_totalTimes < timesArr[0 ])
            {
                percent = _totalTimes / timesArr[0] / len;
                break;
            }
            else if(_totalTimes >= timesArr[i ] && _totalTimes < timesArr[i+1])
            {
                percent = (i+1 + (_totalTimes - timesArr[i]) / (timesArr[i+1] - timesArr[i])) / len;
                break;
            }
            else if(_totalTimes >= timesArr[len-1])
            {
                percent = 1;
                break;
            }
        }
        return percent;
    }

    private function get recruitRankSystem() : CRecruitRankSystem
    {
        return system as CRecruitRankSystem;
    }
    private function get playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
