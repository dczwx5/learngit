//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/15.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Math.CAABBox3;

public class CCollisionOverlap {
    public function CCollisionOverlap() {
    }

    public static function testAABB( box1 : CAABBox3 , box2 : CAABBox3 ) : Boolean
    {
        return box1.isCollided( box2 );
    }
}
}
