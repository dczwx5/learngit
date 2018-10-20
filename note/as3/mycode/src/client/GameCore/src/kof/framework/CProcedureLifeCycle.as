//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Application.Component.CContainerLifeCycle;
import QFLib.Application.Component.ILifeCycle;
import QFLib.Foundation.CProcedureManager;

import flash.utils.getQualifiedClassName;

import kof.util.CAssertUtils;

[Event(name="startCompleted", type="flash.events.Event")]
/**
 * LifeCycle which implement start/stop with CProcedureManager.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CProcedureLifeCycle extends CContainerLifeCycle {

    private var m_pProcedureManager : CProcedureManager;
    private var m_bTransition : Boolean;

    public function CProcedureLifeCycle( theProcedureManager : CProcedureManager = null ) {
        super();
        this.m_pProcedureManager = theProcedureManager;
        // LOG.setStdOutFunction( _stdOut );
    }

    override public function dispose() : void {
        super.dispose();

        if (m_pProcedureManager) {
            m_pProcedureManager.dispose();
        }
        m_pProcedureManager = null;
    }

    protected virtual function isProcedureFinished() : Boolean {
        var iter : Object = this.beanIterator;

        for each ( var o : Object in iter ) {
            if ( o && o.managed != UNMANAGED && o.object is ILifeCycle ) {
                if ( !ILifeCycle( o.object ).isStarted && !ILifeCycle( o.object ).isFailed )
                    return false;
            }
        }

        LOG.logTraceMsg( getQualifiedClassName( this ) + "::isProcedureFinished => true " );

        return true;
    }

    [Inline]
    final public function get procedureManager() : CProcedureManager {
        return m_pProcedureManager;
    }

    [Inline]
    final public function set procedureManager( value : CProcedureManager ) : void {
        m_pProcedureManager = value;
    }

    override public function start() : void {
        if ( isRunning )
            return;

        CAssertUtils.assertNotNull( this.procedureManager );

        this.procedureManager.addSequential( kof_framework::_doStartProcedure, getQualifiedClassName( this ) + " => _doStartProcedure ( doStart )" );
        m_bTransition = true;
    }

    // Call when in async starting.
    final protected function makeStarted() : void {
        m_bTransition = false;
    }

    [Inline]
    final kof_framework function _doStartProcedure( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        this.setStarting();
        m_bTransition = !this.doStart();

        theProcedureTags.isProcedureFinished = kof_framework::_handleProcedureStatus;

        this.afterStarting();

        return true;
    }

    [Inline]
    final kof_framework function _handleProcedureStatus() : Boolean {
        if ( this.isProcedureFinished() && !m_bTransition ) {
            this.procedureManager.addSequential( kof_framework::_setStartProcedure, getQualifiedClassName( this ) + "=> _setStartProcedure ( setStarted )" );
            return true;
        }
        return false;
    }

    [Inline]
    final kof_framework function _setStartProcedure( theProcedureTags : Object ) : Boolean {
        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
            return false;

        this.setStarted();

        return true;
    }

//    override public function stop() : void {
//        if ( this.isStopped || this.isStopping )
//            return;
//
//        CAssertUtils.assertNotNull( this._stage );
//        CAssertUtils.assertNotNull( this._stage.procedureManager );
//
//        this._stage.procedureManager.addSequential( _doStopProcedure );
//        this._stage.procedureManager.addSequential( _setStopProcedure );
//    }
//
//    final private function _doStopProcedure( theProcedureTags : Object ) : Boolean {
//        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
//            return false;
//
//        this.setStopping();
//        this.doStop();
//
//        theProcedureTags.isProcedureFinished = this.isProcedureFinished;
//
//        return true;
//    }
//
//    final private function _setStopProcedure( theProcedureTags : Object ) : Boolean {
//        if ( theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false )
//            return false;
//
//        this.setStopped();
//
//        return true;
//    }


    private function _stdOut( bLogToFile : Boolean, bOutputDebugString : Boolean, prefix : String, s : String ) : void {
        if ( bOutputDebugString ) {
            var str : String = this.getLogExt( 0 ) || "";
            var iCount : int = depth;
            for (var i : int = 0; i < iCount; ++i) {
                str += "  ";
            }
            trace( prefix, str, s );
        }
    }

    protected virtual function getLogExt( iLogLevel : int ) : String {
        return null;
    }

}
}
