//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/29.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.filterenum {

/**
 * 筛选条件
 */
public class EFilterOtherType {
    public static const OTHER_ALL : int = 1;
    public static const OTHER_X_NEARESE : int = 1<<1;
    public static const OTHER_Z_NEARESE : int = 1<<2;
    public static const OTHER_NEAR : int = 1<<3;
    public static const OTHER_FAR : int = 1<<4;
    public static const OTHER_X_FAR : int = 1<<5;
    public static const OTHER_Z_FAR : int = 1<<6;
    public static const OTHER_LESS_HP : int = 1<<7;
}
}
