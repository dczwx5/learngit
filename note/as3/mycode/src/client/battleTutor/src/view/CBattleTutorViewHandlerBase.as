//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.view.component.CCountDownCompoent;

import morn.core.components.Button;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CBattleTutorViewHandlerBase extends CViewHandler {
    protected var _ui:Component;
    public var updateHandler:Handler;
    public var closeHandler:Handler;
    public var addedHandler:Handler;

    protected var _uiClazz:Class;
    protected var _isViewInitialized:Boolean;

    public function CBattleTutorViewHandlerBase(uiClazz:Class) {
        super (false);
        _uiClazz = uiClazz;
    }

    override public function dispose():void {
        super.dispose();

        removeDisplay();
        _ui = null;
    }

//    // 没用, onInitializeView会反复调用
//    override protected function onAssetsLoadCompleted():void {
//        super.onAssetsLoadCompleted();
//        this.onInitializeView();
//    }


    // show
    public function addDisplay():void {
        this.loadAssetsByView(viewClass, _showDisplay);
    }
    protected function _showDisplay():void {
        if (onInitializeView()) {
            invalidate();
            callLater(_addToDisplay);
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg("Initialized \"" + viewClass + "\" failed by requesting display shown.");
        }
    }
    override protected function onInitializeView():Boolean {
        if (!super.onInitializeView())
            return false;

        if (!_isViewInitialized) {
            if (!_ui) {
                _ui = new _uiClazz();
                _isViewInitialized = true;
            }
        }

        return _isViewInitialized;
    }

    private function _addToDisplay():void {
        if (_ui is Dialog) {
            if (isShowMask) {
                uiCanvas.addPopupDialog(_ui);
            } else {
                uiCanvas.addDialog(_ui);
            }
        } else {
            uiCanvas.rootContainer.addChild(_ui);
        }
        _onAdded();
        if (addedHandler) {
            addedHandler.execute();
        }
    }

    protected virtual function _onAdded() : void {

    }

    // update
    override protected virtual function updateData():void {
        super.updateData();

        if (updateHandler) {
            updateHandler.execute();
        }
    }

    // hide
    public function removeDisplay():void {
        if (_ui) {
            if (_countDownComponent) {
                _countDownComponent.dispose();
                _countDownComponent = null;
            }
            system.stage.flashStage.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);

            _onRemoved();
            if (closeHandler) {
                closeHandler.execute();
            }
            if (_ui is Dialog) {
                (_ui as Dialog).close(Dialog.CLOSE);
            } else {
                if (_ui.parent) {
                    _ui.parent.removeChild(_ui);
                }
            }
        }
    }
    protected virtual function _onRemoved() : void {
    }

    public function startCountDown(countDownCallback:Function) : void {
        if (forceStopCountDown) return ;

        _countDownCallback = countDownCallback;
        if (okBtn) {
            if (_countDownComponent) {
                _countDownComponent.dispose();
                _countDownComponent = null;
            }
            system.stage.flashStage.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
            system.stage.flashStage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
            _countDownComponent = new CCountDownCompoent(null, okBtn, 60000, _onCountDownEnd,
                    CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));
        }
    }
    protected function _onEnterFrame(delta:Number) : void {
        if (_countDownComponent) {
            _countDownComponent.tick();
        }
    }
    protected function _onCountDownEnd() : void {
        system.stage.flashStage.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
        if (_countDownCallback) {
            _countDownCallback.apply();
        }
    }
    [Inline]
    public function getUI() : Component {
        return _ui;
    }
    public function isShowed() : Boolean {
        return _ui && _ui.parent != null;
    }

    public function get okBtn() : Button {
        return _ui["ok_btn"];
    }
    public var isShowMask:Boolean;
    private var _countDownComponent:CCountDownCompoent;
    private var _countDownCallback:Function;

    public var forceStopCountDown:Boolean = false;

}
}
