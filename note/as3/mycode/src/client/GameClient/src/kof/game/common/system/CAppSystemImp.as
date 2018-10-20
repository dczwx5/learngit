//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/13.
 */
package kof.game.common.system {


import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;

import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;

import morn.core.handlers.Handler;

public class CAppSystemImp extends CBundleSystem {
    public function CAppSystemImp() {
        super ();
    }

    public override function dispose() : void {
        super.dispose();

    }

    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();

        ret = ret && this.addBean(_listenerHandler = new CSystemListenerHandler());
        ret = ret && this.addBean(_procedureHandler = new CProcedureHandler());

        return ret;
    }

    // ==========bundle
    private var _whiteBundleList:Array;
    public function closeAllSystemBundle(exceptIDList:Array) : void {
        if (!_whiteBundleList) {
            _whiteBundleList = [SYSTEM_ID(KOFSysTags.SWITCHING), SYSTEM_ID(KOFSysTags.CHAT), SYSTEM_ID(KOFSysTags.SYSTEM_NOTICE),
                SYSTEM_ID(KOFSysTags.MAINNOTICE_SYSTEM), SYSTEM_ID(KOFSysTags.MAIN_TASK)];
        }
        var iter:Object = ctx.systemBundleIterator;
        for each (var bundle:ISystemBundle in iter) {
            if (bundle && bundle.bundleID > 0) {
                var isActived:Boolean = ctx.getUserData(bundle, ACTIVATED, false);
                if (!isActived) continue ;

                var isInWhiteList:Boolean;
                if (exceptIDList && exceptIDList.length > 0) {
                    isInWhiteList = exceptIDList.indexOf(bundle.bundleID) != -1;
                }
                if (isInWhiteList) continue;

                switch (bundle.bundleID) {}
                isInWhiteList = _whiteBundleList.indexOf(bundleID) != -1;
                if (isInWhiteList) continue;

                ctx.setUserData(bundle, ACTIVATED, false);
            }
        }

        App.tip.closeAll();
    }
   
    public function get isNotification() : Boolean {
        var v_bCurrent : Boolean = ctx.getUserData(this, NOTIFICATION, false);
        return v_bCurrent;
    }
    public function set isNotification(v:Boolean) : void {
        ctx.setUserData(this, CBundleSystem.NOTIFICATION, v);
    }
    [Inline]
    public function setActived(v:Boolean) : void {
        isActived = v;
    }
    public function get isActived() : Boolean {
        var v_bCurrent : Boolean = ctx.getUserData(this, ACTIVATED, false);
        return v_bCurrent;
    }
    public function set isActived(v:Boolean) : void {
        setActivated(v);
    }
    public function set tab(v:int) : void {
        super.setTab(v);
    }
    public function get tab() : int {
        var ret:int = ctx.getUserData(this, TAB, -1);
        return ret;
    }
    // ==========event
    public function registerEventType(eventType:String) : void {
        _listenerHandler.registerEventType(eventType);
    }

    public function listenEvent(func:Function) : void {
        _listenerHandler.listenEvent(func);
    }

    public function unListenEvent(func:Function) : void {
        _listenerHandler.unListenEvent(func);
    }

    public function sendEvent(event:Event) : Boolean {
        return this.dispatchEvent(event);
    }

    // handle : 可以为null, 则isFinishHandler之后, 就通过, 可以用来等待某个条件完成之后, 通过
    // isFinishHandler : 可以为null, 直接通过, 不阻塞
    // 如果handle和isFinishHandler都为非null, 则调用一次handler, 并且, isFinishHandler return ture时通过
    // * handler和isFinishHandler不可以是同一个函数, 会死循环
    public function addSequential(handler:Handler, isFinishHandler:Function) : void {
        _procedureHandler.addSequential(handler, isFinishHandler);
    }

    [Inline]
    public function isLastProcedureTagFail(theProcedureTags:Object) : Boolean {
        return CProcedureHandler.isLastProcedureTagFail(theProcedureTags);
    }
    [Inline]
    // func = function() : Boolean { true is finish }
    public function setProcedureFinishedHandler(theProcedureTags:Object, func:Function) : void {
        _procedureHandler.setProcedureFinishedHandler(theProcedureTags, func);
    }

    private var _listenerHandler:CSystemListenerHandler;
    private var _procedureHandler:CProcedureHandler;
}
}
