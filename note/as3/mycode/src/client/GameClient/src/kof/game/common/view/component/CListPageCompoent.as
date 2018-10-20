//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/13.
 */
package kof.game.common.view.component {

import kof.game.common.view.CViewBase;

import morn.core.components.Button;
import morn.core.components.List;
import morn.core.handlers.Handler;

// 左右, 上下翻页
public class CListPageCompoent extends CUICompoentBase {
    public function CListPageCompoent(view:CViewBase, list:List, leftBtn:Button, rightBtn:Button, startFunc:Function, endFunc:Function) {
        super(view);
        _list = list;
        _list.repeatX
        _leftBtn = leftBtn;
        _rightBtn = rightBtn;
        _itemCount = _list.repeatX;
        _startFunc = startFunc;
        _endFunc = endFunc;
        _leftBtn.clickHandler = new Handler(_onLeft);
        _rightBtn.clickHandler = new Handler(_onRight);
        _curPage = _list.page;
        refresh();
    }
    public override function dispose() : void {
        super.dispose();

        _leftBtn.clickHandler = null;
        _leftBtn = null;
        _rightBtn.clickHandler = null;
        _rightBtn = null;
        _list = null;
    }

    // list更新数据时, 要调用
    public override function refresh() : void {
        _curPage = -1;
        _pageCount = -1;
        if (_list.array == null) return ;
        _curPage = _list.page;
        _pageCount = int((_list.array.length-1)/_itemCount) + 1;
    }

    public function getPageByIndex(index:int) : int {
        return int(index/_itemCount);

    }

    private function _onLeft() : void {
        if (_curPage == 0) return ;
        _curPage--;
        _onChange(true, true);
    }
    private function _onRight() : void {
        if (_curPage == _pageCount - 1) return ;
        _curPage++;
        _onChange(false, true);
    }
    private function _onChange(isLeft:Boolean, isSelectFirst:Boolean) : void {
        if (_list.array == null) return ;
        if (_startFunc) _startFunc.apply(null, [isLeft]);

        if (_curPage < 0) _curPage = 0;
        if (_curPage >= _pageCount) _curPage = _pageCount - 1;
        _list.page = _curPage;
        this._compoentMap.loop(function (key:Class, value:IUICompeontBase) : void {
            if (value != this) {
                value.clear();
            }
        });
        if (isSelectFirst) {
            _list.selectedIndex = _curPage*_itemCount;
        }

        if (_endFunc) _endFunc.apply(null, [isLeft]);
    }

    public function get page() : int {
        return _curPage;
    }
    public function set page(v:int) : void {
        _curPage = v;
        _onChange(false, true);
    }

    public function setSelectedIndex(index:int, forceChange:Boolean = false) : void {
        var page:int = getPageByIndex(index);
        if (_curPage != page) {
            var isLeft:Boolean = page < _curPage;
            _curPage = page;
            _onChange(isLeft, false);
        }
        if (forceChange) {
            _list.selectedIndex = -1;
        }
        _list.selectedIndex = index;
        // _list.refresh();
    }
    private var _list:List;

    private var _startFunc:Function; // function (isLeft:Boolean);
    private var _endFunc:Function; // function (isLeft:Boolean);
    private var _leftBtn:Button;
    private var _rightBtn:Button;

    private var _curPage:int = -1; // 当前页0开始
    private var _pageCount:int = -1; // 总页数
    private var _itemCount:int = -1; // 一页可显示的对象数量

}
}
