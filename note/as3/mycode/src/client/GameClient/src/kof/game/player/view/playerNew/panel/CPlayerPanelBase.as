//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew.panel {

import flash.display.DisplayObjectContainer;

import kof.framework.CViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;

import morn.core.components.View;

public class CPlayerPanelBase extends CViewHandler{

    protected var m_bViewInitialized : Boolean;
    protected var m_pViewUI:View;

    public function CPlayerPanelBase()
    {
        super ();
    }

    public function initializeView():void
    {
        m_bViewInitialized = true;
    }

    protected function _addListeners():void
    {
        (system as CPlayerSystem).addEventListener(CPlayerEvent.SWITCH_HERO, _onSwitchHeroHandler);
    }

    protected function _removeListeners():void
    {
        (system as CPlayerSystem).removeEventListener(CPlayerEvent.SWITCH_HERO, _onSwitchHeroHandler);
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

    /**
     * 切换格斗家
     */
    protected function _onSwitchHeroHandler(e:CPlayerEvent):void
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

    protected function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
    }
}
}
