//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/7.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.filterenum {

public class EFilterSpecifyTargetType {
    public function EFilterSpecifyTargetType() {
    }

    public static const SPECIFY_NONE : int = 1;
    public static const SPECIFY_RANDOM : int = 1<<1;
    public static const SPECIFY_EXCEPT_SELF : int = 1<<2;
    public static const SPECIFY_ONLY_CURRENT_TARGET : int = 1<<3;
    public static const SPECIFY_EXCEPT_CURRENT_TARGET : int = 1<<4;
    public static const SPECIFY_SELF : int = 1<<5;
    public static const SPECIFY_SPELLER : int = 1<<6;
}
}
