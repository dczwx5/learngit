//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/21.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.RenderCore.CRenderer;
import QFLib.Graphics.RenderCore.starling.display.Quad;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;

public class CCollisionQuadObject extends CBaseObject{
    public function CCollisionQuadObject( theRenderer : CRenderer) {
        super( theRenderer );
    }

    override public function dispose() : void
    {
        if( m_pQuad )
            _removeChild( m_pQuad );
        m_pQuad = null;
        super.dispose();
    }

    public function setCollisionBound( collision : CCollisionBound ) : void
    {
        if( collision )
        {
            m_pCollision = collision;
            var box : CAABBox3 = collision.testAABBBox;
            if( box )
            {
                if( m_pQuad == null )
                        _setQuad( box , _getColorByType(collision.Type))
            }
        }
    }

    override public function update( delta : Number ) : void
    {
        super.update( delta );
        if( m_pCollision )
        {
            _updateTransform();
            _updateColor();
        }

    }

    private function _setQuad( box : CAABBox3 , color : int = 0x00ff00 ) : void
    {
        m_pQuad = new Quad(box.extX * 2 ,box.extZ * 2,color, false);
        this.m_pQuad.x  =  - ((m_pQuad.width)>>1) ;
        this.m_pQuad.y =  - ( ( m_pQuad.height) >>1 );
        m_pQuad.alpha =0.5;
        _addChild( m_pQuad );
    }

    private function _updateTransform( ) : void
    {
        if( m_pQuad )
        {
            var testBox : CAABBox3 = m_pCollision.testAABBBox;
            var position : CVector3 = m_pCollision.pAttacherRef.position;
            position = testBox.center;
            setPosition3D( position.x ,position.z ,  position.y );
        }
    }

    private function _updateColor() : void
    {
        var color : int;
        if( m_pCollision.collidedState )
            color = 0xff0000;
        else
        {
            color = _getColorByType( m_pCollision.Type );
        }
        nColor = color;
    }

    private function _getColorByType( type : int ) : int
    {
        switch ( type ){
            case CCollisionBound.TYPE_ATTACK:
                return 0xffff00;
            case CCollisionBound.TYPE_DEFENSE:
                return 0x00ff00;
            case CCollisionBound.TYPE_BLOCK:
                return 0x0000ff;
            default:
                return 0x00000;
        }
    }

    public function set nColor( value : int ) : void
    {
        if( this.m_nColor == value ) return;
        this.m_nColor = value;
        m_pQuad.verticesColor = value;
    }

    private var m_pQuad : Quad;
    private var m_nColor : int;
    private var m_pCollision : CCollisionBound;
}
}
