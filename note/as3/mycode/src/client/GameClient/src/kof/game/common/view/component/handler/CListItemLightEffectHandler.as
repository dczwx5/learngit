//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/17.
 */
package kof.game.common.view.component.handler {

    import QFLib.Utils.FilterUtil;

    import flash.filters.ColorMatrixFilter;

    import morn.core.components.Box;
    import morn.core.components.List;
    import morn.core.utils.ObjectUtils;

    public class CListItemLightEffectHandler implements IUIEffectHandler {
    private var _list:List;
    public function CListItemLightEffectHandler(list:List) {
        _list = list;
    }

    public function clear() : void {
        var cells:Vector.<Box> = _list.cells;
        for (var i:int = 0; i < cells.length; i++) {
            var item:Box = cells[i];
            ObjectUtils.clearFilter(item, ColorMatrixFilter);
        }
    }

    public function handler() : void {
        if (_list.array == null) return ;

        var selectIndex:int = _list.selectedIndex;
        var selectItem:Box = _list.getCell(selectIndex);
        var items:Vector.<Box> = _list.cells;
        for (var i:int = 0; i < items.length; i++) {
            var item:Box = items[i] as Box;
//            if (item != selectItem) {
                ObjectUtils.clearFilter(item, ColorMatrixFilter);
//            }
        }
        ObjectUtils.addFilter(selectItem, FilterUtil.brightnessControl(100));
    }

}
}
