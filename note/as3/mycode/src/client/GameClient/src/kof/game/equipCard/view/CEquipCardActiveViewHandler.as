//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.view {

import kof.framework.CViewHandler;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CEquipCardActiveViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

//    private var m_pViewUI:PlayerCardActiveViewUI;

    public function CEquipCardActiveViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    /*
    override public function get viewClass() : Array
    {
        return [PlayerCardActiveViewUI];
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
                m_pViewUI = new PlayerCardActiveViewUI();

                m_pViewUI.closeHandler = new Handler( _onClose );

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
            invalidate();
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
        uiCanvas.addDialog( m_pViewUI );

        _initView();
    }

    public function removeDisplay() : void
    {
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if (m_pViewUI && m_pViewUI.parent)
                {
                    m_pViewUI.close(Dialog.CLOSE);
                }
                break;
        }
    }

    private function _initView():void
    {
        updateDisplay();
    }

    override protected function updateDisplay():void
    {
        // TODO
    }
    */
}
}
