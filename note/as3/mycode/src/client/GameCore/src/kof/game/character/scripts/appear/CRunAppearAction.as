//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/28.
 */
package kof.game.character.scripts.appear {

import QFLib.Foundation;
import QFLib.Framework.CObject;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.display.IDisplay;

import kof.game.character.movement.CNavigation;
import kof.game.character.movement.CNavigationEvent;
import kof.game.character.movement.INavigationListener;
import kof.game.core.CGameObject;

/**
 * Appear by run from a born position to a target position.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CRunAppearAction extends CAppearAction {

    /**
     * @private
     */
    private var m_pPathList : Vector.<Point>;
    private var m_pNavListener : INavigationListener;
    private var m_pAppearData:Object;

    /**
     * Creates a new CRunAppearAction.
     */
    public function CRunAppearAction( pOwner : CGameObject, pAppearData : Object ) {
        super( pOwner );

        var positions : Array = pAppearData.pos[ 'location' ] as Array;
        m_pAppearData = pAppearData;
        if ( positions && positions.length > 1 ) {
            m_pPathList = new <Point>[];

            var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;

            for ( var i : int = 1; i < positions.length; ++i ) {
                var pos3D : CVector3 = CObject.get3DPositionFrom2D( pDisplay.modelDisplay, positions[ i ].x, positions[ i ].y );
                var p : Point = new Point( pos3D.x, pos3D.z );
                m_pPathList.push( p );
            }
        }else {
            Foundation.Log.logErrorMsg("路径点报错!!!! + 路径点长度：" +positions.length);
        }
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        if ( m_pPathList && m_pPathList.length ) {
            var pNav : CNavigation = owner.getComponentByClass( CNavigation, true ) as CNavigation;

            if ( pNav ) {
                // FIXME: Use pathList when CNavigation supported.
                // pNav.pathList = m_pPathList;
                pNav.pathList = m_pPathList;

                var l : INavigationListener = pNav.newListener();
                l.addEventListener( CNavigationEvent.EVENT_END, _onNavigationEnd, false );
                pNav.addListener( l );

                m_pNavListener = l;
            }
        }
    }

    /**
     * @private
     */
    private function _onNavigationEnd( event : CNavigationEvent ) : void {
        m_pNavListener.removeEventListener( event.type, _onNavigationEnd );
        m_pNavListener.dispose();
        m_pNavListener = null;

        this.setResult( m_pAppearData.isPlayAction  );
    }

}
}
