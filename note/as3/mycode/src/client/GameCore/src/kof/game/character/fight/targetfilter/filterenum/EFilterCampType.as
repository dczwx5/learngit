//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/29.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.filterenum {

/**
 * 目标过滤阵营类型
 */
public class EFilterCampType {
    public static const CAMP_ALL : int = 1;
    public static const CAMP_FRIEND : int = 1<<1;
    public static const CAMP_ENEMIES : int = 1<<2;
    public static const CAMP_NEUTRALITY : int = 1<<3;

    public static const CAMP_SELF : int = 1>>8;
}
}
