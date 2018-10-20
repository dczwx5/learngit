//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/29.
 */
package kof.game.playerTeam.view.team_new {


import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.player.data.CPlayerVisitData;
import kof.game.player.enum.EPlayerWndResType;
import kof.ui.master.player_team.PlayerTeamUI;

import morn.core.handlers.Handler;


public class CTeamNewViewHandler extends CRootView {

    public function CTeamNewViewHandler() {
        super(PlayerTeamUI, [CTeamBaseView, CTeamSystemView], EPlayerWndResType.TEAM_NEW_MAIN, false);
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        baseView.setArgs(_initialArgs);
        this.setChildrenData(v, forceInvalid);
    }
    protected override function _onCreate() : void {
        _ui.tab.dataSource = [CLang.Get("team_tab_base"), CLang.Get("team_tab_sys")];
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        _ui.tab.selectHandler = new Handler(_onSelectTab);
//        if (_ui.tab.selectedIndex == 0) {
//            _onSelectTab(0);
//        } else {
//            _ui.tab.selectedIndex = _ui.tab.selectedIndex;
//        }
        _onSelectTab(_ui.tab.selectedIndex);
        _ui.tab.visible = false;
     }

    protected override function _onHide() : void {
        _ui.tab.selectHandler = null;
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

//
        this.addToDialog(KOFSysTags.PLAYER_TEAM, _onAddFinishB);

        return true;
    }

    private function _onAddFinishB() : void {
        var sLabel:String = CLang.Get("team_tab_labels");
        if (_ui.tab.labels != sLabel) {
            _ui.tab.labels = sLabel;
        } else {
            _ui.tab.space = _ui.tab.space; // 强制刷新下tab
        }
        _ui.tab.visible = true;
    }

    private function _onSelectTab(index:int) : void {
        if (0 == index) {
            // 基础页
            _ui.base_view.visible = true;
            _ui.sys_view.visible = false;
             invalidate();
        } else {
            // 系统页
            _ui.sys_view.visible = true;
            _ui.base_view.visible = false;
            invalidate();
        }

    }

    private function get _ui() : PlayerTeamUI {
        return rootUI as PlayerTeamUI;
    }
    [Inline]
    private function get _visitPlayerData() : CPlayerVisitData {
        return super._data[0] as CPlayerVisitData;
    }

    public function get baseView() : CTeamBaseView {
        return this.getChild(0) as CTeamBaseView;
    }
}
}

