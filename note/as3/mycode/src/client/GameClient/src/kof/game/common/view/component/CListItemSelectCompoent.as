//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/13.
 */
package kof.game.common.view.component {


import kof.game.common.view.CViewBase;

import morn.core.components.List;
import morn.core.handlers.Handler;

public class CListItemSelectCompoent extends CUICompoentBase {

    public function CListItemSelectCompoent(view:CViewBase, list:List, startFunc:Function, endFunc:Function) {
        super(view);
        _list = list;
        _startFunc = startFunc;
        _endFunc = endFunc;
        _list.selectHandler = new Handler(_onSelectItem);
        refresh();
    }
    public override function dispose() : void {
        super.dispose();
        _list.selectHandler = null;
        _list = null;
    }
    public override function clear() : void {
        super.clear();
    }

    // list更新数据时, 要调用
    public override function refresh() : void {
        if (_list.array == null) return ;
    }

    private function _onSelectItem(idx:int) : void {
        if (_list.array == null || -1 == idx) return ;

        // 

        if (_startFunc) _startFunc.apply(null, idx);

        handleEffect();


        if (_endFunc) _endFunc.apply(null, [idx]);
    }

    private var _list:List;
    private var _startFunc:Function; // function (idx:int);
    private var _endFunc:Function; // function (idx:int);

}
}
