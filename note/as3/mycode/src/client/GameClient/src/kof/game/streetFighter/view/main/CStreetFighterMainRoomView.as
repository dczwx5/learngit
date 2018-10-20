//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter.view.main {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterEnterHeroData;
import kof.ui.master.StreetFighter.StreetFighterUI;
import kof.ui.master.StreetFighter.StreetFighterWarUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;


public class CStreetFighterMainRoomView extends CChildView {
    public function CStreetFighterMainRoomView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.room_fighter_enter_list.renderHandler = new Handler(_onRenderItem);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.room_fighter_enter_list.renderHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _ui.room_fighter_count_txt.text = CLang.Get("street_enter_count", {v1:_streetData.challengeCount});
        var listData:Array = _streetData.enterHeroListData.list;;
        if (listData && listData.length > 0) {
            listData.sortOn("time", Array.NUMERIC);
        }
        _ui.room_fighter_enter_list.dataSource = listData;

        return true;
    }

    private function _onRenderItem(comp:Component, idx:int) : void {
        var item:StreetFighterWarUI = comp as StreetFighterWarUI;
        if ((!comp.dataSource)) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var itemData:CStreetFighterEnterHeroData = comp.dataSource as CStreetFighterEnterHeroData;
        item.name_txt.text = itemData.name;
    }

    [Inline]
    private function get _ui() : StreetFighterUI {
        return rootUI as StreetFighterUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        return super._data[0] as CStreetFighterData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
}
}
