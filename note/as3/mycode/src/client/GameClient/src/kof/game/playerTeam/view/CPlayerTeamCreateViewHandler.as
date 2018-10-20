//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/17.
 */
package kof.game.playerTeam.view {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import kof.game.common.CLang;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndResType;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.CRootView;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.ui.master.player_team.TeamSetUpUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;


public class CPlayerTeamCreateViewHandler extends CRootView {

    public function CPlayerTeamCreateViewHandler() {
        super(TeamSetUpUI, null, EPlayerWndResType.PLAYER_TEAM_CREATE, false);
    }

    protected override function _onCreate() : void {
        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
        ui.ok_btn.label = CLang.Get("common_ok");
    }
    protected override function _onDispose() : void {
        super._onDispose();

        _coundDownComponent.dispose();
        _coundDownComponent = null;
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        this.listEnterFrameEvent = true;

        _onRandomName();

        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
//        ui.intro_label.text = CLang.Get("player_team_input_title");
        ui.team_name_input_label.textField.addEventListener(KeyboardEvent.KEY_UP, _onKeyboard);
        ui.team_name_input_label.text = "";
        ui.team_name_input_label.addEventListener(Event.CHANGE, _onTextChange);
        ui.team_name_input_label.textField.addEventListener(FocusEvent.FOCUS_IN, _onFocus);
        ui.team_name_input_label.textField.addEventListener(FocusEvent.FOCUS_OUT, _onFocus);
        ui.team_name_input_label.textField.addEventListener(MouseEvent.CLICK, _onMouseEvent);
        ui.team_name_input_label.textField.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseEvent);
        ui.team_name_input_label.textField.addEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);
        _lastText = "";

        ui.random_name_btn.clickHandler = new Handler(_onRandomName);
        ui.ok_btn.clickHandler = new Handler(_onOk);
        _coundDownComponent = new CCountDownCompoent(this, ui.ok_btn, 30000, _onCountDownEnd, CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));

        _isFirst = true;
        _startSelect = false;
        _resendTime = 0;
        _normalRandomNextUpdate = false;
        _speceilRandomNameNextUpdate = false;

        system.stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.ERROR, _onError);
        App.stage.addEventListener(KeyboardEvent.KEY_UP, _onPlayerControl);
        App.stage.addEventListener(MouseEvent.CLICK, _onPlayerControl);

        _lastRandomTime = 0;
    }

    protected override function _onHide() : void {
        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
        ui.random_name_btn.clickHandler = null;
        ui.ok_btn.clickHandler = null;
        ui.team_name_input_label.textField.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboard);
        ui.team_name_input_label.removeEventListener(Event.CHANGE, _onTextChange);
        ui.team_name_input_label.textField.removeEventListener(FocusEvent.FOCUS_IN, _onFocus);
        ui.team_name_input_label.textField.removeEventListener(FocusEvent.FOCUS_OUT, _onFocus);
        ui.team_name_input_label.textField.removeEventListener(MouseEvent.CLICK, _onMouseEvent);
        ui.team_name_input_label.textField.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseEvent);
        ui.team_name_input_label.textField.removeEventListener(MouseEvent.MOUSE_UP, _onMouseEvent);
        _lastText = "";
        system.stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.ERROR, _onError);
        App.stage.removeEventListener(KeyboardEvent.KEY_UP, _onPlayerControl);
        App.stage.removeEventListener(MouseEvent.CLICK, _onPlayerControl);

        _coundDownComponent.dispose();
    }

    private function _onPlayerControl(e:Event) : void {
        if ( e is KeyboardEvent ) {
            var pKeyboardEvt:KeyboardEvent = e as KeyboardEvent;
            if (pKeyboardEvt.type == KeyboardEvent.KEY_UP && pKeyboardEvt.keyCode == Keyboard.ENTER) {
                this.dispatchEvent(new CViewEvent(CViewEvent.OK));
                return ;
            }
        }
        _refreshCountDown();
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _coundDownComponent.tick();
    }
    private function _onCountDownEnd() : void {
        this.dispatchEvent(new CViewEvent(CViewEvent.OK));
    }
    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
        var playerData:CPlayerData = _data as CPlayerData;


        this.addToPopupDialog();
        if (_isFirst && ui.stage) {
            _isFirst = false;
            ui.stage.focus = ui.team_name_input_label.textField;
        }

        // 重新随机并启动自动倒时发改名
        if (_normalRandomNextUpdate) {
            _refreshCountDown();
        } else if (_speceilRandomNameNextUpdate) {
            var randomLen:int = 8 - playerData.randomName.length;
            if (randomLen > 0) {
                var randomKey:int = Math.random() * 9999 + 1;
                var strRandomKey:String = randomKey.toString();
                if (strRandomKey.length > randomLen) {
                    strRandomKey = strRandomKey.substr(0, randomLen);
                }
                playerData.updateRandomName(playerData.randomName + strRandomKey);
            }

            _refreshCountDown();
        }
        _normalRandomNextUpdate = false;
        _speceilRandomNameNextUpdate = false;

        ui.team_name_input_label.maxChars = playerData.playerConstant.NAME_LIMIT;
        if (playerData.randomName && playerData.randomName.length > 0) {
            _lastText = ui.team_name_input_label.text = playerData.randomName;
        }
        ui.ok_btn.disabled = ui.team_name_input_label.text.length == 0 || CLang.Get("player_input_team_name") == ui.team_name_input_label.text;

        return true;
    }
    private var _isFirst:Boolean = true;

    private var _lastRandomTime:int;
    private function _onRandomName() : void {
        var curTime:int = getTimer();
        if (curTime - _lastRandomTime > 2000) {
            _lastRandomTime = getTimer();
            this.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_RANDOM_NAME_CLICK));
        } else {
            uiCanvas.showMsgAlert(CLang.Get("clientLockTips2"));
        }
    }

    private function _onOk() : void {
        this.dispatchEvent(new CViewEvent(CViewEvent.OK));

    }
    private function _onTextChange(e:Event) : void {
        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
        var isEmpty:Boolean = ui.team_name_input_label.text.length == 0 || CLang.Get("player_input_team_name") == ui.team_name_input_label.text;
        ui.ok_btn.disabled = isEmpty;
        if (isEmpty) {
            ObjectUtils.gray(ui.team_name_input_label, true);
        } else {
            ObjectUtils.gray(ui.team_name_input_label, false);
        }
        var charLength:int = CLang.getStringCharLength(ui.team_name_input_label.text);
        if (charLength > ui.team_name_input_label.maxChars) {
            ui.team_name_input_label.text = _lastText;
            return ;
        }
        _lastText = ui.team_name_input_label.text;
    }

    private function _onFocus(e:FocusEvent) : void {
        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
        if (e.type == FocusEvent.FOCUS_IN) {
//            if (ui.team_name_input_label.text == CLang.Get("player_input_team_name")) {
//                ui.team_name_input_label.text = "";
//            }
            _startSelect = true;

        } else if (e.type == FocusEvent.FOCUS_OUT) {
//            if (ui.team_name_input_label.text.length == 0) {
//                ui.team_name_input_label.text = CLang.Get("player_input_team_name");
//            }
            _startSelect = false;

            system.stage.flashStage.focus = null;
        }
    }
    private function _onMouseEvent(e:MouseEvent) : void {
        if (MouseEvent.MOUSE_DOWN == e.type) {

        } else if (MouseEvent.MOUSE_UP == e.type) {

        } else if (MouseEvent.CLICK == e.type) {
            if (_startSelect) {
                _startSelect = false;
                var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
//                ui.team_name_input_label.textField.setSelection(ui.team_name_input_label.textField.length-1, ui.team_name_input_label.textField.length-1);
                ui.team_name_input_label.textField.setSelection(0, ui.team_name_input_label.textField.length);
            }
            _refreshCountDown();
        }
//        trace("________________________eventType" + e.type);
    }

    private function _onKeyboard(e:KeyboardEvent) : void{
        if ( e.type == KeyboardEvent.KEY_UP && e.keyCode == Keyboard.ENTER) {
            this.dispatchEvent(new CViewEvent(CViewEvent.OK));

            system.stage.flashStage.focus = null;
        }
        _refreshCountDown();

    }

    private function _onError(e:CPlayerEvent) : void {
        if (_resendTime < 5) {
            _normalRandomNextUpdate = true;
            _onRandomName();

        } else if (_resendTime < 20) {
            _speceilRandomNameNextUpdate = true;
            _onRandomName();
        } else {
            // ...终止
        }
        _resendTime++;
    }

    private function _refreshCountDown() : void {
        _coundDownComponent = new CCountDownCompoent(this, _ui.ok_btn, 30000, _onCountDownEnd, CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));
    }

    private function get _ui() : TeamSetUpUI {
        var ui:TeamSetUpUI = rootUI as TeamSetUpUI;
        return ui;
    }
    private var _lastText:String;

    public var _lastSendName:String;

    private var _coundDownComponent:CCountDownCompoent;
    private var _startSelect:Boolean = false;
    private var _resendTime:int = 0;

    private var _normalRandomNextUpdate:Boolean;
    private var _speceilRandomNameNextUpdate:Boolean;

}
}

