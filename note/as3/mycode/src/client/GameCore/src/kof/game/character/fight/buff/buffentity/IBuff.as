//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/28.
//----------------------------------------------------------------------
package kof.game.character.fight.buff.buffentity {

import kof.game.character.fight.buff.*;

import QFLib.Interface.IUpdatable;

import kof.table.Buff;

public interface IBuff {

    /**
     * runtime id
     */
    function get id() : int;
    function get buffId() : int;

    function get buffAttModifierList() : Array;

    function get buffEffectList() : Array;
    /**
     * valid buff
     */
    function get isValid() : Boolean;

    function get buffData() : Buff;

    function get nEffectCount() : int;

    function get nOverlapCount() : int;

    function get randomSeed() : int;

    /**
     * return its container
     */
    function get parent() : IBuffEffectContainer;


}
}
