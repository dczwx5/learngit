//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/30.
 */
package kof.game.sevenkHall.view {

import QFLib.Foundation;

import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.framework.CViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.platform.sevenK.SevenKEpiredWinUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class C7KExpiredViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : SevenKEpiredWinUI;

    public function C7KExpiredViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [SevenKEpiredWinUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["sevenK.swf"];
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
                m_pViewUI = new SevenKEpiredWinUI();
                m_pViewUI.btn_renewFee.clickHandler = new Handler(_onRenewFeeHandler);

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
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            if(playerData)
            {
                m_pViewUI.txt_playerName.text = "亲爱的" + playerData.teamData.name + "：";
            }
        }
    }

    private function _onRenewFeeHandler():void
    {
        if ( ExternalInterface.available )
        {
            try
            {
                ExternalInterface.call( "goToVipSite" );
            }
            catch ( e : Error )
            {
                Foundation.Log.logErrorMsg( "goTo 7k7k VipSite error caught: " + e.message );
            }
        }

        removeDisplay();
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }
}
}
