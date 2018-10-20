//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Foundation.CLog;
import QFLib.Foundation.CMap;
import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;

import flash.errors.IllegalOperationError;

import kof.data.KOFTableConstants;
import kof.framework.IConfiguration;
import kof.framework.IDatabase;
import kof.game.audio.IAudio;
import kof.game.character.NPC.CNPCBubbleMediator;
import kof.game.character.NPC.CNPCMoveMediator;
import kof.game.character.NPC.CNPCSprite;
import kof.game.character.NPC.CNPCTriggerMediator;
import kof.game.character.NPC.CNPCViewMediator;
import kof.game.character.NPC.CNpcTriggerComponent;
import kof.game.character.NPC.INPCViewFacade;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.CAutoRecoveryComponent;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CFightHandler;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.buff.CSelfBuffInitializer;
import kof.game.character.fight.catches.CKeepAwayTrunk;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.buff.CBuffContainer;
import kof.game.character.fight.buff.CBuffEffectComponent;
import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;
import kof.game.character.fight.emitter.CMissileBuilder;
import kof.game.character.fight.emitter.CMissileContainer;
import kof.game.character.fight.emitter.CMissileIdentifersRepository;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.property.CSkillPropertyComponent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.synctimeline.CFightTimeLineFacade;
import kof.game.character.fight.sync.synctimeline.base.strategy.CSyncStrategyComp;
import kof.game.character.fx.CFXMediator;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.character.movement.CMovement;
import kof.game.character.movement.CNavigation;
import kof.game.character.pathing.CPathingMediator;
import kof.game.character.scene.CBubblesMediator;
import kof.game.character.scripts.CEyeshot;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.scripts.CMonsterSprite;
import kof.game.character.scripts.CNamedSprite;
import kof.game.character.scripts.CPlayerIndexSprite;
import kof.game.character.scripts.CRootRingSpirte;
import kof.game.character.skin.CSkinDisplay;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.IInstanceFacade;
import kof.game.level.ILevelFacade;
import kof.game.npc.INpcFacade;
import kof.game.pathing.IPathingFacade;
import kof.game.scenario.IScenarioSystem;
import kof.game.scene.CSceneHandler;
import kof.game.scene.ISceneFacade;
import kof.util.CAssertUtils;

/**
 * 角色构建辅助
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterBuilder implements IDisposable {

    static internal var LOG : CLog = new CLog( "CCharacterBuilder" );

    /** 渲染器 */
    public var graphicsFramework : CFramework;
    /** 数据系统接口 */
    public var database : IDatabase;
    /** 场景系统逻辑 */
    private var m_pSceneHandler : CSceneHandler;

    /** sub-builders */
    private var m_pMonsterBuilder : CMonsterBuilder;
    private var m_pPlayerBuilder : CPlayerBuilder;
    private var m_pMapObjectBuilder : CMapObjectBuilder;
    private var m_pNPCBuilder : CNPCBuilder;
    private var m_pBuffBuilder : CBuffBuilder;
    private var m_pStandbyBuilder : CStandbyBuilder;
    private var m_pMissileBuilder : CMissileBuilder;

    public function CCharacterBuilder() {
        super();
        this.m_pMonsterBuilder = new CMonsterBuilder( this );
        this.m_pPlayerBuilder = new CPlayerBuilder( this );
        this.m_pMapObjectBuilder = new CMapObjectBuilder( this );
        this.m_pNPCBuilder = new CNPCBuilder( this );
        this.m_pBuffBuilder = new CBuffBuilder( this );
        this.m_pStandbyBuilder = new CStandbyBuilder( this );
        this.m_pMissileBuilder = new CMissileBuilder();
    }

    public function dispose() : void {
        if ( m_pMonsterBuilder )
            m_pMonsterBuilder.dispose();
        m_pMapObjectBuilder = null;

        if ( m_pPlayerBuilder )
            m_pPlayerBuilder.dispose();
        m_pPlayerBuilder = null;

        if ( m_pMapObjectBuilder )
            m_pMapObjectBuilder.dispose();
        m_pMapObjectBuilder = null;

        if ( m_pNPCBuilder )
            m_pNPCBuilder.dispose();
        m_pNPCBuilder = null;

        if ( m_pStandbyBuilder )
            m_pStandbyBuilder.dispose();
        m_pStandbyBuilder = null;

        if( m_pBuffBuilder )
                m_pBuffBuilder.dispose();
        m_pBuffBuilder = null;

        if( m_pMissileBuilder )
            m_pMissileBuilder.dispose();
        m_pMissileBuilder = null;

        graphicsFramework = null;
        m_pSceneHandler = null;
        database = null;

    }

    public function get sceneFacade() : ISceneFacade {
        return this.sceneHandler.system as ISceneFacade;
    }

    public function get sceneHandler() : CSceneHandler {
        return m_pSceneHandler;
    }

    public function set sceneHandler( value : CSceneHandler ) : void {
        m_pSceneHandler = value;

        if ( !this.database && m_pSceneHandler ) {
            this.database = m_pSceneHandler.system.stage.getSystem( IDatabase ) as IDatabase
        }
    }

    public function get instanceSystem() : IInstanceFacade {
        return getSystem( IInstanceFacade ) as IInstanceFacade;
    }

    public function get pPlayerHandle() : CPlayHandler {
        return (sceneHandler.system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
    }

    public function getSystem( clazz : Class ) : * {
        return this.sceneHandler.system.stage.getSystem( clazz );
    }

    public function build( obj : CGameObject ) : Boolean {
        if ( CCharacterDataDescriptor.isCharacterData( obj.data ) ) {
            // Correct the position in the scene by first.

            var iTypeOf : int = CCharacterDataDescriptor.getType( obj.data );

            switch ( iTypeOf ) {
                case CCharacterDataDescriptor.TYPE_PLAYER:
                    return this.m_pPlayerBuilder.build( obj );
                case CCharacterDataDescriptor.TYPE_MONSTER:
                    return this.m_pMonsterBuilder.build( obj );
                case CCharacterDataDescriptor.TYPE_MAP_OBJECT:
                    return this.m_pMapObjectBuilder.build( obj );
                case CCharacterDataDescriptor.TYPE_NPC:
                    return this.m_pNPCBuilder.build( obj );
                case CCharacterDataDescriptor.TYPE_BUFF:
                    return this.m_pBuffBuilder.build( obj );
                case CCharacterDataDescriptor.TYPE_STANDBY:
                    return this.m_pStandbyBuilder.build( obj );
                case CCharacterDataDescriptor.TYPE_MISSILE:
                    return this.m_pMissileBuilder.build( obj );
                default:
                    throw new IllegalOperationError( "Unknown type of GameObject:" + iTypeOf );
                    break;
            }
        }

        return false;
    }

    public function updateSkin( obj : CGameObject, bForced : Boolean = true ) : Boolean {
        if ( CCharacterDataDescriptor.isCharacterData( obj.data ) ) {
            // Correct the position in the scene by first.

            var iTypeOf : int = CCharacterDataDescriptor.getType( obj.data );

            switch ( iTypeOf ) {
                case CCharacterDataDescriptor.TYPE_PLAYER:
                    return this.m_pPlayerBuilder.updateSkin( obj, bForced );
                case CCharacterDataDescriptor.TYPE_MONSTER:
                    return this.m_pMonsterBuilder.updateSkin( obj, bForced );
                case CCharacterDataDescriptor.TYPE_MAP_OBJECT:
                    return this.m_pMapObjectBuilder.updateSkin( obj, bForced );
                case CCharacterDataDescriptor.TYPE_NPC:
                    return this.m_pNPCBuilder.updateSkin( obj, bForced );
                case CCharacterDataDescriptor.TYPE_STANDBY:
                    return this.m_pStandbyBuilder.updateSkin( obj, bForced );
                default:
                    throw new IllegalOperationError( "Unknown type of GameObject:" + iTypeOf );
                    break;
            }
        }

        return false;
    }

    internal function addBaseComponents( obj : CGameObject ) : void {
        obj.addComponent( new CKOFTransform() );
        obj.addComponent( new CTarget() );
        obj.addComponent( new CMovement() );
        obj.addComponent( new CDatabaseMediator( this.database ) );

        var pConfig : IConfiguration = this.sceneHandler.system.stage.getBean( IConfiguration ) as IConfiguration;
        obj.addComponent( new CKOFConfiguration( pConfig ) );
    }

    internal function buildStateSupported( obj : CGameObject ) : void {
        obj.addComponent( new CCharacterStateBoard() );
        obj.addComponent( new CCharacterStateMachine() );
    }

    internal function buildEventSupported( obj : CGameObject ) : void {
        CAssertUtils.assertNotNull( obj, "A legal CGameObject is required." );

        obj.addComponent( new CEventMediator( obj ) );
    }

    internal function buildPhysicalSupported( obj : CGameObject ) : void {
        obj.addComponent( new CCollisionComponent() );
    }

    internal function buildSkillSupported( obj : CGameObject ) : void {
        obj.addComponent( new CSkillList() );
        obj.addComponent( new CCharacterFightTriggle() );

        var pMissileContainer : CMissileContainer = this.sceneHandler.system.getBean( CMissileContainer );
        var pFightHandler : CFightHandler = this.getSystem( CECSLoop ).getBean( CFightHandler );

        obj.addComponent( new CKeepAwayTrunk());
        obj.addComponent( new CSkillPropertyComponent(this.database));
        obj.addComponent( new CSkillCaster( pFightHandler, pMissileContainer ));
        obj.addComponent( new CTargetCriteriaComponet(this.database) );
        obj.addComponent( new CSimulateSkillCaster("skillsimulator"));
        obj.addComponent( new CBuffAttModifiedProperty() );
        obj.addComponent( new CBuffEffectComponent( m_pSceneHandler ) );
        obj.addComponent( new CBuffContainer(m_pSceneHandler) );
        obj.addComponent( new CSelfBuffInitializer( this.sceneHandler.networking ));
        obj.addComponent( new CMissileIdentifersRepository());

        obj.addComponent( new CSkillCatcher() );
        obj.addComponent( new CFightTimeLineFacade( pFightHandler ));
        obj.addComponent( new CSyncStrategyComp() );
    }

    internal function buildRenderingSupported( obj : CGameObject ) : void {
        obj.addComponent( new CSkinDisplay( graphicsFramework ) );
        obj.addComponent( new CCharacterDisplay( graphicsFramework ) );
        obj.addComponent( new CFightFloatSprite() );
        obj.addComponent( new CRootRingSpirte( graphicsFramework, pPlayerHandle ) );
        obj.addComponent( new CMonsterSprite( graphicsFramework ) );
        obj.addComponent( new CPlayerIndexSprite() );
    }

    internal function buildInputSupported( obj : CGameObject ) : void {
        obj.addComponent( new CCharacterInput() );
        // obj.addComponent( new CAIComponent() );
    }

    internal function buildNetworkingSupported( obj : CGameObject ) : void {
        obj.addComponent( new CNetworkMessageMediator( this.sceneHandler.networking ) );
        obj.addComponent( new CCharacterNetworkInput( this.sceneHandler.networking, instanceSystem ) );
        obj.addComponent( new CCharacterSyncBoard() );
        obj.addComponent( new CCharacterResponseQueue( this.sceneFacade ) );
    }

    internal function buildBaseNetworkingSupported( obj : CGameObject ) : void {
        obj.addComponent( new CNetworkMessageMediator( this.sceneHandler.networking ) );
        obj.addComponent( new CCharacterNetworkInput( this.sceneHandler.networking, instanceSystem ) );
        obj.addComponent( new CCharacterSyncBoard() );
        obj.addComponent( new CCharacterResponseQueue( this.sceneFacade ) );
    }

    internal function buildAppSystemSupported( obj : CGameObject ) : void {
        var pLevelSystem : ILevelFacade = this.getSystem( ILevelFacade );
        var pInstanceSystem : IInstanceFacade = this.getSystem( IInstanceFacade );

        obj.addComponent( new CLevelMediator( this.sceneFacade, pInstanceSystem, pLevelSystem ) );
        obj.addComponent( new CBubblesMediator( pLevelSystem ) );

        var pathingSystem:IPathingFacade = this.getSystem(IPathingFacade);
        obj.addComponent(new CPathingMediator(pathingSystem, pInstanceSystem.isMainCity))
    }

    internal function buildOtherSupported( obj : CGameObject ) : void {
        obj.addComponent( new CFacadeMediator() );
        obj.addComponent( new CNavigation() );
        obj.addComponent( new CFXMediator( graphicsFramework ) );
        obj.addComponent( new CAudioMediator( this.getSystem( IAudio ) as IAudio ) );
        obj.addComponent( new CEyeshot );
        obj.addComponent( new CNamedSprite() );
    }

    internal function buildNPCSupported(obj : CGameObject):void{
        var pNPCViewFacade : INPCViewFacade = this.getSystem( INPCViewFacade );
        obj.addComponent( new CNPCViewMediator(pNPCViewFacade) );
        var pLevelSystem : ILevelFacade = this.getSystem( ILevelFacade );
        var pScenarioSystem : IScenarioSystem = this.getSystem( IScenarioSystem );
        var pNpcFacade : INpcFacade = this.getSystem( INpcFacade );
        obj.addComponent( new CNPCTriggerMediator( pNpcFacade, pLevelSystem, pScenarioSystem, this.pPlayerHandle, this.sceneHandler.networking) );
        obj.addComponent( new CNPCSprite(graphicsFramework) );
        obj.addComponent( new CNPCBubbleMediator() );
        obj.addComponent( new CNPCMoveMediator() );
        obj.addComponent( new CNpcTriggerComponent() );
    }

    public function disposeCharacter( character : CGameObject ) : void {
        character.removeAllComponents( true );
    }

}
}

// vim:ft=as3 sw=4 ts=4 expandtab tw=120
