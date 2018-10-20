//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/21.
//----------------------------------------------------------------------
package QFLib.Framework {

import QFLib.Collision.CCollisionBound;
import QFLib.Collision.CCollisionManager;
import QFLib.Collision.CCollisionQuadObject;
import QFLib.Collision.ICollisable;
import QFLib.Collision.common.ICollision;
import QFLib.Framework.CObject;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.RenderCore.CRenderer;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;
import QFLib.Node.CNode;
import QFLib.Node.EDirtyFlag;

public class CCollisionQuad extends CObject implements IDisposable ,IUpdatable{
    public function CCollisionQuad( theFrameWork : CFramework ){
        super(theFrameWork );
        m_pCollisionQuad = new CCollisionQuadObject( theFrameWork.renderer );
    }

    override public function update( delta : Number ) : void
    {
        super.update( delta );
        if( m_pCollisionQuad )
            m_pCollisionQuad.update( delta );

        updateMatrix();
    }

    override public function dispose() : void
    {

        m_pRefCharacter = null;
        m_pCollisionQuad.dispose();
        m_pCollisionQuad = null;
        super.dispose();
    }

    override public function get theObject() : CBaseObject
    {
        return m_pCollisionQuad;
    }

    public function set characterCollision( value : CCollisionBound ) : void
    {
        m_pCharacterCollision = value;
        m_pCollisionQuad.setCollisionBound( m_pCharacterCollision );
        m_pCollisionQuad.setParent( m_pCharacterCollision.pAttacherRef.renderableObject.parent );
    }

    public override function updateMatrix ( bCheckDirty : Boolean = true ) : void
    {
        super.updateMatrix( bCheckDirty );

        if ( _checkDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED ) || bCheckDirty == false )
        {
            _unsetDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED );

            m_pCollisionQuad.setRotation ( this.localRotation.z );

            var vScale : CVector3 = this.scale;
            m_pCollisionQuad.setScale ( vScale.x, vScale.y );

            m_pCollisionQuad.flipX = this.flipX;
            m_pCollisionQuad.flipY = this.flipY;

            // set matrix to character object
            var vPosition : CVector3 = this.position;
            m_pCollisionQuad.setPosition3D ( vPosition.x, vPosition.y, vPosition.z );

            // set 2D position again due to the customized depth value,
            if ( this.depth2D != 0.0 ) m_pCollisionQuad.setPosition ( m_pCollisionQuad.x, m_pCollisionQuad.y, this.depth2D );
        }
    }

    public function get characterCollision() : CCollisionBound
    {
        return m_pCharacterCollision;
    }

    private var m_pRefCharacter : ICollisable;
    private var m_pCollisionQuad : CCollisionQuadObject;
    private var m_pCharacterCollision : CCollisionBound;
}
}
