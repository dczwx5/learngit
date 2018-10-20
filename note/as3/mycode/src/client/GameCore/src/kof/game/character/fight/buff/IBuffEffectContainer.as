//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/31.
//----------------------------------------------------------------------
package kof.game.character.fight.buff {

import QFLib.Interface.IUpdatable;

import kof.game.character.fight.buff.buffentity.IBuff;
import kof.game.core.CGameObject;

import kof.game.core.IGameComponent;

public interface IBuffEffectContainer extends IUpdatable , IGameComponent{

    function addBuff( buff : IBuff) : void ;
    function removeBuff( buff : IBuff ) : void ;
    function getBuff( id : Number ) : IBuff;
    function hasBuff( id : Number ) : Boolean;
    function addBuffGameObject( data : Object ) : CGameObject;
    function removeBuffGameObject( id : int ) : void;
}
}
