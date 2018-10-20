//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/12.
//----------------------------------------------------------------------
package kof.game.character.collision {

import QFLib.Framework.CCollisionObject;
import QFLib.Framework.CharacterExtData.CCharacterCollisionKey;

public interface ICollisable {
//    function get currentCollisionData() : Vector.<CCharacterCollisionKey>;
//    function get currentCollisionName() : String;
    function get currentCollisionLoopDuration() : Number;
    function get collision() : CCollisionObject;
    function set collisionOwnerData( go : Object ) : void

}
}
