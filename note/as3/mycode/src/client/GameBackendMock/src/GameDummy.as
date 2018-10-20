//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

import QFLib.Foundation;

import flash.display.Sprite;

import kof.dummy.CDummyNetworkSystem;
import kof.dummy.CDummyServer;
import kof.framework.CAppStage;
import kof.framework.CDelegateNetworkApp;
import kof.framework.IApplication;
import kof.net.CNetworkSystem;

/**
 * 模拟单机运行时启动类
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class GameDummy extends Sprite {

    /** @private */
    private var m_pDummyServer : CDummyServer;

    /** Creates a new GameDummy. */
    public function GameDummy() {
        super();
    }

    protected function createNetworkSystem() : CNetworkSystem {
        return new CDummyNetworkSystem();
    }

    public function start( app : IApplication ) : void {
        Foundation.Log.logMsg( "Start the game dummy module ..." );
        if ( app is CDelegateNetworkApp ) {
            var pDelegateApp : CDelegateNetworkApp = app as CDelegateNetworkApp;
            if ( pDelegateApp ) {
                pDelegateApp.networkSystemCreator = createNetworkSystem;
                pDelegateApp.runningStageBuilder = buildRunningStage;
            }
        }
    }

    protected function buildRunningStage( pRunningStage : CAppStage ) : void {
        pRunningStage.addSystem( ( m_pDummyServer = m_pDummyServer || new CDummyServer() ) );
    }

}
}
