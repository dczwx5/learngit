//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.utils.getQualifiedClassName;

import kof.util.CAssertUtils;

/**
 * Abstract declaration of Handler.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractHandler extends CProcedureLifeCycle {

    public function CAbstractHandler() {
        super();
    }

    private var _system : CAppSystem;

    public function get system() : CAppSystem {
        return _system;
    }

    kof_framework function set system( value : CAppSystem ) : void {
        this._system = value;
    }

    override virtual protected function getLogExt( iLogLevel : int ) : String {
        if ( system )
            return system.stage.timer.frameCounter.toString() + "  ";
        return null;
    }

    override public function start() : void {
        if ( isRunning )
            return;

        CAssertUtils.assertNotNull( this.procedureManager );

        this.setStarting();
        this.procedureManager.addParallel( kof_framework::_doStartProcedure, getQualifiedClassName( this ) + " => _doStartProcedure ( doStart )" );
    }

    override protected function setStarted() : void {
        super.setStarted();

        if ( _system && _system.isStarted ) {
            kof_framework::onSystemEnter( _system );
        }
    }

    override protected function doStart() : Boolean {
        var ret : Boolean = super.doStart();
        ret = ret && this.onSetup();
        return ret;
    }

    override protected function doStop() : Boolean {
        var ret : Boolean = super.doStop();
        ret = ret && this.onShutdown();
        return ret;
    }

    protected virtual function onSetup() : Boolean {
        // NOOP.
        return true;
    }

    protected virtual function onShutdown() : Boolean {
        // NOOP.
        return true;
    }

    kof_framework function onStageEnter( stage : CAppStage ) : void {
        enterStage( stage );
    }

    kof_framework function onStageExit( stage : CAppStage ) : void {
        exitStage( stage );
    }

    protected virtual function enterStage( stage : CAppStage ) : void {
        // NOOP.
    }

    protected virtual function exitStage( stage : CAppStage ) : void {
        // NOOP.
    }

    kof_framework function onSystemEnter( system : CAppSystem ) : void {
        enterSystem( system );
    }

    kof_framework function onSystemExit( system : CAppSystem ) : void {
        exitSystem( system );
    }

    protected virtual function enterSystem( system : CAppSystem ) : void {
        // NOOP.
    }

    protected virtual function exitSystem( system : CAppSystem ) : void {
        // NOOP.
    }

}
}
