//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/13.
 */
package kof.game.platformDownloadReward {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platformDownloadReward.event.CPlatformBoxRewardEvent;
import kof.game.player.CPlayerSystem;

import morn.core.handlers.Handler;

/**
 * 平台盒子下载礼包奖励
 * @author sprite (sprite@qifun.com)
 */
public class CPlatformBoxRewardSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CPlatformBoxRewardViewHandler;
    private var m_pManager:CPlatformBoxRewardManager;
    private var m_pNetHandler:CPlatformBoxRewardNetHandler;
    private var m_pHelpHandler:CPlatformBoxHelpHandler;

    public function CPlatformBoxRewardSystem( A_objBundleID : * = null )
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

            m_pMainViewHandler = new CPlatformBoxRewardViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new CPlatformBoxRewardNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CPlatformBoxRewardManager();
            this.addBean( m_pManager );

            m_pHelpHandler = new CPlatformBoxHelpHandler();
            this.addBean( m_pHelpHandler );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.PLATFORM_BOX);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        var platformData:CPlatformBaseData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).platform.data;
        if(platformData && platformData.platform != EPlatformType.PLATFORM_2144)
        {
            ctx.stopBundle(this);
            return;
        }

        if(m_pManager.rewardTakeState == 1)
        {
            ctx.stopBundle(this);
            return;
        }

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.isLoginFromBox()
                    && m_pManager.rewardTakeState == 0);
        }

        _addEventListeners();
    }

    override protected function onBundleStop( pCtx : ISystemBundleContext ) : void
    {
        super.onBundleStop(pCtx);

        _removeEventListeners();
    }

    protected function _addEventListeners() : void
    {
        this.addEventListener(CPlatformBoxRewardEvent.GetRewardSucc, _onRewardsInfoUpdateHandler);
        this.addEventListener(CPlatformBoxRewardEvent.RewardInfo, _onRewardsInfoUpdateHandler);
    }

    protected function _removeEventListeners() : void
    {
        this.removeEventListener(CPlatformBoxRewardEvent.GetRewardSucc, _onRewardsInfoUpdateHandler);
        this.removeEventListener(CPlatformBoxRewardEvent.RewardInfo, _onRewardsInfoUpdateHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CPlatformBoxRewardViewHandler = this.getHandler( CPlatformBoxRewardViewHandler )
                as CPlatformBoxRewardViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CPlatformBoxRewardViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            pView.removeDisplay();

            if(pView.isTakeReward)
            {
                var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
                if ( pSystemBundleContext)
                {
                    pSystemBundleContext.stopBundle(this);
                }
            }
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    private function _onRewardsInfoUpdateHandler(e:CPlatformBoxRewardEvent = null):void
    {
        // 小红点提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.isLoginFromBox()
                    && m_pManager.rewardTakeState == 0);
        }
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
