//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/25.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline {

public class ESyncStateType {
    public static const STATE_NORMAL: int = 0 ;
    public static const STATE_FIGHT : int = 1;
    public static const STATE_UNCONTROL : int = 2;

    public static const SUB_NOMAL_IDLE : int = 0;
    public static const SUB_NOMAL_MOVE : int = 1;

    public static const SUB_FIGHT_WUDI : int = 0;
    public static const SUB_FIGHT_UNATTACKABLE : int = 1;
    public static const SUB_FIGHT_BABODY : int = 2;
    public static const SUB_FIGHT_UNCATCHABLE : int = 3;

    public static const SUB_UNCONTROL_UP : int = 0;
    public static const SUB_UNCONTROL_HURT : int = 1;
    public static const SUB_UNCONTROL_GUARD : int = 2;
    public static const SUB_UNCONTROL_BECATCH : int = 3;

}
}
