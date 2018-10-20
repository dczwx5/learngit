 //------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity {


import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.limitActivity.view.CLimitActivityRewardViewHandler;
import kof.game.limitActivity.view.CLimitScoreRewardTipsViewHandler;

import morn.core.handlers.Handler;

/**
 * 消费积分榜活动
 */
public class CLimitActivitySystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;

    private var _limitManager : CLimitActivityManager;
    private var _limitHandler : CLimitActivityHandler;
    private var _limitViewHandler : CLimitActivityViewHandler;
    private var _limitRewardViewHandler : CLimitActivityRewardViewHandler;
    private var _limitRewardTipsViewHandler : CLimitScoreRewardTipsViewHandler;

    public function CLimitActivitySystem() {
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

            this.addBean( _limitManager = new CLimitActivityManager() );
            this.addBean( _limitHandler = new CLimitActivityHandler() );
            this.addBean( _limitViewHandler = new CLimitActivityViewHandler() );
            this.addBean( _limitRewardViewHandler = new CLimitActivityRewardViewHandler() );
            this.addBean( _limitRewardTipsViewHandler = new CLimitScoreRewardTipsViewHandler() );
        }

        var limitView : CLimitActivityViewHandler = this.getBean( CLimitActivityViewHandler );
        limitView.closeHandler = new Handler( onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.LIMIT_ACTIVITY );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CLimitActivityViewHandler = this.getHandler( CLimitActivityViewHandler ) as CLimitActivityViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CLimitActivityViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    public function closeLimitActivity() : void {
        this.ctx.stopBundle(this);
    }


    public function onViewClosed() : void {
        this.setActivated( false );
    }
}
}
