//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/9.
 */
package kof.game.playerSuggest {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.event.CViewEvent;
import kof.game.playerSuggest.event.ESuggestViewEventType;
import kof.game.playerSuggest.view.CSuggestViewHandler;

import morn.core.handlers.Handler;

/**
 * 你提我改
 * @author sprite (sprite@qifun.com)
 */
public class CSuggestSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pViewHandler:CSuggestViewHandler;
    private var m_pNetHandler:CSuggestNetHandler;
    private var m_pManager:CSuggestManager;

    public function CSuggestSystem()
    {
        super();
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pViewHandler = new CSuggestViewHandler();
            this.addBean( m_pViewHandler );

            m_pNetHandler = new CSuggestNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CSuggestManager();
            this.addBean( m_pManager );
        }

        m_pViewHandler = m_pViewHandler || this.getHandler( CSuggestViewHandler ) as CSuggestViewHandler;
        m_pViewHandler.closeHandler = new Handler( _onViewClosed );

        addEventListeners();

        return m_bInitialized;
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    protected function addEventListeners() : void
    {
//        this.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStart, false, CEventPriority.DEFAULT, true );
//        this.addEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStop, false, CEventPriority.DEFAULT, true );
//        this.addEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserData, false, CEventPriority.DEFAULT, true );

        m_pViewHandler.addEventListener(CViewEvent.UI_EVENT,_onUIEventHandler,false,CEventPriority.DEFAULT,true);
    }

    protected function removeEventListeners() : void
    {
//        this.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStart );
//        this.removeEventListener( CSystemBundleEvent.BUNDLE_STOP, _onSystemBundleStop );
//        this.removeEventListener( CSystemBundleEvent.USER_DATA, _onSystemBundleUserData );

        m_pViewHandler.removeEventListener(CViewEvent.UI_EVENT,_onUIEventHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CSuggestViewHandler = this.getHandler( CSuggestViewHandler ) as CSuggestViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            pView.removeDisplay();
        }
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.SUGGESTION );
    }

//    private function _onSystemBundleStart( event : CSystemBundleEvent ) : void
//    {
//        this.enabled = true;
//    }

    private function _onUIEventHandler(e:CViewEvent):void
    {
        var uiEvent:String = e.subEvent;
        switch (uiEvent)
        {
            case ESuggestViewEventType.SubmitSuggest:// 提交建议
                var type:int = e.data["type"];
                var content:String = e.data["content"];
                if(m_pNetHandler)
                {
                    m_pNetHandler.playerSuggestionRequest(type,content);
                }
                break;
        }
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pViewHandler.dispose();
        m_pViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;
    }

}
}
