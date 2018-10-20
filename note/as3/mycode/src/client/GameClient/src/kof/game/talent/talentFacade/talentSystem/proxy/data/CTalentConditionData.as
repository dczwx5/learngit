//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/19.
 */
package kof.game.talent.talentFacade.talentSystem.proxy.data {

public class CTalentConditionData {

    public var conditionType:int;// 条件类型
    public var targetValue:int;// 完成条件需要达到的值
    public var currValue:int;// 当前完成的进度
    public var conditionDesc:String;// 条件描述

    public function CTalentConditionData() {
    }

    public function get isReachTarget():Boolean
    {
        return currValue >= targetValue;
    }
}
}
