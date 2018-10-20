//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/13.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Collision.common.ICollision;
import QFLib.Foundation.CMap;
import QFLib.Foundation.ICollection;
import QFLib.Foundation.free;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.RenderCore.CRenderer;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CAABBox3;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.Memory.CSmartObject;
import QFLib.Node.CNode;

public class CCollisionBound extends CSmartObject implements ICollision , IDisposable {
    public static const TYPE_ATTACK: int = 1 ;
    public static const TYPE_DEFENSE : int = 2 ;
    public static const TYPE_BLOCK : int = 3;
    public function CCollisionBound( ) {
        m_pPair  = new CCollisionPairs( this );
    }

    override public function dispose() : void
    {
        super.dispose();
        m_pOwnerData = null;
        m_pAttacherRef = null;
        free( m_pPair );
        m_pPair = null;
    }

    public function get ownerData() : Object
    {
        return m_pOwnerData;
    }

    public function get testAABBBox() : CAABBox3
    {
        var srcBox : CAABBox3 = AABBBox.clone();
        var vSize : CVector3 = srcBox.ext.mul( characterScale );
        var tranPosition : CVector3 = m_pAttacherRef.position;
        var vCenter : CVector3 = (srcBox.center.clone());
        vCenter.mulOnValueXYZ( 1.0 , 1.0 , characterScale.y );
        var vPos : CVector3 = ((vCenter).mul( characterDir )).add(new CVector3( tranPosition.x ,  tranPosition.z ,tranPosition.y ));
        srcBox.setCenterExt( vPos, vSize );
        return srcBox;
    }

    public function get characterDir() : CVector3
    {
        var dir : CVector3;
        var flipX : Number = m_pAttacherRef.flipX ? -1 : 1;
        var flipY : Number = m_pAttacherRef.flipZ ? -1 : 1;
        var flipZ : Number = m_pAttacherRef.flipY ? 1 : -1;
        dir =  new CVector3( flipX , flipY , flipZ );
        return dir;
    }

    public function get characterScale() : CVector3
    {
        if( m_pAttacherRef == null ) return new CVector3( 1.0 , 1.0 , 1.0 );
        return m_pAttacherRef.scale;
    }

    public function get AABBBox() : CAABBox3
    {
        return m_pAABBBox;
    }

    public function set AABBBox( box : CAABBox3 ) : void
    {
        m_pAABBBox = box;
    }

    public function set ownerData( data : Object ) : void
    {
        m_pOwnerData = data;
    }

    public function get Type() : int
    {
        return m_nType ;
    }

    public function getPairsInfo( targetData : * ) : CCollisionPairInfo
    {
        return pairs.find( targetData );
    }

    public function getCollidedData() : Array
    {
        var targets : Array = [];
        var touchTarget : CMap = pairs;
        for( var key : * in touchTarget ) {
            var index : int = targets.indexOf( key );
            if ( index < 0 )
                targets.push( key );
        }
        return targets;
    }

    public function get pairs() : CMap
    {
        return m_pPair.getTargets();
    }

    public function resetPairs() : void
    {
        m_pPair.resetPair();
    }

    public function addPair( target : ICollision  ) : void
    {
        m_pPair.addToPair( target );
    }

    public function removePair( target : ICollision ) : void{
        m_pPair.removeTargetPair( target );
    }

    public function set Type(value : int ) : void
    {
        m_nType = value;
    }

    public function get pAttacherRef( ) : ICollisable
    {
        return m_pAttacherRef;
    }

    public function set pAttacherRef( value : ICollisable ) : void
    {
        this.m_pAttacherRef = value;
    }

    public function get collidedState() : Boolean
    {
        return m_pPair.hasTargets() ;
    }

    private var m_pOwnerData : Object;
    private var m_pAABBBox : CAABBox3;
    private var m_nType: int ;
    private var m_pPair : CCollisionPairs;
    private var m_pAttacherRef : ICollisable;
}
}
