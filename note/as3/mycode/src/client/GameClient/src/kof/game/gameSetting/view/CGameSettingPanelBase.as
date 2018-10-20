//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/1.
 */
package kof.game.gameSetting.view {

import flash.display.DisplayObjectContainer;

import kof.framework.CViewHandler;

import morn.core.components.View;

public class CGameSettingPanelBase extends CViewHandler {

    protected var m_bViewInitialized : Boolean;
    protected var m_pViewUI:View;

    public function CGameSettingPanelBase( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    public function initializeView():void
    {
        m_bViewInitialized = true;
    }

    protected function _addListeners():void
    {
    }

    protected function _removeListeners():void
    {
    }

    public function set data(value:*):void
    {
    }

    public function addDisplay(parent:DisplayObjectContainer, x:int = 0, y:int = 0):void
    {
        if(parent && m_pViewUI)
        {
            parent.addChild(m_pViewUI);
            m_pViewUI.x = x;
            m_pViewUI.y = y;
        }

        _initView();
        _addListeners();
    }

    protected function _initView():void
    {

    }

    public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();
            clear();

            if(isViewShow)
            {
                m_pViewUI.parent.removeChild(m_pViewUI);
            }
        }
    }

    public function updateAll():void
    {
        if(isViewShow)
        {
            updateDisplay();
        }
    }

    public function clear():void
    {

    }

    public function get view():View
    {
        return m_pViewUI;
    }

    public function set view(value:View):void
    {
        m_pViewUI = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
    }
}
}
