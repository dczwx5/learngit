//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena.view {

import kof.framework.CViewHandler;

public class CArenaAnimationViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    public function CArenaAnimationViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
//        return [ PlayerCardMainViewUI ];
        return [];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
//            if ( !m_pViewUI )
//            {
//                m_pViewUI = new PlayerCardMainViewUI();
//                m_pViewUI.closeHandler = new Handler( _onClose );
//
//                m_bViewInitialized = true;
//            }
        }

        m_bViewInitialized = true;
        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
//        uiCanvas.addDialog( m_pViewUI );

        _initView();
    }

    private function _initView():void
    {
        updateDisplay();
    }

    override protected function updateDisplay():void
    {
    }

    override public function dispose():void
    {
        super.dispose();
    }
}
}