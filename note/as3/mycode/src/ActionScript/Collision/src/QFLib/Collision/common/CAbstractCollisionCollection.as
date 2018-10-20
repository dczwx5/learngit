//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/13.
//----------------------------------------------------------------------
package QFLib.Collision.common {

import QFLib.Interface.IDisposable;
import QFLib.Math.CAABBox3;

public class CAbstractCollisionCollection implements ICollisionCollection , IDisposable{
    public function CAbstractCollisionCollection() {
    }

    public function dispose() : void
    {
        super.dispose();
    }

    protected function _allocate( ) : Object
    {
        return null;
    }

    protected function _free( obj : Object ) : void
    {

    }

    public function createBound( bound : CAABBox3 , ownerData : Object ) : Object
    {
        return null;
    }

    public function destroyBound( bound : ICollision ) : void
    {

    }

    public function getUserData( bound : ICollision ) : Object
    {
        return null;
    }

    public function getAABBBox( bound : ICollision )  : CAABBox3
    {
        return null;
    }
}
}
