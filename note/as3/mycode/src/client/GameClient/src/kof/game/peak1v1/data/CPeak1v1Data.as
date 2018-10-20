//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectData;
import kof.framework.IDatabase;

public class CPeak1v1Data extends CObjectData {

    public function CPeak1v1Data(database:IDatabase) {
        setToRootData(database);
        this.addChild(CPeak1v1HeroStateListData);
        this.addChild(CPeak1v1Rank3ListData);
        this.addChild(CPeak1v1ReportListData);
        this.addChild(CPeak1v1RankingListData);
        this.addChild(CPeak1v1ResultData);
        this.addChild(CPeak1v1MatchData);

        rewardUtil = new CPeak1v1RewardDataUtil(database);
    }
    // ===========================data
    public function initialData(data:Object) : void {
        clearData();
        heroStateListData.resetChild();
        rank3ListData.resetChild();
        isServerData = true;
        updateDataByData(data);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty(_heroStates)) {
            var heroListData:Array = data[_heroStates];
            heroStateListData.updateDataByData(heroListData);
        }
        
        if (data.hasOwnProperty(_rankDatas)) {
            rank3ListData.resetChild();
            rank3ListData.updateDataByData(data[_rankDatas]);
        }
    }
    public function updateResultData(data:Object) : void {
        resultData.updateDataByData(data);
    }

    public function updateEnemyProgressData(data:Object) : void {
        enemyProgress = data as int;
    }
    public function updateReportData(data:Object) : void {
        reportData.isServerData = true;
        reportData.resetChild();
        reportData.updateDataByData(data);
    }
    public function updateRankingData(data:Object) : void {
        rankingListData.isServerData = true;
        rankingListData.resetChild();
        rankingListData.updateDataByData(data);
    }
    public function updateMatchData(data:Object) : void {
        matchData.updateDataByData(data);
    }

    public function isDamageRewardHasGet(ID:int) : Boolean {
        return _isRewardHasGetB(damageRewardIDs, ID);
    }
    public function isJoinRewardHasGet(ID:int) : Boolean {
        return _isRewardHasGetB(countRewardIDs, ID);
    }
    public function isWinRewardHasGet(ID:int) : Boolean {
        return _isRewardHasGetB(winRewardIDs, ID);
    }
    private function _isRewardHasGetB(rewardList:Array, ID:int) : Boolean {
        if (rewardList) {
            return rewardList.indexOf(ID) != -1;
        }
        return false;
    }
    public function isRewardIDHasGet(ID:int) : Boolean {
        var isGet:Boolean = isDamageRewardHasGet(ID);
        if (!isGet) {
            isGet = isJoinRewardHasGet(ID);
        }
        if (!isGet) {
            isGet = isWinRewardHasGet(ID);
        }
        return isGet;
    }

    public function get score() : int { return _data[_score]; } // 当前积分
    public function get fightCount() : int { return _data[_fightCount]; } // 战斗次数
    public function get regState() : int { return _data[_regState]; } // 报名状态 0未报名 1已报名
    public function get round() : int { return _data[_round]; } // 活动进行到第几轮
    public function get startTime() : Number { return _data.hasOwnProperty(_startTime) ? _data[_startTime] : 0; } // 开始时间, 第一轮时间为正常开始时间, 减1分钟是活动开启时间, 减6分钟是主界面提示时间, 减1.5分钟是弹窗时间, 减10秒是报名倒计
    public function get matchTime() : Number { return _data[_matchTime]; } // 每一轮开始时间
    public function get endTime() : Number { return _data[_endTime]; }
    public function get damageRewardIDs() : Array { return _data[_damageRewardIDs]; } // 已领取伤害累计奖励列表（巅峰对决奖励配置表ID）
    public function get countRewardIDs() : Array { return _data[_countRewardIDs]; } // 已领取累计参加次数奖励列表（巅峰对决奖励配置表ID）
    public function get winRewardIDs() : Array { return _data[_winRewardIDs]; } // 已领取累计胜利次数奖励（巅峰对决奖励配置表ID）
    public function get winCount() : int { return _data[_winCount]; } // 胜利次数
    public function get totalDamage() : int { return _data[_totalDamage]; } // 累计伤害值
    public function get alwaysWin() : int { return _data[_alwaysWin]; } // 连胜

    public static const _score:String = "score";
    public static const _fightCount:String = "fightCount";
    public static const _regState:String = "regState";
    public static const _round:String = "round";
    public static const _matchTime:String = "matchTime";
    public static const _startTime:String = "startTime";
    public static const _endTime:String = "endTime";
    public static const _damageRewardIDs:String = "damageRewardIDs";
    public static const _countRewardIDs:String = "countRewardIDs";
    public static const _winRewardIDs:String = "winRewardIDs";
    public static const _winCount:String = "winCount";
    public static const _totalDamage:String = "totalDamage";
    public static const _alwaysWin:String = "alwaysWin";

    public static const _heroStates:String = "heroStates";
    public static const _rankDatas:String = "rankDatas";

    public var enemyProgress:int; // 对手进度
    public var myProgress:int; // 自己的进度
    public function get warnStartTime() : Number { return startTime - 30000 }
    public function get regCountDownStillTime() : Number { return 10000; } // 倒计时持续时间
    public function get regCountDownStartTime() : Number { return startTime - regCountDownStillTime; } // 倒计时开始时间

    public function get showNoticeStillTime() : Number { return 270000; } // { 4.5*60*1000 } 预告
    public function get showNoticeStartTime() : Number { return startTime - 360000; } // 6min
    public function get showNotifyStillTime() : Number { return 10000; } // 开始通知
    public function get showNotifyStartTime() : Number { return startTime - 60000; }
    public function get showStartTime() : Number { return startTime - 60000; }

    public function get nextRoundCountDownStillTime() : Number { return 10000; } // 下一轮倒计时持续时间
    public function get nextRoundCountDownStartTime() : Number { return matchTime - nextRoundCountDownStillTime; } // 下一轮倒计时开始时间

    // 最多可以打几次
    public function get fightCountMax():int {
        return rewardUtil.constantRecord.fightCountLimit;
    }

    // 格斗家血条数据
    public function get heroStateListData() : CPeak1v1HeroStateListData {
        return getChild(0) as CPeak1v1HeroStateListData;
    }
    // 前3数据
    public function get rank3ListData () : CPeak1v1Rank3ListData {
        return getChild(1) as CPeak1v1Rank3ListData;
    }
    public function get reportData () : CPeak1v1ReportListData {
        return getChild(2) as CPeak1v1ReportListData;
    }
    // 排行榜数据
    public function get rankingListData () : CPeak1v1RankingListData {
        return getChild(3) as CPeak1v1RankingListData;
    }

    // 结算数据
    public function get resultData () : CPeak1v1ResultData {
        return getChild(4) as CPeak1v1ResultData;
    }
    // 匹配数据
    public function get matchData () : CPeak1v1MatchData {
        return getChild(5) as CPeak1v1MatchData;
    }


    public var _playerUID:int;
    public var rewardUtil:CPeak1v1RewardDataUtil;
}
}
