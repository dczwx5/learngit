//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/3.
 */
package kof.game.common.view.resultWin {

import kof.data.CObjectData;

/**
 * PVP结算数据
 */
public class CPVPResultData extends CObjectData {

    public static const SelfHeroList:String = "selfHeroList";// 己方格斗家ID
    public static const SelfRoleName:String = "selfRoleName";// 己方战队名
    public static const SelfValue:String = "selfValue";// 己方排名、积分等
    public static const SelfChangeValue:String = "selfChangeValue";// 己方排名/积分等变化值
    public static const EnemyHeroList:String = "enemyHeroList";// 敌方格斗家ID
    public static const EnemyRoleName:String = "enemyRoleName";// 敌方战队名
    public static const EnemyValue:String = "enemyValue";// 敌方排名/积分等
    public static const EnemyChangeValue:String = "enemyChangeValue";// 敌方排名/积分等变化值
    public static const Rewards:String = "rewards";// 获得奖励
    public static const ExtraRewards:String = "extraRewards";// 额外奖励(巅峰赛)
    public static const Result:String = "result";// 对战结果(胜利/失败) EArenaResultType
    public static const SelfSegment:String = "selfSegment";// 段位(巅峰赛)
    public static const EnemySegment:String = "enemySegment";// 段位(巅峰赛)
    public static const InstanceType:String = "instanceType";// PVP副本类型(EInstanceType)

    public static const AlwaysWinScore:String = "alwaysWinScore";// 连胜积分
    public static const RebelKillScore:String = "rebelKillScore";// 反杀积分
    public static const DamageScore:String = "damageScore";// 伤害积分

    public static const IsFirstPass:String = "isFirstPass";// 是否首通
    public static const FightUUID:String = "fightUUID";// 战斗的唯一id

    public static const SCORE_ACTIVITY_START:String = "scoreActivityStart";// 多倍积分活动开启
    public static const SCORE_ACTIVITY_MULTIPLE:String = "scoreActivityBaseMultiple";// 多倍积分活动倍数

    public function CPVPResultData()
    {
        super();
    }

    public function get selfHeroList() : Array { return _data[SelfHeroList] == null ? [] : _data[SelfHeroList]; }
    public function get enemyHeroList() : Array { return _data[EnemyHeroList] == null ? [] : _data[EnemyHeroList]; }
    public function get selfRoleName() : String { return _data[SelfRoleName]; }
    public function get enemyRoleName() : String { return _data[EnemyRoleName]; }
    public function get result() : int { return _data[Result]; }

    public function get selfValue() : int { return _data[SelfValue]; }
    public function get enemyValue() : int { return _data[EnemyValue]; }

    public function get selfChangeValue() : int { return _data[SelfChangeValue]; }
    public function get enemyChangeValue() : int { return _data[EnemyChangeValue]; }

    public function get rewards() : Array { return _data[Rewards]; }// ElementType : CResultRewardInfo
    public function get extraRewards() : Array { return _data[ExtraRewards]; }// ElementType : int []
    public function get selfSegment() : CSegmentData { return _data[SelfSegment]; }
    public function get enemySegment() : CSegmentData { return _data[EnemySegment]; }
    public function get instanceType() : int { return _data[InstanceType]; }

    // 巅峰对决
    public function get alwaysWinScore() : int { return _data[AlwaysWinScore]; } // 连胜积分
    public function get rebelKillScore() : int { return _data[RebelKillScore]; } // 反杀积分
    public function get damageScore() : int { return _data[DamageScore]; } // 伤害积分

    // 无尽塔
    public function get isFirstPass() : Boolean { return _data[IsFirstPass]; } // 是否首通

    public function get fightUUID() : String { return _data[FightUUID]; } // 战斗的唯一id

    // 拳皇大赛
    public function get scoreActivityStart() : int { return _data[SCORE_ACTIVITY_START]; } // 多倍积分活动开启
    public function get scoreActivityBaseMultiple() : int { return _data[SCORE_ACTIVITY_MULTIPLE]; } // 多倍积分活动倍数
}
}
