//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/27.
 */
package kof.game.common.hero {

import flash.geom.Point;

import kof.game.common.view.component.handler.*;

    import QFLib.Utils.FilterUtil;

    import flash.filters.ColorMatrixFilter;

import kof.ui.master.JueseAndEqu.RoleItemUI;

import morn.core.components.Box;
import morn.core.components.FrameClip;
import morn.core.components.List;
    import morn.core.utils.ObjectUtils;

    public class CHeroListItemEffectHandler implements IUIEffectHandler {
    private var _list:List;
    private var _clip:FrameClip;

    public function CHeroListItemEffectHandler(list:List, clip:FrameClip) {
        _list = list;
        _clip = clip;
    }

    public function clear() : void {
        _clip.visible = false;
        _clip.stop();
    }

    public function handler() : void {
        if (_list.array == null) return ;

        var selectIndex:int = _list.selectedIndex;
        var selectItem:RoleItemUI = _list.getCell(selectIndex) as RoleItemUI;

        if(selectItem.img_question.visible)
        {
            return;
        }

        var tox:int = selectItem.icon_image.x - 7;
        var toy:int = selectItem.icon_image.y + 21;
        var pos:Point = new Point(tox,toy);
        pos = selectItem.localToGlobal(pos);
        pos = _list.parent.globalToLocal(pos);
        _clip.setPosition(pos.x, pos.y);
        _clip.play();
        _clip.visible = true;
    }

}
}
