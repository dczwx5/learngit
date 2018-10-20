//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.support {

import flash.events.Event;

import kof.framework.CAbstractHandler;
import kof.framework.CStandaloneApp;
import kof.framework.IApplication;
import kof.framework.INetworking;
import kof.framework.events.CEventPriority;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.game.reciprocation.CReciprocalSystem;
import kof.message.CAbstractPackMessage;
import kof.message.Common.ReloadResourcesResponse;

/**
 * 静态资源刷新控制
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CStaticReloadHandler extends CAbstractHandler {

    /** @private */
    private var m_pLazyCall : Function;

    public function CStaticReloadHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            var pInstanceSys : IInstanceFacade = system.stage.getSystem(
                            IInstanceFacade ) as IInstanceFacade;
            if ( pInstanceSys ) {
                pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.ENTER_INSTANCE,
                        _instanceSys_onEnterEventHandler, false, CEventPriority.DEFAULT, true );
            }

            networking.bind( ReloadResourcesResponse ).toHandler( _onReloadMessageHandler );
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        if ( ret ) {

        }

        return ret;
    }

    final public function get networking() : INetworking {
        return system.stage.getSystem( INetworking ) as INetworking;
    }

    private function _instanceSys_onEnterEventHandler( event : Event ) : void {
        var pInstanceSys : IInstanceFacade = system.stage.getSystem(
                        IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            if ( pInstanceSys.isMainCity && null != m_pLazyCall ) {
                m_pLazyCall();
            }
            // testing.
//            else if ( pInstanceSys.isMainCity ) {
//                var msg : ReloadResourcesResponse = new ReloadResourcesResponse();
//                msg.version = "1.0.44380.0";
//                _onReloadMessageHandler( networking, msg );
//            }
        }
    }

    private function _onReloadMessageHandler( net : INetworking, absMsg : CAbstractPackMessage ) : void {
        void(net);

        var msg : ReloadResourcesResponse = absMsg as ReloadResourcesResponse;
        if ( !msg )
            return;

        var sTheirBuildVersion : String = msg.version;
        var sMyBuildVersion : String = system.stage.configuration.getString( "build_version", sTheirBuildVersion );

        if ( sTheirBuildVersion == sMyBuildVersion ) {
            // nothing to do.
        } else {
            // need to reload static, just refresh the page
            showRefreshIfPossible();
        }
    }

    protected function showRefreshIfPossible() : void {
        var pInstanceSys : IInstanceFacade = system.stage.getSystem(
                        IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            if ( pInstanceSys.isMainCity ) {
                showMessageBox();
            } else {
                m_pLazyCall = showMessageBox;
            }
        }
    }

    protected function showMessageBox() : void {
        var pRS : CReciprocalSystem = system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem;
        if ( pRS ) {
            pRS.showMsgBox(
                    "检测到版本更新，为保证数据一致避免造成损失，请重新进入游戏！",
                    _onRefresh,
                    null,
                    false,
                    "重新登录",
                    null
            );
        }
    }

    private function _onRefresh() : void {
        var pApp : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( pApp && pApp.eventDispatcher ) {
            pApp.eventDispatcher.dispatchEvent( new Event( CStandaloneApp.RESTART ) );
        }
    }

}
}

// vi:ft=as3 sw=4 ts=4 expandtab tw=120

