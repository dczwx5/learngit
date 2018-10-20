//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/13.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Collision.common.CAbstractCollisionCollection;
import QFLib.Collision.common.CCollisionIterator;
import QFLib.Collision.common.ICollision;
import QFLib.Collision.common.IIteratable;
import QFLib.Collision.common.IIterator;
import QFLib.Foundation.free;
import QFLib.Math.CAABBox3;
import QFLib.Memory.CResourcePool;

/**
 * 碰撞存储为数组结构
 */
public class CColArrayCollection extends CAbstractCollisionCollection implements IIteratable{

    public function CColArrayCollection() : void
    {
        m_theBoundPool = new CResourcePool("CollisionPool" , CCollisionBound , 40);
        m_theBoundList = [];
    }

    override public function createBound( bound : CAABBox3 , ownerData : Object ) : Object
    {
        var pCollision : CCollisionBound = _allocate() as CCollisionBound;

        pCollision.AABBBox  = bound.clone();
        pCollision.ownerData = ownerData;

        m_theBoundList.push( pCollision );
        return pCollision;
    }

    override public function destroyBound( bound : ICollision ) : void
    {
        _removeBound( bound );
        _free( bound );
    }

    override public function getUserData( bound : ICollision ) : Object
    {
        return bound.ownerData;
    }

    override public function getAABBBox( bound : ICollision ) : CAABBox3
    {
        return bound.AABBBox;
    }

    private function _removeBound( bound : ICollision ) : void
    {
        var boundIndex : int = m_theBoundList.indexOf( bound );
        if( boundIndex > -1 ) {
            m_theBoundList.splice( boundIndex, 1 );
        }
    }

    override protected function _allocate( ) : Object
    {
        return m_theBoundPool.allocate();
    }

    override protected function _free( obj : Object ) : void
    {
        m_theBoundPool.recycle( obj );
    }

    public function getIterator() : IIterator
    {
        var theIterator : IIterator = new CCollisionIterator( m_theBoundList );
        return theIterator;
    }

    public function resetIterator( iterator : IIterator ) : IIterator
    {
        var colIterator : CCollisionIterator = iterator as CCollisionIterator;
        colIterator.list = m_theBoundList;
        colIterator.position = 0;
        return colIterator;
    }

    private var m_theBoundPool : CResourcePool;
    private var m_theBoundList : Array;
    private var m_theIterator : IIterator;

}
}

