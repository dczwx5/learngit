//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/15.
 */
package kof.game.talent.talentFacade.talentSystem.enums {

/**
 * 斗魂开启条件类型
 */
public class ETalentOpenConditionType {

    public static const Type_TeamLevel:int = 1;// 战队等级达到X
    public static const Type_PeakGame:int = 2;// 拳皇大赛达到X段
    public static const Type_EmbedLevel:int = 3;// 镶嵌总等级达到X级
    public static const Type_AttackHeroNum:int = 4;// 攻击职业格斗家数量达到X
    public static const Type_DefenseHeroNum:int = 5;// 防御职业格斗家数量达到X
    public static const Type_SkillHeroNum:int = 6;// 技巧职业格斗家数量达到X
    public static const Type_AllHeroNum:int = 7;// 所拥有格斗家数量达到X
    public static const Type_MaxIntelligence:int = 8;// 格斗家最高资质达到X
    public static const Type_VipLevel:int = 9;// VIP等级达到X

    public function ETalentOpenConditionType()
    {
    }
}
}
