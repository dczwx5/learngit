//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/31.
 */
package kof.game.instance {
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.getTimer;
import kof.framework.CAbstractHandler;
import kof.game.character.ai.CAIHandler;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.handler.CPlayHandler;
import kof.game.common.CLang;
import kof.game.common.CTest;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CInstanceProcessViewHandler;
import kof.game.instance.event.CInstanceEvent;
import kof.game.lobby.CLobbySystem;
import kof.game.player.CPlayerSystem;
import kof.game.scenario.CScenarioSystem;
import kof.game.scenario.event.CScenarioEvent;

// 控制自动战斗
// 非自动战斗 : 进入关卡时, 关闭自动战斗即可
// 强制自动战斗 : 进入关卡时， 打开强制自动战斗, 并监听阻止playHandler打开
// 自动战斗 : 进入关卡时, 如果达到时间，则打开自动战斗, 需要检测最后一次玩家操作时间, 如果不满意时间关闭自动战斗, 否则打开自动战斗
public class CInstanceAutoFightHandler extends CAbstractHandler implements IUpdatable {
    public function CInstanceAutoFightHandler() {
        _autoFightStateList = new Object();
    }
    public override function dispose():void {
        super.dispose();
        _system.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        _system.removeEventListener(CInstanceEvent.LEVEL_STARTED, _onLevelStarted);
        _system.removeEventListener(CInstanceEvent.LEVEL_EXIT, _onLevelExit);
        _system.removeEventListener(CInstanceEvent.WINACTOR_END, _onWinAnimationEnd);

        var ecsLoop:CECSLoop = system.stage.getSystem(CECSLoop) as CECSLoop;
        if (ecsLoop) {
            var pPlayHandler:CPlayHandler = (ecsLoop.getBean(CPlayHandler) as CPlayHandler);
            if (pPlayHandler) {
                pPlayHandler.removeEventListener("resetPlayState", _onPlayStateChange);
            }
        }

        if (system.stage.getSystem(CLobbySystem)) {
            var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
            if (fightViewHandler) {
                fightViewHandler.removeEventListener("changeAuto", _onChangeAutoStateByUI);
            }
        }

    }
    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        _system.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstance);
        _system.addEventListener(CInstanceEvent.LEVEL_STARTED, _onLevelStarted);
        _system.addEventListener(CInstanceEvent.LEVEL_EXIT, _onLevelExit);
        _system.addEventListener(CInstanceEvent.WINACTOR_END, _onWinAnimationEnd);

//        _onPlayerLevelUp(null);

        return ret;
    }

    private function _onEnterInstance(e:CInstanceEvent) : void {
        var fightViewHandler:CInstanceProcessViewHandler = (system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler) as CFightViewHandler).getBean(CInstanceProcessViewHandler);
        if (fightViewHandler) {
            fightViewHandler.setForceAutoFight(false);
            _resetAutoState();
        }

        _setEnableByInstance();

        if (!_enable)  {
            if (fightViewHandler) {
                var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var pInstanceSystem:CInstanceSystem = system as CInstanceSystem;
                var playerLevel:int = pPlayerSystem.playerData.teamData.level;
                var openSubLevel:int = pInstanceSystem.instanceManager.autoFightOpenSubLevel;
                var openVipLevel:int = pInstanceSystem.instanceManager.autoFightOpenVipLevel;
                var vipLevel:int = pPlayerSystem.playerData.vipData.vipLv;
                var vipLevelNotEnough:Boolean = vipLevel < openVipLevel;
                var subLevelNotEnough:Boolean = playerLevel < openSubLevel;
                if ((vipLevelNotEnough || subLevelNotEnough) && _autoFightType == TYPE_AUTO_FIGHT) {
                    // 因为vip等级或玩家等级, _enable为false, 有可能 是因为subLevel或vipLevel不满足条件.
                    // 但如果两个条件都配。只要满足其中一个就可以.
                    // 而如果或个条件为0.则又不需要判断
                    // 会进到这里。说明就是有不满足的条件
                    fightViewHandler.updateAutoViewBySubLevelNotOpen(vipLevel, playerLevel, openVipLevel, openSubLevel);
                } else {
                    fightViewHandler.setAutoBoxVisbible(false);
                    fightViewHandler.updateAutoView();
                }
            }
            return ;
        }
        _playHandler.removeEventListener("clickTurnToMove", _onClickTurnToMove);
        _scenarioSystem.removeEventListener(CScenarioEvent.EVENT_SCENARIO_END_B, _onScenarioEnd);

        if (_autoFightType == TYPE_AUTO_FIGHT) {
            _scenarioSystem.addEventListener(CScenarioEvent.EVENT_SCENARIO_END_B, _onScenarioEnd);
            _playHandler.addEventListener("clickTurnToMove", _onClickTurnToMove);
        }
    }
    private function _setEnableByInstance() : void {
        if (_autoFightType == TYPE_NO_AUTO_FIGHT) {
            enable = false;
            return;
        }
        var pInstanceSystem:CInstanceSystem = system as CInstanceSystem;

        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if (pPlayerSystem) {
            var playerLevel:int = pPlayerSystem.playerData.teamData.level;
//            var openAutoFightLevel:int = pInstanceSystem.instanceManager.autoFightOpenLevel;
            var openSubLevel:int = pInstanceSystem.instanceManager.autoFightOpenSubLevel;
            var openVipLevel:int = pInstanceSystem.instanceManager.autoFightOpenVipLevel;
            var vipLevel:int = pPlayerSystem.playerData.vipData.vipLv;
//            enable = playerLevel >= openAutoFightLevel;
//            if (enable) { // 两个条件是或的关系。但是配0是不需要处理的条件。
                if (openVipLevel > 0 && openSubLevel > 0) {
                    // 两个都配了. 其中一个满足就行
                    enable = (vipLevel >= openVipLevel || playerLevel >= openSubLevel);
                } else if (openVipLevel > 0) {
                    // 另一个是0.不处理
                    enable = (vipLevel >= openVipLevel);
                } else if (openSubLevel > 0) {
                    enable = (playerLevel >= openSubLevel);
                } else {
                    enable = true;
                }
//            }

        }
    }

    private var _t:int;
    public function update(delta:Number) : void {
        if (!_enable) {
            return ;
        }

        if (_bForcePause) {
            return ;
        }
        if (_isStart && _autoFightType == TYPE_AUTO_FIGHT) {
            // 处理自动战斗 TYPE_AUTO_FIGHT
            _refreshAutoFight();
        }
//
//        var pAiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
//        if (pAiHandler) {
//            if (getTimer() - _t > 1000) {
//                _t = getTimer();
//                trace("自动战斗 : " + pAiHandler.bAutoFight);
//            }
//        }
    }


    private function _onWinAnimationEnd(e:CInstanceEvent) : void {
        if (!_enable) return ;
        _lastWinAnimationEndTime = getTimer();
    }
    private function _onLevelExit(e:CInstanceEvent) : void {
        if (!_enable) return ;
        _isStart = false;
    }
    private function _onScenarioEnd(e:CScenarioEvent) : void {
        if (!_enable) return ;
        _lastScenarioEndTime = getTimer();
    }
    private function _onClickTurnToMove(e:Event) : void {
        if (!_enable) return ;
        _lastClickTurnToMoveTime = getTimer();
//        trace("点了地面移动");
    }

    private var _hasListenPlayHandlerEvent:Boolean = false;
    private var _isStart:Boolean;
    private function _onLevelStarted(e:CInstanceEvent) : void {
        if (!_enable) return ;

        if (!_hasListenPlayHandlerEvent) {
            var pPlayHandler:CPlayHandler = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler);
            if (pPlayHandler) {
                _hasListenPlayHandlerEvent = true;
                pPlayHandler.addEventListener("resetPlayState", _onPlayStateChange);
            }
        }
        _resetAutoState();

        var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
        if (fightViewHandler) {
            fightViewHandler.removeEventListener("changeAuto", _onChangeAutoStateByUI);
            fightViewHandler.addEventListener("changeAuto", _onChangeAutoStateByUI);
        }
        _isStart = true;
    }
    private function _resetAutoState() : void {
        _startTime = getTimer();

        // 开始是否设置自动战斗
        var isAuto:Boolean;
        var iInstanceType:int = _system.instanceType;
        if (false == _autoFightStateList.hasOwnProperty(iInstanceType.toString())) {
            _autoFightStateList[iInstanceType.toString()] = false;
        }
        isAuto = _autoFightStateList[iInstanceType.toString()];
        if (!_isRecordLastState) {
            isAuto = false;
        }

        _refreshAutoFight(isAuto, true);
    }
    private function _onChangeAutoStateByUI(e:Event) : void {
        if (!_enable) return ;

        var pAiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        if (!pAiHandler) return ;

        var iInstanceType:int = _system.instanceType;
        _autoFightStateList[iInstanceType.toString()] = pAiHandler.bAutoFight;
//        trace("修改记录值为 : " + pAiHandler.bAutoFight + "(点UI)");
    }

    private function _refreshAutoFight(isAutoForce:Boolean = false, forceRefresh:Boolean = false) : void {

        var pAiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        if (!pAiHandler) return ;

        if (_system.isMainCity) {
            if (pAiHandler.bAutoFight) {
                pAiHandler.bAutoFight = false;
            }
            return ;
        }
        if (!(_system.instanceContent)) return ;

        if (!_enable) return ;

        var iAutoFightType:int = _autoFightType;
        var iAutoFightDelayTime:int = _autoFightDelayTime;
        var bLastAutoFight:Boolean = pAiHandler.bAutoFight;

        switch (iAutoFightType) {
            case TYPE_NO_AUTO_FIGHT :
                if (bLastAutoFight || forceRefresh) {
                    setAutoFight(false);
                }
                break;
            case TYPE_FORCE_AUTO_FIGHT :
                if (!bLastAutoFight || forceRefresh) {
                    setAutoFight(true);
                }
                break;
            case TYPE_AUTO_FIGHT :
                if (forceRefresh) {
                    setAutoFight(isAutoForce);
                } else {
                    var pPlayHandler:CPlayHandler = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler);
                    if (!pPlayHandler) break;
                    var lastPlayerControlTime:int = pPlayHandler.lastControlTime;
//                    CTest.log("_____________________lastPlayerControlTime " + lastPlayerControlTime);

                    // ui控制时间
                    var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
                    var lastClickAutoTime:int = 0;
                    var lastClickManualTime:int = 0;
                    if (fightViewHandler) {
                        lastClickAutoTime = fightViewHandler.lastClickAutoTime;
                        lastClickManualTime = fightViewHandler.lastClickManualTime;
                    }

                    if (!bLastAutoFight) {
                        // 手动状态下
                        var pHero:CGameObject = _playHandler.hero;
                        if (pHero) {
                            var pSkillCaster : CSkillCaster = pHero.getComponentByClass( CSkillCaster , true ) as CSkillCaster;
                            if (pSkillCaster && pSkillCaster.isPlayingSkill()) {
                                _lastUseSkillTime = getTimer();
                            }
                        }

                        var iLastPlayerControlTime:Number = CMath.max(CMath.max(lastPlayerControlTime, lastClickManualTime), lastClickAutoTime);
                        iLastPlayerControlTime = CMath.max(iLastPlayerControlTime, _lastAutoChangeToManualTimeByClickToMoveTime);
                        iLastPlayerControlTime = CMath.max(iLastPlayerControlTime, _lastUseSkillTime);
                        iLastPlayerControlTime = CMath.max(iLastPlayerControlTime, _lastScenarioEndTime);
                        iLastPlayerControlTime = CMath.max(iLastPlayerControlTime, _lastClickTurnToMoveTime);
                        iLastPlayerControlTime = CMath.max(iLastPlayerControlTime, _lastWinAnimationEndTime);


                        if (iLastPlayerControlTime < _startTime) {
                            iLastPlayerControlTime = _startTime;
                        }
                        var iDeltaTime:Number = getTimer() - iLastPlayerControlTime;
                        var isNeedSetAutoFight:Boolean = iDeltaTime >= iAutoFightDelayTime * 1000;
                        if (isNeedSetAutoFight && isNeedSetAutoFight != bLastAutoFight) {
                            setAutoFight(isNeedSetAutoFight);
//                            trace("切自动战斗");
                        }

                    } else {
                        // 自动状态下
                        if (_lastClickTurnToMoveTime > 0 && _lastAutoChangeToManualTimeByClickToMoveTime != _lastClickTurnToMoveTime &&
                                _lastClickTurnToMoveTime > lastClickAutoTime) { // 在手动下, 点地面, 再点自动按钮, 会导致进入错误判断, 再切回手动
                            // 点鼠标移动
                            _lastAutoChangeToManualTimeByClickToMoveTime = _lastClickTurnToMoveTime;
                            _lastClickTurnToMoveTime = 0;
//                            trace("自动战斗因为点了地面移动, 切成自动战斗");
                            setAutoFight(false);
//                            CTest.log("_____________________自动战斗因为点了地面移动, 切成自动战斗");

                        } else {
                            if (lastPlayerControlTime > lastClickAutoTime && lastPlayerControlTime > lastClickManualTime) {
                                if (_lastScenarioEndTime >= lastPlayerControlTime || _lastWinAnimationEndTime >= lastPlayerControlTime) { // 剧情过程中的按钮无效
                                    lastPlayerControlTime = 0;
                                } else {
                                    // 键盘控制
                                    if (_lastAutoChangeToManualTimeByPlayerControll != lastPlayerControlTime) {
                                        _lastAutoChangeToManualTimeByPlayerControll = lastPlayerControlTime;
                                        setAutoFight(false);
                                        //
//                                        CTest.log("_____________________键盘控制, 切手动");
                                    }
                                }
                            }
                        }
                    }
                }


                break;
        }
    }

    public function setAutoFight(value:Boolean) : void {
        if (!_enable) return ;

        var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        aiHandler.bAutoFight = value;

        var iInstanceType:int = _system.instanceType;
        _autoFightStateList[iInstanceType.toString()] = aiHandler.bAutoFight;
//        trace("修改记录值为 : " + aiHandler.bAutoFight + "(超时设置)");

        // 设置UI
        var iAutoFightType:int = _autoFightType;

        var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);

        if (fightViewHandler) {
            switch (iAutoFightType) {
                case TYPE_NO_AUTO_FIGHT :
                    // visible = false;
                    fightViewHandler.setAutoBoxVisbible(false);
                    fightViewHandler.setForceManualFight(false);
                    break;
                case TYPE_FORCE_AUTO_FIGHT :
                    // visible = true;
                    fightViewHandler.setAutoFightVisible(false);
                    fightViewHandler.setManualFightVisible(true);
                    fightViewHandler.setAutoBoxVisbible(true);
                    fightViewHandler.setManualFightTips(CLang.Get("auto_fight_force"));
                    fightViewHandler.setForceManualFight(true);
                    break;
                case TYPE_AUTO_FIGHT :
                    // visible = true;
                    // state = value
                    fightViewHandler.setAutoBoxVisbible(true);
                    fightViewHandler.setAutoFightVisible(!value);
                    fightViewHandler.setManualFightVisible(value); // 当前正在自动战斗则显示手动
                    fightViewHandler.setManualFightTips(null);
                    fightViewHandler.setForceManualFight(false);

                    break;

            }

            fightViewHandler.updateAutoView();
        }
    }

    private function _onPlayStateChange(e:Event) : void {
        if (_system.isMainCity) return ;
        if (!(_system.instanceContent)) return ;
        if (!_enable) return ;

        // 屏蔽打开playHandler
        if (_autoFightType == TYPE_FORCE_AUTO_FIGHT) {
            if (e.type == "resetPlayState") {
                _system.setPlayEnable(false);
            }
        }
    }

    private function get _isRecordLastState() : Boolean {
        return _system.instanceManager.isRecordAutoState;
    }
    private function get _autoFightType() : int {
        var iAutoFightType:int = _system.instanceManager.autoFight;
        var fightViewHandler:CInstanceProcessViewHandler = system.stage.getSystem(CLobbySystem).getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler);
        if (fightViewHandler.getForceAutoFight()) {
            iAutoFightType = TYPE_FORCE_AUTO_FIGHT;
        }

        return iAutoFightType;
    }
    private function get _autoFightDelayTime() : int {
        return _system.instanceManager.autoFightTime; //单位秒
    }
    [Inline]
    private function get _system() : CInstanceSystem {
        return system as CInstanceSystem;
    }
    [Inline]
    private function get _scenarioSystem() : CScenarioSystem {
        return system.stage.getSystem(CScenarioSystem) as CScenarioSystem;
    }
    [Inline]
    private function get _playHandler() : CPlayHandler {
        return system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler;
    }
    public static const TYPE_NO_AUTO_FIGHT:int = 0; // 没有自动战斗
    public static const TYPE_AUTO_FIGHT:int = 1; // 有自动战斗
    public static const TYPE_FORCE_AUTO_FIGHT:int = 2; // 强制自动战斗

    private var _startTime:int;

    private var _autoFightStateList:Object; // 最后自动状态
    private var _lastScenarioEndTime:int; // 剧情播放完
    private var _lastClickTurnToMoveTime:int; // 点鼠标移动
    private var _lastWinAnimationEndTime:int; // 胜利动作播放完

    private var _lastAutoChangeToManualTimeByClickToMoveTime:int; // 最后一次因点鼠标移动人物，将自动转为手动的时间
    private var _lastAutoChangeToManualTimeByPlayerControll:int; // 最后一次因为控制人物, 将自动转为手动的时间
    private var _lastUseSkillTime:int; // 最后使用技能的时间


    public function setForcePause(v:Boolean) : void {
        if (!_enable) return ;

        _bForcePause = v;
        if (_bForcePause) {
            var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
            if (aiHandler.bAutoFight) {
                _refreshAutoFight(false, true);
                _bLastForcePauseState = true;
            }
        } else {
            if (_bLastForcePauseState) {
                _refreshAutoFight(true, true);
            }
            _bLastForcePauseState = false;
        }
    }

    [Inline]
    public function get enable() : Boolean {
        return _enable;
    }
    [Inline]
    public function set enable(v:Boolean) : void {
        _enable = v;
    }

    // 清除上一次自动状态. 新手引导用到
    public function set lastForcePauseState(v:Boolean) : void {
        _bLastForcePauseState = v;
        _lastScenarioEndTime = getTimer();
    }
    private var _enable:Boolean;
    private var _bForcePause:Boolean;
    private var _bLastForcePauseState:Boolean;

}
}
