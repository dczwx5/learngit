//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/18.
 */
package kof.game.sevenkHall {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.sevenK.C7KData;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.sevenkHall.event.C7K7KEvent;
import kof.game.sevenkHall.view.C7KExpiredViewHandler;
import kof.game.sevenkHall.view.C7KHallViewHandler;

import morn.core.handlers.Handler;

/**
 * 7k畅玩平台
 * @author sprite (sprite@qifun.com)
 */
public class C7KHallSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:C7KHallViewHandler;
    private var m_pManager:C7KHallManager;
    private var m_pNetHandler:C7KHallNetHandler;
    private var m_pHelpHandler:C7KHallHelpHandler;
    private var m_pExpiredViewHandler:C7KExpiredViewHandler;

    public function C7KHallSystem( A_objBundleID : * = null )
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

            m_pMainViewHandler = new C7KHallViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pNetHandler = new C7KHallNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new C7KHallManager();
            this.addBean( m_pManager );

            m_pHelpHandler = new C7KHallHelpHandler();
            this.addBean( m_pHelpHandler );

            m_pExpiredViewHandler = new C7KExpiredViewHandler();
            this.addBean( m_pExpiredViewHandler );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.SEVENK_HALL);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        var platformData:CPlatformBaseData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).platform.data;
        if(platformData && platformData.platform != EPlatformType.PLATFORM_7K)
        {
            ctx.stopBundle(this);
            return;
        }

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.hasRewardToTake());
        }

        _expiredTip();

        _addEventListeners();
    }

    protected function _addEventListeners() : void
    {
        this.addEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
        this.addEventListener(C7K7KEvent.UpdateDailyRewardState, _onRewardsInfoUpdateHandler);
        this.addEventListener(C7K7KEvent.UpdateNewRewardState, _onRewardsInfoUpdateHandler);
        this.addEventListener(C7K7KEvent.UpdateLevelRewardState, _onRewardsInfoUpdateHandler);
        stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
        this.addEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
    }

    protected function _removeEventListeners() : void
    {
        this.removeEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
        this.removeEventListener(C7K7KEvent.UpdateDailyRewardState, _onRewardsInfoUpdateHandler);
        this.removeEventListener(C7K7KEvent.UpdateNewRewardState, _onRewardsInfoUpdateHandler);
        this.removeEventListener(C7K7KEvent.UpdateLevelRewardState, _onRewardsInfoUpdateHandler);
        stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
        this.removeEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : C7KHallViewHandler = this.getHandler( C7KHallViewHandler ) as C7KHallViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the C7KHallViewHandler isn't instance." );
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

    private function _onRewardsInfoUpdateHandler(e:C7K7KEvent = null):void
    {
        // 小红点提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.hasRewardToTake());
        }
    }

    private function _onTeamLevelUpHandler(e:CPlayerEvent):void
    {
        _onRewardsInfoUpdateHandler();
    }

    /**
     * 过期提示
     */
    private function _expiredTip():void
    {
        var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var data:C7KData = pPlayerSystem.platform.sevenKData;
        if(data)
        {
            var expiredTime:Number = data.vipExpired * 1000;
            var nowTime:Number = CTime.getCurrServerTimestamp();
            if(nowTime < expiredTime)// 3天内即将到期
            {
                var diff:Number = expiredTime - nowTime;
                var day:int = Math.ceil(diff / (24 * 60 * 60 * 1000));
                if(day <= 3)
                {
                    m_pExpiredViewHandler.addDisplay();
                }
            }
            else// 已过期3天内
            {
                diff = nowTime - expiredTime;
                day = Math.floor(diff / (24 * 60 * 60 * 1000));
                if(day <= 3)
                {
                    m_pExpiredViewHandler.addDisplay();
                }
            }
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

        if(m_pExpiredViewHandler)
        {
            m_pExpiredViewHandler.dispose();
            m_pExpiredViewHandler = null;
        }
    }
}
}
