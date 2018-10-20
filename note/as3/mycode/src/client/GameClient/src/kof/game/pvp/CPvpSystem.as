//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/19.
 */
package kof.game.pvp {

import flash.utils.getTimer;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CDelayCall;
import kof.game.common.view.CViewBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.event.CInstanceEvent;

import morn.core.handlers.Handler;

public class CPvpSystem extends CBundleSystem implements ISystemBundle {

    private var _pvpViewHandler:CPvpViewHandler;

    public var _pvpListViewHandler:CPvpListViewHandler;

    public var _pvpHandler:CPvpHandler;

    public var _pvpManager:CPvpManager;

    private var m_bInitialized : Boolean;


    public function CPvpSystem() {
        super();
    }

//    override protected virtual function onSetup() : Boolean {
//        var ret : Boolean = super.onSetup();
//        ret = ret && addBean( _pvpViewHandler = new CPvpViewHandler() );
//        ret = ret && addBean( _pvpListViewHandler = new CPvpListViewHandler() );
//        ret = ret && addBean( _pvpHandler = new CPvpHandler() );
//        ret = ret && addBean( _pvpManager = new CPvpManager() );
//        ret = ret && this.initialize();
//        return ret;
//    }

    public override function dispose() : void {
        super.dispose();
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.END_INSTANCE, _onInstanceOverEventProcess);
        }

        _pvpListViewHandler.dispose();
        _pvpViewHandler.dispose();
        _pvpHandler.dispose();
        _pvpManager.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CPvpViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CPvpViewHandler();
            _pvpViewHandler = pView;
            this.addBean( pView );
        }

        pView = pView || this.getHandler( CPvpViewHandler ) as CPvpViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        addBean( _pvpListViewHandler = new CPvpListViewHandler() );
        addBean( _pvpHandler = new CPvpHandler() );
        addBean( _pvpManager = new CPvpManager() );

        return m_bInitialized;
    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
        }
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CPvpViewHandler = this.getHandler( CPvpViewHandler ) as CPvpViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CPvpViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    override protected function onBundleStart(ctx:ISystemBundleContext) : void {
        super.onBundleStart(ctx);

        // 目前爬塔没有其他结算, 先用overInstance的事件, 后面换成爬塔的结算协议
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.addEventListener(CInstanceEvent.END_INSTANCE, _onInstanceOverEventProcess);
        }
    }
    private function _onInstanceOverEventProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var isPvp:Boolean = EInstanceType.TYPE_PVP == (pInstanceSystem.instanceType);
        if (!isPvp) return ;

        pInstanceSystem.startWaitAllGameObjectFinish();
        pInstanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
    }

    private function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);

        var uiHandler:CInstanceUIHandler = pInstanceSystem.getBean(CInstanceUIHandler) as CInstanceUIHandler;
        if (null == uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_RESULT_WIN)) {
            uiHandler.showResultWinView();
        }
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.PVP );
    }

}
}
