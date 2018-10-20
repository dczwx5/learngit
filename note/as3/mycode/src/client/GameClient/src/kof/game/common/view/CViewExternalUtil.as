//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/27.
 */
package kof.game.common.view {

import flash.events.IEventDispatcher;

import kof.framework.CViewHandler;

import kof.framework.CViewHandler;

import kof.ui.IUICanvas;

import morn.core.components.View;

// 封装外部使用viewBase结 ：CInstanceIntroTips
// 或 : 动态需要使用viewbase的情况 : 如CInstanceSweepView, 双重list
public class CViewExternalUtil {
    // viewClass : 需要封装的view : 如CRewardItemListView
    // rootView : 顶层窗口 : 如CInstanceIntroTips, 用于发事件
    // rootUI : viewClass所使用的ui : 如InstanceLevelTipsUI
    // ============================simple : ======================================
    // _viewExternal = new CViewExternalUtil(CRewardItemListView, this, _ui);
    // _viewExternal.show();
    // _viewExternal.setData(rewardListData);
    // _viewExternal.updateWindow();
    public function CViewExternalUtil(viewClass:Class, rootView:CViewHandler, rootUI:View) {
        _view = new viewClass();

        _view.rootView = rootView;
        _view.rootUI = rootUI;

        _view.create();
    }

    public function get view() : CViewBase {
        return _view;
    }
    // call queue : 1
    public function show() : void {
        _view.show();
    }
    // call queue : 2
    public function setData(v:Object) : void {
        _view.setData(v, false);
    }
    // call queue : 3
    public function updateWindow() : Boolean {
        return _view.updateWindow();
    }

    // call want hide
    public function hide() : void {
        _view.hide();
    }

    // call want dispose
    public function close() : void {
        _view.close();
    }

    private var _view:CViewBase;
}
}
