//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.view.rank {

import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.view.CChildView;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameRankData;
import kof.game.peakGame.data.CPeakGameRankItemData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.peakGame.view.CPeakGamePlayerTips;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameRankSpecialItemUI;
import kof.ui.master.PeakGame.PeakGameRankUI;

import morn.core.components.Box;

import morn.core.components.List;
import morn.core.handlers.Handler;


public class CPeakGameRankingListView extends CChildView {
    public function CPeakGameRankingListView() {
    }
    protected override function _onCreate() : void {
        _heroItemRender = new CHeroListItemRender();
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _curPage = 0;
        _ui.left_btn.clickHandler = new Handler(_onLeftPage);
        _ui.right_btn.clickHandler = new Handler(_onRightPage);
        _ui.left_max_btn.clickHandler = new Handler(_onLeftMaxPage);
        _ui.right_max_btn.clickHandler = new Handler(_onRightMaxPage);

//        _ui.special_list.renderHandler = new Handler(_onRenderSpecialItem);
        _ui.item_list.renderHandler = new Handler(_onRenderItem);

    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.left_btn.clickHandler = null;
        _ui.right_btn.clickHandler = null;
        _ui.left_max_btn.clickHandler = null;
        _ui.right_max_btn.clickHandler = null;
//        _ui.special_list.renderHandler = null;
        _ui.item_list.renderHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        if (_peakGameData.isServerData == false) {
            return true;
        }

        if (_ui.tab.selectedIndex == 2) return true;

        var peakSystem:CPeakGameSystem = system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem;
        _heroItemRender.isShowQuality = peakSystem.isShowQuality;
        _heroItemRender.isShowLevel = peakSystem.isShowLevel;

        var rankData:CPeakGameRankData;
        if (_ui.tab.selectedIndex == 0) {
            rankData = _peakGameData.rankDataOne;
        } else {
            rankData = _peakGameData.rankDataMulti;
        }

        var listData:Array = rankData.list.list;
        listData.sortOn("ranking", Array.NUMERIC);

//        var i:int = 0;
//        // 前3数据
//        var specialListData:Array = new Array();
//        for (; i < 3 && i < listData.length; i++) {
//            specialListData[i] = listData[i];
//        }
//
//        // 后面的数据
//        var itemListData:Array = new Array();
//        for (i = 3; i < listData.length; i++) {
//            itemListData[i-3] = listData[i];
//        }

//        _specialList.dataSource = specialListData;
        _itemList.dataSource = listData;

        _curPage = 0;
        _itemList.page = 0;

        _updatePage();

        return true;
    }

    private function _onRenderItem(box:Box, idx:int) : void {
        _onRenderSpecialItem(box, idx);
//        _onRenderOtherItem(box, idx);
    }

    private function _onRenderSpecialItem(box:Box, idx:int) : void {
        var item:PeakGameRankSpecialItemUI = box as PeakGameRankSpecialItemUI;
        if (!item) return ;
        if (null == item.dataSource) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        item.txt_rankOut.visible = false;

        var data:CPeakGameRankItemData = item.dataSource as CPeakGameRankItemData;

        if (data.ranking > 3) {
            item.ranking_clip.visible = false;
            item.bg_clip.index = 3;
            item.txt_rank.visible = true;
            item.txt_rank.text = data.ranking.toString();
        } else {
            item.ranking_clip.visible = true;
            item.ranking_clip.index = data.ranking-1;
            item.bg_clip.index = data.ranking-1;
            item.txt_rank.visible = false;
        }


        item.name_txt.text = data.name;
        item.score_txt.text = data.score.toString();
        item.win_rate_txt.text = data.winPercentString;
        item.hero_list.renderHandler = new Handler(_heroItemRender.renderItemSimpleSmall);
        item.hero_list.dataSource = data.heroList.list;

        var levelRecord:PeakScoreLevel = _peakGameData.getLevelRecordByID(data.peakLevel);
        CPeakGameLevelItemUtil.setValue(item.peak_level_btn, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName, false);

        item.toolTip = new Handler(addTips, [CPeakGamePlayerTips, item, [data]]);

    }
//
//    private function _onRenderOtherItem(box:Box, idx:int) : void {
//        var item:PeakGameRankItemUI = box as PeakGameRankItemUI;
//        if (!item) return ;
//        if (null == item.dataSource) {
//            item.visible = false;
//            return ;
//        }
//        var data:CPeakGameRankItemData = item.dataSource as CPeakGameRankItemData;
//        item.my_rank_title_txt.visible = false;
//
//        item.ranking_txt.text = data.ranking.toString();
//        item.name_txt.text = data.name;
//        item.score_txt.text = data.score.toString();
//        item.win_rate_txt.text = data.winPercentString;
//        item.hero_list.renderHandler = new Handler(_heroItemRender.renderItemFlat);
//        item.hero_list.dataSource = data.heroList.list;
//        item.visible = true;
//        item.toolTip = new Handler(addTips, [CPeakGamePlayerTips, item, [data]]);
//        item.bg_clip.index = 0;
//        var levelRecord:PeakScoreLevel = _peakGameData.getLevelRecordByID(data.peakLevel);
//        CPeakGameLevelItemUtil.setValue(item.peak_level_btn, levelRecord.levelId, levelRecord.subLevelId);
//
//    }
    // ==============page================
    private function _onLeftMaxPage() : void {
        if (_curPage == 0) {
            return ;
        }
        _curPage = 0;
        _updatePage();
    }
    private function _onRightMaxPage() : void {
        var itemPage:int = _curPage + 1;
        if (itemPage >= _itemList.totalPage) {
            return ;
        }
        _curPage = _itemList.totalPage;
        _updatePage();
    }
    private function _onLeftPage() : void {
        if (_curPage == 0) {
            return ;
        }
        _curPage--;
        _updatePage();
    }
    private function _onRightPage() : void {
        var itemPage:int = _curPage + 1;
        if (itemPage >= _itemList.totalPage) {
            return ;
        }
        _curPage++;
        _updatePage();
    }

    private function _updatePage() : void {
//        if (_curPage == 0) {
//            _specialList.visible = true;
//            _itemList.visible = false;
//            _ui.page.text = "1";
//            _ui.my_ranking_box.bg_clip.index = 0;
//        } else {
//            _specialList.visible = false;
//            _itemList.visible = true;
//            _itemList.page = _curPage - 1;
//            _ui.page.text = (_itemList.page + 2).toString();
//            _ui.my_ranking_box.bg_clip.index = 1;
//        }
        _itemList.visible = true;
        _itemList.page = _curPage;
        _ui.page.text = (_itemList.page + 1).toString();
    }

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

//    private function get
//    private function get _listView() : List {
//        return _ui.item_list;
//    }

//    private function get _specialList() : List {
//        return _ui.special_list;
//    }
    private function get _itemList() : List {
        return _ui.item_list;
    }

    private var _curPage:int; // _curPage == 0 说明是显示第三列表, _curPage > 0 显示其他列表, _curPage-1, 其他列表的页数
    private var _heroItemRender:CHeroListItemRender;
}
}
