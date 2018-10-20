//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/9.
 */
package kof.game.yyWeChat {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.yyWeChat.view.CYYWeChatViewHandler;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;

import morn.core.handlers.Handler;

/**
 * 微信
 * @author Diana (diana@qifun.com)
 */
public class CYYWeChatSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;
    private var m_pMainViewHandler:CYYWeChatViewHandler;
    private var m_pManager:CYYWeChatManager;
    private var m_pNetHandler:CYYWeChatNetHandler;
    private var m_pHelpHandler:CYYWeChatHelpHandler;
    public function CYYWeChatSystem( A_objBundleID : * = null )
    {
        super( A_objBundleID );
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

            m_pMainViewHandler = new CYYWeChatViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new CYYWeChatNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CYYWeChatManager();
            this.addBean( m_pManager );

            m_pHelpHandler = new CYYWeChatHelpHandler();
            this.addBean( m_pHelpHandler );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.YY_WECHAT);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);
        var platformData:CPlatformBaseData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).platform.data;
        if(platformData && platformData.platform != EPlatformType.PLATFORM_YY)
        {
            ctx.stopBundle(this);//不是YY平台则屏蔽掉
            return;
        }
        _addEventListeners();
    }
    protected function _addEventListeners() : void
    {
    }

    protected function _removeEventListeners() : void
    {
    }
    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CYYWeChatViewHandler = this.getHandler( CYYWeChatViewHandler ) as CYYWeChatViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CYYWeChatViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();//图标红点显示
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

    override public function dispose() : void
    {
        super.dispose();

        if(m_pMainViewHandler)
        {
            m_pMainViewHandler.dispose();
            m_pMainViewHandler = null;
        }

        if(m_pManager)
        {
            m_pManager.dispose();
            m_pManager = null;
        }

        if(m_pNetHandler)
        {
            m_pNetHandler.dispose();
            m_pNetHandler = null;
        }

        if(m_pHelpHandler)
        {
            m_pHelpHandler.dispose();
            m_pHelpHandler = null;
        }
    }
}
}
