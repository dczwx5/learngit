//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/5/17.
 */
package kof.game.level {

import QFLib.Interface.IUpdatable;

import flash.events.Event;
import flash.geom.Rectangle;

import kof.BIND_SYSTEM_ID;
import kof.SYSTEM_ID;
import kof.data.CPreloadData;
import kof.framework.fsm.CFiniteStateMachine;
import kof.game.KOFSysTags;
import kof.game.bubbles.IBubblesFacade;
import kof.game.character.CCharacterEvent;
import kof.game.character.CFacadeMediator;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.common.system.CAppSystemImp;
import kof.game.core.CGameObject;
import kof.game.instance.enum.EInstanceType;
import kof.game.level.bubbles.CBubblesHandler;
import kof.game.level.event.CLevelEvent;
import kof.game.level.teaching.CTeachingHandler;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkEntityMonster;
import kof.game.result.CGameResultViewHandler;
import kof.game.scene.CSceneSystem;
import kof.message.Level.EnterLevelResponse;
import kof.table.InstanceType;
import kof.table.Level;
import kof.table.Monster.EMonsterDieCameraWay;
import kof.util.CAssertUtils;

public class CLevelSystem extends CAppSystemImp implements IUpdatable, ILevelFacade {

    public function CLevelSystem() {
    }

    public override function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.LEVEL );
    }

    public override function dispose() : void {
        super.dispose();

        this.removeEventListener( CLevelEvent.INSTANCE_EXIT, _onInstanceExit );

        _netHandler.dispose();
        _levelManager.dispose();
        _levelUI.dispose();

        _netHandler = this.getBean( CLevelHandler );
        _levelManager = this.getBean( CLevelManager );
        _levelUI = this.getBean( CLevelUIHandler );
        if ( _netHandler ) {
            this.removeBean( _netHandler );
        }
        if ( _levelManager ) {
            this.removeBean( _levelManager );
        }
        if ( _levelUI ) {
            this.removeBean( _levelUI );
        }

        _netHandler = null;
        _levelManager = null;
        _levelUI = null;
        _campRefHandler = null;
        _bubblesHandler = null;
        _levelPortal = null;
        _levelTeaching = null;
    }

    // ====================================================================
    override public function initialize() : Boolean {
        BIND_SYSTEM_ID( KOFSysTags.LEVEL, -7 );
        var ret : Boolean = super.initialize();
        if ( ret ) {
            ret = ret && this.addBean( _netHandler = new CLevelHandler() );
            ret = ret && this.addBean( _levelManager = new CLevelManager() );
            ret = ret && this.addBean( _levelUI = new CLevelUIHandler() );
            ret = ret && this.addBean( _campRefHandler = new CLevelCampHandler() );
            ret = ret && this.addBean( _bubblesHandler = new CBubblesHandler() );
            ret = ret && this.addBean( _levelPortal = new CLevelPortalHandler() );
            ret = ret && this.addBean( _levelTeaching = new CTeachingHandler() );
            ret = ret && this.addBean( new CLevelTruckTargetHandler() );

            this.addEventListener( CLevelEvent.INSTANCE_EXIT, _onInstanceExit );

            this.registerEventType( CLevelEvent.ENTER );
            this.registerEventType( CLevelEvent.ENTERED );
            this.registerEventType( CLevelEvent.SCENARIO_START );
            this.registerEventType( CLevelEvent.SCENARIO_END );
            this.registerEventType( CLevelEvent.EXIT );
            this.registerEventType( CLevelEvent.READY_GO );
            this.registerEventType( CLevelEvent.START );
            this.registerEventType( CLevelEvent.PLAYER_READY );
            this.registerEventType( CLevelEvent.EACHGAME_END );
            this.registerEventType( CLevelEvent.WINACTOR_END );
            this.registerEventType( CLevelEvent.WINACTOR_START );

            this.registerEventType( CLevelEvent.ROLE_DIE );
            this.registerEventType( CLevelEvent.ACTIVE_TRUNK );
            this.registerEventType( CLevelEvent.ENTER_TRUNK );
        }
        return ret;
    }

    public function update( delta : Number ) : void {
        if ( _levelManager ) {
            _levelManager.update( delta );
        }

        if ( _netHandler && _levelManager.isReady ) {
            _netHandler.update( delta );
        }
        if ( _bubblesHandler ) {
            _bubblesHandler.update( delta );
        }
    }

    [Inline]
    final public function get currentLevel() : Level {
        if ( _levelManager ) {
            return _levelManager.levelRecord;
        }
        return null;
    }

    public function onLevelStarted() : void {
        _levelManager.isStart = true;
    }

    private function _onInstanceExit( e : CLevelEvent ) : void {
        _levelManager.exitInstance();
    }

    // ============================interface========================================
    [Inline]
    public function get manager() : CLevelManager {
        return _levelManager;
    }
    public function isPlayingScenario() : Boolean {
        return _levelManager.isPlayingScenario;
    }

    public function getBubblesFacade() : IBubblesFacade {
        return _bubblesHandler;
    }

    // instance control
    public function onEnter( levelIndex : int, instanceType : int, response : EnterLevelResponse, instanceTypeTable : InstanceType,
                             isFinalLevel:Boolean, preloadListData:Vector.<CPreloadData> ) : void {
        _levelManager.onEnter( levelIndex, instanceType, response, instanceTypeTable, isFinalLevel, preloadListData );

        this.addEventListener( CCharacterEvent.DIE, _onCharacterDie );
    }

    public function onExit( levelIndex : int ) : void {
        _levelManager.onExit( levelIndex );

        this.removeEventListener( CCharacterEvent.DIE, _onCharacterDie );
    }

    public function pause() : void {
        _levelManager.pauseLevel();
    }

    public function play() : void {
        _levelManager.continueLevel();
    }

    public function playBgMusic() : void {
        _levelManager.playBgMusic();
    }

    public function isInstancePass() : Boolean {
        return _levelManager.isInstancePass;
    }

    // 关卡是否已经完成开始
    public function get isStart() : Boolean {
        return _levelManager.isStart;
    }

    // ===================================================================

    public function findCampRefValue( myCampID : int, targetCampID : int ) : int {
        var iCampCategory : int = _levelManager.camprelationship; // _levelManager.instanceType;
        return _campRefHandler.findCampRefValue( iCampCategory, myCampID, targetCampID );
    }

    public function isAttackable( myCampID : int, targetCampID : int ) : Boolean {
        var iCampCategory : int = 0;
        if ( false == EInstanceType.isMainCity( _levelManager.instanceType ) ) {
            iCampCategory = _levelManager.camprelationship; // _levelManager.instanceType;
            return _campRefHandler.isAttackable( iCampCategory, myCampID, targetCampID );
        }
        return true;
    }

    public function isFriendly( myCampID : int, targetCampID : int ) : Boolean {
        var iCampCategory : int = 0;
        if ( false == EInstanceType.isMainCity( _levelManager.instanceType ) ) {
            iCampCategory = _levelManager.camprelationship;
            return _campRefHandler.isFriendly( iCampCategory, myCampID, targetCampID );
        }
        return true;
    }

    public function getSingPoins( id : int ) : Object {
        return _levelManager.getSigenPoins( id );
    }

    public function getAppearData( entityID : int ) : Object {
        var ret : Object = {};

        var monster : CTrunkEntityMonster = _levelManager.getEntityById( entityID ) as CTrunkEntityMonster;
        if ( monster ) {
            var appearType : int = monster.appearType;
            ret[ "fallHeight" ] = monster.fallHeight;
            ret[ "playSkill" ] = monster.playSkill;
            ret[ "fallEffect" ] = monster.fallEffect;
            ret[ "shakeWhenFall" ] = monster.shakeWhenFall;
            ret[ "playAction" ] = monster.playAction;
            ret[ "isPlayAction" ] = monster.isPlayAction;
            ret[ "appearType" ] = appearType;
            ret[ "pos" ] = monster.appear;
            ret[ "ori" ] = monster.ori;
            ret[ "loop" ] = monster.loop;
            ret[ "loopTime" ] = monster.loopTime;
            ret[ "moveToAvailablePosition" ] = monster.moveToAvailablePosition;
        }
        return ret;
    }

    public function getHerotAppearData( entityID : int ) : Object {
        var ret : Object = {};

        var monster : CTrunkEntityMonster = _levelManager.getEntranceById( entityID ) as CTrunkEntityMonster;
        if ( monster ) {
            var appearType : int = monster.appearType;
            ret[ "fallHeight" ] = monster.fallHeight;
            ret[ "playSkill" ] = monster.playSkill;
            ret[ "fallEffect" ] = monster.fallEffect;
            ret[ "shakeWhenFall" ] = monster.shakeWhenFall;
            ret[ "playAction" ] = monster.playAction;
            ret[ "isPlayAction" ] = monster.isPlayAction;
            ret[ "appearType" ] = appearType;
            ret[ "pos" ] = monster.appear;
            ret[ "ori" ] = monster.ori;
            ret[ "loop" ] = monster.loop;
            ret[ "loopTime" ] = monster.loopTime;
        }
        return ret;
    }

    final private function _onCharacterDie( e : Event ) : void {
        var pCharacterEvent : CCharacterEvent = e as CCharacterEvent;
        var pCharacter : CGameObject = pCharacterEvent.character;
        CAssertUtils.assertNotNull( pCharacter );
        this.sendEvent( new CLevelEvent( CLevelEvent.ROLE_DIE, pCharacter ) );


        var pFacadeMediator : CFacadeMediator = pCharacter.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        if ( pFacadeMediator && pFacadeMediator.isMonster ) {
            var pMonsterProperty : CMonsterProperty = pFacadeMediator.getComponent( CMonsterProperty ) as CMonsterProperty;
            if ( pMonsterProperty.dieCameraEffect.indexOf( EMonsterDieCameraWay.SHOW_KO ) != -1 ) {
                // 需要KO显示
                playKO();
            }
        }
    }

    public function get isPlayingKO() : Boolean {
        var pKOViewHandler : CGameResultViewHandler = (this.getBean( CLevelUIHandler ) as CLevelUIHandler).getBean( CGameResultViewHandler ) as CGameResultViewHandler;
        return pKOViewHandler.isPlaying;
    }
    public function playKO() : void {
        var pKOViewHandler : CGameResultViewHandler = (this.getBean( CLevelUIHandler ) as CLevelUIHandler).getBean( CGameResultViewHandler ) as CGameResultViewHandler;
        if ( pKOViewHandler ) {
            pKOViewHandler.addDisplay( 3.0 );
        }
    }

    public function startPortal(portalWay:int) : void {
        (getBean(CLevelPortalHandler) as CLevelPortalHandler).startPortal(portalWay);

    }

    public function getCurReallyTrunkRect() : Rectangle {
        return _levelManager.getCurReallyTrunkRect();
    }

    public function getCurTrunkRec() : Rectangle {
        if ( _levelManager.curTrunkData ) {
            return _levelManager.curTrunkData.getTrunkRect();
        }
        return null;
    }

    public function getNpcByID( id : int ) : Object {
        if ( _levelManager.levelConfigInfo ) {
            return _levelManager.levelConfigInfo.getNpcById( id );
        }
        else {
            return null;
        }
    }

    public function showSceneClickFX( x : Number, y : Number, z : Number ) : void {
        _levelManager._levelEffect.addClickEffect( x, y, z );
//        _levelManager._levelEffect.hideClickEffect();
    }

    public function hideSceneClickFX() : void {
        _levelManager._levelEffect.hideClickEffect();
    }

    public function getAIPosition( entityID : int ) : Array {
        var monster : CTrunkEntityMonster = _levelManager.getEntityById( entityID ) as CTrunkEntityMonster;
        if ( monster )
            return monster.aiPosition;
        return [];
    }

    public function getWarnRange( entityID : int ) : Object {
        var monster : CTrunkEntityMonster = _levelManager.getEntityById( entityID ) as CTrunkEntityMonster;
        return monster ? monster.warnRange : null;
    }

    public function getTriggerRange( entityID : int ) : Object {
        var monster : CTrunkEntityBaseData = _levelManager.getTriggerById( entityID ) as CTrunkEntityBaseData;
        return monster;
    }

    public function getTrunkGoals() : Object {
        if ( _levelManager.curTrunkData ) {
            return _levelManager.curTrunkData.goals;
        }
        return null;
    }

    public function getPortal():Array{
        if (  _levelManager.levelConfigInfo ) {
            return _levelManager.levelConfigInfo.portal;
        }
        return null;
    }

    // 所有角色的行为都完成了
    public function isAllGameObjectStop() : Boolean {
        var sceneSystem : CSceneSystem = stage.getSystem( CSceneSystem ) as CSceneSystem;
        var allGameObj : Array = sceneSystem.allGameObjectIterator as Array;
        for each ( var obj : CGameObject in allGameObj ) {
            var state : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
            if ( state == null ) {
                continue;
            }
            var pActionFSM:CFiniteStateMachine = state.actionFSM;
            if (pActionFSM) {
                if ( pActionFSM.current == CCharacterActionStateConstants.ATTACK || pActionFSM.current == CCharacterActionStateConstants.HURT || pActionFSM.current == CCharacterActionStateConstants.KNOCK_UP ) {
                    return false;
                }
            }

        }
        return true;
    }

    public function getHideFootEffect( entityID : int ) : Boolean {
        var pEntity : CTrunkEntityMonster;
        pEntity = _levelManager.getEntityById( entityID );
        if ( pEntity )
            return pEntity.hideFootEffect;
        return false;
    }

    public function showMasterComingCommon(closeCallback:Function) : void {
        _levelUI.showMasterComingCommon(closeCallback);
    }

    public function get curTrunkID() : int {
        if ( _levelManager.curTrunkData ) {
            return _levelManager.curTrunkData.ID;
        }
        return 0;
    }

    public function setPlayEnable(v:Boolean) : void {
        if (_playEnableHandler != null) {
            _playEnableHandler(v);
        }
    }
    public function setAIEnable(v:Boolean) : void {
        if (_aiEnableHandler != null) {
            _aiEnableHandler(v);
        }
    }

    public function setSkillViewEnable( v: Boolean) : void{
        if( _skillViewHandler != null )
                _skillViewHandler(v);
    }

    public function set playEnableHandler(v:Function) : void {
        _playEnableHandler = v;
    }
    public function set aiEnableHandler(v:Function) : void {
        _aiEnableHandler = v;
    }

    public function set skillViewHandler( v : Function ) : void{
        _skillViewHandler = v;
    }
    public function get netHandler() : CLevelHandler {
        return _netHandler;
    }

    private var _playEnableHandler:Function;
    private var _aiEnableHandler:Function;
    private var _skillViewHandler : Function;

    private var _netHandler : CLevelHandler;
    private var _levelManager : CLevelManager;
    private var _levelUI : CLevelUIHandler;
    private var _campRefHandler : CLevelCampHandler;
    private var _bubblesHandler : CBubblesHandler;
    private var _levelPortal : CLevelPortalHandler;
    private var _levelTeaching : CTeachingHandler;
}
}