//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/20.
 */
package kof.game.rank {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.rank.view.CRankMenuHandler;
import kof.game.rank.view.CRankViewHandler;

import morn.core.handlers.Handler;

public class CRankSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pRankHandler : CRankHandler;

    private var _pRankManager : CRankManager;

    private var _pRankViewHandler : CRankViewHandler;

    private var _pRankMenuHandler : CRankMenuHandler;

    public function CRankSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }
    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pRankManager = new CRankManager() );
            this.addBean( _pRankHandler = new CRankHandler() );
            this.addBean( _pRankViewHandler = new CRankViewHandler() );
            this.addBean( _pRankMenuHandler = new CRankMenuHandler() );
        }

        _pRankViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }
    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CRankViewHandler = this.getHandler( CRankViewHandler ) as CRankViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        var typeArr : * = ctx.getUserData( this, CBundleSystem.RANK_TYPE , false );
        var type:int = 0;
        if( typeArr ){
            type = typeArr[0];
        }

        if ( value ) {
            pView.addDisplay( type );
        } else {
            pView.removeDisplay();
        }
    }
    private function _onViewClosed() : void {
        this.setActivated( false );
    }
    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.RANKING );
    }
    public override function dispose() : void {
        super.dispose();

        _pRankManager.dispose();
        _pRankHandler.dispose();
        _pRankViewHandler.dispose();
        _pRankMenuHandler.dispose();
    }
}
}
