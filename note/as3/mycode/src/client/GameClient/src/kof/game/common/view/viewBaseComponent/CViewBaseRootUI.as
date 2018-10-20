//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/9.
 */
package kof.game.common.view.viewBaseComponent {

import kof.framework.CViewHandler;

import morn.core.components.Button;
import morn.core.components.Dialog;

import morn.core.components.View;
import morn.core.handlers.Handler;

public class CViewBaseRootUI {
    public function CViewBaseRootUI(rootClass:*, isRoot:Boolean) {
        _isRoot = isRoot;
        if (_isRoot) {
            _rootUIClass = rootClass;
        }
    }

    public function dispose() : void {
        _rootUI = null;
        _rootUIList = null;
        _rootView = null;
    }

    public function create() : void {
        if (_isRoot) {
            if (_rootUIClass is Array) {
                _rootUIList = new Array((_rootUIClass as Array).length);
                (_rootUIClass as Array).forEach(function (item:Object, idx:int, arr:Array) : void {
                    _rootUIList[idx] = new item();
                });
                _onRootUiChange(_rootUIList[_uiTags]);
            } else if (_rootUIClass is Class){
                _onRootUiChange(new _rootUIClass());
            }
        }
    }

    public function show():void {
        if (_isRoot) {
            if (_rootUIClass is Array) {
                _onRootUiChange(_rootUIList[_uiTags]);
            }
            if (_rootUI.hasOwnProperty("close_btn")) {
                (_rootUI["close_btn"] as Button).clickHandler = new Handler(_onClose);
            } else if (_rootUI.hasOwnProperty("btn_close")) {
                (_rootUI["btn_close"] as Button).clickHandler = new Handler(_onClose);
            }
        }
    }
    public function hide() : void {
        if ( _rootUI ) {
            if ( _rootUI.hasOwnProperty( "close_btn" ) ) {
                (_rootUI[ "close_btn" ] as Button).clickHandler = null;
            } else if ( _rootUI.hasOwnProperty( "btn_close" ) ) {
                (_rootUI[ "btn_close" ] as Button).clickHandler = null;
            }
        }
        if ( _isRoot ) {
            if ( _rootUI is Dialog ) {
                (_rootUI as Dialog).close( Dialog.CLOSE );
            } else {
                if ( _rootUI && _rootUI.parent ) {
                    _rootUI.parent.removeChild( _rootUI );
                }
            }
        }
    }
    protected function _onClose() : void {
        if (_closeHandle) _closeHandle.execute();
    }
    protected function _onRootUiChange(v:View) : void {
        if (_rootUiChangeHandle) _rootUiChangeHandle.executeWith([v]);
    }

    public function set closeHandle(v:Handler) : void {
        _closeHandle = v;
    }
    public function set rootUiChangeHandle(v:Handler) : void {
        _rootUiChangeHandle = v;
    }
    public function setTags(v:int) : void { _uiTags = v; }
    final public function get rootUI() : View { return _rootUI; }
    public function set rootUI(v:View) : void { _rootUI = v; }
    public function set rootView(v:CViewHandler) : void { _rootView = v; }
    public function get rootView() : CViewHandler { return _rootView; }
    public function get isRoot() : Boolean { return _isRoot; }

    private var _rootUIClass:*; // rootUI资源Class, 可能是一个类数组, 可以选择使用哪个类
    private var _rootUI:View; // rootUI资源
    private var _rootUIList:Array; // rootUIClass为array时使用
    private var _uiTags:int; // 结果uilist使用, 指定使用哪个ui
    protected var _isRoot:Boolean; // 最上层窗口. _rootUI是在该窗口创建
    protected var _rootView:CViewHandler; // 最上级的窗口

    private var _closeHandle:Handler;
    private var _rootUiChangeHandle:Handler;

}
}
