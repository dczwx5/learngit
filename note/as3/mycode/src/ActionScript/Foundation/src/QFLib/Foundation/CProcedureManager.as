//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/1
//----------------------------------------------------------------------------------------------------------------------

/*
    this class can be used to arrange the tasks / functions to be executed in asynchronous and sequential/parallel order
    ex:
        procedureManager.addSequential( TestURLFile, "../FoundationTestBed.iml" );
        procedureManager.addParallel(  TestURLJson, "../table/actionSet.json" );
            TestURLFile() and TestURLJson() should have "theProcedureTags : Object" as the first parameter

        There're several default parameters in the Object - "theProcedureTags":
            theProcedureTags.arguments:             get arguments that users pass to this function.
            theProcedureTags.result:                get the returned object of the function.
            theProcedureTags.timer:                 get procedureManager's timer status.
            theProcedureTags.deltaTimer:            get deltaTime of an update.
            theProcedureTags.lastProcedureTag:      get the previous procedure's procedure tag.
            theProcedureTags.lastProcedureTags:     get the vector of previous procedures' procedure tag.

            theProcedureTags.isProcedureFinished:   provide a function returning whether the current running function is finished,
                                                    if some tasks/functions can not finish in one frame, then user need to provide
                                                    this.

    function examples:
        public function TestPath( theProcedureTags : Object ) : Boolean
        {
            if( theProcedureTags.lastProcedureTag.result == false ) return false;

            ... balababa ...

            return true;
        }

        public function ResourceLoaderTest( theProcedureTags : Object ) : Boolean
        {
            if( theProcedureTags.lastProcedureTag.result == false ) return false;

            bool bFinished = 0;

            ... balabalabala ... and somehow set bFinished = true;

            theProcedureTags.isProcedureFinished = function() : Boolean { return bFinished; }
            return true;
        }

*/

package QFLib.Foundation
{

import QFLib.Foundation;
import QFLib.Memory.CSmartObject;

import flash.events.TimerEvent;
import flash.utils.Timer;

//
    //
    //
    public class CProcedureManager extends CSmartObject
    {
        public function CProcedureManager( fFPS : Number /* set fFPS to non-zero if you want CProcedureManager call Update() itself */ )
        {
            m_fFPS = fFPS;
        }
        
        public override function dispose() : void
        {
            super.dispose();

            this._stopTimer();
            m_theEventTimer = null;

            clearAll();

            m_vectProcedureInfos = null;
        }
        
        [Inline]
        public function addSequential( fn : Function, ...args ) : void
        {
            addSequentialProcedure( fn, args );
        }

        public function addSequentialProcedure( fn : Function, args : Array ) : void
        {
            Foundation.Log.logTraceMsg( "addSequential...[" + args.join() + "]" );
            m_vectProcedureInfos.push( new _CProcedureInfos( fn, args ) );
            this._startTimer();
        }

        [Inline]
        public function addParallel( fn : Function, ...args ) : void
        {
            addParallelProcedure( fn, args );
        }

        public function addParallelProcedure( fn : Function, args : Array ) : void
        {
            Foundation.Log.logTraceMsg( "addParallel...[" + args.join() + "]" );
            if ( m_vectProcedureInfos.length == 0 )
            {
                m_vectProcedureInfos.push( new _CProcedureInfos( fn, args ) );
            }
            else m_vectProcedureInfos[ m_vectProcedureInfos.length - 1 ].push( fn, args );

            this._startTimer();
        }

        [Inline]
        final public function get numSequentialProceduresInQueue() : int
        {
            return m_vectProcedureInfos.length;
        }
        [Inline]
        final public function get numSequentialProcedures() : int
        {
            if( m_theCurrentProcedureInfos != null ) return this.numSequentialProceduresInQueue + 1;
            else return m_vectProcedureInfos.length;
        }

        public function clearAll() : void
        {
            var info : _CProcedureInfo;
            if( m_theCurrentProcedureInfos != null )
            {
                for each( info in m_theCurrentProcedureInfos.m_vectProcedureInfos ) info.dispose();
                m_theCurrentProcedureInfos.m_vectProcedureInfos.length = 0;
                m_theCurrentProcedureInfos = null;
            }
            if( m_theLastProcedureInfos != null )
            {
                for each( info in m_theLastProcedureInfos.m_vectProcedureInfos ) info.dispose();
                m_theLastProcedureInfos.m_vectProcedureInfos.length = 0;
                m_theLastProcedureInfos = null;
            }

            //
            if( m_vectProcedureInfos != null )
            {
                for each( var infos : _CProcedureInfos in m_vectProcedureInfos )
                {
                    for each( info in infos.m_vectProcedureInfos ) info.dispose();
                    infos.m_vectProcedureInfos.length = 0;
                }
                m_vectProcedureInfos.length = 0;
            }
        }

        public function update( fDeltaTime : Number ) : void
        {
            var info : _CProcedureInfo;

            if( m_theCurrentProcedureInfos )
            {
                var iNumUnfinishedProcedures : int = 0;
                for each( info in m_theCurrentProcedureInfos.m_vectProcedureInfos )
                {
                    if( info.m_theProcedureTags != null )
                    {
                        if( info.m_theProcedureTags.run != null )
                        {
                            info.m_theProcedureTags.deltaTimer = fDeltaTime;
                            if( info.m_theProcedureTags.run( fDeltaTime ) == false ) iNumUnfinishedProcedures++;
                            else info.m_theProcedureTags.run = null; // run == null also mean finished
                        }
                        else if( info.m_theProcedureTags.isProcedureFinished != null )
                        {
                            info.m_theProcedureTags.deltaTimer = fDeltaTime;
                            if( info.m_theProcedureTags.isProcedureFinished() == false ) iNumUnfinishedProcedures++;
                            else info.m_theProcedureTags.isProcedureFinished = null; // IsProcedureFinished == null also mean finished
                        }
                    }
                }
                if( iNumUnfinishedProcedures > 0 ) return ;
            }

            m_theLastProcedureInfos = m_theCurrentProcedureInfos;
            m_theCurrentProcedureInfos = m_vectProcedureInfos.shift();
            if( m_theCurrentProcedureInfos == null ) return ;

            for each( info in m_theCurrentProcedureInfos.m_vectProcedureInfos )
            {
                if( info.m_fnProcedure != null )
                {
                    info.m_theProcedureTags.timer = m_theEventTimer;
                    info.m_theProcedureTags.deltaTimer = fDeltaTime;
                    info.m_theProcedureTags.lastProcedureTag = _getLastProcedureTag;
                    info.m_theProcedureTags.lastProcedureTags = _getLastProcedureTags;
                    info.m_theProcedureTags.result = _procedureCall( info.m_fnProcedure, info.m_theProcedureTags );
                }
            }
        }

        //
        protected virtual function _procedureCall( fnProcedure : Function, theProcedureTags : Object ) : Object
        {
            return fnProcedure( theProcedureTags );
        }

        //
        private function _onTimer( e:TimerEvent ) : void
        {
            var fDeltaTime : Number = m_theTimer.seconds();
            m_theTimer.reset();

            update( fDeltaTime );
            
            if (m_theCurrentProcedureInfos == null)
                this._stopTimer();
        }

        private function _startTimer() : void
        {
            if (!m_theEventTimer && m_fFPS > 0.0)
                m_theEventTimer = new Timer( Number(1000.0 / m_fFPS) );

            if (m_theEventTimer && !m_theEventTimer.running) {
                m_theEventTimer.addEventListener( TimerEvent.TIMER, _onTimer );
                m_theEventTimer.start();

                m_theTimer = new CTimer();
            }
        }

        private function _stopTimer() : void
        {
            if (m_theEventTimer) {
                m_theEventTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
                m_theEventTimer.stop();

                m_theTimer = null;
            }
        }

        private function get _getLastProcedureTags() : Vector.<Object>
        {
            if( m_theLastProcedureInfos == null ) return null;

            var vProcedureTags : Vector.<Object> = new Vector.<Object>;
            for each( var info : _CProcedureInfo in m_theLastProcedureInfos.m_vectProcedureInfos )
            {
                vProcedureTags.push( info.m_theProcedureTags );
            }
            return vProcedureTags;
        }
        private function get _getLastProcedureTag() : Object
        {
            if( m_theLastProcedureInfos == null ) return null;
            return m_theLastProcedureInfos.m_vectProcedureInfos[ 0 ].m_theProcedureTags;
        }

        //
        //
        protected var m_vectProcedureInfos : Vector.<_CProcedureInfos> = new Vector.<_CProcedureInfos>;
        protected var m_theCurrentProcedureInfos: _CProcedureInfos = null;
        protected var m_theLastProcedureInfos: _CProcedureInfos = null;

        private var m_theEventTimer: Timer = null;
        private var m_theTimer: CTimer = null;
        private var m_fFPS : Number;
    }

}

class _CProcedureInfos
{
    public function _CProcedureInfos( fnProcedure : Function, args : Array )
    {
        push( fnProcedure, args );
    }

    public function push( fnProcedure : Function, args : Array ) : void
    {
        var procedureInfo : _CProcedureInfo = new _CProcedureInfo( fnProcedure, args );
        m_vectProcedureInfos.push( procedureInfo );
    }

    internal var m_vectProcedureInfos : Vector.<_CProcedureInfo> = new Vector.<_CProcedureInfo>;
}

class _CProcedureInfo
{
    public function _CProcedureInfo( fnProcedure : Function, args : Array )
    {
        m_fnProcedure = fnProcedure;
        m_theProcedureTags.arguments = args;
    }

    public function dispose() : void
    {
        m_fnProcedure = null;
        m_theProcedureTags.arguments = null;
    }

    internal var m_fnProcedure : Function = null;
    internal var m_theProcedureTags : Object = {};
}

