//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/9.
 */
package kof.game.common.view.viewBaseComponent {


import QFLib.Interface.IDisposable;

import flash.display.Stage;

import kof.game.common.view.CViewBase;

import kof.game.common.view.Interface.IWindow;

import morn.core.components.View;


public class CViewBaseChildrenList implements IDisposable {
    public function CViewBaseChildrenList(viewBase:CViewBase, childListClass:Array) {
        _childListClass = childListClass;
        _pViewBase = viewBase;
    }

    public function dispose() : void {
        if (_childList) {
            for each (var child:CViewBase in _childList) {
                _pViewBase.viewManagerHandler.removeBean(child);
                 child.dispose();
            }
            _childList = null;
        }

        _pViewBase = null;
    }

    public function show() : void {
        if (_childList && _childList.length > 0) {
            for each (var child:CViewBase in _childList) {
                child.show();
            }
        }
    }
    public function showing() : void {
        if (_childList && _childList.length > 0) {
            for each (var child:CViewBase in _childList) {
                child.showing();
            }
        }
    }
    public function hide() : void {
        if (_childList && _childList.length > 0) {
            for each (var child:CViewBase in _childList) {
                child.hide();
            }
        }
    }
    public function invalidate() : void {
        for each (var child : CViewBase in _childList) {
            child.invalidate();
        }
    }

    public function create(root:CViewBase) : void {
        if (_childListClass && _childListClass.length > 0) {
            _childList = new Array(_childListClass.length);
            var child:CViewBase;
            for (var i:int = 0; i < _childListClass.length; i++) {
                child = _childList[i] = new (_childListClass[i])();
                _pViewBase.viewManagerHandler.addBean(child);
                child.buildByParent(root);
                child.create();
            }
        }
    }

    public function setData(data:Object, forceInvalid:Boolean = true) : void {
        for each (var child:CViewBase in _childList) {
            child.setData(data, forceInvalid);
        }
    }

    public function setNoneData() : void {
        for each (var child:CViewBase in _childList) {
            child.setNoneData();
        }
    }

    public function set flashStage(v:Stage) : void {
        if (_childList) {
            for each (var child:CViewBase in _childList) {
                child.flashStage = v;
            }
        }
    }

    public function set rootUI(v:View) : void {
        if (_childList) {
            for each (var child:CViewBase in _childList) {
                child.rootUI = v;
            }
        }
    }

    public function get childList() : Array {
        return _childList;
    }
    public function getChild(type:int) : IWindow {
        if (_childList && _childList.length > type) return _childList[type];
        return null;
    }
    public function getChildByType(clazz:Class) : IWindow {
        for each (var child:CViewBase in _childList) {
            if (child is clazz) {
                return child
            }
        }
        return null;
    }


    private var _childList:Array; // 子窗体, 使用_rootUI进行分层
    private var _childListClass:Array; // 子窗体, 类
    private var _pViewBase:CViewBase;

}
}
