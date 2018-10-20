//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import QFLib.Application.Component.IRecycler;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CTimeDog;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.Memory.CResourcePool;

import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Point;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterBuilder;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.ICharacterFactory;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.emitter.CMissileContainer;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.state.CCharacterState;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.message.CAbstractPackMessage;
import kof.message.Map.CharacterAddResponse;
import kof.message.Map.CharacterRemovedResponse;
import kof.message.Map.CharacterUpdateResponse;
import kof.message.Map.MapEnterResponse;
import kof.message.Map.MapLoginRequest;
import kof.message.Map.ReadyCharacterInfoResponse;
import kof.table.Town;
import kof.ui.IUICanvas;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CSceneHandler extends CSystemHandler implements ICharacterFactory, IUpdatable {

    private var m_pSpawner : CSpawnHandler;
    private var m_pObjectLists : CSceneObjectLists;
    private var m_pSceneRendering : CSceneRendering;
    private var m_pMissileContainer : CMissileContainer;
    /** @private */
    private var m_listCharacterPool : IRecycler;
    /** @private */
    private var m_pCharacterBuilder : CCharacterBuilder;
    private var m_pHeroSpawnTimeDog : CTimeDog;
    private var m_bHandleUILoadingRemoved : Boolean;

    private var m_pReadyCharacter : CMap;

    /** Constructor */
    public function CSceneHandler() {
        super();
    }

    /** Returns the factory service with Character. */
    public function get characterFactory() : ICharacterFactory {
        return this;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if ( ret ) {
            networking.bind( MapEnterResponse ).toHandler( onMapEnterMessageHandler );

            networking.bind( CharacterAddResponse ).toHandler( onCharacterAddMessageHandler );
            networking.bind( CharacterRemovedResponse ).toHandler( onCharacterLeaveMessageHandler );
            networking.bind( CharacterUpdateResponse ).toHandler( onCharacterUpdateMessageHandler );
            networking.bind( ReadyCharacterInfoResponse ).toHandler( onReadyCharacterInfoResponse );

            m_listCharacterPool = new CResourcePool( "CharacterPool", CGameObject );
            m_pCharacterBuilder = new CCharacterBuilder();

            system.addEventListener( CSceneEvent.HERO_CREATED, _onHeroCreatedEventHandler, false, CEventPriority.DEFAULT, true );
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            networking.unbind( MapEnterResponse );
            networking.unbind( CharacterAddResponse );
            networking.unbind( CharacterRemovedResponse );

            if ( m_listCharacterPool is IDisposable )
                IDisposable( m_listCharacterPool ).dispose();

            if ( m_pCharacterBuilder )
                m_pCharacterBuilder.dispose();

            system.removeEventListener( CSceneEvent.HERO_CREATED, _onHeroCreatedEventHandler );
        }
        return ret;
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        m_pObjectLists = system.getBean( CSceneObjectLists ) as CSceneObjectLists;
        m_pSpawner = system.getBean( CSpawnHandler ) as CSpawnHandler;
        m_pSceneRendering = system.getBean( CSceneRendering ) as CSceneRendering;
        m_pMissileContainer= system.getBean( CMissileContainer ) as CMissileContainer;

        CAssertUtils.assertNotNull( m_pObjectLists );
        CAssertUtils.assertNotNull( m_pSpawner );
        CAssertUtils.assertNotNull( m_pSceneRendering );

        m_pCharacterBuilder.graphicsFramework = (system as CSceneSystem).graphicsFramework;
        m_pCharacterBuilder.sceneHandler = this;

        this.requestToEnterScene();
    }

    override protected function exitSystem( system : CAppSystem ) : void {
        this.clearAllCharacter();

        if ( m_pObjectLists ) {
            m_pObjectLists.clear();
        }

        m_pObjectLists = null;
        m_pSpawner = null;
        m_pSceneRendering = null;

        if ( m_pHeroSpawnTimeDog )
            m_pHeroSpawnTimeDog.dispose();
        m_pHeroSpawnTimeDog = null;
    }

    /**
     * 请求Server开始进入地图
     */
    protected function requestToEnterScene() : void {
        var mapID : int = 0;
        var mapType : int = 1;
        var roleData : Object = system.stage.configuration.getRaw( "role.data" );
        if ( roleData ) {
            mapID = int( roleData.mapID );
            mapType = int( roleData.mapType );
        }

        if ( mapType == 1 ) {
            var mapLoginRequest : MapLoginRequest = networking.getMessage( MapLoginRequest ) as MapLoginRequest;
            mapLoginRequest.mapID = mapID;

            networking.send( mapLoginRequest );
        }
    }

    //noinspection JSMethodCanBeStatic
    final private function isValidObject( data : Object ) : Boolean {
        if ( !data )
            return false;

        var objID : Number = Number( data.id );
        if ( isNaN( objID ) ) {
            return false;
        }

        var type : int = int( data.type );
        if ( type != 1 && type != 2 && type != 3 && type != 4 && type != 5 && type != 100 )
            return false;

        return true;
    }

    final private function isObjectExists( data : Object ) : Boolean {
        if ( !data )
            return false;

        var objID : Number = CCharacterDataDescriptor.getID( data );
        if ( isNaN( objID ) )
            return false;

        var type : int = CCharacterDataDescriptor.getType( ( data ) );

        if ( type == 1 ) {
            return m_pObjectLists.getPlayer( objID );
        } else if ( type == 2 ) {
            return m_pObjectLists.getMonster( objID );
        } else if ( type == 3 ) {
            return m_pObjectLists.getMapObject( objID );
        } else if ( type == 4 ) {
            return m_pObjectLists.getNPC( objID );
        }

        return false;
    }

    public function isHero( obj : CGameObject ) : Boolean {
        if ( !obj )
            return false;
//        var roleData : Object = system.stage.configuration.getRaw( "role.data" ) || {};
//        return CCharacterDataDescriptor.getID( obj.data ) == roleData.roleID;
        return CCharacterDataDescriptor.isHero( obj.data );
    }

    public function addCharacter( data : Object ) : CGameObject {
        if ( data.type == 1 ) {
            return this.addPlayer( data );
        } else if ( data.type == 2 ) {
            return this.addMonster( data );
        } else if ( data.type == 3 ) {
            return this.addMapObject( data );
        } else if ( data.type == 4 ) {
            return this.addNPC( data );
        } else if ( data.type == CCharacterDataDescriptor.TYPE_BUFF ) {
            return this.addBuff( data );
        } else if ( data.type == CCharacterDataDescriptor.TYPE_STANDBY ) {
            return this.addStandby( data );
        } else if( data.type == CCharacterDataDescriptor.TYPE_MISSILE){
            return m_pMissileContainer.shotMissile( data );
        }else{
            LOG.logErrorMsg( "Unknown character type: " + data.type );
            throw new ArgumentError( "Unknown character type: " + data.type );
        }
    }

    public function removeCharacter( id : Number, type : int ) : CGameObject {
        if ( type == 1 ) {
            return this.removePlayer( id );
        } else if ( type == 2 ) {
            return this.removeMonster( id );
        } else if ( type == 3 ) {
            return this.removeMapObject( id );
        } else if ( type == 4 ) {
            return this.removeNPC( id );
        } else if ( type == CCharacterDataDescriptor.TYPE_BUFF ) {
            return this.removeBuff( id );
        } else if ( type == CCharacterDataDescriptor.TYPE_STANDBY ) {
            return this.removePlayer( id );
        } else if( type == CCharacterDataDescriptor.TYPE_MISSILE ){
            return m_pMissileContainer.removeMissile( id );
        }else
        {
            LOG.logErrorMsg( "Unknown character type: " + type );
            throw new ArgumentError( "Unknown character type: " + type );
        }
    }

    public function updateCharacter( data : Object ) : void {
        if ( isValidObject( data ) ) {
            if ( !isObjectExists( data ) ) {
                LOG.logWarningMsg( "Can't find character for updating: " + data.id );
                return;
            }

            var iTypeOfGameObject : int = Math.max( 0, data.type - 1 );

            var pCharacter : CGameObject = m_pObjectLists.getGameObject( iTypeOfGameObject, data.id );
            CAssertUtils.assertNotNull( pCharacter );

            {
                delete data[ 'id' ];
                delete data[ 'type' ];
            }

            if ( !('direction' in data ) ) {
                var pSB : CCharacterStateBoard = pCharacter.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                if ( pSB ) {
                    var direction : Point = pSB.getValue( CCharacterStateBoard.DIRECTION ) as Point;
                    data.direction = direction.x;
                }
            }

            CObjectUtils.extend( pCharacter.data, data );
            m_pCharacterBuilder.updateSkin( pCharacter );
            pCharacter.invalidateData();

            if ( isHero( pCharacter ) )
                setHero( pCharacter, true );

        } else {
            LOG.logErrorMsg( "Unknown character type: " + data.type );
            throw new ArgumentError( "Unknown character type: " + data.type );
        }
    }

    public function addPlayer( data : Object ) : CGameObject {
        if ( !CCharacterDataDescriptor.isPlayer( data ) )
            throw new ArgumentError( "Incorrect type of player: " + data.type );

        var errorMsg : String;
        if ( !isValidObject( data ) ) {
            errorMsg = "Invalid data of Player, invalid id: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        if ( isObjectExists( data ) ) {
            errorMsg = "Duplicated adding Player: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        var player : CGameObject = this.characterFactory.createCharacter( data );
        CAssertUtils.assertNotNull( player, "Created null player." );

        m_pObjectLists.addPlayer( player.data.id, player ); // Push in scenegraph object lists.
        m_pSpawner.addCharacter( player );

        if ( isHero( player ) )
            this.setHero( player );


        return player;
    }

    public function removePlayer( id : Number ) : CGameObject {
        return _removeCharacter( m_pObjectLists.removePlayer( id ) );
    }

    public function addMonster( data : Object ) : CGameObject {
        if ( !CCharacterDataDescriptor.isMonster( data ) )
            throw new ArgumentError( "Incorrect type of monster: " + data.type );

        var errorMsg : String;
        if ( !isValidObject( data ) ) {
            errorMsg = "Invalid data of Monster, invalid id: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        if ( isObjectExists( data ) ) {
            errorMsg = "Duplicated adding Monster: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        var monster : CGameObject = this.characterFactory.createCharacter( data );
        CAssertUtils.assertNotNull( monster, "Created null monster." );

        m_pObjectLists.addMonster( monster.data.id, monster ); // Push in scenegraph object lists.
        m_pSpawner.addCharacter( monster );

        return monster;
    }

    public function addMapObject( data : Object ) : CGameObject {
        if ( !CCharacterDataDescriptor.isMapObject( data ) )
            throw new ArgumentError( "Incorrect type of monster: " + data.type );

        var errorMsg : String;
        if ( !isValidObject( data ) ) {
            errorMsg = "Invalid data of Monster, invalid id: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        if ( isObjectExists( data ) ) {
            errorMsg = "Duplicated adding Monster: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        var monster : CGameObject = this.characterFactory.createCharacter( data );
        CAssertUtils.assertNotNull( monster, "Created null monster." );

        m_pObjectLists.addMapObject( monster.data.id, monster ); // Push in scenegraph object lists.
        m_pSpawner.addCharacter( monster );

        return monster;
    }

    public function addNPC( data : Object ) : CGameObject {
        if ( !CCharacterDataDescriptor.isNPC( data ) )
            throw new ArgumentError( "Incorrect type of NPC: " + data.type );

        var errorMsg : String;
        if ( !isValidObject( data ) ) {
            errorMsg = "Invalid data of NPC, invalid id: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        if ( isObjectExists( data ) ) {
            errorMsg = "Duplicated adding NPC: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        var monster : CGameObject = this.characterFactory.createCharacter( data );
        CAssertUtils.assertNotNull( monster, "Created null NPC." );

        m_pObjectLists.addNPC( monster.data.id, monster ); // Push in scenegraph object lists.
        m_pSpawner.addCharacter( monster );

        return monster;
    }

    public function addBuff( data : Object ) : CGameObject {
        if ( !CCharacterDataDescriptor.isBuff( data ) )
            throw new ArgumentError( "Incorrect type of monster: " + data.type );
        var errorMsg : String;
        if ( !isValidObject( data ) ) {
            errorMsg = "Invalid data of Buff, invalid id: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        if ( isObjectExists( data ) ) {
            errorMsg = "Duplicated adding Buff: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        var buff : CGameObject = this.characterFactory.createCharacter( data );
        CAssertUtils.assertNotNull( buff, "Created null monster." );

        m_pObjectLists.addBuff( buff.data.id, buff );
        m_pSpawner.addCharacter( buff );

        return buff;
    }

    public function addStandby( data : Object ) : CGameObject {
        if ( !CCharacterDataDescriptor.isStandby( data ) )
            throw new ArgumentError( "Incorrect type of monster: " + data.type );

        var errorMsg : String;
        if ( !isValidObject( data ) ) {
            errorMsg = "Invalid data of Monster, invalid id: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        if ( isObjectExists( data ) ) {
            errorMsg = "Duplicated adding Monster: " + data.id;
            LOG.logErrorMsg( errorMsg );
            throw new IllegalOperationError( errorMsg );
        }

        var monster : CGameObject = this.characterFactory.createCharacter( data );
        CAssertUtils.assertNotNull( monster, "Created null monster." );

        m_pObjectLists.addMapObject( monster.data.id, monster ); // Push in scenegraph object lists.
        m_pSpawner.addCharacter( monster );

        return monster;
    }

    public function removeMonster( id : Number ) : CGameObject {
        return this._removeCharacter( m_pObjectLists.removeMonster( id ) );
    }

    public function removeMapObject( id : Number ) : CGameObject {
        return this._removeCharacter( m_pObjectLists.removeMonster( id ) );
    }

    public function removeNPC( id : Number ) : CGameObject {
        return this._removeCharacter( m_pObjectLists.removeNPC( id ) );
    }

    public function removeBuff( id : Number ) : CGameObject {
        return this._removeCharacter( m_pObjectLists.removeBuff( id ) );
    }

    private function _removeCharacter( obj : CGameObject ) : CGameObject {
        if ( obj ) {
            var display : IDisplay = obj.getComponentByClass( IDisplay, true ) as IDisplay;
            if ( display ) {
                m_pSceneRendering.removeDisplayObject( display.modelDisplay );
            }
            // 在生成列表中移除，如果还没被生成的情况下
            m_pSpawner.removeCharacter( obj );

            if ( this.isHero( obj ) )
                this.setHero( null );

            m_pCharacterBuilder.disposeCharacter( obj );

            return obj;
        }
        return null;
    }

    /** @inheritDoc */
    public function createCharacter( data : Object ) : CGameObject {
        var obj : CGameObject = m_listCharacterPool.allocate() as CGameObject;
        if ( !obj ) {
            throw new IllegalOperationError( "Allocated character failed." );
        }

        obj.data = data;
        m_pCharacterBuilder.build( obj );

        return obj;
    }

    /**
     * 移除所有角色
     */
    public function clearAllCharacter() : void {
        if ( m_pObjectLists ) {
            var iter : Object = m_pObjectLists.iterator;
            if ( iter ) {
                for each ( var o : CGameObject in iter ) {
                    if ( o ) {
                        this._removeCharacter( o );
                    }
                }
            }

            m_pObjectLists.clear();
        }
    }

    /** @inheritDoc */
    public function disposeCharacter( character : CGameObject ) : void {
        if ( !character )
            return;
        m_pCharacterBuilder.disposeCharacter( character ); // dispose.
        m_listCharacterPool.recycle( character ); // recycle in pool.
    }


    /**
     * 有角色被添加到当前视野
     */
    private function onCharacterAddMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : CharacterAddResponse = message as CharacterAddResponse;
        var list : Array;
        if ( msg.data is Array ) {
            list = msg.data as Array;
        } else {
            list = [ msg.data ];
        }
        if ( !list )
            return;

        for each ( var data : Object in list ) {
            this.addCharacter( data );
        }
    }

    public function setHero( hero : CGameObject, bUpdated : Boolean = false ) : void {
        var bFirst : Boolean = true;
        // Retrieves CPlayHandler and set the hero reference to CPlayHandler under control.
        var gameSystem : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        var playHandler : CPlayHandler = gameSystem.getBean( CPlayHandler ) as CPlayHandler;
//        var pNetworkMediator : CNetworkMessageMediator;
//        var pNetworkInput : CCharacterNetworkInput;

        if ( playHandler ) {
            if ( playHandler.hero == hero )
                return;

            bFirst = !Boolean( playHandler.hero );

//            if ( !bFirst ) {
//                pNetworkMediator = playHandler.hero.getComponentByClass( CNetworkMessageMediator, true ) as CNetworkMessageMediator;
//                if ( pNetworkMediator ) {
//                    pNetworkMediator.asHost = false;
//                }
//
//                pNetworkInput = playHandler.hero.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
//                if ( pNetworkInput ) {
//                    pNetworkInput.isAsHost = false;
//                }
//            }

            playHandler.hero = hero;
        }

        if ( !hero )
            this.followObject( null );
        else if ( bUpdated )
            this.followObject( hero );

        // Hero's Networking Message as host anytime.
//        if ( hero ) {
//            pNetworkMediator = hero.getComponentByClass( CNetworkMessageMediator, true ) as CNetworkMessageMediator;
//            if ( pNetworkMediator ) {
//                pNetworkMediator.asHost = true;
//            }
//
//            pNetworkInput = hero.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
//            if ( pNetworkInput ) {
//                pNetworkInput.isAsHost = true;
//            }
//        }

        if ( bFirst && hero ) {
            if ( m_pHeroSpawnTimeDog )
                m_pHeroSpawnTimeDog.dispose();

            m_pHeroSpawnTimeDog = new CTimeDog( _onHeroSpawnTimeEnd );
            m_pHeroSpawnTimeDog.start( 1 );

            // dispatch the hero created event.
            system.dispatchEvent( new CSceneEvent( hero ? CSceneEvent.HERO_CREATED : CSceneEvent.HERO_REMOVED, hero, false, false ) );
        } else if ( !bFirst ) {
            system.dispatchEvent( new CSceneEvent( CSceneEvent.HERO_READY, hero, false, false ) );
        }
    }

    public function notifyCharacterInView( target : CGameObject ) : void {
        system.dispatchEvent( new CSceneEvent( CSceneEvent.CHARACTER_IN_VIEW, target, false, false ) );
    }

    public function notifyCharacterOutView( target : CGameObject ) : void {
        system.dispatchEvent( new CSceneEvent( CSceneEvent.CHARACTER_OUT_VIEW, target, false, false ) );
    }

    final private function _onHeroCreatedEventHandler( event : CSceneEvent ) : void {
        if ( event.type == CSceneEvent.HERO_CREATED ) {
            var pHero : CGameObject = event.value;
            if ( pHero ) {
                var pEventMediator : CEventMediator = pHero.getComponentByClass( CEventMediator, false ) as CEventMediator;
                if ( pEventMediator ) {
                    pEventMediator.addEventListener( CCharacterEvent.INIT, _onHeroInit, false, CEventPriority.DEFAULT, true );
                    pEventMediator.addEventListener( CCharacterEvent.READY, _onHeroCreationReady, false, CEventPriority.DEFAULT, true );
                }
            }
        }
    }

    final private function _onHeroInit( event : Event ) : void {
        event.currentTarget.removeEventListener( CCharacterEvent.INIT, _onHeroInit );

        var obj : CGameObject = null;

        var pECS : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pECS ) {
            var pHandler : CPlayHandler = pECS.getBean( CPlayHandler ) as CPlayHandler;
            if ( pHandler ) {
                obj = pHandler.hero;
            }
        }

        this.followObject( obj );

        CAssertUtils.assertNotNull( obj );
        system.dispatchEvent( new CSceneEvent( CSceneEvent.HERO_INIT, obj, false, false ) );
    }

    final private function _onHeroCreationReady( event : Event ) : void {
        event.currentTarget.removeEventListener( CCharacterEvent.READY, _onHeroCreationReady );

        var obj : CGameObject = null;

        var pECS : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pECS ) {
            var pHandler : CPlayHandler = pECS.getBean( CPlayHandler ) as CPlayHandler;
            if ( pHandler ) {
                obj = pHandler.hero;
            }
        }

        CAssertUtils.assertNotNull( obj );
        system.dispatchEvent( new CSceneEvent( CSceneEvent.HERO_READY, obj, false, false ) );
    }

    private function _onHeroSpawnTimeEnd() : void {
        var ui : IUICanvas = system.stage.getSystem( IUICanvas ) as IUICanvas;
        if ( ui && m_bHandleUILoadingRemoved ) {
            ui.removeSceneLoading();
        }

        if ( m_pHeroSpawnTimeDog )
            m_pHeroSpawnTimeDog.dispose();
        m_pHeroSpawnTimeDog = null;
    }

    public function testCharacterUpdate( data : Object ) : void {
        this.updateCharacter( data );
    }

    private function onCharacterUpdateMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : CharacterUpdateResponse = message as CharacterUpdateResponse;
        var list : Array = ( msg.data is Array ) ? msg.data : [ msg.data ];

        for each ( var data : Object in list ) {
            this.updateCharacter( data );
        }
    }

    /**
     * 有角色离开视野
     */
    private function onCharacterLeaveMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : CharacterRemovedResponse = message as CharacterRemovedResponse;
        var list : Array = (msg.data is Array) ? msg.data : [ msg.data ];
        for each ( var data : Object in list ) {
            this.removeCharacter( data.id, data.type );
        }
    }

    private final function onMapEnterMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : MapEnterResponse = message as MapEnterResponse;

        this.enterTown( msg.mapID, msg.spawnX, msg.spawnY );
    }

    public function followObject( obj : CGameObject ) : void {
        if ( obj ) {
            var characterDisplay : IDisplay = obj.getComponentByClass( IDisplay, true ) as IDisplay;
            if ( !characterDisplay ) {
                return;
            }
            m_pSceneRendering.setFollowObject( characterDisplay.modelDisplay );
        } else {
            m_pSceneRendering.setFollowObject( null );
        }
    }

    /**
     * 进入主城
     *
     * @param townID 主城ID
     * @param x 初始X坐标（像素）
     * @param y 初始Y坐标（像素）
     */
    public function enterTown( townID : uint, x : Number, y : Number ) : void {
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        CAssertUtils.assertNotNull( pDB );

        var pTable : IDataTable = pDB.getTable( KOFTableConstants.TOWN );
        CAssertUtils.assertNotNull( pTable );

        var pTownObject : Town = pTable.findByPrimaryKey( townID ) as Town;
        if ( pTownObject ) {
            CAssertUtils.assertTrue( pTownObject.SceneName && pTownObject.SceneName.length, "Invalid SceneName configure in DataTable: Town." );
            this.enterScene( pTownObject.SceneName, x, y, false );
        } else
            LOG.logErrorMsg( "Cannot find the specific 'townID'(" + townID + ") in the CDataTable." );
    }

    /**
     * 载入场景
     *
     * @param sceneName 场景档名
     * @param x 像素X坐标
     * @param y 像素Y坐标
     * @param isStartByScenario 通过剧情开始
     */
    public function enterScene( sceneName : String, x : Number, y : Number, notRemoveLoading : Boolean) : void {
//        var ui : IUICanvas = system.stage.getSystem( IUICanvas ) as IUICanvas;
//        if ( ui ) {
//            ui.showSceneLoading();
//        }

        m_bHandleUILoadingRemoved = !notRemoveLoading;


        var rendering : CSceneRendering = system.getBean( CSceneRendering ) as CSceneRendering;
        CAssertUtils.assertNotNull( rendering );

        this.clearAllCharacter(); // dispose all character.

        rendering.setFollowObject( null ); // free the current follow target == lock the camera.
        rendering.nextSceneId = sceneName;
        rendering.nextSpawnLocation = new CVector2( x, y );

        if ( rendering.runningSceneId == sceneName ) {
            rendering.dispatchEvent( new Event( CSceneRendering.SCENE_CFG_COMPLETE ) );
        }
    }

    /**
     * 载入待战队友
     *
     */
    private function onReadyCharacterInfoResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : ReadyCharacterInfoResponse = message as ReadyCharacterInfoResponse;
        var arr : Array = msg.readyCharacters;
        if ( m_pReadyCharacter == null ) {

        }
        for each ( var obj : Object in arr ) {
            trace( obj )
        }
    }

    final public function isWalkable( f3DPosX : Number, f3DPosZ : Number, f3DHeight : Number = NaN ) : Boolean {
        if ( !m_pSceneRendering.scene )
            return false;
        return !m_pSceneRendering.scene.isBlocked( f3DPosX, f3DHeight, f3DPosZ, true );
    }

    final public function toPixel( i2DPosX : int, i2DPosY : int ) : CVector2 {
        if ( !m_pSceneRendering.terrainData )
            return new CVector2();

        var px : Number = m_pSceneRendering.terrainData.pixelX( i2DPosX );
        var py : Number = m_pSceneRendering.terrainData.pixelY( i2DPosY );
        return new CVector2( px, py );
    }

    final public function toGrid( f3DPosX : Number, f3DPosZ : Number, f3DHeight : Number = NaN ) : CVector2 {
        if ( !m_pSceneRendering.terrainData )
            return new CVector2();

        var gx : int = m_pSceneRendering.terrainData.gridX( f3DPosX );
        var gy : int = m_pSceneRendering.terrainData.gridY( f3DHeight, f3DPosZ );

        return new CVector2( gx, gy );
    }

    final public function getTerrainHeight( f3DPosX : Number, f3DPosY : Number ) : Number {
        if ( !m_pSceneRendering.scene )
            return 0;
        return m_pSceneRendering.scene.getTerrainHeight( f3DPosX, f3DPosY );
    }

    final public function getGridPosition( i2DPosX : int, i2DPosY : int ) : CVector3 {
        if ( !m_pSceneRendering.terrainData )
            return new CVector3();

        return m_pSceneRendering.terrainData.gridPosition( i2DPosX, i2DPosY );
    }

    public function update( delta : Number ) : void {
        if ( m_pHeroSpawnTimeDog ) {
            m_pHeroSpawnTimeDog.update( delta );
        }
    }
}
}
