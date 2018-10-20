//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/27.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;

import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.getTimer;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.util.CAssertUtils;
import morn.core.handlers.Handler;

import view.CMaskViewHandler;

import view.CQTEViewHandler;
import view.CViewRenderUtil;

public class CQtePackage extends CActionPackageBase {
    public function CQtePackage() {

    }

    public override function buildAction():CActionBase {

        CAssertUtils.assertNotNull(keyList);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var keyCodeList:Array = this.getKeyCodeList();
        var qteView:CQTEViewHandler = tutorBase.battleTutor.viewHelper.qteView;
        var tempKey:String;

        _isAutoPlayOpen = true;
        _needAutoPlay = true;

        var qteAction:CActionCommon = new CActionCommon();
        var onKeyPress:Function = function (pressKeyCode:uint):Boolean {
            battleTutor.actorHelper.doActionByKey(pressKeyCode);

//            _needAutoPlay = false;
//            _isAutoPlayOpen = false;
            return true;
        };
        var onKeyPressPassAutoPlay:Function = function (pressKeyCode:uint) : Boolean {
//            _needAutoPlay = false;
//            _isAutoPlayOpen = false;
            return true;
        };

        // 鼠标点击
        var isMouseClick:Boolean = false;
        var onMouseClickHandler:Function = function (e:MouseEvent) : void {
            isMouseClick = true;
        };
        var listenMouseClickHandler:Function = function () : Boolean {
            isMouseClick = false;
            qteView.ui.skill.removeEventListener(MouseEvent.CLICK, onMouseClickHandler);
            qteView.ui.skill.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
            return true;
        };
        var unlistenMouseClickHandler:Function = function () : Boolean {
            isMouseClick = false;
            qteView.ui.skill.removeEventListener(MouseEvent.CLICK, onMouseClickHandler);
            return true;
        };

        // step : 第几下
        var isPressQte:Function = function (skillIDList:Array, keyCode:uint, step:int):Boolean {
            if (1 == step) {
                if (_needAutoPlay) {
                    if (getTimer() - _autoPlayStartTime>= AUTO_PLAY_TIME) {
//                        _isAutoPlayOpen = true;
                        battleTutor.actorHelper.doActionByKey(keyCode);
                        return true;
                    }
                }
            } else {
                if (_isAutoPlayOpen == false && _needAutoPlay == false) {
                    // 自动播放已被断掉, 停断引导
                    if (!forcePressKey) {
                        // 非强制
                        if (getTimer() - _lastSkillAutoUseTime>= AUTO_STOP_QTE_TIME) {
                            _isCloseQte = true;
                            qteAction.end();
                            return true;
                        }
                    }
                } else {
                    // 自动播放
                    if (_isAutoPlayOpen) {
                        var waitTime:int = _autoPlayKey2WaitTime;
                        if (3 == step) {
                            waitTime = _autoPlayKey3WaitTime;
                        }
                        if (getTimer() - _lastSkillAutoUseTime >= waitTime) {
                            battleTutor.actorHelper.doActionByKey(keyCode);
                        }
                    }
                }
            }
            if (isMouseClick) {
                battleTutor.actorHelper.doActionByKey(keyCode);
            }

            return checkSpellSkill(skillIDList);
        };

        var playCircleEffect:Function = function ():Boolean {
            qteView.ui.bomb.visible = false;
            qteView.ui.effect.visible = true;
            qteView.ui.skill.visible = true;
            qteView.ui.effect.play();
            return true;
        };
        var playBombEffect:Function = function (isPlayCircleEffect:Boolean = true):Boolean {
//            qteView.ui.effect.playFromTo(22);
            qteView.ui.skill.visible = false;
            qteView.ui.effect.visible = false;
            qteView.ui.bomb.visible = true;
            if (isPlayCircleEffect) {
                qteView.ui.bomb.playFromTo(null, null, new Handler(playCircleEffect));
            } else {
                qteView.ui.bomb.playFromTo(null, null, new Handler(function () : Boolean {
                    qteView.ui.bomb.visible = false;
                    return true;
                }));
            }
            return true;
        };
        var isPlayBombEnd:Function = function ():Boolean {
            return qteView.ui.bomb.isPlaying == false;
        };
        var initialView:Function = function ():Boolean {
            qteView.ui.visible = true;
            flyCount = 0;
            _lastSpellSkill = -1;
            _lastFinishSkillID = -1;
            qteView.ui.bomb.visible = false;
            qteView._flyEnd = false;
            qteView.ui.light.visible = false;
            qteView.ui.skill.setPosition(qteView._baseSkillPos.x, qteView._baseSkillPos.y);
            qteView.ui.effect.visible = true;
            CViewRenderUtil.renderSkillItem(tutorBase.battleTutor.system, key1, tutorBase.battleTutor.actorHelper.getSkillIDByKey(key1), qteView.ui.skill);
            return true;
        };
        var updateView:Function = function (updateKey:String):Boolean {
            var keyPress:String = updateKey;
            CViewRenderUtil.renderSkillItem(tutorBase.battleTutor.system, keyPress, tutorBase.battleTutor.actorHelper.getSkillIDByKey(keyPress), qteView.ui.skill);
            return true;
        };
        var hideEffect:Function = function ():Boolean {
            qteView.ui.bomb.visible = false;
            qteView.ui.effect.visible = false;
            qteView.hideUIO();
            return true;
        };

        var reset_UIO_force_finish:Function = function () : Boolean {
            _UIO_force_finish = false;
            return true;
        };
        var onHeroStateChange:Function = function (e:Event):Boolean {
            var hero:CGameObject = tutorBase.battleTutor.actorHelper.hero;
            var pStateBoard : CCharacterStateBoard = hero.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if (pStateBoard.isDirty(CCharacterStateBoard.ON_GROUND) && pStateBoard.getValue(CCharacterStateBoard.ON_GROUND)) {
                _UIO_force_finish = true;
            }
            return true;
        };
        var onSkillSpellStarted:Function = function (e:CFightTriggleEvent):Boolean {
            var skillID:uint;
            if (e.type == CFightTriggleEvent.SPELL_SKILL_BEGIN) {
                skillID = e.parmList[0];
                _lastSpellSkill = skillID;
                _lastSpellSkill = CSkillUtil.getMainSkill(_lastSpellSkill);
            } else if (e.type == CFightTriggleEvent.SPELL_SKILL_END) {
                skillID = e.parmList[0];
                _lastFinishSkillID =  CSkillUtil.getMainSkill(skillID);
            }
            return true;
        };
        var checkSpellSkill:Function = function (skillIDList:Array):Boolean {
            return skillIDList.indexOf(_lastSpellSkill) != -1;
        };
        var resetLastSpellSkill:Function = function ():Boolean {
            _lastSpellSkill = -1;
            return true;
        };
        var checkFinishSkill:Function = function (checkSkillID:uint) : Boolean {
            return _lastFinishSkillID == checkSkillID || _UIO_force_finish;
        };
        var resetPlayStartTime:Function = function () : Boolean {
            _autoPlayStartTime = getTimer();
            return true;
        };
        var resetSkillAutoUseTime:Function = function () : Boolean {
            _lastSkillAutoUseTime = getTimer();
            return true;
        };


        // ===========================================================================================

        // qte
        var setUiUnVisible:Function = function () : Boolean {
            battleTutor.viewHelper.qteView.ui.visible = false;
            return true;
        };
        var setUpdateHandlerNone:Function = function () : Boolean {
            battleTutor.viewHelper.qteView.updateHandler = null;
            return true;
        };

        var maskShowMovie:Function = function () : Boolean {
            battleTutor.viewHelper.maskView.ui.up.height = 1;
            battleTutor.viewHelper.maskView.ui.down.height = 1;
            battleTutor.viewHelper.maskView.ui.visible = true;

            TweenLite.to(battleTutor.viewHelper.maskView.ui.up, 0.1, {height:battleTutor.stage.stageHeight * 0.4, onComplete:function () : void {
                _maskShowed = true;
            }});
            TweenLite.to(battleTutor.viewHelper.maskView.ui.down, 0.1, {height:battleTutor.stage.stageHeight * 0.2});
            return true;
        };
        var initialMaskUI:Function = function () : Boolean {
            battleTutor.viewHelper.maskView.ui.visible = false;
            return true;
        };
        var waitMaskShowed:Function = function () : Boolean {
            return _maskShowed;
        };
        battleTutor.viewHelper.maskView.updateHandler = new Handler(initialMaskUI);
        battleTutor.viewHelper.qteView.updateHandler = new Handler(setUiUnVisible);

        qteAction.addPassHandler(new Handler(battleTutor.viewHelper.showView, [CMaskViewHandler]));
        qteAction.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CMaskViewHandler]));
        qteAction.addPassHandler(new Handler(maskShowMovie));
        qteAction.addPassHandler(new Handler(waitMaskShowed));

        qteAction.addStartHandler(new Handler(battleTutor.viewHelper.showView, [CQTEViewHandler]));
        qteAction.addPassHandler(new Handler(battleTutor.condHelper.isViewShowed, [CQTEViewHandler]));
        qteAction.addPassHandler(new Handler(initialView));

        qteAction.addPassHandler(new Handler(_listenHeroSpellSkill, [onSkillSpellStarted])); // 监听播放技能事件
        if (_UIO) {
            qteAction.addPassHandler(new Handler(_listenHeroState, [onHeroStateChange])); // 监听人物状态改变, 落地
        }

        qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKeyList, [keyCodeList])); // 激活开放按键, 只是不会阻止 这些按键
        qteAction.addPassHandler(new Handler(resetPlayStartTime));

        // 强制按键, 每次只开放一个按键
        // 非强制, 会开放人物, 但是第一次必须按第一个键
        qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [EKeyCode.getKeyCodeByKey(key1), onKeyPress]));
        qteAction.addPassHandler(new Handler(playCircleEffect));
        qteAction.addPassHandler(new Handler(battleTutor.actorHelper.clearSkillCD, [battleTutor.actorHelper.getSkillIDByKey(key1)]));
        if (_showJClip) {
            qteAction.addPassHandler(new Handler(qteView.showJChip));
        }
        if (_showUIOClip) {
            qteAction.addPassHandler(new Handler(qteView.showUIOByIndex, [0]));
        }
        if (_showSpaceClip) {
            qteAction.addPassHandler(new Handler(qteView.showSpaceChip));
        }
        qteAction.addPassHandler(new Handler(listenMouseClickHandler));
        qteAction.addPassHandler(new Handler(isPressQte, [[battleTutor.actorHelper.getSkillIDByKey(key1)], EKeyCode.getKeyCodeByKey(key1), 1]));
        qteAction.addPassHandler(new Handler(unlistenMouseClickHandler));
        qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep1]));
        qteAction.addPassHandler(new Handler(battleTutor.viewHelper.hideView, [CMaskViewHandler]));

        qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.playAudio, [_audioID]));

        qteAction.addPassHandler(new Handler(battleTutor.actorHelper.unSlowGame));

        qteAction.addPassHandler(new Handler(resetLastSpellSkill));

        if (totalPressCount >= 3) { // 播放3次
            if (forcePressKey) {
                // UIO特制
                // 第一次按键过后, 打开人物权限
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [EKeyCode.getKeyCodeByKey(key1), onKeyPress]));
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [EKeyCode.getKeyCodeByKey(key2), onKeyPress]));
                qteAction.addPassHandler(new Handler(updateView, [key2]));
                qteAction.addPassHandler(new Handler(playBombEffect));

                qteAction.addPassHandler(new Handler(qteAction.resetStartTime));
                qteAction.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [qteAction, 400]));
                qteAction.addPassHandler(new Handler(battleTutor.actorHelper.slowGame));
                qteAction.addPassHandler(new Handler(resetSkillAutoUseTime));
                if (_showUIOClip) {
                    qteAction.addPassHandler(new Handler(qteView.showUIOByIndex, [1]));
                }
                qteAction.addPassHandler(new Handler(listenMouseClickHandler));
                qteAction.addPassHandler(new Handler(isPressQte, [[battleTutor.actorHelper.getSkillIDByKey(key2)], EKeyCode.getKeyCodeByKey(key2), 2]));
                qteAction.addPassHandler(new Handler(unlistenMouseClickHandler));
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep2]));

                qteAction.addPassHandler(new Handler(battleTutor.actorHelper.unSlowGame));
                qteAction.addPassHandler(new Handler(resetLastSpellSkill));
                // 3
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [EKeyCode.getKeyCodeByKey(key2), onKeyPress]));
                qteAction.addPassHandler(new Handler(updateView, [key3]));
                qteAction.addPassHandler(new Handler(playBombEffect, [false]));
                // I的暂停只能是技能放完，才能开始
                qteAction.addPassHandler(new Handler(qteAction.resetStartTime));
//                qteAction.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [qteAction, 950]));

                // I完成播放才出现QTE
                qteAction.addPassHandler(new Handler(checkFinishSkill, [battleTutor.actorHelper.getSkillIDByKey(key2)]));
                qteAction.addPassHandler(new Handler(reset_UIO_force_finish));
                qteAction.addPassHandler(new Handler(playCircleEffect));
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [EKeyCode.getKeyCodeByKey(key3), onKeyPress]));
                qteAction.addPassHandler(new Handler(battleTutor.actorHelper.slowGame));
                qteAction.addPassHandler(new Handler(resetSkillAutoUseTime));
                if (_showUIOClip) {
                    qteAction.addPassHandler(new Handler(qteView.showUIOByIndex, [2]));
                }
                qteAction.addPassHandler(new Handler(listenMouseClickHandler));
                qteAction.addPassHandler(new Handler(isPressQte, [[battleTutor.actorHelper.getSkillIDByKey(key3)], EKeyCode.getKeyCodeByKey(key3), 3]));
                qteAction.addPassHandler(new Handler(unlistenMouseClickHandler));
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep3]));

                qteAction.addPassHandler(new Handler(battleTutor.actorHelper.unSlowGame));
            } else {
                // 第一次按键过后, 打开人物权限
                // 如果是强制按键, 则不需要开放人物控制, 否则开放
                qteAction.addPassHandler(new Handler(battleTutor.actorHelper.markPlayerControlValue));
                qteAction.addPassHandler(new Handler(battleTutor.actorHelper.openPlayerControl));
                // 非强制, 后面已经不需要listenKey
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [EKeyCode.getKeyCodeByKey(key1), onKeyPress]));
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [EKeyCode.getKeyCodeByKey(key2), onKeyPressPassAutoPlay]));

                qteAction.addPassHandler(new Handler(updateView, [key2]));
                qteAction.addPassHandler(new Handler(playBombEffect));
                qteAction.addPassHandler(new Handler(resetSkillAutoUseTime));
                if (_showUIOClip) {
                    qteAction.addPassHandler(new Handler(qteView.showUIOByIndex, [1]));
                }
                qteAction.addPassHandler(new Handler(listenMouseClickHandler));
                qteAction.addPassHandler(new Handler(isPressQte, [[battleTutor.actorHelper.getSkillIDByKey(key2)], EKeyCode.getKeyCodeByKey(key2), 2]));
                qteAction.addPassHandler(new Handler(unlistenMouseClickHandler));
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep2]));

                qteAction.addPassHandler(new Handler(resetLastSpellSkill));

                // 3
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [EKeyCode.getKeyCodeByKey(key1), onKeyPressPassAutoPlay]));
                qteAction.addPassHandler(new Handler(updateView, [key3]));
                qteAction.addPassHandler(new Handler(playBombEffect));
                // I的暂停只能是技能放完，才能开始
                qteAction.addPassHandler(new Handler(battleTutor.keyPressHelper.listenKey, [EKeyCode.getKeyCodeByKey(key3), onKeyPressPassAutoPlay]));

                qteAction.addPassHandler(new Handler(resetSkillAutoUseTime));
                if (_showUIOClip) {
                    qteAction.addPassHandler(new Handler(qteView.showUIOByIndex, [2]));
                }
                qteAction.addPassHandler(new Handler(listenMouseClickHandler));
                qteAction.addPassHandler(new Handler(isPressQte, [[battleTutor.actorHelper.getSkillIDByKey(key3)], EKeyCode.getKeyCodeByKey(key3), 3]));
                qteAction.addPassHandler(new Handler(unlistenMouseClickHandler));
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep3]));

            }
        } // 3次
        qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.lockAllKey));

        qteAction.addPassHandler(new Handler(playBombEffect));
        qteAction.addPassHandler(new Handler(isPlayBombEnd));
        qteAction.addPassHandler(new Handler(hideEffect)); // 隐藏qte特效

        qteAction.addPassHandler(new Handler(checkFinishSkill, [battleTutor.actorHelper.getSkillIDByKey(key3)])); // 等待技能放完
        qteAction.addFinishHandler(new Handler(battleTutor.instanceProcess.unLockAllKey));

        for each (tempKey in keyList) {
            qteAction.addFinishHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [EKeyCode.getKeyCodeByKey(tempKey), onKeyPress]));
            qteAction.addFinishHandler(new Handler(battleTutor.keyPressHelper.unListenKey, [EKeyCode.getKeyCodeByKey(tempKey), onKeyPressPassAutoPlay]));
        }
        qteAction.addFinishHandler(new Handler(_unlistenHeroSpellSkill, [onSkillSpellStarted]));
        if (_UIO) {
            qteAction.addFinishHandler(new Handler(_unlistenHeroState, [onHeroStateChange]));
        }

        qteAction.addFinishHandler(new Handler(setUpdateHandlerNone));
        qteAction.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CMaskViewHandler]));

        return qteAction;
    }


    private function _listenHeroSpellSkill(callBack:Function) : Boolean {
//        HIT_TARGET
        var hero:CGameObject = tutorBase.battleTutor.actorHelper.hero;
        var pFightTriggle:CCharacterFightTriggle = hero.getComponentByClass(CCharacterFightTriggle, true) as CCharacterFightTriggle;
        if (pFightTriggle) {
            pFightTriggle.addEventListener(CFightTriggleEvent.SPELL_SKILL_BEGIN, callBack);
            pFightTriggle.addEventListener(CFightTriggleEvent.SPELL_SKILL_END, callBack);
        }

        return true;
    }
    private function _unlistenHeroSpellSkill(callBack:Function) : Boolean {
        var hero:CGameObject = tutorBase.battleTutor.actorHelper.hero;
        var pFightTriggle:CCharacterFightTriggle = hero.getComponentByClass(CCharacterFightTriggle, true) as CCharacterFightTriggle;
        if (pFightTriggle) {
            pFightTriggle.removeEventListener(CFightTriggleEvent.SPELL_SKILL_BEGIN, callBack);
            pFightTriggle.removeEventListener(CFightTriggleEvent.SPELL_SKILL_END, callBack);

        }
        return true;
    }

    private function _listenHeroState(callBack:Function) : Boolean {
        var hero:CGameObject = tutorBase.battleTutor.actorHelper.hero;
        var pEventMediator : CEventMediator = hero.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, callBack );
        }

        return true;
    }
    private function _unlistenHeroState(callBack:Function) : Boolean {
        var hero:CGameObject = tutorBase.battleTutor.actorHelper.hero;
        var pEventMediator : CEventMediator = hero.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, callBack );
        }
        return true;
    }
    private var _lastSpellSkill:uint;
    private var _lastFinishSkillID:uint;
    private var _UIO_force_finish:Boolean;

}
}
