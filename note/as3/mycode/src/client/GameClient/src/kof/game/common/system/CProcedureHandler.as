//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/18.
 */
package kof.game.common.system {

import QFLib.Foundation.CProcedureManager;

import kof.framework.CAbstractHandler;

import morn.core.handlers.Handler;

public class CProcedureHandler extends CAbstractHandler {

    public function CProcedureHandler() {

    }

    public override function dispose() : void {
        super.dispose();


    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    public function addSequential(handler:Handler, isFinishHandler:Function) : void {
        if (!m_pProcedureManager) {
            m_pProcedureManager = new CProcedureManager( 30 );
        }
        var item:_CProcedureItem = new _CProcedureItem();
        item.handler = handler;
        item.isFinishHandler = isFinishHandler;
        item.pProcedureHandler = this;
        m_pProcedureManager.addSequential(item.onSequentialCheckHandler);
    }

    [Inline]
    public static function isLastProcedureTagFail(theProcedureTags:Object) : Boolean {
        var isNotFinish:Boolean = theProcedureTags.lastProcedureTag && theProcedureTags.lastProcedureTag.result == false;
        return isNotFinish;
    }
    [Inline]
    // func = function() : Boolean { true is finish }
    public function setProcedureFinishedHandler(theProcedureTags:Object, func:Function) : void {
        theProcedureTags.isProcedureFinished = func;
    }

    private var m_pProcedureManager:CProcedureManager;
}
}

import kof.game.common.system.CProcedureHandler;

import morn.core.handlers.Handler;

class _CProcedureItem {
    public var handler:Handler;
    public var isFinishHandler:Function;
    public var pProcedureHandler:CProcedureHandler;

    public function onSequentialCheckHandler(theProcedureTags:Object) : Boolean {
        if (CProcedureHandler.isLastProcedureTagFail(theProcedureTags)) {
            return false;
        }
        if (isFinishHandler) {
            pProcedureHandler.setProcedureFinishedHandler(theProcedureTags, isFinishHandler);
        }

        if (handler) {
            handler.method.apply(null, handler.args);
        }

        return true;
    }

}
