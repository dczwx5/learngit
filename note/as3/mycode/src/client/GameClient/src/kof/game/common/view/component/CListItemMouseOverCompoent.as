//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/13.
 */
package kof.game.common.view.component {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.view.CViewBase;

import morn.core.components.Box;
import morn.core.components.List;
import morn.core.handlers.Handler;

public class CListItemMouseOverCompoent extends CUICompoentBase {

    public function CListItemMouseOverCompoent(view:CViewBase, list:List, startFunc:Function, endFunc:Function, scaleAddByOver:Number = 0) {
        super(view);
        _list = list;
        _scaleAddByOver = scaleAddByOver;
        _startFunc = startFunc;
        _endFunc = endFunc;
        _list.mouseHandler = new Handler(_onMouseHandler);
        refresh();
    }
    public override function dispose() : void {
        super.dispose();
        _list.mouseHandler = null;
        _list = null;
    }
    public override function clear() : void {
        super.clear();
        var cells:Vector.<Box> = _list.cells;
        for (var i:int = 0; i < cells.length; i++) {
            var item:Box = cells[i];
            var scale:Number = item.scale - 1;
            if (scale > 0) {
                item.x += (scale*item.width/2);
                item.y += (scale*item.height/2);
                item.scale = 1;
            }
        }
    }

    // list更新数据时, 要调用
    public override function refresh() : void {
        if (_list.array == null) return ;
    }

    private function _onMouseHandler(evt:Event, idx:int) : void {
        if (_list.array == null) return ;

        if (_scaleAddByOver > 0 == false) {
            if (_startFunc) _startFunc.apply(null, idx);
            if (_endFunc) _endFunc.apply(null, idx);
        }
        if (_startFunc) _startFunc.apply(null, idx);

        var item:Box;
        if (evt.type == MouseEvent.ROLL_OVER) {
            item = evt.currentTarget as Box;
            if (item == null) return;

            item.scale += _scaleAddByOver;
            item.x -= (_scaleAddByOver*item.width/2);
            item.y -= (_scaleAddByOver*item.height/2);
        } else if ( evt.type == MouseEvent.ROLL_OUT) {
            item = evt.currentTarget as Box;
            if (item == null) return;
            if (item.scale > 1) {
                if (idx != _list.selectedIndex) {
                    item.scale -= _scaleAddByOver;
                    item.x += (_scaleAddByOver*item.width/2);
                    item.y += (_scaleAddByOver*item.height/2);
                } else {
                    item.scale -= _scaleAddByOver;
                    item.x += (_scaleAddByOver*item.width/2);
                    item.y += (_scaleAddByOver*item.height/2);
                }
            }
        }
        if (_endFunc) _endFunc.apply(null, [idx]);
    }

    private var _list:List;
    private var _scaleAddByOver:Number;
    private var _startFunc:Function; // function (idx:int);
    private var _endFunc:Function; // function (idx:int);

}
}
