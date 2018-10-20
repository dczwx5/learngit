//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.display.Stage;

import kof.net.CNetworkSystem;

/**
 * An application implementation with delegating networking interface.
 */
public class CDelegateNetworkApp extends CNetworkApp {

    private var m_pNetworkingSystemCreator : Function;
    private var m_pRunningStageBuilder : Function;

    public function CDelegateNetworkApp( stage : Stage ) {
        super( stage );
    }

    public function get networkSystemCreator() : Function {
        return m_pNetworkingSystemCreator;
    }

    public function set networkSystemCreator( value : Function ) : void {
        m_pNetworkingSystemCreator = value;
    }

    public function get runningStageBuilder() : Function {
        return m_pRunningStageBuilder;
    }

    public function set runningStageBuilder( value : Function ) : void {
        m_pRunningStageBuilder = value;
    }

    override protected function createNetworkSystem() : CNetworkSystem {
        if ( null == networkSystemCreator ) {
            return super.createNetworkSystem();
        } else {
            return networkSystemCreator();
        }
    }

    override protected function buildRunningStage( runningStage : CAppStage ) : void {
        super.buildRunningStage( runningStage );

        if ( null != runningStageBuilder ) {
            runningStageBuilder( runningStage );
        }
    }

}
}
