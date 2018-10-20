//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.yyHall {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;

import morn.core.handlers.Handler;

/**
 * yy特权大厅
 * @author sprite (sprite@qifun.com)
 */
public class CYYHallSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CYYHallViewHandler;
    private var m_pManager:CYYHallManager;
    private var m_pNetHandler:CYYHallNetHandler;
    private var m_pHelpHandler:CYYHallHelpHandler;
    private var yyData:CYYRewardData;
    public function CYYHallSystem( A_objBundleID : * = null )
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

            m_pMainViewHandler = new CYYHallViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new CYYHallNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CYYHallManager();
            this.addBean( m_pManager );

            m_pHelpHandler = new CYYHallHelpHandler();
            this.addBean( m_pHelpHandler );

            yyData = m_pManager.data;
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.YY_HALL);
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
        m_pNetHandler.platformRewardInfoYYRequest(1);
    }
    public function openMainfunction():void
    {
        // 登陆时主界面图标提示
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

        var pView : CYYHallViewHandler = this.getHandler( CYYHallViewHandler ) as CYYHallViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CYYHallViewHandler isn't instance." );
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
