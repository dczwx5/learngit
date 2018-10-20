//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/3.
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.Box;

import morn.core.components.List;

public class KOFList extends List {

    protected var _mouseOverBool:Boolean;

    public function KOFList() {
        super();
    }

    public function get mouseOverBool() : Boolean{
        return _mouseOverBool;
    }

    public function set mouseOverBool( value : Boolean ) : void{
        _mouseOverBool=value;
    }

    override protected function onCellMouse(e:MouseEvent):void {
        var cell:Box = e.currentTarget as Box;
        var index:int = _startIndex + _cells.indexOf(cell);
        if (e.type == MouseEvent.CLICK || e.type == MouseEvent.ROLL_OVER || e.type == MouseEvent.ROLL_OUT) {
            if (e.type == MouseEvent.CLICK) {
                if (_selectEnable) {
                    selectedIndex = index;
                } else {
                    if(_mouseOverBool){
                        changeCellState(cell, true, index);
                    }else{
                        changeCellState(cell, true, 0);
                    }
                }
            } else if (_selectedIndex != index) {
                if(_mouseOverBool){
                    changeCellState(cell, e.type == MouseEvent.ROLL_OVER, index);
                }else{
                    changeCellState(cell, e.type == MouseEvent.ROLL_OVER, 0);
                }
            }
        }
        if (_mouseHandler != null) {
            _mouseHandler.executeWith([e, index]);
        }
    }

    override protected function changeSelectStatus():void {
        for (var i:int = 0, n:int = _cells.length; i < n; i++) {
            if(_mouseOverBool){
                changeCellState(_cells[i], _selectedIndex == _startIndex + i, _selectedIndex);
            }else{
                changeCellState(_cells[i], _selectedIndex == _startIndex + i, 1);
            }
        }
    }
}
}
