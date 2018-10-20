//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/7.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.filterenum {

/**
 * 根据状态过滤
 */
public class EFilterStateType {
    public function EFilterStateType() {
    }
    public static const STATE_ALL : int = 1;
    public static const STATE_LYING : int = 1<<1;
    public static const STATE_NO_LYING : int = 1<<2;
    public static const STATE_BE_CATCHED : int = 1<<3;
    public static const STATE_NO_BE_CATCHED : int = 1<<4;
    public static const STATE_BE_IN_HURT : int = 1<<5;
    public static const STATE_BE_NORMAL : int = 1<<6;
}
}
