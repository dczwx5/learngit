//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/10.
 */
package kof.game.common.view.bundle {

import flash.events.EventDispatcher;

import kof.framework.events.CEventPriority;
import kof.game.bundle.CBundleSystem;

import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;

public class CViewBundleComponent extends EventDispatcher implements ISystemBundle {
    public function CViewBundleComponent() {

    }

    public function dispose() : void {
        this.removeEventListener(CSystemBundleEvent.BUNDLE_START, _onBundleStart);
        this.removeEventListener(CSystemBundleEvent.BUNDLE_STOP, _onBundleStop);
        this.removeEventListener(CSystemBundleEvent.USER_DATA, _onBundleUserData);

        _pBundleContext.unregisterSystemBundle(this);
        _pBundleContext = null;
    }
    public function create() : void {
        if (_pBundleContext) {
            _pBundleContext.registerSystemBundle(this);

            addEventListener(CSystemBundleEvent.BUNDLE_START, _onBundleStart, false, CEventPriority.DEFAULT, true);
            addEventListener(CSystemBundleEvent.BUNDLE_STOP, _onBundleStop, false, CEventPriority.DEFAULT, true);
            addEventListener(CSystemBundleEvent.USER_DATA, _onBundleUserData, false, CEventPriority.DEFAULT, true);
        }
    }

    private function _onBundleStart(event:CSystemBundleEvent) : void {
        // 功能开启
        if (_startHandler != null) {
            _startHandler();
        }
    }
    private function _onBundleStop(event:CSystemBundleEvent) : void {

    }
    private function _onBundleUserData(event:CSystemBundleEvent) : void {
        if (_pBundleContext) {
//            if (event.propertyData.propertyName == CBundleSystem.ACTIVATED) {
                var vCurrent:Boolean = _pBundleContext.getUserData(this, CBundleSystem.ACTIVATED, false);
                if (_activeHandler != null) {
                    _activeHandler(vCurrent);
                }
//            }
        }
    }
    public function close() : void {
        if (_pBundleContext) {
            _pBundleContext.setUserData(this, CBundleSystem.ACTIVATED, false);
        }
    }

    public function set isActived(v:Boolean) : void {
        if (_pBundleContext) {
            _pBundleContext.setUserData(this, CBundleSystem.ACTIVATED, v);
        }
    }
    public function get tab() : int {
        return _pBundleContext.getUserData(this, CBundleSystem.TAB, -1);
    }
    public function set tab(v:int) : void {
        if (_pBundleContext) {
            _pBundleContext.setUserData(this, CBundleSystem.TAB, v);
        }
    }

    public function set bundleContext(v:ISystemBundleContext) : void {
        _pBundleContext = v;
    }
    public function get bundleID() : * {
        return _bundleID;
    }
    public function set bundleID(v:int) : void {
        _bundleID = v;
    }
    // function (isActived:Boolean) : void ;
    public function set activeHandler(v:Function) : void {
        _activeHandler = v;
    }
    public function set startHandler(v:Function) : void {
        _startHandler = v;
    }
    private var _pBundleContext:ISystemBundleContext;
    private var _bundleID:int;
    private var _activeHandler:Function;
    private var _startHandler:Function;
}
}
