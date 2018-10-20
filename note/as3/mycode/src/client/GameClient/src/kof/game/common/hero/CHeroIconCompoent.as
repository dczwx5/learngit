//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/21.
 */
package kof.game.common.hero {


import kof.game.common.view.CViewBase;
import kof.game.common.view.component.CUICompoentBase;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;

import morn.core.components.Box;

import morn.core.components.Image;
import morn.core.components.Label;

import morn.core.components.List;
import morn.core.handlers.Handler;

public class CHeroIconCompoent extends CUICompoentBase {

    public function CHeroIconCompoent(view:CViewBase, listComponent:List) {
        super(view);
        _list = listComponent;
        _list.renderHandler = new Handler(onRender);
    }
    public override function dispose() : void {
        super.dispose();
        _list = null;
    }
    public function setData(heroListData:Array) : void {
        _list.dataSource = heroListData;
    }
    public function onRender(item:Box, idx:int) : void {
        if (!item) return ;
        var heroData : CPlayerHeroData = item.dataSource as CPlayerHeroData;
        if (heroData == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        var icon:Image = item.getChildByName("icon_img") as Image;
        var name:Label = item.getChildByName("name_txt") as Label;
        if (icon) icon.url = CPlayerPath.getUIHeroIconBigPath(heroData.prototypeID);
        if (name) {
            name.text = heroData.heroNameWithColor;
            name.stroke = heroData.strokeColor;
        }
    }
    private var _list:List;
}
}
