//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.effort.view.CEffortConsumeHandler;
import kof.game.effort.view.CEffortDetailsViewHandler;
import kof.game.effort.view.CEffortDevelopHandler;
import kof.game.effort.view.CEffortFightHandler;
import kof.game.effort.view.CEffortHallViewHandler;
import kof.game.effort.view.CEffortOverviewHandler;
import kof.game.effort.view.CEffortScenarioHandler;
import kof.game.effort.view.CEffortTotalRewardViewHandler;
import kof.game.effort.view.CEffortUIHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.CViewManagerHandler;
import kof.game.welfarehall.CWelfareHallEvent;
import kof.game.welfarehall.view.CWelfareHallViewHandler;

import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 成就系统
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortSystem extends CBundleSystem {


    public var m_aPanelViews:Array;


    private var m_bInitialized : Boolean;

    private var _m_pEffortHallHandler:CEffortHallHandler;
    private var _m_pEffortHallViewHander:CEffortHallViewHandler;
    private var _m_pEffortHallManager:CEffortHallManager;
    private var _m_pEffortDevelopHandler:CEffortDevelopHandler;
    private var _m_pEffortOverviewHandler:CEffortOverviewHandler;
    private var _m_pEffortFightHandler:CEffortFightHandler;
    private var _m_pEffortConsumeHandler:CEffortConsumeHandler;
    private var _m_pEffortScenarioHandler:CEffortScenarioHandler;

    private var _m_pEffortTotalRewardHandler:CEffortTotalRewardViewHandler;
    private var _m_pEffortDetailsViewHandler:CEffortDetailsViewHandler;

    private var _m_pEffortUIHandler:CEffortUIHandler;


    public function CEffortSystem() {
    }

    public override function dispose() : void {
        super.dispose();

        _m_pEffortHallHandler.dispose();
        _m_pEffortHallViewHander.dispose();
        _m_pEffortHallManager.dispose();
        _m_pEffortDevelopHandler.dispose();
        _m_pEffortOverviewHandler.dispose();
        _m_pEffortFightHandler.dispose();
        _m_pEffortConsumeHandler.dispose();
        _m_pEffortScenarioHandler.dispose();
        _m_pEffortTotalRewardHandler.dispose();
        _m_pEffortDetailsViewHandler.dispose();
        _m_pEffortUIHandler.dispose();


        _removeListeners();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean(_m_pEffortHallHandler = new CEffortHallHandler());
            this.addBean(_m_pEffortHallViewHander = new CEffortHallViewHandler());
            this.addBean(_m_pEffortHallManager = new CEffortHallManager());
            this.addBean(_m_pEffortOverviewHandler = new CEffortOverviewHandler());
            this.addBean(_m_pEffortScenarioHandler = new CEffortScenarioHandler());
            this.addBean(_m_pEffortDevelopHandler = new CEffortDevelopHandler());
            this.addBean(_m_pEffortFightHandler = new CEffortFightHandler());
            this.addBean(_m_pEffortConsumeHandler = new CEffortConsumeHandler());
            this.addBean(_m_pEffortDetailsViewHandler = new CEffortDetailsViewHandler());

            this.addBean(_m_pEffortTotalRewardHandler = new CEffortTotalRewardViewHandler());

            this.addBean(_m_pEffortUIHandler = new CEffortUIHandler());

            _m_pEffortHallHandler.m_pHallViewHandler = _m_pEffortHallViewHander;


            m_aPanelViews = [_m_pEffortOverviewHandler,
                             _m_pEffortScenarioHandler,
                             _m_pEffortDevelopHandler,
                             _m_pEffortFightHandler,
                             _m_pEffortConsumeHandler];
        }

        _m_pEffortHallViewHander.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CEffortHallViewHandler = this.getHandler( CEffortHallViewHandler ) as CEffortHallViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }


        if ( value ) {
            pView.addDisplay( 0 );
        } else {
            pView.removeDisplay();

        }
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        //获取福利信息
        //_pCWelfareHallHandler.foreverRechargeInfoRequest(1);

    }
    //小红点
    public function openMainfunction():void
    {
//        redTips();
//
//        _onAnnouncementListHandler();
//        _onAdvertisingHandler();
        _addListeners();
    }


    public function addTips(tipsClass:Class, item:Component, args:Array = null) : void
    {
        _m_pEffortUIHandler.addTips(tipsClass, item, args);
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }


    private function _onViewClosed() : void {
        this.setActivated( false );
        var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var systemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.BUY_MONTH_CARD));
        var vCurrent : Boolean = pSystemBundleCtx.getUserData( systemBundle, "activated", false );
        if(vCurrent){
            pSystemBundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, false);
        }
        systemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.BUY_WEEK_CARD));
        vCurrent = pSystemBundleCtx.getUserData( systemBundle, "activated", false );
        if(vCurrent){
            pSystemBundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, false);
        }
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.EFFORT );
    }
}
}
