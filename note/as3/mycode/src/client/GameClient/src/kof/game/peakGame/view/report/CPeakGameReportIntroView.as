//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/4.
 */
package kof.game.peakGame.view.report {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.data.CPlayerData;
import kof.ui.IUICanvas;
import kof.ui.master.PeakGame.PeakGameReportIntroUI;

public class CPeakGameReportIntroView extends CRootView {

    public function CPeakGameReportIntroView() {
        super(PeakGameReportIntroUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _ui.desc_txt.text = CLang.Get("peak_report_intro_desc");
        this.setNoneData();
    }
    protected override function _onDispose() : void {

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToPopupDialog();

        return true;
    }

    // ====================================event=============================

    // ==================================event=======================================

    //===================================get/set======================================


    [Inline]
    private function get _ui() : PeakGameReportIntroUI {
        return rootUI as PeakGameReportIntroUI;
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
