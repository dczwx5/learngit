//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.bootstrap {

import QFLib.Foundation.CTime;
import QFLib.Foundation.CTimeDog;
import QFLib.Foundation.free;
import QFLib.Interface.IUpdatable;

import flash.utils.getTimer;

import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.message.CAbstractPackMessage;
import kof.message.Common.PingPongRequest;
import kof.message.Common.PingPongResponse;
import kof.util.CAssertUtils;

/**
 * Ping-Pong request and response handler.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPingPongHandler extends CAbstractHandler implements IUpdatable {

    private var m_nID : int;
    private var m_pSendDog : CTimeDog;
    private var _requestAry : Array;
    private var _historyAry : Array;
    private var _timeObj :Object;
    private static const MAX_RECORD:uint = 200;

    public function CPingPongHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        free( m_pSendDog );
        m_pSendDog = null;
        _requestAry = null;
        _historyAry = null;
        _timeObj = null;
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret && this.networking ) {
            this.networking.bind( PingPongResponse ).toHandler( _onPingPongResponse );
        }

        if ( !m_pSendDog ) {
            m_pSendDog = new CTimeDog( _onSendCheckPoint, _onStopCheckPoint );
            m_pSendDog.start( 60.0 );
        }

        _requestAry = [];
        _historyAry = [];

        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            this.networking.unbind( PingPongResponse );
        }

        free( m_pSendDog );
        m_pSendDog = null;

        return ret;
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
    }

    public function get networking() : INetworking {
        return system.stage.getSystem( INetworking ) as INetworking;
    }

    protected function nextID() : int {
        return ++m_nID;
    }

    public function pingRequest() : void {
        var pMsg : PingPongRequest = this.networking.getMessage( PingPongRequest ) as PingPongRequest;
        CAssertUtils.assertNotNull( pMsg );

        pMsg.id = nextID();
        pMsg.time = getTimer();

        this.networking.send( pMsg );
    }

    private var _tempAry : Array;
    private var _tempTotalTime : int;
    private function _onPingPongResponse( net : INetworking, msg : CAbstractPackMessage ) : void {

//        _timeObj = _requestAry.shift();
//        _timeObj.responseTime = CTime.getCurrentTimestamp();
//        _historyAry.push( _timeObj );
//
//        if( _historyAry.length > 5 ){ //平均
//            _tempTotalTime = 0;
//            _tempAry = _historyAry.slice( _historyAry.length - 5 );
//            for each( _timeObj in _tempAry ){
//                _tempTotalTime += _timeObj.responseTime - _timeObj.requestTime;
//            }
//            system.dispatchEvent( new CBootstrapEvent( CBootstrapEvent.AVERAGE_PINGPONG_TIME_DELAY ,_tempTotalTime/5 ));
//        }
//        //单个
//        system.dispatchEvent( new CBootstrapEvent( CBootstrapEvent.SINGLE_PINGPONG_TIME_DELAY ,_timeObj.responseTime - _timeObj.requestTime ));
//
//        if ( _historyAry.length > MAX_RECORD + int( MAX_RECORD * 0.25 ) ) {
//            _historyAry = _historyAry.slice( _historyAry.length - MAX_RECORD );
//        }
    }

    private function _onSendCheckPoint() : void {

//        _timeObj = new Object();
//        _timeObj.requestTime = CTime.getCurrentTimestamp();
//        _requestAry.push( _timeObj );

        this.pingRequest();
    }

    private function _onStopCheckPoint() : void {
        if ( m_pSendDog ) {
            m_pSendDog.start();
        }
    }

    public function update( delta : Number ) : void {
        if ( m_pSendDog ) {
            m_pSendDog.update( delta );
        }
    }

    public function resetHeartBeat(value:Number):void
    {
        m_pSendDog.stop();
        m_pSendDog.start(value);
    }
}
}
