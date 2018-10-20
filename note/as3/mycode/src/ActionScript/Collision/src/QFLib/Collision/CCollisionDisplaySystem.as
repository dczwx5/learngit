//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/24.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Collision.CCollisionQuadObject;
import QFLib.Foundation.CMap;
import QFLib.Graphics.RenderCore.CRenderer;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Node.CNode;

public class CCollisionDisplaySystem implements IUpdatable , IDisposable{
    public function CCollisionDisplaySystem( renderer : CRenderer ) {
        m_theDisplayMap = new CMap();
        m_pRenderer = renderer;
    }

    public function update( delta : Number ) : void
    {
        if( !m_boEnable ) return;

        for( var key : CCollisionBound in m_theDisplayMap )
        {
            var showQuad : CCollisionQuadObject = m_theDisplayMap.find( key );
            showQuad.update( delta );
        }
    }

    public function dispose() : void
    {
        clearCollisionBound();
        m_theDisplayMap = null;
        m_pRenderer = null;
    }

    public function set enable( value : Boolean ) : void
    {
        m_boEnable = value;
        if( !m_boEnable )
            clearCollisionBound();
    }

    public function get enable() : Boolean
    {
        return m_boEnable;
    }

    public function displayCollisionBond( bound : CCollisionBound ) : void
    {
        var showQuad : CCollisionQuadObject = m_theDisplayMap.find( bound );
        if( showQuad ) return;

        showQuad = new CCollisionQuadObject( m_pRenderer );
        showQuad.setCollisionBound( bound );
        showQuad.setParent( bound.pAttacherRef.renderableObject.parent) ;
        m_theDisplayMap.add( bound , showQuad );
    }

    public function hideCollisionBound( bound : CCollisionBound ) : void
    {
        var showQuad : CCollisionQuadObject = m_theDisplayMap.find( bound );
        if( showQuad ) {
            delete m_theDisplayMap[ bound ];
            showQuad.dispose();
            showQuad = null;
        }
    }

    public function clearCollisionBound( ) : void
    {
        for( var key : CCollisionBound in m_theDisplayMap )
        {
            hideCollisionBound( key  );
        }
    }

    private var m_boEnable : Boolean = false;
    private var m_theDisplayMap : CMap;
    private var m_pRenderer : CRenderer;
}
}
