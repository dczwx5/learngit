//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/10.
 */
package kof.game.common.loading {

import kof.game.common.view.CChildView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.imp_common.MatchLoadingUI;
import morn.core.components.Image;


public class CMatchLoadingHeroListView extends CChildView {
    public function CMatchLoadingHeroListView() {
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
        var icon:Image;
        for (var i:int = 0; i < heroList.length; i++) {
            icon = _getImage(i+1);
            icon.url = null;
        }
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
            icon.url = CPlayerPath.getUIHeroFacePath(heroData.prototypeID);
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
    [Inline]
    private function get _matchData() : CMatchData {
        return super._data[0] as CMatchData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
    public function get heroList() : Array {
        return _initialArgs[1] as Array
    }
    private function get _team() : int {
        return _initialArgs[0] as int;
    }
}
}
