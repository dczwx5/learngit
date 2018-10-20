//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.detail {

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;

public class CPlayerHeroDetailPropertyView extends CChildView {
    public function CPlayerHeroDetailPropertyView() {
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


        var ui:Object = _detailUI;
        var selectHeroData:CPlayerHeroData = _heroData;
        if (selectHeroData) {
            ui.property_battle_value_num.num = selectHeroData.battleValue;
            ui.property_level_label.text = CLang.Get("player_level_desc", {v1:selectHeroData.level});
            ui.property_quality_label.text = CLang.Get("player_quality_desc", {v1:selectHeroData.qualityBase});
            ui.property_attack_label.text = CLang.Get("player_attack_desc", {v1:selectHeroData.propertyData.Attack});
            ui.property_defend_label.text = CLang.Get("player_defend_desc", {v1:selectHeroData.propertyData.Defense});
            ui.property_hp_label.text = CLang.Get("player_hp_desc", {v1:selectHeroData.propertyData.HP});
        }

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
