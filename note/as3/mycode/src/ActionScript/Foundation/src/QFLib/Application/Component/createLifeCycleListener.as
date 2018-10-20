//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------
package QFLib.Application.Component
{
    public function createLifeCycleListener( func : Function, inherited : Boolean = false ) : ILifeCycleListener
    {
        var ret : ILifeCycleListener = new DelegateLifeCycleListener( func, inherited );
        return ret;
    }

}

import QFLib.Application.Component.CLifeCycleBeanEvent;
import QFLib.Application.Component.ILifeCycleListener;

import flash.events.EventDispatcher;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class DelegateLifeCycleListener extends EventDispatcher implements ILifeCycleListener
{

    private var _inherited : Boolean;
    private var _handler : Function;

    function DelegateLifeCycleListener( handler : Function, inherited : Boolean = false )
    {
        super( null );
        this._handler = handler;
        this._inherited = inherited;

        this.initWithEventHandlers();
    }

    private function initWithEventHandlers() : void
    {
        if ( !this._handler )
            return;

        this.addEventListener( CLifeCycleBeanEvent.BEAN_ADDED, this._handler, false, 0, true );
        this.addEventListener( CLifeCycleBeanEvent.BEAN_REMOVED, this._handler, false, 0, true );
    }

    public function get isInherited() : Boolean
    {
        return _inherited;
    }

}