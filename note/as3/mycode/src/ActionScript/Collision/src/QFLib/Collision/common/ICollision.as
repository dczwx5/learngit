//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/10.
//----------------------------------------------------------------------
package QFLib.Collision.common {

import QFLib.Math.CAABBox3;

public interface ICollision {
    function get ownerData() : Object;
    function get AABBBox() : CAABBox3;
    function get testAABBBox() : CAABBox3;
}
}
