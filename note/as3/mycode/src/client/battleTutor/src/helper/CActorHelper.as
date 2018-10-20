//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package helper {

import QFLib.Foundation.CMap;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import action.EKeyCode;

import flash.events.Event;

import flash.geom.Point;
import flash.ui.Keyboard;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.framework.IDatabase;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CFacadeMediator;

import kof.game.character.ai.CAIHandler;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.table.PlayerSkill;
import kof.util.CAssertUtils;

public class CActorHelper extends CHelperBase {
    public function CActorHelper(battleTutor:CBattleTutor) {
        super(battleTutor);
    }

    public function getObjectPos(obj:CGameObject) : CVector2 {
        var pos:CVector2;
        if (obj && obj.isRunning) {
            var transform:ITransform = (obj.getComponentByClass(ITransform, false) as ITransform);
            if (transform) {
                pos = new CVector2(transform.x, transform.y);
            }
        }
        return pos;
    }

    public function getMonsterByID(mID:Number) : CGameObject {
        var sceneSystem:CSceneSystem = _pBattleTutor.systemHelper.sceneSystem as CSceneSystem;
        var allMonsters:Vector.<Object> = sceneSystem.findAllMonster();
        for each (var obj:CGameObject in allMonsters) {
            if ((obj.getComponentByClass(ICharacterProperty, false) as ICharacterProperty).prototypeID == mID) {
                return obj;
            }
        }
        return null;
    }

    public function get hero():CGameObject {
        var pHero:CGameObject = (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).hero;
        CAssertUtils.assertNotNull(pHero);
        return pHero;
    }

    public var _needLockAI:Boolean; //  if true, 其他系统改变playHandler's enbale的话， 应该重新设为false, if false, 说明已经不需要限制ai的开关
    public function openAI():Boolean {
        _needLockAI = false;
        var aiHandler:CAIHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
        aiHandler.setEnable(true);
        return true;
    }

    public function closeAI():Boolean {
        _needLockAI = true;
        var aiHandler:CAIHandler = (_pBattleTutor.systemHelper.escLoop.getBean(CAIHandler) as CAIHandler);
        aiHandler.setEnable(false);
        return true;
    }

    public var _needLockPlayControl:Boolean; // true, 其他系统改变playHandler's enbale的话， 应该将playHandler's enbale重新设为false, false : 说明已经不需要限制ai的开关
    private static var s_playerControlValue:Boolean;
    public function markPlayerControlValue():Boolean {
        s_playerControlValue = (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).enabled;
        return true;
    }
    public function setPlayerControlValueByMark() : Boolean {
        if ((_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).enabled != s_playerControlValue) {
            (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).setEnable(s_playerControlValue);
        }
        return true;
    }
    public function get playerControlValue():Boolean {
        return (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).enabled;
    }
    public function openPlayerControl():Boolean {
        if ((_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).enabled == false) {
            _needLockPlayControl = false;
            (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).setEnable(true);
        }
        return true;
    }
    public function closePlayerControl():Boolean {
        _needLockPlayControl = true;
        if ((_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).enabled == false) return true;

        var movment:CMovement = hero.getComponentByClass(CMovement, true) as CMovement;
        movment.direction.setTo(0, 0);
        var input:CCharacterInput = hero.getComponentByClass(CCharacterInput, true) as CCharacterInput;
        input.wheel = new Point();
        (_pBattleTutor.systemHelper.escLoop.getBean(CPlayHandler) as CPlayHandler).setEnable(false);

        return true;
    }

    public function showTeammates():void {
        var sceneSystem:ISceneFacade = _pBattleTutor.systemHelper.sceneSystem;
        var allHero:Vector.<Object> = sceneSystem.playerIterator as Vector.<Object>;

        for each (var obj:CGameObject in allHero) {
            if (CCharacterDataDescriptor.isHero(obj.data))
                continue;
            (obj.getComponentByClass(IDisplay, false) as IDisplay).modelDisplay.visible = true;
        }
    }

    public function hideTeammates():void {
        var sceneSystem:ISceneFacade = _pBattleTutor.systemHelper.sceneSystem;
        var allHero:Vector.<Object> = sceneSystem.playerIterator as Vector.<Object>;

        for each (var obj:CGameObject in allHero) {
            if (CCharacterDataDescriptor.isHero(obj.data))
                continue;
            (obj.getComponentByClass(IDisplay, false) as IDisplay).modelDisplay.visible = false;
        }
    }

    public function pauseActor():void {
        hideTeammates();
        closeAI();
        closePlayerControl();
    }

    public function continueActor():Boolean {
        showTeammates();
        openAI();
        openPlayerControl();
        return true;
    }


    // 所有角色的行为都完成了
    public function isAllGameObjectStop():Boolean {
        var sceneSystem:CSceneSystem = _pBattleTutor.systemHelper.sceneSystem as CSceneSystem;
        var allGameObj:Array = sceneSystem.allGameObjectIterator as Array;
        for each (var obj:CGameObject in allGameObj) {
            var state:CCharacterStateMachine = obj.getComponentByClass(CCharacterStateMachine, true) as CCharacterStateMachine;
            if (state == null) {
                continue;
            }
            if (state.actionFSM.current == CCharacterActionStateConstants.ATTACK
                    || state.actionFSM.current == CCharacterActionStateConstants.HURT
                    || state.actionFSM.current == CCharacterActionStateConstants.KNOCK_UP) {
                return false;
            }
        }
        return true;
    }


    // 实现按键操作
    public function doActionByKey(keyCode:uint):void {
        var pHero:CGameObject = _pBattleTutor.actorHelper.hero;
        if (!pHero) {
            return;
        }
        var pInput:CCharacterInput = pHero.getComponentByClass(CCharacterInput, true) as CCharacterInput;
        var pFacadeMediator:CFacadeMediator = pHero.getComponentByClass(CFacadeMediator, true) as CFacadeMediator;

        switch (keyCode) {
            case Keyboard.J:
                pInput.addSkillRequest(0);
                break;
            case Keyboard.L:
                pInput.addActionCall(pFacadeMediator.dodgeSudden);
                break;
            case Keyboard.K:
                pInput.addSkillRequest(1);
                break;
            case Keyboard.U:
                pInput.addSkillRequest(2);
                break;
            case Keyboard.I:
                pInput.addSkillRequest(3);
                break;
            case Keyboard.O:
                pInput.addSkillRequest(4);
                break;
            case Keyboard.SPACE:
                pInput.addSkillRequest(5);
                break;
            case Keyboard.Q:
                pInput.addActionCall(pFacadeMediator.switchPrevHero);
                break;
            case Keyboard.E:
                pInput.addActionCall(pFacadeMediator.switchNextHero);
                break;
            default:
                break;
        }
        // */
    }

    private var _skill_map:CMap;
    public function getSkillIDByKey(key:String):int {
        if (null == _skill_map) {
            _skill_map = new CMap();
            var pHero:CGameObject = hero;

            var pDB:IDatabase = _pBattleTutor.systemHelper.database;
            var pTablePlayerSkil:IDataTable = pDB.getTable(KOFTableConstants.PLAYER_SKILL);
            var pPlayerSkill:PlayerSkill = pTablePlayerSkil.findByPrimaryKey(pHero.data.prototypeID);

            _skill_map.add(EKeyCode.J, pPlayerSkill.SkillID[0]);
            _skill_map.add(EKeyCode.U, pPlayerSkill.SkillID[2]);
            _skill_map.add(EKeyCode.I, pPlayerSkill.SkillID[3]);
            _skill_map.add(EKeyCode.O, pPlayerSkill.SkillID[4]);
            _skill_map.add(EKeyCode.K, pPlayerSkill.SkillID[1]);
            _skill_map.add(EKeyCode.L, pPlayerSkill.SkillID[0]);
            _skill_map.add(EKeyCode.SPACE, pPlayerSkill.SkillID[5]);
        }
        return _skill_map.find(key);
    }

    public function setRagePowerFull() : Boolean {
        var obj:CGameObject = hero;
        if (!obj) return true;

        var pCharacterProperty : CCharacterProperty = obj.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
        pCharacterProperty.RagePower = Math.max( 1, pCharacterProperty.MaxRagePower );
        return true;
    }

    public function slowGame() : Boolean {
        var pApp : Object = _pBattleTutor.systemHelper.application;
        pApp._baseDeltaFactor = 0.01;
        return true;
    }
    public function unSlowGame() : Boolean {
        var pApp : Object = _pBattleTutor.systemHelper.application;
        pApp._baseDeltaFactor = 1;
        return true;
    }

    public function turnLeft() : Boolean {
        var obj:CGameObject = hero;
        if ((obj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator)){
            (obj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).setDisplayDirection(-1);
        }
        return true;
    }
    public function turnRight() : Boolean {
        var obj:CGameObject = hero;
        if ((obj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator)){
            (obj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).setDisplayDirection(1);
        }
        return true;
    }
    public function moveToByPixel(moveObj:CGameObject, toX:Number, toY:Number, callback:Function) : Boolean {
        log("| -----------------------moveto");

//        var movementComponent:CMovement = moveObj.getComponentByClass(CMovement, false) as CMovement;
//        if (movementComponent) movementComponent.collisionEnabled = false;
        if (!(moveObj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).moveToPixel(Vector.<CVector2>([new CVector2(toX, toY)]), callback)) {
            if (callback) {
                callback();
            }
        }
        return true;
    }
    public function moveTo(moveObj:CGameObject, toX:Number, toY:Number, callback:Function) : Boolean {
//        var movementComponent:CMovement = moveObj.getComponentByClass(CMovement, false) as CMovement;
//        if (movementComponent) movementComponent.collisionEnabled = false;
        if (!(moveObj.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).moveTo(new CVector2(toX, toY), callback)) {
            if (callback) {
                callback();
            }
        }
        return true;
    }

    public function castSkillAndHit(user:CGameObject, useSkillID:int, callback:Function) : Boolean {
        if (!user) {
            return true;
        }

        var _onSkillTimeEnd:Function = function (event:Event) : void {
            (user.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).removeEventListener(CFightTriggleEvent.HIT_TARGET, _onSkillTimeEnd);
            if (callback) {
                callback();
            }
        };
        (user.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).addEventListener(CFightTriggleEvent.HIT_TARGET, _onSkillTimeEnd, false, 0, true);
        var skillCast:CSimulateSkillCaster = (user.getComponentByClass(CSimulateSkillCaster, false) as CSimulateSkillCaster);
        skillCast.castSkillByID(useSkillID);

        return true;
    }

    public function clearSkillCD(skillID:int) : Boolean {
        var obj:CGameObject = hero;
        if (obj) {
            var fightCalc:CFightCalc = obj.getComponentByClass(CFightCalc, false) as CFightCalc;
            if (fightCalc) {
                fightCalc.removeSkillCDByID(skillID);
            }
        }
        return true;
    }

}
}
