//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/20.
 */
package kof.game.impression {

import kof.SYSTEM_ID;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.event.CViewEvent;
import kof.game.impression.event.EImpressionViewEventType;
import kof.game.impression.util.CImpressionRenderUtil;
import kof.game.impression.util.CImpressionUtil;
import kof.game.impression.view.CImpressionDisplayViewHandler;
import kof.game.impression.view.CImpressionUpSuccViewHandler;
import kof.game.impression.view.CImpressionViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;

import morn.core.handlers.Handler;

/**
 * 羁绊系统
 * @author sprite (sprite@qifun.com)
 */
public class CImpressionSystem extends CBundleSystem{

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CImpressionViewHandler;
    private var m_pDisplayViewHandler:CImpressionDisplayViewHandler;
    private var m_pNetHandler:CImpressionNetHandler;
    private var m_pManager:CImpressionManager;
    private var m_pUpSuccViewHandler:CImpressionUpSuccViewHandler;
    private var m_pHelpHandler:CImpressionHelpHandler;

    public function CImpressionSystem()
    {
        super ();

        CImpressionUtil.initialize(this);
        CImpressionRenderUtil.initialize(this);
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

            m_pMainViewHandler = new CImpressionViewHandler();
            this.addBean( m_pMainViewHandler );

            m_pDisplayViewHandler = new CImpressionDisplayViewHandler();
            this.addBean( m_pDisplayViewHandler );

            m_pNetHandler = new CImpressionNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CImpressionManager();
            this.addBean( m_pManager );

            m_pUpSuccViewHandler = new CImpressionUpSuccViewHandler();
            this.addBean( m_pUpSuccViewHandler );

            m_pHelpHandler = new CImpressionHelpHandler();
            this.addBean( m_pHelpHandler );
        }

        m_pMainViewHandler = m_pMainViewHandler || this.getHandler( CImpressionViewHandler ) as CImpressionViewHandler;
        m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.IMPRESSION );
    }

    /**
     * 系统开启
     * @param ctx
     */
    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( "IMPRESSION" ) );
        if ( pSystemBundleContext && pSystemBundle)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,CImpressionUtil.hasCanUpgradeHero());
        }

        addEventListeners();
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CImpressionViewHandler = this.getHandler( CImpressionViewHandler ) as CImpressionViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CImpressionViewHandler isn't instance." );
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

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    protected function addEventListeners() : void
    {
        this.addEventListener(CViewEvent.UI_EVENT,_onUIEventHandler,false,CEventPriority.DEFAULT,true);

        if(stage.getSystem(CBagSystem))
        {
            (stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }

        stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
    }

    protected function removeEventListeners() : void
    {
        this.removeEventListener(CViewEvent.UI_EVENT,_onUIEventHandler);

        if(stage.getSystem(CBagSystem))
        {
            (stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }

        stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
    }

    private function _onUIEventHandler(e:CViewEvent):void
    {
        var uiEvent:String = e.subEvent;
        switch (uiEvent) {
            case EImpressionViewEventType.ImpressionUpgrade:// 亲密度提升
                var roleId:int = e.data["roleId"];
                var itemId:int = e.data["itemId"];
                if(m_pNetHandler)
                {
                    m_pNetHandler.impressionUpgrade(roleId,itemId);
                }
                break;
        }
    }

    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            _updateRedPointTip();
        }
    }

    private function _updateRedPointTip():void
    {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( null != pSystemBundleCtx )
        {
            var curState:Boolean = pSystemBundleCtx.getUserData(this,CBundleSystem.NOTIFICATION,false);
            var canUpgrade:Boolean = CImpressionUtil.hasCanUpgradeHero();
            if(curState != canUpgrade)
            {
                pSystemBundleCtx.setUserData(this,CBundleSystem.NOTIFICATION,canUpgrade);
            }
        }
    }

    private function _onHeroDataUpdateHandler(e:CPlayerEvent):void
    {
        _updateRedPointTip();
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;

        m_pDisplayViewHandler.dispose();
        m_pDisplayViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;

        m_pUpSuccViewHandler.dispose();
        m_pUpSuccViewHandler = null;

        m_pHelpHandler.dispose();
        m_pHelpHandler = null;
    }
}
}
