//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/8.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy {

import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.synctimeline.CFightTimeLineFacade;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CBaseStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.ISyncStrategy;
import kof.game.core.CGameObject;

public class CSyncContext {
    public function CSyncContext( owner : CGameObject = null ) {
        m_pOwner = owner;
    }

    public function dispose() : void {
        m_pOwner = null;
        m_theActionStrategy = null;
    }

    public function resetStrategy() : void {
        m_theActionStrategy = null;
    }

    public function setStrategy( strategy : CBaseStrategy ) : void {
        this.m_theActionStrategy = strategy;
        if ( strategy )
            this.m_theActionStrategy.attachToContext( this );
    }

    public function takeAction() : void {
        var pNetworkInput : CCharacterResponseQueue = owner.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
        if ( !pNetworkInput )
            return;
        if ( m_theActionStrategy )
            m_theActionStrategy.takeAction();
//        pNetworkInput.addResponseStrategy( m_theActionStrategy );
    }

    public function set owner( target : CGameObject ) : void {
        m_pOwner = target;
    }

    public function get owner() : CGameObject {
        return m_pOwner;
    }

    public function pTimeLineFacade() : CFightTimeLineFacade {
        return owner.getComponentByClass( CFightTimeLineFacade, true ) as CFightTimeLineFacade;
    }

    private var m_theActionStrategy : CBaseStrategy;
    private var m_pOwner : CGameObject;
}
}
