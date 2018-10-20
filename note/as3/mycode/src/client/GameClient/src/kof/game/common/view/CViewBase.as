//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.common.view {

import QFLib.Interface.IDisposable;

import flash.display.DisplayObjectContainer;
import flash.display.Stage;

import flash.events.Event;

import flash.events.MouseEvent;

import kof.framework.CViewHandler;

import kof.game.common.view.Interface.IWindow;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.viewBaseComponent.CViewBaseChildrenList;
import kof.game.common.view.viewBaseComponent.CViewBaseLoadAfterShow;
import kof.game.common.view.viewBaseComponent.CViewBaseRootUI;
import kof.game.common.view.viewBaseComponent.CViewBaseStage;
import kof.game.common.view.viewBaseComponent.CViewBaseStatus;
import kof.game.reciprocation.CReciprocalSystem;
import kof.ui.IUICanvas;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.View;
import morn.core.handlers.Handler;
import morn.core.managers.ResLoader;

// new : _onShowing : 传入数据之后, 显示界面之前调用. 2017.5.10

// 规则
// x._onCreate() => _onShow() => _onLoadUnLockResource() => _onHide() => _onDispose()
// 0.创建, new XXWindow().create(), create需要主动调用
// 1.父层与子层都在同一个界面, 子层只是父层进行区域划分
// 2.最上层窗口_rootView，只有最上层窗口会加载_rootUI资源, 并创建
// 3.总ui资源_rootUI
// 4.dirty 上层会覆盖下层
// 5.可以在任何时候调用show, 即使资源并未创建
// 6.窗口流程分别为 _onCreate(),  _onShow(), _onLoadUnLockResource(), _onHide(), _onDispose()
//      override _onCreate : 代替构造函数, 资源加载完调用
//      override _onDispose : 代替dispose
//      override _onShow : 代替 show, show之前调用, 最上层需要调用addToParent， 将_rootUI add 到舞台
//      override _onHide : 代替 hide, 自动奖_rootUi remove
//      show与hide, 都会传递子层
//      _onShow与_onCreate 都可以初始化数据,
//          _onCreate只会调用一次, _onShow在_closeByHide == false时, 也会调用多次
//          _onCreate 在 show之前调用
//      _onLoadUnLockResource : 加载非阻塞资源完毕, create之后, show之后
// 7.updateWindow, 不需要主动调用, 外部调用invalidate强制更新界面(下一帧)
// 8.setData == _data : 窗口基础数据
// 9._initialArgs : 补充数据
// 10.调用CViewManagerHandler.show, hide, 而不要直接调用show, hide方法, or 调用close方法
// 11.close方法支持CViewManagerHandler创建界面, 或独立界面

public class CViewBase extends CTweenViewHandler implements IWindow, IDisposable {
    private var _swfRes:Array; // [[uiClassList], [x.swfList]]

    public function CViewBase(rootClass:*, childListClass:Array, swfRes:Array, isRoot:Boolean, closeByHide:Boolean = true) {
        super();
        _isLoadFinish = false;

        _swfRes = swfRes;
        _isCloseByHide = closeByHide;

        _rootUI = new CViewBaseRootUI(rootClass, isRoot); // ok
        _rootUI.closeHandle = new Handler(_onClose);
        _rootUI.rootUiChangeHandle = new Handler(_onRootUiChange);

        _childList = new CViewBaseChildrenList(this, childListClass); // ok
//        _loadResource = new CViewBaseLoadResource(swfRes); // ok

        _stage = new CViewBaseStage(this);
        _stage.renderHandle = new Handler(_onRender);
        _stage.resizeHandle = new Handler(_onResize);
        _stage.enterFrameHandle = new Handler(_onEnterFrame);
        _stage.stageClickHandle = new Handler(_onStageClick);

        _status = new CViewBaseStatus(); // ok
    }

    // =================dispose
    override public function dispose() : void {
        super.dispose();

        if (isDisposeState) return ;
        if (isShowState) {
            _hideProcess();
        }

        if (_childList) {
            _childList.dispose();
            _childList = null;
        }

        _onDispose();

        _rootUI.dispose();
        _rootUI = null;

        _parentView = null;
        _initialArgs = null;
        _data = null;
        _isNoneData = false;

        _status.dispose();
        _status = null;

        _stage.dispose();
        _stage = null;

        _pControlList = null;

        this.dispatchEvent(new CViewEvent(CViewEvent.DISPOSE));
    }
    protected virtual function _onDispose() : void { throw new Error("override _onDispose instead of dispose"); }

    // =================create
    // 使用parent的数据初始化
    public function buildByParent(parent:CViewBase) : void {
        _stage.flashStage = parent.flashStage;
        _parentView = parent;
        _rootUI.rootUI = parent.rootUI;
        _rootUI.rootView = parent.rootView;
        _isCloseByHide = parent._isCloseByHide;
        _viewManagerHandler = parent._viewManagerHandler;
    }
    final public function create() : void {
        _status.loadingResource();

        if (_swfRes && _swfRes.length > 0) {
            this.loadAssetsByView(_swfRes[0], _onBlockResourceFinish);
        } else {
            _onBlockResourceFinish();
        }

//        _loadResource.load(_onBlockResourceFinish, _onUnBlockResourceFinish);
    }
    protected override function get additionalAssets() : Array {
        if (_swfRes && _swfRes.length > 1) {
            return _swfRes[1];
        }
        return null;
    }

    private function _onBlockResourceFinish() : void {
        _rootUI.create();
        _childList.create(this);
        _onCreate();
        _status.created();

        dispatchEvent(new CViewEvent(CViewEvent.CREATE));
        if (_status.waitToShow) {
            show();
            _status.waitToShow = false;
        }
    }
//    private function _onUnBlockResourceFinish() : void {
//        this.dispatchEvent(new CViewEvent(CViewEvent.UNLOCK_RESOURCE_FINISH));
//
//        _loadResource.dispose();
//        _loadResource = null;
//    }
    protected virtual function _onCreate() : void { throw new Error("override _onCreate instead of construct"); }

    // ===================show
    final public function show():void {
        if (isUnReadyState || isLoadingResouceState) {
            _status.waitToShow = true;
            return ;
        }
        _status.waitToShow = false;

        if (isShowState || isDisposeState) {
            return ;
        }

        _rootUI.show();

        _onShow();

        if (_childList) {
            _childList.show();
        }

        _stage.show();

        _status.showed();

        this.dispatchEvent(new CViewEvent(CViewEvent.LOAD_RESOURCE_FINISH));
        _isLoadFinish = true;
    }
    final public function showing() : void {
        _onShowing();
        if (_childList) {
            _childList.showing();
        }

        if (_loadAfterShow) {
            _loadAfterShow.load(_showingB);
        } else {
            this.dispatchEvent(new CViewEvent(CViewEvent.SHOW));
        }
    }

    private function _showingB() : void {
        this.dispatchEvent(new CViewEvent(CViewEvent.SHOW));
    }
    protected virtual function _onShowing() : void { throw new Error("override _onShowing instead of show"); }
    protected virtual function _onShow() : void { throw new Error("override _onShow instead of show"); }

    // ================hide 不要直接调用hide方面, 调用close
    final public function hide() : void {
        if (_status.isHideState) return ;
        if (_status.waitToShow) return ;

        if (_isCloseByHide) {
            this.dispose();
        } else {
            _hideProcess();
        }
    }
    private function _hideProcess() : void {
        if (_childList) {
            _childList.hide();
        }

        _rootUI.hide();

        _onHide();
        _initialArgs = null;
        _data = null;
        _status.hided();
        this.dispatchEvent(new CViewEvent(CViewEvent.HIDE));

        _stage.hide();
    }
    protected virtual function _onHide() : void { throw new Error("override _onHide instead of hide"); }

    // =========close
    public function close() : void {
        _onClose();
    }
    protected function _onClose() : void {
        if (_viewManagerHandler) {
            _viewManagerHandler.hide(type);
        } else {
            this.hide();
        }

        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        reciprocalSystem.removeEventPopWindow( this.viewId );
    }

    // ==================================================================================================
    protected override function updateDisplay() : void {
        super.updateDisplay();
        _onRender();
    }
    private function _onRender() : void {
//        if (_stage.isInvalid()) {
//            updateWindow();
//        }
        // 有可能 回调的时候。界面已经关闭了
        if (isShowState) {
            updateWindow();
        }
    }

    /**
     * dirty flag 不同步的问题, render事件miss, 有以下两种情况
     *  1.事件已注册, 且未释放事件, dirty为true, 界面未关闭, 这种情况, 在调用invalidate时, 只要重新调用stage.invalidate即可
     *  2.界面已关闭, 事件已移除, dirty为false, 则在界面关闭时, 同步dirty flag即可
     */
    public override function invalidate() : void {
         super.invalidate();
        _childList.invalidate();
//        _stage.invalidate();

//        callLater(_onRender);
    }
    public function invalidateWithoutChildren() : void {
//        if (_stage.isValid()) {
//            _stage.invalidate();
//        } else {
//            // dirty. 可能是render丢失了
//            _stage.invalidateStage();
//        }
        super.invalidate();
//        _stage.invalidate();
    }

    // _data need not null when updateWindow call, except you don't need _data
    public function updateWindow() : Boolean {
//        trace(this.className + " | - updateWindow");

        if (_data == null && _isNoneData == false) {
            // call setNoneData in _onShow if no data
//            _stage.validate();
            throw new Error("data can't be null");
        }

//        if (_stage.isValid()) {
//            _stage.removeRenderEvent();
//            return false;
//        }
//        _stage.validate();

        return true;
    }

    // call by _stage
    protected virtual function _onEnterFrame(delta:Number) : void {

    }
    protected virtual function _onStageClick(e:MouseEvent) : void {

    }
    protected virtual function _onResize(e:Event) : void {

    }

    // ===event
    public function sendEvent(e:Event) : void {
        if (_rootUI.rootView && e) {
            _rootUI.rootView.dispatchEvent(e);
        }
    }
    public function listenEvent(type:String, func:Function) : void {
        if (_rootUI.rootView) {
            _rootUI.rootView.addEventListener(type, func);
        }
    }
    public function unlistenEvent(type:String, func:Function) : void {
        if (_rootUI.rootView) {
            _rootUI.rootView.removeEventListener(type, func);
        }
    }
    // =======================

    public function addToParent(parent:DisplayObjectContainer) : void {
        if (this._rootUI.isRoot && isAddToParent() == false) {
            parent.addChild(_rootUI.rootUI);
        }
    }
    public function addToDialog(sysTag:String = null, onShowEnd:Function = null) : void {
        if (this._rootUI.isRoot && isAddToParent() == false) {
            if (sysTag && sysTag.length > 0) {
                setTweenData(sysTag);
            }
            showDialog(_rootUI.rootUI, false, onShowEnd);
        }
    }
    public function addToPopupDialog() : void {
        if (this._rootUI.isRoot && isAddToParent() == false) {
            uiCanvas.addPopupDialog(_rootUI.rootUI);
        }
    }
    public function addToRoot() : void {
        if (this._rootUI.isRoot && isAddToParent() == false) {
            uiCanvas.rootContainer.addChild(_rootUI.rootUI);
        }
    }
    public function addToLoading() : void {
        if (this._rootUI.isRoot && isAddToParent() == false) {
            uiCanvas.loadingLayer.addChild(_rootUI.rootUI);
        }
    }

    public function loadSwf(url:String) : void {
        if (!_loadAfterShow) {
            _loadAfterShow = new CViewBaseLoadAfterShow();
        }
        _loadAfterShow.addUiResource(url, ResLoader.SWF);
    }
    public function loadBmd(url:String) : void {
        if (!_loadAfterShow) {
            _loadAfterShow = new CViewBaseLoadAfterShow();
        }
        _loadAfterShow.addUiResource(url, ResLoader.BMD);
    }

    // =========================get/set=========================
    public function setArgs(v:Array) : void {
        _initialArgs = v;
    }
    public function setTags(v:int) : void {
        _rootUI.setTags(v);
    }
    public function get childList() : Array {
        return _childList.childList;
    }
    public function getChild(type:int) : IWindow {
        return _childList.getChild(type);
    }
    public function getChildByType(clazz:Class) : IWindow {
        return _childList.getChildByType(clazz);
    }
    public function getData() : Object {
        return _data;
    }

    public function setData(v:Object, forceInvalid:Boolean = true) : void {
        _data = v;
        if (forceInvalid) {
            this.invalidate();
        }
    }

    // 第一层child设置相同的数据
    public function setChildrenData(data:Object, forceInvalid:Boolean = true) : void {
        _childList.setData(data, forceInvalid);
    }

    // 不需要_data的界面, 在_onShow时, 需要调用该函数
    public function setNoneData() : void {
        _isNoneData = true;
    }
    public function setChildrenNoneData() : void {
        _childList.setNoneData();
    }
    public function set flashStage(v:Stage) : void {
        _stage.flashStage = v;
        _childList.flashStage = v;
    }
    public function get flashStage() : Stage {
        return _stage.flashStage;
    }
    public function isAddToParent() : Boolean {
        return rootUI.parent != null;
    }
    final public function get isCloseByHide() : Boolean {
        return _isCloseByHide;
    }
    private function _onRootUiChange(v:View) : void {
        rootUI = v;
    }
    final public function get rootUI() : View {
        return _rootUI.rootUI;
    }
    // 可动态改变, 需要通知children
    public function set rootUI(v:View) : void {
        _rootUI.rootUI = v;
        _childList.rootUI = v;
    }
//    public function set uiCanvas(v:IUICanvas) : void {
//        _uiSystem = v;
//    }
//    public function get uiCanvas() : IUICanvas {
//        return _uiSystem;
//    }
    public function set rootView(v:CViewHandler) : void {
        _rootUI.rootView = v;
    }
    public function get rootView() : CViewHandler { return _rootUI.rootView; }

    final public function get parentView() : CViewBase {
        return _parentView;
    }
    public function get viewManagerHandler() : CViewManagerHandler {
        return _viewManagerHandler;
    }
    public function set viewManagerHandler(v:CViewManagerHandler) : void {
        _viewManagerHandler = v;
    }
    // set in _onShow or _onCreate
    public function set listEnterFrameEvent(v:Boolean) : void {
        _stage.listEnterFrameEvent = v;
    }
    public function set listStageClick(v:Boolean) : void {
        _stage.listStageClick = v;
    }
    public function get dialog() : Dialog {
        return rootUI as Dialog;
    }
    public function set popupCenter(v:Boolean) : void {
        var dialog:Dialog = this.dialog;
        if (dialog) {
            if (dialog.popupCenter != v) {
                dialog.popupCenter = v;
            }
        }
    }

    public function addTips(tipsClass:Class, item:Component, params:Array = null) : void {
        if (null != tipsClass && _viewManagerHandler) _viewManagerHandler.addTips(tipsClass, item, params);
    }
    // parentUI : viewClass所在的ui
    public function showByExternal(viewClass:Class, parentUI:View, data:Object) : void {
        var externalUtil:CViewExternalUtil = new CViewExternalUtil(viewClass, rootView, parentUI);
        externalUtil.show();
        externalUtil.setData(data);
        externalUtil.updateWindow();
    }
    public function addTick(call:Function, interval:Number = 0.0, ...args) : void {
        var temp:Array = [call, interval].concat(args);
        viewManagerHandler.addTick.apply(null, temp);
    }
    public function removeTick(call:Function) : void {
        viewManagerHandler.removeTick(call);

    }
    public function DelayCall(delay:Number, call:Function,  ...args) : void {
        super.delayCall.apply(null, [delay, call].concat(args)); // viewManagerHandler.DelayCall.apply(null, [delay, call].concat(args));
    }

    [Inline]
    public override function get uiCanvas() : IUICanvas {
        if (_rootUI.isRoot == false) {
            return _rootUI.rootView.uiCanvas;
        }
        return super.uiCanvas;
    }

    public function get controlList() : Array {
        return _pControlList;
    }
    public function set controlList(v:Array) : void {
        _pControlList = v;
    }

    final public function get isUnReadyState() : Boolean { return _status.isUnReadyState; }
    final public function get isLoadingResouceState() : Boolean { return _status.isLoadingResouceState; }
    final public function get isCreateState() : Boolean { return _status.isCreateState; }
    final public function get isShowState() : Boolean { return _status.isShowState; }
    final public function get isHideState() : Boolean { return _status.isHideState; }
    final public function get isDisposeState() : Boolean { return _status.isDisposeState; }
    final public function get waitToShow() : Boolean { return _status.waitToShow; }
    public function get isLoadResourceFinish() : Boolean {
        return _isLoadFinish;
    }
    // component
//    private var _loadResource:CViewBaseLoadResource;
    private var _childList:CViewBaseChildrenList;
    protected var _stage:CViewBaseStage;
    private var _status:CViewBaseStatus;
    private var _rootUI:CViewBaseRootUI;
    private var _loadAfterShow:CViewBaseLoadAfterShow; // show之后动态加载的资源

    //
    protected var _viewManagerHandler:CViewManagerHandler;
    protected var _parentView:CViewBase; // 父级窗口

    // data
    protected var _data:Object; // 窗口需要的数据, 比如武将列表, 则data是一个武将的array,
    protected var _initialArgs:Array; // 初始参数, 比如打开武将列表界面, 希望设置选中某个武将, 则设置 args参数

    //
    protected var _isCloseByHide:Boolean;
    private var _isNoneData:Boolean; // 界面是否不需要_data

    //
    public var type:int; // window type EPlayerWndType for PlayerSystem

    private var _isLoadFinish:Boolean; // 是否加载完毕

    private var _pControlList:Array; // controlBase
}
}

