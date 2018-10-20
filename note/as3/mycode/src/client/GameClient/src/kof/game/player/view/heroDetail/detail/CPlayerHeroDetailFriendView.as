//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.detail {

import kof.game.common.view.CChildView;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;

public class CPlayerHeroDetailFriendView extends CChildView {
    public function CPlayerHeroDetailFriendView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
    }
    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        return true;

    }
    private function get _playerData() : CPlayerData {
        return _data[0] as CPlayerData;
    }

    private function get _heroData() : CPlayerHeroData {
        return _data[1] as CPlayerHeroData;
    }
    private function get _ui() : Object {
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL] as Object;
    }
    private function get _detailUI() : Object {
        return _ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_INFO] as Object;
    }
}
}
