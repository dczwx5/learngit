//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/5.
 */
package kof.game.player.childrenEvent {

import QFLib.Interface.IDisposable;

import kof.game.player.CPlayerChildrenEventDispatcher;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;

public class CPlayerChildrenEventProcess implements IDisposable {
    public function CPlayerChildrenEventProcess(childrenEventDispatcher:CPlayerChildrenEventDispatcher, eventType:String) {
        _pChildrenEventDispatcher = childrenEventDispatcher;
        _eventType = eventType;
    }

    public virtual function dispose() : void {
        _pChildrenEventDispatcher = null;
    }

    public virtual function process(newDataObject:Object, oldPlayerData:CPlayerData) : void {

    }
    public virtual function dispatch(playerData:CPlayerData) : void {
        if (_isChange) {
            _pChildrenEventDispatcher.netHandler.system.dispatchEvent(new CPlayerEvent(_eventType, playerData));
        }
    }
    public function reset() : void {
        _isChange = false;
    }

    protected var _pChildrenEventDispatcher:CPlayerChildrenEventDispatcher;
    protected var _isChange:Boolean;
    protected var _eventType:String;
}
}
