//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/6/15.
 * Time: 14:36
 */
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

public class CWhetherHitedByPlayerCondtion extends CBaseNodeCondition {
    private var pBT:CAIObject;
    public function CWhetherHitedByPlayerCondtion(pBt:Object=null,nodeName:String=null)
    {
        this.pBT = pBt as CAIObject;
        setName(nodeName);
    }
    [Inline]
    override protected function externalCondition(input:Object):Boolean
    {
        return false;
    }
}
}
