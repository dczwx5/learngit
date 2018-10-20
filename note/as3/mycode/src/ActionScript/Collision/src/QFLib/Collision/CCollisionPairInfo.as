//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/20.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Math.CAABBox3;

public class CCollisionPairInfo {
    public function CCollisionPairInfo( box : CAABBox3 , colArea : CAABBox3 , attackBox : CAABBox3 ) {
        collidedArea = colArea;
        collisionBox = box;
        attackerBox = attackBox;
    }

    public function dispose() : void{
        attackerBox = null;
        collidedArea = null;
        collisionBox = null;
    }
    public var attackerBox : CAABBox3;
    public var collidedArea : CAABBox3;
    public var collisionBox : CAABBox3;
}
}
