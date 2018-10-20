//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/11.
 */
package kof.game.player.view.playerNew.view.reborn {

import flash.events.Event;

import kof.framework.CViewHandler;

import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.jueseNew.reborn.RebornConfirmUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;


public class CRebornRuleView extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:RebornConfirmUI;

    public function CRebornRuleView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        m_pViewUI = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        return ret;
    }

    override public function get viewClass() : Array {
        return [RebornConfirmUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return null;
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() ) {
            return false;
        }

        if ( !m_bViewInitialized ) {
            if ( !m_pViewUI ) {
                m_pViewUI = new RebornConfirmUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.ok_btn.clickHandler = new Handler(_onOk);
                m_pViewUI.cancelBtn.clickHandler = new Handler(_onCancel);
                m_pViewUI.checkBox.clickHandler = new Handler(_onClickCheckBox);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay(heroData:CPlayerHeroData, rewardData:Array, consumeValue:int) : void {
        _data = heroData;
        _rewardData = rewardData;
        _consumeValue = consumeValue;
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            m_pViewUI.checkBox.selected = false;

            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        if(m_pViewUI.parent == null) {
            uiCanvas.addPopupDialog( m_pViewUI );
        }
    }


    override protected function updateDisplay() : void {

    }
    private function _onClickCheckBox() : void {

//        dispatchEvent(new Event("OkConfirm"));
//        removeDisplay();
    }
    private function _onOk() : void {
        if (m_pViewUI.checkBox.selected) {
            dispatchEvent(new Event("StopPopupRuleEvent"));
        }
        dispatchEvent(new Event("OkConfirm"));
        removeDisplay();
    }
    private function _onCancel() : void {
        removeDisplay();
    }
    private function _onClose(type : String) : void {
        removeDisplay();
    }

    public function removeDisplay() : void {
        if ( m_pViewUI && m_pViewUI.parent ) {
            m_pViewUI.close( Dialog.CLOSE );
        }
    }

    public function get isViewShow() : Boolean {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function get viewUI() : Component {
        return m_pViewUI;
    }

    public function get data() : CPlayerHeroData {
        return _data;
    }
    public function get rewardData() : Array {
        return _rewardData;
    }
    public function get consumeValue() : int {
        return _consumeValue;
    }
    private var _data:CPlayerHeroData;
    private var _rewardData:Array;
    private var _consumeValue:int;
}
}
