//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/25.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline {

import kof.framework.INetworking;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameComponent;

public class CSyncStateMgr extends CGameComponent {
    public function CSyncStateMgr( pNetworking : INetworking ) {
        super( "syncStateMgr" );
        m_pNetworking = pNetworking;
    }

    override public function dispose() : void {
        m_pNetworking = null;
        super.dispose();
    }

    override protected function onExit() : void {
        var pFightTri : CCharacterFightTriggle = this.pFightTrigger;
        if ( pFightTri ) {
            pFightTri.removeEventListener( CFightTriggleEvent.REQUEST_SYNC_SKILL_STATE, postStateChange );
        }

    }

    override protected function onEnter() : void {
        var networkInput : CCharacterNetworkInput = pNetworkcomp;
        if ( networkInput.isAsHost ) {
            var pFightTri : CCharacterFightTriggle = pFightTrigger;
            if ( pFightTri ) {
                pFightTri.addEventListener( CFightTriggleEvent.REQUEST_SYNC_SKILL_STATE, postStateChange )
            }
        }
    }

    protected function postStateChange( e : CFightTriggleEvent ) : void {

    }

    final private function get pNetworkcomp() : CCharacterNetworkInput {
        return owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
    }

    final private function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    private var m_pNetworking : INetworking;
}
}
