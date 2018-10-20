//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/13.
 */
package kof.game.playerCard.view {

import kof.framework.CViewHandler;
import kof.ui.master.playerCard.PlayerCardMainViewUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

/**
 * 角色抽卡活动界面
 */
public class CPlayerCardActiveViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI:PlayerCardMainViewUI;

    public function CPlayerCardActiveViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
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
            if ( !m_pViewUI )
            {
                m_pViewUI = new PlayerCardMainViewUI();

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
        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);
        }
    }

    private function _onClose( type : String ) : void
    {
    }

    private function _initView():void
    {
        updateDisplay();
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override protected function updateDisplay():void
    {
        // TODO
    }
}
}
