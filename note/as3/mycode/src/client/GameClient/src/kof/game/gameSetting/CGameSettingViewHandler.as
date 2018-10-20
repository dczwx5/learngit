//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/1.
 */
package kof.game.gameSetting {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.common.view.CTweenViewHandler;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.game.gameSetting.view.CFunctionSettiongPanel;
import kof.game.gameSetting.view.CGameSettingPanelBase;
import kof.game.gameSetting.view.CKeyboardSettingPanel;
import kof.game.player.view.playerNew.data.CTabInfoData;
import kof.ui.master.gameSetting.GameSettingKeyUI;
import kof.ui.master.gameSetting.GameSettingMiscUI;
import kof.ui.master.gameSetting.GameSettingUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CGameSettingViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:GameSettingUI;
    private var m_pCurrSelPanel:CGameSettingPanelBase;
    private var m_iSelectedIndex:int;
    private var m_pCloseHandler:Handler;

    private var m_pKeyboardSettingPanel:CKeyboardSettingPanel;// 按键设置
    private var m_pFunctionSettingPanel:CFunctionSettiongPanel;// 功能设置

    public function CGameSettingViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault )
        {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        this.addBean(m_pKeyboardSettingPanel = new CKeyboardSettingPanel());
        this.addBean(m_pFunctionSettingPanel = new CFunctionSettiongPanel());

        _reqInfo();

        return ret;
    }

    private function _reqInfo():void
    {
        (system.getHandler(CGameSettingNetHandler) as CGameSettingNetHandler).getAllGameSettingRequest();
    }

    override public function get viewClass() : Array
    {
        return [GameSettingKeyUI, GameSettingMiscUI];
    }

    override protected function get additionalAssets() : Array
    {
        return ["gameSetting.swf"];
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
                m_pViewUI = new GameSettingUI();
                m_pViewUI.closeHandler = new Handler( _onClose );

                m_pKeyboardSettingPanel.initializeView();
                m_pFunctionSettingPanel.initializeView();

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
            callLater( _tweenShow );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _tweenShow():void
    {
        setTweenData(KOFSysTags.GAMESETTING);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
//        if(m_pViewUI.parent == null)
//        {
            _initView();
            _onTabSelectedHandler();
            _addListeners();
//        }

//        uiCanvas.addDialog( m_pViewUI );
    }

    private function _initView():void
    {
        _initTabBarData();
        m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
    }

    private function _initTabBarData():void
    {
        var tabDataVec:Vector.<CTabInfoData> = _helpHandler.getTabInfoData();
        m_pViewUI.tab.dataSource = tabDataVec;

        var labels:String = "";
        for each(var info:CTabInfoData in tabDataVec)
        {
            labels += info.tabNameCN + ",";
        }

        m_pViewUI.tab.labels = labels.slice(0,labels.length-1);
    }

    public function removeDisplay() : void
    {
        closeDialog(_remove);
    }

    private function _remove():void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            m_iSelectedIndex = 0;

            if(m_pCurrSelPanel)
            {
                m_pCurrSelPanel.removeDisplay();
                m_pCurrSelPanel = null;
            }
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
        m_pViewUI.btn_close.addEventListener(MouseEvent.CLICK, _onCloseHandler);
        system.addEventListener(CGameSettingEvent.UpdateAllSettings, _onAllSettingsUpdateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
        m_pViewUI.btn_close.removeEventListener(MouseEvent.CLICK, _onCloseHandler);
        system.removeEventListener(CGameSettingEvent.UpdateAllSettings, _onAllSettingsUpdateHandler);
    }

    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void
    {
        if(m_pCurrSelPanel)
        {
            m_pCurrSelPanel.removeDisplay();
            m_pCurrSelPanel = null;
        }

        if(m_pViewUI.tab.selectedIndex >= 0)
        {
            var tabData:CTabInfoData = m_pViewUI.tab.dataSource[m_pViewUI.tab.selectedIndex] as CTabInfoData;

            if(tabData)
            {
                _helpHandler.currSelPanelIndex = tabData.tabIndex;

                var panelClass:Class = tabData.panelClass;
                m_pCurrSelPanel = this.getBean(panelClass);
//                m_pCurrSelPanel.data = currSelHeroData;
                m_pCurrSelPanel.addDisplay(m_pViewUI.box_panel);
            }
        }
    }

    override protected function updateDisplay():void
    {
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }

//监听==============================================================================================================
    private function _onCloseHandler(e:MouseEvent):void
    {
        if(m_pKeyboardSettingPanel.isKeyNull())
        {
            uiCanvas.showMsgBox("有键位尚未设置", null, null, true, "确定");
            return;
        }

        if(m_pKeyboardSettingPanel.isKeyChange())
        {
            uiCanvas.showMsgBox( "键位设置尚未保存，确定保存?", close, cancle, true, "确定", "取消");
            function cancle() : void
            {
                return;
            }
            function  close() : void
            {
                m_pKeyboardSettingPanel.saveChange();
                _onClose("close");
            }
        }
        else
        {
            _onClose("close");
        }
    }

    private function _onAllSettingsUpdateHandler(e:CGameSettingEvent):void
    {
        m_pCurrSelPanel.updateAll();
    }

    public function isKeyNull():Boolean
    {
        if(m_pKeyboardSettingPanel)
        {
            return m_pKeyboardSettingPanel.isKeyNull();
        }

        return false;
    }

    public function isKeyChange():Boolean
    {
        if(m_pKeyboardSettingPanel)
        {
            return m_pKeyboardSettingPanel.isKeyChange();
        }

        return false;
    }

    public function isSaved():Boolean
    {
        if(m_pKeyboardSettingPanel)
        {
            return m_pKeyboardSettingPanel.isSaved;
        }

        return false;
    }

//property==========================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    public function get _helpHandler():CGameSettingHelpHandler
    {
        return system.getHandler(CGameSettingHelpHandler) as CGameSettingHelpHandler;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose() : void
    {
        super.dispose();
    }
}
}
