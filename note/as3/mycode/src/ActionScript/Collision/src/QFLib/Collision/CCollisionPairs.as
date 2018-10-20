//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/16.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Collision.common.ICollision;
import QFLib.Foundation.CMap;
import QFLib.Foundation.free;
import QFLib.Interface.IDisposable;
import QFLib.Math.CAABBox3;


/**
 * 只有攻击框有pair，包含与他碰撞的受击框
 */
public class CCollisionPairs implements IDisposable {
    public function CCollisionPairs( characterCol : ICollision ) {
        m_pCollison = characterCol;
        m_theRefCollisionPairs = new CMap();
    }

    public function dispose() : void {
        m_pCollison = null;
        m_theRefCollisionPairs.clear();
        m_theRefCollisionPairs = null;
    }

    public function addToPair( target : ICollision ) : void {
        if ( _checkIfNearest( target ) ) {
            var collidedArea : CAABBox3 = _getCollidedArea( target );
            m_theRefCollisionPairs.add( target.ownerData,
                    new CCollisionPairInfo( target.testAABBBox, collidedArea, m_pCollison.testAABBBox ), true );
        }
    }

    public function removeTargetPair( target : ICollision ) : void {
        var info : CCollisionPairInfo = m_theRefCollisionPairs.find( target.ownerData );
        if ( info ) {
            info.dispose();
            delete  m_theRefCollisionPairs[ target.ownerData ];
            info = null;
        }
    }

    public function resetPair() : void {
        m_theRefCollisionPairs.clear();
    }

    public function getTargets() : CMap {
        return m_theRefCollisionPairs;
    }

    /**
     * 当前是否有目标 除了自己
     * @return
     */
    public function hasTargets() : Boolean {
        if ( m_theRefCollisionPairs.count > 1 ) return true;
        return false;
    }

    /**
     * 只取最近的碰撞区域
     * @param target
     * @return
     */
    private function _checkIfNearest( target : ICollision ) : Boolean {
//        return true;
        var m_pairInfo : CCollisionPairInfo = m_theRefCollisionPairs.find( target.ownerData );

        if ( m_pairInfo != null ) {
            var m_theExistTarget : CAABBox3 = m_pairInfo.collidedArea;
            var fCenterX : Number = m_pCollison.testAABBBox.center.x;
            var preDistance : Number = Math.abs( m_theExistTarget.center.x - fCenterX );
            var collidedArea : CAABBox3 = _getCollidedArea( target );
            var curDistance : Number = Math.abs( collidedArea.center.x - fCenterX );
            if ( curDistance < preDistance ) {
                return true;
            }
            return false;
        }

        return true;
    }

    private function _getCollidedArea( target : ICollision ) : CAABBox3 {
        var atk : CAABBox3 = m_pCollison.testAABBBox;
        var def : CAABBox3 = target.testAABBBox;
        var collidedArea : CAABBox3 = atk.collidedArea( def );
        return collidedArea;
    }

    private var m_theRefCollisionPairs : CMap;
    private var m_pCollison : ICollision;

}
}
