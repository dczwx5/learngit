//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/28.
 */
package kof.game.character.scripts.appear {

import QFLib.Math.CVector2;

import kof.game.character.CKOFTransform;

import kof.game.core.CGameObject;

/**
 * Appear by normal type, just located to the target position.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNormalAppearAction extends CAppearAction {

    private var m_pTargetPoint : CVector2;

    private var m_pAppearData:Object;

    public function CNormalAppearAction( pOwner : CGameObject, pAppearData : Object ) {
        super( pOwner );

        var positions : Array = pAppearData[ 'pos' ] as Array;
        m_pAppearData = pAppearData;
        if ( positions && positions.length ) {
            var fX : Number = Number( positions[ 0 ].x );
            var fY : Number = Number( positions[ 0 ].y );

            if ( !isNaN( fX ) && !isNaN( fY ) ) {
                m_pTargetPoint = new CVector2( fX, fY );
            }
        }
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        if ( m_pTargetPoint ) {
//            var pos3D : CVector3 = CObject.get3DPositionFrom2D( m_pTargetPoint.x, m_pTargetPoint.y );
//
//            owner.transform.x = pos3D.x;
//            owner.transform.y = pos3D.z;
//            owner.transform.z = pos3D.y;
            var pTransform : CKOFTransform = owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            pTransform.from2DAxis( m_pTargetPoint.x, m_pTargetPoint.y, 0, true );
        }

        this.setResult( m_pAppearData.isPlayAction );
    }

}

}
