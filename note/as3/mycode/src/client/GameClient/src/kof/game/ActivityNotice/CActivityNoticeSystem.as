//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/3/30.
 */
package kof.game.ActivityNotice {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.ActivityNotice.event.CActivityNoticeEvent;
import kof.game.ActivityNotice.view.CActivityForceNoticeViewHandler;
import kof.game.ActivityNotice.view.CActivityNoticeViewHandler;
import kof.game.ActivityNotice.view.CActivityTimerHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;

import morn.core.handlers.Handler;

public class CActivityNoticeSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CActivityScheduleViewHandler;
//    private var m_pManager:C7KHallManager;
//    private var m_pNetHandler:C7KHallNetHandler;
    private var m_pHelpHandler:CActivityNoticeHelpHandler;
    private var m_pTimerHandler:CActivityTimerHandler;

    public function CActivityNoticeSystem() {
        super();
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

            m_pMainViewHandler = new CActivityScheduleViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

//            m_pNetHandler = new C7KHallNetHandler();
//            this.addBean( m_pNetHandler );
//
//            m_pManager = new C7KHallManager();
//            this.addBean( m_pManager );
//
            m_pHelpHandler = new CActivityNoticeHelpHandler();
            this.addBean( m_pHelpHandler );

            this.addBean( new CActivityNoticeViewHandler() );
            this.addBean( new CActivityForceNoticeViewHandler() );

            m_pTimerHandler = new CActivityTimerHandler();
            this.addBean(m_pTimerHandler);
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.ACTIVITY_NOTICE);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
//            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, m_pHelpHandler.hasRewardToTake());
        }

//        (this.getHandler(CActivityNoticeViewHandler) as CActivityNoticeViewHandler).addDisplay();

        m_pTimerHandler.initialize();

        _addEventListeners();
    }

    protected function _addEventListeners() : void
    {
        this.addEventListener(CActivityNoticeEvent.ActivityCrossDay, _onCrossDayHandler);
        this.stage.flashStage.addEventListener("LoginSucc", _onLoginSuccHandler);
    }

    protected function _removeEventListeners() : void
    {
        this.removeEventListener(CActivityNoticeEvent.ActivityCrossDay, _onCrossDayHandler);
        this.stage.flashStage.removeEventListener("LoginSucc", _onLoginSuccHandler);
    }

    private function _onLoginSuccHandler(e:Event):void
    {
        (this.getHandler(CActivityNoticeViewHandler) as CActivityNoticeViewHandler).addDisplay();
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CActivityScheduleViewHandler = this.getHandler( CActivityScheduleViewHandler ) as CActivityScheduleViewHandler;
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

    // 跨天
    private function _onCrossDayHandler(e:CActivityNoticeEvent):void
    {
        (this.getHandler(CActivityNoticeViewHandler) as CActivityNoticeViewHandler).addDisplay();
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

}
}
