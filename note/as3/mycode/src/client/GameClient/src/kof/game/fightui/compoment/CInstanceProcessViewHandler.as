//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/28.
 */
package kof.game.fightui.compoment {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import kof.framework.CViewHandler;
import kof.game.character.ai.CAIHandler;
import kof.game.common.CLang;
import kof.game.core.CECSLoop;
import kof.game.instance.CInstanceAutoFightHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.ui.IUICanvas;
import kof.ui.demo.FightUI;

import morn.core.components.Button;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CInstanceProcessViewHandler extends CViewHandler {

    private var m_fightUI:FightUI;

    public function CInstanceProcessViewHandler($fightUI:FightUI) {
        super();
        m_fightUI = $fightUI;
        _exitButton.clickHandler = new Handler(_onClickExit);
    }

    public function show():void {
        _isDowning = false;
        if (null == _instanceFacade) {
            _instanceFacade = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        }

        if (_instanceFacade && _instanceFacade.instanceContent) {
            if (!_instanceFacade.isMainCity) {
                if ((_instanceFacade.getBean(CInstanceAutoFightHandler ) as CInstanceAutoFightHandler).enable) { // autoFightHandler会先处理
                    App.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 999);
                    App.stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp );

                    m_fightUI.auto_img.addEventListener(MouseEvent.CLICK, _onAuto); // 切到手动
                    m_fightUI.manual_clip.addEventListener(MouseEvent.CLICK, _onManual); // 切到自动
                }
            }

            if (otherForceHide) {
                _exitButton.visible = false;
            } else {
                ObjectUtils.gray(_exitButton, false);
                _exitButton.mouseEnabled = true;
                if (_instanceFacade.exitRecord) {
                    if (_instanceFacade.exitRecord.ExitIcon > 0) {
                        if (_instanceFacade.exitRecord.ExitType == 0) {
                            // 默认直接显示
                            _exitButton.visible = true;
                        } else if (_instanceFacade.exitRecord.ExitType == 1) {
                            // 延迟显示
                            _exitButton.visible = false;
                            var delayTime:int = _instanceFacade.exitRecord.DelayShowTime;
                            if (delayTime <= 0) {
                                _exitButton.visible = true;
                            } else {
                                if (_instanceFacade.isStart) {
                                    var fDelayShowTime:Number = delayTime/1000;
                                    delayCall(fDelayShowTime, _onDelayShowExitBtn);
                                } else {
                                    var on_instance_started_handler:Function = function (e:Event) : void {
                                        _instanceFacade.removeEventListener(CInstanceEvent.LEVEL_STARTED, on_instance_started_handler);
                                        var fDelayShowTime:Number = delayTime/1000;
                                        delayCall(fDelayShowTime, _onDelayShowExitBtn);
                                    };
                                    _instanceFacade.addEventListener(CInstanceEvent.LEVEL_STARTED, on_instance_started_handler);
                                }
                            }
                        }
                    } else {
                        _exitButton.visible = false;
                    }
                    _exitButton.label = _instanceFacade.exitRecord.IconName;
                } else {
                    _exitButton.visible = false;
                }

                _instanceFacade.listenEvent(_onOver);
            }
        }
    }
    private function _onDelayShowExitBtn() : void {
        _exitButton.visible = true; // 要处理下. 加条件判断
    }
    public function hide(removed:Boolean = true):void {
        _exitButton.visible = false;
        App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
        App.stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp );

        m_fightUI.auto_img.removeEventListener(MouseEvent.CLICK, _onAuto); // 切到手动
        m_fightUI.manual_clip.removeEventListener(MouseEvent.CLICK, _onManual); // 切到自动
    }

    private function _onOver(e:CInstanceEvent) : void {
        var pInstance:IInstanceFacade = e.currentTarget as IInstanceFacade;
        if (e.type == CInstanceEvent.NET_EVENT_INSTANCE_OVER) {
            pInstance.unListenEvent(_onOver);
            _exitButton.visible = false;
        }
    }

    private function _onClickExit() : void {
        var uiCanvas:IUICanvas = system.stage.getSystem(IUICanvas) as IUICanvas;
        if (uiCanvas) {
            uiCanvas.showMsgBox(CLang.Get(_instanceFacade.exitRecord.Language), _onExit);
        } else {
            _onExit();
        }
    }
    private function _onExit() : void {
        if (_instanceFacade) {
            var isCanExit:Boolean = true;
            if (isCanExit) {
                ObjectUtils.gray(_exitButton, true);
                _exitButton.mouseEnabled = false;
                _instanceFacade.listenEvent(_onStopInstanceResult);
                _instanceFacade.stopInstance();
            }
        }
    }
    private function _onStopInstanceResult(e:CInstanceEvent) : void {
        var pInstance:IInstanceFacade = e.currentTarget as IInstanceFacade;
        if (e.type == CInstanceEvent.STOP_INSTANCE) {
            var isSucess:Boolean = e.data as Boolean;
            if (!isSucess) {
                // 退出失败, 恢复暂停
                ObjectUtils.gray(_exitButton, false);
                _exitButton.mouseEnabled = true;
            }
            pInstance.unListenEvent(_onStopInstanceResult);
        }
    }
    private function get _exitButton() : Button {
        return m_fightUI.exit_instance_btn;
    }

    // ======================================== 自动战斗 ========================================
    private function _onKeyDown(e:KeyboardEvent) : void {
        if (forceStopZ) return ;
        if ( e.keyCode == Keyboard.Z) {
            // 切自动战斗             // 自动的情况下。按z键 本身就会被处理为手动

            e.stopImmediatePropagation();
            if (_isDowning) return ;
            // 优化于战斗的按键事件。并停止按钮事件
            // auto_img.visible 不太对。但为了处理像剧情之类的情况。
            var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
            if (m_fightUI.manual_clip.visible && aiHandler.bAutoFight) {
                // 正在自动
                m_fightUI.manual_clip.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            } else if (m_fightUI.auto_img.visible && aiHandler.bAutoFight == false)  {
                // 正在手动
                m_fightUI.auto_img.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            }
            _isDowning = true;
        }
    }
    private var _isDowning:Boolean;
    private function _onKeyUp(e:KeyboardEvent) : void {
        if ( e.keyCode == Keyboard.Z) {
            e.stopImmediatePropagation();
        }
        _isDowning = false;

    }
    private function _onAuto(e:Event) : void {
        if (_isForceManualFight) return ;
        if (_isForceAutoFight) return ;

        var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        aiHandler.bAutoFight = true;
        _bAutoFightVisible = false;
        _bManualFightVisible = true;
        _lastClickAutoTime = getTimer();

        updateAutoView();
        dispatchEvent(new Event("changeAuto"));
    }
    private function _onManual(e:Event) : void {
        if (_isForceManualFight) return ;
        if (_isForceAutoFight) return ;

        var aiHandler:CAIHandler = system.stage.getSystem(CECSLoop).getBean(CAIHandler) as CAIHandler;
        aiHandler.bAutoFight = false;
        _bAutoFightVisible = true;
        _bManualFightVisible = false;
        _lastClickManualTime = getTimer();
        updateAutoView();
        dispatchEvent(new Event("changeAuto"));
    }
    // 因为二级条件不满足。但是又要显示自动战斗
    public function updateAutoViewBySubLevelNotOpen(vipLevel:int, playerLevel:int, openVipLevel:int, openSubLevel:int) : void {
        m_fightUI.auto_img.visible = true;
        m_fightUI.manual_clip.visible = false;
        m_fightUI.auto_open_cond_box.visible = true;
        m_fightUI.auto_z_clip.visible = false;
        m_fightUI.box_autoFight.visible = false;
        m_fightUI.auto_img.removeEventListener(MouseEvent.CLICK, _onAuto); // 切到手动
        m_fightUI.manual_clip.removeEventListener(MouseEvent.CLICK, _onManual); // 切到自动
        App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
        App.stage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyUp );

        var vipLevelNotEnough:Boolean = vipLevel < openVipLevel;
        var subLevelNotEnough:Boolean = playerLevel < openSubLevel;
        if (vipLevelNotEnough && subLevelNotEnough) {
            m_fightUI.auto_open_cond_txt.text = CLang.Get("auto_fight_sublevel_viplv_not_enough", {v1:openSubLevel, v2:openVipLevel})
        } else if (vipLevelNotEnough) {
            m_fightUI.auto_open_cond_txt.text = CLang.Get("auto_fight_viplv_not_enough", {v1:openVipLevel})
        } else {
            m_fightUI.auto_open_cond_txt.text = CLang.Get("auto_fight_sublevel_not_enough", {v1:openSubLevel})
        }
        m_fightUI.auto_open_cond_txt.centerX = m_fightUI.auto_open_cond_txt.centerX;
        m_fightUI.auto_open_cond_box.centerX = m_fightUI.auto_open_cond_box.centerX;
    }
    public function updateAutoView() : void {
        if (!_bAutoBoxVisbible) {
            m_fightUI.auto_img.visible = m_fightUI.manual_clip.visible = false;
            m_fightUI.auto_open_cond_box.visible = false;
            m_fightUI.auto_z_clip.visible = false;
        } else {
            m_fightUI.auto_img.visible = _bAutoFightVisible;
            m_fightUI.manual_clip.visible = _bManualFightVisible;
            m_fightUI.auto_open_cond_box.visible = false;
            m_fightUI.auto_z_clip.visible = true;
            if (!_bManualFightVisible) {
                m_fightUI.auto_z_clip.index = 0;
            } else {
                m_fightUI.auto_z_clip.index = 1;

            }
//            m_fightUI.auto_z_clip.visible = false;
        }

        m_fightUI.manual_clip.toolTip = _sManualTips;

        //
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var isArena:Boolean;
        if ( pInstanceSystem ) {
            isArena = EInstanceType.isArena( pInstanceSystem.instanceType );
        }
        m_fightUI.box_autoFight.visible = isArena;
        if( isArena ){
            m_fightUI.auto_img.visible =
                    m_fightUI.manual_clip.visible =
                            m_fightUI.box_selfAtk.visible = false;
            m_fightUI.auto_open_cond_box.visible = false;
            m_fightUI.auto_z_clip.visible = false;
        }else{
            m_fightUI.box_selfAtk.visible = true;
        }
    }

    public function setAutoFightVisible(v:Boolean) : void {
        _bAutoFightVisible = v;
    }
    public function setManualFightVisible(v:Boolean) : void {
        _bManualFightVisible = v;
    }
    public function setAutoBoxVisbible(v:Boolean) : void {
        _bAutoBoxVisbible = v;
    }
    public function setManualFightTips(v:String) : void {
        _sManualTips = v;
    }
    public function get otherForceHide():Boolean {
        return _otherForceHide;
    }
    public function set otherForceHide(value:Boolean):void {
        _otherForceHide = value;
    }
    public function get lastClickAutoTime() : int {
        return _lastClickAutoTime;
    }
    public function get lastClickManualTime() : int {
        return _lastClickManualTime;
    }
    public function setForceManualFight(v:Boolean) : void {
        _isForceManualFight = v;
    }
    public function setForceAutoFight(v:Boolean) : void {
        _isForceAutoFight = v;
    }
    public function getForceAutoFight() : Boolean {
        return _isForceAutoFight;
    }

    public function showCondition() : void {
        m_fightUI.auto_open_cond_box.visible = true;
    }
    public function hideCondition() : void {
        m_fightUI.auto_open_cond_box.visible = false;
    }

    private var _otherForceHide:Boolean;
    private var _bAutoFightVisible:Boolean;
    private var _bManualFightVisible:Boolean;
    private var _bAutoBoxVisbible:Boolean;
    private var _sManualTips:String;
    private var _lastClickAutoTime:int;
    private var _lastClickManualTime:int;
    private var _instanceFacade:CInstanceSystem;
    private var _isForceManualFight:Boolean; // 强制手动
    private var _isForceAutoFight:Boolean; // 强制自动
    public var forceStopZ:Boolean;


    private var _stopBySubCond:Boolean;

}
}
