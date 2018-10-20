//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/8.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

/**
 * 技能链条件类型借口
 */
public interface ISkillConditionEvaluate {

    //评估技能链是否逻辑通过
    function isEvaluate() : Boolean;
    function get evaluateValue() : *;
    function get evaluateType() : int;
    function get evaluateSuperType() : int;
}
}
