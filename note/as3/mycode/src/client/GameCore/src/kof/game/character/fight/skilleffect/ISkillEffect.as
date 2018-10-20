//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/25.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

public interface ISkillEffect {

    function get effectType() : int ;
    function get effectID() : int;
    function lastUpdate( delta : Number ) : void;

}
}
