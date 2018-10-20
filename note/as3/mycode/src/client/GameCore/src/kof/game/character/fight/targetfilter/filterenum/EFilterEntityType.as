//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/29.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.filterenum {

/**
 * 过滤的目标类型
 */
public class EFilterEntityType {
    public static const ENTITY_ALL : int = 1;
    public static const ENTITY_NORMAL_MONSTER : int = 1<<1;
    public static const ENTITY_ELITE_MONSTER : int = 1<<2;
    public static const ENTITY_BOSS_MONSTER : int = 1<<3;
    public static const ENTITY_PLAYER : int = 1<<4;
    public static const ENTITY_MISSILE : int = 1<< 5;
}
}
