//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.view.rank {

import kof.framework.CAppSystem;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.control.CStreetFighterControler;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.rank.CStreetFighterRankData;
import kof.game.streetFighter.data.rank.CStreetFighterRankItemData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.ui.master.StreetFighter.StreetFighterrankItemUI;
import kof.ui.master.StreetFighter.StreetFighterrankUI;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.handlers.Handler;


public class CStreetFighterRankView extends CRootView {

    public function CStreetFighterRankView() {
        super(StreetFighterrankUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.item_list.renderHandler = new Handler(_onRenderItem);

        _curPage = 0;
        _ui.left_btn.clickHandler = new Handler(_onLeftPage);
        _ui.right_btn.clickHandler = new Handler(_onRightPage);
        _ui.left_max_btn.clickHandler = new Handler(_onLeftMaxPage);
        _ui.right_max_btn.clickHandler = new Handler(_onRightMaxPage);

        _ui.refresh_btn.clickHandler = new Handler(_onRefreshBtn);

    }
    protected override function _onHide() : void {
        _ui.item_list.renderHandler = null;

        _ui.left_btn.clickHandler = null;
        _ui.right_btn.clickHandler = null;
        _ui.left_max_btn.clickHandler = null;
        _ui.right_max_btn.clickHandler = null;

        _ui.refresh_btn.clickHandler = null;
    }


    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        // 我的排名
        var rankData:CStreetFighterRankData = _streetData.rankData;
        _ui.my_ranking_box.dataSource = rankData.getByPlayerUID(_playerData.ID);
        _onRenderItemB(_ui.my_ranking_box, 0, true);

        // 排名列表
        var listData:Array = rankData.list.list;
        listData.sortOn("ranking", Array.NUMERIC);
        _ui.item_list.dataSource = listData;

        _curPage = 0;
        _itemList.page = 0;
        _updatePage();

        this.addToPopupDialog();

        return true;
    }

    private function _onRenderItem(comp:Component, idx:int) : void {
        _onRenderItemB(comp, idx, false);
    }
    private function _onRenderItemB(comp:Component, idx:int, isMyRanking:Boolean) : void {
        var item : StreetFighterrankItemUI = comp as StreetFighterrankItemUI;

        var ranking : int;
        var rankItemData : CStreetFighterRankItemData = comp.dataSource as CStreetFighterRankItemData;
        if ( !isMyRanking ) {
            if ( !rankItemData ) {
                item.visible = false;
                return;
            }
        }

        item.visible = true;
        if ( rankItemData ) {
            ranking = rankItemData.ranking;
        }

        if ( ranking == 0 ) {
            item.txt_rankOut.visible = true;
        } else {
            item.txt_rankOut.visible = false;
        }

        if ( ranking > 3 || ranking == 0 ) {
            item.ranking_clip.visible = false;
            item.bg_clip.index = 3;
            item.txt_rank.visible = true;
            item.txt_rank.text = ranking.toString();
        } else {
            item.ranking_clip.visible = true;
            item.ranking_clip.index = ranking - 1;
            item.bg_clip.index = ranking - 1;
            item.txt_rank.visible = false;
        }

        if ( ranking == 0 ) {
            item.txt_rank.visible = false;
        }

        var pPlayerSystem:CPlayerSystem = ((uiCanvas as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem);
        if ( isMyRanking ) {
            pPlayerSystem.platform.signatureRender.renderSignature(_playerData.vipData.vipLv, pPlayerSystem.platform.data, item.signature, _playerData.teamData.name);

            item.score_num.num = _streetData.score;
            item.history_score_num.num = _streetData.historyHighScore;
            item.win_count_txt.text = _streetData.winCount.toString();
        } else {
//            差pllatformData
             pPlayerSystem.platform.signatureRender.renderSignature(rankItemData.vipLevel, rankItemData.platformData, item.signature, rankItemData.name);

            item.score_num.num = rankItemData.score;
            item.history_score_num.num = rankItemData.historyHighScore;
            item.win_count_txt.text = rankItemData.winCount.toString();
        }

        var embattleMaxCount:int = (controlList[0] as CStreetFighterControler).embattleMaxCount;
        var heroEmbattleList : CHeroEmbattleListView = new CHeroEmbattleListView( system, item.hero_list_view.hero_list, EInstanceType.TYPE_STREET_FIGHTER, null,
                                                        null, false, false, false, false, embattleMaxCount);
        var heroListData : Array;
        if ( isMyRanking ) {
            var embattleListData : CEmbattleListData = _playerData.embattleManager.getByType( EInstanceType.TYPE_STREET_FIGHTER );
            heroListData = _playerData.embattleManager.getHeroListByEmbattleList( embattleListData );
        } else {
            heroListData = rankItemData.heroList.list;
        }
        heroEmbattleList.updateData( EInstanceType.TYPE_STREET_FIGHTER, heroListData );
        heroEmbattleList.updateWindow();
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onRefreshBtn() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.RANK_REFRESH));
    }
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
        _itemList.visible = true;
        _itemList.page = _curPage;
        _ui.page.text = (_itemList.page + 1).toString();
    }

    //===================================get/set======================================

//    private function get _linksView() : CPeakGameMainLinks { return getChild(0) as CPeakGameMainLinks; }
    private function get _itemList() : List {
        return _ui.item_list;
    }
    [Inline]
    private function get _ui() : StreetFighterrankUI {
        return rootUI as StreetFighterrankUI;
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
    private var _curPage:int; // _curPage == 0 说明是显示第三列表, _curPage > 0 显示其他列表, _curPage-1, 其他列表的页数

}
}
