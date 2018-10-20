//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/13.
 */
package kof.game.common.view.component {

import QFLib.Foundation.CMap;

import kof.game.common.view.CViewBase;

public class CUICompoentMap extends CUICompoentBase {
    public function CUICompoentMap(view:CViewBase) {
        super (view);
        _map = new CMap();
    }

    public override function dispose() : void {
        _map.loop(function (key:Class, value:IUICompeontBase) : void {
            value.dispose();
        });
        _map = null;
    }

    public override function refresh() : void {
        _map.loop(function (key:Class, value:IUICompeontBase) : void {
            value.refresh();
        });
    }

    public function addCompoent(key:Class, value:IUICompeontBase) : void {
        value.compoentMap = this;
        _map.add(key, value);
    }
    public function getCompoent(key:Class) : IUICompeontBase {
        return _map.find(key);
    }
    public function setCompoent(key:Class, value:CUICompoentBase) : void {
        if (_map.find(key)) {
            _map.remove(key);
        }
        value.compoentMap = this;
        _map.add(key, value);
    }
    public function loop(func:Function) : void {
        _map.loop(func);
    }

    private var _map:CMap;
}
}
