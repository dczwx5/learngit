//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.ranking {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.ranking.view.CRankingViewHandler;

import morn.core.handlers.Handler;

/**
 * 排行榜系统
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CRankingSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    /**
     * Creates a new CRankingSystem.
     */
    public function CRankingSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CRankingViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CRankingViewHandler();
            this.addBean( pView );
        }

        pView = pView || this.getHandler( CRankingViewHandler ) as CRankingViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
//        return SYSTEM_ID( KOFSysTags.RANKING );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CRankingViewHandler = this.getHandler( CRankingViewHandler ) as CRankingViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

}
}
