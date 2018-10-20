//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/17.
 */
package kof.game.recharge.dailyRecharge {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.playerCard.CPlayerCardSystem;
import kof.util.CSharedObject;

import morn.core.handlers.Handler;

public class CDailyRechargeSystem extends CBundleSystem
{
    public function CDailyRechargeSystem()
    {
        super ();
    }

    private var m_bInitialized : Boolean;

    private var m_pViewHandler:CDailyRechargeViewHandler;
    private var m_pNetHandler:CDailyRechargeNetHandler;
    private var m_pManager:CDailyRechargeManager;

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pViewHandler = new CDailyRechargeViewHandler();
            this.addBean( m_pViewHandler );

            m_pNetHandler = new CDailyRechargeNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CDailyRechargeManager();
            this.addBean( m_pManager );
        }

        m_pViewHandler = m_pViewHandler || this.getHandler( CDailyRechargeViewHandler ) as CDailyRechargeViewHandler;
        m_pViewHandler.closeHandler = new Handler( _onViewClosed );
        _playerSystem.addEventListener(CPlayerEvent.PLAYER_SYSTEM,_onPlayerDataUpdate);
        return m_bInitialized;
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }
    private function _onViewOpend() : void
    {
        this.onActivated(true);
    }
    override protected function onBundleStart(pCtx : ISystemBundleContext) : void
    {
        _autoOpenHandler();
    }
    private function _autoOpenHandler():void
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(!instanceSystem.isMainCity) return;
        //用<角色id+系统id+日期>当key去缓存中去状态,如果取不到则为当天第一次登录
        var selfRoleId:Number = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.ID;
        var dateStr : String = CTime.formatYMDStr(CTime.getCurrServerTimestamp());
        var key : String = selfRoleId  + bundleID + dateStr;
        var bool : Boolean = CSharedObject.readFromSharedObject(key);
        if(bool) return;
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if(pSystemBundleContext && !(stage.getSystem(CTutorSystem) as CTutorSystem).isPlaying)
        {
            _onViewOpend();
        }
        else
        {
            instanceSystem.callWhenInMainCity(_onViewOpend, null, null, null, 1);
        }
    }
    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CDailyRechargeViewHandler = this.getHandler( CDailyRechargeViewHandler ) as CDailyRechargeViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }
        if ( value )
        {
            pView.addDisplay();
            //用<角色id+系统id+日期>当key去缓存中去状态,如果取不到则为当天第一次登录
            var selfRoleId:Number = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.ID;
            var dateStr : String = CTime.formatYMDStr(CTime.getCurrServerTimestamp());
            var key : String = selfRoleId  + bundleID + dateStr;
            var bool : Boolean = CSharedObject.readFromSharedObject(key);
            if(!bool)  CSharedObject.writeToSharedObject(key,true);
        }
        else
        {
            pView.removeDisplay();
        }
    }
    public function setActivity(isActivity : Boolean) : void
    {
        this.setActivated(isActivity);
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.DAILY_RECHARGE );
    }

    override public function dispose() : void
    {
        super.dispose();
    }
    public function updateRedPoint(bool : Boolean) : void
    {
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( bundleID);
        if ( pSystemBundleContext && pSystemBundle)
        {
            pSystemBundleContext.setUserData(this, CBundleSystem.NOTIFICATION, bool);
        }
    }
    private function _onPlayerDataUpdate(e: CPlayerEvent = null):void
    {
        //开服时间不一致，说明跨天了
        if(m_pManager.m_nSeverDays != _playerSystem.playerData.systemData.openSeverDays)
        {
            m_pManager.startSystemBundle();
        }
    }

    private function get _playerSystem() : CPlayerSystem
    {
        return stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
}
}
