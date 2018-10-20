//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/4/26.
 */
package kof.game.cultivate.view.embattle {

import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.CRootView;
import kof.game.player.data.CPlayerData;
import kof.ui.master.cultivate.CultivateEmbattleUI;

public class CCultivateEmbattleView extends CRootView {
    public function CCultivateEmbattleView() {
        super(CultivateEmbattleUI, [CCultivateEmbattleBuff, CCultivateEmbattleHeroList], null, false);
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);

        heroListView.setArgs(_initialArgs);
    }
    protected override function _onCreate() : void {
        _isFrist = true;
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

    }

    protected override function _onHide() : void {


    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();
        return true;
    }


//    public function get chatView() : CCultivateChat { return this.getChild(0) as CCultivateChat; }
    public function get buffView() : CCultivateEmbattleBuff { return this.getChild(0) as CCultivateEmbattleBuff; }
    public function get heroListView() : CCultivateEmbattleHeroList { return this.getChild(1) as CCultivateEmbattleHeroList; }

    public function showBuffActivedMovie() : void {
        buffView.showBuffActivedMovie();
    }

    [Inline]
    public function get _ui() : CultivateEmbattleUI {
        return (rootUI as CultivateEmbattleUI);
    }
    [Inline]
    private function get _climpData() : CClimpData {
        return super._data[0] as CClimpData;
    }
    [Inline]
    private function get _cultivateData() : CCultivateData {
        return _climpData.cultivateData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _isFrist:Boolean = true;
}
}
