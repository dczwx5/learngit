//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/8.
 */
package kof.game.scenario.imp {

import QFLib.Foundation;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFX;
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Graphics.Scene.CCamera;
import QFLib.Graphics.Sprite.CSprite;
import QFLib.Interface.IDisposable;

import kof.framework.CAppStage;

import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.character.CCharacterEvent;
import kof.game.character.CCharacterInitializer;
import kof.game.character.CEventMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.CNetworkMessageMediator;
import kof.game.character.ai.CAIComponent;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.sync.CCharacterResponseQueue;
import kof.game.character.fight.sync.CCharacterSyncBoard;

import kof.game.character.handler.CPlayHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.character.level.CScenarioComponent;
import kof.game.character.movement.CMovement;
import kof.game.character.scripts.CFightFloatSprite;
import kof.game.character.scripts.CMonsterAppear;
import kof.game.character.scripts.CRootRingSpirte;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.CECSLoop;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.CScenarioManager;
import kof.game.scenario.CScenarioSystem;
import kof.game.scenario.CScenarioViewHandler;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.info.CScenarioActorInfo;
import kof.game.scenario.scenarioInterface.IScenarioEnd;
import kof.game.scenario.scenarioInterface.IScenarioStart;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

public class CScenarioActorManager  implements IDisposable, IScenarioStart, IScenarioEnd {
    public function CScenarioActorManager(scenarioManager:CScenarioManager) {
        _scenarioManager = scenarioManager;
    }
    public function dispose():void {
        clear();
        _scenarioManager = null;
    }
    public function clear() : void {
        for (var key:String in _actorList) {
            _removeActor(int(key));
        }

        if(_hero){
//            _hero.getComponentByClass( CSimulateSkillCaster, false).enabled = false;
//            _hero.removeComponent( _hero.getComponentByClass(CSimulateSkillCaster, false), true);
            _hero.removeComponent(_hero.getComponentByClass(CScenarioComponent, false), true);

            (_hero.getComponentByClass( IDisplay, false ) as IDisplay).modelDisplay.visible = true;

        }
        _actorList = null;
        _actorInfoList = null;
        _gameObjectList = null;
        _sceneObjectList = null;
        _gameObjectNum = 0;
        _hero = null;
    }
    public function end():void {
        clear();
    }
    public function start():void {
        _actorList = new Object();
        _actorInfoList = new Object();
        _gameObjectList = [];
        _sceneObjectList = [];
        var actorList:Array = _scenarioManager.scenarioInfo.actorList;
        var actorObj:Object = null;
        if (actorList && actorList.length > 0) {
            for each (var actorInfo:CScenarioActorInfo in actorList) {
                actorObj = _createActor(actorInfo);
                _actorList[actorInfo.actorID] = actorObj;
                if( actorObj is CGameObject){
                    _gameObjectList.push(actorObj);
                }else if( actorObj is CObject){
                    _sceneObjectList.push(actorObj);
                }
                _actorInfoList[actorInfo.actorID] = actorInfo;
            }
        }

        _gameObjectNum = 0;
        if(_gameObjectList.length > 0){
            var pEventMediator:CEventMediator = null;
            for each(var actor:CGameObject in _gameObjectList){
                pEventMediator = actor.getComponentByClass( CEventMediator, true ) as CEventMediator;
                if ( pEventMediator ) {
                    pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY,function( e:CCharacterEvent ):void{
                        _gameObjectNum++;
                    } );
                }
            }
        }
    }

    public function allActorComplete():Boolean
    {
        if(_gameObjectList == null)return true;
        if( _gameObjectNum >= _gameObjectList.length){
//            Foundation.Log.logMsg( "剧情角色加载完成..." );
            return true;
        }
        return false;
    }

    public function allSceneObjectComplete():Boolean
    {
        if(_sceneObjectList && _sceneObjectList.length > 0){
            for each(var sceneObject:CObject in _sceneObjectList){
                if(sceneObject is CFX){
                    if(!(sceneObject as CFX).isLoaded){
                        return false;
                    }else if(sceneObject is CCharacter){
                        if(!(sceneObject as CCharacter).characterObject.isLoaded){
                            return false;
                        }
                    }
                }
            }
        }
//        Foundation.Log.logMsg( "剧情场景动画以及特效资源加载完成..." );
        return true;
    }

    public function getActor(actorID:int) : Object {
        if(_actorList == null)return null;
        var obj:Object = _actorList[actorID];
        if (obj == null) {
            var actorInfo:CScenarioActorInfo = getActorInfo(actorID);
            if (actorInfo && actorInfo.actorType == EScenarioActorType.PLAYER) {
                obj = _actorList[actorID] = _hero;
            }
        }

        return obj;
    }
    public function getActorInfo(actorID:int) : CScenarioActorInfo {
        return _actorInfoList[actorID];
    }
    private function _onHeroReady(e:CSceneEvent) : void {
        _sceneSystem.removeEventListener(CSceneEvent.HERO_READY, _onHeroReady);
        _hero = e.value;
        if(_hero){
//            _hero.addComponent( new CSimulateSkillCaster() );
            _hero.addComponent(new CScenarioComponent());

        }
    }

    // ====================================================================================
    private function _createActor(actorInfo:CScenarioActorInfo) : Object {
        if (actorInfo.actorType == EScenarioActorType.PLAYER) {
            _hero = _createHero();
            if (!_hero) {
                _sceneSystem.addEventListener(CSceneEvent.HERO_READY, _onHeroReady);
            }
            return null;
        } else if (actorInfo.actorType == EScenarioActorType.MONSTER) {
            return _createMonster(actorInfo);
        } else if (actorInfo.actorType == EScenarioActorType.CAMERA) {
            return _createCamera();
        } else if (actorInfo.actorType == EScenarioActorType.AUDIO) {
            return _createAudio();
        } else if (actorInfo.actorType == EScenarioActorType.DIALOG) {
            return _createDialog();
        } else if (actorInfo.actorType == EScenarioActorType.EFFECT || actorInfo.actorType == EScenarioActorType.SCENE_ANIMATION) {
            return _createSceneAnimation(actorInfo);
        }else if (actorInfo.actorType == EScenarioActorType.CG_ANIMATION) {
            return _createCGAnimation();
        }
        return null;
    }
    private function _removeActor(actorID:int) : void {
        var actorInfo:CScenarioActorInfo = _actorInfoList[actorID];
        var actor:Object = _actorList[actorID];
        if (actorInfo.actorType == EScenarioActorType.MONSTER) {
            _removeMonster(actor as CGameObject);
        } else if (actorInfo.actorType == EScenarioActorType.PLAYER) {
            _removeHero(actor as CGameObject);
        } else if (actorInfo.actorType == EScenarioActorType.CAMERA) {
            _removeCamera();
        } else if (actorInfo.actorType == EScenarioActorType.AUDIO) {
            _removeAudio();
        } else if (actorInfo.actorType == EScenarioActorType.DIALOG) {
            _removeDialog();
        } else if (actorInfo.actorType == EScenarioActorType.EFFECT || actorInfo.actorType == EScenarioActorType.SCENE_ANIMATION) {
            _removeSceneAnimation(actor as CObject);
        } else if (actorInfo.actorType == EScenarioActorType.CG_ANIMATION) {
            _removeCGAnimation(actor as CScenarioActorCG);
        }
    }
    private function _createHero() : CGameObject {
        var pHero : CGameObject = (_stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        if( !pHero )return null;
        if (pHero && pHero.isRunning == false) {
            return null;
        }
//        pHero.addComponent( new CSimulateSkillCaster() );
        pHero.addComponent(new CScenarioComponent());
        return pHero;
    }
    private function _createMonster(actorInfo:CScenarioActorInfo) : CGameObject {
        var monsterID:Number = Number(actorInfo.target);
        var actorID:Number = actorInfo.actorID;//110103106  110103107
        var actorType:int = actorInfo.actorType;
        var spawnRoleData : Object = new Object();
        spawnRoleData.id = actorID;
        spawnRoleData.type = actorType;
        spawnRoleData.prototypeID = monsterID;
        spawnRoleData.name = "[NPC] DaMEN";
        spawnRoleData.x = actorInfo.x;
        spawnRoleData.y = actorInfo.y;
        if(actorInfo.campID != 0){
            spawnRoleData.campID = actorInfo.campID;
        }
        var sceneSystem:CSceneSystem = _sceneSystem;
        var monster:CGameObject = (sceneSystem.getBean(CSceneHandler) as CSceneHandler).createCharacter(spawnRoleData);
        //monster.removeComponent(monster.getComponentByClass(CCharacterInput, false), true);
        monster.removeComponent(monster.getComponentByClass(CAIComponent, false), true);
        monster.removeComponent(monster.getComponentByClass(CNetworkMessageMediator, false), true);
        monster.removeComponent(monster.getComponentByClass(CCharacterSyncBoard , false) , true );

        var pLevelMediator : CLevelMediator = monster.getComponentByClass(CLevelMediator , true ) as CLevelMediator;
        var bShowFloatSprite : Boolean;
        if( pLevelMediator ) {
            bShowFloatSprite = pLevelMediator.isPlelude;
        }
        if( !bShowFloatSprite )
            monster.removeComponent(monster.getComponentByClass(CFightFloatSprite, false), true);
        monster.removeComponent(monster.getComponentByClass(CCharacterResponseQueue, false), true);
        monster.removeComponent(monster.getComponentByClass(CCharacterNetworkInput, false), true);
        monster.removeComponent(monster.getComponentByClass(CMonsterAppear, false), true);
        monster.removeComponent(monster.getComponentByClass(CRootRingSpirte , false ) , true );


        monster.addComponent(new CScenarioComponent());
        (_system.stage.getSystem(CECSLoop) as CECSLoop).addObject(monster);
        sceneSystem.scenegraph.addDisplayObject(CCharacterDisplay(monster.getComponentByClass(CCharacterDisplay, true)).modelDisplay);
        (monster.getComponentByClass(CCharacterDisplay, false) as CCharacterDisplay).modelDisplay.visible = false;
//        (monster.getComponentByClass(IDisplay,false) as IDisplay).modelDisplay.castShadow = false;//隐藏影子

//        var pStateBoard : CCharacterStateBoard = monster.getComponentByClass(
//                        CCharacterStateBoard, true ) as CCharacterStateBoard;
//        if ( pStateBoard ) {
//            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false );
//            pStateBoard.setValue( CCharacterStateBoard.CAN_BE_CATCH, false );
//        }


        //剧情里面的角色无视阻挡
        ((monster.getComponentByClass(CMovement,false)) as CMovement).collisionEnabled = false;
//        ((monster.getComponentByClass(CCharacterInitializer,false)) as CCharacterInitializer).moveToAvailablePosition = true;
        ((monster.getComponentByClass(CKOFTransform,false)) as CKOFTransform).from2DAxis(actorInfo.x,actorInfo.y,0);
        return monster;
    }
    private function _createCamera() : CCamera {
        return _sceneSystem.scenegraph.scene.mainCamera;
    }
    private function _createAudio() : IAudio {
        return (_stage.getSystem(IAudio) as IAudio)
    }
    private function _createDialog() : CScenarioViewHandler {
        return (_stage.getSystem(CScenarioSystem) as CScenarioSystem).getBean(CScenarioViewHandler);
    }
    private function _createSceneAnimation(actorInfo:CScenarioActorInfo) : CObject {
        var scene:CScene = (_sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
        var object:CObject = scene.findStaticObject(actorInfo.target as String);
        if (!object) CLevelLog.addDebugLog("[CScenarioActorManager] can not find static Object in scene...animName : " + actorInfo.target as String , true);
        return object;
    }
    private function _createCGAnimation():CScenarioActorCG{
        return new CScenarioActorCG;
    }
    // ==========
    private function _removeCGAnimation(actor:CScenarioActorCG):void{
        actor.dispose();
    }

    private function _removeHero(actor:CGameObject) : void {
        ; // nothing
    }
    private function _removeMonster(actor:CGameObject) : void {
        var gameSystem:CECSLoop = (_system.stage.getSystem(CECSLoop) as CECSLoop);
        var sceneSystem:CSceneSystem = (_system.stage.getSystem(CSceneSystem) as CSceneSystem);
        var sceneHandler:CSceneHandler =  (sceneSystem.getBean(CSceneHandler) as CSceneHandler);
        gameSystem.removeObject(actor);
        sceneHandler.disposeCharacter(actor);
    }
    private function _removeCamera() : void {
        // nothing
    }
    private function _removeAudio() : void {
        // nothing
    }
    private function _removeDialog() : void {
        // nothing
    }
    private function _removeSceneAnimation(obj:CObject) : void {
        // nothing
    }
    // ====================================================================================

    final private function get _system() : CAppSystem {
        return _scenarioManager.system;
    }
    final private function get _stage() : CAppStage {
        return _system.stage;
    }
    final private function get _sceneSystem() : CSceneSystem {
        return _stage.getSystem(CSceneSystem) as CSceneSystem;
    }

    private var _actorList:Object;
    private var _actorInfoList:Object;
    private var _scenarioManager:CScenarioManager;
    private var _hero:CGameObject;

    private var _gameObjectList:Array = new Array();
    private var _sceneObjectList:Array = new Array();
    private var _gameObjectNum:int = 0;
}
}
