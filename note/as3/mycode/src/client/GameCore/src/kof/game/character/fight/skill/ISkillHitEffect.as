//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Interface.IUpdatable;

import kof.game.core.CGameObject;

public interface ISkillHitEffect extends IUpdatable{
    
    function get ID() : int;
    function isValid() : void;
    function get owner() : CGameObject;
}
}
