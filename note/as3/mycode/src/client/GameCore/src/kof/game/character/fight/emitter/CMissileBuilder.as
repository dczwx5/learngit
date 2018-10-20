//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/11.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;

import kof.framework.IDatabase;
import kof.game.audio.IAudio;

import kof.game.character.CCharacterInitializer;
import kof.game.character.CDatabaseMediator;
import kof.game.character.CEventMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.buff.CBuffContainer;
import kof.game.character.fight.buff.CBuffEffectComponent;
import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;
import kof.game.character.fight.emitter.statemach.CTriStateMachine;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillcalc.hurt.CFightDamageComponent;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fx.CFXMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CFromTargetProperty;
import kof.game.character.property.CMissileProperty;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.instance.IInstanceFacade;
import kof.game.level.ILevelFacade;
import kof.game.scene.CSceneHandler;
import kof.game.scene.ISceneFacade;

public class CMissileBuilder implements IDisposable {

    public function CMissileBuilder() {
    }

    public function dispose() : void {
        m_ptheCFrameWork = null;
        m_ptheEmitterFacade = null;
        m_pSceneHandler = null;
    }

    public function build( obj : CGameObject ) : Boolean {
        var pLevelSystem : ILevelFacade = this.getSystem( ILevelFacade );
        var pInstanceSystem : IInstanceFacade = this.getSystem( IInstanceFacade );
        var pSceneSystem : ISceneFacade = this.m_pSceneHandler.system as ISceneFacade;
        var dataSystem : IDatabase = this.getSystem( IDatabase );

        obj.addComponent( new CKOFTransform() );
        obj.addComponent( new CEventMediator() );
        obj.addComponent( new CMissileInitializer() );
        obj.addComponent( new CCharacterInput() );
        obj.addComponent( new CTriStateMachine() );
        obj.addComponent( new CDatabaseMediator( dataSystem ) );
        obj.addComponent( new CAudioMediator( this.getSystem( IAudio ) as IAudio ) );
        obj.addComponent( new CMissileProperty() );

        obj.addComponent( new CMovement() );
        obj.addComponent( new CMasterCompomnent() );
        obj.addComponent( new CMissileDisplay( m_ptheCFrameWork ) );
        obj.addComponent( new CCollisionComponent() );
        obj.addComponent( new CTargetCriteriaComponet( dataSystem ) );
        obj.addComponent( new CFXMediator( m_ptheCFrameWork ) );


        obj.addComponent( new CLevelMediator( pSceneSystem, pInstanceSystem, pLevelSystem ) );

        obj.addComponent( new CCharacterStateBoard() );
        obj.addComponent( new CCharacterFightTriggle() );
        obj.addComponent( new CSkillCaster( null, m_ptheEmitterFacade ) );
        obj.addComponent( new CTargetCriteriaComponet( dataSystem ) )
        obj.addComponent( new CFightCalc() );
        obj.addComponent( new CFightProperty() );
        obj.addComponent( new CFightDamageComponent() );
        obj.addComponent( new CBuffAttModifiedProperty() );
        obj.addComponent( new CBuffEffectComponent( m_pSceneHandler ) );
        obj.addComponent( new CBuffContainer( m_pSceneHandler ) );
        obj.addComponent( new CFightFloatSprite() );
        obj.addComponent( new CEmitterComponent( dataSystem, m_ptheEmitterFacade , this.sceneHandler.networking , pSceneSystem ) );
        obj.addComponent( new CMissileIdentifersRepository());


        return true;
    }

    public function getSystem( clazz : Class ) : * {
        return this.sceneHandler.system.stage.getSystem( clazz );
    }

    public function get sceneHandler() : CSceneHandler {
        return m_pSceneHandler;
    }

    public function set sceneHandler( value : CSceneHandler ) : void {
        m_pSceneHandler = value;
    }

    public function removeMissile( obj : CGameObject ) : Boolean {
        obj.removeAllComponents( true );
        return true;
    }

    public function set theFrameWork( value : CFramework ) : void {
        m_ptheCFrameWork = value;
    }

    public function set theEmitterFacade( value : CMissileContainer ) : void {
        m_ptheEmitterFacade = value;
    }

    final private function get theSceneFacade() : ISceneFacade {
        return m_ptheEmitterFacade.system as ISceneFacade;
    }

    private var m_ptheCFrameWork : CFramework;
    private var m_ptheEmitterFacade : CMissileContainer;
    /** 场景系统逻辑 */
    private var m_pSceneHandler : CSceneHandler;


}
}
