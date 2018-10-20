//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/8/4.
 */
package kof.game.fightui.compoment {

import kof.framework.CViewHandler;
import kof.game.bootstrap.CBootstrapEvent;
import kof.game.bootstrap.CBootstrapSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Common.NetDelayResponse;
import kof.ui.demo.FightUI;

import morn.core.components.Clip;

public class CPingPongViewHandler extends CViewHandler {

    private var _bViewInitialized : Boolean = false;

    private var _fightUI : FightUI = null;

    private static const LV_GOOD : int = 0;

    private static const LV_NORMAL : int = 125;

    private static const LV_BAD : int = 251;

    private var _selfClipSignal : Clip;

    private var _otherClipSignal : Clip;

    private var _initFlg : Boolean;

    public function CPingPongViewHandler( fightUI : FightUI ) {
        super();
        this._fightUI = fightUI;
    }

    public function setData( selfClipSignal : Clip , otherClipSignal : Clip ):void {
        hide();
        _selfClipSignal = selfClipSignal;
        _otherClipSignal = otherClipSignal;
        _initFlg = true;

//        _pBootstrapSystem.removeEventListener( CBootstrapEvent.SINGLE_PINGPONG_TIME_DELAY, _updateSignalView );
//        _pBootstrapSystem.addEventListener( CBootstrapEvent.SINGLE_PINGPONG_TIME_DELAY, _updateSignalView );


//        if( EInstanceType.isPeakGame( EInstanceType.TYPE_MAIN ) == false ){
//            _selfClipSignal.visible =
//                    _otherClipSignal.visible = false;
//            return;
//        }
        _selfClipSignal.visible =
                _otherClipSignal.visible = false;

        _pBootstrapSystem.removeEventListener( CBootstrapEvent.NET_DELAY_RESPONSE, _updateSignalView );
        _pBootstrapSystem.addEventListener( CBootstrapEvent.NET_DELAY_RESPONSE, _updateSignalView );

    }

    private function _updateSignalView( evt : CBootstrapEvent ):void{
        if( _initFlg ){
            _initFlg = false;
            _selfClipSignal.visible =
                    _otherClipSignal.visible = true;
            _selfClipSignal.index =
                    _otherClipSignal.index = 0;
        }
        var response:NetDelayResponse = evt.data as NetDelayResponse;
        if( _playerData.ID == response.roleID ){
            _updateClipSignal( _selfClipSignal , response.delayTime );
        }else{
            _updateClipSignal( _otherClipSignal , response.delayTime );
        }
    }
    private function _updateClipSignal( clipSignal : Clip ,delay : int ):void{
        if( clipSignal.visible == false )
            clipSignal.visible = true;

        if( delay >= LV_BAD ){
            clipSignal.index = 2;
        }else if( delay >= LV_NORMAL ){
            clipSignal.index = 1;
        }else{
            clipSignal.index = 0;
        }
        trace('----------',delay)
    }

    public function hide() : void {

    }
    private function get _pBootstrapSystem():CBootstrapSystem{
        return system.stage.getSystem( CBootstrapSystem ) as CBootstrapSystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
}
}
