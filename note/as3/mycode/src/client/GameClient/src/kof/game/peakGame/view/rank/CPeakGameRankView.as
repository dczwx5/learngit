//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.rank {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.peakGame.view.rank.honour.CPeakGameHonourView;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameRankUI;

import morn.core.handlers.Handler;

public class CPeakGameRankView extends CRootView {

    public function CPeakGameRankView() {
        super(PeakGameRankUI, [CPeakGameMyRanking, CPeakGameRankingListView, CPeakGameHonourView], null, false);
    }

    protected override function _onCreate() : void {
        _ui.tab.labels = CLang.Get("peak_rank_tab");
        _ui.txt_title_0.text = CLang.Get("common_ranking");
        _ui.txt_title_1.text = CLang.Get("common_peak_level_title");
        _ui.txt_title_2.text = CLang.Get("common_team_name");
        _ui.txt_title_3.text = CLang.Get("common_score");
        _ui.txt_title_4.text = CLang.Get("common_win_rate");
        _ui.txt_title_5.text = CLang.Get("common_em_fighter");
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.tab.selectHandler = new Handler(_onTabChange);
        _isFirst = true;
    }

    protected override function _onHide() : void {
        _ui.tab.selectHandler = null;
    }

    private var _isFirst:Boolean;
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFirst) {
            if (_peakGameData.isFirstOpenGloryHallFlag == false) {
                // 需要打开荣耀
                setTabForce(2);
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.FIRST_OPEN_GLORY_ALL));
            } else {
                setTabForce(0);
            }
            _isFirst = false;
        }

        this.addToPopupDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onTabChange(curTab:int) : void {
        if (curTab == 0) {
            // 本服
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.RANK_CHANGE_TAB, curTab));
            _ui.honorView.visible = false;
            _ui.item_list.visible = true;
        } else if (curTab == 1){
            // 赛季
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.RANK_CHANGE_TAB, curTab));
            _ui.honorView.visible = false;
            _ui.item_list.visible = true;
        } else {
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.RANK_CHANGE_TAB, curTab));
            _ui.honorView.visible = true;
            _ui.item_list.visible = false;
        }
    }
    private function setTabForce(index:int) : void {
        if (_ui.tab.selectedIndex == index) {
            _onTabChange(index);
        } else {
            _ui.tab.selectedIndex = index;
        }
    }
    //===================================get/set======================================

    [Inline]
    private function get _myRankView() : CPeakGameMyRanking { return getChild(0) as CPeakGameMyRanking; }
    [Inline]
    private function get _rankList() : CPeakGameRankingListView { return getChild(1) as CPeakGameRankingListView; }

    [Inline]
    private function get _ui() : PeakGameRankUI {
        return rootUI as PeakGameRankUI;
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
