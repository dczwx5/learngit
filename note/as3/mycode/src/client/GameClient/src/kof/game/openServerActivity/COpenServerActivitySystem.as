//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/10/19.
 */
package kof.game.openServerActivity {

import kof.framework.events.CEventPriority;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.limitActivity.*;


import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.limitActivity.enum.ELimitActivityState;
import kof.game.limitActivity.view.CLimitActivityRewardViewHandler;
import kof.game.limitActivity.view.CLimitScoreRewardTipsViewHandler;
import kof.game.openServerActivity.COpenServerActivityManager;
import kof.game.openServerActivity.data.COpenServerTargetData;
import kof.game.openServerActivity.view.COpenServerRewardTipsViewHandler;
import kof.message.Activity.ActivityChangeResponse;
import kof.table.CarnivalEntryConfig;
import kof.table.CarnivalTargetConfig;

import morn.core.handlers.Handler;

/**
 * 开服嘉年华活动（开服七天）
 */
public class COpenServerActivitySystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;

    private var _openServerManager : COpenServerActivityManager;
    private var _openServerHandler : COpenServerActivityHandler;
    private var _openServerViewHandler : COpenServerActivityViewHandler;
    private var _openServerRewardTipsViewHandler : COpenServerRewardTipsViewHandler;

    public function COpenServerActivitySystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _openServerManager = new COpenServerActivityManager() );
            this.addBean( _openServerHandler = new COpenServerActivityHandler() );
            this.addBean( _openServerViewHandler = new COpenServerActivityViewHandler() );
            this.addBean( _openServerRewardTipsViewHandler = new COpenServerRewardTipsViewHandler() );
        }

        var openServerView : COpenServerActivityViewHandler = this.getBean( COpenServerActivityViewHandler );
        openServerView.closeHandler = new Handler( onViewClosed );

        this._addEventListener();
        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.CARNIVAL_ACTIVITY );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : COpenServerActivityViewHandler = this.getHandler( COpenServerActivityViewHandler ) as COpenServerActivityViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the COpenServerActivityViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    public function closeOpenActivity() : void {
        this.ctx.stopBundle(this);
    }

    private function _addEventListener() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
        }
    }

    private function _removeEventListener() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.removeEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler );
        }
    }
    private var _isCarnivalActivityStart : Boolean;
    private function _onSystemBundleStateChangedHandler( event : CSystemBundleEvent ) : void {
        if( _isCarnivalActivityStart )
                return;
        var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.CARNIVAL_ACTIVITY ) ) );
        if( iStateValue == CSystemBundleContext.STATE_STARTED ){
            _isCarnivalActivityStart = true;
            _openServerHandler._onActivityDataRequest();
        }
    }

    public function onViewClosed() : void {
        this.setActivated( false );
    }

    // id : 活动id, index : 第几个奖励
    public function isTargetCanGetReward(id:int, index:int) : Boolean {
        var openServerManager:COpenServerActivityManager = getBean( COpenServerActivityManager ) as COpenServerActivityManager;
        var entryConfig:CarnivalTargetConfig = getCarnivalTargetConfig(id, index);
        if (entryConfig) {
            var ret:Boolean = openServerManager.isCanTargetReward(entryConfig.ID);
            return ret;
        }
        return false;
    }
    public function isTargetHasGetReward(id:int, index:int) : Boolean {
        var openServerManager:COpenServerActivityManager = getBean( COpenServerActivityManager ) as COpenServerActivityManager;
        var entryConfig:CarnivalTargetConfig = getCarnivalTargetConfig(id, index);
        if (entryConfig) {
            var ret:Boolean = openServerManager.isGetTargetReward(entryConfig.ID);
            return ret;
        }
        return true;

    }
    public function getCarnivalTargetConfig(id:int, index:int) : CarnivalTargetConfig {
        var openServerManager:COpenServerActivityManager = getBean( COpenServerActivityManager ) as COpenServerActivityManager;
        var config:CarnivalEntryConfig = openServerManager.getActivityLabelById(id);
        if(config){
            var targets:Array = openServerManager.getActivityTargetsConfig(config.targetIds);
            if (!targets || index >= targets.length) return null;
            var entryConfig:CarnivalTargetConfig = targets[index] as CarnivalTargetConfig;
            return entryConfig;
        }
        return null;
    }
}
}
