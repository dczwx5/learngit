//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.view.reward {

import kof.game.common.view.CRootView;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.CStreetFighterRedPoint;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.ui.master.StreetFighter.StreetFighterAwardUI;

import morn.core.handlers.Handler;


public class CStreetFighterRewardView extends CRootView {

    public function CStreetFighterRewardView() {
        super(StreetFighterAwardUI, [CStreetFighterRewardRankView, CStreetFighterRewardFightView, CStreetFighterRewardScoreView], null, false);
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _isFrist = true;

        _ui.tab.selectHandler = new Handler(_onTabChange);
        _ui.red_fight_img.visible = _ui.red_rank_img.visible = _ui.red_score_img.visible = false;

    }
    protected override function _onHide() : void {
        _ui.tab.selectHandler = null;

    }
    private function _onTabChange(tabIdx:int) : void {
        _ui.item_list.visible = _ui.rank_list.visible = false;
        invalidate();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            if (_ui.tab.selectedIndex == -1) {
                _ui.tab.selectedIndex = 0;
            } else {
                _onTabChange(0);
            }
            _isFrist = false;
        }

        var hasFightReward:Boolean = CStreetFighterRedPoint.hasFightRewardCanGet(_streetData);
        var hasScoreReward:Boolean = CStreetFighterRedPoint.hasScoreRewardCanGet(_streetData);
        _ui.red_fight_img.visible = hasFightReward;
        _ui.red_score_img.visible = hasScoreReward;


        this.addToPopupDialog();

        return true;
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================


    //===================================get/set======================================

//    private function get _linksView() : CPeakGameMainLinks { return getChild(0) as CPeakGameMainLinks; }

    [Inline]
    private function get _ui() : StreetFighterAwardUI {
        return rootUI as StreetFighterAwardUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStreetFighterData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }

    private var _isFrist:Boolean = true;

}
}
