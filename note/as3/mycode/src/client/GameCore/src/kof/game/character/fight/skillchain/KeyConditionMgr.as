//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/16.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import flash.ui.Keyboard;

import kof.table.ChainKeyCondition.EKeyType;

public class KeyConditionMgr {

    public function KeyConditionMgr() {

    }

    public static function getKeyCodeByType( type : int ) : int
    {
        switch( type )
        {
            case EKeyType.KEY_UP:
                return Keyboard.W;
            case EKeyType.KEY_DOWN:
                return Keyboard.S;
            case EKeyType.KEY_LEFT:
                return Keyboard.A;
            case EKeyType.KEY_RIGHT:
                return Keyboard.D;
            default:
                return Keyboard.J;
        }
    }

    public static function isSameCurrentKey( keyIndex : int ) : Boolean
    {
        return keyIndex == EKeyType.KEY_SAME;
    }

    public static function isDiffCurrentKey( keyIndex : int ) : Boolean
    {
        return keyIndex == EKeyType.KEY_DIFF;
    }
}
}
