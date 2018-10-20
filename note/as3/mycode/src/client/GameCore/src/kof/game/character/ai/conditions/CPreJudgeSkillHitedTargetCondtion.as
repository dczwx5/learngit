//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/4.
 * Time: 12:01
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
/**预判技能能否击中目标*/
public class CPreJudgeSkillHitedTargetCondtion extends CBaseNodeCondition {
    public function CPreJudgeSkillHitedTargetCondtion() {
        super();
    }

    override protected final function externalCondition(inputData:Object):Boolean
    {
        return true;
    }
}
}
