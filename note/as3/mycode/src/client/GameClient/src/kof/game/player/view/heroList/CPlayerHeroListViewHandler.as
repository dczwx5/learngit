//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/9.
 */
package kof.game.player.view.heroList {

import kof.game.common.view.CChildView;
import kof.game.player.view.heroList.list.CPlayerHeroListListView;

public class CPlayerHeroListViewHandler extends CChildView {

    public function CPlayerHeroListViewHandler() {
        super([CPlayerHeroListListView], null);
    }


    
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
    }

    // v[0] : heroDataList, v[1] : heroTable
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        listView.setData(v, forceInvalid);
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        // this.addToDialog();
        return true;
    }

    public function get listView() : CPlayerHeroListListView { return getChild(_HERO_LIST) as CPlayerHeroListListView; }

    private static const _HERO_LIST:int = 0;


}
}

