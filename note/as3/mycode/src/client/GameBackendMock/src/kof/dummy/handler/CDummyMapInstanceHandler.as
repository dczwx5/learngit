//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.dummy.handler {

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.Foundation.CKeyboard;
import QFLib.Framework.CObject;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.ui.Keyboard;

import kof.data.KOFTableConstants;
import kof.dummy.CDummyDatabase;
import kof.dummy.CDummyServer;
import kof.framework.CAbstractHandler;
import kof.framework.CAppStage;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.CKOFTransform;
import kof.game.character.ai.CAIComponent;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterPropertyCale;
import kof.game.character.property.CMonsterPropertyData;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneEvent;
import kof.game.scene.ISceneFacade;
import kof.message.CAbstractPackMessage;
import kof.message.Fight.FightTimeLineResponse;
import kof.message.Fight.FighterDeadResponse;
import kof.message.Map.CharacterAddResponse;
import kof.message.Map.CharacterMoveRequest;
import kof.message.Map.MapEnterResponse;
import kof.message.Map.MapLoginRequest;
import kof.message.Scene.ClientReadyRequest;
import kof.table.Town;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CDummyMapInstanceHandler extends CAbstractHandler implements IUpdatable {

    static private var MONSTER_INSTANCE_ID : int = 1;

    private var m_bInitialized : Boolean;
    private var m_bUpdateNeeded : Boolean;
    private var m_roleData : Object;
    private var m_pDatabase : IDatabase;
    private var m_pKeyboard : CKeyboard;
    private var m_pSceneFacade : ISceneFacade;
    private var m_pHero : CGameObject;

    public function CDummyMapInstanceHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();


        m_roleData = null;
        m_pDatabase = null;
        m_pSceneFacade = null;
        m_pHero = null;
    }

    override protected function onSetup() : Boolean {
        if ( !m_bInitialized ) {
            m_bInitialized = true;
            m_bUpdateNeeded = true;

            server.listen( ClientReadyRequest, onClientReady );
            server.listen( MapLoginRequest, onMapLogin );
            server.listen( CharacterMoveRequest, null );
        }

        if ( !m_pKeyboard )
            m_pKeyboard = new CKeyboard( system.stage.flashStage );

        m_pKeyboard.registerKeyCode( false, Keyboard.F6, _onFightingToggle );
        m_pKeyboard.registerKeyCode( false, Keyboard.F8, _onSpawnMonster );
        m_pKeyboard.registerKeyCode( false, Keyboard.F7, _onMaxProperties );
        m_pKeyboard.registerKeyCode( false, Keyboard.F9, _onPlayerAICompnent );

        m_pSceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;

        if ( m_pSceneFacade ) {
            m_pSceneFacade.addEventListener( CSceneEvent.HERO_CREATED, _onHeroReadyEventHandler, false, 0, true );
            m_pSceneFacade.addEventListener( CSceneEvent.HERO_REMOVED, _onHeroRemovedEventHandler, false, 0, true );
        }

        return true;
    }

    override protected function onShutdown() : Boolean {
        super.onShutdown();
        if ( m_pKeyboard ) {
            m_pKeyboard.unregisterKeyCode( false, Keyboard.F6, _onFightingToggle );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.F7, _onMaxProperties );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.F8, _onSpawnMonster );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.F9, _onPlayerAICompnent );
            m_pKeyboard.dispose();
        }

        m_pKeyboard = null;
        m_pSceneFacade = null;
        m_pHero = null;

        return true;
    }

    override protected function enterStage( stage : CAppStage ) : void {
        super.enterStage( stage );
    }

    private function _onPlayerAICompnent( code : int ) : void {
        switch ( code ) {
            case Keyboard.F9:
            {
                var pAIComponent : CAIComponent = m_pHero.getComponentByClass( CAIComponent, true ) as CAIComponent;
                if ( pAIComponent ) {
                    if ( pAIComponent.aiObj ) {
                        pAIComponent.enabled = !pAIComponent.enabled;
                        if ( pAIComponent.enabled == false ) {
                            pAIComponent.removeEventListeners();
                            pAIComponent.resetAllState();
                        }
                        else {
                            pAIComponent.addEventListeners();
                        }
                    }
                    else {
                        pAIComponent.isF9 = true;
                        pAIComponent.loaded = false;
                        pAIComponent.loading = false;
                        m_pHero.data.aiID = 4;
                    }
                }
            }
        }
    }

    private function _onMaxProperties( code : int ) : void {
        switch ( code ) {
            case Keyboard.F7:
            {
                if ( m_pHero ) {
                    var pProp : CPlayerProperty = m_pHero.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
                    if ( pProp ) {
                        pProp.HP = pProp.MaxHP;
                        pProp.AttackPower = pProp.MaxAttackPower;
                        pProp.DefensePower = pProp.MaxDefensePower;
                        pProp.RagePower = pProp.MaxRagePower;
                    }
                }
                break;
            }
            default:
                break;
        }
    }

    private function _onSpawnMonster( code : int ) : void {
        switch ( code ) {
            case Keyboard.F8:
                var pos2D : CVector2 = (m_pHero.transform as CKOFTransform).to2DAxis();
                if ( this.m_pKeyboard.isKeyPressed( Keyboard.SHIFT ) ) {
                    this.spawnRandomMonster( 1, pos2D.x, pos2D.y );
                } else {
//                    var pos2D : CVector2 = (m_pHero.transform as CKOFTransform).to2DAxis();
//                    this.spawnRandomMonster( 1, pos2D.x, pos2D.y );
//                    this.spawnMonster( 1, 12, pos2D.x, pos2D.y );
                    this.spawnMonster( 1, 4 , pos2D.x, pos2D.y );//110102102  3000101 170101105
//                    this.spawnMonster( 1, 1, pos2D.x, pos2D.y );
                }
                break;
            default:
                break;
        }
    }

    private function _onFightingToggle( code : int ) : void {
        switch ( code ) {
            case Keyboard.F6:
//                var pECS : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
//                if ( pECS ) {
//                    var pFightHandler : CFightHandler = pECS.getBean( CFightHandler ) as CFightHandler;
//                    if ( pFightHandler ) {
//                        pFightHandler.enabled = !pFiguhtHandler.enabled;
//                    }
//                }
                var pBoard : CDashBoard = system.stage.getBean( CDashBoard ) as CDashBoard;
                var pConsolePage : CConsolePage = pBoard.findPage( "ConsolePage" ) as CConsolePage;
                if ( pConsolePage ) {
                    pConsolePage.commandHandler.parseCommand( "fight_begin" );
                }
                break;
        }
    }


    final public function get server() : CDummyServer {
        return system as CDummyServer;
    }

    final public function get database() : IDatabase {
        if ( !m_pDatabase ) {
            m_pDatabase = getBean( CDummyDatabase ) as IDatabase;
            if ( m_pDatabase && !m_pDatabase.isReady )
                m_pDatabase = null;
        }

        return m_pDatabase;
    }

    [Inline]
    public final function setUpdateNeeded() : void {
        m_bUpdateNeeded = true;
    }

    public final function update( delta : Number ) : void {
        if ( !m_bInitialized )
            return;

        if ( !m_bUpdateNeeded )
            return;

        if ( m_pSceneFacade ) {
            if ( m_pHero && m_pSceneFacade.monsterIterator ) {
                var monsterList : Vector.<Object> = m_pSceneFacade.monsterIterator as Vector.<Object>;
                var monster : CGameObject;
                for each( var obj : Object in monsterList ) {
                    monster = (obj) as CGameObject;
                    if ( monster && monster.isRunning ) {
                        var pProperty : CCharacterProperty = monster.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
                        var pStateBoard : CCharacterStateBoard = monster.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                        if ( pProperty.HP == 0 && !Boolean( pStateBoard.getValue( CCharacterStateBoard.DEAD ) ) ) {
                            var deadResponse : FighterDeadResponse = new FighterDeadResponse;
                            deadResponse.ID = monster.data.id;
                            deadResponse.type = 2;
                            server.send( deadResponse );
                        }
                    }
                }
            }
        }
        try {
            // do update.

        } finally {
//            m_bUpdateNeeded = false;
        }
    }

    public final function startLogin( roleInfo : Object ) : void {
        CAssertUtils.assertNotNull( roleInfo );
        m_roleData = roleInfo;
    }

    private function onMapLogin( request : MapLoginRequest ) : void {
        // CAssertUtils.assertEquals( request.mapID, m_roleData.mapID );
        this.enterScene();
        this._onReadygoBegin();
    }

    private function onClientReady( request : CAbstractPackMessage ) : void {
        this.broadcastMapInfo();
    }

    private function enterScene() : void {
        if ( !m_roleData )
            return;
        // Find the first town by default.
        var pDatabase : IDatabase = this.database;

        var mapID : int = 2;
        if ( pDatabase ) {
            var pTown : Town = pDatabase.getTable( KOFTableConstants.TOWN ).first();
            if ( pTown )
                mapID = pTown.ID;
        }

        var mapEnterResponse : MapEnterResponse = new MapEnterResponse();
        mapEnterResponse.mapID = mapID;
        mapEnterResponse.spawnX = m_roleData.x;
        mapEnterResponse.spawnY = m_roleData.y;

        server.send( mapEnterResponse );
    }

    private function _onReadygoBegin() : void {
        var msg : FightTimeLineResponse = new FightTimeLineResponse();
        msg.currentTime = 0;
        msg.dynamicStates = {};
        this.server.send( msg );
    }

    private function broadcastMapInfo() : void {
        this.spawnHero();
        this.broadcastMapInfoList();
    }

    private function spawnHero() : void {
        var response : CharacterAddResponse = new CharacterAddResponse();
        response.data = [];

        if ( !m_roleData ) {
            m_roleData = (system.getBean( CDummyDatabase ) as CDummyDatabase).data.role;
        }

        var spawnRoleData : Object = CObjectUtils.extend( true, {}, m_roleData );
        spawnRoleData.id = m_roleData ? m_roleData.roleID : 10086;
        spawnRoleData.type = 1; // int(randomInt(1, 2));
        spawnRoleData.prototypeID = m_roleData ? m_roleData.prototypeID : 10;
         spawnRoleData.name = "[Hero]我是微软雅黑";
//        spawnRoleData.x = 5;
//        spawnRoleData.y = 14;
//        spawnRoleData.x = 21 * 50;
//        spawnRoleData.y = 18 * 50;
        spawnRoleData.fightProperty = {
            "Defense" : 619,
            "AttackPowerRecoverSpeed" : 10,
            "Attack" : 500,
            "DefensePowerRecoverCD" : 100,
            "RagePowerRecoverSpeed" : 10,
            "CritChance" : 3000,
            "DefendCritChance" : 0,
            "CritHurtChance" : 10000,
            "CritDefendChance" : 5000,
            "BlockHurtChance" : 5000,
            "RollerBlockChance" : 0,
            "HurtAddChance" : 2000,
            "RagePower" : 30000,
            "HurtReduceChance" : 1000,
            "CounterAttackChance" : 0,
            "RageRestoreWhenDamaged" : 0,
            "RageRestoreWhenKillTarget" : 0,
            "MaxRagePower" : 30000,
            "AttackPower" : 150,
            "MaxDefensePower" : 100,
            "MaxHP" : 40635,
            "DefensePower" : 100,
            "HP" : 40635,
            "MaxAttackPower" : 150
        };
//        spawnRoleData.vipLevel = 2;
//        spawnRoleData.tx = {
//            "isYellowHighVip" : 0,
//            "isYellowYearVip" : 0,
//            "isBlueVip" : 0,
//            "pf" : "qqgame",
//            "isSuperBlueVip" : 0,
//            "isYellowVip" : 0,
//            "blueVipLevel" : 2,
//            "yellowVipLevel" : 0,
//            "isBlueYearVip" : 0
//        };
//        spawnRoleData.tx = {
//            "pf" : "qqgame",//qqgame
//            "isBlueYearVip" : 1,
//            "blueVipLevel" : 2,
//            "isSuperBlueVip" : 1,
//            "isBlueVip" : 1
//        };
        spawnRoleData.tx = {
            "pf" : "qzone",//qqgame
            "isYellowVip":1,
            "yellowVipLevel":6
        };
        spawnRoleData.x = 1838;
        spawnRoleData.y = 740;
        spawnRoleData.operateSide = 1;
        spawnRoleData.operateIndex = 1;
        spawnRoleData.campID = 1;
        response.data.push( spawnRoleData );

        server.send( response );
    }

    private function spawnMonster( nCount : uint = 1, prototypeID : uint = 3, x : Number = NaN, y : Number = NaN ) : void {
        var response : CharacterAddResponse = new CharacterAddResponse();
        response.data = [];
        // Spawn a dummy player by default.
        var nSpawnCount : uint = nCount;
        for ( var i : int = 0; i < nSpawnCount; ++i ) {
            var spawnRoleData : Object = CObjectUtils.extend( true, {}, m_roleData );
            spawnRoleData.id = MONSTER_INSTANCE_ID++;
            spawnRoleData.type = 2;
            spawnRoleData.prototypeID = prototypeID;
            spawnRoleData.name = "[M] Ran" + spawnRoleData.id.toString();

            var Pos2D : CVector2 = new CVector2( x, y );
            if ( m_pHero ) {
                if ( isNaN( x ) || isNaN( y ) ) {
                    var Pos3D : CVector3 = m_pHero.transform.position;
                    Pos3D = CObject.get2DPositionFrom3D( Pos3D.x, 0, Pos3D.y );
//                    Pos2D = (m_pHero.transform as CKOFTransform).to2DAxis();
                    Pos2D.x = Pos3D.x;
                    Pos2D.y = Pos3D.y;

                    Pos2D.x += randomInt( -5, 5 ) * 50;
                    Pos2D.y += randomInt( -2, 2 ) * 50;
                }
            }

            spawnRoleData.x = Pos2D.x;
            spawnRoleData.y = Pos2D.y;

            if ( isNaN( spawnRoleData.x ) )
                spawnRoleData.x = randomInt( 5, 20 ) * 50;
            if ( isNaN( spawnRoleData.y ) )
                spawnRoleData.y = randomInt( 13, 16 ) * 50;

            spawnRoleData.operateSide = 0;
            spawnRoleData.operateIndex = 0;
            spawnRoleData.campID = 2;

            response.data.push( spawnRoleData );
        }
        server.send( response );
    }

    private function spawnRandomMonster( nCount : uint = 1, x : Number = NaN, y : Number = NaN ) : void {
        var blacklistIDs : Array = [ 0, 1 ];
        var ids : Array = [ 1, 2, 3, 4, 5 ];
        var pDB : IDatabase = system.stage.getBean( IDatabase ) as IDatabase;
        if ( pDB ) {
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.MONSTER );
            CAssertUtils.assertNotNull( pTable, "Can not find data table \"" +
                    KOFTableConstants.MONSTER + "\" in IDatabase!!!" );

            var allMonsters : Array = pTable.toArray();
            ids = allMonsters.map( function ( value : *, idx : int, arr : Array ) : int {
//                if ( arr[ idx ].HP <= 0 )
//                    return 0;
                return arr[ idx ].ID;
            } ).filter( function ( value : int, idx : int, arr : Array ) : Boolean {
                return blacklistIDs.indexOf( value ) == -1;
            } );
        }

        this.spawnMonster( nCount, int( randomValue( ids ) ), x, y );
    }

    private function broadcastMapInfoList() : void {
        // spawn 1 monster by default.
        // this.spawnRandomMonster();
//         this.spawnMonster( 1, 2 );
    }

    private function _onHeroReadyEventHandler( event : CSceneEvent ) : void {
        m_pHero = event.value;
    }

    private function _onHeroRemovedEventHandler( event : CSceneEvent ) : void {
        m_pHero = null;
    }

    static private function randomInt( from : int, to : int ) : int {
        return from + Math.round( Math.random() * (to - from) );
    }

    static private function randomValue( arr : Array ) : * {
        return arr[ randomInt( 0, arr.length - 1 ) ];
    }

}
}
