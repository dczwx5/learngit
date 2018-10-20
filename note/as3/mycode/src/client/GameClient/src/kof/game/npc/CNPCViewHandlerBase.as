//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/19.
 */
package kof.game.npc {

import QFLib.Math.CVector3;

import kof.framework.CViewHandler;

import morn.core.handlers.Handler;

public class CNPCViewHandlerBase extends CViewHandler {

    private var m_pCloseHandler : Handler;

    public var isOpenView:Boolean;

    public function CNPCViewHandlerBase( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    public function updateFun(data:Object,position:CVector3):void
    {

    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function _addToDisplay() : void {
        isOpenView = true;

    }

    public function removeDisplay() : void {
        isOpenView = false;
    }
}
}
