//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/1/16.
 */
package kof.game.gm.controller {

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.IConsoleCommand;
import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CFacadeMediator;
import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIEvent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.collision.CCollisionHandler;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.ESkillSkipType;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.common.view.control.CControlBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.gm.CGmSystem;
import kof.game.gm.CGmUIHandler;
import kof.game.gm.data.CGmData;
import kof.game.gm.event.EGmEventType;
import kof.game.gm.view.gmView.CGmView;
import kof.game.instance.CInstanceSystem;
import kof.game.gm.command.instance.CAddCharacterCommand;
import kof.game.gm.command.instance.CEnterInstanceCommand;
import kof.game.gm.command.instance.CKillCharacterCommand;
import kof.game.gm.command.instance.CModifyCharacterPropertyCommand;
import kof.game.gm.command.instance.CPassAllInstanceCommand;
import kof.game.gm.command.instance.CPassInstanceCommand;
import kof.game.gm.command.instance.CPassLevelCommand;
import kof.game.gm.command.instance.CRemoveAllDiffCampCommand;
import kof.game.scene.CSceneSystem;

public class CGmController extends CControlBase {
    public function CGmController() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    private function _onUIEvent(e:CViewEvent) : void {
        var uiEvent:String = e.subEvent;
        var cmd : IConsoleCommand;
        var aiHandler:CAIHandler;
        var heroID:int;
        var heroList:Array;
        var pCollisionSystem:CCollisionHandler;
        var aiComponent:CAIComponent;
        switch (uiEvent) {
            case EGmEventType.EVENT_MENU_CMD :
                var cmdName:String = e.data[0] as String;
                var cmdParams:String = e.data[1] as String;
                _parseCommand(cmdName + " " + cmdParams);
                break;

            case EGmEventType.EVENT_SELECT_PANEL :
                var panelID : int = e.data as int;
                _gmView.selectPanel(panelID);
                break;

            // =====================================level=======================================

            case EGmEventType.EVENT_LEVEL_ENTER_INSTANCE :
                var instanceContentID : int = e.data as int;
                if (instanceContentID > 0) {
                    cmd = _findCommand(CEnterInstanceCommand);
                    _parseCommand(cmd.name + " " + instanceContentID);
                }
                break;
            case EGmEventType.EVENT_LEVEL_NEXT_LEVEL :
                cmd = _findCommand(CPassLevelCommand);
                _parseCommand(cmd.name);
                break;
            case EGmEventType.EVENT_LEVEL_PASS_INSTANCE :
                cmd = _findCommand(CPassInstanceCommand);
                _parseCommand(cmd.name);
                break;

            case EGmEventType.ENVENT_LEVEL_OPEN_ALL_CHAPTER :
                cmd = _findCommand(CPassAllInstanceCommand);
                _parseCommand(cmd.name);

                //    _instanceSystem.instanceManager.dataManager.instanceData.openAllChapter();
                break;

            // =====================================base=======================================

            case EGmEventType.EVENT_BASE_CALL_HERO :
                heroID = (int)(e.data[0]);
                var count:int = (int)(e.data[1]);
                var camp:int = (int)(e.data[2]); // _searchEnemyCamp();
                var x:Number = _player.transform.x;
                var y:Number = _player.transform.y;
                var d2Pos:CVector3;
                d2Pos = CObject.get2DPositionFrom3D(_player.transform.x, 0, _player.transform.y);
                d2Pos.x += _randomInt( -5, 5 ) * 50;
                d2Pos.y += _randomInt( -2, 2 ) * 50;

                if (heroID > 0 && count > 0) { // } && camp >= 0) {
                    cmd = _findCommand(CAddCharacterCommand);
                    _parseCommand(cmd.name + " " + heroID + " " + count + " " + camp + " " + d2Pos.x + " " + d2Pos.y);
                }
                break;
            case EGmEventType.EVENT_BASE_KILL_ALL :
                // 干掉所有非同阵营的
                cmd = _findCommand(CRemoveAllDiffCampCommand);
                _parseCommand(cmd.name);
                _gmData.clear();
                break;
            case EGmEventType.EVENT_BASE_OPEN_ALL_AI :
                aiHandler = ecsLoop.getBean(CAIHandler) as CAIHandler;
                if (aiHandler) aiHandler.setEnable(true);
                break;
            case EGmEventType.EVENT_BASE_CLOSE_ALL_AI :
                aiHandler = ecsLoop.getBean(CAIHandler) as CAIHandler;
                if (aiHandler) aiHandler.setEnable(false);
                break;

            // =====================================action=======================================

            case EGmEventType.EVENT_SELECT_HERO :
                heroID = e.data as int;
                if (heroID > 0) {
                    heroList = _findHerosByID(heroID);
                    if (heroList && heroList.length > 0) {
                        _gmData.selectHero = heroList[0];
                    }
                }
                break;
            case EGmEventType.EVENT_NEXT_HERO :
                if (_gmData.selectHero) {
                    var findHero:CGameObject = null;
                    heroList = _findHerosByID(CCharacterDataDescriptor.getPrototypeID(_gmData.selectHero.data));
                    if (heroList && heroList.length > 0) {
                        for each (var hero:CGameObject in heroList) {
                            var heroUniID:int = CCharacterDataDescriptor.getID(hero.data);
                            if (_gmData.isUIDHasFind(heroUniID)) {
                                continue ;
                            } else {
                                findHero = hero;
                                break;
                            }
                        }
                        if (findHero == null) {
                            // 跑过一轮了
                            _gmData.clearIDList();
                            _gmData.selectHero = heroList[0];
                        } else {
                            _gmData.selectHero = findHero;
                        }
                    }
                }
                break;
            case EGmEventType.EVENT_SELECT_COMB :
                // 更新列表
                var allMonster:Vector.<Object> = _getAllMonster();
                var monsterDataList:Array = new Array();
                for each (var monster:CGameObject in allMonster) {
                    var property:CMonsterProperty = (monster.getComponentByClass(CMonsterProperty, false) as CMonsterProperty);
                    var monsterName:String;
                    if(property){
                        monsterName = property.nickName;
                    }else{
                        monsterName = (monster.getComponentByClass(CCharacterProperty, false) as CCharacterProperty).nickName; // CCharacterDataDescriptor.getNickName(monster.data);
                    }
                    var monsterID:int = CCharacterDataDescriptor.getPrototypeID(monster.data);
                    monsterName = monsterID + "(" + monsterName + ")";
                    monsterDataList.push(monsterName);
                }
//                monsterName = CCharacterDataDescriptor.getPrototypeID(_player.data) + "(自己)";
//                monsterDataList.push(monsterName);
                _gmView.actionView.setSelectCombData(monsterDataList);

                break;

            case EGmEventType.EVENT_KILL_HERO :
                if (_gmData.selectHero) {
                    // need cmd
                    cmd = _findCommand(CKillCharacterCommand);
                    _parseCommand(cmd.name + " " + _gmData.selectUID + " " + _gmData.selectType);
                }
                _gmData.clear();

                break;
            case EGmEventType.EVENT_MOVE_TO :
                if (_gmData.selectHero) {
                    var facadeMediator:CFacadeMediator = _gmData.selectHero.getComponentByClass(CFacadeMediator, false) as CFacadeMediator;
                    var transform:ITransform = _gmData.selectHero.transform;
                    var dir:int = e.data as int;
                    switch (dir) {
                        case 0 :// 上
                            facadeMediator.moveTo(new CVector2(transform.x, transform.y - _gmView.actionView.movePixel));
                            break;
                        case 1 : // 下
                            facadeMediator.moveTo(new CVector2(transform.x, transform.y + _gmView.actionView.movePixel));
                            break;
                        case 2 : // 左
                            facadeMediator.moveTo(new CVector2(transform.x - _gmView.actionView.movePixel, transform.y));
                            break;
                        case 3 : // 右
                            facadeMediator.moveTo(new CVector2(transform.x + _gmView.actionView.movePixel, transform.y));
                            break;
                        case 4 : //跳
                            facadeMediator._testJump();
                            break;
                        case 5 : //闪
                            facadeMediator.dodgeSudden(null,true);
                            break;
                        }
                }
                break;

            case EGmEventType.EVENT_CHANGE_AI :
                var aiID:int = e.data as int;
                if (_gmData.selectHero) {
                    (ecsLoop.getBean(CAIHandler) as CAIHandler).dispatchEvent(new CAIEvent(CAIEvent.CHANGE_AI_ID,{id:aiID, uid:_gmData.selectUID}));
                }
                break;
            case EGmEventType.EVENT_OPEN_AI :
                if (_gmData.selectHero) {
                    aiComponent = _gmData.selectHero.getComponentByClass(CAIComponent, false) as CAIComponent;
                    if (aiComponent) {
                        aiComponent.enabled = true;
                    }
                }
                break;
            case EGmEventType.EVENT_CLOSE_AI :
                if (_gmData.selectHero) {
                    aiComponent = _gmData.selectHero.getComponentByClass( CAIComponent, false ) as CAIComponent;
                    if ( aiComponent ) {
                        aiComponent.enabled = false;
                    }
                }
                break;
            case EGmEventType.EVENT_USE_SKILL :
                if (_gmData.selectHero) {
                    var useSkillID:int = e.data[0];
                    var times:int = e.data[1];
                    var cd:Number = e.data[2];
                    _castSkill(_gmData.selectHero, useSkillID, times, cd);
                }
                break;
            case EGmEventType.EVENT_SKILL_SELECT_COMB :
                    // 更新技能列表
                var skillList:Array = new Array();
                if (_gmData.selectHero) {
                    skillList = _gmData.skillList;
                }
                _gmView.actionView.setSelectSkillCombData(skillList);
                break;
//            case EGmEventType.EVENT_SKILL_SELECT_SKILL :
//                break;

            // =====================================skill=======================================

            case EGmEventType.EVENT_SKILL_OPEN_AREA :
                pCollisionSystem = ecsLoop.getBean( CCollisionHandler );
                if ( pCollisionSystem ) {
                    pCollisionSystem.showDebug = true;
                }
                break;
            case EGmEventType.EVENT_SKILL_CLOSE_AREA :
                pCollisionSystem = ecsLoop.getBean( CCollisionHandler );
                if ( pCollisionSystem ) {
                    pCollisionSystem.showDebug = false;
                }
                break;
            case EGmEventType.EVENT_SKILL_OPEN_MAX_ATK_POWER :
                _setPlayerConditionFlags(ESkillSkipType.SKIP_AP_EVALUATE, true);
                break;
            case EGmEventType.EVENT_SKILL_CLOSE_MAX_ATK_POWER :
                _setPlayerConditionFlags(ESkillSkipType.SKIP_AP_EVALUATE, false);
                break;
            case EGmEventType.EVENT_SKILL_OPEN_POWER :
                _setPlayerConditionFlags(ESkillSkipType.SKIP_RP_EVALUATE, true);
                break;
            case EGmEventType.EVENT_SKILL_CLOSE_POWER :
                _setPlayerConditionFlags(ESkillSkipType.SKIP_RP_EVALUATE, false);
                break;
            case EGmEventType.EVENT_SKILL_OPEN_NO_CD :
                _setPlayerConditionFlags(ESkillSkipType.SKIP_CD_EVALUATE, true);
                break;
            case EGmEventType.EVENT_SKILL_CLOSE_NO_CD :
                _setPlayerConditionFlags(ESkillSkipType.SKIP_CD_EVALUATE, false);
                break;
            // =====================================property=======================================
            case EGmEventType.EVENT_PROPERTY_MODIFY :
                if (_gmData.selectHero) {
                    var strProperty:String = e.data[0] as String;
                    var value:int = e.data[1];
                    var characterType:int = _gmData.characterType;
                    var iPropertyType:int = _gmData.propertyListData.getTypeByItem(strProperty);
                    if (_gmData.propertyListData.isDataVaild(iPropertyType, value)) {
                        cmd = _findCommand(CModifyCharacterPropertyCommand);
                        _parseCommand(cmd.name + " " + _gmData.selectUID + " " + characterType + " " + iPropertyType + " " + value);
                    }
                }

                break;
        }
    }

    private function _setPlayerConditionFlags(type:int, flag:Boolean) : void {
        (_player.getComponentByClass(CSimulateSkillCaster, false) as CSimulateSkillCaster).setConditionFlags(type, flag);
    }
    private function _findCommand(clazz:Class) : IConsoleCommand {
        var pBoard:CDashBoard = _system.stage.getBean(CDashBoard) as CDashBoard;
        var pConsolePage:CConsolePage = pBoard.findPage("ConsolePage") as CConsolePage;
        if (pConsolePage) {
            return pConsolePage.commandHandler.findCommand(clazz);
        }
        return null;
    }

    private function _parseCommand(cmd:String) : void {
        var pBoard:CDashBoard = _system.stage.getBean(CDashBoard) as CDashBoard;
        var pConsolePage:CConsolePage = pBoard.findPage("ConsolePage") as CConsolePage;
        if (pConsolePage) {
            pConsolePage.commandHandler.parseCommand(cmd);
        }
    }
    private function _findHerosByID(id:int) : Array {
        var ret:Array = new Array();
        var allMonsters:Vector.<Object> = _getAllMonster();
        allMonsters.push(_player as Object);
        for each (var obj:CGameObject in allMonsters) {
            //if(!CCharacterDataDescriptor.isHero( obj.data )){
                var heroID:int = CCharacterDataDescriptor.getPrototypeID( obj.data );
                if (heroID == id) {
                    ret.push(obj);
                }
            //}
        }


        return ret;
    }
    private function _getAllMonster() : Vector.<Object> {
        var sceneSystem:CSceneSystem = _system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var allMonsters:Vector.<Object> = sceneSystem.findAllMonster();
        allMonsters = allMonsters.concat(sceneSystem.findAllPlayer());
        return allMonsters;
    }
    private function _searchEnemyCamp() : int {
        var mList:Vector.<Object> = _getAllMonster();
        for each (var m:CGameObject in mList) {
            return CCharacterDataDescriptor.getCampID(m.data);
        }
        return 10;
    }
    private function _castSkill(user:CGameObject, useSkillID:int, times:int, cd:Number) : void {
        if (user && times > 0) {
            function __onSkillTimeEnd(event:Event) : void {
                (user.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).removeEventListener(CFightTriggleEvent.SPELL_SKILL_END, __onSkillTimeEnd);
                times--;
                if (times > 0) {
                    if (cd > 0) {
                        _wnd.DelayCall(cd, __playSkill);
                    } else {
                        __playSkill();
                    }
                }
            }
            function __playSkill() : void {
                (user.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).addEventListener(CFightTriggleEvent.SPELL_SKILL_END, __onSkillTimeEnd, false, 0, true);
                var skillCast:CSimulateSkillCaster = (user.getComponentByClass(CSimulateSkillCaster, false) as CSimulateSkillCaster);
                skillCast.castSkillByID(useSkillID);
            }
            __playSkill();
        }
    }

    private function _randomInt( from : int, to : int ) : int {
        return from + Math.round( Math.random() * (to - from) );
    }
    // ==============================controller====================================

    // ================================get=================================

    private function get _player() : CGameObject {
        return  (ecsLoop.getBean(CPlayHandler) as CPlayHandler).hero;
    }
    private function get ecsLoop() : CECSLoop {
        return _system.stage.getSystem(CECSLoop) as CECSLoop;
    }
    private function get system() : CGmSystem {
        return _system as CGmSystem;
    }
    private function get uiHandler() : CGmUIHandler {
        return system.uiHandler;
    }
    private function get _gmView() : CGmView {
        return _wnd as CGmView;
    }
    private function get _instanceSystem() : CInstanceSystem {
        return _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }

    private function get _gmData() : CGmData {
        return system.gmData;
    }

}
}
