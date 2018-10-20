//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/13.
//----------------------------------------------------------------------
package QFLib.Collision.common {

import QFLib.Math.CAABBox3;

/**
 * 碰撞池中碰撞框集合数据结构的接口
 */
public interface ICollisionCollection {
    function createBound( bound : CAABBox3 , owerData : Object ) : Object;
    function destroyBound( bound : ICollision ) : void;
    function getUserData( bound : ICollision ) : Object ;
}
}
