//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.view.rank {

import kof.game.common.CLang;
import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.view.CChildView;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameRankData;
import kof.game.peakGame.data.CPeakGameRankItemData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.peakGame.view.CPeakGamePlayerTips;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.ui.master.PeakGame.PeakGameRankSpecialItemUI;
import kof.ui.master.PeakGame.PeakGameRankUI;

import morn.core.handlers.Handler;


public class CPeakGameMyRanking extends CChildView {
    public function CPeakGameMyRanking() {
    }
    protected override function _onCreate() : void {
        _heroItemRender = new CHeroListItemRender();
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex == 2) return true;

        var item:PeakGameRankSpecialItemUI = _ui.my_ranking_box;
        var peakSystem:CPeakGameSystem = system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem;

        _heroItemRender.isShowQuality = peakSystem.isShowQuality;
        _heroItemRender.isShowLevel = peakSystem.isShowLevel;

        var score:int = 0;
        var winRate:String = "";
        var ranking:int = 0;
        var winCount:int = 0;
        var fightCount:int = 0;
        if (_peakGameData.isServerData) {
            // rankData
            var rankData:CPeakGameRankData;
            if (_ui.tab.selectedIndex == 0) {
                rankData = _peakGameData.rankDataOne;
            } else {
                rankData = _peakGameData.rankDataMulti;
            }

            var rankItemData:CPeakGameRankItemData = rankData.getByPlayerUID(_playerData.ID);
            if (rankItemData) {
                ranking = rankItemData.ranking;
            }

            CPeakGameLevelItemUtil.setValue(item.peak_level_btn, _peakGameData.peakLevelRecord.levelId,
                    _peakGameData.peakLevelRecord.subLevelId, _peakGameData.peakLevelRecord.levelName, false);

            score = _peakGameData.score;
            winRate = _peakGameData.winRate;
            winCount = _peakGameData.winCount;
            fightCount = _peakGameData.fightCount;
        }

        if (ranking == 0) {
            item.txt_rankOut.visible = true;
//            item.txt_rank.text = CLang.Get("peak_rank_none");
//            item.txt_rank.color = "0xfff447";
        } else {
            item.txt_rankOut.visible = false;
//            item.txt_rank.text = ranking.toString();
//            item.txt_rank.color = "0xc2dbff";
        }

        if (ranking > 3 || ranking ==0) {
            item.ranking_clip.visible = false;
            item.bg_clip.index = 3;
            item.txt_rank.visible = true;
            item.txt_rank.text = ranking.toString();
        } else {
            item.ranking_clip.visible = true;
            item.ranking_clip.index = ranking-1;
            item.bg_clip.index = ranking-1;
            item.txt_rank.visible = false;
        }

        if (ranking ==0) {
            item.txt_rank.visible = false;
        }

//        item.my_rank_title_txt.text = CLang.Get("peak_my_rank_title");
//        item.my_rank_title_txt.visible = true;

//        item.name_txt.color = item.score_txt.color = item.win_rate_txt.color = "0xb3cdf1";
//        item.name_txt.stroke = item.score_txt.stroke = item.win_rate_txt.stroke = "0x26416b";
        item.name_txt.text = _playerData.teamData.name;
        item.score_txt.text = score.toString();
        item.win_rate_txt.text = winRate;

        item.hero_list.renderHandler = new Handler(_heroItemRender.renderItemSimpleSmall);
        var embattleListData:CEmbattleListData = peakSystem.embattleListData;
        var heroList:Array = _playerData.embattleManager.getHeroListByEmbattleList(embattleListData);
        item.hero_list.dataSource = heroList;
        item.visible = true;

        var iPeakBattleValue:int = _playerData.embattleManager.getPowerByEmbattleType(peakSystem.embattleType);
        var tipsData:Object = new Object();
        tipsData.name = _playerData.teamData.name;
        tipsData.level = _playerData.teamData.level;
        tipsData.winCount = winCount;
        tipsData.fightCount = fightCount;
        tipsData.allFightBattleValue = iPeakBattleValue;
        tipsData.heroList = heroList;
        tipsData.clubName = _playerData.guideData.clubName;
        item.toolTip = new Handler(addTips, [CPeakGamePlayerTips, item, [tipsData]]);
        return true;
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

    private var _heroItemRender:CHeroListItemRender;
}
}
