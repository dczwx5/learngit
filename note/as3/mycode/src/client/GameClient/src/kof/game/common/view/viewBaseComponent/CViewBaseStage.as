//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/9.
 */
package kof.game.common.view.viewBaseComponent {

import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.view.CViewBase;

import morn.core.handlers.Handler;

public class CViewBaseStage {
    public function CViewBaseStage(view:CViewBase) {
        _view = view;
    }

    public function dispose() : void {
        if (_flashStage) {
            _flashStage.removeEventListener(Event.RESIZE, _onResize);
//            _flashStage.removeEventListener(Event.RENDER, _onRender);

            if (_listenEnterFrameEvent) {
                listEnterFrameEvent = false;
            }
            if (_view) _view.rootUI.removeEventListener(MouseEvent.CLICK, _onStageClick);
        }
//        _isDirty = false;
        _view = null;

    }

    public function show() : void {
        if (_flashStage) {
            _flashStage.addEventListener(Event.RESIZE, _onResize);

            if (_listStageClickEvent) {
                _view.rootUI.addEventListener(MouseEvent.CLICK, _onStageClick);
            }
        }
    }
    public function hide() : void {
        if (_flashStage) {
            _flashStage.removeEventListener(Event.RESIZE, _onResize);
//            this._flashStage.removeEventListener(Event.RENDER, _onRender);
            if (_listenEnterFrameEvent) {
                this.listEnterFrameEvent = false;
            }
            if (_listStageClickEvent) {
                _view.rootUI.removeEventListener(MouseEvent.CLICK, _onStageClick);
            }
        }
//        _isDirty = false; // 同步, 保护处理
        _flashStage = null;
    }
    protected function _onEnterFrame(delay:Number) : void {
        if (_enterFrameHandle) _enterFrameHandle.executeWith([delay]);
    }
    protected function _onStageClick(e:MouseEvent) : void {
        if (_stageClickHandle) _stageClickHandle.executeWith([e]);
    }
    protected function _onResize(e:Event) : void {
        if (_resizeHandle) _resizeHandle.executeWith([e]);
    }

    // ====valid====
//    public function isInvalid() : Boolean {
//        return _isDirty;
//    }
//    public function isValid() : Boolean {
//        return _isDirty == false;
//    }
//    public function validate() : void {
//        _isDirty = false;
//        if (_flashStage) this._flashStage.removeEventListener(Event.RENDER, _onRender);
//
//    }
    public function invalidate() : void {
        if (_view.viewManagerHandler) {
            _view.viewManagerHandler.invalidWindow(_onRender);
        }
//
//        _isDirty = true;
//        if (_flashStage) {
//            _flashStage.invalidate();
//            this._flashStage.removeEventListener(Event.RENDER, _onRender);
//            this._flashStage.addEventListener(Event.RENDER, _onRender);
//        }
    }
//    public function invalidateStage() : void {
//        if (_flashStage) _flashStage.invalidate();
//    }
    protected function _onRender() : void {
        if (_renderHandle) _renderHandle.execute();
    }
//    public function removeRenderEvent() : void {
//        this._flashStage.removeEventListener(Event.RENDER, _onRender);
//    }

    public function set renderHandle(v:Handler) : void {
        _renderHandle = v;
    }
    public function set resizeHandle(v:Handler) : void {
        _resizeHandle = v;
    }
    public function set stageClickHandle(v:Handler) : void {
        _stageClickHandle = v;
    }
    public function set enterFrameHandle(v:Handler) : void {
        _enterFrameHandle = v;
    }
    public function set listEnterFrameEvent(v:Boolean) : void {
        _listenEnterFrameEvent = v;
        if (v) {
            _view.addTick(_onEnterFrame);
        } else {
            _view.viewManagerHandler.removeTick(_onEnterFrame);
        }
    }
    public function set listStageClick(v:Boolean) : void { _listStageClickEvent = v; }
    public function get flashStage() : Stage { return _flashStage; }
    public function set flashStage(v:Stage) : void { _flashStage = v; }

    private var _listenEnterFrameEvent:Boolean = false; // 是否需要处理enterFrame
    private var _listStageClickEvent:Boolean = false; // 是否监听stage.click
    private var _flashStage:Stage;
//    private var _isDirty:Boolean; // 父窗口dirty, 子窗口也必然dirty, updateWindow将在下一帧调用
    private var _view:CViewBase;

    private var _renderHandle:Handler;
    private var _resizeHandle:Handler;
    private var _stageClickHandle:Handler;
    private var _enterFrameHandle:Handler;
}
}
