//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/1.
 */
package kof.game.peakGame.view.main {

import kof.framework.CViewHandler;
import kof.ui.demo.Bag.ImportantNoteUI;

import morn.core.components.Button;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CPeakGameTipViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ImportantNoteUI;
    private var m_bIsNotTip:Boolean;
    private var m_pCallBack:Function;

    public function CPeakGameTipViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ImportantNoteUI];
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
                m_pViewUI = new ImportantNoteUI();

                (m_pViewUI.getChildByName("ok") as Button).clickHandler = new Handler(_onClickOKHandler);
                (m_pViewUI.getChildByName("cancel") as Button).clickHandler = new Handler(_onClickCancelHandler);
                m_pViewUI.checkBox.clickHandler = new Handler(_onClickCheckBoxHandler);

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
        if(m_pViewUI.parent == null)
        {
            _initView();
            _addListeners();
        }

        uiCanvas.addPopupDialog(m_pViewUI);
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
            m_pViewUI.txt_cont.text = "0点到8点时间段内，参与拳皇大赛将不会获得积分奖励，是否继续参与？";
            m_pViewUI.checkBox.visible = true;
            m_pViewUI.checkBox.label = "本次在线不再提示";
            m_pViewUI.checkBox.selected = m_bIsNotTip;
        }
    }

    private function _onClickOKHandler():void
    {
        if(m_pCallBack)
        {
            m_pCallBack.apply();
            this.removeDisplay();
        }
    }

    private function _onClickCancelHandler():void
    {
        this.removeDisplay();
    }

    private function _onClickCheckBoxHandler():void
    {
        m_bIsNotTip = m_pViewUI.checkBox.selected;
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

    public function set callBackFunc(value:Function):void
    {
        m_pCallBack = value;
    }

    public function get isNotTip():Boolean
    {
        return m_bIsNotTip;
    }
}
}
