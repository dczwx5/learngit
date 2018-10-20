//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/11.
 */
package kof.game.GMReport.view {

import kof.framework.CViewHandler;
import kof.ui.SubmitSuccUI;

public class CGMSubmitSuccViewHandler extends CViewHandler
{
    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : SubmitSuccUI;

    public function CGMSubmitSuccViewHandler()
    {
    }

    override public function get viewClass() : Array
    {
        return [SubmitSuccUI];
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
                m_pViewUI = new SubmitSuccUI();

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
        uiCanvas.addPopupDialog( m_pViewUI );
    }
}
}
