//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.bootstrap {

import QFLib.Application.Component.ILifeCycle;
import QFLib.Interface.IUpdatable;

import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.game.character.NPC.CNPCHandler;
import kof.game.character.ai.CAIHandler;
import kof.game.character.animation.CAnimationHandler;
import kof.game.character.collision.CCollisionHandler;
import kof.game.character.fight.CFightHandler;
import kof.game.character.fight.emitter.CEmitterHandler;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.handler.CTickHandler;
import kof.game.character.mapObject.CMapObjectHandler;
import kof.game.character.movement.CMovementHandler;
import kof.game.character.state.CCharacterFSMHandler;
import kof.game.core.CECSLoop;
import kof.game.core.IGameSystemHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CBootstrapSystem extends CAppSystem implements IUpdatable {

    /** @private */
    private var m_pGameSystem : CECSLoop;
    /** @private */
    private var m_fElapsedDownTime : Number;

    /**
     * Creates a new CBootstrapSystem.
     */
    public function CBootstrapSystem() {
        super();
        m_fElapsedDownTime = 0;
    }

    /**
     * @inheritDoc
     */
    override protected function onSetup() : Boolean {
        if ( !m_pGameSystem ) {
            m_pGameSystem = stage.getSystem( CECSLoop ) as CECSLoop;
            CAssertUtils.assertNotNull( m_pGameSystem, "CECSLoop required." );

            var handlers : Array = [
                new CMovementHandler(),
                new CAnimationHandler(),
                new CCollisionHandler(),
                new CPlayHandler(),
                new CAIHandler(),
                new CCharacterFSMHandler(),
                new CEmitterHandler(),
                new CFightHandler(),
                new CTickHandler(),
                new CNPCHandler(),
                new CMapObjectHandler(),
            ];

            // Handling specified components.
            for each ( var handler : IGameSystemHandler in handlers ) {
                var lifeCycleHandler : ILifeCycle = handler as ILifeCycle;
                if ( lifeCycleHandler ) {
                    m_pGameSystem.addBean( handler as ILifeCycle, MANAGED );
                    lifeCycleHandler.start();
                }

                var gamePipelineHandler : IGameSystemHandler = handler as IGameSystemHandler;
                if ( gamePipelineHandler )
                    m_pGameSystem.addHandler( handler );
            }
        }

        this.addBean( new CPingPongHandler() );
        this.addBean( new CServerAskHandler() );
        this.addBean( new CNetDelayHandler() );

        _addListeners();

        return true;
    }

    private function _addListeners():void
    {
        stage.getSystem(CInstanceSystem ).addEventListener(CInstanceEvent.ENTER_INSTANCE, _onInstanceEvent);
    }

    private function _removeListeners():void
    {
        stage.getSystem(CInstanceSystem ).addEventListener(CInstanceEvent.ENTER_INSTANCE, _onInstanceEvent);
    }

    private function _onInstanceEvent(e:CInstanceEvent):void
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            var pph : CPingPongHandler = this.getBean( CPingPongHandler ) as CPingPongHandler;
//            if(instanceSystem.isMainCity)
//            {
//                pph.resetHeartBeat(30);
//            }
//            else if(instanceSystem.isInInstance)
//            {
//                pph.resetHeartBeat(5);
//            }
            pph.resetHeartBeat(5);
        }
    }

    override protected function onShutdown() : Boolean {
        if ( !m_pGameSystem )
            m_pGameSystem = stage.getSystem( CECSLoop ) as CECSLoop;

        if ( m_pGameSystem ) {
            m_pGameSystem.removeAllHandler();
        }

        m_pGameSystem = null;
        m_fElapsedDownTime = 0;

        _removeListeners();

        return true;
    }

    /**
     * @inheritDoc
     */
    override protected function enterStage( appStage : CAppStage ) : void {
        LOG.logTraceMsg( "Game Booting ..." );
    }

    public function update( delta : Number ) : void {
        m_fElapsedDownTime += delta;
        if ( m_fElapsedDownTime >= 1.0 ) {
            m_fElapsedDownTime -= 1.0;
            // FIXME: do something every 1 second passed.

            var pph : CPingPongHandler = this.getBean( CPingPongHandler ) as CPingPongHandler;
            if ( pph ) {
                pph.update( 1.0 );
            }
        }
        if( m_pGameSystem ) {
            var fightHandle : CFightHandler = m_pGameSystem.getBean( CFightHandler ) as CFightHandler;
            if ( fightHandle )
                fightHandle.update( delta );
        }
    }

}
}
