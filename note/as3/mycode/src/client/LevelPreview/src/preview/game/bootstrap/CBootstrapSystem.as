//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package preview.game.bootstrap {

import QFLib.Application.Component.ILifeCycle;
import QFLib.Interface.IUpdatable;

import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.game.character.ai.CAIHandler;
import kof.game.character.animation.CAnimationHandler;
import kof.game.character.collision.CCollisionHandler;
import kof.game.character.fight.CFightHandler;
import kof.game.character.fight.emitter.CEmitterHandler;
import kof.game.character.fight.skill.CSpellSkillHandle;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.handler.CTickHandler;
import kof.game.character.movement.CMovementHandler;
import kof.game.character.state.CCharacterFSMHandler;
import kof.game.core.CECSLoop;
import kof.game.core.IGameSystemHandler;
import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CBootstrapSystem extends CAppSystem implements IUpdatable {

    /** @private */
    private var m_pGameSystem:CECSLoop;
    /** @private */
    private var m_bReady:Boolean;
    /** @private */
    private var m_fElapsedDownTime:Number;

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
    override protected function onSetup():Boolean {
        if (!m_pGameSystem) {
            m_pGameSystem = stage.getSystem(CECSLoop) as CECSLoop;
            CAssertUtils.assertNotNull(m_pGameSystem, "CGameSystem required.");

            var handlers:Array = [
                /**new CPlayHandler(),
                // new CAIHandler(),
                new CCharacterFSMHandler(),
                new CMovementHandler(),
                new CDemoFightHandler()*/

//**
                new CPlayHandler(),
                new CAIHandler(),
                new CCharacterFSMHandler(),
                new CMovementHandler(),
                new CFightHandler(),
                new CEmitterHandler(),
                new CCollisionHandler(),
                new CSpellSkillHandle()
                // */
            ];

            // Handling specified components.
            for each (var handler:IGameSystemHandler in handlers) {
                var lifeCycleHandler:ILifeCycle = handler as ILifeCycle;
                if (lifeCycleHandler) {
                    m_pGameSystem.addBean(handler as ILifeCycle, MANAGED);
                    lifeCycleHandler.start();
                }

                var gamePipelineHandler:IGameSystemHandler = handler as IGameSystemHandler;
                if (gamePipelineHandler)
                    m_pGameSystem.addHandler(handler);
            }

            //collision detection
            {
                const collisionHandler : CCollisionHandler = new CCollisionHandler();
                m_pGameSystem.addBean(collisionHandler, MANAGED);
                m_pGameSystem.addHandler(collisionHandler);
                collisionHandler.start();
            }

            {
                // Updated all SubscribeBehaviour before animation updating.
                const tickHandler:CTickHandler = new CTickHandler();
                m_pGameSystem.addBean(tickHandler, MANAGED); // added to lifecycle managed.
                m_pGameSystem.addHandler(tickHandler); // added to GameSystem pipeline.
                tickHandler.start();
            }

            {
                // By default, animation will be updated last.
                const animationHandler:CAnimationHandler = new CAnimationHandler();
                m_pGameSystem.addBean(animationHandler, MANAGED);
                m_pGameSystem.addHandler(animationHandler);
                animationHandler.start();
            }

        }

        return true;
    }

    override protected function onShutdown():Boolean {
        if (!m_pGameSystem)
            m_pGameSystem = stage.getSystem(CECSLoop) as CECSLoop;

        if (m_pGameSystem) {
            m_pGameSystem.removeAllHandler();
        }

        m_pGameSystem = null;
        m_fElapsedDownTime = 0;

        return true;
    }

    /**
     * @inheritDoc
     */
    override protected function enterStage(appStage:CAppStage):void {
        LOG.logMsg("Game Booting ...");
    }

    public function update(delta:Number):void {
        m_fElapsedDownTime += delta;
        if (m_fElapsedDownTime >= 1.0) {
            m_fElapsedDownTime -= 1.0;
            // FIXME: do something every 1 second passed.
        }
    }

}
}
