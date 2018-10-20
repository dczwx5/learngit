//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.display.Stage;

import kof.net.CNetworkSystem;

/**
 * A Runtime application with networking supported.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNetworkApp extends CStandaloneApp {

    /**
     * Constructor
     *
     * @param stage A native flash stage.
     */
    public function CNetworkApp(stage:Stage) {
        super(stage);
    }

    /** @private */
    private var _network:CNetworkSystem;

    protected function get networkSystem():CNetworkSystem {
        return _network;
    }

    /** @private */
    protected function createNetworkSystem():CNetworkSystem {
        return new CNetworkSystem();
    }

    override protected function buildRunningStage(runningStage:CAppStage):void {
        super.buildRunningStage(runningStage);

        _network = _network || createNetworkSystem();
        runningStage.addSystem(_network);
    }

}
}
