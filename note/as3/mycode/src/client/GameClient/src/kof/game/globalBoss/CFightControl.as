//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/4.
 * Time: 15:51
 */
package kof.game.globalBoss {

    import flash.events.Event;
    import flash.utils.setTimeout;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.game.character.CCharacterEvent;
    import kof.game.character.CEventMediator;
import kof.game.character.CSimulationPlayer;
import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAIHandler;
    import kof.game.character.animation.IAnimation;
    import kof.game.character.dynamicBlock.CDynamicBlockComponent;
    import kof.game.character.fight.CCharacterNetworkInput;
    import kof.game.character.fight.sync.CCharacterResponseQueue;
    import kof.game.character.handler.CPlayHandler;
    import kof.game.character.property.CBasePropertyData;
    import kof.game.character.property.CMonsterProperty;
    import kof.game.character.property.CMonsterPropertyCale;
import kof.game.character.property.CMonsterPropertyData;
import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.character.scripts.CRootRingSpirte;
    import kof.game.core.CECSLoop;
    import kof.game.core.CGameObject;
    import kof.game.core.CGameObject;
    import kof.game.globalBoss.Event.CWBEventType;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.instance.CInstanceSystem;
    import kof.game.instance.IInstanceFacade;
    import kof.game.instance.event.CInstanceEvent;
    import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CPlayerData;
    import kof.game.scene.CSceneEvent;
    import kof.game.scene.CSceneHandler;
    import kof.game.scene.CSceneSystem;
    import kof.table.WorldBossConstant;
    import kof.table.WorldBossProperty;
    import kof.ui.imp_common.HeroExpAddListUI;
    import kof.util.CObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/4
     */
    public class CFightControl {
        private var system : CAppSystem = null;
        private var _instanceID : Number = 0;
        private var _bCanPlay : Boolean = false;
        private var _roleData : CGameObject = null;
        private var _iRankLength : int = 0;
        private var _pRankInLevelVec : Vector.<Number> = null;
        private var _currentInstanceID : Number = 0;
        private var _pWBProperty : WorldBossProperty = null;
        private var _pWBCharacterID : Vector.<int> = new <int>[];
        private var _roleID : Number = 0;
        private var _maxRoomPlayer : int = 0;
        private var _RobotId : Number = 10; //机器人id基数，从10开始，避免和boss大蛇重复

        public function CFightControl( system : CAppSystem ) {
            this.system = system;
            _init();
        }
        //副本、关卡流程这部分看不懂问auto、dendi
        private function _init() : void {
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            _roleID = playerData.ID;
            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.EXIT_INSTANCE, _exitInstance );
            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.LEVEL_ENTER, _levelReady );
            system.stage.getSystem( CWorldBossSystem ).getBean( CWBDataManager ).addEventListener( CWBEventType.START_FIGHT, _startFight );
            system.stage.getSystem( CWorldBossSystem ).getBean( CWBDataManager ).addEventListener( CWBEventType.RESULT, _endWB );
            system.stage.getSystem( CWorldBossSystem ).getBean( CWBDataManager ).addEventListener( CWBEventType.UPDATE_WBINFO, _updateWBInfo );
            var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CONSTANT ) as CDataTable;
            var wbConstant : WorldBossConstant = wbInstanceTable.findByPrimaryKey( 1 );
            if ( wbConstant ) {
                _instanceID = wbConstant.instanceID;
                _maxRoomPlayer = wbConstant.maxRoomPlayer;
            }

            _pRankInLevelVec = new <Number>[];
        }

        private function _exitInstance( e : CInstanceEvent ) : void {
            if ( _currentInstanceID == _instanceID ) {
                _pWBCharacterID.splice( 0, _pWBCharacterID.length );
                _pRankInLevelVec.splice( 0, _pRankInLevelVec.length );
            }
        }

        private function _levelReady( e : CInstanceEvent ) : void {
            if ( _currentInstanceID == _instanceID ) {
                if ( (system.getBean( CWBDataManager ) as CWBDataManager).wbData.state == 1 ) {
                    var vec : Vector.<Object> = (system.stage.getSystem( CSceneSystem ) as CSceneSystem).findAllMonster();
                    for each ( var key : * in vec ) {
                        var property : CMonsterProperty = key.getComponentByClass( ICharacterProperty, true ) as CMonsterProperty;
                        var prototypeID : Number = property.prototypeID;
                        //克里斯
                        if ( prototypeID == 100100105 ) {
                            ( (system.stage.getSystem( CSceneSystem ) as CSceneSystem).getHandler( CSceneHandler ) as CSceneHandler ).removeMonster( property.ID )
                        }
                    }
                }
            }
        }

        private function _endWB( e : Event ) : void {
            (system.stage.getSystem( CSceneSystem ) as CSceneSystem).removeEventListener( CSceneEvent.HERO_READY, _playerGetReady );
        }

        private function _updateWBInfo( e : Event ) : void {
            if ( !_roleData )return;
            if ( !_pWBProperty )return;
            var arr : Array = (system.getBean( CWBDataManager ) as CWBDataManager).wbFightData.rankBase;
            if ( _pRankInLevelVec.length > _maxRoomPlayer - 1 || arr.length <= 1 )return;//_maxRoomPlayer-1，因为自己也在里面
            var len : int = 0;
            if ( arr.length > _maxRoomPlayer ) {
                len = _maxRoomPlayer;
            } else {
                len = arr.length;
            }
            if ( _iRankLength < arr.length ) {
                for ( var i : int = 0; i < len; i++ ) {
                    if ( _roleID == arr[ i ].roleId )continue;
                    if ( _pRankInLevelVec.indexOf( arr[ i ].roleId ) == -1 ) {
                        _pRankInLevelVec.push( arr[ i ].roleId );
                        _createCharacter( arr[ i ].heroId );
                    }
                }
            }
        }

        //开始战斗
        private function _startFight( e : Event ) : void {
            var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
            var allMonsters : Vector.<Object> = sceneSystem.findAllMonster();
            for each ( var obj : CGameObject in allMonsters ) {
                var monsterPro : CMonsterProperty = obj.getComponentByClass( ICharacterProperty, true ) as CMonsterProperty;
                var prototypeID : Number = monsterPro.prototypeID;
                //克里斯
                if ( prototypeID == 100100105 ) {
                    _playAction( obj, "Skill_7" );
                    (system.stage.getSystem( CECSLoop ).getBean( CAIHandler ) as CAIHandler).setEnable(false);//战斗开始后，因为大蛇有开场动画要播，先关AI
                }
            }
        }

        private function _enterInstance( e : CInstanceEvent ) : void {
            _currentInstanceID = Number( e.data );
            if ( _currentInstanceID == _instanceID ) {
                _bCanPlay = true;
                (system.stage.getSystem( CSceneSystem ) as CSceneSystem).addEventListener( CSceneEvent.HERO_READY, _playerGetReady );
                var bossLv : int = (system.getBean( CWBDataManager ) as CWBDataManager).wbData.level;
                var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                var wbPropertyTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_PROPERTY ) as CDataTable;
                _pWBProperty = wbPropertyTable.findByPrimaryKey( bossLv );
                (system.stage.getSystem( CECSLoop ).getBean( CAIHandler ) as CAIHandler).setEnable(false); //进入副本关闭AI

            }
        }

        private function _playerGetReady( e : CSceneEvent ) : void {
            if ( _currentInstanceID != _instanceID )return;
            var playHandler : CPlayHandler = (system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
            _roleData = playHandler.hero;
//            _createCharacter(207);
//            _createCharacter(205);
//            _createCharacter(204);
//            _createCharacter(203);
            if ( !_roleData )return;
        }

        //创建假人
        private function _createCharacter( heroID : Number ) : void {
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var pInstanceSystem : IInstanceFacade = this.system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
            var monsterProperty : CMonsterPropertyCale = new CMonsterPropertyCale();
            var propertyData : CBasePropertyData = monsterProperty.getMonsterPropertyByTemplateID( pDatabaseSystem, _pWBProperty.robottemplateID, pInstanceSystem );
            var data : Object = spawnHero( propertyData, _pRankInLevelVec.length, heroID );
            var gameObj : CGameObject = ((system.stage.getSystem( CSceneSystem ) as CSceneSystem).getHandler( CSceneHandler ) as CSceneHandler).addPlayer( data );
            var network : CCharacterNetworkInput = gameObj.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
            gameObj.addComponent( new CSimulationPlayer() );
            gameObj.removeComponent( network, true );
            var responseQueue : CCharacterResponseQueue = gameObj.getComponentByClass( CCharacterResponseQueue, true ) as CCharacterResponseQueue;
            gameObj.removeComponent( responseQueue, true );
            var rootSprite : CRootRingSpirte = gameObj.getComponentByClass( CRootRingSpirte, true ) as CRootRingSpirte;
            gameObj.removeComponent( rootSprite, true );
        }

        private function _playAction( owner : Object, actName : String ) : void {
            var dynamicBlock : CDynamicBlockComponent = owner.getComponentByClass( CDynamicBlockComponent, true ) as CDynamicBlockComponent;
            var iAnimation : IAnimation = dynamicBlock.getComponent( IAnimation ) as IAnimation;
            iAnimation.addSkillAnimationState( actName.toUpperCase(), actName );
            iAnimation.playAnimation( actName.toUpperCase(), false, false );
            (owner.getComponentByClass( CEventMediator, false ) as CEventMediator).addEventListener( CCharacterEvent.ANIMATION_TIME_END, removeSelf );
        }

        private function removeSelf( e : CCharacterEvent ) : void {
            var id : Number = (e.character.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).ID;
            ((system.stage.getSystem( CSceneSystem ) as CSceneSystem).getHandler( CSceneHandler ) as CSceneHandler).removeMonster( id );
            (system.stage.getSystem( CECSLoop ).getBean( CAIHandler ) as CAIHandler).setEnable(true);//因为大蛇有开场动画播完，开启AI
        }
        //人物属性创建这部分看不懂问vincent
        private function spawnHero( thePropertyData : CBasePropertyData, index : int, heroID : Number ) : Object {
            var propertyData : CMonsterPropertyData = thePropertyData as CMonsterPropertyData;
            var spawnRoleData : Object = CObjectUtils.extend( true, {}, _roleData );
            var vec : Vector.<Object> = (system.stage.getSystem( CSceneSystem ) as CSceneSystem).findAllPlayer();
            for each( var key : Object in vec ) {
                _pWBCharacterID.push( key.data.id );
            }
            while ( _pWBCharacterID.indexOf( index + _RobotId ) != -1) {
                index++;
            }
            spawnRoleData.id = index + _RobotId;
            spawnRoleData.type = 1;
            spawnRoleData.prototypeID = heroID;  //_roleData ? property.prototypeID : 10;
            spawnRoleData.fightProperty = {
                "Defense" : propertyData.Defense,
                "AttackPowerRecoverSpeed" : propertyData.attackPowerRecoverSpeed,
                "Attack" : propertyData.Attack,
                "DefensePowerRecoverCD" : propertyData.defensePowerRecoverCD,
                "RagePowerRecoverSpeed" : propertyData.rageRestoreSpeed,
                "CritChance" : propertyData.iCritRate,
                "DefendCritChance" : propertyData.iCritDefendRate,
                "CritHurtChance" : propertyData.iCritDamageRate,
                "CritDefendChance" : propertyData.iCritDamageDefendRate,
                "BlockHurtChance" : propertyData.iDamageBlockRate,
                "RollerBlockChance" : propertyData.iRollerBlockRate,
                "HurtAddChance" : propertyData.iDamageHardRate,
                "RagePower" : propertyData.ragePowerInit,
                "HurtReduceChance" : propertyData.iDamageReduceRate,
                "CounterAttackChance" : propertyData.CounterAttackChance,
                "RageRestoreWhenDamaged" : propertyData.rageRestoreWhenDamaged,
                "RageRestoreWhenKillTarget" : propertyData.rageRestoreWhenKillTarget,
                "MaxRagePower" : 30000,
                "AttackPower" : propertyData.iAttackPower,
                "MaxDefensePower" : propertyData.Defense,
                "MaxHP" : propertyData.HP,
                "DefensePower" : propertyData.Defense,
                "HP" : propertyData.HP,
                "MaxAttackPower" : propertyData.Attack
            };
            spawnRoleData.moveSpeed = 600;
            spawnRoleData.x = _roleData.data.x + Math.random() * 400 - 200;//_roleData.transform.x;
            spawnRoleData.y = _roleData.data.y + Math.random() * (-50);//_roleData.transform.z;
            spawnRoleData.operateSide = 2;
            spawnRoleData.operateIndex = index + 1;
            spawnRoleData.campID = 1;
            spawnRoleData.aiID = _pWBProperty.AI;
            return spawnRoleData;
        }
    }
}