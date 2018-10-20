//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/13.
//----------------------------------------------------------------------
package QFLib.Collision.common {

import QFLib.Math.CAABBox2;
import QFLib.Math.CAABBox3;

/**
 * 外部操作碰撞池的接口
 */
public interface ICollisionPool {
    function createCollisionBound(type : int , bound : CAABBox3 , ownerData : Object ) : Object;
    function destroyCollisionBound( bound : ICollision ) : void;
    function getOwnerData(bound : ICollision) : Object;
    function getAABBBound( bound : ICollision ) : CAABBox3;
}
}
