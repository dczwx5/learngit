//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/29.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

public class ESkillSkipType {
    public static const SKIP_STATE_EVALUATE : int = 1; //跳过状态判断
    public static const SKIP_AP_EVALUATE : int = 2;//跳过攻击值
    public static const SKIP_DP_EVALUATE : int = 3;//跳过防御值
    public static const SKIP_RP_EVALUATE : int = 4;//跳过怒气值
    public static const SKIP_CD_EVALUATE : int = 5 ;//跳过CD判断
    public static const SKIP_INTERRUPT_EVALUATE : int = 6;//无视打断逻辑
}
}
