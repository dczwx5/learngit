//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/21.
 */
package kof.game.common.hero {

import kof.game.common.view.CChildView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.imp_common.MatchLoadingUI;

import morn.core.components.Image;

// 只显示图片的格斗家列表, 且只有3个
public class CHeroIconListView extends CChildView {
    public function CHeroIconListView() {
    }
    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var no:Image;
        var icon:Image;
        var heroData:CPlayerHeroData;
        for (var i:int = 0; i < heroList.length; i++) {
            no = getNo(i+1);
            icon = _getImage(i+1);
            heroData = heroList[i];
            icon.url = CPlayerPath.getUIHeroIconBigPath(heroData.prototypeID);
        }

        return true;
    }

    private function getNo(no:int) : Image {
        return _ui["hero_" + _team + "_no_" + no + "_img"];
    }

    private function _getImage(no:int) : Image {
        return _ui["hero_" + _team + "_icon_" + no + "_img"];
    }


    [Inline]
    private function get _ui() : MatchLoadingUI {
        return rootUI as MatchLoadingUI;
    }
    public function get heroList() : Array {
        return _initialArgs[1] as Array
    }
    private function get _team() : int {
        return _initialArgs[0] as int;
    }
}
}
