/**
 * Created by auto on 2016/8/12.
 */
package kof.game.scenario.imp {

import QFLib.Interface.IDisposable;
import QFLib.Math.CVector2;

import kof.framework.CAppSystem;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CFacadeMediator;
import kof.game.character.ai.CAIHandler;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.IInstanceFacade;
import kof.game.level.ILevelFacade;
import kof.game.scenario.CScenarioManager;
import kof.game.scenario.info.CScenarioCameraInfo;
import kof.game.scenario.scenarioInterface.IScenarioEnd;
import kof.game.scenario.scenarioInterface.IScenarioStart;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

// 非剧情对象管理
public class CScenarioGameObjectManager implements IDisposable, IScenarioStart, IScenarioEnd {
    public function CScenarioGameObjectManager(scenarioManager:CScenarioManager) {
        _scenarioManager = scenarioManager;
    }

    public function dispose():void {
        clear();
        _scenarioManager = null;
    }

    public function start():void {
        _hideMonsterList = {};
        _hideTeammatesList = {};
    }

    public function end():void {
//        resetCamera();
        showAllMonsterInSceneByHide();
//        showTeammatesInSceneByHide();
        clear();
    }
    public function clear() : void {
        resetTimeOut();
        _hideMonsterList = null;
        _hideTeammatesList = null;
    }

    public function resetTimeOut():void {
        _timeOut = 0.0;
    }

    public function hideAllMonsterInScene():void {
        var sceneSystem:CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var allMonsters:Vector.<Object> = sceneSystem.findAllMonster();
        for each (var obj:CGameObject in allMonsters) {
            if(!CCharacterDataDescriptor.isHero( obj.data )){
                (obj.getComponentByClass( IDisplay, false ) as IDisplay).modelDisplay.visible = false;
                _hideMonsterList[(obj.getComponentByClass(ICharacterProperty, false) as ICharacterProperty).ID] = obj;
            }
        }
    }

    public function hideTeammates():void{
        var sceneSystem:CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var allHero:Vector.<Object> = sceneSystem.playerIterator as Vector.<Object>;

        for each ( var obj:CGameObject in allHero ) {
            if (CCharacterDataDescriptor.isHero( obj.data ))
                continue;

            (obj.getComponentByClass( IDisplay, false ) as IDisplay).modelDisplay.visible = false;
            (obj.getComponentByClass( CCollisionComponent , false ) as CCollisionComponent).enabled = false;
            _hideTeammatesList[(obj.getComponentByClass(ICharacterProperty, false) as ICharacterProperty).ID] = obj;
        }
    }

    /**
     * 设置玩家自己显示/隐藏状态
     * @param value
     */
    public function setHeroVisible(value:Boolean):void{
        var sceneSystem:CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var allHero:Vector.<Object> = sceneSystem.playerIterator as Vector.<Object>;

        for each ( var obj:CGameObject in allHero ) {
            if (CCharacterDataDescriptor.isHero( obj.data )){
                (obj.getComponentByClass( IDisplay, false ) as IDisplay).modelDisplay.visible = value;
                (obj.getComponentByClass( CCollisionComponent , false ) as CCollisionComponent).enabled = value;
            }
        }
    }

    public function setHeroTeleport( position:CVector2, dir:int, callback:Function ):void{
        var sceneSystem:CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var allHero:Vector.<Object> = sceneSystem.playerIterator as Vector.<Object>;

        //瞬移目标点计算
        var position1:CVector2 = new CVector2();
        var position2:CVector2 = new CVector2();
        if(dir == 1){
            //朝向右
            position1.x = position.x-75;
            position1.y = position.y-50;

            position2.x = position.x-75;
            position2.y = position.y+50;
        }else{
            //朝向左
            position1.x = position.x+75;
            position1.y = position.y-50;

            position2.x = position.x+75;
            position2.y = position.y+50;
        }
        var positonArr:Array = [position,position1,position2];
        var index:int = 0;
        for each ( var obj:CGameObject in allHero ) {
            var facedeMediator:CFacadeMediator = obj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator;
            if(!facedeMediator.isDead){
                //角色没有死亡才瞬移
                var pSkillCaster : CSkillCaster = obj.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
                pSkillCaster.castTeleportToPosition( 10000 , positonArr[index], function():void{
                    // 右1， 左-1
                    if (facedeMediator){
                        facedeMediator.setDisplayDirection( dir );
                    }
                    if (callback != null) {
                        callback();
                    }
                } );

                index++;
            }
        }
    }

    public function showAllMonsterInSceneByHide():void {
        for each (var obj:CGameObject in _hideMonsterList) {
            var monster : IDisplay = obj.getComponentByClass( IDisplay, false ) as IDisplay;
            if (monster && monster.modelDisplay) {
                monster.modelDisplay.visible = true;
            }
        }
    }
    public function showTeammatesInSceneByHide( value:Boolean = true ):void {
        for each (var obj:CGameObject in _hideTeammatesList) {
            var monster : IDisplay = obj.getComponentByClass( IDisplay, false ) as IDisplay;
            if (monster && monster.modelDisplay) {
                monster.modelDisplay.visible = value;
                (obj.getComponentByClass( CCollisionComponent , false ) as CCollisionComponent).enabled = value;
            }
        }
    }

    public function resetCamera():void {
        (_system.stage.getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering).mainCamera.unZoom(true);
        var hero:CGameObject = (_system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        (_system.stage.getSystem(CSceneSystem).getBean(CSceneHandler) as CSceneHandler).followObject(hero);
    }
    public function resetBgMusic() : void {
        var levelSystem:ILevelFacade = _system.stage.getSystem(ILevelFacade) as ILevelFacade;
        if (levelSystem) {
            levelSystem.playBgMusic();
        }
    }

    public function initCamera():void{
        var obj:CScenarioCameraInfo = _scenarioManager.scenarioInfo.camera;
        if(obj && obj.height>0){
            var width:Number = 1500/900 * obj.height;
            (_system.stage.getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering).mainCamera.zoomTo(obj.x, obj.y, width*0.5, obj.height*0.5);
        }else {
            (_system.stage.getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering).mainCamera.zoomTo(obj.x, obj.y);
        }

    }

    // 所有角色的行为都完成了
    public function isAllGameObjectStop( delta:Number ) : Boolean {
        var isInMainCity : Boolean = (_system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).isMainCity;
        if(isInMainCity){
            return true;
        }
        _timeOut += delta;
        if(_timeOut > TIME_OUT){
            //如果超时5秒，返回true
            return true;
        }
        var sceneSystem:CSceneSystem = _scenarioManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var allGameObj:Array = sceneSystem.allGameObjectIterator as Array;
        for each (var obj:CGameObject in allGameObj) {
            var state:CCharacterStateMachine = obj.getComponentByClass(CCharacterStateMachine,true) as CCharacterStateMachine;
            if(state == null){
                continue;
            }
            if(state.actionFSM.current == CCharacterActionStateConstants.ATTACK || state.actionFSM.current == CCharacterActionStateConstants.HURT || state.actionFSM.current == CCharacterActionStateConstants.KNOCK_UP ){
                return false;
            }
        }


        return true;
    }

    private function get _system():CAppSystem {
        return _scenarioManager.system;
    }

    public static const TIME_OUT:Number = 5.0;//超时时间
    private var _timeOut:Number = 0.0;

    private var _hideMonsterList:Object; // 所有关卡里被隐藏的怪物
    private var _hideTeammatesList:Object; // 所有关卡里被隐藏的队友
    private var _scenarioManager:CScenarioManager;



}
}
