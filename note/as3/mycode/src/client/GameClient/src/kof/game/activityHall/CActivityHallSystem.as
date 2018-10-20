//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/7/31.
 */
package kof.game.activityHall {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;

import morn.core.handlers.Handler;

public class CActivityHallSystem extends CBundleSystem {

    private var m_pActivityHallDataManager : CActivityHallDataManager;
    private var m_pActivityHallViewHandler : CActivityHallViewHandler;
    private var m_pActivityHallHandler : CActivityHallHandler;

    private var m_bInitialized : Boolean;

    public function CActivityHallSystem() {
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            m_pActivityHallDataManager = new CActivityHallDataManager();
            this.addBean( m_pActivityHallDataManager );

            m_pActivityHallViewHandler = new CActivityHallViewHandler();
            m_pActivityHallViewHandler.closeHandler = new Handler( onViewClosed );
            this.addBean( m_pActivityHallViewHandler );

            m_pActivityHallHandler = new CActivityHallHandler();
            this.addBean( m_pActivityHallHandler );
        }

        return m_bInitialized;
    }

    override public function dispose() : void {
        super.dispose();

        m_pActivityHallDataManager.dispose();
        m_pActivityHallViewHandler.dispose();
        m_pActivityHallHandler.dispose();

        _removeEventListeners();
    }

    protected function _removeEventListeners() : void {
        removeEventListener( CActivityHallEvent.ActivityHallActivityStateChanged, _updateRedPoint );
//        removeEventListener( CActivityHallEvent.ConsumeActivityResponse, _updateRedPoint );
        removeEventListener( CActivityHallEvent.ReceiveConsumeActivityResponse, _updateRedPoint );
//        removeEventListener( CActivityHallEvent.TotalRechargeResponse, _updateRedPoint );
//        removeEventListener( CActivityHallEvent.TotalRechargeRewardResponse, _updateRedPoint );
        removeEventListener( CActivityHallEvent.ActiveTaskUpdateEvent, _updateRedPoint );
        removeEventListener( CActivityHallEvent.ActiveTaskRewardResponse, _updateRedPoint );
    }

    /**
     * 系统开启
     * **/
    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        super.onBundleStart( ctx );

        _addEventListener();
    }

    protected function _addEventListener() : void {
        addEventListener( CActivityHallEvent.ActivityHallActivityStateChanged, _updateRedPoint );
//        addEventListener( CActivityHallEvent.ConsumeActivityResponse, _updateRedPoint );
        addEventListener( CActivityHallEvent.ReceiveConsumeActivityResponse, _updateRedPoint );
//        addEventListener( CActivityHallEvent.TotalRechargeResponse, _updateRedPoint );
//        addEventListener( CActivityHallEvent.TotalRechargeRewardResponse, _updateRedPoint );
        addEventListener( CActivityHallEvent.ActiveTaskUpdateEvent, _updateRedPoint );
        addEventListener( CActivityHallEvent.ActiveTaskRewardResponse, _updateRedPoint );
        addEventListener( CActivityHallEvent.ACTIVITYPREVIEWDATA, _updateRedPoint );

        _updateRedPoint();
    }

    private function _updateRedPoint( e : Event = null ) : void {
//        var hasChargeReward : Boolean = m_pActivityHallDataManager.hasTotalChargeReward();
//        var hasConsumeReward : Boolean = m_pActivityHallDataManager.hasConsumeReward();
        var hasActiveTaskReward : Boolean = m_pActivityHallDataManager.hasActiveTaskReward();
        var isFirstOpenPreview : Boolean = m_pActivityHallDataManager.isFirstOpenPreview;
        m_pActivityHallViewHandler.updateRedPoint( false, false, hasActiveTaskReward,isFirstOpenPreview );
        // 主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( bundleID );
        if ( pSystemBundleContext && pSystemBundle ) {
            pSystemBundleContext.setUserData( this, CBundleSystem.NOTIFICATION, hasActiveTaskReward || isFirstOpenPreview);
        }
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.ACTIVITY_HALL );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CActivityHallViewHandler = this.getHandler( CActivityHallViewHandler ) as CActivityHallViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CSevenDaysViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    public function onViewClosed() : void {
        this.setActivated( false );
    }
}
}
