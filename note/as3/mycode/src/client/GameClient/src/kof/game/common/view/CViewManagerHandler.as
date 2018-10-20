//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.common.view {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.tips.ITips;
import kof.game.common.view.CViewBase;
import kof.game.common.view.component.CPlayAudioCompoent;
import kof.game.common.view.control.CControlBase;
import kof.game.common.view.enum.EViewType;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.loading.CLoadingView;

import morn.core.components.Component;

public class CViewManagerHandler extends CTweenViewHandler {// CAbstractHandler {

    public var isNotHideByAuto:Boolean = false;
    public function CViewManagerHandler() {
        _isDispose = false;
    }
    public override function dispose() : void {
        super.dispose();

        if (_isDispose) return ;

        super.dispose();
        _waitingList = null;
        _isDispose = true;
        
        _controlClassMap.clear();
        _controlClassMap = null;
        _controlList.loop(function (type:int, controllerList:Array) : void {
            for each (var value:IDisposable in controllerList) {
                value.dispose();
            }
        });

        _wndClassMap.clear();
        _wndClassMap = null;

        _closeTriggerMap.clear();
        _closeTriggerMap = null;

        _showingView.loop(function (type:int, value:IDisposable) : void {
            removeBean(value);
            value.dispose();
        });
        _showingView.clear();
        _showingView = null;

        _hidingView.loop(function (type:int, value:IDisposable) : void {
            removeBean(value);
            value.dispose();
        });
        _hidingView.clear();
        _hidingView = null;

        _bundleDataList = null;

        m_pHideCallBack = null;
    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();

        _waitingList = new Array();
        _wndClassMap = new CMap();
        _closeTriggerMap = new CMap();
        _showingView = new CMap();
        _hidingView = new CMap();

        _controlClassMap = new CMap();
        _controlList = new CMap();

        _bundleDataList = new CMap();

        if (_USE_LOADING) {
            this.addViewClassHandler(EViewType.VIEW_LOADING, CLoadingView);
        }
        return ret;
    }

    public function getWindow(type:int) : CViewBase {
        var wnd:CViewBase;
        if (_showingView) wnd = _showingView.find(type);
        return wnd;
    }

    // ==========================control by bundle===========================
    public function addBundleData(wndType:int, tag:String) : void {
        var bundleData:BundleData = new BundleData();
        bundleData.tag = tag;
        bundleData.wndType = wndType;

        _bundleDataList.add(wndType, bundleData);
    }
    public function getBundleData(wndType:int) : BundleData {
        return _bundleDataList.find(wndType) as BundleData;
    }
    // =====================================================
    // closeTriggerList : Vector.<WndType> , 关闭type窗口时, 会将closeTriggerList里指定的type窗口也关闭
    public function addViewClassHandler(type:int, viewClass:Class, control:Class = null, closeTriggerList:Array = null) : void {
        _closeTriggerMap.add(type, closeTriggerList);
        _wndClassMap.add(type, viewClass);
        if (control) {
            registControl(type, control);
        }
    }
//
//    public function switchView(type:int, args:Array = null, callback:Function = null, data:Object = null) : void {
//        var view:CViewBase = this.getWindow(type);
//        if (view) {
//            hide(type);
//        } else {
//            this.show(type, args, callback, data);
//        }
//    }

    // 调用show的两个情部
    // 1 : bundle机制, 由主界面控制
    //      流程 : click -> changeData to true -> call showXXView -> call show -> isShow is true -> _showB
    // 2 : 其他调用, 直接调用showxxView
    //      流程 : call showXXView -> call show -> isShow is false -> call bundle.show -> changeData to true -> call showXXView -> call show -> isShow is True -> showB.
    // 3 : 非bundleView调用
    //      流程 : call showXXView -> call show -> _showB
    // args : params for window
    // callback(wnd:CViewBase) : void;
    // data : will call wnd.setData
    public function show(type:int, args:Array = null, callback:Function = null, data:Object = null, uiTags:int = -1) : void {
        _showB(type, args, callback, data, uiTags);
    }
    private function _showLoading() : void {
        if (_USE_LOADING) {
            _showB(EViewType.VIEW_LOADING);
        }
    }

    // 多次调用, 只会显示一次
    private function _showB(type:int, args:Array = null, callback:Function = null, data:Object = null, uiTags:int = -1) : void {
        var cls:Class = _wndClassMap.find(type);
        var showingWnd:CViewBase = _showingView.find(type);
        if (showingWnd != null) {
            if (showingWnd.isShowState) {
                // hide(type);
            }
            return ;
        }

        if (type != EViewType.VIEW_LOADING) {
            if (_USE_LOADING) {
                _showLoading();
            }
        }

        if (_hidingView.find(type) != null) {
            if ((_hidingView.find(type) as CViewBase).isHideState) {
                _reShow(type, args, callback, data, uiTags);
                return ;
            }
        }

        if (_showingCount > 0) {
            _inQueue(new WaitingData(type, args, callback, data, uiTags));
            return ;
        }
        _showingCount++;



        if (null != cls) {
            var func:Function = function (view:CViewBase) : void {
                if (null != callback) callback(view);
                _showingCount--;
                var waitingData:WaitingData = _outQueue();
                if (waitingData) {
                    show(waitingData.type, waitingData.args, waitingData.callback, waitingData.data);
                }
            };
            _showWindow(type, cls, args, func, data, uiTags);
        } else {
            Foundation.Log.logErrorMsg( "[CViewManagerHandler] type error: " + type );
        }
    }
    // callback == var func:Function = function (view:CViewBase) : void;
    private function _showWindow(type:int, wndClass:Class, args:Array, callback:Function, data:Object, uiTags:int) : void {
        var wnd:CViewBase = null;
        try {
            wnd = (new wndClass()); // (system.stage.getSystem(IUICanvas));
            this.addBean(wnd);
        } catch (e:Error) {
            throw new Error(wndClass.toString() + " 构造函数参数错误, 原型 : function Construct(uiSystem:IUICamvas)");
            return ;
        }
        wnd.type = type;
        wnd.flashStage = system.stage.flashStage;
        wnd.viewManagerHandler = this;
        wnd.addEventListener(CViewEvent.LOAD_RESOURCE_FINISH, _getViewLoadReourceFunction(wnd, callback, data));
        wnd.setArgs(args);
        wnd.setTags(uiTags);
        wnd.create();
        wnd.controlList = _addControl(type, wnd);
        _processCloseTrigger(type);

        if (_showingView.length == 0) evtEnable = true;
        _showingView.add(type, wnd);

        wnd.show();

    }

    private function _reShow(type:int, args:Array, callback:Function, data:Object, uiTags:int) : void {
        var view:CViewBase = (_hidingView.find(type) as CViewBase);
        view.flashStage = system.stage.flashStage;
        view.addEventListener(CViewEvent.LOAD_RESOURCE_FINISH, _getViewLoadReourceFunction(view, callback, data));
        view.setArgs(args);
        view.setTags(uiTags);

        view.controlList = _addControl(type, view);
        _processCloseTrigger(type);

        if (_showingView.length == 0) evtEnable = true;
        _showingView.add(type, view);
        
        view.show();
        _hidingView.remove(type);


    }
    private function _processCloseTrigger(type:int) : void {
        var closeTriggerList:Array = _closeTriggerMap.find(type);
        if (closeTriggerList) {
            for each (var closeType:int in closeTriggerList) {
                this.hide(closeType);
            }
        }
    }

    public function registControl(type:int, controlClass:Class) : void {
        var controlClassList:Array = _controlClassMap.find(type);
        if (!controlClassList) {
            controlClassList = new Array();
            _controlClassMap.add(type, controlClassList);
        }
        controlClassList.push(controlClass);
    }
    private function _addControl(type:int, wnd:CViewBase) : Array {
        var controlClassList:Array = this._controlClassMap.find(type);
        for each (var controlClass:Class in controlClassList) {
            if (controlClass) {
                var control:CControlBase = new controlClass();
                control.window = wnd;
                control.setSystem(system);
                control.create();
                var controllerList:Array = _controlList.find(type);
                if (!controllerList) {
                    controllerList = new Array();
                    _controlList.add(type, controllerList);
                }
                controllerList.push(control);
            }
        }

        return controllerList;
    }
    private function _getViewLoadReourceFunction(wnd:CViewBase, callback:Function, data:Object) : Function  {
        var func:Function = function (e:Event) : void {
            wnd.removeEventListener(CViewEvent.LOAD_RESOURCE_FINISH, func);
            if (data) {
                wnd.setData(data, false);
            }
            wnd.addEventListener(CViewEvent.SHOW, _getViewShowFunction(wnd, callback, data));
            wnd.showing();
        };
        return func;
    }
    private function _getViewShowFunction(wnd:CViewBase, callback:Function, data:Object) : Function  {
        var func:Function = function (e:Event) : void {
            wnd.removeEventListener(CViewEvent.SHOW, func);
            if (_USE_LOADING) {
                hide(EViewType.VIEW_LOADING);
            }
            wnd.invalidate();
            if (callback) callback(wnd);
        };
        return func;
    }

    public function hideAll(otherWiseWndType:int = -1) : void {
//    public function hideAll() : void {
        for each (var view:CViewBase in _showingView) {
            if (otherWiseWndType != -1 && otherWiseWndType == view.type) {
                continue;
            }
            hide(view.type);
        }
    }
    public function hide(type:int) : void {
//        closeDialog(function () : void {
            _hideA(type);
//        });
    }
    private function _hideA(type:int) : void {

        var wndClass:Class = _wndClassMap.find(type);
        if (wndClass) {
            var view:CViewBase = (_showingView.find(type) as CViewBase);
            if (view && view.waitToShow == false) {
                var bundle:BundleData = this.getBundleData(view.type);
                if (bundle) {
                    var bundleContext:ISystemBundleContext = (system as CAppSystemImp).ctx;
                    var systemBundle:ISystemBundle = bundleContext.getSystemBundle(SYSTEM_ID(bundle.tag));
                    var isActived:Boolean = bundleContext.getUserData(systemBundle, CBundleSystem.ACTIVATED ,false);
                    if (isActived) {
                        bundleContext.setUserData(systemBundle, CBundleSystem.ACTIVATED ,false);
                    } else {
                        _hideB(view);
                    }
                } else {
                    _hideB(view);
                }
            }
        }

    }
    private function _hideB(view:CViewBase) : void {
        if ( view.isHideState ) return;
        view.closeDialog(function () : void {
            _hideC(view);
        })
    }

    private function _hideC(view:CViewBase) : void {
        if (view.isHideState) return ;

        view.hide();
        _showingView.remove(view.type);

        var controllerList:Array = _controlList.find(view.type);
        if (controllerList) {
            for each (var control:IDisposable in controllerList) {
                if (control) {
                    control.dispose();
                }
            }
            _controlList.remove(view.type);
        }

        if (!view.isCloseByHide) {
            _hidingView.add(view.type, view);
        }
        if (_showingView.length == 0) {
            evtEnable = false;
        }

        if(m_pHideCallBack != null)
        {
            m_pHideCallBack.apply();
        }
    }

    public function get hideCallBack():Function
    {
        return m_pHideCallBack;
    }

    public function set hideCallBack(value:Function):void
    {
        m_pHideCallBack = value;
    }

    // tips
    public function registTips(tipsClass:Class) : void {
        if (tipsClass) this.addBean(new tipsClass());
    }

    public function addTips(tipsClass:Class, item:Component, params:Array = null) : void {
        var tips:ITips = this.getBean(tipsClass);
        if (tips) {
            tips.addTips(item, params);
        } else {
            throw new Error(tipsClass.toString() + "not children");
        }
    }
    private function _inQueue(data:WaitingData) : void {
        _waitingList.push(data);
    }
    private function _outQueue() : WaitingData {
        if (_waitingList.length == 0) return null;
        return _waitingList.shift();
    }
    public function get evtEnable() : Boolean {
        return _evtEnable;
    }
    public function set evtEnable(value:Boolean) : void {
        if (_evtEnable != value) {
            _evtEnable = value;
            // dispatchEvent(new CViewEvent(CViewEvent.EVENT_ENABLE, null, _evtEnable));
            onEvtEnable();
        }
    }
    // 实现界面打开时, 才注册事件, 当相关界面全部关闭时, 事件移除
    public virtual function onEvtEnable() : void {} // override me to add/remove events

    public function playAudio(audioPath:String) : void {
        if (_audioComponent == null) {
            _audioComponent = new CPlayAudioCompoent(null, system);
        }
        _audioComponent.play(audioPath);
    }

    public function invalidWindow(fn:Function) : void {
        callLater(fn);
    }
    public function DelayCall(delay:Number, call:Function, ...args) : void {
        delayCall.apply(null, [delay, call].concat(args));
    }
    public function addTick(call:Function, interval:Number = 0.0, ...args) : void {
        var temp:Array = [interval, call].concat(args);
        schedule.apply(null, temp);
//        schedule(interval, call, args);
    }
    public function removeTick(call:Function) : void {
        unschedule(call);
    }

    public static function HideAllSystem(stage:CAppStage) : void {
        if (!stage) return ;
        var allBeans:Vector.<Object> = stage.getBeans();
        for each (var bean:Object in allBeans) {
            if (bean is CAppSystem) {
                var viewManager:CViewManagerHandler = bean.getBean(CViewManagerHandler) as CViewManagerHandler;
                if (viewManager) {
                    viewManager.hideAll();
                }
                // todo : 改为CViewHandler的关闭接口
            }
        }
    }
    public function hideAllSystem() : void {
        var allBeans:Vector.<Object> = system.stage.getBeans();
        for each (var bean:Object in allBeans) {
            if (bean is CAppSystem) {
                var viewManager:CViewManagerHandler = bean.getBean(CViewManagerHandler) as CViewManagerHandler;
                if (viewManager && viewManager.isNotHideByAuto == false) {
                    viewManager.hideAll();
                }
                // todo : 改为CViewHandler的关闭接口
                
            }

        }
    }

    public static function OpenViewByBundle(system:CAppSystem, sysTags:String, userDataKey:String, args:Array) : void {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var bundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(sysTags));
        if (userDataKey && userDataKey.length >  0) {
            bundleCtx.setUserData(bundle, userDataKey, args);
        }
        bundleCtx.setUserData(bundle, "activated", true);
    }

    public function getCreatedWindow(type:int) : CViewBase {
        var view:CViewBase = getWindow(type);
        if (!view) {
            view = _hidingView.find(type);
        }
        return view;
    }

    public function getControllerListByType(type:int) : Array {
        return _controlList.find(type) as Array
    }

    private var _isDispose:Boolean;
    private var _showingCount:int;
    private var _waitingList:Array;

    private var _wndClassMap:CMap;
    private var _showingView:CMap;
    private var _hidingView:CMap;

    private var _controlClassMap:CMap; // key : viewClass, value : ControlClass
    private var _controlList:CMap; // key : viewClass, value : [controlObject]

    private var _closeTriggerMap:CMap; // value : Vector<type>.

    private var _evtEnable:Boolean; // 没有界面打开时, 不需要处理事件

    private var _audioComponent:CPlayAudioCompoent;

     private var _bundleDataList:CMap;

    private static const _USE_LOADING:Boolean = false;

    private var m_pHideCallBack:Function;// 关闭界面后的回调
}
}

class WaitingData {
    public function WaitingData(type:int, args:Array, callback:Function, data:Object, uiTags:int) {
        this.type = type;
        this.args = args;
        this.callback = callback;
        this.data = data;
        this.uiTags = uiTags;
    }
    public var type:int;
    public var args:Array;
    public var callback:Function;
    public var data:Object;
    public var uiTags:int;
}

class BundleData {
    public var wndType:int;
    public var tag:String;
}