//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/9.
 */
package kof.game.playerCard {

import kof.SYSTEM_ID;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerSystem;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.view.CPlayerCardActiveViewHandler;
import kof.game.playerCard.view.CPlayerCardEffectViewHandler;
import kof.game.playerCard.view.CPlayerCardPoolViewHandler;
import kof.game.playerCard.view.CPlayerCardResultViewHandler;
import kof.game.playerCard.view.CPlayerCardViewHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

/**
 * 抽卡系统
 * @author sprite (sprite@qifun.com)
 */
public class CPlayerCardSystem extends CBundleSystem{

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CPlayerCardViewHandler;
    private var m_pManager:CPlayerCardManager;
    private var m_pNetHandler:CPlayerCardNetHandler;
    private var m_pActivityWin:CPlayerCardActiveViewHandler;

    public function CPlayerCardSystem()
    {
        super();

        CPlayerCardUtil.initialize(this);
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

            m_pMainViewHandler = new CPlayerCardViewHandler();
            this.addBean( m_pMainViewHandler );

            m_pNetHandler = new CPlayerCardNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CPlayerCardManager();
            this.addBean( m_pManager );

            m_pActivityWin = new CPlayerCardActiveViewHandler();
            this.addBean(m_pActivityWin);

            this.addBean( new CPlayerCardResultViewHandler() );
            this.addBean( new CPlayerCardPoolViewHandler() );
            this.addBean( new CPlayerCardEffectViewHandler() );
        }

        m_pMainViewHandler = m_pMainViewHandler || this.getHandler( CPlayerCardViewHandler ) as CPlayerCardViewHandler;
        m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.CARDPLAYER);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            if((stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData.teamData.level > 6 && !(stage.getSystem(CTutorSystem) as CTutorSystem).isPlaying)
            {
                instanceSystem.callWhenInMainCity( _showActiveWin, null, null, null, 1 );
            }
        }

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,CPlayerCardUtil.hasCardToPump());
        }

        addEventListeners();
    }

    protected function addEventListeners() : void
    {
        if(stage.getSystem(CBagSystem))
        {
            (stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }

        stage.getSystem(ISystemBundleContext ).addEventListener(CSystemBundleEvent.USER_DATA,_onUserDataHandler);
    }

    protected function removeEventListeners() : void
    {
        if(stage.getSystem(CBagSystem))
        {
            (stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }

        stage.getSystem(ISystemBundleContext ).removeEventListener(CSystemBundleEvent.USER_DATA,_onUserDataHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CPlayerCardViewHandler = this.getHandler( CPlayerCardViewHandler ) as CPlayerCardViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CPlayerCardViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            if(CPlayerCardUtil.IsInPumping)
            {
                (stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert(CLang.Get("playerCard_zzckz"),CMsgAlertHandler.WARNING);
                this.setActivated( true );
            }
            else
            {
                pView.removeDisplay();
                m_pActivityWin.removeDisplay();
            }
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    /**
     * 显示活动窗口
     */
    private function _showActiveWin():void
    {
        if(CPlayerCardUtil.isInActiveTime())
        {
            m_pActivityWin.addDisplay();
        }
    }

    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( null != pSystemBundleCtx )
            {
                var curState:Boolean = pSystemBundleCtx.getUserData(this,CBundleSystem.NOTIFICATION,false);
                var isCanPump:Boolean = CPlayerCardUtil.hasCardToPump();
                if(curState != isCanPump)
                {
                    pSystemBundleCtx.setUserData(this,CBundleSystem.NOTIFICATION,isCanPump);
                }
            }
        }
    }

    private function _onUserDataHandler(e:CSystemBundleEvent):void
    {
        if( e.bundle is CInstanceSystem)
        {
            if(m_pActivityWin.isViewShow)
            {
                m_pActivityWin.removeDisplay();
            }
        }
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;

        m_pActivityWin.dispose();
        m_pActivityWin = null;
    }
}
}
