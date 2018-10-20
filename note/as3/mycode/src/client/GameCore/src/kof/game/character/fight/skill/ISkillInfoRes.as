//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/1/11.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import kof.table.ActionSeq;

public interface ISkillInfoRes {
    function getSkillEffectsByActionFlag( actionFlag : String ) : Array;
    function getSkillActionsByActionFlag( actionFlag : String ) : ActionSeq;
}
}
