//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/5.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter {

import kof.game.core.CGameObject;

public interface IGroupCriteria {

    function meetCriteria( targetList : Array ) : Array;
    function setOwner(obj : CGameObject) : void
}
}
