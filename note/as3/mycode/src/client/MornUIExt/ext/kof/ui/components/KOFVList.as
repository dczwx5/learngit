//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/22.
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.Box;
import morn.core.components.List;
import morn.core.components.ScrollBar;
import morn.core.components.View;

public class KOFVList extends List {

    public function KOFVList() {
        super();
    }
    override protected function renderItems():void {
        super.renderItems();
        callLater(refreshItemHeight);
    }
    private function refreshItemHeight():void{
        var totalHeight:int;
        var showHeight:int;
        for each (var cell:Box in _cells) {
            cell.y = totalHeight ;
            totalHeight += cell.height + _spaceY;
            if( cell.dataSource )
                showHeight = totalHeight;
        }
        var numX:int = _isVerticalLayout ? repeatX : repeatY;
        var numY:int = _isVerticalLayout ? repeatY : repeatX;
        var lineCount:int = Math.ceil(length / numX);
        _scrollBar.visible = showHeight > height;
        if (_scrollBar.visible) {
            _scrollBar.scrollSize = _cellSize;
            _scrollBar.thumbPercent = numY / lineCount;
            _scrollBar.setScroll(0, (lineCount - numY) * _cellSize, _startIndex / numX * _cellSize);
        } else {
            _scrollBar.setScroll(0, 0, 0);
        }
    }

    override public function set array(value:Array):void {
        exeCallLater(changeCells);
        _array = value || [];
        var length:int = _array.length;
        _totalPage = Math.ceil(length / (repeatX * repeatY));
        //重设selectedIndex
        _selectedIndex = _selectedIndex < length ? _selectedIndex : length - 1;
        //重设startIndex
        startIndex = _startIndex;
        //重设滚动条
        if (_scrollBar) {
            //自动隐藏滚动条
            var numX:int = _isVerticalLayout ? repeatX : repeatY;
            var numY:int = _isVerticalLayout ? repeatY : repeatX;
            var lineCount:int = Math.ceil(length / numX);
//            _scrollBar.visible = _totalPage > 1;
//            if (_scrollBar.visible) {
//                _scrollBar.scrollSize = _cellSize;
//                _scrollBar.thumbPercent = numY / lineCount;
//                _scrollBar.setScroll(0, (lineCount - numY) * _cellSize, _startIndex / numX * _cellSize);
//            } else {
//                _scrollBar.setScroll(0, 0, 0);
//            }
        }
    }
}
}
