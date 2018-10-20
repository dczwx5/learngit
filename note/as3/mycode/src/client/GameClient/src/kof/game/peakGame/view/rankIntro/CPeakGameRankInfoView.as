//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.rankIntro {

import kof.game.common.view.CRootView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.data.CPlayerData;
import kof.ui.IUICanvas;
import kof.ui.master.PeakGame.PeakGameRankIntroUI;

public class CPeakGameRankInfoView extends CRootView {

    public function CPeakGameRankInfoView() {
        super(PeakGameRankIntroUI, null, null, false);
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {

    }

    protected override function _onHide() : void {
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        // this.setChildrenData(v as CPeakGameData);
    }

    // ====================================event=============================


    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameRankIntroUI {
        return rootUI as PeakGameRankIntroUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
}
}
