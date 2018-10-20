//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/7/27.
//----------------------------------------------------------------------
package kof.game.character.fight.buff {

import kof.framework.INetworking;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.core.CGameComponent;
import kof.message.Pvp.AddBufferRequest;

public class CSelfBuffInitializer extends CGameComponent {
    public function CSelfBuffInitializer( pNetwork : INetworking ) {
        super( "selfBuffInitialize" );
        m_pNetwork = pNetwork;

    }

    override public function dispose() : void {
        super.dispose();
        if ( m_buffList )
            m_buffList.splice( 0, m_buffList.length );
        m_buffList = null;
    }

    override protected function onEnter() : void {
        m_nType = CCharacterDataDescriptor.getType( owner.data );
        m_nID = CCharacterDataDescriptor.getID( owner.data );
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.addEventListener( CCharacterEvent.SKILL_COMP_READY, _buildBuff );
    }

    override protected function onExit() : void {
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.removeEventListener( CCharacterEvent.SKILL_COMP_READY, _buildBuff );
        super.onExit();
        m_nType = 0;
        m_nID = 0;
        m_pNetwork = null;
    }

    private function _buildBuff( e : CCharacterEvent = null ) : void {
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.removeEventListener( CCharacterEvent.SKILL_COMP_READY, _buildBuff );

        m_boSkillReady = true;
        if ( !m_buffList || m_buffList.length == 0 )
            return;
        else {
            for ( var i : int = 0; i < m_buffList.length; i++ ) {
                _addBuffToSelf( m_buffList[ i ] );
            }
        }

        if ( m_buffList )
            m_buffList.splice( 0, m_buffList.length );
        m_buffList = null;
    }

    public function addBuffsToSelf( buffs : Array ) : void{
        if( !buffs || buffs.length == 0)
            return;
        var buffID : int;
        for( var buffIndex : int = 0 ; buffIndex < buffs.length ; buffIndex++ ){
            buffID = buffs[buffIndex];
            if( buffID == 0 )
                continue;

            _addBuffToSelf( buffID );
        }
    }

    private function _addBuffToSelf( buffID : int ) : void {
        var msg : AddBufferRequest = new AddBufferRequest();
        msg.type = m_nType;
        msg.srcId = m_nID;
        msg.emitBuffId = buffID;
        var targetInfo : Object = {};
        targetInfo.targetId = m_nID;
        targetInfo.type = m_nType;
        msg.hitTarget = [ targetInfo ];
        m_pNetwork.post( msg );
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
        if ( owner.data && owner.data.hasOwnProperty( "initialBuffs" ) ) {
            m_buffList = owner.data.initialBuffs as Array;

            if ( m_boSkillReady ) {
                _buildBuff();
            }

            delete  owner.data.initialBuffs;
        }
    }

    private var m_buffList : Array;
    private var m_boSkillReady : Boolean;
    private var m_pNetwork : INetworking;
    private var m_nType : int;
    private var m_nID : int;
}
}
