//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/17.
 */
package kof.game.common.view.component.handler {

import morn.core.components.Box;
import morn.core.components.List;

public class CListItemScaleEffectHandler implements IUIEffectHandler {
    private var _list:List;
    private var _scaleAddBySelect:Number;
    public function CListItemScaleEffectHandler(list:List, scaleAddBySelect:Number) {
        _list = list;
        _scaleAddBySelect = scaleAddBySelect;
    }

    public function clear() : void {
        var cells:Vector.<Box> = _list.cells;
        for (var i:int = 0; i < cells.length; i++) {
            var item:Box = cells[i];
            var scale:Number = item.scale - 1;
            if (scale > 0) {
                item.y += (scale*item.height/2);
                item.scale = 1.0;
            }
        }
    }

    public function handler() : void {
        if (_list.array == null) return ;

        var selectIndex:int = _list.selectedIndex;
        var selectItem:Box = _list.getCell(selectIndex);
        var items:Vector.<Box> = _list.cells;
        var resetItemList:Vector.<Box> = new Vector.<Box>();
        for (var i:int = 0; i < items.length; i++) {
            var item:Box = items[i] as Box;
            if (item != selectItem) {
                if (item.scale > 1) {
                    resetItemList.push(item);
                }
            }
        }

        // 设置好scale
        selectItem.scale += _scaleAddBySelect;
        for each (var resetItem:Box in resetItemList) {
            resetItem.scale -= _scaleAddBySelect;
        }

        // 布局
        for (i = 0; i < _list.cells.length; i++) {
            if (i != 0) {
                var preItem:Box = _list.cells[i-1];
                item = _list.cells[i];
                item.x = preItem.x + preItem.displayWidth + _list.spaceX;
            } else {
                item = _list.cells[i];
                item.x = 0;
            }
        }

        // 根据缩放再次设置坐标
        for each (resetItem in resetItemList) {
            resetItem.y += _scaleAddBySelect*resetItem.height/2;
        }
        selectItem.y -= _scaleAddBySelect*selectItem.height/2;

    }

}
}
