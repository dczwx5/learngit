//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/24.
 */
package kof.game.guildWar.data {

import kof.data.CObjectData;
import kof.framework.IDatabase;

public class CGuildWarBaseData extends CObjectData {

    public static const AlwaysWin:String = "alwaysWin";// 连胜次数
    public static const HistoryHighWin:String = "historyHighWin";// 连胜次数
    public static const TotalScore:String = "totalScore";// 个人总积分(以太能源)
    public static const ClubTotalScore:String = "clubTotalScore";// 俱乐部总积分(以太能源)
    public static const StartTime:String = "startTime";// 活动开始时间
    public static const EndTime:String = "endTime";// 活动结束时间
    public static const SettlementTime:String = "settlementTime";// 活动结算时间
    public static const MatchState:String = "matchState";// 匹配状态  0空闲 1匹配中 2匹配成功
    public static const HeroStates:String = "heroStates";// 所有格斗家血量数据(布阵显示) （全量更新）
    public static const RoleTotalScoreRewardIDs:String = "roleTotalScoreRewardIDs";// 已领取个人能源奖励列表（公会战奖励配置表ID）（全量更新）
    public static const ClubTotalScoreRewardIDs:String = "clubTotalScoreRewardIDs";// 已领取俱乐部能源奖励列表（公会战奖励配置表ID）（全量更新）
    public static const WinnerSpaceIds:String = "winnerSpaceIds";// 占领的空间站列表，保底奖励空间站id为-1（全量更新）
    public static const AlreadyReceiveDaySpaceRewards:String = "alreadyReceiveDaySpaceRewards";// 已经领取的各空间站每日奖励列表，保存的是空间站id，保底奖励空间站id为-1（全量更新）
    public static const CurrentSpaceId:String = "currentSpaceId";// 当前选择的空间站ID

    public function CGuildWarBaseData()
    {
        super();

        addChild(CGuildWarStateListData);
    }

    public override function updateDataByData(data:Object) : void
    {
        super.updateDataByData( data );
        if ( data.hasOwnProperty( HeroStates ) )
        {
            heroStateListData.clearAll();
            heroStateListData.updateDataByData( data[ HeroStates ] );
        }
    }

    public function get alwaysWin() : int { return _data[AlwaysWin]; }
    public function get historyHighWin() : int { return _data[HistoryHighWin]; }
    public function get totalScore() : int { return _data[TotalScore]; }
    public function get clubTotalScore() : int { return _data[ClubTotalScore]; }
    public function get startTime() : Number { return _data[StartTime]; }
    public function get endTime() : Number { return _data[EndTime]; }
    public function get settlementTime() : Number { return _data[SettlementTime]; }
    public function get matchState() : int { return _data[MatchState]; }
    public function get heroStates() : Array { return _data[HeroStates]; }
    public function get roleTotalScoreRewardIDs() : Array { return _data[RoleTotalScoreRewardIDs]; }
    public function get clubTotalScoreRewardIDs() : Array { return _data[ClubTotalScoreRewardIDs]; }
    public function get winnerSpaceIds() : Array { return _data[WinnerSpaceIds]; }
    public function get alreadyReceiveDaySpaceRewards() : Array { return _data[AlreadyReceiveDaySpaceRewards]; }
    public function get currentSpaceId() : int { return _data[CurrentSpaceId]; }

    public function set alwaysWin(value:int):void
    {
        _data[AlwaysWin] = value;
    }

    public function set historyHighWin(value:int):void
    {
        _data[HistoryHighWin] = value;
    }

    public function set totalScore(value:int):void
    {
        _data[TotalScore] = value;
    }

    public function set clubTotalScore(value:int):void
    {
        _data[ClubTotalScore] = value;
    }

    public function set startTime(value:Number):void
    {
        _data[StartTime] = value;
    }

    public function set endTime(value:Number):void
    {
        _data[EndTime] = value;
    }

    public function set settlementTime(value:Number):void
    {
        _data[SettlementTime] = value;
    }

    public function set matchState(value:int):void
    {
        _data[MatchState] = value;
    }

    public function set heroStates(value:Array):void
    {
        _data[HeroStates] = value;
    }

    public function set roleTotalScoreRewardIDs(value:Array):void
    {
        _data[RoleTotalScoreRewardIDs] = value;
    }

    public function set clubTotalScoreRewardIDs(value:Array):void
    {
        _data[ClubTotalScoreRewardIDs] = value;
    }

    public function set winnerSpaceIds(value:Array):void
    {
        _data[WinnerSpaceIds] = value;
    }

    public function set alreadyReceiveDaySpaceRewards(value:Array):void
    {
        _data[AlreadyReceiveDaySpaceRewards] = value;
    }

    public function set currentSpaceId(value:int):void
    {
        _data[CurrentSpaceId] = value;
    }

    // 格斗家血条数据
    public function get heroStateListData():CGuildWarStateListData
    {
        return getChild(0) as CGuildWarStateListData;
    }
}
}
