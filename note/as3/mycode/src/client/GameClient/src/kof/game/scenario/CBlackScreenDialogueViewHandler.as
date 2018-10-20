//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/20.
 */
package kof.game.scenario {
import QFLib.Foundation.CKeyboard;

import com.greensock.TimelineLite;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import kof.framework.CAppStage;
import kof.ui.CUISystem;
import kof.ui.demo.BlackScreenDialogUI;

/**
 * 剧情黑幕对话
 */
public class CBlackScreenDialogueViewHandler extends CBaseDialogueViewHandler {

    public var m_blackDialogueUI:BlackScreenDialogUI;
    private var m_theKeyboard:CKeyboard;

    private static const TIME_ON_ALLSHOW:Number = 3.0;
    private var _strIndex:int;
    private var _time:Number = 0.0;

    private var _callBackFun:Function;
    private static const MAX_ALPHA:Number = 1;
    private var _timeline:TimelineLite;

    public function CBlackScreenDialogueViewHandler() {
        super(true);
    }

    override public function get viewClass():Array {
        return [BlackScreenDialogUI];
    }

    override protected function onAssetsLoadCompleted():void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView():Boolean {
        if (!m_blackDialogueUI) {
            m_blackDialogueUI = new BlackScreenDialogUI();

            m_blackDialogueUI.addEventListener(Event.ADDED_TO_STAGE, _onAddStage);
            m_blackDialogueUI.addEventListener(Event.REMOVED_FROM_STAGE, _onRemoveStage);

        }
        return Boolean(m_blackDialogueUI);
    }

    override public function show(callBackFun:Function = null):void {
        _callBackFun = callBackFun;

        m_blackDialogueUI.txt_content.text = "";
        if (display == 1) {
            _strIndex = 0;
            _time = 0.0;
        } else {
            _time = 0.0;
            m_blackDialogueUI.txt_content.text = content;
        }

        _onStageResize(null);
        m_blackDialogueUI.img_mask.alpha = MAX_ALPHA;

        if (_timeline) {
            _timeline.stop();
            _timeline = null;
        }

        if (!m_blackDialogueUI.parent) {
            _timeline = new TimelineLite();
            _timeline.stop();

            m_blackDialogueUI.img_mask.alpha = 0;
            _timeline.append(new TweenLite(m_blackDialogueUI.img_mask, 2, {alpha: MAX_ALPHA}));
            _timeline.append(new TweenLite(m_blackDialogueUI.img_mask, 3, {alpha: 1, onComplete: _onComplete}));
            _timeline.play();
        }

        (uiCanvas as CUISystem).plotLayer.popup(m_blackDialogueUI);

        schedule(1.0 / 30, this.update);
    }

    override protected function enterStage(appStage:CAppStage):void {
        super.enterStage(appStage);

//        if (appStage) {
//            appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
//            appStage.flashStage.addEventListener(MouseEvent.CLICK, _ck);
//        }
//        if (!m_theKeyboard) {
//            m_theKeyboard = new CKeyboard(appStage.flashStage);
//            m_theKeyboard.registerKeyCode(true, Keyboard.J, _enterKeySpace);
//        }
    }

    override protected function exitStage(appStage:CAppStage):void {
        super.exitStage(appStage);

//        appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
//        if (m_theKeyboard) {
//            m_theKeyboard.unregisterKeyCode(true, Keyboard.J, _enterKeySpace);
//            m_theKeyboard.dispose();
//            m_theKeyboard = null;
//        }
    }

    private function _ck( evt : MouseEvent ) : void {
        if ( display != 0 ) {
            display = 0;
            m_blackDialogueUI.txt_content.text = content;
            return;
        }
        onFinish();
    }

    private function _enterKeySpace( keyCode : int ) : void {
        if ( display != 0 ) {
            display = 0;
            m_blackDialogueUI.txt_content.text = content;
            return;
        }
        if ( keyCode == Keyboard.SPACE ) {
            onFinish();
        }
    }

    private function _onComplete(...params):void {
        hide();
        if (_callBackFun) {
            _callBackFun.apply();
        }
    }

    private function _onAddStage(e:Event):void {
        system.stage.flashStage.addEventListener(Event.RESIZE, _onStageResize, false, 0, true);
    }

    private function _onRemoveStage(e:Event):void {
        system.stage.flashStage.removeEventListener(Event.RESIZE, _onStageResize);
    }

    private function _onStageResize(e:Event = null):void {
        if (m_blackDialogueUI) {
            m_blackDialogueUI.img_mask.width = system.stage.flashStage.stageWidth;
            m_blackDialogueUI.img_mask.height = system.stage.flashStage.stageHeight;
            m_blackDialogueUI.txt_content.width = int((system.stage.flashStage.stageWidth * 978) / 1500);
            m_blackDialogueUI.txt_content.centerX = 0;
            m_blackDialogueUI.txt_content.centerY = 0;
        }
    }

    private function onFinish():void {
        if (_callBackFun) {
            _callBackFun.apply();
        }
    }

    private function showStrOneByOne():void {
        if (!m_blackDialogueUI || !m_blackDialogueUI.parent)
            return;
        if (_strIndex >= content.length && _time >= TIME_ON_ALLSHOW) {
            onFinish();
            return;
        }
        m_blackDialogueUI.txt_content.text += content.charAt(_strIndex);
    }

    override public function update(delta:Number):void {
        _time += delta;
        if (display && _time >= rate * _strIndex) {
            showStrOneByOne();
            _strIndex++;
        } else if (!display && _time >= TIME_ON_ALLSHOW) {
            onFinish();
        }
    }

    override public function hide():void {
        if (_timeline)
            _timeline.stop();
        _timeline = null;

        unschedule(this.update);
        (uiCanvas as CUISystem).plotLayer.close(m_blackDialogueUI);
    }
}
}
