//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/11.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import kof.game.core.CGameObject;

public interface IEmitter {

    function shotMissile( id : Object ) : CMissile
    function recycleMissile( missile : CGameObject) : CGameObject
}
}
