//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/16.
//----------------------------------------------------------------------
package kof.game.character.fight.buff.buffentity {

import kof.table.Buff.EAGMMode;
import kof.table.Buff.EAMMode;

public class CBuffModifierInfo {
    public var AttributeName : String;
    public var AttributeModifyMode : int;
    public var AttributeModifyValue : Number;
    public var AttributeGoal : Number;

    public function get boCalByOwnerProperty() : Boolean
    {
        if( AttributeGoal == EAGMMode.MODE_OWNER ) return true;
        if( AttributeGoal == EAGMMode.MODE_CASTER ) return false;
        return false;
    }

    public function get boCalByPercent() : Boolean
    {
        if( AttributeModifyMode == EAMMode.MODE_PERCENT )
                return true;
        return false;
    }
}
}
