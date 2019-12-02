//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/8.
 */
package kof.game.yyVip {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.game.yyVip.data.CYYVipRewardData;
import kof.game.yyVip.view.CYYVipViewHandler;

import morn.core.handlers.Handler;

/**
 * yy会员
 * @author Diana (diana@qifun.com)
 */
public class CYYVipSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;
    private var m_pMainViewHandler:CYYVipViewHandler;
    private var m_pManager:CYYVipManager;
    private var m_pNetHandler:CYYVipNetHandler;
    private var m_pHelpHandler:CYYVipHelpHandler;
    private var yyData:CYYVipRewardData;
    public function CYYVipSystem( A_objBundleID : * = null )
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

            m_pMainViewHandler = new CYYVipViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new CYYVipNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CYYVipManager();
            this.addBean( m_pManager );

            m_pHelpHandler = new CYYVipHelpHandler();
            this.addBean( m_pHelpHandler );

            yyData = m_pManager.data;
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.YY_VIP);
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

        //获取YY数据
//        m_pNetHandler.platformRewardInfoYYRequest(1);
    }

    public function openMainfunction():void
    {
        // 登陆时主界面图标提示小红点
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.updateAllReward(yyData));
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.hasRewardToTake());
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

        var pView : CYYVipViewHandler = this.getHandler( CYYVipViewHandler ) as CYYVipViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CYYVipViewHandler isn't instance." );
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