//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/19.
 */
package kof.game.reciprocation {

import flash.external.ExternalInterface;

import kof.framework.CViewHandler;
import kof.ui.master.AntiAddiction.AntiAddictionWinUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CAntiAddictionViewHandler extends CViewHandler {

    private var m_pViewUI : AntiAddictionWinUI;
    private var m_bViewInitialized : Boolean;

    public function CAntiAddictionViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [AntiAddictionWinUI];
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
                m_pViewUI = new AntiAddictionWinUI();
                m_pViewUI.btn_confirm.clickHandler = new Handler(_onConfirmHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView(viewClass, _showDisplay);
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            _addToDisplay();
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog(m_pViewUI);
    }

    public function removeDisplay():void
    {
        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);
        }
    }

    private function _onConfirmHandler():void
    {
        ExternalInterface.call("complementIDCard");
        removeDisplay();
    }
}
}
