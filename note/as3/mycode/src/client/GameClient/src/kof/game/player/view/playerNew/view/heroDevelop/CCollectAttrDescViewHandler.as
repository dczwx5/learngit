//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/25.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import kof.framework.CViewHandler;
import kof.ui.master.jueseNew.CollectAttrDescWinUI;

import morn.core.components.Dialog;

public class CCollectAttrDescViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:CollectAttrDescWinUI;

    public function CCollectAttrDescViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ CollectAttrDescWinUI];
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
            if ( !m_pViewUI )
            {
                m_pViewUI = new CollectAttrDescWinUI();

                m_bViewInitialized = true;
            }
        }

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
        uiCanvas.addPopupDialog(m_pViewUI);
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }
}
}
