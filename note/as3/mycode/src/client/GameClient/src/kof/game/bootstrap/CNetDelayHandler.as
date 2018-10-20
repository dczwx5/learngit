//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/5.
 */
package kof.game.bootstrap {

import QFLib.Interface.IUpdatable;

import kof.framework.CAbstractHandler;
import kof.framework.INetworking;
import kof.game.player.CPlayerSystem;
import kof.message.CAbstractPackMessage;
import kof.message.Common.NetDelayResponse;

public class CNetDelayHandler extends CAbstractHandler implements IUpdatable {

    public static const NET_DELAY_GOOD : int = 0;
    public static const NET_DELAY_NORMAL : int = 125;
    public static const NET_DELAY_BAD : int = 251;

    private var m_iLastDelay : int;
    private var m_iCurrentDelay : int;
    private var m_iCurrentDelayLevel : int;
    private var m_iMinDelay : int;
    private var m_iMaxDelay : int;

    public function CNetDelayHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret && this.networking ) {
            this.networking.bind( NetDelayResponse ).toHandler( _onNetDelayResponse );
        }

        return ret;
    }

    private function _onNetDelayResponse( net : INetworking, msg : CAbstractPackMessage ) : void {

        var response : NetDelayResponse = msg as NetDelayResponse;

        var pPlayerSys : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        if ( pPlayerSys && pPlayerSys.playerData ) {
            if ( pPlayerSys.playerData.ID == response.roleID ) {
                m_iLastDelay = m_iCurrentDelay;
                m_iCurrentDelay = response.delayTime;
                if ( m_iMinDelay == 0 ) m_iMinDelay = m_iCurrentDelay;
                else m_iMinDelay = Math.min( m_iMinDelay, m_iCurrentDelay );
                m_iMaxDelay = Math.max( m_iMaxDelay, m_iCurrentDelay );
                if ( m_iCurrentDelay < NET_DELAY_NORMAL) {
                    m_iCurrentDelayLevel = NET_DELAY_GOOD;
                } else if ( m_iCurrentDelay < NET_DELAY_BAD ) {
                    m_iCurrentDelayLevel = NET_DELAY_NORMAL;
                } else {
                    m_iCurrentDelayLevel = NET_DELAY_BAD;
                }
            }
        }

        system.dispatchEvent( new CBootstrapEvent( CBootstrapEvent.NET_DELAY_RESPONSE, response ) );

//        trace( response.roleID ,'++++++++++++++++',response.delayTime)
    }

    public function update( delta : Number ) : void {

    }

    [Inline]
    final public function get networking() : INetworking {
        return system.stage.getSystem( INetworking ) as INetworking;
    }

    [Inline]
    final public function get lastDelay() : int {
        return m_iLastDelay;
    }

    [Inline]
    final public function get currentDelay() : int {
        return m_iCurrentDelay;
    }

    [Inline]
    final public function get minDelay() : int {
        return m_iMinDelay;
    }

    [Inline]
    final public function get maxDelay() : int {
        return m_iMaxDelay;
    }

    [Inline]
    final public function get currentDelayLevel() : int {
        return m_iCurrentDelayLevel;
    }

}
}
